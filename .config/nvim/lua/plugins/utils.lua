return {
	-- common utilities
	{
		"nvim-tree/nvim-web-devicons",
		enabled = not vim.g.vscode,
		config = true,
	}, -- icon support for several plugins
	{ "samjwill/nvim-unception", enabled = not vim.g.vscode }, -- prevents an instance of neovim to be openend within neovim
}
