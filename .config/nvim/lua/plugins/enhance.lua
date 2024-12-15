return {
  {
    "folke/which-key.nvim",
    event = 'VeryLazy',
    config = function()
      local keymaps = require("setup.keymaps")
      keymaps.map_keys()
      require("setup.which-key").setup()
    end,
  }, -- shows the keybindings in a floating window.
  { "andymass/vim-matchup", event = 'VeryLazy', config = require("setup.matchup").setup }, -- Enhances the % and matches for blocks
  { "numToStr/Comment.nvim", event = 'VeryLazy', config = require("setup.comment").setup }, -- gcc to comment/uncomment line
  { "kylechui/nvim-surround", event = 'VeryLazy', config = require("setup.surround").setup }, -- add surround commands
  {
    "phaazon/hop.nvim",
    event = 'VeryLazy',
    branch = "v2",
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end,
  }, -- hop to different parts of the buffer
  {
    "booperlv/nvim-gomove",
    event = 'VeryLazy',
    config = true,
  }, -- makes better line moving
  {
    "nvim-pack/nvim-spectre",
    cmd = 'LazySpectre',
    config = true,
  }, -- special search and replace buffer
  "famiu/bufdelete.nvim", -- delete buffer and keep window layout
  "samjwill/nvim-unception", -- prevents an instance of neovim to be openend within neovim
  { "chrishrb/gx.nvim",
    event = 'VeryLazy',
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function ()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true
  }, -- gx opens urls, github issues etc in the browser
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  }, -- makes better insert mode escape
  {
    "PHSix/faster.nvim",
    event = 'VeryLazy',
    config = function()
      vim.api.nvim_set_keymap("n", "j", "<Plug>(faster_move_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("n", "k", "<Plug>(faster_move_k)", { noremap = false, silent = true })
      -- if you need map in visual mode
      vim.api.nvim_set_keymap("v", "j", "<Plug>(faster_vmove_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("v", "k", "<Plug>(faster_vmove_k)", { noremap = false, silent = true })
    end,
  }, -- A neovim plugin to accelerate j or k moving
  {
    'jake-stewart/multicursor.nvim',
    event = 'VeryLazy',
    branch = "1.0",
    config = true
  },
}
