local M = {}

-- Custom segment: shows LEADER while the leader prefix is armed.
-- wezterm's leader is not a key table, so tabline.wez's built-in 'mode'
-- component would always read 'normal'. Ask the window directly instead.
local function leader_status(window)
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
      tabline_z = { 'datetime' },
    },
  })

  tabline.apply_to_config(config)
end

return M
