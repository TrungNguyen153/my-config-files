return {
    setup = function()
        require("neorg").setup {
            load = {
                ['core.defaults'] = {},
                ['core.itero'] = {},
                ['core.highlights'] = {
                  -- config = {
                  --   highlights = custom_highlights,
                  -- },
                },
                ['core.concealer'] = {},
                ['core.dirman'] = {
                  config = {
                    workspaces = {
                      gestione = "~/Dropbox/gestione-norg",
                      astronomia = "~/Dropbox/astronomia",
                    },
                  },
                },
                ["core.dirman"] = { -- Manages Neorg workspaces
                    config = {
                        workspaces = {
                            notes = "~/neorg/notes",
                            gestione = "~/neorg/gestione-norg",
                            astronomia = "~/neorg/astronomia",
                        },
                    },
                },
                ['core.completion'] = {
                  config = {
                    engine = "nvim-cmp",
                    name = "[Neorg]"
                  },
                },
                ['core.export'] = {},
                ['core.export.markdown'] = {
                  config = {
                    extensions = "all"
                  }
                },
            },
          }
    end,
}