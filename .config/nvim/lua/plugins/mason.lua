-- auto installer for lsp servers and linters

return {
	"williamboman/mason.nvim", -- lsp server installer
	enabled = not vim.g.vscode,
	event = "VeryLazy",
	-- opts = { log_level = vim.log.levels.DEBUG },
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "Zeioth/none-ls-autoload.nvim", config = true },
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				--  "rust_analyzer", // dont use this

			},
			automatic_installation = true,
			automatic_enable = false,
		})
		require("mason-tool-installer").setup({
			ensure_installed = {
				"codelldb",
				"clangd",
				"shfmt",
				"stylua",
				"taplo", -- toml formatter
			},
		})
	end,
}
