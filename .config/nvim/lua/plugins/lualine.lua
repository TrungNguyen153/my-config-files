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
                { -- debugger keys while a session runs (plugins/dap.lua)
                    function()
                        return 'F5 run · F10 over · F11 into · S-F11 out · F9 bp · S-F5 stop · ␣d more'
                    end,
                    cond = function()
                        return package.loaded.dap ~= nil and require('dap').session() ~= nil
                    end,
                    color = 'DiagnosticWarn',
                },
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
