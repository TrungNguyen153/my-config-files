
return {
  setup = function(capabilities, on_attach)
    vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
        },
        -- LSP configuration
        server = {
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
                -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                disabled = { "unresolved-macro-call", "unresolved-proc-macro" },
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