local addonName, addon = ...
addon.Options = {}

-- Les réglages de base
local DEFAULT_CONFIG = {
    TutorialSeen             = false,
    DefaultTab               = 1,
    Scale                    = 1.0,
    InspectScale             = 1.0,

    -- Réglages généraux
    ItemNameLength           = 33,
    ItemNameLengthTabard     = 23,
    HoverScroll              = true,
    EnchantRankOnly          = false,

    HeaderPlayerNameFont     = "Friz Quadrata TT",
    HeaderPlayerNameSize     = 16,
    HeaderPlayerLevelFont    = "Friz Quadrata TT",
    HeaderPlayerLevelSize    = 12,
    HeaderMythicPlusFont     = "Friz Quadrata TT",
    HeaderMythicPlusSize     = 22,
    HeaderGreatVaultFont     = "Friz Quadrata TT",
    HeaderGreatVaultSize     = 12,

    -- Pour l'affichage
    ShowIlvl                 = true,
    ShowFlyoutIlvl           = true,
    ShowEnchant              = true,
    ShowUpgrade              = true,

    -- Où est-ce qu'on affiche "Non enchanté" (IDs de WoW)
    -- false = bijoux (11,12,13,14), back (16)
    ShowNotEnchanted_1       = true,  -- Tête
    ShowNotEnchanted_2       = true,  -- Cou
    ShowNotEnchanted_3       = true,  -- Épaules
    ShowNotEnchanted_5       = true,  -- Torse
    ShowNotEnchanted_6       = true,  -- Ceinture
    ShowNotEnchanted_7       = true,  -- Jambes
    ShowNotEnchanted_8       = true,  -- Pieds
    ShowNotEnchanted_9       = true,  -- Poignets
    ShowNotEnchanted_10      = true,  -- Mains
    ShowNotEnchanted_11      = true,  -- Bague 1
    ShowNotEnchanted_12      = true,  -- Bague 2
    ShowNotEnchanted_13      = false, -- Bijoux 1
    ShowNotEnchanted_14      = false, -- Bijoux 2
    ShowNotEnchanted_15      = true,  -- Dos
    ShowNotEnchanted_16      = false, -- Main gauche

    -- Pour les gemmes
    ShowGems                 = true,
    GemSize                  = 16,
    Gem1X                    = 6,
    Gem1Y                    = 0,
    Gem2X                    = 14,
    Gem2Y                    = -15,
    Gem3X                    = 6,
    Gem3Y                    = -30,

    -- Réglages de la police pour le nom des objets
    ItemNameFont             = "Friz Quadrata TT",
    ItemNameSize             = 12,
    ItemNameLeftOffsetX      = 0,
    ItemNameLeftOffsetY      = 0,
    ItemNameRightOffsetX     = 0,
    ItemNameRightOffsetY     = 0,

    -- Réglages de la police pour l'ilvl
    ItemLevelFont            = "Friz Quadrata TT",
    ItemLevelSize            = 16,
    ItemLevelLeftOffsetX     = 0,
    ItemLevelLeftOffsetY     = 0,
    ItemLevelRightOffsetX    = 0,
    ItemLevelRightOffsetY    = 0,

    -- Réglages de la police pour l'amélioration
    UpgradeLevelFont         = "Friz Quadrata TT",
    UpgradeLevelSize         = 10,
    UpgradeLevelLeftOffsetX  = 0,
    UpgradeLevelLeftOffsetY  = 0,
    UpgradeLevelRightOffsetX = 0,
    UpgradeLevelRightOffsetY = 0,

    -- Réglages de la police pour l'enchantement
    EnchantFont              = "Friz Quadrata TT",
    EnchantSize              = 9,
    EnchantLeftOffsetX       = 0,
    EnchantLeftOffsetY       = 0,
    EnchantRightOffsetX      = 0,
    EnchantRightOffsetY      = 0,

    -- Pour les titres des accordéons (Caractéristiques, Améliorations)
    AccordionTitleFont       = "Friz Quadrata TT",
    AccordionTitleSize       = 14,

    -- Pour le gros chiffre de l'ilvl dans l'accordéon
    AccordionIlvlFont        = "Friz Quadrata TT",
    AccordionIlvlSize        = 40,

    -- Pour les onglets sur le côté (Stats, Equipement, Titres)
    AccordionTabFont         = "Friz Quadrata TT",
    AccordionTabSize         = 14,

    -- Pour les noms des stats dans les accordéons
    AccordionStatLabelFont   = "Friz Quadrata TT",
    AccordionStatLabelSize   = 12,
}

local optionsFrame = nil
local optionsButton = nil

-- Met les options par défaut si elles n'existent pas
local function InitializeConfig()
    if not addon.Config then
        addon.Config = {}
    end
    for k, v in pairs(DEFAULT_CONFIG) do
        if addon.Config[k] == nil then
            addon.Config[k] = v
        end
    end
end

-- Applique les réglages de l'addon immédiatement
function addon.Options.ApplyConfig()
    if not addon.Config then return end
    if CharacterFrame then
        if CharacterFrame:IsShown() and MCP_RestorePosition then
            MCP_RestorePosition()
        end
        if CharacterFrame:IsShown() and not addon.Options.hasSetDefaultTab then
            addon.Options.hasSetDefaultTab = true
            if addon.Config.DefaultTab and addon.Config.DefaultTab ~= 1 then
                if addon.Config.DefaultTab == 2 and PaperDollSidebarTab2 then
                    PaperDollSidebarTab2:Click()
                elseif addon.Config.DefaultTab == 3 and PaperDollSidebarTab3 then
                    PaperDollSidebarTab3:Click()
                end
            end
        end
    end
end

-- Force la mise à jour des cases d'équipement
function addon.Options.ForceUpdateAllSlots()
    if addon.CONST then
        if CharacterFrame and CharacterFrame:IsShown() and addon.Personnage and addon.Personnage.UpdateSlot then
            local allSlots = {}
            if addon.CONST.LEFT_SLOTS then
                for _, n in ipairs(addon.CONST.LEFT_SLOTS) do table.insert(allSlots, n) end
            end
            if addon.CONST.RIGHT_SLOTS then
                for _, n in ipairs(addon.CONST.RIGHT_SLOTS) do table.insert(allSlots, n) end
            end
            table.insert(allSlots, "CharacterMainHandSlot")
            table.insert(allSlots, "CharacterSecondaryHandSlot")

            for _, sn in ipairs(allSlots) do
                local s = _G[sn]
                if s and s.MCP_VisualsCreated then addon.Personnage.UpdateSlot(s) end
            end
        end

        if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateSlot then
            local inspectLeft = { "InspectHeadSlot", "InspectNeckSlot", "InspectShoulderSlot", "InspectBackSlot",
                "InspectChestSlot", "InspectShirtSlot", "InspectTabardSlot", "InspectWristSlot" }
            local inspectRight = { "InspectHandsSlot", "InspectWaistSlot", "InspectLegsSlot", "InspectFeetSlot",
                "InspectFinger0Slot", "InspectFinger1Slot", "InspectTrinket0Slot", "InspectTrinket1Slot" }

            for _, sn in ipairs(inspectLeft) do
                local s = _G[sn]
                if s and s.MCP_VisualsCreated then addon.Inspection.UpdateSlot(s) end
            end
            for _, sn in ipairs(inspectRight) do
                local s = _G[sn]
                if s and s.MCP_VisualsCreated then addon.Inspection.UpdateSlot(s) end
            end
            if _G["InspectMainHandSlot"] and _G["InspectMainHandSlot"].MCP_VisualsCreated then
                addon.Inspection
                    .UpdateSlot(_G["InspectMainHandSlot"])
            end
            if _G["InspectSecondaryHandSlot"] and _G["InspectSecondaryHandSlot"].MCP_VisualsCreated then
                addon
                    .Inspection.UpdateSlot(_G["InspectSecondaryHandSlot"])
            end
        end
        if addon.Options.UpdateGemSimulator and _G["MCPOptionsFrame"] and _G["MCPOptionsFrame"]:IsShown() then
            addon.Options.UpdateGemSimulator()
        end
    end
end

-- Pour créer la fenêtre des réglages
local function CreateOptionsUI()
    if optionsFrame then return end

    local L = addon.L
    local frame = CreateFrame("Frame", "MCPOptionsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(650, 800)
    -- On la pose à un endroit par défaut (elle bougera quand on l'ouvre)
    frame:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -800, -100)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetUserPlaced(true)
        self.isUserMoved = true
    end)
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Pour pouvoir fermer avec la touche Echap
    tinsert(UISpecialFrames, "MCPOptionsFrame")

    local titleContainer = CreateFrame("Frame", nil, frame)
    titleContainer:SetHeight(32)
    titleContainer:SetPoint("TOP", 0, -8)

    -- Le logo qui bouge un peu (halo et pulsation)
    local addonLogo = titleContainer:CreateTexture(nil, "ARTWORK")
    addonLogo:SetSize(32, 32)
    addonLogo:SetTexture("Interface\\AddOns\\MyCharacterPanel\\logo\\mcpaddon.png")
    addonLogo:SetPoint("LEFT", titleContainer, "LEFT", 0, 0)

    -- Une petite lumière derrière le logo
    local logoGlow = titleContainer:CreateTexture(nil, "BACKGROUND")
    logoGlow:SetSize(56, 56)
    logoGlow:SetPoint("CENTER", addonLogo, "CENTER", 0, 0)
    logoGlow:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    logoGlow:SetBlendMode("ADD")
    logoGlow:SetVertexColor(1, 0.82, 0, 0.5)

    -- Une petite animation de respiration
    local pulseGrp = logoGlow:CreateAnimationGroup()
    pulseGrp:SetLooping("BOUNCE")
    local alphaAnim = pulseGrp:CreateAnimation("Alpha")
    alphaAnim:SetFromAlpha(0.2)
    alphaAnim:SetToAlpha(0.7)
    alphaAnim:SetDuration(2.5)
    alphaAnim:SetSmoothing("IN_OUT")
    pulseGrp:Play()

    -- Le titre principal de l'addon
    local title = titleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetText(L["ADDON_TITLE"])
    title:SetPoint("TOPLEFT", addonLogo, "TOPRIGHT", 8, -2)
    title:SetTextColor(1, 0.82, 0) -- Or brillant
    title:SetShadowOffset(1, -1)
    title:SetShadowColor(0, 0, 0, 1)

    -- Le petit texte en dessous "Paramètres"
    local subTitle = titleContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subTitle:SetText(L["OPTIONS_TITLE"])
    subTitle:SetPoint("BOTTOMLEFT", addonLogo, "BOTTOMRIGHT", 8, 4)
    subTitle:SetTextColor(0.7, 0.7, 0.7)

    -- Une jolie ligne de séparation
    local titleLine = titleContainer:CreateTexture(nil, "ARTWORK")
    titleLine:SetHeight(1)
    titleLine:SetPoint("TOPLEFT", subTitle, "BOTTOMLEFT", 0, -2)
    titleLine:SetPoint("RIGHT", titleContainer, "RIGHT", 40, 0)
    titleLine:SetColorTexture(1, 1, 1)
    titleLine:SetGradient("HORIZONTAL", CreateColor(1, 0.82, 0, 0.8), CreateColor(1, 0.82, 0, 0))

    -- On ajuste la largeur tout seul selon le texte
    local maxW = title:GetStringWidth()
    local subW = subTitle:GetStringWidth()
    if maxW < subW then maxW = subW end
    if maxW < 50 then maxW = 120 end
    titleContainer:SetWidth(32 + 8 + maxW)

    -- Le menu sur le côté gauche
    local leftMenu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    leftMenu:SetPoint("TOPLEFT", 10, -45) -- Remonté pour fermer le gap
    leftMenu:SetPoint("BOTTOMLEFT", 10, 95)
    leftMenu:SetWidth(150)
    leftMenu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    leftMenu:SetBackdropColor(0, 0, 0, 0.5)

    -- Le contenu sur le côté droit
    local rightContentContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    rightContentContainer:SetPoint("TOPLEFT", leftMenu, "TOPRIGHT", 10, 0)
    rightContentContainer:SetPoint("BOTTOMRIGHT", -10, 105)
    rightContentContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    rightContentContainer:SetBackdropColor(0, 0, 0, 0.5)

    -- Pour pouvoir faire défiler le contenu à droite
    local scrollFrame = CreateFrame("ScrollFrame", "MCPOptionsScrollFrame", rightContentContainer)
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -35, 5)

    -- Le cadre qui bouge quand on scroll
    local rightContent = CreateFrame("Frame", nil, scrollFrame)
    rightContent:SetSize(420, 1000)
    scrollFrame:SetScrollChild(rightContent)

    -- La barre de défilement sur le côté (bien visible)
    local scrollBar = CreateFrame("Slider", nil, rightContentContainer, "BackdropTemplate")
    scrollBar:SetPoint("TOPRIGHT", -8, -10)
    scrollBar:SetPoint("BOTTOMRIGHT", -8, 10)
    scrollBar:SetWidth(18)
    scrollBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    scrollBar:SetBackdropColor(0, 0, 0, 0.8)
    scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    scrollBar:SetMinMaxValues(0, 100)
    scrollBar:SetValueStep(1)
    scrollBar:SetValue(0)
    scrollBar:SetOrientation("VERTICAL")
    scrollBar:EnableMouseWheel(true)

    -- Le petit curseur qu'on attrape pour scroller
    local thumb = scrollBar:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(14, 40)
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetVertexColor(0.8, 0.6, 0, 1) -- Or
    scrollBar:SetThumbTexture(thumb)

    -- Comment ça bouge quand on scroll avec la souris
    scrollBar:SetScript("OnValueChanged", function(self, value)
        scrollFrame:SetVerticalScroll(value)
    end)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur = scrollBar:GetValue()
        local minV, maxV = scrollBar:GetMinMaxValues()
        if delta > 0 then
            scrollBar:SetValue(math.max(minV, cur - 30))
        else
            scrollBar:SetValue(math.min(maxV, cur + 30))
        end
    end)
    scrollBar:SetScript("OnMouseWheel", function(self, delta)
        scrollFrame:GetScript("OnMouseWheel")(scrollFrame, delta)
    end)

    -- Stockage pour mise à jour dynamique de la hauteur
    addon.Options.ScrollBar = scrollBar
    addon.Options.ScrollFrame = scrollFrame

    -- Ici c'est le bas de la fenêtre (le pied de page)
    -- Pour nous dire s'il y a un bug ou un problème
    local reportBanner = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    reportBanner:SetHeight(38)
    reportBanner:SetPoint("BOTTOMLEFT", 10, 50)
    reportBanner:SetPoint("BOTTOMRIGHT", -10, 50)
    reportBanner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    reportBanner:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    reportBanner:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local linkBox = CreateFrame("EditBox", nil, reportBanner, "InputBoxTemplate")
    linkBox:SetSize(220, 20)
    linkBox:SetPoint("LEFT", reportBanner, "CENTER", -20, 0)
    linkBox:SetAutoFocus(false)
    linkBox:SetFontObject("GameFontHighlightSmall")
    linkBox:SetText(L["OPT_ISSUE_URL"])
    linkBox:SetCursorPosition(0)
    linkBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local linkLabel = reportBanner:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    linkLabel:SetPoint("RIGHT", linkBox, "LEFT", -10, 0)
    linkLabel:SetText(L["OPT_GEM_REPORT"])
    linkLabel:SetTextColor(1, 0.82, 0) -- Or brillant Blizzard

    -- Une petite note en bas pour les crédits
    local devNote = CreateFrame("Frame", nil, frame)
    devNote:SetHeight(40)
    devNote:SetPoint("BOTTOMLEFT", 10, 5)
    devNote:SetPoint("BOTTOMRIGHT", -10, 5)

    -- --- LIGNE 1 : DÉVELOPPEUR (Eiganjos) ---
    local line1 = CreateFrame("Frame", nil, devNote)
    line1:SetHeight(18)
    line1:SetPoint("TOP", 0, 0)

    -- Drapeau FR
    local fr1 = line1:CreateTexture(nil, "ARTWORK")
    fr1:SetSize(14, 14)
    fr1:SetTexture("Interface\\AddOns\\MyCharacterPanel\\logo\\Fr.png")
    fr1:SetPoint("LEFT", 0, 0)
    local m1 = line1:CreateMaskTexture()
    m1:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    m1:SetSize(14, 14)
    m1:SetPoint("CENTER", fr1, "CENTER")
    fr1:AddMaskTexture(m1)

    -- Pseudo Dev
    local devText = line1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    devText:SetPoint("LEFT", fr1, "RIGHT", 6, 0)
    devText:SetText("|cffffffff" .. L["OPT_DEV_NOTE"] .. "|r")

    -- Icone Shaman
    local sham = line1:CreateTexture(nil, "ARTWORK")
    sham:SetSize(14, 14)
    sham:SetTexture("Interface\\Icons\\ClassIcon_Shaman")
    sham:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    sham:SetPoint("LEFT", devText, "RIGHT", 6, 0)
    local m2 = line1:CreateMaskTexture()
    m2:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    m2:SetSize(14, 14)
    m2:SetPoint("CENTER", sham, "CENTER")
    sham:AddMaskTexture(m2)

    line1:SetWidth(14 + 6 + devText:GetStringWidth() + 6 + 14)

    -- --- LIGNE 2 : BÉTA TESTEUR (Gyeo) ---
    local line2 = CreateFrame("Frame", nil, devNote)
    line2:SetHeight(16)
    line2:SetPoint("TOP", line1, "BOTTOM", 0, -2)

    -- Drapeau FR (Gyeo)
    local fr2 = line2:CreateTexture(nil, "ARTWORK")
    fr2:SetSize(12, 12)
    fr2:SetTexture("Interface\\AddOns\\MyCharacterPanel\\logo\\Fr.png")
    fr2:SetPoint("LEFT", 0, 0)
    local m3 = line2:CreateMaskTexture()
    m3:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    m3:SetSize(12, 12)
    m3:SetPoint("CENTER", fr2, "CENTER")
    fr2:AddMaskTexture(m3)

    -- Pseudo Beta
    local betaText = line2:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    betaText:SetPoint("LEFT", fr2, "RIGHT", 5, 0)
    betaText:SetText("|cffaaaaaa" .. L["OPT_BETA_NOTE"] .. "|r")


    -- Icone Guerrier
    local war = line2:CreateTexture(nil, "ARTWORK")
    war:SetSize(12, 12)
    war:SetTexture("Interface\\Icons\\ClassIcon_Warrior")
    war:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    war:SetPoint("LEFT", betaText, "RIGHT", 5, 0)
    local m4 = line2:CreateMaskTexture()
    m4:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    m4:SetSize(12, 12)
    m4:SetPoint("CENTER", war, "CENTER")
    war:AddMaskTexture(m4)

    line2:SetWidth(12 + 5 + betaText:GetStringWidth() + 5 + 12)

    -- === GEM SIMULATOR WINDOW (Attached to the right) ===
    local gemSimulatorFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    gemSimulatorFrame:SetSize(220, 220)
    gemSimulatorFrame:SetPoint("LEFT", frame, "RIGHT", -5, 0)
    gemSimulatorFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    gemSimulatorFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
    gemSimulatorFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    gemSimulatorFrame:Hide()

    local simTitle = gemSimulatorFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    simTitle:SetPoint("TOP", 0, -15)
    simTitle:SetText(L["OPT_SIMULATION_TITLE"])

    local simSlot = CreateFrame("Frame", nil, gemSimulatorFrame)
    simSlot:SetSize(36, 36)
    simSlot:SetPoint("CENTER", -20, 0)

    local simIconBg = simSlot:CreateTexture(nil, "BACKGROUND")
    simIconBg:SetAllPoints()
    simIconBg:SetTexture("Interface\\Icons\\INV_Helmet_02")

    -- Masque pour que ça soit propre
    local m1 = simSlot:CreateMaskTexture()
    m1:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m1:SetSize(36, 36)
    m1:SetPoint("CENTER")
    simIconBg:AddMaskTexture(m1)

    -- Masque pour l'effet tourné
    local m2 = simSlot:CreateMaskTexture()
    m2:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m2:SetSize(36, 36)
    m2:SetPoint("CENTER")
    m2:SetRotation(math.rad(45))
    simIconBg:AddMaskTexture(m2)

    -- Fond sombre derrière l'icône
    local simBg = simSlot:CreateTexture(nil, "BACKGROUND", nil, -1)
    simBg:SetAllPoints()
    simBg:SetColorTexture(0, 0, 0, 0.4)
    simBg:AddMaskTexture(m1)
    simBg:AddMaskTexture(m2)

    -- Pour faire une bordure octogonale (8 côtés)
    local radius = 36 / 2
    local sideLength = 2 * radius * 0.414
    local thickness = 2
    for i = 0, 7 do
        local angleDeg = i * 45
        local angleRad = math.rad(angleDeg)
        local line = simSlot:CreateTexture(nil, "OVERLAY")
        line:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        line:SetSize(sideLength + (thickness * 0.45), thickness)
        local cx = radius * math.cos(angleRad)
        local cy = radius * math.sin(angleRad)
        line:SetPoint("CENTER", simSlot, "CENTER", cx, cy)
        line:SetRotation(angleRad + math.pi / 2)
        local r, g, b = C_Item.GetItemQualityColor(4) -- Epic purple for test
        line:SetVertexColor(r or 0.64, g or 0.21, b or 0.93)
    end

    gemSimulatorFrame.Gems = {}
    for i = 1, 3 do
        local container = CreateFrame("Frame", nil, simSlot)
        local g = container:CreateTexture(nil, "ARTWORK")
        g:SetPoint("CENTER")
        g:SetTexCoord(0.03, 0.97, 0.03, 0.97)

        local mask = container:CreateMaskTexture()
        mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        mask:SetPoint("CENTER")
        g:AddMaskTexture(mask)

        local bg = container:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        bg:SetVertexColor(0, 0, 0, 1)
        bg:SetPoint("CENTER")

        local bgMask = container:CreateMaskTexture()
        bgMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        bgMask:SetPoint("CENTER")
        bg:AddMaskTexture(bgMask)

        local ring = container:CreateTexture(nil, "OVERLAY")
        ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        ring:SetVertexColor(0, 0, 0, 0.5)
        ring:SetPoint("CENTER")
        ring:SetBlendMode("ADD")

        container.Texture = g
        container.Mask = mask
        container.Ring = ring
        container.Background = bg
        container.BgMask = bgMask

        table.insert(gemSimulatorFrame.Gems, container)
    end

    addon.Options.UpdateGemSimulator = function()
        local gemSize = (addon.Config and addon.Config.GemSize) or 16
        local stepY = (addon.Config and addon.Config.GemStepY) or 15
        local stepX = (addon.Config and addon.Config.GemStepX) or 5
        local startX = (addon.Config and addon.Config.GemStartX) or 6
        local startY = (addon.Config and addon.Config.GemStartY) or -2

        local gemIcons = {
            "Interface\\Icons\\inv_jewelcrafting_gem_37", -- Red
            "Interface\\Icons\\inv_jewelcrafting_gem_38", -- Blue
            "Interface\\Icons\\inv_jewelcrafting_gem_39"  -- Yellow
        }

        for i, gem in ipairs(gemSimulatorFrame.Gems) do
            gem:SetSize(gemSize + 4, gemSize + 4)
            gem.Texture:SetSize(gemSize, gemSize)
            gem.Mask:SetSize(gemSize, gemSize)
            gem.Ring:SetSize(gemSize + 2, gemSize + 2)
            gem.Background:SetSize(gemSize + 2, gemSize + 2)
            gem.BgMask:SetSize(gemSize + 2, gemSize + 2)

            gem:ClearAllPoints()
            local offsetX = startX + ((i - 1) * stepX)
            local offsetY = startY - ((i - 1) * stepY)
            -- Position relative to sim slot
            gem:SetPoint("CENTER", simSlot, "TOPRIGHT", offsetX, offsetY)

            gem.Texture:SetTexture(gemIcons[i])
            gem.Texture:SetVertexColor(1, 1, 1)
            gem.Ring:Show()
        end
    end
    local categories = {}
    local activeTab = nil

    local function CreateCheckbox(parent, label, configKey, requiresReload, yOffset, tooltipText)
        local btn = CreateFrame("CheckButton", nil, parent)
        btn:SetSize(20, 20)
        btn:SetPoint("TOPLEFT", 20, yOffset)

        -- On fait un look personnalisé pour les cases à cocher
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetColorTexture(0.5, 0.5, 0.5, 1)

        local bg = btn:CreateTexture(nil, "BORDER")
        bg:SetPoint("TOPLEFT", 1, -1)
        bg:SetPoint("BOTTOMRIGHT", -1, 1)
        bg:SetColorTexture(0.1, 0.1, 0.1, 1)

        local chk = btn:CreateTexture(nil, "OVERLAY")
        chk:SetColorTexture(0.2, 0.8, 0.2, 1)
        chk:SetPoint("TOPLEFT", 4, -4)
        chk:SetPoint("BOTTOMRIGHT", -4, 4)
        btn:SetCheckedTexture(chk)

        btn:SetChecked(addon.Config[configKey])

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        text:SetWidth(300) -- On limite la largeur pour pas que ça dépasse
        text:SetWordWrap(true)
        text:SetJustifyH("LEFT")
        text:SetText(label)

        btn:SetScript("OnClick", function(self)
            addon.Config[configKey] = self:GetChecked()
            if addon.Personnage and addon.Personnage.UpdateLayout then
                addon.Personnage:UpdateLayout()
            end
            if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateLayout then
                addon.Inspection:UpdateLayout()
            end
            addon.Options.ForceUpdateAllSlots()
            addon.Options.ApplyConfig()
        end)

        if tooltipText then
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(label, 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end

        return btn
    end

    local function CreateSlider(parent, label, configKey, minV, maxV, stepV, yOffset)
        local sliderBaseName = "MCPOptCustomSlid_" .. configKey

        -- Le cadre qui contient tout le réglage
        local container = CreateFrame("Frame", nil, parent)
        container:SetSize(400, 40)
        container:SetPoint("TOPLEFT", 20, yOffset)

        -- Les textes à côté
        local textLabel = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        textLabel:SetPoint("LEFT", container, "LEFT", 10, 0)
        textLabel:SetWidth(150)
        textLabel:SetHeight(40)
        textLabel:SetWordWrap(true)
        textLabel:SetJustifyV("MIDDLE")
        textLabel:SetJustifyH("LEFT")
        textLabel:SetText(label)

        -- La barre (le fond)
        local track = CreateFrame("Frame", nil, container, "BackdropTemplate")
        track:SetSize(140, 12)
        track:SetPoint("LEFT", container, "LEFT", 185, 0)
        track:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        track:SetBackdropColor(0.1, 0.1, 0.1, 1)
        track:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)



        local lowText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        lowText:SetPoint("RIGHT", track, "LEFT", -10, 0)
        lowText:SetText(tostring(minV))

        local highText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        highText:SetPoint("LEFT", track, "RIGHT", 8, 0)
        highText:SetText(tostring(maxV))

        -- La couleur qui remplit la barre (jaune/or)
        local fill = track:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT", track, "TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", 2, 2)
        fill:SetTexture("Interface\\Buttons\\WHITE8X8")
        fill:SetVertexColor(0.85, 0.65, 0.1, 1) -- Jaune moutarde / Or mat

        -- Le curseur qu'on déplace
        local thumb = CreateFrame("Button", nil, container)
        thumb:SetSize(8, 16)
        thumb:SetFrameLevel(track:GetFrameLevel() + 5)

        local thumbTex = thumb:CreateTexture(nil, "OVERLAY")
        thumbTex:SetAllPoints()
        thumbTex:SetTexture("Interface\\Buttons\\WHITE8X8")
        thumbTex:SetVertexColor(0.8, 0.8, 0.8, 1)
        thumb:SetNormalTexture(thumbTex)

        local thumbHl = thumb:CreateTexture(nil, "HIGHLIGHT")
        thumbHl:SetAllPoints()
        thumbHl:SetTexture("Interface\\Buttons\\WHITE8X8")
        thumbHl:SetVertexColor(1, 1, 1, 1)
        thumb:SetHighlightTexture(thumbHl)

        -- Le chiffre écrit au dessus du curseur
        local valueText = thumb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueText:SetPoint("BOTTOM", thumb, "TOP", 0, 5)
        valueText:SetTextColor(1, 0.82, 0) -- Couleur Or pour le faire ressortir

        local function UpdateSliderDisplay(val)
            -- Snap to step
            if stepV > 0 then
                val = math.floor((val - minV) / stepV + 0.5) * stepV + minV
            end
            if val < minV then val = minV end
            if val > maxV then val = maxV end

            addon.Config[configKey] = val
            valueText:SetText(tostring(val))

            local ratio = (val - minV) / (maxV - minV)
            thumb:SetPoint("CENTER", track, "LEFT", ratio * 140, 0)

            if ratio > 0 then
                fill:SetWidth(ratio * 138)
                fill:Show()
            else
                fill:Hide()
            end
        end

        local isDragging = false
        local function OnUpdateDrag()
            if not isDragging then return end

            -- Ce qu'on fait quand on déplace le curseur avec la souris
            local x = GetCursorPosition()
            if not x then return end

            local scale = container:GetEffectiveScale()
            local trackLeft = track:GetLeft() * scale
            local trackWidth = track:GetWidth() * scale

            local ratio = (x - trackLeft) / trackWidth
            if ratio < 0 then ratio = 0 end
            if ratio > 1 then ratio = 1 end

            local newVal = minV + ratio * (maxV - minV)
            UpdateSliderDisplay(newVal)

            -- Application immédiate demandée par l'utilisateur
            if configKey == "Scale" and CharacterFrame then
                CharacterFrame:SetScale(addon.Config[configKey])
            end
            if configKey == "InspectScale" and InspectFrame then
                InspectFrame:SetScale(addon.Config[configKey])
            end
            if addon.Personnage and addon.Personnage.UpdateLayout then addon.Personnage.UpdateLayout() end
            if CharacterFrame and CharacterFrame.MCP_Header and addon.Personnage.UpdateHeader then
                addon.Personnage.UpdateHeader(CharacterFrame.MCP_Header)
            end
            if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateLayout then
                addon.Inspection:UpdateLayout()
            end
            addon.Options.ForceUpdateAllSlots()
            -- Refresh des accordéons si paramètre Accordion*
            if configKey:find("^Accordion") then
                if addon.Statistiques and addon.Statistiques.Update then
                    addon.Statistiques:Update()
                end
            end
        end

        local function ApplySliderEffect()
            -- Déjà géré dans OnUpdateDrag pour un effet immédiat
        end

        -- Une zone pour pouvoir cliquer sur toute la barre
        local interactFrame = CreateFrame("Frame", nil, container)
        interactFrame:SetPoint("TOPLEFT", track, "TOPLEFT", 0, 5)
        interactFrame:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", 0, -5)
        interactFrame:EnableMouse(true)

        interactFrame:SetScript("OnMouseDown", function()
            isDragging = true
            interactFrame:SetScript("OnUpdate", OnUpdateDrag)
            OnUpdateDrag()
        end)

        interactFrame:SetScript("OnMouseUp", function()
            isDragging = false
            interactFrame:SetScript("OnUpdate", nil)
            ApplySliderEffect()
        end)

        thumb:SetScript("OnMouseDown", function()
            isDragging = true
            interactFrame:SetScript("OnUpdate", OnUpdateDrag)
        end)

        thumb:SetScript("OnMouseUp", function()
            isDragging = false
            interactFrame:SetScript("OnUpdate", nil)
            ApplySliderEffect()
        end)

        UpdateSliderDisplay(addon.Config[configKey] or minV)

        return container
    end

    local function GetLSM() return LibStub and LibStub("LibSharedMedia-3.0", true) end

    local function CreateFontPanel(parent, titleText, prefixKey, topElementsBuilder)
        local frameC = CreateFrame("Frame", nil, parent)
        frameC:SetAllPoints(parent)
        frameC:Hide()

        local title = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        title:SetPoint("TOP", 0, -20)
        title:SetText("|cffffcc00" .. titleText .. "|r")

        local mainLine = frameC:CreateTexture(nil, "ARTWORK")
        mainLine:SetHeight(1)
        mainLine:SetPoint("TOPLEFT", frameC, "TOPLEFT", 20, -60)
        mainLine:SetPoint("TOPRIGHT", frameC, "TOPRIGHT", -20, -60)
        mainLine:SetColorTexture(1, 0.82, 0, 0.4)

        local currentY = -80

        if topElementsBuilder then
            currentY = topElementsBuilder(frameC, currentY)
        end

        local appTitle = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        appTitle:SetPoint("TOPLEFT", 15, currentY)
        appTitle:SetText("|cffffcc00" .. L["OPT_TEXT_APPEARANCE"] .. "|r")

        local appLine = frameC:CreateTexture(nil, "ARTWORK")
        appLine:SetHeight(1)
        appLine:SetPoint("TOPLEFT", appTitle, "BOTTOMLEFT", 0, -4)
        appLine:SetPoint("RIGHT", frameC, "RIGHT", -20, 0)
        appLine:SetColorTexture(1, 0.82, 0, 0.4)

        local tip = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tip:SetPoint("TOPLEFT", appTitle, "BOTTOMLEFT", 10, -20)
        tip:SetText("|cffffb300" .. L["OPT_TIP_SCALING"] .. "|r")

        currentY = currentY - 65

        local fontTitle = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fontTitle:SetPoint("TOPLEFT", 25, currentY - 5)
        fontTitle:SetText(L["OPT_FONT_NAME"])

        local dropBtn = CreateFrame("Button", nil, frameC)
        dropBtn:SetSize(260, 24)
        dropBtn:SetPoint("LEFT", fontTitle, "RIGHT", 15, 0)

        local dropBg = dropBtn:CreateTexture(nil, "BACKGROUND")
        dropBg:SetAllPoints()
        dropBg:SetColorTexture(0.06, 0.06, 0.06, 1)

        local dropBorder = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
        dropBorder:SetAllPoints()
        dropBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        dropBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local dropText = dropBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        dropText:SetPoint("LEFT", 8, 0)
        dropText:SetPoint("RIGHT", -20, 0)
        dropText:SetJustifyH("LEFT")
        local currentFont = addon.Config[prefixKey .. "Font"] or "Friz Quadrata TT"
        dropText:SetText(currentFont)

        local arrow = dropBtn:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(16, 16)
        arrow:SetPoint("RIGHT", -4, 0)
        arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")

        local ddlPopup = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
        ddlPopup:SetWidth(dropBtn:GetWidth())
        ddlPopup:SetPoint("TOPLEFT", dropBtn, "BOTTOMLEFT", 0, -2)
        ddlPopup:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        ddlPopup:SetBackdropColor(0.1, 0.1, 0.1, 1)
        ddlPopup:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        ddlPopup:SetFrameStrata("TOOLTIP")
        ddlPopup:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, ddlPopup, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 6, -6)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)

        local _scrollBox = CreateFrame("Frame", nil, scrollFrame)
        _scrollBox:SetSize(ddlPopup:GetWidth() - 34, 10)
        scrollFrame:SetScrollChild(_scrollBox)

        local scrollCount = 0
        local function AddDropChoice(name)
            local choice = CreateFrame("Button", nil, _scrollBox)
            choice:SetSize(_scrollBox:GetWidth(), 20)
            choice:SetPoint("TOPLEFT", 0, -(scrollCount * 20))

            local cBg = choice:CreateTexture(nil, "BACKGROUND")
            cBg:SetAllPoints()
            cBg:SetColorTexture(0.3, 0.3, 0.3, 0)

            local hl = choice:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.1)

            local fontStr = choice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fontStr:SetPoint("LEFT", 5, 0)
            fontStr:SetPoint("RIGHT", -5, 0)
            fontStr:SetJustifyH("LEFT")
            fontStr:SetText(name)

            choice:SetScript("OnClick", function()
                addon.Config[prefixKey .. "Font"] = name
                dropText:SetText(name)
                ddlPopup:Hide()

                C_Timer.After(0.01, function()
                    if addon.Personnage and addon.Personnage.UpdateLayout then addon.Personnage:UpdateLayout() end
                    if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateLayout then
                        addon.Inspection:UpdateLayout()
                    end
                    addon.Options.ForceUpdateAllSlots()
                end)
            end)

            scrollCount = scrollCount + 1
            return choice
        end

        local fontsPopulated = false
        local function PopulateFonts()
            if fontsPopulated then return end
            local lsm = GetLSM()
            if lsm then
                local fonts = lsm:HashTable("font")
                local sortedFonts = {}
                for name, _ in pairs(fonts) do table.insert(sortedFonts, name) end
                table.sort(sortedFonts)
                for _, name in ipairs(sortedFonts) do AddDropChoice(name) end
            else
                AddDropChoice("Friz Quadrata TT")
            end
            local maxH = scrollCount * 20 + 12
            if maxH > 200 then maxH = 200 end
            ddlPopup:SetHeight(maxH)
            _scrollBox:SetHeight(scrollCount * 20)
            fontsPopulated = true
        end

        dropBtn:SetScript("OnClick", function()
            if not ddlPopup:IsShown() then
                if frameC.activeDDL and frameC.activeDDL ~= ddlPopup then
                    frameC.activeDDL:Hide()
                end
                frameC.activeDDL = ddlPopup
                PopulateFonts()
                ddlPopup:Show()
            else
                ddlPopup:Hide()
                frameC.activeDDL = nil
            end
        end)

        currentY = currentY - 45
        CreateSlider(frameC, L["OPT_FONT_SIZE"], prefixKey .. "Size", 6, 60, 1, currentY)

        if prefixKey == "ItemName" then
            currentY = currentY - 40
            CreateSlider(frameC, L["OPT_MAX_LEN"], "ItemNameLength", 10, 80, 1, currentY)
            currentY = currentY - 40
            CreateSlider(frameC, L["OPT_MAX_LEN_TABARD"], "ItemNameLengthTabard", 10, 80, 1,
                currentY)
        end

        currentY = currentY - 55

        local posTitle = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        posTitle:SetPoint("TOPLEFT", 15, currentY)
        posTitle:SetText("|cffffcc00" .. L["OPT_TEXT_POSITION"] .. "|r")

        local posLine = frameC:CreateTexture(nil, "ARTWORK")
        posLine:SetHeight(1)
        posLine:SetPoint("TOPLEFT", posTitle, "BOTTOMLEFT", 0, -4)
        posLine:SetPoint("RIGHT", frameC, "RIGHT", -20, 0)
        posLine:SetColorTexture(1, 0.82, 0, 0.4)

        currentY = currentY - 45

        local leftTitle = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
        leftTitle:SetPoint("TOPLEFT", 25, currentY)
        leftTitle:SetText(L["OPT_LEFT_COLUMN"])
        leftTitle:SetTextColor(0.8, 0.8, 0.8)
        currentY = currentY - 30

        CreateSlider(frameC, L["OPT_OFFSET_X"], prefixKey .. "LeftOffsetX", -100, 100, 1, currentY)
        currentY = currentY - 40
        CreateSlider(frameC, L["OPT_OFFSET_Y"], prefixKey .. "LeftOffsetY", -100, 100, 1, currentY)

        currentY = currentY - 55

        local rightTitle = frameC:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
        rightTitle:SetPoint("TOPLEFT", 25, currentY)
        rightTitle:SetText(L["OPT_RIGHT_COLUMN"])
        rightTitle:SetTextColor(0.8, 0.8, 0.8)
        currentY = currentY - 30

        CreateSlider(frameC, L["OPT_OFFSET_X"], prefixKey .. "RightOffsetX", -100, 100, 1, currentY)
        currentY = currentY - 40
        CreateSlider(frameC, L["OPT_OFFSET_Y"], prefixKey .. "RightOffsetY", -100, 100, 1, currentY)

        return frameC, math.abs(currentY - 40)
    end

    local function CreateFontSelector(parent, titleText, prefixKey, yOffset)
        local fontTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fontTitle:SetPoint("TOPLEFT", 25, yOffset)
        fontTitle:SetText(titleText)
        fontTitle:SetTextColor(1, 0.82, 0)

        local dropBtn = CreateFrame("Button", nil, parent)
        dropBtn:SetSize(220, 24)
        dropBtn:SetPoint("LEFT", parent, "TOPLEFT", 160, yOffset - 4)

        local dropBg = dropBtn:CreateTexture(nil, "BACKGROUND")
        dropBg:SetAllPoints()
        dropBg:SetColorTexture(0.06, 0.06, 0.06, 1)

        local dropBorder = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
        dropBorder:SetAllPoints()
        dropBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        dropBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local dropText = dropBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        dropText:SetPoint("LEFT", 8, 0)
        dropText:SetPoint("RIGHT", -20, 0)
        dropText:SetJustifyH("LEFT")
        local currentFont = addon.Config[prefixKey .. "Font"] or "Friz Quadrata TT"
        dropText:SetText(currentFont)

        local arrow = dropBtn:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(16, 16)
        arrow:SetPoint("RIGHT", -4, 0)
        arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")

        local ddlPopup = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
        ddlPopup:SetWidth(dropBtn:GetWidth())
        ddlPopup:SetPoint("TOPLEFT", dropBtn, "BOTTOMLEFT", 0, -2)
        ddlPopup:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        ddlPopup:SetBackdropColor(0.1, 0.1, 0.1, 1)
        ddlPopup:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        ddlPopup:SetFrameStrata("TOOLTIP")
        ddlPopup:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, ddlPopup, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 6, -6)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)

        local _scrollBox = CreateFrame("Frame", nil, scrollFrame)
        _scrollBox:SetSize(ddlPopup:GetWidth() - 34, 10)
        scrollFrame:SetScrollChild(_scrollBox)

        local scrollCount = 0
        local function AddDropChoice(name)
            local choice = CreateFrame("Button", nil, _scrollBox)
            choice:SetSize(_scrollBox:GetWidth(), 20)
            choice:SetPoint("TOPLEFT", 0, -(scrollCount * 20))

            local cBg = choice:CreateTexture(nil, "BACKGROUND")
            cBg:SetAllPoints()
            cBg:SetColorTexture(0.3, 0.3, 0.3, 0)

            local hl = choice:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.1)

            local fontStr = choice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fontStr:SetPoint("LEFT", 5, 0)
            fontStr:SetPoint("RIGHT", -5, 0)
            fontStr:SetJustifyH("LEFT")
            fontStr:SetText(name)

            choice:SetScript("OnClick", function()
                addon.Config[prefixKey .. "Font"] = name
                dropText:SetText(name)
                ddlPopup:Hide()

                C_Timer.After(0.01, function()
                    if addon.Personnage and addon.Personnage.UpdateHeader and CharacterFrame and CharacterFrame.MCP_Header then
                        addon.Personnage.UpdateHeader(CharacterFrame.MCP_Header)
                    end
                    if prefixKey:find("^Accordion") then
                        if addon.Statistiques and addon.Statistiques.Update then
                            addon.Statistiques:Update()
                        end
                    end
                end)
            end)

            scrollCount = scrollCount + 1
            return choice
        end

        local fontsPopulated = false
        local function PopulateFonts()
            if fontsPopulated then return end
            local lsm = GetLSM()
            if lsm then
                local fonts = lsm:HashTable("font")
                local sortedFonts = {}
                for name, _ in pairs(fonts) do table.insert(sortedFonts, name) end
                table.sort(sortedFonts)
                for _, name in ipairs(sortedFonts) do AddDropChoice(name) end
            else
                AddDropChoice("Friz Quadrata TT")
            end
            local maxH = scrollCount * 20 + 12
            if maxH > 200 then maxH = 200 end
            ddlPopup:SetHeight(maxH)
            _scrollBox:SetHeight(scrollCount * 20)
            fontsPopulated = true
        end

        dropBtn:SetScript("OnClick", function()
            if not ddlPopup:IsShown() then
                if parent.activeDDL and parent.activeDDL ~= ddlPopup then
                    parent.activeDDL:Hide()
                end
                parent.activeDDL = ddlPopup
                PopulateFonts()
                ddlPopup:Show()
            else
                ddlPopup:Hide()
                parent.activeDDL = nil
            end
        end)

        CreateSlider(parent, L["OPT_FONT_SIZE"], prefixKey .. "Size", 6, 60, 1, yOffset - 35)

        return yOffset - 85
    end

    local function AddCategory(name, buildFunc)
        local cFrame = CreateFrame("Frame", nil, rightContent)
        cFrame:SetPoint("TOPLEFT", 0, 0)
        cFrame:SetPoint("TOPRIGHT", 0, 0)
        cFrame:Hide()
        local _, h = buildFunc(cFrame)
        h = h or 800
        cFrame:SetHeight(h)
        local cat = { frame = cFrame, contentHeight = h }

        local btn = CreateFrame("Button", nil, leftMenu)
        btn:SetSize(130, 30)
        if #categories == 0 then
            btn:SetPoint("TOP", 0, -10)
        else
            btn:SetPoint("TOP", categories[#categories].btn, "BOTTOM", 0, -5)
        end

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
        btn.bg = bg

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText(name)
        text:SetWidth(120)
        text:SetWordWrap(false)
        btn.text = text

        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.isActive then
                self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            end
        end)

        cat.btn = btn
        table.insert(categories, cat)

        btn:SetScript("OnClick", function(self)
            for _, c in ipairs(categories) do
                c.frame:Hide()
                c.btn.isActive = false
                c.btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
                c.btn.text:SetTextColor(1, 0.82, 0)
            end
            cFrame:Show()
            local contentH = cat.contentHeight or 800
            rightContent:SetHeight(contentH)

            local viewH = scrollFrame:GetHeight()
            local range = math.max(0, contentH - viewH)
            scrollBar:SetMinMaxValues(0, range)
            scrollBar:SetValue(0)

            self.isActive = true
            self.bg:SetColorTexture(0.4, 0.4, 0.4, 1)
            self.text:SetTextColor(1, 1, 1)

            if name == L["TAB_MENU_GEMS"] then
                if addon.Options.UpdateGemSimulator then addon.Options.UpdateGemSimulator() end
            end
        end)
        return cFrame
    end

    AddCategory(L["TAB_MENU_GENERAL"], function(c)
        local t = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        t:SetPoint("TOP", 0, -20)
        t:SetText("|cffffcc00" .. L["TAB_MENU_GENERAL"] .. "|r")

        local mainLine = c:CreateTexture(nil, "ARTWORK")
        mainLine:SetHeight(1)
        mainLine:SetPoint("TOPLEFT", c, "TOPLEFT", 20, -60)
        mainLine:SetPoint("TOPRIGHT", c, "TOPRIGHT", -20, -60)
        mainLine:SetColorTexture(1, 0.82, 0, 0.4)

        local currentY = -80

        local tabTitle = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabTitle:SetPoint("TOPLEFT", 25, currentY)
        tabTitle:SetText(L["OPT_DEFAULT_TAB"])

        local tabDropBtn = CreateFrame("Button", nil, c)
        tabDropBtn:SetSize(200, 24)
        tabDropBtn:SetPoint("LEFT", tabTitle, "RIGHT", 10, 0)
        local tbBg = tabDropBtn:CreateTexture(nil, "BACKGROUND")
        tbBg:SetAllPoints(); tbBg:SetColorTexture(0.06, 0.06, 0.06, 1)
        local tbBorder = CreateFrame("Frame", nil, tabDropBtn, "BackdropTemplate")
        tbBorder:SetAllPoints(); tbBorder:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
        tbBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        local tabTextName = { [1] = L["OPT_TAB_STATS"], [2] = L["OPT_TAB_TITLES"], [3] = L["OPT_TAB_EQUIP"] }
        local tbText = tabDropBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        tbText:SetPoint("LEFT", 8, 0); tbText:SetJustifyH("LEFT")
        tbText:SetText(tabTextName[addon.Config.DefaultTab] or tabTextName[1])
        local tbArrow = tabDropBtn:CreateTexture(nil, "OVERLAY")
        tbArrow:SetSize(16, 16); tbArrow:SetPoint("RIGHT", -4, 0); tbArrow:SetTexture(
            "Interface\\ChatFrame\\ChatFrameExpandArrow")

        local tabPopup = CreateFrame("Frame", nil, tabDropBtn, "BackdropTemplate")
        tabPopup:SetWidth(tabDropBtn:GetWidth()); tabPopup:SetHeight(3 * 20 + 8); tabPopup:SetPoint("TOPLEFT", tabDropBtn,
            "BOTTOMLEFT", 0, -2)
        tabPopup:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile =
            "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        tabPopup:SetBackdropColor(0.1, 0.1, 0.1, 1); tabPopup:SetBackdropBorderColor(0.5, 0.5, 0.5, 1); tabPopup
            :SetFrameStrata("TOOLTIP"); tabPopup:Hide()
        for idx = 1, 3 do
            local choice = CreateFrame("Button", nil, tabPopup)
            choice:SetSize(tabPopup:GetWidth() - 8, 20); choice:SetPoint("TOPLEFT", 4, -(idx - 1) * 20 - 4)
            local fontStr = choice:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fontStr:SetPoint("LEFT", 5, 0); fontStr:SetText(tabTextName[idx])
            choice:SetScript("OnClick",
                function()
                    addon.Config.DefaultTab = idx; tbText:SetText(tabTextName[idx]); tabPopup:Hide()
                end)
        end
        tabDropBtn:SetScript("OnClick",
            function() if tabPopup:IsShown() then tabPopup:Hide() else tabPopup:Show() end end)

        currentY = currentY - 40

        currentY = currentY - 40

        CreateSlider(c, L["OPT_SCALE_TITLE"], "Scale", 0.5, 2.0, 0.05, currentY)
        currentY = currentY - 50
        CreateSlider(c, (L["OPT_INSPECT_SCALE"] or "Échelle Inspection"), "InspectScale", 0.5, 2.0, 0.05, currentY)
        currentY = currentY - 70

        local tText = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        tText:SetPoint("TOPLEFT", 15, currentY)
        tText:SetText("|cffffcc00" .. L["TAB_MENU_TEXT_APPEARANCE"] .. "|r")

        local textLine = c:CreateTexture(nil, "ARTWORK")
        textLine:SetHeight(1)
        textLine:SetPoint("TOPLEFT", tText, "BOTTOMLEFT", 0, -4)
        textLine:SetPoint("RIGHT", c, "RIGHT", -20, 0)
        textLine:SetColorTexture(1, 0.82, 0, 0.4)

        local tip = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tip:SetPoint("TOPLEFT", tText, "BOTTOMLEFT", 10, -20)
        tip:SetText("|cffffb300" .. L["OPT_TIP_SCALING"] .. "|r")

        currentY = currentY - 65

        currentY = CreateFontSelector(c, L["OPT_HEADER_NAME"], "HeaderPlayerName", currentY)
        currentY = currentY - 10
        currentY = CreateFontSelector(c, L["OPT_HEADER_LEVEL"], "HeaderPlayerLevel", currentY)
        currentY = currentY - 10
        currentY = CreateFontSelector(c, L["OPT_HEADER_MYTHIC"], "HeaderMythicPlus", currentY)
        currentY = currentY - 10
        currentY = CreateFontSelector(c, L["GREAT_VAULT"], "HeaderGreatVault", currentY)

        local statResetBtn = CreateFrame("Button", nil, c)
        statResetBtn:SetSize(300, 32)
        statResetBtn:SetPoint("BOTTOM", c, "BOTTOM", 0, 60)
        local srBg = statResetBtn:CreateTexture(nil, "BACKGROUND")
        srBg:SetAllPoints(); srBg:SetColorTexture(0.5, 0.3, 0, 0.8)
        local srText = statResetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        srText:SetPoint("CENTER", 0, 0); srText:SetText(L["OPT_RESET_STATS"])
        statResetBtn:SetScript("OnClick", function()
            StaticPopupDialogs["MCP_RESET_STATS_CONFIRM"] = {
                text = L["OPT_RESET_STATS_CONFIRM"],
                button1 = L["OPT_YES"],
                button2 = L["OPT_NO"],
                OnAccept = function()
                    addon.Config.StatOrder = nil; MCP_StatsOrder = nil; addon.Config.StatsTutorialSeen = nil; addon.Config.TutorialSeen = nil; ReloadUI()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("MCP_RESET_STATS_CONFIRM")
        end)

        local resetBtn = CreateFrame("Button", nil, c)
        resetBtn:SetSize(300, 32)
        resetBtn:SetPoint("BOTTOM", c, "BOTTOM", 0, 20)
        local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
        resetBg:SetAllPoints(); resetBg:SetColorTexture(0.5, 0.1, 0.1, 0.8)
        local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        resetText:SetPoint("CENTER", 0, 0); resetText:SetText(L["OPT_RESET_ALL"])
        resetBtn:SetScript("OnClick", function()
            StaticPopupDialogs["MCP_RESET_CONFIRM"] = {
                text = L["OPT_RESET_WARN"],
                button1 = L["OPT_YES"],
                button2 = L["OPT_NO"],
                OnAccept = function()
                    wipe(addon.Config); for k, v in pairs(DEFAULT_CONFIG) do addon.Config[k] = v end; MCP_StatsOrder = nil; ReloadUI()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("MCP_RESET_CONFIRM")
        end)
        return c, math.abs(currentY - 100)
    end)

    AddCategory(L["FONT_CATEGORY_ITEM"], function(c)
        local f, h = CreateFontPanel(c, L["FONT_CATEGORY_ITEM"], "ItemName", function(panel, y)
            CreateCheckbox(panel, L["OPT_SHOW_NAME"], "ShowItemName", true, y)
            local d1 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            d1:SetPoint("TOPLEFT", 50, y - 22)
            d1:SetText(L["OPT_SHOW_NAME_DESC"])
            y = y - 45

            CreateCheckbox(panel, L["OPT_HOVER_SCROLL"], "HoverScroll", false, y)
            local d2 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            d2:SetPoint("TOPLEFT", 50, y - 22)
            d2:SetText("|cffaaaaaa" .. L["OPT_HOVER_SCROLL_DESC"] .. "|r")
            return y - 55
        end)
        f:Show()
        return f, h
    end)

    AddCategory(L["FONT_CATEGORY_ILVL"], function(c)
        local f, h = CreateFontPanel(c, L["FONT_CATEGORY_ILVL"], "ItemLevel", function(panel, y)
            CreateCheckbox(panel, L["OPT_SHOW_ILVL"], "ShowIlvl", false, y)
            y = y - 35

            CreateCheckbox(panel, addon.L["OPT_SHOW_FLYOUT_ILVL"] or "Afficher l'Ilvl menu volant (Maj)",
                "ShowFlyoutIlvl", false, y)
            return y - 35
        end)
        f:Show()
        return f, h
    end)

    AddCategory(L["FONT_CATEGORY_ENCHANT"], function(c)
        local f, h = CreateFontPanel(c, L["FONT_CATEGORY_ENCHANT"], "Enchant", function(panel, y)
            CreateCheckbox(panel, L["OPT_SHOW_ENCHANT"], "ShowEnchant", false, y)
            y = y - 35

            CreateCheckbox(panel, L["OPT_ENCHANT_RANK_ONLY"], "EnchantRankOnly", false, y)
            local d3 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            d3:SetPoint("TOPLEFT", 50, y - 22)
            d3:SetText("|cffaaaaaa" .. L["OPT_ENCHANT_RANK_DESC"] .. "|r")
            y = y - 50

            -- Le titre de la section "Non enchanté" (Style Big Menu)
            local lbl = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            lbl:SetPoint("TOPLEFT", 15, y)
            lbl:SetText(L["OPT_NOT_ENCHANTED_TITLE"])

            local lblLine = panel:CreateTexture(nil, "ARTWORK")
            lblLine:SetHeight(1)
            lblLine:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -4)
            lblLine:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
            lblLine:SetColorTexture(1, 0.82, 0, 0.4)

            y = y - 40

            -- Les cases à cocher pour chaque emplacement d'équipement
            local slotsLeft = {
                { key = "ShowNotEnchanted_1",  label = L["SLOT_HEAD"] },
                { key = "ShowNotEnchanted_2",  label = L["SLOT_NECK"] },
                { key = "ShowNotEnchanted_3",  label = L["SLOT_SHOULDER"] },
                { key = "ShowNotEnchanted_15", label = L["SLOT_BACK"] },
                { key = "ShowNotEnchanted_5",  label = L["SLOT_CHEST"] },
                { key = "ShowNotEnchanted_11", label = L["SLOT_FINGER1"] },
                { key = "ShowNotEnchanted_9",  label = L["SLOT_WRIST"] },
                { key = "ShowNotEnchanted_16", label = L["SLOT_MAINHAND"] },
            }
            local slotsRight = {
                { key = "ShowNotEnchanted_10", label = L["SLOT_HANDS"] },
                { key = "ShowNotEnchanted_6",  label = L["SLOT_WAIST"] },
                { key = "ShowNotEnchanted_7",  label = L["SLOT_LEGS"] },
                { key = "ShowNotEnchanted_8",  label = L["SLOT_FEET"] },
                { key = "ShowNotEnchanted_12", label = L["SLOT_FINGER2"] },
                { key = "ShowNotEnchanted_13", label = L["SLOT_TRINKET1"] },
                { key = "ShowNotEnchanted_14", label = L["SLOT_TRINKET2"] },
                { key = "ShowNotEnchanted_17", label = L["SLOT_OFFHAND"] },
            }

            local function CreateSlotCheckbox(slot, cbX, cbY)
                local btn = CreateFrame("CheckButton", nil, panel)
                btn:SetSize(20, 20)
                btn:SetPoint("TOPLEFT", cbX, cbY)
                local border2 = btn:CreateTexture(nil, "BACKGROUND")
                border2:SetAllPoints(); border2:SetColorTexture(0.5, 0.5, 0.5, 1)
                local bg2 = btn:CreateTexture(nil, "BORDER")
                bg2:SetPoint("TOPLEFT", 1, -1); bg2:SetPoint("BOTTOMRIGHT", -1, 1)
                bg2:SetColorTexture(0.1, 0.1, 0.1, 1)
                local chk2 = btn:CreateTexture(nil, "OVERLAY")
                chk2:SetColorTexture(0.2, 0.8, 0.2, 1)
                chk2:SetPoint("TOPLEFT", 4, -4); chk2:SetPoint("BOTTOMRIGHT", -4, 4)
                btn:SetCheckedTexture(chk2)
                btn:SetChecked(addon.Config[slot.key])
                local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                txt:SetPoint("LEFT", btn, "RIGHT", 6, 0)
                txt:SetText(slot.label)
                local slotKey = slot.key
                btn:SetScript("OnClick", function(self)
                    addon.Config[slotKey] = self:GetChecked()
                    addon.Options.ForceUpdateAllSlots()
                end)
            end

            local startY = y
            local colW = 150

            -- Les cases à gauche
            for i, slot in ipairs(slotsLeft) do
                local cbY = startY - ((i - 1) * 26)
                local cbX = 20
                CreateSlotCheckbox(slot, cbX, cbY)
            end

            -- Les cases à droite
            for i, slot in ipairs(slotsRight) do
                local cbY = startY - ((i - 1) * 26)
                local cbX = 20 + colW
                CreateSlotCheckbox(slot, cbX, cbY)
            end
            local maxRows = math.max(#slotsLeft, #slotsRight)
            return startY - (maxRows * 26) - 10
        end)
        f:Show()
        return f, h
    end)

    AddCategory(L["FONT_CATEGORY_UPGRADE"], function(c)
        local f, h = CreateFontPanel(c, L["FONT_CATEGORY_UPGRADE"], "UpgradeLevel", function(panel, y)
            CreateCheckbox(panel, L["OPT_SHOW_UPGRADE"], "ShowUpgrade", false, y)
            return y - 35
        end)
        f:Show()
        return f, h
    end)

    -- Gemmes
    AddCategory(L["TAB_MENU_GEMS"], function(c)
        local t = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        t:SetPoint("TOP", 0, -20)
        t:SetText("|cffffcc00" .. L["TAB_MENU_GEMS"] .. "|r")

        -- Ligne sous Big Title
        local mainLine = c:CreateTexture(nil, "ARTWORK")
        mainLine:SetHeight(1)
        mainLine:SetPoint("TOPLEFT", c, "TOPLEFT", 20, -60)
        mainLine:SetPoint("TOPRIGHT", c, "TOPRIGHT", -20, -60)
        mainLine:SetColorTexture(1, 0.82, 0, 0.4)

        local currentY = -80
        CreateCheckbox(c, L["OPT_SHOW_GEMS"], "ShowGems", false, currentY)
        currentY = currentY - 50
        CreateSlider(c, L["OPT_GEM_SIZE"], "GemSize", 8, 32, 1, currentY)
        currentY = currentY - 50

        local onyxIcon = C_Item.GetItemIconByID(213745) or 134096
        local gemIcons = {
            onyxIcon,
            onyxIcon,
            onyxIcon
        }

        -- Le cadre qui entoure le simulateur de gemmes
        local simBox = CreateFrame("Frame", nil, c, "BackdropTemplate")
        simBox:SetSize(400, 200)
        simBox:SetPoint("TOP", c, "TOP", 0, -170)

        local instruction = simBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        instruction:SetPoint("TOP", simBox, "TOP", 0, -16)
        instruction:SetText(L["OPT_GEM_DRAG_INST"])
        instruction:SetJustifyH("CENTER")
        instruction:SetSpacing(4)
        instruction:SetTextColor(0.9, 0.8, 0.5) -- Doré léger très discret
        simBox:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 14,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        simBox:SetBackdropColor(0.05, 0.05, 0.05, 0.6)
        simBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

        -- L'emplacement où on voit les gemmes bouger
        local simSlot = CreateFrame("Frame", nil, simBox)
        simSlot:SetSize(36, 36)
        simSlot:SetPoint("CENTER", 85, 0) -- Décalé sur la droite pour centrer la barre horizontalement

        -- Atlas "128-RedButton-Disable" (background objet)
        local itemAtlas = simSlot:CreateTexture(nil, "BORDER")
        itemAtlas:SetAtlas("128-RedButton-Disable")
        itemAtlas:SetSize(200, 50)
        itemAtlas:SetDesaturated(true)
        itemAtlas:SetVertexColor(1, 1, 1, 1)
        itemAtlas:SetPoint("RIGHT", simSlot, "LEFT", 32, 0)
        itemAtlas:SetTexCoord(1, 0, 0, 1)

        -- On lui donne un look d'octogone (8 côtés)
        local simIconBg = simSlot:CreateTexture(nil, "ARTWORK")
        simIconBg:SetAllPoints()
        simIconBg:SetTexture("Interface\\Icons\\INV_Helmet_02")

        local m1 = simSlot:CreateMaskTexture()
        m1:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        m1:SetSize(36, 36)
        m1:SetPoint("CENTER")
        simIconBg:AddMaskTexture(m1)

        local m2 = simSlot:CreateMaskTexture()
        m2:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        m2:SetSize(36, 36)
        m2:SetPoint("CENTER")
        m2:SetRotation(math.rad(45))
        simIconBg:AddMaskTexture(m2)

        local simBg = simSlot:CreateTexture(nil, "ARTWORK", nil, -1)
        simBg:SetAllPoints()
        simBg:SetColorTexture(0, 0, 0, 0.4)
        simBg:AddMaskTexture(m1)
        simBg:AddMaskTexture(m2)

        local radius = 36 / 2
        local sideLength = 2 * radius * 0.414
        local thickness = 2
        for i = 0, 7 do
            local angleDeg = i * 45
            local angleRad = math.rad(angleDeg)
            local line = simSlot:CreateTexture(nil, "OVERLAY")
            line:SetTexture("Interface\\BUTTONS\\WHITE8X8")
            line:SetSize(sideLength + (thickness * 0.45), thickness)
            local cx = radius * math.cos(angleRad)
            local cy = radius * math.sin(angleRad)
            line:SetPoint("CENTER", simSlot, "CENTER", cx, cy)
            line:SetRotation(angleRad + math.pi / 2)
            local r, g, b = C_Item.GetItemQualityColor(4)
            line:SetVertexColor(r or 0.64, g or 0.21, b or 0.93)
        end

        local btnResetSim = CreateFrame("Button", nil, simBox)
        btnResetSim:SetSize(170, 24)
        btnResetSim:SetPoint("BOTTOM", simBox, "BOTTOM", 0, 15)

        local simResetBg = btnResetSim:CreateTexture(nil, "BACKGROUND")
        simResetBg:SetAllPoints()
        simResetBg:SetColorTexture(0.06, 0.06, 0.06, 1)

        local simResetBorder = CreateFrame("Frame", nil, btnResetSim, "BackdropTemplate")
        simResetBorder:SetAllPoints()
        simResetBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        simResetBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local simResetHl = btnResetSim:CreateTexture(nil, "HIGHLIGHT")
        simResetHl:SetAllPoints()
        simResetHl:SetColorTexture(1, 1, 1, 0.1)

        local simResetText = btnResetSim:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        simResetText:SetPoint("CENTER")
        simResetText:SetText(L["OPT_GEM_RESET"])
        btnResetSim:SetScript("OnClick", function()
            addon.Config.Gem1X = DEFAULT_CONFIG.Gem1X
            addon.Config.Gem1Y = DEFAULT_CONFIG.Gem1Y
            addon.Config.Gem2X = DEFAULT_CONFIG.Gem2X
            addon.Config.Gem2Y = DEFAULT_CONFIG.Gem2Y
            addon.Config.Gem3X = DEFAULT_CONFIG.Gem3X
            addon.Config.Gem3Y = DEFAULT_CONFIG.Gem3Y
            if addon.Options.UpdateGemSimulator then addon.Options.UpdateGemSimulator() end
            if addon.Options.ForceUpdateAllSlots then
                if addon.Personnage and addon.Personnage.UpdateLayout then addon.Personnage:UpdateLayout() end
                if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateLayout then
                    addon.Inspection:UpdateLayout()
                end
                addon.Options.ForceUpdateAllSlots()
            end
        end)

        c.Gems = {}
        for i = 1, 3 do
            local container = CreateFrame("Button", nil, simSlot)
            container:SetSize(28, 28) -- On fait une zone un peu plus large pour cliquer facilement
            container:EnableMouse(true)
            container:SetMovable(true)
            container:RegisterForDrag("LeftButton")

            local gTex = container:CreateTexture(nil, "ARTWORK")
            gTex:SetPoint("CENTER")
            gTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            local mask = container:CreateMaskTexture()
            mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE")
            mask:SetPoint("CENTER")
            gTex:AddMaskTexture(mask)

            local bg = container:CreateTexture(nil, "BACKGROUND")
            bg:SetColorTexture(0.1, 0.1, 0.1, 1)
            bg:SetPoint("CENTER")

            local bgMask = container:CreateMaskTexture()
            bgMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
                "CLAMPTOBLACKADDITIVE")
            bgMask:SetPoint("CENTER")
            bg:AddMaskTexture(bgMask)

            local ring = container:CreateTexture(nil, "OVERLAY")
            ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
            ring:SetVertexColor(1, 0.82, 0, 0) -- On le cache au début
            ring:SetPoint("CENTER")
            ring:SetBlendMode("ADD")

            local hl = container:CreateTexture(nil, "HIGHLIGHT")
            hl:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
            hl:SetVertexColor(1, 1, 1, 0.4)
            hl:SetAllPoints(ring)
            hl:SetBlendMode("ADD")
            container:SetHighlightTexture(hl)

            container.Texture = gTex
            container.Mask = mask
            container.Ring = ring
            container.Background = bg
            container.BgMask = bgMask

            container:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(string.format(L["OPT_GEM_TOOLTIP_TITLE"], i), 1, 0.82, 0)
                GameTooltip:AddLine(L["OPT_GEM_TOOLTIP_DESC"], 1, 1, 1)
                GameTooltip:Show()
                self.Ring:SetVertexColor(1, 0.82, 0, 0.8)      -- Aura dorée
                self.Background:SetColorTexture(1, 0.82, 0, 1) -- Bordure dorée
            end)

            container:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
                self.Ring:SetVertexColor(1, 0.82, 0, 0)
                self.Background:SetColorTexture(0.1, 0.1, 0.1, 1)
            end)

            container:SetScript("OnMouseDown", function(self)
                self.Background:SetColorTexture(0, 1, 0, 1) -- Vert au clic
            end)

            container:SetScript("OnMouseUp", function(self)
                if self:IsMouseOver() then
                    self.Background:SetColorTexture(1, 0.82, 0, 1)
                else
                    self.Background:SetColorTexture(0.1, 0.1, 0.1, 1)
                end
            end)

            container:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)

            container:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()

                local gx, gy = self:GetCenter()

                -- Pour pas que les gemmes sortent de la boîte en les bougeant
                local sbL = simBox:GetLeft()
                local sbR = simBox:GetRight()
                local sbB = simBox:GetBottom()
                local sbT = simBox:GetTop()

                if sbL and sbR and sbB and sbT and gx and gy then
                    -- On calcule pour que ça reste bien dedans
                    gx = math.max(sbL + 18, math.min(gx, sbR - 18))
                    gy = math.max(sbB + 18, math.min(gy, sbT - 18))
                end

                local sx, sy = simSlot:GetCenter()

                local trX = sx + (simSlot:GetWidth() / 2)
                local trY = sy + (simSlot:GetHeight() / 2)

                local diffX = math.floor(gx - trX + 0.5)
                local diffY = math.floor(gy - trY + 0.5)

                -- On aligne par pas de 2 pixels pour que ça soit droit
                diffX = math.floor(diffX / 2) * 2
                diffY = math.floor(diffY / 2) * 2

                addon.Config["Gem" .. i .. "X"] = diffX
                addon.Config["Gem" .. i .. "Y"] = diffY

                self:ClearAllPoints()
                self:SetPoint("CENTER", simSlot, "TOPRIGHT", diffX, diffY)

                if addon.Options.ForceUpdateAllSlots then
                    if addon.Personnage and addon.Personnage.UpdateLayout then addon.Personnage:UpdateLayout() end
                    if InspectFrame and InspectFrame:IsShown() and addon.Inspection and addon.Inspection.UpdateLayout then
                        addon.Inspection:UpdateLayout()
                    end
                    addon.Options.ForceUpdateAllSlots()
                end
            end)

            table.insert(c.Gems, container)
        end

        addon.Options.UpdateGemSimulator = function()
            local gemSize = (addon.Config and addon.Config.GemSize) or 16

            for i, gem in ipairs(c.Gems) do
                local gx = (addon.Config and addon.Config["Gem" .. i .. "X"]) or 0
                local gy = (addon.Config and addon.Config["Gem" .. i .. "Y"]) or 0

                gem:SetSize(gemSize + 4, gemSize + 4)
                gem.Texture:SetSize(gemSize, gemSize)
                gem.Mask:SetSize(gemSize, gemSize)
                gem.Ring:SetSize(gemSize + 2, gemSize + 2)
                gem.Background:SetSize(gemSize + 2, gemSize + 2)
                gem.BgMask:SetSize(gemSize + 2, gemSize + 2)

                gem:ClearAllPoints()
                gem:SetPoint("CENTER", simSlot, "TOPRIGHT", gx, gy)

                gem.Texture:SetTexture(gemIcons[i])
                gem.Texture:SetVertexColor(1, 1, 1)
                gem.Ring:Show()
            end
        end
    end)

    -- Accordéons
    AddCategory(L["TAB_MENU_ACCORDIONS"], function(c)
        local t = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
        t:SetPoint("TOP", 0, -20)
        t:SetText("|cffffcc00" .. L["TAB_MENU_ACCORDIONS"] .. "|r")

        -- Ligne sous Big Title
        local mainLine = c:CreateTexture(nil, "ARTWORK")
        mainLine:SetHeight(1)
        mainLine:SetPoint("TOPLEFT", c, "TOPLEFT", 20, -60)
        mainLine:SetPoint("TOPRIGHT", c, "TOPRIGHT", -20, -60)
        mainLine:SetColorTexture(1, 0.82, 0, 0.4)

        local currentY = -80

        -- Titres d'accordéons (Stats, Titres, Stuff)
        local s1Title = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        s1Title:SetPoint("TOPLEFT", 15, currentY)
        s1Title:SetText("|cffffcc00" .. L["ACCORDION_SECTION_TABS"] .. "|r")

        local s1Desc = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        s1Desc:SetPoint("TOPLEFT", 25, currentY - 20)
        s1Desc:SetText(L["ACCORDION_TAB_DESC"])
        s1Desc:SetTextColor(0.7, 0.7, 0.7)
        currentY = currentY - 45
        currentY = CreateFontSelector(c, L["OPT_FONT_NAME"], "AccordionTab", currentY)

        currentY = currentY - 40

        -- GROS TITRE STATISTIQUES avec ligne
        local t2 = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        t2:SetPoint("TOPLEFT", 15, currentY)
        t2:SetText("|cffffcc00" .. L["TAB_STATS"] .. "|r")

        local mainLine2 = c:CreateTexture(nil, "ARTWORK")
        mainLine2:SetHeight(1)
        mainLine2:SetPoint("TOPLEFT", t2, "BOTTOMLEFT", 0, -4)
        mainLine2:SetPoint("RIGHT", c, "RIGHT", -20, 0)
        mainLine2:SetColorTexture(1, 0.82, 0, 0.4)

        currentY = currentY - 45

        -- Entêtes de catégories (Caractéristiques, Améliorations)
        local sHeadTitle = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sHeadTitle:SetPoint("TOPLEFT", 15, currentY)
        sHeadTitle:SetText("|cffffcc00" .. L["ACCORDION_SECTION_TITLES"] .. "|r")

        local sHeadDesc = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        sHeadDesc:SetPoint("TOPLEFT", 25, currentY - 20)
        sHeadDesc:SetText(L["ACCORDION_TITLE_DESC"])
        sHeadDesc:SetTextColor(0.7, 0.7, 0.7)
        currentY = currentY - 45

        currentY = CreateFontSelector(c, L["OPT_FONT_NAME"], "AccordionTitle", currentY)

        currentY = currentY - 25

        -- Réglages pour le gros chiffre du niveau d'objet
        local s2Title = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        s2Title:SetPoint("TOPLEFT", 15, currentY)
        s2Title:SetText("|cffffcc00" .. L["ACCORDION_SECTION_ILVL"] .. "|r")

        local s2Desc = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        s2Desc:SetPoint("TOPLEFT", 25, currentY - 20)
        s2Desc:SetText(L["ACCORDION_ILVL_DESC"])
        s2Desc:SetTextColor(0.7, 0.7, 0.7)
        currentY = currentY - 45

        currentY = CreateFontSelector(c, L["OPT_FONT_NAME"], "AccordionIlvl", currentY)

        currentY = currentY - 25

        -- Réglages pour les noms des stats (Force, Agilité...)
        local s4Title = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        s4Title:SetPoint("TOPLEFT", 15, currentY)
        s4Title:SetText("|cffffcc00" .. L["ACCORDION_SECTION_STATS"] .. "|r")

        local s4Desc = c:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        s4Desc:SetPoint("TOPLEFT", 25, currentY - 20)
        s4Desc:SetText(L["ACCORDION_STAT_DESC"])
        s4Desc:SetTextColor(0.7, 0.7, 0.7)
        currentY = currentY - 45

        currentY = CreateFontSelector(c, L["OPT_FONT_NAME"], "AccordionStatLabel", currentY)

        return math.abs(currentY) + 30
    end)

    -- On ouvre la première page par défaut au chargement
    if #categories > 0 then
        categories[1].btn:Click()
    end

    optionsFrame = frame
end

-- Affiche un message d'aide pour le premier démarrage
local function SpawnTutorial()
    if addon.Config.TutorialSeen then return end
    if not HelpTip or not optionsButton then return end
    if CharacterFrame and PanelTemplates_GetSelectedTab(CharacterFrame) ~= 1 then return end

    local helpTipInfo = {
        text = addon.L["TUTORIAL_OPTIONS"],
        buttonStyle = HelpTip.ButtonStyle.Close,
        targetPoint = HelpTip.Point.TopEdgeCenter,
        alignment = HelpTip.Alignment.Center,
        offsetY = 10,
        onHideCallback = function()
            addon.Config.TutorialSeen = true
        end
    }
    HelpTip:Show(CharacterFrame, helpTipInfo, optionsButton)
end

-- Crée le bouton d'engrenage pour ouvrir les options
local function CreateOptionsButton()
    if optionsButton then return end
    if not CharacterFrame then return end

    optionsButton = CreateFrame("Button", nil, PaperDollFrame)
    optionsButton:SetSize(28, 28)
    optionsButton:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -15, 15)

    optionsButton:SetNormalAtlas("poi-scrapper")
    optionsButton:SetHighlightAtlas("poi-scrapper")
    local hl = optionsButton:GetHighlightTexture()
    if hl then
        hl:SetAlpha(0.3); hl:SetBlendMode("ADD")
    end

    optionsButton:SetScript("OnClick", function()
        if HelpTip then HelpTip:HideAll(CharacterFrame) end
        addon.Config.TutorialSeen = true

        if not optionsFrame then
            CreateOptionsUI()
        end
        if optionsFrame and optionsFrame:IsShown() then
            optionsFrame:Hide()
        elseif optionsFrame then
            if not optionsFrame.isUserMoved and CharacterFrame then
                local right = CharacterFrame:GetRight()
                local top = CharacterFrame:GetTop()
                local s = CharacterFrame:GetEffectiveScale()
                local uS = UIParent:GetEffectiveScale()
                if right and top then
                    optionsFrame:ClearAllPoints()
                    optionsFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (right * s / uS) + 80, (top * s / uS))
                end
            end
            optionsFrame:Show()
        end
    end)

    optionsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(addon.L["OPTIONS_TITLE"], 1.0, 1.0, 1.0, 1.0, true)
        GameTooltip:Show()
    end)
    optionsButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, loadedName)
    if event == "ADDON_LOADED" and loadedName == addonName then
        InitializeConfig()

        -- On surveille quand on ouvre la fenêtre du perso pour mettre notre bouton
        CharacterFrame:HookScript("OnShow", function()
            CreateOptionsButton()
            addon.Options.ApplyConfig()
            C_Timer.After(0.5, SpawnTutorial)
        end)
    end
end)
