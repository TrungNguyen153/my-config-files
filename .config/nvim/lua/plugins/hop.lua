return {
    "smoka7/hop.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
        keys = 'etovxqpdygfblzhckisuran',
    },
    keys = {
        {
            "ss",
            '<cmd>HopChar2<CR>',
            mode = { "n", "x", "o" },
			desc = "Hopping another character by 2 character",
			noremap = true,
            silent = true,
        }
    },
}