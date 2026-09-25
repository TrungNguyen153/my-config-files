-- Debugger: nvim-dap with nvim-dap-ui and variable values shown next to the code.
-- F-keys follow VS Code, and every action is also under <leader>d, where which-key
-- lists it with its F-key. While a session runs, the statusline (lualine.lua) and
-- the REPL's buttons show the main keys.

-- WezTerm on Windows delivers Shift/Ctrl+F<n> as <F(n+12)>/<F(n+24)> (Neovim reads
-- the xterm terminfo first), Neovide as <S-F<n>>/<C-F<n>>, so map both names.
local function terminal_names(fkey)
    local mod, n = fkey:match('^<([SC])%-F(%d+)>$')
    if not mod then
        return { fkey }
    end
    return { fkey, ('<F%d>'):format(tonumber(n) + (mod == 'S' and 12 or 24)) }
end

-- Esc or an empty answer cancels: set_breakpoint('') would still replace the
-- breakpoint on this line, dropping its condition or log message.
local function conditional_breakpoint()
    vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(condition)
        if condition and condition ~= '' then
            require('dap').set_breakpoint(condition)
        end
    end)
end

local function log_point()
    vim.ui.input({ prompt = 'Log message: ' }, function(message)
        if message and message ~= '' then
            require('dap').set_breakpoint(nil, nil, message)
        end
    end)
end

-- { <leader>d key, label, nvim-dap function name or a function, fkey = F-key, mode = modes }
local actions = {
    { 'c', 'Run / continue', 'continue', fkey = '<F5>' },
    { 't', 'Stop', 'terminate', fkey = '<S-F5>' },
    { 'l', 'Run last', 'run_last', fkey = '<C-F5>' },
    { 'R', 'Restart', 'restart' },
    { 'p', 'Pause', 'pause', fkey = '<F6>' },
    { 'b', 'Toggle breakpoint', 'toggle_breakpoint', fkey = '<F9>' },
    { 'B', 'Conditional breakpoint', conditional_breakpoint, fkey = '<S-F9>' },
    { 'L', 'Log point', log_point, fkey = '<C-F9>' },
    { 'X', 'Clear breakpoints', 'clear_breakpoints' },
    { 'E', 'Exception breakpoints', 'set_exception_breakpoints' },
    { 'n', 'Step over', 'step_over', fkey = '<F10>' },
    { 'i', 'Step into', 'step_into', fkey = '<F11>' },
    { 'o', 'Step out', 'step_out', fkey = '<S-F11>' },
    { 'C', 'Run to cursor', 'run_to_cursor', fkey = '<S-F10>' },
    { 'k', 'Frame up', 'up' },
    { 'j', 'Frame down', 'down' },
    { 'f', 'Focus current frame', 'focus_frame' },
    {
        'r',
        'Toggle REPL',
        function()
            require('dap').repl.toggle()
        end,
        fkey = '<F4>',
    },
    {
        'h',
        'Hover value',
        function()
            require('dap.ui.widgets').hover()
        end,
        fkey = '<F7>',
        mode = { 'n', 'x' },
    },
    {
        'e',
        'Eval expression',
        function()
            require('dapui').eval()
        end,
        mode = { 'n', 'x' },
    },
    {
        'u',
        'Toggle UI (last output)',
        function()
            require('dapui').toggle()
        end,
    },
}

local keys = {}
for _, action in ipairs(actions) do
    local key, label, run = action[1], action[2], action[3]
    if type(run) == 'string' then
        local name = run
        run = function()
            require('dap')[name]()
        end
    end
    local mode = action.mode or 'n'
    local desc = action.fkey and ('%s (%s)'):format(label, action.fkey:sub(2, -2)) or label
    table.insert(keys, { '<leader>d' .. key, run, mode = mode, desc = desc })
    for _, lhs in ipairs(action.fkey and terminal_names(action.fkey) or {}) do
        table.insert(keys, { lhs, run, mode = mode, desc = 'Debug: ' .. label })
    end
end

return {
    'mfussenegger/nvim-dap',
    enabled = not vim.g.vscode,
    dependencies = {
        'rcarriga/nvim-dap-ui', -- ui for nvim-dap
        'theHamsta/nvim-dap-virtual-text', -- variable values next to the code
        'nvim-neotest/nvim-nio',
    },
    cmd = {
        'DapClearBreakpoints',
        'DapContinue',
        'DapDisconnect',
        'DapEval',
        'DapNew',
        'DapPause',
        'DapRestartFrame',
        'DapSetLogLevel',
        'DapShowLog',
        'DapStepInto',
        'DapStepOut',
        'DapStepOver',
        'DapTerminate',
        'DapToggleBreakpoint',
        'DapToggleRepl',
    },
    keys = keys,
    init = function()
        -- K shows the debugger's value while a session runs, LSP hover otherwise.
        -- LSP only adds its buffer-local K when no K exists, so this one wins.
        vim.keymap.set('n', 'K', function()
            if package.loaded.dap and require('dap').session() then
                require('dap.ui.widgets').hover()
            elseif #vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/hover' }) > 0 then
                vim.lsp.buf.hover()
            else
                vim.cmd.normal({ 'K', bang = true }) -- 'keywordprg' (:help, :Man)
            end
        end, { desc = 'Hover (debug value while debugging)' })
    end,
    config = function()
        local dap, dapui = require('dap'), require('dapui')

        -- codelldb from Mason. rustaceanvim only defines it while building a Rust
        -- target, but neovim-tasks (<leader>cd) and C/C++ below need it too;
        -- rustaceanvim reuses this one.
        dap.adapters.codelldb = {
            type = 'server',
            host = '127.0.0.1',
            port = '${port}',
            executable = {
                command = vim.fn.exepath('codelldb'),
                args = { '--port', '${port}' },
                detached = vim.fn.has('win32') == 0, -- nvim-dap wiki: attached on Windows
            },
        }
        -- F5 in C/C++ (neovim-tasks' <leader>cd builds and debugs CMake targets itself)
        dap.configurations.cpp = {
            {
                name = 'Launch executable',
                type = 'codelldb',
                request = 'launch',
                program = function()
                    local path = vim.fn.input('Executable: ', 'build/', 'file')
                    return path ~= '' and vim.fn.fnamemodify(path, ':p') or dap.ABORT
                end,
                cwd = '${workspaceFolder}',
            },
        }
        dap.configurations.c = dap.configurations.cpp

        require('nvim-dap-virtual-text').setup({})
        dapui.setup({
            controls = {
                -- the REPL's buttons, labelled with their keys
                icons = {
                    play = '\u{EAD3} F5',
                    pause = '\u{EAD1} F6',
                    step_over = '\u{EAD6} F10',
                    step_into = '\u{EAD4} F11',
                    step_out = '\u{EAD5} S-F11',
                    run_last = '\u{EB37} C-F5',
                    terminate = '\u{EAD7} S-F5',
                },
            },
        })
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        -- Close once the last session ends, however it ends: codelldb has no
        -- terminate request, so Stop disconnects without a terminated/exited event.
        -- Deferred: closing inside a listener can crash Neovim on Windows
        -- (nvim-dap-ui #486). <leader>du reopens the UI to read the last output.
        dap.listeners.on_session.dapui_config = function(_, new)
            if not new then
                vim.schedule(dapui.close)
            end
        end

        -- completion in the REPL as you type
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'dap-repl',
            callback = function()
                require('dap.ext.autocompl').attach()
            end,
        })

        vim.fn.sign_define('DapBreakpoint', { text = '\u{EA71}', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
        vim.fn.sign_define(
            'DapBreakpointCondition',
            { text = '\u{EB88}', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' }
        )
        vim.fn.sign_define('DapLogPoint', { text = '\u{EAAB}', texthl = 'DapLogPoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '\u{EAB6}', texthl = 'DapStopped', linehl = 'Visual', numhl = '' })
        vim.fn.sign_define(
            'DapBreakpointRejected',
            { text = '\u{EAB8}', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' }
        )
    end,
}
