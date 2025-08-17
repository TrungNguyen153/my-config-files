-- rust enhancements

---@type integer | nil
local latest_buf_id = nil

---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, opts)
    local shell = require('rustaceanvim.shell')
    local ui = require('rustaceanvim.ui')
    local commands = {}
    if cwd then
      table.insert(commands, shell.make_cd_command(cwd))
    end
    table.insert(commands, shell.make_command_from_args(command, args))
    local full_command = shell.chain_commands(commands)

    -- check if a buffer with the latest id is already open, if it is then
    -- delete it and continue
    ui.delete_buf(latest_buf_id)

    -- create the new buffer
    latest_buf_id = vim.api.nvim_create_buf(false, true)

    -- split the window to create a new buffer and set it to our window
    ui.split(false, latest_buf_id)

    -- make the new buffer smaller
    ui.resize(false, '-5')

    -- close the buffer when escape is pressed :)
    vim.keymap.set('n', '<Esc>', '<CMD>q<CR>', { buffer = latest_buf_id, noremap = true })
	vim.keymap.set('n', 'q', '<CMD>q<CR>', { buffer = latest_buf_id, noremap = true })

    vim.fn.jobstart(full_command, { term = true, env = opts.env })

    -- when the buffer is closed, set the latest buf id to nil else there are
    -- some edge cases with the id being sit but a buffer not being open
    local function onDetach(_, _)
      latest_buf_id = nil
    end
    vim.api.nvim_buf_attach(latest_buf_id, false, { on_detach = onDetach })
  end,
}

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
					executor = M,
					test_executor = M,
					crate_test_executor = M,
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
							rustfmt = {
								extraArgs = {"+nightly"},
							},
							diagnostics = {
								enable = true,
								enableExperimental = false,
								disabled = {"unresolved-proc-macro"},
							},
							completion = {
								autoself = { enable = true },
								autoimport = { enable = true },
								postfix = { enable = true },
							},
							imports = {
								group = { enable = true },
								merge = { glob = false },
								prefix = "self",
								preferPrelude = true,
								granularity = {
									enforce = true,
									group = "crate",
								},
							},
							-- cargo = {
							-- 	loadOutDirsFromCheck = true,
							-- 	autoreload = true,
							-- 	runBuildScripts = true,
							-- 	features = "all",
							-- 	allTargets = true,
							-- },
							procMacro = {
								enable = true,
								attributes = { enable = true },
							},
							lens = {
								enable = true,
								run = { enable = true },
								debug = { enable = true },
								implementations = { enable = true },
								references = {
									adt = { enable = false },
									enumVariant = { enable = false },
									method = { enable = false },
									trait = { enable = false },
								},
							},
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
								command = "clippy",
								features = "all",
								allTargets = true,
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
