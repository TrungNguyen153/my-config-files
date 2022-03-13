-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`
-- https://github.com/kyazdani42/nvim-tree.lua for options
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<localleader>e", "<cmd>NvimTreeRefresh<CR><cmd>NvimTreeFindFileToggle<CR>", opts)

vim.g.nvim_tree_icons = {
	default = "",
	symlink = "",
	git = {
		unstaged = "",
		staged = "S",
		unmerged = "",
		renamed = "➜",
		deleted = "",
		untracked = "U",
		ignored = "◌",
	},
	folder = {
		default = "",
		open = "",
		empty = "",
		empty_open = "",
		symlink = "",
	},
}

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
	return
end

nvim_tree.setup({
	disable_netrw = true, -- Disable default neovim explorer
	hijack_netrw = true,
	open_on_setup = false,
	ignore_ft_on_setup = {
		"startify",
		"dashboard",
		"alpha",
	},
	auto_close = true,
	open_on_tab = false,
	hijack_cursor = false,
	update_cwd = true,
	diagnostics = {
		enable = true,
		-- Diagnostics signs and highlights
		--   Error:   ✘
		--   Warn:  ⚠ 
		--   Hint:  
		--   Info:   ⁱ

		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "✘",
		},
	},
	update_focused_file = {
		enable = false,
		update_cwd = true,
		ignore_list = {},
	},
	system_open = {
		cmd = nil,
		args = {},
	},
	filters = {
		dotfiles = false,
		custom = {},
	},
	git = {
		enable = true,
		ignore = false,
		timeout = 500,
	},
	view = {
		width = 30,
		height = 30,
		hide_root_folder = false,
		side = "left",
		auto_resize = true,
    preserve_window_proportions = false,
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
			},
		},
		number = true,
		relativenumber = true,
	},
	actions = {
		open_file = {
			quit_on_open = false,
			window_picker = {
				enable = true,
			},
		},
	},
	trash = {
		cmd = "trash",
		require_confirm = true,
	},
	show_icons = {
		git = 1,
		folders = 1,
		files = 1,
		folder_arrows = 1,
		tree_width = 30,
	},
})
