local is_unix = vim.fn.has "unix" == 1
local is_macos = vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1
local is_wsl = vim.fn.has "wsl" == 1
-- false for WSL
local is_windows = vim.fn.has "win32" == 1 or vim.fn.has "win32unix" == 1
local function open_system_dir_command(path)
	if is_windows then
		return ":lua os.execute('cmd /c start " .. path .. "')<CR>"
	end
	if is_macos then
		return ":lua os.execute('open /c start " .. path .. "')<CR>"
	end
	if is_unix then
		return ":lua os.execute('xdg-open /c start " .. path .. "')<CR>"
	end
end

return {
	setup = function()
		-- Setting up the greeter
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		local short_heading = {
			[[  _  _ ___ _____   _____ __  __  ]],
			[[ | \| | __/ _ \ \ / /_ _|  \/  | ]],
			[[ | .` | _| (_) \ V / | || |\/| | ]],
			[[ |_|\_|___\___/ \_/ |___|_|  |_| ]],
			[[                                 ]],
		}

		dashboard.section.header.val = short_heading

		local host_file_location = is_windows and "C:/windows/system32/drivers/etc" or "/etc"
		local config_file_location = is_windows and "~/AppData/Local/nvim/init.lua" or "~/.config/nvim/init.lua"
		local config_wezterm = "~/.config/wezterm/wezterm.lua"
		local config_nushell = is_windows and "~/AppData/Roaming/nushell/config.nu" or "~/.config/nushell/config.nu"

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
			dashboard.button("o", "  > Workspace", ":Telescope workspaces<CR>"),
			dashboard.button("r", "  > Recent file", ":Telescope oldfiles<CR>"),
			dashboard.button("i", "  > Neorg inbox", ":edit ~/neorg/inbox.org<CR>"),
			dashboard.button("t", "  > Neorg todo", ":edit ~/neorg/todo.org<CR>"),
			dashboard.button("p", "  > Package Manager", ":Lazy<CR>"),
			dashboard.button("s", "  > Neovim settings", ":e " .. config_file_location .. " | :cd %:p:h<CR>"),
			dashboard.button("w", "  > Wezterm settings", ":e " .. config_wezterm .. " | :cd %:p:h<CR>"),
			dashboard.button("n", "  > Nushell settings", ":e " .. config_nushell .. " | :cd %:p:h<CR>"),
			dashboard.button("h", "  > Open hosts file dir", open_system_dir_command(host_file_location)),
			dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
		}
		local function footer()
			return "Don't Stop Until You are Proud..."
		end

		dashboard.section.footer.val = footer()
		dashboard.section.footer.opts.hl = "Type"
		dashboard.section.header.opts.hl = "Include"
		dashboard.section.buttons.opts.hl = "Keyword"
		dashboard.opts.opts.noautocmd = true
		alpha.setup(dashboard.opts)
	end,
}

