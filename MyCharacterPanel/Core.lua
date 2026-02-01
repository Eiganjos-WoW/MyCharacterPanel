local addonName, addon = ...
local C = addon.Consts
local L = addon.L
local Settings = Settings -- API 11.0+

local CreateFrame, UIParent, Mixin = CreateFrame, UIParent, Mixin
local hooksecurefunc = hooksecurefunc
local CharacterFrame = CharacterFrame
local HideUIPanel = HideUIPanel



local f = CreateFrame("Frame", "MyCharacterPanelFrame", CharacterFrame, "BackdropTemplate")
addon.MainFrame = f 

if addon.MainFrameMixin then
    Mixin(f, addon.MainFrameMixin)
end

f:SetSize(680, 700) 
f:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 30, 40)
f:SetFrameStrata("HIGH") -- On passe en HIGH pour être sûr de passer au dessus
f:SetFrameLevel(900) -- Niveau arbitrairement haut
f:EnableMouse(true) 

f:SetBackdrop({
    bgFile = nil, 
    edgeFile = C.BORDER_TEXTURE, 
    tile = true, tileSize = 256, edgeSize = 28, 
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
f:SetBackdropColor(1, 1, 1, 1) 
f:SetBackdropBorderColor(1, 1, 1, 1) 

f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.CloseButton:SetPoint("TOPRIGHT", -5, -5)
f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 100) 
f.CloseButton:SetScript("OnClick", function() 
    HideUIPanel(CharacterFrame) 
end)

-- Bouton d'accès aux options

f.SettingsBtn = CreateFrame("Button", nil, f)
f.SettingsBtn:SetSize(18, 18) 
f.SettingsBtn:SetPoint("BOTTOMRIGHT", -8, 28)

f.SettingsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
f.SettingsBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
f.SettingsBtn:GetHighlightTexture():SetBlendMode("ADD")
f.SettingsBtn:SetFrameLevel(f:GetFrameLevel() + 200)

f.SettingsBtn:SetScript("OnClick", function()
    if addon.Options and addon.Options.Toggle then
        addon.Options:Toggle()
    end
end)

f.SettingsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["SETTINGS_TITLE"])
    GameTooltip:Show()
end)
f.SettingsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

CharacterFrame:SetAttribute("UIPanelLayout-width", 680)



local function HideNativeElements()
    local elementsToKill = {
        "CharacterFramePortrait", "CharacterFrameTitleText", "CharacterFrameBg",
        "CharacterFrameInset", "CharacterFrameCloseButton",
        "CharacterFrameTab1", "CharacterFrameTab2", "CharacterFrameTab3",
        -- "PaperDollFrame",
        "CharacterModelFrame",
    }
    
    for _, name in ipairs(elementsToKill) do
        local frame = _G[name]
        if frame then 
            frame:Hide(); frame:SetAlpha(0)
            if frame.EnableMouse then frame:EnableMouse(false) end 
        end
    end

    -- Gestion de la fermeture pour garantir la cohérence de l'UI

    local framesToGhost = {PaperDollFrame, TokenFrame, ReputationFrame}
    for _, frame in ipairs(framesToGhost) do
        if frame then
            frame:SetAlpha(0)
            frame:EnableMouse(false)
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", 10000, 0) -- On les envoie très loin
        end
    end

    if CharacterFrame.NineSlice then CharacterFrame.NineSlice:Hide() end
    if CharacterFrame.TopTileStreaks then CharacterFrame.TopTileStreaks:Hide() end
    if CharacterFrame.Background then CharacterFrame.Background:Hide() end

    -- Désactivation explicite des slots natifs (qui bloquent la colonne de gauche)
    local nativeSlots = {
        "CharacterHeadSlot", "CharacterNeckSlot", "CharacterShoulderSlot", "CharacterBackSlot", "CharacterChestSlot",
        "CharacterShirtSlot", "CharacterTabardSlot", "CharacterWristSlot", 
        "CharacterHandsSlot", "CharacterWaistSlot", "CharacterLegsSlot", "CharacterFeetSlot",
        "CharacterFinger0Slot", "CharacterFinger1Slot", "CharacterTrinket0Slot", "CharacterTrinket1Slot",
        "CharacterMainHandSlot", "CharacterSecondaryHandSlot"
    }

    for _, name in ipairs(nativeSlots) do
        local button = _G[name]
        if button then
            button:Hide()
            button:SetAlpha(0)
            if button.EnableMouse then button:EnableMouse(false) end
        end
    end
end

CharacterFrame:HookScript("OnShow", function()
    HideNativeElements()
    f:Show()
end)

hooksecurefunc("ToggleCharacter", function(frameType)
    local targetTab = 1 
    if frameType == "ReputationFrame" then targetTab = 3
    elseif frameType == "TokenFrame" then targetTab = 2 end
    if f.SelectTab then f:SelectTab(targetTab) end
    
    -- Synchronisation de la visibilité des éléments natifs

    HideNativeElements() 
end)



local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if addon.Options and addon.Options.InitDB then
            addon.Options:InitDB()
        end

        if not MyCharacterPanelDB.favorites then MyCharacterPanelDB.favorites = {} end
        if MyCharacterPanelDB.CoinApologySeen == nil then MyCharacterPanelDB.CoinApologySeen = false end
        addon.CoinApologySeen = MyCharacterPanelDB.CoinApologySeen

        if f.OnLoad then f:OnLoad() end
        HideNativeElements()
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGOUT" then
        if addon.CoinApologySeen ~= nil then
            MyCharacterPanelDB.CoinApologySeen = addon.CoinApologySeen
        end
    end
end)

SLASH_MYCHARPANEL1 = "/mcp"
SlashCmdList["MYCHARPANEL"] = function() 
    if addon.Options and addon.Options.Toggle then addon.Options:Toggle() end
end