local function format_session_info(session)
    -- Vérification que la session est valide
    if not session or type(session) ~= "table" then
        return {
            line = "Session invalide",
            cmd = ""
        }
    end

    -- Récupérer les informations de la session avec vérification
    local name = session.name or "Sans nom"
    local branch = session.branch and ' [' .. session.branch .. ']' or ''
    local time = session.time and os.date('%Y-%m-%d %H:%M', session.time) or "Date inconnue"
    
    -- Formater le nom de la session avec des détails
    local display_name = name .. branch .. ' (' .. time .. ')'
    
    -- Récupérer les détails des buffers de la session
    local session_path = session.file_path and 
        vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/" .. session.file_path) or ""
    local has_session = vim.fn.filereadable(session_path) == 1
    
    if has_session then
        return {
            line = display_name,
            cmd = string.format([[lua require("persisted").load({ session = "%s" })]], name)
        }
    end
    
    return {
        line = display_name .. ' (vide)',
        cmd = string.format([[lua require("persisted").load({ session = "%s" })]], name)
    }
end

local function get_persisted_sessions()
    local ok, sessions = pcall(require('persisted').list)
    if not ok or not sessions then
        return {}
    end
    
    local formatted_sessions = {}
    for _, session in ipairs(sessions) do
        table.insert(formatted_sessions, format_session_info(session))
    end
    
    return formatted_sessions
end

-- Configuration de Startify
vim.g.startify_lists = {
    { type = 'files',     header = {'   MRU'} },
    { type = 'dir',       header = {'   MRU ' .. vim.fn.getcwd()} },
    { type = 'bookmarks', header = {'   Bookmarks'} },
    { type = 'commands',  header = {'   Commands'} }
}

-- Configuration additionnelle de Startify
vim.g.startify_session_autoload = true
vim.g.startify_session_delete_buffers = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_persistence = 0
vim.g.startify_enable_special = 0
vim.g.startify_padding_left = 3
vim.g.startify_relative_path = 1
vim.g.startify_session_sort = 1

-- En-tête personnalisé
vim.g.startify_custom_header = {
    '',
    '   Bienvenue dans Neovim',
    ''
}

-- Commandes personnalisées
vim.g.startify_commands = {
    {s = {'Nouvelle Session', 'SessionSave'}},
    {l = {'Charger Session', 'SessionLoad'}},
    {d = {'Supprimer Session', 'SessionDelete'}}
}

-- Ajouter les sessions persisted à la liste
vim.api.nvim_create_autocmd("User", {
    pattern = "StartifyReady",
    callback = function()
        local sessions = get_persisted_sessions()
        if #sessions > 0 then
            table.insert(vim.g.startify_lists, 1, {
                type = function() return sessions end,
                header = {'   Sessions'}
            })
        end
    end
})