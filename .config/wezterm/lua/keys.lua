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
    -- wezterm already binds CTRL+SHIFT+1..9 and CTRL+SHIFT+Tab for this; these
    -- are leader-consistent aliases, not new capability.
    { key = 'Tab', mods = 'LEADER', action = act.ActivateLastTab },
    {
      key = ',',
      mods = 'LEADER',
      action = act.PromptInputLine({
        description = 'Rename tab',
        action = wezterm.action_callback(function(window, _pane, line)
          if line and line ~= '' then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },

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
    { key = '/', mods = 'LEADER', action = act.Search({ CaseInSensitiveString = '' }) },
    -- Label every pane and jump to one by typing its letter. Shift swaps the
    -- chosen pane with the active one instead of focusing it.
    { key = 'p', mods = 'LEADER', action = act.PaneSelect({ mode = 'Activate' }) },
    { key = 'P', mods = 'LEADER', action = act.PaneSelect({ mode = 'SwapWithActive' }) },
    -- Sustained resizing: hjkl repeat until Escape, rather than re-arming the
    -- leader for every nudge. The one-shot LEADER+HJKL bindings above stay for
    -- single adjustments.
    {
      key = 'R',
      mods = 'LEADER',
      action = act.ActivateKeyTable({ name = 'resize_pane', one_shot = false }),
    },
  }

  -- ActivateTab is 0-indexed; LEADER+1 should select the first tab.
  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'LEADER',
      action = act.ActivateTab(i - 1),
    })
  end

  config.key_tables = {
    resize_pane = {
      { key = 'h', action = act.AdjustPaneSize({ 'Left', 2 }) },
      { key = 'j', action = act.AdjustPaneSize({ 'Down', 2 }) },
      { key = 'k', action = act.AdjustPaneSize({ 'Up', 2 }) },
      { key = 'l', action = act.AdjustPaneSize({ 'Right', 2 }) },
      { key = 'LeftArrow', action = act.AdjustPaneSize({ 'Left', 2 }) },
      { key = 'DownArrow', action = act.AdjustPaneSize({ 'Down', 2 }) },
      { key = 'UpArrow', action = act.AdjustPaneSize({ 'Up', 2 }) },
      { key = 'RightArrow', action = act.AdjustPaneSize({ 'Right', 2 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q', action = 'PopKeyTable' },
    },
  }
end

return M
