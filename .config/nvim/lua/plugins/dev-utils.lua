return {
	{ "SmiteshP/nvim-navic", event = { 'User NvimStartupDone' }, config = require("setup.nvim-navic").setup }, -- adds breadcrumbs
	{ "folke/trouble.nvim", event = { 'User NvimStartupDone' }, config = require("setup.trouble").setup }, -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
	{ "GustavoKatel/sidebar.nvim", event = { 'User NvimStartupDone' }, config = require("setup.sidebar-nvim").setup }, -- ful sidebar with todos, git status, etc.
	{
		"nvim-neotest/neotest",
		dependencies = {
			"rouge8/neotest-rust", "nvim-neotest/nvim-nio",
		},
		cmd = 'LazyNeoTest',
		config = require("setup.neotest").setup,
	}, -- test helpers. runs and show signs of test runs
	{
		"pwntester/octo.nvim",
		event = { 'User NvimStartupDone' },
		config = function()
			require("octo").setup()
		end,
	}, -- github manager for issues and pull requests
	{ 'NeogitOrg/neogit', cmd = 'LazyNeogit', config = require('setup.neogit').setup },
	{
		"mfussenegger/nvim-dap", -- debug adapter for debugging
		event = { 'User NvimStartupDone' },
		dependencies = {
			{"rcarriga/nvim-dap-ui", dependencies = {"nvim-neotest/nvim-nio"} }, -- ui for nvim-dap
			"theHamsta/nvim-dap-virtual-text", -- virtual text during debugging
		},
		config = require("setup.dap").setup,
	},
	{ "stevearc/overseer.nvim", cmd = 'LazyOverseer', config = require("setup.overseer").setup }, -- A task runner and job management plugin for Neovim
	-- { 'lvimuser/lsp-inlayhints.nvim',
	-- 	config = require("setup.lsp-inlayhints").setup,
	-- }, -- for Neovim < 0.10
}
