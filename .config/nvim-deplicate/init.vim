" Enables 24-bit RGB color in the terminal
if has('termguicolors')
	if empty($COLORTERM) || $COLORTERM =~# 'truecolor\|24bit'
		set termguicolors
	endif
endif

if ! has('nvim')
	set t_Co=256
	" Set Vim-specific sequences for RGB colors
	" Fixes 'termguicolors' usage in vim+tmux
	" :h xterm-true-color
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

augroup user_events
	autocmd!
augroup END


execute 'source' fnamemodify(expand('<sfile>'), ':h').'/config/vimrc'




