require('kanagawa').setup({
    compile = false,
    undercurl = true,
    commentStyle = { italic = true },
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    transparent = false,
    dimInactive = true,
    terminalColors = true,
    theme = "wave",
    background = {
        dark = "wave",
        light = "lotus"
    },
})

vim.cmd("colorscheme kanagawa")
vim.opt.guifont = "FiraCode Nerd Font:h14" 