local M = {}

-- Stocker les dimensions originales des fenêtres
local original_dimensions = {}

function M.zoom_window()
    local current_win = vim.api.nvim_get_current_win()
    
    -- Sauvegarder les dimensions de toutes les fenêtres si pas déjà fait
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not original_dimensions[win] then
            original_dimensions[win] = {
                width = vim.api.nvim_win_get_width(win),
                height = vim.api.nvim_win_get_height(win)
            }
        end
    end

    -- Redimensionner la fenêtre courante à 80%
    local win_height = math.floor(vim.o.lines * 0.8)
    local win_width = math.floor(vim.o.columns * 0.8)
    
    -- Réduire toutes les autres fenêtres
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= current_win then
            vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.2))
            vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * 0.2))
        end
    end

    -- Zoomer la fenêtre courante
    vim.api.nvim_win_set_width(current_win, win_width)
    vim.api.nvim_win_set_height(current_win, win_height)
end

-- Fonction pour restaurer les dimensions originales
function M.restore_dimensions()
    for win, dims in pairs(original_dimensions) do
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_width(win, dims.width)
            vim.api.nvim_win_set_height(win, dims.height)
        end
    end
end

-- Configuration de l'autocommande pour le changement de fenêtre
vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        -- Restaurer les dimensions originales
        M.restore_dimensions()
        -- Vider le stockage des dimensions originales
        original_dimensions = {}
    end
})

return M 