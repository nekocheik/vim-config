



-- Custom fold text function
function _G.CustomFoldText()
  local line = vim.fn.getline(vim.v.foldstart)
  local num_lines = vim.v.foldend - vim.v.foldstart + 1
  local fold_marker = '+ ' .. num_lines .. ' lignes pliées ' .. ' +++'
  return line .. string.rep(' ', vim.fn.winwidth(0) - #line - #fold_marker) .. fold_marker
end

-- Function to create file if it doesn't exist
function _G.CreateFileIfNotExist()
  local file = vim.fn.expand('<cfile>')
  local current_file = vim.fn.expand('%:p')
  local current_file_dir = vim.fn.fnamemodify(current_file, ':h')
  local current_extension = vim.fn.fnamemodify(current_file, ':e')

  local src_dir = vim.fn.finddir('src', current_file_dir .. ';')

  if file:sub(1,1) == '@' then
    file = src_dir .. '/' .. file:sub(2)
  elseif file:sub(1,2) == './' then
    file = current_file_dir .. '/' .. file:sub(3)
  elseif file:sub(1,1) ~= '/' then
    file = current_file_dir .. '/' .. file
  end

  if vim.fn.fnamemodify(file, ':e') == '' then
    file = file .. '.' .. current_extension
  end

  local normalized_file = vim.fn.fnamemodify(file, ':p')

  if vim.fn.filereadable(normalized_file) == 1 or vim.fn.isdirectory(normalized_file) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(normalized_file))
  else
    local dir = vim.fn.fnamemodify(normalized_file, ':h')
    if vim.fn.isdirectory(dir) == 0 then
      local create_dir = vim.fn.input('Le répertoire n\'existe pas. Le créer ? (y/n): ')
      if create_dir:lower() == 'y' then
        vim.fn.mkdir(dir, 'p')
      else
        print("Annulé.")
        return
      end
    end

    local new_name = vim.fn.input('Fichier non trouvé. Créer le fichier : ', normalized_file, 'file')
    if new_name ~= '' then
      vim.cmd('edit ' .. vim.fn.fnameescape(new_name))
    end
  end
end

-- Function to handle K keypress
function _G.HandleK()
  local filetype = vim.bo.filetype
  if filetype == 'typescript' or filetype == 'typescriptreact' then
    local success, result = pcall(require('utils.functions').GetTypeAtCursor)
    if not success then
      print("Erreur lors de l'appel à GetTypeAtCursor: " .. result)  -- Afficher l'erreur si échec
    else
      print("GetTypeAtCursor a été appelée avec succès")  -- Si tout va bien
    end
  else
    vim.cmd('normal! K')
  end
end


function _G.SearchWithFzfFromClipboard()
  local clipboard_content = vim.fn.getreg('+')
  if #clipboard_content > 0 then
    vim.cmd('Rg ' .. clipboard_content)
  else
    print("Le presse-papiers est vide.")
  end
end

function _G.ReplaceAllWithFzf()
  -- Récupérer le texte à rechercher dans le presse-papiers
  local search_text = vim.fn.input('Texte à rechercher: ', vim.fn.getreg('+'))
  
  if #search_text == 0 then
    print("Texte de recherche vide.")
    return
  end

  -- Demander le texte de remplacement
  local replace_text = vim.fn.input('Texte de remplacement: ')
  
  if #replace_text == 0 then
    print("Texte de remplacement vide.")
    return
  end

  -- Commande ripgrep pour rechercher les occurrences du texte
  local rg_command = 'rg --vimgrep ' .. vim.fn.shellescape(search_text)

  -- Utilisation de `fzf` pour afficher les résultats et permettre la sélection
  local fzf_command = ' | fzf --preview "bat --style=numbers --color=always --highlight-line {2}" --multi'

  -- Exécuter la recherche et récupérer les fichiers sélectionnés
  local results = vim.fn.systemlist(rg_command .. fzf_command)
  
  if #results == 0 then
    print("Aucune sélection effectuée.")
    return
  end

  -- Remplacer le texte dans chaque fichier sélectionné
  for _, line in ipairs(results) do
    -- Extraire le nom du fichier et la ligne depuis le résultat
    local filepath = string.match(line, "([^:]+):")
    local cmd = 'sed -i "" "s/' .. vim.fn.escape(search_text, '/') .. '/' .. vim.fn.escape(replace_text, '/') .. '/g" ' .. filepath
    -- Exécuter la commande de remplacement
    vim.fn.system(cmd)
  end

  print("Remplacement terminé.")
end


-- Make these functions global so they can be called from anywhere
vim.cmd[[
command! -nargs=0 CreateFileIfNotExist lua CreateFileIfNotExist()
command! -nargs=0 HandleK lua HandleK()
command! -nargs=0 SearchWithAgFromClipboard lua SearchWithAgFromClipboard()
]]

local M = {}

local type_win = -1  -- Garde la trace de la fenêtre flottante

-- Fonction pour récupérer le type au survol avec logs
function M.GetTypeAtCursor()
  -- Récupère le fichier actuel et la position du curseur
  local file = vim.fn.expand('%:p')
  local line = vim.fn.line('.') - 1
  local col = vim.fn.col('.') - 1

  -- Récupère le mot sous le curseur
  local cword = vim.fn.expand('<cword>')

  -- Exécute le script Node.js pour récupérer le type à cette position
  local command = 'node ~/.config/nvim/get-type-info.js ' .. file .. ' ' .. (line * 1000 + col) .. ' ' .. cword

  -- Récupère la sortie du script
  local output = vim.fn.system(command)

  -- Formate la sortie JSON pour un affichage lisible
  local formatted_output
  local success, json_output = pcall(vim.fn.json_decode, output)
  if success then
    formatted_output = vim.fn.json_encode(json_output, { indent = 2 })
  else
    -- Si l'analyse JSON échoue, affiche la sortie brute
    formatted_output = output
  end

  -- Calcul de la largeur et de la hauteur en fonction du contenu
  local lines = vim.split(formatted_output, "\n")
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(#line, max_width)
  end
  local height = #lines
  local width = math.min(max_width, vim.o.columns - 4) -- Limite la largeur à presque la largeur totale de l'écran

  -- Ajuste la hauteur pour qu'elle ne dépasse pas une limite raisonnable
  height = math.min(height, vim.o.lines - 4) -- Limite la hauteur pour ne pas dépasser la taille de l'écran

  -- Affiche la sortie formatée dans une fenêtre flottante
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = width,
    height = height,
    col = 1,
    row = 1,
    style = 'minimal',
    border = 'rounded', -- Ajoute des bords arrondis pour un look plus propre
  })

  -- Affiche un message de confirmation
  print("Type info affiché dans une fenêtre flottante")
end


-- Fonction pour fermer la fenêtre flottante
function M.CloseTypeWindow()
  if type_win ~= -1 then
    vim.api.nvim_win_close(type_win, true)
    type_win = -1
    print("CloseTypeWindow: Fenêtre flottante fermée.")  -- Log lors de la fermeture
  end
end

function split_string(inputstr, sep)
  if sep == nil then
    sep = "%s" -- Si aucun séparateur n'est fourni, utilise l'espace
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function CopyMessagesToClipboard()
  vim.cmd([[redir => output]])
  vim.cmd([[silent messages]])
  vim.cmd([[redir END]])

  vim.fn.setreg('+', output)

  print("All messages copied to clipboard!")
end


vim.api.nvim_create_user_command('CopyMessages', CopyMessagesToClipboard, {})


local function js_to_ts()
  -- Demander à l'utilisateur d'entrer le nom de l'interface (par défaut "RootObject")
  local interface_name = vim.fn.input('Enter the name of the interface (default: RootObject): ')
  if interface_name == '' then
    interface_name = 'RootObject'
  end

  -- Récupérer le contenu du presse-papier
  local clipboard_input = vim.fn.getreg('+')

  -- Construire la commande pour exécuter le script Node.js
  local command = 'node ~/.config/nvim/generate-types.js ' .. vim.fn.shellescape(clipboard_input) .. ' ' .. vim.fn.shellescape(interface_name)

  -- Exécuter la commande
  local typescript_output = vim.fn.system(command)

  -- Vérifier s'il y a une erreur lors de l'exécution du script
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({{'Error: Could not generate TypeScript types', 'ErrorMsg'}}, false, {})
    vim.api.nvim_echo({{typescript_output, 'ErrorMsg'}}, false, {})
    return
  end

  -- Copier le résultat dans le presse-papier
  vim.fn.setreg('+', typescript_output)
  vim.api.nvim_echo({{'TypeScript interface copied to clipboard!', 'None'}}, false, {})
end

-- Créer la commande Neovim pour appeler la fonction
vim.api.nvim_create_user_command('JsToTs', js_to_ts, {})


return M
