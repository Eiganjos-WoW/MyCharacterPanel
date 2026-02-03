local addonName, addon = ...
local L = addon.L

if GetLocale() ~= "koKR" then return end

-- Fichier de traduction pour la langue koKR
-- Information : La traduction a été entièrement géré par IA en dehors de la partie frFR.lua

-- ==============================================================================
-- Traduction pour Global / Partagé
-- ==============================================================================
L["LOADING"] = "불러오는 중..."
L["YES"] = "예"
L["NO"] = "아니요"
L["OK"] = "확인"
L["CANCEL"] = "취소"
L["CONFIRM"] = "확인"
L["UNKNOWN"] = "알 수 없음"

-- ==============================================================================
-- Traduction pour Mixins/Stats.lua
-- ==============================================================================
L["TITLE_ATTRIBUTES"] = "능력치"
L["TITLE_M_SCORE"] = "신화+ 점수"
L["TITLE_GREAT_VAULT"] = "위대한 금고"
L["TITLE_ILVL"] = "아이템 레벨"
L["PARRY_TOOLTIP_FALLBACK"] = "무기 막기 확률이 %.2f%%만큼 증가합니다."
L["BLOCK_TOOLTIP_FALLBACK"] = "방패 막기 시 공격으로 입는 피해가 %.2f%%만큼 감소합니다."

-- ==============================================================================
-- Traduction pour Mixins/Slot.lua
-- ==============================================================================
L["TITLE_ENHANCEMENTS"] = "강화"
L["NOT_ENCHANTED"] = "마법부여 안됨"
L["SOCKET_TOOLTIP"] = "Shift + 우클릭으로 보석 장착"

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
L["SLOT_FINGER1"] = "손가락 1"
L["SLOT_FINGER2"] = "손가락 2"
L["SLOT_TRINKET1"] = "장신구 1"
L["SLOT_TRINKET2"] = "장신구 2"

L["PATTERN_ENCHANT_FIND"] = "마법부여" -- Enchant
L["PATTERN_RENFORT_FIND"] = "보강" -- Reinforced - À vérifier
L["PATTERN_ILLUSION"] = "환영" -- Illusion
L["PATTERN_USE"] = "사용 효과" -- Use
L["PATTERN_TIER1"] = "Tier1"
L["PATTERN_TIER2"] = "Tier2"
L["PATTERN_TIER3"] = "Tier3"

-- ==============================================================================
-- Traduction pour Mixins/Equipment.lua
-- ==============================================================================
L["TITLE_EQUIPMENT"] = "장비 관리"
L["TEXT_CONFIRM_SAVE"] = "장비 세트 저장"
L["TEXT_CONFIRM_DELETE"] = "장비 세트 삭제"
L["EQUIP"] = "장착"
L["SAVE"] = "저장"
L["NEW_SET"] = "새 세트"
L["EDIT"] = "편집"
L["DELETE"] = "삭제"
L["SPECIALIZATION"] = "전문화"
L["NAME"] = "이름"
L["CHOOSE_ICON"] = "아이콘 선택"
L["ENTER_NAME"] = "이름 입력"

-- ==============================================================================
-- Traduction pour Mixins/Titles.lua
-- ==============================================================================
L["TITLE_TITLES"] = "칭호"
L["NO_TITLE"] = "칭호 없음"

-- ==============================================================================
-- Traduction pour Mixins/Reputation.lua
-- ==============================================================================
L["SELECT_FACTION"] = "평판을 선택하세요."
L["PARAGON_REWARDS_AVAILABLE"] = "동맹 보상 사용 가능:"
L["REWARD"] = "보상"
L["REWARDS"] = "보상"
L["REWARD_ZERO"] = "보상: 0"

-- ==============================================================================
-- Traduction pour Mixins/History.lua
-- ==============================================================================
L["TRANSFER_HISTORY"] = "기록"
L["NO_DESCRIPTION"] = "설명이 없습니다."

-- ==============================================================================
-- Traduction pour Config/Options.lua
-- ==============================================================================
L["SETTINGS_TITLE"] = "설정"
L["RELOAD_REQUIRED_BODY"] = "변경 사항을 적용하려면 UI를 다시 불러와야 합니다.\n지금 하시겠습니까?"
L["YES_RELOAD"] = "예 (Reload)"
L["RESET_FONTS_BODY"] = "경고: 모든 글꼴을 기본값으로 초기화하려고 합니다.\n\n확실합니까?"


L["PREVIEW_ENCHANT_NAME"] = "마법부여: 어둠의 가속"
L["PREVIEW_UPGRADE_TEXT"] = "[영웅 6/8]"
L["TITLE_PREVIEW"] = "실시간 미리보기"
L["TITLE_GENERAL_DISPLAY"] = "일반 표시"

L["OPTION_SHOW_ITEM_NAMES"] = "아이템 이름 표시"
L["OPTION_SHOW_ITEM_LEVEL"] = "Show Item Level"
L["OPTION_SHOW_ITEM_LEVEL_DESC"] = "Show or hide the item level on the icon."
L["OPTION_SHOW_ITEM_NAMES_DESC"] = "아이템의 전체 이름을 표시하거나 숨깁니다."
L["OPTION_SCROLL_NAMES"] = "이름 스크롤 활성화"
L["OPTION_SCROLL_NAMES_DESC"] = "아이템 이름이 너무 길면 스크롤합니다."
L["OPTION_SHOW_UPGRADE"] = "업그레이드 레벨 표시"
L["OPTION_SHOW_UPGRADE_DESC"] = "업그레이드 등급을 표시합니다 (예: 영웅 4/6)."
L["OPTION_SHOW_ENCHANTS"] = "마법부여 표시"
L["OPTION_SHOW_ENCHANTS_DESC"] = "마법부여 이름을 표시합니다."
L["OPTION_SHOW_SET_INFO"] = "세트 아이템 표시기"
L["OPTION_SHOW_SET_INFO_DESC"] = "세트 진행 상황을 표시합니다 (예: 2/4)."
L["OPTION_SHOW_MODEL"] = "마우스 오버 시 3D 모델 표시"
L["OPTION_SHOW_MODEL_DESC"] = "마우스 오버 시 아이템을 착용한 캐릭터를 표시합니다."

L["TITLE_TYPOGRAPHY"] = "타이포그래피"
L["RELOAD_REQUIRED_SHORT"] = "/reload 필요"
L["BUTTON_APPLY_FONTS"] = "글꼴을 적용하려면 클릭하세요"
L["BUTTON_RESET_FONTS"] = "글꼴 초기화"

L["FONT_ACCORDION_TITLE"] = "아코디언 제목"
L["FONT_ACCORDION_TITLE_DESC"] = "접을 수 있는 제목 표시줄의 글꼴입니다."
L["FONT_ITEM_NAME"] = "아이템 이름"
L["FONT_ITEM_NAME_DESC"] = "아이템 이름의 글꼴입니다."
L["FONT_ITEM_LEVEL"] = "아이템 레벨 (ILVL)"
L["FONT_ITEM_LEVEL_DESC"] = "아이콘의 아이템 레벨 글꼴입니다."
L["FONT_ENCHANTS"] = "마법부여"
L["FONT_ENCHANTS_DESC"] = "마법부여 및 경고의 글꼴입니다."
L["FONT_UPGRADE"] = "업그레이드 레벨"
L["FONT_UPGRADE_DESC"] = "업그레이드 텍스트의 글꼴입니다."
L["FONT_SET_BONUS"] = "세트 아이템 표시기"
L["FONT_SET_BONUS_DESC"] = "세트 카운터의 글꼴입니다."

L["TITLE_BEHAVIOR"] = "동작"
L["OPTION_DEFAULT_ACCORDION"] = "기본 열림 메뉴:"
L["OPTION_ACCORDION_ALL_COLLAPSED"] = "모두 접기"

L["TITLE_ALERT_MISSING_ENCHANT"] = "경고: 마법부여 누락"
L["OPTION_ALERT_MISSING_ENCHANT_DESC"] = "마법부여가 없을 때 |cffff2020'마법부여 안됨'|r을 표시할 슬롯을 선택하세요."

L["DEV_LABEL"] = "|cffffffff개발:|r |cff0070deEiganjos|r-|cffffd100Archimonde|r"
L["CREDITS_TEXTURE_ATLAS"] = "TextureAtlasViewer 애드온의 LanceDH 님께 감사드립니다"
L["CREDITS_NEXUS"] = "개발에 참여해주신 NexuswOw님께 감사드립니다"

-- ==============================================================================
-- New Features (Update) & Reset
-- ==============================================================================
L["RESET_STATS"] = "통계 초기화"
L["RESET_STATS_DESC"] = "통계 순서를 기본 구성으로 초기화합니다."
L["MAJ_TITLE"] = "새로운 기능 - 버전 %s"
L["MAJ_FEATURE_1"] = "- 드래그 앤 드롭: 통계를 드래그 앤 드롭하여 순서를 변경하세요!"
L["MAJ_FEATURE_2"] = "- 캐릭터별 저장: 이제 각 캐릭터마다 고유한 설정이 있습니다."
L["MAJ_FEATURE_3"] = "- API iLvl 수정"
L["MAJ_FEATURE_4"] = "- Zoom: Hold CTRL + Mouse Wheel to adjust interface size (50% to 150%)"
L["MAJ_FEATURE_5"] = "- 수정: 무기 오일/마법부여 적용 문제 해결"
L["TITLE_RESET_SECTION"] = "기본 설정 복원"
L["INSTRUCTION_ACCESS"] = "|TInterface\\Buttons\\UI-OptionsButton:18:18:0:-2|t 버튼을 통해 설정을 열거나 \n채팅창에 |cff00ccff/mcp|r 명령어를 입력하세요."


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
    ["힘"] = "힘",
    ["민첩"] = "민첩",
    ["지능"] = "지능",
    ["체력"] = "체력",
    ["마나"] = "마나",
    ["방어도"] = "방어도",

    -- Secondary & Tertiary
    ["치명타"] = "치명",
    ["가속"] = "가속",
    ["특화"] = "특화",
    ["유연성"] = "유연",
    ["생기 흡수"] = "생흡",
    ["광역 회피"] = "광회",
    ["이동 속도"] = "이속",
}
