local ADDON, addon = ...
local L      = addon.L
local C      = addon.Consts
local Utils  = addon.Utils

-- Mise en cache des API

local CreateFrame = CreateFrame
local C_Timer = C_Timer
local C_Reputation = C_Reputation
local hooksecurefunc = hooksecurefunc

addon.ReputationMixin = {}
local Reputation = addon.ReputationMixin

Reputation.TAB_ICON = ("Interface\\AddOns\\%s\\Utils\\logo\\reputation.png"):format(ADDON)

-- Fonctions de recherche (Scan hybride)


local function CleanStr(str)
    if not str then return "" end
    return str:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("[^%w]", ""):lower()
end

local function GetFactionDataByString(textStr)
    if not textStr or textStr == "" or string.len(textStr) < 3 then return nil end
    local searchKey = CleanStr(textStr)
    local num = C_Reputation.GetNumFactions()
    for i = 1, num do
        local data = C_Reputation.GetFactionDataByIndex(i)
        if data and data.name and CleanStr(data.name) == searchKey then
            return data
        end
    end
    return nil
end

local function FindCurrentFactionData()
    -- Scanner de texte affiché (Fiable)


    if ReputationFrame and ReputationFrame.ReputationDetailFrame then
        local regions = {ReputationFrame.ReputationDetailFrame:GetRegions()}
        for _, region in ipairs(regions) do
            if region:IsObjectType("FontString") and region:IsShown() then
                local text = region:GetText()
                local data = GetFactionDataByString(text)
                if data then return data end
            end
        end
    end
    
    -- Scanner visuel de boutons (Rapide)


    if ReputationFrame and ReputationFrame.ScrollBox then
        for _, button in ipairs(ReputationFrame.ScrollBox:GetFrames()) do
            local isSelected = (button.SelectedTexture and button.SelectedTexture:IsShown())
                            or (button.Selected and button.Selected:IsShown())
            if isSelected and button.elementData then
                local d = button.elementData
                if type(d) == "number" then return C_Reputation.GetFactionDataByIndex(d)
                elseif type(d) == "table" then 
                    return d.index and C_Reputation.GetFactionDataByIndex(d.index) or d 
                end
            end
        end
    end
    return nil
end

-- Cadre de description


function Reputation:CreateDescriptionFrame(parent)
    if self.CustomDesc then return end
    
    local f = CreateFrame("Frame", nil, parent)
    
    -- Positionnement (Titre et Boutons)

    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -45)
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 100) 
    
    f:SetFrameLevel(parent:GetFrameLevel() + 50)
    
    f.Scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    f.Scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f.Scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -26, 0)
    
    local content = CreateFrame("Frame", nil, f.Scroll)
    content:SetSize(f.Scroll:GetWidth(), 200)
    f.Scroll:SetScrollChild(content)
    
    f.Text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft")
    f.Text:SetPoint("TOPLEFT", content, "TOPLEFT", 5, 0)
    f.Text:SetWidth(f.Scroll:GetWidth() - 10)
    f.Text:SetJustifyH("LEFT")
    f.Text:SetJustifyV("TOP")
    f.Text:SetTextColor(1, 1, 1)
    
    self.CustomDesc = f
end

function Reputation:RefreshDescription()
    local detailFrame = ReputationFrame and ReputationFrame.ReputationDetailFrame
    if not detailFrame or not detailFrame:IsShown() then return end

    if detailFrame.Description then detailFrame.Description:SetAlpha(0) end
    if detailFrame.ScrollingDescription then detailFrame.ScrollingDescription:SetAlpha(0) end
    
    local data = FindCurrentFactionData()
    
    if self.CustomDesc then
        self.CustomDesc:Show()
        
        local textToDisplay = ""
        if data then
            textToDisplay = data.description
            if not textToDisplay or textToDisplay == "" then 
                textToDisplay = L["NO_DESCRIPTION"]
            end
        else
            textToDisplay = L["SELECT_FACTION"]
        end
        
        self.CustomDesc.Text:SetText(textToDisplay)
        
        local h = self.CustomDesc.Text:GetStringHeight()
        self.CustomDesc.Scroll:GetScrollChild():SetHeight(h + 20)
        
        local currentName = data and data.name or "NIL"
        if addon.LastLoreName ~= currentName then
            self.CustomDesc.Scroll:SetVerticalScroll(0)
            addon.LastLoreName = currentName
        end
    end
end

function Reputation:FixParagonLayers()
    if not ReputationFrame or not ReputationFrame.ScrollBox then return end
    
    local frames = ReputationFrame.ScrollBox:GetFrames()
    if not frames then return end
    
    for _, frame in ipairs(frames) do
        local content = frame.Content
        if content then
             -- Fix pour l'icône Parangon native
             if content.ParagonIcon then
                  if content.ParagonIcon.SetFrameLevel then
                        -- Forcer un niveau très élevé par rapport au parent
                        content.ParagonIcon:SetFrameLevel(content:GetFrameLevel() + 50)
                  end
                  if content.ParagonIcon.SetDrawLayer then
                        content.ParagonIcon:SetDrawLayer("OVERLAY", 7)
                  end
             end
             
             -- Parfois l'icone est directe
             if frame.ParagonIcon then
                  if frame.ParagonIcon.SetFrameLevel then
                        frame.ParagonIcon:SetFrameLevel(frame:GetFrameLevel() + 50)
                  end
                  if frame.ParagonIcon.SetDrawLayer then
                        frame.ParagonIcon:SetDrawLayer("OVERLAY", 7)
                  end
             end
        end
    end
end

-- Initialisation


function Reputation:OnLoad()
    self.bottomPadding = 5 
    self:SetScript("OnShow", self.OnShowAction)
    self:SetScript("OnHide", self.OnHideAction)
    self:EnableMouse(false)
end

function Reputation:OnShowAction()
    if ReputationFrame then ReputationFrame:SetAlpha(0) end
    
    local detailFrame = ReputationFrame and ReputationFrame.ReputationDetailFrame
    
    if detailFrame then
        if not self.detailsHooked then
            self.detailsHooked = true
            detailFrame:HookScript("OnShow", function(f)
                f:SetFrameStrata("DIALOG") 
                f:SetFrameLevel(800)
                self:CreateDescriptionFrame(f)
                self:RefreshDescription()
            end)
        end
        if detailFrame:IsShown() then
            self:CreateDescriptionFrame(detailFrame)
            self:RefreshDescription()
        end
    end
    
    if not self.hooksInstalled and ReputationFrame then
        self.hooksInstalled = true
        
        if ReputationFrame.Update then
            hooksecurefunc(ReputationFrame, "Update", function()
                 self:UpdateHeaderInfo()
                 C_Timer.After(0.01, function() 
                    self:RefreshDescription() 
                    self:FixParagonLayers()
                 end)
            end)
        end
        
        if ReputationFrame.ScrollBox then
            ReputationFrame.ScrollBox:HookScript("OnMouseUp", function()
                C_Timer.After(0.01, function() self:RefreshDescription() end)
            end)
            
            if not self.fastTicker then
                self.fastTicker = C_Timer.NewTicker(0.1, function()
                    if self:IsVisible() and detailFrame:IsShown() then
                        self:RefreshDescription()
                    end
                    if self:IsVisible() then self:FixParagonLayers() end
                end)
            end
        end
    end
    
    if ReputationFrame and ReputationFrame.Update then ReputationFrame:Update() end

    self:SetupMyAddonElements(true)
    self:IntegrateNativeFrame()
    self:UpdateHeaderInfo() 

    if detailFrame then detailFrame:Hide() end

    C_Timer.After(0.1, function() 
        if self:IsVisible() then 
            self:IntegrateNativeFrame()
            self:UpdateHeaderInfo()
            if ReputationFrame then ReputationFrame:SetAlpha(1) end
            if ReputationFrame.ReputationDetailFrame then 
                ReputationFrame.ReputationDetailFrame:Hide() 
            end
        end 
    end)
end

function Reputation:OnHideAction()
    if self.fastTicker then self.fastTicker:Cancel(); self.fastTicker = nil end
    if ReputationFrame then 
        ReputationFrame:Hide() 
        ReputationFrame:SetAlpha(1)
    end
    if ReputationFrame and ReputationFrame.filterDropdown then ReputationFrame.filterDropdown:Hide() end
    self:SetupMyAddonElements(false)
    local main = addon.MainFrame
    if main and main.activeTab == 1 then
        if main.isStatsOpen and main.StatsFrame then main.StatsFrame:Show() end
        if main.isEquipmentOpen and main.EquipmentFrame then main.EquipmentFrame:Show() end
        if main.isTitlesOpen and main.TitlesFrame then main.TitlesFrame:Show() end
    end
end

-- Intégration de l'interface native

function Reputation:IntegrateNativeFrame()
    if not ReputationFrame then return end
    local mainFrame = addon.MainFrame
    if not mainFrame then return end

    if ReputationFrame:GetParent() ~= mainFrame then
        ReputationFrame:SetParent(mainFrame)
    end

    ReputationFrame:ClearAllPoints()
    ReputationFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 50, 0)
    
    ReputationFrame:SetToplevel(false)
    ReputationFrame:SetFrameStrata("HIGH") 
    ReputationFrame:SetFrameLevel(mainFrame:GetFrameLevel() + 10)
    ReputationFrame:EnableMouse(false) 
    ReputationFrame:Show() 
    
    if ReputationFrame.ScrollBox then
        ReputationFrame.ScrollBox:EnableMouse(false)
        if ReputationFrame.ScrollBox.Shadows then ReputationFrame.ScrollBox.Shadows:Hide() end
        if ReputationFrame.ScrollBox.Background then ReputationFrame.ScrollBox.Background:Hide() end
    end
    
    local detailFrame = ReputationFrame.ReputationDetailFrame
    if detailFrame then
        detailFrame:SetFrameStrata("DIALOG")
        detailFrame:SetFrameLevel(800) 
    end
    
    local header = mainFrame.Header
    local dropdown = ReputationFrame.filterDropdown
    if dropdown and header then
        dropdown:SetParent(header)
        dropdown:ClearAllPoints()
        dropdown:SetPoint("LEFT", header, "LEFT", 10, 0)
        dropdown:Show()
        dropdown:SetFrameStrata("DIALOG")
        dropdown:SetFrameLevel(500)
    end
    
    local scrollBar = ReputationFrame.ScrollBar
    local topOffset = -30
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", 0, topOffset)
        scrollBar:SetPoint("BOTTOMRIGHT", ReputationFrame, "BOTTOMRIGHT", 0, 5)
    end

    if ReputationFrame.ScrollBox then
        ReputationFrame.ScrollBox:ClearAllPoints()
        ReputationFrame.ScrollBox:SetPoint("TOPLEFT", ReputationFrame, "TOPLEFT", 2, -10)
        if scrollBar then
            ReputationFrame.ScrollBox:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMLEFT", -2, 0) 
        else
            ReputationFrame.ScrollBox:SetPoint("BOTTOMRIGHT", ReputationFrame, "BOTTOMRIGHT", -25, 5)
        end
    end
    
    if ReputationFrame.Background then ReputationFrame.Background:Hide() end
    for _, region in ipairs({ReputationFrame:GetRegions()}) do
        if region:IsObjectType("Texture") then
            if region:GetAtlas() ~= nil or region:GetTexture() ~= nil then
               region:SetAlpha(0)
            end
        end
    end
end

-- Widget d'en-tête et calcul (Scan profond)

function Reputation:SetupMyAddonElements(isRepMode)
    local main = addon.MainFrame
    if not main then return end

    if main.Header then
        main.Header:Show()
        local showStandardContent = not isRepMode
        if main.VaultBtn then main.VaultBtn:SetShown(showStandardContent) end
        local headerElements = {"Name", "Level", "ClassIcon", "IconBorder", "SpecIcon", "SpecIconBorder", "Score", "ScoreLabel"}
        for _, key in ipairs(headerElements) do
            if main.Header[key] then main.Header[key]:SetShown(showStandardContent) end
        end

        if isRepMode then
            if not self.HeaderWidget then
                self.HeaderWidget = CreateFrame("Button", nil, main.Header)
                self.HeaderWidget:SetSize(200, 30) 
                self.HeaderWidget:SetPoint("RIGHT", main.Header, "RIGHT", -15, 0)
                self.HeaderWidget:SetToplevel(true)
                self.HeaderWidget:SetFrameStrata("FULLSCREEN_DIALOG")
                self.HeaderWidget:SetFrameLevel(9999)
                
                self.HeaderWidget.Bg = self.HeaderWidget:CreateTexture(nil, "BACKGROUND")
                self.HeaderWidget.Bg:SetAllPoints()
                self.HeaderWidget.Bg:SetAtlas("common-gray-button-entry-normal", true) 
                self.HeaderWidget.Bg:SetVertexColor(0.1, 0.1, 0.1, 0.9)

                self.HeaderWidget.Icon = self.HeaderWidget:CreateTexture(nil, "OVERLAY", nil, 7)
                self.HeaderWidget.Icon:SetAtlas("ParagonReputation_Bag", false) 
                self.HeaderWidget.Icon:SetSize(25, 25) 
                self.HeaderWidget.Icon:SetPoint("RIGHT", self.HeaderWidget, "RIGHT", -5, 0)

                self.HeaderWidget.Glow = self.HeaderWidget:CreateTexture(nil, "OVERLAY", nil, 6)
                self.HeaderWidget.Glow:SetAtlas("ParagonReputation_Glow", false) 
                self.HeaderWidget.Glow:SetSize(55, 55)
                self.HeaderWidget.Glow:SetPoint("CENTER", self.HeaderWidget.Icon, "CENTER", 0, 0)
                self.HeaderWidget.Glow:SetBlendMode("ADD")
                self.HeaderWidget.Glow:SetAlpha(0)

                self.HeaderWidget.Anim = self.HeaderWidget.Glow:CreateAnimationGroup()
                self.HeaderWidget.Anim:SetLooping("BOUNCE")
                local fade = self.HeaderWidget.Anim:CreateAnimation("Alpha")
                fade:SetFromAlpha(0.2); fade:SetToAlpha(1); fade:SetDuration(0.8); fade:SetSmoothing("IN_OUT")

                self.HeaderWidget.Check = self.HeaderWidget:CreateTexture(nil, "OVERLAY", nil, 7)
                self.HeaderWidget.Check:SetAtlas("ParagonReputation_Checkmark", false)
                self.HeaderWidget.Check:SetSize(25, 25)
                self.HeaderWidget.Check:SetPoint("CENTER", self.HeaderWidget.Icon, "CENTER", 4, -4)
                
                self.HeaderWidget.Text = self.HeaderWidget:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                self.HeaderWidget.Text:SetPoint("RIGHT", self.HeaderWidget.Icon, "LEFT", -5, 0)
                self.HeaderWidget.Text:SetJustifyH("RIGHT")

                self.HeaderWidget:SetScript("OnEnter", function(btn)
                    btn.Bg:SetVertexColor(0.2, 0.2, 0.2, 1)
                    if btn.tooltipLines then
                        GameTooltip:SetOwner(btn, "ANCHOR_BOTTOMRIGHT")
                        for _, line in ipairs(btn.tooltipLines) do
                            if type(line) == "table" then
                                GameTooltip:AddLine(line.text, line.r, line.g, line.b)
                            else
                                GameTooltip:AddLine(line)
                            end
                        end
                        GameTooltip:Show()
                    end
                end)
                self.HeaderWidget:SetScript("OnLeave", function(btn) 
                    btn.Bg:SetVertexColor(0.1, 0.1, 0.1, 0.9)
                    GameTooltip:Hide() 
                end)
            end
            self.HeaderWidget:Show()
            self:UpdateHeaderInfo()
        else
            if self.HeaderWidget then self.HeaderWidget:Hide() end
        end
    end

    if isRepMode then
        if main.StatsFrame then main.StatsFrame:Hide() end
        if main.EquipmentFrame then main.EquipmentFrame:Hide() end
        if main.TitlesFrame then main.TitlesFrame:Hide() end
    end
end

function Reputation:UpdateHeaderInfo()
    if not self.HeaderWidget or not self:IsVisible() then return end
    
    local pendingRewardsMap = {} 
    
    -- Scan profond des IDs de faction (1 à 2800)
    -- Permet de trouver les récompenses même si le menu est fermé/réduit.
    -- Ce scan est très rapide pour le moteur de jeu.

    for factionID = 1, 2800 do
        -- On vérifie si c'est une faction Parangon connue
        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
            
            if hasRewardPending then
                local data = C_Reputation.GetFactionDataByID(factionID)
                if data and data.name then
                    pendingRewardsMap[factionID] = data.name
                end
            end
        end
    end
    
    -- Construction liste
    local rewardsList = {}
    for id, name in pairs(pendingRewardsMap) do
        table.insert(rewardsList, name)
    end
    table.sort(rewardsList)
    
    -- Affichage
    self.HeaderWidget.tooltipLines = {}
    local count = #rewardsList
    
    if count > 0 then
        self.HeaderWidget.Icon:SetDesaturated(false)
        self.HeaderWidget.Check:Show()
        self.HeaderWidget.Glow:Show()
        if not self.HeaderWidget.Anim:IsPlaying() then self.HeaderWidget.Anim:Play() end
        
        local label = (count > 1) and L["REWARDS"] or L["REWARD"]
        self.HeaderWidget.Text:SetText("|cff1eff00" .. label .. " : " .. count .. "|r")
        
        table.insert(self.HeaderWidget.tooltipLines, {text = L["PARAGON_REWARDS_AVAILABLE"], r=1, g=1, b=1})
        for _, name in ipairs(rewardsList) do 
            table.insert(self.HeaderWidget.tooltipLines, {text = "- " .. name, r=0, g=1, b=0}) 
        end
    else
        self.HeaderWidget.Icon:SetDesaturated(true)
        self.HeaderWidget.Check:Hide()
        self.HeaderWidget.Glow:Hide()
        self.HeaderWidget.Anim:Stop()
        self.HeaderWidget.Text:SetText("|cff808080" .. L["REWARD_ZERO"] .. "|r")
    end
    
    local textWidth = self.HeaderWidget.Text:GetStringWidth()
    self.HeaderWidget:SetWidth(textWidth + 25 + 30)
end

function Reputation:Update() self:UpdateHeaderInfo() end