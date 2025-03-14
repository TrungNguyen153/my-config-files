-- add surround commands
-- The three "core" operations of add/delete/change can be done with the 
-- keymaps:
-- ys{motion}{char}
-- ds{char}
-- and cs{target}{replacement}
return {
	"kylechui/nvim-surround",
	version = "^3.0.0",
	event = "VeryLazy",
	opts = {
		surrounds = {
			["r"] = { add = { 'r#"', '"#' } },
		},
		-- keymaps = {
		-- 	insert = false,
		-- 	insert_line = false,
		-- 	normal = "'a",
		-- 	normal_cur = false,
		-- 	normal_line = false,
		-- 	normal_cur_line = false,
		-- 	visual = "'",
		-- 	visual_line = false,
		-- 	delete = "'d",
		-- 	change = "'r",
		-- },
		highlight = {
			duration = 1000,
		},
	},
}
