local M = {}

-- Variables d'état
local move_mode = false
local inactivity_timer = nil
local inactivity_timeout = 1000 -- millisecondes
local last_direction = nil

-- Options par défaut
local defaults = {
    move_auto_indent = true,
    move_past_end_of_line = true
}

-- Réinitialisation du timer
function M.reset_timer()
    if inactivity_timer then
        inactivity_timer:stop()
        inactivity_timer:close()
    end
    
    inactivity_timer = vim.loop.new_timer()
    inactivity_timer:start(inactivity_timeout, 0, vim.schedule_wrap(function()
        M.stop_move()
    end))
end

-- Fonction pour déplacer le contenu
function M.move_content(direction)
    M.reset_timer()
    
    if not vim.bo.modifiable then return end
    
    local mode = vim.fn.mode()
    
    -- Déplacement horizontal
    if direction == 'left' or direction == 'right' then
        local distance = direction == 'left' and -1 or 1
        if mode == '\22' then -- Mode bloc (CTRL-V)
            require('plugins.move').MoveBlockHorizontally(distance)
        else
            require('plugins.move').MoveCharHorizontally(distance)
        end
        return
    end
    
    -- Déplacement vertical
    local distance = direction == 'up' and -1 or 1
    if mode:match('[vV\22]') then
        require('plugins.move').MoveBlockVertically(distance)
    else
        require('plugins.move').MoveLineVertically(distance)
    end
end

-- Gestion de l'entrée grave (`)
function M.handle_grave_input()
    local char = vim.fn.getchar()
    local key = type(char) == "number" and vim.fn.nr2char(char) or char
    
    local direction
    if key == 'j' then
        direction = 'down'
    elseif key == 'k' then
        direction = 'up'
    elseif key == 'h' then
        direction = 'left'
    elseif key == 'l' then
        direction = 'right'
    else
        M.stop_move()
        return
    end
    
    M.activate_move_mode(direction)
end

-- Activation du mode déplacement
function M.activate_move_mode(direction)
    move_mode = true
    last_direction = direction
    M.move_content(direction)
    M.reset_timer()

    -- Configuration des mappings de mouvement
    vim.keymap.set({'n', 'v'}, 'j', function()
        if move_mode and (last_direction == 'down' or last_direction == 'up') then
            M.move_content('down')
        end
    end, { buffer = true, silent = true })

    vim.keymap.set({'n', 'v'}, 'k', function()
        if move_mode and (last_direction == 'down' or last_direction == 'up') then
            M.move_content('up')
        end
    end, { buffer = true, silent = true })

    vim.keymap.set({'n', 'v'}, 'h', function()
        if move_mode and (last_direction == 'left' or last_direction == 'right') then
            M.move_content('left')
        end
    end, { buffer = true, silent = true })

    vim.keymap.set({'n', 'v'}, 'l', function()
        if move_mode and (last_direction == 'left' or last_direction == 'right') then
            M.move_content('right')
        end
    end, { buffer = true, silent = true })
end

-- Arrêt du mode déplacement
function M.stop_move()
    move_mode = false
    last_direction = nil
    
    if inactivity_timer then
        inactivity_timer:stop()
        inactivity_timer:close()
        inactivity_timer = nil
    end
    
    pcall(vim.keymap.del, {'n', 'v'}, 'j', { buffer = true })
    pcall(vim.keymap.del, {'n', 'v'}, 'k', { buffer = true })
    pcall(vim.keymap.del, {'n', 'v'}, 'h', { buffer = true })
    pcall(vim.keymap.del, {'n', 'v'}, 'l', { buffer = true })
end

-- Configuration
function M.setup(opts)
    opts = opts or {}
    
    for k, v in pairs(defaults) do
        if opts[k] ~= nil then
            defaults[k] = opts[k]
        end
    end
    
    inactivity_timeout = opts.timeout or 1000
    
    -- Configuration des mappings
    vim.keymap.set({'n', 'v'}, '`', function()
        M.handle_grave_input()
    end, { silent = true })

    vim.keymap.set({'n', 'v'}, '<Esc>', function()
        M.stop_move()
    end, { silent = true })

    -- Auto-commandes pour arrêter le déplacement
    vim.api.nvim_create_autocmd({'BufLeave', 'InsertEnter'}, {
        callback = function()
            M.stop_move()
        end
    })
end

return M