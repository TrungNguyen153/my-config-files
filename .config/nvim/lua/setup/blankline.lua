return {
	setup = function()
		-- require("ibl").setup()
		-- require("indent_blankline").setup({
		-- 	char = "┆",
		-- 	filetype_exclude = { "packer", "lazy", "startup" },
		-- 	buftype_exclude = { "terminal" },
		-- 	show_current_context = true,
		-- 	show_current_context_start = true,
		-- })
		require('ibl').setup({
            indent = {
                char = '│',
            },
            exclude = {
                filetypes = { 'packer', 'startup', 'noice' },
                buftypes = { 'terminal' },
            },
            scope = {
                enabled = true,
            },
		})
	end,
}
