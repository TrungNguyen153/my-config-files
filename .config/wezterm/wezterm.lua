local wezterm = require('wezterm')

local platform = {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
  is_linux   = wezterm.target_triple:find('linux')   ~= nil,
}

local config = wezterm.config_builder()

require('lua.appearance').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm)
require('lua.workspace').apply(config, wezterm)
require('lua.keys').apply(config, wezterm)

return config
