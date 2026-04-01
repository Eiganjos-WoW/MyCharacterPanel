-- Les textes en allemand pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "deDE" then return end

local L                       = addon.L or {}
addon.L                       = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["ADDON_TITLE"]              = "MyCharacterPanel"
L["LOADING"]                  = "..."
L["COMING_SOON"]              = "Demnächst.."
L["LEVEL_FORMAT"]             = "Stufe %s"
L["ILVL_FORMAT"]              = "iLvl: %s"
L["MYTHIC_PLUS_FORMAT"]       = "M+: %s"
L["OPT_YES"]                  = "Ja"
L["OPT_NO"]                   = "Nein"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]              = "Große Schatzkammer"
L["REWARD_AVAILABLE"]         = "Belohnung verfügbar!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]            = "Nicht verzaubert"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]          = "Aufwertungsstufe:"
L["PATTERN_UPGRADE_RAW"]      = "Aufwertungsstufe"
L["PATTERN_ENCHANT"]          = "Verzaubert"
L["PATTERN_RENFORT"]          = "Verstärkung"
L["PATTERN_USE"]              = "Benutzen"
L["PATTERN_USE_EN"]           = "Use"
L["PATTERN_ENCHANT_SHORT"]    = "Verz."
L["PATTERN_TRACK_EXCLUDE_1"]  = "aufwertung"
L["PATTERN_TRACK_EXCLUDE_2"]  = "Level"
L["PATTERN_TRACK_EXCLUDE_3"]  = "Upgrade"

-- Formats d'affichage
L["UPGRADE_FORMAT"]           = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"]     = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]                = "Statistiken"
L["TAB_TITLES"]               = "Titel"
L["TAB_EQUIPMENT"]            = "Ausrüstung"
L["STAT_MOVESPEED"]           = "Tempo"
L["STAT_DURABILITY"]          = "Haltbarkeit:"
DRAG_DROP_STATS               = "Du kannst Statistiken per Drag & Drop verschieben (pro Charakter gespeichert)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]            = "Einstellungen"
L["TUTORIAL_OPTIONS"]         = "Hier klicken, um das MCP-Interface zu konfigurieren."
L["OPTIONS_RELOAD_REQ"]       = "(Erfordert /reload zur vollständigen Übernahme)"

-- Catégories Menu Gauche
L["TAB_MENU_GENERAL"]         = "Allgemein"
L["TAB_MENU_SETTINGS"]        = "Einstellungen"
L["TAB_MENU_DISPLAY"]         = "Anzeige"
L["TAB_MENU_FONTS"]           = "Schriftarten"
L["TAB_MENU_GEMS"]            = "Edelsteine"
L["TAB_MENU_TEXT_APPEARANCE"] = "Apparence du texte"
L["TAB_MENU_CHARACTER_FRAME"] = "Cadre personnage"
L["TAB_MENU_ACCORDIONS"]      = "Accordéons"

-- Section Général
L["OPT_GEN_TITLE"]            = "Allgemein"
L["OPT_SCALE_TITLE"]          = "Skalierung des Charakterfensters"
L["OPT_INSPECT_SCALE"]        = "Skalierung des Inspektionsfensters"
L["OPT_DEFAULT_TAB"]          = "Standard-Tab"

-- Section Visuels & Textes
L["OPT_VIS_TITLE"]            = "Layout und Optik"
L["OPT_SHOW_ILVL"]            = "Gegenstandsstufe anzeigen"
L["OPT_SHOW_FLYOUT_ILVL"]     = "Itemlevel anzeigen, während die |cff00ff00ALT|r-Taste gedrückt wird"
L["OPT_SHOW_NAME"]            = "Gegenstandsname anzeigen"

-- Section Apparence & Positions
L["OPT_TEXT_APPEARANCE"]      = "Textaussehen"
L["OPT_TEXT_POSITION"]        = "Textposition"
L["OPT_LEFT_COLUMN"]          = "Linke Spalte:"
L["OPT_RIGHT_COLUMN"]         = "Rechte Spalte:"

-- Section Footer / Infos
L["OPT_GEM_REPORT"]           = "Für Anfragen oder Fehler:"
L["OPT_DEV_NOTE"]             = "Entwickler: Eiganjos-Archimonde (EU)"
L["OPT_BETA_NOTE"]            = "Beta-Tester: Gyeo (EU)"
L["OPT_ISSUE_URL"]            = "https://legacy.curseforge.com/wow/addons/my-character-panel-mcp/issues"
L["OPT_WAITING"]              = "Warten..."

-- Section "Non enchanté"
L["SLOT_HEAD"]                = "Kopf"
L["SLOT_NECK"]                = "Hals"
L["SLOT_SHOULDER"]            = "Schulter"
L["SLOT_CHEST"]               = "Brust"
L["SLOT_WAIST"]               = "Taille"
L["SLOT_LEGS"]                = "Beine"
L["SLOT_FEET"]                = "Füße"
L["SLOT_WRIST"]               = "Handgelenke"
L["SLOT_HANDS"]               = "Hände"
L["SLOT_FINGER1"]             = "Finger 1"
L["SLOT_FINGER2"]             = "Finger 2"
L["SLOT_TRINKET1"]            = "Schmuck 1"
L["SLOT_TRINKET2"]            = "Schmuck 2"
L["SLOT_BACK"]                = "Rücken"
L["SLOT_MAINHAND"]            = "Waffenhand"
L["SLOT_OFFHAND"]             = "Schildhand"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP                   = {
    ["Kritischer Trefferwert"] = "Krit",
    ["Tempo"]                  = "Tempo",
    ["Meisterschaft"]          = "Meist",
    ["Vielseitigkeit"]         = "Viels",
    ["Intelligenz"]            = "Int",
    ["Beweglichkeit"]          = "Bew",
    ["Ausdauer"]               = "Ausd",
}

L.COSMETIC_MAP                = {
    [" und %+"] = " | +",
    [" der "]   = " ",
    [" die "]   = " ",
    [" das "]   = " ",
    [" des "]   = " ",
    [" dem "]   = " ",
    [" den "]   = " ",
    [" am "]    = " ",
    [" im "]    = " ",

    ["^Der "]   = "",
    ["^der "]   = "",
    ["^Die "]   = "",
    ["^die "]   = "",
    ["^Das "]   = "",
    ["^das "]   = "",
}
