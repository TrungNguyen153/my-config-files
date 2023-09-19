return {
	setup = function()
		-- Setting up the greeter
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		local is_windows = (function()
			if package.config:sub(1, 1) == "\\" then
				return true
			end
			return false
		end)()

		local short_heading = {
			[[  _  _ ___ _____   _____ __  __  ]],
			[[ | \| | __/ _ \ \ / /_ _|  \/  | ]],
			[[ | .` | _| (_) \ V / | || |\/| | ]],
			[[ |_|\_|___\___/ \_/ |___|_|  |_| ]],
			[[                                 ]],
		}

		dashboard.section.header.val = short_heading

		local host_file_location = is_windows and "C:/windows/system32/drivers/etc/hosts" or "/etc/hosts"
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
			dashboard.button("h", "  > Edit hosts file", ":e " .. host_file_location .. "<CR>"),
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
