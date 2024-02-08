
return {
  setup = function(capabilities, on_attach)
    -- Cargo.toml
    require("crates").setup({
      null_ls = {
        enabled = true,
      },
    })
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
              -- cachePriming = {
              --   enable = false,
              --   numThreads = 2,
              -- },
              -- server = {
              --   extraEnv = {
              --     RUSTUP_TOOLCHAIN = "stable",
              --   },
              -- },
              -- diagnostics = {
              --   enable = true,
              --   -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
              --   disabled = { "unresolved-macro-call", "unresolved-proc-macro", "macro-error" },
              --   experimental = { enable = true },
              --   enableExperimental = true,
              -- },
              -- completion = {
              --   autoself = { enable = true },
              --   autoimport = { enable = true },
              --   postfix = { enable = true },
              -- },
              -- imports = {
              --   group = { enable = true },
              --   merge = { glob = false },
              --   prefix = "self",
              --   granularity = {
              --     enforce = true,
              --     group = "crate",
              --   },
              -- },
              -- cargo = {
              --   loadOutDirsFromCheck = true,
              --   autoreload = true,
              --   runBuildScripts = true,
              --   -- https://github.com/rust-lang/rust-analyzer/issues/13400
              --   -- target = 'x86_64-pc-windows-msvc',
              -- },
              -- procMacro = {
              --   enable = true,
              --   attributes = { enable = true },
              -- },
              -- lens = {
              --   enable = true,
              --   run = { enable = true },
              --   debug = { enable = true },
              --   implementations = { enable = true },
              --   references = {
              --     adt = { enable = true },
              --     enumVariant = { enable = true },
              --     method = { enable = true },
              --     trait = { enable = true },
              --   },
              -- },
              -- hover = {
              --   actions = {
              --     enable = true,
              --     run = { enable = true },
              --     debug = { enable = true },
              --     gotoTypeDef = { enable = true },
              --     implementations = { enable = true },
              --     references = { enable = true },
              --   },
              --   links = { enable = true },
              --   documentation = { enable = true },
              -- },
              inlayHints = {
                enable = true,
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = {
                  enable = true,
                  minLines = 10,
                },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial" },
                discriminantHints = {
                  enable = "fieldless",
                },
                typeHints = { enable = true, hideClosureInitialization = false },
                implicitDrops = { enable = true },
              },
              -- check = {
              --   enable = true,
              --   -- command = "clippy",
              -- },
              -- checkOnSave = false,
            },
          },
        },
    }
  end,
}