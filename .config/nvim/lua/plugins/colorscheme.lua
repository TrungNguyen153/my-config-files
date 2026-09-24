-- colorscheme
return {
    'catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    priority = 1000,
    ---@type CatppuccinOptions
    opts = {
        transparent_background = false,
        float = {
            transparent = false,
            solid = false,
        },
        term_colors = true,
        auto_integrations = true,
        styles = {
            comments = {},
            conditionals = { 'italic' },
            loops = { 'italic' },
            functions = {},
            keywords = { 'italic' },
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        lsp_styles = {
            virtual_text = {
                errors = { 'italic' },
                hints = { 'italic' },
                warnings = { 'italic' },
                information = { 'italic' },
            },
            underlines = {
                errors = { 'underline' },
                hints = { 'underline' },
                warnings = { 'underline' },
                information = { 'underline' },
            },
            inlay_hints = {
                background = true,
            },
        },
    },
    config = function(_, opts)
        vim.g.catppuccin_flavour = 'frappe' -- mocha, frappe, latte, macchiato
        require('catppuccin').setup(opts)

        vim.cmd.colorscheme('catppuccin')
    end,
}
