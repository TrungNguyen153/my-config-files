local M = {}

M.on_attach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end

	require("setup.autocommand").lsp_autocmds(client, bufnr)
	-- check if this is applicable (for rust for example it is not)
	-- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#improve-language-server-snippets

	-- enable inlay hints if server supports it
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint(bufnr, true)
    end
end
M.capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

	-- workaround until neovim supports multiple client encodings
    capabilities = vim.tbl_deep_extend('force', capabilities, {
        offsetEncoding = { 'utf-16' },
        general = {
            positionEncodings = { 'utf-16' },
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
					enable = true,
					url = "https://www.schemastore.org/api/json/catalog.json",
				},
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				},
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
				schemas = require("schemastore").json.schemas(),
			},
		},
	})
	-- docker
	lspconfig.dockerls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
	})
	-- deno
	-- ensure_server('denols'):setup({})
	-- sql
	lspconfig.sqlls.setup({
		on_attach = M.on_attach,
		capabilities = M.capabilities(),
		cmd = { "sql-language-server", "up", "--method", "stdio" },
	})
	-- swift
	-- lspconfig.sourcekit.setup({
	-- 	on_attach = M.on_attach,
	-- 	capabilities = M.capabilities(),
	-- })
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
	})
	-- C/C++
    lspconfig.clangd.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
    })
	-- typescript
	require("setup.lsp.typescript").setup(lspconfig, M.capabilities(), M.on_attach)
end

M.setup = function()
	local lspconfig = require("lspconfig")
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = { "jdtls" },
		automatic_installation = true,
	})
	require("mason-tool-installer").setup({
		ensure_installed = {
			"codelldb",
			"eslint_d",
			-- "black", -- python formater
			"clangd",
			"ktlint",
			-- "markdownlint",
			"shfmt",
			"stylua",
			"codespell",
			"vale",
			-- 'clang-format',
			-- "luacheck",
			-- "pylint",
			"write-good",
			-- "yamllint",
			-- "cmakelang",
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