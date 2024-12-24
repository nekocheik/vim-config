-- Configuration de base
require('core.options')      -- Options de base de Neovim d'abord
require('core.keymaps')      -- Puis les mappings de touches
require('core.autocmds')     -- Ensuite les autocommandes
require('core.underlineworld')

-- Utilitaires
require('utils.functions')   -- Fonctions utilitaires avant les plugins

-- Plugins et leurs configurations
require('plugins')           -- Chargement principal des plugins
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions') 
require('utils.functions')
