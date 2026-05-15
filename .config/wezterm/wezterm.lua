local wezterm = require('wezterm')
local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')

local workspace_persist = require('workspace_persist')
workspace_persist.setup(resurrect)

local platform = {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
  is_linux   = wezterm.target_triple:find('linux')   ~= nil,
}

local mux = wezterm.mux

local function base_path_name(str)
    return string.gsub(str, '(.*[/\\])(.*)', '%2')
end

local function update_right_status(window)
    local title = base_path_name(window:active_workspace())
    window:set_right_status(wezterm.format({
        { Foreground = { Color = 'green' } },
        { Text = title .. '  ' },
    }))
end

wezterm.on('update-right-status', function(window, _)
    update_right_status(window)
end)

wezterm.on('gui-attached', function()
    local workspace = mux.get_active_workspace()
    for _, window in ipairs(mux.all_windows()) do
        if window:get_workspace() == workspace then
            window:gui_window():maximize()
        end
    end
end)

local config = wezterm.config_builder()

-- Module hooks (currently stubs; populated in later tasks)
require('lua.appearance').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm)
require('lua.workspace').apply(config, wezterm)
require('lua.keys').apply(config, wezterm)

-- ============================================================
-- BELOW: all existing config inlined. Migrated into modules in Tasks 2-5.
-- ============================================================

-- commons
config.max_fps = 144

-- theme stuff
config.color_scheme = 'GruvboxDarkHard'

config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 11
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- sanity wezterm settings
config.warn_about_missing_glyphs = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'

-- default window size
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
    config.window_padding = {
        left = '0cell',
        right = '0cell',
        top = '0.1cell',
        bottom = '0cell',
    }

    config.default_prog = { 'nu' }
    config.launch_menu = {
        {
            label = 'WSL',
            args = { 'wsl', '-d', 'fedora', '--cd', '~' },
        },
        {
            label = 'PowerShell',
            args = { 'powershell', '-NoLogo' },
        },
        {
            label = 'Command Prompt',
            args = { 'cmd' },
        },
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

-- key binding
config.leader = { key = 't', mods = 'CTRL' }
config.keys = {
    { key = '-', mods = 'LEADER', action = wezterm.action({ SplitVertical = { domain = 'CurrentPaneDomain' } }) },
    { key = '\\', mods = 'LEADER', action = wezterm.action({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }) },
    { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },
    { key = 'h', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Left' }) },
    { key = 'j', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Down' }) },
    { key = 'k', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Up' }) },
    { key = 'l', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Right' }) },
    { key = 'n', mods = 'LEADER', action = wezterm.action({ SpawnTab = 'CurrentPaneDomain' }) },
    { key = '&', mods = 'LEADER', action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
    { key = 'x', mods = 'LEADER', action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
    { key = 'n', mods = 'SHIFT|CTRL', action = 'ToggleFullScreen' },
    { key = 'w', mods = 'LEADER', action = workspace_persist.actions.manager },
    { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') },
    { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo('Clipboard') },
}

return config
