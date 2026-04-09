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

        -- C/C++
        vim.lsp.enable('clangd')
        vim.lsp.config('clangd', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- bash
        vim.lsp.enable('bashls')
        vim.lsp.config('bashls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- yaml
        vim.lsp.config('yamlls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
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
        vim.lsp.enable('yamlls')

        -- json
        vim.lsp.config('jsonls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            commands = {
                Format = {
                    function()
                        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
                    end,
                },
            },
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })
        vim.lsp.enable('jsonls')
        vim.lsp.config('jsonls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- eslint
        vim.lsp.enable('eslint')
        vim.lsp.config('eslint', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- docker
        vim.lsp.enable('dockerls')
        vim.lsp.config('dockerls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        vim.lsp.enable('docker_compose_language_service')
        vim.lsp.config('docker_compose_language_service', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- toml
        vim.lsp.enable('taplo')
        vim.lsp.config('taplo', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- kotlin
        vim.lsp.enable('kotlin_language_server')
        vim.lsp.config('kotlin_language_server', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- svelte
        vim.lsp.enable('svelte')
        vim.lsp.config('svelte', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- slint
        vim.lsp.enable('slint_lsp')
        vim.lsp.config('slint_lsp', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- CMake
        vim.lsp.config('neocmake', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            init_options = { buildDirectory = 'build' },
        })
        vim.lsp.enable('neocmake')

        -- sql
        vim.lsp.config('sqlls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
        })
        vim.lsp.enable('sqlls')

        vim.lsp.enable('emmylua_ls')
        vim.lsp.config('emmylua_ls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        vim.lsp.config('wgsl_analyzer', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
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
        vim.lsp.enable('wgsl_analyzer')

        vim.lsp.enable('pyright')
        vim.lsp.config('pyright', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
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
            'gt',
            function()
                Snacks.picker.lsp_type_definitions()
            end,
            desc = 'Goto Type Definition',
            silent = true,
        },
        {
            '<leader>ss',
            function()
                Snacks.picker.lsp_symbols()
            end,
            desc = 'LSP Symbols',
            silent = true,
        },
        {
            '<leader>sS',
            function()
                Snacks.picker.lsp_workspace_symbols()
            end,
            desc = 'LSP Workspace Symbols',
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
            'K',
            vim.lsp.buf.hover,
            mode = { 'n' },
            desc = 'Show hover popup or folded preview',
            silent = true,
        },
        {
            '<M-f>',
            function()
                vim.lsp.buf.format({ async = false })
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
            '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
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
            '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',
            mode = { 'n' },
            desc = 'Diagnostic set loclist',
            noremap = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.range_code_action()<CR>',
            mode = { 'v' },
            desc = 'Range Code Action',
            noremap = true,
        },
        {
            'si',
            '<Cmd>ClangdSwitchSourceHeader<CR>',
            mode = { 'n' },
            desc = 'Switch Source Header (C/C++)',
            noremap = true,
            silent = true,
        },
    },
}
