vim.o.termguicolors = true

-- Remove toolbar
-- lua api seems to not be able to access this option
vim.cmd("set guioptions-=T")

vim.o.background = "dark"
-- No more beeps
vim.o.vb = true
vim.o.synmaxcol = 500
vim.o.laststatus = 2
-- Relative line numbers
vim.o.relativenumber = true
-- Also show current absolute line
vim.o.number = true
-- Show (partial) command in status line.
vim.o.showcmd = true
-- Enable mouse usage (all modes) in terminals
vim.o.mouse = "a"

-- Create a new highlight group for unwanted whitespaces or tabs
-- vim.cmd('highlight ExtraWhitespace ctermbg=lightyellow guibg=lightyellow')

vim.cmd("syntax on")
vim.cmd("hi Normal ctermbg=NONE")
