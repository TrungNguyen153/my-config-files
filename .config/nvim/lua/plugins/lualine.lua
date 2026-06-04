-- status line

return {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    enabled = not vim.g.vscode,
    opts = {
        options = {
            theme = 'auto',
        },
        sections = {
            lualine_c = {
                { 'filename', path = 1 },
            },
            lualine_x = {
                'encoding',
                'fileformat',
                'filetype',
            },
        },
        inactive_sections = {
            lualine_c = {
                { 'filename', path = 1 },
            },
        },
    },
}
