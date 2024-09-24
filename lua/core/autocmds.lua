-- ~/.config/nvim/lua/core/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Save view (folds, cursor, etc.)
autocmd('BufWinLeave', {
    pattern = '*',
    command = "if expand('%') != '' | silent! mkview | endif"
})

-- Activate AnyFold
autocmd('Filetype', {
    pattern = '*',
    command = 'AnyFoldActivate'
})

-- Clear CtrlP cache on buffer write
-- autocmd('BufWritePost', {
--     pattern = '*',
--     command = 'CtrlPClearAllCaches'
-- })

-- COC specific autocommands
local coc_group = augroup('CocGroup', {})
autocmd('FileType', {
    group = coc_group,
    pattern = {'typescript', 'json'},
    callback = function()
        vim.bo.formatexpr = "CocAction('formatSelected')"
    end
})

autocmd('User', {
    group = coc_group,
    pattern = 'CocJumpPlaceholder',
    command = "call CocActionAsync('showSignatureHelp')"
})

-- Initialize COC TabNine
autocmd('User', {
    pattern = 'CocNvimInit',
    once = true,
    callback = function()
        vim.fn['coc#config']('tabnine', {ignore_all_lsp = true})
    end
})
