-- enables experimental lua loader
vim.loader.enable()

-- default shell
local powershell_options = {
	-- shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
	-- shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
	-- shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
	-- shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
	-- shellquote = "",
	-- shellxquote = "",

	-- This for NuShell
	shell = "nu",
	shellcmdflag = "-c",
	shellquote = "",
	shellxquote = "",
	shellslash = true,
}
for option, value in pairs(powershell_options) do
	vim.opt[option] = value
end

vim.g.mapleader = " "      -- <leader>
vim.g.maplocalleader = ";" -- <localleader>

-- clipboard
vim.go.clipboard = "unnamedplus"

-- secure modelines
vim.g.secure_modelines_allowed_items = {
	"textwidth",
	"tw",
	"softtabstop",
	"sts",
	"tabstop",
	"ts",
	"shiftwidth",
	"sw",
	"expandtab",
	"et",
	"noexpandtab",
	"noet",
	"filetype",
	"ft",
	"foldmethod",
	"fdm",
	"readonly",
	"ro",
	"noreadonly",
	"noro",
	"rightleft",
	"rl",
	"norightleft",
	"norl",
	"colorcolumn",
}

-- replace grep with rg
vim.go.grepprg = "rg --no-heading --vimgrep"
vim.go.grepformat = "%f:%l:%c:%m"

-- Don't confirm .lvimrc
vim.g.localvimrc_ask = 0

-- size of cmd bar
vim.go.cmdheight = 0
-- You will have bad experience for diagnostic messages when it's default 4000.
-- this is time trigger CursorHold[i] -> Laggy if large text file
vim.go.updatetime = 666

-- Editor settings
vim.g.editorconfig = true
vim.o.autoindent = true
vim.o.timeoutlen = 300 -- http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
vim.o.encoding = "utf-8"
vim.o.scrolloff = 2
vim.o.showmode = false
vim.o.hidden = true
vim.o.wrap = false
vim.o.joinspaces = false
vim.o.conceallevel = 0
vim.o.concealcursor = "n"
-- current line will have a background
vim.o.cursorline = true
-- Always draw sign column. Prevent buffer moving when adding/deleting sign.
vim.o.signcolumn = "yes"
vim.o.numberwidth = 1

-- folding
vim.o.foldenable = true                            -- Enable folding.
vim.o.foldcolumn = '1'                             -- Show folding signs.
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Use treesitter for folding.
vim.o.foldlevel = 999                              -- Open all folds.
vim.o.foldlevelstart = 99                          -- Start with all folds closed.
vim.o.foldmethod = 'expr'                          -- Use expr to determine fold level.
vim.o.foldopen = 'insert,mark,search,tag'          -- Which commands open folds if the cursor moves into a closed fold.
vim.o.foldtext = 'v:lua.custom_fold_text()'        -- What to display on fold
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Settings needed for .lvimrc
vim.o.exrc = true
vim.o.secure = true

-- Sane splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Permanent undo
--[[ vim.o.undodir = os.getenv('HOME') .. '/.vimdid' ]]
-- for not windows
vim.o.undodir = vim.fn.stdpath("data") .. "/.vimdid"
vim.o.undofile = true

-- Decent wildmenu
vim.o.wildmenu = true
vim.o.wildmode = "list:longest"
vim.o.wildignore =
".hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor,*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite"

-- Use wide tabs
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 2
-- expandtab will make neovim overwrite those tab above when enter buffer
vim.o.expandtab = false

-- Backspace over newline
vim.o.backspace = "indent,eol,start"

-- Wrapping options
vim.o.formatoptions = "tc"                       -- wrap text and comments using textwidth
vim.o.formatoptions = vim.o.formatoptions .. "r" -- continue comments when pressing ENTER in I mode
vim.o.formatoptions = vim.o.formatoptions .. "q" -- enable formatting of comments with gq
vim.o.formatoptions = vim.o.formatoptions .. "n" -- detect lists for formatting
vim.o.formatoptions = vim.o.formatoptions .. "b" -- auto-wrap in insert mode, and do not wrap old long lines

-- Proper search
vim.o.incsearch = true
vim.o.inccommand = "split"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

-- Abbreviations
vim.cmd([[
cnoreabbrev W! w!
cnoreabbrev W1 w!
cnoreabbrev w1 w!
cnoreabbrev Q! q!
cnoreabbrev Q1 q!
cnoreabbrev q1 q!
cnoreabbrev Qa! qa!
cnoreabbrev Qall! qall!
cnoreabbrev Wa wa
cnoreabbrev Wq wq
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev wq1 wq!
cnoreabbrev Wq1 wq!
cnoreabbrev wQ1 wq!
cnoreabbrev WQ1 wq!
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev Qall qall
cnoreabbrev vr Vr
cnoreabbrev hr Hr
]])

-- No whitespace in vimdiff
vim.o.diffopt = vim.o.diffopt .. ",iwhite"
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.o.diffopt = vim.o.diffopt .. ",algorithm:patience"
vim.o.diffopt = vim.o.diffopt .. ",indent-heuristic"
-- https://github.com/neovim/neovim/pull/14537
vim.o.diffopt = vim.o.diffopt .. ",linematch:50"

-- shortmess
-- I -> don't show intro message
-- O -> file-read message overwrites previous
-- o -> file-read message
-- c -> completion messages
-- W -> don't show [w] or written when writing
-- T -> truncate file messages at start
-- t -> truncate file messages in middle
-- F -> don't give file info when editing a file
-- x -> do not show [+] or [-] when lines are added/deleted
-- n -> no swap file
-- l -> use internal grep
-- C -> do not give |ins-completion-menu| messages
-- i -> case insensitive search
vim.o.shortmess = "IOocWTtFxnflCi"

-- automatic reload file on buffer changed outside of vim
vim.o.autoread = true

-- Show those damn hidden characters
-- Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
vim.o.listchars = "tab: >,nbsp:¬,extends:»,precedes:«,trail:•"

-- Show problematic characters.
vim.o.list = true

-- Stabilize the cursor position when creating/deleting horizontal splits
vim.o.splitkeep = "topline"

-- enable autoformat when saving. it is set for each buffer when lsp is attached
vim.g.autoformat = true

-- disable legacy perl provider
vim.g.loaded_perl_provider = false

-- don't create swap files because it is very annoying
vim.o.swapfile = false

-- Disable <C-c> effect on sql file
vim.g.ftplugin_sql_omni_key = '<C-p>'

