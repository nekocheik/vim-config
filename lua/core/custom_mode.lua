local M = {}

-- Variable globale pour suivre l'état du mode
M.custom_mode_active = false

-- Table pour stocker les mappages originaux
local original_mappings = {}

-- Timers pour la désactivation automatique et le décompte
local auto_disable_timer = nil
local countdown_timer = nil
local remaining_seconds = 45

-- Chemin du fichier temporaire
local tmp_file = '/tmp/nvim_custom_mode_status'

-- Fonction pour mettre à jour le fichier d'état
local function update_status_file()
    local file = io.open(tmp_file, "w")
    if file then
        file:write(M.custom_mode_active and "true" or "false")
        file:close()
    end
end

-- Créer le fichier immédiatement au démarrage et définir la couleur par défaut
do
    update_status_file()
    vim.schedule(function()
        -- Supprimer la ligne qui change la couleur de fond par défaut
        -- vim.cmd([[highlight Normal guibg=NONE]])
    end)
end

-- Fonction pour exécuter une commande shell
local function execute_command(cmd)
    vim.fn.system(cmd)
end

function M.toggle_custom_mode()
    if M.custom_mode_active then
        -- Désactiver le mode personnalisé
        for _, mapping in ipairs(original_mappings) do
            vim.keymap.del(mapping.mode, mapping.lhs, { buffer = 0 })
        end
        
        execute_command([[osascript -e 'tell application "Hammerspoon" to execute "enableCustomShortcuts()"']])
        
        original_mappings = {}
        M.custom_mode_active = false
        update_status_file()
        
        -- Annuler les timers s'ils existent
        if auto_disable_timer then
            auto_disable_timer:stop()
            auto_disable_timer:close()
            auto_disable_timer = nil
        end
        if countdown_timer then
            countdown_timer:stop()
            countdown_timer:close()
            countdown_timer = nil
        end
        
        vim.notify("Mode personnalisé désactivé", vim.log.levels.INFO)
    else
        -- Activer le mode personnalisé
        local current_mappings = vim.api.nvim_get_keymap('n')
        for _, map in ipairs(current_mappings) do
            if map.lhs == 'j' or map.lhs == 'k' then
                table.insert(original_mappings, map)
            end
        end

        execute_command([[osascript -e 'tell application "Hammerspoon" to execute "disableCustomShortcuts()"']])

        vim.keymap.set('n', 'k', 'gk', { buffer = 0, silent = true })
        vim.keymap.set('n', 'j', 'gj', { buffer = 0, silent = true })
        
        M.custom_mode_active = true
        update_status_file()
        
        -- Réinitialiser le compteur
        remaining_seconds = 45
        
        -- Créer un nouveau timer pour le décompte chaque seconde
        if countdown_timer then
            countdown_timer:stop()
            countdown_timer:close()
        end
        countdown_timer = vim.loop.new_timer()
        countdown_timer:start(0, 1000, vim.schedule_wrap(function()
            remaining_seconds = remaining_seconds - 1
            vim.notify("Mode personnalisé : " .. remaining_seconds .. "s restantes", vim.log.levels.INFO)
        end))
        
        -- Créer un nouveau timer pour désactiver automatiquement après 45 secondes
        if auto_disable_timer then
            auto_disable_timer:stop()
            auto_disable_timer:close()
        end
        auto_disable_timer = vim.loop.new_timer()
        auto_disable_timer:start(45000, 0, vim.schedule_wrap(function()
            if M.custom_mode_active then
                M.toggle_custom_mode()
            end
        end))
        
        vim.notify("Mode personnalisé activé (45s)", vim.log.levels.INFO)
    end
end

-- Timer pour mettre à jour le statut régulièrement (optionnel)
local timer = vim.loop.new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
    update_status_file()
end))

-- Nettoyer le timer à la fermeture de Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        if timer then
            timer:stop()
            timer:close()
        end
        -- Réinitialiser le fichier de statut
        local file = io.open(tmp_file, "w")
        if file then
            file:write("false")
            file:close()
        end
    end
})

return M 