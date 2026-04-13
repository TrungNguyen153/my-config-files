-- ACP Yolo Mode Extension for CodeCompanion
--
-- Monkey-patches ACPHandler.handle_permission_request to check the
-- Approvals module before showing the approval UI. When yolo mode is
-- on (gty) and a tool is configured under its adapter key, the
-- request is auto-approved without prompting.
--
-- If codecompanion refactors the patched internals, the extension
-- disables itself with a warning and normal prompts resume.
--
-- Config structure:
--   opts = {
--     notify      = true,       — notify on auto-approve
--     ignore_case = true,       — global default, match tool kind case-insensitively
--     record      = true,       — global default, record to inspector
--
--     claude_code = {            — adapter name as key
--       ["edit"]  = {},          — auto-approve with global defaults
--       ["write"] = { record = false },
--       ["bash"]  = { allow = false },   — always prompt even in yolo
--       ["switch_mode"] = { ignore_case = true },
--     },
--   }
--
-- Per-tool opts:
--   allow              = true|false          — auto-approve or always prompt (default true)
--   ignore_case        = true|false          — override global ignore_case
--   record             = true|false          — override global record
--   title_pattern      = string|string[]|nil — lua patterns, title must match at least one (nil = match all)
--   title_deny_pattern = string|string[]|nil — lua patterns, if title matches any → always prompt
--
-- Commands:
--   :CodeCompanionAcpYoloInspector  — show all intercepted permission requests

local M = {}

---@type table[] History of intercepted permission requests
local history = {}

-- Known option keys (not adapter blocks)
local RESERVED_KEYS = { notify = true, ignore_case = true, record = true }

---Record a permission request for inspection
---@param entry table
local function record(entry)
    entry.timestamp = os.date('%H:%M:%S')
    table.insert(history, entry)
end

---Get the adapter tools block from opts
---@param ext_opts table
---@param adapter_name string
---@return table|nil
local function get_adapter_tools(ext_opts, adapter_name)
    if not adapter_name or not ext_opts[adapter_name] then
        return nil
    end
    return ext_opts[adapter_name]
end

---Find a tool config in the adapter tools block
---@param adapter_tools table
---@param kind string
---@param ignore_case boolean
---@return table|nil tool_cfg
---@return string|nil matched_key
local function find_tool_cfg(adapter_tools, kind, ignore_case)
    if not adapter_tools then
        return nil, nil
    end
    -- Exact match first
    if adapter_tools[kind] ~= nil then
        local val = adapter_tools[kind]
        if type(val) == 'table' then
            return val, kind
        end
        -- shorthand: true = auto-approve, false = deny
        return { allow = val }, kind
    end
    if not ignore_case then
        return nil, nil
    end
    -- Case-insensitive fallback
    local lower_kind = kind:lower()
    for key, cfg in pairs(adapter_tools) do
        if type(key) == 'string' and key:lower() == lower_kind then
            if type(cfg) == 'table' then
                return cfg, key
            end
            return { allow = cfg }, key
        end
    end
    return nil, nil
end

---Check if a string matches any pattern in a list
---@param str string
---@param patterns string|string[]|nil
---@return boolean matched
---@return string|nil matched_pattern
local function matches_any(str, patterns)
    if not patterns or not str then
        return false, nil
    end
    if type(patterns) == 'string' then
        patterns = { patterns }
    end
    for _, pat in ipairs(patterns) do
        if str:find(pat) then
            return true, pat
        end
    end
    return false, nil
end

---Resolve a per-tool option with global fallback
---@param tool_cfg table|nil
---@param key string
---@param global_default any
---@return any
local function resolve_opt(tool_cfg, key, global_default)
    if tool_cfg and tool_cfg[key] ~= nil then
        return tool_cfg[key]
    end
    return global_default
end

---Open the inspector buffer as a floating window
local function open_inspector()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = 'codecompanion_acp_yolo_inspector'
    vim.bo[buf].bufhidden = 'wipe'

    local lines = { '-- ACP Yolo Inspector', '-- Total requests: ' .. #history, '' }

    if #history == 0 then
        table.insert(lines, '-- No permission requests recorded yet.')
    else
        for i, entry in ipairs(history) do
            table.insert(lines, string.format('-- [%d] %s', i, entry.timestamp))
            for _, line in ipairs(vim.split(vim.inspect(entry), '\n', { plain = true })) do
                table.insert(lines, line)
            end
            table.insert(lines, '')
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    -- Floating window sized to 80% of editor
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

    -- Lua syntax highlighting for vim.inspect output
    vim.wo[win].winhl = 'Normal:NormalFloat,FloatBorder:FloatBorder'
    vim.treesitter.start(buf, 'lua')

    -- q or <Esc> to close
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

---@param opts table
---  Global options:
---    notify       boolean  (default true)  — show notification on auto-approve
---    ignore_case  boolean  (default true)  — match tool kind case-insensitively
---    record       boolean  (default true)  — record requests to inspector
---
---  Adapter blocks (key = adapter name, e.g. "claude_code", "gemini_cli"):
---    opts.<adapter_name> = {
---      ["<tool_kind>"] = {                 — tool kind from ACP request
---        allow              boolean         (default true)   — false = always prompt in yolo
---        ignore_case        boolean         (inherit global) — override case matching
---        record             boolean         (inherit global) — override inspector recording
---        title_pattern      string|string[] (default nil)    — lua patterns, must match at least one to auto-approve
---        title_deny_pattern string|string[] (default nil)    — lua patterns, if any match → always prompt
---      },
---      -- shorthand: ["<tool_kind>"] = true/false  (same as { allow = true/false })
---    }
---
---  Example:
---    opts = {
---      notify = true,
---      ignore_case = true,
---      claude_code = {
---        ["edit"]        = {},                  -- auto-approve, global defaults
---        ["write"]       = { record = false },  -- auto-approve, skip inspector
---        ["bash"]        = { allow = false },   -- always prompt
---        ["switch_mode"] = true,                -- shorthand auto-approve
---        ["execute"]     = {                    -- pattern-based approval
---          allow = true,
---          title_pattern = { 'cargo test', 'cargo check', 'npm test' },
---          title_deny_pattern = { 'rm %-rf', 'sudo ' },
---        },
---      },
---    }
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
    local global_ignore_case = opts.ignore_case ~= false -- default true
    local global_record = opts.record ~= false -- default true

    local original = Handler.handle_permission_request

    function Handler:handle_permission_request(request)
        local bufnr = self.chat.bufnr
        local kind = request.tool_call and request.tool_call.kind
        local title = request.tool_call and request.tool_call.title
        local adapter_name = self.chat.adapter and self.chat.adapter.name
        local yolo_on = approvals:is_approved(bufnr)

        -- Build entry for inspector
        local tc = request.tool_call
        local entry = {
            bufnr = bufnr,
            adapter = adapter_name,
            yolo_mode = yolo_on,
            auto_approved = false,
            reason = nil,
            matched_config_key = nil,
            options = {},
            tool_call = tc and {
                toolCallId = tc.toolCallId,
                kind = tc.kind,
                title = tc.title,
                status = tc.status,
                locations = tc.locations,
            } or nil,
        }

        -- Collect available options
        for _, opt in ipairs(request.options or {}) do
            table.insert(entry.options, { kind = opt.kind, optionId = opt.optionId })
        end

        -- Not in yolo mode → normal prompt
        if not yolo_on then
            entry.reason = 'yolo_mode_off'
            if global_record then
                record(entry)
            end
            return original(self, request)
        end

        -- No tool kind → normal prompt
        if not kind then
            entry.reason = 'no_tool_kind'
            if global_record then
                record(entry)
            end
            return original(self, request)
        end

        -- Get adapter tools block
        local adapter_tools = get_adapter_tools(opts, adapter_name)
        if not adapter_tools then
            entry.reason = 'adapter_not_configured'
            if global_record then
                record(entry)
            end
            return original(self, request)
        end

        -- Find tool config
        local tool_cfg, matched_key = find_tool_cfg(adapter_tools, kind, global_ignore_case)
        entry.matched_config_key = matched_key

        -- Resolve per-tool record option
        local should_record = resolve_opt(tool_cfg, 'record', global_record)

        -- Tool not configured → normal prompt (user adds later)
        if not tool_cfg then
            entry.reason = 'tool_not_configured'
            if should_record then
                record(entry)
            end
            return original(self, request)
        end

        -- Resolve per-tool ignore_case (for entry display)
        local tool_ignore_case = resolve_opt(tool_cfg, 'ignore_case', global_ignore_case)
        entry.ignore_case = tool_ignore_case

        -- Explicitly denied → normal prompt
        local allow = resolve_opt(tool_cfg, 'allow', true)
        if not allow then
            entry.reason = 'denied_by_config'
            if should_record then
                record(entry)
            end
            return original(self, request)
        end

        -- Check title_deny_pattern first (takes precedence)
        if title and tool_cfg.title_deny_pattern then
            local denied, deny_pat = matches_any(title, tool_cfg.title_deny_pattern)
            if denied then
                entry.reason = 'denied_by_title_pattern'
                entry.matched_title_pattern = deny_pat
                if should_record then
                    record(entry)
                end
                return original(self, request)
            end
        end

        -- Check title_pattern (must match at least one)
        if tool_cfg.title_pattern then
            local matched, match_pat = matches_any(title or '', tool_cfg.title_pattern)
            if not matched then
                entry.reason = 'title_pattern_not_matched'
                if should_record then
                    record(entry)
                end
                return original(self, request)
            end
            entry.matched_title_pattern = match_pat
        end

        -- Find allow_once option from ACP response options
        local allow_id
        for _, opt in ipairs(request.options or {}) do
            if opt.kind == 'allow_once' then
                allow_id = opt.optionId
                break
            end
        end

        if not allow_id then
            entry.reason = 'no_allow_once_option'
            if should_record then
                record(entry)
            end
            return original(self, request)
        end

        -- Auto-approve
        entry.auto_approved = true
        entry.reason = 'yolo_auto_approved'
        entry.responded_with = allow_id
        if should_record then
            record(entry)
        end

        if opts.notify then
            utils.notify(
                string.format('Auto-approved: %s', title or kind),
                vim.log.levels.INFO
            )
        end
        request.respond(allow_id, false)
    end

    -- Register command
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
