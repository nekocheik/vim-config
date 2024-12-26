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

-- Ajouter au début du fichier
local hotkeys = {}

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

-- Fonction pour gérer les raccourcis
local function toggleHotkeys(enabled)
    for _, hk in ipairs(hotkeys) do
        if enabled then
            hk:enable()
        else
            hk:disable()
        end
    end
end

-- Function to check the custom mode from the file
function checkCustomMode()
    local file = io.open('/tmp/nvim_custom_mode_status', "r")
    if file then
        local content = file:read("*all")
        file:close()
        local isCustomMode = content:gsub("%s+", "") == "true"
        -- hs.alert.show("Custom Mode Check: " .. tostring(isCustomMode))
        return isCustomMode
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
        -- hs.alert.show("Border Update: Custom Mode = " .. tostring(isCustomMode))
        
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
        
        -- Ajouter la gestion des raccourcis
        toggleHotkeys(not isCustomMode)
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
    -- hs.alert.show("Window Event: Window event triggered border update")
    updateBorder()
end)

-- Observateur pour les changements d'application
local applicationWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        -- hs.alert.show("App Changed: " .. (appName or "unknown"))
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

-- Modifier les définitions des raccourcis pour les stocker
local hk1 = hs.hotkey.bind({"cmd", "option"}, "V", vsp)
table.insert(hotkeys, hk1)

local hk2 = hs.hotkey.bind({"right_option"}, "Space", function()
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
      win:raise()
    end
  end
end)
table.insert(hotkeys, hk2)

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

-- Table de mapping pour les raccourcis natifs
local nativeKeyMap = {
    -- Navigation avec les caractères spéciaux pour vim-move
    ["right_option+h"] = { key = "˙" }, -- Option + h -> ˙
    ["right_option+j"] = { key = "∆" }, -- Option + j -> ∆
    ["right_option+k"] = { key = "˚" }, -- Option + k -> ˚
    ["right_option+l"] = { key = "¬" }, -- Option + l -> ¬
    
    -- Focus avec cmd (inchangé)
    ["right_option+cmd+h"] = { mods = {"cmd", "alt"}, key = "left" },
    ["right_option+cmd+l"] = { mods = {"cmd", "alt"}, key = "right" },
    ["right_option+cmd+j"] = { mods = {"cmd", "alt"}, key = "down" },
    ["right_option+cmd+k"] = { mods = {"cmd", "alt"}, key = "up" },
}

-- Variable pour le debounce
local lastExecutionTime = 0
local debounceInterval = 50 -- Réduit de 100ms à 50ms

local function shouldExecuteAction(mods, key)
    local currentTime = hs.timer.absoluteTime() / 1000000
    
    -- En mode custom, pas besoin de debounce pour les commandes de focus
    if checkCustomMode() then
        local keyCombo = table.concat(mods, "+") .. "+" .. key
        local mapping = nativeKeyMap[keyCombo]
        if mapping then
            hs.eventtap.keyStrokes(mapping.key)
        end
        return false
    end
    
    -- Pour les commandes de focus (avec cmd), ignorer le debounce
    if mods and #mods == 2 and mods[1] == "right_option" and mods[2] == "cmd" then
        return true
    end
    
    -- Appliquer le debounce uniquement pour les autres commandes
    if (currentTime - lastExecutionTime) < debounceInterval then
        return false
    end
    
    lastExecutionTime = currentTime
    return true
end

-- Modifier les définitions des raccourcis pour utiliser la nouvelle logique
hs.hotkey.bind({"right_option"}, "h", function()
    if shouldExecuteAction({"right_option"}, "h") then
        moveWindowLeft()
    end
end)

hs.hotkey.bind({"right_option"}, "l", function()
    if shouldExecuteAction({"right_option"}, "l") then
        moveWindowRight()
    end
end)

hs.hotkey.bind({"right_option"}, "j", function()
    if shouldExecuteAction({"right_option"}, "j") then
        moveWindowDown()
    end
end)

hs.hotkey.bind({"right_option"}, "k", function()
    if shouldExecuteAction({"right_option"}, "k") then
        moveWindowUp()
    end
end)

-- Pour les fonctions de focus
hs.hotkey.bind({"right_option", "cmd"}, "h", function()
    if shouldExecuteAction({"right_option", "cmd"}, "h") then
        focusWindowLeft()
    end
end)

hs.hotkey.bind({"right_option", "cmd"}, "l", function()
    if shouldExecuteAction({"right_option", "cmd"}, "l") then
        focusWindowRight()
    end
end)

hs.hotkey.bind({"right_option", "cmd"}, "k", function()
    if shouldExecuteAction({"right_option", "cmd"}, "k") then
        focusWindowUp()
    end
end)

hs.hotkey.bind({"right_option", "cmd"}, "j", function()
    if shouldExecuteAction({"right_option", "cmd"}, "j") then
        focusWindowDown()
    end
end)

-- Pour les raccourcis de fermeture
hs.hotkey.bind({"right_option"}, "3", function()
    if shouldExecuteAction() then
        local win = hs.window.focusedWindow()
        if win then win:close() end
    end
end)

hs.hotkey.bind({"right_option"}, "2", function()
    if shouldExecuteAction() then
        local win = hs.window.focusedWindow()
        if win then win:close() end
    end
end)

-- Pour le raccourci Space
hs.hotkey.bind({"right_option"}, "Space", function()
    if shouldExecuteAction() then
        local win = hs.window.focusedWindow()
        if win then
            local f = win:frame()
            local screen = win:screen()
            local max = screen:frame()
            
            if f.x == max.x and f.y == max.y and f.w == max.w and f.h == max.h then
                -- Restaurer à la taille précédente
                f.w = max.w / 2
                f.h = max.h
                win:setFrame(f)
            else
                -- Maximiser et mettre au premier plan
                win:maximize()
                win:raise()
            end
        end
    end
end)

hs.ipc.cliInstall()
_G.vsp = vsp

local function handleRightOption(event)
    return false
end

local rightOptionTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, handleRightOption)
rightOptionTap:start()

