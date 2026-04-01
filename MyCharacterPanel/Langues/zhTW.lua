-- Les textes en chinois traditionnel pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "zhTW" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "角色視窗縮放"
L["OPT_INSPECT_SCALE"]        = "觀察視窗縮放"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "敬请期待.."
L["LEVEL_FORMAT"]         = "等級 %s"
L["ILVL_FORMAT"]          = "物品等級: %s"
L["MYTHIC_PLUS_FORMAT"]   = "大秘境+: %s"
L["OPT_YES"]              = "是"
L["OPT_NO"]               = "否"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "宏偉寶庫"
L["REWARD_AVAILABLE"]     = "獎勵可用！"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "未附魔"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "升級等級:"
L["PATTERN_ENCHANT"]      = "已附魔"
L["PATTERN_RENFORT"]      = "強化"
L["PATTERN_USE"]          = "使用"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "屬性"
L["TAB_TITLES"]           = "頭銜"
L["TAB_EQUIPMENT"]        = "裝備"
L["STAT_MOVESPEED"]       = "速度"
L["STAT_DURABILITY"]      = "耐久度:"
L["DRAG_DROP_STATS"]      = "您可以拖放屬性來更改順序！"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "設置"

-- Section "Non enchanté"
L["SLOT_HEAD"]            = "頭部"
L["SLOT_NECK"]            = "項鍊"
L["SLOT_SHOULDER"]        = "肩部"
L["SLOT_CHEST"]           = "胸部"
L["SLOT_WAIST"]           = "腰部"
L["SLOT_LEGS"]            = "腿部"
L["SLOT_FEET"]            = "腳部"
L["SLOT_BACK"]            = "背部"
L["SLOT_MAINHAND"]        = "主手"
L["SLOT_OFFHAND"]         = "副手"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["爆擊"] = "爆擊",
    ["極速"] = "極速",
    ["精通"] = "精通",
    ["全能"] = "全能",
    ["智力"] = "智力",
    ["敏捷"] = "敏捷",
    ["耐力"] = "耐力",
}

L.COSMETIC_MAP            = {
    [" 和 %+"] = " | +",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "按住 |cff00ff00ALT|r 鍵時顯示物品物等"
