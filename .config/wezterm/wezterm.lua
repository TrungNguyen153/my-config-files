local wezterm = require('wezterm')
local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')

local workspace_persist = require('workspace_persist')
workspace_persist.setup(resurrect)

local platform = {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
  is_linux   = wezterm.target_triple:find('linux')   ~= nil,
}

local config = wezterm.config_builder()

-- Module hooks (currently stubs; populated in later tasks)
require('lua.appearance').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm)
require('lua.workspace').apply(config, wezterm)
require('lua.keys').apply(config, wezterm)

-- key binding
config.leader = { key = 't', mods = 'CTRL' }
config.keys = {
    { key = '-', mods = 'LEADER', action = wezterm.action({ SplitVertical = { domain = 'CurrentPaneDomain' } }) },
    { key = '\\', mods = 'LEADER', action = wezterm.action({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }) },
    { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },
    { key = 'h', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Left' }) },
    { key = 'j', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Down' }) },
    { key = 'k', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Up' }) },
    { key = 'l', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Right' }) },
    { key = 'n', mods = 'LEADER', action = wezterm.action({ SpawnTab = 'CurrentPaneDomain' }) },
    { key = '&', mods = 'LEADER', action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
    { key = 'x', mods = 'LEADER', action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
    { key = 'n', mods = 'SHIFT|CTRL', action = 'ToggleFullScreen' },
    { key = 'w', mods = 'LEADER', action = workspace_persist.actions.manager },
    { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') },
    { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo('Clipboard') },
}

return config
