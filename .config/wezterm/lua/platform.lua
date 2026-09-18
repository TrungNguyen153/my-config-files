local wezterm = require('wezterm')

local M = {}

-- Normalize Windows backslashes to forward slashes. wezterm.glob and io.open
-- both accept forward slashes on Windows, and resurrect's path math is
-- forward-slash friendly.
function M.norm(path)
  return (path:gsub('\\', '/'))
end

M.is_windows = wezterm.target_triple:find('windows') ~= nil
M.is_linux = wezterm.target_triple:find('linux') ~= nil

-- Where saved workspace state lives.
-- Windows: %LOCALAPPDATA%\wezterm   Linux: $XDG_DATA_HOME/wezterm or ~/.local/share/wezterm
local function resolve_state_dir()
  if M.is_windows then
    local base = os.getenv('LOCALAPPDATA')
    if not base or base == '' then
      base = (os.getenv('USERPROFILE') or 'C:/Users/Default') .. '/AppData/Local'
    end
    return M.norm(base) .. '/wezterm'
  end

  local xdg = os.getenv('XDG_DATA_HOME')
  if xdg and xdg ~= '' then
    return M.norm(xdg) .. '/wezterm'
  end
  return M.norm(os.getenv('HOME') or '~') .. '/.local/share/wezterm'
end

M.state_dir = resolve_state_dir()

-- Root that the project picker scans for git repos.
M.projects_dir = M.is_windows and (M.norm(os.getenv('USERPROFILE') or 'C:/Users/OS') .. '/Desktop/Workspace')
  or ((os.getenv('HOME') or '~') .. '/workspace')

return M
