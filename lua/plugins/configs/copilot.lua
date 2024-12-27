vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

require('copilot').setup({
    panel = {
        enabled = true,
        auto_refresh = true,
    },
    suggestion = {
        enabled = true,
        auto_trigger = true,
        model = "claude-3-sonnet-20240229",
        keymap = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
        },
    },
    filetypes = {
        yaml = true,
        markdown = true,
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
    },
}) 