
function debounce(fn, debounce_time)
	local timer = vim.loop.new_timer()
	local is_debounce_fn = type(debounce_time) == "function"
  
	return function(...)
	  timer:stop()
  
	  local time = debounce_time
	  local args = { ... }
  
	  if is_debounce_fn then
		time = debounce_time()
	  end
  
	  timer:start(
		time,
		0,
		vim.schedule_wrap(function()
		  fn(unpack(args))
		end)
	  )
	end
end

return {
	term_autocmds = function()
		local autocmd = vim.api.nvim_create_autocmd
		local augroup = function(name)
			return vim.api.nvim_create_augroup(name, { clear = true })
		end

		local termgroup = augroup("ToggleTerm")

		autocmd({ "TermOpen" }, {
			desc = "Set terminal keymaps",
			pattern = "term://*",
			group = termgroup,
			callback = function()
				-- vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
				local opts = { noremap = true }
				vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "jj", [[<C-\><C-n>]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
				if not vim.g.SessionLoad then
					vim.cmd(":startinsert")
				end
			end,
		})
		autocmd({ "BufEnter" }, {
			desc = "Set terminal to insert mode",
			group = termgroup,
			pattern = "term://*",
			callback = function()
				if not vim.g.SessionLoad then
					vim.cmd(":startinsert")
				end
			end,
		})
	end,
	lsp_autocmds = function(client, bufnr)
		local autocmd = vim.api.nvim_create_autocmd
		local augroup = function(name)
			return vim.api.nvim_create_augroup(name, { clear = false })
		end
		if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
			local group = augroup("LSPRefreshLens")

			-- Code Lens
			autocmd({ "BufEnter", "InsertLeave" }, {
				desc = "Auto show code lenses",
				buffer = bufnr,
                callback = function()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                end,
				group = group,
			})
		end
		if client.server_capabilities.document_highlight or client.server_capabilities.documentHighlightProvider then
			local group = augroup("LSPHighlightSymbols")

			-- Highlight text at cursor position
			-- autocmd({ "CursorHold", "CursorHoldI" }, {
			-- 	desc = "Highlight references to current symbol under cursor",
			-- 	buffer = bufnr,
			-- 	callback = vim.lsp.buf.document_highlight,
			-- 	group = group,
			-- })
			autocmd({ "CursorMoved", "CursorMovedI" }, {
				desc = "Clear highlights when cursor is moved",
				buffer = bufnr,
				callback = debounce(function()
						vim.lsp.buf.clear_references()
						vim.lsp.buf.document_highlight()
				end, 500),
				group = group,
			})
		end
		-- Format on save but not sure want use or not... really laggy
		if client.server_capabilities.document_formatting or client.server_capabilities.documentFormattingProvider then
			local group = augroup("LSPAutoFormat")

			-- auto format file on save
			autocmd({ "BufWritePre" }, {
				desc = "Auto format file before saving",
				buffer = bufnr,
				-- command = "silent! undojoin | lua vim.lsp.buf.format({timeout = 200, filter = function(client) return client.name ~= \"rust_analyzer\" end})",
				command = "silent! undojoin | lua vim.lsp.buf.format({timeout = 200})",
				group = group,
			})
		end
		-- local group = augroup("LSPDianostics")
		-- autocmd({ "CursorHold", "CursorHoldI" }, {
		-- 	desc = "Show box with diagnostics for current line",
		-- 	pattern = "*",
		-- 	callback = function()
		-- 		local float_opts = {
		-- 			focusable = false,
		-- 			close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
		-- 			border = "rounded",
		-- 			source = "always", -- show source in diagnostic popup window
		-- 			prefix = " ",
		-- 		  }
		-- 		vim.diagnostic.open_float(nil, float_opts)
		-- 	end,
		-- 	group = group,
		-- })
	end,
	setup = function()
		local autocmd = vim.api.nvim_create_autocmd
		local augroup = function(name)
			return vim.api.nvim_create_augroup(name, { clear = true })
		end

		autocmd({ "ModeChanged" }, {
			desc = "Stop snippets when you leave to normal mode",
			pattern = "*",
			callback = function()
				if
					((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
					and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
					and not require("luasnip").session.jump_active
				then
					require("luasnip").unlink_current()
				end
			end,
		})

		autocmd({ "BufRead" }, {
			desc = "Prevent accidental writes to buffers that shouldn't be edited",
			pattern = "*.orig",
			command = "set readonly",
		})

		autocmd({ "TextYankPost" }, {
			desc = "Highlight yanked text",
			pattern = "*",
			callback = function()
				require("vim.highlight").on_yank({ higroup = "IncSearch", timeout = 100 })
			end,
		})

		autocmd({ "OptionSet" }, {
			desc = " Automatically switch theme to dark/light when background set",
			pattern = "background",
			callback = function()
				vim.cmd("Catppuccin " .. (vim.v.option_new == "light" and "latte" or "mocha"))
			end,
		})


		autocmd({"FileType"}, {
			desc = "q for quit floating widget dap windows",
			pattern = "dap-float",
			command = "nnoremap <buffer><silent> q <cmd>close!<CR>",
		})

	end,
}
