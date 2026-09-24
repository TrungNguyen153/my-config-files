-- auto installer for lsp servers, formatters and debug adapters

return {
    'mason-org/mason.nvim', -- lsp server installer
    enabled = not vim.g.vscode,
    -- Not lazy: setup() puts Mason's bin on PATH, which has to happen before the
    -- first buffer starts a server, and mason-tool-installer installs on VimEnter.
    lazy = false,
    -- opts = { log_level = vim.log.levels.DEBUG },
    dependencies = {
        'mason-org/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
        require('mason').setup()
        require('mason-lspconfig').setup({
            -- auto-install every server the config enables (lspconfig.lua)
            ensure_installed = require('utils.lsp').servers,
            automatic_enable = false,
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                'stylua',
                'shfmt',
                'prettier',
                'sqlfluff',
                'ruff',
                'markdownlint',
                'codelldb',
            },
        })
    end,
}
