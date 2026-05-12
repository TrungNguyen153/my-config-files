return {
    'akinsho/toggleterm.nvim',
    version = "*",
    event = "VeryLazy",
    enabled = not vim.g.vscode,
    config = function()
        require("toggleterm").setup({
            on_open = function(term)
                vim.cmd("startinsert!")
            end,
            size = function(term)
                if term.direction == 'horizontal' then
                  return 15
                elseif term.direction == 'vertical' then
                  return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-;>]],
            hide_numbers = true,
            start_in_insert = true,
            auto_scroll = true,
            winbar = {
                enabled = true,
            },
        })

        local function set_terminal_keymaps()
            local opts = {buffer = 0}
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', 'jj', [[<C-\><C-n>]], opts)
            -- vim.keymap.set('t', '<C-c>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
        end
        
        vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
            pattern = "term://*toggleterm#*",
            callback = function()
                vim.cmd("startinsert!")
            end,
        })
        -- if you only want these mappings for toggle term use term://*toggleterm#* instead
        vim.api.nvim_create_autocmd({ "TermOpen" }, {
            pattern = "term://*",
            callback = function()
                set_terminal_keymaps()
            end,
        })
        



    end,
}