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

  -- One x64 dev prompt per Visual Studio with the C++ tools: any version or
  -- edition (Build Tools too), wherever it is installed. Ask vswhere rather
  -- than guess folders: VS 2026 moved them (2022 -> 18, Program Files (x86)
  -- -> Program Files). pcall: without Visual Studio there is no vswhere,
  -- and a failed spawn would break the whole config.
  local vswhere = 'C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe'
  local spawned, ok, stdout = pcall(wezterm.run_child_process, {
    vswhere, '-products', '*',
    '-requires', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    '-format', 'json', '-utf8',
  })
  if spawned and ok then
    for _, vs in ipairs(wezterm.serde.json_decode(stdout)) do
      table.insert(config.launch_menu, {
        label = 'x64 Native Tools: ' .. vs.displayName,
        args = { 'cmd.exe', '/k', vs.installationPath .. '\\VC\\Auxiliary\\Build\\vcvars64.bat' },
      })
    end
  end
end

return M
