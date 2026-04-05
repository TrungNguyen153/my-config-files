 -- enhancements in highlighting and virtual text
return {
	{
		-- adds treesitter based text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter"
		},
		config = true,
		opt = {
			select = {
				lookahead = true,
				selection_modes = {
					["@comment.outer"] = "au",
					["@comment.inner"] = "iu",
					["@function.outer"] = "af",
					["@function.inner"] = "if",
					["@class.outer"] = "ac",
					["@class.inner"] = "ic",
					["@block.outer"] = "ab",
					["@block.inner"] = "ib",
				},
				include_surrounding_whitespace = true,
			},
			move = {
				set_jumps = true, -- whether to set jumps in the jumplist
				-- those bellow go to keymap
				-- goto_next_start = {
				-- 	["]m"] = "@function.outer",
				-- 	["]]"] = { query = "@class.outer", desc = "Next class start" },
				-- },
				-- goto_next_end = {
				-- 	["]M"] = "@function.outer",
				-- 	["]["] = "@class.outer",
				-- },
				-- goto_previous_start = {
				-- 	["[m"] = "@function.outer",
				-- 	["[["] = "@class.outer",
				-- },
				-- goto_previous_end = {
				-- 	["[M"] = "@function.outer",
				-- 	["[]"] = "@class.outer",
				-- },
			},
		},
		keys = {
			{
				'af',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@function.outer", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
			{
				'if',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@function.inner", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
			{
				'ac',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@class.outer", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
			{
				'ic',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@class.inner", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
			{
				'ab',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@block.outer", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
			{
				'ib',
				function()
					require "nvim-treesitter-textobjects.select"
					.select_textobject("@block.inner", "textobjects")
				end,
				mode = { 'x', 'o' },
				silent = true,
				nowait = true
			},
		}
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		dependencies = {
			-- {
			-- 	"nvim-treesitter/playground",
			-- 	branch = "main",
			-- 	enabled = false 
			-- }, -- TS PLayground for creating queries
			-- {
			-- 	"nvim-treesitter/nvim-treesitter-context",
			-- 	branch = "main"
			-- }, -- shows context of offscreen block in a float
		},
		config = function()
			-- require("nvim-treesitter").setup({
			-- 	ensure_installed = {
			-- 		'cmake',
			-- 		'asm',
			-- 		'tsx',
			-- 		'xml',
			-- 		'svelte',
			-- 		'bash',
            --         'c',
            --         'comment',
            --         'cpp',
            --         'c_sharp',
            --         'css',
            --         'diff',
            --         'dockerfile',
            --         'dtd',
            --         'editorconfig',
            --         'fish',
            --         'git_config',
            --         'git_rebase',
            --         'gitattributes',
            --         'gitcommit',
            --         'gitignore',
            --         'html',
            --         'java',
            --         'javascript',
            --         'jsdoc',
            --         'json',
            --         'json5',
            --         'kdl',
            --         'kotlin',
            --         'lua',
            --         'luadoc',
            --         'markdown',
            --         'markdown_inline',
            --         'norg',
            --         'python',
            --         'query',
            --         'rust',
            --         'sql',
            --         'regex',
            --         'toml',
            --         'typescript',
            --         'vim',
            --         'vimdoc',
            --         'yaml',
			-- 	},
			-- 	highlight = {
			-- 		enable = true,
			-- 		additional_vim_regex_highlighting = false,
			-- 	},
			-- 	indent = {
			-- 		enable = true,
			-- 		disable = {
			-- 			"rust",
			-- 			"python",
			-- 		},
			-- 	},
			-- 	matchup = {
			-- 		enable = true,
			-- 	},
			-- 	incremental_selection = {
			-- 		enable = true,
			-- 		keymaps = {
			-- 			init_selection = "<CR>",
			-- 			scope_incremental = "<CR>",
			-- 			node_incremental = "<TAB>",
			-- 			node_decremental = "<S-TAB>",
			-- 		},
			-- 	},
			-- })

			-- require("treesitter-context").setup({
			-- 	enable = true,
			-- 	max_lines = 3,
			-- 	mode = "topline",
			-- 	patterns = {
			-- 		default = {
			-- 			"class",
			-- 			"function",
			-- 			"method",
			-- 			"for",
			-- 			"while",
			-- 			"if",
			-- 			"switch",
			-- 			"case",
			-- 		},
			-- 		rust = {
			-- 			"impl_item",
			-- 			"struct",
			-- 			"enum",
			-- 		},
			-- 		json = {
			-- 			"pair",
			-- 		},
			-- 		yaml = {
			-- 			"block_mapping_pair",
			-- 		},
			-- 	},
			-- })
		end,
	},
}
