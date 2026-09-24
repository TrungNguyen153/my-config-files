-- enables experimental lua loader
vim.loader.enable()

-- default shell, branched per OS
-- Windows host -> Nushell. WSL/Linux -> bash. nu is not on PATH inside WSL Ubuntu
-- by default; using it there breaks every shell-out plugin (toggleterm, conform,
-- rustaceanvim executor, mason installers, gitsigns, snacks find-in-files, etc.).
local is_wsl = vim.fn.has('wsl') == 1
local is_win = vim.fn.has('win32') == 1

if is_win and not is_wsl then
    vim.opt.shell = 'nu'
    vim.opt.shellcmdflag = '-c'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
    vim.opt.shellslash = true
    -- nushell redirection syntax: the Windows defaults (`2>&1| tee`) break :grep and :make
    vim.opt.shellredir = 'out+err> %s'
    vim.opt.shellpipe = 'out+err>| tee { save --force --raw %s }'
else
    vim.opt.shell = 'bash'
    vim.opt.shellcmdflag = '-c'
end

vim.g.mapleader = ' ' -- <leader>
vim.g.maplocalleader = ';' -- <localleader>

-- replace grep with rg
vim.go.grepprg = 'rg --no-heading --vimgrep'
vim.go.grepformat = '%f:%l:%c:%m'

-- size of cmd bar
vim.go.cmdheight = 0
-- You will have bad experience for diagnostic messages when it's default 4000.
-- this is time trigger CursorHold[i] -> Laggy if large text file
vim.go.updatetime = 100

-- Editor settings
vim.g.editorconfig = true
vim.o.autoindent = true
vim.o.timeoutlen = 300 -- http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
vim.o.encoding = 'utf-8'
vim.o.scrolloff = 2
vim.o.showmode = false
vim.o.hidden = true
vim.o.wrap = false
vim.o.joinspaces = false
vim.o.conceallevel = 3
vim.o.concealcursor = 'n'
-- current line will have a background
vim.o.cursorline = true
-- Use a beam cursor in terminal mode (toggleterm "insert"). Neovim's default
-- guicursor maps terminal mode to `t:block`; override to a vertical bar.
-- If it still shows a block, nushell/reedline is forcing the shape -> fix in config.nu.
vim.opt.guicursor:append('t:ver25-blinkon500-blinkoff500-TermCursor')
-- Always draw sign column. Prevent buffer moving when adding/deleting sign.
vim.o.signcolumn = 'yes'
vim.o.numberwidth = 1

-- folding
vim.o.foldenable = true -- Enable folding.
vim.o.foldcolumn = '1' -- Show folding signs.
-- vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Use treesitter for folding.
vim.o.foldlevel = 999 -- Open all folds.
vim.o.foldlevelstart = 99 -- Start with all folds closed.
vim.o.foldmethod = 'expr' -- Use expr to determine fold level.
vim.o.foldopen = 'insert,mark,search,tag' -- Which commands open folds if the cursor moves into a closed fold.
vim.o.foldtext = 'v:lua.custom_fold_text()' -- What to display on fold
-- views (mkview/loadview autocmds) keep folds and the cursor/scroll position, but not
-- the window's directory; the LastPlace autocmd covers files that have no view yet
vim.o.viewoptions = 'folds,cursor'
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
vim.o.undodir = vim.fn.stdpath('data') .. '/.vimdid'
vim.o.undofile = true

-- Decent wildmenu
vim.o.wildmenu = true
vim.o.wildmode = 'list:longest'
vim.o.wildignore =
    '.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor,*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite'

-- Use wide tabs
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
-- expandtab will make neovim overwrite those tab above when enter buffer
vim.o.expandtab = true

-- Backspace over newline
vim.o.backspace = 'indent,eol,start'

-- Wrapping options
-- t -> wrap text using textwidth
-- c -> wrap comments using textwidth
-- r -> continue comments when pressing ENTER in I mode
-- q -> enable formatting of comments with gq
-- n -> detect lists for formatting
-- b -> auto-wrap in insert mode, and do not wrap old long lines
vim.o.formatoptions = 'tcrqnb'

-- Proper search
vim.o.incsearch = true
vim.o.inccommand = 'split'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

-- Abbreviations for typos. They expand only when the : command line is the
-- abbreviation (after an optional range, as in :'<,'>W), so a W inside a :s
-- pattern or a :grep argument stays a W.
local cmd_abbrevs = {
    ['W!'] = 'w!',
    W1 = 'w!',
    w1 = 'w!',
    ['Q!'] = 'q!',
    Q1 = 'q!',
    q1 = 'q!',
    ['Qa!'] = 'qa!',
    ['Qall!'] = 'qall!',
    Wa = 'wa',
    Wq = 'wq',
    wQ = 'wq',
    WQ = 'wq',
    wq1 = 'wq!',
    Wq1 = 'wq!',
    wQ1 = 'wq!',
    WQ1 = 'wq!',
    W = 'w',
    Q = 'q',
    Qa = 'qa',
    Qall = 'qall',
    vr = 'Vr',
    hr = 'Hr',
}
for lhs, rhs in pairs(cmd_abbrevs) do
    vim.keymap.set('ca', lhs, function()
        local cmd = vim.fn.getcmdline():gsub("^[%s%d%.%$%%,;'<>+%-]*", '') -- drop a leading range
        return (vim.fn.getcmdtype() == ':' and cmd == lhs) and rhs or lhs
    end, { expr = true })
end

-- No whitespace in vimdiff
vim.o.diffopt = vim.o.diffopt .. ',iwhite'
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.o.diffopt = vim.o.diffopt .. ',algorithm:patience'
vim.o.diffopt = vim.o.diffopt .. ',indent-heuristic'
-- https://github.com/neovim/neovim/pull/14537
vim.o.diffopt = vim.o.diffopt .. ',linematch:50'

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
vim.o.shortmess = 'IOocWTtFxnflCi'

-- Files changed outside of Neovim still reload automatically, through the
-- FileChangedShell autocmd in utils/autocommands.lua. 'autoread' stays off because
-- its silent reload keeps the old 'fileformat' (^M after a CRLF rewrite).
vim.o.autoread = false

-- Show those damn hidden characters
-- Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
vim.o.listchars = 'tab: >,nbsp:¬,extends:»,precedes:«,trail:•'

-- Show problematic characters.
vim.o.list = true

-- Stabilize the cursor position when creating/deleting horizontal splits
vim.o.splitkeep = 'topline'

-- disable legacy perl provider
vim.g.loaded_perl_provider = false

-- don't create swap files because it is very annoying
vim.o.swapfile = false

-- Disable <C-c> effect on sql file
vim.g.ftplugin_sql_omni_key = '<C-p>'
