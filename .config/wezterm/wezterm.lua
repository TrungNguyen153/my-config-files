local wezterm = require('wezterm')
local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')

local workspace_persist = require('workspace_persist')
workspace_persist.setup(resurrect)

local is_linux = wezterm.target_triple:find('linux') ~= nil
local is_windows = wezterm.target_triple:find('windows') ~= nil

local mux = wezterm.mux

local function base_path_name(str)
    return string.gsub(str, '(.*[/\\])(.*)', '%2')
end

local function switch_workspace(window, pane)
    local choices = { { id = '__new__', label = '+ New workspace...' } }
    for _, name in ipairs(mux.get_workspace_names()) do
        table.insert(choices, { id = name, label = name })
    end
    window:perform_action(
        wezterm.action.InputSelector({
            title = 'Switch workspace',
            choices = choices,
            fuzzy = true,
            action = wezterm.action_callback(function(w, p, id, _)
                if not id then
                    return
                end
                if id == '__new__' then
                    w:perform_action(
                        wezterm.action.PromptInputLine({
                            description = 'New workspace name:',
                            action = wezterm.action_callback(function(w2, p2, line)
                                if line and line ~= '' then
                                    w2:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), p2)
                                end
                            end),
                        }),
                        p
                    )
                else
                    w:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), p)
                end
            end),
        }),
        pane
    )
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
    -- maximize all displayed windows on startup
    local workspace = mux.get_active_workspace()
    for _, window in ipairs(mux.all_windows()) do
        if window:get_workspace() == workspace then
            window:gui_window():maximize()
        end
    end
end)

local config = wezterm.config_builder()

-- commons
config.max_fps = 144

-- theme stuff
config.color_scheme = 'GruvboxDarkHard'

config.font = wezterm.font('JetBrainsMono Nerd Font')
-- config.font = wezterm.font('JetBrains Mono')
config.font_size = 11
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- sanity wezterm settings
config.warn_about_missing_glyphs = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'

-- default window size
config.initial_cols = 150
config.initial_rows = 40

if is_linux then
    -- hyprland :)
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

if is_windows then
    -- no tiling window manager :(
    config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
    config.window_padding = {
        left = '0cell',
        right = '0cell',
        top = '0.1cell',
        bottom = '0cell',
    }

    -- shell stuff
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

    -- Find installed visual studio version(s) and add their compilation
    -- environment command prompts to the menu
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
end -- ill add mac stuff if i ever become rich

-- key binding
-- config.disable_default_key_bindings = true
config.leader = { key = 't', mods = 'CTRL' }
config.keys = {

    -- split
    {
        key = '-',
        mods = 'LEADER',
        action = wezterm.action({ SplitVertical = { domain = 'CurrentPaneDomain' } }),
    },
    {
        key = '\\',
        mods = 'LEADER',
        action = wezterm.action({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }),
    },
    -- zoom focus pane
    { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },
    -- switch pane
    { key = 'h', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Left' }) },
    { key = 'j', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Down' }) },
    { key = 'k', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Up' }) },
    { key = 'l', mods = 'LEADER', action = wezterm.action({ ActivatePaneDirection = 'Right' }) },
    -- Open new tab
    { key = 'n', mods = 'LEADER', action = wezterm.action({ SpawnTab = 'CurrentPaneDomain' }) },
    -- close Tab
    { key = '&', mods = 'LEADER', action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
    -- close pane
    { key = 'x', mods = 'LEADER', action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
    -- Toggle full
    { key = 'n', mods = 'SHIFT|CTRL', action = 'ToggleFullScreen' },
    -- Workspace switcher
    { key = 'w', mods = 'LEADER', action = wezterm.action_callback(switch_workspace) },
    -- Workspace persist: save
    { key = 'S', mods = 'LEADER|SHIFT', action = workspace_persist.actions.save_current },
    -- Copy paste
    { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') },
    { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo('Clipboard') },
}

return config
