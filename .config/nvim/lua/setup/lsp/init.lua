local M = {}

M.on_attach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end

	require("setup.autocommand").lsp_autocmds(client, bufnr)
	vim.lsp.set_log_level("OFF") -- ON CAUSE LAG

	-- check if this is applicable (for rust for example it is not)
	-- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#improve-language-server-snippets

	-- enable inlay hints if server supports it
	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
end
M.capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

	-- workaround until neovim supports multiple client encodings
	capabilities = vim.tbl_deep_extend("force", capabilities, {
		offsetEncoding = { "utf-16" },
		general = {
			positionEncodings = { "utf-16" },
		},
	})

	return capabilities
end

M.config_defaults = function()
	local lspconfig = require("lspconfig")
	-- bash
	lspconfig.bashls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- C#
	lspconfig.omnisharp.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- python
	lspconfig.pyright.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- yaml
	lspconfig.yamlls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
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
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
		commands = {
			Format = {
				function()
					vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
				end,
			},
		},
		settings = {
			json = {
				schemas = require("schemastore").json.schemas({
					extra = {
						{
							description = "Monkeys Schema",
							fileMatch = { "monkeys/config.json", "monkeys/example.json" },
							name = "Infinite Monkeys",
							url = "file://" .. vim.fn.getcwd() .. "/monkeys/schema.json",
						},
					},
				}),
				validate = { enable = true },
			},
		},
	})
	-- docker
	lspconfig.dockerls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- sql
	lspconfig.sqlls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
		cmd = { "sql-language-server", "up", "--method", "stdio" },
	})
	-- kotlin
	lspconfig.kotlin_language_server.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- svelte
	lspconfig.svelte.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	lspconfig.tailwindcss.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
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
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- Qml
	lspconfig.qmlls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- Toml formatter
	lspconfig.taplo.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
end

M.setup = function()
	local lspconfig = require("lspconfig")
	require("mason").setup()
	require("mason-lspconfig").setup({
		-- ensure_installed = { "jdtls", },
	})
	require("mason-tool-installer").setup({
		ensure_installed = {
			"codelldb",
			-- "eslint_d", -- npm - but no longer use
			-- "write-good", -- npm
			-- "rust-analyzer",
			"clangd",
			"shfmt",
			"stylua",
			"taplo", -- toml formatter
			-- "codespell", -- require python for installer
		},
	})
	-- general LSP config
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		update_in_insert = true,
		virtual_text = false,
		signs = true,
	})

	-- show icons in the sidebar
	local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
	vim.fn.sign_define(
		"LightBulbSign",
		{ text = "💡", texthl = "LspDiagnosticsDefaultInformation", numhl = "LspDiagnosticsDefaultInformation" }
	)

	vim.diagnostic.config({
		severity_sort = true,
	})
	return lspconfig
end
return M
