local function dd(arg)
    local res = vim.inspect(arg)
    vim.notify(res)
end

local function switch_source_header(bufnr)
    local method_name = 'textDocument/switchSourceHeader'
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
    if not client then
        return vim.notify(
            ('method %s is not supported by any servers active on the current buffer'):format(method_name)
        )
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    ---@diagnostic disable-next-line: param-type-mismatch
    client.request(method_name, params, function(err, result)
        if err then
            error(tostring(err))
        end
        if not result then
            vim.notify('corresponding file cannot be determined')
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end

local function symbol_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
    ---@diagnostic disable-next-line: param-type-mismatch
    if not clangd_client or not clangd_client.supports_method('textDocument/symbolInfo') then
        return vim.notify('Clangd client not found', vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
    ---@diagnostic disable-next-line: param-type-mismatch
    clangd_client.request('textDocument/symbolInfo', params, function(err, res)
        if err or #res == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format('container: %s', res[1].containerName) ---@type string
        local name = string.format('name: %s', res[1].name) ---@type string
        vim.lsp.util.open_floating_preview({ name, container }, '', {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = 'single',
            title = 'Symbol Info',
        })
    end, bufnr)
end

return {
    lsp_autocmds = function(client, bufnr)
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, { clear = false })
        end

        vim.api.nvim_buf_create_user_command(0, 'ClangdSwitchSourceHeader', function()
            switch_source_header(0)
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'ClangdShowSymbolInfo', function()
            symbol_info()
        end, { desc = 'Show symbol info' })
    end,
    setup = function()
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, { clear = true })
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
            callback = function(args)
                local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
                if ok and parser then
                vim.treesitter.start(args.buf)
                -- optional: treesitter-based folds and indent
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        autocmd({ 'BufRead' }, {
            desc = "Prevent accidental writes to buffers that shouldn't be edited",
            pattern = '*.orig',
            command = 'set readonly',
        })

        autocmd({ 'TextYankPost' }, {
            desc = 'Highlight yanked text',
            pattern = '*',
            callback = function()
                vim.hl.on_yank({ higroup = 'IncSearch', timeout = 200 })
            end,
        })

        autocmd({ 'BufReadPost' }, {
            group = augroup('LastPlace'),
            pattern = { '*' },
            desc = 'When editing a file, always jump to the last known cursor position',
            callback = function()
                local exclude = { 'gitcommit', 'commit', 'gitrebase' }
                if vim.tbl_contains(exclude, vim.bo.filetype) then
                    return
                end
                local line = vim.fn.line('\'"')
                if line >= 1 and line <= vim.fn.line('$') then
                    vim.cmd('normal! g`"')
                end
            end,
        })

        autocmd({ 'BufRead', 'BufNewFile' }, {
            pattern = { 'CMakeLists.txt', '*.cmake' },
            command = 'set filetype=cmake',
        })

        -- Do not conceal JSON files
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'json', 'jsonc', 'json5' },
            callback = function()
                vim.opt_local.conceallevel = 0
            end,
        })

        -- close those buffer when press 'q'
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'qf', 'help', 'checkhealth', 'dap-repl', 'toggleterm', 'dbout' },
            callback = function()
                vim.keymap.set('n', 'q', '<cmd>bd!<cr>', { silent = true, buffer = true })
            end,
        })

        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
                vim.b.copilot_suggestion_hidden = true
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuClose',
            callback = function()
                vim.b.copilot_suggestion_hidden = false
            end,
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

        local set_file_type_group = augroup('SetCTFileType')
        autocmd('BufEnter', {
            group = set_file_type_group,
            pattern = '*.slint',
            command = 'setlocal filetype=slint',
        })

        -- Resizes
        vim.api.nvim_create_user_command('Vr', function(opts)
            local usage = 'Usage: [VirticalResize] :Vr {number (%)}'
            if not opts.args or not string.len(opts.args) == 2 then
                print(usage)
                return
            end
            vim.cmd(':vertical resize ' .. vim.opt.columns:get() * (opts.args / 100.0))
        end, { nargs = '*' })

        vim.api.nvim_create_user_command('Hr', function(opts)
            local usage = 'Usage: [HorizontalResize] :Hr {number (%)}'
            if not opts.args or not string.len(opts.args) == 2 then
                print(usage)
                return
            end
            vim.cmd(':resize ' .. ((vim.opt.lines:get() - vim.opt.cmdheight:get()) * (opts.args / 100.0)))
        end, { nargs = '*' })

        -- CodeCompanion event hooks
        local cc_group = augroup('CodeCompanionHooks')

        -- Register per-chat callbacks on creation
        autocmd('User', {
            group = cc_group,
            pattern = 'CodeCompanionChatCreated',
            callback = function(ev)
                local ok, cc = pcall(require, 'codecompanion')
                if not ok then
                    return
                end

                local chat = cc.buf_get_chat(ev.buf)
                if not chat then
                    return
                end

                -- Token usage warning at 80%
                chat:add_callback('on_checkpoint', function(c, data)
                    if not data or not data.estimated_tokens or not data.adapter then
                        return
                    end
                    local ctx_window = data.adapter.meta and data.adapter.meta.context_window or 200000
                    local pct = (data.estimated_tokens / ctx_window) * 100
                    if pct >= 80 then
                        vim.schedule(function()
                            vim.notify(
                                string.format(
                                    'Token usage: %.0f%% (%d/%d) — consider /compact or new chat',
                                    pct,
                                    data.estimated_tokens,
                                    ctx_window
                                ),
                                pct >= 95 and vim.log.levels.ERROR or vim.log.levels.WARN
                            )
                        end)
                    end
                end)

                -- Truncate oversized tool outputs
                chat:add_callback('on_tool_output', function(c, data)
                    if not data or not data.for_llm then
                        return
                    end
                    local max_len = 50000
                    if #data.for_llm > max_len then
                        data.for_llm = data.for_llm:sub(1, max_len)
                            .. '\n\n[TRUNCATED — '
                            .. (#data.for_llm - max_len)
                            .. ' chars removed to preserve context]'
                        vim.schedule(function()
                            vim.notify('Tool output truncated to preserve context window', vim.log.levels.INFO)
                        end)
                    end
                end)
            end,
        })

        -- Notification when all tools finish
        autocmd('User', {
            group = cc_group,
            pattern = 'CodeCompanionToolsFinished',
            callback = function()
                vim.schedule(function()
                    vim.notify('Tools finished', vim.log.levels.INFO)
                end)
            end,
        })
    end,
}
