local addonName, addon = ...
local L = addon.L
local C = addon.Consts

addon.Options = {}
local Options = addon.Options
local FONT_DIR = "Interface/AddOns/MyCharacterPanel/Utils/Fonts/"

-- Je définis ici les couleurs et l'apparence générale
local THEME = {
    bg          = {0.05, 0.05, 0.07, 0.95},
    cardBg      = {0.10, 0.10, 0.14, 0.5},
    border      = {0.00, 0.00, 0.00, 1.0},
    accent      = {0.00, 0.70, 1.00, 1.0},
    textHeader  = {1.00, 1.00, 1.00, 1.0},
    textNormal  = {0.80, 0.80, 0.85, 1.0},
}



local function CreateBackdrop(frame, bgColor, borderColor)
    if not frame.SetBackdrop then Mixin(frame, BackdropTemplateMixin) end
    frame:SetBackdrop({
        bgFile   = "Interface/Buttons/WHITE8x8",
        edgeFile = "Interface/Buttons/WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(unpack(bgColor or THEME.bg))
    frame:SetBackdropBorderColor(unpack(borderColor or THEME.border))
end

-- Retourne le header pour ancrage
local function CreateSectionHeader(parent, text, yOffset, warningText)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetText(text)
    header:SetTextColor(unpack(THEME.accent))
    header:SetAlpha(1.0) -- Force l'opacité complète
    
    if warningText then
        local warn = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        warn:SetPoint("LEFT", header, "RIGHT", 10, 0)
        warn:SetText(warningText)
        warn:SetTextColor(1, 0.3, 0.3) 
    end
    
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", header, "BOTTOMLEFT", 0, -5)
    line:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    line:SetColorTexture(unpack(THEME.accent))
    line:SetAlpha(0.3)
    
    return yOffset - 35, header
end

-- Les options par défaut quand on installe l'addon
local DEFAULTS = {
    showItemNames = true,
    showItemLevel = true,
    scrollItemNames = true,
    showUpgradeLevels = true,
    showEnchants = true,
    showModelPreview = true,
    showSetInfo = true,         
    defaultAccordion = 1, 
    lockZoom = false, -- Zoom non verrouillé par défaut 
    
    fonts = {
        itemLevel = FONT_DIR.."DorisPP.ttf",
        itemName  = "Fonts/2002.TTF",
        enchant   = "Fonts/2002.TTF",
        upgrade   = FONT_DIR.."DorisPP.ttf",
        setBonus  = "Fonts/FRIZQT__.TTF",
        headers   = FONT_DIR.."DorisPP.ttf",
    },

    enchantCheckSlots = {
        [1]=true, [2]=false, [3]=true, [15]=true, [5]=true, 
        [9]=true, [10]=true, [16]=true, 
        [6]=true, [7]=true, [8]=true, [11]=true, [12]=true, 
        [13]=false, [14]=false, [17]=false, 
    }
}

function Options:InitDB()
    if not MyCharacterPanelDB then MyCharacterPanelDB = {} end
    local db = MyCharacterPanelDB

    for k, v in pairs(DEFAULTS) do
        if db[k] == nil then db[k] = v end
    end
    
    if not db.fonts then db.fonts = CopyTable(DEFAULTS.fonts) end
    if not db.enchantCheckSlots then db.enchantCheckSlots = CopyTable(DEFAULTS.enchantCheckSlots) end
    
    for k, v in pairs(DEFAULTS.fonts) do
        if db.fonts[k] == nil then db.fonts[k] = v end
    end
    
    -- Global defaults
    for k, v in pairs(DEFAULTS.fonts) do
        if db.fonts[k] == nil then db.fonts[k] = v end
    end

    -- Per-Character DB
    if not db.char then db.char = {} end
    local guid = UnitGUID("player")
    if not db.char[guid] then db.char[guid] = {} end
    self.charDb = db.char[guid]

    -- Init char defaults for enchantCheckSlots
    if not self.charDb.enchantCheckSlots then
         -- Try to migrate from global if exists (legacy support), else defaults
         if db.enchantCheckSlots then
             self.charDb.enchantCheckSlots = CopyTable(db.enchantCheckSlots)
         else
             self.charDb.enchantCheckSlots = CopyTable(DEFAULTS.enchantCheckSlots)
         end
    end
    
    -- Stat Order
    if not self.charDb.statOrder then
        self.charDb.statOrder = {}
    end

    -- Une fenêtre pour demander de recharger l'interface
    StaticPopupDialogs["MYCHARPANEL_RELOAD"] = {
        text = "|cff00ccffMy Character Panel|r\n\n" .. (L["RELOAD_REQUIRED_BODY"]),
        button1 = L["YES_RELOAD"],
        button2 = L["NO"],
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- Une fenêtre pour confirmer qu'on veut remettre les polices à zéro
    StaticPopupDialogs["MYCHARPANEL_RESET_FONTS"] = {
        text = "|cff00ccffMy Character Panel|r\n\n" .. (L["RESET_FONTS_BODY"]),
        button1 = L["CONFIRM"],
        button2 = L["CANCEL"],
        OnAccept = function() 
            -- Réinitialisation de la base de données

            Options.db.fonts = CopyTable(DEFAULTS.fonts)
            
            -- Rafraîchir l'aperçu et le panneau principal

            Options:UpdatePreview()
            Options:TriggerUpdate()
            
            -- Mise à jour visuelle des Dropdowns (Menus déroulants)

            if Options.fontDropdowns then
                for dbKey, ddFrame in pairs(Options.fontDropdowns) do
                    local defaultPath = Options.db.fonts[dbKey]
                    UIDropDownMenu_SetSelectedValue(ddFrame, defaultPath)
                    
                    local name = L["UNKNOWN"]
                    for _, f in ipairs(C.AVAILABLE_FONTS) do
                        if f.path == defaultPath then name = f.name; break end
                    end
                    UIDropDownMenu_SetText(ddFrame, name)
                end
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopupDialogs["MYCHARPANEL_RESET_STATS"] = {
        text = "|cff00ccffMy Character Panel|r\n\n" .. (L["RESET_STATS_DESC"] or "Reset Stats?"),
        button1 = L["CONFIRM"],
        button2 = L["CANCEL"],
        OnAccept = function() 
            local guid = UnitGUID("player")
            -- On vide la table de tri
            if MyCharacterPanelDB.char and MyCharacterPanelDB.char[guid] then
                MyCharacterPanelDB.char[guid].statOrder = nil 
            end
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    self.db = db
    self:CreateStandalonePanel()
    self:RegisterBlizzardSettings()
end

function Options:TriggerUpdate()
    if addon.MainFrame and addon.MainFrame.RequestUpdate then
        addon.MainFrame:RequestUpdate()
    end
end


-- Tout le code pour afficher l'aperçu de l'objet en haut des options
function Options:UpdatePreview()
    if not self.PreviewSlot then return end
    local p = self.PreviewSlot
    local db = self.db

    p.Name:SetFont(db.fonts.itemName, 12, "")
    p.ItemLevel:SetFont(db.fonts.itemLevel, 18, "THICKOUTLINE")
    p.Enchant:SetFont(db.fonts.enchant, 10, "")
    p.UpgradeText:SetFont(db.fonts.upgrade, 10, "")
    p.SetLabel:SetFont(db.fonts.setBonus, 10, "")

    -- Item Dummy
    local itemID = 245966 
    local item = Item:CreateFromItemID(itemID)
    
    local rawEnchant = L["PREVIEW_ENCHANT_NAME"]
    local enchantColor = {0.4, 1, 0.4} 
    local fakeUpgrade = L["PREVIEW_UPGRADE_TEXT"]
    local fakeSet = "(2/4)" 

    -- État initial avant chargement
    if db.showItemNames then
        p.Name:SetText(L["LOADING"])
    else
        p.Name:SetText("")
    end
    p.QualityCircle:SetVertexColor(0.2, 0.2, 0.2, 1)

    item:ContinueOnItemLoad(function()
        local itemName = item:GetItemName()
        local itemQuality = item:GetItemQuality()
        local itemIcon = item:GetItemIcon()
        
        if db.showItemNames then
            p.Name:SetText(itemName or L["UNKNOWN"])
            local r, g, b = C_Item.GetItemQualityColor(itemQuality or 1)
            p.Name:SetTextColor(r, g, b)
            p.QualityCircle:SetVertexColor(r, g, b, 1)
        else
            p.Name:SetText("")
            p.QualityCircle:SetVertexColor(0.2, 0.2, 0.2, 1) 
        end
        
        if itemIcon then
            p.Icon:SetTexture(itemIcon)
        end

        -- Si la souris est déjà dessus, relancer le scroll avec le nouveau nom chargé
        if p:IsMouseOver() and db.scrollItemNames and db.showItemNames then
            Options:StartPreviewScroll(p)
        end
    end)

    local upgradeStr = ""
    if db.showUpgradeLevels then upgradeStr = fakeUpgrade end
    p.UpgradeText:SetText(upgradeStr)

    if db.showItemLevel then
        p.ItemLevel:Show()
    else
        p.ItemLevel:Hide()
    end

    if db.showEnchants then
        local cleanEnchant = rawEnchant
        cleanEnchant = string.gsub(cleanEnchant, L["PATTERN_ENCHANT_FIND"]..": ", "")
        cleanEnchant = string.gsub(cleanEnchant, "Enchant: ", "")
        cleanEnchant = string.gsub(cleanEnchant, L["PATTERN_RENFORT_FIND"]..": ", "")
        
        p.Enchant:SetText(cleanEnchant)
        p.Enchant:SetTextColor(unpack(enchantColor))
        p.RankIcon:Show() 
        p.RankIcon:SetAtlas("Professions-Icon-Quality-Tier3-Small")
    else
        p.Enchant:SetText("")
        p.RankIcon:Hide()
    end

    if db.showSetInfo then
        p.SetLabel:SetText(fakeSet)
        p.SetLabel:Show(); p.SetLabelBg:Show()
    else
        p.SetLabel:Hide(); p.SetLabelBg:Hide()
    end

    p.UpgradeText:ClearAllPoints()
    p.Enchant:ClearAllPoints()
    
    local hasUpgrade = (upgradeStr ~= "")
    local hasEnchant = (p.Enchant:GetText() ~= "")
    local anchorPoint = "LEFT"
    local xOffset = 48 

    if hasUpgrade and hasEnchant then
        p.UpgradeText:SetPoint(anchorPoint, p.IconBg, anchorPoint, xOffset, 5)
        p.Enchant:SetPoint("TOP"..anchorPoint, p.UpgradeText, "BOTTOM"..anchorPoint, 0, -2)
    elseif hasUpgrade then
        p.UpgradeText:SetPoint(anchorPoint, p.IconBg, anchorPoint, xOffset, 0)
    elseif hasEnchant then
        p.Enchant:SetPoint(anchorPoint, p.IconBg, anchorPoint, xOffset, 0)
    end

    if p.RankIcon:IsShown() then
        p.RankIcon:ClearAllPoints()
        local iconTextW = p.Enchant:GetStringWidth() + 3
        p.RankIcon:SetPoint("LEFT", p.Enchant, "LEFT", iconTextW, 0)
    end

    p:SetScript("OnEnter", function()
        if db.scrollItemNames and db.showItemNames then self:StartPreviewScroll(p) end
    end)
    p:SetScript("OnLeave", function() self:StopPreviewScroll(p) end)
end

function Options:StartPreviewScroll(p)
    p.Name:SetWidth(0) 
    local textWidth = p.Name:GetStringWidth()
    local containerWidth = p.NameContainer:GetWidth()

    if textWidth > containerWidth then
        p.Name:SetWidth(textWidth + 25)
        p.NameScrollChild:SetWidth(textWidth + 25)
        local scrollPos, speed, wait = 0, 40, 0
        p.NameContainer:SetHorizontalScroll(0)
        p.NameContainer:SetScript("OnUpdate", function(self, elapsed)
            if wait > 0 then wait = wait - elapsed; return end
            scrollPos = scrollPos + (speed * elapsed)
            if scrollPos > textWidth - containerWidth + 25 then
                scrollPos, wait = 0, 1.5
                self:SetHorizontalScroll(0)
            else
                self:SetHorizontalScroll(scrollPos)
            end
        end)
    else
        p.Name:SetWidth(containerWidth)
    end
end

function Options:StopPreviewScroll(p)
    p.NameContainer:SetScript("OnUpdate", nil)
    p.NameContainer:SetHorizontalScroll(0)
    p.Name:SetWidth(p.NameContainer:GetWidth()) 
end

function Options:CreatePreviewSlot(parent, yOffset)
    yOffset = CreateSectionHeader(parent, L["TITLE_PREVIEW"], yOffset)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetSize(540, 80)
    card:SetPoint("TOP", parent, "TOP", 0, yOffset + 15)
    CreateBackdrop(card, THEME.cardBg, {0.2, 0.2, 0.2, 0.5})

    local p = CreateFrame("Frame", nil, card)
    p:SetSize(210, 56)
    p:SetPoint("CENTER", card, "CENTER", -20, 0) 
    p:SetScale(1.0)

    p.InfoBar = p:CreateTexture(nil, "BACKGROUND", nil, 0)
    p.InfoBar:SetAtlas("128-RedButton-Disable") 
    p.InfoBar:SetHeight(40) 
    p.InfoBar:SetWidth(185) 
    p.InfoBar:SetDesaturated(true) 
    p.InfoBar:SetVertexColor(0.9, 0.9, 0.9, 1)

    local iconSize = 42
    p.IconBg = p:CreateTexture(nil, "BACKGROUND", nil, 1) 
    p.IconBg:SetSize(iconSize + 2, iconSize + 2) 
    p.IconBg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    p.IconBg:SetVertexColor(0, 0, 0, 1) 

    p.QualityCircle = p:CreateTexture(nil, "BACKGROUND", nil, 2)
    p.QualityCircle:SetSize(iconSize, iconSize)
    p.QualityCircle:SetPoint("CENTER", p.IconBg, "CENTER", 0, 0)
    p.QualityCircle:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")

    p.Icon = p:CreateTexture(nil, "ARTWORK")
    p.Icon:SetSize(iconSize - 4, iconSize - 4) 
    p.Icon:SetPoint("CENTER", p.QualityCircle, "CENTER", 0, 0)
    p.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    p.IconMask = p:CreateMaskTexture()
    p.IconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    p.IconMask:SetAllPoints(p.Icon)
    p.Icon:AddMaskTexture(p.IconMask)

    p.ItemLevel = p:CreateFontString(nil, "OVERLAY")
    p.ItemLevel:SetFont("Fonts/FRIZQT__.TTF", 18, "THICKOUTLINE")
    p.ItemLevel:SetPoint("CENTER", p.Icon, "CENTER", 0, 0) 
    p.ItemLevel:SetTextColor(1, 1, 1) 
    p.ItemLevel:SetShadowOffset(1, -1)
    p.ItemLevel:SetText("619")

    p.RankIcon = p:CreateTexture(nil, "OVERLAY")
    p.RankIcon:SetAtlas("Professions-Icon-Quality-Tier3-Small")
    p.RankIcon:SetSize(14, 14) 

    p.NameContainer = CreateFrame("ScrollFrame", nil, p)
    p.NameContainer:SetSize(190, 15) 
    p.NameScrollChild = CreateFrame("Frame", nil, p.NameContainer)
    p.NameScrollChild:SetSize(190, 15)
    p.NameContainer:SetScrollChild(p.NameScrollChild)

    p.Name = p.NameScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    p.Name:SetPoint("LEFT", p.NameScrollChild, "LEFT", 0, 0)
    p.Name:SetWordWrap(false)

    p.UpgradeText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    p.UpgradeText:SetTextColor(0, 1, 1) 
    p.UpgradeText:SetJustifyH("LEFT")

    p.Enchant = p:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny") 
    p.Enchant:SetTextColor(0.4, 1, 0.4) 
    p.Enchant:SetWordWrap(false)
    p.Enchant:SetWidth(160)
    p.Enchant:SetJustifyH("LEFT")

    p.SetLabelBg = p:CreateTexture(nil, "OVERLAY")
    p.SetLabelBg:SetSize(36, 12)
    p.SetLabelBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    p.SetLabelBg:SetVertexColor(0, 0, 0, 0.6) 
    local setMask = p:CreateMaskTexture()
    setMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    setMask:SetPoint("CENTER", p.Icon, "CENTER", 0, 0)
    setMask:SetSize(40, 40)
    p.SetLabelBg:AddMaskTexture(setMask)
    
    p.SetLabel = p:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
    p.SetLabel:SetTextColor(1, 0.82, 0) 
    p.SetLabel:SetShadowOffset(1, -1)
    
    p.SetLabelBg:SetPoint("BOTTOM", p.Icon, "BOTTOM", 0, -4)
    p.SetLabel:SetPoint("CENTER", p.SetLabelBg, "CENTER", 0, 0.5)

    p.IconBg:SetPoint("LEFT", 3, -5) 
    p.InfoBar:SetPoint("LEFT", p.IconBg, "CENTER", -10, 0)
    p.InfoBar:SetTexCoord(0, 1, 0, 1) 
    p.NameContainer:SetPoint("BOTTOMLEFT", p.IconBg, "TOPLEFT", 0, 1)
    p.Name:SetJustifyH("LEFT")

    self.PreviewSlot = p
    self:UpdatePreview()
    
    return yOffset - 90 
end

function Options:Toggle()
    if self.Frame:IsShown() then self.Frame:Hide() else self.Frame:Show() end
end

function Options:CreateStandalonePanel()
    self.fontDropdowns = {} -- Pour stocker les références des menus déroulants

    local f = CreateFrame("Frame", "MyCharacterPanel_OptionsFrame", UIParent, "BackdropTemplate")
    f:SetSize(600, 710) 
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(100)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    CreateBackdrop(f, THEME.bg, {0,0,0,1}) 

    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    header:SetHeight(40)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    CreateBackdrop(header, {0.1, 0.1, 0.12, 1}, {0,0,0,0})
    
    local accent = header:CreateTexture(nil, "OVERLAY")
    accent:SetHeight(2)
    accent:SetPoint("BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", 0, 0)
    accent:SetColorTexture(unpack(THEME.accent))

    f.Title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    f.Title:SetPoint("LEFT", 15, 0)
    f.Title:SetText("My Character Panel")
    f.Title:SetTextColor(1, 1, 1)

    f.Close = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    f.Close:SetPoint("RIGHT", -5, 0)
    f.Close:SetScript("OnClick", function() f:Hide() end)

    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -50)
    scroll:SetPoint("BOTTOMRIGHT", -30, 70) 
    
    local regions = {scroll:GetRegions()}
    for _, region in ipairs(regions) do if region:IsObjectType("Texture") then region:Hide() end end

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(560, 1150)
    scroll:SetScrollChild(content)

    -- Smooth Scroll
    scroll.scrollTarget = 0
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local range = self:GetVerticalScrollRange()
        local step = 50 

        if not self.scrollTarget then self.scrollTarget = current end
        if math.abs(self.scrollTarget - current) > 200 then self.scrollTarget = current end

        if delta > 0 then
            self.scrollTarget = math.max(0, self.scrollTarget - step)
        else
            self.scrollTarget = math.min(range, self.scrollTarget + step)
        end

        self:SetScript("OnUpdate", function(s, elapsed)
            local now = s:GetVerticalScroll()
            local target = s.scrollTarget
            local diff = target - now

            if math.abs(diff) < 0.5 then
                s:SetVerticalScroll(target)
                s:SetScript("OnUpdate", nil)
            else
                s:SetVerticalScroll(now + (diff * (elapsed * 15)))
            end
        end)
    end)

    local yOffset = -10
    yOffset = self:CreatePreviewSlot(content, yOffset)
    yOffset = yOffset - 20

    local function CreateCB(label, key, tooltipText)
        local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 25, yOffset)
        cb.text:SetText(label)
        cb.text:SetFontObject("GameFontHighlight")
        cb.text:SetTextColor(unpack(THEME.textNormal))
        cb:SetChecked(self.db[key])
        
        if tooltipText then
            cb:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(label, 1, 1, 1)
                GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
                GameTooltip:Show()
            end)
            cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        cb:SetScript("OnClick", function(btn)
            self.db[key] = btn:GetChecked()
            self:UpdatePreview() 
            Options:TriggerUpdate() 
        end)
        yOffset = yOffset - 30
    end

    local function CreateFontDD(label, dbKey, tooltipText)
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(500, 30)
        row:SetPoint("TOPLEFT", 20, yOffset)

        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local lbl = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        lbl:SetPoint("LEFT", 0, 0)
        lbl:SetText(label)
        lbl:SetTextColor(unpack(THEME.textNormal))
        
        local dd = CreateFrame("Frame", nil, row, "UIDropDownMenuTemplate")
        dd:SetPoint("RIGHT", 0, 0)
        UIDropDownMenu_SetWidth(dd, 180)
        
        UIDropDownMenu_Initialize(dd, function()
            local sortedFonts = {}
            for i, f in ipairs(C.AVAILABLE_FONTS) do
                sortedFonts[i] = f
            end
            table.sort(sortedFonts, function(a, b) return a.name < b.name end)

            for _, fontData in ipairs(sortedFonts) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = fontData.name
                info.value = fontData.path
                info.checked = (self.db.fonts[dbKey] == fontData.path)
                info.func = function(btn)
                    self.db.fonts[dbKey] = btn.value
                    UIDropDownMenu_SetSelectedValue(dd, btn.value)
                    self:UpdatePreview()
                    Options:TriggerUpdate() 
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        
        UIDropDownMenu_SetSelectedValue(dd, self.db.fonts[dbKey])
        
        local currentPath = self.db.fonts[dbKey]
        local foundName = L["UNKNOWN"]
        for _, f in ipairs(C.AVAILABLE_FONTS) do
            if f.path == currentPath then foundName = f.name; break end
        end
        UIDropDownMenu_SetText(dd, foundName)
        
        -- On stocke la référence du menu pour le bouton Reset
        self.fontDropdowns[dbKey] = dd
        
        yOffset = yOffset - 35
    end

    yOffset = CreateSectionHeader(content, L["TITLE_GENERAL_DISPLAY"], yOffset)
    CreateCB(L["OPTION_SHOW_ITEM_NAMES"], "showItemNames", L["OPTION_SHOW_ITEM_NAMES_DESC"])
    CreateCB(L["OPTION_SHOW_ITEM_LEVEL"], "showItemLevel", L["OPTION_SHOW_ITEM_LEVEL_DESC"])
    CreateCB(L["OPTION_SCROLL_NAMES"], "scrollItemNames", L["OPTION_SCROLL_NAMES_DESC"])
    CreateCB(L["OPTION_SHOW_UPGRADE"], "showUpgradeLevels", L["OPTION_SHOW_UPGRADE_DESC"])
    CreateCB(L["OPTION_SHOW_ENCHANTS"], "showEnchants", L["OPTION_SHOW_ENCHANTS_DESC"])
    CreateCB(L["OPTION_SHOW_SET_INFO"], "showSetInfo", L["OPTION_SHOW_SET_INFO_DESC"])
    CreateCB(L["OPTION_SHOW_MODEL"], "showModelPreview", L["OPTION_SHOW_MODEL_DESC"])
    yOffset = yOffset - 10

    -- La partie pour choisir les polices d'écriture
    local typoHeader
    yOffset, typoHeader = CreateSectionHeader(content, L["TITLE_TYPOGRAPHY"], yOffset, L["RELOAD_REQUIRED_SHORT"])
    
    -- BOUTON RELOAD UI
    if typoHeader then
        local reloadBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        reloadBtn:SetSize(280, 20)
        reloadBtn:SetPoint("LEFT", typoHeader, "RIGHT", 130, 0)
        reloadBtn:SetText(L["BUTTON_APPLY_FONTS"])
        reloadBtn:SetScript("OnClick", function()
            ReloadUI()
        end)
    end
    
    -- Fond pour la section typo (Agrandie pour tout contenir)
    local typoBg = CreateFrame("Frame", nil, content, "BackdropTemplate")
    typoBg:SetPoint("TOPLEFT", 10, yOffset + 5)
    typoBg:SetSize(540, 280) 
    CreateBackdrop(typoBg, THEME.cardBg, {0,0,0,0})
    yOffset = yOffset - 10

    CreateFontDD(L["FONT_ACCORDION_TITLE"], "headers", L["FONT_ACCORDION_TITLE_DESC"])
    CreateFontDD(L["FONT_ITEM_NAME"], "itemName", L["FONT_ITEM_NAME_DESC"])
    CreateFontDD(L["FONT_ITEM_LEVEL"], "itemLevel", L["FONT_ITEM_LEVEL_DESC"])
    CreateFontDD(L["FONT_ENCHANTS"], "enchant", L["FONT_ENCHANTS_DESC"])
    CreateFontDD(L["FONT_UPGRADE"], "upgrade", L["FONT_UPGRADE_DESC"])
    CreateFontDD(L["FONT_SET_BONUS"], "setBonus", L["FONT_SET_BONUS_DESC"]) 
    
    yOffset = yOffset - 40 -- Espace après la zone 

    yOffset = CreateSectionHeader(content, L["TITLE_BEHAVIOR"], yOffset)
    local behavFrame = CreateFrame("Frame", nil, content)
    behavFrame:SetSize(540, 40)
    behavFrame:SetPoint("TOPLEFT", 10, yOffset)
    local ddLabel = behavFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    ddLabel:SetPoint("LEFT", 15, 0)
    ddLabel:SetText(L["OPTION_DEFAULT_ACCORDION"])
    ddLabel:SetTextColor(unpack(THEME.textNormal))
    local ddAcc = CreateFrame("Frame", nil, behavFrame, "UIDropDownMenuTemplate")
    ddAcc:SetPoint("LEFT", ddLabel, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(ddAcc, 160)
    UIDropDownMenu_Initialize(ddAcc, function()
        local function SetAcc(self)
            Options.db.defaultAccordion = self.value 
            UIDropDownMenu_SetSelectedValue(ddAcc, self.value)
        end
        local list = {{L["TITLE_ATTRIBUTES"], 1}, {L["TITLE_EQUIPMENT"], 2}, {L["TITLE_TITLES"], 3}, {L["OPTION_ACCORDION_ALL_COLLAPSED"], 0}}
        for _, v in ipairs(list) do
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = v[1], v[2]
            info.checked = (Options.db.defaultAccordion == v[2])
            info.func = SetAcc
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(ddAcc, Options.db.defaultAccordion)
    local reloadText = behavFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    reloadText:SetPoint("LEFT", ddAcc, "RIGHT", -10, 0)
    reloadText:SetText(L["RELOAD_REQUIRED_SHORT"])
    reloadText:SetTextColor(1, 0.3, 0.3)
    yOffset = yOffset - 60
    
    -- Notes d'information
    local infoNote1 = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    infoNote1:SetPoint("TOPLEFT", 25, yOffset)
    infoNote1:SetWidth(520)
    infoNote1:SetJustifyH("LEFT")
    infoNote1:SetText("|cff00ccff•|r " .. (L["INFO_NOTE_STATS_DRAG"] or "You can move stats via Click/Drag"))
    infoNote1:SetTextColor(0.7, 0.7, 0.7)
    yOffset = yOffset - 25
    
    local infoNote2 = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    infoNote2:SetPoint("TOPLEFT", 25, yOffset)
    infoNote2:SetWidth(520)
    infoNote2:SetJustifyH("LEFT")
    infoNote2:SetText("|cff00ccff•|r " .. (L["INFO_NOTE_ZOOM_SCROLL"] or "You can change frame size with CTRL + mouse wheel"))
    infoNote2:SetTextColor(0.7, 0.7, 0.7)
    yOffset = yOffset - 35
    
    -- Checkbox pour verrouiller le zoom
    local lockZoomCB = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    lockZoomCB:SetPoint("TOPLEFT", 25, yOffset)
    lockZoomCB.text:SetText(L["OPTION_LOCK_ZOOM"] or "Lock zoom")
    lockZoomCB.text:SetTextColor(unpack(THEME.textNormal))
    lockZoomCB:SetChecked(self.db.lockZoom)
    
    lockZoomCB:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["OPTION_LOCK_ZOOM_DESC"] or "Prevents changing interface size with CTRL + Mouse Wheel")
        GameTooltip:Show()
    end)
    lockZoomCB:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    lockZoomCB:SetScript("OnClick", function(btn)
        Options.db.lockZoom = btn:GetChecked()
    end)
    yOffset = yOffset - 40

    yOffset = CreateSectionHeader(content, L["TITLE_ALERT_MISSING_ENCHANT"], yOffset)
    local alertBg = CreateFrame("Frame", nil, content, "BackdropTemplate")
    alertBg:SetPoint("TOPLEFT", 10, yOffset)
    alertBg:SetSize(540, 310) 
    CreateBackdrop(alertBg, THEME.cardBg, {0,0,0,0})

    local desc = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", content, "TOPLEFT", 15, yOffset - 5)
    desc:SetWidth(520)
    desc:SetJustifyH("LEFT")
    desc:SetText(L["OPTION_ALERT_MISSING_ENCHANT_DESC"])
    desc:SetTextColor(0.7, 0.7, 0.7)
    
    local gridStartY = yOffset - 35 

    local slotsCol1 = {
        {1, L["SLOT_HEAD"]}, {2, L["SLOT_NECK"]}, {3, L["SLOT_SHOULDER"]}, {15, L["SLOT_BACK"]}, 
        {5, L["SLOT_CHEST"]}, {9, L["SLOT_WRIST"]}, {10, L["SLOT_HAND"]}, {16, L["SLOT_MAINHAND"]} 
    }
    local slotsCol2 = {
        {6, L["SLOT_WAIST"]}, {7, L["SLOT_LEGS"]}, {8, L["SLOT_FEET"]},
        {11, L["SLOT_FINGER1"]}, {12, L["SLOT_FINGER2"]}, {13, L["SLOT_TRINKET1"]}, {14, L["SLOT_TRINKET2"]},
        {17, L["SLOT_OFFHAND"]}
    }
    
    local function CreateAlertCheck(data, xPos, yPos)
        local slotID, name = unpack(data)
        local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", xPos, yPos)
        cb.text:SetText(name)
        cb.text:SetFontObject("GameFontHighlightSmall")
        cb.text:SetTextColor(unpack(THEME.textNormal))
        
        if not self.charDb.enchantCheckSlots[slotID] then
             cb.text:SetTextColor(0.5, 0.5, 0.5)
        end

        cb:SetChecked(self.charDb.enchantCheckSlots[slotID])
        cb:SetScript("OnClick", function(btn)
            self.charDb.enchantCheckSlots[slotID] = btn:GetChecked()
            if btn:GetChecked() then
                btn.text:SetTextColor(unpack(THEME.textNormal))
            else
                btn.text:SetTextColor(0.5, 0.5, 0.5)
            end
            Options:TriggerUpdate() 
        end)
    end

    for i, data in ipairs(slotsCol1) do CreateAlertCheck(data, 30, gridStartY - ((i-1) * 30)) end
    for i, data in ipairs(slotsCol2) do CreateAlertCheck(data, 300, gridStartY - ((i-1) * 30)) end
    
    yOffset = gridStartY - (8 * 30) - 20
    
    -- ==============================================================================
    -- SECTION: RESTAURATION (RESET)
    -- ==============================================================================
    
    yOffset = CreateSectionHeader(content, L["TITLE_RESET_SECTION"] or "Restore Defaults", yOffset)
    
    local resetBg = CreateFrame("Frame", nil, content, "BackdropTemplate")
    resetBg:SetPoint("TOPLEFT", 10, yOffset) 
    resetBg:SetSize(540, 80)
    CreateBackdrop(resetBg, THEME.cardBg, {0,0,0,0})
    
    -- Bouton RESET POLICES
    local resetFontsBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetFontsBtn:SetSize(220, 24)
    resetFontsBtn:SetPoint("TOPLEFT", 40, yOffset - 25)
    resetFontsBtn:SetText(L["BUTTON_RESET_FONTS"])
    resetFontsBtn:SetScript("OnClick", function()
        StaticPopup_Show("MYCHARPANEL_RESET_FONTS")
    end)
    
    -- Bouton RESET STATS
    local resetStatsBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetStatsBtn:SetSize(220, 24)
    resetStatsBtn:SetPoint("TOPRIGHT", -40, yOffset - 25) 
    resetStatsBtn:SetText(L["RESET_STATS"])
    resetStatsBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["RESET_STATS"], 1, 1, 1)
        GameTooltip:AddLine(L["RESET_STATS_DESC"], nil, nil, nil, true)
        GameTooltip:Show()
    end)
    resetStatsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    resetStatsBtn:SetScript("OnClick", function()
         StaticPopup_Show("MYCHARPANEL_RESET_STATS")
    end)
    
    yOffset = yOffset - 100

    -- Pied de page (Versions standalone)

    local footer = CreateFrame("Frame", nil, f)
    footer:SetSize(600, 60) 
    footer:SetPoint("BOTTOM", 0, 0)
    
    local sep = footer:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 20, 0)
    sep:SetPoint("TOPRIGHT", -20, 0)
    sep:SetColorTexture(1, 1, 1, 0.05) 

    local devName = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    devName:SetPoint("TOP", footer, "TOP", 0, -10) 
    devName:SetText(L["DEV_LABEL"])

    local devLogo = footer:CreateTexture(nil, "ARTWORK")
    devLogo:SetSize(12, 12) 
    devLogo:SetPoint("RIGHT", devName, "LEFT", -6, 0)
    devLogo:SetTexture("Interface\\AddOns\\"..addonName.."\\Utils\\logo\\Fr.png")

    local iconSize = 16 
    local iconBg = footer:CreateTexture(nil, "BACKGROUND")
    iconBg:SetSize(iconSize, iconSize)
    iconBg:SetPoint("LEFT", devName, "RIGHT", 6, 0)
    iconBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    iconBg:SetVertexColor(0,0,0,1)
    
    local bgMask = footer:CreateMaskTexture()
    bgMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    bgMask:SetAllPoints(iconBg)
    iconBg:AddMaskTexture(bgMask)

    local classIcon = footer:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(iconSize, iconSize)
    classIcon:SetPoint("CENTER", iconBg, "CENTER")
    classIcon:SetTexture("Interface\\Icons\\ClassIcon_Shaman")
    classIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    
    local mask = footer:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(classIcon)
    classIcon:AddMaskTexture(mask)

    local credits = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") 
    credits:SetPoint("TOP", devName, "BOTTOM", 0, -5) 
    credits:SetJustifyH("CENTER")
    credits:SetTextColor(0.7, 0.7, 0.7) 
    credits:SetText(L["CREDITS_TEXTURE_ATLAS"] .. "\n" .. L["CREDITS_NEXUS"])

    self.Frame = f
end

-- Enregistrement du panneau d'options Blizzard

function Options:RegisterBlizzardSettings()
    local panel = CreateFrame("Frame", "MyCharacterPanel_BlizzSettings")
    panel.name = "My Character Panel"
    
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    
    local center = CreateFrame("Frame", nil, panel)
    center:SetSize(450, 400)
    center:SetPoint("CENTER")
    
    -- Logo


    local logo = center:CreateTexture(nil, "ARTWORK")
    logo:SetSize(200, 200)
    logo:SetPoint("TOP", 0, -20)
    logo:SetTexture("Interface\\AddOns\\"..addonName.."\\Utils\\logo\\mcpaddon.png")

    -- Titre


    local title = center:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOP", logo, "BOTTOM", 0, -10)
    title:SetText("My Character Panel")
    title:SetTextColor(unpack(THEME.accent))

    -- Instructions d'accès


    local desc = center:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    desc:SetPoint("TOP", title, "BOTTOM", 0, -25)
    desc:SetWidth(420)
    desc:SetSpacing(4) -- Espace un peu les lignes pour la lisibilité
    desc:SetJustifyH("CENTER")
    
    -- L'icône roue dentée est insérée directement dans le texte via |T...|t
    desc:SetText(L["INSTRUCTION_ACCESS"])
    
    -- Section d'aide : Zoom
    
    local helpZoom = center:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    helpZoom:SetPoint("TOP", desc, "BOTTOM", 0, -30)
    helpZoom:SetWidth(420)
    helpZoom:SetSpacing(3)
    helpZoom:SetJustifyH("LEFT")
    helpZoom:SetText(L["HELP_ZOOM"] or "|cffffffffZoom:|r Hold CTRL and use mouse wheel to adjust size (50%-150%)")
    
    -- Section d'aide : Réorganisation des stats
    
    local helpStats = center:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    helpStats:SetPoint("TOP", helpZoom, "BOTTOM", 0, -15)
    helpStats:SetWidth(420)
    helpStats:SetSpacing(3)
    helpStats:SetJustifyH("LEFT")
    helpStats:SetText(L["HELP_STATS_REORDER"] or "|cffffffffStats Reorder:|r Click and drag stats to reorder them")

    -- Pied de page avec crédits


    local footer = CreateFrame("Frame", nil, panel)
    footer:SetSize(400, 60)
    footer:SetPoint("BOTTOM", 0, 30)

    -- Développeur

    local devName = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    devName:SetPoint("TOP", 0, 0)
    devName:SetText(L["DEV_LABEL"])

    -- Drapeau

    local flag = footer:CreateTexture(nil, "ARTWORK")
    flag:SetSize(12, 12)
    flag:SetTexture("Interface\\AddOns\\"..addonName.."\\Utils\\logo\\Fr.png")
    flag:SetPoint("RIGHT", devName, "LEFT", -6, 0)

    -- Icône de classe

    local iconSize = 16 
    local iconBg = footer:CreateTexture(nil, "BACKGROUND")
    iconBg:SetSize(iconSize, iconSize)
    iconBg:SetPoint("LEFT", devName, "RIGHT", 6, 0)
    iconBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    iconBg:SetVertexColor(0,0,0,1)
    
    local bgMask = footer:CreateMaskTexture()
    bgMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    bgMask:SetAllPoints(iconBg)
    iconBg:AddMaskTexture(bgMask)

    local classIcon = footer:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(iconSize, iconSize)
    classIcon:SetPoint("CENTER", iconBg, "CENTER")
    classIcon:SetTexture("Interface\\Icons\\ClassIcon_Shaman")
    classIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    
    local mask = footer:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(classIcon)
    classIcon:AddMaskTexture(mask)

    -- Remerciements

    local credits = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    credits:SetPoint("TOP", devName, "BOTTOM", 0, -5)
    credits:SetTextColor(0.5, 0.5, 0.5)
    credits:SetText(L["CREDITS_TEXTURE_ATLAS"])
end