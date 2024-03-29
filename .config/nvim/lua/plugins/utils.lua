return {
  { "dgrbrady/nvim-docker", enabled = false }, -- docker manager. TODO: enable and configure when needed
  -- {
  --     'krivahtoo/silicon.nvim',
  --     build = './install.sh build',
  --     config = require('setup.silicon').setup,
  -- }, -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
  { 'bennypowers/nvim-regexplainer', cmd = 'LazyRegexplainer' }, -- shows popup explaining regex under cursor
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = require("setup.neotree").setup,
  }, -- file browser
  {
    "stevearc/oil.nvim",
    config = require("setup.oil").setup,
  }, -- file browser. eventually should replace neo-tree
  { "akinsho/toggleterm.nvim", config = require("setup.toggleterm").setup }, -- better terminal
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { -- pickers
      "gbrlsnchs/telescope-lsp-handlers.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-telescope/telescope-live-grep-raw.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = require("setup.telescope").setup,
  },
  {
    "nvim-neorg/neorg",
    ft = {"norg"},
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("setup.neorg").setup,
  },
  -- {
	-- 	"goolord/alpha-nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- 	config = require("setup.alpha").setup,
	-- },
  {
    "coffebar/neovim-project",
    init = function()
      -- enable saving the state of plugins in the session
      vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
      { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 10,
    opts = {
      projects = { -- define project roots
        "D:/rust-workspace/*",
      },
    },
  },
}
