local M = {}

-- Clickable workspace list in the tab bar: one chip per open workspace, click
-- one to switch to it.
--
-- WezTerm reports clicks on the new-tab button and on nothing else in the bar
-- (the status areas either side only drag the window), and that event says
-- which mouse button was used but not where. So:
--   1. The whole list is drawn as the new-tab button's label, replaced through
--      config overrides whenever the workspaces change.
--   2. On a click, helpers/cursor-pos.cs reports where the mouse is.
--   3. The button's first cell is worked out the way wezterm-gui's tabbar.rs
--      lays the bar out: left status, then the tabs, then the button. Both
--      widths are measured as tabline renders them.
-- When any of that is unavailable -- not Windows, the helper won't build,
-- tabline reorganised -- a click opens the workspace picker instead.

local MAX_CHIPS = 5
local MAX_NAME = 18

-- Catppuccin Frappe, as in tabline.lua.
local frappe = {
  mantle = '#292c3c',
  surface0 = '#414559',
  text = '#c6d0f5',
  subtext0 = '#a5adce',
  mauve = '#ca9ee6',
}

-- Event handlers share this Lua state, so these persist between events. Window
-- ids are mux window ids: they change when the workspace does.
local tab_cells = {} -- tab id -> cells its title takes
local left_cells = {} -- window id -> cells the left status takes
local layouts = {} -- window id -> what the button shows there

-- What the button shows: up to MAX_CHIPS workspaces and, past that, a '+N'
-- chip for the rest. The active workspace always gets a chip, taking the last
-- one when it sorts beyond the limit. Chips record the cells they cover,
-- counted from the start of the button.
function M.layout(wezterm, names, active)
  local active_index = 0
  for i, name in ipairs(names) do
    if name == active then
      active_index = i
    end
  end

  local shown, hidden = {}, {}
  for i, name in ipairs(names) do
    local fits = i < MAX_CHIPS or (i == MAX_CHIPS and active_index <= MAX_CHIPS)
    table.insert((fits or name == active) and shown or hidden, name)
  end

  local items = {}
  local chips = {}
  local cells = 0
  local function add(text, fg, bg, intensity, chip)
    table.insert(items, { Foreground = { Color = fg } })
    table.insert(items, { Background = { Color = bg } })
    table.insert(items, { Attribute = { Intensity = intensity } })
    table.insert(items, { Text = text })
    local width = wezterm.column_width(text)
    if chip then
      chip.from = cells
      chip.to = cells + width - 1
      table.insert(chips, chip)
    end
    cells = cells + width
  end

  add(' ' .. wezterm.nerdfonts.cod_multiple_windows .. ' ', frappe.mauve, frappe.mantle, 'Normal')
  for _, name in ipairs(shown) do
    local label = name
    if wezterm.column_width(label) > MAX_NAME then
      label = wezterm.truncate_right(label, MAX_NAME - 1) .. '…'
    end
    if name == active then
      add(' ' .. label .. ' ', frappe.mauve, frappe.surface0, 'Bold', { name = name })
    else
      add(' ' .. label .. ' ', frappe.subtext0, frappe.mantle, 'Normal', { name = name })
    end
  end
  if #hidden > 0 then
    add(' +' .. #hidden .. ' ', frappe.text, frappe.mantle, 'Normal', { hidden = hidden })
  end
  table.insert(items, { Attribute = { Intensity = 'Normal' } })

  return { label = wezterm.format(items), cells = cells, chips = chips }
end

-- The chip covering `offset`, a cell counted from the start of the button.
function M.chip_at(layout, offset)
  for _, chip in ipairs(layout.chips) do
    if offset >= chip.from and offset <= chip.to then
      return chip
    end
  end
  return nil
end

-- Drop the escapes wezterm.format emits (colours, and ESC ( B after a reset),
-- leaving the text that takes up cells.
local function strip_escapes(text)
  return (text:gsub('\27%[[^m]*m', ''):gsub('\27%(B', ''))
end

-- Record how wide tabline draws each tab and the left status. This reaches into
-- plugin modules, like patch_leader_mode in tabline.lua; tabline looks both
-- functions up on every call, so replacing them here is enough.
local function measure_tabline(wezterm)
  local ok_tabs, tabs = pcall(require, 'tabline.tabs')
  local ok_component, component = pcall(require, 'tabline.component')
  if not ok_tabs or not ok_component or not tabs.set_title or not component.set_status then
    return false
  end
  if tabs._measured then
    return true
  end

  local set_title = tabs.set_title
  tabs.set_title = function(tab, pane, hover)
    local items = set_title(tab, pane, hover)
    local width = 0
    for _, item in ipairs(items or {}) do
      if type(item) == 'table' and item.Text then
        width = width + wezterm.column_width(item.Text)
      end
    end
    tab_cells[tab.tab_id] = width
    return items
  end

  -- set_status hands the finished string straight to the window, so pass it a
  -- stand-in that measures the string on the way through.
  local set_status = component.set_status
  component.set_status = function(window, pane)
    local stand_in = setmetatable({}, {
      __index = function(_, method)
        if method == 'set_left_status' then
          return function(_, text)
            left_cells[window:window_id()] = wezterm.column_width(strip_escapes(text))
            return window:set_left_status(text)
          end
        end
        -- Anything that isn't a window method must stay nil: tabline tells a
        -- window from a tab by whether it has a tab_id.
        local found, value = pcall(function()
          return window[method]
        end)
        if not found or type(value) ~= 'function' then
          return nil
        end
        return function(_, ...)
          return value(window, ...)
        end
      end,
    })
    return set_status(stand_in, pane)
  end

  tabs._measured = true
  return true
end

-- Mouse x within the window, in pixels, or nil when it can't be found.
local function cursor_x(wezterm, platform)
  if not platform.is_windows then
    return nil
  end

  local exe = platform.state_dir .. '/cursor-pos.exe'
  local found, entries = pcall(wezterm.glob, exe)
  if not found or #entries == 0 then
    local windir = os.getenv('WINDIR') or 'C:\\Windows'
    pcall(wezterm.run_child_process, {
      windir .. '\\Microsoft.NET\\Framework64\\v4.0.30319\\csc.exe',
      '/nologo',
      '/optimize',
      '/out:' .. exe:gsub('/', '\\'),
      (wezterm.config_dir .. '\\helpers\\cursor-pos.cs'):gsub('/', '\\'),
    })
  end

  local ok, success, stdout = pcall(wezterm.run_child_process, { exe })
  if not ok or not success then
    return nil
  end
  return tonumber((stdout or ''):match('^(-?%d+)'))
end

-- Which cell of the button the mouse is over, 0 being its first.
local function clicked_cell(wezterm, platform, window, layout, tab_max_width)
  local x = cursor_x(wezterm, platform)
  if not x then
    return nil
  end

  local size = window:active_tab():get_size()
  local cell_width = size.pixel_width / size.cols
  local bar_cells = math.floor(window:get_dimensions().pixel_width / cell_width)

  local tabs = window:mux_window():tabs()
  local widths = {}
  local total = 0
  for i, tab in ipairs(tabs) do
    widths[i] = tab_cells[tab:tab_id()] or 0
    total = total + widths[i]
  end

  -- Tabs that don't fit are clamped to an equal share of the bar.
  local limit = tab_max_width
  local available = math.max(bar_cells - (#tabs - 1) - layout.cells, 0)
  if #tabs > 0 and available < total then
    limit = math.min(limit, available // #tabs)
  end

  local start = left_cells[window:window_id()] or 0
  for _, width in ipairs(widths) do
    start = start + math.min(width, limit)
  end
  return math.floor(x / cell_width) - start
end

function M.apply(config, wezterm, platform)
  if platform.is_linux then
    -- Linux runs without a tab bar (see appearance.lua).
    return
  end

  local sessions = require('lua.sessions')
  local actions = sessions.actions(wezterm, platform)
  local tab_max_width = config.tab_max_width or 16
  local measured = measure_tabline(wezterm)

  -- Placeholder until the first status update fills the list in. The hover
  -- style matches so the list doesn't light up as one block under the mouse.
  local placeholder = ' ' .. wezterm.nerdfonts.cod_multiple_windows .. ' '
  config.show_new_tab_button_in_tab_bar = true
  config.tab_bar_style = { new_tab = placeholder, new_tab_hover = placeholder }

  wezterm.on('update-status', function(window, _pane)
    -- 'default' is the workspace WezTerm starts in, not a project: no chip.
    local names = {}
    for _, name in ipairs(sessions.workspace_names(wezterm)) do
      if name ~= 'default' then
        table.insert(names, name)
      end
    end
    local layout = M.layout(wezterm, names, window:active_workspace())
    layouts[window:window_id()] = layout

    -- Overrides belong to the GUI window and outlive a workspace switch, so
    -- compare against what is set rather than against a cache of our own.
    local overrides = window:get_config_overrides() or {}
    if not overrides.tab_bar_style or overrides.tab_bar_style.new_tab ~= layout.label then
      overrides.tab_bar_style = { new_tab = layout.label, new_tab_hover = layout.label }
      window:set_config_overrides(overrides)
    end
  end)

  wezterm.on('new-tab-button-click', function(window, pane, button, _default_action)
    if button == 'Right' then
      window:perform_action(actions.back, pane)
    elseif button == 'Left' then
      local layout = layouts[window:window_id()]
      local cell = measured and layout and clicked_cell(wezterm, platform, window, layout, tab_max_width)
      local chip = cell and M.chip_at(layout, cell)
      wezterm.log_info('workspace bar: click on cell', cell, 'chip', chip and (chip.name or '+N'))
      if chip and chip.name then
        sessions.switch(wezterm, window, pane, chip.name)
      else
        -- '+N' lists the workspaces without a chip; a miss lists them all.
        sessions.pick(wezterm, window, pane, chip and chip.hidden)
      end
    end
    -- Never fall through to the default of spawning a tab.
    return false
  end)
end

return M
