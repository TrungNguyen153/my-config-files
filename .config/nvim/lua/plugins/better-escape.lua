-- better jj for exit

return {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = true,
    opts = {
        default_mappings = false,
        mappings = {
            -- i for insert
            i = {
                j = {
                    -- These can all also be functions
                    k = "<Esc>",
                    j = "<Esc>",
                },
            },
            c = {
                j = {
                    k = "<C-c>",
                    j = "<C-c>",
                },
            },
            t = {
                j = {
                    k = "<C-\\><C-n>",
                },
            },
        }
    },
}