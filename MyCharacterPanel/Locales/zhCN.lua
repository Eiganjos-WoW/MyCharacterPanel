local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "zhCN" then return end

-- Fichier de traduction pour la langue zhCN
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "正在加载..."
L["YES"] = "是"
L["NO"] = "否"
L["OK"] = "确定"
L["CANCEL"] = "取消"
L["CONFIRM"] = "确认"
L["UNKNOWN"] = "未知"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "属性"
L["TITLE_M_SCORE"] = "史诗钥石评分"
L["TITLE_GREAT_VAULT"] = "宏伟宝库"
L["TITLE_ILVL"] = "物品等级"
L["PARRY_TOOLTIP_FALLBACK"] = "使你的招架几率提高%.2f%%。"
L["BLOCK_TOOLTIP_FALLBACK"] = "格挡会使你受到的攻击伤害降低%.2f%%。"

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "强化"
L["NOT_ENCHANTED"] = "未附魔"
L["SOCKET_TOOLTIP"] = "Shift + 右键点击镶嵌宝石"

L["SLOT_HEAD"] = _G["INVTYPE_HEAD"]
L["SLOT_NECK"] = _G["INVTYPE_NECK"]
L["SLOT_SHOULDER"] = _G["INVTYPE_SHOULDER"]
L["SLOT_CHEST"] = _G["INVTYPE_CHEST"]
L["SLOT_WAIST"] = _G["INVTYPE_WAIST"]
L["SLOT_LEGS"] = _G["INVTYPE_LEGS"]
L["SLOT_FEET"] = _G["INVTYPE_FEET"]
L["SLOT_WRIST"] = _G["INVTYPE_WRIST"]
L["SLOT_HAND"] = _G["INVTYPE_HAND"]
L["SLOT_BACK"] = _G["INVTYPE_CLOAK"]
L["SLOT_MAINHAND"] = _G["INVTYPE_WEAPONMAINHAND"]
L["SLOT_OFFHAND"] = _G["INVTYPE_WEAPONOFFHAND"]
L["SLOT_TABARD"] = _G["INVTYPE_TABARD"]
L["SLOT_SHIRT"] = _G["INVTYPE_BODY"]
L["SLOT_FINGER1"] = "手指 1"
L["SLOT_FINGER2"] = "手指 2"
L["SLOT_TRINKET1"] = "饰品 1"
L["SLOT_TRINKET2"] = "饰品 2"

L["PATTERN_ENCHANT_FIND"] = "附魔"
L["PATTERN_RENFORT_FIND"] = "强化" -- Reinforced / Reinforcement
L["PATTERN_ILLUSION"] = "幻象"
L["PATTERN_USE"] = "使用"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "装备"
L["TEXT_CONFIRM_SAVE"] = "保存装备方案"
L["TEXT_CONFIRM_DELETE"] = "删除装备方案"
L["EQUIP"] = "装备"
L["SAVE"] = "保存"
L["NEW_SET"] = "新方案"
L["EDIT"] = "编辑"
L["DELETE"] = "删除"
L["SPECIALIZATION"] = "专精"
L["NAME"] = "名称"
L["CHOOSE_ICON"] = "选择图标"
L["ENTER_NAME"] = "输入名称"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "头衔"
L["NO_TITLE"] = "无头衔"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "选择一个声望阵营。"
L["PARAGON_REWARDS_AVAILABLE"] = "巅峰奖励可用："
L["REWARD"] = "奖励"
L["REWARDS"] = "奖励"
L["REWARD_ZERO"] = "奖励：0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "历史记录"
L["NO_DESCRIPTION"] = "暂无描述。"

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "设置"
L["RELOAD_REQUIRED_BODY"] = "需要重载界面才能应用这些更改。\n是否立即重载？"
L["YES_RELOAD"] = "是 (Reload)"
L["RESET_FONTS_BODY"] = "注意，您即将重置所有字体为默认值。\n\n确定吗？"


L["PREVIEW_ENCHANT_NAME"] = "附魔：暗影泰坦之速"
L["PREVIEW_UPGRADE_TEXT"] = "[英雄 6/8]"
L["TITLE_PREVIEW"] = "实时预览"
L["TITLE_GENERAL_DISPLAY"] = "常规显示"

L["OPTION_SHOW_ITEM_NAMES"] = "显示物品名称"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "显示或隐藏完整的物品名称。"
L["OPTION_SCROLL_NAMES"] = "启用名称滚动"
L["OPTION_SCROLL_NAMES_DESC"] = "如果物品名称过长则滚动显示。"
L["OPTION_SHOW_UPGRADE"] = "显示升级等级"
L["OPTION_SHOW_UPGRADE_DESC"] = "显示升级等级（例如：英雄 4/6）。"
L["OPTION_SHOW_ENCHANTS"] = "显示附魔"
L["OPTION_SHOW_ENCHANTS_DESC"] = "显示附魔名称。"
L["OPTION_SHOW_SET_INFO"] = "套装进度指示器"
L["OPTION_SHOW_SET_INFO_DESC"] = "显示套装进度（例如：2/4）。"
L["OPTION_SHOW_MODEL"] = "鼠标悬停显示3D模型"
L["OPTION_SHOW_MODEL_DESC"] = "鼠标悬停时显示您的角色穿着该物品的模型。"

L["TITLE_TYPOGRAPHY"] = "排版"
L["RELOAD_REQUIRED_SHORT"] = "/reload 必须"
L["BUTTON_APPLY_FONTS"] = "点击此处应用字体"
L["BUTTON_RESET_FONTS"] = "重置字体"

L["FONT_ACCORDION_TITLE"] = "折叠标题"
L["FONT_ACCORDION_TITLE_DESC"] = "可折叠标题栏的字体。"
L["FONT_ITEM_NAME"] = "物品名称"
L["FONT_ITEM_NAME_DESC"] = "物品名称的字体。"
L["FONT_ITEM_LEVEL"] = "物品等级 (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "图标上物品等级的字体。"
L["FONT_ENCHANTS"] = "附魔"
L["FONT_ENCHANTS_DESC"] = "附魔和警告的字体。"
L["FONT_UPGRADE"] = "升级等级"
L["FONT_UPGRADE_DESC"] = "升级文本的字体。"
L["FONT_SET_BONUS"] = "套装进度指示器"
L["FONT_SET_BONUS_DESC"] = "套装计数器的字体。"

L["TITLE_BEHAVIOR"] = "行为"
L["OPTION_DEFAULT_ACCORDION"] = "默认展开菜单："
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "全部折叠"

L["TITLE_ALERT_MISSING_ENCHANT"] = "警告：缺少附魔"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "选择如果没有附魔则显示 |cffff2020'未附魔'|r 的部位。"

L["DEV_LABEL"] = "|cffffffff开发:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "感谢 LanceDH 的 TextureAtlasViewer 插件"
L["CREDITS_NEXUS"] = "感谢 NexuswOw 的开发"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "重置统计"
L["RESET_STATS_DESC"] = "将统计顺序重置为默认配置。"
L["MAJ_TITLE"] = "新功能 - 版本 %s"
L["MAJ_FEATURE_1"] = "- 拖放：拖放统计数据以重新排序！"
L["MAJ_FEATURE_2"] = "- 角色独立保存：每个角色现在都有自己的配置。"
L["MAJ_FEATURE_3"] = "- API iLvl 修复"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- 修复：武器上的油/附魔应用已修复"
L["MAJ_NOTE_OPTIONS"] = "别忘了可以通过 |TInterface\\Buttons\\UI-OptionsButton:16:16:0:-1|t 图标或游戏中的 |cff00ccff/mcp config|r 命令访问选项！"
L["SEE_OPTIONS"] = "查看选项"
L["TITLE_RESET_SECTION"] = "恢复默认设置"
L["INSTRUCTION_ACCESS"] = "通过按钮 |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t 访问设置 \n或在聊天中输入命令 |cff00ccff/mcp config|r"




-- Notes d'information dans les options
L["INFO_NOTE_STATS_DRAG"] = "You can move stats between each other via Click/Drag."
L["INFO_NOTE_ZOOM_SCROLL"] = "You can change the frame size by holding CTRL + mouse wheel up or down."
L["OPTION_LOCK_ZOOM"] = "Lock zoom"
L["OPTION_LOCK_ZOOM_DESC"] = "Prevents changing the interface size with CTRL + Mouse Wheel."
-- ==============================================================================
-- Zoom / Scaling
-- ==============================================================================
L["ZOOM_HINT"] = "CTRL + Scroll to zoom"
L["ZOOM_FEEDBACK"] = "Zoom %d%%"
L["RESET_ZOOM"] = "Reset zoom"
L["HELP_ZOOM"] = "|cffffffffInterface Zoom:|r Hold |cff00ccffCTRL|r and use the |cff00ccffmouse wheel|r to adjust the addon size between 50% and 150%. Zoom is saved automatically."
L["HELP_STATS_REORDER"] = "|cffffffffStats Reordering:|r Click and hold on a stat, then drag it to change its display order. Order is saved per character."

-- ==============================================================================
-- Traduction pour Config/Consts.lua
-- ==============================================================================
L["STANDARD"] = "Friz Quadrata"
L["ARIAL"] = "Arial"
L["MORPHEUS"] = "Morpheus"
L["SKURRI"] = "Skurri"
L["2002"] = "2002"

-- ==============================================================================
-- Mapping des noms courts
-- ==============================================================================
addon.Data.STAT_SHORT_MAP = {
    -- Primary
    ["力量"] = "力量",
    ["敏捷"] = "敏捷",
    ["智力"] = "智力",
    ["耐力"] = "耐力",
    ["法力值"] = "法力",
    ["护甲"] = "护甲",

    -- Secondary & Tertiary
    ["爆击"] = "爆击",
    ["急速"] = "急速",
    ["精通"] = "精通",
    ["全能"] = "全能",
    ["吸血"] = "吸血",
    ["闪避"] = "闪避",
    ["加速"] = "加速",
}
