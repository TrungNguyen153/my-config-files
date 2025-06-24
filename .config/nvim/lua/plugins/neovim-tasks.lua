return {
    -- "Shatur/neovim-tasks",
    "TrungNguyen153/neovim-tasks",
    -- dir = "E:/c++/neovim-tasks",
    -- enabled = false,
    event = "VeryLazy",
    config = function()
        local tasks = require('tasks')
        local cmake_utils = require('tasks.cmake_utils.cmake_utils')
        -- https://github.com/Shatur/neovim-tasks
        local function selectPreset()
            local availablePresets = cmake_presets.parse('buildPresets')

            vim.ui.select(availablePresets, {prompt = 'Select build preset'},
                          function(choice, idx)
                if not idx then return end
                local projectConfig = ProjectConfig:new()
                if not projectConfig['cmake'] then
                    projectConfig['cmake'] = {}
                end

                projectConfig['cmake']['build_preset'] =
                    choice -- autoselect will invoke projectConfig:write()
                    .autoselectConfigurePresetFromCurrentBuildPreset(
                        projectConfig)

            end)
        end

        local function selectBuildKitOrPreset()
            if cmake_utils.shouldUsePresets() then
                selectPreset()
            else
                tasks.set_module_param('cmake', 'build_kit')
            end
        end

        local function selectBuildTypeOrPreset()
            if cmake_utils.shouldUsePresets() then
                selectPreset()
            else
                tasks.set_module_param('cmake', 'build_type')
            end
        end

        vim.keymap.set("n", "<leader>cg", [[:Task start cmake configure<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cG",
                       [[:Task start cmake configureDebug<cr>]], {silent = true})
        vim.keymap.set("n", "<leader>cP", [[:Task start cmake reconfigure<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cT", [[:Task start cmake ctest<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cK", [[:Task start cmake purge<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>ct",
                       [[:Task set_module_param cmake target<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cc", [[:Task cancel<cr>]], {silent = true})
        vim.keymap.set("n", "<leader>cr", [[:Task start cmake run<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cd", [[:Task start cmake debug<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cb", [[:Task start cmake build<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>cB", [[:Task start cmake build_all<cr>]],
                       {silent = true})
        vim.keymap.set("n", "<leader>ck", selectBuildKitOrPreset, {
            silent = true,
            desc = "CMake select build kit or preset"
        })
        vim.keymap.set("n", "<leader>cv", selectBuildTypeOrPreset, {
            silent = true,
            desc = "CMake select build type or preset"
        })

        tasks.setup({
            default_params = {
                cmake = {
                    cmake_kits_file = ".\\cmake-kits.json",
                    cmake_build_types_file = ".\\cmake-build-types.json"
                }
            }

        })
    end
}
