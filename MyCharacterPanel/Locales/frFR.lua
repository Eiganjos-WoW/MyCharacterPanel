local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "frFR" then return end

-- Fichier de traduction pour la langue frFR
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Chargement..."
L["YES"] = "Oui"
L["NO"] = "Non"
L["OK"] = "OK"
L["CANCEL"] = "Annuler"
L["CONFIRM"] = "Confirmer"
L["UNKNOWN"] = "Inconnu"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Statistiques"
L["TITLE_M_SCORE"] = "Score M+"
L["TITLE_GREAT_VAULT"] = "Grande chambre forte"
L["TITLE_ILVL"] = "Niveau d'objet"
L["PARRY_TOOLTIP_FALLBACK"] = "Augmente les chances de parer de %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Bloquer réduit les dégâts subis d’une attaque de %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Améliorations"
L["NOT_ENCHANTED"] = "Non enchanté"
L["SOCKET_TOOLTIP"] = "Clic droit + Shift sur l'objet pour sertir"

L["SLOT_FINGER1"] = "Doigt 1"
L["SLOT_FINGER2"] = "Doigt 2"
L["SLOT_TRINKET1"] = "Bijou 1"
L["SLOT_TRINKET2"] = "Bijou 2"
L["SLOT_HEAD"] = "Tête"
L["SLOT_NECK"] = "Cou"
L["SLOT_SHOULDER"] = "Épaules"
L["SLOT_BACK"] = "Dos"
L["SLOT_CHEST"] = "Torse"
L["SLOT_SHIRT"] = "Chemise"
L["SLOT_TABARD"] = "Tabard"
L["SLOT_WRIST"] = "Poignets"
L["SLOT_HAND"] = "Mains"
L["SLOT_WAIST"] = "Taille"
L["SLOT_LEGS"] = "Jambes"
L["SLOT_FEET"] = "Pieds"
L["SLOT_MAINHAND"] = "Main principale"
L["SLOT_OFFHAND"] = "Main gauche"

L["PATTERN_ENCHANT_FIND"] = "Enchant"
L["PATTERN_RENFORT_FIND"] = "Renfort"
L["PATTERN_ILLUSION"] = "Illusion"
L["PATTERN_USE"] = "Utiliser"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Équipement"
L["TEXT_CONFIRM_SAVE"] = "Sauvegarder l'ensemble d'équipement"
L["TEXT_CONFIRM_DELETE"] = "Supprimer l'ensemble d'équipement"
L["EQUIP"] = "Équiper"
L["SAVE"] = "Sauver"
L["NEW_SET"] = "Nouvel ensemble"
L["EDIT"] = "Éditer"
L["DELETE"] = "Supprimer"
L["SPECIALIZATION"] = "Spécialisation"
L["NAME"] = "Nom"
L["CHOOSE_ICON"] = "Choisir une icône"
L["ENTER_NAME"] = "Entrer un nom"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Titres"
L["NO_TITLE"] = "Sans titre"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Sélectionnez une faction."
L["PARAGON_REWARDS_AVAILABLE"] = "Récompenses Parangon disponibles :"
L["REWARD"] = "Récompense"
L["REWARDS"] = "Récompenses"
L["REWARD_ZERO"] = "Récompense : 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Historique des transferts"
L["NO_DESCRIPTION"] = "Pas de description disponible."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Paramètres"
L["RELOAD_REQUIRED_BODY"] = "Un rechargement de l'interface est nécessaire pour appliquer ces changements.\nVoulez-vous le faire maintenant ?"
L["YES_RELOAD"] = "Oui (Reload)"
L["RESET_FONTS_BODY"] = "Attention, vous êtes sur le point de réinitialiser toutes les polices par défaut.\n\nÊtes-vous sûr ?"


L["PREVIEW_ENCHANT_NAME"] = "Hâte de pénombre"
L["PREVIEW_UPGRADE_TEXT"] = "[Héros 6/8]"
L["TITLE_PREVIEW"] = "APERÇU EN TEMPS RÉEL"
L["TITLE_GENERAL_DISPLAY"] = "AFFICHAGE GÉNÉRAL"

L["OPTION_SHOW_ITEM_NAMES"] = "Afficher le nom des objets"
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Affiche ou masque le nom complet de l'objet."
L["OPTION_SCROLL_NAMES"] = "Activer le défilement des noms"
L["OPTION_SCROLL_NAMES_DESC"] = "Fait défiler le nom de l'objet s'il est trop long."
L["OPTION_SHOW_UPGRADE"] = "Afficher le niveau d'amélioration"
L["OPTION_SHOW_UPGRADE_DESC"] = "Affiche le rang d'amélioration (ex: Héros 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Afficher les enchantements"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Affiche le nom de l'enchantement."
L["OPTION_SHOW_SET_INFO"] = "Indicateur pièce de set"
L["OPTION_SHOW_SET_INFO_DESC"] = "Affiche la progression du set (ex: 2/4)."
L["OPTION_SHOW_MODEL"] = "Afficher l'aperçu 3D au survol"
L["OPTION_SHOW_MODEL_DESC"] = "Affiche votre personnage portant l'objet au survol."

L["TITLE_TYPOGRAPHY"] = "TYPOGRAPHIE"
L["RELOAD_REQUIRED_SHORT"] = "/reload requis"
L["BUTTON_APPLY_FONTS"] = "Cliquez ici pour appliquer vos polices"
L["BUTTON_RESET_FONTS"] = "Restaurer les polices"

L["FONT_ACCORDION_TITLE"] = "Titres des Accordéons"
L["FONT_ACCORDION_TITLE_DESC"] = "Police des barres de titre repliables."
L["FONT_ITEM_NAME"] = "Nom des objets"
L["FONT_ITEM_NAME_DESC"] = "Police des noms d'objets."
L["FONT_ITEM_LEVEL"] = "Niveau d'objet (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Police du niveau d'objet sur l'icône."
L["FONT_ENCHANTS"] = "Enchantements"
L["FONT_ENCHANTS_DESC"] = "Police des enchantements et alertes."
L["FONT_UPGRADE"] = "Niveau d'amélioration"
L["FONT_UPGRADE_DESC"] = "Police du texte d'amélioration."
L["FONT_SET_BONUS"] = "Indicateur pièce de set"
L["FONT_SET_BONUS_DESC"] = "Police du compteur de set."

L["TITLE_BEHAVIOR"] = "COMPORTEMENT"
L["OPTION_DEFAULT_ACCORDION"] = "Menu ouvert par défaut :"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Tout replié"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ALERTE : SLOT NON ENCHANTÉ"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Sélectionnez les emplacements devant afficher |cffff2020'Non enchanté'|r s'ils ne possèdent pas d'enchantement."

L["DEV_LABEL"] = "|cffffffffDev :|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Remerciements à LanceDH pour l'addon TextureAtlasViewer"
L["INSTRUCTION_ACCESS"] = "Accédez à la configuration via le bouton |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \nou saisissez la commande |cff00ccff/mcp|r dans le chat"

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
    ["Coup critique"] = "crit",
    ["Critique"] = "crit",
    ["Polyvalence"] = "poly",
    ["Intelligence"] = "intel",
    ["Force"] = "force",
    ["Agilité"] = "agi",
    ["Endurance"] = "endu",
    ["Mana"] = "mana",
    ["Armure"] = "armure",
    ["Hâte"] = "hâte",
    ["Maîtrise"] = "maît",
    ["Ponction"] = "ponction",
    ["Évitement"] = "évitement",
    ["Vitesse"] = "vitesse",
}