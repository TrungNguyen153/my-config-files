local no_remap_opt = { noremap = true }
local silent_opt = { silent = true }
local no_remap_silent_opt = { noremap = true, silent = true }

local sidebar = require('sidebar')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
local gitsigns = require('gitsigns')

local keymap_table = {
  {
    shortcut = ';',
    cmd = ts_repeat_move.repeat_last_move,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Repeat last move',
},
{
    shortcut = ',',
    cmd = ts_repeat_move.repeat_last_move_opposite,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Repeat last move opposite direction',
},
{
    shortcut = 'f',
    cmd = ts_repeat_move.builtin_f,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Go to char ocurrence to the right',
},
{
    shortcut = 'F',
    cmd = ts_repeat_move.builtin_F,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Go to char ocurrence to the left',
},
{
    shortcut = 't',
    cmd = ts_repeat_move.builtin_t,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Go to before char ocurrence to the right',
},
{
    shortcut = 'T',
    cmd = ts_repeat_move.builtin_T,
    opts = no_remap_opt,
    modes = { 'n', 'x', 'o' },
    description = 'Go to after char ocurrence to the left',
},
{
    shortcut = ']c',
    cmd = function()
        if vim.wo.diff then
            return ']c'
        end
        vim.schedule(function()
            gitsigns.next_hunk()
        end)
        return '<Ignore>'
    end,
    opts = { expr = true },
    modes = { 'n' },
    description = 'Next git hunk',
},
{
    shortcut = '[c',
    cmd = function()
        if vim.wo.diff then
            return '[c'
        end
        vim.schedule(function()
            gitsigns.prev_hunk()
        end)
        return '<Ignore>'
    end,
    opts = { expr = true },
    modes = { 'n' },
    description = 'Previous git hunk',
},
  {
    shortcut = '+',
    cmd = '<C-a>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Increment number',
  },
  {
    shortcut = '-',
    cmd = '<C-x>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Decrement number',
  },
  {
    shortcut = '<C-a>',
    cmd = 'gg<S-v>G',
    opts = {},
    modes = { 'n' },
    description = 'Select all',
  },
  {
    shortcut = '<M-p>',
    cmd = require('telescope.builtin').buffers,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open buffers',
  },
  {
    shortcut = '<C-p>',
    cmd = require('telescope.builtin').find_files,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open file in workspace',
  },
  {
    shortcut = '<M-r>',
    cmd = ':e!<CR>',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Refresh buffer',
  },
  {
    shortcut = '<M-w>',
    cmd = ':Telescope neovim-project history<CR>',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open saved session',
  },
  {
    shortcut = '<localleader>b',
    cmd = require('telescope.builtin').buffers,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open list buffers opening',
  },
  {
    shortcut = '<localleader>f',
    cmd = require('telescope.builtin').find_files,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open file in workspace',
  },
  {
    shortcut = '<localleader>g',
    cmd = require('telescope.builtin').live_grep,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Live Grep',
  },
  {
    shortcut = '<localleader>r',
    cmd = require('telescope.builtin').resume,
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Resume Last Picker',
  },
  {
    shortcut = '<localleader>;',
    cmd = '<cmd>Telescope command_history<CR>',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Open command history',
  },
  {
    shortcut = '<M-t>',
    cmd = ':TroubleToggle workspace_diagnostics<CR>',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Show diagnostics pane',
  },
  {
    shortcut = 'n',
    cmd = 'nzz',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Center search navigation',
  },
  {
    shortcut = 'N',
    cmd = 'Nzz',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Center search navigation',
  },
  {
    shortcut = '*',
    cmd = '*zz',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Center search navigation',
  },
  {
    shortcut = '#',
    cmd = '#zz',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Center search navigation',
  },
  {
    shortcut = 'g*',
    cmd = 'g*zz',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Center search navigation',
  },
  { shortcut = '?', cmd = '?\\v', opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
  { shortcut = '/', cmd = '/\\v', opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
  { shortcut = '\\', cmd = '/@', opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
  { shortcut = '%s/', cmd = '%sm/', opts = no_remap_opt, modes = { 'c' }, description = 'Improve search' },
  {
    shortcut = '<F2>',
    cmd = function()
      require('oil').toggle_float()
    end,
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Toggle File Manager',
  },
  {
    shortcut = '<localleader>e',
    cmd = function()
      sidebar:toggle('neotree')
    end,
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Toggle Neo-tree',
  },
  {
    shortcut = '<M><left>',
    cmd = '<Plug>(SpotifyPrev)<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Previous Song (Spotify)',
  },
  {
    shortcut = '<M><right>',
    cmd = '<Plug>(SpotifySkip)<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Next Song (Spotify)',
  },
  {
    shortcut = '<M-/>',
    cmd = '<Plug>(SpotifyPause)<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Pause (Spotify)',
  },
  {
    shortcut = 'ss',
    cmd = '<cmd>HopChar2<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Hopping another character by 2 character',
  },
  {
    shortcut = '<C-n>',
    cmd = ':nohlsearch<CR>',
    opts = no_remap_opt,
    modes = { 'n', 'v' },
    description = 'Clear search',
  },
  { shortcut = 'H', cmd = '^', opts = {}, modes = { 'n', 'v' }, description = 'Jump to start of the line' },
  { shortcut = 'L', cmd = '$', opts = {}, modes = { 'n', 'v' }, description = 'Jump to end of the line' },
  {
    shortcut = '<C-h>',
    cmd = '<Left>',
    opts = no_remap_opt,
    modes = { 'i', 'c' },
    description = 'Move cursor left',
  },
  {
    shortcut = '<C-j>',
    cmd = '<Down>',
    opts = no_remap_opt,
    modes = { 'i', 'c' },
    description = 'Move cursor down',
  },
  {
    shortcut = '<C-k>',
    cmd = '<Up>',
    opts = no_remap_opt,
    modes = { 'i', 'c' },
    description = 'Move cursor up',
  },
  {
    shortcut = '<C-l>',
    cmd = '<Right>',
    opts = no_remap_opt,
    modes = { 'i', 'c' },
    description = 'Move cursor right',
  },
  {
    shortcut = 'so',
    cmd = '<cmd>only<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Close all windows but this',
  },
  {
    shortcut = 'sd',
    cmd = '<cmd>bd<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Delete current buffer',
  },
  {
    shortcut = 'st',
    cmd = '<cmd>tabnew<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Open new tab',
  },
  {
    shortcut = 'sb',
    cmd = '<cmd>buffer#<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Switch last open buffer',
  },
  {
    shortcut = 'sv',
    cmd = '<cmd>split<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Split horizontal on window',
  },
  {
    shortcut = 'sg',
    cmd = '<cmd>vsplit<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Split vertical on window',
  },
  {
    shortcut = '<C-h>',
    cmd = '<C-w><left>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Focus on window to the left',
  },
  {
    shortcut = '<C-l>',
    cmd = '<C-w><right>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Focus on window to the right',
  },
  {
    shortcut = '<C-k>',
    cmd = '<C-w><up>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Focus on window up',
  },
  {
    shortcut = '<C-j>',
    cmd = '<C-w><down>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Focus on window down',
  },
  {
    shortcut = '<C-d>',
    cmd = '<C-o>x',
    opts = no_remap_opt,
    modes = { 'i' },
    description = 'Delete char forward in insert mode',
  },
  {
    shortcut = '<F1>',
    -- cmd = function()
    --   sidebar:toggle('sidebar')
    -- end,
    cmd = ':AerialToggle<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Toggle sidebar',
  },
  {
    shortcut = '<C-s>',
    cmd = ':wa<CR>',
    opts = no_remap_silent_opt,
    modes = { 'n' },
    description = 'Savel all',
  },
  {
    shortcut = '<C-s>',
    cmd = '<C-o>:wa<CR>',
    opts = no_remap_silent_opt,
    modes = { 'i' },
    description = 'Savel all',
  },
  {
    shortcut = '[d',
    cmd = vim.diagnostic.goto_prev,
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Go to previous diagnostic',
  },
  {
    shortcut = ']d',
    cmd = vim.diagnostic.goto_next,
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Go to next diagnostic',
  },
  {
    shortcut = 'gD',
    cmd = vim.lsp.buf.declaration,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Go to declaration',
  },
  {
    shortcut = 'gt',
    cmd = vim.lsp.buf.type_definition,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Go to type definition',
  },
  {
    shortcut = 'gd',
    cmd = vim.lsp.buf.definition,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Go to definition',
  },
  {
    shortcut = 'gi',
    cmd = vim.lsp.buf.implementation,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Go to implementation',
  },
  {
    shortcut = 'gr',
    cmd = function()
      vim.lsp.buf.references({ includeDeclaration = false })
    end,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Find references',
  },
  {
    shortcut = '<M-k>',
    cmd = vim.lsp.buf.signature_help,
    opts = silent_opt,
    modes = { 'i' },
    description = 'Signature help',
  },
  -- calling twice make the cursor go into the float window. good for navigating big docs
  {
    shortcut = 'K',
    cmd = vim.lsp.buf.hover,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Show hover popup',
  },
  {
    shortcut = '<M-f>',
    cmd = function()
      vim.lsp.buf.format({ async = false })
    end,
    opts = silent_opt,
    modes = { 'n' },
    description = 'Format code',
  },
  {
    shortcut = '<leader>rn',
    cmd = "<cmd>lua vim.lsp.buf.rename()<CR>",
    opts = silent_opt,
    modes = { 'n' },
    description = 'Rename symbol',
  },
  {
    shortcut = '<leader>ca',
    cmd = "<cmd>lua vim.lsp.buf.code_action()<CR>",
    opts = silent_opt,
    modes = { 'n' },
    description = 'Code Action',
  },
  {
    shortcut = '<F4>',
    cmd = require('dap').repl.toggle,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Toggle repl COMPLETION',
  },
  {
    shortcut = '<F5>',
    cmd = require('dap').continue,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Continue',
  },
  {
    shortcut = '<S-F5>',
    cmd = require('dap').close,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Stop',
  },
  {
    shortcut = '<M-F5>',
    cmd = require('dap').terminate,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Terminate',
  },
  {
    shortcut = '<C-F5>',
    cmd = require('dap').run_last,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Run last',
  },
  {
    shortcut = '<F6>',
    cmd = require('dap').pause,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Pause',
  },
  {
    shortcut = '<F7>',
    cmd = require('dap.ui.widgets').hover,
    opts = silent_opt,
    modes = { 'x' },
    description = 'DAP Hover',
  },
  {
    shortcut = '<F9>',
    cmd = require('dap').toggle_breakpoint,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Toggle breakpoint',
  },
  {
    shortcut = '<S-F9>',
    cmd = function()
      require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Set breakpoint with condition',
  },
  {
    shortcut = '<C-F9>',
    cmd = function()
      require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Set logpoint',
  },
  {
    shortcut = '<F10>',
    cmd = require('dap').step_over,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Step over',
  },
  {
    shortcut = '<S-F10>',
    cmd = require('dap').run_to_cursor,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Run to cursor',
  },
  {
    shortcut = '<F11>',
    cmd = require('dap').step_into,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Step into',
  },
  {
    shortcut = '<S-F11>',
    cmd = require('dap').step_out,
    opts = silent_opt,
    modes = { 'n' },
    description = 'DAP Step out',
  },
  
}

return {
  keymap_table = keymap_table,
  which_key = {
    visual = {
      maps = {
        j = {
          name = 'Java',
          a = { '<cmd>lua require("jdtls").code_action(true)', 'Code Action' },
          e = { '<cmd>lua require("jdtls").extract_variable(true)', 'Extract Variable' },
          c = { '<cmd>lua require("jdtls").extract_constant(true)', 'Extract Constant' },
          m = { '<cmd>lua require("jdtls").extract_method(true)', 'Extract Method' },
        },
        ['c'] = { '"*y', 'Copy selection to system clipboard' },
        l = {
          name = 'LSP',
          a = { '<cmd>lua vim.lsp.buf.range_code_action()<CR>', 'Range Code Action' },
        },
      },
      opts = {
        prefix = '<leader>',
        noremap = true,
        silent = true,
        mode = 'v',
      },
    },
    normal = {
      maps = {
        f = {
          name = 'File',
          b = { '<cmd>lua require("telescope.builtin").buffers()<CR>', 'Buffers' },
          f = { '<cmd>lua require("telescope.builtin").find_files()<CR>', 'Files' },
          w = { '<cmd>lua require("telescope").extensions.file_browser.file_browser()<CR>', 'File Browser' },
          o = { '<cmd>%bd|e#<CR>', 'Close All Buffer But This' },
        },
        v = {
          name = 'Vim',
          q = { '<cmd>lua require("telescope.builtin").quickfix()<CR>', 'Quickfix List' },
          l = { '<cmd>lua require("telescope.builtin").loclist()<CR>', 'Location List' },
          j = { '<cmd>lua require("telescope.builtin").jumplist()<CR>', 'Jump List' },
          c = { '<cmd>lua require("telescope.builtin").commands()<CR>', 'Commands' },
          h = { '<cmd>lua require("telescope.builtin").command_history()<CR>', 'Command History' },
          s = { '<cmd>lua require("telescope.builtin").search_history()<CR>', 'Search History' },
          m = { '<cmd>lua require("telescope.builtin").man_pages()<CR>', 'Man Pages' },
          k = { '<cmd>lua require("telescope.builtin").marks()<CR>', 'Marks' },
          o = { '<cmd>lua require("telescope.builtin").colorscheme()<CR>', 'Colorscheme' },
          r = { '<cmd>lua require("telescope.builtin").registers()<CR>', 'Registers' },
          a = { '<cmd>lua require("telescope.builtin").autocommands()<CR>', 'Autocommands' },
          p = { '<cmd>lua require("telescope.builtin").vim_options()<CR>', 'Vim Options' },
          e = { '<cmd>lua require("telescope.builtin").spell_suggest()<CR>', 'Spell Suggestions' },
          y = { '<cmd>lua require("telescope.builtin").keymaps()<CR>', 'Normal Mode Keymaps' },
        },
        p = {
          name = 'Grep',
          g = { '<cmd>lua require("telescope.builtin").grep_string()<CR>', 'Grep String' },
          l = { '<cmd>lua require("telescope.builtin").live_grep()<CR>', 'Live Grep' },
          r = {
            '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>',
            'Live Grep Raw',
          },
          s = { '<cmd>lua require("spectre").open()<CR>', 'Spectre' },
          w = {
            '<cmd>lua require("spectre").open_visual({select_word = true})<CR>',
            'Spectre Current Word',
          },
        },
        g = {
          name = 'Git',
          f = { '<cmd>lua require("telescope.builtin").git_files()<CR>', 'Files' },
          s = { '<cmd>lua require("telescope.builtin").git_status()<CR>', 'Status' },
          c = { '<cmd>lua require("telescope.builtin").git_commits()<CR>', 'Commit Log' },
          l = { '<cmd>lua require("telescope.builtin").git_bcommits()<CR>', 'Commit Log Current Buffer' },
          b = { '<cmd>lua require("telescope.builtin").git_branches()<CR>', 'Branches' },
          t = { '<cmd>lua require("telescope.builtin").git_stash()<CR>', 'Stash' },
          d = { ':DiffviewOpen<CR>', 'Open Diff View' },
          x = { ':DiffviewClose<CR>', 'Close Diff View' },
          r = { ':DiffviewRefresh<CR>', 'Diff View Refresh' },
          e = { ':DiffviewFocusFiles<CR>', 'Diff View Focus Files' },
          h = { ':DiffviewFileHistory<CR>', 'Diff View File History' },
          g = { '<cmd>lua require("setup.neotree").neogit("git")<CR>', 'Neo-tree git' },
        },
        l = {
          name = 'LSP',
          a = { '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Actions' },
          b = { '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', 'Show line diagnostics' },
          d = { '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', 'Definitions' },
          e = { '<cmd>lua require("telescope.builtin").treesitter()<CR>', 'Treesitter' },
          g = {
            '<cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>',
            'Document Diagnostics',
          },
          i = { '<cmd>lua require("telescope.builtin").lsp_implementations()<CR>', 'Implementations' },
          l = { '<cmd>lua vim.lsp.codelens.run()<CR>', 'Code Lens' },
          m = { '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename symbol' },
          o = {
            '<cmd>lua require("telescope.builtin").diagnostics()<CR>',
            'Workspace Diagnostics',
          },
          q = { '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', 'Diagnostic set loclist' },
          r = { '<cmd>lua require("telescope.builtin").lsp_references()<CR>', 'References' },
          s = { '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Document Symbols' },
          t = { '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', 'Type Definitions' },
          v = {
            '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
            'Dynamic Workspace Symbols',
          },
          w = {
            '<cmd>lua require("telescope.builtin").lsp_workspace_symbols()<CR>',
            'Workspace Symbols',
          },
        },
        t = {
          name = 'Telescope',
          s = { '<cmd>lua require("telescope.builtin").planets()<CR>', 'Use Telescope...' },
          c = { '<cmd>lua require("telescope.builtin").builtin()<CR>', 'Builtin Pickers' },
          h = { '<cmd>lua require("telescope.builtin").reloader()<CR>', 'Reload Lua Modules' },
          y = {
            '<cmd>lua require("telescope.builtin").symbols({"emoji", "kaomoji", "gitmoji", "julia", "math", "nerd"})<CR>',
            'List Symbols',
          },
          m = { '<cmd>lua require("telescope.builtin").resume()<CR>', 'Resume Last Picker' },
          r = { '<cmd>lua require("telescope.builtin").pickers()<CR>', 'Previous Pickers' },
        },
        d = {
          name = 'Debug Adapter',
          c = { '<cmd>lua require("telescope").extensions.dap.commands()<CR>', 'Telescope DAP Commands' },
          f = { '<cmd>lua require("telescope").extensions.dap.configurations()<CR>', 'Telescope DAP Configurations' },
          b = { '<cmd>lua require("telescope").extensions.dap.list_breakpoints()<CR>', 'Telescope DAP List Breakpoints' },
          v = { '<cmd>lua require("telescope").extensions.dap.variables()<CR>', 'Telescope DAP Variables' },
          r = { '<cmd>lua require("telescope").extensions.dap.frames()<CR>', 'Telescope DAP Frames' },
          t = { '<cmd>lua require("dapui").toggle()<CR>', 'Toggle DAP UI' },
        },
        r = {
          name = 'Rust',
          -- r = { ':RustRunnables<CR>', 'Runnables' },
          -- d = { ':RustDebuggables<CR>', 'Debuggables' },
          -- e = { ":RustExpandMacro<CR>", 'Expand Macro' },
          -- -- p = { ":RustLsp rebuildProcMacros<CR>", 'Rebuild Proc Macro' },
          -- c = { ':RustOpenCargo<CR>', 'Open Cargo.toml' },
          -- -- g = { ':RustLsp crateGraph<CR>', 'View Crate Graph' },
          -- m = { ':RustParentModule<CR>', 'Parent Module' },
          -- j = { ':RustJoinLines<CR>', 'Join Lines' },
          -- -- a = { ':RustLsp hover actions<CR>', 'Hover Actions' },
          -- -- h = { ':RustLsp hover range<CR>', 'Range Hover Actions' },
          -- w = { ':RustReloadWorkspace<CR>', 'Reload Workspace' },
          -- -- s = { ':RustLsp syntaxTree<CR>', 'Syntax Tree' },
          -- -- f = { ':RustLsp flyCheck<CR>', 'Cargo Check Background' },
          -- t = { '<cmd>require("setup.toggleterm").run_float("cargo test")<CR>', 'Run tests' },

          l = { ':RustAnalyzer restart<CR>', 'Reload Rust LSP' },
          r = { ':RustLsp runnables<CR>', 'Runnables' },
          d = { ':RustLsp debuggables<CR>', 'Debuggables' },
          e = { ':RustLsp expandMacro<CR>', 'Expand Macro' },
          p = { ':RustLsp rebuildProcMacros<CR>', 'Rebuild Proc Macro' },
          c = { ':RustLsp openCargo<CR>', 'Open Cargo.toml' },
          g = { ':RustLsp crateGraph<CR>', 'View Crate Graph' },
          m = { ':RustLsp parentModule<CR>', 'Parent Module' },
          j = { ':RustLsp joinLines<CR>', 'Join Lines' },
          a = { ':RustLsp hover actions<CR>', 'Hover Actions' },
          h = { ':RustLsp hover range<CR>', 'Range Hover Actions' },
          w = { ':RustLsp reloadWorkspace<CR>', 'Reload Workspace' },
          s = { ':RustLsp syntaxTree<CR>', 'Syntax Tree' },
          c = { ':RustLsp flyCheck<CR>', 'Cargo Check Background' },
          t = { '<cmd>require("setup.toggleterm").run_float("cargo test")<CR>', 'Run tests' },
        },
        j = {
          name = 'Java',
          a = { '<cmd>lua require("jdtls").code_action()', 'Code Action' },
          r = { '<cmd>lua require("jdtls").code_action(false, "refactor")', 'Refactor' },
          o = { '<cmd>lua require("jdtls").organize_imports()', 'Organize Imports' },
          e = { '<cmd>lua require("jdtls").extract_variable()', 'Extract Variable' },
          c = { '<cmd>lua require("jdtls").extract_constant()', 'Extract Constant' },
          m = { '<cmd>lua require("jdtls").extract_method()', 'Extract Method' },
          t = { '<cmd>lua require("jdtls").test_class()', 'Test Class' },
          n = { '<cmd>lua require("jdtls").test_nearest_method()', 'Test Nearest Method' },
        },
        s = {
          name = 'Shell',
          a = { ':ToggleTermToggleAll<CR>', 'Toggle Term All' },
          h = { ':ToggleTerm direction=horizontal<CR>', 'Horizontal' },
          v = { ':ToggleTerm direction=vertical<CR>', 'Vertical' },
          f = { ':ToggleTerm direction=float<CR>', 'Float' },
        },
        a = {
          name = 'Aerial',
          t = { ':AerialToggle<CR>', 'Toggle' },
          a = { ':AerialOpenAll<CR>', 'Open All' },
          c = { ':AerialCloseAll<CR>', 'Close All' },
          s = { ':AerialTreeSyncFolds<CR>', 'Sync code folding' },
          i = { ':AerialInfo<CR>', 'Info' },
        },
        o = {
          name = 'Overseer',
          t = { '<cmd>lua require("sidebar"):toggle("overseer")<CR>', 'Toggle' },
          s = { ':OverseerSaveBundle<CR>', 'Save' },
          l = { ':OverseerLoadBundle<CR>', 'Load' },
          d = { ':OverseerDeleteBundle<CR>', 'Delete' },
          c = { ':OverseerRunCmd<CR>', 'Run shell command' },
          r = { ':OverseerRun<CR>', 'Run task' },
          b = { ':OverseerBuild<CR>', 'Open task builder' },
          q = { ':OverseerQuickAction<CR>', 'Run action on a task' },
          a = { ':OverseerTaskAction<CR>', 'Select a task to run an action on' },
        },
      },
      opts = {
        prefix = '<leader>',
        noremap = true,
        silent = true,
        mode = 'n',
      },
    },
  },
  map_keys = function()
    for _, keymap in pairs(keymap_table) do
      local opts = vim.tbl_extend('force', { desc = keymap.description }, keymap.opts)
      vim.keymap.set(keymap.modes, keymap.shortcut, keymap.cmd, opts)
    end
  end,
}
