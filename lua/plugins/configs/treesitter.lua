require'nvim-treesitter.configs'.setup {
  ensure_installed = { 
    "javascript", "typescript", "tsx", "html", "css", 
    "c", "lua", "vim", "vimdoc", "query", "markdown", 
    "markdown_inline", "vue" 
  },
  auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  },
}
