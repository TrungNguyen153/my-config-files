return {
	setup = function()
		vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal"
		require("auto-session").setup({
			log_level = "error",
			auto_session_enable_last_session = false,
			auto_session_enabled = true, -- enables auto save and auto restore
			auto_restore_enabled = true, -- enables auto restore if session for cwd exists
			auto_session_create_enabled = false, -- disables auto session creation
			cwd_change_handling = {
				restore_upcoming_session = true,
				pre_cwd_changed_hook = function()
					require("sidebar"):close()
				end,
				post_cwd_changed_hook = function()
					require("lualine").refresh()
				end,
			},
			session_lens = {
				theme_conf = { border = false },
				previewer = true,
			},
		})
	end,
}
