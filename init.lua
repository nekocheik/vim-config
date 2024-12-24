vim.cmd [[packadd packer.nvim]]


require('plugins')           -- Chargement principal des plugins
-- -- Configuration de base
require('core.keymaps')      -- Puis les mappings de touches
require('core.underlineworld')

-- Plugins et leurs configurations
require('core.options')      -- Options de base de Neovim d'abord
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions') 
require('plugins.configs.coc') 
require('utils.functions')

require('core.autocmds')     -- Ensuite les autocommandes
