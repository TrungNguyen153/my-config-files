vim.g.neovide_no_idle = true
vim.g.neovide_input_use_logo = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_opacity = 1
vim.g.neovide_theme = "dark"
vim.g.neovide_refresh_rate = 144
vim.g.neovide_cursor_animation_length = 0.03
vim.g.neovide_cursor_trail_size = 0.9
-- false for alway full size
vim.g.neovide_remember_window_size = false
vim.g.neovide_remember_window_position = false
vim.g.neovide_floating_shadow = false
vim.g.neovide_floating_corner_radius = 0.5
if vim.g.neovide then
    -- vim.keymap.set('v', '<C-S-c>', '"*y') -- Copy
    -- vim.keymap.set('n', '<C-S-v>', '"*p') -- Paste normal mode
    -- vim.keymap.set('v', '<C-S-v>', '"*p') -- Paste visual mode
    -- vim.keymap.set('c', '<C-S-v>', '<C-r>*') -- Paste command mode
    -- vim.keymap.set('t', '<C-S-v>', '<C-r>*') -- Paste in terminal mode
    -- vim.keymap.set('i', '<C-S-v>', '<C-r>*') -- Paste insert mode

    vim.keymap.set('v', '<C-S-c>', '"+y')       -- Copy
	vim.keymap.set('n', '<C-S-v>', '"+p')      -- Paste normal mode
	vim.keymap.set('v', '<C-S-v>', '"+P')       -- Paste visual mode
	vim.keymap.set('c', '<C-S-v>', '<C-r>*')    -- Paste command mode
	vim.keymap.set('i', '<C-S-v>', function()
        vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
    end, { noremap = true, silent = true })    -- Paste insert mode
	vim.keymap.set('t', '<C-S-v>', '<C-\\><C-n>"+Pi')   -- Paste in terminal mode

    -- zoom setting
    vim.api.nvim_set_keymap("n", "<C-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", { silent = true })
    vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor - 0.1,  0.1)<CR>", { silent = true })
    vim.api.nvim_set_keymap("n", "<C-+>", ":lua vim.g.neovide_opacity = math.min(vim.g.neovide_opacity + 0.05, 1.0)<CR>", { silent = true })
    vim.api.nvim_set_keymap("n", "<C-_>", ":lua vim.g.neovide_opacity = math.max(vim.g.neovide_opacity - 0.05, 0.0)<CR>", { silent = true })
    vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1.0<CR>", { silent = true })
    vim.api.nvim_set_keymap("n", "<C-)>", ":lua vim.g.neovide_opacity = 0.9<CR>", { silent = true })
end
