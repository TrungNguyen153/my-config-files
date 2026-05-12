local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require('utils.custom_fold')
require('settings.general')
require('settings.gui')
require('settings.neovide')
require('settings.unception')
require('utils.keymaps').map_keys()
local is_wsl = vim.fn.has('wsl') == 1
local lockfile_name = is_wsl and 'lazy-lock.wsl.json' or 'lazy-lock.windows.json'

require('lazy').setup('plugins', {
    lockfile = vim.fn.stdpath('config') .. '/' .. lockfile_name,
    checker = {
        enabled = true,
        frequency = 7200,
    },
    rocks = {
        enabled = false,
    },
})
require('utils.clipboard')

require('utils.autocommands').setup()
