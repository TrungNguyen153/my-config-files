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

-- Recursive mkdir. No-op if directory exists.
local function mkdir_p(path)
  if wezterm.target_triple:find('windows') then
    -- cmd's mkdir creates intermediate dirs by default. Backslash paths required.
    local win_path = path:gsub('/', '\\')
    os.execute('cmd /c if not exist "' .. win_path .. '" mkdir "' .. win_path .. '" 2>nul')
  else
    os.execute('mkdir -p "' .. path .. '" 2>/dev/null')
  end
end

M._mkdir_p = mkdir_p  -- exposed for testing

-- Initialize plugin and ensure data directories exist.
-- Must be called from wezterm.lua exactly once.
function M.setup(resurrect)
  local dir = M.state_dir()
  mkdir_p(dir)
  mkdir_p(dir .. '/workspace')
  resurrect.state_manager.change_state_save_dir(dir)
  M._resurrect = resurrect
  wezterm.log_info('workspace_persist: state dir = ' .. dir)
end

return M
