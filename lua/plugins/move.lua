-- plugin/move.lua
local M = {}

-- Check if already loaded or in compatible mode
if vim.g.loaded_move or vim.o.compatible then
  return M
end

vim.g.loaded_move = 1

-- Set default values for variables if not exists
vim.g.move_map_keys = vim.g.move_map_keys or 1
vim.g.move_key_modifier = vim.g.move_key_modifier or 'A'
vim.g.move_key_modifier_visualmode = vim.g.move_key_modifier_visualmode or 'A'
vim.g.move_normal_option = vim.g.move_normal_option or 0
vim.g.move_auto_indent = vim.g.move_auto_indent or 1
vim.g.move_past_end_of_line = vim.g.move_past_end_of_line or 1
vim.g.move_undo_join = vim.g.move_undo_join or 1
vim.g.move_undo_join_same_dir_only = vim.g.move_undo_join_same_dir_only or 1

-- Define functions
function M.UndoJoin(dir)
  -- Check changedtick to see if there were no other changes since our last operation.
  -- Depending on settings, we may also require the same direction of move.
  local last = vim.b.move_last or { changedtick = -1, dir = nil }
  local no_changes = last.changedtick == vim.b.changedtick
  local dir_ok = not vim.g.move_undo_join_same_dir_only or last.dir == dir
  if no_changes and dir_ok then
      vim.cmd([[silent! undojoin]])
  end
end

function M.SaveMoveInfo(dir)
  -- Save changedtick/dir to check it in the next move operation.
  vim.b.move_last = { changedtick = vim.b.changedtick, dir = dir }
end

function M.MoveVertically(first, last, distance)
  if not vim.bo.modifiable or distance == 0 then
      return
  end

  local l_first = vim.fn.line(first)
  local l_last = vim.fn.line(last)

  -- Compute the destination line.
  local old_pos = vim.fn.getcurpos()
  if distance < 0 then
      vim.fn.cursor(l_first, 1)
      vim.cmd('normal! ' .. -distance .. 'k')
      local after = vim.fn.line('.') - 1
      vim.fn.setpos('.', old_pos)
      if vim.g.move_undo_join then
          M.UndoJoin(distance < 0 and 'up' or 'down')
      end
      vim.cmd(l_first .. ',' .. l_last .. 'move ' .. after)
  else
      vim.fn.cursor(l_last, 1)
      vim.cmd('normal! ' .. distance .. 'j')
      local after = vim.fn.foldclosedend('.') == -1 and vim.fn.line('.') or vim.fn.foldclosedend('.')
      vim.fn.setpos('.', old_pos)
      if vim.g.move_undo_join then
          M.UndoJoin(distance < 0 and 'up' or 'down')
      end
      vim.cmd(l_first .. ',' .. l_last .. 'move ' .. after)
  end

  if vim.g.move_auto_indent then
      local first_m = vim.fn.line("'[")
      local last_m = vim.fn.line("']")
      vim.fn.cursor(first_m, 1)
      local old_indent = vim.fn.indent('.')
      vim.cmd([[normal! ==]])
      local new_indent = vim.fn.indent('.')
      if first_m < last_m and old_indent ~= new_indent then
          local op = old_indent < new_indent and string.rep('>', new_indent - old_indent) or string.rep('<', old_indent - new_indent)
          local old_sw = vim.o.shiftwidth
          vim.o.shiftwidth = 1
          vim.cmd(first_m + 1 .. ',' .. last_m .. ' ' .. op)
          vim.o.shiftwidth = old_sw
      end
      vim.fn.cursor(first_m, 1)
      vim.cmd([[normal! 0m[]])
      vim.fn.cursor(last_m, 1)
      vim.cmd([[normal! $m]])
  end

  if vim.g.move_undo_join then
      M.SaveMoveInfo(distance < 0 and 'up' or 'down')
  end
end

function M.MoveLineVertically(distance)
  local old_col = vim.fn.col('.')
  vim.cmd([[normal! ^]])
  local old_indent = vim.fn.col('.')
  M.MoveVertically('.', '.', distance)
  vim.cmd([[normal! ^]])
  local new_indent = vim.fn.col('.')
  local new_col = math.max(1, old_col - old_indent + new_indent)
  vim.fn.cursor(vim.fn.line('.'), new_col)
end

function M.MoveBlockVertically(distance)
  M.MoveVertically("'<", "'>", distance)
  vim.cmd([[normal! gv]])
end

function M.MoveHorizontally(corner_start, corner_end, distance)
  if not vim.bo.modifiable or distance == 0 then
      return 0
  end

  local cols = {vim.fn.col(corner_start), vim.fn.col(corner_end)}
  local first = math.min(unpack(cols))
  local last = math.max(unpack(cols))
  local width = last - first + 1

  local before = math.max(1, first + distance)
  if distance > 0 and not vim.g.move_past_end_of_line then
      local lines = vim.fn.getline(corner_start, corner_end)
      local shortest = math.min(vim.fn.map(lines, 'strwidth(v:val)'))
      if last < shortest then
          before = math.min(before, shortest - width + 1)
      else
          before = first
      end
  end

  if first == before then
      return 0
  end

  if vim.g.move_undo_join then
      M.UndoJoin(distance < 0 and 'left' or 'right')
  end

  local old_default_register = vim.fn.getreg('"')
  vim.cmd([[normal! x]])

  local old_virtualedit = vim.o.virtualedit
  if before >= vim.fn.col('$') then
      vim.o.virtualedit = 'all'
  else
      vim.o.virtualedit = ''
  end

  vim.fn.cursor(vim.fn.line('.'), before)
  vim.cmd([[normal! P]])

  vim.o.virtualedit = old_virtualedit
  vim.fn.setreg('"', old_default_register)

  if vim.g.move_undo_join then
      M.SaveMoveInfo(distance < 0 and 'left' or 'right')
  end

  return 1
end

function M.MoveCharHorizontally(distance)
  M.MoveHorizontally('.', '.', distance)
end

function M.MoveBlockHorizontally(distance)
  vim.cmd([[normal! g<C-v>g]])
  if M.MoveHorizontally("'<", "'>", distance) then
      vim.cmd([[normal! g[<C-v>g]])
  end
end

function M.HalfPageSize()
  return math.floor(vim.fn.winheight('.') / 2)
end

local mac_map_keys = { k = '˚', j = '∆', h = '˙', l = '¬' }

function M.MoveKey(key)
  if vim.g.move_normal_option and vim.g.move_key_modifier_visualmode == 'A' then
      return mac_map_keys[key]
  else
      return '<' .. vim.g.move_key_modifier .. '-' .. key .. '>'
  end
end

function M.VisualMoveKey(key)
  if vim.g.move_normal_option and vim.g.move_key_modifier_visualmode == 'A' then
      return mac_map_keys[key]
  else
      return '<' .. vim.g.move_key_modifier_visualmode .. '-' .. key .. '>'
  end
end

-- Visual mode mappings
vim.keymap.set('v', '<Plug>MoveBlockDown', [[<C-u>silent lua require('move').MoveBlockVertically(vim.v.count1)<CR>]])
vim.keymap.set('v', '<Plug>MoveBlockUp', [[<C-u>silent lua require('move').MoveBlockVertically(-vim.v.count1)<CR>]])
vim.keymap.set('v', '<Plug>MoveBlockHalfPageDown', [[<C-u>silent lua require('move').MoveBlockVertically(vim.v.count1 * require('move').HalfPageSize())<CR>]])
vim.keymap.set('v', '<Plug>MoveBlockHalfPageUp', [[<C-u>silent lua require('move').MoveBlockVertically(-vim.v.count1 * require('move').HalfPageSize())<CR>]])
vim.keymap.set('v', '<Plug>MoveBlockRight', [[<C-u>silent lua require('move').MoveBlockHorizontally(vim.v.count1)<CR>]])
vim.keymap.set('v', '<Plug>MoveBlockLeft', [[<C-u>silent lua require('move').MoveBlockHorizontally(-vim.v.count1)<CR>]])

-- Normal mode mappings
vim.keymap.set('n', '<Plug>MoveLineDown', [[<C-u>silent lua require('move').MoveLineVertically(vim.v.count1)<CR>]])
vim.keymap.set('n', '<Plug>MoveLineUp', [[<C-u>silent lua require('move').MoveLineVertically(-vim.v.count1)<CR>]])
vim.keymap.set('n', '<Plug>MoveLineHalfPageDown', [[<C-u>silent lua require('move').MoveLineVertically(vim.v.count1 * require('move').HalfPageSize())<CR>]])
vim.keymap.set('n', '<Plug>MoveLineHalfPageUp', [[<C-u>silent lua require('move').MoveLineVertically(-vim.v.count1 * require('move').HalfPageSize())<CR>]])
vim.keymap.set('n', '<Plug>MoveCharRight', [[<C-u>silent lua require('move').MoveCharHorizontally(vim.v.count1)<CR>]])
vim.keymap.set('n', '<Plug>MoveCharLeft', [[<C-u>silent lua require('move').MoveCharHorizontally(-vim.v.count1)<CR>]])

-- Conditional key mappings
if vim.g.move_map_keys then
  local function map_move_keys(mode, lhs, plug_name)
      vim.keymap.set(mode, lhs, '<Plug>' .. plug_name, { silent = true })
  end

  -- Visual mode keys
  map_move_keys('v', M.VisualMoveKey('j'), 'MoveBlockDown')
  map_move_keys('v', M.VisualMoveKey('k'), 'MoveBlockUp')
  map_move_keys('v', M.VisualMoveKey('h'), 'MoveBlockLeft')
  map_move_keys('v', M.VisualMoveKey('l'), 'MoveBlockRight')

  -- Normal mode keys
  map_move_keys('n', M.MoveKey('j'), 'MoveLineDown')
  map_move_keys('n', M.MoveKey('k'), 'MoveLineUp')
  map_move_keys('n', M.MoveKey('h'), 'MoveCharLeft')
  map_move_keys('n', M.MoveKey('l'), 'MoveCharRight')
end

return M