local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if not vim.loop.fs_stat(fn.glob(install_path)) then
	os.execute('git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use {'wbthomason/packer.nvim', opt=true}
  -- Require ulti
  use 'nvim-lua/plenary.nvim'
  use 'christoomey/vim-tmux-navigator'
  use {
    'sgur/vim-editorconfig',
    config = function()
      vim.cmd([[
        let g:editorconfig_verbose = 1
      ]])
    end,
  }
  -- Theme
  use 'morhetz/gruvbox'
  -- HighLight
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    requires = {
      {'nvim-treesitter/nvim-treesitter-textobjects'},
      {'p00f/nvim-ts-rainbow'},
      {'JoosepAlviste/nvim-ts-context-commentstring'},
    },
    config = function() require('configs.treesitter') end,
  }
  
  use {
    'neovim/nvim-lspconfig',
    requires = {{'hrsh7th/cmp-nvim-lsp'}, {'folke/lsp-colors.nvim'}},
    config = function()
			require('configs.lspconfig') 
			require'lspconfig'.cssls.setup{}
			require'lspconfig'.tailwindcss.setup{}
			-- require('lsp.clangd-lsp')
      -- require('lsp.ccls-lsp')
      -- require('lsp.sourcekit-lsp')
		end,
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    config = function() require('configs.cmp') end
  }
  use {'windwp/nvim-autopairs',event = 'InsertEnter', config = function() require('configs.autopairs') end}
  use {'hrsh7th/vim-vsnip', event = 'InsertEnter' , requires = {{'hrsh7th/vim-vsnip-integ'}, {'dsznajder/vscode-es7-javascript-react-snippets'}},
    setup = function()
      vim.cmd([[
        " vsnip
      imap <expr><C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      smap <expr><C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
      ]])
    end,
    config = function()
      vim.cmd([[
        let g:vsnip_snippet_dir = expand('$VIM_PATH/snippets')
        let g:vsnip_filetypes = {}
        let g:vsnip_filetypes.javascriptreact = ['javascript']
        let g:vsnip_filetypes.typescriptreact = ['typescript']
      ]])
    end,
  }
  use { 'hrsh7th/cmp-vsnip', after = {'vim-vsnip'}}
  use {
    'sbdchd/neoformat',
    cmd = 'Neoformat',
  }
  use {'tzachar/cmp-tabnine',
    run='./install.sh',
    after = 'nvim-cmp',
    config = function()
      require('configs.cmp-tabnine')
    end,
  }
  
  -- Lsp
  use {
    'jose-elias-alvarez/null-ls.nvim',
    after = {'nvim-lspconfig', 'plenary.nvim'},
    config = function() require('lsp.null-ls-rc') end
  }
  use {
    'jose-elias-alvarez/nvim-lsp-ts-utils',
    after = {'null-ls.nvim'},
    config = function() require('lsp.tsserver-rc') end
  }

  -- use {
  --   'apple/sourcekit-lsp',
  --   after = {'nvim-lspconfig'},
  --   config = function()
  --     require('lsp.sourcekit-lsp')
  --   end,
  -- }

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
    config = function() require('configs.lualine') end,
  }
  -- find file
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'}, 
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
    },
    config = function()
      require('configs.telescope').setup()
      require('configs.telescope').preload()
      require('telescope').load_extension('fzf')
    end,
  }
  
  -- Explorer
  use {
    'lambdalisue/fern.vim',
    config = function()
      vim.cmd(':runtime! lua/configs/fern.vim')
    end,
  }

  use {
    'lambdalisue/nerdfont.vim',
    after = 'fern.vim',
  }
  use {
    'lambdalisue/fern-git-status.vim',
    after = 'fern.vim',
    setup = function()
      vim.cmd([[
        let g:fern_git_status_disable_startup = 1
      ]])
    end,
    configs = function()
      vim.cmd([[
        call fern_git_status#init()
      ]])
    end,
  }
  use {
    'lambdalisue/fern-mapping-git.vim',
    after = 'fern.vim',
  }
  use {
    'lambdalisue/fern-bookmark.vim',
    after = 'fern.vim',
  }
  use {
    'yuki-yano/fern-preview.vim',
    after = 'fern.vim',
  }
  use {
    'lambdalisue/fern-renderer-nerdfont.vim',
    after = 'fern.vim',
    config = function()
      vim.cmd([[
        let g:fern#renderer = 'nerdfont'
        let g:fern#renderer#nerdfont#padding = get(g:, 'global_symbol_padding', ' ')
      ]])
    end,
  }
  use {
    'lambdalisue/glyph-palette.vim',
    after = 'fern.vim',
    config = function()
      vim.cmd([[
        autocmd user_events FileType fern call glyph_palette#apply()
      ]])
    end,
  }

  -- ulti
  use {
    'max397574/better-escape.nvim',
    event = 'InsertEnter',
    config = function()
      require("better_escape").setup {
        mapping = { "jj"}, -- a table with mappings to use
        timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
        clear_empty_lines = false, -- clear line after escaping if there is only whitespace
        keys = "<Esc>", -- keys used for escaping, if it is a function will use the result everytime
        -- example
        -- keys = function()
        --   return vim.fn.col '.' - 2 >= 1 and '<esc>l' or '<esc>'
        -- end,
    }
    end,
  }
  use {
    'folke/which-key.nvim',
    cmd = 'WhichKey',
    config = function()
      require('configs.which-key')
    end,
  }
  use {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    config = function()
      require('configs.zen-mode')
    end,
  }

  use {
    'machakann/vim-sandwich',
    config = function()
      vim.cmd([[
        let g:sandwich_no_default_key_mappings = 1
        let g:operator_sandwich_no_default_key_mappings = 1
        let g:textobj_sandwich_no_default_key_mappings = 1
        nmap sa <Plug>(operator-sandwich-add)
        xmap sa <Plug>(operator-sandwich-add)
        omap sa <Plug>(operator-sandwich-g@)
        nmap sd <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)
        xmap sd <Plug>(operator-sandwich-delete)
        nmap sr <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)
        xmap sr <Plug>(operator-sandwich-replace)
        nmap sdb <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)
        nmap srb <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)
        omap ir <Plug>(textobj-sandwich-auto-i)
        xmap ir <Plug>(textobj-sandwich-auto-i)
        omap ab <Plug>(textobj-sandwich-auto-a)
        xmap ab <Plug>(textobj-sandwich-auto-a)
        omap is <Plug>(textobj-sandwich-query-i)
        xmap is <Plug>(textobj-sandwich-query-i)
        omap as <Plug>(textobj-sandwich-query-a)
        xmap as <Plug>(textobj-sandwich-query-a)
				runtime macros/sandwich/keymap/surround.vim
      ]])
    end,
  }

  use {
    'rhysd/accelerated-jk',
    config = function()
      vim.cmd([[
        nmap <silent> j <Plug>(accelerated_jk_gj)
	      nmap <silent> k <Plug>(accelerated_jk_gk)
      ]])
    end,
  }
  use {
    'haya14busa/vim-edgemotion',
    config = function()
      vim.cmd([[
        nmap gj <Plug>(edgemotion-j)
        nmap gk <Plug>(edgemotion-k)
        xmap gj <Plug>(edgemotion-j)
        xmap gk <Plug>(edgemotion-k)
      ]])
    end,
  }
  use 'windwp/nvim-ts-autotag'

  use {
    'easymotion/vim-easymotion',
    setup = function()
      vim.cmd([[
        let g:EasyMotion_do_mapping = 0
        " Jump to anywhere you want with minimal keystrokes, with just one key binding.
        " `sm{char}{label}`
        nmap sm <Plug>(easymotion-overwin-f)
        " or
        " `sm{char}{char}{label}`
        " Need one more keystroke, but on average, it may be more comfortable.
        nmap sm <Plug>(easymotion-overwin-f2)
        
        " Turn on case-insensitive feature
        let g:EasyMotion_smartcase = 1
        
        " JK motions: Line motions
        " map <Leader>j <Plug>(easymotion-j)
        " map <Leader>k <Plug>(easymotion-k)
      ]])
    end,
    configs = function()
      vim.cmd([[
        
      ]])
    end,
  }

  use {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    cmd = 'BqfAutoToggle',
    event = 'QuickFixCmdPost',
    setup = function()
      vim.cmd([[
        nmap <Leader>q <cmd>lua require('user').qflist.toggle()<CR>
      ]])
    end,
    config = function()
      require('configs.bqf')
    end,
  }

  -- Color tag
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('configs.colorizer')
    end,
  }

  -- Command helper
  use {
    'tyru/caw.vim',
    requires = {'nvim-ts-context-commentstring'},
    config = function()
      vim.g.caw_no_default_keymappings = 1
      vim.g.caw_operator_keymappings = 0
      vim.cmd([[
        function! InitCaw() abort
          if &l:modifiable && &buftype ==# '' && &filetype !=# 'gitrebase'
            xmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)
            nmap <buffer> <Leader>V <Plug>(caw:wrap:toggle)
            xmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)
            nmap <buffer> <Leader>v <Plug>(caw:hatpos:toggle)
            nmap <buffer> gc <Plug>(caw:prefix)
            xmap <buffer> gc <Plug>(caw:prefix)
            nmap <buffer> gcc <Plug>(caw:hatpos:toggle)
            xmap <buffer> gcc <Plug>(caw:hatpos:toggle)
          else
            silent! nunmap <buffer> <Leader>V
            silent! xunmap <buffer> <Leader>V
            silent! nunmap <buffer> <Leader>v
            silent! xunmap <buffer> <Leader>v
            silent! nunmap <buffer> gc
            silent! xunmap <buffer> gc
            silent! nunmap <buffer> gcc
            silent! xunmap <buffer> gcc
          endif
        endfunction
        autocmd user_events FileType * call InitCaw()
        call InitCaw()
      ]])
    end,
  }


end)
