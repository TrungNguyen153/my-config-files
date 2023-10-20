return {
  {
    "williamboman/mason.nvim", -- lsp server installer
    config = function()
      require("mason").setup()
    end,
    dependencies = { "williamboman/mason-lspconfig.nvim", "WhoIsSethDaniel/mason-tool-installer.nvim" },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("setup.lsp")
      local conf = lspconfig.setup()
      lspconfig.config_defaults()
      require("setup.lsp.lua").setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
      require("setup.lsp.typescript").setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
    end,
  }, -- collection of LSP configurations for nvim
  {
    "stevearc/aerial.nvim",
    config = require("setup.lsp.aerial").setup,
  }, -- show symbol tree in the current buffer
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = "ThePrimeagen/refactoring.nvim", -- refactoring library used by null-ls
    config = function()
      local lspconfig = require("setup.lsp")
      require("setup.lsp.null-ls").setup(lspconfig.on_attach)
    end,
  }, -- can be ful to integrate with non LSP sources like eslint
  "jose-elias-alvarez/nvim-lsp-ts-utils", -- improve typescript
  { "ray-x/lsp_signature.nvim", dependencies = "nvim-lspconfig", config = require("setup.lsp_signature").setup }, -- show signature from methods as float windows
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java", "gradle" },
    config = function()
      local lspconfig = require("setup.lsp")
      require("setup.lsp.java").setup(lspconfig.capabilities(), lspconfig.on_attach)
    end,
  }, -- java enhancements
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    config = function()
      local lspconfig = require("setup.lsp")
      require("setup.lsp.rust").setup(lspconfig.capabilities(), lspconfig.on_attach)
    end,
  }, -- rust enhancements
  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    config = function()
      local lspconfig = require("setup.lsp")
      require("setup.lsp.flutter-tools").setup(lspconfig.capabilities(), lspconfig.on_attach)
    end,
  },
}