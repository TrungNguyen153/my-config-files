-- https://github.com/aaronlifton/.config/blob/main/.config/nvim/lua/plugins/extras/coding/multicursor.lua

return {
	"jake-stewart/multicursor.nvim",
	event = "VeryLazy",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")

		mc.setup()

		local set = vim.keymap.set

		-- Add next matching cursor
		set({ "n", "v" }, "m", function()
			mc.matchAddCursor(1)
		end)

		-- Skip next matching cursor
		set({ "n", "v" }, "<leader>m", function()
			mc.matchSkipCursor(1)
		end)

		-- Add previous matching cursor
		set({ "n", "v" }, "M", function()
			mc.matchAddCursor(-1)
		end)

		-- Skip previous matching cursor
		set({ "n", "v" }, "<leader>M", function()
			mc.matchSkipCursor(-1)
		end)

		-- Toggle/clear cursors
		local exit_fn = function()
			if not mc.cursorsEnabled() then
				mc.enableCursors()
			elseif mc.hasCursors() then
				mc.clearCursors()
			else
				-- Default <esc> handler.
			end
		end
		set("n", "<esc>", exit_fn)
		set("n", "<C-c>", exit_fn)

		-- Visual mode operations
		set("v", "I", mc.insertVisual)
		set("v", "A", mc.appendVisual)

		-- Customize how cursors look.
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Cursor" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	
	
	end,
}
