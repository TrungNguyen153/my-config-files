# Wezterm pro-user overhaul — design

**Date:** 2026-05-15
**Scope:** Replace ~620 LoC of custom wezterm config with a plugin-orchestrator pattern (~300 LoC), adding pro-user features in three areas: visual layer, workspace management, and navigation keybindings.

## Goals

1. Adopt community plugins where they're more capable than current custom code.
2. Add visible pro-user features the current config lacks: powerline tab bar, leader-mode indicator, Windows acrylic backdrop, quick-select, copy mode, zen mode.
3. Modularize the config so each concern lives in one small file.
4. Preserve cross-platform support (Windows primary, Linux/hyprland-friendly secondary).

## Non-goals

- Mac support (user has noted this is out of scope).
- Backwards compatibility with saved workspace files from the old `workspace_persist.lua` — file paths and JSON shape are the same (resurrect writes them), so existing saved states will continue to work.
- Plugins beyond the four selected (tabline.wez, resurrect.wezterm, smart_workspace_switcher.wezterm). Sessionizer-style discovery is handled via a one-time zoxide seed instead of a second plugin.

## Module layout

```
.config/wezterm/
  wezterm.lua           # thin entry (~30 LoC)
  lua/
    appearance.lua      # theme, font, backdrop, padding, per-platform window chrome (~80 LoC)
    tabline.lua         # tabline.wez setup + leader-mode segment (~30 LoC)
    workspace.lua       # resurrect + smart_workspace_switcher wiring (~80 LoC)
    keys.lua            # all keybindings, zen-toggle helper (~80 LoC)
  stylua.toml           # unchanged
  workspace_persist.lua # DELETED
```

Each module exposes a single `apply(config, wezterm)` function that mutates `config`. Modules own their own event handlers (registered inside `apply`). No cross-module imports beyond the shared `wezterm` and `config`.

## Plugins

| Plugin | Purpose |
|---|---|
| `MLFlexer/resurrect.wezterm` | Workspace state save/restore. Already installed in current config. |
| `MLFlexer/smart_workspace_switcher.wezterm` | Zoxide-powered fuzzy workspace picker. New. |
| `michaelbrusegard/tabline.wez` | Lualine-style tab/status bar with process icons, mode indicator, theme presets. New. |

All loaded via `wezterm.plugin.require(<url>)` at the top of their owning module.

## Section 1 — `wezterm.lua` (entry)

Builds platform flags, calls each module's `apply`, returns config.

```lua
local wezterm = require('wezterm')
local config = wezterm.config_builder()

local platform = {
  is_windows = wezterm.target_triple:find('windows') ~= nil,
  is_linux   = wezterm.target_triple:find('linux')   ~= nil,
}

require('lua.appearance').apply(config, wezterm, platform)
require('lua.tabline').apply(config, wezterm)
require('lua.workspace').apply(config, wezterm)
require('lua.keys').apply(config, wezterm)

return config
```

## Section 2 — `lua/appearance.lua`

Sets visual + chrome config. Per-platform branching at the bottom.

Common settings (unchanged from current):
- `color_scheme = 'GruvboxDarkHard'`
- `font_size = 11`
- `harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }` (ligatures globally off)
- `max_fps = 144`
- `audible_bell = 'Disabled'`
- `window_close_confirmation = 'NeverPrompt'`
- `warn_about_missing_glyphs = false`
- `initial_cols = 150`, `initial_rows = 40`

New:
- `font = wezterm.font_with_fallback({ 'JetBrainsMono Nerd Font', 'Segoe UI Emoji', 'Noto Sans Mono CJK SC' })` — adds emoji + CJK fallback so Vietnamese diacritics and color emoji render correctly.
- `inactive_pane_hsb = { saturation = 0.85, brightness = 0.75 }` — dims non-focused panes.

Windows branch:
- `window_decorations = 'INTEGRATED_BUTTONS|RESIZE'`
- `win32_system_backdrop = 'Acrylic'`
- `window_background_opacity = 0.85`
- `window_padding = { left='0cell', right='0cell', top='0.1cell', bottom='0cell' }` (unchanged)
- `default_prog = { 'nu' }` (unchanged)
- `launch_menu` with WSL/PowerShell/CMD + auto-detected VS dev prompts (unchanged from current logic — preserved verbatim).

Linux branch:
- `window_decorations = 'NONE'`
- `enable_tab_bar = false` (no tabline on Linux — consistent with hyprland minimalism)
- `window_background_opacity = 0.8`
- `window_padding = { left='0.5cell', right='0.5cell', top='0.1cell', bottom='0.1cell' }` (unchanged)

`gui-attached` event handler (maximize all windows in active workspace on startup) moves here from the current `wezterm.lua`.

## Section 3 — `lua/tabline.lua`

Wires up `tabline.wez` with a minimal section layout (per user preference: leader indicator only on the right side is excessive — instead, leader indicator goes in section A on the left, where mode indicators conventionally live).

```lua
local M = {}
function M.apply(config, wezterm)
  local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')
  tabline.setup({
    options = {
      theme = 'GruvboxDarkHard',
      section_separators = '',
      component_separators = '',
    },
    sections = {
      tabline_a = { 'mode' },        -- leader indicator: tabline.wez's built-in 'mode' component reads wezterm's key-table/leader state
      tabline_b = { 'workspace' },   -- active workspace name with icon
      tabline_c = {},
      tab_active   = { 'index', { 'process', icons_only = false }, ' ', 'zoomed' },
      tab_inactive = { 'index', { 'process', icons_only = true } },
      tabline_x = {}, tabline_y = {}, tabline_z = {},
    },
  })
  tabline.apply_to_config(config)
end
return M
```

Replaces the current `update-right-status` handler (workspace name now lives in section B of tabline). `tabline.wez` ships a `GruvboxDarkHard` theme preset that auto-coordinates with the color scheme.

Tab bar only renders on Windows because Linux sets `enable_tab_bar = false` in `appearance.lua`.

**Fallback if the built-in `'mode'` component doesn't reflect leader state to satisfaction:** add a custom segment that reads `window:leader_is_active()` and emits `'LEADER'` or `'NORMAL'`, registered through tabline's component API. The implementation plan should verify the built-in behavior first and only fall back if needed — this avoids upfront custom code.

## Section 4 — `lua/workspace.lua`

Replaces `workspace_persist.lua`. Behavior model:

| Concern | Implementation |
|---|---|
| State directory | Custom Windows-aware logic preserved (~15 LoC). `%LOCALAPPDATA%\wezterm` on Windows, `$XDG_DATA_HOME/wezterm` on Linux. Passed to `resurrect.state_manager.change_state_save_dir(dir .. '/')`. |
| Auto-save | `resurrect.state_manager.periodic_save({ interval_seconds = 60, save_workspaces = true, save_windows = false, save_tabs = false })`. Replaces the custom debounced fingerprint detector. Trades change-driven precision for plugin-maintained simplicity. |
| Error surfacing | `resurrect.error` event handler that calls `wezterm.log_error` + a toast on every GUI window. Same approach as current config. |
| Switch to new workspace | `smart_workspace_switcher.workspace_switcher.chosen` event fires when the user picks an entry. Handler saves the current workspace before the switch settles. |
| Restore on enter | `smart_workspace_switcher.workspace_switcher.created` event fires after the new workspace materializes. Handler calls `resurrect.state_manager.load_state(label, 'workspace')`; if a saved state exists, restore into `window:mux_window()` with `close_open_tabs = true, close_open_panes = true`. |
| Delete saved state | Keybinding (in `keys.lua`) calls `resurrect.fuzzy_loader.fuzzy_load` to pick a state, then `resurrect.state_manager.delete_state(rel_path)`. |

### Module shape

```lua
local M = {}

local function state_dir(wezterm)
  -- ~15 LoC: Windows %LOCALAPPDATA%\wezterm or XDG/HOME on Linux. Preserved from current code.
end

function M.apply(config, wezterm)
  local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
  local workspace_switcher = wezterm.plugin.require('https://github.com/MLFlexer/smart_workspace_switcher.wezterm')

  local dir = state_dir(wezterm)
  resurrect.state_manager.change_state_save_dir(dir .. '/')

  resurrect.state_manager.periodic_save({
    interval_seconds = 60,
    save_workspaces = true, save_windows = false, save_tabs = false,
  })

  wezterm.on('resurrect.error', function(err)
    wezterm.log_error('resurrect: ' .. tostring(err))
    for _, gw in ipairs(wezterm.gui.gui_windows()) do
      gw:toast_notification('wezterm', 'resurrect: ' .. tostring(err), nil, 5000)
    end
  end)

  wezterm.on('smart_workspace_switcher.workspace_switcher.chosen', function(window, _path, _label)
    local current = window:active_workspace()
    if current and current ~= '' then
      resurrect.state_manager.save_state(
        resurrect.workspace_state.get_workspace_state(),
        current
      )
    end
  end)

  wezterm.on('smart_workspace_switcher.workspace_switcher.created', function(window, _path, label)
    local state = resurrect.state_manager.load_state(label, 'workspace')
    if not state then return end
    local ok, err = pcall(function()
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
      window:toast_notification('wezterm', 'Restore failed: ' .. tostring(err), nil, 5000)
    end
  end)
end

return M
```

### Tradeoffs accepted

- **Lost: fingerprint-based change-driven auto-save.** Current code only writes when workspace structure changes. New approach writes every 60s if there's been activity. For a single-user dev box this is acceptable.
- **Lost: unified live+saved picker with `★` active marker and `(active · saved)` status tags.** New picker shows zoxide-ranked directories. Different mental model: "where do I want to be" rather than "what workspaces exist".
- **Gained: zoxide ranking** (frequently used projects bubble up automatically), simpler maintenance, ~80 LoC vs ~480.

### Bootstrap (one-time, documented in commit message of the implementing commit)

Zoxide starts empty. After install, the user runs this once from PowerShell:

```powershell
Get-ChildItem D:\Workspace -Directory | ForEach-Object { zoxide add $_.FullName }
```

After this, `LEADER+w` shows all 15+ projects in `D:\Workspace`. Zoxide updates ranks from cd-activity going forward. The implementation plan must include the bootstrap command in the final commit message body so it's discoverable in `git log`.

## Section 5 — `lua/keys.lua`

Leader: `CTRL+t` (unchanged). `timeout_milliseconds = 1000` added explicitly so the tabline mode indicator has a clear deactivation window.

### Inherited (unchanged from current)

| Key | Action |
|---|---|
| `LEADER -` | split vertical |
| `LEADER \` | split horizontal |
| `LEADER h/j/k/l` | pane navigation |
| `LEADER z` | toggle pane zoom |
| `LEADER x` | close pane (confirm) |
| `LEADER n` | new tab |
| `LEADER &` | close tab (confirm) |
| `CTRL+SHIFT+n` | toggle fullscreen |
| `CTRL+V` / `CTRL+C` | clipboard paste/copy |

### Changed — workspace stack moved to plugins

| Key | Action |
|---|---|
| `LEADER w` | `workspace_switcher.switch_workspace()` — zoxide fuzzy picker |
| `LEADER SHIFT+w` | `workspace_switcher.switch_to_prev_workspace()` — jump back |
| `LEADER SHIFT+s` | save current workspace state (manual); toast on success |
| `LEADER SHIFT+d` | fuzzy-pick a saved workspace to delete |

### New — pro-user features

| Key | Action |
|---|---|
| `LEADER SPACE` | `QuickSelect` — highlight URLs/paths/git SHAs/IPs with letter labels |
| `LEADER [` | `ActivateCopyMode` — vim-style scrollback navigation + `/` search |
| `LEADER u` | `CharSelect` — fuzzy emoji/symbol picker |
| `LEADER SHIFT+z` | toggle zen mode (hide tab bar + zero padding on active window) |

### Zen toggle implementation

Per-window via `set_config_overrides` — zen on one window doesn't affect others:

```lua
local function toggle_zen(window)
  local o = window:get_config_overrides() or {}
  if o.enable_tab_bar == false then
    o.enable_tab_bar = nil
    o.window_padding = nil
  else
    o.enable_tab_bar = false
    o.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
  end
  window:set_config_overrides(o)
end
```

Bound via `wezterm.action_callback(function(win, _) toggle_zen(win) end)`.

### Save/delete actions

```lua
-- save current
local save_current = wezterm.action_callback(function(window, _pane)
  local name = window:active_workspace()
  if not name or name == '' then return end
  resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state(), name)
  window:toast_notification('wezterm', 'Saved: ' .. name, nil, 2000)
end)

-- fuzzy delete
local delete_saved = wezterm.action_callback(function(window, pane)
  resurrect.fuzzy_loader.fuzzy_load(window, pane, function(id, _label)
    -- id looks like '<state_dir>/workspace/<name>.json' (absolute on Windows)
    local rel = id:match('([^/\\]+[/\\][^/\\]+%.json)$')
    if not rel then return end
    resurrect.state_manager.delete_state(rel)
    window:toast_notification('wezterm', 'Deleted', nil, 1500)
  end, { is_fuzzy = true })
end)
```

### Module shape

`apply(config, wezterm)` requires both plugins (cached after first `require`), defines the helper closures above, then assigns `config.keys = { ... }` with the four groups in order (panes, tabs/window, clipboard, workspace, utility). ~80 LoC.

## Validation plan

After implementing each module:

1. **appearance.lua**: launch wezterm, verify Acrylic backdrop visible on Windows, font fallback works (paste Vietnamese text + emoji), inactive pane is visibly dimmed when split.
2. **tabline.lua**: split panes, switch tabs — verify process icons, hold `LEADER` and verify mode indicator changes color/text.
3. **workspace.lua**: seed zoxide, `LEADER+w` opens picker, picking a dir creates a workspace + restores any saved state. After the 60s interval elapses, verify a state JSON was written under `%LOCALAPPDATA%\wezterm\workspace\`. `LEADER+SHIFT+s` saves immediately and toasts. `LEADER+SHIFT+d` fuzzy-deletes.
4. **keys.lua**: `LEADER+SPACE` highlights links in scrollback. `LEADER+[` enters copy mode (cursor moves with hjkl, `/` searches). `LEADER+SHIFT+z` collapses chrome, again restores.

## Rollback

If something breaks, the change is single-commit. `git revert` restores the previous setup including `workspace_persist.lua`. Old saved state JSON files are untouched (resurrect uses the same path + format).

## Open items (deferred, not in this spec)

- Git branch / clock / battery in status bar — user opted for leader-mode only. Easy to add later as tabline.wez segments.
- Sessionizer-style git-repo discovery as a second plugin — covered by zoxide seed + ongoing usage tracking. Re-evaluate after a week of use.
- Hyperlink rules (Jira / GH issue auto-linking) — out of scope, can be added to `appearance.lua` later via `hyperlink_rules`.
- SSH multiplexer domains — out of scope.

## Implementation order

1. Create `lua/` subdirectory and stub the four modules with `M = {}; function M.apply(...) end; return M`. Update `wezterm.lua` to require them. Reload — should be functionally equivalent to deleting all config (defaults). Confirm wezterm still launches.
2. Move appearance settings from current `wezterm.lua` into `lua/appearance.lua`. Add font fallback, `inactive_pane_hsb`, Windows acrylic. Reload + verify.
3. Add tabline plugin in `lua/tabline.lua`. Remove the old `update-right-status` handler. Reload + verify mode indicator + process icons.
4. Migrate workspace logic to `lua/workspace.lua`. Delete `workspace_persist.lua`. Reload + verify `LEADER+w` opens picker, periodic_save writes files.
5. Add `lua/keys.lua` with all bindings including new pro-user actions. Reload + verify each new key works.
6. Commit.

Each step is independently testable; if step 4 breaks, steps 1-3 still leave a working terminal.
