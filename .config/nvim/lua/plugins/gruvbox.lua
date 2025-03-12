return {
	"ellisonleao/gruvbox.nvim",
	-- enable = false,
    cond = not vim.g.vscode,
    lazy = false,
    priority = 1000,
	setup = function()
		require("gruvbox").setup({
			terminal_colors = true, -- add neovim terminal colors
			undercurl = true,
			underline = true,
			bold = true,
			italic = {
				strings = true,
				emphasis = true,
				comments = true,
				operators = false,
				folds = true,
			},
			strikethrough = true,
			invert_selection = false,
			invert_signs = false,
			invert_tabline = false,
			invert_intend_guides = false,
			inverse = true, -- invert background for search, diffs, statuslines and errors
			contrast = "", -- can be "hard", "soft" or empty string
			palette_overrides = {},
			overrides = {},
			dim_inactive = false,
			transparent_mode = false,
		})

		-- temporary way help Snacks
		vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "GruvboxBg4" })
		vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "GruvboxGray" })
		vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "GruvboxGray" })
	end,
}
