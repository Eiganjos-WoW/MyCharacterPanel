local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "ruRU" then return end

-- Fichier de traduction pour la langue ruRU
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "Загрузка..."
L["YES"] = "Да"
L["NO"] = "Нет"
L["OK"] = "ОК"
L["CANCEL"] = "Отмена"
L["CONFIRM"] = "Подтвердить"
L["UNKNOWN"] = "Неизвестно"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "Характеристики"
L["TITLE_M_SCORE"] = "Рейтинг M+"
L["TITLE_GREAT_VAULT"] = "Великое хранилище"
L["TITLE_ILVL"] = "Уровень предметов"
L["PARRY_TOOLTIP_FALLBACK"] = "Увеличивает вероятность парирования на %.2f%%."
L["BLOCK_TOOLTIP_FALLBACK"] = "Блокирование снижает получаемый от атаки урон на %.2f%%."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "Усиления"
L["NOT_ENCHANTED"] = "Не зачаровано"
L["SOCKET_TOOLTIP"] = "Shift + Правый клик для вставки камня"

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
L["SLOT_FINGER1"] = "Палец 1"
L["SLOT_FINGER2"] = "Палец 2"
L["SLOT_TRINKET1"] = "Аксессуар 1"
L["SLOT_TRINKET2"] = "Аксессуар 2"

L["PATTERN_ENCHANT_FIND"] = "Чары"
L["PATTERN_RENFORT_FIND"] = "Усиление" -- À vérifier
L["PATTERN_ILLUSION"] = "Иллюзия"
L["PATTERN_USE"] = "Использование"
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "Экипировка"
L["TEXT_CONFIRM_SAVE"] = "Сохранить набор экипировки"
L["TEXT_CONFIRM_DELETE"] = "Удалить набор экипировки"
L["EQUIP"] = "Надеть"
L["SAVE"] = "Сохранить"
L["NEW_SET"] = "Новый набор"
L["EDIT"] = "Изменить"
L["DELETE"] = "Удалить"
L["SPECIALIZATION"] = "Специализация"
L["NAME"] = "Название"
L["CHOOSE_ICON"] = "Выбрать значок"
L["ENTER_NAME"] = "Введите название"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "Звания"
L["NO_TITLE"] = "Нет звания"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "Выберите фракцию."
L["PARAGON_REWARDS_AVAILABLE"] = "Доступны награды Идеала:"
L["REWARD"] = "Награда"
L["REWARDS"] = "Награды"
L["REWARD_ZERO"] = "Награда: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "История"
L["NO_DESCRIPTION"] = "Описание недоступно."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "Настройки"
L["RELOAD_REQUIRED_BODY"] = "Требуется перезагрузка интерфейса для применения изменений.\nВыполнить сейчас?"
L["YES_RELOAD"] = "Да (Reload)"
L["RESET_FONTS_BODY"] = "Внимание, вы собираетесь сбросить все шрифты по умолчанию.\n\nВы уверены?"


L["PREVIEW_ENCHANT_NAME"] = "Чары: ускорение темных теней"
L["PREVIEW_UPGRADE_TEXT"] = "[Герой 6/8]"
L["TITLE_PREVIEW"] = "ПРЕДПРОСМОТР"
L["TITLE_GENERAL_DISPLAY"] = "ОБЩЕЕ ОТОБРАЖЕНИЕ"

L["OPTION_SHOW_ITEM_NAMES"] = "Показывать названия предметов"
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "Показывает или скрывает полное название предмета."
L["OPTION_SCROLL_NAMES"] = "Прокрутка длинных названий"
L["OPTION_SCROLL_NAMES_DESC"] = "Прокручивает название предмета, если оно слишком длинное."
L["OPTION_SHOW_UPGRADE"] = "Показывать уровень улучшения"
L["OPTION_SHOW_UPGRADE_DESC"] = "Показывает ранг улучшения (например: Герой 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "Показывать зачарования"
L["OPTION_SHOW_ENCHANTS_DESC"] = "Показывает название чар."
L["OPTION_SHOW_SET_INFO"] = "Индикатор комплекта"
L["OPTION_SHOW_SET_INFO_DESC"] = "Показывает прогресс комплекта (например: 2/4)."
L["OPTION_SHOW_MODEL"] = "Показывать 3D модель при наведении"
L["OPTION_SHOW_MODEL_DESC"] = "Показывает вашего персонажа с этим предметом при наведении курсора."

L["TITLE_TYPOGRAPHY"] = "ТИПОГРАФИЯ"
L["RELOAD_REQUIRED_SHORT"] = "/reload требуется"
L["BUTTON_APPLY_FONTS"] = "Нажмите здесь, чтобы применить шрифты"
L["BUTTON_RESET_FONTS"] = "Сбросить шрифты"

L["FONT_ACCORDION_TITLE"] = "Заголовки аккордеона"
L["FONT_ACCORDION_TITLE_DESC"] = "Шрифт для сворачиваемых заголовков."
L["FONT_ITEM_NAME"] = "Названия предметов"
L["FONT_ITEM_NAME_DESC"] = "Шрифт для названий предметов."
L["FONT_ITEM_LEVEL"] = "Уровень предмета (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "Шрифт для уровня предмета на иконке."
L["FONT_ENCHANTS"] = "Зачарования"
L["FONT_ENCHANTS_DESC"] = "Шрифт для зачарований и предупреждений."
L["FONT_UPGRADE"] = "Уровень улучшения"
L["FONT_UPGRADE_DESC"] = "Шрифт для текста улучшения."
L["FONT_SET_BONUS"] = "Индикатор комплекта"
L["FONT_SET_BONUS_DESC"] = "Шрифт для счетчика комплекта."

L["TITLE_BEHAVIOR"] = "ПОВЕДЕНИЕ"
L["OPTION_DEFAULT_ACCORDION"] = "Меню открыто по умолчанию:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "Все свернуто"

L["TITLE_ALERT_MISSING_ENCHANT"] = "ТРЕВОГА: НЕТ ЧАР"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "Выберите слоты, которые должны показывать |cffff2020'Не зачаровано'|r, если на них нет чар."

L["DEV_LABEL"] = "|cffffffffDev:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "Спасибо LanceDH за аддон TextureAtlasViewer"
L["INSTRUCTION_ACCESS"] = "Доступ к настройкам через кнопку |TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t \nили введите команду |cff00ccff/mcp|r в чате"

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
    ["Сила"] = "сил",
    ["Ловкость"] = "ловк",
    ["Интеллект"] = "инт",
    ["Выносливость"] = "вын",
    ["Мана"] = "мана",
    ["Броня"] = "броня",

    -- Secondary & Tertiary
    ["Критический удар"] = "крит",
    ["Скорость"] = "скор",
    ["Искусность"] = "иск",
    ["Универсальность"] = "унив",
    ["Самоисцеление"] = "само",
    ["Избегание"] = "изб",
    ["Скорость передвижения"] = "быстр",
}
