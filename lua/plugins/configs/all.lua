-- Chargement de tous les plugins
local plugins = {
    'startify',
    'cmp',
    'spectre',
    'accelerated',
    'scrollbar',
    'sessions',
    'coc',
    'move',
    'persisted',
    'notify',
    'hover',
    'vimspector'
}

for _, plugin in ipairs(plugins) do
    require('plugins.configs.' .. plugin)
end

-- Configurations globales
vim.g.maximizer_set_default_mapping = 0
vim.g.maximizer_set_mapping_with_bang = 1 