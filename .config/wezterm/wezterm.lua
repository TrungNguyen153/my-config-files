local wezterm = require('wezterm')

local config = wezterm.config_builder()
local platform = require('lua.platform')

require('lua.appearance').apply(config, wezterm, platform)
require('lua.domains').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm, platform)
require('lua.sessions').apply(config, wezterm, platform)
require('lua.keys').apply(config, wezterm, platform)

return config
