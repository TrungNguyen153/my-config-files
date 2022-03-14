local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local opts = {
		on_attach = require("lsp.handlers").on_attach,
		capabilities = require("lsp.handlers").capabilities,
	}

	if server.name == "jsonls" then
		local jsonls_opts = require("lsp.settings.jsonls")
		opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
	end

	if server.name == "sumneko_lua" then
		local sumneko_opts = require("lsp.settings.sumneko_lua")
		opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
		local luadev = require("lua-dev").setup({
			-- add any options here, or leave empty to use the default settings
			-- lspconfig = {
			--   cmd = {"lua-language-server"}
			-- },
		})
		opts = vim.tbl_deep_extend("force", luadev, opts)
	end

  if server.name == "pyright" then
    local pyright_opts = require("lsp.settings.pyright")
    opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  end

	if server.name == "tsserver" then
		local tsserver_opts = require("lsp.settings.tsserver")
		opts = vim.tbl_deep_extend("force", tsserver_opts, opts)
	end

	if server.name == "rust_analyzer" then
		local rust_tools_config = require("lsp.settings.rust-tools")
		local merge_option = vim.tbl_deep_extend("force",rust_tools_config.server, opts)
		require("rust-tools").setup({
      tools = rust_tools_config.tools,
      dap = rust_tools_config.dap,
			server = vim.tbl_deep_extend("force", server:get_default_options(), merge_option),
		})
		return
	end

	-- Ignore server setup because plugin handle this for us
	if server.name == "dartls" then
		return
	end
	-- This setup() function is exactly the same as lspconfig's setup function.
	-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	server:setup(opts)
end)
