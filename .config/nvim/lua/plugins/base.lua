return {
    -- common utilities
    'ciaranm/securemodelines', -- https://vim.fandom.com/wiki/Modeline_magic
    'farmergreg/vim-lastplace', -- remembers cursor position with nice features in comparison to just an autocmd
    {
        'nvim-lua/plenary.nvim', -- serveral lua utilities
        -- commit = "62d1e2e5691865586187bd6aa890e43b85c00518" -- use this commit because lasted broken Codium [https://github.com/Exafunction/codeium.nvim/issues/121#issuecomment-1832819652]
    },
    {
        'nvim-tree/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup()
        end,
    }, -- icon support for several plugins
    'MunifTanjim/nui.nvim', -- base ui components for nvim
    'tpope/vim-repeat', -- adds repeat functionality for other plugins
    'stevearc/dressing.nvim', -- overrides the default vim input to provide better visuals
    -- {
    --     'augustocdias/gatekeeper.nvim',
    --     config = require('setup.gatekeeper').setup,
    -- }, -- sets buffers outside the cwd as readonly
}