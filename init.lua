require('plugins')           
require('core.keymaps')      
require('core.options')      -- Déplacer options avant underlineworld
require('core.underlineworld')
require('plugins.configs.move')
require('plugins.configs.persisted')

-- Ajouter un keymap de test pour les contrôles
vim.api.nvim_create_autocmd({"VimEnter"}, {
    callback = function()
        -- Créer une fonction pour logger les touches
        local function log_keypress(key)
            local log_file = io.open('/tmp/nvim_keypress.log', 'a')
            if log_file then
                log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - Pressed: " .. key .. "\n")
                log_file:close()
            end
        end

        -- Mapper les touches de contrôle
        vim.keymap.set('n', '<C-h>', function() log_keypress('Ctrl-h') end, {silent = true})
        vim.keymap.set('n', '<C-j>', function() log_keypress('Ctrl-j') end, {silent = true})
        vim.keymap.set('n', '<C-k>', function() log_keypress('Ctrl-k') end, {silent = true})
        vim.keymap.set('n', '<C-l>', function() log_keypress('Ctrl-l') end, {silent = true})
        vim.keymap.set('n', '<C-h>', '<C-w>h', {silent = true})
        vim.keymap.set('n', '<C-j>', '<C-w>j', {silent = true})
        vim.keymap.set('n', '<C-k>', '<C-w>k', {silent = true})
        vim.keymap.set('n', '<C-l>', '<C-w>l', {silent = true})
    end
})


-- vim.g.move_key_modifier = 'D'  -- Pour Command


-- Plugins et leurs configurations
require('plugins.configs.startify')
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions')
require('plugins.configs.coc')
require('utils.functions')
require('core.autocmds')
require('core.custom_mode')

vim.g.maximizer_set_default_mapping = 0  -- Désactive le mapping par défaut (F3)
vim.g.maximizer_set_mapping_with_bang = 1  -- Utilise la version avec bang par défaut


