local M = {}

function M.apply(config, wezterm, platform)
  -- Renderer settings are per platform, at the bottom.

  -- Theme. Kept in lockstep with nvim's catppuccin flavour, set in
  -- .config/nvim/lua/plugins/colorscheme.lua. Note the spelling: the built-in
  -- scheme is the unaccented 'Catppuccin Frappe'. 'Catppuccin Frappé (Gogh)'
  -- is a different scheme with different colors.
  config.color_scheme = 'Catppuccin Frappe'

  -- 'Noto Sans Symbols 2' covers Miscellaneous Technical, which JetBrainsMono
  -- Nerd Font does not. Claude Code's status line draws its auto-mode indicator
  -- with U+23F5 (as two chars), and nothing shipped with Windows -- Segoe UI
  -- Symbol included -- has a glyph for it, so it rendered as tofu boxes.
  config.font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'Noto Sans Symbols 2',
    'Segoe UI Emoji',
    'Noto Sans Mono CJK SC',
  })
  config.font_size = 11
  -- Ligatures off.
  config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

  -- Sanity
  config.warn_about_missing_glyphs = false
  config.window_close_confirmation = 'NeverPrompt'
  config.audible_bell = 'Disabled'
  config.scrollback_lines = 10000

  -- Beam cursor, matching the terminal-mode cursor used in nvim. Steady: every
  -- blink is a redraw (every frame of it, when eased), which this laptop feels.
  -- A zero rate also ignores programs that ask for a blinking cursor.
  config.default_cursor_style = 'SteadyBar'
  config.cursor_blink_rate = 0

  -- Frame rate for easing effects. With the cursor steady, only the visual bell
  -- below animates, and only while it rings; the default of 10 would turn its
  -- 150 ms fades into a couple of steps.
  config.animation_fps = 60

  -- audible_bell is Disabled above, which left no bell feedback at all. Flash
  -- the cursor instead -- enough to catch a finished build or agent turn
  -- without strobing the whole pane.
  config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 150,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 150,
    target = 'CursorColor',
  }
  -- Since 20220903 `colors` layers on top of `color_scheme` rather than
  -- replacing it, so naming one key here leaves Catppuccin Frappe intact.
  config.colors = { visual_bell = '#ef9f76' } -- frappe peach

  -- Pane dimming
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.75 }

  -- Every window gets maximized on gui-attached, so don't let a font-size
  -- change resize the window out from under that.
  config.adjust_window_size_when_changing_font_size = false
  config.switch_to_last_active_tab_when_closing_tab = true

  -- Initial size
  config.initial_cols = 150
  config.initial_rows = 40

  if platform.is_linux then
    -- WebGpu reaches Vulkan here; the default OpenGL path struggles at high
    -- refresh rates.
    config.front_end = 'WebGpu'
    config.webgpu_power_preference = 'HighPerformance'
    config.max_fps = 144

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
    -- OpenGL rather than WebGpu. This laptop's screen hangs off an Intel HD
    -- 4600 (Haswell): no Vulkan, and wgpu skips its DX12, so WebGpu gained
    -- nothing -- and 'HighPerformance' rendered on the GTX 950M, copying every
    -- frame across to the Intel GPU. EGL here is ANGLE, i.e. Direct3D 11 on the
    -- Intel GPU (checked: libEGL/libGLESv2 + Intel's D3D11 driver load, and the
    -- process no longer shows in nvidia-smi). OpenGL has no vsync, so max_fps
    -- is the only cap; the panel is 60 Hz.
    config.front_end = 'OpenGL'
    config.prefer_egl = true
    config.max_fps = 60

    -- Solid, unblurred background: Acrylic lags window drags on Windows 10, and
    -- blur and transparency cost GPU time on every frame. No title bar buttons.
    config.window_decorations = 'RESIZE'
    config.win32_system_backdrop = 'Disable'
    config.window_background_opacity = 1.0
    config.window_padding = {
      left = '0cell',
      right = '0cell',
      top = '0.1cell',
      bottom = '0cell',
    }
  end

  -- Maximize all windows in the active workspace on GUI attach.
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
