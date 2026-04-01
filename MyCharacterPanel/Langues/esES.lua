-- Les textes en espagnol pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "esES" then return end

local L                    = addon.L or {}
addon.L                    = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "Escala de la ventana de personaje"
L["OPT_INSPECT_SCALE"]        = "Escala de la ventana de inspección"
L["ADDON_TITLE"]           = "MyCharacterPanel"
L["LOADING"]               = "..."
L["COMING_SOON"]           = "Próximamente.."
L["LEVEL_FORMAT"]          = "Nivel %s"
L["ILVL_FORMAT"]           = "iLvl: %s"
L["MYTHIC_PLUS_FORMAT"]    = "M+: %s"
L["OPT_YES"]               = "Sí"
L["OPT_NO"]                = "No"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]           = "Gran Cámara"
L["REWARD_AVAILABLE"]      = "¡Recompensa disponible!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]         = "No encantado"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]       = "Nivel de mejora:"
L["PATTERN_UPGRADE_RAW"]   = "Nivel de mejora"
L["PATTERN_ENCHANT"]       = "Encantado"
L["PATTERN_RENFORT"]       = "Refuerzo"
L["PATTERN_USE"]           = "Uso"
L["PATTERN_USE_EN"]        = "Use"
L["PATTERN_ENCHANT_SHORT"] = "Encan."

-- Formats d'affichage
L["UPGRADE_FORMAT"]        = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"]  = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]             = "Estadísticas"
L["TAB_TITLES"]            = "Títulos"
L["TAB_EQUIPMENT"]         = "Equipo"
L["STAT_MOVESPEED"]        = "Velocidad"
L["STAT_DURABILITY"]       = "Durabilidad:"
L["DRAG_DROP_STATS"]       = "¡Puedes arrastrar y soltar las estadísticas (se guarda por personaje)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]         = "Configuración"
L["TUTORIAL_OPTIONS"]      = "Haz clic aquí para configurar la interfaz de MCP."
L["OPTIONS_RELOAD_REQ"]    = "(Requiere /reload para aplicarse por completo)"

-- Section "Non enchanté"
L["SLOT_HEAD"]             = "Cabeza"
L["SLOT_NECK"]             = "Cuello"
L["SLOT_SHOULDER"]         = "Hombro"
L["SLOT_CHEST"]            = "Pecho"
L["SLOT_WAIST"]            = "Cintura"
L["SLOT_LEGS"]             = "Piernas"
L["SLOT_FEET"]             = "Pies"
L["SLOT_WRIST"]            = "Muñecas"
L["SLOT_HANDS"]            = "Manos"
L["SLOT_FINGER1"]          = "Dedo 1"
L["SLOT_FINGER2"]          = "Dedo 2"
L["SLOT_TRINKET1"]         = "Abalorio 1"
L["SLOT_TRINKET2"]         = "Abalorio 2"
L["SLOT_BACK"]             = "Espalda"
L["SLOT_MAINHAND"]         = "Mano derecha"
L["SLOT_OFFHAND"]          = "Mano izquierda"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP                = {
    ["Golpe crítico"] = "Crit",
    ["Celeridad"]     = "Cele",
    ["Maestría"]      = "Maes",
    ["Versatilidad"]  = "Versa",
    ["Intelecto"]     = "Inte",
    ["Agilidad"]      = "Agi",
    ["Aguante"]       = "Agua",
}

L.COSMETIC_MAP             = {
    [" y %+"]   = " | +",
    [" de la "] = " ",
    [" del "]   = " ",
    [" a la "]  = " ",
    [" de "]    = " ",
    [" la "]    = " ",
    [" el "]    = " ",
    [" al "]     = " ",
    [" los "]   = " ",
    [" las "]   = " ",

    ["^El "]    = "",
    ["^el "]    = "",
    ["^La "]    = "",
    ["^la "]    = "",
    ["^Los "]   = "",
    ["^los "]   = "",
    ["^Las "]   = "",
    ["^las "]   = "",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "Mostrar nivel de objeto al mantener la tecla |cff00ff00ALT|r"
