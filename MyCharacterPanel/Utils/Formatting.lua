local addonName, addon = ...
local L = addon.L
local Utils = {}
addon.Utils = Utils

-- Cache des fonctions pour les performances

local tostring, tonumber, type = tostring, tonumber, type
local strgsub, strfind, strlower, strmatch, strsub, strtrim = string.gsub, string.find, string.lower, string.match, string.sub, strtrim
local ipairs, pairs = ipairs, pairs

-- Formatage des nombres

function Utils.FormatNumber(num)
    if not num then return "0" end
    -- Utilisation des fonctions natives WoW si disponibles
    if FormatLargeNumber then return FormatLargeNumber(num)
    elseif BreakUpLargeNumbers then return BreakUpLargeNumbers(num) end
    
    local formatted = tostring(num)
    while true do  
        local k
        formatted, k = strgsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

-- Nettoyage et analyse de texte
-- =============================================================================
local SEPARATOR = " | " 

-- Définition externe des listes pour optimiser la mémoire (Garbage Collector)

local BLACKLIST_MIDDLE = {
    " de ", " du ", " des ", " le ", " la ", " les ", 
    " au ", " aux ", " à ", " et ", ",", 
    " l ", " d " 
}

local BLACKLIST_START = {
    "^de ", "^du ", "^des ", "^le ", "^la ", "^les ", 
    "^au ", "^aux ", "^à ", 
    "^l ", "^d "
}

-- Nettoyage du nom de la statistique pour correspondance

local function CleanStatName(text)
    if not text then return "" end
    
    -- Minuscules et nettoyage basique


    text = strlower(text)
    
    -- Remplacer les apostrophes par des espaces

    text = strgsub(text, "['’]", " ") 
    
    -- Nettoyer les espaces autour

    text = strtrim(text)
    
    -- Application suppression début de phrase

    for _, pattern in ipairs(BLACKLIST_START) do
        text = strgsub(text, pattern, "")
    end

    -- Application suppression milieu de phrase
    for _, pattern in ipairs(BLACKLIST_MIDDLE) do
        text = strgsub(text, pattern, " ")
    end
    
    -- Dernier trim pour avoir le mot pur

    return strtrim(text)
end

-- Recherche de la version courte dans la map

local function GetShortStat(statName)
    local cleanName = CleanStatName(statName)
    local map = addon.Data.STAT_SHORT_MAP
    
    if map then
        -- Recherche de correspondance partielle

        for long, short in pairs(map) do
            if strfind(cleanName, strlower(long)) then
                return short
            end
        end
    end
    
    -- Fallback : renvoi en majuscules

    return string.upper(cleanName)
end

function Utils.CleanString(text)
    if not text or type(text) ~= "string" then return "" end
    
    -- Nettoyage technique global (Couleurs, textures...)


    text = strgsub(text, "|[cC]%x%x%x%x%x%x%x%x", "")
    text = strgsub(text, "|[rR]", "")
    text = strgsub(text, "|A.-|a", "")
    text = strgsub(text, "|T.-|t", "")
    text = strtrim(text)
    
    -- Suppression des préfixes techniques

    local startPos, endPos = strfind(text, ":")
    if endPos then text = strsub(text, endPos + 1) end
    
    -- Optimisation regex pour Enchant/Renfort
    local patEnchant = L["PATTERN_ENCHANT_FIND"] or "Enchant"
    local patRenfort = L["PATTERN_RENFORT_FIND"] or "Renfort"
    
    text = strgsub(text, "^" .. patEnchant .. ".-%s+", "")
    text = strgsub(text, "^" .. patRenfort .. ".-%s+", "")
    text = strtrim(text)

    -- Détection des statistiques doubles

    -- Pattern : Chiffre -> Texte -> Séparateur -> Chiffre -> Texte

    local val1, name1, val2, name2 = strmatch(text, "^%+?(%d+)%s+(.-)%s+[&etanduyи,]+%s+%+?(%d+)%s+(.-)$")
    
    if val1 and val2 then
        local short1 = GetShortStat(name1)
        local short2 = GetShortStat(name2)
        return "+" .. val1 .. " " .. short1 .. SEPARATOR .. "+" .. val2 .. " " .. short2
    end

    -- Statistique simple


    return text
end