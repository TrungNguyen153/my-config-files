return {
  setup = function()
    require('neo-tree').setup({
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
    })
    require('neo-tree.events.queue').subscribe({
      event = 'file_opened',
      handler = function()
        vim.schedule(function()
          require('sidebar'):toggle('neotree')
        end)
      end,
    })
    local open_neotree = function()
      vim.api.nvim_cmd({
        cmd = 'Neotree',
        args = {
          'source=filesystem',
          -- 'reveal=true',
          -- 'reveal_force_cwd=true',
          'position=left',
          'action=focus',
        },
      }, {})
    end

    local close_neotree = function()
      vim.api.nvim_cmd({
        cmd = 'Neotree',
        args = {
          'source=filesystem',
          'position=left',
          'action=close',
        },
      }, {})
    end

    require('sidebar'):register_sidebar('neotree', open_neotree, close_neotree)
    --require('sidebar'):toggle('neotree')
  end,
  neogit = function()
    vim.api.nvim_cmd({
      cmd = 'Neotree',
      args = {
        'source=git_status',
        'reveal=true',
        'position=float',
        'action=focus',
        'toggle=true',
      },
    }, {})
  end,
  cwd_changed = function()
    vim.api.nvim_cmd({
      cmd = 'Neotree',
      args = {
        'dir=' .. vim.fn.getcwd(),
      },
    }, {})
    vim.api.nvim_cmd({
      cmd = 'Neotree',
      args = {
        'close',
      },
    }, {})
  end,
}
