local M = {}

-- TODO: backfill this to template
M.setup = function()
	-- Diagnostics signs and highlights
	--   Error:   ✘
	--   Warn:  ⚠ 
	--   Hint:  
	--   Info:   ⁱ

	local signs = {
		{ name = "DiagnosticSignError", text = "✘" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- disable virtual text
		virtual_text = true,
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_highlight_document(client)
	-- Set autocommands conditional on server_capabilities
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

local function lsp_keymaps(bufnr)
	local function map_buf(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local opts = { noremap = true, silent = true }
	map_buf("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	map_buf("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	map_buf("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	map_buf("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	map_buf("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	map_buf("n", "<leader>h", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	map_buf("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	map_buf("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	map_buf("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	map_buf("n", "<Leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	map_buf("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting()' ]])
	vim.cmd([[ command! Neoformat execute 'lua vim.lsp.buf.formatting()' ]])
end

M.on_attach = function(client, bufnr)
	if client.name == "tsserver" or client.name == "dartls" then
		client.resolved_capabilities.document_formatting = false
	end
	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local status_cmp_ok, _ = pcall(require, "cmp")
if not status_cmp_nvim_lsp_ok or not status_cmp_ok then
	return M
end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
