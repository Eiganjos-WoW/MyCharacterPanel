local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

local strfind, strmatch, strsub, strgsub = string.find, string.match, string.sub, string.gsub
local tonumber, tostring, pairs, ipairs = tonumber, tostring, pairs, ipairs
local strlen = string.len

local C_Item = C_Item
local C_TooltipInfo = C_TooltipInfo
local C_AddOns = C_AddOns
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemDurability = GetInventoryItemDurability
local GetInventoryItemCooldown = GetInventoryItemCooldown
local PickupInventoryItem = PickupInventoryItem
local HandleModifiedItemClick = HandleModifiedItemClick
local SocketInventoryItem = SocketInventoryItem
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local CursorHasItem = CursorHasItem
local SpellIsTargeting = SpellIsTargeting
local ItemLocation = ItemLocation
local GetInventoryItemLink = GetInventoryItemLink

addon.SlotMixin = {}
local SlotMixin = addon.SlotMixin

-- Fonction Globale pour gérer les clics via macro (contourne le SecureHandler)
_G["MyCharacterPanel_SlotClick"] = function(self, button)
    local slotID = self.slotID
    if not slotID then return end
    
    if button == "LeftButton" then
        if IsModifiedClick() then
            local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID)
            local itemLink = C_Item.GetItemLink(itemLocation)
            if itemLink then HandleModifiedItemClick(itemLink) end
        else 
            PickupInventoryItem(slotID) 
        end
    elseif button == "RightButton" then
        -- Le clic droit simple est géré par l'attribut "macro" (/use)
        -- Le Shift+Clic Droit arrive ici via la config shift-type2
        if IsShiftKeyDown() then
            if not C_AddOns.IsAddOnLoaded("Blizzard_ItemSocketingUI") then 
                C_AddOns.LoadAddOn("Blizzard_ItemSocketingUI") 
            end
            SocketInventoryItem(slotID)
        end
    end
end

function SlotMixin:OnLoad(slotID, defaultNameLabel, side)
    self.slotID = slotID
    self.defaultName = L[defaultNameLabel] or defaultNameLabel 
    self.side = side 
    self.isCosmetic = (slotID == 4 or slotID == 19) 
    self.isHighlighted = false 
    self.pendingItemID = nil 
    self.isScrolling = false 
    self.finishCycle = false 
    self.scrollHoldTime = 0 
    self.fullName = ""
    self.truncatedName = ""

    self:SetSize(210, 56)
    self:EnableMouse(true)
    
    if self:GetParent() then
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
    else
        self:SetFrameLevel(20) 
    end

    self:SetHitRectInsets(-2, -2, -7, -7)
    -- Initialisation par défaut pour le Drag & Drop (Mains libres)
    -- LeftUp pour Drag, RightUp/Down pour interaction complète
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp", "RightButtonDown")
    self:RegisterForDrag("LeftButton")
    
    -- Gestion manuelle du Drag & Drop pour contourner les limitations SecureButton proxy
    self:SetScript("OnMouseDown", function(f, button)
        -- Si on a un objet en main (Huile), le Drag est désactivé de toute façon par la logique dynamique
        if button == "LeftButton" then
            f.dragStartX, f.dragStartY = GetCursorPosition()
            f:SetScript("OnUpdate", function(self)
                local x, y = GetCursorPosition()
                if abs(x - (self.dragStartX or x)) > 5 or abs(y - (self.dragStartY or y)) > 5 then
                     self:SetScript("OnUpdate", nil)
                     -- Si on commence à glisser (hors combat), on désactive le Proxy Click temporairement
                     if not InCombatLockdown() then 
                        self.isDraggingSource = true -- BLOQUE la mise à jour des attributs pendant le drag pour éviter le blink
                        self:SetAttribute("type", nil) 
                        PickupInventoryItem(self.slotID)
                     end
                end
            end)
        end
    end)
    
    self:SetScript("OnMouseUp", function(f) 
        f:SetScript("OnUpdate", nil)
        f.isDraggingSource = nil -- Libère la protection
        if not InCombatLockdown() then f:SetAttribute("type", "click") end
    end)
    
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:RegisterEvent("CURSOR_CHANGED") -- Important pour détecter la prise d'huile en main

    -- Adapte la réactivité du bouton selon qu'on a un item en main (Huile) ou non (Drag possible)
    self.UpdateClickRegistration = function(f)
        if f.isDraggingSource then return end -- PROTECTION ANTI-BLINK
        
        if CursorHasItem() or SpellIsTargeting() then
            -- Huile en main : On écoute tout (Lua + Secure) pour être sûr que l'interaction passe
            f:RegisterForClicks("AnyUp", "AnyDown")
            if not InCombatLockdown() then f:SetAttribute("registerForClicks", "AnyUp, AnyDown") end
        else
            -- Mains libres : 
            -- LeftButton : Seulement UP (libère le Down pour le Drag & Drop)
            -- RightButton : UP et DOWN (Comportement standard pour Bijoux/Sertissage)
            local types = "LeftButtonUp, RightButtonUp, RightButtonDown"
            f:RegisterForClicks("LeftButtonUp", "RightButtonUp", "RightButtonDown")
            if not InCombatLockdown() then f:SetAttribute("registerForClicks", types) end
        end
    end 
    
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", function(f)
        f:SetScript("OnUpdate", nil)
        f.isDraggingSource = nil
        if not InCombatLockdown() then f:SetAttribute("type", "click") end
        self.OnLeave(f)
    end) 

    -- CONFIGURATION PROXY BLIZZARD --

    -- On délègue TOUS les clics aux boutons officiels de Blizzard via le type "click".
    -- Cela garantit que toutes les actions (Huiles, Bijoux, Links, Sertissage) fonctionnent nativement sans erreur "Blocked".
    
    local slotNameMap = {
        [1] = "CharacterHeadSlot", [2] = "CharacterNeckSlot", [3] = "CharacterShoulderSlot",
        [4] = "CharacterShirtSlot", [5] = "CharacterChestSlot", [6] = "CharacterWaistSlot",
        [7] = "CharacterLegsSlot", [8] = "CharacterFeetSlot", [9] = "CharacterWristSlot",
        [10] = "CharacterHandsSlot", [11] = "CharacterFinger0Slot", [12] = "CharacterFinger1Slot",
        [13] = "CharacterTrinket0Slot", [14] = "CharacterTrinket1Slot", [15] = "CharacterBackSlot",
        [16] = "CharacterMainHandSlot", [17] = "CharacterSecondaryHandSlot", [19] = "CharacterTabardSlot",
    }
    
    local targetFrameName = slotNameMap[slotID]
    local targetFrame = targetFrameName and _G[targetFrameName]
    
    if targetFrame then
        -- Redirection complète du clic vers le bouton Blizzard
        self:SetAttribute("type", "click")
        self:SetAttribute("clickbutton", targetFrame)
    else
        -- Fallback de sécurité (ne devrait pas arriver sur une installation standard)
        self:SetAttribute("type2", "macro")
        self:SetAttribute("macrotext2", "/use "..slotID)
    end

    self:SetBackdrop(nil)

    self.InfoBar = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    self.InfoBar:SetAtlas("128-RedButton-Disable") 
    self.InfoBar:SetHeight(40) 
    self.InfoBar:SetWidth(185) 
    self.InfoBar:SetDesaturated(true) 
    self.InfoBar:SetVertexColor(0.9, 0.9, 0.9, 1)

    self.BarHighlight = self:CreateTexture(nil, "BACKGROUND", nil, 1)
    self.BarHighlight:SetAtlas("128-RedButton-Highlight") 
    self.BarHighlight:SetBlendMode("ADD")
    self.BarHighlight:SetAllPoints(self.InfoBar)
    self.BarHighlight:SetDesaturated(true) 
    self.BarHighlight:SetVertexColor(1, 1, 1, 1) 
    self.BarHighlight:SetAlpha(0.50) 
    self.BarHighlight:Hide()
    
    -- ... Suite de l'initialisation visuelle ...

    local iconSize = 42 

    self.IconBg = self:CreateTexture(nil, "BACKGROUND", nil, 1) 
    self.IconBg:SetSize(iconSize + 2, iconSize + 2) 
    self.IconBg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    self.IconBg:SetVertexColor(0, 0, 0, 1) 

    self.QualityCircle = self:CreateTexture(nil, "BACKGROUND", nil, 2)
    self.QualityCircle:SetSize(iconSize, iconSize)
    self.QualityCircle:SetPoint("CENTER", self.IconBg, "CENTER", 0, 0)
    self.QualityCircle:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    self.QualityCircle:SetVertexColor(0.2, 0.2, 0.2, 1) 

    self.Icon = self:CreateTexture(nil, "ARTWORK")
    self.Icon:SetSize(iconSize - 4, iconSize - 4) 
    self.Icon:SetPoint("CENTER", self.QualityCircle, "CENTER", 0, 0)
    self.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    self.IconMask = self:CreateMaskTexture()
    self.IconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    self.IconMask:SetAllPoints(self.Icon)
    self.Icon:AddMaskTexture(self.IconMask)

    self.Glow = self:CreateTexture(nil, "OVERLAY", nil, 2)
    self.Glow:SetSize(iconSize + 16, iconSize + 16)
    self.Glow:SetAtlas("loottab-highlight") 
    self.Glow:SetBlendMode("ADD")
    self.Glow:SetPoint("CENTER", self.Icon, "CENTER", 0, 0)
    self.Glow:Hide()

    self.ItemLevel = self:CreateFontString(nil, "OVERLAY")
    self.ItemLevel:SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE")
    self.ItemLevel:SetPoint("CENTER", self.Icon, "CENTER", 0, 0) 
    self.ItemLevel:SetTextColor(1, 1, 1) 
    self.ItemLevel:SetShadowOffset(1, -1)
    
    self.Cooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
    self.Cooldown:SetAllPoints(self.Icon)
    self.Cooldown:SetDrawEdge(false)
    self.Cooldown:EnableMouse(false)
    self.Cooldown:SetSwipeTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", 0, 0, 0, 0.8) 

    self.RankIcon = self:CreateTexture(nil, "OVERLAY")
    self.RankIcon:SetSize(14, 14) 
    self.RankIcon:Hide()

    self.NameContainer = CreateFrame("ScrollFrame", nil, self)
    self.NameContainer:SetSize(190, 15) 
    
    self.NameScrollChild = CreateFrame("Frame", nil, self.NameContainer)
    self.NameScrollChild:SetSize(190, 15)
    self.NameContainer:SetScrollChild(self.NameScrollChild)

    self.Name = self.NameScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.Name:SetPoint("LEFT", self.NameScrollChild, "LEFT", 0, 0)
    self.Name:SetWordWrap(false) 
    
    self.UpgradeText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.UpgradeText:SetTextColor(0, 1, 1) 
    
    self.Enchant = self:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny") 
    self.Enchant:SetTextColor(0.4, 1, 0.4)
    self.Enchant:SetWordWrap(false)
    self.Enchant:SetWidth(160) 

    self.SetLabelBg = self:CreateTexture(nil, "OVERLAY")
    self.SetLabelBg:SetSize(36, 12)
    self.SetLabelBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    self.SetLabelBg:SetVertexColor(0, 0, 0, 0.6) 
    self.SetLabelBg:Hide()
    
    local setMask = self:CreateMaskTexture()
    setMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    setMask:SetPoint("CENTER", self.Icon, "CENTER", 0, 0)
    setMask:SetSize(40, 40)
    self.SetLabelBg:AddMaskTexture(setMask)

    self.SetLabel = self:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
    self.SetLabel:SetTextColor(1, 0.82, 0) 
    self.SetLabel:SetShadowOffset(1, -1)
    self.SetLabel:Hide()
    
    self.SetLabelBg:SetPoint("BOTTOM", self.Icon, "BOTTOM", 0, -4)
    self.SetLabel:SetPoint("CENTER", self.SetLabelBg, "CENTER", 0, 0.5)

    self.GemFrames = {}
    for i = 1, 3 do
        local f = CreateFrame("Frame", nil, self)
        f:SetSize(20, 20) 
        f:Hide()
        
        f.Bg = f:CreateTexture(nil, "BACKGROUND")
        f.Bg:SetAllPoints()
        f.Bg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        f.Bg:SetVertexColor(0, 0, 0, 1) 

        f.Texture = f:CreateTexture(nil, "ARTWORK")
        f.Texture:SetSize(16, 16) 
        f.Texture:SetPoint("CENTER", f.Bg, "CENTER", 0, 0)
        f.Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        f.EmptyHighlight = f:CreateTexture(nil, "OVERLAY")
        f.EmptyHighlight:SetSize(22, 22) 
        f.EmptyHighlight:SetPoint("CENTER")
        f.EmptyHighlight:SetAtlas("loottab-highlight")
        f.EmptyHighlight:SetBlendMode("ADD")
        f.EmptyHighlight:SetAlpha(1.0)
        f.EmptyHighlight:Hide()

        f.Mask = f:CreateMaskTexture()
        f.Mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        f.Mask:SetAllPoints(f.Texture)
        f.Texture:AddMaskTexture(f.Mask)

        f:SetScript("OnEnter", function(gemFrame)
            local tt = addon.Tooltip
            tt:SetOwner(gemFrame, "ANCHOR_RIGHT")
            if gemFrame.gemLink then
                tt:SetHyperlink(gemFrame.gemLink)
            else
                tt:SetText(EMPTY_SOCKET_PRISMATIC, 1, 0.8, 0)
                tt:AddLine(L["SOCKET_TOOLTIP"], 0.7, 0.7, 0.7)
            end
            tt:Show()
        end)
        f:SetScript("OnLeave", function(gemFrame) addon.Tooltip:Hide() end)
        self.GemFrames[i] = f
    end

    if side == "RIGHT" or slotID == 17 then
        self.IconBg:SetPoint("RIGHT", 3, -5) 
        self.InfoBar:SetPoint("RIGHT", self.IconBg, "CENTER", 10, 0) 
        self.InfoBar:SetTexCoord(1, 0, 0, 1) 
        self.InfoBar:Show()

        if self.isCosmetic then
            self.NameContainer:SetPoint("RIGHT", self.IconBg, "LEFT", -5, 0)
            self.Name:SetJustifyH("RIGHT")
            self.Name:SetPoint("RIGHT", self.NameScrollChild, "RIGHT", 0, 0) 
            self.Name:SetJustifyV("MIDDLE")
        else
            self.NameContainer:SetPoint("BOTTOMRIGHT", self.IconBg, "TOPRIGHT", 0, 1)
            self.Name:SetJustifyH("RIGHT")
            self.Name:SetPoint("RIGHT", self.NameScrollChild, "RIGHT", 0, 0)
            self.Name:SetJustifyV("BOTTOM")
        end
    else
        self.IconBg:SetPoint("LEFT", 3, -5) 
        self.InfoBar:SetPoint("LEFT", self.IconBg, "CENTER", -10, 0)
        self.InfoBar:SetTexCoord(0, 1, 0, 1)
        self.InfoBar:Show()

        if self.isCosmetic then
            self.NameContainer:SetPoint("LEFT", self.IconBg, "RIGHT", 5, 0)
            self.Name:SetJustifyH("LEFT")
            self.Name:SetPoint("LEFT", self.NameScrollChild, "LEFT", 0, 0)
            self.Name:SetJustifyV("MIDDLE")
        else
            self.NameContainer:SetPoint("BOTTOMLEFT", self.IconBg, "TOPLEFT", 0, 1)
            self.Name:SetJustifyH("LEFT")
            self.Name:SetPoint("LEFT", self.NameScrollChild, "LEFT", 0, 0)
            self.Name:SetJustifyV("BOTTOM")
        end
    end


    self:SetScript("OnEvent", self.OnEvent) 
    -- OnDragStart est géré manuellement via OnMouseDown/Update car le bouton est Secure
    self:SetScript("OnReceiveDrag", function() PickupInventoryItem(self.slotID) end)
    -- OnClick est maintenant géré uniquement par les attributs sécurisés
end

function SlotMixin:SetHighlight(enabled)
    self.isHighlighted = enabled 
    if enabled then
        self:SetAlpha(1.0) 
        self:ApplyHighlightVisuals()
    else
        self.Glow:Hide()
        self:UpdateInfo() 
    end
end

function SlotMixin:SetDimmed(enabled)
    if enabled then
        self:SetAlpha(0.25) 
        self.isHighlighted = false
        self.Glow:Hide()
    else
        self:SetAlpha(1.0) 
    end
end



function SlotMixin:OnEvent(event, arg1)
    if event == "CURSOR_CHANGED" then
        if self.UpdateClickRegistration then self:UpdateClickRegistration() end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        local slot = arg1
        if slot == self.slotID then
            self:UpdateInfo()
        end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local receivedItemID = arg1
        if receivedItemID then
            local itemLocation = ItemLocation:CreateFromEquipmentSlot(self.slotID)
            if C_Item.DoesItemExist(itemLocation) then
                local currentItemID = C_Item.GetItemID(itemLocation)
                if currentItemID and currentItemID == receivedItemID then
                    self:UpdateInfo()
                end
            end
        end
    end
end

function SlotMixin:ApplyFonts()
    local db = MyCharacterPanelDB or {}
    local fonts = db.fonts or {}

    if fonts.itemName and self.Name then 
        self.Name:SetFont(fonts.itemName, 12, "") 
    end
    if fonts.itemLevel and self.ItemLevel then 
        self.ItemLevel:SetFont(fonts.itemLevel, 18, "THICKOUTLINE") 
    end
    if fonts.enchant and self.Enchant then 
        self.Enchant:SetFont(fonts.enchant, 10, "") 
    end
    if fonts.upgrade and self.UpgradeText then 
        self.UpgradeText:SetFont(fonts.upgrade, 10, "") 
    end
    if fonts.setBonus and self.SetLabel then
        self.SetLabel:SetFont(fonts.setBonus, 10, "")
    end
end

function SlotMixin:UpdateInfo()
    self:ApplyFonts()

    local itemLocation = ItemLocation:CreateFromEquipmentSlot(self.slotID)
    
    local db = MyCharacterPanelDB or {}
    -- Lecture Per-Character
    local guid = UnitGUID("player")
    local charDb = (db.char and db.char[guid]) or {}
    
    local showNames = (db.showItemNames == nil) and true or db.showItemNames
    local showUpgrade = (db.showUpgradeLevels == nil) and true or db.showUpgradeLevels
    local showEnchants = (db.showEnchants == nil) and true or db.showEnchants
    local showSet = (db.showSetInfo == nil) and true or db.showSetInfo
    local showILvl = (db.showItemLevel == nil) and true or db.showItemLevel
    
    -- Fallback sur la DB globale si la charDb n'est pas encore init
    local enchantCheck = charDb.enchantCheckSlots or db.enchantCheckSlots or {}

    for _, f in ipairs(self.GemFrames) do 
        f:Hide() 
        f.EmptyHighlight:Hide()
        f.Bg:SetVertexColor(0, 0, 0, 1) 
    end
    self.SetLabel:Hide()
    self.SetLabelBg:Hide()
    self.RankIcon:Hide()
    self.Icon:SetDesaturated(false)
    self.Enchant:SetText("")
    self.Icon:SetVertexColor(1, 1, 1)
    self.ItemLevel:SetText("")
    self.UpgradeText:SetText("")
    
    self.IconBg:SetVertexColor(0, 0, 0, 1)
    self.QualityCircle:SetVertexColor(0.2, 0.2, 0.2, 1)
    self.Icon:SetAlpha(1)
    self.Glow:Hide()
    self.InfoBar:SetVertexColor(0.9, 0.9, 0.9, 1)

    self.NameContainer:SetHorizontalScroll(0)
    self.NameContainer:SetScript("OnUpdate", nil)
    self.isScrolling = false
    self.finishCycle = false
    
    local containerWidth = self.NameContainer:GetWidth()
    self.Name:SetWidth(containerWidth)
    self.NameScrollChild:SetWidth(containerWidth)

    if not C_Item.DoesItemExist(itemLocation) then
        self.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up") 
        self.Icon:SetDesaturated(true)
        self.Icon:SetAlpha(0.5)
        self.fullName = ""
        self.truncatedName = ""
        if showNames then self.Name:SetText(self.defaultName) else self.Name:SetText("") end
        self.Name:SetTextColor(0.5, 0.5, 0.5)
        self.Cooldown:Hide()
        self.InfoBar:SetVertexColor(0.3, 0.3, 0.3, 0.5)
        if self.isHighlighted then self:ApplyHighlightVisuals() end
        return
    end

    local itemLink = C_Item.GetItemLink(itemLocation)
    -- Tentative récupération synchrone
    local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemLink or "")
    
    if itemTexture then self.Icon:SetTexture(itemTexture)
    else self.Icon:SetTexture(GetInventoryItemTexture("player", self.slotID)) end

    self.Icon:SetVertexColor(0.60, 0.60, 0.60)

    if itemName then
        self.fullName = itemName
        
        if self.isCosmetic and strlen(itemName) > 20 then
             self.truncatedName = strsub(itemName, 1, 20) .. ".."
        else
             self.truncatedName = itemName
        end

        local displayText = self.isCosmetic and self.truncatedName or self.fullName
        if showNames then 
            if self.isCosmetic then self.Name:SetWidth(0) else self.Name:SetWidth(containerWidth) end
            self.Name:SetText(displayText) 
        else 
            self.Name:SetText("") 
        end
        
        local r, g, b = C_Item.GetItemQualityColor(itemRarity or 1)
        self.Name:SetTextColor(r, g, b)
        self.QualityCircle:SetVertexColor(r, g, b, 1) 
        
        if not self.isCosmetic then
            if showILvl then
                local currentILvl = C_Item.GetCurrentItemLevel(itemLocation)
                if currentILvl then
                    self.ItemLevel:SetText(tostring(currentILvl))
                    self.ItemLevel:SetTextColor(1, 1, 1)
                    self.ItemLevel:Show()
                end
            else
                self.ItemLevel:Hide()
            end
        end
    else
        -- Important : Requête serveur si le nom est manquant
        self.Name:SetText(L["LOADING"] or "...")
        self.Name:SetTextColor(0.5, 0.5, 0.5)
        
        local itemID = C_Item.GetItemInfoInstant(itemLink or "")
        if itemID then
            C_Item.RequestLoadItemDataByID(itemID)
        end
    end


    if not self.isCosmetic then
        local tooltipData = C_TooltipInfo.GetInventoryItem("player", self.slotID)
        local enchantText = ""
        local foundEnchant = false
        local upgradeString = ""
        local rankAtlas = nil 

        if itemLink then
            local enchantID = tonumber(string.match(itemLink, "item:%d+:(%d+):"))
            if enchantID and enchantID > 0 then 
                foundEnchant = true 
            end
        end

        if tooltipData and tooltipData.lines then
            for i, line in ipairs(tooltipData.lines) do
                local text = line.leftText
                local rawLineData = ""
                
                if text then rawLineData = rawLineData .. text end
                local lineArgs = line["args"]
                if lineArgs then
                    for _, arg in ipairs(lineArgs) do
                        if arg.stringVal then rawLineData = rawLineData .. arg.stringVal end
                        if arg.atlasName then rawLineData = rawLineData .. arg.atlasName end
                    end
                end

                if strfind(rawLineData, L["PATTERN_TIER1"]) then rankAtlas = "Professions-Icon-Quality-Tier1-Small"
                elseif strfind(rawLineData, L["PATTERN_TIER2"]) then rankAtlas = "Professions-Icon-Quality-Tier2-Small"
                elseif strfind(rawLineData, L["PATTERN_TIER3"]) then rankAtlas = "Professions-Icon-Quality-Tier3-Small"
                end

                if text and type(text) == "string" then
                    local cleanRaw = gsub(text, "|c%x%x%x%x%x%x%x%x", "")
                    cleanRaw = gsub(cleanRaw, "|r", "")
                    
                    if strmatch(cleanRaw, "%d+/%d+") then
                        if not strmatch(cleanRaw, "%(%d+/%d+%)") then
                             local cleaned = Utils.CleanString(text)
                             local matchTrack, matchNum = strmatch(cleaned, "^(.-)%s*(%d+/%d+)$")
                             if not matchTrack then
                                matchNum = strmatch(cleaned, "(%d+/%d+)")
                                matchTrack = ""
                             end

                             if matchNum then
                                if matchTrack and matchTrack ~= "" and matchTrack ~= " " then
                                     upgradeString = "[" .. matchTrack .. " " .. matchNum .. "]"
                                else
                                     upgradeString = "[" .. matchNum .. "]"
                                end
                             end
                        elseif showSet then
                             self.SetLabel:SetText(strmatch(cleanRaw, "%(%d+/%d+%)"))
                             self.SetLabel:Show(); self.SetLabelBg:Show() 
                        else
                             self.SetLabel:Hide()
                             self.SetLabelBg:Hide()
                        end
                    end

                    if foundEnchant and enchantText == "" then
                        if (strfind(cleanRaw, L["PATTERN_ENCHANT_FIND"]) or strfind(cleanRaw, L["PATTERN_RENFORT_FIND"])) 
                           and not strfind(cleanRaw, L["PATTERN_USE"]) 
                           and not strfind(cleanRaw, L["PATTERN_ILLUSION"]) then
                              enchantText = Utils.CleanString(text)
                        end
                    end
                end
            end
        end

        self.UpgradeText:ClearAllPoints(); self.Enchant:ClearAllPoints()
        local textOffset = 48 
        local isRight = (self.side == "RIGHT" or self.slotID == 17)
        local anchorPoint = isRight and "RIGHT" or "LEFT"
        local xOffset = isRight and -textOffset or textOffset
        local justify = isRight and "RIGHT" or "LEFT"

        self.UpgradeText:SetJustifyH(justify); self.Enchant:SetJustifyH(justify)
        
        if showUpgrade and upgradeString ~= "" then
            self.UpgradeText:SetText(upgradeString)
            self.UpgradeText:SetTextColor(0, 1, 1) -- Turquoise
        else
            self.UpgradeText:SetText("")
        end
        local hasUpgrade = (upgradeString ~= "")

        local hasEnchantMsg = false
        
        if not foundEnchant then
            if enchantCheck[self.slotID] then
                 self.Enchant:SetText(L["NOT_ENCHANTED"])
                 self.Enchant:SetTextColor(1, 0.2, 0.2) -- Rouge
                 self.RankIcon:Hide()
                 hasEnchantMsg = true 
            else
                 self.Enchant:SetText("")
                 self.RankIcon:Hide()
                 hasEnchantMsg = false
            end
        
        elseif showEnchants then
            if enchantText ~= "" then
                self.Enchant:SetText(enchantText)
                self.Enchant:SetTextColor(0.4, 1, 0.4) -- Vert
                if rankAtlas then
                    self.RankIcon:SetAtlas(rankAtlas)
                    self.RankIcon:Show()
                else
                    self.RankIcon:Hide()
                end
                hasEnchantMsg = true
            else
                self.Enchant:SetText("")
                self.RankIcon:Hide()
                hasEnchantMsg = false 
            end
        else
            self.Enchant:SetText("")
            self.RankIcon:Hide()
            hasEnchantMsg = false
        end

        if hasUpgrade and hasEnchantMsg then
            self.UpgradeText:SetPoint(anchorPoint, self.IconBg, anchorPoint, xOffset, 5)
            self.Enchant:SetPoint("TOP"..anchorPoint, self.UpgradeText, "BOTTOM"..anchorPoint, 0, -2)
        elseif hasUpgrade then
            self.UpgradeText:SetPoint(anchorPoint, self.IconBg, anchorPoint, xOffset, 0)
        elseif hasEnchantMsg then
            self.Enchant:ClearAllPoints()
            self.Enchant:SetPoint(anchorPoint, self.IconBg, anchorPoint, xOffset, 0)
        end

        if self.RankIcon:IsShown() and showEnchants then
            self.RankIcon:ClearAllPoints()
            local iconTextW = self.Enchant:GetStringWidth() + 2
            if isRight then
                self.RankIcon:SetPoint("RIGHT", self.Enchant, "RIGHT", -iconTextW, 0)
            else
                self.RankIcon:SetPoint("LEFT", self.Enchant, "LEFT", iconTextW, 0)
            end
        end

    else
        self.UpgradeText:SetText("")
        self.Enchant:SetText("")
        self.RankIcon:Hide()
        self.SetLabel:Hide()
        self.SetLabelBg:Hide()
    end

    if itemLink and not self.isCosmetic then
        local stats = C_Item.GetItemStats(itemLink or "") or {}
        local numSockets = 0
        for key, value in pairs(stats) do
            if strfind(key, "EMPTY_SOCKET_") then
                numSockets = numSockets + value
            end
        end
        for i = 1, 3 do
            local _, gemLink = C_Item.GetItemGem(itemLink or "", i)
            if gemLink then if i > numSockets then numSockets = i end end
        end

        if numSockets > 0 then
            local gemSize = 18
            local spacing = 2 
            local distance = 30 
            
            local totalHeight = (numSockets * gemSize) + ((numSockets - 1) * spacing)
            local startY = (totalHeight / 2) - (gemSize / 2)

            for i = 1, numSockets do
                local gemFrame = self.GemFrames[i]
                if gemFrame then
                    gemFrame:Show()
                    gemFrame:ClearAllPoints()
                    
                    local yOffset = startY - ((i-1) * (gemSize + spacing))
                    
                    if self.side == "RIGHT" or self.slotID == 17 then
                        gemFrame:SetPoint("CENTER", self.IconBg, "CENTER", distance, yOffset) 
                    else
                        gemFrame:SetPoint("CENTER", self.IconBg, "CENTER", -distance, yOffset) 
                    end

                    local _, gemLink = C_Item.GetItemGem(itemLink or "", i)
                    if gemLink then
                        local _, _, _, _, icon = C_Item.GetItemInfoInstant(gemLink)
                        gemFrame.Texture:SetTexture(icon)
                        gemFrame.gemLink = gemLink
                        gemFrame.Bg:SetVertexColor(0, 0, 0, 1) 
                        gemFrame.EmptyHighlight:Hide()
                    else
                        gemFrame.Texture:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
                        gemFrame.gemLink = nil
                        gemFrame.Bg:SetVertexColor(0.8, 0.8, 0.8, 1) 
                        gemFrame.EmptyHighlight:Show()
                    end
                end
            end
        end
    end

    local currentDura, maxDura = GetInventoryItemDurability(self.slotID)
    if currentDura and maxDura and maxDura > 0 and currentDura == 0 then
        self.Icon:SetVertexColor(1, 0, 0)
    end
    self:UpdateCooldown()

    if self.isHighlighted then
        self:ApplyHighlightVisuals()
    end
end

function SlotMixin:ApplyHighlightVisuals()
    self.Icon:SetAlpha(1) 
    self.Glow:Show()
    self.Glow:SetVertexColor(1, 1, 1, 1) 
    self.IconBg:SetVertexColor(1, 1, 1, 1) 
    self.QualityCircle:SetVertexColor(1, 1, 1, 0.5) 
    self.InfoBar:SetVertexColor(0.9, 0.9, 0.9, 1) 
end

function SlotMixin:UpdateCooldown()
    local start, duration, enable = GetInventoryItemCooldown("player", self.slotID)
    if start and duration and enable and duration > 0 then
        self.Cooldown:SetCooldown(start, duration)
        self.Cooldown:Show()
    else
        self.Cooldown:Hide()
    end
end

function SlotMixin:OnEnter()
    self:SetScript("OnUpdate", nil)
    if self.UpdateClickRegistration then self:UpdateClickRegistration() end
    if CursorHasItem() then return end
    
    self.BarHighlight:Show() 
    self.finishCycle = false 
    
    local db = MyCharacterPanelDB or {}
    local canScroll = (db.scrollItemNames == nil) and true or db.scrollItemNames

    if canScroll then
        local itemLocation = ItemLocation:CreateFromEquipmentSlot(self.slotID)
        local hasItem = C_Item.DoesItemExist(itemLocation)

        if not hasItem then
            self.Name:SetWidth(self.NameContainer:GetWidth())
            if db.showItemNames ~= false then
                self.Name:SetText(self.defaultName)
            end
        else
            self.Name:SetWidth(0) 
            local textWidth = self.Name:GetStringWidth()
            local containerWidth = self.NameContainer:GetWidth()
    
            if textWidth > containerWidth then
                self.Name:SetText(self.fullName) 
                self.Name:SetWidth(textWidth + 25) 
                self.NameScrollChild:SetWidth(textWidth + 25)
    
                local scrollPos = 0
                local maxScroll = textWidth - containerWidth + 30 
                local speed = 40 
                local wait = 0 
                local holdTime = 1.0 
    
                self.NameContainer:SetHorizontalScroll(0)
                self.isScrolling = true
                self.scrollHoldTime = 0
                
                self.NameContainer:SetScript("OnUpdate", function(f, elapsed)
                    if MyCharacterPanelDB and MyCharacterPanelDB.scrollItemNames == false then
                          f:SetHorizontalScroll(0)
                          f:SetScript("OnUpdate", nil)
                          return
                    end
    
                    if wait > 0 then
                        wait = wait - elapsed
                        return
                    end
                    
                    if self.scrollHoldTime > 0 then
                        self.scrollHoldTime = self.scrollHoldTime - elapsed
                        if self.scrollHoldTime <= 0 then
                            if self.finishCycle then
                                f:SetScript("OnUpdate", nil)
                                f:SetHorizontalScroll(0)
                                
                                if self.Name then 
                                    if self.isCosmetic then
                                        self.Name:SetWidth(0)
                                        self.Name:SetText(self.truncatedName)
                                    else
                                        self.Name:SetWidth(containerWidth)
                                        self.Name:SetText(self.fullName)
                                    end
                                end
                                self.finishCycle = false
                                self.isScrolling = false
                                return
                            end
                            
                            scrollPos = 0
                            wait = 1.0 
                            f:SetHorizontalScroll(0)
                        end
                        return
                    end
                    
                    scrollPos = scrollPos + (speed * elapsed)
                    
                    if scrollPos > maxScroll then
                        scrollPos = maxScroll
                        f:SetHorizontalScroll(scrollPos)
                        self.scrollHoldTime = holdTime 
                    else
                        f:SetHorizontalScroll(scrollPos)
                    end
                end)
            else
                self.Name:SetWidth(containerWidth)
            end
        end
    end

    local tt = addon.Tooltip
    tt:SetOwner(self:GetParent(), "ANCHOR_NONE")
    
    tt:ClearAllPoints()
    if self.side == "LEFT" then
        tt:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
    else
        tt:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
    end
    
    tt:SetMinimumWidth(260)
    tt:SetInventoryItem("player", self.slotID)
    
    if not IsShiftKeyDown() then
        if ShoppingTooltip1 then ShoppingTooltip1:Hide() end
        if ShoppingTooltip2 then ShoppingTooltip2:Hide() end
    end
    
    tt:Show()
    
    local mainFrame = self:GetParent()
    if mainFrame and mainFrame.ShowItemPreview then mainFrame:ShowItemPreview(self.slotID) end
end

function SlotMixin:OnLeave()
    self:SetScript("OnUpdate", nil)
    local tt = addon.Tooltip
    tt:Hide()
    tt:SetMinimumWidth(0)

    self.BarHighlight:Hide()

    self.NameContainer:SetScript("OnUpdate", nil)
    self.NameContainer:SetHorizontalScroll(0)
    
    self.isScrolling = false
    self.finishCycle = false

    if self.Name and self.NameContainer and self.NameScrollChild then
        local containerWidth = self.NameContainer:GetWidth()
        self.NameScrollChild:SetWidth(containerWidth)
        
        local db = MyCharacterPanelDB or {}
        local showNames = (db.showItemNames == nil) and true or db.showItemNames

        if self.isCosmetic then
            self.Name:SetWidth(0)
            if self.fullName and self.fullName ~= "" then
                 self.Name:SetText(self.truncatedName)
            elseif showNames then
                 self.Name:SetText(self.defaultName)
            else
                 self.Name:SetText("")
            end
        else
            self.Name:SetWidth(containerWidth)
            if self.fullName and self.fullName ~= "" then
                 self.Name:SetText(self.fullName)
            elseif showNames then
                 self.Name:SetText(self.defaultName)
            else
                 self.Name:SetText("")
            end
        end
    end

    local mainFrame = self:GetParent()
    if mainFrame and mainFrame.HideItemPreview then mainFrame:HideItemPreview() end
end