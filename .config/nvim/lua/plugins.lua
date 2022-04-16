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
			require("doom-one").setup({
				cursor_coloring = true,
				terminal_colors = true,
				italic_comments = true,
				enable_treesitter = true,
				transparent_background = false,
				pumblend = {
					enable = true,
					transparency_amount = 20,
				},
				plugins_integrations = {
					neorg = true,
					barbar = true,
					bufferline = true,
					gitgutter = false,
					gitsigns = true,
					telescope = false,
					neogit = true,
					nvim_tree = true,
					dashboard = true,
					startify = true,
					whichkey = true,
					indent_blankline = true,
					vim_illuminate = true,
					lspsaga = false,
				},
			})
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
			require("tabout").setup({
				tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
				backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
				act_as_tab = false, -- shift content if tab out is not possible
				act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
				enable_backwards = true, -- well ...
				completion = false, -- if the tabkey is used in a completion pum
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
				},
				ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
				exclude = {}, -- tabout will ignore these filetypes
			})
		end,
		wants = { "nvim-treesitter" }, -- or require if not used so far
		-- after = { "completion-nvim" }, -- if a completion plugin is using tabs load it before
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
			require("tabline").setup({
				no_name = "[No Name]", -- Name for buffers with no name
				modified_icon = "", -- Icon for showing modified buffer
				close_icon = "", -- Icon for closing tab with mouse
				separator = "▌", -- Separator icon on the left side
				padding = 3, -- Prefix and suffix space
				color_all_icons = false, -- Color devicons in active and inactive tabs
				right_separator = false, -- Show right separator on the last tab
				show_index = false, -- Shows the index of tab before filename
				show_icon = true, -- Shows the devicon
			})
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
  use("nathom/filetype.nvim")
	--}}}

	-- Misc {{{
	-- replaces filetype load from vim for a more performant one
	use("nathom/filetype.nvim")

	-- jj to exit insert mode
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

	-- makes better line moving
	use({
		"booperlv/nvim-gomove",
		config = function()
			require("gomove").setup({
				-- whether or not to map default key bindings, (true/false)
				map_defaults = true,
				-- whether or not to reindent lines moved vertically (true/false)
				reindent = true,
				-- whether or not to undojoin same direction moves (true/false)
				undojoin = false,
				-- whether to not to move past end column when moving blocks horizontally, (true/false)
				move_past_end_col = false,
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

	-- Jumper like vim-motion
	use({
		"phaazon/hop.nvim",
		branch = "v1", -- optional but strongly recommended
		config = function()
			-- you can configure Hop the way you like here; see :h hop-config
			require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
			vim.api.nvim_set_keymap("n", "ss", "<cmd>HopChar2<CR>", { noremap = false })
		end,
	})
  -- use({
  --   "ggandor/lightspeed.nvim",
  -- })
	-- text object + operator object
	-- HIGH SILL NEOVIM -> NEED TO MASTER THIS
	-- textobj-sandwich  -> ib is ab as
	-- operator-sandwich -> sa sd sr
	use({
		"machakann/vim-sandwich",
		config = function()
			vim.cmd([[
				runtime macros/sandwich/keymap/surround.vim
      ]])
		end,
	})
	-- Search in browser
	use({
		"voldikss/vim-browser-search",
		config = function()
			require("configs.vim-browser-search")
		end,
	})
	-- }}}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
