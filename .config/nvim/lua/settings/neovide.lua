vim.g.neovide_no_idle = true
vim.g.neovide_input_use_logo = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_transparency = 1
vim.g.neovide_theme = 'dark'
vim.g.neovide_refresh_rate = 144
vim.g.neovide_cursor_animation_length = 0.03
vim.g.neovide_cursor_trail_size = 0.9
vim.g.neovide_remember_window_size = true
vim.g.neovide_remember_window_position = true
vim.g.neovide_floating_shadow = false
if vim.g.neovide then
    vim.keymap.set('v', '<C-S-c>', '"*y') -- Copy
    vim.keymap.set('n', '<C-S-v>', '"*p') -- Paste normal mode
    vim.keymap.set('v', '<C-S-v>', '"*p') -- Paste visual mode
    vim.keymap.set('c', '<C-S-v>', '<C-r>*') -- Paste command mode
    vim.keymap.set('t', '<C-S-v>', '<C-r>*') -- Paste in terminal mode
    vim.keymap.set('i', '<C-S-v>', '<C-r>*') -- Paste insert mode
end