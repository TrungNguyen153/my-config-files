-- collection of LSP configurations for nvim

return {
	"neovim/nvim-lspconfig",
	priority = 100,
	enabled = not vim.g.vscode,
	config = function()
		local lsp_utils = require("utils.lsp")
		local lspconfig = require("lspconfig")

		-- general LSP config
		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			underline = true,
			update_in_insert = true,
			virtual_text = false,
			signs = true,
		})

		-- skip rust error spam
		for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
			local default_diagnostic_handler = vim.lsp.handlers[method]
			vim.lsp.handlers[method] = function(err, result, context, config)
				if err ~= nil and err.code == -32802 then
					return
				end
				return default_diagnostic_handler(err, result, context, config)
			end
		end

		vim.fn.sign_define(
			"LightBulbSign",
			{ text = "󰛩", texthl = "LspDiagnosticsDefaultInformation", numhl = "LspDiagnosticsDefaultInformation" }
		)

		vim.diagnostic.config({
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = '',
					[vim.diagnostic.severity.WARN] = '',
					[vim.diagnostic.severity.INFO] = '',
					[vim.diagnostic.severity.HINT] = '',
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
					[vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
					[vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
					[vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
				},
			},
		})

		-- bash
		lspconfig.bashls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
		})
		-- yaml
		lspconfig.yamlls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			settings = {
				yaml = {
					schemaStore = {
						enable = false,
						url = "https://www.schemastore.org/api/json/catalog.json",
					},
					schemas = require("schemastore").yaml.schemas(),
					format = {
						enable = true,
					},
				},
			},
		})
		-- json
		lspconfig.jsonls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			commands = {
				Format = {
					function()
						vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
					end,
				},
			},
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})
		-- docker
		lspconfig.dockerls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
		})
		-- kotlin
		lspconfig.kotlin_language_server.setup({

			capabilities = lsp_utils.capabilities(),
		})
		-- svelte
		lspconfig.svelte.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
		})
		lspconfig.tailwindcss.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			-- There add every filetype you want tailwind to work on
			filetypes = {
				"css",
				"scss",
				"sass",
				"postcss",
				"html",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"svelte",
				"vue",
				"rust",
			},
			init_options = {
				-- There you can set languages to be considered as different ones by tailwind lsp I guess same as includeLanguages in VSCod
				userLanguages = {
					rust = "html",
				},
			},
			-- Here If any of files from list will exist tailwind lsp will activate.
			root_dir = lspconfig.util.root_pattern(
				"tailwind.config.js",
				"tailwind.config.ts",
				"postcss.config.js",
				"postcss.config.ts",
				"windi.config.ts"
			),
		})
		-- C/C++
		lspconfig.clangd.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			cmd = {
				"clangd",
				"--fallback-style=webkit",
			},
		})
		-- toml
		lspconfig.taplo.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
		})
		-- sql
		lspconfig.sqlls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			cmd = { "sql-language-server", "up", "--method", "stdio" },
		})

		-- lua
		local lua_runtime = {
			[vim.fn.expand("$VIMRUNTIME/lua")] = true,
			[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
		}
		for _, v in pairs(vim.api.nvim_get_runtime_file("", true)) do
			lua_runtime[v] = true
		end
		lspconfig.lua_ls.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			settings = {
				Lua = {
					format = {
						enabled = false,
						defaultConfig = {
							indent_style = "space",
						},
					},
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						-- Get the language server to recognize the `vim` global
						globals = { "vim", 'Snacks' },
						disable = { "inject-field" },
					},
					workspace = {
						-- Make the server aware of Neovim runtime files
						library = lua_runtime,
						-- stop the annoying message from luassert
						checkThirdParty = false,
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = {
						enable = false,
					},
				},
			},
		})

		lspconfig.wgsl_analyzer.setup({
			on_attach = lsp_utils.on_attach,
			capabilities = lsp_utils.capabilities(),
			settings = {
				["wgsl-analyzer.customImports"] = {
					
					["bevy_sprite::mesh2d_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_bindings.wgsl",
					["bevy_sprite::mesh2d_functions"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_functions.wgsl",
					["bevy_sprite::mesh2d_types"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_types.wgsl",
					["bevy_sprite::mesh2d_vertex_output"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_vertex_output.wgsl",
					["bevy_sprite::mesh2d_view_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_bindings.wgsl",
					["bevy_sprite::mesh2d_view_types"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_types.wgsl",
					["bevy_sprite::sprite_view_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/render/sprite_view_bindings.wgsl",
					["bevy_ui::ui_vertex_output"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_ui/src/render/ui_vertex_output.wgsl"
				},
			},
        })
	end,
	keys = {
		{
			"gD",
			vim.lsp.buf.declaration,
			mode = { "n" },
			desc = "Go to declaration",
			silent = true,
		},
		{
			"gt",
			vim.lsp.buf.type_definition,
			mode = { "n" },
			desc = "Go to type definition",
			silent = true,
		},
		{
			"gd",
			vim.lsp.buf.definition,
			mode = { "n" },
			desc = "Go to definition",
			silent = true,
		},
		{
			"gw",
			":vsplit | lua vim.lsp.buf.definition()<CR>",
			mode = { "n" },
			desc = "Go to definition splited",
			silent = true,
		},
		{
			"gi",
			function()
				-- vim.lsp.buf.implementation,\
				Snacks.picker.lsp_implementations()
			end,
			mode = { "n" },
			desc = "Go to implementation",
			silent = true,
		},
		{
			"gr",
			function()
				-- vim.lsp.buf.references({ includeDeclaration = false })
				Snacks.picker.lsp_references({ include_declaration = false })
			end,
			mode = { "n" },
			desc = "Find references",
			silent = true,
		},
		{
			"<M-s>",
			function()
				local blink_window = require 'blink.cmp.completion.windows.menu'
        		local blink = require 'blink.cmp'
				-- Close the completion menu first (if open).
				if blink_window.win:is_open() then
					blink.hide()
				end
				vim.lsp.buf.signature_help()
			end,
			mode = { "i" },
			desc = "Signature help",
			silent = true,
		},
		{
			"<M-s>",
			vim.lsp.buf.signature_help,
			mode = { "n" },
			desc = "Signature help",
			silent = true,
		},
		{
			"K",
			vim.lsp.buf.hover,
			mode = { "n" },
			desc = "Show hover popup or folded preview",
			silent = true,
		},
		{
			"<M-f>",
			function()
				vim.lsp.buf.format({ async = false })
			end,
			mode = { "n" },
			desc = "Format code",
			silent = true,
		},
		{
			"<leader>la",
			"<cmd>lua vim.lsp.buf.code_action()<CR>",
			desc = "Code Actions",
			noremap = true,
			mode = { "n" },
		},
		{
			"<leader>ca",
			"<cmd>lua vim.lsp.buf.code_action()<CR>",
			desc = "Code Actions",
			noremap = true,
			mode = { "n" },
		},
		{
			"<leader>lb",
			"<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
			mode = { "n" },
			desc = "Show line diagnostics",
			noremap = true,
		},
		{
			"<leader>lc",
			function()
				vim.b.autoformat = not vim.b.autoformat
			end,
			mode = { "n" },
			desc = "Toggle autoformat",
			noremap = true,
		},
		{
			"<leader>lf",
			"<cmd>lua vim.lsp.buf.format({ async = false })<CR>",
			mode = { "n" },
			desc = "Format",
			noremap = true,
		},
		{
			"<leader>ll",
			"<cmd>lua vim.lsp.codelens.run()<CR>",
			mode = { "n" },
			desc = "Code Lens",
			noremap = true,
		},
		{
			"<leader>lm",
			"<cmd>lua vim.lsp.buf.rename()<CR>",
			mode = { "n" },
			desc = "Rename symbol",
			noremap = true,
		},
		{
			"<leader>lq",
			"<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>",
			mode = { "n" },
			desc = "Diagnostic set loclist",
			noremap = true,
		},
		{
			"<leader>la",
			"<cmd>lua vim.lsp.buf.range_code_action()<CR>",
			mode = { "v" },
			desc = "Range Code Action",
			noremap = true,
		},
	},
}
