local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

-- Définition de classe pour le linter :
-- Cela informe l'analyseur que nos boutons de menu auront une propriété 'SpecIcon' et une méthode 'AttachTexture'.
---@class EquipmentMenuButton : Button
---@field SpecIcon Texture
---@field AttachTexture fun(self: EquipmentMenuButton): Texture

local CreateFrame = CreateFrame
local C_EquipmentSet = C_EquipmentSet
local C_Item = C_Item
local C_Spell = C_Spell
local GetSpecialization, GetSpecializationInfo = GetSpecialization, GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetNumSpecializations = GetNumSpecializations
local GetMacroItemIcons, GetMacroIcons = GetMacroItemIcons, GetMacroIcons
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local tinsert, wipe, sort = table.insert, table.wipe, table.sort
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local ipairs, pairs = ipairs, pairs
local StaticPopup_Show = StaticPopup_Show

local MenuUtil = MenuUtil

addon.EquipmentMixin = {}
local EquipmentMixin = addon.EquipmentMixin

-- Récupération sécurisée des globales pour garantir le type 'string' (et non string?)
-- Récupération des globales via L
local TEXT_CONFIRM_SAVE = L["TEXT_CONFIRM_SAVE"]
local TEXT_CONFIRM_DELETE = L["TEXT_CONFIRM_DELETE"]
local TEXT_YES = L["YES"]
local TEXT_NO = L["NO"]
local TEXT_EQUIP = L["EQUIP"]
local TEXT_SAVE = L["SAVE"]
local TEXT_NEW_SET = L["NEW_SET"]
local TEXT_EDIT = L["EDIT"]
local TEXT_DELETE = L["DELETE"]
local TEXT_SPECIALIZATION = L["SPECIALIZATION"]
local TEXT_NAME = L["NAME"]
local TEXT_CHOOSE_ICON = L["CHOOSE_ICON"]
local TEXT_ENTER_NAME = L["ENTER_NAME"]
local TEXT_CANCEL = L["CANCEL"]
local TEXT_OK = L["OK"]
local TEXT_EQUIPMENT = L["TITLE_EQUIPMENT"]

-- POPUPS
StaticPopupDialogs["MYCHARACTERPANEL_CONFIRM_SAVE_SET"] = {
    text = TEXT_CONFIRM_SAVE,
    button1 = TEXT_YES,
    button2 = TEXT_NO,
    OnAccept = function(self)
        if self.data then
            C_EquipmentSet.SaveEquipmentSet(self.data)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
}

StaticPopupDialogs["MYCHARACTERPANEL_CONFIRM_DELETE_SET"] = {
    text = TEXT_CONFIRM_DELETE, 
    button1 = TEXT_YES,
    button2 = TEXT_NO,
    OnAccept = function(self)
        if self.data then
            C_EquipmentSet.DeleteEquipmentSet(self.data)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1,
}

function EquipmentMixin:OnLoad()
    -- Fond général

    self.Background = self:CreateTexture(nil, "BACKGROUND")
    self.Background:SetPoint("TOPLEFT", 4, -4)
    self.Background:SetPoint("BOTTOMRIGHT", -4, 4)
    self.Background:SetAtlas(C.CONTENT_ATLAS)
    self.Background:SetVertexColor(0.8, 0.8, 0.8, 1)
    
    self:SetBackdrop({
        bgFile = nil, 
        edgeFile = C.BORDER_TEXTURE, 
        tile = true, tileSize = 256, edgeSize = 28, 
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    self:SetBackdropColor(1, 1, 1, 1)
    self:SetBackdropBorderColor(1, 1, 1, 1)
    self:SetClampedToScreen(true)
    self:SetClipsChildren(false) 

    -- État fermé

    self.CenterContainer = CreateFrame("Frame", nil, self)
    self.CenterContainer:SetPoint("TOPLEFT", 0, 0)
    self.CenterContainer:SetPoint("BOTTOMRIGHT", 0, 0)
    
    self.Icon = self.CenterContainer:CreateTexture(nil, "ARTWORK")
    self.Icon:SetSize(26, 26)
    self.Icon:SetPoint("CENTER", self.CenterContainer, "TOP", 0, 12)
    self.Icon:SetTexture("Interface\\AddOns\\MyCharacterPanel\\Utils\\logo\\eqp.png")
    self.Icon:SetTexCoord(0, 1, 0, 1)
    
    self.VerticalLabel = self.CenterContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local labelText = L["TITLE_EQUIPMENT"]
    self.VerticalLabel:SetText("   " .. labelText)
    self.VerticalLabel:SetTextColor(1, 0.82, 0)
    self.VerticalLabel:SetRotation(math.rad(270))
    self.VerticalLabel:SetJustifyH("CENTER")
    self.VerticalLabel:SetJustifyV("MIDDLE")
    self.VerticalLabel:SetWordWrap(false)
    self.VerticalLabel:SetPoint("CENTER", self.CenterContainer, "CENTER", 9, 0)

    self.Glow = self.CenterContainer:CreateTexture(nil, "OVERLAY")
    self.Glow:SetColorTexture(1, 1, 1) 
    self.Glow:SetBlendMode("ADD")
    self.Glow:SetPoint("TOPLEFT", 4, -4)
    self.Glow:SetPoint("BOTTOMRIGHT", -4, 4)
    self.Glow:SetAlpha(0)

    self.GlowAnim = self.Glow:CreateAnimationGroup()
    local anim = self.GlowAnim:CreateAnimation("Alpha")
    anim:SetFromAlpha(0.1)
    anim:SetToAlpha(0.25)
    anim:SetDuration(0.8)
    anim:SetSmoothing("IN_OUT")
    self.GlowAnim:SetLooping("BOUNCE")

    self.ExpandBtn = CreateFrame("Button", nil, self)
    self.ExpandBtn:SetAllPoints()
    self.ExpandBtn:Hide()
    self.CenterContainer:Hide() 
    
    self.ExpandBtn:SetScript("OnEnter", function() 
        self.Glow:Show()
        self.GlowAnim:Play()
        self.VerticalLabel:SetTextColor(1, 1, 1)
    end)
    self.ExpandBtn:SetScript("OnLeave", function() 
        self.GlowAnim:Stop()
        self.Glow:SetAlpha(0)
        self.VerticalLabel:SetTextColor(1, 0.82, 0)
    end)
    self.ExpandBtn:SetScript("OnClick", function() 
        local parent = self:GetParent()
        if parent.ToggleEquipment then parent:ToggleEquipment(true) end
    end)

    -- État ouvert

    self.Content = CreateFrame("Frame", nil, self)
    self.Content:SetAllPoints()
    self.Content:Show() 

    self.CollapseBtn = CreateFrame("Button", nil, self.Content)
    self.CollapseBtn:SetSize(28, 28)
    self.CollapseBtn:SetPoint("TOPLEFT", 0, -10)
    self.CollapseBtn.Icon = self.CollapseBtn:CreateTexture(nil, "ARTWORK")
    self.CollapseBtn.Icon:SetAllPoints()
    self.CollapseBtn.Icon:SetAtlas("NPE_ArrowDown")
    self.CollapseBtn.Icon:SetRotation(math.rad(-90))
    self.CollapseBtn:SetScript("OnEnter", function(btn) btn.Icon:SetVertexColor(1, 1, 1) end)
    self.CollapseBtn:SetScript("OnLeave", function(btn) btn.Icon:SetVertexColor(0.7, 0.7, 0.7) end)
    self.CollapseBtn:SetScript("OnClick", function() 
        local parent = self:GetParent()
        if parent.ToggleEquipment then parent:ToggleEquipment() end
    end)

    self.HeaderTitle = self.Content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.HeaderTitle:SetPoint("LEFT", self.CollapseBtn, "RIGHT", 5, 0)
    self.HeaderTitle:SetPoint("RIGHT", -10, 0)
    self.HeaderTitle:SetJustifyH("CENTER")
    self.HeaderTitle:SetText(L["TITLE_EQUIPMENT"])
    self.HeaderTitle:SetTextColor(1, 0.82, 0)

    -- BOUTONS D'ACTION
    self.EquipSetBtn = CreateFrame("Button", nil, self.Content, "UIPanelButtonTemplate")
    self.EquipSetBtn:SetSize(95, 22)
    self.EquipSetBtn:SetPoint("TOPLEFT", 15, -45)
    self.EquipSetBtn:SetText(TEXT_EQUIP)
    self.EquipSetBtn:SetScript("OnClick", function() 
        if self.selectedSetID then
            C_EquipmentSet.UseEquipmentSet(self.selectedSetID)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        end
    end)
    self.EquipSetBtn:Disable()

    self.SaveSetBtn = CreateFrame("Button", nil, self.Content, "UIPanelButtonTemplate")
    self.SaveSetBtn:SetSize(95, 22)
    self.SaveSetBtn:SetPoint("TOPRIGHT", -15, -45)
    self.SaveSetBtn:SetText(TEXT_SAVE)
    self.SaveSetBtn:SetScript("OnClick", function() 
        if self.selectedSetID then
            local setName = C_EquipmentSet.GetEquipmentSetInfo(self.selectedSetID)
            -- Garantie de type string pour le linter
            local safeSetName = setName or ""
            if safeSetName ~= "" then
                StaticPopup_Show("MYCHARACTERPANEL_CONFIRM_SAVE_SET", safeSetName, nil, self.selectedSetID)
            end
        end
    end)
    self.SaveSetBtn:Disable() 

    -- SCROLL FRAME
    self.ScrollFrame = CreateFrame("ScrollFrame", nil, self.Content, "UIPanelScrollFrameTemplate")
    self.ScrollFrame:SetPoint("TOPLEFT", 10, -75)
    self.ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    self.ScrollChild = CreateFrame("Frame", nil, self.ScrollFrame)
    self.ScrollChild:SetSize(200, 1) 
    self.ScrollFrame:SetScrollChild(self.ScrollChild)

    self.buttons = {}
    self.setList = {}
    
    self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:RegisterEvent("PLAYER_LOGIN") 
    self:SetScript("OnEvent", function() self:UpdateSets() end)
    
    self:CreateDialogFrame()

    C_Timer.After(0.2, function() self:UpdateSets() end)
end

function EquipmentMixin:UpdateSets()
    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    wipe(self.setList)
    
    for _, id in ipairs(setIDs) do
        local name, iconFileID, setID, isEquipped, numItems, numEquipped, numInventory, numMissing, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(id)
        if name then
            tinsert(self.setList, {
                id = id,
                name = name,
                icon = iconFileID,
                isEquipped = isEquipped,
                numMissing = numMissing or 0,
                numIgnored = numIgnored,
                isNew = false
            })
        end
    end
    
    sort(self.setList, function(a, b) return a.name < b.name end)

    tinsert(self.setList, {
        id = -1,
        name = TEXT_NEW_SET,
        icon = "Interface\\PaperDollInfoFrame\\Character-Plus",
        isEquipped = false,
        numMissing = 0,
        isNew = true 
    })

    local buttonHeight = 44
    local totalHeight = 0
    
    for i, setData in ipairs(self.setList) do
        local btn = self.buttons[i]
        
        -- Initialisation du bouton

        if not btn then
            btn = CreateFrame("Button", nil, self.ScrollChild, "BackdropTemplate")
            btn:SetSize(195, buttonHeight)
            
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8", 
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
                tile = false, tileSize = 16, edgeSize = 12, 
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })

            btn.Icon = btn:CreateTexture(nil, "ARTWORK")
            btn.Icon:SetSize(36, 36)
            btn.Icon:SetPoint("LEFT", 4, 0)
            
            -- Bouton paramètres
            btn.SettingsBtn = CreateFrame("Button", nil, btn)
            btn.SettingsBtn:SetSize(18, 18)
            btn.SettingsBtn:SetPoint("RIGHT", -5, 0)
            btn.SettingsBtn:SetNormalTexture("Interface\\WorldMap\\Gear_64Grey")
            btn.SettingsBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
            btn.SettingsBtn:GetHighlightTexture():SetBlendMode("ADD")
            btn.SettingsBtn:Hide()
            
            btn.SettingsBtn:SetScript("OnClick", function(settingsBtn) 
                self:ShowContextMenu(settingsBtn, btn.setID, btn.setName, btn.icon)
            end)
            
            btn.Name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.Name:SetPoint("LEFT", btn.Icon, "RIGHT", 10, 0)
            btn.Name:SetPoint("RIGHT", -25, 0) 
            btn.Name:SetPoint("TOP", 0, -4) 
            btn.Name:SetPoint("BOTTOM", 0, 4)
            btn.Name:SetJustifyH("CENTER")
            btn.Name:SetJustifyV("MIDDLE")
            btn.Name:SetWordWrap(true)
            btn.Name:SetMaxLines(2)
            
            -- Icône de spécialisation avec Atlas

            
            -- Le cadre (Atlas ChallengeMode)

            btn.SpecBorder = btn:CreateTexture(nil, "ARTWORK")
            btn.SpecBorder:SetSize(33, 33) 
            btn.SpecBorder:SetPoint("BOTTOMRIGHT", btn.Icon, "BOTTOMRIGHT", 12, -12) 
            btn.SpecBorder:SetAtlas("housing-layout-room-orb-ring-outerglow")

            -- L'icône (Contenu)

            btn.SpecIcon = btn:CreateTexture(nil, "OVERLAY")
            btn.SpecIcon:SetSize(20, 20) 
            btn.SpecIcon:SetPoint("CENTER", btn.SpecBorder, "CENTER", 0, 0)
            
            -- Le masque (Rend l'icône ronde)

            btn.SpecMask = btn:CreateMaskTexture()
            btn.SpecMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
            btn.SpecMask:SetSize(20, 20) 
            btn.SpecMask:SetPoint("CENTER", btn.SpecIcon)
            
            btn.SpecIcon:AddMaskTexture(btn.SpecMask)

            btn:SetScript("OnEnter", function(b) 
                if not b.isNew then b.SettingsBtn:Show() end
                b:SetBackdropColor(0.2, 0.2, 0.2, 0.8) 
            end)
            btn:SetScript("OnLeave", function(b) 
                if not b:IsMouseOver() then b.SettingsBtn:Hide() end
                self:UpdateButtonState(b) 
            end)
            btn:SetScript("OnClick", function(b, button)
                if b.isNew then
                    self:OpenSetDialog() 
                elseif button == "LeftButton" then
                    self.selectedSetID = b.setID
                    self.EquipSetBtn:Enable()
                    self.SaveSetBtn:Enable()
                    self:UpdateSets() 
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                end
            end)
            
            btn.SettingsBtn:SetScript("OnEnter", function() btn:GetScript("OnEnter")(btn) end)
            btn.SettingsBtn:SetScript("OnLeave", function() btn:GetScript("OnLeave")(btn) end)

            self.buttons[i] = btn
        end
        
        -- Mise à jour du bouton

        btn:SetPoint("TOPLEFT", 0, -totalHeight)
        btn.Icon:SetTexture(setData.icon)
        btn.Name:SetText(setData.name)
        btn.setID = setData.id
        btn.setName = setData.name
        btn.icon = setData.icon
        btn.isNew = setData.isNew
        btn.hasMissing = (setData.numMissing > 0)
        btn.isEquipped = setData.isEquipped
        
        if setData.isNew then
            btn.Name:SetTextColor(0, 1, 0)
            btn.Icon:SetTexCoord(0, 1, 0, 1) 
            btn.SpecIcon:Hide()
            btn.SpecBorder:Hide()
            btn.SettingsBtn:Hide()
        else
            btn.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            
            -- Centrage vertical permanent (Plus de "Manquant")
            btn.Name:SetPoint("BOTTOM", 0, 4) 
            
            -- Affichage de l'icône de spé
            local assignedSpecIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(setData.id)
            if assignedSpecIndex and assignedSpecIndex > 0 then
                local _, _, _, icon = GetSpecializationInfo(assignedSpecIndex)
                btn.SpecIcon:SetTexture(icon)
                btn.SpecIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Zoom léger
                btn.SpecIcon:Show()
                btn.SpecBorder:Show()
            else
                btn.SpecIcon:Hide()
                btn.SpecBorder:Hide()
            end
        end
        
        self:UpdateButtonState(btn) 
        
        btn:Show()
        totalHeight = totalHeight + buttonHeight + 4
    end
    
    for i = #self.setList + 1, #self.buttons do self.buttons[i]:Hide() end
    self.ScrollChild:SetHeight(totalHeight)
end

function EquipmentMixin:UpdateButtonState(btn)
    if not btn:IsMouseOver() then btn.SettingsBtn:Hide() end

    local r, g, b, a = 0.1, 0.1, 0.1, 0.5 
    local br, bg, bb, ba = 0.4, 0.4, 0.4, 1 
    local textR, textG, textB = 1, 0.82, 0 

    if btn.isNew then
        br, bg, bb = 0, 1, 0
        textR, textG, textB = 0, 1, 0
    else
        if btn.isEquipped then
            br, bg, bb = 0, 0.5, 1 
            r, g, b, a = 0, 0.2, 0.5, 0.3 
            textR, textG, textB = 1, 1, 1
        elseif btn.hasMissing then
            br, bg, bb = 1, 0, 0 
            r, g, b, a = 0.3, 0, 0, 0.3 
            textR, textG, textB = 1, 0.1, 0.1
        end

        if self.selectedSetID == btn.setID then
            a = 0.6 
            br, bg, bb = 1, 0.82, 0 
            ba = 1
        end
    end

    btn:SetBackdropColor(r, g, b, a)
    btn:SetBackdropBorderColor(br, bg, bb, ba)
    if not btn.isNew then
        btn.Name:SetTextColor(textR, textG, textB)
    end
end

-- DIALOGUE ICONES
function EquipmentMixin:CreateDialogFrame()
    self.allIcons = {}
    local itemIcons = {}
    local macroIcons = {}
    GetMacroItemIcons(itemIcons)
    GetMacroIcons(macroIcons)
    for _, icon in ipairs(itemIcons) do tinsert(self.allIcons, icon) end
    for _, icon in ipairs(macroIcons) do tinsert(self.allIcons, icon) end

    local f = CreateFrame("Frame", nil, self:GetParent(), "BackdropTemplate")
    f:SetSize(400, 500)
    f:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
    f:SetFrameStrata("DIALOG")
    f:Hide()
    
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.Title:SetPoint("TOP", 0, -15)
    f.Title:SetText(TEXT_NEW_SET)
    
    f.NameLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.NameLabel:SetPoint("TOPLEFT", 25, -45)
    f.NameLabel:SetText(TEXT_ENTER_NAME or TEXT_NAME)

    f.CharCount = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.CharCount:SetPoint("LEFT", f.NameLabel, "RIGHT", 5, 0)
    f.CharCount:SetTextColor(0.5, 0.5, 0.5)
    f.CharCount:SetText("(0/30)")

    f.EditBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.EditBox:SetSize(340, 20)
    f.EditBox:SetPoint("TOP", 0, -65)
    f.EditBox:SetAutoFocus(true)
    f.EditBox:SetMaxLetters(30)
    f.EditBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText() or ""
        f.CharCount:SetText(string.format("(%d/30)", string.len(text)))
    end)
    
    f.IconLabel = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.IconLabel:SetPoint("TOPLEFT", 25, -95)
    f.IconLabel:SetText(TEXT_CHOOSE_ICON)
    
    f.ScrollBar = CreateFrame("Slider", nil, f, "UIPanelScrollBarTemplate")
    f.ScrollBar:SetPoint("TOPRIGHT", -25, -115)
    f.ScrollBar:SetPoint("BOTTOMRIGHT", -25, 50)
    f.ScrollBar:SetMinMaxValues(0, 100) 
    f.ScrollBar:SetValueStep(1)
    f.ScrollBar.scrollStep = 1
    f.ScrollBar:SetWidth(16)
    
    local mixin = self 
    f.ScrollBar:SetScript("OnValueChanged", function(bar, value)
        mixin:UpdateIconGrid() 
    end)

    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(_, delta)
        local current = f.ScrollBar:GetValue()
        local step = f.ScrollBar.scrollStep * 3 
        if delta > 0 then
            f.ScrollBar:SetValue(current - step)
        else
            f.ScrollBar:SetValue(current + step)
        end
    end)
    
    f.CancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.CancelBtn:SetSize(100, 24)
    f.CancelBtn:SetPoint("BOTTOMRIGHT", -20, 15)
    f.CancelBtn:SetText(TEXT_CANCEL)
    f.CancelBtn:SetScript("OnClick", function() f:Hide() end)
    
    f.OkBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.OkBtn:SetSize(100, 24)
    f.OkBtn:SetPoint("RIGHT", f.CancelBtn, "LEFT", -10, 0)
    f.OkBtn:SetText(TEXT_OK)
    f.OkBtn:SetScript("OnClick", function() 
        local name = f.EditBox:GetText()
        local icon = f.selectedIcon
        
        if name and name ~= "" and icon then
            if f.mode == "CREATE" then
                C_EquipmentSet.CreateEquipmentSet(name, icon)
            elseif f.mode == "EDIT" and f.setID then
                C_EquipmentSet.ModifyEquipmentSet(f.setID, name, icon)
            end
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
            f:Hide()
        end
    end)
    
    self.Dialog = f
    
    self.iconButtonsPool = {}
    local BUTTON_SIZE = 36
    local BUTTON_PADDING = 6
    local NUM_COLS = 8 
    local NUM_ROWS = 8 
    
    f.IconContainer = CreateFrame("Frame", nil, f)
    f.IconContainer:SetPoint("TOPLEFT", 25, -115)
    f.IconContainer:SetSize(NUM_COLS * (BUTTON_SIZE + BUTTON_PADDING), NUM_ROWS * (BUTTON_SIZE + BUTTON_PADDING))
    
    for i = 1, NUM_COLS * NUM_ROWS do
        local btn = CreateFrame("Button", nil, f.IconContainer, "BackdropTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        
        btn:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        btn:SetBackdropBorderColor(0, 0, 0, 1)

        btn.Icon = btn:CreateTexture(nil, "ARTWORK")
        btn.Icon:SetAllPoints()
        btn.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        btn.Selected = btn:CreateTexture(nil, "OVERLAY")
        btn.Selected:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        btn.Selected:SetBlendMode("ADD")
        btn.Selected:SetAllPoints()
        btn.Selected:Hide()

        btn.Hover = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.Hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        btn.Hover:SetBlendMode("ADD")
        btn.Hover:SetAllPoints()
        
        btn:SetScript("OnEnter", function(b) 
            b:SetBackdropBorderColor(1, 1, 1, 1) 
        end)
        btn:SetScript("OnLeave", function(b) 
            if b.iconID == self.Dialog.selectedIcon then
                b:SetBackdropBorderColor(1, 0.82, 0, 1)
            else
                b:SetBackdropBorderColor(0, 0, 0, 1)
            end
        end)
        
        btn:SetScript("OnClick", function(b)
            self.Dialog.selectedIcon = b.iconID
            self:UpdateIconGrid() 
        end)
        
        local col = (i - 1) % NUM_COLS
        local row = floor((i - 1) / NUM_COLS)
        btn:SetPoint("TOPLEFT", col * (BUTTON_SIZE + BUTTON_PADDING), -(row * (BUTTON_SIZE + BUTTON_PADDING)))
        
        self.iconButtonsPool[i] = btn
    end
end

function EquipmentMixin:OpenSetDialog(setID, currentName, currentIcon)
    self.Dialog:Show()
    
    local len = currentName and string.len(currentName) or 0
    self.Dialog.CharCount:SetText(string.format("(%d/30)", len))
    
    if setID then
        self.Dialog.mode = "EDIT"
        self.Dialog.setID = setID
        self.Dialog.Title:SetText(TEXT_EDIT)
        self.Dialog.EditBox:SetText(currentName or "")
        self.Dialog.selectedIcon = currentIcon
    else
        self.Dialog.mode = "CREATE"
        self.Dialog.setID = nil
        self.Dialog.Title:SetText(TEXT_NEW_SET)
        self.Dialog.EditBox:SetText("")
        self.Dialog.selectedIcon = 134400 
    end
    
    self.Dialog.ScrollBar:SetValue(0)
    self:UpdateIconGrid()
end

function EquipmentMixin:UpdateIconGrid()
    if not self.allIcons then return end 
    
    local totalIcons = #self.allIcons
    local numVisible = #self.iconButtonsPool
    local numCols = 8 
    
    local totalRows = ceil(totalIcons / numCols)
    local visibleRows = 8
    
    local maxScroll = max(0, totalRows - visibleRows)
    self.Dialog.ScrollBar:SetMinMaxValues(0, maxScroll)
    
    local scrollOffset = floor(self.Dialog.ScrollBar:GetValue())
    local startIndex = scrollOffset * numCols
    
    for i, btn in ipairs(self.iconButtonsPool) do
        local dataIndex = startIndex + i
        if dataIndex <= totalIcons then
            local iconTexture = self.allIcons[dataIndex]
            btn.Icon:SetTexture(iconTexture)
            btn.iconID = iconTexture
            
            if iconTexture == self.Dialog.selectedIcon then
                btn.Selected:Show()
                btn:SetBackdropBorderColor(1, 0.82, 0, 1)
            else
                btn.Selected:Hide()
                btn:SetBackdropBorderColor(0, 0, 0, 1)
            end
            
            btn:Show()
        else
            btn:Hide()
        end
    end
end

function EquipmentMixin:ShowContextMenu(anchor, setID, setName, setIcon)
    if not MenuUtil then return end 
    
    MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
        -- Sécurisation du titre (CreateTitle exige une string non-nil)
        local safeTitle = setName or ""
        rootDescription:CreateTitle(safeTitle)
        
        -- Sous-menu Spécialisation
        local specSub = rootDescription:CreateButton(TEXT_SPECIALIZATION, function() end)
        local numSpecs = GetNumSpecializations()
        
        for i = 1, numSpecs do
            local id, name, _, icon = GetSpecializationInfo(i)
            -- name peut être nil selon le linter, on force le type
            local safeSpecName = name or ""
            
            local function IsSelected()
                local current = C_EquipmentSet.GetEquipmentSetAssignedSpec(setID)
                return current == i
            end
            
            local function SetSelected()
                local current = C_EquipmentSet.GetEquipmentSetAssignedSpec(setID)
                if current == i then
                    C_EquipmentSet.UnassignEquipmentSetSpec(setID)
                else
                    C_EquipmentSet.AssignSpecToEquipmentSet(setID, i)
                end
                self:UpdateSets()
            end
            
            local btn = specSub:CreateCheckbox(safeSpecName, IsSelected, SetSelected)
            
            -- Initialiseur avec typage correct pour le bouton
            btn:AddInitializer(function(button, description, menu)
                ---@cast button EquipmentMenuButton
                
                -- Utilisation de l'API native MenuUtil pour ajouter une icône
                local texture = button:AttachTexture()
                texture:SetSize(16, 16)
                texture:SetPoint("RIGHT", -20, 0)
                texture:SetTexture(icon or 134400)
            end)
        end
        
        rootDescription:CreateDivider()
        
        rootDescription:CreateButton(TEXT_EDIT, function()
            self:OpenSetDialog(setID, setName, setIcon)
        end)

        rootDescription:CreateButton("|cffff0000" .. TEXT_DELETE .. "|r", function()
            -- Sécurisation du nom pour l'appel StaticPopup
            local safeName = setName or ""
            if safeName ~= "" then
                StaticPopup_Show("MYCHARACTERPANEL_CONFIRM_DELETE_SET", safeName, nil, setID)
            end
        end)
    end)
end