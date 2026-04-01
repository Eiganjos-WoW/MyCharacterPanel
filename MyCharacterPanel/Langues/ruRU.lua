-- Les textes en russe pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "ruRU" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "Масштаб окна персонажа"
L["OPT_INSPECT_SCALE"]        = "Масштаб окна осмотра"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "Скоро.."
L["LEVEL_FORMAT"]         = "Уровень %s"
L["ILVL_FORMAT"]          = "iLvl: %s"
L["MYTHIC_PLUS_FORMAT"]   = "M+: %s"
L["OPT_YES"]              = "Да"
L["OPT_NO"]               = "Нет"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "Великое хранилище"
L["REWARD_AVAILABLE"]     = "Награда доступна!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "Не зачаровано"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "Уровень улучшения:"
L["PATTERN_ENCHANT"]      = "Зачаровано"
L["PATTERN_RENFORT"]      = "Накладка"
L["PATTERN_USE"]          = "Использование"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "Характеристики"
L["TAB_TITLES"]           = "Звания"
L["TAB_EQUIPMENT"]        = "Экипировка"
L["STAT_MOVESPEED"]       = "Скорость"
L["STAT_DURABILITY"]      = "Прочность:"
L["DRAG_DROP_STATS"]      = "Вы можете перетаскивать характеристики (сохраняется для персонажа)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "Настройки"

-- Section "Non enchanté"
L["SLOT_HEAD"]            = "Голова"
L["SLOT_NECK"]            = "Шея"
L["SLOT_SHOULDER"]        = "Плечи"
L["SLOT_CHEST"]           = "Грудь"
L["SLOT_WAIST"]           = "Пояс"
L["SLOT_LEGS"]            = "Ноги"
L["SLOT_FEET"]            = "Ступни"
L["SLOT_BACK"]            = "Спина"
L["SLOT_MAINHAND"]        = "Правая рука"
L["SLOT_OFFHAND"]         = "Левая рука"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["Критический удар"] = "Крит",
    ["Скорость"] = "Скорость",
    ["Искусность"] = "Искусн",
    ["Универсальность"] = "Универс",
    ["Интеллект"] = "Инт",
    ["Ловкость"] = "Ловк",
    ["Выносливость"] = "Вын",
}

L.COSMETIC_MAP            = {
    [" и %+"] = " | +",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "Показывать iLvl предмета при удержании |cff00ff00ALT|r"
