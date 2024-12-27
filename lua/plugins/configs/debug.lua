-- Configuration de Vimspector
require('plugins.configs.vimspector').setup()

-- Configuration de Launch
require('launch').setup({
    task = {
        display = 'float',
        float_config = {
            relative = 'editor',
            border = 'rounded',
            title_pos = 'center',
            style = 'minimal',
        },
        insert_on_launch = true,
        options = {
            shell = {
                exec = vim.o.shell,
                args = { '-c' }
            }
        }
    }
})

-- Configuration des keymaps de débogage
vim.api.nvim_create_autocmd({"VimEnter"}, {
    callback = function()
        local function log_keypress(key)
            local log_file = io.open('/tmp/nvim_keypress.log', 'a')
            if log_file then
                log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - Pressed: " .. key .. "\n")
                log_file:close()
            end
        end

        -- Mapper les touches de contrôle
        local keymap_pairs = {
            {'<C-h>', 'Ctrl-h', '<C-w>h'},
            {'<C-j>', 'Ctrl-j', '<C-w>j'},
            {'<C-k>', 'Ctrl-k', '<C-w>k'},
            {'<C-l>', 'Ctrl-l', '<C-w>l'},
        }

        for _, map in ipairs(keymap_pairs) do
            vim.keymap.set('n', map[1], function() log_keypress(map[2]) end, {silent = true})
            vim.keymap.set('n', map[1], map[3], {silent = true})
        end
    end
}) 