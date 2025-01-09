return {
  {
    "folke/which-key.nvim",
    event = 'VeryLazy',
    config = function()
      local keymaps = require("setup.keymaps")
      keymaps.map_keys()
      require("setup.which-key").setup()
    end,
  }, -- shows the keybindings in a floating window.
  { "andymass/vim-matchup", event = 'VeryLazy', config = require("setup.matchup").setup }, -- Enhances the % and matches for blocks
  { "numToStr/Comment.nvim", event = 'VeryLazy', config = require("setup.comment").setup }, -- gcc to comment/uncomment line
  { "kylechui/nvim-surround", event = 'VeryLazy', config = require("setup.surround").setup }, -- add surround commands
  {
    "phaazon/hop.nvim",
    event = 'VeryLazy',
    branch = "v2",
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end,
  }, -- hop to different parts of the buffer
  {
    "booperlv/nvim-gomove",
    event = 'VeryLazy',
    config = true,
  }, -- makes better line moving
  {
    "nvim-pack/nvim-spectre",
    cmd = 'LazySpectre',
    config = true,
  }, -- special search and replace buffer
  "famiu/bufdelete.nvim", -- delete buffer and keep window layout
  "samjwill/nvim-unception", -- prevents an instance of neovim to be openend within neovim
  { "chrishrb/gx.nvim",
    event = 'VeryLazy',
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function ()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true
  }, -- gx opens urls, github issues etc in the browser
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  }, -- makes better insert mode escape
  {
    "PHSix/faster.nvim",
    event = 'VeryLazy',
    config = function()
      vim.api.nvim_set_keymap("n", "j", "<Plug>(faster_move_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("n", "k", "<Plug>(faster_move_k)", { noremap = false, silent = true })
      -- if you need map in visual mode
      vim.api.nvim_set_keymap("v", "j", "<Plug>(faster_vmove_j)", { noremap = false, silent = true })
      vim.api.nvim_set_keymap("v", "k", "<Plug>(faster_vmove_k)", { noremap = false, silent = true })
    end,
  }, -- A neovim plugin to accelerate j or k moving
  {
    'jake-stewart/multicursor.nvim',
    event = 'VeryLazy',
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      -- set({"n", "v"}, "<up>",
      --     function() mc.lineAddCursor(-1) end)
      -- set({"n", "v"}, "<down>",
      --     function() mc.lineAddCursor(1) end)
      -- set({"n", "v"}, "<leader><up>",
      --     function() mc.lineSkipCursor(-1) end)
      -- set({"n", "v"}, "<leader><down>",
      --     function() mc.lineSkipCursor(1) end)

      -- Add or skip adding a new cursor by matching word/selection
      set({"n", "v"}, "m",         function() mc.matchAddCursor(1) end)
      set({"n", "v"}, "<leader>m", function() mc.matchSkipCursor(1) end)
      set({"n", "v"}, "M", function() mc.matchAddCursor(-1) end)
      set({"n", "v"}, "<leader>M", function() mc.matchSkipCursor(-1) end)

      -- Add all matches in the document
      -- set({"n", "v"}, "<leader>A", mc.matchAllAddCursors)

      -- You can also add cursors with any motion you prefer:
      -- set("n", "<right>", function()
      --     mc.addCursor("w")
      -- end)
      -- set("n", "<leader><right>", function()
      --     mc.skipCursor("w")
      -- end)

      -- Rotate the main cursor.
      -- set({"n", "v"}, "<left>", mc.nextCursor)
      -- set({"n", "v"}, "<right>", mc.prevCursor)

      -- Delete the main cursor.
      set({"n", "v"}, "<leader>x", mc.deleteCursor)

      -- Add and remove cursors with control + left click.
      -- set("n", "<c-leftmouse>", mc.handleMouse)

      -- Easy way to add and remove cursors using the main cursor.
      -- set({"n", "v"}, "<c-q>", mc.toggleCursor)

      -- Clone every cursor and disable the originals.
      -- set({"n", "v"}, "<leader><c-q>", mc.duplicateCursors)

      local exit_fn = function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        elseif mc.hasCursors() then
            mc.clearCursors()
        else
            -- Default <esc> handler.
        end
    end

      set("n", "<esc>", exit_fn)
      set("n", "<C-c>", exit_fn)

      -- bring back cursors if you accidentally clear them
      -- set("n", "<leader>gv", mc.restoreCursors)

      -- Align cursor columns.
      -- set("n", "<leader>a", mc.alignCursors)

      -- Split visual selections by regex.
      set("v", "S", mc.splitCursors)

      -- Append/insert for each line of visual selections.
      set("v", "I", mc.insertVisual)
      set("v", "A", mc.appendVisual)

      -- match new cursors within visual selections by regex.
      set("v", "M", mc.matchCursors)

      -- Rotate visual selection contents.
      -- set("v", "<leader>t",
      --     function() mc.transposeCursors(1) end)
      -- set("v", "<leader>T",
      --     function() mc.transposeCursors(-1) end)

      -- Jumplist support
      -- set({"v", "n"}, "<c-i>", mc.jumpForward)
      -- set({"v", "n"}, "<c-o>", mc.jumpBackward)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn"})
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
  end
  },
}
