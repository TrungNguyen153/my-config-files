-- https://github.com/Civitasv/cmake-tools.nvim

return {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    enabled = not vim.g.vscode,
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load({ plugins = { "cmake-tools.nvim" } })
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    config = function()
        local osys = require("cmake-tools.osys")
        require("cmake-tools").setup({
            cmake_command = "cmake",
            cmake_regenerate_on_save = true,
            cmake_generate_options = { 
                "-G",
                "Ninja",
                "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
            }, -- Use Ninja for MSVC
            cmake_build_options = {},
            cmake_compile_commands_options = {
                action = "soft_link",
                target = vim.loop.cwd(),
            },
            cmake_build_type = "Debug",
            cmake_build_directory = function()
                if osys.iswin32 then
                  return "build\\${variant:buildType}"
                end
                return "build/${variant:buildType}"
            end,
            cmake_variants_message = {
                short = { show = true }, -- whether to show short message
                long = { show = true, max_length = 40 }, -- whether to show long message
            },
            cmake_executor = {
              name = "terminal",
              opts = {
                direction = "horizontal",
                split_size = 30,
              },
            },
            cmake_runner = {
              name = "terminal",
              opts = {
                direction = "horizontal",
                split_size = 30,
              },
            },
            cmake_notifications = {
                runner = { enabled = true },
                executor = { enabled = true },
                spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
                refresh_rate_ms = 100, -- how often to iterate icons
              },
              cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
              cmake_use_scratch_buffer = false, -- A buffer that shows what cmake-tools has done
        })
    end,
    keys = {
        {
            "<leader>cg",
            "<cmd>CMakeGenerate<CR>",
            mode = { "n" },
            desc = "Generate CMake",
        },
        {
            "<leader>cb",
            "<cmd>CMakeBuild<CR>",
            mode = { "n" },
            desc = "Build CMake",
        },
        {
            "<leader>cr",
            "<cmd>CMakeRun<CR>",
            mode = { "n" },
            desc = "Run CMake",
        },
    }
}