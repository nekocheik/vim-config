print("spectre ---")

require('spectre').setup({
  color_devicons = true, -- Afficher les icônes colorées
  open_cmd = 'vnew | vertical resize 40', -- Ouvrir les résultats dans une nouvelle fenêtre
  live_update = false, -- Rechercher automatiquement quand tu édites un fichier
  lnum_for_results = true, -- Afficher les numéros de ligne dans les résultats
  width = 200,
  result_padding = '¦  ',
  line_sep_start = '┌-----------------------------------------',
  line_sep = '└-----------------------------------------',
  highlight = {
      ui = "String",
      search = "DiffChange",
      replace = "DiffDelete"
  },
  mapping = {
    -- Configuration des raccourcis personnalisés
    ['tab'] = {
        map = '<Tab>',
        cmd = "<cmd>lua require('spectre').tab()<cr>",
        desc = 'Next query'
    },
    ['enter_file'] = {
        map = "<cr>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        desc = "Open file"
    },
    ['run_replace'] = {
        map = "<leader>R",
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
        desc = "Replace all"
    },
    ['toggle_ignore_case'] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "Toggle ignore case"
    },
    ['toggle_ignore_hidden'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "Toggle search hidden"
    }
  }
})
