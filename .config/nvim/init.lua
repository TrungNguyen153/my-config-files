-- From Good person config
-- https://github.com/augustocdias/dotfiles/blob/main/.config/nvim/

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("settings.general")
require("settings.gui")
require('settings.neovide')
require("settings.unception")
require("lazy").setup("plugins", {
  checker = {
    enabled = false,
    frequency = 7200,
  },
})
require("setup.autocommand").setup()
