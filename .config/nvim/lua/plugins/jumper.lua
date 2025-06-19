-- return {
--     "smoka7/hop.nvim",
--     event = "VeryLazy",
--     version = "*",
--     enabled = false,
--     opts = {
--         keys = 'etovxqpdygfblzhckisuran',
--     },
--     keys = {
--         {
--             "ss",
--             '<cmd>HopChar2<CR>',
--             mode = { "n", "x", "o" },
-- 			desc = "Hopping another character by 2 character",
-- 			noremap = true,
--             silent = true,
--         }
--     },
-- }

-- return {
-- 	"folke/flash.nvim",
-- 	event = "VeryLazy",
-- 	enabled = false,
-- 	opts = {
-- 		search = {
-- 			-- search/jump in all windows
-- 			multi_window = false,
-- 		},
-- 		modes = {
-- 			char = {
-- 				config = function(opts)
-- 					-- autohide flash when in operator-pending mode
-- 					opts.autohide = vim.fn.mode(true):find("no")
-- 				end,
-- 			},
-- 		},
-- 	},
-- 	keys = {
-- 		{
-- 			"<leader>s",
-- 			function()
-- 				require("flash").jump()
-- 			end,
-- 			mode = { "n", "x", "o" },
-- 			desc = "Flash",
-- 			noremap = true,
-- 		},
-- 		{
-- 			"<leader>S",
-- 			function()
-- 				require("flash").treesitter()
-- 			end,
-- 			mode = { "n", "x", "o" },
-- 			desc = "Flash Treesitter",
-- 			noremap = true,
-- 		},
-- 		{
-- 			"<leader>r",
-- 			function()
-- 				require("flash").remote()
-- 			end,
-- 			mode = { "o" },
-- 			desc = "Flash Remote",
-- 			noremap = true,
-- 		},
-- 		{
-- 			"<leader>R",
-- 			function()
-- 				require("flash").treesitter_search()
-- 			end,
-- 			mode = { "x", "o" },
-- 			desc = "Flash Treesitter Search",
-- 			noremap = true,
-- 		},
-- 	},
-- }


return {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
        vim.keymap.set({'n', 'x', 'o'}, 'ss', '<Plug>(leap)')
        vim.keymap.set('n',             '<leader>s', '<Plug>(leap-from-window)')
    end,
}