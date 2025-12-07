-- Simple cross-platform clipboard config that works
-- Add this directly to your init.lua or save as lua/clipboard.lua

local function setup_clipboard()
  -- Check environment
  local is_wsl = vim.fn.has('wsl') == 1
  local is_win = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
  local is_mac = vim.fn.has('mac') == 1
  local is_ssh = os.getenv('SSH_TTY') ~= nil or os.getenv('SSH_CONNECTION') ~= nil
  
  -- WSL
  if is_wsl then
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 1,
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  -- Windows
  if is_win then
    vim.g.clipboard = {
      name = 'win32',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = 1,
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  -- macOS
  if is_mac then
    vim.g.clipboard = {
      name = 'macOS',
      copy = {
        ['+'] = 'pbcopy',
        ['*'] = 'pbcopy',
      },
      paste = {
        ['+'] = 'pbpaste',
        ['*'] = 'pbpaste',
      },
      cache_enabled = 1,
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  -- SSH with OSC 52
  if is_ssh then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  -- Linux
  if vim.fn.executable('xclip') == 1 then
    vim.g.clipboard = {
      name = 'xclip',
      copy = {
        ['+'] = 'xclip -selection clipboard',
        ['*'] = 'xclip -selection primary',
      },
      paste = {
        ['+'] = 'xclip -selection clipboard -o',
        ['*'] = 'xclip -selection primary -o',
      },
      cache_enabled = 1,
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  if vim.fn.executable('wl-copy') == 1 then
    vim.g.clipboard = {
      name = 'wayland',
      copy = {
        ['+'] = 'wl-copy',
        ['*'] = 'wl-copy --primary',
      },
      paste = {
        ['+'] = 'wl-paste --no-newline',
        ['*'] = 'wl-paste --no-newline --primary',
      },
      cache_enabled = 1,
    }
    vim.opt.clipboard = 'unnamedplus'
    return
  end
  
  -- Fallback: use default but with cache
  vim.opt.clipboard = 'unnamedplus'
end

-- Run setup
setup_clipboard()

-- Debug command
vim.api.nvim_create_user_command('ClipboardDebug', function()
  print('=== Clipboard Debug ===')
  print('Provider: ' .. (vim.g.clipboard and vim.g.clipboard.name or 'default'))
  print('Cache enabled: ' .. tostring(vim.g.clipboard and vim.g.clipboard.cache_enabled or false))
  print('WSL: ' .. tostring(vim.fn.has('wsl') == 1))
  print('Windows: ' .. tostring(vim.fn.has('win32') == 1))
  print('macOS: ' .. tostring(vim.fn.has('mac') == 1))
  print('SSH: ' .. tostring(os.getenv('SSH_TTY') ~= nil))
  print('xclip: ' .. tostring(vim.fn.executable('xclip') == 1))
  print('wl-copy: ' .. tostring(vim.fn.executable('wl-copy') == 1))
end, {})