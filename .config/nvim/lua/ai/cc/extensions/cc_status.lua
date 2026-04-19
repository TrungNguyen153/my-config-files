-- CodeCompanion Status Indicator
--
-- Floating pill at editor top-right showing:
--   [ ⚡ YOLO ]            — any chat has yolo mode on
--   [ ⠋ thinking ]         — any chat has a request in flight
--   [ ⚡ YOLO · ⠋ thinking ] — both
--
-- Hidden when neither is true.
--
-- Highlight groups (all default-linked, override freely):
--   CodeCompanionStatusYolo       → DiagnosticWarn
--   CodeCompanionStatusProcessing → DiagnosticInfo
--   CodeCompanionStatusFrame      → Comment
-- Window background uses NormalFloat so it blends with the theme's floats.

local M = {}

local HL_YOLO = 'CodeCompanionStatusYolo'
local HL_WORK = 'CodeCompanionStatusProcessing'
local HL_FRAME = 'CodeCompanionStatusFrame'
local SPINNER_FRAMES = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local SPINNER_MS = 100
local NS = vim.api.nvim_create_namespace('CodeCompanionStatusPill')

---@type table<integer, true>
local yolo_bufs = {}
---@type table<integer, true>
local processing_bufs = {}
local spinner_frame = 1
local win, buf
local timer

local uv = vim.uv or vim.loop

local function is_yolo_active()
    return next(yolo_bufs) ~= nil
end

local function is_processing()
    return next(processing_bufs) ~= nil
end

---Build pill text plus per-segment highlight ranges (byte offsets).
---@return string|nil text
---@return { start: integer, stop: integer, hl: string }[]|nil segments
local function build_text()
    if not is_yolo_active() and not is_processing() then
        return nil, nil
    end
    local segments = {}
    local text = '[ '
    table.insert(segments, { start = 0, stop = #text, hl = HL_FRAME })
    local need_sep = false
    if is_yolo_active() then
        local s = #text
        text = text .. '⚡ YOLO'
        table.insert(segments, { start = s, stop = #text, hl = HL_YOLO })
        need_sep = true
    end
    if is_processing() then
        if need_sep then
            local s = #text
            text = text .. ' · '
            table.insert(segments, { start = s, stop = #text, hl = HL_FRAME })
        end
        local s = #text
        text = text .. SPINNER_FRAMES[spinner_frame] .. ' thinking'
        table.insert(segments, { start = s, stop = #text, hl = HL_WORK })
    end
    local s = #text
    text = text .. ' ]'
    table.insert(segments, { start = s, stop = #text, hl = HL_FRAME })
    return text, segments
end

local function hide()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    win = nil
    buf = nil
end

local function ensure_buf()
    if buf and vim.api.nvim_buf_is_valid(buf) then
        return
    end
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'codecompanion_status'
end

local function render()
    local text, segments = build_text()
    if not text then
        hide()
        return
    end
    local width = vim.fn.strdisplaywidth(text)
    if vim.o.columns < width + 4 then
        hide()
        return
    end
    local col = vim.o.columns - width
    ensure_buf()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
    for _, seg in ipairs(segments) do
        vim.api.nvim_buf_set_extmark(buf, NS, 0, seg.start, {
            end_col = seg.stop,
            hl_group = seg.hl,
        })
    end

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, {
            relative = 'editor',
            row = 0,
            col = col,
            width = width,
            height = 1,
        })
    else
        win = vim.api.nvim_open_win(buf, false, {
            relative = 'editor',
            row = 0,
            col = col,
            width = width,
            height = 1,
            style = 'minimal',
            focusable = false,
            noautocmd = true,
            zindex = 200,
        })
        vim.wo[win].winhl = 'Normal:NormalFloat'
    end
end

local function start_spinner()
    if timer then
        return
    end
    timer = uv.new_timer()
    timer:start(0, SPINNER_MS, vim.schedule_wrap(function()
        spinner_frame = (spinner_frame % #SPINNER_FRAMES) + 1
        if is_processing() then
            render()
        end
    end))
end

local function stop_spinner()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end
end

local function set_processing(bufnr, on)
    if not bufnr then
        return
    end
    if on then
        processing_bufs[bufnr] = true
        start_spinner()
    else
        processing_bufs[bufnr] = nil
        if not is_processing() then
            stop_spinner()
        end
    end
    render()
end

local function set_yolo(bufnr, on)
    if not bufnr then
        return
    end
    yolo_bufs[bufnr] = on or nil
    render()
end

---@param opts table|nil
function M.setup(opts)
    opts = opts or {}

    vim.api.nvim_set_hl(0, HL_YOLO, { link = 'DiagnosticWarn', default = true })
    vim.api.nvim_set_hl(0, HL_WORK, { link = 'DiagnosticInfo', default = true })
    vim.api.nvim_set_hl(0, HL_FRAME, { link = 'Comment', default = true })

    local ok_approvals, approvals =
        pcall(require, 'codecompanion.interactions.chat.tools.approvals')

    -- Monkey-patch Approvals.toggle_yolo_mode to fire a User autocmd
    if ok_approvals and type(approvals.toggle_yolo_mode) == 'function' then
        local original_toggle = approvals.toggle_yolo_mode
        approvals.toggle_yolo_mode = function(self, bufnr)
            local ret = original_toggle(self, bufnr)
            vim.api.nvim_exec_autocmds('User', {
                pattern = 'AcpYoloToggled',
                data = { bufnr = bufnr },
            })
            return ret
        end
    else
        vim.notify(
            '[cc_status] Approvals.toggle_yolo_mode missing — yolo indicator will rely on chat-lifecycle polling',
            vim.log.levels.WARN
        )
    end

    local group = vim.api.nvim_create_augroup('CodeCompanionStatusPill', { clear = true })

    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'CodeCompanionChatSubmitted',
        callback = function(ev)
            local data = ev.data or {}
            set_processing(data.bufnr, true)
        end,
    })

    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = { 'CodeCompanionChatDone', 'CodeCompanionChatStopped' },
        callback = function(ev)
            local data = ev.data or {}
            set_processing(data.bufnr, false)
        end,
    })

    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'AcpYoloToggled',
        callback = function(ev)
            if not ok_approvals then
                return
            end
            local data = ev.data or {}
            if not data.bufnr then
                return
            end
            set_yolo(data.bufnr, approvals:is_approved(data.bufnr))
        end,
    })

    -- Fallback poll: re-probe yolo on chat lifecycle events. Harmless when
    -- the monkey-patch above already keeps state fresh.
    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = {
            'CodeCompanionChatOpened',
            'CodeCompanionChatSubmitted',
            'CodeCompanionChatDone',
        },
        callback = function(ev)
            if not ok_approvals then
                return
            end
            local data = ev.data or {}
            if not data.bufnr then
                return
            end
            set_yolo(data.bufnr, approvals:is_approved(data.bufnr))
        end,
    })

    vim.api.nvim_create_autocmd('BufWipeout', {
        group = group,
        callback = function(ev)
            yolo_bufs[ev.buf] = nil
            processing_bufs[ev.buf] = nil
            if not is_processing() then
                stop_spinner()
            end
            render()
        end,
    })

    vim.api.nvim_create_autocmd('VimResized', {
        group = group,
        callback = function()
            render()
        end,
    })
end

M.exports = {
    yolo_bufs = function() return yolo_bufs end,
    processing_bufs = function() return processing_bufs end,
}

return M
