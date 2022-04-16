-- plugin: nvim-treesitter
-- see: https://github.com/nvim-treesitter/nvim-treesitter
-- rafi settings

local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

-- vim.cmd [[
--   set foldenable=true
--   set foldmethod=expr
--   set foldexpr=nvim_treesitter#foldexpr()
-- ]]

parser_configs.http = {
	install_info = {
		url = "https://github.com/NTBBloodbath/tree-sitter-http",
		files = { "src/parser.c" },
		branch = "main",
	},
	filetype = "http",
}
require("nvim-treesitter.configs").setup({
	ensure_installed = "all", -- A list of parser names, or "all"
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	autotag = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = {
			"rust",
			"python",
		},
	},
	refactor = {
		highlight_definitions = { enable = true },
		-- highlight_current_scope = { enable = true },
	},
	-- See: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	textobjects = {
		select = {
			enable = true,
			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				-- ["gc"] = "@comment.outer",
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
	-- https://github.com/p00f/nvim-ts-rainbow
	rainbow = {
		enable = true,
		extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},

	-- See: https://github.com/JoosepAlviste/nvim-ts-context-commentstring
	context_commentstring = {
		enable = true,
		-- The plugin caw.vim will automatically detect and use this plugin itself
		enable_autocmd = false,
	},
})

require("vim.treesitter.query").set_query(
	"rust",
	"injections",
	[[
((
  (raw_string_literal) @constant
  (#match? @constant "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).*")
) @injection.content (#set! injection.language "sql"))
]]
) -- inject sql in raw_string_literals
