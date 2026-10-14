-- rust enhancements

---@type integer | nil
local latest_buf_id = nil

---@type rustaceanvim.Executor
local M = {
    execute_command = function(command, args, cwd, opts)
        local shell = require('rustaceanvim.shell')
        local ui = require('rustaceanvim.ui')
        local commands = {}
        if cwd then
            table.insert(commands, shell.make_cd_command(cwd))
        end
        table.insert(commands, shell.make_command_from_args(command, args))
        local full_command = shell.chain_commands(commands)

        -- check if a buffer with the latest id is already open, if it is then
        -- delete it and continue
        ui.delete_buf(latest_buf_id)

        -- create the new buffer
        latest_buf_id = vim.api.nvim_create_buf(false, true)

        -- split the window to create a new buffer and set it to our window
        ui.split(false, latest_buf_id)

        -- make the new buffer smaller
        ui.resize(false, '-5')

        -- close the buffer when escape is pressed :)
        vim.keymap.set('n', '<Esc>', '<CMD>q<CR>', { buffer = latest_buf_id, noremap = true })
        vim.keymap.set('n', 'q', '<CMD>q<CR>', { buffer = latest_buf_id, noremap = true })

        vim.fn.jobstart(full_command, { term = true, env = opts.env })

        -- when the buffer is closed, set the latest buf id to nil else there are
        -- some edge cases with the id being sit but a buffer not being open
        local function onDetach(_, _)
            latest_buf_id = nil
        end
        vim.api.nvim_buf_attach(latest_buf_id, false, { on_detach = onDetach })
    end,
}

-- rust-analyzer stays off until toggled on: Claude Code already runs one on the
-- same workspace, and a second instance doubles RAM on large workspaces.
---@param bufnr integer
---@return boolean
local function should_attach(bufnr)
    return vim.g.rust_analyzer_enabled == true
        and vim.bo[bufnr].buftype == ''
        and vim.api.nvim_buf_get_name(bufnr) ~= ''
end

local function toggle_rust_analyzer()
    vim.g.rust_analyzer_enabled = not vim.g.rust_analyzer_enabled
    if vim.g.rust_analyzer_enabled then
        -- :RustAnalyzer start only attaches the buffer it runs in
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'rust' and should_attach(buf) then
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd.RustAnalyzer('start')
                end)
            end
        end
    else
        for _, client in ipairs(vim.lsp.get_clients({ name = 'rust-analyzer' })) do
            client:stop()
        end
    end
    vim.notify('rust-analyzer ' .. (vim.g.rust_analyzer_enabled and 'enabled' or 'disabled'))
end

return {
    'mrcjkb/rustaceanvim',
    enabled = not vim.g.vscode,
    lazy = false, -- the plugin is already lazy
    init = function()
        vim.g.rustaceanvim = function()
            return {
                tools = {
                    --- options right now: termopen / quickfix / toggleterm / vimux
                    executor = M,
                    test_executor = M,
                    crate_test_executor = M,
                    reload_workspace_from_cargo_toml = true,
                    hover_actions = {
                        replace_builtin_hover = false,
                    },
                    float_win_config = {
                        auto_focus = true,
                    },
                },
                -- on_attach work and capabilities come from the LspAttach autocmd and
                -- vim.lsp.config('*') in lspconfig.lua; rustaceanvim merges both.
                server = {
                    standalone = false,
                    auto_attach = should_attach,
                    exit_timeout = 100,
                    settings = {
                        ['rust-analyzer'] = {
                            diagnostics = {
                                enable = true,
                                disabled = { 'inactive-code', 'unresolved-proc-macro' },
                            },
                            completion = {
                                autoself = { enable = true },
                                autoimport = { enable = true },
                                postfix = { enable = true },
                            },
                            imports = {
                                group = { enable = true },
                                merge = { glob = false },
                                prefix = 'self',
                                preferPrelude = true,
                                granularity = {
                                    enforce = true,
                                    group = 'crate',
                                },
                            },
                            cargo = {
                                targetDir = true, -- writes to target/rust-analyzer
                                allTargets = false, -- skip tests/benches/examples in metadata
                            },
                            procMacro = {
                                enable = true,
                                attributes = { enable = true },
                            },
                            files = {
                                -- relative to the workspace root, no globs
                                exclude = {
                                    'node_modules',
                                    '.direnv',
                                },
                            },
                            lens = {
                                enable = true,
                                run = { enable = true },
                                debug = { enable = true },
                                implementations = { enable = true },
                                references = {
                                    adt = { enable = false },
                                    enumVariant = { enable = false },
                                    method = { enable = false },
                                    trait = { enable = false },
                                },
                            },
                            hover = {
                                actions = {
                                    enable = true,
                                    run = { enable = true },
                                    debug = { enable = true },
                                    gotoTypeDef = { enable = true },
                                    implementations = { enable = true },
                                    references = { enable = true },
                                },
                                links = { enable = true },
                                documentation = { enable = true },
                            },
                            inlayHints = {
                                implicitDrops = { enable = false },
                                closingBraceHints = { enable = false },
                                parameterHints = { enable = false },
                            },
                            typing = {
                                -- '{' and '(' are left out: they fight nvim-autopairs
                                triggerChars = '=.<>',
                            },
                            -- interpret = { tests = true },
                            checkOnSave = true,
                            check = {
                                -- https://github.com/rust-analyzer/rust-analyzer/issues/9768
                                command = 'clippy',
                                -- features = "all",
                                allTargets = false,
                            },
                        },
                    },
                },
            }
        end
    end,
    keys = {
        {
            '<leader>rl',
            toggle_rust_analyzer,
            mode = { 'n' },
            desc = 'Toggle rust-analyzer',
            noremap = true,
        },
        {
            '<leader>ra',
            ':RustLsp hover actions<CR>',
            mode = { 'n' },
            desc = 'Hover Actions',
            noremap = true,
        },
        {
            '<leader>rb',
            ':RustLsp moveItem down<CR>',
            mode = { 'n' },
            desc = 'Move Item Down',
            noremap = true,
        },
        {
            '<leader>rc',
            ':RustLsp openCargo<CR>',
            mode = { 'n' },
            desc = 'Open Cargo.toml',
            noremap = true,
        },
        {
            '<leader>rd',
            ':RustLsp debuggables<CR>',
            mode = { 'n' },
            desc = 'Debuggables',
            noremap = true,
        },
        {
            '<leader>rg',
            ':RustLsp renderDiagnostic current<CR>',
            mode = { 'n' },
            desc = 'Render Diagnostic',
            noremap = true,
        },
        {
            '<leader>re',
            ':RustLsp explainError current<CR>',
            mode = { 'n' },
            desc = 'Explain Error',
            noremap = true,
        },
        {
            '<leader>rk',
            ':RustLsp crateGraph<CR>',
            mode = { 'n' },
            desc = 'View Crate Graph',
            noremap = true,
        },
        {
            '<leader>rh',
            ':RustLsp hover range<CR>',
            mode = { 'n' },
            desc = 'Range Hover Actions',
            noremap = true,
        },
        {
            '<leader>rj',
            ':RustLsp joinLines<CR>',
            mode = { 'n' },
            desc = 'Join Lines',
            noremap = true,
        },
        {
            '<leader>rm',
            ':RustLsp expandMacro<CR>',
            mode = { 'n' },
            desc = 'Expand Macro',
            noremap = true,
        },
        {
            '<leader>rp',
            ':RustLsp parentModule<CR>',
            mode = { 'n' },
            desc = 'Parent Module',
            noremap = true,
        },
        {
            '<leader>rx',
            ':RustLsp openDocs<CR>',
            mode = { 'n' },
            desc = 'Open Rust Docs',
            noremap = true,
        },
        {
            '<leader>rr',
            ':RustLsp runnables<CR>',
            mode = { 'n' },
            desc = 'Runnables',
            noremap = true,
        },
        {
            '<leader>rs',
            ':RustLsp syntaxTree<CR>',
            mode = { 'n' },
            desc = 'View Syntax Tree',
            noremap = true,
        },
        {
            '<leader>ru',
            ':RustLsp moveItem up<CR>',
            mode = { 'n' },
            desc = 'Move Item Up',
            noremap = true,
        },
        {
            '<leader>rf',
            ':RustLsp flyCheck<CR>',
            mode = { 'n' },
            desc = 'Run fly check',
            noremap = true,
        },
        {
            '<leader>rC',
            ':RustLsp flyCheck cancel<CR>',
            mode = { 'n' },
            desc = 'Clear last run fly check',
            noremap = true,
        },
        {
            '!',
            ":lua vim.cmd.RustLsp { 'runnables', bang = true }<CR>",
            ft = 'rust',
            mode = { 'n' },
            desc = 'Rerun last runnables',
            noremap = true,
            silent = true,
        },
    },
}
