local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

-- Références API (Standards 12.0)

local CreateFrame = CreateFrame
local GetCursorInfo, SpellIsTargeting = GetCursorInfo, SpellIsTargeting
local UnitClass, UnitName, UnitLevel, UnitRace = UnitClass, UnitName, UnitLevel, UnitRace
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetInventoryItemLink, GetCursorPosition = GetInventoryItemLink, GetCursorPosition
local C_Item, C_ChallengeMode, C_WeeklyRewards, C_Container = C_Item, C_ChallengeMode, C_WeeklyRewards, C_Container
local C_Timer, C_ClassColor, C_AddOns = C_Timer, C_ClassColor, C_AddOns
local PlaySound, SOUNDKIT = PlaySound, SOUNDKIT -- Audio API
local pairs, ipairs, unpack, tostring = pairs, ipairs, unpack, tostring
local min, max, floor, pi = math.min, math.max, math.floor, math.pi
local strfind, lower = string.find, string.lower
local hooksecurefunc = hooksecurefunc 
local CharacterFrame = CharacterFrame -- Référence au parent natif

local Mixin = Mixin

-- Assets & Cache

local MEDIA_PATH = "Interface\\AddOns\\"..addonName.."\\Utils\\logo\\"
local validSlotsCache = {}

addon.MainFrameMixin = {}
local MainMixin = addon.MainFrameMixin

-- Initialisation de l'en-tête (Header)


function MainMixin:InitHeader()
    -- Cadre principal
    self.Header = CreateFrame("Frame", nil, self, "BackdropTemplate")
    self.Header:SetPoint("TOPLEFT", self, "TOPLEFT", 40, -20)
    self.Header:SetPoint("TOPRIGHT", self, "TOPRIGHT", -40, -20)
    self.Header:SetHeight(60)
    self.Header:SetClipsChildren(true)
    
    self.Header:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
        edgeFile = C.HEADER_BORDER, 
        tile = false, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    self.Header:SetBackdropBorderColor(0.7, 0.7, 0.7, 1) 
    self.Header:SetBackdropColor(0, 0, 0, 0.3) 

    -- Arrière-plan
    self.Header.Bg = self.Header:CreateTexture(nil, "BACKGROUND", nil, 1)
    self.Header.Bg:SetPoint("TOPLEFT", 4, -4)
    self.Header.Bg:SetPoint("BOTTOMRIGHT", -4, 4)
    self.Header.Bg:SetAtlas(C.HEADER_ATLAS)
    self.Header.Bg:SetDesaturated(true) 
    self.Header.Bg:SetVertexColor(0.6, 0.6, 0.6, 1) 

    self.Header.Shadow = self.Header:CreateTexture(nil, "ARTWORK")
    self.Header.Shadow:SetAllPoints(self.Header.Bg)
    self.Header.Shadow:SetColorTexture(0,0,0,0.4)
    self.Header.Shadow:SetGradient("VERTICAL", CreateColor(0,0,0,0), CreateColor(0,0,0,0.8))

    -- Bouton Vault
    self.VaultBtn = CreateFrame("Button", nil, self.Header, "BackdropTemplate")
    self.VaultBtn:SetSize(200, 34)
    self.VaultBtn:SetPoint("CENTER", self.Header, "CENTER", 0, 0)
    self.VaultBtn:SetFrameLevel(self.Header:GetFrameLevel() + 10) 

    self.VaultBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8", 
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        tile = false, tileSize = 16, edgeSize = 16, 
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    self.VaultBtn:SetBackdropColor(0.1, 0.1, 0.1, 1) 
    self.VaultBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) 

    self.VaultBtn.Text = self.VaultBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.VaultBtn.Text:SetPoint("CENTER")
    self.VaultBtn.Text:SetTextColor(1, 1, 1) 

    -- Effet Glow
    self.VaultBtn.Glow = self.VaultBtn:CreateTexture(nil, "OVERLAY")
    self.VaultBtn.Glow:SetAtlas("loottoast-glow") 
    self.VaultBtn.Glow:SetBlendMode("ADD")
    self.VaultBtn.Glow:SetPoint("TOPLEFT", -10, 10)
    self.VaultBtn.Glow:SetPoint("BOTTOMRIGHT", 10, -10)
    self.VaultBtn.Glow:SetAlpha(0) 
    self.VaultBtn.Glow:Hide()

    self.VaultBtn.GlowAnimGroup = self.VaultBtn.Glow:CreateAnimationGroup()
    local fadeIn = self.VaultBtn.GlowAnimGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0); fadeIn:SetToAlpha(1); fadeIn:SetDuration(0.8); fadeIn:SetSmoothing("IN_OUT"); fadeIn:SetOrder(1)
    local fadeOut = self.VaultBtn.GlowAnimGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1); fadeOut:SetToAlpha(0.4); fadeOut:SetDuration(0.8); fadeOut:SetSmoothing("IN_OUT"); fadeOut:SetOrder(2)
    self.VaultBtn.GlowAnimGroup:SetLooping("BOUNCE")

    self.VaultBtn:SetScript("OnEnter", function(btn)
        btn:SetBackdropColor(0.2, 0.2, 0.2, 1) 
        if not C_WeeklyRewards.HasAvailableRewards() then btn:SetBackdropBorderColor(0.9, 0.9, 0.9, 1) end
    end)
    self.VaultBtn:SetScript("OnLeave", function(btn)
        btn:SetBackdropColor(0.1, 0.1, 0.1, 1)
        if C_WeeklyRewards.HasAvailableRewards() then
            btn:SetBackdropBorderColor(1, 0.85, 0.4, 1) 
        else
            btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) 
        end
    end)
    self.VaultBtn:SetScript("OnClick", function() 
        if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end
        if WeeklyRewardsFrame then 
            WeeklyRewardsFrame:SetFrameStrata("DIALOG")
            WeeklyRewardsFrame:SetShown(not WeeklyRewardsFrame:IsShown())
        end
    end)

    -- Infos Classe/Spé
    self.Header.ClassIcon = self.Header:CreateTexture(nil, "ARTWORK", nil, 2)
    self.Header.ClassIcon:SetSize(48, 48) 
    self.Header.ClassIcon:SetPoint("LEFT", 10, 0) 
    self.Header.ClassIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    
    self.Header.IconBorder = self.Header:CreateTexture(nil, "ARTWORK", nil, 1)
    self.Header.IconBorder:SetSize(48, 48)
    self.Header.IconBorder:SetPoint("CENTER", self.Header.ClassIcon, "CENTER", 0, 0)
    self.Header.IconBorder:SetColorTexture(0, 0, 0, 1)

    local mask = self.Header:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(self.Header.ClassIcon)
    self.Header.ClassIcon:AddMaskTexture(mask)
    self.Header.IconBorder:AddMaskTexture(mask)

    self.Header.SpecIcon = self.Header:CreateTexture(nil, "OVERLAY", nil, 7) 
    self.Header.SpecIcon:SetSize(27, 27)
    self.Header.SpecIcon:SetPoint("BOTTOMRIGHT", self.Header.ClassIcon, "BOTTOMRIGHT", 3, -3) 
    self.Header.SpecIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9) 
    
    self.Header.SpecIconBorder = self.Header:CreateTexture(nil, "OVERLAY", nil, 6)
    self.Header.SpecIconBorder:SetSize(27, 27)
    self.Header.SpecIconBorder:SetPoint("CENTER", self.Header.SpecIcon)
    self.Header.SpecIconBorder:SetColorTexture(0, 0, 0, 1) 

    local specMask = self.Header:CreateMaskTexture()
    specMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    specMask:SetAllPoints(self.Header.SpecIcon)
    self.Header.SpecIcon:AddMaskTexture(specMask)
    self.Header.SpecIconBorder:AddMaskTexture(specMask)

    -- Labels
    self.Header.Name = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.Header.Name:SetPoint("BOTTOMLEFT", self.Header.ClassIcon, "RIGHT", 10, 2) 
    self.Header.Name:SetJustifyH("LEFT")

    self.Header.Level = self.Header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.Header.Level:SetPoint("TOPLEFT", self.Header.ClassIcon, "RIGHT", 10, 0)
    self.Header.Level:SetTextColor(0.8, 0.8, 0.8)

    self.Header.Score = self.Header:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Large") 
    self.Header.Score:SetPoint("RIGHT", -15, 0) 
    self.Header.Score:SetJustifyH("RIGHT")
    
    self.Header.ScoreLabel = self.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Header.ScoreLabel:SetPoint("RIGHT", self.Header.Score, "LEFT", -5, 0)
    self.Header.ScoreLabel:SetText(L["TITLE_M_SCORE"] or "M+ Score")
    self.Header.ScoreLabel:SetTextColor(0.7, 0.7, 0.7) 
end

function MainMixin:UpdateHeader()
    -- Vérification de l'onglet actif
    local isCharTab = (self.activeTab == 1 or self.activeTab == nil)

    -- Gestion de la visibilité des éléments "Statiques"
    self.VaultBtn:SetShown(isCharTab)
    self.Header.ClassIcon:SetShown(isCharTab)
    self.Header.IconBorder:SetShown(isCharTab)
    self.Header.Name:SetShown(isCharTab)
    self.Header.Level:SetShown(isCharTab)
    self.Header.Score:SetShown(isCharTab)

    -- Si ce n'est pas l'onglet personnage, on cache le reste
    if not isCharTab then
        self.Header.SpecIcon:Hide()
        self.Header.SpecIconBorder:Hide()
        self.Header.ScoreLabel:Hide()
        return
    end

    -- Mise à jour des données
    local _, classFile = UnitClass("player")
    if classFile then
        self.Header.ClassIcon:SetTexture("Interface\\Icons\\ClassIcon_"..classFile)
        local color = C_ClassColor.GetClassColor(classFile)
        if color then
            self.Header.Name:SetTextColor(color.r, color.g, color.b)
        end
    end
    
    self.Header.Name:SetText(UnitName("player") or "")
    self.Header.Level:SetText((LEVEL or "Level").." "..(UnitLevel("player") or 0))

    local currentSpec = GetSpecialization()
    if currentSpec then
        local _, _, _, icon = GetSpecializationInfo(currentSpec)
        self.Header.SpecIcon:SetTexture(icon)
        self.Header.SpecIcon:Show()
        self.Header.SpecIconBorder:Show()
    else
        self.Header.SpecIcon:Hide()
        self.Header.SpecIconBorder:Hide()
    end

    local score = C_ChallengeMode.GetOverallDungeonScore()
    if score and score > 0 then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or {r=1, g=1, b=1}
        self.Header.Score:SetText(tostring(score))
        self.Header.Score:SetTextColor(color.r, color.g, color.b)
        self.Header.ScoreLabel:Show()
    else
        self.Header.Score:SetText("")
        self.Header.ScoreLabel:Hide()
    end

    self.VaultBtn.Text:SetText(L["TITLE_GREAT_VAULT"] or "Great Vault")
    self.VaultBtn.Text:SetTextColor(1, 1, 1)

    if C_WeeklyRewards.HasAvailableRewards() then
        self.VaultBtn.Glow:Show()
        self.VaultBtn.GlowAnimGroup:Play()
        self.VaultBtn:SetBackdropBorderColor(1, 0.85, 0.4, 1) 
    else
        self.VaultBtn.GlowAnimGroup:Stop()
        self.VaultBtn.Glow:Hide()
        self.VaultBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) 
    end
end

-- Gestion des emplacements d'équipement


function MainMixin:InitSlots()
    self.slots = {}
    for id, layout in pairs(C.SLOTS_LAYOUT) do
        local side, x, y, labelKey = unpack(layout)
        local frame = CreateFrame("Button", nil, self, "BackdropTemplate, SecureActionButtonTemplate")
        Mixin(frame, addon.SlotMixin) 
        local yOffset = y + 5
        if side == "LEFT" then frame:SetPoint("TOPLEFT", self, "TOPLEFT", x, yOffset)
        elseif side == "RIGHT" then frame:SetPoint("TOPRIGHT", self, "TOPRIGHT", x, yOffset)
        else frame:SetPoint("BOTTOM", self, "BOTTOM", x, y) end
        
        local alignSide = side
        if id == 16 then alignSide = "LEFT" elseif id == 17 then alignSide = "RIGHT" end
        frame:OnLoad(id, labelKey, alignSide)
        self.slots[id] = frame
    end
end

-- Navigation (Onglets du bas)


function MainMixin:InitBottomTabs()
    local TAB_HEIGHT = C.STATS_WIDTH_CLOSED or 40

    self.TabsContainer = CreateFrame("Frame", nil, self)
    self.TabsContainer:SetHeight(TAB_HEIGHT)
    self.TabsContainer:SetPoint("TOP", self, "BOTTOM", 0, 1)
    
    self.tabs = {}
    
    local tabsData = {
        { id = 1, label = CHARACTER, icon = MEDIA_PATH.."character.png" },
        { id = 2, label = CURRENCY, icon = MEDIA_PATH.."monnaie.png" },
        { id = 3, label = REPUTATION, icon = MEDIA_PATH.."reputation.png" },
    }
    
    local buttons = {}
    local totalWidth = 0
    local SPACING = 32          
    local TEXT_PADDING = 25     

    for i, data in ipairs(tabsData) do
        local btn = CreateFrame("Button", nil, self.TabsContainer, "BackdropTemplate")
        
        btn.Background = btn:CreateTexture(nil, "BACKGROUND")
        btn.Background:SetPoint("TOPLEFT", 4, -4)
        btn.Background:SetPoint("BOTTOMRIGHT", -4, 4)
        btn.Background:SetAtlas(C.CONTENT_ATLAS)
        btn.Background:SetVertexColor(0.8, 0.8, 0.8, 1)

        btn:SetBackdrop({
            bgFile = nil, 
            edgeFile = C.BORDER_TEXTURE, 
            tile = true, tileSize = 256, edgeSize = 28, 
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        btn:SetBackdropColor(1, 1, 1, 1) 
        btn:SetBackdropBorderColor(1, 1, 1, 1)

        btn.Icon = btn:CreateTexture(nil, "ARTWORK")
        btn.Icon:SetSize(26, 26) 
        btn.Icon:SetPoint("RIGHT", btn, "LEFT", 0, 0)
        btn.Icon:SetTexture(data.icon) 

        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        btn.Text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.Text:SetText(data.label or "")
        
        local textWidth = btn.Text:GetStringWidth()
        if textWidth < 30 then textWidth = 30 end
        local btnWidth = floor(textWidth + TEXT_PADDING) 
        
        btn:SetSize(btnWidth, TAB_HEIGHT) 
        
        totalWidth = totalWidth + btnWidth
        
        btn.Glow = btn:CreateTexture(nil, "OVERLAY")
        btn.Glow:SetColorTexture(1, 1, 1) 
        btn.Glow:SetBlendMode("ADD")
        btn.Glow:SetPoint("TOPLEFT", 4, -4)
        btn.Glow:SetPoint("BOTTOMRIGHT", -4, 4)
        btn.Glow:SetAlpha(0)

        btn.GlowAnim = btn.Glow:CreateAnimationGroup()
        local anim = btn.GlowAnim:CreateAnimation("Alpha")
        anim:SetFromAlpha(0.1); anim:SetToAlpha(0.25); anim:SetDuration(0.8); anim:SetSmoothing("IN_OUT")
        btn.GlowAnim:SetLooping("BOUNCE")

        btn:SetScript("OnEnter", function(b)
            if self.activeTab ~= data.id then
                b.Glow:Show(); b.GlowAnim:Play(); b.Text:SetTextColor(1, 1, 1)
            end
        end)
        
        btn:SetScript("OnLeave", function(b)
            if self.activeTab ~= data.id then
                b.GlowAnim:Stop(); b.Glow:SetAlpha(0); b.Text:SetTextColor(0.6, 0.6, 0.6)
            end
        end)
        
        btn:SetScript("OnClick", function() 
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
            self:SelectTab(data.id) 
        end)

        btn.id = data.id
        self.tabs[data.id] = btn
        buttons[i] = btn
    end

    totalWidth = totalWidth + ((#buttons - 1) * SPACING)
    local LEFT_MARGIN = 20 
    self.TabsContainer:SetWidth(totalWidth + LEFT_MARGIN)
    
    local currentX = LEFT_MARGIN 
    for i, btn in ipairs(buttons) do
        btn:SetPoint("LEFT", currentX, 0)
        currentX = currentX + btn:GetWidth() + SPACING
    end

    self:InitCoinPanel()
    self:InitReputationPanel()
    self:SelectTab(1)
end

function MainMixin:InitCoinPanel()
    self.CoinFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
    self.CoinFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -90)
    self.CoinFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -C.STATS_WIDTH_CLOSED - 40, 70)
    if addon.CoinMixin then Mixin(self.CoinFrame, addon.CoinMixin); self.CoinFrame:OnLoad() end
    self.CoinFrame:Hide()
end

function MainMixin:InitReputationPanel()
    self.ReputationFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
    self.ReputationFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 30, -90)
    self.ReputationFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -C.STATS_WIDTH_CLOSED - 40, 70)
    if addon.ReputationMixin then Mixin(self.ReputationFrame, addon.ReputationMixin); self.ReputationFrame:OnLoad() end
    self.ReputationFrame:Hide()
end

function MainMixin:SelectTab(tabID)
    self.activeTab = tabID

    for id, btn in pairs(self.tabs) do
        if id == tabID then
            btn.Text:SetTextColor(1, 0.82, 0)
            btn.Glow:Show(); btn.Glow:SetAlpha(0.15); btn.GlowAnim:Stop()
            btn.Icon:SetAlpha(1); btn.Icon:SetDesaturated(false)
            btn:SetBackdropBorderColor(1, 0.82, 0, 1)
        else
            btn.Text:SetTextColor(0.6, 0.6, 0.6)
            btn.Glow:SetAlpha(0); btn.Glow:Hide(); btn.GlowAnim:Stop()
            btn.Icon:SetAlpha(1); btn.Icon:SetDesaturated(true) 
            btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    end

    local isCharTab = (tabID == 1)

    if self.ModelContainer then self.ModelContainer:SetShown(isCharTab) end
    self:ToggleSlots(isCharTab)

    if self.StatsFrame then self.StatsFrame:SetShown(isCharTab) end
    if self.EquipmentFrame then self.EquipmentFrame:SetShown(isCharTab) end
    if self.TitlesFrame then self.TitlesFrame:SetShown(isCharTab) end

    if self.CoinFrame then self.CoinFrame:SetShown(tabID == 2) end
    if self.ReputationFrame then self.ReputationFrame:SetShown(tabID == 3) end

    if tabID == 2 and self.CoinFrame and self.CoinFrame.Update then
        self.CoinFrame:Update()
    elseif tabID == 3 and self.ReputationFrame and self.ReputationFrame.Update then
        self.ReputationFrame:Update()
    end

    self:UpdateHeader()
end

function MainMixin:ToggleSlots(show)
    for _, slotFrame in pairs(self.slots) do slotFrame:SetShown(show) end
end

-- Panneaux latéraux


function MainMixin:InitStatsPanel()
    self.STATS_HEIGHT = 450
    self.EQUIPMENT_HEIGHT = 400
    self.TITLES_HEIGHT = 600
    
    self.StatsFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
    if addon.StatsMixin then Mixin(self.StatsFrame, addon.StatsMixin) end 
    self.StatsFrame:SetSize(C.STATS_WIDTH_OPEN or 200, self.STATS_HEIGHT) 
    self.StatsFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", -2, -27)
    if self.StatsFrame.OnLoad then self.StatsFrame:OnLoad() end
    
    self.EquipmentFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
    if addon.EquipmentMixin then Mixin(self.EquipmentFrame, addon.EquipmentMixin) end
    self.EquipmentFrame:SetSize(C.STATS_WIDTH_CLOSED or 40, self.EQUIPMENT_HEIGHT)
    if self.EquipmentFrame.OnLoad then self.EquipmentFrame:OnLoad() end
    if self.EquipmentFrame.UpdateSets then self.EquipmentFrame:UpdateSets() end
    
    self.TitlesFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
    if addon.TitlesMixin then Mixin(self.TitlesFrame, addon.TitlesMixin) end
    self.TitlesFrame:SetSize(C.STATS_WIDTH_CLOSED or 40, self.TITLES_HEIGHT) 
    if self.TitlesFrame.OnLoad then self.TitlesFrame:OnLoad() end
    if self.TitlesFrame.UpdateTitles then self.TitlesFrame:UpdateTitles() end

    -- OPTION: Accordéon par défaut
    local db = MyCharacterPanelDB or {}
    local def = db.defaultAccordion or 1
    
    self.isStatsOpen = (def == 1)
    self.isEquipmentOpen = (def == 2)
    self.isTitlesOpen = (def == 3)
    
    self:CalculateClosedHeights()
    
    -- [CORRECTION BUG DÉBORDEMENT]
    -- On utilise GetAvailableHeightFor pour déterminer la hauteur initiale de l'élément ouvert
    local statsH = self.isStatsOpen and self:GetAvailableHeightFor(self.StatsFrame) or self.STATS_HEIGHT
    local equipH = self.isEquipmentOpen and self:GetAvailableHeightFor(self.EquipmentFrame) or self.EQUIPMENT_HEIGHT
    local titleH = self.isTitlesOpen and self:GetAvailableHeightFor(self.TitlesFrame) or self.TITLES_HEIGHT

    self:ApplyPanelState(self.StatsFrame, self.isStatsOpen, statsH)
    self:ApplyPanelState(self.EquipmentFrame, self.isEquipmentOpen, equipH)
    self:ApplyPanelState(self.TitlesFrame, self.isTitlesOpen, titleH)

    self:UpdateLayout()
end

function MainMixin:UpdateLayout()
    local PADDING = 35
    self.EquipmentFrame:ClearAllPoints()
    self.TitlesFrame:ClearAllPoints()

    self.EquipmentFrame:SetPoint("TOPLEFT", self.StatsFrame, "BOTTOMLEFT", 0, -PADDING)

    if self.isStatsOpen then
        self.TitlesFrame:SetPoint("TOPLEFT", self.EquipmentFrame, "TOPRIGHT", 0, 0)
    else
        self.TitlesFrame:SetPoint("TOPLEFT", self.EquipmentFrame, "BOTTOMLEFT", 0, -PADDING)
    end
end

function MainMixin:CalculateClosedHeights()
    local function getAutoHeight(frame)
        if frame and frame.VerticalLabel then
            local textWidth = frame.VerticalLabel:GetStringWidth()
            return floor(max(textWidth, 30) + 22)
        end
        return 150 
    end

    self.StatsFrame.closedHeight = getAutoHeight(self.StatsFrame)
    self.EquipmentFrame.closedHeight = getAutoHeight(self.EquipmentFrame)
    self.TitlesFrame.closedHeight = getAutoHeight(self.TitlesFrame)
    
    if not self.isStatsOpen then self:ApplyPanelState(self.StatsFrame, false) end
    if not self.isEquipmentOpen then self:ApplyPanelState(self.EquipmentFrame, false) end
    if not self.isTitlesOpen then self:ApplyPanelState(self.TitlesFrame, false) end
end

function MainMixin:UpdateStatsHeight(newHeight)
    if newHeight and newHeight > 0 then
        self.STATS_HEIGHT = newHeight
        if self.isStatsOpen then self.StatsFrame:SetHeight(newHeight) end
    end
end

function MainMixin:ApplyPanelState(frame, isOpen, openHeight)
    local width = isOpen and C.STATS_WIDTH_OPEN or C.STATS_WIDTH_CLOSED
    local height = isOpen and openHeight or (frame.closedHeight or 150)
    frame:SetSize(width, height)
    
    if isOpen then
        if frame.CenterContainer then frame.CenterContainer:Hide() end
        if frame.ExpandBtn then frame.ExpandBtn:Hide() end
        if frame.Content then frame.Content:Show() end
        if frame.VerticalLabel then frame.VerticalLabel:SetAlpha(0) end 
    else
        if frame.Content then frame.Content:Hide() end
        if frame.ExpandBtn then frame.ExpandBtn:Show() end
        if frame.CenterContainer then frame.CenterContainer:Show() end
        if frame.VerticalLabel then frame.VerticalLabel:Show(); frame.VerticalLabel:SetAlpha(1) end
    end
    
    -- Application initiale de la police d'en-tête (Accordéons)

    if frame.HeaderTitle and MyCharacterPanelDB and MyCharacterPanelDB.fonts then
        local font = MyCharacterPanelDB.fonts.headers or "Fonts\\FRIZQT__.TTF"
        frame.HeaderTitle:SetFont(font, 14, "NORMAL")
    end
end

function MainMixin:AnimatePanel(frame, targetWidth, targetHeight, isOpen)
    if not frame.SlideAnim then
        frame.SlideAnim = CreateFrame("Frame", nil, frame)
        frame.SlideAnim:Hide()
        frame.SlideAnim:SetScript("OnUpdate", function(anim, elapsed)
            anim.elapsed = anim.elapsed + elapsed
            local progress = min(anim.elapsed / 0.25, 1)
            local smooth = 1 - (1 - progress)^5 
            
            frame:SetSize(
                floor(anim.startW + (anim.endW - anim.startW) * smooth),
                floor(anim.startH + (anim.endH - anim.startH) * smooth)
            )
            
            if progress >= 1 then
                anim:Hide()
                frame:SetSize(anim.endW, anim.endH)
                if anim.targetStateOpen then
                    if frame.CenterContainer then frame.CenterContainer:Hide() end
                    if frame.ExpandBtn then frame.ExpandBtn:Hide() end
                    if frame.Content then frame.Content:Show() end
                    if frame.VerticalLabel then frame.VerticalLabel:SetAlpha(0) end
                else
                    if frame.Content then frame.Content:Hide() end
                    if frame.ExpandBtn then frame.ExpandBtn:Show() end
                    if frame.CenterContainer then frame.CenterContainer:Show() end
                    if frame.VerticalLabel then frame.VerticalLabel:Show(); frame.VerticalLabel:SetAlpha(1) end
                end
            end
        end)
    end

    local anim = frame.SlideAnim
    if anim:IsShown() then return end 

    anim.startW, anim.startH = frame:GetSize()
    anim.endW, anim.endH = targetWidth, targetHeight
    anim.targetStateOpen = isOpen
    anim.elapsed = 0
    
    if not isOpen then 
        if frame.Content then frame.Content:Hide() end 
    else 
        if frame.CenterContainer then frame.CenterContainer:Hide() end
        if frame.ExpandBtn then frame.ExpandBtn:Hide() end 
    end
    anim:Show()
end

function MainMixin:CloseAllPanelsExcept(exceptFrame)
    if self.StatsFrame ~= exceptFrame and self.isStatsOpen then
        self.isStatsOpen = false
        self:AnimatePanel(self.StatsFrame, C.STATS_WIDTH_CLOSED, self.StatsFrame.closedHeight or 150, false)
    end
    if self.EquipmentFrame ~= exceptFrame and self.isEquipmentOpen then
        self.isEquipmentOpen = false
        self:AnimatePanel(self.EquipmentFrame, C.STATS_WIDTH_CLOSED, self.EquipmentFrame.closedHeight or 150, false)
    end
    if self.TitlesFrame ~= exceptFrame and self.isTitlesOpen then
        self.isTitlesOpen = false
        self:AnimatePanel(self.TitlesFrame, C.STATS_WIDTH_CLOSED, self.TitlesFrame.closedHeight or 150, false)
    end
    self:UpdateLayout()
end


function MainMixin:GetAvailableHeightFor(targetFrame)
    local totalH = self:GetHeight()
    local usedHeight = 29 
    local gap = 35
    
    if targetFrame ~= self.StatsFrame then
        usedHeight = usedHeight + (self.isStatsOpen and (self.StatsFrame.fullHeight or self.STATS_HEIGHT) or (self.StatsFrame.closedHeight or 150)) + gap
    end
    
    local titlesTakesSpace = true
    if self.isStatsOpen and targetFrame == self.EquipmentFrame then titlesTakesSpace = false end
    
    if targetFrame ~= self.TitlesFrame and titlesTakesSpace then
        usedHeight = usedHeight + (self.isTitlesOpen and self.TitlesFrame:GetHeight() or (self.TitlesFrame.closedHeight or 150)) + gap
    end
    
    if targetFrame == self.TitlesFrame and targetFrame ~= self.EquipmentFrame and not self.isStatsOpen then
         usedHeight = usedHeight + (self.isEquipmentOpen and self.EquipmentFrame:GetHeight() or (self.EquipmentFrame.closedHeight or 150)) + gap
    end
    
    return max(totalH - usedHeight, 100) 
end

function MainMixin:ToggleStats(forceOpen)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) 
    local h = (self.StatsFrame.fullHeight and self.StatsFrame.fullHeight > 0) and self.StatsFrame.fullHeight or self.STATS_HEIGHT
    if self.isStatsOpen and not forceOpen then
        self.isStatsOpen = false
        self:AnimatePanel(self.StatsFrame, C.STATS_WIDTH_CLOSED, self.StatsFrame.closedHeight or 150, false)
    else
        self:CloseAllPanelsExcept(self.StatsFrame)
        self.isStatsOpen = true
        self:AnimatePanel(self.StatsFrame, C.STATS_WIDTH_OPEN, h, true)
    end
    self:UpdateLayout()
end

function MainMixin:ToggleEquipment(forceOpen)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) 
    if self.isEquipmentOpen and not forceOpen then
        self.isEquipmentOpen = false
        self:AnimatePanel(self.EquipmentFrame, C.STATS_WIDTH_CLOSED, self.EquipmentFrame.closedHeight or 150, false)
        self:UpdateLayout()
    else
        self:CloseAllPanelsExcept(self.EquipmentFrame)
        self.isEquipmentOpen = true
        self:AnimatePanel(self.EquipmentFrame, C.STATS_WIDTH_OPEN, self:GetAvailableHeightFor(self.EquipmentFrame), true)
        self:UpdateLayout()
    end
end

function MainMixin:ToggleTitles(forceOpen)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) 
    if self.isTitlesOpen and not forceOpen then
        self.isTitlesOpen = false
        self:AnimatePanel(self.TitlesFrame, C.STATS_WIDTH_CLOSED, self.TitlesFrame.closedHeight or 150, false)
        self:UpdateLayout()
    else
        self:CloseAllPanelsExcept(self.TitlesFrame)
        self.isTitlesOpen = true
        self:AnimatePanel(self.TitlesFrame, C.STATS_WIDTH_OPEN, self:GetAvailableHeightFor(self.TitlesFrame), true)
        self:UpdateLayout()
    end
end

-- Modèle 3D et prévisualisation


function MainMixin:InitModels()
    self.ModelContainer = CreateFrame("Frame", nil, self)
    self.ModelContainer:SetSize(260, 400) -- Réduction de la largeur pour éviter de couvrir les slots (340 -> 260)
    self.ModelContainer:SetPoint("CENTER", 0, -10)
    self.ModelContainer:SetClipsChildren(true) 
    self.ModelContainer:EnableMouse(true)
    self.ModelContainer:SetFrameLevel(self:GetFrameLevel() + 2) -- On s'assure qu'il est en dessous des slots (Main+10)

    self.Model = CreateFrame("PlayerModel", nil, self.ModelContainer) 
    self.Model:SetAllPoints()
    self.Model:SetUnit("player")
    self.Model:SetAnimation(804)
    self.Model:SetCamDistanceScale(1.1)
    self.currentModelScale = 1.1 
    self.currentModelFacing = 0 

    self.ModelContainer:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self.isRotatingModel = true
            self.Model.startX = GetCursorPosition()
            self.Model.startFacing = self.currentModelFacing or self.Model:GetFacing() or 0
            self.Model:SetScript("OnUpdate", function(model)
                local diff = (GetCursorPosition() - model.startX) / 60
                self.currentModelFacing = model.startFacing + diff
                model:SetFacing(self.currentModelFacing)
            end)
        end
    end)

    self.ModelContainer:SetScript("OnMouseUp", function()
        self.isRotatingModel = false
        self.Model:SetScript("OnUpdate", nil)
    end)
    
    self.ModelContainer:SetScript("OnMouseWheel", function(_, delta)
        local scale = max(0.5, min((self.currentModelScale or 1.1) + (delta > 0 and -0.1 or 0.1), 2.0))
        self.currentModelScale = scale 
        self.Model:SetCamDistanceScale(scale)
    end)

    self.PreviewModel = CreateFrame("DressUpModel", nil, self.ModelContainer)
    self.PreviewModel:SetAllPoints()
    self.PreviewModel:SetUnit("player")
    self.PreviewModel:Hide()
end

function MainMixin:ShowItemPreview(slotID)
    -- Option : Vérifier si l'aperçu 3D est activé

    local db = MyCharacterPanelDB or {}
    local showPreview = (db.showModelPreview == nil) and true or db.showModelPreview
    
    if not showPreview then return end

    local itemLink = GetInventoryItemLink("player", slotID)
    
    if self.isRotatingModel or not itemLink then return end
    if ({[2]=1,[11]=1,[12]=1,[13]=1,[14]=1})[slotID] then return end 

    self.Model:Hide()
    self.PreviewModel:Show()
    self.PreviewModel:SetPosition(0, 0, 0)
    self.PreviewModel:SetFacing(slotID == 15 and pi or 0) 
    self.PreviewModel:SetUnit("player")
    self.PreviewModel:RefreshUnit()
    self.PreviewModel:Undress()
    self.PreviewModel:TryOn(itemLink)
    self.PreviewModel.shouldRotate = (slotID ~= 15)

    local ZOOM_DATA = { [1]={1.5,0,-0.4}, [3]={0.9,0,-0.4}, [15]={0.85,0,0}, [8]={1.0,0,0.5}, [5]={0.9,0,-0.2}, [4]={0.9,0,-0.2}, [19]={0.9,0,-0.2}, [9]={1.1,0,-0.1}, [10]={1.1,0,-0.1}, [6]={1.3,0,0.1}, [7]={1.3,0,0.3} }
    local _, race = UnitRace("player")
    local data = ZOOM_DATA[slotID]
    
    if data then
        local zoom, x, y = unpack(data)
        if ({Gnome=1,Goblin=1,Vulpera=1,Mechagnome=1,Dwarf=1,DarkIronDwarf=1,Earthen=1})[race] then
            if slotID==10 or slotID==9 then zoom, y = 1.4, 0.3
            elseif slotID==5 or slotID==4 or slotID==19 then zoom, y = 1.1, 0.2
            elseif slotID==1 then zoom, y = 1.4, -0.2 end
        end
        self.PreviewModel:SetPosition(zoom, x, y)
    end
end

function MainMixin:HideItemPreview()
    self.PreviewModel:Hide()
    if self.activeTab == 1 then
        self.Model:Show()
        self.Model:SetFacing(self.currentModelFacing or 0)
        self.Model:SetCamDistanceScale(self.currentModelScale or 1.1)
    end
end

-- Événements et chargement


function MainMixin:OnLoad()
    -- Gestion du déplacement de la fenêtre parente

    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function() 
        if CharacterFrame:IsMovable() then CharacterFrame:StartMoving() end
    end)
    self:SetScript("OnDragStop", function() CharacterFrame:StopMovingOrSizing() end)
    
    self.Background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
    self.Background:SetPoint("TOPLEFT", 8, -8)
    self.Background:SetPoint("BOTTOMRIGHT", -8, 8)
    self.Background:SetAtlas(C.BACKGROUND_ATLAS)
    self.Background:SetDesaturated(true)
    if C.COLOR_BACKGROUND_TINT then self.Background:SetVertexColor(unpack(C.COLOR_BACKGROUND_TINT)) end

    self.BottomLight = self:CreateTexture(nil, "BACKGROUND", nil, -6)
    self.BottomLight:SetPoint("BOTTOMLEFT", 8, 8)
    self.BottomLight:SetPoint("BOTTOMRIGHT", -8, 8)
    self.BottomLight:SetHeight(250) 
    self.BottomLight:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.15), CreateColor(1, 1, 1, 0)) 
    self.BottomLight:SetBlendMode("ADD")

    -- Initialisation des composants

    self:InitHeader()
    self:InitModels()
    self:InitSlots()
    self:InitStatsPanel()
    self:InitBottomTabs()

    local events = {"PLAYER_ENTERING_WORLD", "UNIT_INVENTORY_CHANGED", "UNIT_MODEL_CHANGED", "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_AVG_ITEM_LEVEL_UPDATE", "UPDATE_INVENTORY_DURABILITY", "BAG_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN", "WEEKLY_REWARDS_UPDATE", "WEEKLY_REWARDS_ITEM_CHANGED", "CURSOR_CHANGED", "KNOWN_TITLES_UPDATE", "UNIT_NAME_UPDATE"}
    for _, e in ipairs(events) do self:RegisterEvent(e) end

    self:SetScript("OnEvent", self.OnEvent)
    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self:SetScript("OnUpdate", self.OnUpdate)
    
    self.updateTimer = 0

    hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info then
            self.lastBagItemID = info.itemID
            self.updatePending = true 
            C_Timer.After(0.05, function() self:OnCursorChanged() end)
        end
    end)

    self:UpdateHeader()
    self:RequestUpdate()
end

function MainMixin:OnShow()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN) -- Son d'ouverture

    if self.Model then
        self.currentModelScale = 1.1; self.currentModelFacing = 0
        self.Model:SetFacing(0); self.Model:SetCamDistanceScale(1.1); self.Model.isRotating = false
    end
    if self.PreviewModel then self.PreviewModel:SetFacing(0) end
    self.isRotatingModel = false
    self:UpdateHeader()
    self:RequestUpdate()
end

function MainMixin:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) -- Son de fermeture
end

function MainMixin:OnUpdate(elapsed)
    if self.isTargeting and not SpellIsTargeting() then
        self.isTargeting = false
        self:OnCursorChanged() 
    end

    if self.updatePending then
        self.updateTimer = self.updateTimer + elapsed
        if self.updateTimer > 0.05 then
            self:UpdateAll()
            self.updatePending = false
            self.updateTimer = 0
        end
    end

    if self.PreviewModel and self.PreviewModel:IsShown() and self.PreviewModel.shouldRotate then
        self.PreviewModel:SetFacing((self.PreviewModel:GetFacing() or 0) + (elapsed * 0.8))
    end
end

function MainMixin:OnCursorChanged()
    wipe(validSlotsCache)
    local cursorType, id = GetCursorInfo()
    local hasInteraction, searchString = false, ""

    self.isTargeting = SpellIsTargeting() 

    if cursorType == "item" and id then
        hasInteraction = true
        local _, _, _, equipLoc = C_Item.GetItemInfoInstant(id)
        if equipLoc and C.EQUIP_LOC_TO_SLOT and C.EQUIP_LOC_TO_SLOT[equipLoc] then
            for _, slotId in ipairs(C.EQUIP_LOC_TO_SLOT[equipLoc]) do validSlotsCache[slotId] = true end
        else
            hasInteraction = false 
        end
    elseif self.isTargeting and self.lastBagItemID then
        local itemName = C_Item.GetItemInfo(self.lastBagItemID)
        if itemName then searchString = lower(itemName); hasInteraction = true end
    end

    if hasInteraction and searchString ~= "" then
        hasInteraction = false 
        local targets = {
            ["tête"]={1}, ["head"]={1}, ["cou"]={2}, ["neck"]={2}, ["épaules"]={3}, ["shoulder"]={3}, ["cape"]={15}, ["dos"]={15},
            ["torse"]={5}, ["chest"]={5}, ["poignets"]={9}, ["wrist"]={9}, ["mains"]={10}, ["hands"]={10}, ["taille"]={6}, ["waist"]={6},
            ["jambes"]={7}, ["legs"]={7}, ["bottes"]={8}, ["feet"]={8}, ["anneau"]={11,12}, ["ring"]={11,12}, ["arme"]={16,17}, ["weapon"]={16,17}
        }
        for k, v in pairs(targets) do
            if strfind(searchString, k) then
                for _, slot in ipairs(v) do validSlotsCache[slot] = true end
                hasInteraction = true
            end
        end
    end

    for _, slotFrame in pairs(self.slots) do
        if hasInteraction then
            if validSlotsCache[slotFrame.slotID] then
                slotFrame:SetDimmed(false); slotFrame:SetHighlight(true)
            else
                slotFrame:SetDimmed(true); slotFrame:SetHighlight(false)
            end
        else
            slotFrame:SetDimmed(false); slotFrame:SetHighlight(false)
        end
    end
    if not hasInteraction then self.lastBagItemID = nil; self.isTargeting = false end
end

function MainMixin:RequestUpdate() self.updatePending = true end

function MainMixin:OnEvent(event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        self.Model:SetUnit("player"); self.Model:RefreshUnit(); self:RequestUpdate()
    elseif event == "KNOWN_TITLES_UPDATE" or (event == "UNIT_NAME_UPDATE" and unit == "player") then
        if self.TitlesFrame then self.TitlesFrame:UpdateTitles() end
    elseif event == "CURSOR_CHANGED" then
        self:OnCursorChanged()
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if unit == "player" then self:RequestUpdate() end
    elseif event == "BAG_UPDATE_COOLDOWN" or event == "SPELL_UPDATE_COOLDOWN" then
        for _, slot in pairs(self.slots) do slot:UpdateCooldown() end
    elseif event == "UNIT_MODEL_CHANGED" and unit == "player" then
        self.Model:RefreshUnit()
    elseif event == "WEEKLY_REWARDS_UPDATE" or event == "WEEKLY_REWARDS_ITEM_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        self:UpdateHeader(); self:RequestUpdate()
    else
        self:RequestUpdate()
    end
end

-- FONCTION AJOUTÉE : Applique la police aux titres des accordéons
function MainMixin:UpdateAccordionFonts()
    local db = MyCharacterPanelDB
    if not db or not db.fonts or not db.fonts.headers then return end
    local font = db.fonts.headers
    
    local frames = {self.StatsFrame, self.EquipmentFrame, self.TitlesFrame}
    for _, frame in ipairs(frames) do
        if frame then
            if frame.HeaderTitle then
                frame.HeaderTitle:SetFont(font, 14, "NORMAL")
            end
            if frame.VerticalLabel then
                -- Mise à jour également du label vertical quand l'accordéon est fermé
                frame.VerticalLabel:SetFont(font, 14, "NORMAL")
            end
        end
    end
end

function MainMixin:UpdateAll()
    self:UpdateHeader()
    self:UpdateAccordionFonts() -- Appel ajouté ici pour mise à jour instantanée
    for _, slotFrame in pairs(self.slots) do slotFrame:UpdateInfo() end
    if self.StatsFrame and self.StatsFrame.UpdateStats then self.StatsFrame:UpdateStats() end
    if self.TitlesFrame and self.TitlesFrame.UpdateTitles then self.TitlesFrame:UpdateTitles() end
    if self.CoinFrame and self.CoinFrame:IsShown() and self.CoinFrame.Update then self.CoinFrame:Update() end
    if self.ReputationFrame and self.ReputationFrame:IsShown() and self.ReputationFrame.Update then self.ReputationFrame:Update() end
end