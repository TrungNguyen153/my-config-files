-- various utilities

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		gitbrowse = { enabled = true },
		indent = {
			indent = {
				enabled = false,
			},
			animate = {
				enabled = vim.fn.has("nvim-0.10") == 1,
				style = "out",
				easing = "linear",
				duration = {
				  step = 20, -- ms per step
				  total = 250, -- maximum duration
				},
			},
			chunk = {
				enabled = true,
				horizontal = '─',
				vertical = '│',
				corner_top = '╭',
				corner_bottom = '╰',
				arrow = '─',
			},
		},
		
		notifier = { enabled = true, style = "fancy" },
		rename = { enabled = true },
		words = { enabled = true },
		scroll = { enabled = true },
		input = { enabled = true },
		styles = {
			blame_line = { border = "none" },
			notification = { border = "none" },
			notification_history = { border = "none" },
			input = { relative = "cursor" },
		},
		zen = {
			toggles = {
				dim = false,
			},
		},

		statuscolumn = {
			enabled = true,
			left = { 'sign', 'fold', 'mark' }, -- priority of signs on the left (high to low)
            right = { 'git' },                 -- priority of signs on the right (high to low)
		},
		
		picker = {
			sources = {
				explorer = {
					enabled = false,
					-- https://github.com/shubham-cpp/dotfiles/blob/main/.config/nvim-astro/lua/plugins/snacks.lua
					layout = { cycle = false, layout = { position = "left" } },
					actions = {
						-- more option go here
					},
					win = {
						list = {
							keys = {
							},
						},
					},
				}
			},
			layout = {
				preset = "telescope",
				reverse = false,
				-- layout = {
				-- 	backdrop = 70,
				-- },
			},
			ui_select = true, -- replace `vim.ui.select` with the snacks picker
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
						["<Tab>"] = { "list_down", mode = { "i", "n" } },
					},
				},
			},
			icons = {
				ui = {
					ignored = " ",
					hidden = " ",
					follow = "󰭔 ",
				},
				git = {
					enabled = true, -- show git icons
					commit = "󰜘 ", -- used by git log
					staged = "● ", -- staged changes. always overrides the type icons
					added = " ",
					deleted = " ",
					ignored = " ",
					modified = "○ ",
					renamed = "󰑕 ",
					unmerged = " ",
					untracked = " ",
				},
				kinds = {
					Control = " ",
					Collapsed = " ",
					Copilot = " ",
					Key = " ",
					Namespace = "󰦮 ",
					Null = " ",
					Number = "󰎠 ",
					Object = " ",
					Package = " ",
					String = " ",
					Unknown = " ",

					-- copy from cmp
					Text = "",
					Method = "󰊕",
					Function = "󰊕",
					Constructor = "",
					Field = "󰜢",
					Variable = "",
					Class = "",
					Interface = "",
					Module = "",
					Property = "",
					Unit = "",
					Value = "",
					Enum = "",
					Keyword = "󱕴",
					Snippet = "",
					Color = "",
					File = "",
					Reference = "",
					Folder = "",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "",
					Event = "",
					Operator = "",
					TypeParameter = "",
					Boolean = " ",
					Array = " ",
				},
			},
		},
	},
	keys = {
		{
			"<C-x>",
			":lua Snacks.bufdelete()<CR>",
			mode = { "n" },
			desc = "Close current buffer",
			noremap = true,
			silent = true,
		},
		{
			"<C-S-x>",
			":lua Snacks.bufdelete.all()<CR>",
			mode = { "n" },
			desc = "Close call buffers",
			noremap = true,
			silent = true,
		},
		{
			"<M-p>",
			"<cmd>lua Snacks.picker.buffers()<CR>",
			mode = { "n" },
			desc = "Open buffers",
			noremap = true,
			silent = true,
		},
		{
			"<localleader>f",
			"<cmd>lua Snacks.picker.files()<CR>",
			mode = { "n" },
			desc = "Open file in workspace",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gb",
			"<cmd>lua Snacks.picker.git_branches()<CR>",
			mode = { "n" },
			desc = "Branches",
			noremap = true,
		},
		{
			"<leader>gc",
			"<cmd>lua Snacks.picker.git_log()<CR>",
			mode = { "n" },
			desc = "Commit Log",
			noremap = true,
		},
		{
			"<leader>gf",
			"<cmd>lua Snacks.picker.git_files()<CR>",
			mode = { "n" },
			desc = "Files",
			noremap = true,
		},
		{
			"<leader>gg",
			"<cmd>lua Snacks.picker.git_diff()<CR>",
			mode = { "n" },
			desc = "Git Diff (Hunks)",
			noremap = true,
		},
		{
			"<leader>gl",
			"<cmd>lua Snacks.picker.git_log_file()<CR>",
			mode = { "n" },
			desc = "Commit Log Current Buffer",
			noremap = true,
		},
		{
			"<leader>gs",
			"<cmd>lua Snacks.picker.git_status()<CR>",
			mode = { "n" },
			desc = "Status",
			noremap = true,
		},
		{
			"<leader>gt",
			"<cmd>lua Snacks.picker.git_stash()<CR>",
			mode = { "n" },
			desc = "Stash",
			noremap = true,
		},
		{
			"<leader>ld",
			"<cmd>lua Snacks.picker.lsp_definitions()<CR>",
			mode = { "n" },
			desc = "Definitions",
			noremap = true,
		},
		{
			"<leader>li",
			"<cmd>lua Snacks.picker.lsp_implementations()<CR>",
			mode = { "n" },
			desc = "Implementations",
			noremap = true,
		},
		{
			"<leader>lr",
			"<cmd>lua Snacks.picker.lsp_references()<CR>",
			mode = { "n" },
			desc = "References",
			noremap = true,
		},
		{
			"<leader>ls",
			"<cmd>lua Snacks.picker.lsp_symbols()<CR>",
			mode = { "n" },
			desc = "Document Symbols",
			noremap = true,
		},
		{
			"<leader>lt",
			"<cmd>lua Snacks.picker.lsp_type_definitions()<CR>",
			mode = { "n" },
			desc = "Type Definitions",
			noremap = true,
		},
		{
			"<leader>lw",
			"<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>",
			mode = { "n" },
			desc = "Workspace Symbols",
			noremap = true,
		},
		{
			"<leader>pw",
			"<cmd>lua Snacks.picker.grep_word()<CR>",
			mode = { "n" },
			desc = "Grep Word",
			noremap = true,
		},
		{
			"<localleader>g",
			"<cmd>lua Snacks.picker.grep()<CR>",
			mode = { "n" },
			desc = "Live Grep",
			noremap = true,
		},
		{
			"<leader>pb",
			"<cmd>lua Snacks.picker.grep_buffers()<CR>",
			mode = { "n" },
			desc = "Grep Buffers",
			noremap = true,
		},
		{
			"<leader>va",
			"<cmd>lua Snacks.picker.autocmds()<CR>",
			mode = { "n" },
			desc = "Autocommands",
			noremap = true,
		},
		{
			"<leader>vc",
			"<cmd>lua Snacks.picker.commands()<CR>",
			mode = { "n" },
			desc = "Commands",
			noremap = true,
		},
		{
			"<leader>ve",
			"<cmd>lua Snacks.picker.spelling()<CR>",
			mode = { "n" },
			desc = "Spell Suggestions",
			noremap = true,
		},
		{
			"<leader>vh",
			"<cmd>lua Snacks.picker.help()<CR>",
			mode = { "n" },
			desc = "Help Pages",
			noremap = true,
		},
		{
			"<leader>vb",
			"<cmd>lua Snacks.picker.command_history()<CR>",
			mode = { "n" },
			desc = "Command History",
			noremap = true,
		},
		{
			"<leader>vj",
			"<cmd>lua Snacks.picker.jumps()<CR>",
			mode = { "n" },
			desc = "Jump List",
			noremap = true,
		},
		{
			"<leader>vk",
			"<cmd>lua Snacks.picker.marks()<CR>",
			mode = { "n" },
			desc = "Marks",
			noremap = true,
		},
		{
			"<leader>vl",
			"<cmd>lua Snacks.picker.loclist()<CR>",
			mode = { "n" },
			desc = "Location List",
			noremap = true,
		},
		{
			"<leader>vm",
			"<cmd>lua Snacks.picker.man()<CR>",
			mode = { "n" },
			desc = "Man Pages",
			noremap = true,
		},
		{
			"<leader>vo",
			"<cmd>lua Snacks.picker.colorschemes()<CR>",
			mode = { "n" },
			desc = "Colorscheme",
			noremap = true,
		},
		{
			"<leader>vi",
			"<cmd>lua Snacks.picker.highlights()<CR>",
			mode = { "n" },
			desc = "Highlights",
			noremap = true,
		},
		{
			"<localleader>r",
			"<cmd>lua Snacks.picker.resume()<CR>",
			mode = { "n" },
			desc = "Resume Last Picker",
			noremap = true,
		},
		{
			"<leader>vz",
			"<cmd>lua Snacks.picker.lazy()<CR>",
			mode = { "n" },
			desc = "Lazy Plugins",
			noremap = true,
		},
		{
			"<leader>vq",
			"<cmd>lua Snacks.picker.qflist()<CR>",
			mode = { "n" },
			desc = "Quickfix List",
			noremap = true,
		},
		{
			"<leader>vr",
			"<cmd>lua Snacks.picker.registers()<CR>",
			mode = { "n" },
			desc = "Registers",
			noremap = true,
		},
		{
			"<leader>vs",
			"<cmd>lua Snacks.picker.search_history()<CR>",
			mode = { "n" },
			desc = "Search History",
			noremap = true,
		},
		{
			"<leader>vy",
			"<cmd>lua Snacks.picker.keymaps()<CR>",
			mode = { "n" },
			desc = "Normal Mode Keymaps",
			noremap = true,
		},
		{
			"gb",
			":lua Snacks.gitbrowse()<CR>",
			silent = true,
			mode = { "n" },
			desc = "Open file in remeote repo",
		},
		{
			"grn",
			function()
				Snacks.words.jump(1, true)
			end,
			silent = true,
			mode = { "n" },
			desc = "Go to next reference",
		},
		{
			"grp",
			function()
				Snacks.words.jump(-1, true)
			end,
			silent = true,
			mode = { "n" },
			desc = "Go to previous reference",
		},
		{
			"gz",
			function()
				Snacks.zen()
			end,
			silent = true,
			mode = { "n" },
			desc = "Go to ZenMode",
		},
		-- {
		-- 	"<localleader>e",
		-- 	function()
		-- 		Snacks.explorer()
		-- 	end,
		-- 	silent = true,
		-- 	mode = { "n" },
		-- 	desc = "Explorer toggle",
		-- }
	},
}
