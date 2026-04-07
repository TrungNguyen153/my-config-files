-- status line



return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter",
	enabled = not vim.g.vscode,
	-- enabled = false,
	opts = {
		options = {
			theme = "auto"
		}
	}
}
