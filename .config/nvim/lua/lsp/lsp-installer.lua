local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

lsp_installer.setup({})

local lspconfig = require("lspconfig")
local function ensure_server(name)
	local _, server = lsp_installer.get_server(name)
	if not server:is_installed() then
		server:install()
	end
	return lspconfig[name]
end

-- Normal Server Config
local servers = { "jsonls", "sumneko_lua", "pyright", "yamlls" }

for _, server in pairs(servers) do
	local opts = {
		on_attach = require("lsp.handlers").on_attach,
		capabilities = require("lsp.handlers").capabilities,
	}
	local has_custom_opts, server_custom_opts = pcall(require, "lsp.settings." .. server)
	if has_custom_opts then
		opts = vim.tbl_deep_extend("force", server_custom_opts, opts)
	end
	ensure_server(server).setup(opts)
end

-- Below hard config server
local default_on_attach = require("lsp.handlers").on_attach
local capabilities = require("lsp.handlers").capabilities

-- typescript
ensure_server("tsserver").setup({
	init_options = require("nvim-lsp-ts-utils").init_options,
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		default_on_attach(client, bufnr)
		local ts_utils = require("nvim-lsp-ts-utils")

		-- defaults
		ts_utils.setup({
			debug = false,
			disable_commands = false,
			enable_import_on_completion = true,

			-- import all
			import_all_timeout = 5000, -- ms
			-- lower numbers indicate higher priority
			import_all_priorities = {
				same_file = 1, -- add to existing import statement
				local_files = 2, -- git files or files with relative path markers
				buffer_content = 3, -- loaded buffer content
				buffers = 4, -- loaded buffer names
			},
			import_all_scan_buffers = 100,
			import_all_select_source = false,

			-- eslint
			eslint_enable_code_actions = true,
			eslint_enable_disable_comments = true,
			eslint_bin = "eslint_d",
			eslint_enable_diagnostics = true,
			eslint_opts = {},

			-- formatting
			enable_formatting = true,
			formatter = "eslint_d",
			formatter_opts = {},

			-- update imports on file move
			update_imports_on_move = true,
			require_confirmation_on_move = false,
			watch_dir = nil,

			-- filter diagnostics
			filter_out_diagnostics_by_severity = {},
			filter_out_diagnostics_by_code = {},

			-- inlay hints
			auto_inlay_hints = true,
			inlay_hints_highlight = "Comment",
		})

		-- required to fix code action ranges and filter diagnostics
		ts_utils.setup_client(client)

		-- no default maps, so you may want to define some here
		local opts = { silent = true }
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gf", ":TSLspRenameFile<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "go", ":TSLspImportAll<CR>", opts)
	end,
})

-- rust
-- FIXME: version used by lspinstall is too old
ensure_server("rust_analyzer")
require("rust-tools").setup({
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
		on_attach = default_on_attach,
		capabilities = capabilities,
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
					enableExperimental = true,
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
					-- https://github.com/rust-analyzer/rust-analyzer/issues/9768
					command = "clippy",
					allFeatures = true,
				},
			},
		},
	},
})
