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
