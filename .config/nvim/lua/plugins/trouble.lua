-- adds a bottom panel with lsp diagnostics, quickfixes, etc.

return {
    'folke/trouble.nvim',
    enabled = not vim.g.vscode,
    cmd = 'Trouble',
    opts = {
        modes = {
            diagnostics = {
                filter = {
                    any = {
                        function(item)
                            -- normalize: on Windows cwd() has backslashes, filenames have /
                            local cwd = vim.fs.normalize(vim.uv.cwd())
                            if cwd:sub(-1) ~= '/' then
                                cwd = cwd .. '/' -- a drive root is already C:/
                            end
                            return item.filename:sub(1, #cwd) == cwd
                        end,
                    },
                },
            },
        },
    },
    keys = {
        {
            '<M-t>',
            ':Trouble diagnostics toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Show diagnostics pane',
            noremap = true,
            silent = true,
        },
        { -- TEST: require('dap').list_breakpoints() adds them to a qflist
            '<leader>tb',
            function()
                require('dap').list_breakpoints()
                require('trouble').toggle({ mode = 'qflist', focus = true })
            end,
            mode = { 'n' },
            desc = 'Breakpoints',
            noremap = true,
        },
        {
            '<leader>tc',
            ':Trouble lsp_declarations toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Declarations',
            noremap = true,
        },
        {
            '<leader>td',
            ':Trouble diagnostics toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Show diagnostics pane',
            noremap = true,
            silent = true,
        },
        {
            '<leader>tf',
            ':Trouble lsp_definitions toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Definitions',
            noremap = true,
        },
        {
            '<leader>ti',
            ':Trouble lsp_implementations toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Implementations',
            noremap = true,
        },
        {
            '<leader>tl',
            ':Trouble todo toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Toggle todo list',
            noremap = true,
        },
        {
            '<leader>to',
            ':Trouble loclist toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Location List',
            noremap = true,
        },
        {
            '<leader>tq',
            ':Trouble qflist toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Quickfix List',
            noremap = true,
        },
        {
            '<leader>tr',
            ':Trouble lsp_references toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP References',
            noremap = true,
        },
        {
            '<leader>ts',
            ':Trouble symbols toggle pinned=true win.relative=win win.position=right focus=true<CR>',
            mode = { 'n' },
            desc = 'Symbols',
            noremap = true,
        },
    },
}