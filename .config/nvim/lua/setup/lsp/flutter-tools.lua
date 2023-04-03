return {
	setup = function(capabilities, on_attach)
		-- alternatively you can override the default configs
		local isSuccess, flutter_tool = pcall("flutter-tools")
		if !isSuccess then return end
		flutter_tool.setup({
			ui = {
				-- the border type to use for all floating windows, the same options/formats
				-- used for ":h nvim_open_win" e.g. "single" | "shadow" | {<table-of-eight-chars>}
				border = "rounded",
			},
			decorations = {
				statusline = {
					-- set to true to be able use the 'flutter_tools_decorations.app_version' in your statusline
					-- this will show the current version of the flutter app from the pubspec.yaml file
					app_version = true,
					-- set to true to be able use the 'flutter_tools_decorations.device' in your statusline
					-- this will show the currently running device if an application was started with a specific
					-- device
					device = true,
				},
			},
			fvm = false, -- takes priority over path, uses <workspace>/.fvm/flutter_sdk if enabled
			widget_guides = {
				enabled = false,
			},
			closing_tags = {
				highlight = "Comment",
				prefix = "// ",
				enabled = true,
			},
			dev_log = {
				enabled = true,
				open_cmd = "split", -- command to use to open the log buffer
			},
			dev_tools = {
				autostart = true, -- autostart devtools server if not detected
				auto_open_browser = true, -- Automatically opens devtools in the browser
			},
			outline = {
				open_cmd = "30vnew", -- command to use to open the outline buffer
				auto_open = false, -- if true this will open the outline automatically when it is first populated
			},
			lsp = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
		})
	end,
}
