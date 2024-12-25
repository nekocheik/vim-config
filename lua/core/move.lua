local M = {}

-- Variables pour suivre l'état
local move_mode = false
local inactivity_timer = nil
local inactivity_timeout = 1000 -- millisecondes

-- Fonction pour déplacer les lignes
function M.move_line(direction)
    local mode = vim.fn.mode()
    local current_line = vim.fn.line('.')
    local last_line = vim.fn.line('$')

    -- En mode normal
    if mode == 'n' then
        if direction == 'down' and current_line < last_line then
            vim.cmd('move +1')
        elseif direction == 'up' and current_line > 1 then
            vim.cmd('move -2')
        end
    -- En mode visuel
    elseif mode == 'v' or mode == 'V' then
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")

        if direction == 'down' and end_line < last_line then
            vim.cmd("'<,'>move '>+1")
            vim.cmd('normal! gv')
        elseif direction == 'up' and start_line > 1 then
            vim.cmd("'<,'>move '<-2")
            vim.cmd('normal! gv')
        end
    end

    -- Réinitialiser le timer d'inactivité
    if inactivity_timer then
        inactivity_timer:stop()
        inactivity_timer:close()
    end
    
    inactivity_timer = vim.loop.new_timer()
    inactivity_timer:start(inactivity_timeout, 0, vim.schedule_wrap(function()
        M.stop_move()
    end))
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
