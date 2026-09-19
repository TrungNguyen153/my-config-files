local M = {}

-- Custom segment: which input mode is active.
--
-- tabline.wez's built-in 'mode' component reads key tables only, so it would
-- print 'normal' the whole time the leader is armed. Asking the window covers
-- both: an active key table (resize mode) wins, then the leader prefix, then
-- plain normal.
local function mode_status(window)
  local key_table = window:active_key_table()
  if key_table then
    return ' ' .. (key_table:upper():gsub('_', ' ')) .. ' '
  end
  if window:leader_is_active() then
    return ' LEADER '
  end
  return ' NORMAL '
end

function M.apply(config, wezterm, platform)
  if platform.is_linux then
    -- Linux runs without a tab bar (see appearance.lua).
    return
  end

  local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

  tabline.setup({
    options = {
      theme = 'Catppuccin Frappe',
      section_separators = '',
      component_separators = '',
    },
    sections = {
      tabline_a = { mode_status },
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
      tabline_z = { 'datetime' },
    },
  })

  tabline.apply_to_config(config)
end

return M
