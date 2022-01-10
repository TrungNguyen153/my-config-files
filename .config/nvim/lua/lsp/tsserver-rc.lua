
local lspconfig = require("lspconfig")

local config = _G.lsp_pre_default_config()

config.on_attach = function(client, bufnr)
    -- client.resolved_capabilities.document_formatting = false
    -- client.resolved_capabilities.document_range_formatting = false
    local ts_utils = require("nvim-lsp-ts-utils")
    print('hello from tsserver-rc')
    ts_utils.setup({
        debug = false,
        disable_commands = false,
        enable_import_on_completion = false,

        -- import all
        import_all_timeout = 5000, -- ms
        -- lower numbers = higher priority
        import_all_priorities = {
            same_file = 1, -- add to existing import statement
            local_files = 2, -- git files or files with relative path markers
            buffer_content = 3, -- loaded buffer content
            buffers = 4, -- loaded buffer names
        },
        import_all_scan_buffers = 100,
        import_all_select_source = false,

        -- filter diagnostics
        filter_out_diagnostics_by_severity = {},
        filter_out_diagnostics_by_code = {},

        -- inlay hints
        auto_inlay_hints = true,
        inlay_hints_highlight = "Comment",
    })
    ts_utils.setup_client(client)
    _G.lsp_buf_map(bufnr, "n", ",o", ":TSLspOrganize<CR>")
    -- _G.lsp_buf_map(bufnr, "n", ",r", ":TSLspRenameFile<CR>")
    -- _G.lsp_buf_map(bufnr, "n", "fip", ":TSLspImportAll<CR>")
    -- delegate to lsp attack
    _G.lsp_on_attach(client, bufnr)
end

lspconfig.tsserver.setup(config)