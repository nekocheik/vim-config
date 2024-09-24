augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

vim.cmd [[packadd packer.nvim]]

local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end


return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-pack/nvim-spectre',
    requires = {'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons'}
  }
  use { 'junegunn/fzf', run = './install --bin' }
  use { 'junegunn/fzf.vim' }

  -- Your plugins here
  --
  use 'folke/which-key.nvim'
  use 'matze/vim-move'
  use 'roxma/vim-tmux-clipboard'
  use 'neoclide/coc.nvim'
  use 'folke/tokyonight.nvim'
  use 'tmux-plugins/vim-tmux-focus-events'
  use 'christoomey/vim-tmux-navigator'
  use 'cohama/lexima.vim'
  use 'preservim/nerdcommenter'
  use 'tpope/vim-surround'
  use 'kien/ctrlp.vim'
  use 'thaerkh/vim-indentguides'
  use 'lucasprag/simpleblack'
  use 'prabirshrestha/vim-lsp'
  use 'mattn/vim-lsp-settings'
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'petertriho/nvim-scrollbar'
  use 'nathanaelkane/vim-indent-guides'
  use 'christoomey/vim-system-copy'
  use 'wfxr/minimap.vim'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
  use 'romgrk/barbar.nvim'
  use 'mhinz/vim-startify'
  use 'junegunn/fzf'
  use {'catppuccin/nvim', as = 'catppuccin'}
  use {'mg979/vim-visual-multi', branch = 'master'}
  use 'tpope/vim-fugitive'
  use 'junegunn/gv.vim'
  use 'neoclide/coc-tabnine'
  use 'antosha417/nvim-lsp-file-operations'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-tree/nvim-tree.lua'
  use 'tmhedberg/simpylfold'
  use 'mhinz/vim-signify'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'pseewald/vim-anyfold'
  use 'onsails/lspkind-nvim'
  use 'stevearc/dressing.nvim'
  use 'MunifTanjim/nui.nvim'
  use 'echasnovski/mini.icons'
  use 'HakonHarnes/img-clip.nvim'
  use 'zbirenbaum/copilot.lua'
  use 'ibhagwan/fzf-lua'


  if packer_bootstrap then
    require('packer').sync()
  end
end)
