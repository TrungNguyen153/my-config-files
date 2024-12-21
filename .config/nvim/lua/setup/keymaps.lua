local no_remap_opt = { noremap = true }
local silent_opt = { silent = true }
local no_remap_silent_opt = { noremap = true, silent = true }
local no_remap_silent_expr_opt = { noremap = true, silent = true, expr = true }

local sidebar = require('sidebar')

local keymap_table = {
{
    shortcut = ']c',
    cmd = function()
        if vim.wo.diff then
            return ']c'
        end
        vim.schedule(function()
          require('gitsigns').next_hunk()
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
          require('gitsigns').prev_hunk()
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
    description = 'Open sessions history',
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
    shortcut = '<right>',
    cmd = '<CMD>vertical resize +2<CR>',
    opts = no_remap_opt,
    modes = { 'n' },
    description = 'Increase window width',
    enabled = not vim.g.vscode,
  },
  {
      shortcut = '<left>',
      cmd = '<CMD>vertical resize -2<CR>',
      opts = no_remap_opt,
      modes = { 'n' },
      description = 'Decrease window width',
      enabled = not vim.g.vscode,
  },
  {
      shortcut = '<up>',
      cmd = '<CMD>resize +2<CR>',
      opts = no_remap_opt,
      modes = { 'n' },
      description = 'Increase window height',
      enabled = not vim.g.vscode,
  },
  {
      shortcut = '<down>',
      cmd = '<CMD>resize -2<CR>',
      opts = no_remap_opt,
      modes = { 'n' },
      description = 'Decrease window height',
      enabled = not vim.g.vscode,
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
  -- RHS
  {
    shortcut = '<leader>r',
    cmd = 'rhs',
    description = 'Rust',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rl',
    cmd = ':RustAnalyzer restart<CR>',
    description = 'Reload Rust LSP',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rr',
    cmd = ':RustLsp runnables<CR>',
    description = 'Runnables',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rd',
    cmd = ':RustLsp debuggables<CR>',
    description = 'Debuggables',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>re',
    cmd = ':RustLsp expandMacro<CR>',
    description = 'Expand Macro',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rp',
    cmd = ':RustLsp rebuildProcMacros<CR>',
    description = 'Rebuild Proc Macro',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rc',
    cmd = ':RustLsp openCargo<CR>',
    description = 'Open Cargo.toml',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rg',
    cmd = ':RustLsp crateGraph<CR>',
    description = 'View Crate Graph',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rm',
    cmd = ':RustLsp parentModule<CR>',
    description = 'Goto Parent Module',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rj',
    cmd = ':RustLsp joinLines<CR>',
    description = 'Join Lines',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>ra',
    cmd = ':RustLsp hover actions<CR>',
    description = 'Hover Actions',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rh',
    cmd = ':RustLsp hover range<CR>',
    description = 'Range Hover Actions',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rw',
    cmd = ':RustLsp reloadWorkspace<CR>',
    description = 'Reload Workspace',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rs',
    cmd = ':RustLsp syntaxTree<CR>',
    description = 'Syntax Tree',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rc',
    cmd = ':RustLsp flyCheck<CR>',
    description = 'Cargo Check Background',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  {
    shortcut = '<leader>rt',
    cmd = '<cmd>require("setup.toggleterm").run_float("cargo test")<CR>',
    description = 'Run tests',
    opts = no_remap_opt,
    modes = { 'n' },
  },
  -- RHS
  {
    shortcut = '<leader>d',
    cmd = 'rhs',
    description = 'Debug Adapter',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>dc',
    cmd = '<cmd>lua require("telescope").extensions.dap.commands()<CR>',
    description = 'Commands',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>df',
    cmd = '<cmd>lua require("telescope").extensions.dap.configurations()<CR>',
    description = 'Configurations',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>db',
    cmd = '<cmd>lua require("telescope").extensions.dap.list_breakpoints()<CR>',
    description = 'List Breakpoints',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>dv',
    cmd = '<cmd>lua require("telescope").extensions.dap.variables()<CR>',
    description = 'Variables',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>dr',
    cmd = '<cmd>lua require("telescope").extensions.dap.frames()<CR>',
    description = 'Frames',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>dt',
    cmd = '<cmd>lua require("dapui").toggle()<CR>',
    description = 'Toggle DAP UI',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  -- RHS
  {
    shortcut = '<leader>s',
    cmd = 'rhs',
    description = 'Shell',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>st',
    cmd = function()
      require('here-term').toggle_terminal()
    end,
    description = 'Toggle Terminal',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>sk',
    cmd = function()
      require('here-term').kill_terminal()
    end,
    description = 'Kill Terminal',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  -- RHS
  {
    shortcut = '<leader>a',
    cmd = 'rhs',
    description = 'Aerial',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>at',
    cmd = ':AerialToggle<CR>',
    description = 'Toggle',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>aa',
    cmd = ':AerialOpenAll<CR>',
    description = 'Open All',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>ac',
    cmd = ':AerialCloseAll<CR>',
    description = 'Close All',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>aa',
    cmd = ':AerialTreeSyncFolds<CR>',
    description = 'Sync code folding',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>ai',
    cmd = ':AerialInfo<CR>',
    description = 'Info',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  -- RHS
  {
    shortcut = '<leader>o',
    cmd = 'rhs',
    description = 'Overseer',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>ot',
    cmd = ':OverseerToggle<CR>',
    description = 'Toggle',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>os',
    cmd = ':OverseerSaveBundle<CR>',
    description = 'Save',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>ol',
    cmd = ':OverseerLoadBundle<CR>',
    description = 'Load',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>od',
    cmd = ':OverseerDeleteBundle<CR>',
    description = 'Delete',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>oc',
    cmd = ':OverseerRunCmd<CR>',
    description = 'Run shell command',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>or',
    cmd = ':OverseerRun<CR>',
    description = 'Run task',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>ob',
    cmd = ':OverseerBuild<CR>',
    description = 'Open task builder',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>oq',
    cmd = ':OverseerQuickAction<CR>',
    description = 'Run action on a task',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>oa',
    cmd = ':OverseerTaskAction<CR>',
    description = 'Select a task to run an action on',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  -- RHS c
  {
    shortcut = '<leader>c',
    cmd = 'rhs',
    description = 'Code',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<leader>cs',
    cmd = ':ClangdSwitchSourceHeader<CR>',
    description = 'C/C++ switch source/header',
    opts = no_remap_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<F4>',
    cmd = ':ClangdSwitchSourceHeader<CR>',
    description = 'C/C++ switch source/header',
    opts = silent_opt,
    modes = { 'n' }
  },
  {
    shortcut = '<F4>',
    cmd = ':TSCppDefineClassFunc<CR>',
    description = 'C/C++ switch source/header',
    opts = silent_opt,
    modes = { 'v' }
  },
}

return {
  map_keys = function()
      for _, keymap in pairs(keymap_table) do
          if keymap.enabled == nil or keymap.enabled then
              local opts = vim.tbl_extend('force', { desc = keymap.description }, keymap.opts)
              vim.keymap.set(keymap.modes, keymap.shortcut, keymap.cmd, opts)
          end
      end
  end,
}