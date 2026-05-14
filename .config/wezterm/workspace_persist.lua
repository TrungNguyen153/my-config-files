local wezterm = require('wezterm')

local M = {}

-- Normalize path separators to forward slashes (wezterm.glob and io.open
-- both accept forward slashes on Windows).
local function norm(path)
  return (path:gsub('\\', '/'))
end

-- Returns the data directory where workspace JSON files live.
-- Windows: %LOCALAPPDATA%\wezterm
-- Linux:   $XDG_DATA_HOME/wezterm or ~/.local/share/wezterm
-- The plugin creates `workspace/` (and `window/`, `tab/`) subdirs under this.
function M.state_dir()
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

-- Recursive mkdir. No-op if directory exists.
local function mkdir_p(path)
  if wezterm.target_triple:find('windows') then
    -- cmd's mkdir creates intermediate dirs by default. Backslash paths required.
    local win_path = path:gsub('/', '\\')
    os.execute('cmd /c if not exist "' .. win_path .. '" mkdir "' .. win_path .. '" 2>nul')
  else
    os.execute('mkdir -p "' .. path .. '" 2>/dev/null')
  end
end

M._mkdir_p = mkdir_p  -- exposed for testing

-- Cheap fingerprint of a workspace: concatenation of tab/pane structure
-- and cwds. Captures everything we care about for change detection without
-- serializing the whole state on every tick.
local function fingerprint_workspace(ws_name)
  local parts = { ws_name }
  for _, win in ipairs(wezterm.mux.all_windows()) do
    if win:get_workspace() == ws_name then
      for tab_idx, tab in ipairs(win:tabs()) do
        table.insert(parts, 't' .. tab_idx .. ':' .. (tab:get_title() or ''))
        for _, pane_info in ipairs(tab:panes_with_info()) do
          local pane = pane_info.pane
          local cwd_url = pane:get_current_working_dir()
          local cwd = cwd_url and cwd_url.file_path or ''
          table.insert(parts, string.format(
            'p%d,%dx%d,%s',
            pane:pane_id(),
            pane_info.width or 0,
            pane_info.height or 0,
            cwd
          ))
        end
      end
    end
  end
  return table.concat(parts, '|')
end

-- Last-seen fingerprint per workspace name. Tracks "what was on disk".
local last_fingerprint = {}
-- "Save is enqueued and pending" flag per workspace, to coalesce bursts.
local pending = {}
-- "Save is currently in flight" flag per workspace, to prevent concurrent writes.
local in_flight = {}

local function do_save(ws_name)
  pending[ws_name] = nil
  if in_flight[ws_name] then return end
  if not M.is_tracked(ws_name) then return end
  in_flight[ws_name] = true
  local resurrect = M._resurrect
  local ok, err = pcall(function()
    -- Note: get_workspace_state captures whatever is currently active in the
    -- mux, so this only auto-saves the active workspace. (Auto-saving an
    -- inactive tracked workspace would require iterating its tabs/panes
    -- manually; out of scope for this design.)
    local state = resurrect.workspace_state.get_workspace_state()
    resurrect.state_manager.save_state(state, ws_name)
  end)
  in_flight[ws_name] = nil
  if not ok then
    wezterm.log_error('workspace_persist auto-save failed for ' .. ws_name .. ': ' .. tostring(err))
  else
    last_fingerprint[ws_name] = fingerprint_workspace(ws_name)
  end
end

-- Schedule a save 1s in the future. Repeated calls within 1s coalesce.
local function debounced_save(ws_name)
  if pending[ws_name] then return end
  pending[ws_name] = true
  wezterm.time.call_after(1.0, function()
    do_save(ws_name)
  end)
end

M._debounced_save = debounced_save  -- exposed for testing
M._fingerprint_workspace = fingerprint_workspace

-- Initialize plugin and ensure data directories exist.
-- Must be called from wezterm.lua exactly once.
function M.setup(resurrect)
  local dir = M.state_dir()
  mkdir_p(dir)
  mkdir_p(dir .. '/workspace')
  resurrect.state_manager.change_state_save_dir(dir)
  M._resurrect = resurrect

  -- Auto-save: detect change via fingerprint and trigger debounced save.
  wezterm.on('update-status', function(window, _pane)
    local ws = window:active_workspace()
    if not M.is_tracked(ws) then return end
    local fp = fingerprint_workspace(ws)
    if fp ~= last_fingerprint[ws] then
      last_fingerprint[ws] = fp
      debounced_save(ws)
    end
  end)

  wezterm.on('window-resized', function(window, _pane)
    local ws = window:active_workspace()
    if M.is_tracked(ws) then
      debounced_save(ws)
    end
  end)

  -- Safety tick: every 60s, re-check the active workspace's fingerprint.
  -- Catches changes during long unfocused periods.
  local function tick()
    wezterm.time.call_after(60.0, function()
      for _, win in ipairs(wezterm.mux.all_windows()) do
        local ws = win:get_workspace()
        if M.is_tracked(ws) then
          local fp = fingerprint_workspace(ws)
          if fp ~= last_fingerprint[ws] then
            last_fingerprint[ws] = fp
            debounced_save(ws)
          end
        end
      end
      tick()
    end)
  end
  tick()

  wezterm.log_info('workspace_persist: state dir = ' .. dir)
end

-- Read a file's contents. Returns string or nil.
local function read_file(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  return content
end

-- Returns sorted list of saved workspace names (file basename without .json).
-- Files whose JSON fails to parse are omitted (logged as warnings).
function M.list_saved()
  local dir = M.state_dir() .. '/workspace'
  local files = wezterm.glob('*.json', dir) or {}
  local names = {}
  for _, filename in ipairs(files) do
    -- wezterm.glob returns just basenames; construct full path
    local path = dir .. '/' .. filename
    local content = read_file(path)
    if content then
      local parse_ok, _ = pcall(wezterm.json_parse, content)
      if parse_ok then
        local name = filename:match('([^/\\]+)%.json$')
        if name then
          table.insert(names, name)
        end
      else
        wezterm.log_warn('workspace_persist: skipping corrupt file: ' .. path)
      end
    end
  end
  table.sort(names)
  return names
end

-- True if a saved workspace file exists with this name.
function M.is_tracked(name)
  if not name or name == '' then return false end
  local path = M.state_dir() .. '/workspace/' .. name .. '.json'
  local f = io.open(path, 'r')
  if f then f:close() return true end
  return false
end

M.actions = {}

-- Save the current workspace under a user-chosen name.
-- Same-name input overwrites in place; a different name switches to a new
-- workspace and restores the captured layout there.
M.actions.save_current = wezterm.action_callback(function(window, pane)
  local resurrect = M._resurrect
  local current_name = window:active_workspace()
  window:perform_action(
    wezterm.action.PromptInputLine({
      description = 'Save workspace as:',
      initial_value = current_name,
      action = wezterm.action_callback(function(w, p, line)
        if not line or line == '' then return end
        local target = line

        local state = resurrect.workspace_state.get_workspace_state()
        local ok, err = pcall(resurrect.state_manager.save_state, state, target)
        if not ok then
          w:toast_notification('wezterm', 'Save failed: ' .. tostring(err), nil, 4000)
          wezterm.log_error('workspace_persist save_state failed: ' .. tostring(err))
          return
        end

        if target == current_name then
          w:toast_notification('wezterm', 'Saved workspace: ' .. target, nil, 2000)
          return
        end

        -- Rename path: switch to a workspace named `target`, restore the
        -- captured state into it. The old workspace persists in the mux until
        -- the user closes it.
        w:perform_action(
          wezterm.action.SwitchToWorkspace({ name = target }),
          p
        )

        -- Reload the state from disk (the saved file already encodes `target`
        -- as the workspace name in fresh tab spawns).
        local restored = resurrect.state_manager.load_state(target, 'workspace')
        if not restored then
          w:toast_notification('wezterm', 'Saved, but restore into new workspace failed', nil, 4000)
          return
        end

        local restore_ok, restore_err = pcall(function()
          resurrect.workspace_state.restore_workspace(restored, {
            window = w:mux_window(),
            relative = true,
            restore_text = false,
            close_open_tabs = true,
            close_open_panes = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          })
        end)
        if not restore_ok then
          w:toast_notification('wezterm', 'Saved as ' .. target .. ', but layout restore failed: ' .. tostring(restore_err), nil, 5000)
          wezterm.log_error('workspace_persist restore failed: ' .. tostring(restore_err))
          return
        end

        w:toast_notification('wezterm', 'Saved as ' .. target .. ' and switched', nil, 2500)
      end),
    }),
    pane
  )
end)

-- Helper: is workspace name currently live in the mux?
local function workspace_is_live(name)
  for _, live_name in ipairs(wezterm.mux.get_workspace_names()) do
    if live_name == name then return true end
  end
  return false
end

M.actions.load = wezterm.action_callback(function(window, pane)
  local resurrect = M._resurrect
  local names = M.list_saved()
  if #names == 0 then
    window:toast_notification('wezterm', 'No saved workspaces yet', nil, 2000)
    return
  end

  local choices = {}
  for _, name in ipairs(names) do
    table.insert(choices, { id = name, label = name })
  end

  window:perform_action(
    wezterm.action.InputSelector({
      title = 'Load workspace',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(w, p, id, _)
        if not id then return end

        if workspace_is_live(id) then
          w:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), p)
          w:toast_notification('wezterm', 'Workspace already active, switched to it', nil, 2000)
          return
        end

        -- Switch first (creates the workspace), then restore into it.
        w:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), p)

        local state = resurrect.state_manager.load_state(id, 'workspace')
        if not state then
          w:toast_notification('wezterm', 'Load failed: could not read state for ' .. id, nil, 4000)
          wezterm.log_error('workspace_persist load_state returned nil for ' .. id)
          return
        end

        local ok, err = pcall(function()
          resurrect.workspace_state.restore_workspace(state, {
            window = w:mux_window(),
            relative = true,
            restore_text = false,
            close_open_tabs = true,
            close_open_panes = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          })
        end)
        if not ok then
          w:toast_notification('wezterm', 'Load failed: ' .. tostring(err), nil, 5000)
          wezterm.log_error('workspace_persist restore failed: ' .. tostring(err))
          return
        end

        w:toast_notification('wezterm', 'Loaded workspace: ' .. id, nil, 2000)
      end),
    }),
    pane
  )
end)

M.actions.delete = wezterm.action_callback(function(window, pane)
  local resurrect = M._resurrect
  local names = M.list_saved()
  if #names == 0 then
    window:toast_notification('wezterm', 'No saved workspaces to delete', nil, 2000)
    return
  end

  local choices = {}
  for _, name in ipairs(names) do
    table.insert(choices, { id = name, label = name })
  end

  window:perform_action(
    wezterm.action.InputSelector({
      title = 'Delete workspace',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(w, p, id, _)
        if not id then return end

        -- Confirmation prompt
        w:perform_action(
          wezterm.action.PromptInputLine({
            description = 'Delete `' .. id .. '`? Type y to confirm:',
            initial_value = '',
            action = wezterm.action_callback(function(w2, p2, line)
              if line ~= 'y' and line ~= 'Y' then
                w2:toast_notification('wezterm', 'Delete cancelled', nil, 1500)
                return
              end

              local path = M.state_dir() .. '/workspace/' .. id .. '.json'
              local ok, err = pcall(resurrect.state_manager.delete_state, path)
              if not ok then
                w2:toast_notification('wezterm', 'Delete failed: ' .. tostring(err), nil, 4000)
                wezterm.log_error('workspace_persist delete_state failed: ' .. tostring(err))
                return
              end

              w2:toast_notification('wezterm', 'Deleted: ' .. id, nil, 2000)
            end),
          }),
          p
        )
      end),
    }),
    pane
  )
end)

return M
