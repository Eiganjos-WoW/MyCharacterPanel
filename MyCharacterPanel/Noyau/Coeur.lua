local addonName, addon = ...
local isReskinned      = false

-- Change la police d'un texte sans faire d'erreur
addon.SafeSetFont      = function(fontString, path, size, flags)
    if not fontString then return end
    local ok, success = pcall(function() return fontString:SetFont(path, size, flags) end)
    if not ok or not success then
        fontString:SetFont(STANDARD_TEXT_FONT, size, flags)
    end
end

-- Met les options par défaut si elles n'existent pas
local function InitializeDefaults()
    _G["MCP_Config"] = _G["MCP_Config"] or {}
    addon.Config = _G["MCP_Config"]

    local defaults = {
        Scale = 1.0,
        DefaultTab = 1,
        ShowItemName = true,
    }
    for k, v in pairs(defaults) do
        if addon.Config[k] == nil then addon.Config[k] = v end
    end
end

-- Met à jour l'affichage de la fenêtre personnage
local function UpdateView()
    if not CharacterFrame:IsShown() then return end

    local selectedTab = PanelTemplates_GetSelectedTab(CharacterFrame) or 1
    local shouldBeReskinned = true

    if shouldBeReskinned ~= isReskinned then
        isReskinned = shouldBeReskinned
        if isReskinned then
            addon.Outils.ToggleNative(false)
            CharacterFrame:SetAlpha(0)

            if MCP_RestorePosition then MCP_RestorePosition() end

            CharacterFrame:SetClampedToScreen(true)
            CharacterFrame:SetClampRectInsets(0, 0, 0, 0)
            CharacterFrame:SetHitRectInsets(0, 0, 0, 0)
            CharacterFrame:SetMovable(true)
            CharacterFrame:EnableMouse(true)

            if CharacterFrame.MCP_MainBG then CharacterFrame.MCP_MainBG:Show() end
            if CharacterFrame.MCP_Border then CharacterFrame.MCP_Border:Show() end

            if CharacterFrameCloseButton then
                CharacterFrameCloseButton:ClearAllPoints()
                CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", -8, -8)
                CharacterFrameCloseButton:SetNormalTexture("")
                CharacterFrameCloseButton:SetNormalAtlas("uitools-icon-close")
                CharacterFrameCloseButton:SetPushedAtlas("uitools-icon-close")
                CharacterFrameCloseButton:SetDisabledAtlas("uitools-icon-close")
                CharacterFrameCloseButton:SetHighlightAtlas("uitools-icon-close")
                CharacterFrameCloseButton:SetSize(32, 32)
                CharacterFrameCloseButton:SetFrameStrata("HIGH")
            end

            local rightInset = CharacterFrameInsetRight
            if rightInset then rightInset:Hide() end
        else
            CharacterFrame:SetScript("OnMouseWheel", nil)
            CharacterFrame:EnableMouseWheel(false)
            CharacterFrame:SetMovable(false)
            addon.Outils.ToggleNative(true)

            if CharacterFrameCloseButton then
                CharacterFrameCloseButton:ClearAllPoints()
                CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 4, 5)
                CharacterFrameCloseButton:SetNormalAtlas("")
                CharacterFrameCloseButton:SetPushedAtlas("")
                CharacterFrameCloseButton:SetDisabledAtlas("")
                CharacterFrameCloseButton:SetHighlightAtlas("")
                CharacterFrameCloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
                CharacterFrameCloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
                CharacterFrameCloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
                CharacterFrameCloseButton:SetSize(32, 32)
            end

            CharacterFrame:SetWidth(addon.CONST.DEFAULT_WIDTH)
            CharacterFrame:SetHeight(addon.CONST.DEFAULT_HEIGHT)

            if CharacterFrame.MCP_Header then CharacterFrame.MCP_Header:Hide() end
            if CharacterFrame.MCP_MainBG then CharacterFrame.MCP_MainBG:Hide() end
            if CharacterFrame.MCP_Border then CharacterFrame.MCP_Border:Hide() end

            addon.Personnage:Hide()
            addon.Statistiques:Hide()
            if addon.Reputation and addon.Reputation.Hide then addon.Reputation:Hide() end
            if addon.Monnaies and addon.Monnaies.Hide then addon.Monnaies:Hide() end
        end
    end

    if isReskinned then
        local targetW = (selectedTab == 1) and addon.CONST.TOTAL_WIDTH or addon.CONST.TABS_WIDTH
        local targetScale = (addon.Config and addon.Config.Scale) or 1

        if CharacterFrame:GetWidth() ~= targetW then
            CharacterFrame:SetWidth(targetW)
        end
        if CharacterFrame:GetHeight() ~= addon.CONST.HEIGHT then
            CharacterFrame:SetHeight(addon.CONST.HEIGHT)
        end
        if CharacterFrame:GetScale() ~= targetScale then
            CharacterFrame:SetScale(targetScale)
        end
        CharacterFrame:SetAlpha(1)

        if selectedTab == 1 then
            if CharacterFrame.MCP_Header then
                CharacterFrame.MCP_Header:Show()
                addon.Personnage.UpdateHeader(CharacterFrame.MCP_Header)
            end
            addon.Personnage:UpdateLayout()
            addon.Statistiques:Update()
            if addon.Reputation and addon.Reputation.Hide then addon.Reputation:Hide() end
            if addon.Monnaies and addon.Monnaies.Hide then addon.Monnaies:Hide() end
        else
            if CharacterFrame.MCP_Header then CharacterFrame.MCP_Header:Hide() end
            addon.Personnage:Hide()
            addon.Statistiques:Hide()

            if selectedTab == 2 then
                if addon.Monnaies and addon.Monnaies.Hide then addon.Monnaies:Hide() end
                if addon.Reputation and addon.Reputation.Update then addon.Reputation:Update() end
            elseif selectedTab == 3 then
                if addon.Reputation and addon.Reputation.Hide then addon.Reputation:Hide() end
                if addon.Monnaies and addon.Monnaies.Update then addon.Monnaies:Update() end
            end
        end
    end
end

-- Prépare les fonds et les textures de la fenêtre
local function InitBackgrounds()
    if CharacterFrame.MCP_MainBG then return end

    local C = addon.CONST

    local header = CreateFrame("Frame", nil, CharacterFrame, "BackdropTemplate")
    header:SetSize(550, 60)

    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")

    local gvBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    gvBtn:SetSize(200, 32)
    gvBtn:SetPoint("CENTER", header, "CENTER", 0, 0)

    gvBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    gvBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    gvBtn:SetBackdropColor(0.1, 0.1, 0.1, 1)

    local gvWg = gvBtn:CreateTexture(nil, "BACKGROUND")
    gvWg:SetPoint("TOPLEFT", gvBtn, "TOPLEFT", 4, -4)
    gvWg:SetPoint("BOTTOMRIGHT", gvBtn, "BOTTOMRIGHT", -4, 4)
    gvWg:SetColorTexture(1, 1, 1, 1)
    gvWg:SetGradient("VERTICAL", CreateColor(0.35, 0.35, 0.35, 1), CreateColor(0.2, 0.2, 0.2, 1))
    gvBtn.wg = gvWg

    local gvHl = gvBtn:CreateTexture(nil, "HIGHLIGHT")
    gvHl:SetPoint("TOPLEFT", 4, -4)
    gvHl:SetPoint("BOTTOMRIGHT", -4, 4)
    gvHl:SetColorTexture(1, 1, 1, 0.05)
    gvHl:SetBlendMode("ADD")

    local gvGlow = gvBtn:CreateTexture(nil, "OVERLAY")
    gvGlow:SetPoint("TOPLEFT", 4, -4)
    gvGlow:SetPoint("BOTTOMRIGHT", -4, 4)
    gvGlow:SetColorTexture(1, 0.82, 0, 0.6) -- Plus doré et visible
    gvGlow:SetAlpha(0)
    gvGlow:SetBlendMode("ADD")
    gvBtn.Glow = gvGlow

    local pulseAnim = gvGlow:CreateAnimationGroup()
    pulseAnim:SetLooping("BOUNCE")
    local alphaAnim = pulseAnim:CreateAnimation("Alpha")
    alphaAnim:SetFromAlpha(0.2)
    alphaAnim:SetToAlpha(1)
    alphaAnim:SetDuration(0.8)
    alphaAnim:SetSmoothing("IN_OUT")
    gvBtn.PulseAnim = pulseAnim

    local gvText = gvBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gvText:SetPoint("CENTER", 0, 0)
    gvText:SetText(addon.L["GREAT_VAULT"])
    gvBtn.Text = gvText

    gvBtn:SetScript("OnMouseDown", function(self)
        if self.wg then
            self.wg:SetPoint("TOPLEFT", 5, -5)
            self.wg:SetPoint("BOTTOMRIGHT", -5, 5)
        end
        if self.Text then self.Text:SetPoint("CENTER", 1, -1) end
    end)
    gvBtn:SetScript("OnMouseUp", function(self)
        if self.wg then
            self.wg:SetPoint("TOPLEFT", 4, -4)
            self.wg:SetPoint("BOTTOMRIGHT", -4, 4)
        end
        if self.Text then self.Text:SetPoint("CENTER", 0, 0) end
    end)

    gvBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(addon.L["GREAT_VAULT"], 1, 1, 1, 1)
        if self.hasReward then
            GameTooltip:AddLine(addon.L["REWARD_AVAILABLE"], 0, 1, 0)
        end
        GameTooltip:Show()
    end)
    gvBtn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    gvBtn:SetScript("OnClick", function()
        if gvBtn.wg then
            gvBtn.wg:SetPoint("TOPLEFT", 4, -4)
            gvBtn.wg:SetPoint("BOTTOMRIGHT", -4, 4)
        end
        if gvBtn.Text then gvBtn.Text:SetPoint("CENTER", 0, 0) end

        if not _G["WeeklyRewardsFrame"] then
            C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
        end

        local gvFrame = _G["WeeklyRewardsFrame"]
        if gvFrame then
            if gvFrame:IsShown() then
                gvFrame:Hide()
            else
                gvFrame:Show()
                -- Ajout à UISpecialFrames pour permettre de fermer avec Echap
                if not gvFrame.mcp_hooked_escape then
                    tinsert(UISpecialFrames, "WeeklyRewardsFrame")
                    gvFrame.mcp_hooked_escape = true
                end
            end
            gvFrame:SetFrameLevel(CharacterFrame:GetFrameLevel() + 50)
        end
    end)

    header.GVButton = gvBtn
    header:SetPoint("TOP", CharacterFrame, "TOP", 0, -15)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")

    MCP_SavePosition, MCP_RestorePosition = addon.Outils.InitDeplacementFenetre(
        CharacterFrame,
        { CharacterFrame, PaperDollFrame, PaperDollItemsFrame },
        function() return isReskinned end
    )

    -- Drag du header : réancrage explicite avant StartMoving pour éviter le décalage
    header:SetScript("OnDragStart", function()
        if not isReskinned or InCombatLockdown() then return end
        local left = CharacterFrame:GetLeft()
        local top  = CharacterFrame:GetTop()
        if left and top then
            CharacterFrame:ClearAllPoints()
            CharacterFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top - UIParent:GetHeight())
        end
        CharacterFrame:SetMovable(true)
        CharacterFrame:SetUserPlaced(true)
        CharacterFrame.mcp_isDragging = true
        CharacterFrame:StartMoving()
    end)
    header:SetScript("OnDragStop", function()
        CharacterFrame:StopMovingOrSizing()
        CharacterFrame.mcp_isDragging = false
        if MCP_SavePosition then MCP_SavePosition() end
    end)

    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    header:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    header:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

    local hBg = header:CreateTexture(nil, "BACKGROUND", nil, 1)
    hBg:SetPoint("TOPLEFT", 4, -4)
    hBg:SetPoint("BOTTOMRIGHT", -4, 4)
    hBg:SetColorTexture(0.08, 0.08, 0.08, 1)

    local cIcon = header:CreateTexture(nil, "ARTWORK", nil, 2)
    cIcon:SetSize(45, 45)
    cIcon:SetPoint("LEFT", 10, 0)
    cIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    local cMask = header:CreateMaskTexture()
    cMask:SetTexture(C.MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    cMask:SetAllPoints(cIcon)
    cIcon:AddMaskTexture(cMask)
    header.ClassIcon = cIcon

    local name = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("BOTTOMLEFT", cIcon, "RIGHT", 10, 2)
    header.Name = name

    local lvl = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lvl:SetPoint("TOPLEFT", cIcon, "RIGHT", 10, 0)
    lvl:SetTextColor(0.8, 0.8, 0.8)
    header.Level = lvl

    local sIcon = header:CreateTexture(nil, "ARTWORK", nil, 3)
    sIcon:SetSize(22, 22)
    sIcon:SetPoint("BOTTOMRIGHT", cIcon, "BOTTOMRIGHT", 6, -2)
    local sMask = header:CreateMaskTexture()
    sMask:SetTexture(C.MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    sMask:SetAllPoints(sIcon)
    sIcon:AddMaskTexture(sMask)
    sIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    header.SpecIcon = sIcon

    local score = header:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Large")
    score:SetPoint("RIGHT", -15, 0)
    header.Score = score
    CharacterFrame.MCP_Header = header

    if not CharacterFrame.MCP_MainBG then
        local mainBg = CharacterFrame:CreateTexture(nil, "BACKGROUND")
        mainBg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 4, -4)
        mainBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -4, 4)
        mainBg:SetAtlas("talents-heroclass-choicepopup-background")
        mainBg:SetDesaturated(true)
        mainBg:SetVertexColor(1, 1, 1, 1)
        mainBg:SetTexCoord(0, 1, 0, 1)
        CharacterFrame.MCP_MainBG = mainBg
    end

    local border = CreateFrame("Frame", nil, CharacterFrame, "BackdropTemplate")
    border:SetAllPoints(CharacterFrame)
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    CharacterFrame.MCP_Border = border
end

-- Fonction qui lance tout au démarrage de l'addon
local function Init()
    InitBackgrounds()

    if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then
        C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
    end

    local allSlots = {}
    for _, n in ipairs(addon.CONST.LEFT_SLOTS) do table.insert(allSlots, n) end
    for _, n in ipairs(addon.CONST.RIGHT_SLOTS) do table.insert(allSlots, n) end
    table.insert(allSlots, "CharacterMainHandSlot")
    table.insert(allSlots, "CharacterSecondaryHandSlot")
    for _, sn in ipairs(allSlots) do
        local s = _G[sn]
        if s then addon.Personnage.UpdateSlot(s) end
    end

    for i = 1, 3 do
        local tab = _G["CharacterFrameTab" .. i]
        if tab then
            tab:HookScript("OnClick", function()
                if isReskinned then
                    UpdateView()
                end
            end)
        end
    end

    UpdateView()
end

-- Création d'une frame pour écouter les événements du jeu
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializeDefaults()
        Init()
        if MCP_RestorePosition then MCP_RestorePosition() end
    elseif event == "ADDON_LOADED" and ... == addonName then
        InitializeDefaults()
    elseif event == "ADDON_LOADED" and ... == "Blizzard_CharacterFrame" then
        Init()
    end
end)


-- Force la mise à jour quand on ouvre la fenêtre
CharacterFrame:HookScript("OnShow", function()
    MCP_RestorePosition()
    UpdateView()
end)

-- Met à jour la vue quand on utilise la fonction de base
hooksecurefunc("ToggleCharacter", function() C_Timer.After(0.01, UpdateView) end)

-- Met à jour les emplacements d'objets
hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
    if self:GetName() and self:GetName():find("Character") then
        C_Timer.After(0, function()
            addon.Personnage.UpdateSlot(self)
        end)
    end
end)

-- Garde la bonne échelle pour la fenêtre
hooksecurefunc(CharacterFrame, "SetScale", function(self, scale)
    if isReskinned and addon.Config and addon.Config.Scale then
        if scale ~= addon.Config.Scale and not self.mcp_isSettingScale then
            self.mcp_isSettingScale = true
            self:SetScale(addon.Config.Scale)
            self.mcp_isSettingScale = false
        end
    end
end)

-- Garde la bonne largeur pour la fenêtre
hooksecurefunc(CharacterFrame, "SetWidth", function(self, width)
    if isReskinned and not self.mcp_isSettingWidth then
        local sel = PanelTemplates_GetSelectedTab(self) or 1
        local target = (sel == 1) and addon.CONST.TOTAL_WIDTH or addon.CONST.TABS_WIDTH
        if width ~= target then
            self.mcp_isSettingWidth = true
            self:SetWidth(target)
            self.mcp_isSettingWidth = false
        end
    end
end)

-- Garde la bonne hauteur pour la fenêtre
hooksecurefunc(CharacterFrame, "SetHeight", function(self, height)
    if isReskinned and not self.mcp_isSettingHeight then
        if height ~= addon.CONST.HEIGHT then
            self.mcp_isSettingHeight = true
            self:SetHeight(addon.CONST.HEIGHT)
            self.mcp_isSettingHeight = false
        end
    end
end)

-- Garde la bonne position pour la fenêtre
hooksecurefunc(CharacterFrame, "SetPoint", function(self)
    if isReskinned and addon.Config and addon.Config.CharFrameX and not self.mcp_isSettingPoint and not self.mcp_isDragging and not InCombatLockdown() then
        self.mcp_isSettingPoint = true
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", addon.Config.CharFrameX, addon.Config.CharFrameY)
        self.mcp_isSettingPoint = false
    end
end)
