local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "deDE" then return end

-- Fichier de traduction pour la langue deDE
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Laden..."
L["YES"] = "Ja"
L["NO"] = "Nein"
L["OK"] = "OK"
L["CANCEL"] = "Abbrechen"
L["CONFIRM"] = "Bestätigen"
L["UNKNOWN"] = "Unbekannt"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Attribute"
L["TITLE_M_SCORE"] = "Wertung für Mythisch+"
L["TITLE_GREAT_VAULT"] = "Große Schatzkammer"
L["TITLE_ILVL"] = "Gegenstandsstufe"
L["PARRY_TOOLTIP_FALLBACK"] = "Erhöht Eure Chance zu parieren um %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Blocken verringert den erlittenen Schaden eines Angriffs um %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Verstärkungen"
L["NOT_ENCHANTED"] = "Nicht verzaubert"
L["SOCKET_TOOLTIP"] = "Shift + Rechtsklick zum Sockeln"

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
L["SLOT_FINGER1"] = "Finger 1"
L["SLOT_FINGER2"] = "Finger 2"
L["SLOT_TRINKET1"] = "Schmuck 1"
L["SLOT_TRINKET2"] = "Schmuck 2"

L["PATTERN_ENCHANT_FIND"] = "Verzaubert"
L["PATTERN_RENFORT_FIND"] = "Verstärkt" -- Besoin de vérification pour l'allemand
L["PATTERN_ILLUSION"] = "Illusion"
L["PATTERN_USE"] = "Benutzen" -- Ou "Anlegen" selon le contexte
L["PATTERN_TIER1"] = "Tier1" -- Noms de textures, ne pas traduire
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Ausrüstung"
L["TEXT_CONFIRM_SAVE"] = "Ausrüstungsset speichern"
L["TEXT_CONFIRM_DELETE"] = "Ausrüstungsset löschen"
L["EQUIP"] = "Anlegen"
L["SAVE"] = "Speichern"
L["NEW_SET"] = "Neues Set"
L["EDIT"] = "Bearbeiten"
L["DELETE"] = "Löschen"
L["SPECIALIZATION"] = "Spezialisierung"
L["NAME"] = "Name"
L["CHOOSE_ICON"] = "Symbol wählen"
L["ENTER_NAME"] = "Namen eingeben"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Titel"
L["NO_TITLE"] = "Kein Titel"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Wählen Sie eine Fraktion."
L["PARAGON_REWARDS_AVAILABLE"] = "Paragon-Belohnungen verfügbar:"
L["REWARD"] = "Belohnung"
L["REWARDS"] = "Belohnungen"
L["REWARD_ZERO"] = "Belohnung: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Verlauf"
L["NO_DESCRIPTION"] = "Keine Beschreibung verfügbar."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Einstellungen"
L["RELOAD_REQUIRED_BODY"] = "Ein Neuladen des UI ist erforderlich, um diese Änderungen anzuwenden.\nMöchten Sie dies jetzt tun?"
L["YES_RELOAD"] = "Ja (Reload)"
L["RESET_FONTS_BODY"] = "Achtung, Sie sind dabei, alle Schriftarten auf Standard zurückzusetzen.\n\nSind Sie sicher?"


L["PREVIEW_ENCHANT_NAME"] = "Verzaubert: Schattenhafte Hast"
L["PREVIEW_UPGRADE_TEXT"] = "[Held 6/8]"
L["TITLE_PREVIEW"] = "ECHTZEIT-VORSCHAU"
L["TITLE_GENERAL_DISPLAY"] = "ALLGEMEINE ANZEIGE"

L["OPTION_SHOW_ITEM_NAMES"] = "Gegenstandsnamen anzeigen"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Zeigt oder verbirgt den vollständigen Namen des Gegenstands."
L["OPTION_SCROLL_NAMES"] = "Namenslaufschrift aktivieren"
L["OPTION_SCROLL_NAMES_DESC"] = "Lässt den Gegenstandsnamen scrollen, wenn er zu lang ist."
L["OPTION_SHOW_UPGRADE"] = "Aufwertungsstufe anzeigen"
L["OPTION_SHOW_UPGRADE_DESC"] = "Zeigt den Aufwertungsrang an (z.B. Held 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Verzauberungen anzeigen"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Zeigt den Namen der Verzauberung an."
L["OPTION_SHOW_SET_INFO"] = "Set-Teile-Indikator"
L["OPTION_SHOW_SET_INFO_DESC"] = "Zeigt den Set-Fortschritt an (z.B. 2/4)."
L["OPTION_SHOW_MODEL"] = "3D-Modell bei Mouseover anzeigen"
L["OPTION_SHOW_MODEL_DESC"] = "Zeigt Euren Charakter mit dem Gegenstand bei Mouseover an."

L["TITLE_TYPOGRAPHY"] = "TYPOGRAFIE"
L["RELOAD_REQUIRED_SHORT"] = "/reload erforderlich"
L["BUTTON_APPLY_FONTS"] = "Hier klicken, um Schriftarten anzuwenden"
L["BUTTON_RESET_FONTS"] = "Schriftarten zurücksetzen"

L["FONT_ACCORDION_TITLE"] = "Akkordeon-Titel"
L["FONT_ACCORDION_TITLE_DESC"] = "Schriftart für einklappbare Titelleisten."
L["FONT_ITEM_NAME"] = "Gegenstandsnamen"
L["FONT_ITEM_NAME_DESC"] = "Schriftart für Gegenstandsnamen."
L["FONT_ITEM_LEVEL"] = "Gegenstandsstufe (GS)"
L["FONT_ITEM_LEVEL_DESC"] = "Schriftart für die Gegenstandsstufe auf dem Symbol."
L["FONT_ENCHANTS"] = "Verzauberungen"
L["FONT_ENCHANTS_DESC"] = "Schriftart für Verzauberungen und Warnungen."
L["FONT_UPGRADE"] = "Aufwertungsstufe"
L["FONT_UPGRADE_DESC"] = "Schriftart für den Aufwertungstext."
L["FONT_SET_BONUS"] = "Set-Teile-Indikator"
L["FONT_SET_BONUS_DESC"] = "Schriftart für den Set-Zähler."

L["TITLE_BEHAVIOR"] = "VERHALTEN"
L["OPTION_DEFAULT_ACCORDION"] = "Standardmäßig geöffnetes Menü:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Alles eingeklappt"

L["TITLE_ALERT_MISSING_ENCHANT"] = "WARNUNG: FEHLENDE VERZAUBERUNG"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Wählen Sie die Plätze aus, die |cffff2020'Nicht verzaubert'|r anzeigen sollen, wenn sie keine Verzauberung haben."

L["DEV_LABEL"] = "|cffffffffDev:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Danke an LanceDH für das Addon TextureAtlasViewer"
L["CREDITS_NEXUS"] = "Dank an NexuswOw für die Entwicklung"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "Statistiken zurücksetzen"
L["RESET_STATS_DESC"] = "Setzt die Statistikreihenfolge auf die Standardkonfiguration zurück."
L["MAJ_TITLE"] = "Neuheiten - Version %s"
L["MAJ_FEATURE_1"] = "- Drag & Drop: Ziehen Sie Ihre Statistiken, um sie neu anzuordnen!"
L["MAJ_FEATURE_2"] = "- Charakterspezifische Speicherung: Jeder Charakter hat jetzt seine eigene Konfiguration."
L["MAJ_FEATURE_3"] = "- API iLvl Korrektur"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- Fix: Öl/Verzauberung Anwendung auf Waffen repariert"
L["TITLE_RESET_SECTION"] = "Standardeinstellungen wiederherstellen"
L["INSTRUCTION_ACCESS"] = "Konfiguration über den Knopf |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t aufrufen \noder den Befehl |cff00ccff/mcp|r im Chat eingeben"


-- ==============================================================================
-- Update Notes (MAJ) & Reset
-- ==============================================================================
L["MAJ_NOTE_OPTIONS"] = "Don't forget that options are available via the |TInterface\\Buttons\\UI-OptionsButton:16:16:0:-1|t icon or via the |cff00ccff/mcp config|r command in-game!"
L["SEE_OPTIONS"] = "See Options"



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
    ["Stärke"] = "str",
    ["Beweglichkeit"] = "bew",
    ["Intelligenz"] = "int",
    ["Ausdauer"] = "ausd",
    ["Mana"] = "mana",
    ["Rüstung"] = "rüst",

    -- Secondary & Tertiary
    ["Kritischer Treffer"] = "krit",
    ["Tempo"] = "tempo",
    ["Meisterschaft"] = "meist",
    ["Vielseitigkeit"] = "viels",
    ["Lebensraub"] = "lebensr",
    ["Vermeidung"] = "verm",
    ["Geschwindigkeit"] = "speed",
}
