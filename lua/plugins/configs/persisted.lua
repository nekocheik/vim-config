require('persisted').setup({
    save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- répertoire où sauvegarder les sessions
    command = "VimLeavePre", -- moment où sauvegarder automatiquement
    use_git_branch = true,   -- inclure la branche git dans le nom de session
    autosave = true,         -- sauvegarde automatique de la session
    autoload = false,        -- ne pas charger automatiquement la dernière session
    on_autoload_no_session = function()
        vim.notify("Pas de session existante", vim.log.levels.INFO)
    end,
    telescope = {  -- intégration avec telescope
        before_source = function()
            -- Fermer tous les buffers avant de charger une session
            vim.api.nvim_command('%bdelete!')
        end,
        after_source = function(session)
            vim.notify("Session chargée: " .. session.name, vim.log.levels.INFO)
        end,
    }
})

-- Créer les commandes pour telescope
vim.api.nvim_create_user_command('SessionLoad', function()
    require('telescope').extensions.persisted.persisted()
end, {}) 