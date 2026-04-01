-- Les textes en anglais pour servir de base ou de secours

local addonName, addon        = ...
local L                       = addon.L or {}
addon.L                       = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["ADDON_TITLE"]              = "MyCharacterPanel"
L["LOADING"]                  = "..."
L["COMING_SOON"]              = "Coming soon.."
L["LEVEL_FORMAT"]             = "Level %s"
L["ILVL_FORMAT"]              = "ilvl: %s"
L["MYTHIC_PLUS_FORMAT"]       = "M+: %s"
L["OPT_YES"]                  = "Yes"
L["OPT_NO"]                   = "No"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]              = "Great Vault"
L["REWARD_AVAILABLE"]         = "Reward available!"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]            = "Not enchanted"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]          = "Upgrade Level:"
L["PATTERN_UPGRADE_RAW"]      = "Upgrade Level"
L["PATTERN_ENCHANT"]          = "Enchanted"
L["PATTERN_RENFORT"]          = "Reinforcement"
L["PATTERN_USE"]              = "Use"
L["PATTERN_USE_EN"]           = "Use"
L["PATTERN_ENCHANT_SHORT"]    = "Enchant"
L["PATTERN_TRACK_EXCLUDE_1"]  = "upgrade"
L["PATTERN_TRACK_EXCLUDE_2"]  = "Level"
L["PATTERN_TRACK_EXCLUDE_3"]  = "Upgrade"

-- Formats d'affichage
L["UPGRADE_FORMAT"]           = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"]     = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]                = "Statistics"
L["TAB_TITLES"]               = "Titles"
L["TAB_EQUIPMENT"]            = "Equipment"
L["STAT_MOVESPEED"]           = "Speed"
L["STAT_DURABILITY"]          = "Durability:"
L["DRAG_DROP_STATS"]          = "You can drag & drop statistics (saved per character)!"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]            = "Settings"
L["TUTORIAL_OPTIONS"]         = "Click here to configure MCP interface."
L["OPTIONS_RELOAD_REQ"]       = "(Requires /reload to fully apply)"

-- Catégories Menu Gauche
L["TAB_MENU_GENERAL"]         = "General"
L["TAB_MENU_SETTINGS"]        = "Settings"
L["TAB_MENU_DISPLAY"]         = "Display"
L["TAB_MENU_FONTS"]           = "Fonts"
L["TAB_MENU_GEMS"]            = "Gems"
L["TAB_MENU_TEXT_APPEARANCE"] = "Text Appearance"
L["TAB_MENU_CHARACTER_FRAME"] = "Character Frame"
L["TAB_MENU_ACCORDIONS"]      = "Accordions"

-- Section Général
L["OPT_GEN_TITLE"]            = "General"
L["OPT_SCALE_TITLE"]          = "Character window scale"
L["OPT_INSPECT_SCALE"]        = "Inspection window scale"
L["OPT_DEFAULT_TAB"]          = "Default Tab"
L["OPT_TAB_STATS"]            = "Statistics (Default)"
L["OPT_TAB_TITLES"]           = "Titles"
L["OPT_TAB_EQUIP"]            = "Equipment Manager"
L["OPT_RESET_STATS_CONFIRM"]  = "Reset statistics order?"
L["OPT_RESET_STATS"]          = "Reset statistics order"
L["OPT_RESET_ALL"]            = "Reset all options"
L["OPT_RESET_WARN"]           = "This will restore default settings and reload the interface. Continue?"

-- Section Visuels & Textes
L["OPT_VIS_TITLE"]            = "Layout and Visuals"
L["OPT_SHOW_ILVL"]            = "Show item iLvl"
L["OPT_SHOW_FLYOUT_ILVL"]     = "Show item iLvl when holding |cff00ff00ALT|r key"
L["OPT_SHOW_NAME"]            = "Show item name"
L["OPT_SHOW_NAME_DESC"]       = "|cffaaaaaaShow or hide item names on the sides.|r"
L["OPT_SHOW_ENCHANT"]         = "Show Enchants"
L["OPT_SHOW_UPGRADE"]         = "Show Upgrade Level"
L["OPT_SHOW_GEMS"]            = "Show Gems"
L["OPT_TEXT_TITLE"]           = "Texts and Font"
L["OPT_FONT_NAME"]            = "Font Name"
L["OPT_FONT_NAME_DESC"]       = "Select your preferred font."
L["OPT_FONT_SIZE"]            = "Font Size"
L["OPT_MAX_LEN"]              = "Item name length"
L["OPT_HOVER_SCROLL"]         = "Hover scroll"
L["OPT_HOVER_SCROLL_SHORT"]   = "Hover scroll"
L["OPT_HOVER_SCROLL_DESC"]    = "Scrolls long names on mouse hover for full reading."
L["OPT_MAX_LEN_TABARD"]       = "Tabard/Shirt length"
L["OPT_ENCHANT_RANK_ONLY"]    = "Simplified format '|cff00ff00Enchanted|r' (Enchants)"
L["OPT_ENCHANT_RANK_DESC"]    = "Shows only 'Enchanted' and rank instead of full enchant name."
L["OPT_TIP_SCALING"]          = "Install Lib: SharedMedia-3.0 for more fonts"

-- Section Apparence & Positions
L["OPT_TEXT_APPEARANCE"]      = "Text Appearance"
L["OPT_TEXT_POSITION"]        = "Text Position"
L["OPT_LEFT_COLUMN"]          = "Left Column:"
L["OPT_RIGHT_COLUMN"]         = "Right Column:"
L["OPT_OFFSET_X"]             = "X Offset"
L["OPT_OFFSET_Y"]             = "Y Offset"
L["OPT_HEADER_NAME"]          = "Name"
L["OPT_HEADER_LEVEL"]         = "Level"
L["OPT_HEADER_MYTHIC"]        = "Mythic+"

-- Section Accordéons
L["ACCORDION_SECTION_TITLES"] = "Category Headers"
L["ACCORDION_SECTION_ILVL"]   = "Item Level (iLvl)"
L["ACCORDION_SECTION_TABS"]   = "Accordion Titles"
L["ACCORDION_SECTION_STATS"]  = "Stat Labels"
L["ACCORDION_TITLE_DESC"]     = "Attributes, Enhancements"
L["ACCORDION_ILVL_DESC"]      = "Large item level number"
L["ACCORDION_TAB_DESC"]       = "Statistics, Equipment, Titles"
L["ACCORDION_STAT_DESC"]      = "Intellect, Stamina, Crit, etc."

-- Section Polices par catégorie
L["FONT_CATEGORY_ITEM"]       = "Item Name"
L["FONT_CATEGORY_ILVL"]       = "Item Level"
L["FONT_CATEGORY_ENCHANT"]    = "Enchantment"
L["FONT_CATEGORY_UPGRADE"]    = "Upgrade"

-- Section Gemmes
L["OPT_GEM_SIZE"]             = "Gem size"
L["OPT_GEM_DRAG_INST"]        =
"Click and drag gems to change default position\nSymmetry will be automatic on the left side of equipment."
L["OPT_GEM_RESET"]            = "Reset gems"
L["OPT_GEM_TOOLTIP_TITLE"]    = "Gem %d - Move"
L["OPT_GEM_TOOLTIP_DESC"]     = "Hold left click\nto drag it elsewhere."
L["OPT_SIMULATION_TITLE"]     = "Test Layout"

-- Section Footer / Infos
L["OPT_GEM_REPORT"]           = "For requests or bugs:"
L["OPT_DEV_NOTE"]             = "Developer: Eiganjos-Archimonde (EU)"
L["OPT_BETA_NOTE"]            = "Beta tester: Gyeo (EU)"
L["OPT_ISSUE_URL"]            = "https://legacy.curseforge.com/wow/addons/my-character-panel-mcp/issues"
L["OPT_WAITING"]              = "Waiting..."

-- Section "Non enchanté"
L["OPT_NOT_ENCHANTED_TITLE"]  = "|cffffcc00Display|r |cffff0000\"Not enchanted\"|r"
L["SLOT_HEAD"]                = "Head"
L["SLOT_NECK"]                = "Neck"
L["SLOT_SHOULDER"]            = "Shoulder"
L["SLOT_CHEST"]               = "Chest"
L["SLOT_WAIST"]               = "Waist"
L["SLOT_LEGS"]                = "Legs"
L["SLOT_FEET"]                = "Feet"
L["SLOT_WRIST"]               = "Wrist"
L["SLOT_HANDS"]               = "Hands"
L["SLOT_FINGER1"]             = "Finger 1"
L["SLOT_FINGER2"]             = "Finger 2"
L["SLOT_TRINKET1"]            = "Trinket 1"
L["SLOT_TRINKET2"]            = "Trinket 2"
L["SLOT_BACK"]                = "Back"
L["SLOT_MAINHAND"]            = "Main Hand"
L["SLOT_OFFHAND"]             = "Off Hand"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP                   = {
    ["Critical Strike"] = "Crit",
    ["Haste"]           = "Haste",
    ["Mastery"]         = "Mastery",
    ["Versatility"]     = "Versa",
    ["Intellect"]       = "Intel",
    ["Agility"]         = "Agility",
    ["Stamina"]         = "Stam",
}

L.COSMETIC_MAP                = {
    [" and %+"]  = " | +",
    [" the "]    = " ",
    [" of "]     = " ",
    [" of the "] = " ",
    [" with "]   = " ",

    ["^The "]    = "",
    ["^the "]    = "",
}
