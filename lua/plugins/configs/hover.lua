require("hover").setup({
    init = function()
        -- Configuration des providers
        require("hover.providers.lsp")
        require("hover.providers.dictionary")
        require("hover.providers.man")
        require("hover.providers.diagnostic")
        require("hover.providers.fold_preview")
    end,

    preview_opts = {
        border = "rounded"
    },

    preview_window = false,
    title = true,
    mouse_providers = {
        'LSP'
    },
    mouse_delay = 1000
})

-- Remplacer directement le keymap de COC
vim.keymap.del('n', 'K')  -- Supprime le mapping existant de COC
vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })

-- Navigation entre les sources
vim.keymap.set("n", "<leader>hp", function() 
    require("hover").hover_switch("previous") 
end, { desc = "hover.nvim (previous source)" })

vim.keymap.set("n", "<leader>hn", function() 
    require("hover").hover_switch("next") 
end, { desc = "hover.nvim (next source)" })

-- Support de la souris
vim.keymap.set('n', '<MouseMove>', require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
vim.o.mousemoveevent = true 