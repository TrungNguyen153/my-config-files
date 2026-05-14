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

-- Read a file's contents. Returns string or nil.
local function read_file(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  return content
end

-- Returns sorted list of saved workspace names (file basename without .json).
-- Files whose JSON fails to parse are omitted (logged as warnings).
function M.list_saved()
  local dir = M.state_dir() .. '/workspace'
  local files = wezterm.glob('*.json', dir) or {}
  local names = {}
  for _, filename in ipairs(files) do
    -- wezterm.glob returns just basenames; construct full path
    local path = dir .. '/' .. filename
    local content = read_file(path)
    if content then
      local parse_ok, _ = pcall(wezterm.json_parse, content)
      if parse_ok then
        local name = filename:match('([^/\\]+)%.json$')
        if name then
          table.insert(names, name)
        end
      else
        wezterm.log_warn('workspace_persist: skipping corrupt file: ' .. path)
      end
    end
  end
  table.sort(names)
  return names
end

-- True if a saved workspace file exists with this name.
function M.is_tracked(name)
  if not name or name == '' then return false end
  local path = M.state_dir() .. '/workspace/' .. name .. '.json'
  local f = io.open(path, 'r')
  if f then f:close() return true end
  return false
end

return M
