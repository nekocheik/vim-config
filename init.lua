-- Chargements essentiels
require('utils.functions')      -- Charger les fonctions utilitaires en premier
require('plugins')           
require('core.keymaps')      
require('core.options')      

-- Configurations des plugins
require('plugins.configs.copilot')  -- Nouvelle configuration
require('plugins.configs.avante')   -- Nouvelle configuration
require('plugins.configs.git')      -- Nouvelle configuration
require('plugins.configs.theme')    -- Nouvelle configuration
require('plugins.configs.debug')    -- Nouvelle configuration

-- Chargement des configurations de base
require('core.autocmds')
require('core.custom_mode')
require('core.underlineworld')

-- Chargement des plugins additionnels
require('plugins.configs.all')      -- Nouveau fichier pour gérer tous les plugins
