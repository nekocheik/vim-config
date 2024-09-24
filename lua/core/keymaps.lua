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

map('n', '<leader>f', ':Files<CR>')
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

map('n', '<leader>K', ':lua SearchWithFzfFromClipboard()<CR>')

map('n', '<leader>aa', ':AvanteToggle<CR>')
map('n', '<leader>ar', ':AvanteRefresh<CR>')
map('n', '<leader>ae', ':AvanteEdit<CR>')

map('', '∆', '<A-j>')
map('', '˙', '<A-h>')
map('', '˚', '<A-k>')
map('', '¬', '<A-l>')

vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "Search current word"
})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "Search on current file"
})

vim.api.nvim_set_keymap('n', 'U', '<C-r>', { noremap = true, silent = true })

map('n', '<leader>tw', ':!python3  ~/Project/Projet/transcrib.py &<CR>')
