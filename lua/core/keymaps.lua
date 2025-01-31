-- Définir la touche leader comme espace
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Fonction de mapping
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- General mappings
map('n', '<Leader>m', ':source $MYVIMRC<CR>')
map('n', '<leader>;', ':Commentary<CR>')
map('n', '<C-s>', ':w!<CR>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>r', ':source $MYVIMRC<CR>:echo "nvim config reloaded!"<CR>')

map('n', '<leader>b', ':Buffers<CR>')
map('n', '<leader>rg', ':Rg<CR>')

map('n', '<leader>qf', '<Plug>(coc-fix-current)')
map('n', '<leader>dn', '<Plug>(coc-diagnostic-next-error)')
map('n', '<leader>dp', '<Plug>(coc-diagnostic-prev-error)')
map('n', 'K', '<Plug>(coc-hover)')
map('n', '<leader>ty', ':call CocAction("type")<CR>')
map('n', '<space>e', '<Cmd>CocCommand explorer<CR>')
map('x', '<leader>ac', '<Plug>(coc-codeaction-selected)')
map('n', 'gd', '<Plug>(coc-definition)')
map('n', 'gD', '<Plug>(coc-implementation)')
map('n', 'gr', '<Plug>(coc-references)')
map('n', '<leader>rn', '<Plug>(coc-rename)')

map('n', 'gf', ':lua CreateFileIfNotExist()<CR>')
map('n', 'K', ':lua HandleK()<CR>')

map('n', '<leader>k', ':lua SearchWithFzfFromClipboard()<CR>')

map('n', '<leader>aa', ':AvanteToggle<CR>')
map('n', '<leader>ar', ':AvanteRefresh<CR>')
map('n', '<leader>ae', ':AvanteEdit<CR>')
map('n', '<C-p>', ':lua vim.cmd("cd " .. ProjectRoot() .. " | Files")<CR>')
map('n', '<leader>f', ':Files<CR>')

vim.keymap.set('n', '<leader>S', ':lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>sw', ':lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc>:lua require("spectre").open_visual()<CR>', {
  desc = "Search current word"
})
vim.keymap.set('n', '<leader>sp', ':lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "Search on current file"
})

vim.api.nvim_set_keymap('n', 'U', '<C-r>', { noremap = true, silent = true })

map('n', '<leader>tw', ':!python3  ~/Project/Projet/transcrib.py &<CR>')

vim.keymap.set('n', '<leader>tm', require('core.custom_mode').toggle_custom_mode, 
    { desc = 'Toggle mode personnalisé' })

-- Mapping pour vim-maximizer
map('n', '<leader>df', ':MaximizerToggle<CR>')  -- Toggle maximize/restore
map('n', '<leader>dc', ':wincmd =<CR>')         -- Équilibrer toutes les fenêtres

-- Mappings optionnels pour les autres modes
map('v', '<leader>df', ':MaximizerToggle<CR>gv')
map('i', '<leader>df', '<C-o>:MaximizerToggle<CR>')

-- Supprimez ou commentez l'ancien code de zoom_restore
-- vim.g.zoom_restore_enabled = true
-- local function toggle_zoom_restore() ...
-- etc.

-- Gestion des sessions
map('n', '<leader>ss', ':SessionSave<CR>', { desc = 'Sauvegarder la session' })
map('n', '<leader>sl', ':SessionLoad<CR>', { desc = 'Charger une session' })
map('n', '<leader>sd', ':SessionDelete<CR>', { desc = 'Supprimer la session' })

-- Mappings pour Vimspector
vim.api.nvim_set_keymap('n', '<Leader>di', '<Plug>VimspectorBalloonEval', { noremap = false })
vim.api.nvim_set_keymap('x', '<Leader>di', '<Plug>VimspectorBalloonEval', { noremap = false })

-- Mapping personnalisé pour lancer le débogueur
vim.api.nvim_set_keymap('n', '<Leader>dd', ':call vimspector#Launch()<CR>', { noremap = true, silent = true })

-- Mappings pour nvim-notify
map('n', '<leader>fn', ':Telescope notify<CR>', { desc = 'Rechercher les notifications' })
map('n', '<leader>nn', ':Notifications<CR>', { desc = 'Afficher l\'historique des notifications' })

