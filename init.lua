require('core.options')

-- Installer mini.nvim avec mini.deps
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up MiniDeps
require('mini.deps').setup({
  path = { package = path_package }
})


vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost init.lua source <afile> | PackerCompile
augroup end
]])

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

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
end)


-- Chargez vos autres configurations ici
require('core.keymaps')
require('core.underlineworld')
require('core.autocmds')
require('plugins')

-- require('lua.plugins.configs.avante')
require('plugins.configs.spectre')
require('plugins.configs.accelerated')
require('plugins.configs.scrollbar')
require('plugins.configs.sessions')
require('plugins.configs.cmp')
require('utils.functions')


---- avante

local add, later, now = MiniDeps.add, MiniDeps.later, MiniDeps.now
add({

  source = 'yetone/avante.nvim',
  monitor = 'main',
  depends = {
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'echasnovski/mini.icons'
  },
  hooks = {
    post_checkout = function()
      vim.cmd('AvanteBuild source=false')
    end
  }
})

-- Charger `avante_lib` immédiatement
now(function()
  require('avante_lib').load()
end)

-- Dépendances optionnelles
add({ source = 'zbirenbaum/copilot.lua' })
add({ source = 'HakonHarnes/img-clip.nvim' })
add({ source = 'MeanderingProgrammer/render-markdown.nvim' })



-- Configuration des autres plugins après le démarrage de Neovim
later(function()
  require('render-markdown').setup({ file_types = { 'markdown', 'vimwiki', "Avante" }, })
  require('img-clip').setup({ embed_image_as_base64 = false })
  require("copilot").setup({})
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "bash", "c", "cpp", "css", "dockerfile", "go", "html", "javascript", 
      "json", "lua", "make", "markdown", "python", "ruby", "rust", "scss", 
      "sql", "typescript", "vim", "yaml", "java", "php", "toml", "vue"
    },
    sync_install = false, -- Installe les parsers de façon asynchrone (false pour synchrone)
    auto_install = true,  -- Installe automatiquement les parsers manquants lors de l'ouverture d'un fichier
    highlight = {
      enable = true,              -- Activer la coloration syntaxique basée sur Treesitter
      additional_vim_regex_highlighting = false, -- Utiliser la coloration Vim standard en plus de Treesitter
    },
    indent = {
      enable = true               -- Activer l'indentation automatique basée sur Treesitter
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Déplacer le curseur vers les objets textuels détectés
        keymaps = {
          -- Sélectionner en fonction des objets textuels
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  }


  require("avante").setup({
    auto_suggestions_provider = "openai",
    provider = "openai",
    openai = {
      endpoint = "https://api.corcel.io/v1",
      model = "llama3-70b-8192",
      temperature = 0.1,
      max_tokens = 4096,
      api_key = "d8f2407e-bae3-45b5-a04a-aff0f5d93d99",
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
    },
    mappings = {
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      diff = {
        ours = "co",
        theirs = "ct",
        both = "cb",
        next = "]x",
        prev = "[x",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      sidebar = {
        show = "<leader>aa",
        refresh = "<leader>ar",
        edit_blocks = "<leader>ae",
      },
    },
    windows = {
      position = "right",
      width = 30,
    },
    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
  })
end)
