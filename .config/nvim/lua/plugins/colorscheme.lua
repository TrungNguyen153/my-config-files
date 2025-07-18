local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.neovide_transparency_point))
  end

-- return {
-- 	"ellisonleao/gruvbox.nvim",
-- 	-- enable = false,
--     cond = not vim.g.vscode,
--     lazy = false,
--     priority = 1000,
-- 	config = true,
-- }

-- return {
--     "rose-pine/neovim",
--     name = "rose-pine",
--     lazy = false,
--     config = function()
--       require("rose-pine").setup({
--         variant = "auto",      -- auto, main, moon, or dawn
--         dark_variant = "main", -- main, moon, or dawn
--         dim_inactive_windows = false,
--         extend_background_behind_borders = true,

--         enable = {
--           terminal = false,
--           legacy_highlights = false, -- Improve compatibility for previous versions of Neovim
--           migrations = true,         -- Handle deprecated options automatically
--         },

--         styles = {
--           bold = true,
--           italic = false,
--           transparency = true,
--         },

--         groups = {
--           border = "muted",
--           link = "iris",
--           panel = "surface",

--           error = "love",
--           hint = "iris",
--           info = "foam",
--           note = "pine",
--           todo = "rose",
--           warn = "gold",

--           git_add = "foam",
--           git_change = "rose",
--           git_delete = "love",
--           git_dirty = "rose",
--           git_ignore = "muted",
--           git_merge = "iris",
--           git_rename = "pine",
--           git_stage = "iris",
--           git_text = "rose",
--           git_untracked = "subtle",

--           h1 = "iris",
--           h2 = "foam",
--           h3 = "rose",
--           h4 = "gold",
--           h5 = "pine",
--           h6 = "foam",

--         },

--         highlight_groups = {
--           Number = { fg = "#5BC1A2" },
--           -- LineNr = { fg = "#3B4261" },
--           LineNr4 = { fg = "#3B4261" },
--           LineNr3 = { fg = "#445464" },
--           LineNr2 = { fg = "#5D8E97" },
--           LineNr1 = { fg = "#7DAEB9" },
--           LineNr0 = { fg = "#bDeEf9", bold = true }
--         },
--       })

--       if vim.g.neovide then
--         require("rose-pine").setup({
--           styles = {
--             -- bold = true,
--             italic = false,
--             transparency = false,
--           },
--         })
--         -- Set transparency and background color (title bar color)
--         vim.g.neovide_background_color_base = "#191724"
--         vim.g.neovide_background_color = vim.g.neovide_background_color_base .. alpha()
--         vim.g.neovide_title_background_color = vim.g.neovide_background_color_base .. alpha()
--         vim.g.neovide_title_text_color = "pink"
--         -- vim.g.neovide_normal_opacity = 1
--         vim.cmd("colorscheme rose-pine")
--       else
--         vim.cmd("colorscheme rose-pine") -- setting
--       end
--     end
-- }

return {
  "nickkadutskyi/jb.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
      -- require("jb").setup({transparent = true})
      vim.cmd("colorscheme jb")
  end,
}