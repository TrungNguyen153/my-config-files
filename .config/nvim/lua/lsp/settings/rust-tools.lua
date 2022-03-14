local opts = {
	tools = {
		autoSetHints = true,
		hover_with_actions = true,
		inlay_hints = {
			only_current_line = false,
			show_parameter_hints = true,
			parameter_hints_prefix = "",
			other_hints_prefix = "",
		},
		hover_actions = {
			auto_focus = false,
		},
		debuggables = {
			use_telescope = true,
		},
		runnables = {
			use_telescope = true,
		},
	},

	-- debugging stuff
	--sudo apt install lldb-11
	-- sudo ln -s /usr/bin/lldb-vscode-11 /usr/bin/lldb-vscode
	dap = {
		adapter = {
			type = "executable",
			command = "/usr/bin/lldb-vscode", -- adjust as needed
			name = "lldb",
		},
	},
	-- all the opts to send to nvim-lspconfig
	-- these override the defaults set by rust-tools.nvim
	-- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
	server = {
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
			["rust-analyzer"] = {
				assist = {
					importGranularity = "module",
					importPrefix = "by_self",
				},
				diagnostics = {
					-- https://github.com/rust-analyzer/rust-analyzer/issues/6835
					disabled = { "unresolved-macro-call" },
				},
				completion = {
					autoimport = {
						enable = true,
					},
					postfix = {
						enable = true,
					},
				},
				cargo = {
					loadOutDirsFromCheck = true,
					autoreload = true,
					runBuildScripts = true,
				},
				procMacro = {
					enable = true,
				},
				lens = {
					enable = true,
					run = true,
					methodReferences = true,
					implementations = true,
				},
				hoverActions = {
					enable = true,
				},
				inlayHints = {
					chainingHintsSeparator = "‣ ",
					typeHintsSeparator = "‣ ",
					typeHints = true,
				},
				checkOnSave = {
					enable = true,
					command = "clippy",
					allFeatures = true,
				},
			},
		},
	},
}

return opts
