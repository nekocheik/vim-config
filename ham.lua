-- Load required extensions
require("hs.fs")

-- Define animation duration
hs.window.animationDuration = 0

-- Variable for the last focused window
local lastFocusedWindow = nil

-- Variables for the border
local borderCanvas = nil
local borderWidth = 4
local normalBorderColor = {red = 1, green = 0.5, blue = 0, alpha = 0.8}
local customModeBorderColor = {red = 1, green = 0, blue = 0, alpha = 0.8}

-- Variable to track the previous mode
local previousMode = false

-- Function to check the custom mode from the file
function checkCustomMode()
    local file = io.open('/tmp/nvim_custom_mode_status', "r")
    if file then
        local content = file:read("*all")
        file:close()
        -- Nettoyage du contenu pour éviter les problèmes de caractères invisibles
        return content:gsub("%s+", "") == "true"
    end
    return false
end

-- Function to update the border
local function updateBorder()
    if borderCanvas then
        borderCanvas:delete()
        borderCanvas = nil
    end
    
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local isCustomMode = checkCustomMode()
        
        borderCanvas = hs.canvas.new({
            x = f.x - borderWidth,
            y = f.y - borderWidth,
            w = f.w + (borderWidth * 2),
            h = f.h + (borderWidth * 2)
        })
        
        borderCanvas:appendElements({
            type = "rectangle",
            action = "stroke",
            strokeWidth = borderWidth,
            strokeColor = isCustomMode and customModeBorderColor or normalBorderColor,
            frame = {x = "0%", y = "0%", w = "100%", h = "100%"}
        })
        
        borderCanvas:level("overlay")
        borderCanvas:show()
    end
end

-- Keypress event watcher
local keyWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local currentMode = checkCustomMode()
    if currentMode ~= previousMode then
        previousMode = currentMode
        updateBorder()
    end
    return false
end)
keyWatcher:start()

-- Watch for window focus, move, and resize events
local windowFilter = hs.window.filter.new()
windowFilter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowMoved,
    hs.window.filter.windowResized
}, function()
    lastFocusedWindow = hs.window.focusedWindow()
    updateBorder()
end)

-- Watch for application changes
local applicationWatcher = hs.application.watcher.new(function(app, eventType)
    if eventType == hs.application.watcher.activated then
        updateBorder()
    end
end)
applicationWatcher:start()

-- More frequent check every 0.5 seconds
hs.timer.doEvery(0.5, function()
    local currentMode = checkCustomMode()
    if currentMode ~= previousMode then
        previousMode = currentMode
        updateBorder()
    end
end)

-- Configuration des événements du window filter
windowFilter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowMoved,
    hs.window.filter.windowResized
}, function()
    hs.notify.new({
        title = "Window Event",
        informativeText = "Window event triggered border update"
    }):send()
    updateBorder()
end)

-- Observateur pour les changements d'application
local applicationWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        hs.notify.new({
            title = "App Changed",
            informativeText = "Application changed to: " .. (appName or "unknown")
        }):send()
        updateBorder()
    end
end)
applicationWatcher:start()

-- Watcher pour le fichier de statut
if statusWatcher then
    statusWatcher:stop()
end

statusWatcher = hs.pathwatcher.new('/tmp/nvim_custom_mode_status', function(files)
    local currentMode = checkCustomMode()
    if currentMode ~= previousMode then
        previousMode = currentMode
        updateBorder()
    end
end):start()

-- Fonction VSP pour diviser la fenêtre en deux
function vsp()
    local win = lastFocusedWindow
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end

-- Bind VSP à Cmd+Option+V
hs.hotkey.bind({"cmd", "option"}, "V", vsp)

-- Raccourci clavier pour basculer la fenêtre en plein écran avec Right Option + Espace
hs.hotkey.bind({"right_option"}, "Space", function()
  local win = hs.window.focusedWindow()
  if win then
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    
    if f.x == max.x and f.y == max.y and f.w == max.w and f.h == max.h then
      -- Restaurer à la taille précédente (50% de l'écran)
      f.w = max.w / 2
      f.h = max.h
      win:setFrame(f)
    else
      win:maximize()
    end
  end
end)

-- Fonction pour déplacer la fenêtre vers la gauche et réorganiser
function moveWindowLeft()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    -- Déplacer la fenêtre active à gauche
    local f = win:frame()
    f.x = screenFrame.x
    f.y = screenFrame.y
    f.w = screenFrame.w / 2
    f.h = screenFrame.h
    win:setFrame(f)
    
    -- Réorganiser les autres fenêtres à droite
    local otherWindows = hs.window.visibleWindows()
    for _, otherwin in ipairs(otherWindows) do
        if otherwin ~= win and otherwin:screen() == screen then
            local of = otherwin:frame()
            of.x = screenFrame.x + screenFrame.w / 2
            of.y = screenFrame.y
            of.w = screenFrame.w / 2
            of.h = screenFrame.h
            otherwin:setFrame(of)
        end
    end
end

-- Fonction pour déplacer la fenêtre vers la droite et réorganiser
function moveWindowRight()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    -- Déplacer la fenêtre active à droite
    local f = win:frame()
    f.x = screenFrame.x + screenFrame.w / 2
    f.y = screenFrame.y
    f.w = screenFrame.w / 2
    f.h = screenFrame.h
    win:setFrame(f)
    -- Réorganiser les autres fenêtres à gauche
    local otherWindows = hs.window.visibleWindows()
    for _, otherwin in ipairs(otherWindows) do
        if otherwin ~= win and otherwin:screen() == screen then
            local of = otherwin:frame()
            of.x = screenFrame.x
            of.y = screenFrame.y
            of.w = screenFrame.w / 2
            of.h = screenFrame.h
            otherwin:setFrame(of)
        end
    end
end

-- Fonction pour déplacer la fenêtre vers le haut
function moveWindowUp()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    local f = win:frame()
    f.x = screenFrame.x
    f.y = screenFrame.y
    f.w = screenFrame.w
    f.h = screenFrame.h / 2
    win:setFrame(f)
    
    -- Réorganiser les autres fenêtres en bas
    local otherWindows = hs.window.visibleWindows()
    for _, otherwin in ipairs(otherWindows) do
        if otherwin ~= win and otherwin:screen() == screen then
            local of = otherwin:frame()
            of.x = screenFrame.x
            of.y = screenFrame.y + screenFrame.h / 2
            of.w = screenFrame.w
            of.h = screenFrame.h / 2
            otherwin:setFrame(of)
        end
    end
end

-- Fonction pour déplacer la fenêtre vers le bas
function moveWindowDown()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    local f = win:frame()
    f.x = screenFrame.x
    f.y = screenFrame.y + screenFrame.h / 2
    f.w = screenFrame.w
    f.h = screenFrame.h / 2
    win:setFrame(f)
    
    -- Réorganiser les autres fenêtres en haut
    local otherWindows = hs.window.visibleWindows()
    for _, otherwin in ipairs(otherWindows) do
        if otherwin ~= win and otherwin:screen() == screen then
            local of = otherwin:frame()
            of.x = screenFrame.x
            of.y = screenFrame.y
            of.w = screenFrame.w
            of.h = screenFrame.h / 2
            otherwin:setFrame(of)
        end
    end
end

-- Raccourcis clavier avec right_option + hjkl (pour déplacer les fenêtres)
hs.hotkey.bind({"right_option"}, "h", moveWindowLeft)
hs.hotkey.bind({"right_option"}, "j", moveWindowUp)
hs.hotkey.bind({"right_option"}, "k", moveWindowDown)
hs.hotkey.bind({"right_option"}, "l", moveWindowRight)

-- Fonctions pour changer de fenêtre active
local function focusWindowLeft()
    local win = hs.window.focusedWindow()
    if win then
        win:focusWindowWest()
    end
end

local function focusWindowRight()
    local win = hs.window.focusedWindow()
    if win then
        win:focusWindowEast()
    end
end

local function focusWindowUp()
    local win = hs.window.focusedWindow()
    if win then
        win:focusWindowNorth()
    end
end

local function focusWindowDown()
    local win = hs.window.focusedWindow()
    if win then
        win:focusWindowSouth()
    end
end

-- Raccourcis clavier avec right_option + f + hjkl (pour changer le focus)
hs.hotkey.bind({"right_option", "cmd"}, "h", focusWindowLeft)
hs.hotkey.bind({"right_option", "cmd"}, "l", focusWindowRight)
hs.hotkey.bind({"right_option", "cmd"}, "k", focusWindowUp)
hs.hotkey.bind({"right_option", "cmd"}, "j", focusWindowDown)

-- Rendre la fonction vsp accessible via CLI
hs.ipc.cliInstall()
_G.vsp = vsp
-- Exposer la fonction vsp globalement

-- Ajouter un raccourci right_option + w pour fermer la fenêtre
hs.hotkey.bind({"right_option"}, "3", function()
    local win = hs.window.focusedWindow()
    if win then
        win:close()
    end
end)

hs.hotkey.bind({"right_option"}, "2", function()
    local win = hs.window.focusedWindow()
    if win then
        win:close()
    end
end)

-- Définir la fonction handleRightOption si nécessaire
local function handleRightOption(event)
    -- Ajoutez ici la logique pour gérer l'événement right_option
    return false
end

local rightOptionTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, handleRightOption)
rightOptionTap:start()

