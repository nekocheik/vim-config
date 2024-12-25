local M = {}

-- State tracking variables
local move_mode = false
local inactivity_timer = nil
local inactivity_timeout = 1000 -- milliseconds
local last_direction = nil

-- Default options
local defaults = {
    move_auto_indent = true,
    move_past_end_of_line = true,
    move_undo_join = true,
    move_undo_join_same_dir_only = true
}

-- Store last move info for undo joining
local function save_move_info(direction)
    vim.b.move_last = {
        changedtick = vim.b.changedtick,
        direction = direction
    }
end

-- Check if we can join with the last undo
local function try_undo_join(direction)
    local last = vim.b.move_last or { changedtick = -1, direction = nil }
    local no_changes = last.changedtick == vim.b.changedtick
    local dir_ok = not defaults.move_undo_join_same_dir_only or last.direction == direction
    
    if no_changes and dir_ok then
        pcall(vim.cmd, 'silent! undojoin')
    end
end

-- Reset the inactivity timer
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

-- Function to move block selection horizontally
local function move_block_horizontally(distance)
    if not vim.bo.modifiable or distance == 0 then
        return
    end

    -- Switch to block visual mode if not already
    local mode = vim.fn.mode()
    if mode ~= '\22' then -- \22 is the char code for CTRL-V
        vim.cmd('normal! `<' .. vim.api.nvim_replace_termcodes('<C-v>', true, true, true) .. '`>')
    end

    -- Get block dimensions
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local first_col = math.min(start_pos[3], end_pos[3])
    local last_col = math.max(start_pos[3], end_pos[3])
    local width = last_col - first_col + 1

    -- Calculate new position
    local new_col = math.max(1, first_col + distance)
    if distance > 0 and not defaults.move_past_end_of_line then
        local lines = vim.fn.getline(start_pos[2], end_pos[2])
        local shortest = math.huge
        for _, line in ipairs(lines) do
            shortest = math.min(shortest, vim.fn.strwidth(line))
        end
        if last_col < shortest then
            new_col = math.min(new_col, shortest - width + 1)
        else
            new_col = first_col
        end
    end

    if first_col == new_col then
        return
    end

    -- Handle undo joining
    if defaults.move_undo_join then
        try_undo_join(distance < 0 and 'left' or 'right')
    end

    -- Store the original register content
    local old_reg = vim.fn.getreg('"')
    local old_reg_type = vim.fn.getregtype('"')

    -- Delete the block
    vim.cmd('normal! x')

    -- Move cursor and paste
    local old_virtualedit = vim.wo.virtualedit
    if new_col >= vim.fn.col('$') then
        vim.wo.virtualedit = 'all'
    else
        vim.wo.virtualedit = ''
    end

    vim.fn.cursor(start_pos[2], new_col)
    vim.cmd('normal! P')

    -- Restore settings and register
    vim.wo.virtualedit = old_virtualedit
    vim.fn.setreg('"', old_reg, old_reg_type)

    -- Save move info for undo joining
    if defaults.move_undo_join then
        save_move_info(distance < 0 and 'left' or 'right')
    end

    -- Reselect the block
    vim.cmd('normal! `[' .. vim.api.nvim_replace_termcodes('<C-v>', true, true, true) .. '`]')
end

-- Function to move content (with block mode support)
function M.move_content(direction)
    M.reset_timer()
    
    if not vim.bo.modifiable then
        return
    end

    local mode = vim.fn.mode()
    
    -- Handle horizontal movement
    if direction == 'left' or direction == 'right' then
        local distance = direction == 'left' and -1 or 1
        if mode == '\22' then -- CTRL-V (block) mode
            move_block_horizontally(distance)
        else
            local col = vim.fn.col('.')
            local line = vim.fn.line('.')
            local line_text = vim.fn.getline('.')
            
            if direction == 'left' and col > 1 then
                vim.cmd('normal! xhP')
            elseif direction == 'right' and col < #line_text then
                vim.cmd('normal! xp')
            end
        end
        return
    end

    -- Handle vertical movement
    local first_line, last_line
    if mode == 'n' then
        first_line = vim.fn.line('.')
        last_line = first_line
    else
        first_line = vim.fn.line("'<")
        last_line = vim.fn.line("'>")
    end

    local old_pos = vim.fn.getcurpos()
    
    -- Calculate destination line
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

    vim.fn.setpos('.', old_pos)

    if defaults.move_undo_join then
        try_undo_join(direction)
    end

    -- Move the lines
    vim.cmd(string.format('%d,%dmove %d', first_line, last_line, after_line))

    -- Handle auto-indentation
    if defaults.move_auto_indent then
        local new_first = vim.fn.line("'[")
        local new_last = vim.fn.line("']")

        vim.fn.cursor(new_first, 1)
        local old_indent = vim.fn.indent('.')
        vim.cmd('normal! ==')
        local new_indent = vim.fn.indent('.')

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

        vim.fn.cursor(new_first, 1)
        vim.cmd('normal! 0m[')
        vim.fn.cursor(new_last, 1)
        vim.cmd('normal! $m]')
    end

    -- Restore visual selection if needed
    if mode:match('[vV\22]') then
        vim.cmd('normal! gv')
    end

    if defaults.move_undo_join then
        save_move_info(direction)
    end
end

-- Function to handle the grave accent (`) input
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

-- Function to activate move mode
function M.activate_move_mode(direction)
    move_mode = true
    last_direction = direction
    M.move_content(direction)
    M.reset_timer()

    -- Set up movement key mappings
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

-- Function to stop movement mode
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

-- Setup function
function M.setup(opts)
    opts = opts or {}
    
    -- Merge user options with defaults
    for k, v in pairs(defaults) do
        if opts[k] ~= nil then
            defaults[k] = opts[k]
        end
    end
    
    inactivity_timeout = opts.timeout or 1000
    
    -- Set up the grave accent mapping
    vim.keymap.set({'n', 'v'}, '`', function()
        M.handle_grave_input()
    end, { silent = true })

    vim.keymap.set({'n', 'v'}, '<Esc>', function()
        M.stop_move()
    end, { silent = true })

    -- Auto-commands to stop movement
    vim.api.nvim_create_autocmd({'BufLeave', 'InsertEnter'}, {
        callback = function()
            M.stop_move()
        end
    })
end

return M