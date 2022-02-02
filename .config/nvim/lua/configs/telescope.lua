local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local horizontal_preview_width = function(_, cols, _)
	if cols > 200 then
		return math.floor(cols * 0.7)
	else
		return math.floor(cols * 0.6)
	end
end

local width_for_nopreview = function(_, cols, _)
	if cols > 200 then
		return math.floor(cols * 0.5)
	elseif cols > 110 then
		return math.floor(cols * 0.6)
	else
		return math.floor(cols * 0.75)
	end
end

local height_dropdown_nopreview = function(_, _, rows)
	return math.floor(rows * 0.7)
end

-- Custom keymap for telescope
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- General pickers
keymap("n", "<localleader>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
keymap("n", "<localleader>r", "<cmd>Telescope resume<CR>", opts)
keymap("n", "<localleader>R", "<cmd>Telescope pickers<CR>", opts)
keymap("n", "<localleader>f", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<localleader>g", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<localleader>b", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<localleader>h", "<cmd>Telescope highlights<CR>", opts)
keymap("n", "<localleader>j", "<cmd>Telescope jumplist<CR>", opts)
keymap("n", "<localleader>m", "<cmd>Telescope marks<CR>", opts)
keymap("n", "<localleader>o", "<cmd>Telescope vim_options<CR>", opts)
keymap("n", "<localleader>t", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts)
keymap("n", "<localleader>v", "<cmd>Telescope registers<CR>", opts)
keymap("n", "<localleader>u", "<cmd>Telescope spell_suggest<CR>", opts)
keymap("n", "<localleader>s", "<cmd>Telescope session-lens search_session<CR>", opts)
keymap("n", "<localleader>x", "<cmd>Telescope oldfiles<CR>", opts)
-- keymap("n", "<localleader>z", '<cmd>lua require"configs.telescope".pickers.zoxide()<CR>', opts)
keymap("n", "<localleader>;", "<cmd>Telescope command_history<CR>", opts)
keymap("n", "<localleader>/", "<cmd>Telescope search_history<CR>", opts)

local actions = require("telescope.actions")

telescope.setup({
	defaults = {
		sorting_strategy = "ascending",
		selection_strategy = "closest",
		scroll_strategy = "cycle",
		cache_picker = {
			num_pickers = 3,
			limit_entries = 300,
		},

		prompt_prefix = " ",
		selection_caret = " ",
		path_display = { "smart" },
		set_env = { COLORTERM = "truecolor" },
		-- Flex layout swaps between horizontal and vertical strategies
		-- based on the window width. See :h telescope.layout
		layout_strategy = "flex",
		layout_config = {
			width = 0.9,
			height = 0.85,
			prompt_position = "top",
			-- center = {
			-- 	preview_cutoff = 40
			-- },
			horizontal = {
				-- width_padding = 0.1,
				-- height_padding = 0.1,
				-- preview_cutoff = 60,
				preview_width = horizontal_preview_width,
			},
			vertical = {
				-- width_padding = 0.05,
				-- height_padding = 1,
				width = 0.75,
				height = 0.85,
				preview_height = 0.4,
				mirror = true,
			},
			flex = {
				-- change to horizontal after 120 cols
				flip_columns = 120,
			},
		},
		mappings = {
			i = {
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-c>"] = actions.close,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,

				-- ["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<C-l>"] = actions.complete_tag,
				["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
			},

			n = {
				["<esc>"] = actions.close,
				["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,
				["gg"] = actions.move_to_top,
				["G"] = actions.move_to_bottom,

				["sv"] = actions.select_horizontal,
				["sg"] = actions.select_vertical,
				["st"] = actions.select_tab,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["?"] = actions.which_key,
			},
		},
	},
	pickers = {
		buffers = {
			theme = "dropdown",
			previewer = false,
			sort_lastused = true,
			sort_mru = true,
			show_all_buffers = true,
			ignore_current_buffer = true,
			path_display = { shorten = 5 },
			layout_config = {
				width = width_for_nopreview,
				height = height_dropdown_nopreview,
			},
			mappings = {
				n = {
					["dd"] = actions.delete_buffer,
				},
			},
		},
		find_files = {
			-- theme = 'dropdown',
      hidden = true,
			-- previewer = false,
			-- layout_config = {
			-- 	width = width_for_nopreview,
			-- 	height = height_dropdown_nopreview,
   --      }
			},
		-- 	find_command = {
		-- 		'rg',
		-- 		'--smart-case',
		-- 		'--hidden',
		-- 		'--no-ignore-vcs',
		-- 		'--glob',
		-- 		'!.git',
		-- 		'--files',
		-- 	}
		-- },
		colorscheme = {
			enable_preview = true,
			-- previewer = false,
			-- theme = 'dropdown',
			layout_config = { width = 0.45, height = 0.8 },
		},
		highlights = {
			layout_strategy = "horizontal",
			layout_config = { preview_width = 0.80 },
		},
		-- jumplist = {
		-- 	layout_strategy = 'horizontal',
		-- 	layout_config = { preview_width = 0.60 },
		-- },
		vim_options = {
			theme = "dropdown",
			previewer = false,
			layout_config = { width = 0.6, height = 0.7 },
		},
		command_history = {
			theme = "dropdown",
			previewer = false,
			layout_config = { width = 0.5, height = 0.7 },
		},
		search_history = {
			theme = "dropdown",
			layout_config = { width = 0.4, height = 0.6 },
		},
		spell_suggest = {
			theme = "cursor",
			layout_config = { width = 0.27, height = 0.45 },
		},
		registers = {
			theme = "cursor",
			previewer = false,
			layout_config = { width = 0.45, height = 0.6 },
		},
		oldfiles = {
			theme = "dropdown",
			previewer = false,
			path_display = { shorten = 5 },
			layout_config = {
				width = width_for_nopreview,
				height = height_dropdown_nopreview,
			},
		},
		lsp_definitions = {
			layout_strategy = "horizontal",
			layout_config = { width = 0.95, height = 0.85, preview_width = 0.45 },
		},
		lsp_implementations = {
			layout_strategy = "horizontal",
			layout_config = { width = 0.95, height = 0.85, preview_width = 0.45 },
		},
		lsp_references = {
			layout_strategy = "horizontal",
			layout_config = { width = 0.95, height = 0.85, preview_width = 0.45 },
		},
		lsp_code_actions = {
			theme = "cursor",
			previewer = false,
			layout_config = { width = 0.3, height = 0.4 },
		},
		lsp_range_code_actions = {
			theme = "cursor",
			previewer = false,
			layout_config = { width = 0.3, height = 0.4 },
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
		["ui-select"] = {
			require("telescope.themes").get_cursor({
				layout_config = { width = 0.35, height = 0.35 },
			}),
		},
	},
})
