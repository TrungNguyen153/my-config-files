
local lspconfig = require("lspconfig")

local config = _G.lsp_pre_default_config()

config.on_attach = function(client, bufnr)
    _G.lsp_on_attach(client, bufnr)
end


lspconfig.ccls.setup(config)
