return {
  {
    "folke/which-key.nvim",
    config = function()
      local keymaps = require("setup.keymaps")
      keymaps.map_keys()
      require("setup.which-key").setup(keymaps.which_key)
    end,
  }, -- shows the keybindings in a floating window.
  { "andymass/vim-matchup", config = require("setup.matchup").setup }, -- Enhances the % and matches for blocks
  { "numToStr/Comment.nvim", config = require("setup.comment").setup }, -- gcc to comment/uncomment line
  { "kylechui/nvim-surround", config = require("setup.surround").setup }, -- add surround commands
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end,
  }, -- hop to different parts of the buffer
  {
    "booperlv/nvim-gomove",
    config = function()
      require("gomove").setup()
    end,
  }, -- makes better line moving
  {
    "nvim-pack/nvim-spectre",
    config = function()
      require("spectre").setup()
    end,
  }, -- special search and replace buffer
  "famiu/bufdelete.nvim", -- delete buffer and keep window layout
  "samjwill/nvim-unception", -- prevents an instance of neovim to be openend within neovim
  { "chrishrb/gx.nvim", config = true }, -- gx opens urls, github issues etc in the browser
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  }, -- makes better insert mode escape
  {
    "PHSix/faster.nvim",
    event = { "VimEnter *" },
    config = function()
      vim.api.nvim_set_keymap("n", "j", "<Plug>(faster_move_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("n", "k", "<Plug>(faster_move_k)", { noremap = false, silent = true })
      -- if you need map in visual mode
      vim.api.nvim_set_keymap("v", "j", "<Plug>(faster_vmove_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("v", "k", "<Plug>(faster_vmove_k)", { noremap = false, silent = true })
    end,
  }, -- A neovim plugin to accelerate j or k moving
}
