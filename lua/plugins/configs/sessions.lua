local fzf_session = {}

-- Obtenir le chemin du répertoire de session pour le projet actuel
function fzf_session.path()
  local project_root = vim.fn.getcwd()
  return project_root .. '/.vim_sessions'
end

-- Générer le chemin complet du fichier de session avec l'extension '.vim'
function fzf_session.session_file(name)
  return vim.fn.fnamemodify(fzf_session.path() .. '/' .. name .. '.vim', ':p')
end

-- Configurer les options de session
function fzf_session.setup_session_options()
  vim.opt.sessionoptions = {
    "blank",    -- keep empty windows
    "tabpages", -- all tab pages
    "winsize",  -- size of windows
    "winpos",   -- position of the whole Vim window
    "folds",    -- manually created folds
    "help",     -- the help window
    "globals",  -- global variables that start with an uppercase letter and contain at least one lowercase letter
    "slash",    -- backslashes in file names replaced with forward slashes
    "unix",     -- with Unix end-of-line format (single <NL>), even when on Windows
    "localoptions", -- options and mappings local to a window or buffer (not global values for local options)
  }
end

-- Créer une session avec log
function fzf_session.create(name)
  print('Création de la session : ' .. name)
  local session_path = fzf_session.path()
  vim.fn.mkdir(session_path, "p")
  vim.g.this_fzf_session = fzf_session.session_file(name)
  print('Chemin de la session : ' .. vim.g.this_fzf_session)
  vim.g.this_fzf_session_name = name
  fzf_session.setup_session_options()
  fzf_session.persist()
end

-- Charger une session avec gestion d'erreurs améliorée
function fzf_session.load(name)
  local session_file = fzf_session.session_file(name)
  
  if vim.fn.filereadable(session_file) == 0 then
    print("Erreur : Fichier de session introuvable : " .. session_file)
    return
  end

  if vim.g.this_fzf_session then
    print('Une session est déjà active, on la quitte')
    fzf_session.quit()
  end

  fzf_session.setup_session_options()
  
  -- Sauvegarder l'état actuel avant de charger la nouvelle session
  local old_sessionoptions = vim.o.sessionoptions
  vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize"
  local temp_session = vim.fn.tempname() .. '.vim'
  vim.cmd('mksession! ' .. vim.fn.fnameescape(temp_session))
  vim.o.sessionoptions = old_sessionoptions

  local status, err = pcall(function()
    vim.cmd('silent! bufdo bwipeout')
    vim.cmd('silent! source ' .. session_file)
  end)

  if not status then
    print("Erreur lors du chargement de la session : " .. err)
    print("Tentative de restauration de l'état précédent...")
    pcall(function()
      vim.cmd('silent! source ' .. temp_session)
    end)
    vim.fn.delete(temp_session)
    return
  end

  vim.fn.delete(temp_session)
  vim.g.this_fzf_session_name = name
  print("Session " .. name .. " chargée avec succès")
end

-- Supprimer une session avec log
function fzf_session.delete(name)
  local session_file = fzf_session.session_file(name)
  print('Suppression de la session : ' .. session_file)

  if vim.fn.filereadable(session_file) == 0 then
    print("Erreur : Fichier de session introuvable : " .. session_file)
    return
  end

  if vim.g.this_fzf_session and session_file == vim.g.this_fzf_session then
    print('On quitte la session avant de la supprimer')
    fzf_session.quit()
  end

  vim.fn.delete(session_file)
  print("Session supprimée : " .. session_file)
end

-- Quitter la session courante avec log
function fzf_session.quit()
  if not vim.g.this_fzf_session then
    print("Aucune session active à quitter")
    return
  end

  vim.g.this_fzf_session = nil
  vim.g.this_fzf_session_name = nil
  print("Fermeture de la session active")

  pcall(function()
    vim.cmd('silent! bufdo bwipeout')
  end)
end

-- Sauvegarder la session avec gestion d'erreurs améliorée
function fzf_session.persist()
  if vim.g.this_fzf_session then
    fzf_session.setup_session_options()
    print("Sauvegarde de la session en cours...")

    local status, err = pcall(function()
      vim.cmd('mksession! ' .. vim.fn.fnameescape(vim.g.this_fzf_session))
    end)

    if not status then
      print("Erreur lors de la création de la session : " .. err)
      print("Tentative de sauvegarde dans un fichier temporaire...")
      local temp_file = vim.fn.tempname() .. '.vim'
      local temp_status, temp_err = pcall(function()
        vim.cmd('mksession! ' .. vim.fn.fnameescape(temp_file))
      end)
      if temp_status then
        print("Session sauvegardée dans un fichier temporaire : " .. temp_file)
      else
        print("Échec de la sauvegarde de secours : " .. temp_err)
      end
      return
    end

    print("Session sauvegardée : " .. vim.g.this_fzf_session)
  end
end

-- Lister toutes les sessions avec log
function fzf_session.list()
  local session_files = vim.fn.split(vim.fn.globpath(fzf_session.path(), "*.vim"), "\n")
  local result = {}
  for _, file in ipairs(session_files) do
    table.insert(result, vim.fn.fnamemodify(file, ':t:r'))
  end
  print("Sessions disponibles : " .. table.concat(result, ", "))
  return result
end

-- Fonction pour gérer les sessions avec fzf
function fzf_session.fzf_session()
  local sessions = fzf_session.list()
  
  local actions = {
    { name = "Créer une nouvelle session", action = fzf_session.create },
    { name = "Quitter la session actuelle", action = fzf_session.quit },
  }

  local action_names = vim.tbl_map(function(item) return item.name end, actions)
  local all_choices = vim.list_extend(sessions, action_names)
  
  vim.fn.extend(vim.fn.getcompletion('', 'function'), {'fzf#run'})
  vim.fn['fzf#run']{
    source = all_choices,
    sink = function(selected)
      if vim.tbl_contains(sessions, selected) then
        fzf_session.load(selected)
      else
        for _, action in ipairs(actions) do
          if action.name == selected then
            if action.action == fzf_session.create then
              vim.ui.input({ prompt = "Nom de la nouvelle session : " }, function(input)
                if input then
                  action.action(input)
                end
              end)
            else
              action.action()
            end
            break
          end
        end
      end
    end,
    options = '--prompt="Session > "'
  }
end

-- Commandes pour gérer les sessions
vim.api.nvim_create_user_command('Session', function(opts)
  fzf_session.create(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command('Sessions', function()
  fzf_session.fzf_session()
end, { nargs = 0 })

vim.api.nvim_create_user_command('SLoad', function(opts)
  fzf_session.load(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command('SDelete', function(opts)
  fzf_session.delete(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command('SQuit', function()
  fzf_session.quit()
end, { nargs = 0 })

vim.api.nvim_create_user_command('SList', function()
  fzf_session.list()
end, { nargs = 0 })

return fzf_session
