if vim.g.neovide then
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    vim.g.neovide_text_gamma = 0.01
    vim.g.neovide_text_contrast = 0.01

    vim.g.neovide_scroll_animation_far_lines = 9999

    vim.g.neovide_hide_mouse_when_typing = false

    vim.g.neovide_floating_shadow = true
    vim.g.neovide_refresh_rate = 240
    -- Match idle rate to refresh rate — Neovide defaults to 5 fps when idle,
    -- which causes a 1–2s stall on the next UI event (e.g. <C-h/j/k/l>)
    -- while the GPU/compositor wakes up.
    vim.g.neovide_refresh_rate_idle = 120
    vim.g.neovide_confirm_quit = true
    vim.g.neovide_cursor_animation_length = 0.13
    vim.g.neovide_scroll_animation_length = 0.3
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.opt.linespace = 7

    -- Combo for macos
    vim.g.neovide_opacity = 1.0
    vim.g.neovide_floating_blur_amount_x = 6.0
    vim.g.neovide_floating_blur_amount_y = 6.0
    vim.g.neovide_transparency_point = 0.75
    vim.g.neovide_normal_opacity = 1.0
    vim.g.transparency = 0
    vim.g.neovide_window_blurred = true

    vim.g.neovide_floating_corner_radius = 2.0

    vim.keymap.set('v', '<C-S-c>', '"+y') -- Copy
    vim.keymap.set('n', '<C-S-v>', '"+p') -- Paste normal mode
    vim.keymap.set('v', '<C-S-v>', '"+P') -- Paste visual mode
    vim.keymap.set('c', '<C-S-v>', '<C-r>*') -- Paste command mode
    vim.keymap.set('i', '<C-S-v>', function()
        vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
    end, { noremap = true, silent = true }) -- Paste insert mode
    vim.keymap.set('t', '<C-S-v>', '<C-\\><C-n>"+Pi') -- Paste in terminal mode

    -- zoom setting
    vim.g.neovide_scale_factor = 0.8
    vim.api.nvim_set_keymap(
        'n',
        '<C-=>',
        ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>',
        { silent = true }
    )
    vim.api.nvim_set_keymap(
        'n',
        '<C-->',
        ':lua vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor - 0.1,  0.1)<CR>',
        { silent = true }
    )
    vim.api.nvim_set_keymap(
        'n',
        '<C-+>',
        ':lua vim.g.neovide_opacity = math.min(vim.g.neovide_opacity + 0.05, 1.0)<CR>',
        { silent = true }
    )
    vim.api.nvim_set_keymap(
        'n',
        '<C-_>',
        ':lua vim.g.neovide_opacity = math.max(vim.g.neovide_opacity - 0.05, 0.0)<CR>',
        { silent = true }
    )
    vim.api.nvim_set_keymap('n', '<C-0>', ':lua vim.g.neovide_scale_factor = 1.0<CR>', { silent = true })
    vim.api.nvim_set_keymap('n', '<C-)>', ':lua vim.g.neovide_opacity = 0.9<CR>', { silent = true })

    -- Toggle neovide window frame (full <-> none). Neovide hot-reloads config.toml,
    -- but `frame` is applied at startup, so the chrome change shows on next launch.
    local function neovide_config_path()
        if vim.fn.has('win32') == 1 then
            return vim.fn.expand('$APPDATA') .. '/neovide/config.toml'
        end
        local xdg = os.getenv('XDG_CONFIG_HOME') or vim.fn.expand('~/.config')
        return xdg .. '/neovide/config.toml'
    end

    local function toggle_neovide_frame()
        local path = neovide_config_path()
        local lines = vim.fn.readfile(path)
        local new_value
        for i, line in ipairs(lines) do
            local pre, val, post = line:match('^(%s*frame%s*=%s*")([^"]+)(".*)$')
            if pre then
                new_value = (val == 'full') and 'none' or 'full'
                lines[i] = pre .. new_value .. post
                break
            end
        end
        if not new_value then
            vim.notify('No frame = "..." line in ' .. path, vim.log.levels.WARN)
            return
        end
        vim.fn.writefile(lines, path)
        vim.notify('Neovide frame -> ' .. new_value .. ' (restart to apply)', vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command('NeovideToggleFrame', toggle_neovide_frame, {})
    vim.keymap.set('n', '<leader>vf', toggle_neovide_frame, { silent = true, desc = 'Neovide: toggle frame' })
end
