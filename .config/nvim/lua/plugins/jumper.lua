return {
    url = "https://codeberg.org/andyg/leap.nvim",
    event = "VeryLazy",
    config = function()
        vim.keymap.set({'n', 'x', 'o'}, 'ss', '<Plug>(leap)')
        vim.keymap.set('n',             '<leader>s', '<Plug>(leap-from-window)')
    end,
}