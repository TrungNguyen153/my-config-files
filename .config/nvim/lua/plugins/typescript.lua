-- typescript enhancements

return {
	"pmizio/typescript-tools.nvim",
	enabled = not vim.g.vscode,
	ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	config = function()
		
		require("typescript-tools").setup({
			settings = {
				code_lens = "all",
				tsserver_file_preferences = {
					includeCompletionsForModuleExports = true,
					includeCompletionsForImportStatements = true,
					includeCompletionsWithSnippetText = true,
					includeAutomaticOptionalChainCompletions = true,
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					quotePreference = "auto",
				},
			},
		})
	end,
}
