return {
	{ "rcarriga/nvim-notify", config = require("setup.notify").setup }, -- overides the default vim notify method for a floating window
	{ 'MunifTanjim/nui.nvim',   enabled = not vim.g.vscode }, -- base ui components for nvim
    { 'stevearc/dressing.nvim', enabled = not vim.g.vscode }, -- overrides the default vim input to provide better visuals
	-- { "j-hui/fidget.nvim", tag = "legacy", config = require("setup.fidget").setup }, -- status progress for lsp servers
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
	{
        'folke/noice.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
        },
        config = function()
            require('setup.noice').setup()
        end,
    }, -- adds various ui enhancements such as a popup for the cmd line, lsp progress
	-- {
	-- 	'AlexvZyl/nordic.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require 'nordic' .load()
	-- 	end
	-- }, -- theme
	-- {
	-- 	"Mofiqul/vscode.nvim",
	-- 	config = require("setup.vscode-theme").setup,
	-- }, -- theme
	-- {
	--   'catppuccin/nvim',
	--   lazy = false,
	--   priority = 150,
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
	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = require("setup.gruvbox").setup },
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
		cmd = 'LazyDiffView',
		config = function()
			require("diffview").setup()
		end,
	}, -- creates a tab focd on diff view and git history
    {
        'lukas-reineke/indent-blankline.nvim',
		dependencies = {"nvim-treesitter/nvim-treesitter"},
        main = 'ibl',
        config = require('setup.blankline').setup,
    }, -- Adds a | to show indentation levels
	{ "folke/todo-comments.nvim", config = require("setup.todo-comments").setup }, -- todo comments helper
	-- { 'wyattjsmith1/weather.nvim', config = require('setup.weather').setup }, -- adds weather information to status line
	-- {
	-- 	"zbirenbaum/neodim",
	-- 	event = "LspAttach",
	-- 	config = require("setup.neodim").setup,
	-- },
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
