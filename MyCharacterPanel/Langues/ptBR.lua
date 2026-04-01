-- Les textes en portugais pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "ptBR" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "Escala da janela do personagem"
L["OPT_INSPECT_SCALE"]        = "Escala da janela de inspeção"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "Em breve.."
L["LEVEL_FORMAT"]         = "Nível %s"
L["ILVL_FORMAT"]          = "iLvl: %s"
L["MYTHIC_PLUS_FORMAT"]   = "M+: %s"
L["OPT_YES"]              = "Sim"
L["OPT_NO"]               = "Não"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "Grande Cofre"
L["REWARD_AVAILABLE"]     = "Recompensa disponível!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "Não encantado"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "Nível de aprimoramento:"
L["PATTERN_ENCHANT"]      = "Encantado"
L["PATTERN_RENFORT"]      = "Reforço"
L["PATTERN_USE"]          = "Uso"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "Estatísticas"
L["TAB_TITLES"]           = "Títulos"
L["TAB_EQUIPMENT"]        = "Equipamento"
L["STAT_MOVESPEED"]       = "Velocidade"
L["STAT_DURABILITY"]      = "Durabilidade:"
L["DRAG_DROP_STATS"]      = "Você pode arrastar as estatísticas (salvo por personagem)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "Configurações"

-- Section "Non enchanté"
L["SLOT_HEAD"]            = "Cabeça"
L["SLOT_NECK"]            = "Pescoço"
L["SLOT_SHOULDER"]        = "Ombro"
L["SLOT_CHEST"]           = "Torso"
L["SLOT_WAIST"]           = "Cintura"
L["SLOT_LEGS"]            = "Pernas"
L["SLOT_FEET"]            = "Pés"
L["SLOT_BACK"]            = "Costas"
L["SLOT_MAINHAND"]        = "Mão Direita"
L["SLOT_OFFHAND"]         = "Mão Esquerda"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["Acerto Crítico"] = "Crítico",
    ["Aceleração"]     = "Acel",
    ["Maestria"]       = "Maes",
    ["Versatilidade"]  = "Versa",
    ["Intelecto"]      = "Intel",
    ["Agilidade"]      = "Agi",
    ["Vigor"]          = "Vig",
}

L.COSMETIC_MAP            = {
    [" e %+"]  = " | +",
    [" da "]   = " ",
    [" do "]   = " ",
    [" das "]  = " ",
    [" dos "]  = " ",
    [" de "]   = " ",
    [" ao "]   = " ",
    [" à "]    = " ",
    [" aos "]  = " ",
    [" às "]   = " ",
    [" o "]    = " ",
    [" a "]    = " ",
    ["^O "]    = "",
    ["^o "]    = "",
    ["^A "]    = "",
    ["^a "]    = "",
    ["^Os "]   = "",
    ["^os "]   = "",
    ["^As "]   = "",
    ["^as "]   = "",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "Mostrar iLvl do item ao segurar a tecla |cff00ff00ALT|r"
