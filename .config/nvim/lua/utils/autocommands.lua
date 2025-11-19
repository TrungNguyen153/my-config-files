local function dd(arg)
    local res = vim.inspect(arg)
    vim.notify(res)
end

local function switch_source_header(bufnr)
    local method_name = 'textDocument/switchSourceHeader'
    local client = vim.lsp.get_clients({bufnr = bufnr, name = 'clangd'})[1]
    if not client then
        return vim.notify(
                   ('method %s is not supported by any servers active on the current buffer'):format(
                       method_name))
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client.request(method_name, params, function(err, result)
        if err then error(tostring(err)) end
        if not result then
            vim.notify('corresponding file cannot be determined')
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end

local function symbol_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client =
        vim.lsp.get_clients({bufnr = bufnr, name = 'clangd'})[1]
    if not clangd_client or
        not clangd_client.supports_method 'textDocument/symbolInfo' then
        return vim.notify('Clangd client not found', vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win,
                                                     clangd_client.offset_encoding)
    clangd_client.request('textDocument/symbolInfo', params, function(err, res)
        if err or #res == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format('container: %s', res[1].containerName) ---@type string
        local name = string.format('name: %s', res[1].name) ---@type string
        vim.lsp.util.open_floating_preview({name, container}, '', {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = 'single',
            title = 'Symbol Info'
        })
    end, bufnr)
end

function lsp_autocmds(client, bufnr)
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = function(name)
        return vim.api.nvim_create_augroup(name, {clear = false})
    end
    if client.server_capabilities.code_lens or
        client.server_capabilities.codeLensProvider then
        local group = augroup("LSPRefreshLens")

        -- Code Lens
        autocmd({"BufEnter", "InsertLeave"}, {
            desc = "Auto show code lenses",
            buffer = bufnr,
            callback = function()
                vim.lsp.codelens.refresh({bufnr = bufnr})
            end,
            group = group
        })
    end
    if client.server_capabilities.document_highlight or
        client.server_capabilities.documentHighlightProvider then
        local group = augroup("LSPHighlightSymbols")

        -- Highlight text at cursor position
        autocmd({"CursorHold", "CursorHoldI"}, {
            desc = "Highlight references to current symbol under cursor",
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
            group = group
        })
        autocmd({"CursorMoved"}, {
            desc = "Clear highlights when cursor is moved",
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
            group = group
        })
    end
    if client.server_capabilities.document_formatting or
        client.server_capabilities.documentFormattingProvider then
        local group = augroup("LSPAutoFormat")
        -- set the autoformat flag
        vim.b.autoformat = vim.g.autoformat

        -- auto format file on save
        autocmd({"BufWritePre"}, {
            desc = "Auto format file before saving",
            buffer = bufnr,
            callback = function()
                if vim.b.autoformat then
                    vim.lsp.buf.format({async = false})
                end
            end,
            group = group
        })
    end

    -- autocmd({ "CursorHold", "CursorHoldI" }, {
    -- 	desc = "Show box with diagnostics for current line",
    -- 	pattern = "*",
    -- 	callback = function()
    -- 		vim.diagnostic.open_float({ focusable = false })
    -- 	end,
    -- 	group = augroup("LSPDianostics"),
    -- })

    vim.api.nvim_buf_create_user_command(0, 'ClangdSwitchSourceHeader',
        function() switch_source_header(0) end,
        {desc = 'Switch between source/header'})

    vim.api.nvim_buf_create_user_command(0, 'ClangdShowSymbolInfo',
        function() symbol_info() end,
        {desc = 'Show symbol info'})
end

return {
    setup = function()
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, {clear = true})
        end

        autocmd({"BufRead"}, {
            desc = "Prevent accidental writes to buffers that shouldn't be edited",
            pattern = "*.orig",
            command = "set readonly"
        })

        autocmd({"TextYankPost"}, {
            desc = "Highlight yanked text",
            pattern = "*",
            callback = function()
                vim.hl.on_yank { higroup = "IncSearch", timeout = 200 }
                -- local v = vim.v.event
                -- local regcontents = v.regcontents
                -- vim.defer_fn(function()
                --     vim.fn.setreg("+", regcontents)
                --     vim.notify(vim.inspect(regcontents))
                -- end, 100)
            end
        })

        -- sync system clipboard to vim clipboard
        -- vim.api.nvim_create_autocmd("FocusGained", {
        --     callback = function()
        --         local loaded_content = vim.fn.getreg("+")
        --         if loaded_content ~= "" then
        --             vim.fn.setreg('"', loaded_content)
        --             vim.notify(vim.inspect(loaded_content))
        --         end
        --     end,
        -- })


        autocmd({'BufReadPost'}, {
            group = augroup('LastPlace'),
            pattern = {'*'},
            desc = 'When editing a file, always jump to the last known cursor position',
            callback = function()
                local exclude = {'gitcommit', 'commit', 'gitrebase'}
                if vim.tbl_contains(exclude, vim.bo.filetype) then
                    return
                end
                local line = vim.fn.line('\'"')
                if line >= 1 and line <= vim.fn.line('$') then
                    vim.cmd('normal! g`"')
                end
            end
        })

        autocmd({"BufRead", "BufNewFile"}, {
            pattern = {"CMakeLists.txt", "*.cmake"},
            command = "set filetype=cmake"
        })

		-- close those buffer when press 'q'
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'qf', 'help', 'checkhealth', 'dap-repl', 'toggleterm', 'dbout' },
            callback = function()
                vim.keymap.set('n', 'q', '<cmd>bd!<cr>', { silent = true, buffer = true })
            end,
        })

		vim.api.nvim_create_autocmd("User", {
			pattern = "BlinkCmpMenuOpen",
			callback = function()
				vim.b.copilot_suggestion_hidden = true
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			pattern = "BlinkCmpMenuClose",
			callback = function()
				vim.b.copilot_suggestion_hidden = false
			end,
		})

        autocmd({"LspAttach"}, {
            group = augroup('LspAttachClient'),
            callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                local buf = args.buf
                if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint.is_enabled({}) then
                    vim.lsp.inlay_hint.enable(true, {bufnr = buf})
                end
                lsp_autocmds(client, buf)
            end
        })

        local fold_group = augroup('Folds')
        local IGNORE_FILETYPES = {
            ['lazy_backdrop'] = true,
            ['snacks_layout_box'] = true,
            ['snacks_picker_input'] = true,
            ['snacks_picker_list'] = true,
            ['snacks_picker_preview'] = true,
            ['snacks_win_backdrop'] = true,
            ['vim-messages'] = true,
            checkhealth = true,
            fugitive = true,
            git = true,
            gitcommit = true,
            help = true,
            lazy = true,
            lspinfo = true,
            mason = true,
            minifiles = true,
            mininotify = true,
            terminal = true,
            vim = true,
        }

        -- Save view when leaving a buffer
        autocmd('BufWinLeave', {
            group = fold_group,
            callback = function(ev)
                local ft = vim.bo[ev.buf].filetype
                if ft == '' or IGNORE_FILETYPES[ft] then
                    return
                end

                vim.cmd.mkview({ mods = { emsg_silent = true } })
            end,
        })

        -- Load view when entering a buffer
        autocmd('BufWinEnter', {
            group = fold_group,
            callback = function(ev)
                local ft = vim.bo[ev.buf].filetype
                if ft == '' or IGNORE_FILETYPES[ft] then
                    return
                end

                vim.cmd.loadview({ mods = { emsg_silent = true } })
            end,
        })

        -- Resizes
        vim.api.nvim_create_user_command("Vr", function(opts)
            local usage = "Usage: [VirticalResize] :Vr {number (%)}"
            if not opts.args or not string.len(opts.args) == 2 then
                print(usage)
                return
            end
            vim.cmd(":vertical resize " .. vim.opt.columns:get() * (opts.args / 100.0))
        end, { nargs = "*" })

        vim.api.nvim_create_user_command("Hr", function(opts)
            local usage = "Usage: [HorizontalResize] :Hr {number (%)}"
            if not opts.args or not string.len(opts.args) == 2 then
                print(usage)
                return
            end
            vim.cmd(
                ":resize "
                    .. (
                        (vim.opt.lines:get() - vim.opt.cmdheight:get())
                        * (opts.args / 100.0)
                    )
            )
        end, { nargs = "*" })

    end
}
