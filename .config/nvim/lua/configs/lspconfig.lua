local lspconfig = require("lspconfig")
_G.lsp_buf_map = function(bufnr, mode, lhs, rhs, opts)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or {
        silent = true,
        noremap = true,
    })
end

_G.lsp_on_attach = function(client, bufnr)
    local function map_buf(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	-- local function opt_buf(...) vim.api.nvim_buf_set_option(bufnr, ...) end
	-- Disable diagnostics for Helm template files
	if vim.bo[bufnr].buftype ~= '' or vim.bo[bufnr].filetype == 'helm' then
		vim.lsp.diagnostic.disable()
		return
	end

	if client.config.flags then
		client.config.flags.allow_incremental_sync = true
		client.config.flags.debounce_text_changes  = 100
	end

	-- Keyboard mappings
	local opts = { noremap = true, silent = true }
	map_buf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	map_buf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	map_buf('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	map_buf('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	map_buf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map_buf('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	map_buf('n', ',s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map_buf('n', ',wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	map_buf('n', ',wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	map_buf('n', ',wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	map_buf('n', '<Leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map_buf('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	map_buf('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	map_buf('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	map_buf('n', '<Leader>ce', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)

	-- See https://github.com/ray-x/lsp_signature.nvim
	--  require('lsp_signature').on_attach({
	-- 	bind = true,
	-- 	check_pumvisible = true,
	-- 	hint_enable = false,
	-- 	hint_prefix = '🐼 ',  --🐼
	-- 	handler_opts = { border = 'single' },
	-- 	zindex = 50,
	--  }, bufnr)

	-- Set some keybinds conditional on server capabilities
	if client.resolved_capabilities.document_formatting then
		map_buf('n', ',f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
		-- map_buf('n', ',f', '<cmd>Neoformat<CR>', opts)
	end
	if client.resolved_capabilities.document_range_formatting then
		map_buf('x', ',f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
	end

	-- Set autocommands conditional on server_capabilities
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec([[
			highlight! LspReferenceRead ctermbg=237 guibg=#3D3741
			highlight! LspReferenceText ctermbg=237 guibg=#373B41
			highlight! LspReferenceWrite ctermbg=237 guibg=#374137
			augroup lsp_document_highlight
				autocmd! * <buffer>
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup END
		]], false)
	end
end

_G.lsp_pre_default_config = function()
	local c = {}
	c.on_attach = _G.lsp_on_attach
	c.capabilities = vim.lsp.protocol.make_client_capabilities()
	c.capabilities = require('cmp_nvim_lsp').update_capabilities(c.capabilities)
	c.flags = {
		debounce_text_changes = 150,
	}
	return c
end


-- Configure diagnostics publish settings
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		signs = true,
		underline = false,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			-- prefix = '',
		}
	}
)

-- Configure hover (normal K) handle
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
	vim.lsp.handlers.hover, { border = 'rounded' }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.signature_help, { border = 'rounded' }
)


