local opt = vim.opt
vim.opt.laststatus = 3
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldtext = 'v:lua.CustomFoldText()'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.binary = true
opt.eol = false
opt.fixendofline = false
opt.hidden = true
opt.relativenumber = true
opt.smartcase = true
opt.incsearch = true
opt.inccommand = 'split'
opt.updatetime = 50
opt.path:append('**')
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.cursorline = true
opt.cursorcolumn = true
opt.encoding = 'UTF-8'
opt.clipboard = 'unnamed,unnamedplus'
opt.tabstop = 2
opt.smarttab = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

vim.g.mapleader = ' '
vim.cmd('syntax on')

-- Configuration correcte de l'autocmd pour PackerCompile
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  callback = function()
    vim.cmd("source <afile>")
    vim.cmd("PackerCompile")
  end,
})

-- Simplification de la configuration du thème
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "catppuccin",
  callback = function()
    vim.cmd('colorscheme catppuccin-macchiato')
    vim.g.airline_theme = 'catppuccin'
  end,
})

-- Alternative directe si vous préférez
vim.cmd('colorscheme catppuccin-macchiato')
vim.g.airline_theme = 'catppuccin'

-- Ignorer les fichiers cachés et dossiers spécifiques dans FZF
vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!**/{node_modules,vendor,.git,__pycache__,build,dist,target,elm-stuff,.idea,.vscode,deps,.venv,Cargo.lock,Cargo.toml,.*}"'
vim.env.FZF_CTRL_T_COMMAND = 'rg --files --hidden --glob "!**/{node_modules,vendor,.git,__pycache__,build,dist,target,elm-stuff,.idea,.vscode,deps,.venv,Cargo.lock,Cargo.toml,.*}"'
vim.env.FZF_ALT_C_COMMAND = 'rg --files --hidden --glob "!**/{node_modules,vendor,.git,__pycache__,build,dist,target,elm-stuff,.idea,.vscode,deps,.venv,Cargo.lock,Cargo.toml,.*}"'
vim.env.FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --ansi --preview="bat --style=numbers --color=always --line-range :500 {}"'

-- Exclure globalement les fichiers cachés et certains dossiers
opt.wildignore:append({
  '**/.git/**', 
  '**/node_modules/**', 
  '**/vendor/**', 
  '**/.vscode/**',
  '**/.idea/**',
  '**/dist/**',
  '**/build/**',
  '**/.DS_Store',
  '.*'
})

-- Minimap settings
vim.g.minimap_width = 10
vim.g.minimap_auto_start = 1
vim.g.minimap_auto_start_win_enter = 1

-- SimpylFold settings
vim.g.SimpylFold_docstring_preview = 1

-- Ag settings
vim.g.ag_working_path_mode = 'r'


require'fzf-lua'.setup {
  sessions = {
    path = vim.fn.expand(vim.g.workspace_session_directory),
    autosave = false,  -- Sauvegarde automatique des sessions
    post_save_cmd = nil,
    post_load_cmd = nil,
  }
}

-- Touche de raccourci pour afficher les sessions avec fzf-lua
vim.api.nvim_set_keymap('n', '<leader>ss', ':Sessions<CR>', { noremap = true, silent = true })
