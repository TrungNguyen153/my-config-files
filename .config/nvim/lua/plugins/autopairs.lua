-- helps with auto closing blocks
return {
	"windwp/nvim-autopairs",
	enabled = not vim.g.vscode,
	event = "VeryLazy",
	config = function()
		local npairs = require("nvim-autopairs")
		local npairs_rule = require("nvim-autopairs.rule")
		local cond = require('nvim-autopairs.conds')

		npairs.setup()

		npairs.add_rule(
			npairs_rule('r#"', '"#', "rust")
			:with_pair(cond.not_after_regex('"#'))
			:with_pair(cond.not_before_regex('r#"', 3))
			:with_move(function(opts)
				return opts.next_char == '"#'
			end)
		)
		npairs.add_rule(
			npairs_rule("|", "|", "rust")
			:with_pair(cond.not_after_regex('|'))
			:with_pair(cond.not_before_regex('|', 1))
			:with_move(function(opts)
				return opts.next_char == '|'
			end)
		)
	end,
}
