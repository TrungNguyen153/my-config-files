local wk = require("which-key")

-- Which-key for normal mode
wk.register({
  f = {
    name = 'File',
    b = { '<cmd>lua require("telescope.builtin").buffers()<CR>', 'Buffers' },
    f = { '<cmd>lua require("telescope.builtin").find_files()<CR>', 'Files' },
    w = { '<cmd>lua require("telescope").extensions.file_browser.file_browser()<CR>', 'File Browser' },
    o = { '<cmd>lua require("telescope.builtin").oldfiles()<CR>', 'Prev Open Files' },
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
    r = { '<cmd>lua require("telescope").extensions.live_grep_raw.live_grep_raw()<CR>', 'Live Grep Raw' },
    s = { '<cmd>lua require("spectre").open()<CR>', 'Spectre' },
    w = { '<cmd>lua require("spectre").open_visual({select_word = true})<CR>', 'Spectre Current Word' },
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
  },
  l = {
    name = 'LSP',
    r = { '<cmd>lua require("telescope.builtin").lsp_references()<CR>', 'References' },
    d = { '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', 'Definitions' },
    t = { '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', 'Type Definitions' },
    i = { '<cmd>lua require("telescope.builtin").lsp_implementations()<CR>', 'Implementations' },
    s = { '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Document Symbols' },
    w = { '<cmd>lua require("telescope.builtin").lsp_workspace_symbols()<CR>', 'Workspace Symbols' },
    v = {
      '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
      'Dynamic Workspace Symbols',
    },
    a = { '<cmd>lua require("telescope.builtin").lsp_code_actions()<CR>', 'Code Actions' },
    n = { '<cmd>lua require("telescope.builtin").lsp_range_code_actions()<CR>', 'Range Code Actions' },
    g = { '<cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>', 'Document Diagnostics' },
    o = { '<cmd>lua require("telescope.builtin").lsp_workspace_diagnostics()<CR>', 'Workspace Diagnostics' },
    e = { '<cmd>lua require("telescope.builtin").treesitter()<CR>', 'Treesitter' },
    l = { '<cmd>lua vim.lsp.codelens.display()<CR>', 'Code Lens' },
  },
  t = {
    name = 'Telescope',
    s = { '<cmd>lua require("telescope.builtin").planets()<CR>', 'Use Telescope...' },
    c = { '<cmd>lua require("telescope.builtin").builtin()<CR>', 'Builtin Pickers' },
    h = { '<cmd>lua require("telescope.builtin").reloader()<CR>', 'Reload Lua Modules' },
    y = { '<cmd>lua require("telescope.builtin").symbols()<CR>', 'List Symbols' },
    m = { '<cmd>lua require("telescope.builtin").resume()<CR>', 'Resume Last Picker' },
    r = { '<cmd>lua require("telescope.builtin").pickers()<CR>', 'Previous Pickers' },
  },
  d = {
    name = 'Debug Adapter',
    c = { '<cmd>lua require("telescope").extensions.dap.commands()<CR>', 'Commands' },
    f = { '<cmd>lua require("telescope").extensions.dap.configurations()<CR>', 'Configurations' },
    B = { '<cmd>lua require("telescope").extensions.dap.list_breakpoints()<CR>', 'Break Points' },
    v = { '<cmd>lua require("telescope").extensions.dap.variables()<CR>', 'Variables' },
    r = { '<cmd>lua require("telescope").extensions.dap.frames()<CR>', 'Frames' },
    u = { '<cmd>lua require("dapui").toggle()<CR>', "Toggle Dap UI" },
    b = { '<cmd>:DapToggleBreakpoint<CR>', 'Toggle Breakpoint' },
    n = { '<cmd>:DapStepOver<CR>', "Step Next" },
    N = { '<cmd>:DapStepOut<CR>', "Step Out" }
  },
  r = {
    name = 'Rust',
    r = { ':RustRunnables<CR>', 'Runnables' },
    d = { ':RustDebuggables<CR>', 'Debuggables' },
    e = { ':RustExpandMacro<CR>', 'Expand Macro' },
    c = { ':RustOpenCargo<CR>', 'Open Cargo.toml' },
    g = { ':RustViewCrateGraph<CR>', 'View Crate Graph' },
    m = { ':RustParentModule<CR>', 'Parent Module' },
    j = { ':RustJoinLines<CR>', 'Join Lines' },
    a = { ':RustHoverActions<CR>', 'Hover Actions' },
    h = { ':RustHoverRange<CR>', 'Range Hover Actions' },
    b = { ':RustMoveItemDown<CR>', 'Move Item Down' },
    u = { ':RustMoveItemUp<CR>', 'Move Item Up' },
    s = { ':RustStartStandaloneServerForBuffer<CR>', 'New Server for Buffer' },
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
}, {
  prefix = '<leader>',
  noremap = true,
  silent = true,
  mode = 'n',
})
