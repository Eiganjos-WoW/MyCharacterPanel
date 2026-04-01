-- Les textes en chinois simplifié pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "zhCN" then return end

local L                   = addon.L or {}
addon.L                   = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["OPT_SCALE_TITLE"]          = "角色窗口缩放"
L["OPT_INSPECT_SCALE"]        = "观察窗口缩放"
L["ADDON_TITLE"]          = "MyCharacterPanel"
L["LOADING"]              = "..."
L["COMING_SOON"]          = "敬请期待.."
L["LEVEL_FORMAT"]         = "等级 %s"
L["ILVL_FORMAT"]          = "物品等级: %s"
L["MYTHIC_PLUS_FORMAT"]   = "大秘境+: %s"
L["OPT_YES"]              = "是"
L["OPT_NO"]               = "否"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]          = "宏伟宝库"
L["REWARD_AVAILABLE"]     = "奖励可用！"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]        = "未附魔"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]      = "升级等级:"
L["PATTERN_ENCHANT"]      = "已附魔"
L["PATTERN_RENFORT"]      = "强化"
L["PATTERN_USE"]          = "使用"

-- Formats d'affichage
L["UPGRADE_FORMAT"]       = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"] = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]            = "属性"
L["TAB_TITLES"]           = "称号"
L["TAB_EQUIPMENT"]        = "装备"
L["STAT_MOVESPEED"]       = "速度"
L["STAT_DURABILITY"]      = "耐久度:"
L["DRAG_DROP_STATS"]      = "您可以拖放属性来更改顺序！"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]        = "设置"

-- Section "Non enchanté"
L["SLOT_HEAD"]            = "头部"
L["SLOT_NECK"]            = "项链"
L["SLOT_SHOULDER"]        = "肩部"
L["SLOT_CHEST"]           = "胸部"
L["SLOT_WAIST"]           = "腰部"
L["SLOT_LEGS"]            = "腿部"
L["SLOT_FEET"]            = "脚部"
L["SLOT_BACK"]            = "背部"
L["SLOT_MAINHAND"]        = "主手"
L["SLOT_OFFHAND"]         = "副手"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP               = {
    ["爆击"] = "爆击",
    ["急速"] = "急速",
    ["精通"] = "精通",
    ["全能"] = "全能",
    ["智力"] = "智力",
    ["敏捷"] = "敏捷",
    ["耐力"] = "耐力",
}

L.COSMETIC_MAP            = {
    [" 和 %+"] = " | +",
}



L["OPT_SHOW_FLYOUT_ILVL"] = "按住 |cff00ff00ALT|r 键时显示物品物等"
