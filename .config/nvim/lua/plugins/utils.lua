return {
  { "dgrbrady/nvim-docker", enabled = false }, -- docker manager. TODO: enable and configure when needed
  -- {
  --     'krivahtoo/silicon.nvim',
  --     build = './install.sh build',
  --     config = require('setup.silicon').setup,
  -- }, -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
  "bennypowers/nvim-regexplainer", -- shows popup explaining regex under cursor
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
      { 'natecraddock/workspaces.nvim', config = true }
    },
    config = require("setup.telescope").setup,
  },
  -- session management and picker
  {
    "rmagatti/auto-session",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = require("setup.session").setup,
  },

  {
    "nvim-neorg/neorg",
    ft = {"norg"},
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = require("setup.neorg").setup,
  }
}
