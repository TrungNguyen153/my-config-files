if vim.g.neovide then
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    vim.g.neovide_text_gamma = 0.01
    vim.g.neovide_text_contrast = 0.01
  
    vim.g.neovide_scale_factor = 1.0
    vim.g.neovide_hide_mouse_when_typing = true
  
    vim.g.neovide_floating_shadow = false
    vim.g.neovide_scroll_animation_length = 0.15
    vim.g.neovide_refresh_rate = 120
    vim.g.neovide_confirm_quit = false
    vim.g.neovide_cursor_animation_length = 0.05
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.opt.linespace = 7

    vim.g.neovide_opacity = 0.95
    vim.g.neovide_transparency_point = 0.75
    vim.g.neovide_normal_opacity = 0.85

    vim.g.transparency = 0

    vim.g.neovide_window_blurred = true
    vim.g.neovide_floating_corner_radius = 0.2



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
