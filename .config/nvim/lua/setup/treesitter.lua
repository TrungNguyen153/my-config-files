return {
	setup = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"cpp",
				"cmake",
				"bash",
				"asm",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"rust",
				"c_sharp",
				"tsx",
				"xml",
				"typescript",
				"javascript",
				"svelte",
				"gitignore",
				"dockerfile",
			},
			ignore_install = {
				"phpdoc",
			},
			highlight = {
				enable = true,
				-- add languages not supported by treesitter here
				-- disable = function(lang, buf)
				--   local max_filesize = 30 * 1024 -- 30 KB
				--   local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				--   if ok and stats and stats.size > max_filesize then
				--       return true
				--   end
				-- end,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
				disable = {
					"rust",
					"python",
				},
			},
			autotag = {
				enable = true,
			},
			matchup = {
				enable = false,
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["au"] = "@comment.outer",
						["iu"] = "@comment.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = { query = "@class.outer", desc = "Next class start" },
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					scope_incremental = "<CR>",
					node_incremental = "<TAB>",
					node_decremental = "<S-TAB>",
				},
			},
		})
		-- require('vim.treesitter.query').set(
		--     'rust',
		--     'injections',
		--     [[
		-- ((
		--   (raw_string_literal) @constant
		--   (#match? @constant "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).*")
		-- ) @injection.content (#set! injection.language "sql"))
		-- ]]
		-- ) -- inject sql in raw_string_literals
		--     require('vim.treesitter.query').set(
		--       'rust',
		--       'injections',
		--       [[
		-- ((
		--   (line_comment) @constant
		-- ) @injection.content (#set! injection.language "markdown_inline"))
		-- ]]
		--     ) -- inject markdown in comments

		require("treesitter-context").setup({
			enable = true,
			max_lines = 3,
			mode = "topline",
			patterns = {
				default = {
					"class",
					"function",
					"method",
					"for",
					"while",
					"if",
					"switch",
					"case",
				},
				rust = {
					"impl_item",
					"struct",
					"enum",
				},
				json = {
					"pair",
				},
				yaml = {
					"block_mapping_pair",
				},
			},
		})
	end,
}
