local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- Normal --

-- Macro
keymap("n", "Q", "q", opts)
-- Spliter window
keymap("n", "[window]", "<Nop>", opts)
keymap("n", "s", "[window]", term_opts)
keymap("n", "[window]b", "<cmd>buffer#<CR>", opts)
keymap("n", "[window]c", "<cmd>close<CR>", opts)
keymap("n", "[window]d", "<cmd>Bdelete<CR>", opts)
keymap("n", "[window]v", "<cmd>split<CR>", opts)
keymap("n", "[window]g", "<cmd>vsplit<CR>", opts)
keymap("n", "[window]t", "<cmd>tabnew<CR>", opts)
keymap("n", "[window]o", "<cmd>only<CR>", opts)
keymap("n", "[window]z", "<cmd>ZoomWinTabToggle<CR>", opts)
keymap("n", "<C-x>", "<C-w>x", opts ) -- Swap index window

-- Quit buffer by q
keymap("n", "q", "<cmd>q<CR>", opts)
-- vim.cmd([[
--   	autocmd BufWinEnter,VimEnter *
-- 		\  if ! maparg('q', 'n')
-- 		\|   nnoremap <buffer> q <cmd>quit<CR>
-- 		\| endif
-- ]])

-- Yank from cusor to end
keymap("n", "Y", "yg$<cmd>echo \"Copied\"<CR>", opts)
keymap("n", "Y", 'yg$<cmd>echo "Copied"<CR>', opts)
-- Jump and focus highlight word
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Toggle Fold
keymap("n", "<CR>", "za", opts)

-- Clear highlight search
keymap("n", "<C-n>", "<cmd>nohl<CR>", term_opts)

-- Navigate buffers
-- keymap("n", "<S-l>", ":bnext<CR>", opts)
-- keymap("n", "<S-h>", ":bprevious<CR>", opts)
-- Navigate Tabs
keymap("n", "<S-l>", ":tabnext<CR>", opts)
keymap("n", "<S-h>", ":tabprev<CR>", opts)

--Easier line-wise movement
keymap("n", "gh", "g^", opts)
keymap("n", "gl", "g$", opts)

-- Move text up and down
keymap("n", "<A-j>", "<cmd>move+<CR>==", opts)
keymap("n", "<A-k>", "<cmd>move-2<CR>==", opts)

-- Double leader key for toggling visual-line mode
-- keymap("n", "<leader><leader>", "V", term_opts)
-- Visual --

-- Double leader key for toggling visual-line mode
keymap("x", "<leader><leader>", "<esc>", term_opts)

-- Stay in indent mode
keymap("v", "<S-Tab>", "<gv", opts)
keymap("v", "<Tab>", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
