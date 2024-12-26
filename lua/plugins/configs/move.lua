-- -- Configuration pour vim-move sur macOS
-- vim.g.move_key_modifier = 'M'     -- 'M' représente Meta/Alt sur macOS
-- vim.g.move_map_keys = 1           -- Active les mappings par défaut
-- vim.g.move_auto_indent = 1        -- Active l'indentation automatique

-- -- Mappings personnalisés pour macOS (si les mappings par défaut ne fonctionnent pas)
-- vim.keymap.set('n', '˚', '<Plug>MoveLineUp')     -- Option + k
-- vim.keymap.set('n', '∆', '<Plug>MoveLineDown')   -- Option + j
-- vim.keymap.set('n', '˙', '<Plug>MoveCharLeft')   -- Option + h
-- vim.keymap.set('n', '¬', '<Plug>MoveCharRight')  -- Option + l

-- -- Pour le mode visuel
-- vim.keymap.set('v', '˚', '<Plug>MoveBlockUp')    -- Option + k
-- vim.keymap.set('v', '∆', '<Plug>MoveBlockDown')  -- Option + j
-- vim.keymap.set('v', '˙', '<Plug>MoveBlockLeft')  -- Option + h
-- vim.keymap.set('v', '¬', '<Plug>MoveBlockRight') -- Option + l