local addonName, addon = ...
local C = addon.Consts
local L = addon.L
local Settings = Settings -- API 11.0+

local CreateFrame, UIParent, Mixin = CreateFrame, UIParent, Mixin
local hooksecurefunc = hooksecurefunc
local CharacterFrame = CharacterFrame
local HideUIPanel = HideUIPanel

-- Fonction pour masquer les éléments natifs (définie en premier pour être accessible partout)
local function HideNativeElements()
    local elementsToKill = {
        "CharacterFramePortrait", "CharacterFrameTitleText", "CharacterFrameBg",
        "CharacterFrameInset", "CharacterFrameCloseButton",
        "CharacterFrameTab1", "CharacterFrameTab2", "CharacterFrameTab3",
        "CharacterModelFrame",
    }
    
    for _, name in ipairs(elementsToKill) do
        local frame = _G[name]
        if frame then 
            frame:Hide(); frame:SetAlpha(0)
            if frame.EnableMouse then frame:EnableMouse(false) end 
        end
    end

    local framesToGhost = {PaperDollFrame, TokenFrame, ReputationFrame}
    for _, frame in ipairs(framesToGhost) do
        if frame then
            frame:SetAlpha(0)
            frame:EnableMouse(false)
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", 10000, 0)
        end
    end

    if CharacterFrame.NineSlice then CharacterFrame.NineSlice:Hide() end
    if CharacterFrame.TopTileStreaks then CharacterFrame.TopTileStreaks:Hide() end
    if CharacterFrame.Background then CharacterFrame.Background:Hide() end

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

-- Fonction d'initialisation différée
local function InitializeMainFrame()
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
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("|cffaaaaaa" .. (L["ZOOM_HINT"] or "CTRL + Scroll to zoom") .. "|r", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    f.SettingsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    CharacterFrame:SetAttribute("UIPanelLayout-width", 680)
    
    -- Fonctionnalité de zoom avec CTRL+Scroll
    f.scale = 1.0 -- Échelle par défaut (100%)
    f.baseWidth = 680
    f.baseHeight = 700
    
    -- Charger l'échelle sauvegardée
    if not MyCharacterPanelDB then MyCharacterPanelDB = {} end
    if MyCharacterPanelDB.scale then
        f.scale = MyCharacterPanelDB.scale
        f:SetScale(f.scale)
    end
    
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(self, delta)
        -- Vérifier si le zoom est verrouillé
        if MyCharacterPanelDB.lockZoom then
            return
        end
        
        if IsControlKeyDown() then
            local oldScale = self.scale
            
            -- Ajuster l'échelle (min 0.5 = 50%, max 1.5 = 150%)
            if delta > 0 then
                self.scale = math.min(self.scale + 0.05, 1.5)
            else
                self.scale = math.max(self.scale - 0.05, 0.5)
            end
            
            -- Appliquer la nouvelle échelle
            if self.scale ~= oldScale then
                self:SetScale(self.scale)
                
                -- Sauvegarder
                MyCharacterPanelDB.scale = self.scale
                
                -- Son de confirmation
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            end
        end
    end)
    
    -- Setup hooks
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
    
    return f
end



local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize main frame
        local f = InitializeMainFrame()
        
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
SlashCmdList["MYCHARPANEL"] = function(msg) 
    if addon.Options and addon.Options.Toggle then addon.Options:Toggle() end
end