local M = {}

-- Per-window zen mode: hides tab bar + zeroes padding. Toggling stores the
-- "zen" state by setting overrides; toggling again clears them. Per-window
-- means zen on one window doesn't affect others.
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

function M.apply(config, wezterm)
  local act = wezterm.action
  local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
  local workspace_switcher = wezterm.plugin.require(
    'https://github.com/MLFlexer/smart_workspace_switcher.wezterm'
  )

  -- Save the current workspace's state on demand. Toasts on success.
  local save_current = wezterm.action_callback(function(window, _pane)
    local name = window:active_workspace()
    if not name or name == '' then
      window:toast_notification('wezterm', 'No active workspace to save', nil, 2000)
      return
    end
    local ok, err = pcall(function()
      resurrect.state_manager.save_state(
        resurrect.workspace_state.get_workspace_state(),
        name
      )
    end)
    if ok then
      window:toast_notification('wezterm', 'Saved: ' .. name, nil, 2000)
    else
      window:toast_notification('wezterm', 'Save failed: ' .. tostring(err), nil, 4000)
    end
  end)

  -- Fuzzy-pick a saved workspace state and delete its JSON.
  local delete_saved = wezterm.action_callback(function(window, pane)
    resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, _label)
      if not id then return end
      -- id is an absolute path like '<state_dir>/workspace/<name>.json'.
      -- delete_state expects a path relative to the configured save dir.
      local rel = id:match('([^/\\]+[/\\][^/\\]+%.json)$')
      if not rel then
        window:toast_notification('wezterm', 'Could not parse path: ' .. tostring(id), nil, 4000)
        return
      end
      local ok, err = pcall(resurrect.state_manager.delete_state, rel)
      if ok then
        window:toast_notification('wezterm', 'Deleted ' .. rel, nil, 2000)
      else
        window:toast_notification('wezterm', 'Delete failed: ' .. tostring(err), nil, 4000)
      end
    end, { is_fuzzy = true })
  end)

  config.leader = { key = 't', mods = 'CTRL', timeout_milliseconds = 1000 }

  config.keys = {
    -- ---------- Panes ----------
    { key = '-',  mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = 'h',  mods = 'LEADER', action = act.ActivatePaneDirection('Left') },
    { key = 'j',  mods = 'LEADER', action = act.ActivatePaneDirection('Down') },
    { key = 'k',  mods = 'LEADER', action = act.ActivatePaneDirection('Up') },
    { key = 'l',  mods = 'LEADER', action = act.ActivatePaneDirection('Right') },
    { key = 'z',  mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = 'x',  mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

    -- ---------- Tabs / Window ----------
    { key = 'n', mods = 'LEADER',     action = act.SpawnTab('CurrentPaneDomain') },
    { key = '&', mods = 'LEADER',     action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'n', mods = 'SHIFT|CTRL', action = act.ToggleFullScreen },

    -- ---------- Clipboard ----------
    { key = 'V', mods = 'CTRL', action = act.PasteFrom('Clipboard') },
    { key = 'C', mods = 'CTRL', action = act.CopyTo('Clipboard') },

    -- ---------- Workspace ----------
    { key = 'w', mods = 'LEADER', action = workspace_switcher.switch_workspace() },
    { key = 'W', mods = 'LEADER', action = workspace_switcher.switch_to_prev_workspace() },
    { key = 'S', mods = 'LEADER', action = save_current },
    { key = 'D', mods = 'LEADER', action = delete_saved },

    -- ---------- Pro-user utilities ----------
    { key = ' ', mods = 'LEADER', action = act.QuickSelect },
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = 'u', mods = 'LEADER', action = act.CharSelect },
    {
      key = 'Z', mods = 'LEADER',
      action = wezterm.action_callback(function(window, _pane) toggle_zen(window) end),
    },
  }
end

return M
