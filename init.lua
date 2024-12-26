local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('plugins')           

require('core.keymaps')      


-- Configuration de base
require('core.options')      -- Déplacer options avant underlineworld
require('core.underlineworld')

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
    end
})

vim.g.move_key_modifier = 'D'  -- Pour Command

-- Plugins et leurs configurations
require('plugins.configs.cmp')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions')
require('plugins.configs.coc')
require('utils.functions')
require('core.autocmds')
require('core.custom_mode')
-- require('plugins.move')
