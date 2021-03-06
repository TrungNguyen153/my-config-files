local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end
-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`
-- https://github.com/kyazdani42/nvim-tree.lua for options
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<localleader>e", "<cmd>NvimTreeRefresh<CR><cmd>NvimTreeFindFileToggle<CR>", opts)
local winwidth = 40
-- :h nvim-tree.lua


-- vim.g.nvim_tree_icons = {
--   default = "",
--   symlink = "",
--   git = {
--     unstaged = "+",
--     staged = "+",
--     unmerged = "",
--     renamed = "",
--     untracked = "?",
--     deleted = "",
--     ignored = "!",
--   },
--   folder = {
--     arrow_open = "",
--     arrow_closed = "",
--     default = "",
--     open = "",
--     empty = "",
--     empty_open = "",
--     symlink = "",
--     symlink_open = "",
--   },
-- }

local function get_current_directory(node)
  local path = node.absolute_path
  if node.nodes == nil or not node.open then
    local path_separator = package.config:sub(1, 1)
    path = path:match("(.*)" .. path_separator)
  end
  return path
end

local function grep_tree(node)
  require("telescope.builtin").live_grep({
    cwd = get_current_directory(node),
  })
end

local function find_tree(node)
  require("telescope.builtin").find_files({
    cwd = get_current_directory(node),
  })
end

local toggle_width = function(_)
  local max = 0
  local line_count = vim.fn.line("$")

  for i = 1, line_count do
    local txt = vim.fn.substitute(vim.fn.getline(i), "\\s\\+$", "", "")
    max = math.max(vim.fn.strdisplaywidth(txt) + 2, max)
  end

  local cur_width = vim.fn.winwidth(0)
  local half = math.floor((winwidth + (max - winwidth) / 2) + 0.5)
  local new_width = winwidth
  if cur_width == winwidth then
    new_width = half
  elseif cur_width == half then
    new_width = max
  else
    new_width = winwidth
  end
  vim.cmd(new_width .. " wincmd |")
end
nvim_tree.setup({
  disable_netrw = true, -- Disable default neovim explorer
  hijack_directories = {
    enable = false,
    auto_open = false,
  },
  create_in_closed_folder = false,
  respect_buf_cwd = true,
  ignore_ft_on_setup = {
    "startify",
    "dashboard",
    "alpha",
  },
  update_cwd = true,
  open_on_setup = false,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "✘",
    },
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
  filters = {
    dotfiles = false,
    custom = {
      ".git",
      ".hg",
      ".svc",
      ".stversions",
      ".mypy_cache",
      ".pytest_cache",
      "__pycache__",
      ".sass-cache",
      ".DS_Store",
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    add_trailing = true,
    group_empty = true,
    highlight_git = true,
  },
  actions = {
    change_dir = {
      enable = true,
      global = false,
    },
    open_file = {
      quit_on_open = true,
      window_picker = {
        enable = false,
      },
    },
  },
  view = {
    width = winwidth,
    side = "left",
    signcolumn = "no",
    mappings = {
      custom_only = true,
      list = {
        { key = { "l", "<CR>", "o" }, action = "edit" },
        { key = { "O" }, action = "system_open" },
        { key = "h", action = "close_node" },
        { key = "sv", action = "split" },
        { key = "sg", action = "vsplit" },
        { key = "st", action = "tabnew" },
        { key = "q", action = "close" },
        { key = "?", action = "toggle_help" },
        { key = "a", action = "create" },
        { key = "d", action = "remove" },
        { key = "r", action = "rename" },
        { key = "<C-r>", action = "full_rename" },
        { key = "x", action = "cut" },
        { key = "c", action = "copy" },
        { key = "p", action = "paste" },
        { key = "y", action = "copy_name" },
        { key = "Y", action = "copy_path" },
        { key = "gy", action = "copy_absolute_path" },
        { key = "-", action = "dir_up" },
        { key = "<Tab>", action = "preview" },
        -- Search
        { key = "gr", action = "grep_tree", action_cb = grep_tree },
        { key = "gf", action = "find_tree", action_cb = find_tree },
        { key = "w", action = "toggle_width", action_cb = toggle_width },
      },
    },
    number = true,
    relativenumber = true,
  },
})
