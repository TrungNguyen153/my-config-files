---@diagnostic disable: different-requires
local fn = vim.fn
-- Good person config
-- https://github.com/augustocdias/dotfiles/blob/main/.config/nvim/lua/plugins.lua

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return require("packer").startup(function(use)
	-- packer embbed itself
	use("wbthomason/packer.nvim")

	-- Require util
	use("nvim-lua/plenary.nvim")

	-- Optimaze loader time lua module
	use({
		"lewis6991/impatient.nvim",
		config = function()
			require("configs.impatient")
		end,
	})

	-- Integrated with tmux navigator
	use("christoomey/vim-tmux-navigator")

	-- Amazing terminal
	use({
		"akinsho/toggleterm.nvim",
		config = function()
			require("configs.toggleterm")
		end,
	})

	-- Theme
	-- use({
	-- 	"morhetz/gruvbox",
	-- 	-- Perform set theme when loaded plugin
	-- 	config = function()
	-- 		vim.cmd([[
	--            set background=dark
	--            execute 'colorscheme' 'gruvbox'
	--        ]])
	-- 	end,
	-- })
	use({
		"NTBBloodbath/doom-one.nvim",
		config = function()
			require("configs.doom-one")
		end,
	})

	-- TreeSitter Group {{{
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		-- add plugin for treesitter
		requires = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "p00f/nvim-ts-rainbow" },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{ "windwp/nvim-ts-autotag" },
			{ "nvim-treesitter/nvim-treesitter-refactor" },
		},
		config = function()
			require("configs.treesitter")
		end,
	})

	use({
		"numToStr/Comment.nvim",
		require = { "JoosepAlviste/nvim-ts-context-commentstring" },
		after = { "nvim-treesitter" },
		config = function()
			require("configs.comment")
		end,
	})

	use({
		"abecodes/tabout.nvim",
		config = function()
			require("configs.tabout")
		end,
		wants = { "nvim-treesitter" }, -- or require if not used so far
		after = { "nvim-cmp" }, -- if a completion plugin is using tabs load it before
	})
	-- }}}

	-- LSP Group {{{
	use({
		"neovim/nvim-lspconfig",
		requires = { { "hrsh7th/cmp-nvim-lsp" }, { "folke/lsp-colors.nvim" } },
		config = function()
			-- Load setup for each lsp source
			require("lsp.init")
		end,
	})

	use({
		"williamboman/nvim-lsp-installer",
		requires = { "b0o/schemastore.nvim", "jose-elias-alvarez/nvim-lsp-ts-utils", "folke/lua-dev.nvim" }, -- for typescript helper
		config = function()
			require("lsp.lsp-installer")
		end,
	})

	-- Many useful stuff (Format Diagnostic CodeAction)
	use({
		"jose-elias-alvarez/null-ls.nvim",
		after = { "nvim-lspconfig", "plenary.nvim" },
		config = function()
			require("lsp.null-ls")
		end,
	})

	-- Flutter stuff
	use({
		"akinsho/flutter-tools.nvim",
		requires = { "nvim-lua/plenary.nvim", "RobertBrunhage/flutter-riverpod-snippets" },
		after = { "telescope.nvim", "LuaSnip" },
		config = function()
			require("lsp.settings.flutter-tools")
			require("telescope").load_extension("flutter")
		end,
	})

	-- Rust stuff
	use({
		"simrat39/rust-tools.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("lsp.settings.rust-tools")
		end,
	})
	use({
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		requires = { { "nvim-lua/plenary.nvim" } },
		config = function()
			require("crates").setup()
		end,
	})
	--- }}}

	-- debug
	-- check https://github.com/Pocco81/DAPInstall.nvim
	use({
		"Pocco81/DAPInstall.nvim",
		config = function()
			require("dap-install").setup({
				installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
			})
		end,
	})
	use({
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
	}) -- virtual text during debugging
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })

	-- Completion Group {{{
	use({
		requires = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-nvim-lua",
			"L3MON4D3/LuaSnip", --snippet engine
			"rafamadriz/friendly-snippets", -- a bunch of snippets to use
		},
		"hrsh7th/nvim-cmp",
		config = function()
			require("configs.cmp")
		end,
	})
	-- Auto Pairs
	use({
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		after = { "nvim-cmp" },
		config = function()
			require("configs.autopairs")
		end,
	})

	-- Disable for docker, should open for real devices
	use({
		"tzachar/cmp-tabnine",
		run = "./install.sh",
		requires = "hrsh7th/nvim-cmp",
		after = "nvim-cmp",
		config = function()
			require("configs.cmp-tabnine")
		end,
	})
	-- }}}

	-- TELESCOPE {{{
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
			{ "LinArcX/telescope-env.nvim" }, -- Watch environment variables with telescop
			{ "nvim-telescope/telescope-dap.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		config = function()
			require("configs.telescope")
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("env")
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("dap")
		end,
	})

	use({
		"rmagatti/auto-session",
		event = "VimEnter",
		config = function()
			require("configs.auto-session")
		end,
	})
	use({
		"rmagatti/session-lens",
		after = "auto-session",
		config = function()
			require("session-lens").setup({
				path_display = { "shorten" },
				winblend = 0,
			})
			require("telescope").load_extension("session-lens")
		end,
	})

	-- }}}

	-- UI {{{
	use({
		"stevearc/dressing.nvim",
	})
	-- Status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("configs.lualine")
		end,
	})

	-- Tab line
	use({
		"seblj/nvim-tabline",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("configs.tabline")
		end,
	})
	-- Zoom window
	use({
		"troydm/zoomwintab.vim",
		-- event = "ZoomWinTabToggle",
	})

	--Scrollbar
	use({
		"petertriho/nvim-scrollbar",
		requires = { "kevinhwang91/nvim-hlslens" },
		config = function()
			require("configs.nvim-scrollbar")
		end,
	})

	-- indent virtual
	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("configs.indentline")
		end,
	})

	-- Better quick fix plugin
	use({
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		cmd = "BqfAutoToggle",
		event = "QuickFixCmdPost",
		config = function()
			require("configs.bqf")
		end,
	})
	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("configs.gitsigns")
		end,
	})
	-- Color tag
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("configs.colorizer")
		end,
	})

	-- }}}

	-- Explorer {{{
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
		config = function()
			require("configs.nvim-tree")
		end,
	})
	--}}}

	--# FileType {{{
	-- use({
	-- 	"neoclide/jsonc.vim",
	-- })
	-- replaces filetype load from vim for a more performant one
	use({
		"nathom/filetype.nvim",
		config = function()
			require("filetype").setup({
				overrides = {
					complex = {
						["Dockerfile*"] = "dockerfile",
						-- Set the filetype of any full filename matching the regex to gitconfig
						[".*git/config"] = "gitconfig", -- Included in the plugin
					},
				},
			})
		end,
	})
	--}}}

	-- Misc {{{

	-- jj to exit insert mode
	use({
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("configs.better-escape")
		end,
	})

	-- makes better line moving
	use({
		"booperlv/nvim-gomove",
		config = function()
			require("configs.gomove")
		end,
	})

	-- Moving j k faster in normal/visual mode
	use({
		"PHSix/faster.nvim",
		event = { "VimEnter *" },
		config = function()
			require("configs.faster")
		end,
	})

	-- Jumper like vim-motion
	use({
		"phaazon/hop.nvim",
		branch = "v1", -- optional but strongly recommended
		config = function()
			require("configs.hop")
		end,
	})
	use("ur4ltz/surround.nvim") -- add surround commands
	-- Search in browser
	use({
		"voldikss/vim-browser-search",
		config = function()
			require("configs.vim-browser-search")
		end,
	})
	-- }}}

	use("tpope/vim-repeat") -- adds repeat functionality for other plugins
	use("andymass/vim-matchup") -- Enhances the %
	use({
		"nvim-pack/nvim-spectre",
		config = function()
			require("spectre").setup()
		end,
	}) -- special search and replace buffer
	use("rcarriga/nvim-notify") -- overides the default vim notify method for a floating window
	use({"j-hui/fidget.nvim", config = function ()
	  require"fidget".setup{}
	end}) -- status progress for lsp servers
	-- use({
	-- 	"wyattjsmith1/weather.nvim",
	-- 	requires = {
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("weather").setup({})
	-- 	end,
	-- }) -- adds weather information to status line
	use("meznaric/conmenu")
	use("segeljakt/vim-silicon") -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
	use({
		"luukvbaal/stabilize.nvim",
		config = function()
			require("stabilize").setup()
		end,
	}) -- stabilize buffer content on window open/close events
	use("farmergreg/vim-lastplace") -- remembers cursor position with nice features in comparison to just an autocmd
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			-- Trouble
			require("trouble").setup({
				use_diagnostic_signs = true,
			})
		end,
	}) -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
	use({
		"GustavoKatel/sidebar.nvim",
		config = function()
			require("sidebar-nvim").setup({
				open = false,
				side = "left",
				initial_width = 30,
				update_interval = 1000,
				hide_statusline = true,
				sections = { "git", "todos", "symbols", "diagnostics", "containers" },
				todos = {
					ignored_paths = { "~" },
					initially_closed = false,
				},
			})
		end,
	}) -- useful sidebar with todos, git status, etc.
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({
				signs = false,
				highlight = {
					comments_only = true,
				},
				search = {
					command = "rg",
					args = {
						"--max-depth=10",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
				},
			})
		end,
	}) -- todo comments helper
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
