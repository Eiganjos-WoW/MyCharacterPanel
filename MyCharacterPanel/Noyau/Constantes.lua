-- Toutes les variables fixes de l'addon
if C_AddOns and C_AddOns.LoadAddOn then
    C_AddOns.LoadAddOn("LibSharedMedia-3.0")
    C_AddOns.LoadAddOn("SharedMedia")
end

local _, addon              = ...
addon.CONST                 = {}
addon.Config                = _G["MCP_Config"] or {} -- On prépare la référence globale via indexation dynamique

-- Les tailles de la fenêtre
addon.CONST.MAIN_WIDTH      = 700
addon.CONST.TABS_WIDTH      = 600
addon.CONST.STATS_WIDTH     = 250
addon.CONST.TOTAL_WIDTH     = addon.CONST.MAIN_WIDTH + addon.CONST.STATS_WIDTH + 40
addon.CONST.HEIGHT          = 700

-- Les réglages pour les objets
addon.CONST.SLOT_START_Y    = -90
addon.CONST.SLOT_STEP_Y     = 64
addon.CONST.DEFAULT_WIDTH   = 338
addon.CONST.DEFAULT_HEIGHT  = 424

-- Les images par défaut
addon.CONST.BAR_ATLAS       = "128-RedButton-Disable"
addon.CONST.MASK_TEXTURE    = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

-- Liste des emplacements d'objets à gauche
addon.CONST.LEFT_SLOTS      = {
    "CharacterHeadSlot", "CharacterNeckSlot", "CharacterShoulderSlot",
    "CharacterBackSlot", "CharacterChestSlot", "CharacterShirtSlot",
    "CharacterTabardSlot", "CharacterWristSlot"
}

-- Liste des emplacements d'objets à droite
addon.CONST.RIGHT_SLOTS     = {
    "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot",
    "CharacterFeetSlot", "CharacterFinger0Slot", "CharacterFinger1Slot",
    "CharacterTrinket0Slot", "CharacterTrinket1Slot"
}
