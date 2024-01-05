return {
	{ "rcarriga/nvim-notify", config = require("setup.notify").setup }, -- overides the default vim notify method for a floating window
	{ "j-hui/fidget.nvim", tag = "legacy", config = require("setup.fidget").setup }, -- status progress for lsp servers
	{
		"nvim-lualine/lualine.nvim",
		event = "UIEnter",
		config = function()
			local signature = require("setup.lsp_signature")
			-- local weather = require('setup.weather')
			require("setup.lualine").setup(
				signature.status_line,
				-- weather.status_line,
				nil,
				require("setup.nvim-navic").winbar
			)
		end,
	}, -- status line
	-- {
	-- 	'AlexvZyl/nordic.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require 'nordic' .load()
	-- 	end
	-- }, -- theme
	{
		"Mofiqul/vscode.nvim",
		config = require("setup.vscode-theme").setup,
	}, -- theme
	-- {
	--   'catppuccin/nvim',
	--   config = function()
	--     require('setup.catppuccin').setup('latte')
	--   end,
	-- }, -- theme
	-- {
	--   "NTBBloodbath/doom-one.nvim",
	--   config = require("setup.doom-one").setup,
	-- }, -- theme
	-- {
	--   "marko-cerovac/material.nvim",
	--   config = require("setup.material-color").setup,
	-- }, -- theme
	{
		-- 'romgrk/barbar.nvim',
		"nanozuki/tabby.nvim",
		-- requires = { -- tabline
		--     'tiagovla/scope.nvim', -- creates scopes for splitting buffers per tabs
		-- },
		config = require("setup.tabline").setup,
	},
	{ "lewis6991/gitsigns.nvim", config = require("setup.gitsigns").setup }, -- show git indicators next to the line numbers (lines changed, added, etc.)
	{
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup()
		end,
	}, -- creates a tab focd on diff view and git history
	{
		"lukas-reineke/indent-blankline.nvim",
		tag = "v2.20.8",
		config = require("setup.blankline").setup,
	}, -- Adds a | to show indentation levels
	{ "folke/todo-comments.nvim", config = require("setup.todo-comments").setup }, -- todo comments helper
	-- { 'wyattjsmith1/weather.nvim', config = require('setup.weather').setup }, -- adds weather information to status line
	-- {
	-- 	"zbirenbaum/neodim",
	-- 	event = "LspAttach",
	-- 	config = require("setup.neodim").setup,
	-- },
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = require("setup.alpha").setup,
	},
	-- {
	--   'KadoBOT/nvim-spotify',
	--   build = 'make',
	--   config = function()
	--     require('nvim-spotify').setup({
	--       update_interval = 5000,
	--     })
	--   end,
	-- },
}
