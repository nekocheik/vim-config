vim.g.closetag_filenames = '*.html,*.xhtml,*.phtml'
vim.g.closetag_xhtml_filenames = '*.xhtml,*.jsx'
vim.g.closetag_filetypes = 'html,xhtml,phtml'
vim.g.closetag_xhtml_filetypes = 'xhtml,jsx'
vim.g.closetag_emptyTags_caseSensitive = 1

vim.g.closetag_regions = {
  ['typescript.tsx'] = 'jsxRegion,tsxRegion',
  ['javascript.jsx'] = 'jsxRegion',
  ['typescriptreact'] = 'jsxRegion,tsxRegion',
  ['javascriptreact'] = 'jsxRegion'
}

vim.g.closetag_shortcut = '>'

vim.g.closetag_close_shortcut = '<leader>>'

require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    ["html"] = {
      enable_close = false
    }
  }
})


-- Configuration du plugin en Lua
vim.g.tagalong_filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'jsx', 'xml' }
vim.g.tagalong_additional_filetypes = { 'vue' }
vim.g.tagalong_verbose = 1
