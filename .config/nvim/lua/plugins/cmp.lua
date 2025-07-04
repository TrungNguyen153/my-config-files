-- auto completion and snippets
return {
	"saghen/blink.cmp", -- auto completion
	version = '1.*',
	enabled = not vim.g.vscode,
	event = "VeryLazy",
	dependencies = {
		"rafamadriz/friendly-snippets", -- snippets for many languages
		"chrisgrieser/nvim-scissors", -- snippet editor
		"xzbdmw/colorful-menu.nvim", -- adds highlights to the auto-complete options
		'Kaiser-Yang/blink-cmp-avante', -- avante ai
	},
	config = function()
		require("colorful-menu").setup({})
		local custom_snippets_folder = vim.fn.stdpath("config") .. "/snippets"
		require("scissors").setup({
			snippetDir = custom_snippets_folder,
		})
		

		local disabled_filetypes = { "minifiles" }

		require("blink.cmp").setup({
			-- Disable for some filetypes
			enabled = function()
				return vim.bo.buftype ~= "prompt"
					and vim.b.completion ~= false
					and not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
			end,
			signature = { enabled = true },
			
			sources = {
				default = function()
					local success, node = pcall(vim.treesitter.get_node)
					local is_comment = success
						and node
						and vim.tbl_contains(
							{ 'avante', "comment", "line_comment", "block_comment", "doc", "doc_comment" },
							node:type()
						)
					if is_comment then
						return { "lsp", "buffer", "path" }
					else
						return { "lsp", "snippets", "path" }
					end
				end,
				providers = {
					avante = {
						module = 'blink-cmp-avante',
						name = 'Avante',
						opts = {
							-- options for blink-cmp-avante
						}
					}
				},
			},
			completion = {
				ghost_text = { enabled = true },
				accept = {
					dot_repeat = true,
					
				},
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				documentation = {
					auto_show = true,
				},
				trigger = {
					show_in_snippet = true,
				},
				menu = {
					auto_show = function(ctx)
						return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
					end,
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon", 	gap = 1 },
							{ "label", 		gap = 3 },
							{ "item_idx", 	gap = 1 },
							{ "source_name" },
						},
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
							item_idx = {
								text = function(ctx)
									return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx",
							},
							source_name = {
								text = function(ctx)
									return "[" .. ctx.source_name .. "]"
								end,
							},
						},
					},
				},
			},
			fuzzy = {
				sorts = { 'exact', "score", "sort_text", "kind", "label" },
			},
			cmdline = {
				completion = {
					list = {
                        selection = {
                            preselect = false,
                            auto_insert = true,
                        },
                    },
                    menu = {
                        auto_show = true,
                    },
                },
                keymap = { -- https://github.com/neovim/neovim/issues/21585
                    ['<C-space>'] = { 'show' },
                    ['<CR>'] = { 'fallback' },
                    ['<Tab>'] = { 'show', 'select_next', 'fallback' },
                    ['<S-Tab>'] = { 'select_prev', 'fallback' },
                    ['<Esc>'] = {
                        'cancel',
                        function()
                            if vim.fn.getcmdtype() ~= '' then
                                vim.api.nvim_feedkeys(
                                    vim.api.nvim_replace_termcodes('<C-c>', true, true, true),
                                    'n',
                                    true
                                )
                                return
                            end
                        end,
                    },
                },
            },

			keymap = {
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<Esc>"] = { "cancel", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },

				["<Tab>"] = {
					"select_next",
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = {
					"select_prev",
					"snippet_backward",
					"fallback",
				},
				["<A-1>"] = {
					function(cmp)
						cmp.accept({ index = 1 })
					end,
				},
				["<A-2>"] = {
					function(cmp)
						cmp.accept({ index = 2 })
					end,
				},
				["<A-3>"] = {
					function(cmp)
						cmp.accept({ index = 3 })
					end,
				},
				["<A-4>"] = {
					function(cmp)
						cmp.accept({ index = 4 })
					end,
				},
				["<A-5>"] = {
					function(cmp)
						cmp.accept({ index = 5 })
					end,
				},
				["<A-6>"] = {
					function(cmp)
						cmp.accept({ index = 6 })
					end,
				},
				["<A-7>"] = {
					function(cmp)
						cmp.accept({ index = 7 })
					end,
				},
				["<A-8>"] = {
					function(cmp)
						cmp.accept({ index = 8 })
					end,
				},
				["<A-9>"] = {
					function(cmp)
						cmp.accept({ index = 9 })
					end,
				},
				["<A-0>"] = {
					function(cmp)
						cmp.accept({ index = 10 })
					end,
				},
			},
			appearance = {
				highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = false,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "normal",
				kind_icons = {
					Text = "",
					Method = "󰊕",
					Function = "󰊕",
					Constructor = "",
					Field = "󰜢",
					Variable = "",
					Class = "",
					Interface = "",
					Module = "",
					Property = "",
					Unit = "",
					Value = "",
					Enum = "",
					Keyword = "󱕴",
					Snippet = "",
					Color = "",
					File = "",
					Reference = "",
					Folder = "",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "",
					Event = "",
					Operator = "",
					TypeParameter = "",
					Boolean = " ",
					Array = " ",
				},
			},
		})

		-- create commands to manage snippets
		vim.api.nvim_create_user_command("SnippetAdd", function()
			require("scissors").addNewSnippet()
		end, {})
		vim.api.nvim_create_user_command("SnippetEdit", function()
			require("scissors").editSnippet()
		end, {})
	end,
}
