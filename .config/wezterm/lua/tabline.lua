local M = {}

-- Catppuccin Frappe, matching color_scheme in appearance.lua.
local frappe = {
  crust = '#232634',
  mantle = '#292c3c',
  surface0 = '#414559',
  surface1 = '#51576d',
  text = '#c6d0f5',
  subtext0 = '#a5adce',
  peach = '#ef9f76',
  red = '#e78284',
  yellow = '#e5c890',
  green = '#a6d189',
}

-- Colours for a mode block. tabline looks up theme_overrides[<key table name>]
-- for every key table named *_mode, and update-status errors if it is missing.
local function mode_colors(accent)
  return {
    a = { fg = frappe.crust, bg = accent },
    b = { fg = accent, bg = frappe.surface0 },
    c = { fg = frappe.text, bg = frappe.mantle },
  }
end

-- Programs that are just the shell: their tabs are labelled by folder alone.
local SHELLS = {
  nu = true,
  pwsh = true,
  powershell = true,
  cmd = true,
  bash = true,
  sh = true,
  zsh = true,
  fish = true,
  wslhost = true,
}

-- '/C:/Users/OS/' or 'C:\Users\OS\' -> 'C:/Users/OS'
local function norm(path)
  return (path:gsub('\\', '/'):gsub('^/(%a:)', '%1'):gsub('(.)/+$', '%1'))
end

-- tabline colours the mode block from the active key table only, so an armed
-- leader looked like NORMAL. Report it as a mode of its own (the workaround
-- from tabline issue #102). This reaches into a plugin module: if the plugin
-- reorganises, the require fails and the leader simply keeps NORMAL's colour.
local function patch_leader_mode()
  local ok, mode = pcall(require, 'tabline.components.window.mode')
  if not ok or mode._leader_patched then
    return
  end
  local get = mode.get
  mode.get = function(window)
    local current = get(window)
    if current == 'normal_mode' and window:leader_is_active() then
      return 'leader_mode'
    end
    return current
  end
  mode._leader_patched = true
end

local function has_unseen_output(tab)
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then
      return true
    end
  end
  return false
end

function M.apply(config, wezterm, platform)
  if platform.is_linux then
    -- Linux runs without a tab bar (see appearance.lua).
    return
  end

  local nf = wezterm.nerdfonts
  local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')
  patch_leader_mode()

  local home = norm(wezterm.home_dir):lower()

  local function fit(text, max_width)
    if wezterm.column_width(text) <= max_width then
      return text
    end
    return wezterm.truncate_right(text, max_width - 1) .. '…'
  end

  -- Tab label: a name set with LEADER+, wins; otherwise the pane's folder ('~'
  -- at home), prefixed with the program when it isn't the shell ('nvim · Zeus').
  -- Windows can't see a WSL pane's cwd, so those fall back to the pane title.
  -- tabline doesn't pad function components, hence the trailing space.
  local function tab_label(max_width)
    return function(tab)
      if (tab.tab_title or '') ~= '' then
        return fit(tab.tab_title, max_width) .. ' '
      end
      local pane = tab.active_pane
      local label
      local cwd = pane.current_working_dir
      local path = cwd and (type(cwd) == 'string' and cwd:gsub('^file://[^/]*', '') or cwd.file_path)
      if path and path ~= '' then
        path = norm(path)
        label = path:lower() == home and '~' or (path:match('([^/]+)$') or path)
      end
      label = label or pane.title or ''
      local program = ((pane.foreground_process_name or ''):match('([^/\\]+)$') or ''):gsub('%.[Ee][Xx][Ee]$', '')
      if program ~= '' and not SHELLS[program:lower()] then
        label = program .. ' · ' .. label
      end
      return fit(label, max_width) .. ' '
    end
  end

  -- Icon only; the label names the program. Merged into tabline's own map.
  local process_icon = {
    'process',
    icons_only = true,
    padding = { left = 1, right = 0 },
    process_to_icon = {
      ['nu.exe'] = { nf.cod_terminal, color = { fg = frappe.green } },
      ['claude.exe'] = { nf.md_robot, color = { fg = frappe.peach } },
    },
  }

  tabline.setup({
    options = {
      theme = 'Catppuccin Frappe',
      section_separators = { left = nf.pl_left_hard_divider, right = nf.pl_right_hard_divider },
      component_separators = { left = nf.pl_left_soft_divider, right = nf.pl_right_soft_divider },
      tab_separators = { left = nf.pl_left_hard_divider, right = nf.pl_right_hard_divider },
      theme_overrides = {
        -- copy_mode and search_mode keep tabline's yellow and green.
        leader_mode = mode_colors(frappe.peach),
        resize_mode = mode_colors(frappe.red),
        tab = {
          active = { fg = frappe.text, bg = frappe.surface1 },
          -- The tab arrows are drawn on this colour, so it stays the bar colour.
          inactive = { fg = frappe.subtext0, bg = frappe.mantle },
          inactive_hover = { fg = frappe.text, bg = frappe.surface0 },
        },
      },
    },
    sections = {
      tabline_a = { 'mode' },
      tabline_b = { 'workspace' },
      tabline_c = { ' ' },
      -- Explicit padding keeps an active tab within tab_max_width; WezTerm
      -- clips anything wider, closing arrow first.
      tab_active = {
        { 'index', padding = { left = 1, right = 0 } },
        process_icon,
        tab_label(20),
        { 'zoomed', padding = 0 },
      },
      tab_inactive = {
        { 'index', padding = { left = 1, right = 0 } },
        process_icon,
        tab_label(16),
        -- A bell on tabs that printed something since you last looked.
        {
          'output',
          padding = 0,
          cond = has_unseen_output,
          icon = { nf.md_bell_badge_outline, color = { fg = frappe.yellow } },
        },
      },
      -- No cpu/ram: on Windows they spawn wmic every 3 s. No battery: this
      -- laptop's battery reads 2% on AC.
      tabline_x = {},
      tabline_y = { { 'datetime', style = '%a %d %b', icon = nf.md_calendar, hour_to_icon = false } },
      tabline_z = { { 'datetime', style = '%H:%M' } },
    },
  })

  -- What tabline.apply_to_config sets, minus the parts that fought the rest of
  -- this config: it forced window_decorations = 'RESIZE', zeroed the padding
  -- and polled the status every 500 ms.
  config.use_fancy_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 32
  -- Leader and key-table changes already refresh the bar immediately; this
  -- only paces the clock.
  config.status_update_interval = 1000
  config.colors = config.colors or {}
  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.background = tabline.get_theme().normal_mode.c.bg
end

return M
