local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "itIT" then return end

-- Fichier de traduction pour la langue itIT
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Caricamento..."
L["YES"] = "Sì"
L["NO"] = "No"
L["OK"] = "OK"
L["CANCEL"] = "Annulla"
L["CONFIRM"] = "Conferma"
L["UNKNOWN"] = "Sconosciuto"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Statistiche"
L["TITLE_M_SCORE"] = "Punteggio Mitica+"
L["TITLE_GREAT_VAULT"] = "Grancassa"
L["TITLE_ILVL"] = "Livello Oggetto"
L["PARRY_TOOLTIP_FALLBACK"] = "Aumenta la probabilità di parata del %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Blocco riduce i danni subiti da un attacco del %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Miglioramenti"
L["NOT_ENCHANTED"] = "Non incantato"
L["SOCKET_TOOLTIP"] = "Shift + Clic Destro per incastonare"

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
L["SLOT_FINGER1"] = "Dito 1"
L["SLOT_FINGER2"] = "Dito 2"
L["SLOT_TRINKET1"] = "Monile 1"
L["SLOT_TRINKET2"] = "Monile 2"

L["PATTERN_ENCHANT_FIND"] = "Incanta"
L["PATTERN_RENFORT_FIND"] = "Rinforzo"
L["PATTERN_ILLUSION"] = "Illusione"
L["PATTERN_USE"] = "Usa"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Equipaggiamento"
L["TEXT_CONFIRM_SAVE"] = "Salva Set Equipaggiamento"
L["TEXT_CONFIRM_DELETE"] = "Elimina Set Equipaggiamento"
L["EQUIP"] = "Equipaggia"
L["SAVE"] = "Salva"
L["NEW_SET"] = "Nuovo Set"
L["EDIT"] = "Modifica"
L["DELETE"] = "Elimina"
L["SPECIALIZATION"] = "Specializzazione"
L["NAME"] = "Nome"
L["CHOOSE_ICON"] = "Scegli Icona"
L["ENTER_NAME"] = "Inserisci Nome"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Titoli"
L["NO_TITLE"] = "Nessun Titolo"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Seleziona una fazione."
L["PARAGON_REWARDS_AVAILABLE"] = "Ricompense Paragone disponibili:"
L["REWARD"] = "Ricompensa"
L["REWARDS"] = "Ricompense"
L["REWARD_ZERO"] = "Ricompensa: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Cronologia"
L["NO_DESCRIPTION"] = "Nessuna descrizione disponibile."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Impostazioni"
L["RELOAD_REQUIRED_BODY"] = "È necessario ricaricare l'interfaccia per applicare queste modifiche.\nVuoi farlo ora?"
L["YES_RELOAD"] = "Sì (Ricarica)"
L["RESET_FONTS_BODY"] = "Attenzione, stai per ripristinare tutti i caratteri ai valori predefiniti.\n\nSei sicuro?"


L["PREVIEW_ENCHANT_NAME"] = "Incantato: Celerità dell'Ombra"
L["PREVIEW_UPGRADE_TEXT"] = "[Eroe 6/8]"
L["TITLE_PREVIEW"] = "ANTEPRIMA IN TEMPO REALE"
L["TITLE_GENERAL_DISPLAY"] = "VISUALIZZAZIONE GENERALE"

L["OPTION_SHOW_ITEM_NAMES"] = "Mostra Nomi Oggetti"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Mostra o nasconde il nome completo dell'oggetto."
L["OPTION_SCROLL_NAMES"] = "Abilita Scorrimento Nomi"
L["OPTION_SCROLL_NAMES_DESC"] = "Fa scorrere il nome dell'oggetto se è troppo lungo."
L["OPTION_SHOW_UPGRADE"] = "Mostra Livello Potenziamento"
L["OPTION_SHOW_UPGRADE_DESC"] = "Mostra il grado di potenziamento (es: Eroe 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Mostra Incantamenti"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Mostra il nome dell'incantamento."
L["OPTION_SHOW_SET_INFO"] = "Indicatore Pezzi Set"
L["OPTION_SHOW_SET_INFO_DESC"] = "Mostra il progresso del set (es: 2/4)."
L["OPTION_SHOW_MODEL"] = "Mostra Modello 3D al Passaggio"
L["OPTION_SHOW_MODEL_DESC"] = "Mostra il tuo personaggio che indossa l'oggetto al passaggio del mouse."

L["TITLE_TYPOGRAPHY"] = "TIPOGRAFIA"
L["RELOAD_REQUIRED_SHORT"] = "/reload richiesto"
L["BUTTON_APPLY_FONTS"] = "Clicca qui per applicare i caratteri"
L["BUTTON_RESET_FONTS"] = "Ripristina Caratteri"

L["FONT_ACCORDION_TITLE"] = "Titoli Fisarmonica"
L["FONT_ACCORDION_TITLE_DESC"] = "Carattere per le barre dei titoli comprimibili."
L["FONT_ITEM_NAME"] = "Nomi Oggetti"
L["FONT_ITEM_NAME_DESC"] = "Carattere per i nomi degli oggetti."
L["FONT_ITEM_LEVEL"] = "Livello Oggetto (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Carattere per il livello dell'oggetto sull'icona."
L["FONT_ENCHANTS"] = "Incantamenti"
L["FONT_ENCHANTS_DESC"] = "Carattere per incantamenti e avvisi."
L["FONT_UPGRADE"] = "Livello Potenziamento"
L["FONT_UPGRADE_DESC"] = "Carattere per il testo di potenziamento."
L["FONT_SET_BONUS"] = "Indicatore Pezzi Set"
L["FONT_SET_BONUS_DESC"] = "Carattere per il contatore del set."

L["TITLE_BEHAVIOR"] = "COMPORTAMENTO"
L["OPTION_DEFAULT_ACCORDION"] = "Menu aperto di default:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Tutto Compresso"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ALLARME: INCANTAMENTO MANCANTE"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Seleziona gli slot per mostrare |cffff2020'Non incantato'|r se non hanno un incantamento."

L["DEV_LABEL"] = "|cffffffffSvil:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Grazie a LanceDH per l'addon TextureAtlasViewer"
L["CREDITS_NEXUS"] = "Grazie a NexuswOw per lo sviluppo"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "Ripristina statistiche"
L["RESET_STATS_DESC"] = "Ripristina l'ordine delle statistiche alla configurazione predefinita."
L["MAJ_TITLE"] = "Novità - Versione %s"
L["MAJ_FEATURE_1"] = "- Drag & Drop: Trascina e rilascia le tue statistiche per riordinarle!"
L["MAJ_FEATURE_2"] = "- Salvataggio per personaggio: Ogni personaggio ora ha la propria configurazione."
L["MAJ_FEATURE_3"] = "- Correzione API iLvl"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- Correzione: Applicazione olio/incantamento su armi riparata"
L["TITLE_RESET_SECTION"] = "Ripristina impostazioni predefinite"
L["INSTRUCTION_ACCESS"] = "Accedi alla configurazione tramite il pulsante |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \no digita il comando |cff00ccff/mcp|r in chat"


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
    ["Forza"] = "forza",
    ["Agilità"] = "agil",
    ["Intelletto"] = "int",
    ["Tempra"] = "tempra",
    ["Mana"] = "mana",
    ["Armatura"] = "armat",

    -- Secondary & Tertiary
    ["Colpo Critico"] = "crit",
    ["Celerità"] = "celer",
    ["Maestria"] = "maest",
    ["Versatilità"] = "vers",
    ["Assorbimento"] = "assorb",
    ["Elusione"] = "elus",
    ["Velocità"] = "veloc",
}
