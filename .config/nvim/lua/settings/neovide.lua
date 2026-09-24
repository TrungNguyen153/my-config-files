if not (vim.g.neovide or vim.env.NEOVIDE_UI) then
    return
end

-- font
-- vim.o.guifont = "CaskaydiaMono_Nerd_Font,Noto_Color_Emoji,Sarasa_Fixed_SC:h12"
-- 中文 😀 😎

-- dynamic scaling
vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
end
vim.keymap.set('n', '<C-=>', function()
    change_scale_factor(0.1)
end)
vim.keymap.set('n', '<C-->', function()
    change_scale_factor(-0.1)
end)
vim.keymap.set('n', '<C-0>', function()
    vim.g.neovide_scale_factor = 1.0
end)

-- padding
vim.g.neovide_padding_top = 0
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_left = 0
vim.g.neovide_padding_right = 0

-- dynamic colorscheme
vim.g.neovide_theme = 'auto'

-- title bar
vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Update Neovide colors on colorscheme change',
    callback = function()
        vim.g.neovide_title_background_color =
            string.format('%x', vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name('Normal') }).bg)

        vim.g.neovide_title_text_color =
            string.format('%x', vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name('Normal') }).fg)
    end,
})

-- floating
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

vim.g.neovide_floating_shadow = false
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

vim.g.neovide_floating_corner_radius = 0
vim.g.neovide_experimental_layer_grouping = true

-- transparency
vim.g.neovide_opacity = 1
vim.g.neovide_normal_opacity = 1
local change_opacity = function(delta)
    vim.g.neovide_normal_opacity = math.min(math.max(vim.g.neovide_normal_opacity + delta, 0.1), 1)
    -- vim.g.neovide_normal_opacity = vim.g.neovide_opacity
end
vim.keymap.set({ 'n', 'v', 'o' }, '<M-]>', function()
    change_opacity(0.05)
end)
vim.keymap.set({ 'n', 'v', 'o' }, '<M-[>', function()
    change_opacity(-0.05)
end)

-- animations
vim.g.neovide_position_animation_length = 0.15
vim.g.neovide_scroll_animation_length = 0.3
vim.g.neovide_scroll_animation_far_lines = 1

-- progress
vim.g.neovide_progress_bar_enabled = true
vim.g.neovide_progress_bar_height = 5.0
vim.g.neovide_progress_bar_animation_speed = 200.0
vim.g.neovide_progress_bar_hide_delay = 0.2

-- misc
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_refresh_rate = 240 -- Base on Monitor
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_confirm_quit = true
vim.api.nvim_create_user_command('Neovide', function(opts)
    local arg = opts.args:lower()
    if arg == 'profile' then
        vim.g.neovide_profiler = not vim.g.neovide_profiler
    elseif arg == 'fullscreen' then
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
    else
        print('Unknown argument: ' .. opts.args)
    end
end, {
    nargs = 1,
    complete = function()
        return { 'fullscreen', 'profile' }
    end,
    desc = 'Toggle Neovide features',
})

-- macos only
vim.g.neovide_highlight_matching_pair = true
vim.g.neovide_proxy_icon = true
vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

-- cursor
vim.g.neovide_cursor_smooth_blink = true
vim.g.neovide_cursor_animation_length = 0.150
vim.g.neovide_cursor_short_animation_length = 0.04
vim.g.neovide_cursor_trail_size = 1.0
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_cursor_unfocused_outline_width = 0.125
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait300-blinkoff200-blinkon1000'
vim.opt.guicursor:append('t:ver25-blinkon500-blinkoff500-TermCursor') -- keep general.lua's terminal-mode beam

-- Pasting
vim.keymap.set('v', '<C-S-c>', '"+y') -- Copy
vim.keymap.set('n', '<C-S-v>', '"+p') -- Paste normal mode
vim.keymap.set('v', '<C-S-v>', '"+P') -- Paste visual mode
vim.keymap.set('c', '<C-S-v>', '<C-r>*') -- Paste command mode
vim.keymap.set('i', '<C-S-v>', function()
    vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
end, { noremap = true, silent = true }) -- Paste insert mode
vim.keymap.set('t', '<C-S-v>', '<C-\\><C-n>"+Pi') -- Paste in terminal mode
