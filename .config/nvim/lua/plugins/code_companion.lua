-- CodeCompanion + Claude Code ACP
--
-- Slash Commands (in chat buffer):
--   /review          — code review (visual + normal)
--   /fix-diagnostics — fix LSP errors in buffer (normal, auto-submit)
--   /refactor        — refactor selected code (visual)
--   /doc             — generate documentation (visual, auto-submit)
--   /optimize        — performance analysis (visual)
--   /test-this       — generate tests (visual + normal)
--
-- Workflows (Action Palette):
--   Edit-Test Loop   — edit code, run tests, retry until pass
--   Review Fix Test  — review → fix → test chain
--
-- Tool Groups (in chat buffer):
--   @{rust_dev}      — Rust specialist with full editing tools
--   @{reviewer}      — read-only code review agent
--
-- Keymaps:
--   <leader>aa       — open chat
--   <leader>af       — focus chat input
--   <leader>at       — toggle chat
--   <leader>ah       — chat history
--   <leader>as       — save chat
--   <leader>am       — create summary
--   <leader>ay       — browse summaries
--   gty              — toggle yolo mode (built-in)
--
local function is_floating_window(win_id)
    win_id = win_id or 0
    local win_cfg = vim.api.nvim_win_get_config(win_id)
    return win_cfg and (win_cfg.relative ~= '' or not win_cfg.relative)
end
local _claude_code

return {
    {
        'olimorris/codecompanion.nvim',
        dependencies = {
            'ravitemer/codecompanion-history.nvim',
            'mrjones2014/codecompanion-ui.nvim',
            {
                'ravitemer/mcphub.nvim',
                branch = 'main',
                dependencies = {
                    'nvim-lua/plenary.nvim',
                },
                build = 'npm install -g mcp-hub@latest', -- Installs `mcp-hub` node binary globally
                config = function()
                    require('mcphub').setup()
                end,
            },
            -- {
            --     'Davidyz/VectorCode',
            --     version = '*',
            --     build = 'uv tool upgrade vectorcode',
            --     dependencies = { 'nvim-lua/plenary.nvim' },
            --     config = function()
            --         require('vectorcode').setup({
            --             n_query = 5,
            --             exclude_this = true,
            --             notify = true,
            --             async_backend = 'lsp',
            --             on_setup = { lsp = true },
            --             async_opts = {
            --                 events = { 'BufWritePost', 'InsertEnter', 'BufReadPost' },
            --                 debounce = 10,
            --                 n_query = 3,
            --                 notify = false,
            --                 run_on_register = true,
            --             },
            --         })
            --     end,
            -- },
        },
        enabled = true,
        cmd = {
            'CodeCompanion',
            'CodeCompanionChat',
            'CodeCompanionActions',
            'CodeCompanionCmd',
            'CodeCompanionHistory',
            'CodeCompanionSummaries',
        },
        keys = {
            {
                '<leader>aa',
                function()
                    require('codecompanion').chat()
                end,
                desc = 'codecompanion: chat',
                mode = { 'n', 'v' },
                noremap = true,
                silent = true,
            },
            {
                '<leader>af',
                function()
                    if require('codecompanion-ui').is_visible() then
                        require('codecompanion-ui').focus_input()
                    else
                        -- Fallback: find any CC window
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            ---@diagnostic disable-next-line: unnecessary-if
                            if vim.bo[buf].filetype == 'codecompanion' and not is_floating_window(win) then
                                vim.api.nvim_set_current_win(win)
                                break
                            end
                        end
                    end
                end,
                desc = 'codecompanion: focus',
                noremap = true,
                silent = true,
            },
            {
                '<leader>at',
                function()
                    require('codecompanion').toggle()
                end,
                desc = 'CodeCompanion: toggle',
                noremap = true,
                silent = true,
            },
        },
        opts = {
            opts = {
                log_level = 'DEBUG',
            },
            interactions = {
                cli = {
                    agent = 'claude_code',
                    agents = {
                        claude_code = {
                            cmd = 'claude',
                            args = {},
                            description = 'Claude Code CLI',
                            provider = 'terminal',
                        },
                    },
                },
                chat = {
                    adapter = 'claude_code',
                    keymaps = {
                        close = false,
                    },
                    prompt_decorator = function(message, context)
                        local ft = context and context.filetype or vim.bo.filetype
                        local bufname = context and context.bufname or vim.api.nvim_buf_get_name(0)
                        if ft and ft ~= '' then
                            return string.format(
                                '[Context: file=%s, filetype=%s, cwd=%s]\n\n%s',
                                bufname ~= '' and vim.fn.fnamemodify(bufname, ':~:.') or 'unnamed',
                                ft,
                                vim.fn.getcwd(),
                                message
                            )
                        end
                        return message
                    end,
                    tools = {
                        -- builtin auto-approve, if use ACP adapter, those tools have no effect
                        ['file_search'] = {
                            opts = {
                                require_cmd_approval = false,
                                require_approval_before = false,
                            },
                        },
                        ['memory'] = {
                            opts = {
                                require_cmd_approval = false,
                                require_approval_before = false,
                            },
                        },
                        ['read_file'] = {
                            opts = {
                                require_cmd_approval = false,
                                require_approval_before = false,
                            },
                        },
                        ['grep_search'] = {
                            opts = {
                                require_cmd_approval = false,
                                require_approval_before = false,
                            },
                        },
                        ['get_diagnostics'] = {
                            opts = {
                                require_approval_before = false,
                                require_cmd_approval = false,
                            },
                        },
                        ['insert_edit_into_file'] = {
                            opts = {
                                require_approval_before = false,
                            },
                        },
                        ['create_file'] = {
                            opts = {
                                require_approval_before = true,
                            },
                        },
                        ['delete_file'] = {
                            opts = {
                                require_approval_before = true,
                            },
                        },
                        ['date'] = {
                            path = 'ai.cc.tools.date',
                            description = 'Provide date calculations based on today',
                            opts = {
                                require_approval_before = false,
                            },
                        },
                        -- custom tools
                        ['calendar_scheduler'] = {
                            path = 'ai.cc.tools.calendar_scheduler',
                            description = 'Manage meeting URL scheduling via Hammerspoon',
                            enabled = function()
                                return vim.fn.executable('hs') == 1
                            end,
                            opts = {
                                require_approval_before = false,
                            },
                        },
                        opts = {
                            system_prompt = {
                                enabled = true,
                                replace_main_system_prompt = false,
                            },
                            auto_submit_errors = true,
                            default_tools = {
                                'file_search',
                                'get_changed_files',
                                'get_diagnostics',
                                'grep_search',
                                'insert_edit_into_file',
                                'read_file',
                                'run_command',
                                'fetch_webpage',
                                'web_search',
                                'date',
                            },
                        },
                        groups = {
                            ['rust_dev'] = {
                                description = 'Rust development agent with full editing capabilities',
                                system_prompt = [[You are a Rust development specialist with deep expertise in:
- Ownership, borrowing, and lifetime management
- Idiomatic Rust patterns (Result/Option combinators, iterator chains, From/Into traits)
- Cargo workspace management, feature flags, and dependency management
- Performance optimization (zero-cost abstractions, avoiding unnecessary allocations)
- Unsafe code review and soundness verification
- Async Rust (tokio, futures, Pin/Unpin)

When editing Rust code:
- Ensure code compiles with `cargo check` before considering done
- Prefer clippy compliance: no warnings
- Use rustfmt compatible formatting
- Handle errors explicitly, avoid `.unwrap()` in library code]],
                                tools = {
                                    'read_file',
                                    'insert_edit_into_file',
                                    'run_command',
                                    'file_search',
                                    'grep_search',
                                    'get_diagnostics',
                                },
                                opts = {
                                    collapse_tools = true,
                                },
                            },
                            ['reviewer'] = {
                                description = 'Read-only code review agent',
                                system_prompt = [[You are a read-only code review agent. You can ONLY read and analyze code — no edits, no file creation, no commands that modify the filesystem.

Your capabilities:
- Read files to understand code structure
- Search for patterns across the codebase
- Inspect LSP diagnostics
- Provide detailed analysis and recommendations

Format reviews with:
- Severity: CRITICAL / WARNING / SUGGESTION / NITPICK
- Line number references
- Concrete code suggestions (as markdown blocks, not file edits)
- Summary stats at the end]],
                                tools = {
                                    'read_file',
                                    'file_search',
                                    'grep_search',
                                    'get_diagnostics',
                                },
                                opts = {
                                    collapse_tools = true,
                                },
                            },
                        },
                    },
                },
            },
            rules = {
                -- don't load rules by default,
                -- the underlying Claude Code ACP adapter
                -- will load them itself
                default = {
                    files = {},
                    is_default = false,
                },
            },
            -- Prompt Library create CodeCompanisonAction
            -- like: Fix Code, etcs
            prompt_library = {
                markdown = {
                    dirs = {
                        vim.fn.stdpath('config') .. '/lua/ai/cc/prompts',
                    },
                },
                ['Edit-Test Loop'] = {
                    interaction = 'chat',
                    description = 'Edit code and run tests in a loop until they pass',
                    opts = {
                        index = 10,
                        is_default = true,
                        short_name = 'etl',
                    },
                    prompts = {
                        {
                            {
                                name = 'Describe Change',
                                role = 'user',
                                opts = { auto_submit = false },
                                content = function()
                                    return [[### Edit-Test Loop

Describe the change you want below. I will:
1. Read relevant files to understand context
2. Make edits using @{insert_edit_into_file}
3. Run the test suite with @{run_command}
4. If tests fail, analyze errors and fix — repeating until they pass

**Available test commands:**
- Rust: `cargo test`
- TypeScript: `npm test` or `npx vitest run`
- Python: `pytest`

**What to change:**]]
                                end,
                            },
                        },
                        {
                            {
                                name = 'Fix on Failure',
                                role = 'user',
                                opts = { auto_submit = true },
                                condition = function()
                                    return _G.codecompanion_current_tool == 'run_command'
                                end,
                                repeat_until = function(chat)
                                    return chat.tool_registry.flags.testing == true
                                end,
                                content = 'The tests have failed. Read the error output carefully, fix the code with insert_edit_into_file, and run the tests again.',
                            },
                        },
                    },
                },
            },
            -- mcp = {
            --     server = {

            --     },
            -- },
            adapters = {
                acp = {
                    claude_code = function()
                        if _claude_code ~= nil then
                            return _claude_code
                        end

                        local instance
                        local ok = vim.wait(5000, function()
                            instance = require('mcphub').get_hub_instance()
                            return instance ~= nil and instance:is_ready()
                        end, 100)

                        local mcpServers = {}
                        if ok and instance then
                            mcpServers = {
                                {
                                    type = 'sse',
                                    name = 'mcphub',
                                    url = ('http://localhost:%d/mcp'):format(instance.port),
                                    headers = {},
                                },
                            }
                        end

                        _claude_code = require('codecompanion.adapters').extend('claude_code', {
                            env = {
                                ANTHROPIC_DEFAULT_OPUS_MODEL = 'claude-opus-4-6[1m]',
                            },
                            defaults = {
                                mode = 'plan',
                                model = 'opus',
                                mcpServers = mcpServers,
                            },
                        })
                        return _claude_code
                    end,
                },
                http = {},
            },
            extensions = {
                acp_yolo = {
                    enabled = true,
                    callback = 'ai.cc.extensions.acp_yolo',
                    opts = {
                        notify = true,
                        ignore_case = true,
                        record = true,
                        claude_code = {
                            ['edit'] = true,
                            ['read'] = true,
                            ['search'] = true,
                            ['write'] = true,
                            ['switch_mode'] = true,
                            ['fetch'] = true,
                            ['bash'] = { allow = false },
                            ['execute'] = {
                                allow = true,
                                title_pattern = {
                                    -- Rust (build/lint/test only)
                                    'cargo test',
                                    'cargo check',
                                    'cargo build',
                                    'cargo clippy',
                                    'cargo fmt',
                                    'cargo doc',
                                    -- JavaScript / TypeScript (lint/test/typecheck only)
                                    'npm test',
                                    'yarn test',
                                    'pnpm test',
                                    'bun test',
                                    'vitest',
                                    'jest',
                                    'mocha',
                                    'eslint',
                                    'prettier',
                                    'tsc ',
                                    'tsc$',
                                    -- Python (lint/test only)
                                    'pytest',
                                    'ruff ',
                                    'mypy ',
                                    'black ',
                                    'isort ',
                                    -- Go (build/lint/test only)
                                    'go test',
                                    'go build',
                                    'go vet',
                                    'go fmt',
                                    'golangci%-lint',
                                    -- Read-only shell
                                    'git status',
                                    'git diff',
                                    'git log',
                                    'git branch',
                                    'git show',
                                    'git blame',
                                    'cat ',
                                    'head ',
                                    'tail ',
                                    'wc ',
                                    'sort ',
                                    'ls ',
                                    'ls$',
                                    'pwd',
                                    'grep ',
                                    'rg ',
                                    -- Read-only Windows / PowerShell
                                    'Get%-ChildItem',
                                    'Get%-Content',
                                    'Select%-String',
                                    'Test%-Path',
                                    'dir ',
                                    'dir$',
                                    'type ',
                                    'where ',
                                    'findstr ',
                                },
                                title_deny_pattern = {
                                    -- Unix destructive
                                    'rm ',
                                    'sudo ',
                                    'chmod ',
                                    'chown ',
                                    'mkfs',
                                    'dd if=',
                                    '> /dev/',
                                    'mv ',
                                    'cp %-r',
                                    'kill ',
                                    'killall ',
                                    'pkill ',
                                    -- Shell eval / arbitrary execution
                                    'eval ',
                                    'exec ',
                                    'source ',
                                    '%. ',
                                    'sh %-c',
                                    'bash %-c',
                                    'zsh %-c',
                                    -- Windows destructive
                                    'del ',
                                    'rmdir ',
                                    'rd ',
                                    'format ',
                                    'move ',
                                    'Remove%-Item',
                                    'Move%-Item',
                                    'Set%-Content',
                                    'Out%-File',
                                    'Invoke%-Expression',
                                    'Invoke%-WebRequest',
                                    'Start%-Process',
                                    -- Network / download
                                    'curl ',
                                    'wget ',
                                    'Invoke%-RestMethod',
                                    'iex ',
                                    'iwr ',
                                    -- Package install / global changes
                                    'pip install',
                                    'npm install',
                                    'cargo install',
                                    'yarn add',
                                    'pnpm add',
                                    'bun add',
                                    'npx ',
                                    'bunx ',
                                    -- File redirection (overwrite)
                                    '> ',
                                    '>> ',
                                    -- Git write operations
                                    'git push',
                                    'git reset',
                                    -- allow checkout
                                    'git checkout ',
                                    'git clean',
                                    'git rebase',
                                    'git merge',
                                    -- allow commit
                                    -- 'git commit',
                                    'git stash',
                                },
                            },
                        },
                    },
                },
                mcphub = {
                    callback = 'mcphub.extensions.codecompanion',
                    opts = {
                        -- MCP Tools
                        make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
                        show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
                        add_mcp_prefix_to_tool_names = true, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
                        show_result_in_chat = true, -- Show tool results directly in chat buffer
                        -- format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
                        -- MCP Resources
                        make_vars = false, -- Convert MCP resources to #variables for prompts
                        -- MCP Prompts
                        make_slash_commands = true, -- Add MCP prompts as /slash commands
                    },
                },
                history = {
                    enabled = true,
                    opts = {
                        keymap = '<leader>ah',
                        save_chat_keymap = '<leader>as',
                        auto_save = true,
                        -- Number of days after which chats are automatically deleted (0 to disable)
                        expiration_days = 0,
                        picker = 'snacks',
                        picker_keymaps = {
                            rename = { n = 'r', i = '<M-r>' },
                            delete = { n = 'd', i = '<M-d>' },
                            duplicate = { n = '<C-y>', i = '<C-y>' },
                        },
                        auto_generate_title = false,
                        title_generation_opts = {
                            enabled = false,
                            -- adapter = 'anthropic',
                            -- ---Number of user prompts after which to refresh the title (0 to disable)
                            -- refresh_every_n_prompts = 0,
                            -- max_refreshes = 3,
                        },
                        ---On exiting and entering neovim, loads the last chat on opening chat
                        continue_last_chat = false,
                        delete_on_clearing_chat = false,
                        dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
                        chat_filter = function(chat_data)
                            return chat_data.cwd == vim.fn.getcwd()
                        end,
                        summary = {
                            create_summary_keymap = '<leader>am',
                            browse_summaries_keymap = '<leader>ay',

                            generation_opts = {
                                context_size = 1000000, -- max tokens that the model supports
                                include_references = true, -- include slash command content
                                include_tool_outputs = true, -- include tool execution results
                            },
                        },
                    },
                },
                ui = {},
            },
            display = {
                chat = {
                    start_in_insert_mode = true,
                    show_token_count = true,
                    fold_context = true,
                    separator = '─',
                    window = {
                        position = 'right',
                        width = 0.3,
                        sticky = true,
                    },
                },
            },
        },
    },
}
