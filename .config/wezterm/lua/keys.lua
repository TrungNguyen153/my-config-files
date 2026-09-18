local M = {}

-- Per-window zen mode: hides the tab bar and zeroes padding. Uses config
-- overrides so zen on one window doesn't affect the others.
local function toggle_zen(window)
  local overrides = window:get_config_overrides() or {}
  if overrides.enable_tab_bar == false then
    overrides.enable_tab_bar = nil
    overrides.window_padding = nil
  else
    overrides.enable_tab_bar = false
    overrides.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
  end
  window:set_config_overrides(overrides)
end

function M.apply(config, wezterm, platform)
  local act = wezterm.action
  local sessions = require('lua.sessions').actions(wezterm, platform)

  config.leader = { key = 't', mods = 'CTRL', timeout_milliseconds = 1000 }

  config.keys = {
    -- ---------- Panes ----------
    { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection('Left') },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection('Up') },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection('Right') },
    { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize({ 'Left', 3 }) },
    { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize({ 'Down', 3 }) },
    { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize({ 'Up', 3 }) },
    { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize({ 'Right', 3 }) },
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

    -- ---------- Tabs / Window ----------
    { key = 'n', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
    { key = '&', mods = 'LEADER', action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'n', mods = 'SHIFT|CTRL', action = act.ToggleFullScreen },

    -- ---------- Clipboard ----------
    { key = 'V', mods = 'CTRL', action = act.PasteFrom('Clipboard') },
    { key = 'C', mods = 'CTRL', action = act.CopyTo('Clipboard') },

    -- ---------- Projects / sessions ----------
    { key = 'f', mods = 'LEADER', action = sessions.projects },
    { key = 's', mods = 'LEADER', action = sessions.save },
    { key = 'r', mods = 'LEADER', action = sessions.restore },
    { key = 'd', mods = 'LEADER', action = sessions.delete },

    -- ---------- Utilities ----------
    { key = ' ', mods = 'LEADER', action = act.QuickSelect },
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = 'u', mods = 'LEADER', action = act.CharSelect },
    { key = '?', mods = 'LEADER', action = act.ActivateCommandPalette },
    {
      key = 'Z',
      mods = 'LEADER',
      action = wezterm.action_callback(function(window, _pane)
        toggle_zen(window)
      end),
    },
  }
end

return M
