-- https://github.com/Shatur/neovim-tasks

return {
    -- "Shatur/neovim-tasks",
    "TrungNguyen153/neovim-tasks",
    -- dir = "E:/c++/neovim-tasks",
    -- enabled = false,
    event = "VeryLazy",
    config = function()
        vim.keymap.set( "n", "<leader>cg", [[:Task start cmake configure<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cG", [[:Task start cmake configureDebug<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cP", [[:Task start cmake reconfigure<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cT", [[:Task start cmake ctest<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cK", [[:Task start cmake clean<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>ct", [[:Task set_module_param cmake target<cr>]], { silent = true } )
        vim.keymap.set( "n", "<C-c>", [[:Task cancel<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cr", [[:Task start cmake run<cr>]], { silent = true } )
        vim.keymap.set( "n", "<F7>", [[:Task start cmake debug<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cb", [[:Task start cmake build<cr>]], { silent = true } )
        vim.keymap.set( "n", "<leader>cB", [[:Task start cmake build_all<cr>]], { silent = true } )

        -- open ccmake in embedded terminal
        local function openCCMake()
            local build_dir = tostring( require( 'tasks.cmake_utils.cmake_utils' ).getBuildDir() )
            vim.cmd( [[bo sp term://ccmake ]] .. build_dir )
        end
        vim.keymap.set( "n", "<leader>cc", openCCMake, { silent = true, desc = "Open CCMake" } )

        -- if project is using presets, provide preset selection for both <leader>cv and <leader>ck
        -- if not, provide build type (<leader>cv) and kit (<leader>ck) selection

        local function selectPreset()
            local availablePresets = cmake_presets.parse( 'buildPresets' )

            vim.ui.select( availablePresets, { prompt = 'Select build preset' }, function( choice, idx )
                if not idx then
                    return
                end
                local projectConfig = ProjectConfig:new()
                if not projectConfig[ 'cmake' ] then
                    projectConfig[ 'cmake' ] = {}
                end

                projectConfig[ 'cmake' ][ 'build_preset' ] = choice

                -- autoselect will invoke projectConfig:write()
                cmake_utils.autoselectConfigurePresetFromCurrentBuildPreset( projectConfig )

            end)
        end

        local function selectBuildKitOrPreset()
            if cmake_utils.shouldUsePresets() then
                selectPreset()
            else
                tasks.set_module_param( 'cmake', 'build_kit' )
            end
        end

        vim.keymap.set( "n", "<leader>ck", selectBuildKitOrPreset, { silent = true, desc = "CMake select build kit or preset" } )

        local function selectBuildTypeOrPreset()
            if cmake_utils.shouldUsePresets() then
                selectPreset()
            else
                tasks.set_module_param( 'cmake', 'build_type' )
            end
        end

        vim.keymap.set( "n", "<leader>cv", selectBuildTypeOrPreset, { silent = true, desc= "CMake select build type or preset" } )

        require('tasks').setup({})
    end
}