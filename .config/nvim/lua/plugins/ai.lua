-- # Scoped keys (recommended)
-- export AVANTE_ANTHROPIC_API_KEY=your-claude-api-key
-- export AVANTE_OPENAI_API_KEY=your-openai-api-key
-- export AVANTE_AZURE_OPENAI_API_KEY=your-azure-api-key
-- export AVANTE_GEMINI_API_KEY=your-gemini-api-key
-- export AVANTE_CO_API_KEY=your-cohere-api-key
-- export AVANTE_AIHUBMIX_API_KEY=your-aihubmix-api-key

return {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    -- BuildFromSource false => download prebuilt
    build = function()
        -- conditionally use the correct build system for the current OS
        if vim.fn.has("win32") == 1 then
            return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        else
            return "make"
        end
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!

    opts = {
        ---@alias avante.ProviderName "claude" | "openai" | "azure" | "gemini" | "vertex" | "cohere" | "copilot" | "bedrock" | "ollama" | string
        ---@type avante.ProviderName
        provider = "copilot",
        -- https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
        providers = {
            ---@type AvanteSupportedProvider
            gemini_2_5 = {
                endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
                model = "gemini-2.5-flash",
                timeout = 30000, -- Timeout in milliseconds
                extra_request_body = {
                    generationConfig = {
                        temperature = 0.75,
                    },
                },
            },
        },
    },

    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "folke/snacks.nvim", -- for input provider snacks
        "nvim-tree/nvim-web-devicons",
        {
            'zbirenbaum/copilot.lua',
            opts = {
              panel = {
                enabled = false,
              },
              suggestion = {
                auto_trigger = true,
                hide_during_completion = false,
                keymap = {
                  accept = '<Tab>',
                },
              },
            },
            config = true
        }
    },
}