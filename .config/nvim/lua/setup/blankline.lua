return {
	setup = function()
		require("indent_blankline").setup({
			char = "┆",
			filetype_exclude = { "packer", "startup" },
			buftype_exclude = { "terminal" },
			show_current_context = true,
			show_current_context_start = true,
		})
	end,
}