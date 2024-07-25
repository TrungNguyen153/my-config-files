return {
	setup = function(on_attach)
		require("refactoring").setup({})
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.shfmt,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.diagnostics.hadolint,
				null_ls.builtins.diagnostics.ktlint,
				null_ls.builtins.diagnostics.write_good,
				null_ls.builtins.diagnostics.pylint,
				null_ls.builtins.diagnostics.yamllint,
				null_ls.builtins.diagnostics.vale.with({
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
				null_ls.builtins.code_actions.refactoring.with({
					filetypes = { "go", "javascript", "lua", "python", "typescript", "svelte", "ruby", "java" },
				}),
			},
			on_attach = on_attach,
		})
	end,
}
