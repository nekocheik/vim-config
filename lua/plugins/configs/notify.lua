local notify = require("notify")

notify.setup({
    -- Configuration de base avec style harmonisé
    background_colour = "NotifyBackground",
    fps = 30,
    icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = ""
    },
    level = 2,
    minimum_width = 50,
    render = "default",
    stages = "static",
    timeout = 5000,
    top_down = true,

    -- Alignement avec vos options de tabulation
    on_open = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_buf_set_option(buf, "tabstop", 2)
        vim.api.nvim_buf_set_option(buf, "shiftwidth", 2)
        vim.api.nvim_buf_set_option(buf, "expandtab", true)
    end,

    -- Configuration des dimensions adaptatives
    max_height = function()
        return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
        return math.floor(vim.o.columns * 0.75)
    end,
})

-- Définir nvim-notify comme le gestionnaire de notifications par défaut
vim.notify = notify

-- Configuration des highlights harmonisés avec Kanagawa
vim.cmd([[
    highlight NotifyBackground guibg=#1F1F28
    
    highlight NotifyERRORBorder guifg=#E82424 guibg=#1F1F28
    highlight NotifyWARNBorder guifg=#FFA066 guibg=#1F1F28
    highlight NotifyINFOBorder guifg=#658594 guibg=#1F1F28
    highlight NotifyDEBUGBorder guifg=#727169 guibg=#1F1F28
    highlight NotifyTRACEBorder guifg=#957FB8 guibg=#1F1F28
    
    highlight NotifyERRORIcon guifg=#E82424
    highlight NotifyWARNIcon guifg=#FFA066
    highlight NotifyINFOIcon guifg=#658594
    highlight NotifyDEBUGIcon guifg=#727169
    highlight NotifyTRACEIcon guifg=#957FB8
    
    highlight NotifyERRORTitle guifg=#E82424
    highlight NotifyWARNTitle guifg=#FFA066
    highlight NotifyINFOTitle guifg=#658594
    highlight NotifyDEBUGTitle guifg=#727169
    highlight NotifyTRACETitle guifg=#957FB8
]])

-- Fonction utilitaire pour tester les notifications
_G.test_notify = function()
    vim.notify("Test de notification\nAvec indentation correcte\n  Ligne indentée", "info", {
        title = "Test Notification",
        timeout = 3000,
        render = "wrapped-compact",
    })
end 