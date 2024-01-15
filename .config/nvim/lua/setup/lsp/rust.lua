
return {
  setup = function(capabilities, on_attach)

    -- local mason_registry = require("mason-registry")
    -- local codelldb = mason_registry.get_package("codelldb")
    -- local extension_path = codelldb:get_install_path()
    -- local codelldb_path = extension_path .. "\\extension\\adapter\\codelldb.exe"
    -- local liblldb_path = extension_path .. "\\extension\\lldb\\bin\\liblldb.dll"
    -- require("rust-tools").setup({
    --   tools = {
    --     executor = require("rust-tools.executors").termopen,
    --     inlay_hints = {
    --       auto = true,
    --       only_current_line = false,
    --       show_parameter_hints = true,
    --       parameter_hints_prefix = "◂ ",
    --       other_hints_prefix = "▸ ",
    --       max_len_align = false,
    --       max_len_align_padding = 1,
    --       right_align = false,
    --       right_align_padding = 7,
    --       highlight = "Comment",
    --     },
    --     reload_workspace_from_cargo_toml = true,
    --     hover_actions = { auto_focus = true, border = "rounded", },
    --   },
    --   dap = {
    --     adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
    --   },
    --   server = {
    --     on_attach = on_attach,
    --     capabilities = capabilities,
    --     standalone = false,
    --     settings = {
    --       ["rust-analyzer"] = {
    --         diagnostics = {
    --           enable = true,
    --           -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
    --           disabled = { "unresolved-macro-call" },
    --           experimental = { enable = true },
    --           enableExperimental = true,
    --         },
    --         completion = {
    --           autoself = { enable = true },
    --           autoimport = { enable = true },
    --           postfix = { enable = true },
    --         },
    --         imports = {
    --           group = { enable = true },
    --           merge = { glob = false },
    --           prefix = "self",
    --           granularity = {
    --             enforce = true,
    --             group = "crate",
    --           },
    --         },
    --         cargo = {
    --           autoreload = true,
    --           buildScripts = { enable = true },
    --           features = '', -- so just use special feature "all"
    --           -- https://github.com/rust-lang/rust-analyzer/issues/13400
    --           -- target = 'aarch64-apple-darwin',
    --         },
    --         procMacro = {
    --           enable = true,
    --           attributes = { enable = true },
    --         },
    --         lens = {
    --           enable = true,
    --           run = { enable = true },
    --           debug = { enable = true },
    --           implementations = { enable = true },
    --           references = {
    --             adt = { enable = true },
    --             enumVariant = { enable = true },
    --             method = { enable = true },
    --             trait = { enable = true },
    --           },
    --         },
    --         hover = {
    --           actions = {
    --             enable = true,
    --             run = { enable = true },
    --             debug = { enable = true },
    --             gotoTypeDef = { enable = true },
    --             implementations = { enable = true },
    --             references = { enable = true },
    --           },
    --           links = { enable = true },
    --           documentation = { enable = true },
    --         },
    --         inlayHints = {
    --           enable = true,
    --           bindingModeHints = { enable = true },
    --           chainingHints = { enable = true },
    --           closingBraceHints = {
    --             enable = true,
    --             minLines = 0,
    --           },
    --           closureReturnTypeHints = { enable = "always" },
    --           lifetimeElisionHints = { enable = "skip_trivial" },
    --           typeHints = { enable = true },
    --         },
    --         checkOnSave = {
    --           enable = true,
    --           -- https://github.com/rust-analyzer/rust-analyzer/issues/9768
    --           command = "clippy",
    --           -- features = "all",
    --           -- allTargets = true,
    --         },
    --       },
    --     },
    --   },
    -- })

    vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
          reload_workspace_from_cargo_toml = true,
        },
        -- LSP configuration
        server = {
          -- auto_attach = false,
          on_attach = on_attach,
          capabilities = capabilities,
          standalone = false,
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
                -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                disabled = { "unresolved-macro-call", "unresolved-proc-macro", "macro-error" },
                experimental = { enable = true },
                enableExperimental = true,
              },
              completion = {
                autoself = { enable = true },
                autoimport = { enable = true },
                postfix = { enable = true },
              },
              imports = {
                group = { enable = true },
                merge = { glob = false },
                prefix = "self",
                granularity = {
                  enforce = true,
                  group = "crate",
                },
              },
              cargo = {
                autoreload = true,
                buildScripts = { enable = true },
                features = '', -- so just use special feature "all"
                -- https://github.com/rust-lang/rust-analyzer/issues/13400
                -- target = 'aarch64-apple-darwin',
              },
              procMacro = {
                enable = true,
                attributes = { enable = true },
              },
              lens = {
                enable = true,
                run = { enable = true },
                debug = { enable = true },
                implementations = { enable = true },
                references = {
                  adt = { enable = true },
                  enumVariant = { enable = true },
                  method = { enable = true },
                  trait = { enable = true },
                },
              },
              hover = {
                actions = {
                  enable = true,
                  run = { enable = true },
                  debug = { enable = true },
                  gotoTypeDef = { enable = true },
                  implementations = { enable = true },
                  references = { enable = true },
                },
                links = { enable = true },
                documentation = { enable = true },
              },
              inlayHints = {
                enable = true,
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = {
                  enable = true,
                  minLines = 0,
                },
                closureReturnTypeHints = { enable = "always" },
                lifetimeElisionHints = { enable = "skip_trivial" },
                typeHints = { enable = true },
              },
              check = {
                enable = true,
                -- https://github.com/rust-analyzer/rust-analyzer/issues/9768
                command = "clippy",
              },
            },
          },
        },
    }

    -- Cargo.toml
    require("crates").setup({
      null_ls = {
        enabled = true,
      },
    })
  end,
}