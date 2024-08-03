local wezterm = require("wezterm")
local mux = wezterm.mux
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local session_manager = require("wezterm-session-manager/session-manager")
wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

local function base_path_name(str)
  return string.gsub(str, "(.*[/\\])(.*)", "%2")
end

local function update_right_status(window)
  local title = base_path_name(window:active_workspace())
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "green" } },
    { Text = title .. "  " },
  }))
end

wezterm.on("update-right-status", function(window, _)
  update_right_status(window)
end)

wezterm.on('gui-attached', function(domain)
  -- maximize all displayed windows on startup
  local workspace = mux.get_active_workspace()
  for _, window in ipairs(mux.all_windows()) do
    if window:get_workspace() == workspace then
      window:gui_window():maximize()
    end
  end
end)

local config = {
  check_for_updates = false,
  color_scheme = "GruvboxDarkHard",
  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
  },
  default_prog = { "/bin/bash", "-l" },
  font = wezterm.font("RobotoMono Nerd Font Propo"),
  font_size = 8.0,
  launch_menu = {},
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  hide_tab_bar_if_only_one_tab = true,
  scrollback_lines = 3000,
  enable_scroll_bar = false,
  leader = { key = "t", mods = "CTRL" },
  disable_default_key_bindings = true,
  keys = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    { key = "a", mods = "LEADER|CTRL",  action = wezterm.action({ SendString = "\x01" }) },
    -- split
    {
      key = "-",
      mods = "LEADER",
      action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
    },
    {
      key = "\\",
      mods = "LEADER",
      action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
    },
    -- zoom focus pane
    { key = "z", mods = "LEADER",       	action = "TogglePaneZoomState" },
    -- switch pane
    { key = "h", mods = "LEADER",       	action = wezterm.action({ ActivatePaneDirection = "Left" }) },
    { key = "j", mods = "LEADER",       	action = wezterm.action({ ActivatePaneDirection = "Down" }) },
    { key = "k", mods = "LEADER",       	action = wezterm.action({ ActivatePaneDirection = "Up" }) },
    { key = "l", mods = "LEADER",       	action = wezterm.action({ ActivatePaneDirection = "Right" }) },
    -- Adjust pane size
    { key = "h", mods = "LEADER|CTRL",  	action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
    { key = "j", mods = "LEADER|CTRL",  	action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
    { key = "k", mods = "LEADER|CTRL",  	action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
    { key = "l", mods = "LEADER|CTRL",  	action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
    -- tab switching
    { key = "1", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 0 }) },
    { key = "2", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 1 }) },
    { key = "3", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 2 }) },
    { key = "4", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 3 }) },
    { key = "5", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 4 }) },
    { key = "6", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 5 }) },
    { key = "7", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 6 }) },
    { key = "8", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 7 }) },
    { key = "9", mods = "LEADER",       	action = wezterm.action({ ActivateTab = 8 }) },
    -- Open new tab
    { key = "n", mods = "LEADER",       	action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
    -- close Tab
    { key = "&", mods = "LEADER|SHIFT", 	action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
    -- close pane
    { key = "x", mods = "LEADER",       	action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
    -- Toggle full
    { key = "n", mods = "SHIFT|CTRL",   	action = "ToggleFullScreen" },
    -- Copy paste
    { key = "v", mods = "SHIFT|CTRL",   	action = wezterm.action.PasteFrom("Clipboard") },
    { key = "c", mods = "SHIFT|CTRL",   	action = wezterm.action.CopyTo("Clipboard") },
    { key = "w", mods = "LEADER", 		action = workspace_switcher.switch_workspace(), },
    -- Session Manager
    {key  = "S",  mods = "LEADER|SHIFT", 	action = wezterm.action{EmitEvent = "save_session"}},
    {key  = "L",  mods = "LEADER|SHIFT", 	action = wezterm.action{EmitEvent = "load_session"}},
    {key  = "R",  mods = "LEADER|SHIFT", 	action = wezterm.action{EmitEvent = "restore_session"}},
  },
  set_environment_variables = {},
  window_padding = {
    left = '0cell',
    right = '0cell',
    top = '0.1cell',
    bottom = '0cell',
  },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.front_end = "OpenGL" -- OpenGL doesn't work quite well with RDP.
  config.term = ""           -- Set to empty so FZF works on windows
  config.default_prog = { "nu" }
  config.window_background_image = ""
  table.insert(config.launch_menu, { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } })
  table.insert(config.launch_menu, { label = "CMD", args = { "cmd.exe" } })

  -- Find installed visual studio version(s) and add their compilation
  -- environment command prompts to the menu
  for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*", "C:/Program Files (x86)")) do
    local year = vsvers:gsub("Microsoft Visual Studio/", "")
    table.insert(config.launch_menu, {
      label = "x64 Native Tools VS " .. year,
      args = {
        "cmd.exe",
        "/k",
        "C:/Program Files (x86)/" .. vsvers .. "/BuildTools/VC/Auxiliary/Build/vcvars64.bat",
      },
    })
  end
else
  table.insert(config.launch_menu, { label = "bash", args = { "bash", "-l" } })
  table.insert(config.launch_menu, { label = "fish", args = { "fish", "-l" } })
end

return config
