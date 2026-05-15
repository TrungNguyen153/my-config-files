# Wezterm Pro-User Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace ~620 LoC of custom wezterm config with a modular plugin-orchestrator (~300 LoC across 4 modules), adding pro-user features: powerline tab bar, leader-mode indicator, Windows Acrylic backdrop, zoxide-powered workspace switcher, quick-select, copy mode, char select, zen mode.

**Architecture:** `wezterm.lua` becomes a thin entry that delegates to four single-purpose modules under `.config/wezterm/lua/`. Each module exposes `apply(config, wezterm[, platform])` and mutates `config` in place. Community plugins (tabline.wez, smart_workspace_switcher.wezterm, resurrect.wezterm) replace hand-rolled UI and persistence logic.

**Tech Stack:** wezterm 20240203+ (Lua 5.4 config), zoxide (workspace ranking), Nerd Font (icons), Windows 11 (Acrylic backdrop), PowerShell (bootstrap).

**Spec:** [docs/superpowers/specs/2026-05-15-wezterm-pro-overhaul-design.md](../specs/2026-05-15-wezterm-pro-overhaul-design.md)

---

## File Structure

**Created:**
- `.config/wezterm/lua/appearance.lua` — theme, font, backdrop, padding, per-platform window chrome (~80 LoC)
- `.config/wezterm/lua/tabline.lua` — tabline.wez setup + custom leader-mode segment (~40 LoC)
- `.config/wezterm/lua/workspace.lua` — resurrect + smart_workspace_switcher wiring + state-dir logic (~80 LoC)
- `.config/wezterm/lua/keys.lua` — keybindings, zen-toggle helper, save/delete actions (~100 LoC)

**Modified:**
- `.config/wezterm/wezterm.lua` — reduced to ~30 LoC orchestrator

**Deleted:**
- `.config/wezterm/workspace_persist.lua`

---

## Verification Pattern (read before starting)

wezterm auto-reloads `wezterm.lua` and required modules on file save (default `automatically_reload_config = true`). Each task's verification step assumes wezterm is open. If a change doesn't apply within ~2 seconds, manually reload via `CTRL+SHIFT+R`. For changes to `window_decorations`, `default_prog`, or font/backdrop options, close and reopen the wezterm window.

There is no test framework for wezterm configs. "Verification" = save file, observe behavior, confirm matches expected. If a reload fails, wezterm shows a red error overlay in the bottom-right — read it before continuing.

Keep a wezterm window open throughout implementation.

---

## Task 0: Install zoxide

**Files:** none

**Purpose:** Prerequisite for `smart_workspace_switcher.wezterm` (Task 4). Doing this first ensures Task 4's verification works without surprises.

- [ ] **Step 1: Install via scoop**

Run in PowerShell:
```powershell
scoop install zoxide
```

- [ ] **Step 2: Verify zoxide is on PATH**

Run:
```powershell
zoxide --version
```

Expected: prints a version string like `zoxide 0.9.x`. If "command not found", restart PowerShell to pick up the updated PATH.

- [ ] **Step 3: No commit**

This is environment setup, not a code change. No commit.

---

## Task 1: Scaffold module structure

**Files:**
- Create: `.config/wezterm/lua/appearance.lua`
- Create: `.config/wezterm/lua/tabline.lua`
- Create: `.config/wezterm/lua/workspace.lua`
- Create: `.config/wezterm/lua/keys.lua`
- Modify: `.config/wezterm/wezterm.lua` (entire file replaced — but only with stub orchestration; old behavior preserved by inlining for now)

**Purpose:** Establish the module layout. After this task, wezterm should launch identically to before — modules are empty stubs that don't override anything yet.

- [ ] **Step 1: Create `lua/` directory and four stub modules**

Create `.config/wezterm/lua/appearance.lua`:
```lua
local M = {}

function M.apply(config, wezterm, platform)
  -- TODO Task 2: move appearance settings here
end

return M
```

Create `.config/wezterm/lua/tabline.lua`:
```lua
local M = {}

function M.apply(config, wezterm)
  -- TODO Task 3: tabline.wez setup here
end

return M
```

Create `.config/wezterm/lua/workspace.lua`:
```lua
local M = {}

function M.apply(config, wezterm)
  -- TODO Task 4: resurrect + smart_workspace_switcher wiring here
end

return M
```

Create `.config/wezterm/lua/keys.lua`:
```lua
local M = {}

function M.apply(config, wezterm)
  -- TODO Task 5: keybindings here
end

return M
```

These `-- TODO Task N` comments are intentional plan markers; they get replaced with real code by the named task and must not survive past that task's commit.

- [ ] **Step 2: Replace `wezterm.lua` with orchestrator that still inlines old behavior**

This is the trickiest step. We want the new entry shape, but we don't want to lose any current behavior until the relevant module takes over. So we keep ALL current logic inline AND call the (empty) modules. Each subsequent task will move logic out of inline and into a module.

Replace the entire contents of `.config/wezterm/wezterm.lua` with:

```lua
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
```

The `require('lua.appearance')` form uses Lua's dot-as-separator path syntax. wezterm sets up the package path so this works for files under the wezterm config dir.

- [ ] **Step 3: Verify wezterm still launches and looks identical**

Save the file. Watch the running wezterm window: it should reload cleanly with NO red error overlay. Visually compare to before: same colors, same font, same tab bar, same status (workspace name on right). All keybindings still work (try `LEADER -` to split).

If you see a red error overlay, read the line number in the error, fix the syntax issue, save again.

Expected: identical behavior to before this commit.

- [ ] **Step 4: Commit**

```powershell
git add .config/wezterm/wezterm.lua .config/wezterm/lua/
git commit -m @'
refactor(wezterm): scaffold lua/ module structure

Introduces lua/{appearance,tabline,workspace,keys}.lua as empty stubs
and rewires wezterm.lua to call them. All existing behavior preserved
inline; subsequent commits will migrate inline logic into the modules.
'@
```

---

## Task 2: Migrate appearance into `appearance.lua`

**Files:**
- Modify: `.config/wezterm/lua/appearance.lua` (fill in the stub)
- Modify: `.config/wezterm/wezterm.lua` (remove the migrated inline sections)

**Purpose:** Move all theme/font/padding/window-chrome settings into the appearance module. Add the new features: font fallback, inactive-pane dim, Windows Acrylic.

- [ ] **Step 1: Fill in `lua/appearance.lua`**

Replace the contents of `.config/wezterm/lua/appearance.lua` with:

```lua
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
```

- [ ] **Step 2: Remove the migrated lines from `wezterm.lua`**

Open `.config/wezterm/wezterm.lua`. Delete every line that the appearance module now owns. Specifically remove:
- The `local mux = wezterm.mux` line
- The entire `gui-attached` event handler
- The `commons`, `theme stuff`, `sanity wezterm settings`, `default window size` sections
- The entire `if platform.is_linux then ... end` block
- The entire `if platform.is_windows then ... end` block

Leave intact:
- The `require('wezterm')`, `resurrect`, `workspace_persist`, `platform` table at top
- The `base_path_name` + `update_right_status` + `update-right-status` handler (tabline task removes these)
- `config = wezterm.config_builder()`
- The four `require('lua.X').apply(...)` calls
- The `config.leader` + `config.keys = { ... }` block
- `return config`

After deletion, the file should be around 50 LoC.

- [ ] **Step 3: Verify**

Save. Wezterm auto-reloads. Confirm:
- Colors still Gruvbox dark hard
- Font still JetBrains Mono
- On Windows: the window now has a frosted Acrylic backdrop visible (you can see your desktop through it slightly)
- Open a pane split (`LEADER -`): non-focused pane is visibly dimmer
- Paste Vietnamese text with diacritics (e.g. `Tiếng Việt`) into a shell prompt: glyphs render without missing-character boxes
- Paste an emoji (e.g. `🎉`): renders correctly

If Acrylic doesn't appear: close + reopen the wezterm window (backdrop changes don't always live-reload).

- [ ] **Step 4: Commit**

```powershell
git add .config/wezterm/wezterm.lua .config/wezterm/lua/appearance.lua
git commit -m @'
feat(wezterm): migrate appearance into lua/appearance.lua

Moves theme/font/window-chrome/launch-menu config into the appearance
module. Adds font fallback for emoji + CJK glyphs, inactive_pane_hsb
dimming, and Windows 11 Acrylic backdrop.
'@
```

---

## Task 3: Add tabline.wez with leader-mode indicator

**Files:**
- Modify: `.config/wezterm/lua/tabline.lua` (fill in the stub)
- Modify: `.config/wezterm/wezterm.lua` (remove the old `update-right-status` handler + `base_path_name` helper)

**Purpose:** Replace the homemade right-status with a real tab bar that has process icons in tab titles, workspace name segment, and a leader-mode indicator (`LEADER` vs `NORMAL`).

- [ ] **Step 1: Fill in `lua/tabline.lua`**

Replace the contents of `.config/wezterm/lua/tabline.lua` with:

```lua
local M = {}

-- Custom segment: shows LEADER when the leader key prefix is active.
-- Wezterm's leader is not a keytable, so tabline.wez's built-in 'mode'
-- component would always read 'normal'. We reach in and check leader state
-- directly via the Window method.
local function leader_status(window)
  if window:leader_is_active() then
    return ' LEADER '
  end
  return ' NORMAL '
end

function M.apply(config, wezterm)
  local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

  tabline.setup({
    options = {
      theme = 'GruvboxDarkHard',
      section_separators = '',
      component_separators = '',
    },
    sections = {
      tabline_a = { leader_status },
      tabline_b = { 'workspace' },
      tabline_c = {},
      tab_active = {
        'index',
        { 'process', icons_only = false },
        ' ',
        'zoomed',
      },
      tab_inactive = {
        'index',
        { 'process', icons_only = true },
      },
      tabline_x = {},
      tabline_y = {},
      tabline_z = {},
    },
  })

  tabline.apply_to_config(config)
end

return M
```

- [ ] **Step 2: Remove old status-bar code from `wezterm.lua`**

In `.config/wezterm/wezterm.lua`, delete:
- The `base_path_name` function
- The `update_right_status` function
- The entire `wezterm.on('update-right-status', ...)` handler

Tabline owns workspace-name display from this commit on.

- [ ] **Step 3: Verify tabline appears**

Save. Wezterm should auto-reload. If the tabline plugin isn't downloaded yet, you may see a brief "downloading plugin" message — wait ~10s. After reload:

- Tab bar at top shows: `[ NORMAL ]` (or whatever color theme renders) `[ workspace-name ]` `[ tab list ]`
- Open a few tabs running different programs (e.g. one with `nvim`, one with `nu`, one with `git status`): each tab title shows a process-specific icon
- Press and hold `CTRL+T` (the leader key) — left segment should flip to `LEADER`. Release: returns to `NORMAL` after ~1s
- If `LEADER` indicator doesn't appear: the leader has a default ~1s timeout. Press `CTRL+T` then immediately glance at the tab bar — the change is brief

If you see no tab bar at all on Windows: check `appearance.lua` doesn't set `enable_tab_bar = false` for the Windows branch. On Linux it should remain hidden.

If the theme name `GruvboxDarkHard` isn't a recognized tabline preset, the tabline will fall back to a default theme. To list available presets, search the tabline.wez repo's `themes/` directory or set `theme = 'Catppuccin Mocha'` as a known-good fallback to confirm wiring before debugging theme names.

- [ ] **Step 4: Commit**

```powershell
git add .config/wezterm/wezterm.lua .config/wezterm/lua/tabline.lua
git commit -m @'
feat(wezterm): add tabline.wez with leader-mode indicator

Replaces the hand-rolled update-right-status handler with tabline.wez.
Adds a custom leader-mode segment that reads window:leader_is_active()
(wezterm leader is not a keytable, so tabline's built-in mode component
will not capture it). Tab titles now show process icons.
'@
```

---

## Task 4: Replace workspace_persist with plugin stack

**Files:**
- Modify: `.config/wezterm/lua/workspace.lua` (fill in the stub)
- Modify: `.config/wezterm/wezterm.lua` (remove resurrect require + workspace_persist require + the LEADER+w keybinding)
- Delete: `.config/wezterm/workspace_persist.lua`

**Purpose:** Replace ~480 LoC of custom persistence with resurrect (already used) + smart_workspace_switcher.wezterm. State save/restore becomes plugin-driven.

- [ ] **Step 1: Fill in `lua/workspace.lua`**

Replace the contents of `.config/wezterm/lua/workspace.lua` with:

```lua
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
```

- [ ] **Step 2: Update `wezterm.lua`: remove resurrect import + workspace_persist + the LEADER+w keybinding**

Open `.config/wezterm/wezterm.lua`. Delete:
- `local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')` (workspace module now owns this)
- `local workspace_persist = require('workspace_persist')`
- `workspace_persist.setup(resurrect)`
- The `{ key = 'w', mods = 'LEADER', action = workspace_persist.actions.manager }` line from `config.keys` (Task 5 will replace it; for now, leave a gap)

After this, `wezterm.lua` should be ~35 LoC: just `require('wezterm')`, the platform table, `config = wezterm.config_builder()`, the four module `apply` calls, the leader+keys table (with LEADER+w removed), and `return config`.

- [ ] **Step 3: Delete `workspace_persist.lua`**

```powershell
git rm .config/wezterm/workspace_persist.lua
```

- [ ] **Step 4: Verify**

Save. Wezterm reloads. The smart_workspace_switcher plugin may need to download on first load (~10s).

Expected immediately:
- No red error overlay
- Tab bar still shows current workspace name in section B
- `LEADER+w` does nothing yet (we removed the binding; Task 5 re-adds it)

Verify state persistence works:
- Note the current workspace name (e.g. `default`)
- Open `%LOCALAPPDATA%\wezterm\workspace\` in Explorer (or `Get-ChildItem $env:LOCALAPPDATA\wezterm\workspace`)
- Wait 60 seconds
- Confirm a JSON file matching your workspace name now exists (or has a recent modified time)

If the file isn't appearing: check the wezterm debug log via `CTRL+SHIFT+L` for any `resurrect:` toast messages, and verify the state_dir path matches what `state_dir()` would compute on your machine.

- [ ] **Step 5: Commit**

```powershell
git add .config/wezterm/wezterm.lua .config/wezterm/lua/workspace.lua .config/wezterm/workspace_persist.lua
git commit -m @'
feat(wezterm): replace workspace_persist with smart_workspace_switcher

Drops the 480-LoC custom workspace manager in favour of:
  - MLFlexer/resurrect.wezterm with periodic_save for auto-save
  - MLFlexer/smart_workspace_switcher.wezterm for the zoxide-powered picker

The state directory and Windows-aware path logic are preserved (~30 LoC
moved into workspace.lua). Existing saved JSON state files remain
readable - resurrect uses the same path layout and schema.

LEADER+w temporarily unbound; restored in the keys.lua migration.
'@
```

---

## Task 5: Migrate keys into `keys.lua` with new pro-user bindings

**Files:**
- Modify: `.config/wezterm/lua/keys.lua` (fill in the stub)
- Modify: `.config/wezterm/wezterm.lua` (remove the inline `config.leader` + `config.keys` block)

**Purpose:** Move all keybindings to the keys module and add the new actions: workspace switcher (LEADER+w back), manual save (LEADER+S), fuzzy delete (LEADER+D), QuickSelect, ActivateCopyMode, CharSelect, zen-mode toggle.

- [ ] **Step 1: Fill in `lua/keys.lua`**

Replace the contents of `.config/wezterm/lua/keys.lua` with:

```lua
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
```

- [ ] **Step 2: Remove inline keys from `wezterm.lua`**

In `.config/wezterm/wezterm.lua`, delete:
- The `config.leader = { ... }` line
- The entire `config.keys = { ... }` table

After this, `wezterm.lua` should be ~20 LoC. It looks like:

```lua
local wezterm = require('wezterm')

local platform = {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
  is_linux   = wezterm.target_triple:find('linux')   ~= nil,
}

local config = wezterm.config_builder()

require('lua.appearance').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm)
require('lua.workspace').apply(config, wezterm)
require('lua.keys').apply(config, wezterm)

return config
```

- [ ] **Step 3: Verify each keybinding**

Save. Wezterm reloads. Run through every new binding:

| Key | Expected behavior |
|---|---|
| `LEADER -` / `LEADER \` | splits pane (vertical/horizontal) |
| `LEADER h/j/k/l` | focus moves between panes |
| `LEADER z` | active pane toggles zoom |
| `LEADER x` | close-pane confirm prompt |
| `LEADER n` | new tab |
| `LEADER &` | close-tab confirm prompt |
| `LEADER w` | smart_workspace_switcher fuzzy picker opens (may be empty if zoxide is unseeded — Task 6 fixes that) |
| `LEADER SHIFT+w` | toggles back to previous workspace (no-op if there's only one) |
| `LEADER SHIFT+s` | toast: `Saved: <workspace>` |
| `LEADER SHIFT+d` | fuzzy picker over saved states, picking one deletes it |
| `LEADER SPACE` | screen overlays letter labels on URLs/paths/hashes — type a label to copy |
| `LEADER [` | enters copy mode (cursor highlights, `hjkl` moves it, `/` opens scrollback search) |
| `LEADER u` | fuzzy emoji/symbol picker |
| `LEADER SHIFT+z` | tab bar disappears + padding collapses to 0. Press again: restores |
| `CTRL+SHIFT+n` | toggles fullscreen |
| `CTRL+C` / `CTRL+V` | clipboard copy/paste |

If `LEADER+w` shows an empty picker, that's expected at this stage — Task 6 seeds zoxide. The keybinding itself is wired correctly as long as the picker UI appears.

- [ ] **Step 4: Commit**

```powershell
git add .config/wezterm/wezterm.lua .config/wezterm/lua/keys.lua
git commit -m @'
feat(wezterm): migrate keys + add pro-user bindings

All keybindings move into keys.lua. New bindings added:
  - LEADER+w  / LEADER+W : workspace_switcher.switch / switch_to_prev
  - LEADER+S            : manual save current workspace state
  - LEADER+D            : fuzzy-delete a saved workspace state
  - LEADER+SPACE        : QuickSelect (URLs/paths/SHAs/IPs)
  - LEADER+[            : ActivateCopyMode (vim-style scrollback)
  - LEADER+u            : CharSelect (emoji/symbol picker)
  - LEADER+SHIFT+z      : toggle per-window zen mode

wezterm.lua is now a 20-LoC orchestrator that hands off to four
single-purpose modules under lua/.
'@
```

---

## Task 6: Seed zoxide with project directories

**Files:** none

**Purpose:** Smart_workspace_switcher displays directories ranked by zoxide. A fresh zoxide install knows about nothing, so the picker is empty. Seeding from `D:\Workspace` gives an immediately-useful picker on first invocation. After this, day-to-day cd activity keeps zoxide ranks current.

- [ ] **Step 1: Seed zoxide from project root**

Run in PowerShell:
```powershell
Get-ChildItem D:\Workspace -Directory | ForEach-Object { zoxide add $_.FullName }
```

Expected: no output (zoxide is silent on success). If zoxide errors, verify Task 0 (`zoxide --version` succeeds).

- [ ] **Step 2: Verify zoxide knows about the projects**

Run:
```powershell
zoxide query --list
```

Expected: prints ~15 lines, one per directory under `D:\Workspace`, each an absolute Windows path.

- [ ] **Step 3: Verify the workspace picker is now useful**

In wezterm, press `LEADER+w`. The picker overlay opens with a fuzzy-searchable list of those directories. Type the first letters of a project name (e.g. `nav` for `Navigation.XCore`); the list narrows. Press Enter: a new workspace is created with that name, cwd set to that directory. The tabline workspace segment updates.

Press `LEADER+w` again, pick a different project: workspace switches, the previous workspace's state is saved to `%LOCALAPPDATA%\wezterm\workspace\<previous-name>.json`.

Press `LEADER+SHIFT+w` to flip back to the previous workspace.

- [ ] **Step 4: Final commit (optional)**

If you want a "completion" marker commit (no code change, but documents the bootstrap):

```powershell
git commit --allow-empty -m @'
chore(wezterm): bootstrap zoxide for workspace switcher

One-time seed of zoxide with project directories from D:\Workspace:
    Get-ChildItem D:\Workspace -Directory | ForEach-Object { zoxide add $_.FullName }

Run this once after a fresh zoxide install. From then on, zoxide
auto-tracks usage via shell hooks and LEADER+w surfaces the most
frequent projects first.
'@
```

This empty commit is optional but useful for `git log` discoverability of the bootstrap step (see spec).

---

## Final sanity sweep

After all six tasks complete, do one end-to-end pass:

- [ ] **Open a fresh wezterm window.** Verify Acrylic backdrop, font fallback (paste Vietnamese), tabline with `NORMAL` segment + workspace name.
- [ ] **Hold `CTRL+T`.** `NORMAL` flips to `LEADER`, releases back after timeout.
- [ ] **`LEADER+w` → pick a project.** New workspace, cwd correct, state restored if any.
- [ ] **Split panes (`LEADER -`).** Inactive pane visibly dimmed.
- [ ] **`LEADER+SPACE`.** Screen overlays letter labels on visible URLs/paths.
- [ ] **`LEADER+[`.** Enter copy mode; `/`-search through scrollback works.
- [ ] **`LEADER+SHIFT+z`.** Tab bar disappears; padding collapses. Press again: restores.
- [ ] **Close and reopen the wezterm window.** The active workspace's state restores from disk.
- [ ] **`git log --oneline`.** Should show ~5-6 atomic commits, each a logical step.
- [ ] **`Get-ChildItem .config/wezterm -Recurse`.** Confirm `workspace_persist.lua` is gone and `lua/{appearance,tabline,workspace,keys}.lua` all exist.

---

## Rollback

If anything breaks at any point: every task ends in a commit, so `git revert <hash>` cleanly undoes a single task. To roll back the whole effort: `git revert <first-task-hash>..<last-task-hash>`.

Saved state JSON files in `%LOCALAPPDATA%\wezterm\workspace\` are untouched by these changes — resurrect uses the same path and format your previous `workspace_persist.lua` used.
