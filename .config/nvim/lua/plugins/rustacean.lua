-- rust enhancements

return {
	"mrcjkb/rustaceanvim",
	enabled = not vim.g.vscode,
	dependencies = {
		"Saecki/crates.nvim", -- auto complete for Cargo.toml
		"nvim-lua/plenary.nvim", -- its a dependency from crates.nvim
	},
	lazy = false, -- the plugin is already lazy
	init = function()
		
		vim.g.rustaceanvim = function()
			require("crates").setup({
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
				completion = {
					crates = {
						enabled = true,
					},
				},
			})
			local executors = require('rustaceanvim.executors')
			return {
				tools = {
					--- options right now: termopen / quickfix / toggleterm / vimux
					executor = executors.toggleterm,
					test_executor = executors.toggleterm,
					crate_test_executor = executors.toggleterm,
					reload_workspace_from_cargo_toml = true,
					hover_actions = {
						replace_builtin_hover = false,
					},
					float_win_config = {
						auto_focus = true,
					},
				},
				server = {
					standalone = false,
					settings = {
						["rust-analyzer"] = {
							diagnostics = {
								enable = true,
								enableExperimental = true,
							},
							completion = {
								autoself = { enable = true },
								autoimport = { enable = true },
								postfix = { enable = true },
							},
							-- imports = {
							-- 	group = { enable = true },
							-- 	merge = { glob = false },
							-- 	prefix = "self",
							-- 	preferPrelude = true,
							-- 	granularity = {
							-- 		enforce = true,
							-- 		group = "crate",
							-- 	},
							-- },
							-- cargo = {
							-- 	loadOutDirsFromCheck = true,
							-- 	autoreload = true,
							-- 	runBuildScripts = true,
							-- 	features = "all",
							-- 	allTargets = true,
							-- },
							-- procMacro = {
							-- 	enable = true,
							-- 	attributes = { enable = true },
							-- },
							-- lens = {
							-- 	enable = true,
							-- 	run = { enable = true },
							-- 	debug = { enable = true },
							-- 	implementations = { enable = true },
							-- 	references = {
							-- 		adt = { enable = true },
							-- 		enumVariant = { enable = true },
							-- 		method = { enable = true },
							-- 		trait = { enable = true },
							-- 	},
							-- },
							hover = {
								actions = {
									enable = true,
									run = { enable = true },
									debug = { enable = true },
									gotoTypeDef = { enable = true },
									implementations = { enable = true },
									references = { enable = true },
								},
								links = { enable = true },
								documentation = { enable = true },
							},
							inlayHints = {
								enable = true,
								implicitDrops = { enable = false },
							},
							typing = {
								autoClosingAngleBrackets = { enable = true },
							},
							-- interpret = { tests = true },
							checkOnSave = true,
							check = {
								-- https://github.com/rust-analyzer/rust-analyzer/issues/9768
								-- command = "clippy",
								-- features = "all",
								-- allTargets = true,
							},
						},
					},
				},
			}
		end
	end,
	keys = {
		{
			"<leader>ra",
			":RustLsp hover actions<CR>",
			mode = { "n" },
			desc = "Hover Actions",
			noremap = true,
		},
		{
			"<leader>rb",
			":RustLsp moveItem down<CR>",
			mode = { "n" },
			desc = "Move Item Down",
			noremap = true,
		},
		{
			"<leader>rc",
			":RustLsp openCargo<CR>",
			mode = { "n" },
			desc = "Open Cargo.toml",
			noremap = true,
		},
		{
			"<leader>rd",
			":RustLsp debuggables<CR>",
			mode = { "n" },
			desc = "Debuggables",
			noremap = true,
		},
		{
			"<leader>rg",
			":RustLsp renderDiagnostic current<CR>",
			mode = { "n" },
			desc = "Render Diagnostic",
			noremap = true,
		},
		{
			"<leader>re",
			":RustLsp explainError current<CR>",
			mode = { "n" },
			desc = "Explain Error",
			noremap = true,
		},
		{
			"<leader>rk",
			":RustLsp crateGraph<CR>",
			mode = { "n" },
			desc = "View Crate Graph",
			noremap = true,
		},
		{
			"<leader>rh",
			":RustLsp hover range<CR>",
			mode = { "n" },
			desc = "Range Hover Actions",
			noremap = true,
		},
		{
			"<leader>rj",
			":RustLsp joinLines<CR>",
			mode = { "n" },
			desc = "Join Lines",
			noremap = true,
		},
		{
			"<leader>rm",
			":RustLsp expandMacro<CR>",
			mode = { "n" },
			desc = "Expand Macro",
			noremap = true,
		},
		{
			"<leader>rp",
			":RustLsp parentModule<CR>",
			mode = { "n" },
			desc = "Parent Module",
			noremap = true,
		},
		{
			"<leader>rx",
			":RustLsp openDocs<CR>",
			mode = { "n" },
			desc = "Open Rust Docs",
			noremap = true,
		},
		{
			"<leader>rr",
			":RustLsp runnables<CR>",
			mode = { "n" },
			desc = "Runnables",
			noremap = true,
		},
		{
			"<leader>rs",
			":RustLsp syntaxTree<CR>",
			mode = { "n" },
			desc = "View Syntax Tree",
			noremap = true,
		},
		{
			"<leader>ru",
			":RustLsp moveItem up<CR>",
			mode = { "n" },
			desc = "Move Item Up",
			noremap = true,
		},
		{
			"<leader>rc",
			":RustLsp flyCheck<CR>",
			mode = { "n" },
			desc = "Run fly check",
			noremap = true,
		},
		{
			"<leader>rC",
			":RustLsp flyCheck cancel<CR>",
			mode = { "n" },
			desc = "Clear last run fly check",
			noremap = true,
		},
		{
			"!",
			":lua vim.cmd.RustLsp { 'runnables', bang = true }<CR>",
			ft = "rust",
			mode = { "n" },
			desc = "Rerun last runnables",
			noremap = true,
			silent = true,
		},
	},
}
