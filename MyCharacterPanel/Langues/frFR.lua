-- Les textes en français pour que tout le monde comprenne

local addonName, addon = ...
if GetLocale() ~= "frFR" then return end

local L                       = addon.L or {}
addon.L                       = L

-- ============================================================================
-- GLOBAL & NOYAU (Utilisés dans plusieurs fichiers)
-- ============================================================================
L["ADDON_TITLE"]              = "MyCharacterPanel"
L["LOADING"]                  = "..."
L["COMING_SOON"]              = "Développement à venir.."
L["LEVEL_FORMAT"]             = "Niveau %s"
L["ILVL_FORMAT"]              = "ilvl : %s"
L["MYTHIC_PLUS_FORMAT"]       = "M+ : %s"
L["OPT_YES"]                  = "Oui"
L["OPT_NO"]                   = "Non"

-- ============================================================================
-- NOYAU / COEUR.LUA (Bandeau Great Vault)
-- ============================================================================
L["GREAT_VAULT"]              = "Chambre Forte"
L["REWARD_AVAILABLE"]         = "Récompense disponible !"

-- ============================================================================
-- ONGLETS / PERSONNAGE.LUA & INSPECTION.LUA
-- ============================================================================
L["NOT_ENCHANTED"]            = "Non enchanté"

-- Patterns de détection (Tooltip scanning)
L["PATTERN_UPGRADE"]          = "Niveau d'amélioration :"
L["PATTERN_UPGRADE_RAW"]      = "Niveau d'amélioration"
L["PATTERN_ENCHANT"]          = "Enchanté"
L["PATTERN_RENFORT"]          = "Renfort"
L["PATTERN_USE"]              = "Utiliser"
L["PATTERN_USE_EN"]           = "Use"
L["PATTERN_ENCHANT_SHORT"]    = "Enchant"
L["PATTERN_TRACK_EXCLUDE_1"]  = "amélioration"
L["PATTERN_TRACK_EXCLUDE_2"]  = "Level"
L["PATTERN_TRACK_EXCLUDE_3"]  = "Upgrade"

-- Formats d'affichage
L["UPGRADE_FORMAT"]           = "[%s %s]"
L["UPGRADE_FORMAT_SHORT"]     = "[%s]"

-- ============================================================================
-- ONGLETS / PAPERDOLLFRAME.LUA (Sidebar & Stats)
-- ============================================================================
L["TAB_STATS"]                = "Statistiques"
L["TAB_TITLES"]               = "Titres"
L["TAB_EQUIPMENT"]            = "Équipement"
L["STAT_MOVESPEED"]           = "Vitesse"
L["STAT_DURABILITY"]          = "Durabilité :"
L["DRAG_DROP_STATS"]          = "Vous pouvez drag & drop les statistiques (sauvegardé par personnage) !"

-- ============================================================================
-- ONGLETS / OPTIONS.LUA (Menu de configuration)
-- ============================================================================
L["OPTIONS_TITLE"]            = "Paramètres"
L["TUTORIAL_OPTIONS"]         = "Cliquez ici pour configurer l'interface de MCP."
L["OPTIONS_RELOAD_REQ"]       = "(Nécessite de taper /reload pour s'appliquer totalement)"

-- Catégories Menu Gauche
L["TAB_MENU_GENERAL"]         = "Général"
L["TAB_MENU_SETTINGS"]        = "Paramètres"
L["TAB_MENU_DISPLAY"]         = "Affichage"
L["TAB_MENU_FONTS"]           = "Polices"
L["TAB_MENU_GEMS"]            = "Gemmes"
L["TAB_MENU_TEXT_APPEARANCE"] = "Apparence du texte"
L["TAB_MENU_CHARACTER_FRAME"] = "Cadre personnage"
L["TAB_MENU_ACCORDIONS"]      = "Accordéons"

-- Section Général
L["OPT_GEN_TITLE"]            = "Général"
L["OPT_SCALE_TITLE"]          = "Échelle de la fenêtre personnage"
L["OPT_INSPECT_SCALE"]        = "Échelle de la fenêtre d'inspection"
L["OPT_DEFAULT_TAB"]          = "Onglet par défaut"
L["OPT_TAB_STATS"]            = "Statistiques (défaut)"
L["OPT_TAB_TITLES"]           = "Titres"
L["OPT_TAB_EQUIP"]            = "Gestionnaire d'équipement"
L["OPT_RESET_STATS_CONFIRM"]  = "Réinitialiser l'ordre des statistiques ?"
L["OPT_RESET_STATS"]          = "Réinitialiser l'ordre des statistiques"
L["OPT_RESET_ALL"]            = "Réinitialiser l'ensemble des options"
L["OPT_RESET_WARN"]           = "Ceci va rétablir les paramètres par défaut et recharger l'interface. Continuer ?"

-- Section Visuels & Textes
L["OPT_VIS_TITLE"]            = "Disposition et Visuels"
L["OPT_SHOW_ILVL"]            = "Afficher l'iLvl de l'objet"
L["OPT_SHOW_FLYOUT_ILVL"]     = "Afficher l'Ilvl des pièces lors du maintient de la touche |cff00ff00ALT|r"
L["OPT_SHOW_NAME"]            = "Afficher le nom de l'objet"
L["OPT_SHOW_NAME_DESC"]       = "|cffaaaaaaAfficher ou masquer les noms d'objets sur les côtés.|r"
L["OPT_SHOW_ENCHANT"]         = "Afficher les Enchantements"
L["OPT_SHOW_UPGRADE"]         = "Afficher le niveau d'Amélioration"
L["OPT_SHOW_GEMS"]            = "Afficher les Gemmes"
L["OPT_TEXT_TITLE"]           = "Textes et Police"
L["OPT_FONT_NAME"]            = "Police d'écriture"
L["OPT_FONT_NAME_DESC"]       = "Sélectionnez votre police préférée."
L["OPT_FONT_SIZE"]            = "Taille de la police"
L["OPT_MAX_LEN"]              = "Longueur des noms d'objet"
L["OPT_HOVER_SCROLL"]         = "Défilement au survol"
L["OPT_HOVER_SCROLL_SHORT"]   = "Défilement au survol"
L["OPT_HOVER_SCROLL_DESC"]    = "Fait défiler les noms trop longs lors du survol de la souris pour une lecture complète."
L["OPT_MAX_LEN_TABARD"]       = "Longueur Tabard/Chemise"
L["OPT_ENCHANT_RANK_ONLY"]    = "Format simplifié '|cff00ff00Enchanté|r' (Enchantements)"
L["OPT_ENCHANT_RANK_DESC"]    = "Affiche uniquement 'Enchanté' et le rang au lieu du nom complet de l'enchantement."
L["OPT_TIP_SCALING"]          = "Installer Lib: SharedMedia-3.0 pour davantage de police"

-- Section Apparence & Positions
L["OPT_TEXT_APPEARANCE"]      = "Apparence du texte"
L["OPT_TEXT_POSITION"]        = "Position du texte"
L["OPT_LEFT_COLUMN"]          = "Colonne de gauche :"
L["OPT_RIGHT_COLUMN"]         = "Colonne de droite :"
L["OPT_OFFSET_X"]             = "Décalage X"
L["OPT_OFFSET_Y"]             = "Décalage Y"
L["OPT_HEADER_NAME"]          = "Pseudo"
L["OPT_HEADER_LEVEL"]         = "Niveau"
L["OPT_HEADER_MYTHIC"]        = "Mythique+"

-- Section Accordéons
L["ACCORDION_SECTION_TITLES"] = "Entêtes de catégories"
L["ACCORDION_SECTION_ILVL"]   = "Niveau d'objet (iLvl)"
L["ACCORDION_SECTION_TABS"]   = "Titres d'accordéon"
L["ACCORDION_SECTION_STATS"]  = "Libellés de statistique"
L["ACCORDION_TITLE_DESC"]     = "Caractéristiques, Améliorations"
L["ACCORDION_ILVL_DESC"]      = "Le grand chiffre du niveau d'objet"
L["ACCORDION_TAB_DESC"]       = "Statistiques, Équipement, Titres"
L["ACCORDION_STAT_DESC"]      = "Intelligence, Endurance, Crit, etc."

-- Section Polices par catégorie
L["FONT_CATEGORY_ITEM"]       = "Nom de l'Objet"
L["FONT_CATEGORY_ILVL"]       = "Niveau d'Objet"
L["FONT_CATEGORY_ENCHANT"]    = "Enchantement"
L["FONT_CATEGORY_UPGRADE"]    = "Amélioration"

-- Section Gemmes
L["OPT_GEM_SIZE"]             = "Taille des gemmes"
L["OPT_GEM_DRAG_INST"]        =
"Cliquez-glissez les gemmes pour changer la position par défaut\nLa symétrie sera automatique du côté gauche de l'équipement."
L["OPT_GEM_RESET"]            = "Réinitialiser les gemmes"
L["OPT_GEM_TOOLTIP_TITLE"]    = "Gemme %d - Déplacer"
L["OPT_GEM_TOOLTIP_DESC"]     = "Maintenez le clic gauche enfoncé\npour la glisser à un autre endroit."
L["OPT_SIMULATION_TITLE"]     = "Disposition Test"

-- Section Footer / Infos
L["OPT_GEM_REPORT"]           = "Pour toutes requêtes ou bug :"
L["OPT_DEV_NOTE"]             = "Développeur: Eiganjos-Archimonde (EU)"
L["OPT_BETA_NOTE"]            = "Béta testeur: Gyeo (EU)"
L["OPT_ISSUE_URL"]            = "https://legacy.curseforge.com/wow/addons/my-character-panel-mcp/issues"
L["OPT_WAITING"]              = "En attente..."

-- Section "Non enchanté"
L["OPT_NOT_ENCHANTED_TITLE"]  = "|cffffcc00Affichage|r |cffff0000\"Non enchanté\"|r"
L["SLOT_HEAD"]                = "Tête"
L["SLOT_NECK"]                = "Cou"
L["SLOT_SHOULDER"]            = "Épaules"
L["SLOT_CHEST"]               = "Torse"
L["SLOT_WAIST"]               = "Ceinture"
L["SLOT_LEGS"]                = "Jambes"
L["SLOT_FEET"]                = "Pieds"
L["SLOT_WRIST"]               = "Poignets"
L["SLOT_HANDS"]               = "Mains"
L["SLOT_FINGER1"]             = "Bague 1"
L["SLOT_FINGER2"]             = "Bague 2"
L["SLOT_TRINKET1"]            = "Bijoux 1"
L["SLOT_TRINKET2"]            = "Bijoux 2"
L["SLOT_BACK"]                = "Dos"
L["SLOT_MAINHAND"]            = "Main droite"
L["SLOT_OFFHAND"]             = "Main gauche"

-- ============================================================================
-- DONNÉES / MAPS (Tables de correspondance)
-- ============================================================================
L.STATS_MAP                   = {
    ["Coup critique"] = "Crit",
    ["Critique"]      = "Crit",
    ["Polyvalence"]   = "Poly",
    ["Intelligence"]  = "Intel",
    ["Agilité"]       = "Agi",
    ["Endurance"]     = "Endu",
    ["Maîtrise"]      = "Maîtrise",
    ["Hâte"]          = "Hâte",
    ["Vitesse"]       = "Vitesse",
    ["Évitement"]     = "Évit",
    ["Ponction"]      = "Ponct",
    ["Force"]         = "Force",
}

L.COSMETIC_MAP                = {
    [" et %+"] = " | +",
    [" à l'"] = " ",
    [" à la "] = " ",
    [" au "] = " ",
    [" à "] = " ",
    [" de la "] = " ",
    [" de l'"] = " ",
    [" du "] = " ",
    [" des "] = " ",
    ["d'"] = "",
    ["d’"] = "",
    ["D'"] = "",
    ["D’"] = "",
    ["l'"] = "",
    ["l’"] = "",
    ["L'"] = "",
    ["L’"] = ""
}
