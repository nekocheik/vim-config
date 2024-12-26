local function get_persisted_sessions()
    local sessions = require('persisted').list()
    local formatted_sessions = {}
    
    for _, session in ipairs(sessions) do
        table.insert(formatted_sessions, {
            line = session.name,
            cmd = string.format([[lua require("persisted").load({ session = "%s" })]], session.name)
        })
    end
    
    return formatted_sessions
end

vim.g.startify_lists = {
    { type = 'sessions',  header = {'   Sessions'}, function() return get_persisted_sessions() end },
    { type = 'files',     header = {'   MRU'} },
    { type = 'dir',       header = {'   MRU ' .. vim.fn.getcwd()} },
    { type = 'bookmarks', header = {'   Bookmarks'} },
    { type = 'commands',  header = {'   Commands'} },
}

-- Configuration additionnelle de Startify
vim.g.startify_session_autoload = true
vim.g.startify_session_delete_buffers = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_persistence = 0  -- Désactivé car nous utilisons persisted.nvim
vim.g.startify_enable_special = 0
vim.g.startify_custom_header = {
    '   Bienvenue dans Neovim',
    '',
}

-- Custom commands dans Startify
vim.g.startify_commands = {
    { s = {'Nouvelle Session', ':SessionSave'}},
    { l = {'Charger Session', ':SessionLoad'}},
    { d = {'Supprimer Session', ':SessionDelete'}},
} 