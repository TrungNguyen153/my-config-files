return {
  'hrsh7th/nvim-cmp', -- auto completion
  event = "UIEnter",
  enabled = not vim.g.vscode,
  config = require('setup.cmp').setup,
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets', -- snippets for many languages
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-cmdline',
    -- { 'tzachar/cmp-tabnine', build = './install.sh' }, -- unix
    -- { 'tzachar/cmp-tabnine', build = 'powershell ./install.ps1' }, -- windows
    'windwp/nvim-autopairs', -- helps with auto closing blocks
    { 'Saecki/crates.nvim', dependencies = { 'nvim-lua/plenary.nvim' } }, -- auto complete for Cargo.toml
    'onsails/lspkind-nvim', -- show pictograms in the auto complete popup
    'hrsh7th/cmp-nvim-lsp-document-symbol',
    'b0o/schemastore.nvim', -- adds schemas for json lsp
    "luckasRanarison/tailwind-tools.nvim",
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'rcarriga/cmp-dap',     -- auto completion for the REPL in DAP. to check if dap client supports it: :lua= require("dap").session().capabilities.supportsCompletionsRequest
    -- {
    --   'zbirenbaum/copilot-cmp',
    --   dependencies = { 'zbirenbaum/copilot.lua' },
    -- },
    -- use({ 'github/copilot.vim' }), -- before first time using the lua version, this has to be installed and then run :Copilot to setup. Uninstall afterwards
    -- { "Exafunction/codeium.nvim",
    --   dependencies = { 'nvim-lua/plenary.nvim' },
    --   config = function()
    --     require("codeium").setup({
    --       config_path = "D:\\ai-completions\\codeium\\config",
    --       bin_path = "D:\\ai-completions\\codeium",
    --       tools = {
    --         language_server = "D:\\ai-completions\\codeium\\1.6.7\\language_server_windows_x64.exe",
    --         gzip = "powershell.exe",
    --         curl = "C:\\Windows\\system32\\curl.exe",
    --       }
    --     })
    --     end
    -- }
  },
}
