local M = {}

function M.apply(config, wezterm, platform)
  -- Performance
  config.max_fps = 144

  -- Theme + font
  config.color_scheme = 'GruvboxDarkHard'
  config.font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'Segoe UI Emoji',
    'Noto Sans Mono CJK SC',
  })
  config.font_size = 11
  config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

  -- Sanity
  config.warn_about_missing_glyphs = false
  config.window_close_confirmation = 'NeverPrompt'
  config.audible_bell = 'Disabled'

  -- Pane dimming
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.75 }

  -- Initial size
  config.initial_cols = 150
  config.initial_rows = 40

  if platform.is_linux then
    config.window_decorations = 'NONE'
    config.enable_tab_bar = false
    config.window_background_opacity = 0.8
    config.window_padding = {
      left = '0.5cell',
      right = '0.5cell',
      top = '0.1cell',
      bottom = '0.1cell',
    }
  end

  if platform.is_windows then
    config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
    config.win32_system_backdrop = 'Acrylic'
    config.window_background_opacity = 0.85
    config.window_padding = {
      left = '0cell',
      right = '0cell',
      top = '0.1cell',
      bottom = '0cell',
    }

    config.default_prog = { 'nu' }
    config.launch_menu = {
      { label = 'WSL',             args = { 'wsl', '-d', 'fedora', '--cd', '~' } },
      { label = 'PowerShell',      args = { 'powershell', '-NoLogo' } },
      { label = 'Command Prompt',  args = { 'cmd' } },
    }

    for _, vsvers in ipairs(wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files (x86)')) do
      local year = vsvers:gsub('Microsoft Visual Studio/', '')
      table.insert(config.launch_menu, {
        label = 'x64 Native Tools VS ' .. year,
        args = {
          'cmd.exe',
          '/k',
          'C:/Program Files (x86)/' .. vsvers .. '/BuildTools/VC/Auxiliary/Build/vcvars64.bat',
        },
      })
    end
  end

  -- Maximize all windows in the active workspace on GUI attach
  wezterm.on('gui-attached', function()
    local workspace = wezterm.mux.get_active_workspace()
    for _, window in ipairs(wezterm.mux.all_windows()) do
      if window:get_workspace() == workspace then
        window:gui_window():maximize()
      end
    end
  end)
end

return M
