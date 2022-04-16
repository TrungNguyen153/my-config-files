-- you can configure Hop the way you like here; see :h hop-config
require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
vim.api.nvim_set_keymap("n", "ss", "<cmd>HopChar2<CR>", { noremap = false })
