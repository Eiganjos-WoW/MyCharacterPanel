local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

-- Mise en cache des API

local CreateFrame = CreateFrame
local C_AddOns = C_AddOns
local C_Timer = C_Timer
local BreakUpLargeNumbers = BreakUpLargeNumbers
local C_CurrencyInfo = C_CurrencyInfo
local hooksecurefunc = hooksecurefunc

addon.CoinMixin = {}
local CoinMixin = addon.CoinMixin

-- Initialisation


function CoinMixin:OnLoad()
    self.bottomPadding = 5 
    self:SetScript("OnShow", self.OnShowAction)
    self:SetScript("OnHide", self.OnHideAction)
    self:EnableMouse(false) 
end

function CoinMixin:OnShowAction()
    if not C_AddOns.IsAddOnLoaded("Blizzard_TokenUI") then
        C_AddOns.LoadAddOn("Blizzard_TokenUI")
    end
    
    -- Masquage préventif pour éviter les scintillements

    if TokenFrame then TokenFrame:SetAlpha(0) end
    
    -- Hook de mise en page pour les boutons

    if not self.hooksInstalled and TokenFrame and TokenFrame.ScrollBox then
        self.hooksInstalled = true
        TokenFrame.ScrollBox:RegisterCallback(BaseScrollBoxEvents.OnLayout, function()
            self:RefreshCurrencyButtons()
        end, self)
    end

    if TokenFrame then 
        if TokenFrame.Update then TokenFrame:Update() end
    end

    self:SetupMyAddonElements(true)
    self:IntegrateNativeFrame()
    self:RefreshCurrencyButtons()

    -- Révélation retardée une fois l'interface prête

    C_Timer.After(0.05, function() 
        if self:IsVisible() then 
            self:IntegrateNativeFrame()
            self:RefreshCurrencyButtons()
            if TokenFrame then TokenFrame:SetAlpha(1) end -- Révélation en douceur
        end 
    end)
end

-- Intégration de l'interface native


function CoinMixin:IntegrateNativeFrame()
    if not TokenFrame then return end
    
    local mainFrame = addon.MainFrame
    if not mainFrame then return end
    
    -- Reparentage

    if TokenFrame:GetParent() ~= mainFrame then
        TokenFrame:SetParent(mainFrame)
    end
    
    -- Positionnement

    TokenFrame:ClearAllPoints()
    TokenFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    TokenFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 50, 0)
    
    -- Configuration Clics & Z-Index

    TokenFrame:SetToplevel(false)
    TokenFrame:SetFrameStrata("HIGH") -- Ajustement de la strate (HIGH) pour l'UX

    TokenFrame:SetFrameLevel(mainFrame:GetFrameLevel() + 10) -- Au-dessus du fond
    TokenFrame:EnableMouse(false) -- Laisse passer les clics vers le contenu
    
    TokenFrame:Show()
    -- Note : L'alpha est géré par le timer pour la fluidité


    -- Correctifs ScrollBox


    if TokenFrame.ScrollBox then
        TokenFrame.ScrollBox:EnableMouse(false) 
        
        if TokenFrame.ScrollBox.Shadows then TokenFrame.ScrollBox.Shadows:Hide() end
        if TokenFrame.ScrollBox.Background then TokenFrame.ScrollBox.Background:Hide() end
        
        -- Force le recalcul pour éviter l'espace vide en haut de liste
        if TokenFrame.ScrollBox.FullUpdate then
            TokenFrame.ScrollBox:FullUpdate(1)
        end
    end
    
    -- Dropdown (Filtres)

    local header = mainFrame.Header
    local dropdown = TokenFrame.FilterDropdown or TokenFrame.filterDropdown
    if dropdown and header then
        dropdown:SetParent(header)
        dropdown:ClearAllPoints()
        dropdown:SetPoint("LEFT", header, "LEFT", 10, 0)
        dropdown:Show()
        
        -- Le menu déroulant doit être au premier plan

        dropdown:SetFrameStrata("DIALOG") 
        dropdown:SetFrameLevel(500)
        -- Calcul dynamique de la largeur basée sur le contenu
        if not self.calcFontString then
            self.calcFontString = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            self.calcFontString:Hide()
        end

        local maxWidth = 180 -- Augmenter la base minimale
        
        -- 1. Vérifier le texte actuellement affiché dans le bouton
        local currentText = ""
        if dropdown.Text and dropdown.Text.GetText then 
             currentText = dropdown.Text:GetText() 
        elseif dropdown.GetText then
             currentText = dropdown:GetText()
        end
        
        if currentText and currentText ~= "" then
             self.calcFontString:SetText(currentText)
             local w = self.calcFontString:GetStringWidth()
             if w > maxWidth then maxWidth = w end
        end

        -- 2. Parcourir les en-têtes de la liste (au cas où on change de filtre)
        local listSize = C_CurrencyInfo.GetCurrencyListSize()
        for i = 1, listSize do
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if info and info.isHeader then
                 self.calcFontString:SetText(info.name)
                 local w = self.calcFontString:GetStringWidth()
                 -- On ajoute une marge pour les titres longs non sélectionnés
                 if w > maxWidth then maxWidth = w end
            end
        end
        
        local finalWidth = maxWidth + 80 -- Padding augmenté pour éviter la troncature

        if _G.UIDropDownMenu_SetWidth and not dropdown.intrinsic then
             _G.UIDropDownMenu_SetWidth(dropdown, finalWidth)
        else
             dropdown:SetWidth(finalWidth)
        end
    end
    
    -- Nettoyage

    if TokenFrame.CurrencyTransferLogToggleButton then TokenFrame.CurrencyTransferLogToggleButton:Hide() end
    if TokenFrame.TransferRecordButton then TokenFrame.TransferRecordButton:Hide() end
    
    -- ScrollBar

    local topOffset = -30
    if TokenFrame.ScrollBar then
        TokenFrame.ScrollBar:ClearAllPoints()
        TokenFrame.ScrollBar:SetPoint("TOPRIGHT", TokenFrame, "TOPRIGHT", 0, topOffset)
        TokenFrame.ScrollBar:SetPoint("BOTTOMRIGHT", TokenFrame, "BOTTOMRIGHT", 0, 5)
    end

    if TokenFrame.ScrollBox then
        TokenFrame.ScrollBox:ClearAllPoints()
        TokenFrame.ScrollBox:SetPoint("TOPLEFT", TokenFrame, "TOPLEFT", 5, topOffset)
        if TokenFrame.ScrollBar then
            TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", TokenFrame.ScrollBar, "BOTTOMLEFT", -5, 0) 
        else
            TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", TokenFrame, "BOTTOMRIGHT", -25, 5)
        end
    end
end

-- Logique métier


function CoinMixin:RefreshCurrencyButtons()
    if not TokenFrame or not TokenFrame.ScrollBox then return end
    local frames = TokenFrame.ScrollBox:GetFrames()
    if not frames then return end

    for _, button in ipairs(frames) do
        if button.elementData and not button.elementData.isHeader then
            local currencyID = button.elementData.currencyID
            if currencyID then
                local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
                if info and info.maxQuantity and info.maxQuantity > 0 then
                    local countFs = button.Content and button.Content.Count
                    if countFs then
                        local current = BreakUpLargeNumbers(info.quantity or 0)
                        local max = BreakUpLargeNumbers(info.maxQuantity)
                        countFs:SetText(current .. " / " .. max)
                    end
                end
            end
        end
    end
end

-- Gestion de l'en-tête


function CoinMixin:SetupMyAddonElements(isCoinMode)
    local main = addon.MainFrame
    if not main then return end

    if main.Header then
        main.Header:Show()
        local showStandardContent = not isCoinMode
        if main.VaultBtn then main.VaultBtn:SetShown(showStandardContent) end
        local headerElements = {"Name", "Level", "ClassIcon", "IconBorder", "SpecIcon", "SpecIconBorder", "Score", "ScoreLabel"}
        for _, key in ipairs(headerElements) do
            if main.Header[key] then main.Header[key]:SetShown(showStandardContent) end
        end

        if isCoinMode then
            if not self.CustomHistoryBtn then
                self.CustomHistoryBtn = CreateFrame("Button", nil, main.Header)
                self.CustomHistoryBtn:SetHeight(32)
                self.CustomHistoryBtn:SetPoint("RIGHT", main.Header, "RIGHT", -15, 0)
                
                self.CustomHistoryBtn:SetNormalAtlas("128-RedButton-Disable")
                self.CustomHistoryBtn:SetHighlightAtlas("loottoast-glow")
                self.CustomHistoryBtn:GetHighlightTexture():SetBlendMode("ADD")
                self.CustomHistoryBtn:GetHighlightTexture():SetAlpha(0.6)
                
                self.CustomHistoryBtn.Text = self.CustomHistoryBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                self.CustomHistoryBtn.Text:SetPoint("CENTER", 0, 1)
                self.CustomHistoryBtn.Text:SetText(L["TRANSFER_HISTORY"])
                self.CustomHistoryBtn.Text:SetTextColor(1, 1, 1) 
                
                self.CustomHistoryBtn:SetWidth(self.CustomHistoryBtn.Text:GetStringWidth() + 40)
                
                self.CustomHistoryBtn:SetScript("OnClick", function()
                    if not C_AddOns.IsAddOnLoaded("Blizzard_TokenUI") then C_AddOns.LoadAddOn("Blizzard_TokenUI") end
                    if CurrencyTransferLog then
                        CurrencyTransferLog:SetShown(not CurrencyTransferLog:IsShown())
                        if CurrencyTransferLog:IsShown() then
                            CurrencyTransferLog:ClearAllPoints()
                            CurrencyTransferLog:SetPoint("TOPLEFT", main, "TOPRIGHT", 5, 0)
                            CurrencyTransferLog:Raise()
                        end
                    end
                end)
            end
            self.CustomHistoryBtn:Show()
            self.CustomHistoryBtn:SetFrameLevel(main.Header:GetFrameLevel() + 20)
        else
            if self.CustomHistoryBtn then self.CustomHistoryBtn:Hide() end
        end
    end

    if isCoinMode then
        if main.StatsFrame then main.StatsFrame:Hide() end
        if main.EquipmentFrame then main.EquipmentFrame:Hide() end
        if main.TitlesFrame then main.TitlesFrame:Hide() end
    end
end

function CoinMixin:OnHideAction()
    if TokenFrame then 
        TokenFrame:Hide() 
        TokenFrame:SetAlpha(1) -- Reset alpha pour utilisation standard ailleurs
    end
    self:SetupMyAddonElements(false)
    local main = addon.MainFrame
    if main and main.activeTab == 1 then
        if main.isStatsOpen and main.StatsFrame then main.StatsFrame:Show() end
        if main.isEquipmentOpen and main.EquipmentFrame then main.EquipmentFrame:Show() end
        if main.isTitlesOpen and main.TitlesFrame then main.TitlesFrame:Show() end
    end
    if TokenFrame and (TokenFrame.FilterDropdown or TokenFrame.filterDropdown) then
        (TokenFrame.FilterDropdown or TokenFrame.filterDropdown):Hide()
    end
end

function CoinMixin:Update() end