-- status line

local cc_processing = false

vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequestStarted',
    callback = function()
        cc_processing = true
    end,
})

vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequestFinished',
    callback = function()
        cc_processing = false
    end,
})

local cc_spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local cc_spinner_idx = 1

return {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    enabled = not vim.g.vscode,
    opts = {
        options = {
            theme = 'auto',
        },
        sections = {
            lualine_c = {
                { 'filename', path = 1 },
            },
            lualine_x = {
                {
                    function()
                        cc_spinner_idx = (cc_spinner_idx % #cc_spinner_frames) + 1
                        return cc_spinner_frames[cc_spinner_idx] .. ' CodeCompanion'
                    end,
                    cond = function()
                        return cc_processing
                    end,
                },
                {
                    function()
                        return require('vectorcode.integrations').lualine({ show_job_count = true })[1]()
                    end,
                    cond = function()
                        if package.loaded['vectorcode'] == nil then
                            return false
                        end
                        return require('vectorcode.integrations').lualine({ show_job_count = true }).cond()
                    end,
                },
                'encoding',
                'fileformat',
                'filetype',
            },
        },
    },
}
