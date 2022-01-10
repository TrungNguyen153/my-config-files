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
local package_path_str = "/Users/bth/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/bth/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/bth/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/bth/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/bth/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
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
  ["accelerated-jk"] = {
    config = { "\27LJ\2\nç\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0n        nmap <silent> j <Plug>(accelerated_jk_gj)\n\t      nmap <silent> k <Plug>(accelerated_jk_gk)\n      \bcmd\bvim\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/accelerated-jk",
    url = "https://github.com/rhysd/accelerated-jk"
  },
  ["better-escape.nvim"] = {
    config = { "\27LJ\2\n†\1\0\0\4\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0026\3\6\0009\3\a\0039\3\b\3=\3\t\2B\0\2\1K\0\1\0\ftimeout\15timeoutlen\6o\bvim\fmapping\1\0\2\tkeys\n<Esc>\22clear_empty_lines\1\1\2\0\0\ajj\nsetup\18better_escape\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/better-escape.nvim",
    url = "https://github.com/max397574/better-escape.nvim"
  },
  ["caw.vim"] = {
    config = { "\27LJ\2\nà\t\0\0\3\0\6\0\r6\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0í\b        function! InitCaw() abort\n          if &l:modifiable && &buftype ==# '' && &filetype !=# 'gitrebase'\n            xmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)\n            nmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)\n            xmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)\n            nmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)\n            nmap <buffer> gc <Plug>(caw:prefix)\n            xmap <buffer> gc <Plug>(caw:prefix)\n            nmap <buffer> gcc <Plug>(caw:hatpos:toggle)\n            xmap <buffer> gcc <Plug>(caw:hatpos:toggle)\n          else\n            silent! nunmap <buffer> <Leader>V\n            silent! xunmap <buffer> <Leader>V\n            silent! nunmap <buffer> <Leader>v\n            silent! xunmap <buffer> <Leader>v\n            silent! nunmap <buffer> gc\n            silent! xunmap <buffer> gc\n            silent! nunmap <buffer> gcc\n            silent! xunmap <buffer> gcc\n          endif\n        endfunction\n        autocmd user_events FileType * call InitCaw()\n        call InitCaw()\n      \bcmd\29caw_operator_keymappings\31caw_no_default_keymappings\6g\bvim\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/caw.vim",
    url = "https://github.com/tyru/caw.vim"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-tabnine"] = {
    after_files = { "/Users/bth/.local/share/nvim/site/pack/packer/opt/cmp-tabnine/after/plugin/cmp-tabnine.lua" },
    config = { "\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24configs.cmp-tabnine\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/cmp-tabnine",
    url = "https://github.com/tzachar/cmp-tabnine"
  },
  ["cmp-vsnip"] = {
    after_files = { "/Users/bth/.local/share/nvim/site/pack/packer/opt/cmp-vsnip/after/plugin/cmp_vsnip.vim" },
    load_after = {
      ["vim-vsnip"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/cmp-vsnip",
    url = "https://github.com/hrsh7th/cmp-vsnip"
  },
  ["fern-bookmark.vim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/fern-bookmark.vim",
    url = "https://github.com/lambdalisue/fern-bookmark.vim"
  },
  ["fern-git-status.vim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/fern-git-status.vim",
    url = "https://github.com/lambdalisue/fern-git-status.vim"
  },
  ["fern-mapping-git.vim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/fern-mapping-git.vim",
    url = "https://github.com/lambdalisue/fern-mapping-git.vim"
  },
  ["fern-preview.vim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/fern-preview.vim",
    url = "https://github.com/yuki-yano/fern-preview.vim"
  },
  ["fern-renderer-nerdfont.vim"] = {
    config = { "\27LJ\2\n©\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0â\1        let g:fern#renderer = 'nerdfont'\n        let g:fern#renderer#nerdfont#padding = get(g:, 'global_symbol_padding', ' ')\n      \bcmd\bvim\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/fern-renderer-nerdfont.vim",
    url = "https://github.com/lambdalisue/fern-renderer-nerdfont.vim"
  },
  ["fern.vim"] = {
    after = { "fern-git-status.vim", "fern-mapping-git.vim", "fern-renderer-nerdfont.vim", "nerdfont.vim", "glyph-palette.vim", "fern-preview.vim", "fern-bookmark.vim" },
    loaded = true,
    only_config = true
  },
  ["glyph-palette.vim"] = {
    config = { "\27LJ\2\no\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0P        autocmd user_events FileType fern call glyph_palette#apply()\n      \bcmd\bvim\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/glyph-palette.vim",
    url = "https://github.com/lambdalisue/glyph-palette.vim"
  },
  gruvbox = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/morhetz/gruvbox"
  },
  ["lsp-colors.nvim"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/lsp-colors.nvim",
    url = "https://github.com/folke/lsp-colors.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20configs.lualine\frequire\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  neoformat = {
    commands = { "Neoformat" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  ["nerdfont.vim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/nerdfont.vim",
    url = "https://github.com/lambdalisue/nerdfont.vim"
  },
  ["null-ls.nvim"] = {
    after = { "nvim-lsp-ts-utils" },
    config = { "\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19lsp.null-ls-rc\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22configs.autopairs\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    commands = { "BqfAutoToggle" },
    config = { "\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16configs.bqf\frequire\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-cmp"] = {
    after = { "cmp-tabnine" },
    loaded = true,
    only_config = true
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22configs.colorizer\frequire\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-lsp-ts-utils"] = {
    config = { "\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20lsp.tsserver-rc\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/nvim-lsp-ts-utils",
    url = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    after = { "null-ls.nvim" },
    loaded = true,
    only_config = true
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23configs.treesitter\frequire\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-autotag"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-ts-rainbow"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-ts-rainbow",
    url = "https://github.com/p00f/nvim-ts-rainbow"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\nê\1\0\0\3\0\a\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\1\0B\0\2\0029\0\3\0B\0\1\0016\0\0\0'\2\4\0B\0\2\0029\0\5\0'\2\6\0B\0\2\1K\0\1\0\bfzf\19load_extension\14telescope\fpreload\nsetup\22configs.telescope\frequire\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-easymotion"] = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/vim-easymotion",
    url = "https://github.com/easymotion/vim-easymotion"
  },
  ["vim-edgemotion"] = {
    config = { "\27LJ\2\nø\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0ü\1        nmap gj <Plug>(edgemotion-j)\n        nmap gk <Plug>(edgemotion-k)\n        xmap gj <Plug>(edgemotion-j)\n        xmap gk <Plug>(edgemotion-k)\n      \bcmd\bvim\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vim-edgemotion",
    url = "https://github.com/haya14busa/vim-edgemotion"
  },
  ["vim-editorconfig"] = {
    config = { "\27LJ\2\nQ\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0002        let g:editorconfig_verbose = 1\n      \bcmd\bvim\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vim-editorconfig",
    url = "https://github.com/sgur/vim-editorconfig"
  },
  ["vim-sandwich"] = {
    config = { "\27LJ\2\n◊\n\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0∑\n        let g:sandwich_no_default_key_mappings = 1\n        let g:operator_sandwich_no_default_key_mappings = 1\n        let g:textobj_sandwich_no_default_key_mappings = 1\n        nmap sa <Plug>(operator-sandwich-add)\n        xmap sa <Plug>(operator-sandwich-add)\n        omap sa <Plug>(operator-sandwich-g@)\n        nmap sd <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)\n        xmap sd <Plug>(operator-sandwich-delete)\n        nmap sr <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)\n        xmap sr <Plug>(operator-sandwich-replace)\n        nmap sdb <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)\n        nmap srb <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)\n        omap ir <Plug>(textobj-sandwich-auto-i)\n        xmap ir <Plug>(textobj-sandwich-auto-i)\n        omap ab <Plug>(textobj-sandwich-auto-a)\n        xmap ab <Plug>(textobj-sandwich-auto-a)\n        omap is <Plug>(textobj-sandwich-query-i)\n        xmap is <Plug>(textobj-sandwich-query-i)\n        omap as <Plug>(textobj-sandwich-query-a)\n        xmap as <Plug>(textobj-sandwich-query-a)\n\t\t\t\truntime macros/sandwich/keymap/surround.vim\n      \bcmd\bvim\0" },
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator",
    url = "https://github.com/christoomey/vim-tmux-navigator"
  },
  ["vim-vsnip"] = {
    after = { "cmp-vsnip" },
    config = { "\27LJ\2\nã\2\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0Î\1        let g:vsnip_snippet_dir = expand('$VIM_PATH/snippets')\n        let g:vsnip_filetypes = {}\n        let g:vsnip_filetypes.javascriptreact = ['javascript']\n        let g:vsnip_filetypes.typescriptreact = ['typescript']\n      \bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/vim-vsnip",
    url = "https://github.com/hrsh7th/vim-vsnip"
  },
  ["vim-vsnip-integ"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vim-vsnip-integ",
    url = "https://github.com/hrsh7th/vim-vsnip-integ"
  },
  ["vscode-es7-javascript-react-snippets"] = {
    loaded = true,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/start/vscode-es7-javascript-react-snippets",
    url = "https://github.com/dsznajder/vscode-es7-javascript-react-snippets"
  },
  ["which-key.nvim"] = {
    commands = { "WhichKey" },
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22configs.which-key\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  },
  ["zen-mode.nvim"] = {
    commands = { "ZenMode" },
    config = { "\27LJ\2\n0\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\21configs.zen-mode\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/bth/.local/share/nvim/site/pack/packer/opt/zen-mode.nvim",
    url = "https://github.com/folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: vim-easymotion
time([[Setup for vim-easymotion]], true)
try_loadstring("\27LJ\2\nÅ\5\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0·\4        let g:EasyMotion_do_mapping = 0\n        \" Jump to anywhere you want with minimal keystrokes, with just one key binding.\n        \" `sm{char}{label}`\n        nmap sm <Plug>(easymotion-overwin-f)\n        \" or\n        \" `sm{char}{char}{label}`\n        \" Need one more keystroke, but on average, it may be more comfortable.\n        nmap sm <Plug>(easymotion-overwin-f2)\n        \n        \" Turn on case-insensitive feature\n        let g:EasyMotion_smartcase = 1\n        \n        \" JK motions: Line motions\n        \" map <Leader>j <Plug>(easymotion-j)\n        \" map <Leader>k <Plug>(easymotion-k)\n      \bcmd\bvim\0", "setup", "vim-easymotion")
time([[Setup for vim-easymotion]], false)
time([[packadd for vim-easymotion]], true)
vim.cmd [[packadd vim-easymotion]]
time([[packadd for vim-easymotion]], false)
-- Setup for: fern-git-status.vim
time([[Setup for fern-git-status.vim]], true)
try_loadstring("\27LJ\2\n\\\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0=        let g:fern_git_status_disable_startup = 1\n      \bcmd\bvim\0", "setup", "fern-git-status.vim")
time([[Setup for fern-git-status.vim]], false)
-- Setup for: nvim-bqf
time([[Setup for nvim-bqf]], true)
try_loadstring("\27LJ\2\nn\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0O        nmap <Leader>q <cmd>lua require('user').qflist.toggle()<CR>\n      \bcmd\bvim\0", "setup", "nvim-bqf")
time([[Setup for nvim-bqf]], false)
-- Setup for: vim-vsnip
time([[Setup for vim-vsnip]], true)
try_loadstring("\27LJ\2\nÂ\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0≈\1        \" vsnip\n      imap <expr><C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'\n      smap <expr><C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'\n      \bcmd\bvim\0", "setup", "vim-vsnip")
time([[Setup for vim-vsnip]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\n+\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\16configs.cmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20configs.lualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: vim-editorconfig
time([[Config for vim-editorconfig]], true)
try_loadstring("\27LJ\2\nQ\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0002        let g:editorconfig_verbose = 1\n      \bcmd\bvim\0", "config", "vim-editorconfig")
time([[Config for vim-editorconfig]], false)
-- Config for: caw.vim
time([[Config for caw.vim]], true)
try_loadstring("\27LJ\2\nà\t\0\0\3\0\6\0\r6\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0í\b        function! InitCaw() abort\n          if &l:modifiable && &buftype ==# '' && &filetype !=# 'gitrebase'\n            xmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)\n            nmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)\n            xmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)\n            nmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)\n            nmap <buffer> gc <Plug>(caw:prefix)\n            xmap <buffer> gc <Plug>(caw:prefix)\n            nmap <buffer> gcc <Plug>(caw:hatpos:toggle)\n            xmap <buffer> gcc <Plug>(caw:hatpos:toggle)\n          else\n            silent! nunmap <buffer> <Leader>V\n            silent! xunmap <buffer> <Leader>V\n            silent! nunmap <buffer> <Leader>v\n            silent! xunmap <buffer> <Leader>v\n            silent! nunmap <buffer> gc\n            silent! xunmap <buffer> gc\n            silent! nunmap <buffer> gcc\n            silent! xunmap <buffer> gcc\n          endif\n        endfunction\n        autocmd user_events FileType * call InitCaw()\n        call InitCaw()\n      \bcmd\29caw_operator_keymappings\31caw_no_default_keymappings\6g\bvim\0", "config", "caw.vim")
time([[Config for caw.vim]], false)
-- Config for: fern.vim
time([[Config for fern.vim]], true)
try_loadstring("\27LJ\2\nB\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0#:runtime! lua/configs/fern.vim\bcmd\bvim\0", "config", "fern.vim")
time([[Config for fern.vim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\nê\1\0\0\3\0\a\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\0\0'\2\1\0B\0\2\0029\0\3\0B\0\1\0016\0\0\0'\2\4\0B\0\2\0029\0\5\0'\2\6\0B\0\2\1K\0\1\0\bfzf\19load_extension\14telescope\fpreload\nsetup\22configs.telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: accelerated-jk
time([[Config for accelerated-jk]], true)
try_loadstring("\27LJ\2\nç\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0n        nmap <silent> j <Plug>(accelerated_jk_gj)\n\t      nmap <silent> k <Plug>(accelerated_jk_gk)\n      \bcmd\bvim\0", "config", "accelerated-jk")
time([[Config for accelerated-jk]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
try_loadstring("\27LJ\2\n◊\n\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0∑\n        let g:sandwich_no_default_key_mappings = 1\n        let g:operator_sandwich_no_default_key_mappings = 1\n        let g:textobj_sandwich_no_default_key_mappings = 1\n        nmap sa <Plug>(operator-sandwich-add)\n        xmap sa <Plug>(operator-sandwich-add)\n        omap sa <Plug>(operator-sandwich-g@)\n        nmap sd <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)\n        xmap sd <Plug>(operator-sandwich-delete)\n        nmap sr <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)\n        xmap sr <Plug>(operator-sandwich-replace)\n        nmap sdb <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)\n        nmap srb <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)\n        omap ir <Plug>(textobj-sandwich-auto-i)\n        xmap ir <Plug>(textobj-sandwich-auto-i)\n        omap ab <Plug>(textobj-sandwich-auto-a)\n        xmap ab <Plug>(textobj-sandwich-auto-a)\n        omap is <Plug>(textobj-sandwich-query-i)\n        xmap is <Plug>(textobj-sandwich-query-i)\n        omap as <Plug>(textobj-sandwich-query-a)\n        xmap as <Plug>(textobj-sandwich-query-a)\n\t\t\t\truntime macros/sandwich/keymap/surround.vim\n      \bcmd\bvim\0", "config", "vim-sandwich")
time([[Config for vim-sandwich]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22configs.colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\nã\1\0\0\3\0\6\0\0186\0\0\0'\2\1\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0029\0\3\0009\0\4\0004\2\0\0B\0\2\0016\0\0\0'\2\2\0B\0\2\0029\0\5\0009\0\4\0004\2\0\0B\0\2\1K\0\1\0\16tailwindcss\nsetup\ncssls\14lspconfig\22configs.lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: vim-edgemotion
time([[Config for vim-edgemotion]], true)
try_loadstring("\27LJ\2\nø\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0ü\1        nmap gj <Plug>(edgemotion-j)\n        nmap gk <Plug>(edgemotion-k)\n        xmap gj <Plug>(edgemotion-j)\n        xmap gk <Plug>(edgemotion-k)\n      \bcmd\bvim\0", "config", "vim-edgemotion")
time([[Config for vim-edgemotion]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23configs.treesitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd null-ls.nvim ]]

-- Config for: null-ls.nvim
try_loadstring("\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19lsp.null-ls-rc\frequire\0", "config", "null-ls.nvim")

vim.cmd [[ packadd nvim-lsp-ts-utils ]]

-- Config for: nvim-lsp-ts-utils
try_loadstring("\27LJ\2\n/\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\20lsp.tsserver-rc\frequire\0", "config", "nvim-lsp-ts-utils")

vim.cmd [[ packadd cmp-tabnine ]]

-- Config for: cmp-tabnine
try_loadstring("\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24configs.cmp-tabnine\frequire\0", "config", "cmp-tabnine")

vim.cmd [[ packadd fern-preview.vim ]]
vim.cmd [[ packadd fern-mapping-git.vim ]]
vim.cmd [[ packadd fern-renderer-nerdfont.vim ]]

-- Config for: fern-renderer-nerdfont.vim
try_loadstring("\27LJ\2\n©\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0â\1        let g:fern#renderer = 'nerdfont'\n        let g:fern#renderer#nerdfont#padding = get(g:, 'global_symbol_padding', ' ')\n      \bcmd\bvim\0", "config", "fern-renderer-nerdfont.vim")

vim.cmd [[ packadd fern-bookmark.vim ]]
vim.cmd [[ packadd fern-git-status.vim ]]
vim.cmd [[ packadd glyph-palette.vim ]]

-- Config for: glyph-palette.vim
try_loadstring("\27LJ\2\no\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0P        autocmd user_events FileType fern call glyph_palette#apply()\n      \bcmd\bvim\0", "config", "glyph-palette.vim")

vim.cmd [[ packadd nerdfont.vim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Neoformat lua require("packer.load")({'neoformat'}, { cmd = "Neoformat", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ZenMode lua require("packer.load")({'zen-mode.nvim'}, { cmd = "ZenMode", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file WhichKey lua require("packer.load")({'which-key.nvim'}, { cmd = "WhichKey", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
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
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'better-escape.nvim', 'nvim-autopairs', 'vim-vsnip'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
