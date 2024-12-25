local M = {}

-- Variables pour suivre l'état
local move_mode = false
local inactivity_timer = nil
local inactivity_timeout = 1000 -- millisecondes

-- Fonction pour déplacer les lignes
function M.move_line(direction)
    local mode = vim.fn.mode()
    
    -- Vérifier si le buffer est modifiable
    if not vim.bo.modifiable then
        return
    end

    -- Déterminer les lignes de début et de fin
    local first_line, last_line
    if mode == 'n' then
        first_line = vim.fn.line('.')
        last_line = first_line
    else
        first_line = vim.fn.line("'<")
        last_line = vim.fn.line("'>")
    end

    -- Sauvegarder la position actuelle
    local old_pos = vim.fn.getcurpos()
    
    -- Calculer la ligne de destination
    local after_line
    if direction == 'up' then
        vim.fn.cursor(first_line, 1)
        vim.cmd('normal! k')
        after_line = vim.fn.line('.') - 1
    else
        vim.fn.cursor(last_line, 1)
        vim.cmd('normal! j')
        local fold_end = vim.fn.foldclosedend('.')
        after_line = fold_end == -1 and vim.fn.line('.') or fold_end
    end

    -- Restaurer la position du curseur
    vim.fn.setpos('.', old_pos)

    -- Déplacer les lignes
    vim.cmd(string.format('%d,%dmove %d', first_line, last_line, after_line))

    -- Gérer l'indentation automatique
    if vim.g.move_auto_indent then
        local new_first = vim.fn.line("'[")
        local new_last = vim.fn.line("']")

        -- Indenter la première ligne et obtenir le niveau d'indentation
        vim.fn.cursor(new_first, 1)
        local old_indent = vim.fn.indent('.')
        vim.cmd('normal! ==')
        local new_indent = vim.fn.indent('.')

        -- Ajuster l'indentation des lignes suivantes si nécessaire
        if new_first < new_last and old_indent ~= new_indent then
            local old_sw = vim.bo.shiftwidth
            vim.bo.shiftwidth = 1
            
            local indent_cmd
            if old_indent < new_indent then
                indent_cmd = string.rep('>', new_indent - old_indent)
            else
                indent_cmd = string.rep('<', old_indent - new_indent)
            end
            
            vim.cmd(string.format('%d,%d%s', new_first + 1, new_last, indent_cmd))
            vim.bo.shiftwidth = old_sw
        end

        -- Mettre à jour les marques
        vim.fn.cursor(new_first, 1)
        vim.cmd('normal! 0m[')
        vim.fn.cursor(new_last, 1)
        vim.cmd('normal! $m]')
    end

    -- Restaurer la sélection visuelle si nécessaire
    if mode == 'v' or mode == 'V' then
        vim.cmd('normal! gv')
    end
end

-- Fonction pour activer le mode de déplacement
function M.activate_move_mode(direction)
    move_mode = true
    M.move_line(direction)

    -- Créer des mappings temporaires pour j et k
    vim.keymap.set({'n', 'v'}, 'j', function()
        if move_mode then
            M.move_line('down')
        end
    end, { buffer = true, silent = true })

    vim.keymap.set({'n', 'v'}, 'k', function()
        if move_mode then
            M.move_line('up')
        end
    end, { buffer = true, silent = true })
end

-- Fonction pour arrêter le mouvement
function M.stop_move()
    move_mode = false
    if inactivity_timer then
        inactivity_timer:stop()
        inactivity_timer:close()
        inactivity_timer = nil
    end
    pcall(vim.keymap.del, {'n', 'v'}, 'j', { buffer = true })
    pcall(vim.keymap.del, {'n', 'v'}, 'k', { buffer = true })
end

-- Configuration des mappings
function M.setup()
    -- Ajouter cette ligne au début de setup()
    vim.g.move_auto_indent = true
    
    -- Mappings pour le début du mouvement
    vim.keymap.set({'n', 'v'}, '`j', function()
        M.activate_move_mode('down')
    end, { silent = true })

    vim.keymap.set({'n', 'v'}, '`k', function()
        M.activate_move_mode('up')
    end, { silent = true })

    -- Mapping pour arrêter le mouvement
    vim.keymap.set({'n', 'v'}, '`', function()
        M.stop_move()
    end, { silent = true })

    -- Arrêter le mouvement sur Échap
    vim.keymap.set({'n', 'v'}, '<Esc>', function()
        M.stop_move()
    end, { silent = true })

    -- Arrêter le mouvement quand on quitte le buffer ou entre en mode insertion
    vim.api.nvim_create_autocmd({'BufLeave', 'InsertEnter'}, {
        callback = function()
            M.stop_move()
        end
    })
end

return M
