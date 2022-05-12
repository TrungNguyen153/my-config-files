local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
---@diagnostic disable-next-line: unused-local
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({
			extra_args = {
				"--no-semi",
				"--single-quote",
				"--jsx-single-quote",
			},
			prefer_local = "node_modules/.bin",
		}),
		diagnostics.eslint.with({
			prefer_local = "node_modules/.bin",
		}),
		-- formatting.black.with({ extra_args = { "--fast" } }),
		-- formatting.gofmt,
		formatting.shfmt,
		formatting.clang_format,
		formatting.cmake_format,
		formatting.dart_format,
		-- formatting.lua_format.with({
		--   extra_args = {
		--     '--no-keep-simple-function-one-line', '--no-break-after-operator', '--column-limit=100',
		--     '--break-after-table-lb', '--indent-width=2'
		--   }
		-- }),
		formatting.stylua,
		formatting.isort,
		formatting.codespell.with({ filetypes = { "markdown" } }),
    -- code_actions.gitsigns, // Not helpful
	},
})
