local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

-- Gestionnaires de plugins et utilitaires de base
Plug('nvim-pack/nvim-spectre', { 
    requires = {'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons'}
})
Plug('junegunn/fzf', { ['do'] = './install --bin' })
Plug('junegunn/fzf.vim')
Plug('folke/which-key.nvim')
Plug('roxma/vim-tmux-clipboard')
Plug('NvChad/nvim-colorizer.lua')
Plug('anhpt379/nvim-cursorword')
Plug('neoclide/coc.nvim', { ['branch'] = 'master', ['do'] = 'npm ci' })
Plug('folke/tokyonight.nvim')
Plug('tmux-plugins/vim-tmux-focus-events')
Plug('AndrewRadev/tagalong.vim')
Plug('azabiong/vim-highlighter')
Plug('terryma/vim-expand-region')
Plug('tpope/vim-obsession')
Plug('andymass/vim-matchup')
Plug('alvan/vim-closetag')
Plug('jiangmiao/auto-pairs')
Plug('christoomey/vim-tmux-navigator')
Plug('preservim/nerdcommenter')
Plug('tpope/vim-surround')
Plug('thaerkh/vim-indentguides')
Plug('lucasprag/simpleblack')
Plug('prabirshrestha/vim-lsp')
Plug('mattn/vim-lsp-settings')
Plug('petertriho/nvim-scrollbar')
Plug('nathanaelkane/vim-indent-guides')
Plug('christoomey/vim-system-copy')
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')
Plug('ryanoasis/vim-devicons')
Plug('kyazdani42/nvim-web-devicons')
Plug('romgrk/barbar.nvim')
Plug('mhinz/vim-startify')
Plug('catppuccin/nvim', { ['as'] = 'catppuccin' })
Plug('mg979/vim-visual-multi', { ['branch'] = 'master' })
Plug('tpope/vim-fugitive')
Plug('junegunn/gv.vim')
Plug('neoclide/coc-tabnine')
Plug('antosha417/nvim-lsp-file-operations')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-tree/nvim-tree.lua')
Plug('tmhedberg/simpylfold')
Plug('mhinz/vim-signify')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('pseewald/vim-anyfold')
Plug('zbirenbaum/copilot.lua')
Plug('onsails/lspkind-nvim')
Plug('stevearc/dressing.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('echasnovski/mini.icons')
Plug('HakonHarnes/img-clip.nvim')
Plug('github/copilot.vim')
Plug('ibhagwan/fzf-lua')
Plug('sindrets/diffview.nvim')
Plug('matze/vim-move')


vim.call('plug#end')

-- Après plug#end, ajoutez cette configuration pour airline
vim.g.airline_extensions = {
    'branch',
    'hunks',
    'coc',
    'tabline',
    'fzf',
    'netrw',
    'quickfix',
    'wordcount',
    'term'
}

-- Désactiver le chargement automatique des extensions
vim.g.airline_skip_empty_sections = 1

-- Configuration pour matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }

