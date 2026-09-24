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
		opts = {
			select = {
				lookahead = true,
				-- 'v' charwise (the default), 'V' linewise, '<c-v>' blockwise
				selection_modes = {
					["@function.outer"] = "V",
					["@class.outer"] = "V",
				},
				include_surrounding_whitespace = true,
			},
			move = {
				set_jumps = true, -- whether to set jumps in the jumplist
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
			{
				']m',
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				silent = true,
				nowait = true
			},
			{
				']]',
				function()
					require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				silent = true,
				nowait = true
			},
			{
				'[m',
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
				silent = true,
				nowait = true
			},
			{
				'[[',
				function()
					require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
				end,
				mode = { "n", "x", "o" },
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
		config = function()
			-- main has no ensure_installed; install() skips parsers already present
			require("nvim-treesitter").install({
				"bash", "c", "cmake", "cpp", "css", "diff", "dockerfile", "html",
				"javascript", "json", "kotlin", "lua", "luadoc", "markdown",
				"markdown_inline", "python", "query", "regex", "rust", "slint",
				"sql", "svelte", "toml", "tsx", "typescript", "vim", "vimdoc",
				"wgsl", "yaml",
			})
		end,
	},
}
