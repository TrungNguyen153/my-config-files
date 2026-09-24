return {
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
                vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })

        autocmd({ 'BufRead' }, {
            desc = "Prevent accidental writes to buffers that shouldn't be edited",
            pattern = '*.orig',
            command = 'setlocal readonly',
        })

        -- Reload files changed outside of Neovim (this replaces 'autoread', see
        -- settings/general.lua). 'autoread' keeps the old 'fileformat' on reload, so a
        -- file rewritten with CRLF (PowerShell's Set-Content) showed ^M on every line,
        -- and one rewritten with LF was saved back as CRLF. 'edit' reloads and
        -- re-detects it, like :e!. Unsaved edits or a deleted file still get the prompt.
        autocmd('FileChangedShell', {
            group = augroup('ReloadDetectFileformat'),
            callback = function()
                vim.v.fcs_choice = vim.v.fcs_reason == 'changed' and 'edit' or 'ask'
            end,
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
            callback = function(ev)
                if vim.bo[ev.buf].filetype ~= 'toggleterm' then
                    vim.keymap.set('n', 'q', '<cmd>bd!<cr>', { silent = true, buffer = ev.buf })
                    return
                end
                -- hide a terminal instead of killing its shell; the last window can't
                -- close, so it shows the alternate buffer (or a new one) instead
                vim.keymap.set('n', 'q', function()
                    if not pcall(vim.cmd.close) and not pcall(vim.cmd, 'buffer #') then
                        vim.cmd.enew()
                    end
                end, { silent = true, buffer = ev.buf })
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
                if ft == '' or IGNORE_FILETYPES[ft] or vim.bo[ev.buf].buftype ~= '' then
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
                if ft == '' or IGNORE_FILETYPES[ft] or vim.bo[ev.buf].buftype ~= '' then
                    return
                end

                vim.cmd.loadview({ mods = { emsg_silent = true } })
            end,
        })

        -- Keep the snacks explorer synced to the focused buffer.
        -- (The built-in `follow_file` only acts while the tree is unfocused and
        -- is unreliable, so we reveal explicitly on every real file buffer.)
        autocmd('BufEnter', {
            group = augroup('SnacksExplorerFollow'),
            desc = 'Reveal the current file in the snacks explorer',
            callback = function(ev)
                if vim.bo[ev.buf].buftype ~= '' or vim.api.nvim_buf_get_name(ev.buf) == '' then
                    return
                end
                if not _G.Snacks or not Snacks.picker then
                    return
                end
                local explorer = Snacks.picker.get({ source = 'explorer' })[1]
                if not explorer or explorer.closed then
                    return
                end
                vim.schedule(function()
                    pcall(function()
                        require('snacks.explorer').reveal({ buf = ev.buf })
                    end)
                end)
            end,
        })

        -- Resizes
        vim.api.nvim_create_user_command('Vr', function(opts)
            local pct = tonumber(opts.args)
            if not pct then
                return vim.notify('Usage: :Vr {percent}', vim.log.levels.WARN)
            end
            vim.cmd('vertical resize ' .. math.floor(vim.o.columns * pct / 100))
        end, { nargs = 1 })

        vim.api.nvim_create_user_command('Hr', function(opts)
            local pct = tonumber(opts.args)
            if not pct then
                return vim.notify('Usage: :Hr {percent}', vim.log.levels.WARN)
            end
            vim.cmd('resize ' .. math.floor((vim.o.lines - vim.o.cmdheight) * pct / 100))
        end, { nargs = 1 })

    end,
}
