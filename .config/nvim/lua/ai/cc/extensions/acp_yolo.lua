-- ACP Yolo Mode Extension for CodeCompanion (smart deny-list policy)
--
-- Monkey-patches ACPHandler.handle_permission_request. When yolo mode is on
-- (gty), every permission request is auto-approved by default. The only
-- exceptions are command-execution tools whose title matches a small static
-- deny list (truly destructive commands or fetch-piped-to-shell), or `rm`
-- commands that the smart analyzer judges unsafe.
--
-- If codecompanion refactors the patched internals, the extension disables
-- itself with a warning and normal prompts resume.
--
-- opts schema:
--   notify             boolean  (default true)   — notify on auto-approve
--   record             boolean  (default true)   — record to inspector
--   command_exec_kinds string[] (default {'execute','bash','other'})
--                                                — kinds whose title runs through
--                                                  destructive/anonymous-exec/rm checks
--   force_prompt_kinds string[] (default {})     — always prompt for these kinds
--   rm_safe_paths      string[] (default {})     — extra safe paths for `rm`
--   adapters           string[] (default nil)    — adapters that participate;
--                                                  nil/empty = all adapters
--
-- Commands:
--   :CodeCompanionAcpYoloInspector  — show all intercepted permission requests

local M = {}

---@type table[] History of intercepted permission requests
local history = {}

---Record a permission request for inspection
---@param entry table
local function record(entry)
    entry.timestamp = os.date('%H:%M:%S')
    table.insert(history, entry)
end

-- ── Static deny patterns ───────────────────────────────────────────────────

local DESTRUCTIVE_PATTERNS = {
    '^sudo ',
    'mkfs',
    'dd if=',
    '> /dev/',
    '%f[%w]format ',
    'pkill ',
    'killall ',
    'chown ',
    'chmod %-R',
}

local ANONYMOUS_EXEC_PATTERNS = {
    'curl[^|]*|%s*sh',
    'curl[^|]*|%s*bash',
    'curl[^|]*|%s*zsh',
    'wget[^|]*|%s*sh',
    'wget[^|]*|%s*bash',
    'iwr[^|]*|%s*iex',
    'Invoke%-WebRequest[^|]*|%s*Invoke%-Expression',
    'bash%s*<%(',
    'sh%s*<%(',
    'zsh%s*<%(',
}

local DEFAULT_RM_SAFE_SEGMENTS = {
    'node_modules',
    'target',
    'dist',
    'build',
    '.cache',
    '.next',
    '.nuxt',
    'vendor',
    '__pycache__',
    '.pytest_cache',
    '.turbo',
}

---Return the list of safe absolute path prefixes for `rm`.
---@param extra string[]|nil
---@return string[]
local function rm_safe_prefixes(extra)
    local prefixes = { '/tmp/', '/var/tmp/' }
    local cache = vim.fn.stdpath('cache')
    if type(cache) == 'string' and cache ~= '' then
        table.insert(prefixes, cache:gsub('\\', '/') .. '/')
    end
    for _, env_var in ipairs({ 'TMPDIR', 'TEMP', 'TMP' }) do
        local v = os.getenv(env_var)
        if v and v ~= '' then
            table.insert(prefixes, v:gsub('\\', '/') .. '/')
        end
    end
    if extra then
        for _, p in ipairs(extra) do
            if type(p) == 'string' and p ~= '' then
                local norm = p:gsub('\\', '/')
                if not norm:match('/$') then
                    norm = norm .. '/'
                end
                table.insert(prefixes, norm)
            end
        end
    end
    return prefixes
end

---Find the first matching pattern in `title` from `patterns`.
---@param title string|nil
---@param patterns string[]
---@return string|nil matched_pattern
local function first_match(title, patterns)
    if not title then
        return nil
    end
    for _, pat in ipairs(patterns) do
        if title:find(pat) then
            return pat
        end
    end
    return nil
end

---Lookup helper: list contains string (case-sensitive).
---@param list string[]|nil
---@param needle string
---@return boolean
local function list_has(list, needle)
    if not list then
        return false
    end
    for _, v in ipairs(list) do
        if v == needle then
            return true
        end
    end
    return false
end

-- ── Smart `rm` analyzer ────────────────────────────────────────────────────

local RECURSIVE_FLAGS = {
    ['-r'] = true,
    ['-R'] = true,
    ['-rf'] = true,
    ['-fr'] = true,
    ['-Rf'] = true,
    ['-fR'] = true,
}

---Naive whitespace split that respects simple single/double quotes. Returns
---tokens or nil on quoting we can't handle.
---@param s string
---@return string[]|nil
local function split_args(s)
    local tokens = {}
    local i, n = 1, #s
    while i <= n do
        local c = s:sub(i, i)
        if c == ' ' or c == '\t' then
            i = i + 1
        elseif c == "'" or c == '"' then
            local quote = c
            local j = s:find(quote, i + 1, true)
            if not j then
                return nil
            end
            table.insert(tokens, s:sub(i + 1, j - 1))
            i = j + 1
        else
            local j = i
            while j <= n do
                local ch = s:sub(j, j)
                if ch == ' ' or ch == '\t' or ch == "'" or ch == '"' then
                    break
                end
                j = j + 1
            end
            table.insert(tokens, s:sub(i, j - 1))
            i = j
        end
    end
    return tokens
end

---Run a command and return (ok, stdout). Treats timeout/failure to spawn as not-ok.
---@param argv string[]
---@param timeout_ms integer
---@return boolean ok
---@return string stdout
local function sys_run(argv, timeout_ms)
    local ok, result = pcall(function()
        return vim.system(argv, { text = true }):wait(timeout_ms)
    end)
    if not ok or type(result) ~= 'table' then
        return false, ''
    end
    return result.code == 0, result.stdout or ''
end

---Check whether `path` is git-tracked + clean inside `cwd`.
---Returns 'safe' if tracked + clean, 'unsafe' if tracked + modified, nil otherwise.
---@param path string
---@param cwd string
---@return string|nil
local function git_state(path, cwd)
    local ok = sys_run({ 'git', '-C', cwd, 'ls-files', '--error-unmatch', '--', path }, 2000)
    if not ok then
        return nil -- not tracked or not in repo
    end
    local _, out = sys_run({ 'git', '-C', cwd, 'status', '--porcelain', '--', path }, 2000)
    if out == '' then
        return 'safe'
    end
    return 'unsafe'
end

---Path matches a safe-prefix or contains a safe-segment.
---@param abs_path string
---@param prefixes string[]
---@return boolean
local function path_is_safe(abs_path, prefixes)
    local norm = abs_path:gsub('\\', '/')
    for _, prefix in ipairs(prefixes) do
        if norm:sub(1, #prefix) == prefix then
            return true
        end
    end
    for _, seg in ipairs(DEFAULT_RM_SAFE_SEGMENTS) do
        if norm:find('/' .. seg .. '/', 1, true) or norm:match('/' .. seg .. '$') then
            return true
        end
    end
    return false
end

---Smart `rm` check.
---@param title string  -- full command title, starting with `rm `
---@param cwd string
---@param extra_safe_paths string[]|nil
---@return string verdict  -- 'safe' | 'unsafe' | 'unknown'
---@return string detail   -- short reason for inspector
local function smart_rm_check(title, cwd, extra_safe_paths)
    local rest = title:match('^rm%s+(.+)$')
    if not rest then
        return 'unknown', 'rm with no arguments'
    end
    local tokens = split_args(rest)
    if not tokens then
        return 'unknown', 'unparseable quoting'
    end

    local paths = {}
    local seen_double_dash = false
    for _, tok in ipairs(tokens) do
        if seen_double_dash then
            table.insert(paths, tok)
        elseif tok == '--' then
            seen_double_dash = true
        elseif RECURSIVE_FLAGS[tok] or tok:match('^%-%-recursive') then
            return 'unsafe', 'recursive flag ' .. tok
        elseif tok:sub(1, 1) == '-' then
            -- harmless flag (-i, -v, -f without r). Ignore.
        else
            table.insert(paths, tok)
        end
    end

    if #paths == 0 then
        return 'unknown', 'no path argument'
    end
    if #paths > 1 then
        return 'unsafe', string.format('%d paths', #paths)
    end

    local path = paths[1]
    if path:find('[*?{%[]') then
        return 'unsafe', 'wildcard in path'
    end

    local abs = vim.fn.fnamemodify(path, ':p')
    if abs == nil or abs == '' then
        return 'unknown', 'cannot resolve path'
    end

    local prefixes = rm_safe_prefixes(extra_safe_paths)
    if path_is_safe(abs, prefixes) then
        return 'safe', 'in safe-path allowlist'
    end

    local verdict = git_state(path, cwd)
    if verdict == 'safe' then
        return 'safe', 'tracked + clean (recoverable from git)'
    elseif verdict == 'unsafe' then
        return 'unsafe', 'tracked but modified/staged'
    end
    return 'unsafe', 'untracked / not in git repo'
end

-- ── Inspector ──────────────────────────────────────────────────────────────

---Pick the one-line status icon for an entry
---@param entry table
---@return string icon
---@return string label
local function status_of(entry)
    if entry.auto_approved then
        return '✓', '✓ approve'
    end
    if entry.reason and entry.reason:match('^denied') or entry.reason == 'force_prompted' then
        return '✗', '✗ deny   '
    end
    return '·', '· prompt '
end

---@param entry table
---@param max_width integer
---@return string
local function short_detail(entry, max_width)
    local r = entry.reason
    local d = entry.detail_reason or ''
    if r == 'auto_approved_default' then
        d = entry.detail_reason or 'default auto-approve'
    elseif r == 'auto_approved_smart_rm' then
        d = 'rm safe: ' .. (entry.detail_reason or '')
    elseif r == 'denied_destructive' then
        d = "destructive '" .. (entry.matched_pattern or '?') .. "'"
    elseif r == 'denied_anonymous_exec' then
        d = "anon-exec '" .. (entry.matched_pattern or '?') .. "'"
    elseif r == 'denied_smart_rm_unsafe' then
        d = 'rm unsafe: ' .. (entry.detail_reason or '')
    elseif r == 'denied_smart_rm_unknown' then
        d = 'rm unknown: ' .. (entry.detail_reason or '')
    elseif r == 'force_prompted' then
        d = "force_prompt '" .. (entry.tool_call and entry.tool_call.kind or '?') .. "'"
    elseif r == 'yolo_mode_off' then
        d = 'yolo mode is off'
    elseif r == 'no_tool_kind' then
        d = 'no tool kind'
    elseif r == 'adapter_not_participating' then
        d = "adapter '" .. (entry.adapter or '?') .. "' not in adapters list"
    elseif r == 'no_allow_once_option' then
        d = 'no allow_once option'
    end
    if vim.fn.strdisplaywidth(d) > max_width then
        d = d:sub(1, max_width - 1) .. '…'
    end
    return d
end

---@param detail_width integer
---@param expanded table<integer,boolean>
---@return string[] lines
---@return table<integer,integer|false> line_to_entry
local function render_lines(detail_width, expanded)
    local lines = {}
    local line_to_entry = {}
    local function push(line, entry_idx)
        table.insert(lines, line)
        line_to_entry[#lines] = entry_idx or false
    end

    push(string.format('ACP Yolo Inspector — %d entries', #history))
    push(string.format('%-4s %-9s %-9s %-9s %s', '#', 'TIME', 'STATUS', 'TOOL', 'DETAIL'))

    if #history == 0 then
        push('')
        push('(no permission requests recorded yet)')
    else
        for i, entry in ipairs(history) do
            local _, status_label = status_of(entry)
            local tool_kind = (entry.tool_call and entry.tool_call.kind) or '<none>'
            push(
                string.format(
                    '%-4d %-9s %-9s %-9s %s',
                    i,
                    entry.timestamp or '--:--:--',
                    status_label,
                    tool_kind:sub(1, 9),
                    short_detail(entry, detail_width)
                ),
                i
            )
            if expanded[i] then
                local tc = entry.tool_call or {}
                local function det(label, value)
                    local text = tostring(value == nil and '<nil>' or value)
                    text = text:gsub('[\r\n]+', ' ⏎ ')
                    push(string.format('       %-16s %s', label, text), i)
                end
                det('adapter:', entry.adapter)
                det('tool kind:', tc.kind)
                det('title:', tc.title)
                det('matched pattern:', entry.matched_pattern)
                det('yolo_mode:', tostring(entry.yolo_mode))
                det('reason:', entry.reason)
                det('detail_reason:', entry.detail_reason)
                det('responded_with:', entry.responded_with)
                if tc.locations and #tc.locations > 0 then
                    for li, loc in ipairs(tc.locations) do
                        det(
                            li == 1 and 'locations:' or '',
                            vim.inspect(loc, { newline = ' ', indent = '' })
                        )
                    end
                else
                    det('locations:', '<none>')
                end
                if entry.options and #entry.options > 0 then
                    for oi, opt in ipairs(entry.options) do
                        det(
                            oi == 1 and 'options:' or '',
                            string.format('%s  (%s)', opt.optionId or '<nil>', opt.kind or '<nil>')
                        )
                    end
                end
                push('', i)
            end
        end
    end

    push('')
    push('[j/k] move  [<CR>] expand  [c] clear  [q] close')
    return lines, line_to_entry
end

local function open_inspector()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = 'codecompanion_acp_yolo_inspector'
    vim.bo[buf].bufhidden = 'wipe'

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' ACP Yolo Inspector ',
        title_pos = 'center',
    })
    vim.wo[win].winhl = 'Normal:NormalFloat,FloatBorder:FloatBorder'

    local expanded = {}
    local detail_width = math.max(20, width - 34)
    local line_to_entry = {}

    local function rerender(preserve_entry_idx)
        local lines
        lines, line_to_entry = render_lines(detail_width, expanded)
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        if preserve_entry_idx then
            for lnum, idx in ipairs(line_to_entry) do
                if idx == preserve_entry_idx then
                    pcall(vim.api.nvim_win_set_cursor, win, { lnum, 0 })
                    return
                end
            end
        end
    end

    local function entry_under_cursor()
        local lnum = vim.api.nvim_win_get_cursor(win)[1]
        local idx = line_to_entry[lnum]
        return idx and idx ~= false and idx or nil
    end

    rerender()

    vim.keymap.set('n', '<CR>', function()
        local idx = entry_under_cursor()
        if not idx then
            return
        end
        expanded[idx] = not expanded[idx] or nil
        rerender(idx)
    end, { buffer = buf, silent = true, desc = 'Toggle expand' })

    vim.keymap.set('n', 'c', function()
        M.exports.clear_history()
        expanded = {}
        rerender()
    end, { buffer = buf, silent = true, desc = 'Clear history' })

    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- ── Setup ──────────────────────────────────────────────────────────────────

function M.setup(opts)
    opts = opts or {}

    local ok_handler, Handler = pcall(require, 'codecompanion.interactions.chat.acp.handler')
    if not ok_handler or type(Handler) ~= 'table' then
        vim.notify('[acp_yolo] Cannot load ACPHandler — extension disabled', vim.log.levels.WARN)
        return
    end

    local ok_approvals, approvals = pcall(require, 'codecompanion.interactions.chat.tools.approvals')
    if not ok_approvals or type(approvals) ~= 'table' then
        vim.notify('[acp_yolo] Cannot load Approvals — extension disabled', vim.log.levels.WARN)
        return
    end

    if type(Handler.handle_permission_request) ~= 'function' then
        vim.notify(
            '[acp_yolo] ACPHandler.handle_permission_request missing — extension disabled',
            vim.log.levels.WARN
        )
        return
    end

    if type(approvals.is_approved) ~= 'function' then
        vim.notify('[acp_yolo] Approvals.is_approved missing — extension disabled', vim.log.levels.WARN)
        return
    end

    local utils = require('codecompanion.utils')
    local notify = opts.notify ~= false
    local should_record = opts.record ~= false
    local command_exec_kinds = opts.command_exec_kinds or { 'execute', 'bash', 'other' }
    local force_prompt_kinds = opts.force_prompt_kinds or {}
    local rm_safe_paths = opts.rm_safe_paths or {}
    local adapters_filter = opts.adapters

    local original = Handler.handle_permission_request

    function Handler:handle_permission_request(request)
        local bufnr = self.chat.bufnr
        local kind = request.tool_call and request.tool_call.kind
        local title = request.tool_call and request.tool_call.title
        local adapter_name = self.chat.adapter and self.chat.adapter.name
        local yolo_on = approvals:is_approved(bufnr)

        local tc = request.tool_call
        local entry = {
            bufnr = bufnr,
            adapter = adapter_name,
            yolo_mode = yolo_on,
            auto_approved = false,
            reason = nil,
            options = {},
            tool_call = tc and {
                toolCallId = tc.toolCallId,
                kind = tc.kind,
                title = tc.title,
                status = tc.status,
                locations = tc.locations,
            } or nil,
        }
        for _, opt in ipairs(request.options or {}) do
            table.insert(entry.options, { kind = opt.kind, optionId = opt.optionId })
        end

        local function fall_through(reason, detail)
            entry.reason = reason
            entry.detail_reason = detail
            if should_record then
                record(entry)
            end
            return original(self, request)
        end

        if not yolo_on then
            return fall_through('yolo_mode_off', 'yolo mode is off')
        end
        if not kind then
            return fall_through('no_tool_kind', 'request has no tool kind')
        end
        if adapters_filter and #adapters_filter > 0 and not list_has(adapters_filter, adapter_name) then
            return fall_through(
                'adapter_not_participating',
                string.format("adapter '%s' not in adapters list", adapter_name or '<unknown>')
            )
        end
        if list_has(force_prompt_kinds, kind) then
            return fall_through('force_prompted', "force_prompt_kinds includes '" .. kind .. "'")
        end

        -- Title checks only apply to command-execution kinds.
        if list_has(command_exec_kinds, kind) and title and title ~= '' then
            local destructive = first_match(title, DESTRUCTIVE_PATTERNS)
            if destructive then
                entry.matched_pattern = destructive
                return fall_through(
                    'denied_destructive',
                    "title matched destructive pattern '" .. destructive .. "'"
                )
            end
            local anon = first_match(title, ANONYMOUS_EXEC_PATTERNS)
            if anon then
                entry.matched_pattern = anon
                return fall_through(
                    'denied_anonymous_exec',
                    "title matched anonymous-exec pattern '" .. anon .. "'"
                )
            end
            if title:match('^rm%s') or title == 'rm' then
                local cwd = vim.fn.getcwd()
                local verdict, detail = smart_rm_check(title, cwd, rm_safe_paths)
                if verdict == 'unsafe' then
                    return fall_through('denied_smart_rm_unsafe', detail)
                elseif verdict == 'unknown' then
                    return fall_through('denied_smart_rm_unknown', detail)
                else
                    -- 'safe' falls through to auto-approve below, but tag the reason.
                    entry.reason = 'auto_approved_smart_rm'
                    entry.detail_reason = detail
                end
            end
        end

        -- Auto-approve path.
        local allow_id
        for _, opt in ipairs(request.options or {}) do
            if opt.kind == 'allow_once' then
                allow_id = opt.optionId
                break
            end
        end
        if not allow_id then
            return fall_through('no_allow_once_option', 'ACP request had no allow_once option')
        end

        entry.auto_approved = true
        if not entry.reason then
            entry.reason = 'auto_approved_default'
            entry.detail_reason = 'default auto-approve'
        end
        entry.responded_with = allow_id
        if should_record then
            record(entry)
        end

        if notify then
            utils.notify(
                string.format('Auto-approved: %s', title or kind),
                vim.log.levels.INFO
            )
        end
        request.respond(allow_id, false)
    end

    vim.api.nvim_create_user_command('CodeCompanionAcpYoloInspector', open_inspector, {
        desc = 'Inspect ACP permission request history',
    })
end

M.exports = {
    history = function()
        return history
    end,
    clear_history = function()
        history = {}
    end,
}

return M
