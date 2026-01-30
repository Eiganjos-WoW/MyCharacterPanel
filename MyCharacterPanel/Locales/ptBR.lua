local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "ptBR" then return end

-- Fichier de traduction pour la langue ptBR
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Carregando..."
L["YES"] = "Sim"
L["NO"] = "Não"
L["OK"] = "OK"
L["CANCEL"] = "Cancelar"
L["CONFIRM"] = "Confirmar"
L["UNKNOWN"] = "Desconhecido"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Atributos"
L["TITLE_M_SCORE"] = "Pontuação de Mítica+"
L["TITLE_GREAT_VAULT"] = "O Grande Cofre"
L["TITLE_ILVL"] = "Nível de Item"
L["PARRY_TOOLTIP_FALLBACK"] = "Aumenta sua chance de aparar em %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Bloquear reduz o dano que você recebe em %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Melhorias"
L["NOT_ENCHANTED"] = "Não Encantado"
L["SOCKET_TOOLTIP"] = "Shift + Clique Direito para engastar"

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
L["SLOT_TRINKET1"] = "Berloque 1"
L["SLOT_TRINKET2"] = "Berloque 2"

L["PATTERN_ENCHANT_FIND"] = "Encantamento"
L["PATTERN_RENFORT_FIND"] = "Reforço"
L["PATTERN_ILLUSION"] = "Ilusão"
L["PATTERN_USE"] = "Uso"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Equipamento"
L["TEXT_CONFIRM_SAVE"] = "Salvar Conjunto de Equipamento"
L["TEXT_CONFIRM_DELETE"] = "Excluir Conjunto de Equipamento"
L["EQUIP"] = "Equipar"
L["SAVE"] = "Salvar"
L["NEW_SET"] = "Novo Conjunto"
L["EDIT"] = "Editar"
L["DELETE"] = "Excluir"
L["SPECIALIZATION"] = "Especialização"
L["NAME"] = "Nome"
L["CHOOSE_ICON"] = "Escolher Ícone"
L["ENTER_NAME"] = "Inserir Nome"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Títulos"
L["NO_TITLE"] = "Sem Título"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Selecione uma facção."
L["PARAGON_REWARDS_AVAILABLE"] = "Recompensas de Paragon disponíveis:"
L["REWARD"] = "Recompensa"
L["REWARDS"] = "Recompensas"
L["REWARD_ZERO"] = "Recompensa: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "Histórico"
L["NO_DESCRIPTION"] = "Nenhuma descrição disponível."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Configurações"
L["RELOAD_REQUIRED_BODY"] = "Um recarregamento da interface é necessário para aplicar essas alterações.\nDeseja fazer isso agora?"
L["YES_RELOAD"] = "Sim (Recarregar)"
L["RESET_FONTS_BODY"] = "Aviso, você está prestes a redefinir todas as fontes para o padrão.\n\nTem certeza?"


L["PREVIEW_ENCHANT_NAME"] = "Encantado: Aceleração Sombria"
L["PREVIEW_UPGRADE_TEXT"] = "[Herói 6/8]"
L["TITLE_PREVIEW"] = "PRÉ-VISUALIZAÇÃO EM TEMPO REAL"
L["TITLE_GENERAL_DISPLAY"] = "EXIBIÇÃO GERAL"

L["OPTION_SHOW_ITEM_NAMES"] = "Mostrar Nomes dos Itens"
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Mostra ou oculta o nome completo do item."
L["OPTION_SCROLL_NAMES"] = "Habilitar Rolagem de Nomes"
L["OPTION_SCROLL_NAMES_DESC"] = "Rola o nome do item se for muito longo."
L["OPTION_SHOW_UPGRADE"] = "Mostrar Nível de Melhoria"
L["OPTION_SHOW_UPGRADE_DESC"] = "Mostra a classificação de melhoria (ex: Herói 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Mostrar Encantamentos"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Mostra o nome do encantamento."
L["OPTION_SHOW_SET_INFO"] = "Indicador de Peça de Conjunto"
L["OPTION_SHOW_SET_INFO_DESC"] = "Mostra a progressão do conjunto (ex: 2/4)."
L["OPTION_SHOW_MODEL"] = "Mostrar Modelo 3D ao Passar o Mouse"
L["OPTION_SHOW_MODEL_DESC"] = "Mostra seu personagem usando o item ao passar o mouse."

L["TITLE_TYPOGRAPHY"] = "TIPOGRAFIA"
L["RELOAD_REQUIRED_SHORT"] = "/reload necessário"
L["BUTTON_APPLY_FONTS"] = "Clique aqui para aplicar suas fontes"
L["BUTTON_RESET_FONTS"] = "Redefinir Fontes"

L["FONT_ACCORDION_TITLE"] = "Títulos Acordeão"
L["FONT_ACCORDION_TITLE_DESC"] = "Fonte para barras de título recolhíveis."
L["FONT_ITEM_NAME"] = "Nomes dos Itens"
L["FONT_ITEM_NAME_DESC"] = "Fonte para nomes de itens."
L["FONT_ITEM_LEVEL"] = "Nível de Item (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Fonte para o nível do item no ícone."
L["FONT_ENCHANTS"] = "Encantamentos"
L["FONT_ENCHANTS_DESC"] = "Fonte para encantamentos e alertas."
L["FONT_UPGRADE"] = "Nível de Melhoria"
L["FONT_UPGRADE_DESC"] = "Fonte para o texto de melhoria."
L["FONT_SET_BONUS"] = "Indicador de Peça de Conjunto"
L["FONT_SET_BONUS_DESC"] = "Fonte para o contador de conjunto."

L["TITLE_BEHAVIOR"] = "COMPORTAMENTO"
L["OPTION_DEFAULT_ACCORDION"] = "Menu Aberto Padrão:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Tudo Recolhido"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ALERTA: ENCANTAMENTO AUSENTE"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Selecione os slots para exibir |cffff2020'Não Encantado'|r se não tiverem encantamento."

L["DEV_LABEL"] = "|cffffffffDev:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Obrigado a LanceDH pelo addon TextureAtlasViewer"
L["INSTRUCTION_ACCESS"] = "Acesse a configuração via o botão |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \nou digite o comando |cff00ccff/mcp|r no chat"

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
    ["Força"] = "força",
    ["Agilidade"] = "agil",
    ["Intelecto"] = "int",
    ["Vigor"] = "vigor",
    ["Mana"] = "mana",
    ["Armadura"] = "armad",

    -- Secondary & Tertiary
    ["Acerto Crítico"] = "crit",
    ["Aceleração"] = "acel",
    ["Maestria"] = "maest",
    ["Versatilidade"] = "vers",
    ["Sorver"] = "sorver",
    ["Evasiva"] = "evas",
    ["Velocidade"] = "veloc",
}
