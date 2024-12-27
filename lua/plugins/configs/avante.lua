-- Charger la bibliothèque avante
require('avante_lib').load()

-- Configuration d'Avante avec délai
vim.defer_fn(function()
    require('avante').setup({
        provider = "copilot",
        auto_suggestions_provider = "copilot",
        behaviour = {
            auto_suggestions = false,
            auto_set_highlight_group = true,
            auto_set_keymaps = true,
            auto_apply_diff_after_generation = false,
            minimize_diff = true,
        },
        windows = {
            position = "right",
            width = 30,
            sidebar_header = {
                enabled = true,
                align = "center",
                rounded = true,
            },
        },
        mappings = {
            suggestion = {
                accept = "<C-y>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
            },
        },
        highlights = {
            diff = {
                current = "DiffText",
                incoming = "DiffAdd",
            },
        },
    })
end, 3000)
