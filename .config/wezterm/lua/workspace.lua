local M = {}

-- Normalize Windows backslashes to forward slashes. wezterm.glob and io.open
-- both accept forward slashes on Windows, and resurrect's path math is
-- forward-slash friendly.
local function norm(path)
  return (path:gsub('\\', '/'))
end

-- Compute the resurrect state directory.
-- Windows: %LOCALAPPDATA%\wezterm   Linux: $XDG_DATA_HOME/wezterm or ~/.local/share/wezterm
local function state_dir(wezterm)
  if wezterm.target_triple:find('windows') then
    local base = os.getenv('LOCALAPPDATA')
    if not base or base == '' then
      base = (os.getenv('USERPROFILE') or 'C:/Users/Default') .. '/AppData/Local'
    end
    return norm(base) .. '/wezterm'
  else
    local xdg = os.getenv('XDG_DATA_HOME')
    if xdg and xdg ~= '' then
      return xdg .. '/wezterm'
    end
    return (os.getenv('HOME') or '~') .. '/.local/share/wezterm'
  end
end

function M.apply(config, wezterm)
  local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
  local workspace_switcher = wezterm.plugin.require(
    'https://github.com/MLFlexer/smart_workspace_switcher.wezterm'
  )

  local dir = state_dir(wezterm)
  -- Trailing slash matters: resurrect concatenates `dir .. type .. sep .. name.json`
  -- with no separator inserted between dir and type.
  resurrect.state_manager.change_state_save_dir(dir .. '/')

  -- Auto-save every 60s. The plugin handles change detection internally
  -- by simply rewriting the state; if nothing changed, the JSON is identical.
  resurrect.state_manager.periodic_save({
    interval_seconds = 60,
    save_workspaces = true,
    save_windows = false,
    save_tabs = false,
  })

  -- Surface plugin errors as both a log line and a toast notification.
  -- Resurrect logs internally but swallows errors from save_state's return value,
  -- so without this handler quiet failures go unnoticed.
  wezterm.on('resurrect.error', function(err)
    wezterm.log_error('resurrect: ' .. tostring(err))
    for _, gw in ipairs(wezterm.gui.gui_windows()) do
      gw:toast_notification('wezterm', 'resurrect: ' .. tostring(err), nil, 5000)
    end
  end)

  -- Note on save-before-switch: the smart_workspace_switcher 'chosen' event
  -- fires AFTER the switch, so the mux_window at that point already reports
  -- the target workspace, not the source. There is no clean post-event hook
  -- for "the workspace we're leaving". We rely instead on periodic_save
  -- (every 60s, configured above) and the manual LEADER+S binding for
  -- precision saves. In practice the previous workspace was already saved
  -- by the periodic tick before the user switches.

  -- After a new workspace is created by the switcher, restore its saved state
  -- if one exists on disk. The callback receives a MuxWindow + the path
  -- (which is the working directory, not necessarily the workspace name).
  wezterm.on('smart_workspace_switcher.workspace_switcher.created', function(mux_window, _path)
    local label = mux_window:get_workspace()
    if not label or label == '' then return end

    local state = resurrect.state_manager.load_state(label, 'workspace')
    if not state then return end

    local ok, err = pcall(function()
      resurrect.workspace_state.restore_workspace(state, {
        window = mux_window,
        relative = true,
        restore_text = false,
        close_open_tabs = true,
        close_open_panes = true,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
      })
    end)
    if not ok then
      -- toast via any gui window (we only have a mux_window in this callback)
      for _, gw in ipairs(wezterm.gui.gui_windows()) do
        gw:toast_notification('wezterm', 'Restore failed: ' .. tostring(err), nil, 5000)
      end
      wezterm.log_error('workspace restore failed: ' .. tostring(err))
    end
  end)
end

return M
