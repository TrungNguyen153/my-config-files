local M = {}

function M.apply(config, wezterm, platform)
  if not platform.is_windows then
    return
  end

  config.default_prog = { 'nu' }

  config.launch_menu = {
    { label = 'PowerShell', args = { 'powershell', '-NoLogo' } },
    { label = 'Command Prompt', args = { 'cmd' } },
    { label = 'Nushell', args = { 'nu' } },
  }

  -- Auto-detect installed Visual Studio build tools and expose a dev prompt
  -- for each one.
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

return M
