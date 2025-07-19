local function open_dir(dir)
  vim.fn.jobstart('start ' .. dir)
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
      "MunifTanjim/nui.nvim",
  },
  event = "VeryLazy",
  enabled = not vim.g.vscode,
  -- enabled = false,
  branch = "v3.x",
	-- enabled = false, -- not use yet
	config = true,
    opts = {
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        -- popup_border_style = 'none',
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = true, -- used when sorting files and directories in the tree
        sources = {
          'filesystem',
          'git_status',
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added = '✚',
              modified = '',
              deleted = '✖',
              renamed = '',
              untracked = '',
              ignored = '',
              unstaged = '',
              staged = '',
              conflict = '',
            },
          },
        },
        window = {
          position = 'left',
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["l"] = "open",
            ["h"] = "close_node",
          }
        },
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false, -- only works on Windows for hidden files/directories
            hide_by_name = {
              'node_modules',
              '.git',
            },
            never_show = {
              '.DS_Store',
              'thumbs.db',
            },
          },
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          hijack_netrw_behavior = 'disabled', -- netrw disabled, opening a directory opens neo-tree
          use_libuv_file_watcher = false, -- set to true will cause https://github.com/nvim-neo-tree/neo-tree.nvim/issues/914
        },
        git_status = {
          window = {
            position = 'left',
          },
        },
        event_handlers = {
            {
                event = "neo_tree_buffer_enter",
                handler = function()
                    vim.opt_local.relativenumber = true
                end,
            },
            {
                event = "file_opened",
                handler = function()
                    vim.api.nvim_cmd({
                        cmd = 'Neotree',
                        args = {
                            'source=filesystem',
                            'position=left',
                            'action=close',
                            'toggle=false',
                        },
                    }, {})
                end,
            }
        },
    },
    keys = {
        {
            '<localleader>e',
            function()
                vim.api.nvim_cmd({
                    cmd = 'Neotree',
                    args = {
                        'action=focus',
                        'source=filesystem',
                        'position=left',
                        'toggle=true',
                        'reveal=true',
                    },
                }, {})
            end,
            mode = { 'n' },
            noremap = true,
            desc = 'File System Toggle',
        },
    },
}




-- return {
--   "stevearc/oil.nvim",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   lazy = false,
--   enabled = not vim.g.vscode,
--   -- enabled = false,
--   config = true,
--   cmd = { "Oil" },
--   keys = {
--     { "<localleader>e", "<CMD>Oil<CR>", mode = {"n"}, silent = true, desc = "Open parent directory" },
--     { "_", function() require("oil").open(vim.fn.getcwd()) end, mode = {"n"}, silent = true, desc = "Open cwd" },

--   },
--   opts = {
--     -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
--     -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
--     default_file_explorer = true,
--     use_default_keymaps = false,
--     view_options = {
--       -- This function defines what is considered a "hidden" file
--       is_hidden_file = function(name, bufnr)
--         -- local m = name:match("^%.")
--         -- return m ~= nil
--         return m == 'node_modules' or m == ".git"
--       end,
--       is_always_hidden = function(name, bufnr) return name == ".." end,
--     },
--     win_options = {
--       winbar = "%{v:lua.require('oil').get_current_dir()}",
--       concealcursor = "n",
--     },
--     keymaps = {
--       ["<localleader>e"] = "actions.close",
--       ["?"] = { "actions.show_help", mode = "n" },
--       ["<CR>"] = "actions.select",
--       ["<S-s>"] = { "actions.select", opts = { vertical = true } },
--       ["<S-h>"] = { "actions.select", opts = { horizontal = true } },
--       ["<S-t>"] = { "actions.select", opts = { tab = true } },
--       ["<C-p>"] = "actions.preview",
--       ["-"] = { "actions.parent", mode = "n" },
--       ["_"] = { "actions.open_cwd", mode = "n" },
--       ["."] = { "actions.cd", mode = "n" },
--       ["X"] = {
--         function()
--           open_dir(require('oil').get_current_dir())
--         end,
--         silent = true,
--         desc = "Open Current Dir in explorer"
--       },
--       ["H"] = { "actions.toggle_hidden", mode = "n" },
--       ["T"] = { "actions.toggle_trash", mode = "n" },
--     },
--   },
-- }