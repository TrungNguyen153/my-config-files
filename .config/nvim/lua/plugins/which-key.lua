-- Shows hints for the keybindings in a floating window.

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "󰔰", -- symbol used between a key and it's label
			group = "󰊳 ", -- symbol
		},
		-- Group labels only. Entries under `keys` would become real mappings.
		spec = {
			{ "<leader>c", group = "CMake / Code" },
			{ "<leader>g", group = "Git" },
			{ "<leader>h", group = "Gitsigns", mode = { "n", "v" } },
			{ "<leader>l", group = "LSP" },
			{ "<leader>p", group = "Grep" },
			{ "<leader>r", group = "Rust" },
			{ "<leader>t", group = "Trouble" },
			{ "<leader>v", group = "Vim" },
			{ "<leader>w", group = "Session" },
		},
	},
}
