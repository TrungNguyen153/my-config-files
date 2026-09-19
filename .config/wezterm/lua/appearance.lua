local M = {}

function M.apply(config, wezterm, platform)
  -- Renderer. WebGpu reaches DirectX 12 on Windows and Vulkan on Linux; the
  -- default OpenGL path struggles at high refresh rates.
  config.front_end = 'WebGpu'
  config.webgpu_power_preference = 'HighPerformance'
  config.max_fps = 144

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

  -- Beam cursor, matching the terminal-mode cursor used in nvim.
  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 500

  -- Frame rate for easing effects: cursor blink and the visual bell. This
  -- defaults to 10, which makes the blinking bar visibly steppy next to
  -- max_fps = 144. Easing the fade in both directions turns the blink into a
  -- pulse rather than a hard on/off toggle.
  config.animation_fps = 60
  config.cursor_blink_ease_in = 'EaseOut'
  config.cursor_blink_ease_out = 'EaseOut'

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
