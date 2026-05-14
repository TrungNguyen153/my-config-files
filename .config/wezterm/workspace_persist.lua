local wezterm = require('wezterm')

local M = {}

-- Normalize path separators to forward slashes (wezterm.glob and io.open
-- both accept forward slashes on Windows).
local function norm(path)
  return (path:gsub('\\', '/'))
end

-- Returns the data directory where workspace JSON files live.
-- Windows: %LOCALAPPDATA%\wezterm
-- Linux:   $XDG_DATA_HOME/wezterm or ~/.local/share/wezterm
-- The plugin creates `workspace/` (and `window/`, `tab/`) subdirs under this.
function M.state_dir()
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

return M
