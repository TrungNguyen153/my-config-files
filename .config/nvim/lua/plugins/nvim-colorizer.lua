return {
    "catgoose/nvim-colorizer.lua",
    event = "VeryLazy",
    config = true,
    opts = {
        filetypes = {
            rust = {
                css = true,
                AARRGGBB = true,
            },
        }, -- Filetype options.  Accepts table like `user_default_options`
        buftypes = {}, -- Buftype options.  Accepts table like `user_default_options`
        -- Boolean | List of usercommands to enable.  See User commands section.
        user_commands = true, -- Enable all or some usercommands
        lazy_load = true, -- Lazily schedule buffer highlighting setup function
        
    }
}