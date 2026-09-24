return {
    'PHSix/faster.nvim',
    event = 'VeryLazy',
    enabled = true,
    config = function()
        -- Call the mover from Lua: the plugin's <Plug> maps open the command line on every j/k.
        vim.keymap.set('n', 'j', function()
            require('faster').move('j')
        end, { silent = true })
        vim.keymap.set('n', 'k', function()
            require('faster').move('k')
        end, { silent = true })
        -- if you need map in visual mode
        vim.api.nvim_set_keymap('x', 'j', '<Plug>(faster_vmove_j)', { noremap = false, silent = true })
        vim.api.nvim_set_keymap('x', 'k', '<Plug>(faster_vmove_k)', { noremap = false, silent = true })
    end,
}
