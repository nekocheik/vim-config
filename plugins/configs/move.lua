-- Configuration complète de vim-move
vim.g.move_map_keys = 0  -- Désactive les mappings par défaut
vim.g.move_key_modifier = 'leader'
vim.g.move_auto_indent = 1

-- Définir nos propres mappings
vim.keymap.set('n', '<leader>j', '<Plug>MoveLineDown')
vim.keymap.set('n', '<leader>k', '<Plug>MoveLineUp')
vim.keymap.set('v', '<leader>j', '<Plug>MoveBlockDown')
vim.keymap.set('v', '<leader>k', '<Plug>MoveBlockUp') 