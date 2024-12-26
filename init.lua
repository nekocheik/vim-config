-- Charger les plugins de base d'abord
require('plugins')           
require('core.keymaps')      
require('core.options')      

-- Charger la bibliothèque avante avant la configuration
require('avante_lib').load()

-- Configuration initiale de Copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- S'assurer que Copilot est configuré avant avante
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

-- Attendre un peu plus longtemps avant de configurer avante
vim.defer_fn(function()
    require('avante').setup({
        provider = "copilot",
        auto_suggestions_provider = "copilot",
        behaviour = {
            auto_suggestions = true,
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
                accept = "<M-l>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
            },
        }
    })
end, 3000)  -- Augmenté à 3 secondes

-- Charger le reste des configurations
require('core.underlineworld')
require('plugins.configs.move')
require('plugins.configs.persisted')



-- Ajouter un keymap de test pour les contrôles
vim.api.nvim_create_autocmd({"VimEnter"}, {
    callback = function()
        -- Créer une fonction pour logger les touches
        local function log_keypress(key)
            local log_file = io.open('/tmp/nvim_keypress.log', 'a')
            if log_file then
                log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - Pressed: " .. key .. "\n")
                log_file:close()
            end
        end

        -- Mapper les touches de contrôle
        vim.keymap.set('n', '<C-h>', function() log_keypress('Ctrl-h') end, {silent = true})
        vim.keymap.set('n', '<C-j>', function() log_keypress('Ctrl-j') end, {silent = true})
        vim.keymap.set('n', '<C-k>', function() log_keypress('Ctrl-k') end, {silent = true})
        vim.keymap.set('n', '<C-l>', function() log_keypress('Ctrl-l') end, {silent = true})
        vim.keymap.set('n', '<C-h>', '<C-w>h', {silent = true})
        vim.keymap.set('n', '<C-j>', '<C-w>j', {silent = true})
        vim.keymap.set('n', '<C-k>', '<C-w>k', {silent = true})
        vim.keymap.set('n', '<C-l>', '<C-w>l', {silent = true})
    end
})


-- vim.g.move_key_modifier = 'D'  -- Pour Command


-- Plugins et leurs configurations
require('plugins.configs.startify')
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions')
require('plugins.configs.coc')
require('utils.functions')
require('core.autocmds')
require('core.custom_mode')

vim.g.maximizer_set_default_mapping = 0  -- Désactive le mapping par défaut (F3)
vim.g.maximizer_set_mapping_with_bang = 1  -- Utilise la version avec bang par défaut

-- Configuration de GitHub Copilot en premier
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- Configuration de copilot.lua
require('copilot').setup({
    copilot = {
      model = "claude-3-sonnet",
    },
    panel = {
        enabled = true,
        auto_refresh = true,
    },
    suggestion = {
        enabled = true,
        auto_trigger = true,
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

-- Configuration pour gitgraph.nvim
require('gitgraph').setup({
    symbols = {
        merge_commit = 'M',
        commit = '*',
    },
    format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
    },
    hooks = {
        on_select_commit = function(commit)
            vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
            vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        on_select_range_commit = function(from, to)
            vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
            vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
    },
})

-- Ajouter un keymap pour dessiner le graphe Git
vim.api.nvim_set_keymap('n', '<leader>gl', [[:lua require('gitgraph').draw({}, { all = true, max_count = 5000 })<CR>]], { noremap = true, silent = true })

