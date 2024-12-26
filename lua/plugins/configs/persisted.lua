require('persisted').setup({
    save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- répertoire où sauvegarder les sessions
    use_git_branch = true,   -- inclure la branche git dans le nom de session
    autosave = true,         -- sauvegarde automatique de la session
    autoload = false,        -- ne pas charger automatiquement la dernière session
    on_autoload_no_session = function()
        vim.notify("Pas de session existante", vim.log.levels.INFO)
    end,
    telescope = {
        before_source = function()
            vim.api.nvim_command('%bdelete!')
        end,
        after_source = function(session)
            vim.notify("Session chargée: " .. session.name, vim.log.levels.INFO)
        end,
    },
    should_autosave = function()
        -- Conditions où vous ne voulez PAS sauvegarder automatiquement
        local ignored_filetypes = {
            'gitcommit',
            'gitrebase',
            'startify',
            'TelescopePrompt'
        }
        
        if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            return false
        end
        
        return true
    end
})

-- Créer une commande personnalisée pour Exit qui sauvegarde la session
vim.api.nvim_create_user_command('Exit', function()
    -- Sauvegarder la session avant de quitter
    require('persisted').save()
    -- Quitter Vim
    vim.cmd('qa')
end, {})

-- Créer un alias pour :exit qui pointe vers :Exit
vim.cmd([[cnoreabbrev exit Exit]]) 