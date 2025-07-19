-- https://github.com/aaronlifton/.config/blob/main/.config/nvim/lua/plugins/extras/coding/multicursor.lua


return {
	"jake-stewart/multicursor.nvim",
	event = "VeryLazy",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")

		mc.setup()

		-- Add next matching cursor
		vim.keymap.set({ "n", "v" }, "m", function()
			mc.matchAddCursor(1)
		end)

		-- Skip next matching cursor
		vim.keymap.set({ "n", "v" }, "<leader>m", function()
			mc.matchSkipCursor(1)
		end)

		-- Add previous matching cursor
		vim.keymap.set({ "n", "v" }, "M", function()
			mc.matchAddCursor(-1)
		end)

		-- Skip previous matching cursor
		vim.keymap.set({ "n", "v" }, "<leader>M", function()
			mc.matchSkipCursor(-1)
		end)

		vim.keymap.set("n", "<esc>", function()
			if not mc.cursorsEnabled() then
			  mc.addCursor()
			  mc.enableCursors()
			else
			  -- Default <esc> handler.
			end
		end)
	  
		vim.keymap.set("n", "<C-c>", function()
			if mc.hasCursors() then
				mc.clearCursors()
			else
				-- Default <C-c> handler.
			end
		end)

		-- Visual mode operations
		vim.keymap.set("v", "I", mc.insertVisual)
		vim.keymap.set("v", "A", mc.appendVisual)

		-- Jumplist support
		vim.keymap.set({ "v", "n" }, "<c-i>", mc.jumpForward)
		vim.keymap.set({ "v", "n" }, "<c-o>", mc.jumpBackward)

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
