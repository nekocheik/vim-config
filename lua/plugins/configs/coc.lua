local function coc_config(key, value)
  vim.fn['coc#config'](key, value)
end

coc_config('hover', {
  target = 'float',
  maxWidth = 120,
  float = {
    border = {'│', '─', '│', '│', '┌', '┐', '┘', '└'},
    highlight = 'CocFloating'
  }
})

coc_config('suggest.timeout', 5000)
coc_config('signature.target', 'float')
coc_config('hover.floatConfig', {
  maxWidth = 120,
  maxHeight = 30
})

coc_config('typescript', {
  suggest = {
    completeFunctionCalls = true,
    includeCompletionsForImportStatements = true,
    includeCompletionsWithSnippetText = true,
  },
  implementationsCodeLens = { enable = true },
  referencesCodeLens = { enable = true },
  inlayHints = {
    includeInlayParameterNameHints = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
  }
})

vim.g.coc_global_extensions = {
  'coc-snippets', 'coc-pairs', 'coc-tsserver', 'coc-eslint', 
  'coc-prettier', 'coc-json', 'coc-explorer', 'coc-tabnine', 
  'coc-git', 'coc-react-refactor', '@hexuhua/coc-copilot',  "@yaegassy/coc-volar"
}

-- Function to show detailed type info
vim.cmd[[
function! ShowDetailedTypeInfo()
  call CocActionAsync('doHover')
  call CocActionAsync('showOutline')
endfunction
]]

vim.keymap.set('n', '<leader>K', ':lua SearchWithFzfFromClipboard()<CR>', { silent = true })
