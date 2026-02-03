local addonName, addon = ...

-- On s'assure que l'addon est bien chargé avec ses tables

addon.L = addon.L or {}
addon.Data = addon.Data or {} 

setmetatable(addon.L, {
    __index = function(t, k)
        return k
    end
})

addon.IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local L = addon.L
addon.Consts = addon.Consts or {}


-- Une infobulle spéciale pour éviter les problèmes avec celle de base

addon.Tooltip = CreateFrame("GameTooltip", "MyCharacterPanelTooltip", UIParent, "GameTooltipTemplate")
addon.Tooltip:SetFrameStrata("TOOLTIP")
addon.Tooltip:SetClampedToScreen(true)

if addon.Tooltip.NineSlice then
    addon.Tooltip.NineSlice:SetCenterColor(0, 0, 0, 0.9)
    addon.Tooltip.NineSlice:SetBorderColor(0.5, 0.5, 0.5, 1)
end


-- Toutes les constantes pour l'apparence et les positions

local START_Y, STEP_Y, WEAPON_Y = -110, 64, 20

addon.Consts = {
    STATS_WIDTH_OPEN = 240,
    STATS_WIDTH_CLOSED = 40,
    
    BACKGROUND_ATLAS = "GarrMissionLocation-Maw-bg-02", 
    COLOR_BACKGROUND_TINT = {1.0, 1.0, 1.0, 1}, 

    HEADER_ATLAS = "spec-background", 
    CONTENT_ATLAS = "tradeskill-background-recipe-unlearned", 
    
    BORDER_TEXTURE = "Interface\\DialogFrame\\UI-DialogBox-Border",
    HEADER_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border",
    
    COLOR_GOLD = {r=1, g=0.82, b=0},
}

addon.Consts.EQUIP_LOC_TO_SLOT = {
    ["INVTYPE_HEAD"] = {1}, ["INVTYPE_NECK"] = {2}, ["INVTYPE_SHOULDER"] = {3},
    ["INVTYPE_BODY"] = {4}, ["INVTYPE_CHEST"] = {5}, ["INVTYPE_ROBE"] = {5},
    ["INVTYPE_WAIST"] = {6}, ["INVTYPE_LEGS"] = {7}, ["INVTYPE_FEET"] = {8},
    ["INVTYPE_WRIST"] = {9}, ["INVTYPE_HAND"] = {10}, ["INVTYPE_FINGER"] = {11, 12},
    ["INVTYPE_TRINKET"] = {13, 14}, ["INVTYPE_CLOAK"] = {15},
    ["INVTYPE_WEAPON"] = {16, 17}, ["INVTYPE_SHIELD"] = {17}, ["INVTYPE_2HWEAPON"] = {16},
    ["INVTYPE_WEAPONMAINHAND"] = {16}, ["INVTYPE_WEAPONOFFHAND"] = {17},
    ["INVTYPE_HOLDABLE"] = {17}, ["INVTYPE_TABARD"] = {19},
}

addon.Consts.SLOTS_LAYOUT = {
    [1]  = { "LEFT", 30, START_Y, "SLOT_HEAD" },
    [2]  = { "LEFT", 30, START_Y - STEP_Y, "SLOT_NECK" },
    [3]  = { "LEFT", 30, START_Y - (STEP_Y * 2), "SLOT_SHOULDER" },
    [15] = { "LEFT", 30, START_Y - (STEP_Y * 3), "SLOT_BACK" },
    [5]  = { "LEFT", 30, START_Y - (STEP_Y * 4), "SLOT_CHEST" },
    [4]  = { "LEFT", 30, START_Y - (STEP_Y * 5), "SLOT_SHIRT" },
    [19] = { "LEFT", 30, START_Y - (STEP_Y * 6), "SLOT_TABARD" },
    [9]  = { "LEFT", 30, START_Y - (STEP_Y * 7), "SLOT_WRIST" },
    [10] = { "RIGHT", -35, START_Y, "SLOT_HAND" },
    [6]  = { "RIGHT", -35, START_Y - STEP_Y, "SLOT_WAIST" },
    [7]  = { "RIGHT", -35, START_Y - (STEP_Y * 2), "SLOT_LEGS" },
    [8]  = { "RIGHT", -35, START_Y - (STEP_Y * 3), "SLOT_FEET" },
    [11] = { "RIGHT", -35, START_Y - (STEP_Y * 4), "SLOT_FINGER1" },
    [12] = { "RIGHT", -35, START_Y - (STEP_Y * 5), "SLOT_FINGER2" },
    [13] = { "RIGHT", -35, START_Y - (STEP_Y * 6), "SLOT_TRINKET1" },
    [14] = { "RIGHT", -35, START_Y - (STEP_Y * 7), "SLOT_TRINKET2" },
    [16] = { "BOTTOM", -120, WEAPON_Y, "SLOT_MAINHAND" },
    [17] = { "BOTTOM", 120, WEAPON_Y, "SLOT_OFFHAND" },
}

addon.Consts.CLASS_DEFAULT_STAT = {
    ["WARRIOR"] = 1, ["DEATHKNIGHT"] = 1, ["PALADIN"] = 1,
    ["ROGUE"] = 2,   ["HUNTER"] = 2,      ["DEMONHUNTER"] = 2, ["MONK"] = 2,
    ["MAGE"] = 4,    ["PRIEST"] = 4,      ["WARLOCK"] = 4,     ["EVOKER"] = 4,
    ["SHAMAN"] = 2,  ["DRUID"] = 4,
}

-- La liste des polices d'écriture qu'on peut utiliser
addon.Consts.AVAILABLE_FONTS = {
    { name = L["STANDARD"] or "Friz Quadrata", path = "Fonts/FRIZQT__.TTF" },
    { name = L["ARIAL"] or "Arial",            path = "Fonts/ARIALN.TTF" },
    { name = L["MORPHEUS"] or "Morpheus",      path = "Fonts/MORPHEUS.TTF" },
    { name = L["SKURRI"] or "Skurri",          path = "Fonts/SKURRI.TTF" },
    { name = L["2002"] or "2002",              path = "Fonts/2002.TTF" },
    
    -- Custom Fonts
    { name = "Adventure",       path = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/Adventure.ttf" },
    { name = "DorisPP",         path = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/DorisPP.ttf" },
    { name = "Swift",           path = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/SWF!T___.ttf" }, 
    { name = "TeXGyreAdventor", path = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/TeXGyreAdventor.ttf" },
    { name = "Yellowjacket",    path = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/yellow.ttf" },
}