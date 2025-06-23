-- collection of LSP configurations for nvim
return {
    "neovim/nvim-lspconfig",
    priority = 100,
    lazy = false,
    dependencies = {
        'b0o/schemastore.nvim' -- adds schemas for json lsp
    },
    enabled = not vim.g.vscode,
    config = function()
        local util = require 'lspconfig.util'

        -- general LSP config
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                                                                  vim.lsp
                                                                      .diagnostic
                                                                      .on_publish_diagnostics,
                                                                  {
                underline = true,
                update_in_insert = true,
                virtual_text = false,
                signs = true
            })

        -- skip rust error spam
        for _, method in ipairs({
            "textDocument/diagnostic", "workspace/diagnostic"
        }) do
            local default_diagnostic_handler = vim.lsp.handlers[method]
            vim.lsp.handlers[method] = function(err, result, context, config)
                if err ~= nil and err.code == -32802 then return end
                return default_diagnostic_handler(err, result, context, config)
            end
        end

        vim.fn.sign_define("LightBulbSign", {
            text = "󰛩",
            texthl = "LspDiagnosticsDefaultInformation",
            numhl = "LspDiagnosticsDefaultInformation"
        })

        vim.diagnostic.config({
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '',
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.INFO] = '',
                    [vim.diagnostic.severity.HINT] = ''
                },
                numhl = {
                    [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
                    [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
                    [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
                    [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint'
                }
            }
        })

        -- C/C++
        vim.lsp.enable('clangd')

        -- bash
        vim.lsp.enable('bashls')
        -- yaml
        vim.lsp.config('yamlls', {
            settings = {
                yaml = {
                    schemaStore = {
                        enable = false,
                        url = 'https://www.schemastore.org/api/json/catalog.json'
                    },
                    schemas = require('schemastore').yaml.schemas(),
                    format = {enable = true}
                }
            }
        })
        vim.lsp.enable('yamlls')

        -- json
        vim.lsp.config('jsonls', {
            commands = {
                Format = {
                    function()
                        vim.lsp.buf.range_formatting({}, {0, 0},
                                                     {vim.fn.line('$'), 0})
                    end
                }
            },
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = {enable = true}
                }
            }
        })
        vim.lsp.enable('jsonls')

        -- eslint
        vim.lsp.enable('eslint')

        -- docker
        vim.lsp.enable('dockerls')

        vim.lsp.enable('docker_compose_language_service')

        -- toml
        vim.lsp.enable('taplo')

        -- kotlin
        vim.lsp.enable('kotlin_language_server')

        -- svelte
        vim.lsp.enable('svelte')

        -- Tailwindcss
        vim.lsp.config('tailwindcss', {
            -- There add every filetype you want tailwind to work on
            filetypes = {
                "css", "scss", "sass", "postcss", "html", "javascript",
                "javascriptreact", "typescript", "typescriptreact", "svelte",
                "vue", "rust"
            },
            settings = {
                tailwindCSS = {
                    emmetCompletions = true,
                    experimental = {classRegex = {"class\\s*:\\s*\"([^\"]*)"}},
                    includeLanguages = {rust = "html"}
                }
            }
        })
        vim.lsp.enable('tailwindcss')

        -- CMake
        vim.lsp.config('neocmake', {init_options = {buildDirectory = "build"}})
        vim.lsp.enable('neocmake')

        -- sql
        vim.lsp.config('sqlls', {
            cmd = {"sql-language-server", "up", "--method", "stdio"}
        })
        vim.lsp.enable('sqlls')

        -- lua
        local lua_runtime = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
        }
        for _, v in pairs(vim.api.nvim_get_runtime_file("", true)) do
            lua_runtime[v] = true
        end

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    format = {
                        enabled = false,
                        defaultConfig = {indent_style = "space"}
                    },
                    runtime = {version = "LuaJIT"},
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {"vim", 'Snacks'},
                        disable = {"inject-field"}
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = lua_runtime,
                        -- stop the annoying message from luassert
                        checkThirdParty = false
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {enable = false}
                }
            }
        })
        vim.lsp.enable('lua_ls')

        vim.lsp.config('wgsl_analyzer', {
            settings = {
                ["wgsl-analyzer.customImports"] = {

                    ["bevy_sprite::mesh2d_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_bindings.wgsl",
                    ["bevy_sprite::mesh2d_functions"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_functions.wgsl",
                    ["bevy_sprite::mesh2d_types"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_types.wgsl",
                    ["bevy_sprite::mesh2d_vertex_output"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_vertex_output.wgsl",
                    ["bevy_sprite::mesh2d_view_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_bindings.wgsl",
                    ["bevy_sprite::mesh2d_view_types"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/mesh2d/mesh2d_view_types.wgsl",
                    ["bevy_sprite::sprite_view_bindings"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_sprite/src/render/sprite_view_bindings.wgsl",
                    ["bevy_ui::ui_vertex_output"] = "https://raw.githubusercontent.com/bevyengine/bevy/refs/tags/v0.15.2/crates/bevy_ui/src/render/ui_vertex_output.wgsl"
                }
            }
        })
        vim.lsp.enable('wgsl_analyzer')

    end,
    keys = {
        -- LSP
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", silent = true },
        { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration", silent = true },
        { "gr", function() Snacks.picker.lsp_references({include_declaration = false}) end, nowait = true, desc = "References", silent = true },
        { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", silent = true },
        { "gt", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition", silent = true },
        { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols", silent = true },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols", silent = true },
        {
            "gw",
            ":vsplit | lua vim.lsp.buf.definition()<CR>",
            mode = {"n"},
            desc = "Go to definition splited",
            silent = true
        },{
            "<M-s>",
            function()
                local blink_window = require 'blink.cmp.completion.windows.menu'
                local blink = require 'blink.cmp'
                -- Close the completion menu first (if open).
                if blink_window.win:is_open() then blink.hide() end
                vim.lsp.buf.signature_help()
            end,
            mode = {"i"},
            desc = "Signature help",
            silent = true
        }, {
            "<M-s>",
            vim.lsp.buf.signature_help,
            mode = {"n"},
            desc = "Signature help",
            silent = true
        }, {
            "K",
            vim.lsp.buf.hover,
            mode = {"n"},
            desc = "Show hover popup or folded preview",
            silent = true
        }, {
            "<M-f>",
            function() vim.lsp.buf.format({async = false}) end,
            mode = {"n"},
            desc = "Format code",
            silent = true
        }, {
            "<leader>la",
            "<cmd>lua vim.lsp.buf.code_action()<CR>",
            desc = "Code Actions",
            noremap = true,
            mode = {"n"}
        }, {
            "<leader>ca",
            "<cmd>lua vim.lsp.buf.code_action()<CR>",
            desc = "Code Actions",
            noremap = true,
            mode = {"n"}
        }, {
            "<leader>lb",
            "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>",
            mode = {"n"},
            desc = "Show line diagnostics",
            noremap = true
        }, {
            "<leader>lc",
            function() vim.b.autoformat = not vim.b.autoformat end,
            mode = {"n"},
            desc = "Toggle autoformat",
            noremap = true
        }, {
            "<leader>lf",
            "<cmd>lua vim.lsp.buf.format({ async = false })<CR>",
            mode = {"n"},
            desc = "Format",
            noremap = true
        }, {
            "<leader>ll",
            "<cmd>lua vim.lsp.codelens.run()<CR>",
            mode = {"n"},
            desc = "Code Lens",
            noremap = true
        }, {
            "<leader>lm",
            "<cmd>lua vim.lsp.buf.rename()<CR>",
            mode = {"n"},
            desc = "Rename symbol",
            noremap = true
        }, {
            "<leader>lq",
            "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>",
            mode = {"n"},
            desc = "Diagnostic set loclist",
            noremap = true
        }, {
            "<leader>la",
            "<cmd>lua vim.lsp.buf.range_code_action()<CR>",
            mode = {"v"},
            desc = "Range Code Action",
            noremap = true
        }, {
            "si",
            "<Cmd>ClangdSwitchSourceHeader<CR>",
            mode = {'n'},
            desc = "Switch Source Header (C/C++)",
            noremap = true,
            silent = true
        }
    }
}
