-- markdown enhancements -- check marvkview

return {
	"MeanderingProgrammer/render-markdown.nvim",
	enabled = not vim.g.vscode,
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Used by the code bloxks
	},
	opts = {
		file_types = { "markdown", "Avante" },
	},
	ft = { "markdown", "Avante" },
	config = true,
}
