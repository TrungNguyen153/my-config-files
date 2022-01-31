-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/trungnguyen/snap/alacritty/common/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/trungnguyen/snap/alacritty/common/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/trungnguyen/snap/alacritty/common/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/trungnguyen/snap/alacritty/common/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/trungnguyen/snap/alacritty/common/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    config = { "\27LJ\2\2/\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\20configs.comment\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["auto-session"] = {
    after = { "session-lens" },
    config = { "\27LJ\2\0024\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\25configs.auto-session\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/auto-session",
    url = "https://github.com/rmagatti/auto-session"
  },
  ["better-escape.nvim"] = {
    config = { "\27LJ\2\2 \1\0\0\3\0\n\0\r6\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\4\0005\2\3\0=\2\5\0016\2\6\0009\2\a\0029\2\b\2=\2\t\1B\0\2\1K\0\1\0\ftimeout\15timeoutlen\6o\bvim\fmapping\1\0\2\22clear_empty_lines\1\tkeys\n<Esc>\1\2\0\0\ajj\nsetup\18better_escape\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/better-escape.nvim",
    url = "https://github.com/max397574/better-escape.nvim"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.bufferline\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["faster.nvim"] = {
    config = { "\27LJ\2\2×\2\0\0\5\0\15\0!6\0\0\0009\0\1\0009\0\2\0'\1\3\0'\2\4\0'\3\5\0005\4\6\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\1\3\0'\2\a\0'\3\b\0005\4\t\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\1\n\0'\2\4\0'\3\v\0005\4\f\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\1\n\0'\2\a\0'\3\r\0005\4\14\0B\0\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\1\27<Plug>(faster_vmove_k)\1\0\2\vsilent\2\fnoremap\1\27<Plug>(faster_vmove_j)\6v\1\0\2\vsilent\2\fnoremap\1\27<Plug>(faster_move_gk)\6k\1\0\2\vsilent\2\fnoremap\1\27<Plug>(faster_move_gj)\6j\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/faster.nvim",
    url = "https://github.com/PHSix/faster.nvim"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/friendly-snippets",
    url = "https://github.com/rafamadriz/friendly-snippets"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\0020\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\21configs.gitsigns\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  gruvbox = {
    config = { "\27LJ\2\2x\0\0\2\0\3\0\0056\0\0\0009\0\1\0'\1\2\0B\0\2\1K\0\1\0Y            set background=dark\n            execute 'colorscheme' 'gruvbox'\n        \bcmd\bvim\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/morhetz/gruvbox"
  },
  ["impatient.nvim"] = {
    config = { "\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.impatient\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "https://github.com/lewis6991/impatient.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.indentline\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/lsp-colors.nvim",
    url = "https://github.com/folke/lsp-colors.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\2/\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\20configs.lualine\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["nlsp-settings.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nlsp-settings.nvim",
    url = "https://github.com/tamago324/nlsp-settings.nvim"
  },
  ["null-ls.nvim"] = {
    config = { "\27LJ\2\2+\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\16lsp.null-ls\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.autopairs\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    commands = { "BqfAutoToggle" },
    config = { "\27LJ\2\2+\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\16configs.bqf\frequire\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\2+\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\16configs.cmp\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.colorizer\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-lsp-installer"] = {
    config = { "\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22lsp.lsp-installer\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-lsp-installer",
    url = "https://github.com/williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    after = { "null-ls.nvim" },
    loaded = true,
    only_config = true
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.nvim-tree\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "Comment.nvim" },
    loaded = true,
    only_config = true
  },
  ["nvim-treesitter-refactor"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-treesitter-refactor",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-refactor"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-autotag"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-ts-rainbow"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-ts-rainbow",
    url = "https://github.com/p00f/nvim-ts-rainbow"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["session-lens"] = {
    config = { "\27LJ\2\2ž\1\0\0\3\0\b\0\0156\0\0\0'\1\1\0B\0\2\0029\0\2\0005\1\4\0005\2\3\0=\2\5\1B\0\2\0016\0\0\0'\1\6\0B\0\2\0029\0\a\0'\1\1\0B\0\2\1K\0\1\0\19load_extension\14telescope\17path_display\1\0\1\rwinblend\3\0\1\2\0\0\fshorten\nsetup\17session-lens\frequire\0" },
    load_after = {
      ["auto-session"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/opt/session-lens",
    url = "https://github.com/rmagatti/session-lens"
  },
  ["telescope-env.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/telescope-env.nvim",
    url = "https://github.com/LinArcX/telescope-env.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\2¤\1\0\0\2\0\a\0\0226\0\0\0'\1\1\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\4\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\5\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\6\0B\0\2\1K\0\1\0\14ui-select\benv\bfzf\19load_extension\14telescope\22configs.telescope\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["toggleterm.nvim"] = {
    config = { "\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.toggleterm\frequire\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  ["vim-bbye"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/vim-bbye",
    url = "https://github.com/moll/vim-bbye"
  },
  ["vim-easymotion"] = {
    config = { "\27LJ\2\2ë\1\0\0\2\0\3\0\0056\0\0\0009\0\1\0'\1\2\0B\0\2\1K\0\1\0Ë\1          let g:EasyMotion_do_mapping = 0\n          nmap <Leader><Leader>s <Plug>(easymotion-overwin-f)\n          \" Turn on case-insensitive feature\n          let g:EasyMotion_smartcase = 1\n        \bcmd\bvim\0" },
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/vim-easymotion",
    url = "https://github.com/easymotion/vim-easymotion"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/home/trungnguyen/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator",
    url = "https://github.com/christoomey/vim-tmux-navigator"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.treesitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\2+\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\16configs.cmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: gruvbox
time([[Config for gruvbox]], true)
try_loadstring("\27LJ\2\2x\0\0\2\0\3\0\0056\0\0\0009\0\1\0'\1\2\0B\0\2\1K\0\1\0Y            set background=dark\n            execute 'colorscheme' 'gruvbox'\n        \bcmd\bvim\0", "config", "gruvbox")
time([[Config for gruvbox]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: indent-blankline.nvim
time([[Config for indent-blankline.nvim]], true)
try_loadstring("\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.indentline\frequire\0", "config", "indent-blankline.nvim")
time([[Config for indent-blankline.nvim]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: impatient.nvim
time([[Config for impatient.nvim]], true)
try_loadstring("\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22configs.impatient\frequire\0", "config", "impatient.nvim")
time([[Config for impatient.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\2(\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\rlsp.init\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: vim-easymotion
time([[Config for vim-easymotion]], true)
try_loadstring("\27LJ\2\2ë\1\0\0\2\0\3\0\0056\0\0\0009\0\1\0'\1\2\0B\0\2\1K\0\1\0Ë\1          let g:EasyMotion_do_mapping = 0\n          nmap <Leader><Leader>s <Plug>(easymotion-overwin-f)\n          \" Turn on case-insensitive feature\n          let g:EasyMotion_smartcase = 1\n        \bcmd\bvim\0", "config", "vim-easymotion")
time([[Config for vim-easymotion]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\2/\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\20configs.lualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\2¤\1\0\0\2\0\a\0\0226\0\0\0'\1\1\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\4\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\5\0B\0\2\0016\0\0\0'\1\2\0B\0\2\0029\0\3\0'\1\6\0B\0\2\1K\0\1\0\14ui-select\benv\bfzf\19load_extension\14telescope\22configs.telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: nvim-lsp-installer
time([[Config for nvim-lsp-installer]], true)
try_loadstring("\27LJ\2\0021\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\22lsp.lsp-installer\frequire\0", "config", "nvim-lsp-installer")
time([[Config for nvim-lsp-installer]], false)
-- Config for: toggleterm.nvim
time([[Config for toggleterm.nvim]], true)
try_loadstring("\27LJ\2\0022\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\23configs.toggleterm\frequire\0", "config", "toggleterm.nvim")
time([[Config for toggleterm.nvim]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\0020\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\21configs.gitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd null-ls.nvim ]]

-- Config for: null-ls.nvim
try_loadstring("\27LJ\2\2+\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\16lsp.null-ls\frequire\0", "config", "null-ls.nvim")

vim.cmd [[ packadd Comment.nvim ]]

-- Config for: Comment.nvim
try_loadstring("\27LJ\2\2/\0\0\2\0\2\0\0046\0\0\0'\1\1\0B\0\2\1K\0\1\0\20configs.comment\frequire\0", "config", "Comment.nvim")

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file BqfAutoToggle lua require("packer.load")({'nvim-bqf'}, { cmd = "BqfAutoToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au QuickFixCmdPost * ++once lua require("packer.load")({'nvim-bqf'}, { event = "QuickFixCmdPost *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs', 'better-escape.nvim'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'auto-session', 'faster.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
