require('core.keymaps')      
require('plugins')           

-- Configuration de base
require('core.options')      -- Déplacer options avant underlineworld
require('core.underlineworld')

-- Plugins et leurs configurations
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions')
require('plugins.configs.coc')
require('utils.functions')

require('core.autocmds')
