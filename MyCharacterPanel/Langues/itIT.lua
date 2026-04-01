-- Les textes en italien pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "itIT" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "Scala della finestra del personaggio"
L["OPT_INSPECT_SCALE"]        = "Scala della finestra di ispezione"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "Prossimamente.."
L["LEVEL_FORMAT"]         = "Livello %s"
L["ILVL_FORMAT"]          = "iLvl: %s"
L["MYTHIC_PLUS_FORMAT"]   = "M+: %s"
L["OPT_YES"]              = "Sì"
L["OPT_NO"]               = "No"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "Gran Camera"
L["REWARD_AVAILABLE"]     = "Ricompensa disponibile!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "Non incantato"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "Livello di potenziamento:"
L["PATTERN_UPGRADE_RAW"]  = "Livello di potenziamento"
L["PATTERN_ENCHANT"]      = "Incantato"
L["PATTERN_RENFORT"]      = "Rinforzo"
L["PATTERN_USE"]          = "Uso"
L["PATTERN_USE_EN"]       = "Use"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "Statistiche"
L["TAB_TITLES"]           = "Titoli"
L["TAB_EQUIPMENT"]        = "Equipaggiamento"
L["STAT_MOVESPEED"]       = "Velocità"
L["STAT_DURABILITY"]      = "Integrità:"
L["DRAG_DROP_STATS"]      = "Puoi trascinare le statistiche (salvato per personaggio)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "Impostazioni"
-- Section "Non enchanté"
L["SLOT_HEAD"]            = "Testa"
L["SLOT_NECK"]            = "Collo"
L["SLOT_SHOULDER"]        = "Spalle"
L["SLOT_CHEST"]           = "Torace"
L["SLOT_WAIST"]           = "Vita"
L["SLOT_LEGS"]            = "Gambe"
L["SLOT_FEET"]            = "Piedi"
L["SLOT_BACK"]            = "Schiena"
L["SLOT_MAINHAND"]        = "Mano Destra"
L["SLOT_OFFHAND"]         = "Mano Sinistra"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["Finitura critica"] = "Crit",
    ["Celerità"]         = "Cele",
    ["Maestria"]         = "Maes",
    ["Versatilità"]      = "Versa",
    ["Intelletto"]       = "Intel",
    ["Agilità"]          = "Agi",
    ["Tempra"]           = "Sta",
}

L.COSMETIC_MAP            = {
    [" e %+"]    = " | +",
    [" del "]    = " ",
    [" della "]  = " ",
    [" dell'"]   = " ",
    [" degli "]  = " ",
    [" delle "]  = " ",
    [" al "]     = " ",
    [" alla "]   = " ",
    [" all'"]    = " ",
    [" allo "]   = " ",
    [" ai "]     = " ",
    [" agli "]   = " ",
    [" alle "]   = " ",
    [" di "]     = " ",
    [" il "]     = " ",
    [" la "]     = " ",
    [" lo "]     = " ",
    ["d'"]       = "",
    ["d’"]       = "",
    ["D'"]       = "",
    ["D’"]       = "",
    ["l'"]       = "",
    ["l’"]       = "",
    ["L'"]       = "",
    ["L’"]       = "",
    ["^Il "]     = "",
    ["^il "]     = "",
    ["^La "]     = "",
    ["^la "]     = "",
    ["^Lo "]     = "",
    ["^lo "]     = "",
}


L["OPT_SHOW_FLYOUT_ILVL"] = "Mostra livello oggetto tenendo premuto |cff00ff00ALT|r"
