return {
    "TrungNguyen153/tailwind-tools.nvim",
    -- dir = "E:/rust-workspace/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins", 
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "neovim/nvim-lspconfig",
    },
    opts = {
        server = {
            settings = {
                emmetCompletions = true,
                experimental = {
                    classRegex = {
                        "class\\s*:\\s*\"([^\"]*)" -- dioxus
                    }
                },
                includeLanguages = {
                    rust = "html"
                }
            }
        },
        extension = {
            queries = {
                "rust",
            }, -- a list of filetypes having custom `class` queries
            patterns = { -- a map of filetypes to Lua pattern lists
            --   rust = { "class=[\"']([^\"']+)[\"']" },
              -- javascript = { "clsx%(([^)]+)%)" },
            },
        },
    }
}