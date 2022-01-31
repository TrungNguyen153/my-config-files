local fn = vim.fn

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

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

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
	use("wbthomason/packer.nvim")
	-- Require ulti
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
	use({
		"akinsho/toggleterm.nvim",
		config = function()
			require("configs.toggleterm")
		end,
	})
	-- Theme
	use({
		"morhetz/gruvbox",
		-- Perform set theme when loaded plugin
		config = function()
			vim.cmd([[
            set background=dark
            execute 'colorscheme' 'gruvbox'
        ]])
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
    requires = {"jose-elias-alvarez/nvim-lsp-ts-utils"}, -- for typescript helper
		config = function()
			require("lsp.lsp-installer")
		end,
	})

	-- language server settings defined in json for
	use("tamago324/nlsp-settings.nvim")

	use({
		"jose-elias-alvarez/null-ls.nvim",
		after = { "nvim-lspconfig", "plenary.nvim" },
		config = function()
			require("lsp.null-ls")
		end,
	})
	--- }}}

	-- Completion Group {{{
	use({
		"hrsh7th/nvim-cmp",
		config = function()
			require("configs.cmp")
		end,
	})
	use("hrsh7th/cmp-buffer") -- buffer completions
	use("hrsh7th/cmp-path") -- path completions
	use("hrsh7th/cmp-cmdline") -- cmdline completions
	use("saadparwaiz1/cmp_luasnip") -- snippet completions
	use("hrsh7th/cmp-nvim-lsp")
	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use
	-- Auto Pairs
	use({
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("configs.autopairs")
		end,
	})

	-- Disable for docker, should open for real devices
	-- use {'tzachar/cmp-tabnine',
	--   run='./install.sh',
	--   after = 'nvim-cmp',
	--   config = function()
	--     require('configs.cmp-tabnine')
	--   end,
	-- }
	-- }}}

	-- TELESCOPE {{{
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
			{ "LinArcX/telescope-env.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		config = function()
			require("configs.telescope")
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("env")
			require("telescope").load_extension("ui-select")
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
	-- Status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("configs.lualine")
		end,
	})

	use({
		"akinsho/bufferline.nvim",
		requires = { "kyazdani42/nvim-web-devicons", "moll/vim-bbye" },
		config = function()
			require("configs.bufferline")
		end,
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("configs.indentline")
		end,
	})

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

	-- ulti {{{
	use({
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup({
				mapping = { "jj" }, -- a table with mappings to use
				timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
				clear_empty_lines = false, -- clear line after escaping if there is only whitespace
				keys = "<Esc>", -- keys used for escaping, if it is a function will use the result everytime
				-- example
				-- keys = function()
				--   return vim.fn.col '.' - 2 >= 1 and '<esc>l' or '<esc>'
				-- end,
			})
		end,
	})

	-- Moving j k faster in normal/visual mode
	use({
		"PHSix/faster.nvim",
		event = { "VimEnter *" },
		config = function()
			-- vim.api.nvim_set_keymap('n', 'j', '<Plug>(faster_move_j)', {noremap=false, silent=true})
			-- vim.api.nvim_set_keymap('n', 'k', '<Plug>(faster_move_k)', {noremap=false, silent=true})
			-- or
			vim.api.nvim_set_keymap("n", "j", "<Plug>(faster_move_gj)", { noremap = false, silent = true })
			vim.api.nvim_set_keymap("n", "k", "<Plug>(faster_move_gk)", { noremap = false, silent = true })
			-- if you need map in visual mode
			vim.api.nvim_set_keymap("v", "j", "<Plug>(faster_vmove_j)", { noremap = false, silent = true })
			vim.api.nvim_set_keymap("v", "k", "<Plug>(faster_vmove_k)", { noremap = false, silent = true })
		end,
	})

	-- jump anywhere on screen
	use({
		"easymotion/vim-easymotion",
		config = function()
			vim.cmd([[
          let g:EasyMotion_do_mapping = 0
          nmap <Leader><Leader>s <Plug>(easymotion-overwin-f)
          " Turn on case-insensitive feature
          let g:EasyMotion_smartcase = 1
        ]])
		end,
	})

	-- }}}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
