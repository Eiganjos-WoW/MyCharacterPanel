local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "enUS" then return end

-- Fichier de traduction pour la langue enUS
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Loading..."
L["YES"] = "Yes"
L["NO"] = "No"
L["OK"] = "OK"
L["CANCEL"] = "Cancel"
L["CONFIRM"] = "Confirm"
L["UNKNOWN"] = "Unknown"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Statistics"
L["TITLE_M_SCORE"] = "Mythic+ Score"
L["TITLE_GREAT_VAULT"] = "Great Vault"
L["TITLE_ILVL"] = "Item Level"
L["PARRY_TOOLTIP_FALLBACK"] = "Increases your chance to parry by %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Block reduces the damage you take by %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Enhancements"
L["NOT_ENCHANTED"] = "Not Enchanted"
L["SOCKET_TOOLTIP"] = "Shift + Right Click to socket item"

L["SLOT_FINGER1"] = "Finger 1"
L["SLOT_FINGER2"] = "Finger 2"
L["SLOT_TRINKET1"] = "Trinket 1"
L["SLOT_TRINKET2"] = "Trinket 2"
L["SLOT_HEAD"] = _G["INVTYPE_HEAD"]
L["SLOT_NECK"] = _G["INVTYPE_NECK"]
L["SLOT_SHOULDER"] = _G["INVTYPE_SHOULDER"]
L["SLOT_BACK"] = _G["INVTYPE_CLOAK"]
L["SLOT_CHEST"] = _G["INVTYPE_CHEST"]
L["SLOT_SHIRT"] = _G["INVTYPE_BODY"]
L["SLOT_TABARD"] = _G["INVTYPE_TABARD"]
L["SLOT_WRIST"] = _G["INVTYPE_WRIST"]
L["SLOT_HAND"] = _G["INVTYPE_HAND"]
L["SLOT_WAIST"] = _G["INVTYPE_WAIST"]
L["SLOT_LEGS"] = _G["INVTYPE_LEGS"]
L["SLOT_FEET"] = _G["INVTYPE_FEET"]
L["SLOT_MAINHAND"] = _G["INVTYPE_WEAPONMAINHAND"]
L["SLOT_OFFHAND"] = _G["INVTYPE_WEAPONOFFHAND"]

L["PATTERN_ENCHANT_FIND"] = "Enchant"
L["PATTERN_RENFORT_FIND"] = "Reinforced"
L["PATTERN_ILLUSION"] = "Illusion"
L["PATTERN_USE"] = "Use"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Equipment"
L["TEXT_CONFIRM_SAVE"] = "Save Equipment Set"
L["TEXT_CONFIRM_DELETE"] = "Delete Equipment Set"
L["EQUIP"] = "Equip"
L["SAVE"] = "Save"
L["NEW_SET"] = "New Set"
L["EDIT"] = "Edit"
L["DELETE"] = "Delete"
L["SPECIALIZATION"] = "Specialization"
L["NAME"] = "Name"
L["CHOOSE_ICON"] = "Choose Icon"
L["ENTER_NAME"] = "Enter Name"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Titles"
L["NO_TITLE"] = "No Title"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Select a faction."
L["PARAGON_REWARDS_AVAILABLE"] = "Paragon Rewards Available:"
L["REWARD"] = "Reward"
L["REWARDS"] = "Rewards"
L["REWARD_ZERO"] = "Reward: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Transfer History"
L["NO_DESCRIPTION"] = "No description available."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Settings"
L["RELOAD_REQUIRED_BODY"] = "A UI reload is required to apply these changes.\nDo you want to request it now?"
L["YES_RELOAD"] = "Yes (Reload)"
L["RESET_FONTS_BODY"] = "Warning, you are about to reset all fonts to default.\n\nAre you sure?"


L["PREVIEW_ENCHANT_NAME"] = "Shadow Haste"
L["PREVIEW_UPGRADE_TEXT"] = "[Hero 6/8]"
L["TITLE_PREVIEW"] = "REAL-TIME PREVIEW"
L["TITLE_GENERAL_DISPLAY"] = "GENERAL DISPLAY"

L["OPTION_SHOW_ITEM_NAMES"] = "Show Item Names"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Show or hide the full item name."
L["OPTION_SCROLL_NAMES"] = "Enable Name Scrolling"
L["OPTION_SCROLL_NAMES_DESC"] = "Scrolls the item name if it is too long."
L["OPTION_SHOW_UPGRADE"] = "Show Upgrade Level"
L["OPTION_SHOW_UPGRADE_DESC"] = "Shows the upgrade rank (e.g. Hero 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Show Enhancements"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Shows the enchantment name."
L["OPTION_SHOW_SET_INFO"] = "Set Piece Indicator"
L["OPTION_SHOW_SET_INFO_DESC"] = "Shows set progression (e.g. 2/4)."
L["OPTION_SHOW_MODEL"] = "Show 3D Model on Hover"
L["OPTION_SHOW_MODEL_DESC"] = "Shows your character wearing the item on hover."

L["TITLE_TYPOGRAPHY"] = "TYPOGRAPHY"
L["RELOAD_REQUIRED_SHORT"] = "/reload required"
L["BUTTON_APPLY_FONTS"] = "Click here to apply your fonts"
L["BUTTON_RESET_FONTS"] = "Reset Fonts"

L["FONT_ACCORDION_TITLE"] = "Accordion Titles"
L["FONT_ACCORDION_TITLE_DESC"] = "Font for collapsible title bars."
L["FONT_ITEM_NAME"] = "Item Names"
L["FONT_ITEM_NAME_DESC"] = "Font for item names."
L["FONT_ITEM_LEVEL"] = "Item Level (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Font for item level on the icon."
L["FONT_ENCHANTS"] = "Enhancements"
L["FONT_ENCHANTS_DESC"] = "Font for enhancements and alerts."
L["FONT_UPGRADE"] = "Upgrade Level"
L["FONT_UPGRADE_DESC"] = "Font for upgrade text."
L["FONT_SET_BONUS"] = "Set Piece Indicator"
L["FONT_SET_BONUS_DESC"] = "Font for set counter."

L["TITLE_BEHAVIOR"] = "BEHAVIOR"
L["OPTION_DEFAULT_ACCORDION"] = "Default Open Menu:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "All Collapsed"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ALERT: MISSING ENCHANT"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Select slots to display |cffff2020'Not Enchanted'|r if they have no enchantment."

L["DEV_LABEL"] = "|cffffffffDev:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Thanks to LanceDH for the TextureAtlasViewer addon"
L["CREDITS_NEXUS"] = "Thanks to NexuswOw for the development"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "Reset Stats Order"
L["RESET_STATS_DESC"] = "Resets the statistics order to the default configuration."
L["MAJ_TITLE"] = "What's New - Version %s"
L["MAJ_FEATURE_1"] = "- Drag & Drop: Drag and drop your stats to reorder them!"
L["MAJ_FEATURE_2"] = "- Per-Character Saving: Each character now has their own configuration."
L["MAJ_FEATURE_3"] = "- API iLvl Fix"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- Fix: Oil/Enchant application on weapons repaired"
L["TITLE_RESET_SECTION"] = "Restore Default Settings"
L["INSTRUCTION_ACCESS"] = "Access configuration via the button |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \nor type |cff00ccff/mcp|r in chat"


-- ==============================================================================
-- Update Notes (MAJ) & Reset
-- ==============================================================================
L["MAJ_NOTE_OPTIONS"] = "Don't forget that options are available via the |TInterface\\Buttons\\UI-OptionsButton:16:16:0:-1|t icon or via the |cff00ccff/mcp config|r command in-game!"
L["SEE_OPTIONS"] = "See Options"

-- Textes d'aide pour les options
L["HELP_ZOOM"] = "|cffffffffInterface Zoom:|r Hold |cff00ccffCTRL|r and use the |cff00ccffmouse wheel|r to adjust the addon size between 50% and 150%. Zoom is saved automatically."
L["HELP_STATS_REORDER"] = "|cffffffffStats Reordering:|r Click and hold on a stat, then drag it to change its display order. Order is saved per character."

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
    ["Strength"] = "str",
    ["Agility"] = "agi",
    ["Intellect"] = "intel",
    ["Stamina"] = "sta",
    ["Mana"] = "mana",
    ["Armor"] = "armor",

    -- Secondary & Tertiary
    ["Critical Strike"] = "crit",
    ["Haste"] = "haste",
    ["Mastery"] = "mast",
    ["Versatility"] = "vers",
    ["Leech"] = "leech",
    ["Avoidance"] = "avoid",
    ["Speed"] = "speed",
}