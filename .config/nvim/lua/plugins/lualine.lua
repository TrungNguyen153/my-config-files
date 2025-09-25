-- status line



return {
	"nvim-lualine/lualine.nvim",
	event = "UIEnter",
	enabled = not vim.g.vscode,
	-- enabled = false,
	config = function()
		local lualine = require( 'lualine' )

		local function search_result()
			if vim.v.hlsearch == 0 then
				return ""
			end
			local last_search = vim.fn.getreg("/")
			if not last_search or last_search == "" then
				return ""
			end
			local searchcount = vim.fn.searchcount({ maxcount = 9999 })
			return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
		end

		lualine.setup({
			options = {
				icons_enabled = true,
				theme =  {
					normal = {
						---Auto generated ProjectColor based on cwd, 1st and 2nd parent dirs
						---to quickly distinguish between projects
						a = "IdeaVim_Modes_Normal",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						y = "StatusLineTintedNormal",
						---Mode dependend colors
						z = "ProjectColor",
					},
					insert = {
						a = "IdeaVim_Modes_Insert",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						y = "StatusLineTintedInsert",
						z = "ProjectColor",
					},
					visual = {
						a = "IdeaVim_Modes_Visual",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						y = "StatusLineTintedVisual",
						z = "ProjectColor",
					},
					replace = {
						a = "IdeaVim_Modes_Replace",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						y = "StatusLineTintedReplace",
						z = "ProjectColor",
					},
					command = {
						a = "IdeaVim_Modes_Normal",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						y = "StatusLineTintedNormal",
						z = "ProjectColor",
					},
					terminal = {
						a = "IdeaVim_Modes_Insert",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						x = "CustomStatusLine",
						y = "StatusLineTintedInsert",
						z = "ProjectColor",
					},
					inactive = {
						a = "IdeaVim_Modes_Normal",
						b = "StatusLineTinted",
						c = "CustomStatusLine",
						x = "CustomStatusLine",
						y = "StatusLineTintedNormal",
						z = "ProjectColor",
					},
				}, -- old is "auto"
				section_separators = { left = "", right = "" },
				-- section_separators = { left = ' ', right = ' ' },
				-- section_separators = { left = '', right = '' },
				-- section_separators = { left = '', right = '' },
				component_separators = { left = "", right = "" },
				-- component_separators = { left = '', right = '' },
				-- component_separators = { left = '', right = '' },
				-- component_separators = { left = '', right = '' },
				disabled_filetypes = {
					winbar = { "neo-tree", "packer", "help", "terminal", "toggleterm", "dap-repl" },
				},
				globalstatus = true,
			},
			sections = {
				lualine_a = { { "mode" } },
				lualine_b = { "diff", "branch", {
					"filename",
					file_status = true, -- displays file status (readonly status, modified status)
					path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
				}, },
				lualine_c = { },
				lualine_x = {
					function()
						if vim.fn.reg_recording() ~= "" then
							return "Recording @" .. vim.fn.reg_recording()
						else
							return ""
						end
					end,
					{
						require("noice").api.status.command.get,
						cond = require("noice").api.status.command.has,
						color = { fg = "#ff9e64" },
					},
					search_result,
					"encoding",
					"filetype",
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						always_visible = true,
					},
				},
				lualine_y = {
					"location",
					"progress",
				},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {
					{
						"filename",
						file_status = true, -- displays file status (readonly status, modified status)
						path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
					},
				},
				lualine_c = { },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
