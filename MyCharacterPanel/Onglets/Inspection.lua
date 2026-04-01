local addonName, addon = ...
addon.Inspection = {}

addon.Config = addon.Config

local C = addon.CONST

local isInspectSkinned = false

-- Découpe une chaine de caractères en caractères UTF-8
local function getUtf8Chars(str)
    local chars = {}
    local pos = 1
    while pos <= #str do
        local b = string.byte(str, pos)
        local n = 1
        if b >= 240 then
            n = 4
        elseif b >= 224 then
            n = 3
        elseif b >= 192 then
            n = 2
        end
        table.insert(chars, string.sub(str, pos, pos + n - 1))
        pos = pos + n
    end
    return chars
end

-- Récupère un morceau de texte découpé
local function getSlicedText(chars, startIdx, count)
    local res = ""
    local len = #chars
    if len == 0 then return "" end
    for i = 0, count - 1 do
        local idx = startIdx + i
        if idx <= len then
            res = res .. chars[idx]
        end
    end
    return res
end

-- Dessine un octogone autour de la case d'objet
local function CreateOctagonBorder(slot, radius, thickness)
    if slot.MCP_OctagonLines then return end
    slot.MCP_OctagonLines = {}

    local color = { 0.3, 0.3, 0.3 }

    local sideLength = 2 * radius * 0.414

    for i = 0, 7 do
        local angleDeg = i * 45
        local angleRad = math.rad(angleDeg)

        local line = slot:CreateTexture(nil, "OVERLAY")
        line:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        line:SetSize(sideLength + (thickness * 0.45), thickness)

        local cx = radius * math.cos(angleRad)
        local cy = radius * math.sin(angleRad)

        line:SetPoint("CENTER", slot.icon, "CENTER", cx, cy)
        line:SetRotation(angleRad + math.pi / 2)
        line:SetVertexColor(unpack(color))
        table.insert(slot.MCP_OctagonLines, line)
    end
end

-- Coupe l'icône de l'objet en forme d'octogone
local function CreateOctagonMask(slot)
    if slot.MCP_OctagonMasks then return end

    local m1 = slot:CreateMaskTexture()
    m1:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m1:SetSize(36, 36)
    m1:SetPoint("CENTER", slot.icon, "CENTER")
    slot.icon:AddMaskTexture(m1)

    local m2 = slot:CreateMaskTexture()
    m2:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m2:SetSize(36, 36)
    m2:SetPoint("CENTER", slot.icon, "CENTER")
    m2:SetRotation(math.rad(45))
    slot.icon:AddMaskTexture(m2)

    if slot.MCP_Background then
        slot.MCP_Background:AddMaskTexture(m1)
        slot.MCP_Background:AddMaskTexture(m2)
    end

    slot.MCP_OctagonMasks = { m1, m2 }
end

-- Prépare le look des cases d'équipement
local function CreateInspectSlotVisuals(slot)
    if slot.MCP_VisualsCreated then return end

    local slotName = slot:GetName()
    local isRight = false

    local rightNames = { "InspectHandsSlot", "InspectWaistSlot", "InspectLegsSlot", "InspectFeetSlot",
        "InspectFinger0Slot", "InspectFinger1Slot", "InspectTrinket0Slot", "InspectTrinket1Slot",
        "InspectSecondaryHandSlot" }
    for _, s in ipairs(rightNames) do
        if s == slotName then
            isRight = true
            break
        end
    end

    if slot.IconBorder then
        slot.IconBorder:SetTexture("")
        slot.IconBorder:Hide() -- On cache les bordures de base
    end
    slot:SetNormalTexture("")
    if slot.IconOverlay then slot.IconOverlay:Hide() end

    local sideFrame = _G[slotName .. "Frame"]
    if sideFrame then
        sideFrame:Hide()
        sideFrame:SetAlpha(0)
    end

    if slot.IconOverlay2 then slot.IconOverlay2:Hide() end
    if slot.AzeriteTexture then slot.AzeriteTexture:Hide() end

    if slot.icon then
        local bg = slot:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0, 0.5)
        bg:SetSize(38, 38)
        bg:SetPoint("CENTER", slot.icon, "CENTER")
        slot.MCP_Background = bg

        CreateOctagonMask(slot)
        slot.icon:SetTexCoord(0, 1, 0, 1)
    end

    CreateOctagonBorder(slot, 19, 2)

    local itemAtlas = slot:CreateTexture(nil, "BORDER")
    itemAtlas:SetAtlas(C.BAR_ATLAS)
    itemAtlas:SetSize(200, 50)
    itemAtlas:SetDesaturated(true)
    itemAtlas:SetVertexColor(1, 1, 1, 1) -- Bien blanc

    local highlightBar = slot:CreateTexture(nil, "ARTWORK")
    highlightBar:SetAtlas(C.BAR_ATLAS)
    highlightBar:SetSize(200, 50)
    highlightBar:SetBlendMode("ADD")
    highlightBar:SetVertexColor(1, 1, 1, 0.25) -- Reflet au survol
    highlightBar:Hide()

    if isRight then
        itemAtlas:SetPoint("RIGHT", slot, "LEFT", 32, 0)
        itemAtlas:SetTexCoord(1, 0, 0, 1)
        highlightBar:SetPoint("RIGHT", slot, "LEFT", 32, 0)
        highlightBar:SetTexCoord(1, 0, 0, 1)
        slot:SetHitRectInsets(-168, 0, -6, -6)
    else
        itemAtlas:SetPoint("LEFT", slot, "RIGHT", -32, 0)
        itemAtlas:SetTexCoord(0, 1, 0, 1)
        highlightBar:SetPoint("LEFT", slot, "RIGHT", -32, 0)
        highlightBar:SetTexCoord(0, 1, 0, 1)
        slot:SetHitRectInsets(0, -168, -6, -6)
    end
    slot.MCP_Bar = itemAtlas
    slot.MCP_HighlightBar = highlightBar

    if not slot.MCP_HoverHooked then
        slot:HookScript("OnEnter", function()
            slot.MCP_HighlightBar:Show()
        end)
        slot:HookScript("OnLeave", function()
            slot.MCP_HighlightBar:Hide()
        end)
        slot.MCP_HoverHooked = true
    end

    local name = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetWidth(400)
    name:SetJustifyV("BOTTOM")
    name:SetWordWrap(false)
    slot.MCP_Name = name

    local ilvl = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    local font, size = ilvl:GetFont()
    ilvl:SetFont(font, size, "OUTLINE")
    ilvl:SetPoint("CENTER", slot, "CENTER", 0, 0)
    ilvl:SetTextColor(1, 1, 1)
    ilvl:SetShadowColor(0, 0, 0, 1)
    ilvl:SetShadowOffset(1, -1)
    slot.MCP_iLvl = ilvl

    local upgrade = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    upgrade:SetTextColor(0, 1, 1)
    slot.MCP_Upgrade = upgrade

    local enchant = slot:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
    enchant:SetTextColor(0.4, 1, 0.4)
    slot.MCP_Enchant = enchant

    local rankIcon = slot:CreateTexture(nil, "OVERLAY")
    rankIcon:SetSize(15, 15)
    rankIcon:Hide()
    slot.MCP_RankIcon = rankIcon

    if isRight then
        name:SetPoint("BOTTOMRIGHT", slot, "TOPRIGHT", 0, 5)
        name:SetJustifyH("RIGHT")

        upgrade:SetPoint("TOPRIGHT", itemAtlas, "TOPRIGHT", -45, -5)
        upgrade:SetJustifyH("RIGHT")

        enchant:SetPoint("TOPRIGHT", upgrade, "BOTTOMRIGHT", 0, -2)
        enchant:SetJustifyH("RIGHT")

        slot.MCP_RankIcon:SetPoint("RIGHT", enchant, "LEFT", -2, 0)
    else
        local slotName = slot:GetName()
        if slotName == "InspectShirtSlot" or slotName == "InspectTabardSlot" then
            name:SetPoint("LEFT", slot, "RIGHT", 10, 0)
            name:SetJustifyV("MIDDLE")
        else
            name:SetPoint("BOTTOMLEFT", slot, "TOPLEFT", 0, 5)
            name:SetJustifyV("BOTTOM")
        end
        name:SetJustifyH("LEFT")

        upgrade:SetPoint("TOPLEFT", itemAtlas, "TOPLEFT", 45, -5)
        upgrade:SetJustifyH("LEFT")

        enchant:SetPoint("TOPLEFT", upgrade, "BOTTOMLEFT", 0, -2)
        enchant:SetJustifyH("LEFT")

        slot.MCP_RankIcon:SetPoint("LEFT", enchant, "RIGHT", 2, 0)
    end

    local gemSize = (addon.Config and addon.Config.GemSize) or 16
    -- === LES GEMMES ===
    if not slot.MCP_Gems then
        slot.MCP_Gems = {}
    end
    for i = 1, 3 do
        local container = CreateFrame("Frame", nil, slot)
        container:SetSize(gemSize + 4, gemSize + 4)

        local g = container:CreateTexture(nil, "ARTWORK")
        g:SetSize(gemSize, gemSize)
        g:SetPoint("CENTER")
        g:SetTexCoord(0.03, 0.97, 0.03, 0.97)

        local mask = container:CreateMaskTexture()
        mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        mask:SetSize(gemSize, gemSize)
        mask:SetPoint("CENTER")
        g:AddMaskTexture(mask)

        local bg = container:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        bg:SetVertexColor(0, 0, 0, 0.7)
        bg:SetSize(gemSize + 2, gemSize + 2)
        bg:SetPoint("CENTER")
        container.Background = bg

        local bgMask = container:CreateMaskTexture()
        bgMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        bgMask:SetSize(gemSize + 2, gemSize + 2)
        bgMask:SetPoint("CENTER")
        bg:AddMaskTexture(bgMask)
        container.BgMask = bgMask

        local ring = container:CreateTexture(nil, "OVERLAY")
        ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        ring:SetSize(gemSize + 2, gemSize + 2)
        ring:SetVertexColor(0, 0, 0, 0.5)
        ring:SetPoint("CENTER")
        ring:SetBlendMode("ADD")
        ring:Hide()

        container:EnableMouse(true)
        container:SetScript("OnEnter", function(self)
            if self.gemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.gemLink)
                GameTooltip:Show()
            end
        end)
        container:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        local pulseAnim = container:CreateAnimationGroup()
        pulseAnim:SetLooping("BOUNCE")

        local alpha1 = pulseAnim:CreateAnimation("Alpha")
        alpha1:SetFromAlpha(1)
        alpha1:SetToAlpha(0.3)
        alpha1:SetDuration(0.8)
        alpha1:SetSmoothing("IN_OUT")

        container.PulseAnim = pulseAnim

        container.Texture = g
        container.Ring = ring
        container.Mask = mask
        table.insert(slot.MCP_Gems, container) -- On ajoute la gemme à la liste
    end

    -- === NETTOYAGE POUR LES ARMES ===
    if slotName == "InspectMainHandSlot" or slotName == "InspectSecondaryHandSlot" then
        if not slot.MCP_Hooked then
            hooksecurefunc(slot, "SetNormalTexture", function(self, tex)
                if tex and tex ~= "" then self:SetNormalTexture("") end
            end)
            slot.MCP_Hooked = true
        end

        -- On vire tout ce qui n'est pas à nous
        local regions = { slot:GetRegions() }
        for _, region in ipairs(regions) do
            if region:IsObjectType("Texture") then
                local isSafe = false
                if region == slot.icon then isSafe = true end
                if region == slot.MCP_Background then isSafe = true end
                if region == slot.MCP_Bar then isSafe = true end
                if region == slot.MCP_HighlightBar then isSafe = true end

                -- On vérifie les lignes de l'octogone
                if slot.MCP_OctagonLines then
                    for _, l in ipairs(slot.MCP_OctagonLines) do
                        if region == l then
                            isSafe = true
                            break
                        end
                    end
                end

                if slot.MCP_OctagonMasks then
                    for _, m in ipairs(slot.MCP_OctagonMasks) do
                        if region == m then
                            isSafe = true
                            break
                        end
                    end
                end

                if slot.MCP_Gems then
                    for _, g in ipairs(slot.MCP_Gems) do
                        if region == g.Texture or region == g.Ring or region == g.Mask or region == g or region == g.Background or region == g.BgMask then
                            isSafe = true
                            break
                        end
                    end
                end

                if not isSafe then
                    region:SetAlpha(0)
                    region:Hide()
                end
            end
        end
    end

    slot.MCP_VisualsCreated = true
end

-- Met à jour les informations d'une case d'équipement
function addon.Inspection.UpdateSlot(slot)
    local fname = slot:GetName() or ""

    if fname:find("Bag") then return end
    if not slot.MCP_VisualsCreated then CreateInspectSlotVisuals(slot) end

    slot.MCP_Bar:Show()
    if fname:find("InspectShirtSlot") or fname:find("InspectTabardSlot") then
        slot.MCP_Bar:SetVertexColor(1, 1, 1, 0.3)
    else
        slot.MCP_Bar:SetVertexColor(1, 1, 1, 1)
    end
    if slot.IconBorder then
        slot.IconBorder:SetTexture("")
        slot.IconBorder:SetAlpha(0)
    end
    if slot.IconOverlay then slot.IconOverlay:Hide() end
    if slot.ItemContextOverlay then slot.ItemContextOverlay:Hide() end

    local sideFrame = _G[fname .. "Frame"]
    if sideFrame then
        sideFrame:Hide()
        sideFrame:SetAlpha(0)
    end

    if slot.icon then slot.icon:SetTexCoord(0, 1, 0, 1) end
    local normal = slot:GetNormalTexture()
    if normal then
        slot:SetNormalTexture("")
        normal:SetAlpha(0)
    end

    -- === CHANGEMENT DE POLICE ===
    if addon.Config then
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

        -- Apply for Item Name
        local nameFPath = (LSM and addon.Config.ItemNameFont) and LSM:Fetch("font", addon.Config.ItemNameFont) or
            "Fonts\\FRIZQT__.TTF"
        local _, _, nameFlags = slot.MCP_Name:GetFont()
        addon.SafeSetFont(slot.MCP_Name, nameFPath, addon.Config.ItemNameSize or 12, nameFlags or "")

        -- Apply for Item Level
        local ilvlFPath = (LSM and addon.Config.ItemLevelFont) and LSM:Fetch("font", addon.Config.ItemLevelFont) or
            "Fonts\\FRIZQT__.TTF"
        local _, _, ilvlFlags = slot.MCP_iLvl:GetFont()
        addon.SafeSetFont(slot.MCP_iLvl, ilvlFPath, addon.Config.ItemLevelSize or 16, ilvlFlags or "")

        -- Apply for Enchantment
        local enchFPath = (LSM and addon.Config.EnchantFont) and LSM:Fetch("font", addon.Config.EnchantFont) or
            "Fonts\\FRIZQT__.TTF"
        local _, _, enchFlags = slot.MCP_Enchant:GetFont()
        addon.SafeSetFont(slot.MCP_Enchant, enchFPath, addon.Config.EnchantSize or 9, enchFlags or "")

        -- Apply for Upgrade
        local upgFPath = (LSM and addon.Config.UpgradeLevelFont) and LSM:Fetch("font", addon.Config.UpgradeLevelFont) or
            "Fonts\\FRIZQT__.TTF"
        local _, _, upgFlags = slot.MCP_Upgrade:GetFont()
        addon.SafeSetFont(slot.MCP_Upgrade, upgFPath, addon.Config.UpgradeLevelSize or 10, upgFlags or "")
    end

    -- Changement important: unit de l'InspectFrame
    local unit = InspectFrame and InspectFrame.unit or "target"
    local itemLink = GetInventoryItemLink(unit, slot:GetID())
    local itemID = GetInventoryItemID(unit, slot:GetID())
    local hasItem = GetInventoryItemTexture(unit, slot:GetID())

    if itemLink or itemID or hasItem then
        local itemName, itemRarity, itemLevel, itemTexture

        if itemLink then
            itemName, _, itemRarity, itemLevel, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemLink)
        elseif itemID then
            itemName, _, itemRarity, itemLevel, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID)
        end
        local actualILvl = itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel

        if itemName then
            -- On prépare le nom affiché
            local displayName = itemName
            local maxLen = 33
            if addon.Config and addon.Config.ItemNameLength then maxLen = addon.Config.ItemNameLength end
            if slot:GetName() == "InspectShirtSlot" or slot:GetName() == "InspectTabardSlot" then
                maxLen = (addon.Config and addon.Config.ItemNameLengthTabard) or 23
            end

            local charsStr = getUtf8Chars(displayName)
            local currentLen = #charsStr

            if currentLen > maxLen then
                local truncatedChars = {}
                for i = 1, maxLen - 2 do table.insert(truncatedChars, charsStr[i]) end
                table.insert(truncatedChars, ".")
                table.insert(truncatedChars, ".")
                displayName = table.concat(truncatedChars)
            end

            slot.MCP_FullName = itemName
            slot.MCP_ShortName = displayName

            if not slot.MCP_TextHoverHooked then
                -- Pour faire défiler le texte si c'est trop long
                slot:HookScript("OnEnter", function(self)
                    if self.isHoverScrollActive then return end
                    if addon.Config and addon.Config.HoverScroll and self.MCP_FullName then
                        local maxL = addon.Config.ItemNameLength or 33
                        if self:GetName() == "InspectShirtSlot" or self:GetName() == "InspectTabardSlot" then
                            maxL = addon.Config.ItemNameLengthTabard or 23
                        end
                        local origChars = getUtf8Chars(self.MCP_FullName)

                        if #origChars > maxL then
                            self.isHoverScrollActive = true
                            self.hoverScrollIdx = 1
                            self.isWaitingAtEnd = false
                            self.mcpPauseTicks = 0 -- pas de pause au départ initial
                            if self.mcpScrollTicker then self.mcpScrollTicker:Cancel() end
                            self.mcpScrollTicker = C_Timer.NewTicker(0.08, function()
                                if not self.isHoverScrollActive or not self:IsVisible() then
                                    if self.mcpScrollTicker then
                                        self.mcpScrollTicker:Cancel(); self.mcpScrollTicker = nil
                                    end
                                    return
                                end

                                if self.mcpPauseTicks > 0 then
                                    self.mcpPauseTicks = self.mcpPauseTicks - 1
                                    return
                                end

                                if self.isWaitingAtEnd then
                                    self.isWaitingAtEnd = false
                                    self.hoverScrollIdx = 1
                                    self.MCP_Name:SetText(getSlicedText(origChars, self.hoverScrollIdx, maxL))
                                    self.mcpPauseTicks = 12 -- Pause de ~1s début au reset
                                    return
                                end

                                self.MCP_Name:SetText(getSlicedText(origChars, self.hoverScrollIdx, maxL))
                                self.hoverScrollIdx = self.hoverScrollIdx + 1

                                if self.hoverScrollIdx > #origChars - maxL + 1 then
                                    self.isWaitingAtEnd = true
                                    self.mcpPauseTicks = 12 -- Pause de ~1s à la fin
                                end
                            end)
                        else
                            self.MCP_Name:SetText(self.MCP_FullName)
                        end
                    end
                end)
                slot:HookScript("OnLeave", function(self)
                    self.isHoverScrollActive = false
                    if self.mcpScrollTicker then
                        self.mcpScrollTicker:Cancel()
                        self.mcpScrollTicker = nil
                    end
                    if self.MCP_ShortName then
                        self.MCP_Name:SetText(self.MCP_ShortName)
                    end
                end)
                slot.MCP_TextHoverHooked = true
            end

            if not slot.isHoverScrollActive then
                slot.MCP_Name:SetText(displayName)
            end
            local r, g, b = C_Item.GetItemQualityColor(itemRarity or 1)
            slot.MCP_Name:SetTextColor(r, g, b)

            if slot.MCP_OctagonLines then
                for _, line in ipairs(slot.MCP_OctagonLines) do
                    line:SetVertexColor(r, g, b)
                    line:Show()
                end
            end
        else
            local loadingText = addon.L["LOADING"]
            slot.MCP_Name:SetText((not itemLink and hasItem) and addon.L["OPT_WAITING"] or loadingText)
            local r, g, b = 0.5, 0.5, 0.5
            slot.MCP_Name:SetTextColor(r, g, b)

            if slot.MCP_OctagonLines then
                for _, line in ipairs(slot.MCP_OctagonLines) do
                    line:SetVertexColor(r, g, b)
                    line:Show()
                end
            end
        end

        if not addon.Config or addon.Config.ShowIlvl then
            slot.MCP_iLvl:SetText(actualILvl or "")
        else
            slot.MCP_iLvl:SetText("")
        end

        -- On regarde les enchantements et améliorations de la cible
        local tooltipData = C_TooltipInfo.GetInventoryItem(unit, slot:GetID())
        local enchantText = ""
        local upgradeText = ""
        local rankAtlas = nil

        if tooltipData and tooltipData.lines then
            for i, line in ipairs(tooltipData.lines) do
                local text = line.leftText
                local currentLineAtlas = nil
                local currentLineTier = ""

                local args = line["args"]
                if type(args) == "table" then
                    for _, arg in ipairs(args) do
                        if type(arg) == "table" and arg.atlasName then
                            if arg.atlasName:find("Professions%-Icon%-Quality%-Tier1") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier1-Small:14:14|a"
                            elseif arg.atlasName:find("Professions%-Icon%-Quality%-Tier2") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier2-Small:14:14|a"
                            elseif arg.atlasName:find("Professions%-Icon%-Quality%-Tier3") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier3-Small:14:14|a"
                            end
                        end
                        if not text and type(arg) == "table" and arg.stringVal then text = arg.stringVal end
                    end
                end

                if text then
                    local cleanText = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                    cleanText = cleanText:match("^%s*(.-)%s*$")

                    local level = cleanText:match("(%d+/%d+)")
                    if level and not cleanText:match("%(%d+/%d+%)") then
                        local track = cleanText:match("([%aéèê]+)%s+" .. level)

                        if track and (track == addon.L["PATTERN_TRACK_EXCLUDE_1"] or track == addon.L["PATTERN_TRACK_EXCLUDE_2"] or track == addon.L["PATTERN_TRACK_EXCLUDE_3"]) then
                            track = nil
                        end

                        if track then
                            upgradeText = string.format(addon.L["UPGRADE_FORMAT"], track, level)
                        else
                            upgradeText = string.format(addon.L["UPGRADE_FORMAT_SHORT"], level)
                        end
                    end

                    -- On regarde si c'est un enchantement
                    local isEnchant = cleanText:find(addon.L["PATTERN_ENCHANT"]) or
                        cleanText:find(addon.L["PATTERN_ENCHANT_SHORT"])
                    local isRenfort = cleanText:find(addon.L["PATTERN_RENFORT"])
                    local isUse     = cleanText:find(addon.L["PATTERN_USE"]) or cleanText:find(addon.L["PATTERN_USE_EN"])

                    if (isEnchant or isRenfort) and not isUse then
                        local work = cleanText

                        local rankIconString = cleanText:match("(|A.-|a)")
                        if not rankIconString and currentLineAtlas then
                            rankIconString = currentLineAtlas
                        end
                        rankIconString = rankIconString or ""

                        if addon.Config and addon.Config.EnchantRankOnly then
                            enchantText = addon.L["PATTERN_ENCHANT"] .. " " .. rankIconString
                        else
                            if isEnchant then
                                work = work:match(addon.L["PATTERN_ENCHANT_SHORT"] .. ".-[%s:]+(.+)$") or work
                            elseif isRenfort then
                                work = work:match(addon.L["PATTERN_RENFORT"] .. ".-[%s:]+(.+)$") or work
                            end
                            work = work:gsub("^[%s:]+", "")
                            -- Nettoyage robuste : on ignore les atlas pour la recherche du tiret
                            local workClean = work:gsub("|A.-|a", "")
                            local sStart, sEnd = workClean:find("%s+[%-–—]%s*")

                            if sStart then
                                enchantText = workClean:sub(sEnd + 1)
                            else
                                -- Supprime "Enchanté : " et "Enchantement de..." si le tiret est absent
                                enchantText = workClean:gsub("^.-:%s*", ""):gsub("^Enchantement%s+d'.-%s+", ""):gsub(
                                    "^Enchantement%s+de%s+.-%s+", "")
                            end

                            -- Nettoyage final des espaces et tirets restants au début
                            enchantText = enchantText:gsub("^[%s%-–—]+", ""):match("^%s*(.-)%s*$")
                            if rankIconString and rankIconString ~= "" then
                                enchantText = enchantText .. " " .. rankIconString
                            end
                        end
                    end
                end
            end
        end

        local hasEnchantText = false
        local hasUpgradeText = false

        if enchantText ~= "" then
            for k, v in pairs(addon.L.STATS_MAP) do
                enchantText = enchantText:gsub(k, v)
                local cap = k:gsub("^%l", string.upper)
                enchantText = enchantText:gsub(cap, v)
                local low = k:gsub("^%u", string.lower)
                enchantText = enchantText:gsub(low, v)
            end

            if addon.L and addon.L.COSMETIC_MAP then
                for k, v in pairs(addon.L.COSMETIC_MAP) do
                    enchantText = enchantText:gsub(k, v)
                end
            end

            -- On garde que le bonus si c'est un long texte avec | +
            if enchantText:find(" %| %+") then
                local firstPart = enchantText:match("^(.-) %| %+")
                if firstPart and not firstPart:find("%+") then
                    enchantText = enchantText:match(" %| (%+.+)$") or enchantText
                end
            end

            if not addon.Config or addon.Config.ShowEnchant then
                slot.MCP_Enchant:SetText(enchantText)
                slot.MCP_Enchant:SetTextColor(0.4, 1, 0.4)
                hasEnchantText = true
            else
                slot.MCP_Enchant:SetText("")
                hasEnchantText = false
            end

            if rankAtlas and hasEnchantText then
                slot.MCP_RankIcon:SetAtlas(rankAtlas)
                slot.MCP_RankIcon:Show()
            else
                slot.MCP_RankIcon:Hide()
            end
        else
            local id = slot:GetID()
            local showKey = "ShowNotEnchanted_" .. id
            local shouldShow = addon.Config[showKey]
            if shouldShow == nil then shouldShow = false end -- bijoux/tabard : masqué par défaut
            if shouldShow and (not addon.Config or addon.Config.ShowEnchant) then
                slot.MCP_Enchant:SetText(addon.L["NOT_ENCHANTED"])
                slot.MCP_Enchant:SetTextColor(1, 0.2, 0.2)
                hasEnchantText = true
            else
                slot.MCP_Enchant:SetText("")
                hasEnchantText = false
            end
        end

        -- On nettoie le texte d'amélioration
        if upgradeText:find(addon.L["PATTERN_UPGRADE_RAW"]) then
            upgradeText = upgradeText:gsub(addon.L["PATTERN_UPGRADE_RAW"], ""):gsub(":", ""):gsub("^%s+", ""):gsub(
                "%s+$", "")
            upgradeText = "[" .. upgradeText:match("^%s*(.-)%s*$") .. "]"
            upgradeText = upgradeText:gsub("%[%s+", "[")
        end

        if not addon.Config or addon.Config.ShowUpgrade then
            slot.MCP_Upgrade:SetText(upgradeText)
            hasUpgradeText = (upgradeText ~= "")
        else
            slot.MCP_Upgrade:SetText("")
            hasUpgradeText = false
        end

        -- === FONT APPLY WAS HERE ===

        local justify = slot.MCP_Name:GetJustifyH()
        local isRight = (justify == "RIGHT")
        local anchorPoint = isRight and "RIGHT" or "LEFT"
        local xBaseOffset = isRight and -38 or 38

        local prefix = isRight and "Right" or "Left"

        -- Application des offsets manuels
        local nameOffsetX = (addon.Config and addon.Config["ItemName" .. prefix .. "OffsetX"] or 0)
        local nameOffsetY = (addon.Config and addon.Config["ItemName" .. prefix .. "OffsetY"] or 0)

        local upgOffsetX = (addon.Config and addon.Config["UpgradeLevel" .. prefix .. "OffsetX"] or 0)
        local upgOffsetY = (addon.Config and addon.Config["UpgradeLevel" .. prefix .. "OffsetY"] or 0)

        local enchOffsetX = (addon.Config and addon.Config["Enchant" .. prefix .. "OffsetX"] or 0)
        local enchOffsetY = (addon.Config and addon.Config["Enchant" .. prefix .. "OffsetY"] or 0)

        local ilvlOffsetX = (addon.Config and addon.Config["ItemLevel" .. prefix .. "OffsetX"] or 0)
        local ilvlOffsetY = (addon.Config and addon.Config["ItemLevel" .. prefix .. "OffsetY"] or 0)

        -- Offset Name
        slot.MCP_Name:ClearAllPoints()
        if isRight then
            slot.MCP_Name:SetPoint("BOTTOMRIGHT", slot, "TOPRIGHT", nameOffsetX, 5 + nameOffsetY)
        else
            local sName = slot:GetName()
            if sName == "InspectShirtSlot" or sName == "InspectTabardSlot" then
                slot.MCP_Name:SetPoint("LEFT", slot, "RIGHT", 10 + nameOffsetX, nameOffsetY)
            else
                slot.MCP_Name:SetPoint("BOTTOMLEFT", slot, "TOPLEFT", nameOffsetX, 5 + nameOffsetY)
            end
        end

        -- Offset iLvl
        slot.MCP_iLvl:ClearAllPoints()
        slot.MCP_iLvl:SetPoint("CENTER", slot, "CENTER", ilvlOffsetX, ilvlOffsetY)

        slot.MCP_Upgrade:ClearAllPoints()
        slot.MCP_Enchant:ClearAllPoints()

        if hasUpgradeText and hasEnchantText then
            slot.MCP_Upgrade:SetPoint(anchorPoint, slot.MCP_Bar, anchorPoint, xBaseOffset + upgOffsetX, 7 + upgOffsetY)
            slot.MCP_Enchant:SetPoint(anchorPoint, slot.MCP_Bar, anchorPoint, xBaseOffset + enchOffsetX, -7 + enchOffsetY)
        elseif hasUpgradeText then
            slot.MCP_Upgrade:SetPoint(anchorPoint, slot.MCP_Bar, anchorPoint, xBaseOffset + upgOffsetX, upgOffsetY)
        elseif hasEnchantText then
            slot.MCP_Enchant:SetPoint(anchorPoint, slot.MCP_Bar, anchorPoint, xBaseOffset + enchOffsetX, enchOffsetY)
        end

        local stats = nil
        if itemLink and type(itemLink) == "string" then
            stats = C_Item.GetItemStats(itemLink)
        end
        local numSockets = 0
        -- On regarde s'il y a des gemmes
        if (not addon.Config or addon.Config.ShowGems) and stats then
            for k, v in pairs(stats) do
                if string.find(k, "EMPTY_SOCKET_") then
                    numSockets = numSockets + v
                end
            end
        end

        local fname = slot:GetName() or ""
        local simulateGems = addon.Config and addon.Config.SimulateGems

        if simulateGems and string.find(fname, "HeadSlot") then
            numSockets = 3
        end

        for i, gem in ipairs(slot.MCP_Gems) do
            local gemSize = (addon.Config and addon.Config.GemSize) or 16
            gem:SetSize(gemSize + 4, gemSize + 4)
            gem.Texture:SetSize(gemSize, gemSize)
            if gem.Mask then gem.Mask:SetSize(gemSize, gemSize) end
            if gem.Ring then gem.Ring:SetSize(gemSize + 2, gemSize + 2) end
            if gem.Background then gem.Background:SetSize(gemSize + 2, gemSize + 2) end
            if gem.BgMask then gem.BgMask:SetSize(gemSize + 2, gemSize + 2) end

            local _, gemLink = nil, nil
            if simulateGems and string.find(fname, "HeadSlot") then
                gemLink = "item:192985"
            elseif not addon.Config or addon.Config.ShowGems then
                if itemLink and type(itemLink) == "string" then
                    _, gemLink = C_Item.GetItemGem(itemLink, i)
                end
            end

            gem:ClearAllPoints()

            local offsetX = (addon.Config and addon.Config["Gem" .. i .. "X"]) or 0
            local offsetY = (addon.Config and addon.Config["Gem" .. i .. "Y"]) or 0

            if isRight then
                gem:SetPoint("CENTER", slot, "TOPRIGHT", offsetX, offsetY)
            else
                gem:SetPoint("CENTER", slot, "TOPLEFT", -offsetX, offsetY)
            end

            if (not addon.Config or addon.Config.ShowGems) or simulateGems then
                if gemLink then
                    local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(gemLink)
                    if not icon and simulateGems then
                        icon = 138655 -- Primary stat gem override image for test
                    end
                    gem.Texture:SetTexture(icon)
                    gem.Texture:SetVertexColor(1, 1, 1)
                    gem.gemLink = gemLink
                    gem:Show()
                    if gem.Ring then gem.Ring:Show() end
                    if gem.PulseAnim then gem.PulseAnim:Stop() end
                elseif i <= numSockets then
                    gem.Texture:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
                    gem.Texture:SetVertexColor(1, 0.9, 0.4, 1.0) -- Doré brillant
                    gem.gemLink = nil
                    gem:Show()
                    if gem.Background then gem.Background:SetVertexColor(1, 1, 1, 0.1) end
                    if gem.Ring then
                        gem.Ring:Show()
                        gem.Ring:SetVertexColor(1, 1, 1, 0.3)
                    end
                    if gem.PulseAnim then gem.PulseAnim:Play() end
                else
                    gem.gemLink = nil
                    gem:Hide()
                    if gem.Ring then gem.Ring:Hide() end
                    if gem.PulseAnim then gem.PulseAnim:Stop() end
                end
            else
                gem.gemLink = nil
                gem:Hide()
                if gem.Ring then gem.Ring:Hide() end
                if gem.PulseAnim then gem.PulseAnim:Stop() end
            end
        end
    else
        slot.MCP_Bar:Show()
        slot.MCP_Bar:SetVertexColor(0.6, 0.6, 0.6)
        slot.MCP_Name:SetText("")

        if slot.MCP_OctagonLines then
            for _, line in ipairs(slot.MCP_OctagonLines) do
                line:SetVertexColor(0.5, 0.5, 0.5)
                line:Show()
            end
        end

        if slot.MCP_Background then
            slot.MCP_Background:SetColorTexture(0, 0, 0, 0.4)
            slot.MCP_Background:Show()
        end

        slot.MCP_iLvl:SetText("")
        slot.MCP_Enchant:SetText("")
        slot.MCP_Upgrade:SetText("")
        slot.MCP_RankIcon:Hide()

        for _, g in ipairs(slot.MCP_Gems) do
            g:Hide()
            if g.Ring then g.Ring:Hide() end
        end
    end
end

-- Organise le placement des cases dans la fenêtre
function addon.Inspection:UpdateLayout()
    if not InspectFrame then return end

    local selectedTab = PanelTemplates_GetSelectedTab(InspectFrame) or 1
    if selectedTab ~= 1 then return end

    local MAIN_WIDTH   = 640
    local SLOT_START_Y = C.SLOT_START_Y
    local SLOT_STEP_Y  = C.SLOT_STEP_Y

    -- On force la taille pour que ça ressemble à la fiche perso du joueur
    InspectFrame:SetWidth(MAIN_WIDTH)
    InspectFrame:SetHeight(740) -- Hauteur augmentée pour la marge des talents

    local PAD_X = 26

    local leftNames = { "InspectHeadSlot", "InspectNeckSlot", "InspectShoulderSlot", "InspectBackSlot",
        "InspectChestSlot", "InspectShirtSlot", "InspectTabardSlot", "InspectWristSlot" }
    local rightNames = { "InspectHandsSlot", "InspectWaistSlot", "InspectLegsSlot", "InspectFeetSlot",
        "InspectFinger0Slot", "InspectFinger1Slot", "InspectTrinket0Slot", "InspectTrinket1Slot" }

    for i, name in ipairs(leftNames) do
        local slot = _G[name]
        if slot then
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", PAD_X, SLOT_START_Y - ((i - 1) * SLOT_STEP_Y))
            slot:Show()
        end
    end

    for i, name in ipairs(rightNames) do
        local slot = _G[name]
        if slot then
            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT", InspectFrame, "TOPLEFT", MAIN_WIDTH - PAD_X, SLOT_START_Y - ((i - 1) * SLOT_STEP_Y))
            slot:Show()
        end
    end

    local WEAPON_GAP = C.WEAPON_GAP or 240
    local WEAPON_HEIGHT = 70 -- Armes remontées pour laisser de la place aux talents en dessous

    local mh = _G["InspectMainHandSlot"]
    local oh = _G["InspectSecondaryHandSlot"]

    if mh then
        mh:ClearAllPoints()
        mh:SetPoint("BOTTOM", InspectFrame, "BOTTOMLEFT", (MAIN_WIDTH / 2) - WEAPON_GAP, WEAPON_HEIGHT)
        mh:SetSize(37, 37)
        mh:SetNormalTexture("")
        mh:Show()
    end
    if oh then
        oh:ClearAllPoints()
        oh:SetPoint("BOTTOM", InspectFrame, "BOTTOMLEFT", (MAIN_WIDTH / 2) + WEAPON_GAP, WEAPON_HEIGHT)
        oh:SetSize(37, 37)
        oh:SetNormalTexture("")
        oh:Show()
    end

    if InspectModelFrame then
        InspectModelFrame:ClearAllPoints()
        InspectModelFrame:SetPoint("TOP", InspectFrame, "TOPLEFT", MAIN_WIDTH / 2, C.MODEL_YH or -100)
        InspectModelFrame:SetSize(260, 420)
        InspectModelFrame:Show()

        if InspectModelFrame.ControlFrame then InspectModelFrame.ControlFrame:Hide() end

        if InspectModelFrame.SetBackdrop then InspectModelFrame:SetBackdrop(nil) end
        for _, region in pairs({ InspectModelFrame:GetRegions() }) do
            if region:IsObjectType("Texture") then
                region:SetAlpha(0)
                region:Hide()
            end
        end
        if InspectModelFrame.BackgroundOverlay then InspectModelFrame.BackgroundOverlay:SetAlpha(0) end
        if InspectModelFrameBackgroundOverlay then InspectModelFrameBackgroundOverlay:SetAlpha(0) end
    end
    if InspectPaperDollItemsFrame and InspectPaperDollItemsFrame.DarkTop then
        InspectPaperDollItemsFrame.DarkTop
            :SetAlpha(0)
    end
end

local isInspectReskinned = nil

-- Gère l'affichage de la fenêtre d'inspection selon l'onglet
local function UpdateInspectView()
    if not InspectFrame or not InspectFrame:IsShown() then return end

    local selectedTab = PanelTemplates_GetSelectedTab(InspectFrame) or 1
    local shouldBeReskinned = (selectedTab == 1)

    -- Force size immediately
    if shouldBeReskinned then
        InspectFrame:SetWidth(640)
        InspectFrame:SetHeight(740)
    end

    if shouldBeReskinned then
        if InspectFrame.MCP_Header then
            InspectFrame.MCP_Header:Show()
            addon.Inspection.UpdateHeader()
        end

        -- NETTOYAGE (Blizzard remet tout à zéro quand on change d'onglet)
        if InspectFrame.MCP_MainBG then InspectFrame.MCP_MainBG:Show() end
        if InspectFrame.MCP_Border then InspectFrame.MCP_Border:Show() end

        if InspectFrameInset then
            InspectFrameInset:SetAlpha(0); InspectFrameInset:Hide()
        end
        if InspectFrame.NineSlice then
            InspectFrame.NineSlice:SetAlpha(0); InspectFrame.NineSlice:Hide()
        end
        if InspectFrame.Bg then
            InspectFrame.Bg:SetAlpha(0); InspectFrame.Bg:Hide()
        end
        if InspectFrameBg then InspectFrameBg:Hide() end
        if InspectFrame.TitleBg then
            InspectFrame.TitleBg:SetAlpha(0); InspectFrame.TitleBg:Hide()
        end
        if InspectFrame.TopTileStreaks then
            InspectFrame.TopTileStreaks:SetAlpha(0); InspectFrame.TopTileStreaks:Hide()
        end

        if InspectFrame.TitleContainer then
            InspectFrame.TitleContainer:SetAlpha(0); InspectFrame.TitleContainer:Hide()
        end
        if InspectFrameTitleText then
            InspectFrameTitleText:SetAlpha(0); InspectFrameTitleText:SetText("")
        end
        if InspectFrame.TitleText then
            InspectFrame.TitleText:SetAlpha(0); InspectFrame.TitleText:SetText("")
        end

        -- On cache le portrait de base
        if InspectFramePortrait then
            InspectFramePortrait:SetAlpha(0); InspectFramePortrait:Hide()
        end
        if InspectFrame.PortraitContainer then
            InspectFrame.PortraitContainer:SetAlpha(0); InspectFrame.PortraitContainer:Hide()
        end

        if InspectPaperDollItemsFrame then
            if InspectPaperDollItemsFrame.InspectLevelText then
                InspectPaperDollItemsFrame.InspectLevelText:SetAlpha(0); InspectPaperDollItemsFrame.InspectLevelText
                    :SetText(""); InspectPaperDollItemsFrame.InspectLevelText:Hide()
            end
            if InspectPaperDollItemsFrame.InspectGuildText then
                InspectPaperDollItemsFrame.InspectGuildText:SetAlpha(0); InspectPaperDollItemsFrame.InspectGuildText
                    :SetText(""); InspectPaperDollItemsFrame.InspectGuildText:Hide()
            end
            if InspectPaperDollItemsFrame.InspectTitleText then
                InspectPaperDollItemsFrame.InspectTitleText:SetAlpha(0); InspectPaperDollItemsFrame.InspectTitleText
                    :SetText(""); InspectPaperDollItemsFrame.InspectTitleText:Hide()
            end
            if InspectPaperDollItemsFrame.ViewButton then InspectPaperDollItemsFrame.ViewButton:SetAlpha(1) end
        end
        if InspectLevelText then
            InspectLevelText:SetAlpha(0); InspectLevelText:SetText("")
        end
        if InspectGuildText then
            InspectGuildText:SetAlpha(0); InspectGuildText:SetText("")
        end
        if InspectTitleText then
            InspectTitleText:SetAlpha(0); InspectTitleText:SetText("")
        end

        -- On ne refait le layout complet que si nécessaire (optimisation)
        if shouldBeReskinned == isInspectReskinned then return end
        isInspectReskinned = shouldBeReskinned

        if InspectFrameCloseButton then
            InspectFrameCloseButton:ClearAllPoints()
            InspectFrameCloseButton:SetPoint("TOPRIGHT", InspectFrame, "TOPRIGHT", -8, -8)
            InspectFrameCloseButton:SetNormalTexture("")
            InspectFrameCloseButton:SetNormalAtlas("uitools-icon-close")
            InspectFrameCloseButton:SetPushedAtlas("uitools-icon-close")
            InspectFrameCloseButton:SetDisabledAtlas("uitools-icon-close")
            InspectFrameCloseButton:SetHighlightAtlas("uitools-icon-close")
            InspectFrameCloseButton:SetSize(32, 32)
            InspectFrameCloseButton:SetFrameStrata("HIGH")
        end

        addon.Inspection:UpdateLayout()
    else
        -- NATIVE STATE
        InspectFrame:SetWidth(338)
        InspectFrame:SetHeight(424)

        if InspectFrame.MCP_MainBG then InspectFrame.MCP_MainBG:Hide() end
        if InspectFrame.MCP_Border then InspectFrame.MCP_Border:Hide() end
        if InspectFrame.MCP_Header then
            InspectFrame.MCP_Header:Hide()
            if InspectFrame.MCP_Header.ModelIlvl then InspectFrame.MCP_Header.ModelIlvl:Hide() end
        end

        if InspectFrameInset then
            InspectFrameInset:SetAlpha(1); InspectFrameInset:Show()
        end
        if InspectFrame.NineSlice then
            InspectFrame.NineSlice:SetAlpha(1); InspectFrame.NineSlice:Show()
        end
        if InspectFrame.Bg then
            InspectFrame.Bg:SetAlpha(1); InspectFrame.Bg:Show()
        end
        if InspectFrameBg then InspectFrameBg:Show() end
        if InspectFrame.TitleBg then InspectFrame.TitleBg:SetAlpha(1) end
        if InspectFrame.TopTileStreaks then InspectFrame.TopTileStreaks:SetAlpha(1) end

        if InspectFrame.TitleContainer then InspectFrame.TitleContainer:SetAlpha(1) end
        if InspectFrameTitleText then InspectFrameTitleText:SetAlpha(1) end
        if InspectFrame.TitleText then InspectFrame.TitleText:SetAlpha(1) end
        if InspectFramePortrait then InspectFramePortrait:SetAlpha(1) end
        if InspectFrame.PortraitContainer then InspectFrame.PortraitContainer:SetAlpha(1) end

        if InspectPaperDollItemsFrame then
            if InspectPaperDollItemsFrame.InspectLevelText then
                InspectPaperDollItemsFrame.InspectLevelText:SetAlpha(1); InspectPaperDollItemsFrame.InspectLevelText
                    :Show()
            end
            if InspectPaperDollItemsFrame.InspectGuildText then
                InspectPaperDollItemsFrame.InspectGuildText:SetAlpha(1); InspectPaperDollItemsFrame.InspectGuildText
                    :Show()
            end
            if InspectPaperDollItemsFrame.InspectTitleText then
                InspectPaperDollItemsFrame.InspectTitleText:SetAlpha(1); InspectPaperDollItemsFrame.InspectTitleText
                    :Show()
            end
        end
        if InspectLevelText then InspectLevelText:SetAlpha(1) end
        if InspectGuildText then InspectGuildText:SetAlpha(1) end
        if InspectTitleText then InspectTitleText:SetAlpha(1) end

        if InspectFrameCloseButton then
            InspectFrameCloseButton:ClearAllPoints()
            InspectFrameCloseButton:SetPoint("TOPRIGHT", InspectFrame, "TOPRIGHT", 4, 5)
            InspectFrameCloseButton:SetNormalAtlas("")
            InspectFrameCloseButton:SetPushedAtlas("")
            InspectFrameCloseButton:SetDisabledAtlas("")
            InspectFrameCloseButton:SetHighlightAtlas("")
            InspectFrameCloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
            InspectFrameCloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
            InspectFrameCloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
            InspectFrameCloseButton:SetSize(32, 32)
        end
    end
end

-- Applique le nouveau style à la fenêtre d'inspection
local function SkinInspectFrame()
    if isInspectSkinned then return end
    isInspectSkinned = true

    if InspectFrame then
        -- On fabrique nos propres fonds
        local mainBg = InspectFrame:CreateTexture(nil, "BACKGROUND")
        mainBg:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 4, -4)
        mainBg:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMRIGHT", -4, 4)
        mainBg:SetAtlas("talents-heroclass-choicepopup-background")
        mainBg:SetDesaturated(true)
        mainBg:SetVertexColor(1, 1, 1, 1)
        mainBg:SetTexCoord(0, 1, 0, 1)
        InspectFrame.MCP_MainBG = mainBg

        local border = CreateFrame("Frame", nil, InspectFrame, "BackdropTemplate")
        border:SetAllPoints(InspectFrame)
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        InspectFrame.MCP_Border = border

        local header = CreateFrame("Frame", nil, InspectFrame, "BackdropTemplate")
        header:SetSize(540, 50)
        header:SetPoint("TOP", InspectFrame, "TOP", 0, -15)

        InspectFrame:SetMovable(true)
        InspectFrame:SetUserPlaced(true)
        InspectFrame:SetClampedToScreen(true)
        InspectFrame:SetClampRectInsets(0, 0, 0, 0)
        InspectFrame:SetHitRectInsets(0, 0, 0, 0)

        header:EnableMouse(true)
        header:RegisterForDrag("LeftButton")
        header:SetScript("OnDragStart", function() InspectFrame:StartMoving() end)
        header:SetScript("OnDragStop", function() InspectFrame:StopMovingOrSizing() end)

        if InspectPaperDollFrame then
            InspectPaperDollFrame:EnableMouse(true)
            InspectPaperDollFrame:RegisterForDrag("LeftButton")
            InspectPaperDollFrame:SetScript("OnDragStart", function() InspectFrame:StartMoving() end)
            InspectPaperDollFrame:SetScript("OnDragStop", function() InspectFrame:StopMovingOrSizing() end)
        end

        if InspectPaperDollItemsFrame then
            InspectPaperDollItemsFrame:EnableMouse(true)
            InspectPaperDollItemsFrame:RegisterForDrag("LeftButton")
            InspectPaperDollItemsFrame:SetScript("OnDragStart", function() InspectFrame:StartMoving() end)
            InspectPaperDollItemsFrame:SetScript("OnDragStop", function() InspectFrame:StopMovingOrSizing() end)
        end

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
        cIcon:SetSize(40, 40)
        cIcon:SetPoint("LEFT", 10, 0)
        cIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        local cMask = header:CreateMaskTexture()
        cMask:SetTexture(C.MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        cMask:SetAllPoints(cIcon)
        cIcon:AddMaskTexture(cMask)
        header.ClassIcon = cIcon

        local name = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header.Name = name

        local lvl = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lvl:SetTextColor(0.8, 0.8, 0.8)
        header.Level = lvl

        local scoreLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        scoreLabel:SetPoint("RIGHT", header, "RIGHT", -20, 0)
        header.Score = scoreLabel

        -- Icône de Spéc (En bas à droite du portrait)
        local sIcon = header:CreateTexture(nil, "ARTWORK", nil, 3)
        sIcon:SetSize(18, 18)
        sIcon:SetPoint("BOTTOMRIGHT", cIcon, "BOTTOMRIGHT", 6, 2)
        local sMask = header:CreateMaskTexture()
        sMask:SetTexture(C.MASK_TEXTURE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        sMask:SetAllPoints(sIcon)
        sIcon:AddMaskTexture(sMask)
        sIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        header.SpecIcon = sIcon

        header.Name:SetPoint("BOTTOMLEFT", cIcon, "RIGHT", 8, 0)
        header.Level:SetPoint("TOPLEFT", cIcon, "RIGHT", 8, -2)

        -- iLVL Global au dessus du perso
        local modelIlvl = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
        modelIlvl:SetPoint("BOTTOM", InspectModelFrame, "TOP", 0, 10)
        header.ModelIlvl = modelIlvl

        -- On déplace les boutons de base de Blizzard
        if InspectPaperDollFrame then
            if InspectPaperDollFrame.ViewButton then
                local viewBtn = InspectPaperDollFrame.ViewButton
                viewBtn:SetParent(header)
                viewBtn:ClearAllPoints()
                viewBtn:SetPoint("CENTER", header, "CENTER", 0, 0)

                -- Look "Coffre-fort" pour les boutons
                viewBtn:SetSize(230, 34)

                -- Les boutons natifs ont souvent des textures basées sur des régions
                local regions = { viewBtn:GetRegions() }
                for _, r in ipairs(regions) do
                    if r:IsObjectType("Texture") and r ~= viewBtn:GetFontString() then
                        r:SetAlpha(0)
                        r:Hide()
                    end
                end

                if viewBtn.Left then viewBtn.Left:SetAlpha(0) end
                if viewBtn.Middle then viewBtn.Middle:SetAlpha(0) end
                if viewBtn.Right then viewBtn.Right:SetAlpha(0) end
                if viewBtn.TopLeft then viewBtn.TopLeft:SetAlpha(0) end
                if viewBtn.TopRight then viewBtn.TopRight:SetAlpha(0) end
                if viewBtn.BottomLeft then viewBtn.BottomLeft:SetAlpha(0) end
                if viewBtn.BottomRight then viewBtn.BottomRight:SetAlpha(0) end
                if viewBtn.TopMiddle then viewBtn.TopMiddle:SetAlpha(0) end
                if viewBtn.BottomMiddle then viewBtn.BottomMiddle:SetAlpha(0) end
                if viewBtn.MiddleMiddle then viewBtn.MiddleMiddle:SetAlpha(0) end

                viewBtn:SetNormalTexture("")
                viewBtn:SetPushedTexture("")
                viewBtn:SetHighlightTexture("")

                -- On soigne le texte des boutons
                local vText = viewBtn:GetFontString()
                if vText then
                    viewBtn.Text = vText
                    vText:ClearAllPoints()
                    vText:SetPoint("CENTER", viewBtn, "CENTER", 0, 0)
                    vText:SetJustifyH("CENTER")
                    vText:SetFontObject("GameFontNormal")
                end

                if not viewBtn.MCP_Styling then
                    local bgFrame = CreateFrame("Frame", nil, viewBtn, "BackdropTemplate")
                    bgFrame:SetAllPoints(viewBtn)
                    bgFrame:SetFrameLevel(viewBtn:GetFrameLevel() - 1)

                    bgFrame:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8X8",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 16,
                        insets = { left = 3, right = 3, top = 3, bottom = 3 }
                    })
                    bgFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
                    bgFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)

                    local wg = bgFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
                    wg:SetPoint("TOPLEFT", 4, -4)
                    wg:SetPoint("BOTTOMRIGHT", -4, 4)
                    -- Couleur sombre style Vault
                    wg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
                    viewBtn.wg = wg

                    local hl = viewBtn:CreateTexture(nil, "HIGHLIGHT")
                    hl:SetPoint("TOPLEFT", 4, -4)
                    hl:SetPoint("BOTTOMRIGHT", -4, 4)
                    hl:SetColorTexture(1, 1, 1, 0.05)
                    hl:SetBlendMode("ADD")

                    viewBtn.MCP_Styling = true

                    viewBtn:SetScript("OnMouseDown", function(self)
                        if self.wg then
                            self.wg:SetPoint("TOPLEFT", 5, -5)
                            self.wg:SetPoint("BOTTOMRIGHT", -5, 5)
                        end
                        if self.Text then self.Text:SetPoint("CENTER", 1, -1) end
                    end)
                    viewBtn:SetScript("OnMouseUp", function(self)
                        if self.wg then
                            self.wg:SetPoint("TOPLEFT", 4, -4)
                            self.wg:SetPoint("BOTTOMRIGHT", -4, 4)
                        end
                        if self.Text then self.Text:SetPoint("CENTER", 0, 0) end
                    end)
                end
            end
        end

        if InspectPaperDollItemsFrame and InspectPaperDollItemsFrame.InspectTalents then
            local talentsBtn = InspectPaperDollItemsFrame.InspectTalents
            talentsBtn:ClearAllPoints()
            talentsBtn:SetPoint("BOTTOM", InspectFrame, "BOTTOM", 0, 25)
            talentsBtn:SetSize(160, 30)
        end

        InspectFrame.MCP_Header = header

        -- On surveille les clics sur les onglets pour rafraîchir la vue
        if InspectFrameTab1 then InspectFrameTab1:HookScript("OnClick", function() UpdateInspectView() end) end
        if InspectFrameTab2 then InspectFrameTab2:HookScript("OnClick", function() UpdateInspectView() end) end
        if InspectFrameTab3 then InspectFrameTab3:HookScript("OnClick", function() UpdateInspectView() end) end

        UpdateInspectView()
    end
end

-- Met à jour le bandeau du haut (nom, niveau, score)
function addon.Inspection.UpdateHeader()
    if not InspectFrame or not InspectFrame.MCP_Header then return end

    local header = InspectFrame.MCP_Header
    local unit = InspectFrame.unit or "target"

    -- On vérifie qu'on regarde bien le nouveau mec (anti-bug de cache)
    local guid = UnitGUID(unit)
    if not guid then return end

    if header.lastGUID ~= guid then
        header.lastGUID = guid
        header.Name:SetText(UnitName(unit) or addon.L["LOADING"])
        header.Level:SetText("")
        if header.Score then header.Score:SetText("") end
        if header.SpecIcon then header.SpecIcon:Hide() end
        if header.ModelIlvl then header.ModelIlvl:SetText("") end
    end

    local _, classFile = UnitClass(unit)
    if classFile then
        header.ClassIcon:SetTexture("Interface\\Icons\\ClassIcon_" .. classFile)
    end

    header.Name:SetText(UnitName(unit))

    local color = C_ClassColor.GetClassColor(classFile)
    if color then header.Name:SetTextColor(color.r, color.g, color.b) end

    header.Level:SetText(string.format(addon.L["LEVEL_FORMAT"], UnitLevel(unit) or 0))

    -- Icône de la Spécialisation (Tank, Heal, Dps)
    if header.SpecIcon then
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            local _, _, _, specIcon = GetSpecializationInfoByID(specID)
            if specIcon then
                header.SpecIcon:SetTexture(specIcon)
                header.SpecIcon:Show()
            else
                header.SpecIcon:Hide()
            end
        else
            header.SpecIcon:Hide()
        end
    end

    -- iLVL Global (que sur le premier onglet)
    if header.ModelIlvl then
        local isPaperDoll = (PanelTemplates_GetSelectedTab(InspectFrame) == 1)
        local avgItemLevel, avgItemLevelEquipped = C_PaperDollInfo.GetInspectItemLevel(unit)
        local iLvl = avgItemLevelEquipped or avgItemLevel or 0
        if isPaperDoll and iLvl > 0 then
            header.ModelIlvl:Show()
            header.ModelIlvl:SetText(string.format(addon.L["ILVL_FORMAT"], string.format("%.1f", iLvl)))
            -- Couleur du texte selon l'iLvl (dégradé simple)
            local r, g, b = 1, 1, 1
            if iLvl >= 630 then
                r, g, b = 1, 0.5, 0        -- Légendaire/Mythique
            elseif iLvl >= 610 then
                r, g, b = 0.64, 0.21, 0.93 -- Épique
            elseif iLvl >= 590 then
                r, g, b = 0, 0.44, 0.87    -- Rare
            elseif iLvl >= 570 then
                r, g, b = 0.12, 1, 0       -- Inhabituel
            end
            header.ModelIlvl:SetTextColor(r, g, b)
        else
            header.ModelIlvl:Hide()
            header.ModelIlvl:SetText("")
        end
    end

    if header.Score then
        local score = 0
        if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
            local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
            if summary and summary.currentSeasonScore then
                score = summary.currentSeasonScore
            end
        end

        if score > 0 then
            local c = C_ChallengeMode.GetDungeonScoreRarityColor(score) or { r = 1, g = 1, b = 1 }
            header.Score:SetText(string.format(addon.L["MYTHIC_PLUS_FORMAT"], score))
            header.Score:SetTextColor(c.r, c.g, c.b)
        else
            header.Score:SetText(string.format(addon.L["MYTHIC_PLUS_FORMAT"], "-"))
            header.Score:SetTextColor(0.5, 0.5, 0.5)
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("INSPECT_READY")
f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
f:RegisterEvent("TOOLTIP_DATA_UPDATE")

-- Fonction pour forcer la mise à jour de tous les emplacements (utile en combat car les infos chargent lentement)
local function ForceUpdateAllInspectSlots()
    if not InspectFrame or not InspectFrame:IsShown() then return end
    if f.isUpdatingSlots then return end
    f.isUpdatingSlots = true

    C_Timer.After(0.1, function()
        if InspectFrame and InspectFrame:IsShown() then
            addon.Inspection.UpdateHeader()

            -- Boucle sur les objets de gauche
            for _, slotName in ipairs(addon.CONST.LEFT_SLOTS) do
                local s = _G[slotName:gsub("Character", "Inspect")]
                if s then addon.Inspection.UpdateSlot(s) end
            end
            -- Boucle sur les objets de droite
            for _, slotName in ipairs(addon.CONST.RIGHT_SLOTS) do
                local s = _G[slotName:gsub("Character", "Inspect")]
                if s then addon.Inspection.UpdateSlot(s) end
            end
            -- Armes
            if _G["InspectMainHandSlot"] then addon.Inspection.UpdateSlot(_G["InspectMainHandSlot"]) end
            if _G["InspectSecondaryHandSlot"] then addon.Inspection.UpdateSlot(_G["InspectSecondaryHandSlot"]) end
        end
        f.isUpdatingSlots = false
    end)
end

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addOnName = ...
        if addOnName == "Blizzard_InspectUI" then
            SkinInspectFrame()
            hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(btn)
                addon.Inspection.UpdateSlot(btn)
            end)
            InspectFrame:HookScript("OnShow", function()
                UpdateInspectView()
            end)
            hooksecurefunc("InspectPaperDollFrame_OnShow", function()
                UpdateInspectView()
            end)
        end
    elseif event == "INSPECT_READY" or event == "GET_ITEM_INFO_RECEIVED" or event == "TOOLTIP_DATA_UPDATE" then
        if InspectFrame and InspectFrame:IsShown() then
            ForceUpdateAllInspectSlots()
        end
    end
end)
