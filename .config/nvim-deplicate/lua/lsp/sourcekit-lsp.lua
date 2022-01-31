
local lspconfig = require("lspconfig")

local config = _G.lsp_pre_default_config()

config.on_attach = function(client, bufnr)
    _G.lsp_on_attach(client, bufnr)
end

config.filetypes = { "swift", "c", "cpp", "objective-c", "objective-cpp", "objc", "objcpp" }


lspconfig.sourcekit.setup(config)
