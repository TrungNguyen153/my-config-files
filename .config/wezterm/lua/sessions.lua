local M = {}

-- Session persistence + project switching.
--
-- Persistence uses StephenGemin/resurrect.wezterm, the maintained fork of
-- MLFlexer/resurrect.wezterm. The original is archived, and its
-- utils.ensure_folder_exists shipped a Windows-fatal bug -- it ran
-- `mkdir /p "..."` with the closing quote misplaced into the gsub replacement,
-- so the state folder was never created and every save failed silently at
-- io.open(). The fork fixes that; we also create the folder ourselves below so
-- persistence never again depends on a plugin getting mkdir right.
--
-- Project switching uses mikkasendke/sessionizer.wezterm, which finds git repos
-- with `fd`. The previous smart_workspace_switcher needed zoxide, which is not
-- installed here, so its keybinding was dead.

local RESURRECT_URL = 'https://github.com/StephenGemin/resurrect.wezterm'
local SESSIONIZER_URL = 'https://github.com/mikkasendke/sessionizer.wezterm'

local function toast(window, message, ms)
  window:toast_notification('wezterm', message, nil, ms or 2000)
end

local function toast_all(wezterm, message, ms)
  for _, gui_window in ipairs(wezterm.gui.gui_windows()) do
    gui_window:toast_notification('wezterm', message, nil, ms or 5000)
  end
end

-- Create `path` if it is missing. wezterm.glob returns the path itself when it
-- exists, so an empty result means we need to make it.
local function ensure_dir(wezterm, platform, path)
  local found, entries = pcall(wezterm.glob, path)
  if found and entries and #entries > 0 then
    return
  end

  local args
  if platform.is_windows then
    -- cmd's mkdir creates intermediate directories on its own; there is no -p.
    args = { 'cmd', '/c', 'mkdir', (path:gsub('/', '\\')) }
  else
    args = { 'mkdir', '-p', path }
  end
  pcall(wezterm.run_child_process, args)
end

-- Split a path reported by resurrect's fuzzy loader into (kind, name), e.g.
-- '<state_dir>/workspace/my-project.json' -> 'workspace', 'my-project'.
local function split_state_id(id)
  local kind = id:match('([^/\\]+)[/\\][^/\\]+%.json$')
  local name = id:match('([^/\\]+)%.json$')
  return kind or 'workspace', name
end

-- Turn a project path into a workspace name. fd emits mixed separators on
-- Windows ('C:/Users/OS/Desktop/Workspace\rust\Zeus'), and sessionizer's
-- DefaultCallback would use that whole string as the workspace name. resurrect
-- saves state to '<dir>/workspace/<name>.json', so a name containing separators
-- makes io.open fail -- the same class of silent-save failure this config exists
-- to fix. Use the final path component instead.
local function workspace_name(path)
  return path:match('([^/\\]+)[/\\]*$') or path
end

-- Build the keybinding actions. Memoized so keys.lua can ask for them without
-- depending on apply() having run first.
function M.actions(wezterm, platform)
  if M._actions then
    return M._actions
  end

  local resurrect = wezterm.plugin.require(RESURRECT_URL)
  local sessionizer = wezterm.plugin.require(SESSIONIZER_URL)

  -- Save the current workspace on demand.
  local save = wezterm.action_callback(function(window, _pane)
    local name = window:active_workspace()
    if not name or name == '' then
      toast(window, 'No active workspace to save')
      return
    end
    local ok, err = pcall(function()
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state(), name)
    end)
    if ok then
      toast(window, 'Saved: ' .. name)
    else
      toast(window, 'Save failed: ' .. tostring(err), 4000)
    end
  end)

  -- Fuzzy-pick a saved state and restore it into the current window.
  local restore = wezterm.action_callback(function(window, pane)
    resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, _label)
      if not id then
        return
      end
      local kind, name = split_state_id(id)
      if not name then
        toast(window, 'Could not parse state path: ' .. tostring(id), 4000)
        return
      end

      local ok, err = pcall(function()
        local state = resurrect.state_manager.load_state(name, kind)
        if not state then
          error('no saved state named ' .. name)
        end
        resurrect.workspace_state.restore_workspace(state, {
          window = window:mux_window(),
          relative = true,
          restore_text = false,
          close_open_tabs = true,
          close_open_panes = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        })
      end)
      if not ok then
        toast(window, 'Restore failed: ' .. tostring(err), 4000)
      end
    end, { is_fuzzy = true })
  end)

  -- Fuzzy-pick a saved state and delete its JSON.
  local delete = wezterm.action_callback(function(window, pane)
    resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, _label)
      if not id then
        return
      end
      -- delete_state wants a path relative to the configured save dir.
      local rel = id:match('([^/\\]+[/\\][^/\\]+%.json)$')
      if not rel then
        toast(window, 'Could not parse state path: ' .. tostring(id), 4000)
        return
      end
      local ok, err = pcall(resurrect.state_manager.delete_state, rel)
      if ok then
        toast(window, 'Deleted ' .. rel)
      else
        toast(window, 'Delete failed: ' .. tostring(err), 4000)
      end
    end, { is_fuzzy = true })
  end)

  -- Open the chosen entry as a workspace named after its directory.
  local function switch_to_project(window, pane, id, _label)
    if not id then
      return
    end

    -- FdSearch yields absolute paths; DefaultWorkspace and AllActiveWorkspaces
    -- yield plain workspace names. Only a path is meaningful as a spawn cwd.
    local is_path = id:find('[/\\]') ~= nil
    local action
    if is_path then
      action = wezterm.action.SwitchToWorkspace({
        name = workspace_name(id),
        spawn = { cwd = id },
      })
    else
      action = wezterm.action.SwitchToWorkspace({ name = id })
    end

    window:perform_action(action, pane)
  end

  -- Project picker: every git repo under the projects root, plus whatever
  -- workspaces are already live.
  local schema = {
    options = {
      title = 'Projects',
      prompt = 'Select project: ',
      always_fuzzy = true,
      callback = switch_to_project,
    },
    sessionizer.DefaultWorkspace({}),
    sessionizer.AllActiveWorkspaces({}),
    sessionizer.FdSearch({
      platform.projects_dir,
      max_depth = 3, -- reaches nested repos such as rust/<project>
      exclude = { 'node_modules', 'target', 'build', '.cargo' },
    }),
  }

  M._actions = {
    projects = sessionizer.show(schema),
    save = save,
    restore = restore,
    delete = delete,
  }
  return M._actions
end

function M.apply(_config, wezterm, platform)
  local resurrect = wezterm.plugin.require(RESURRECT_URL)

  local dir = platform.state_dir
  ensure_dir(wezterm, platform, dir)
  ensure_dir(wezterm, platform, dir .. '/workspace')

  -- Trailing slash matters: resurrect concatenates `dir .. kind .. sep .. name.json`
  -- without inserting a separator after dir.
  resurrect.state_manager.change_state_save_dir(dir .. '/')

  resurrect.state_manager.periodic_save({
    interval_seconds = 60,
    save_workspaces = true,
    save_windows = false,
    save_tabs = false,
  })

  -- Surface plugin errors loudly. A silent failure here is exactly what hid the
  -- broken-mkdir bug in the archived plugin for months.
  wezterm.on('resurrect.error', function(err)
    wezterm.log_error('resurrect: ' .. tostring(err))
    toast_all(wezterm, 'resurrect: ' .. tostring(err))
  end)

  -- Warm the action cache so the plugins are fetched at config load rather than
  -- on first keypress.
  M.actions(wezterm, platform)
end

return M
