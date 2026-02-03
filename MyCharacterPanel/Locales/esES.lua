local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "esES" then return end

-- Fichier de traduction pour la langue esES
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Cargando..."
L["YES"] = "Sí"
L["NO"] = "No"
L["OK"] = "Aceptar"
L["CANCEL"] = "Cancelar"
L["CONFIRM"] = "Confirmar"
L["UNKNOWN"] = "Desconocido"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Estadísticas"
L["TITLE_M_SCORE"] = "Puntuación M+"
L["TITLE_GREAT_VAULT"] = "La Gran Cámara"
L["TITLE_ILVL"] = "Nivel de objeto"
L["PARRY_TOOLTIP_FALLBACK"] = "Aumenta tu probabilidad de parada un %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Bloquear reduce el daño recibido de un ataque un %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Mejoras"
L["NOT_ENCHANTED"] = "No encantado"
L["SOCKET_TOOLTIP"] = "Shift + Clic Derecho para engarzar"

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
L["SLOT_FINGER1"] = "Dedo 1"
L["SLOT_FINGER2"] = "Dedo 2"
L["SLOT_TRINKET1"] = "Abalorio 1"
L["SLOT_TRINKET2"] = "Abalorio 2"

L["PATTERN_ENCHANT_FIND"] = "Encantar"
L["PATTERN_RENFORT_FIND"] = "Refuerzo"
L["PATTERN_ILLUSION"] = "Ilusión"
L["PATTERN_USE"] = "Uso"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Equipamiento"
L["TEXT_CONFIRM_SAVE"] = "Guardar conjunto de equipamiento"
L["TEXT_CONFIRM_DELETE"] = "Borrar conjunto de equipamiento"
L["EQUIP"] = "Equipar"
L["SAVE"] = "Guardar"
L["NEW_SET"] = "Nuevo conjunto"
L["EDIT"] = "Editar"
L["DELETE"] = "Borrar"
L["SPECIALIZATION"] = "Especialización"
L["NAME"] = "Nombre"
L["CHOOSE_ICON"] = "Elegir icono"
L["ENTER_NAME"] = "Introduce un nombre"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Títulos"
L["NO_TITLE"] = "Sin título"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Selecciona una facción."
L["PARAGON_REWARDS_AVAILABLE"] = "Recompensas de Dechado disponibles:"
L["REWARD"] = "Recompensa"
L["REWARDS"] = "Recompensas"
L["REWARD_ZERO"] = "Recompensa: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Historial"
L["NO_DESCRIPTION"] = "No hay descripción disponible."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Configuración"
L["RELOAD_REQUIRED_BODY"] = "Es necesario recargar la interfaz para aplicar estos cambios.\n¿Quieres hacerlo ahora?"
L["YES_RELOAD"] = "Sí (Recargar)"
L["RESET_FONTS_BODY"] = "Atención, estás a punto de restablecer todas las fuentes por defecto.\n\n¿Estás seguro?"


L["PREVIEW_ENCHANT_NAME"] = "Encantar: Celeridad sombría"
L["PREVIEW_UPGRADE_TEXT"] = "[Héroe 6/8]"
L["TITLE_PREVIEW"] = "VISTA PREVIA"
L["TITLE_GENERAL_DISPLAY"] = "VISUALIZACIÓN GENERAL"

L["OPTION_SHOW_ITEM_NAMES"] = "Mostrar nombres de objetos"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Muestra u oculta el nombre completo del objeto."
L["OPTION_SCROLL_NAMES"] = "Desplazar nombres largos"
L["OPTION_SCROLL_NAMES_DESC"] = "Desplaza el nombre del objeto si es demasiado largo."
L["OPTION_SHOW_UPGRADE"] = "Mostrar nivel de mejora"
L["OPTION_SHOW_UPGRADE_DESC"] = "Muestra el rango de mejora (ej: Héroe 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Mostrar encantamientos"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Muestra el nombre del encantamiento."
L["OPTION_SHOW_SET_INFO"] = "Indicador de conjunto"
L["OPTION_SHOW_SET_INFO_DESC"] = "Muestra el progreso del conjunto (ej: 2/4)."
L["OPTION_SHOW_MODEL"] = "Mostrar modelo 3D al pasar el ratón"
L["OPTION_SHOW_MODEL_DESC"] = "Muestra a tu personaje usando el objeto al pasar el ratón."

L["TITLE_TYPOGRAPHY"] = "TIPOGRAFÍA"
L["RELOAD_REQUIRED_SHORT"] = "/reload requerido"
L["BUTTON_APPLY_FONTS"] = "Clic para aplicar fuentes"
L["BUTTON_RESET_FONTS"] = "Restaurar fuentes"

L["FONT_ACCORDION_TITLE"] = "Títulos de acordeón"
L["FONT_ACCORDION_TITLE_DESC"] = "Fuente para las barras de título plegables."
L["FONT_ITEM_NAME"] = "Nombres de objetos"
L["FONT_ITEM_NAME_DESC"] = "Fuente para los nombres de los objetos."
L["FONT_ITEM_LEVEL"] = "Nivel de objeto (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Fuente para el nivel de objeto en el icono."
L["FONT_ENCHANTS"] = "Encantamientos"
L["FONT_ENCHANTS_DESC"] = "Fuente para encantamientos y alertas."
L["FONT_UPGRADE"] = "Nivel de mejora"
L["FONT_UPGRADE_DESC"] = "Fuente para el texto de mejora."
L["FONT_SET_BONUS"] = "Indicador de conjunto"
L["FONT_SET_BONUS_DESC"] = "Fuente para el contador del conjunto."

L["TITLE_BEHAVIOR"] = "COMPORTAMIENTO"
L["OPTION_DEFAULT_ACCORDION"] = "Menú abierto por defecto:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Todo contraído"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ALERTA: HUECO NO ENCANTADO"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Selecciona las ranuras que deben mostrar |cffff2020'No encantado'|r si no tienen encantamiento."

L["DEV_LABEL"] = "|cffffffffDev:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Gracias a LanceDH por el addon TextureAtlasViewer"
L["CREDITS_NEXUS"] = "Gracias a NexuswOw por el desarrollo"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "Restablecer estadísticas"
L["RESET_STATS_DESC"] = "Restablece el orden de las estadísticas a la configuración predeterminada."
L["MAJ_TITLE"] = "Novedades - Versión %s"
L["MAJ_FEATURE_1"] = "- Drag & Drop: ¡Arrastra y suelta tus estadísticas para reordenarlas!"
L["MAJ_FEATURE_2"] = "- Guardado por personaje: Cada personaje tiene ahora su propia configuración."
L["MAJ_FEATURE_3"] = "- Corrección API iLvl"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- Corrección: Aplicación de aceite/encantamiento en armas reparada"
L["TITLE_RESET_SECTION"] = "Restaurar configuración predeterminada"
L["INSTRUCTION_ACCESS"] = "Accede a la configuración con el botón |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \no escribe |cff00ccff/mcp|r en el chat"


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
    ["Fuerza"] = "fuerza",
    ["Agilidad"] = "agil",
    ["Intelecto"] = "int",
    ["Aguante"] = "aguan",
    ["Maná"] = "mana",
    ["Armadura"] = "armad",

    -- Secondary & Tertiary
    ["Golpe crítico"] = "crit",
    ["Celeridad"] = "celer",
    ["Maestría"] = "maest",
    ["Versatilidad"] = "vers",
    ["Restitución"] = "rest",
    ["Evasión"] = "evas",
    ["Velocidad"] = "veloc",
}
