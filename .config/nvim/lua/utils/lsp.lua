local M = {}

-- Render LSP codelens inline (end-of-line) instead of on a virtual line above
-- the symbol (the "N implementations" line that gets pushed up over a struct).
--
-- Neovim 0.12 rewrote codelens: vim.lsp.codelens.display() is now a deprecated
-- no-op, and rendering lives in a private decoration provider that hardcodes
-- `virt_lines` + `virt_lines_above`. There is no public option to change it, so
-- we re-register that decoration provider on its own namespace and reuse
-- Neovim's own fetch/resolve pipeline (rust-analyzer fills the implementation
-- count in lazily via codeLens/resolve), only swapping the render to virt_text.
--
-- NOTE: this reaches into Neovim internals (vim.lsp._capability). If a Neovim
-- update ever makes codelens vanish, this block is the thing to revisit.
-- Swap 'eol' for 'right_align' below to pin the text to the window's right edge.
do
    local api = vim.api
    -- Force the builtin codelens module to load so it registers its decoration
    -- provider first; we override it right after.
    local _ = vim.lsp.codelens
    local ok, capability = pcall(require, 'vim.lsp._capability')
    local Provider = ok and capability.all and capability.all['codelens']

    if Provider then
        local function render(bufnr, toprow, botrow)
            local provider = Provider.active[bufnr]
            if not provider then
                return
            end
            for row = toprow, botrow do
                if provider.row_version[row] ~= provider.version then
                    for client_id, state in pairs(provider.client_state) do
                        local ns = state.namespace
                        api.nvim_buf_clear_namespace(bufnr, ns, row, row + 1)
                        local lenses = state.row_lenses[row]
                        if lenses then
                            table.sort(lenses, function(a, b)
                                return a.range.start.character < b.range.start.character
                            end)
                            local client = vim.lsp.get_client_by_id(client_id)
                            local virt_text = {}
                            for _, lens in ipairs(lenses) do
                                if not lens.command then
                                    -- Unresolved: ask the server for the title (the count).
                                    if client then
                                        provider:resolve(client, lens)
                                    end
                                else
                                    table.insert(virt_text, { lens.command.title, 'LspCodeLens' })
                                    table.insert(virt_text, { ' | ', 'LspCodeLensSeparator' })
                                end
                            end
                            if #virt_text > 0 then
                                table.remove(virt_text) -- drop trailing separator
                                api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
                                    virt_text = virt_text,
                                    virt_text_pos = 'eol',
                                    hl_mode = 'combine',
                                })
                            end
                        end
                    end
                    provider.row_version[row] = provider.version
                end
            end
            -- Clear stale extmarks past the end of the buffer.
            if botrow == api.nvim_buf_line_count(bufnr) - 1 then
                for _, state in pairs(provider.client_state) do
                    api.nvim_buf_clear_namespace(bufnr, state.namespace, botrow + 1, -1)
                end
            end
        end

        api.nvim_set_decoration_provider(api.nvim_create_namespace('nvim.lsp.codelens'), {
            on_win = function(_, _, bufnr, toprow, botrow)
                pcall(render, bufnr, toprow, botrow)
            end,
        })
    end
end

M.on_attach = function(client, bufnr)
    require('utils.autocommands').lsp_autocmds(client, bufnr)

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end
end
M.capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

    -- workaround until neovim supports multiple client encodings
    capabilities = vim.tbl_deep_extend('force', capabilities, {
        offsetEncoding = { 'utf-16' },
        general = {
            positionEncodings = { 'utf-16' },
        },
    })
    return capabilities
end

return M
