-- Define the leader key as space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Function for key mapping
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
      options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Keybinding for zoom
map('n', '<leader>df', ':lua require("core.window").zoom_window()<CR>')

-- Autocommand to restore windows on FocusLost
vim.api.nvim_create_augroup('ZoomRestore', { clear = true })
vim.api.nvim_create_autocmd('FocusLost', {
  group = 'ZoomRestore',
  callback = function()
      require('core.window').restore_windows()
  end
})

-- core.window module
local M = {}

-- Stockage des fenêtres zoomées et leurs configurations
local zoomed_windows = {}

function M.zoom_window()
    local current_win = vim.api.nvim_get_current_win()
    
    -- Si la fenêtre est déjà zoomée, on la restaure
    if zoomed_windows[current_win] then
        -- Restaurer les dimensions originales
        local saved = zoomed_windows[current_win]
        vim.cmd('resize ' .. saved.height)
        vim.cmd('vertical resize ' .. saved.width)
        
        -- Restaurer les valeurs minimales
        vim.o.winminheight = saved.winminheight
        vim.o.winminwidth = saved.winminwidth
        
        -- Équilibrer les fenêtres
        vim.cmd('wincmd =')
        
        -- Supprimer la sauvegarde
        zoomed_windows[current_win] = nil
        return
    end
    
    -- Sauvegarder la configuration actuelle
    zoomed_windows[current_win] = {
        height = vim.api.nvim_win_get_height(current_win),
        width = vim.api.nvim_win_get_width(current_win),
        winminheight = vim.o.winminheight,
        winminwidth = vim.o.winminwidth
    }
    
    -- Définir temporairement les valeurs minimales à 0
    vim.o.winminheight = 0
    vim.o.winminwidth = 0
    
    -- Redimensionner la fenêtre courante à 80%
    -- Ajuster la hauteur en tenant compte de la ligne de commande et autres éléments UI
    local cmdheight = vim.o.cmdheight
    local tabline = vim.o.showtabline > 0 and 1 or 0
    local statusline = vim.o.laststatus > 0 and 1 or 0
    
    local available_height = vim.o.lines - cmdheight - tabline - statusline
    local win_height = math.floor(available_height * 0.8)
    local win_width = math.floor(vim.o.columns * 0.8)
    
    -- Forcer d'abord la hauteur maximale puis ajuster
    vim.cmd('resize 999')
    vim.cmd('resize ' .. win_height)
    vim.cmd('vertical resize ' .. win_width)
end

return M
