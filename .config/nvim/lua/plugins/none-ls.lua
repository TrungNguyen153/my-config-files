-- can be useful to integrate with non LSP sources like eslint

return {
	"nvimtools/none-ls.nvim",
	event = "VeryLazy",
	enabled = not vim.g.vscode,
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local none_ls = require("null-ls")
		none_ls.setup({
			sources = {
				-- Python stuff
				require("none-ls.diagnostics.ruff"),
				require("none-ls.formatting.ruff"),
				-- End python stuff
				-- none_ls.builtins.formatting.prettier,
				none_ls.builtins.formatting.fish_indent,
				none_ls.builtins.formatting.markdownlint,
				none_ls.builtins.formatting.shfmt,
				none_ls.builtins.formatting.stylua.with({
					extra_args = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
				}),
				none_ls.builtins.diagnostics.actionlint,
				none_ls.builtins.diagnostics.codespell.with({
					filetypes = { "markdown", "tex", "asciidoc", "norg" },
				}),
				none_ls.builtins.diagnostics.hadolint,
				none_ls.builtins.diagnostics.write_good,
				none_ls.builtins.diagnostics.markdownlint,
				none_ls.builtins.diagnostics.yamllint,
				none_ls.builtins.diagnostics.vale.with({
					-- filetypes = {},
					diagnostics_postprocess = function(diagnostic)
						-- reduce the severity
						if diagnostic.severity == vim.diagnostic.severity["ERROR"] then
							diagnostic.severity = vim.diagnostic.severity["WARN"]
						elseif diagnostic.severity == vim.diagnostic.severity["WARN"] then
							diagnostic.severity = vim.diagnostic.severity["INFO"]
						end
					end,
				}),
				none_ls.builtins.hover.dictionary,
			},
		})
	end,
	keys = {
		
	},
}
