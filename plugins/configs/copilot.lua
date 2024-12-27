-- Configuration de base de Copilot
vim.g.copilot_no_tab_map = false  -- Permet d'utiliser Tab pour les suggestions
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- Configurations supplémentaires pour améliorer l'expérience
vim.g.copilot_filetypes = {
    ["*"] = true,
    ["help"] = false,
    ["gitcommit"] = false,
    ["gitrebase"] = false,
    ["hgcommit"] = false,
    ["svn"] = false,
    ["cvs"] = false,
}

-- Mapping personnalisé pour Copilot
vim.api.nvim_set_keymap('i', '<Tab>', 'copilot#Accept("<CR>")', {
    expr = true,
    silent = true,
    replace_keycodes = false
}) 