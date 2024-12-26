vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-pack/nvim-spectre',
    requires = {'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons'}
  }
  use { 'junegunn/fzf', run = './install --bin' }
  use { 'junegunn/fzf.vim' }

  use 'folke/which-key.nvim'
  use 'roxma/vim-tmux-clipboard'
  use "NvChad/nvim-colorizer.lua"
  use 'anhpt379/nvim-cursorword'
  use {'neoclide/coc.nvim',branch = 'master', run = 'npm ci', }
  use 'folke/tokyonight.nvim'
  use 'tmux-plugins/vim-tmux-focus-events'
  use 'AndrewRadev/tagalong.vim'
  -- use 'windwp/nvim-ts-autotag'
  use 'azabiong/vim-highlighter'
  use 'terryma/vim-expand-region'
  use 'tpope/vim-obsession'
  -- use 'dominickng/fzf-session.vim'
  use {
    'andymass/vim-matchup',
  }
  use 'alvan/vim-closetag'
  use 'jiangmiao/auto-pairs'
  use 'christoomey/vim-tmux-navigator'
  use 'preservim/nerdcommenter'
  use 'tpope/vim-surround'
  use 'thaerkh/vim-indentguides'
  use 'lucasprag/simpleblack'
  use 'prabirshrestha/vim-lsp'
  use 'mattn/vim-lsp-settings'
  use 'petertriho/nvim-scrollbar'
  use 'nathanaelkane/vim-indent-guides'
  use 'christoomey/vim-system-copy'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
  use 'romgrk/barbar.nvim'
  use 'mhinz/vim-startify'
  use {'catppuccin/nvim', as = 'catppuccin'}
  use {'mg979/vim-visual-multi', branch = 'master'}
  use 'tpope/vim-fugitive'
  use 'junegunn/gv.vim'
  use 'neoclide/coc-tabnine'
  use 'antosha417/nvim-lsp-file-operations'
  use 'nvim-lua/plenary.nvim'

  use 'matze/vim-move'
  use 'nvim-tree/nvim-tree.lua'
  use 'tmhedberg/simpylfold'
  use 'mhinz/vim-signify'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {
    'pseewald/vim-anyfold',
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        command = "AnyFoldActivate"
      })
    end
  }
  use {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("plugins.configs.copilot").setup()
    end,
  }
  use 'onsails/lspkind-nvim'
  use 'stevearc/dressing.nvim'
  use 'MunifTanjim/nui.nvim'
  use 'echasnovski/mini.icons'
  use 'HakonHarnes/img-clip.nvim'
  use 'github/copilot.vim'
  use 'ibhagwan/fzf-lua'
  use "sindrets/diffview.nvim" 

  vim.g.matchup_matchparen_offscreen = { method = "popup" }
  if packer_bootstrap then
    require('packer').sync()
  end

  use 'tpope/vim-unimpaired'
end)
