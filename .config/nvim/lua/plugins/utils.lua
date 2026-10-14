return {
	-- common utilities
	{
		"nvim-tree/nvim-web-devicons",
		enabled = not vim.g.vscode,
		config = true,
	}, -- icon support for several plugins
	{ "samjwill/nvim-unception", enabled = not vim.g.vscode }, -- prevents an instance of neovim to be openend within neovim
	-- loaded on first require; neovim-tasks, typescript-tools, todo-comments and gx.nvim
	-- use it without declaring it
	{ "nvim-lua/plenary.nvim", lazy = true },
}
