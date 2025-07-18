-- improves tab on insert mode

return {
	"abecodes/tabout.nvim",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	event = "InsertCharPre",
	config = true,
	opts = {
		act_as_shift_tab = true,
		act_as_tab = true,
		ignore_beginning = false,
		tabouts = {
			{ open = "#", close = "]" },
			{ open = "'", close = "'" },
			{ open = '"', close = '"' },
			{ open = "`", close = "`" },
			{ open = "(", close = ")" },
			{ open = "[", close = "]" },
			{ open = "{", close = "}" },
		},
	},
}
