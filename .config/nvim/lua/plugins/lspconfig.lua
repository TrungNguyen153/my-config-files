-- collection of LSP configurations for nvim
return {
    'neovim/nvim-lspconfig',
    priority = 100,
    lazy = false,
    dependencies = {
        'b0o/schemastore.nvim', -- adds schemas for json lsp
    },
    enabled = not vim.g.vscode,
    config = function()
        local lsp_utils = require('utils.lsp')

        -- general LSP config
        vim.diagnostic.config({
            underline = true,
            virtual_text = false,
            severity_sort = true,
            update_in_insert = true,
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

        vim.lsp.on_type_formatting.enable()

        -- Shared setup for every client (rustaceanvim and typescript-tools too),
        -- without replacing the per-server on_attach that nvim-lspconfig ships.
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then
                    return
                end
                if client:supports_method('textDocument/inlayHint', ev.buf) then
                    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                end
                if client:supports_method('textDocument/codeLens', ev.buf) then
                    vim.lsp.codelens.enable(true, { bufnr = ev.buf })
                end
            end,
        })

        vim.lsp.config('*', { capabilities = lsp_utils.capabilities() })
        -- nvim-lspconfig's clangd config lists utf-8 first and outranks '*'
        vim.lsp.config('clangd', { capabilities = { offsetEncoding = { 'utf-16' } } })

        -- yaml
        vim.lsp.config('yamlls', {
            settings = {
                yaml = {
                    schemaStore = {
                        enable = false,
                        url = 'https://www.schemastore.org/api/json/catalog.json',
                    },
                    schemas = require('schemastore').yaml.schemas(),
                    format = { enable = true },
                },
            },
        })

        -- json
        vim.lsp.config('jsonls', {
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        -- CMake
        vim.lsp.config('neocmake', {
            init_options = { buildDirectory = 'build' },
        })

        -- sql
        vim.lsp.config('sqlls', {
            cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
        })

        vim.lsp.config('wgsl_analyzer', {
            settings = {
                ['wgsl-analyzer.customImports'] = {

                    ['bevy_sprite::mesh2d_bindings'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_bindings.wgsl',
                    ['bevy_sprite::mesh2d_functions'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_functions.wgsl',
                    ['bevy_sprite::mesh2d_types'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_types.wgsl',
                    ['bevy_sprite::mesh2d_vertex_output'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_vertex_output.wgsl',
                    ['bevy_sprite::mesh2d_view_bindings'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_bindings.wgsl',
                    ['bevy_sprite::mesh2d_view_types'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_types.wgsl',
                    ['bevy_sprite::sprite_view_bindings'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/render/sprite_view_bindings.wgsl',
                    ['bevy_ui::ui_vertex_output'] = 'https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_ui/src/render/ui_vertex_output.wgsl',
                },
            },
        })

        vim.lsp.enable(vim.list_extend({ 'clangd' }, lsp_utils.servers))
    end,
    keys = {
        -- LSP
        {
            'gd',
            function()
                Snacks.picker.lsp_definitions()
            end,
            desc = 'Goto Definition',
            silent = true,
        },
        {
            'gD',
            function()
                Snacks.picker.lsp_declarations()
            end,
            desc = 'Goto Declaration',
            silent = true,
        },
        {
            'gr',
            function()
                Snacks.picker.lsp_references({ include_declaration = false })
            end,
            nowait = true,
            desc = 'References',
            silent = true,
        },
        {
            'gi',
            function()
                Snacks.picker.lsp_implementations()
            end,
            desc = 'Goto Implementation',
            silent = true,
        },
        {
            'gy',
            function()
                Snacks.picker.lsp_type_definitions()
            end,
            desc = 'Goto Type Definition',
            silent = true,
        },
        {
            'gw',
            ':vsplit | lua vim.lsp.buf.definition()<CR>',
            mode = { 'n' },
            desc = 'Go to definition splited',
            silent = true,
        },
        {
            '<M-s>',
            function()
                local blink_window = require('blink.cmp.completion.windows.menu')
                local blink = require('blink.cmp')
                -- Close the completion menu first (if open).
                if blink_window.win:is_open() then
                    blink.hide()
                end
                vim.lsp.buf.signature_help()
            end,
            mode = { 'i' },
            desc = 'Signature help',
            silent = true,
        },
        {
            '<M-s>',
            vim.lsp.buf.signature_help,
            mode = { 'n' },
            desc = 'Signature help',
            silent = true,
        },
        {
            '<M-f>',
            function()
                require('conform').format({ async = false, lsp_format = 'fallback' })
            end,
            mode = { 'n' },
            desc = 'Format code',
            silent = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            desc = 'Code Actions',
            noremap = true,
            mode = { 'n' },
        },
        {
            '<leader>ca',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            desc = 'Code Actions',
            noremap = true,
            mode = { 'n' },
        },
        {
            '<leader>lb',
            '<cmd>lua vim.diagnostic.open_float()<CR>',
            mode = { 'n' },
            desc = 'Show line diagnostics',
            noremap = true,
        },
        {
            '<leader>ll',
            '<cmd>lua vim.lsp.codelens.run()<CR>',
            mode = { 'n' },
            desc = 'Code Lens',
            noremap = true,
        },
        {
            '<leader>lm',
            '<cmd>lua vim.lsp.buf.rename()<CR>',
            mode = { 'n' },
            desc = 'Rename symbol',
            noremap = true,
        },
        {
            '<leader>lq',
            '<cmd>lua vim.diagnostic.setloclist()<CR>',
            mode = { 'n' },
            desc = 'Diagnostic set loclist',
            noremap = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            mode = { 'v' },
            desc = 'Range Code Action',
            noremap = true,
        },
        {
            'si',
            '<Cmd>LspClangdSwitchSourceHeader<CR>',
            ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
            mode = { 'n' },
            desc = 'Switch Source Header (C/C++)',
            noremap = true,
            silent = true,
        },
    },
}
