-- formatters
return {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    config = function()
        -- Filetypes whose formatter timed out on save; they format after the save instead.
        local slow_format_filetypes = {}
        require('conform').setup({
            formatters_by_ft = {
                css = { 'prettier' },
                html = { 'prettier' },
                javascript = { 'prettier' },
                javascriptreact = { 'prettier' },
                json = { 'prettier' },
                lua = { 'stylua' },
                markdown = { 'markdownlint' },
                python = { 'ruff_format' },
                sh = { 'shfmt' },
                sql = { 'sqlfluff' },
                typescript = { 'prettier' },
                typescriptreact = { 'prettier' },
                yaml = { 'prettier' },
            },
            default_format_opts = {
                lsp_format = 'fallback',
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                if slow_format_filetypes[vim.bo[bufnr].filetype] then
                    return
                end
                local function on_format(err)
                    if err and err:match('timeout$') then
                        slow_format_filetypes[vim.bo[bufnr].filetype] = true
                    end
                end
                return { timeout_ms = 500, lsp_format = 'fallback' }, on_format
            end,
            format_after_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                if not slow_format_filetypes[vim.bo[bufnr].filetype] then
                    return
                end
                return { lsp_format = 'fallback' }
            end,
        })
    end,
    keys = {
        {
            '<leader>lc',
            function()
                vim.b.disable_autoformat = not vim.b.disable_autoformat
                local state = vim.b.disable_autoformat and 'disabled' or 'enabled'
                vim.notify('Autoformat ' .. state .. ' for buffer')
            end,
            mode = { 'n' },
            desc = 'Toggle autoformat (buffer)',
            noremap = true,
        },
        {
            '<leader>lf',
            function()
                require('conform').format({ async = false, lsp_format = 'fallback' })
            end,
            mode = { 'n' },
            desc = 'Format code',
            silent = true,
        },
    },
}
