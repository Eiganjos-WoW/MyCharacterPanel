-- Les textes en coréen pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "koKR" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "캐릭터 창 크기 조절"
L["OPT_INSPECT_SCALE"]        = "살펴보기 창 크기 조절"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "준비 중.."
L["LEVEL_FORMAT"]         = "레벨 %s"
L["ILVL_FORMAT"]          = "아이템 레벨: %s"
L["MYTHIC_PLUS_FORMAT"]   = "신화+: %s"
L["OPT_YES"]              = "예"
L["OPT_NO"]               = "아니오"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "위대한 금고"
L["REWARD_AVAILABLE"]     = "보상 획득 가능!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "마법부여 안 됨"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "업그레이드 레벨:"
L["PATTERN_ENCHANT"]      = "마법부여됨"
L["PATTERN_RENFORT"]      = "강화"
L["PATTERN_USE"]          = "사용 효과"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "능력치"
L["TAB_TITLES"]           = "칭호"
L["TAB_EQUIPMENT"]        = "장비"
L["STAT_MOVESPEED"]       = "속도"
L["STAT_DURABILITY"]      = "내구도:"
L["DRAG_DROP_STATS"]      = "능력치를 드래그 앤 드롭하여 순서를 변경할 수 있습니다!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "설정"

-- Section "Non enchanté"
L["SLOT_HEAD"]            = "머리"
L["SLOT_NECK"]            = "목"
L["SLOT_SHOULDER"]        = "어깨"
L["SLOT_CHEST"]           = "가슴"
L["SLOT_WAIST"]           = "허리"
L["SLOT_LEGS"]            = "다리"
L["SLOT_FEET"]            = "발"
L["SLOT_BACK"]            = "등"
L["SLOT_MAINHAND"]        = "주장비"
L["SLOT_OFFHAND"]         = "보조장비"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["치명타 및 극대화"] = "치명",
    ["가속"] = "가속",
    ["특화"] = "특화",
    ["유연성"] = "유연",
    ["지능"] = "지능",
    ["민첩성"] = "민첩",
    ["체력"] = "체력",
}

L.COSMETIC_MAP            = {
    [" 및 %+"] = " | +",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "|cff00ff00ALT|r 키를 누른 상태에서 아이템 iLvl 표시"
