-- session management
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,globals,localoptions"
return {
	"rmagatti/auto-session",
	enabled = not vim.g.vscode,
	lazy = false,
	opts = {
		auto_create = false,
		auto_restore = true,
		cwd_change_handling = true,
		enabled = true,
		post_cwd_changed_cmds = function()
			require("lualine").refresh()
		end,
		session_lens = {
			load_on_setup = false,
			previewer = true,
			theme_conf = {
				border = false,
			},
			mappings = {
				-- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
				delete_session = { "i", "<C-D>" },
				alternate_session = { "i", "<C-S>" },
				copy_session = { "i", "<C-Y>" },
			},
		},
	},
	keys = {
		-- Will use Telescope if installed or a vim.ui.select picker otherwise
		{ '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session search' },
		{ '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
		{ '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave' },
		{
			"<M-w>",
			"<cmd>SessionSearch<CR>",
			mode = { "n" },
			desc = "Session search",
			noremap = true,
			silent = true,
		},
	},
}
