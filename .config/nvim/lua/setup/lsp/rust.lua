
return {
  setup = function(capabilities, on_attach)
    -- Cargo.toml
    require("crates").setup({
      null_ls = {
        enabled = true,
      },
    })
    require("dap").adapters.codelldb = {
			type = 'server',
			host = '127.0.0.1',
			port = 13000,
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
				args = {"--port", "13000"},

				-- on windows you may have to uncomment this:
				-- detached = false,
			},
		}
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
              -- inlayHints = {
              --   enable = true,
              --   bindingModeHints = { enable = false },
              --   chainingHints = { enable = true },
              --   closingBraceHints = {
              --     enable = true,
              --     minLines = 10,
              --   },
              --   closureReturnTypeHints = { enable = "with_block" },
              --   lifetimeElisionHints = { enable = "skip_trivial" },
              --   discriminantHints = {
              --     enable = "fieldless",
              --   },
              --   typeHints = { enable = true, hideClosureInitialization = false },
              --   implicitDrops = { enable = false },
              -- },
              check = {
                enable = true,
                -- command = "clippy",
              },
              checkOnSave = true,
            },
          },
        },
    }
  end,
}