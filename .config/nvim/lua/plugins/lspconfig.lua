-- collection of LSP configurations for nvim

return {
	"neovim/nvim-lspconfig",
	priority = 100,
	lazy = false,
	dependencies = {
        'b0o/schemastore.nvim', -- adds schemas for json lsp
    },
	enabled = not vim.g.vscode,
	config = function()
		local lsp_utils = require("utils.lsp")

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
		vim.lsp.enable('bashls')
        vim.lsp.config('bashls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
		-- yaml
		vim.lsp.enable('yamlls')
        vim.lsp.config('yamlls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            settings = {
                yaml = {
                    schemaStore = {
                        enable = false,
                        url = 'https://www.schemastore.org/api/json/catalog.json',
                    },
                    schemas = require('schemastore').yaml.schemas(),
                    format = {
                        enable = true,
                    },
                },
            },
        })
		-- json
		vim.lsp.enable('jsonls')
        vim.lsp.config('jsonls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            commands = {
                Format = {
                    function()
                        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
                    end,
                },
            },
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })
		-- eslint
        vim.lsp.enable('eslint')
        vim.lsp.config('eslint', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- docker
        vim.lsp.enable('dockerls')
        vim.lsp.config('dockerls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        vim.lsp.enable('docker_compose_language_service')
        vim.lsp.config('docker_compose_language_service', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
		-- toml
        vim.lsp.enable('taplo')
        vim.lsp.config('taplo', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
		-- kotlin
		vim.lsp.enable('kotlin_language_server')
        vim.lsp.config('kotlin_language_server', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
		-- svelte
		vim.lsp.enable('svelte')
        vim.lsp.config('svelte', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
		-- Tailwindcss
		vim.lsp.enable('tailwindcss')
        vim.lsp.config('tailwindcss', {
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
			settings = {
				tailwindCSS = {
					emmetCompletions = true,
					experimental = {
						classRegex = { "class\\s*:\\s*\"([^\"]*)" },
					},
					includeLanguages = {
						rust = "html",
					}
				}
			}
			-- Here If any of files from list will exist tailwind lsp will activate.
			-- root_dir = require('lspconfig').util.root_pattern(
			-- 	"tailwind.config.js",
			-- 	"tailwind.config.ts",
			-- 	"postcss.config.js",
			-- 	"postcss.config.ts",
			-- 	"windi.config.ts"
			-- ),
        })
		-- C/C++
		vim.lsp.enable('clangd')
        vim.lsp.config('clangd', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
			cmd = {
				"clangd",
				"--fallback-style=webkit",
			},
        })
		-- sql
		vim.lsp.enable('sqlls')
        vim.lsp.config('sqlls', {
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
		vim.lsp.enable('lua_ls')
		vim.lsp.config('lua_ls', {
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

		vim.lsp.enable('wgsl_analyzer')
		vim.lsp.config('wgsl_analyzer', {
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
