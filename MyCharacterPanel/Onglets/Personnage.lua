local addonName, addon = ...
addon.Personnage = {}



local C = addon.CONST
C.SLOT_START_Y = -105 -- On descend les cases sous le titre
C.SLOT_STEP_Y = 65
C.WEAPON_HEIGHT = 25
C.WEAPON_GAP = 220
C.MODEL_YH = -130   -- On descend le perso 3D pour suivre
C.TOTAL_WIDTH = 680 -- Fenêtre plus large
C.MAIN_WIDTH = 680  -- Objets plus larges
C.STATS_WIDTH = 230 -- Stats moins larges
C.HEIGHT = 700

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

-- Fonction pour faire une bordure en octogone procédurale
local function CreateOctagonBorder(slot, radius, thickness)
    if slot.MCP_OctagonLines then return end
    slot.MCP_OctagonLines = {}

    local color = { 0.3, 0.3, 0.3 } -- Couleur par défaut

    -- Pour dessiner les 8 côtés de l'octogone
    local sideLength = 2 * radius * 0.414

    for i = 0, 7 do
        local angleDeg = i * 45
        local angleRad = math.rad(angleDeg)

        local line = slot:CreateTexture(nil, "OVERLAY")
        line:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        line:SetSize(sideLength + (thickness * 0.45), thickness) -- Ajusté pour moins d'irrégularité aux angles

        -- Pour placer chaque ligne au bon endroit
        local cx = radius * math.cos(angleRad)
        local cy = radius * math.sin(angleRad)

        line:SetPoint("CENTER", slot.icon, "CENTER", cx, cy)

        -- On tourne la ligne pour qu'elle suive le bord
        line:SetRotation(angleRad + math.pi / 2)

        line:SetVertexColor(unpack(color))
        table.insert(slot.MCP_OctagonLines, line)
    end
end

-- Fonction pour faire un masque octogonal (un carré normal + un penché)
local function CreateOctagonMask(slot)
    if slot.MCP_OctagonMasks then return end
    slot.MCP_OctagonMasks = {}

    -- Masque 1 : Carré normal
    local m1 = slot:CreateMaskTexture()
    m1:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m1:SetSize(36, 36)
    m1:SetPoint("CENTER", slot.icon, "CENTER")
    slot.icon:AddMaskTexture(m1)

    -- Masque 2 : Carré tourné 45°
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

    if slot.searchOverlay then
        slot.searchOverlay:AddMaskTexture(m1)
        slot.searchOverlay:AddMaskTexture(m2)
    end

    -- On masque aussi les trucs de Blizzard qui dépassent (bordures, reflets...)
    local nativeOverlays = { "IconBorder", "IconOverlay", "IconOverlay2", "ItemContextOverlay" }
    for _, name in ipairs(nativeOverlays) do
        if slot[name] and slot[name].AddMaskTexture then
            slot[name]:AddMaskTexture(m1)
            slot[name]:AddMaskTexture(m2)
        end
    end

    slot.MCP_OctagonMasks = { m1, m2 }
end

-- On prépare le visuel d'une case (une seule fois)
local function CreateSlotVisuals(slot)
    if slot.MCP_VisualsCreated then return end

    local slotName = slot:GetName()
    local isRight = false
    for _, s in ipairs(C.RIGHT_SLOTS) do
        if s == slotName then
            isRight = true
            break
        end
    end
    if slotName == "CharacterSecondaryHandSlot" then isRight = true end

    -- === L'OCTOGONE ===
    -- 1. On cache les vieilles bordures carrées
    if slot.IconBorder then
        slot.IconBorder:SetTexture("")
        slot.IconBorder:Hide()
        slot.IconBorder:SetAlpha(0) -- Pour être sûr que ça revienne pas
    end
    slot:SetNormalTexture("")
    if slot.IconOverlay then
        slot.IconOverlay:Hide()
        slot.IconOverlay:SetAlpha(0)
    end
    if slot.IconOverlay2 then
        slot.IconOverlay2:Hide()
        slot.IconOverlay2:SetAlpha(0)
    end

    local sideFrame = _G[slotName .. "Frame"]
    if sideFrame then
        sideFrame:Hide()
        sideFrame:SetAlpha(0)
    end

    if slot.IconOverlay2 then slot.IconOverlay2:Hide() end
    if slot.AzeriteTexture then slot.AzeriteTexture:Hide() end

    if slot.icon then
        -- 2. Le fond noir derrière l'icône
        local bg = slot:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0, 0.5) -- Un peu de transparence
        bg:SetSize(38, 38)
        bg:SetPoint("CENTER", slot.icon, "CENTER")
        slot.MCP_Background = bg

        -- 3. On coupe l'icône en forme d'octogone
        CreateOctagonMask(slot)

        slot.icon:SetTexCoord(0, 1, 0, 1)
    end

    -- 4. Genère la bordure
    CreateOctagonBorder(slot, 19, 2)

    -- Le hook searchOverlay a été déplacé à la fin de la fonction

    -- === ATLAS DE L'ITEM (FOND TEXTURÉ) ===
    -- Pour changer la taille : Modifier SetSize(210, 50)
    -- Pour changer la couleur : Modifier SetVertexColor
    local itemAtlas = slot:CreateTexture(nil, "BORDER") -- BORDER pour être sûr d'être visible
    itemAtlas:SetAtlas(C.BAR_ATLAS)
    itemAtlas:SetSize(200, 50)
    itemAtlas:SetDesaturated(true)
    itemAtlas:SetVertexColor(1, 1, 1, 1) -- Bien blanc

    -- === ATLAS HIGHLIGHT ===
    local highlightBar = slot:CreateTexture(nil, "ARTWORK")
    highlightBar:SetAtlas(C.BAR_ATLAS)
    highlightBar:SetSize(200, 50)
    highlightBar:SetBlendMode("ADD")
    highlightBar:SetVertexColor(1, 1, 1, 0.25) -- Un petit reflet quand on survole
    highlightBar:Hide()

    -- === POSITION DE L'ATLAS ===
    -- Si vous voulez écarter l'atlas de l'icône : changez le 5 (droite) ou -5 (gauche)
    if isRight then
        -- A droite (le texte va vers la gauche)
        itemAtlas:SetPoint("RIGHT", slot, "LEFT", 32, 0)
        itemAtlas:SetTexCoord(1, 0, 0, 1)
        highlightBar:SetPoint("RIGHT", slot, "LEFT", 32, 0)
        highlightBar:SetTexCoord(1, 0, 0, 1)
        slot:SetHitRectInsets(-168, 0, -6, -6)
    else
        -- A gauche (le texte va vers la droite)
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

    -- === NOM DE L'OBJET ===
    local name = slot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetWidth(400) -- Beaucoup plus large pour supporter jusqu'à 80 caractères
    name:SetJustifyV("BOTTOM")
    name:SetWordWrap(false)
    slot.MCP_Name = name

    -- === NIVEAU D'OBJET (ILVL) ===
    local ilvl = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    -- On met un contour pour mieux voir le chiffre
    local font, size = ilvl:GetFont()
    ilvl:SetFont(font, size, "OUTLINE")
    ilvl:SetPoint("CENTER", slot, "CENTER", 0, 0)
    ilvl:SetTextColor(1, 1, 1)
    -- Ombre légère
    ilvl:SetShadowColor(0, 0, 0, 1)
    ilvl:SetShadowOffset(1, -1)
    slot.MCP_iLvl = ilvl

    -- === NIVEAU D'AMELIORATION ===
    local upgrade = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    upgrade:SetTextColor(0, 1, 1) -- Couleur turquoise
    slot.MCP_Upgrade = upgrade

    -- === ENCHANTEMENT ===
    local enchant = slot:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
    enchant:SetTextColor(0.4, 1, 0.4) -- Couleur verte
    slot.MCP_Enchant = enchant

    -- === RANG ENCHANTEMENT ===
    local rankIcon = slot:CreateTexture(nil, "OVERLAY")
    rankIcon:SetSize(15, 15)
    rankIcon:Hide()
    slot.MCP_RankIcon = rankIcon

    -- === POSITIONNEMENT DES TEXTES ===
    -- Si c'est à droite (Gants...) ou à gauche (Tête...)
    if isRight then
        -- Positionnement pour les objets à droite
        name:SetPoint("BOTTOMRIGHT", slot, "TOPRIGHT", 0, 5)
        name:SetJustifyH("RIGHT")

        -- AMELIORATION : Sous le nom
        upgrade:SetPoint("TOPRIGHT", itemAtlas, "TOPRIGHT", -45, -5)
        upgrade:SetJustifyH("RIGHT")

        -- ENCHANT : En dessous de l'upgrade
        enchant:SetPoint("TOPRIGHT", upgrade, "BOTTOMRIGHT", 0, -2)
        enchant:SetJustifyH("RIGHT")

        slot.MCP_RankIcon:SetPoint("RIGHT", enchant, "LEFT", -2, 0)
    else
        -- Positionnement pour les objets à gauche
        local slotName = slot:GetName()
        if slotName == "CharacterShirtSlot" or slotName == "CharacterTabardSlot" then
            name:SetPoint("LEFT", slot, "RIGHT", 10, 0)
            name:SetJustifyV("MIDDLE")
        else
            name:SetPoint("BOTTOMLEFT", slot, "TOPLEFT", 0, 5)
            name:SetJustifyV("BOTTOM")
        end
        name:SetJustifyH("LEFT")

        -- AMELIORATION : Sous le nom
        upgrade:SetPoint("TOPLEFT", itemAtlas, "TOPLEFT", 45, -5)
        upgrade:SetJustifyH("LEFT")

        -- ENCHANT : En dessous de l'upgrade
        enchant:SetPoint("TOPLEFT", upgrade, "BOTTOMLEFT", 0, -2)
        enchant:SetJustifyH("LEFT")

        slot.MCP_RankIcon:SetPoint("LEFT", enchant, "RIGHT", 2, 0)
    end

    -- === LES GEMMES ===
    local gemSize = (addon.Config and addon.Config.GemSize) or 16
    slot.MCP_Gems = {}
    for i = 1, 3 do
        local container = CreateFrame("Frame", nil, slot)
        container:SetSize(gemSize + 4, gemSize + 4)

        -- Texture de la gemme
        local g = container:CreateTexture(nil, "ARTWORK")
        g:SetSize(gemSize, gemSize)
        g:SetPoint("CENTER")
        g:SetTexCoord(0.03, 0.97, 0.03, 0.97)

        -- Masque circulaire
        local mask = container:CreateMaskTexture()
        mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        mask:SetSize(gemSize, gemSize)
        mask:SetPoint("CENTER")
        g:AddMaskTexture(mask)

        -- Fond circulaire noir pour créer la bordure
        local bg = container:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        bg:SetVertexColor(0, 0, 0, 0.7)
        bg:SetSize(gemSize + 2, gemSize + 2)
        bg:SetPoint("CENTER")
        container.Background = bg

        -- Masque circulaire pour le fond
        local bgMask = container:CreateMaskTexture()
        bgMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE")
        bgMask:SetSize(gemSize + 2, gemSize + 2)
        bgMask:SetPoint("CENTER")
        bg:AddMaskTexture(bgMask)

        -- Bordure circulaire fine noire (anneau vide pour effet)
        local ring = container:CreateTexture(nil, "OVERLAY")
        ring:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        ring:SetSize(gemSize + 2, gemSize + 2)
        ring:SetVertexColor(0, 0, 0, 0.5)
        ring:SetPoint("CENTER")
        ring:SetBlendMode("ADD")
        ring:Hide() -- Caché pour l'instant

        -- Pour voir les infos de la gemme quand on passe la souris
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

        -- Animation pour les gemmes vides
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
        table.insert(slot.MCP_Gems, container)
    end

    -- === NETTOYAGE POUR LES ARMES ===
    if slotName == "CharacterMainHandSlot" or slotName == "CharacterSecondaryHandSlot" then
        -- 1. Empeche le jeu de remettre sa texture
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

                -- Safe Octagon
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

                -- On vérifie les gemmes aussi
                if slot.MCP_Gems then
                    for _, g in ipairs(slot.MCP_Gems) do
                        if region == g then
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

    -- === ON SYNCHRONISE LA RECHERCHE (ENCHANT, GEMMES) ===
    if not slot.MCP_SearchHooked then
        local function UpdateSlotAlpha()
            -- L'opacité doit être réduite si le searchOverlay est actif.
            -- De plus, on vérifie si l'itemContextOverlay existe.
            local isSearching = false
            if slot.searchOverlay and slot.searchOverlay:IsShown() then isSearching = true end
            if slot.ItemContextOverlay and slot.ItemContextOverlay:IsShown() then isSearching = true end
            if slot.IconOverlay and slot.IconOverlay:IsShown() then isSearching = true end

            local alpha = isSearching and 0.2 or 1

            if slot.MCP_OctagonLines then
                for _, line in ipairs(slot.MCP_OctagonLines) do
                    line:SetAlpha(isSearching and 0 or 1)
                end
            end

            if slot.MCP_Bar then slot.MCP_Bar:SetAlpha(alpha) end
            if slot.MCP_Name then slot.MCP_Name:SetAlpha(alpha) end
            if slot.MCP_iLvl then slot.MCP_iLvl:SetAlpha(alpha) end
            if slot.MCP_Enchant then slot.MCP_Enchant:SetAlpha(alpha) end
            if slot.MCP_Upgrade then slot.MCP_Upgrade:SetAlpha(alpha) end
            if slot.MCP_RankIcon then slot.MCP_RankIcon:SetAlpha(alpha) end
            if slot.MCP_GemRoot then slot.MCP_GemRoot:SetAlpha(alpha) end
            if slot.MCP_Background then slot.MCP_Background:SetAlpha(isSearching and 0 or 0.5) end
        end

        if slot.searchOverlay then
            hooksecurefunc(slot.searchOverlay, "Show", UpdateSlotAlpha)
            hooksecurefunc(slot.searchOverlay, "Hide", UpdateSlotAlpha)
            hooksecurefunc(slot.searchOverlay, "SetShown", UpdateSlotAlpha)
        end
        if slot.ItemContextOverlay then
            hooksecurefunc(slot.ItemContextOverlay, "Show", function()
                slot.ItemContextOverlay:SetAlpha(0)
                UpdateSlotAlpha()
            end)
            hooksecurefunc(slot.ItemContextOverlay, "Hide", UpdateSlotAlpha)
            hooksecurefunc(slot.ItemContextOverlay, "SetShown", function()
                slot.ItemContextOverlay:SetAlpha(0)
                UpdateSlotAlpha()
            end)
        end
        if slot.IconOverlay then
            hooksecurefunc(slot.IconOverlay, "Show", function()
                slot.IconOverlay:SetAlpha(0)
                UpdateSlotAlpha()
            end)
            hooksecurefunc(slot.IconOverlay, "Hide", UpdateSlotAlpha)
            hooksecurefunc(slot.IconOverlay, "SetShown", function()
                slot.IconOverlay:SetAlpha(0)
                UpdateSlotAlpha()
            end)
        end

        slot.MCP_SearchHooked = true
        slot.MCP_UpdateSlotAlpha = UpdateSlotAlpha

        UpdateSlotAlpha()
    end

    slot.MCP_VisualsCreated = true
end


-- Lancé dès qu'un objet change
function addon.Personnage.UpdateSlot(slot)
    if not addon.Config then return end -- Sécurité si appelé trop tôt
    local fname = slot:GetName() or ""

    -- Le reste du début de fonction est inchangé...
    if fname:find("Bag") then return end
    if not slot.MCP_VisualsCreated then CreateSlotVisuals(slot) end
    local selectedTab = PanelTemplates_GetSelectedTab(CharacterFrame) or 1
    if selectedTab ~= 1 then return end -- Si on n'est pas sur le premier onglet, on s'arrête

    -- On réaffiche le tout si Tab 1
    slot.MCP_Bar:Show()
    if fname:find("CharacterShirtSlot") or fname:find("CharacterTabardSlot") then
        slot.MCP_Bar:SetVertexColor(1, 1, 1, 0.3) -- Transparent
    else
        slot.MCP_Bar:SetVertexColor(1, 1, 1, 1)   -- Plus clair
    end
    -- On enlève les bordures de base au cas où
    if slot.IconBorder then
        slot.IconBorder:SetTexture("")
        slot.IconBorder:SetAlpha(0)
    end
    if slot.IconOverlay then slot.IconOverlay:SetAlpha(0) end
    if slot.ItemContextOverlay then slot.ItemContextOverlay:SetAlpha(0) end

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
        local function ApplySlotFont(fontString, fontKey, sizeKey, defaultSize)
            local fPath = (LSM and addon.Config[fontKey]) and LSM:Fetch("font", addon.Config[fontKey])
            if not fPath then fPath = "Fonts\\FRIZQT__.TTF" end
            if not fontString then return end
            local font, size, flags = fontString:GetFont()
            addon.SafeSetFont(fontString, fPath, addon.Config[sizeKey] or defaultSize, flags or "")
        end

        ApplySlotFont(slot.MCP_Name, "ItemNameFont", "ItemNameSize", 12)
        ApplySlotFont(slot.MCP_iLvl, "ItemLevelFont", "ItemLevelSize", 16)
        ApplySlotFont(slot.MCP_Enchant, "EnchantFont", "EnchantSize", 9)
        ApplySlotFont(slot.MCP_Upgrade, "UpgradeLevelFont", "UpgradeLevelSize", 10)
    end

    local itemLink = GetInventoryItemLink("player", slot:GetID())
    -- On récupère les infos de l'objet
    if itemLink then
        local itemName, _, itemRarity, itemLevel, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemLink)
        local actualILvl = C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel

        if itemName then
            local displayName = itemName
            local maxLen = 33
            if addon.Config and addon.Config.ItemNameLength then maxLen = addon.Config.ItemNameLength end
            if slot:GetName() == "CharacterShirtSlot" or slot:GetName() == "CharacterTabardSlot" then
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
                -- Pour faire défiler le texte si le nom est trop long
                slot:HookScript("OnEnter", function(self)
                    if self.isHoverScrollActive then return end
                    if addon.Config and addon.Config.HoverScroll and self.MCP_FullName then
                        local maxL = addon.Config.ItemNameLength or 33
                        if self:GetName() == "CharacterShirtSlot" or self:GetName() == "CharacterTabardSlot" then
                            maxL = addon.Config.ItemNameLengthTabard or 23
                        end
                        local origChars = getUtf8Chars(self.MCP_FullName)

                        if #origChars > maxL then
                            self.isHoverScrollActive = true
                            self.hoverScrollIdx = 1
                            self.isWaitingAtEnd = false
                            self.mcpPauseTicks = 0 -- pas de pause au départ
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

                                -- Si on arrive à la fin du texte affichable
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
            slot.MCP_Name:SetShown(addon.Config.ShowItemName ~= false)

            -- Couleur de l'octogone selon la rareté
            if slot.MCP_OctagonLines then
                for _, line in ipairs(slot.MCP_OctagonLines) do
                    line:SetVertexColor(r, g, b)
                    line:Show()
                end
            end
        else
            slot.MCP_Name:SetText(addon.L["LOADING"])
        end

        if not addon.Config or addon.Config.ShowIlvl then
            slot.MCP_iLvl:SetText(actualILvl or "")
        else
            slot.MCP_iLvl:SetText("")
        end

        -- === ON REGARDE LES ENCHANTEMENTS ET AMELIORATIONS ===
        local tooltipData = C_TooltipInfo.GetInventoryItem("player", slot:GetID())
        local enchantText = ""
        local upgradeText = ""
        local rankAtlas = nil

        if tooltipData and tooltipData.lines then
            for i, line in ipairs(tooltipData.lines) do
                local text = line.leftText
                local currentLineAtlas = nil
                local currentLineTier = ""

                -- On cherche s'il y a un rang (1, 2, 3)
                local args = line["args"]
                if args then
                    for _, arg in ipairs(args) do
                        if arg.atlasName then
                            if arg.atlasName:find("Professions%-Icon%-Quality%-Tier1") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier1-Small:14:14|a"
                            elseif arg.atlasName:find("Professions%-Icon%-Quality%-Tier2") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier2-Small:14:14|a"
                            elseif arg.atlasName:find("Professions%-Icon%-Quality%-Tier3") then
                                currentLineAtlas = "|A:Professions-Icon-Quality-Tier3-Small:14:14|a"
                            end
                        end
                        if not text and arg.stringVal then text = arg.stringVal end
                    end
                end

                if text then
                    -- === ON NETTOIE LE TEXTE ===
                    -- Nettoie la couleur de l'infobulle
                    local cleanText = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                    cleanText = cleanText:match("^%s*(.-)%s*$") -- Trim

                    -- 1. On cherche s'il y a une amélioration (ex: 1/8)
                    local level = cleanText:match("(%d+/%d+)")
                    if level and not cleanText:match("%(%d+/%d+%)") then
                        -- On essaie de trouver le Track juste avant (Héros, Vétéran...)
                        -- Le pattern cherche le dernier mot avant le niveau
                        -- On ignore "d'amélioration" ou "Level"

                        local track = cleanText:match("([%aéèê]+)%s+" .. level)

                        -- Filtre les faux positifs (mots du préfixe)
                        if track and (track == addon.L["PATTERN_TRACK_EXCLUDE_1"] or track == addon.L["PATTERN_TRACK_EXCLUDE_2"] or track == addon.L["PATTERN_TRACK_EXCLUDE_3"]) then
                            track = nil
                        end

                        if track then
                            upgradeText = string.format(addon.L["UPGRADE_FORMAT"], track, level)
                        else
                            upgradeText = string.format(addon.L["UPGRADE_FORMAT_SHORT"], level)
                        end
                    end

                    -- 2. On cherche l'enchantement
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
                                -- Découpe le charabia avant l'enchantement
                                work = work:match(addon.L["PATTERN_ENCHANT_SHORT"] .. ".-[%s:]+(.+)$") or work
                            elseif isRenfort then
                                -- Prend tout après "Renfort..."
                                work = work:match(addon.L["PATTERN_RENFORT"] .. ".-[%s:]+(.+)$") or work
                            end

                            -- Retire l'espace du début qui dérange l'alignement
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

        -- On affiche "Non enchanté" si besoin
        local hasEnchantText = false
        local hasUpgradeText = false

        if enchantText ~= "" then
            -- Application de la MAP de traduction (ex: Coup critique -> Crit)
            for k, v in pairs(addon.L.STATS_MAP) do
                enchantText = enchantText:gsub(k, v)
                local cap = k:gsub("^%l", string.upper)
                enchantText = enchantText:gsub(cap, v)
                local low = k:gsub("^%u", string.lower)
                enchantText = enchantText:gsub(low, v)
            end

            -- Remplacement cosmétique final depuis la Locale
            if addon.L and addon.L.COSMETIC_MAP then
                for k, v in pairs(addon.L.COSMETIC_MAP) do
                    enchantText = enchantText:gsub(k, v)
                end
            end

            -- Découpe le nom avec | (garde uniquement les stats si un nom textuel précède les stats)
            if enchantText:find(" %| %+") then
                local firstPart = enchantText:match("^(.-) %| %+")
                if firstPart and not firstPart:find("%+") then
                    enchantText = enchantText:match(" %| (%+.+)$") or enchantText
                end
            end

            if not addon.Config or addon.Config.ShowEnchant then
                slot.MCP_Enchant:SetText(enchantText)
                slot.MCP_Enchant:SetTextColor(0.4, 1, 0.4) -- Vert
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
            -- Contrôle par slot via la config
            local id = slot:GetID()
            local configKey = "ShowNotEnchanted_" .. id
            local showIt = (addon.Config == nil or addon.Config[configKey] == nil) and (id ~= 4 and id ~= 19) or
                (addon.Config and addon.Config[configKey])
            if showIt and (not addon.Config or addon.Config.ShowEnchant) then
                slot.MCP_Enchant:SetText(addon.L["NOT_ENCHANTED"])
                slot.MCP_Enchant:SetTextColor(1, 0.2, 0.2)
                hasEnchantText = true
            else
                slot.MCP_Enchant:SetText("")
                hasEnchantText = false
            end
        end

        -- On nettoie le texte d'amélioration pour que ça soit propre
        if upgradeText:find(addon.L["PATTERN_UPGRADE_RAW"]) then
            upgradeText = upgradeText:gsub(addon.L["PATTERN_UPGRADE_RAW"], ""):gsub(":", ""):gsub("^%s+", ""):gsub(
                "%s+$", "")
            -- Reformatage propre
            upgradeText = "[" .. upgradeText:match("^%s*(.-)%s*$") .. "]"
            upgradeText = upgradeText:gsub("%[%s+", "[") -- Nettoie espace après crochet
        end

        if not addon.Config or addon.Config.ShowUpgrade then
            slot.MCP_Upgrade:SetText(upgradeText)
            hasUpgradeText = (upgradeText ~= "")
        else
            slot.MCP_Upgrade:SetText("")
            hasUpgradeText = false
        end

        -- === FONT APPLY WAS HERE ===

        -- === REAJUSTEMENT DU TEXTE ===
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
            if sName == "CharacterShirtSlot" or sName == "CharacterTabardSlot" then
                slot.MCP_Name:SetPoint("LEFT", slot, "RIGHT", 10 + nameOffsetX, nameOffsetY)
            else
                slot.MCP_Name:SetPoint("BOTTOMLEFT", slot, "TOPLEFT", nameOffsetX, 5 + nameOffsetY)
            end
        end

        -- Offset iLvl
        slot.MCP_iLvl:ClearAllPoints()
        slot.MCP_iLvl:SetPoint("CENTER", slot, "CENTER", ilvlOffsetX, ilvlOffsetY)

        -- Offsets Enchant/Upgrade
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

        -- Gemmes & Sockets vides
        -- On compte les sockets disponibles (Prismatic, etc.)
        local stats = C_Item.GetItemStats(itemLink)
        local numSockets = 0
        if (not addon.Config or addon.Config.ShowGems) and stats then
            for k, v in pairs(stats) do
                if string.find(k, "EMPTY_SOCKET_") then
                    numSockets = numSockets + v
                end
            end
        end

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
                _, gemLink = C_Item.GetItemGem(itemLink, i)
            end

            -- Mise à jour position
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
                    -- Slot vide - icon de gemme vide avec couleur plus lisible (Doré/Blanc)
                    gem.Texture:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
                    gem.Texture:SetVertexColor(1, 0.9, 0.4, 1.0) -- Doré brillant
                    gem.gemLink = nil
                    gem:Show()
                    if gem.Background then gem.Background:SetVertexColor(1, 1, 1, 0.1) end
                    if gem.Ring then
                        gem.Ring:Show(); gem.Ring:SetVertexColor(1, 1, 1, 0.3)
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
        slot.MCP_Bar:SetVertexColor(0.6, 0.6, 0.6) -- Gris visible
        -- Cache tout si vide
        slot.MCP_Name:SetText("")

        if slot.MCP_OctagonLines then
            for _, line in ipairs(slot.MCP_OctagonLines) do
                line:SetVertexColor(0.5, 0.5, 0.5) -- Gris plus clair pour être visible
                line:Show()
            end
        end

        -- On s'assure que le fond octogonal est là
        if slot.MCP_Background then
            slot.MCP_Background:SetColorTexture(0, 0, 0, 0.4) -- Plus clair
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

    -- Application finale de la transparence (si MCP s'ouvre depuis un clic de sac)
    if slot.MCP_UpdateSlotAlpha then
        slot.MCP_UpdateSlotAlpha()
    end
end

-- Change les infos basique (score mm, niveau, ilevel logo de classe)
function addon.Personnage.UpdateHeader(self)
    local _, classFile = UnitClass("player")
    if classFile then
        self.ClassIcon:SetTexture("Interface\\Icons\\ClassIcon_" .. classFile)
    end
    self.Name:SetText(UnitName("player"))
    local color = C_ClassColor.GetClassColor(classFile)
    if color then self.Name:SetTextColor(color.r, color.g, color.b) end
    self.Level:SetText(string.format(addon.L["LEVEL_FORMAT"], UnitLevel("player") or 0))

    -- Update Spec Icon
    local specIndex = GetSpecialization()
    if specIndex and self.SpecIcon then
        local _, _, _, specIcon = GetSpecializationInfo(specIndex)
        if specIcon then
            self.SpecIcon:SetTexture(specIcon)
            self.SpecIcon:Show()
        else
            self.SpecIcon:Hide()
        end
    elseif self.SpecIcon then
        self.SpecIcon:Hide()
    end
    local score = C_ChallengeMode.GetOverallDungeonScore() or 0
    if score > 0 then
        local c = C_ChallengeMode.GetDungeonScoreRarityColor(score) or { r = 1, g = 1, b = 1 }
        self.Score:SetText(string.format(addon.L["MYTHIC_PLUS_FORMAT"], score))
        self.Score:SetTextColor(c.r, c.g, c.b)
    else
        self.Score:SetText("")
    end

    if addon.Config then
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

        local function ApplyFont(fontString, fontKey, sizeKey, defaultSize)
            local fPath = (LSM and addon.Config[fontKey]) and LSM:Fetch("font", addon.Config[fontKey])
            if not fPath then fPath = "Fonts\\FRIZQT__.TTF" end
            if not fontString then return end
            local font, size, flags = fontString:GetFont()
            addon.SafeSetFont(fontString, fPath, addon.Config[sizeKey] or defaultSize, flags or "")
        end

        ApplyFont(self.Name, "HeaderPlayerNameFont", "HeaderPlayerNameSize", 16)
        ApplyFont(self.Level, "HeaderPlayerLevelFont", "HeaderPlayerLevelSize", 12)
        ApplyFont(self.Score, "HeaderMythicPlusFont", "HeaderMythicPlusSize", 22)
        if self.GVButton and self.GVButton.Text then
            ApplyFont(self.GVButton.Text, "HeaderGreatVaultFont", "HeaderGreatVaultSize", 14)
        end
    end

    -- Gestion du Bouton Grande Chambre Forte
    if self.GVButton then
        local hasRewards = C_WeeklyRewards.HasAvailableRewards()
        self.GVButton.hasReward = hasRewards
        if hasRewards then
            self.GVButton.Glow:Show()
            self.GVButton:SetBackdropBorderColor(1, 0.82, 0, 1)
            -- Fait clignoter
            if not self.GVButton.flashing then
                if self.GVButton.PulseAnim then
                    self.GVButton.PulseAnim:Play()
                end
                self.GVButton.flashing = true
            end
        else
            self.GVButton:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
            if self.GVButton.flashing then
                if self.GVButton.PulseAnim then
                    self.GVButton.PulseAnim:Stop()
                end
                self.GVButton.flashing = false
            end
            self.GVButton.Glow:Hide()
        end
    end
end

-- Met à jour visuellement les positions de tous les slots
function addon.Personnage:UpdateLayout()
    local C            = addon.CONST
    local MAIN_WIDTH   = C.MAIN_WIDTH
    local SLOT_START_Y = C.SLOT_START_Y
    local SLOT_STEP_Y  = C.SLOT_STEP_Y

    -- FORCE LA LARGEUR ET HAUTEUR
    CharacterFrame:SetWidth(C.TOTAL_WIDTH)
    CharacterFrame:SetHeight(C.HEIGHT)

    -- PAD_X: Espace entre le bord de la fenêtre et les slots
    -- Plus le chiffre est petit, plus c'est collé au bord.
    local PAD_X = 28

    -- Place les slots de GAUCHE (Tête, Cou...)
    for i, name in ipairs(C.LEFT_SLOTS) do
        local slot = _G[name]
        if slot then
            slot:ClearAllPoints()
            slot:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", PAD_X, SLOT_START_Y - ((i - 1) * SLOT_STEP_Y))
            slot:Show()
        end
    end

    -- Place les slots de DROITE (Gants, Ceinture...)
    for i, name in ipairs(C.RIGHT_SLOTS) do
        local slot = _G[name]
        if slot then
            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT", CharacterFrame, "TOPLEFT", MAIN_WIDTH - PAD_X,
                SLOT_START_Y - ((i - 1) * SLOT_STEP_Y))
            slot:Show()
        end
    end

    local WEAPON_GAP = C.WEAPON_GAP or 240
    local WEAPON_HEIGHT = C.WEAPON_HEIGHT or 60

    local mh = _G["CharacterMainHandSlot"]
    local oh = _G["CharacterSecondaryHandSlot"]

    if mh then
        mh:ClearAllPoints()
        -- Arme Main Droite (Décalée vers la GAUCHE du centre)
        mh:SetPoint("BOTTOM", CharacterFrame, "BOTTOMLEFT", (MAIN_WIDTH / 2) - WEAPON_GAP, WEAPON_HEIGHT)
        mh:SetSize(37, 37)      -- Force la taille carrée pour l'hexagone
        mh:SetNormalTexture("") -- Nettoyage ultime
        mh:Show()
    end
    if oh then
        oh:ClearAllPoints()
        -- Arme Main Gauche (Décalée vers la DROITE du centre)
        oh:SetPoint("BOTTOM", CharacterFrame, "BOTTOMLEFT", (MAIN_WIDTH / 2) + WEAPON_GAP, WEAPON_HEIGHT)
        oh:SetSize(37, 37)      -- Force la taille carrée pour l'hexagone
        oh:SetNormalTexture("") -- Nettoyage ultime
        oh:Show()
    end

    -- === MODELE 3D DU PERSO ===
    if CharacterModelScene then
        CharacterModelScene:ClearAllPoints()
        -- Centre le modèle
        CharacterModelScene:SetPoint("TOP", CharacterFrame, "TOPLEFT", MAIN_WIDTH / 2, C.MODEL_YH or -100)
        CharacterModelScene:SetSize(260, 420)
        CharacterModelScene:Show()

        -- Cache la barre de boutons sous le personnage
        if CharacterModelScene.ControlFrame then CharacterModelScene.ControlFrame:Hide() end

        -- Nettoie tous les fonds natifs du jeu
        if CharacterModelScene.SetBackdrop then CharacterModelScene:SetBackdrop(nil) end
        for _, region in pairs({ CharacterModelScene:GetRegions() }) do
            if region:IsObjectType("Texture") then
                region:SetAlpha(0)
                region:Hide()
            end
        end
        local charModel = _G["CharacterModelFrame"]
        if charModel then
            for _, r in pairs({ charModel:GetRegions() }) do
                if r:IsObjectType("Texture") then r:SetAlpha(0) end
            end
            if _G["CharacterModelFrameBackgroundBotLeft"] then _G["CharacterModelFrameBackgroundBotLeft"]:Hide() end
            if _G["CharacterModelFrameBackgroundBotRight"] then _G["CharacterModelFrameBackgroundBotRight"]:Hide() end
            if _G["CharacterModelFrameBackgroundTopLeft"] then _G["CharacterModelFrameBackgroundTopLeft"]:Hide() end
            if _G["CharacterModelFrameBackgroundTopRight"] then _G["CharacterModelFrameBackgroundTopRight"]:Hide() end
            if _G["CharacterModelFrameBackgroundOverlay"] then _G["CharacterModelFrameBackgroundOverlay"]:Hide() end
        end
    end
end

function addon.Personnage:Hide()
    if CharacterModelScene then CharacterModelScene:Hide() end
    local C = addon.CONST
    if not C then return end

    local allSlots = {}
    if C.LEFT_SLOTS then
        for _, n in ipairs(C.LEFT_SLOTS) do table.insert(allSlots, n) end
    end
    if C.RIGHT_SLOTS then
        for _, n in ipairs(C.RIGHT_SLOTS) do table.insert(allSlots, n) end
    end
    table.insert(allSlots, "CharacterMainHandSlot")
    table.insert(allSlots, "CharacterSecondaryHandSlot")

    for _, sn in ipairs(allSlots) do
        local slot = _G[sn]
        if slot then slot:Hide() end
    end
end

-- Écouteur d'événements pour forcer le rafraîchissement (notamment des gemmes) quand l'équipement est manipulé
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("SOCKET_INFO_UPDATE")
EventFrame:RegisterEvent("SOCKET_INFO_SUCCESS")
EventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
EventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
EventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "UNIT_INVENTORY_CHANGED" and arg1 ~= "player" then return end
    if not (CharacterFrame and CharacterFrame:IsShown()) then return end

    local function DoUpdate()
        local C = addon.CONST
        if not C then return end

        for _, name in ipairs(C.LEFT_SLOTS) do
            local slot = _G[name]
            if slot then addon.Personnage.UpdateSlot(slot) end
        end
        for _, name in ipairs(C.RIGHT_SLOTS) do
            local slot = _G[name]
            if slot then addon.Personnage.UpdateSlot(slot) end
        end
        local mh = _G["CharacterMainHandSlot"]
        local oh = _G["CharacterSecondaryHandSlot"]
        if mh then addon.Personnage.UpdateSlot(mh) end
        if oh then addon.Personnage.UpdateSlot(oh) end
    end

    DoUpdate()
    C_Timer.After(0.1, DoUpdate)
    C_Timer.After(0.5, DoUpdate)
end)

-- === HOOK : ILVL SUR EQUIPMENT FLYOUT ===
-- === HOOK : ILVL SUR EQUIPMENT FLYOUT ===
-- === HOOK : ILVL SUR EQUIPMENT FLYOUT ===
local flyoutHooked = false

local function GetActualIlvl(locNumObj)
    if not locNumObj then return nil end

    -- Cas 1: ItemLocation table (TWW/Midnight)
    if type(locNumObj) == "table" and locNumObj.IsValid and locNumObj:IsValid() then
        if C_Item.GetCurrentItemLevel then
            local lvl = C_Item.GetCurrentItemLevel(locNumObj)
            if lvl and lvl > 0 then return lvl end
        end
        local link = C_Item.GetItemLink(locNumObj)
        if link then
            local lvl = C_Item.GetDetailedItemLevelInfo(link)
            if lvl and lvl > 0 then return lvl end
            local _, _, _, ilvl = C_Item.GetItemInfo(link)
            if ilvl and ilvl > 0 then return ilvl end
        end
    end

    -- Cas 2: Number (Packed Location via EquipmentManager)
    if type(locNumObj) == "number" and locNumObj < 0xFFFFFFFD then
        local link = nil

        ---@diagnostic disable-next-line: deprecated
        if EquipmentManager_UnpackLocation then
            ---@diagnostic disable-next-line: deprecated
            local player, bank, bags, _, slot, bag = EquipmentManager_UnpackLocation(locNumObj)
            if bags and bag and slot then
                ---@diagnostic disable-next-line: undefined-global, deprecated
                link = C_Container and C_Container.GetContainerItemLink(bag, slot) or GetContainerItemLink(bag, slot)
            elseif bank and bag and slot then
                ---@diagnostic disable-next-line: undefined-global, deprecated
                link = C_Container and C_Container.GetContainerItemLink(bag, slot) or GetContainerItemLink(bag, slot)
            elseif player and slot then
                ---@diagnostic disable-next-line: deprecated
                link = GetInventoryItemLink("player", slot)
            end
        end

        if link then
            local lvl = C_Item.GetDetailedItemLevelInfo(link)
            if lvl and lvl > 0 then return lvl end
            local _, _, _, ilvl = C_Item.GetItemInfo(link)
            if ilvl and ilvl > 0 then return ilvl end
        end

        -- Ultime Fallback si on a juste l'ID via EquipmentManager
        ---@diagnostic disable-next-line: undefined-global
        if not link and EquipmentManager_GetItemInfoByLocation then
            ---@diagnostic disable-next-line: undefined-global
            local itemID = EquipmentManager_GetItemInfoByLocation(locNumObj)
            if itemID then
                local lvl = C_Item.GetDetailedItemLevelInfo(itemID)
                if lvl and lvl > 0 then return lvl end
                local _, _, _, ilvl = C_Item.GetItemInfo(itemID)
                if ilvl and ilvl > 0 then return ilvl end
            end
        end
    end
    return nil
end

local function UpdateFlyoutButton(button)
    if not button or not button:IsShown() then return end

    if not button.MCP_iLvl then
        local ilvl = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ilvl:SetDrawLayer("OVERLAY", 7)
        ilvl:SetPoint("CENTER", button, "CENTER", 0, 0)
        ilvl:SetTextColor(1, 1, 1)

        -- Ombre forte pour assurer la lisibilité par dessus l'icône
        ilvl:SetShadowColor(0, 0, 0, 1)
        ilvl:SetShadowOffset(1.5, -1.5)
        button.MCP_iLvl = ilvl
    end

    local actualILvl = nil

    -- Extraction robuste selon l'existance de GetItemLocation (TWW+) ou fallback
    local loc = nil
    if button.GetItemLocation then
        loc = button:GetItemLocation()
    end
    if not (loc and loc.IsValid and loc:IsValid()) then
        loc = button.location
    end

    actualILvl = GetActualIlvl(loc)

    if actualILvl and (not addon.Config or addon.Config.ShowFlyoutIlvl ~= false) then
        button.MCP_iLvl:SetText(actualILvl)
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        local fPath = (LSM and addon.Config and addon.Config.ItemLevelFont) and LSM:Fetch("font", addon.Config.ItemLevelFont) or
        "Fonts\\FRIZQT__.TTF"

        -- Augmente la taille de la police comparativement au réglage de base du menu d'options
        local fSize = (addon.Config and addon.Config.ItemLevelSize and (addon.Config.ItemLevelSize + 1)) or 16

        if addon.SafeSetFont then
            addon.SafeSetFont(button.MCP_iLvl, fPath, fSize, "OUTLINE")
        end
    else
        -- Filtre des boutons spéciaux d'équipements (Ignorer, Remettre au sac qui ont des ID > FFFFFFFD)
        if type(button.location) == "number" and button.location >= 0xFFFFFFFD then
            button.MCP_iLvl:SetText("")
        else
            -- Debugging ??: désactivé pour la prod où rendu propre selon config
            if not actualILvl and (not addon.Config or addon.Config.ShowFlyoutIlvl ~= false) then
                button.MCP_iLvl:SetText("??")
            else
                button.MCP_iLvl:SetText("")
            end
        end
    end
end

local function AttemptHookFlyout()
    if flyoutHooked then return true end

    ---@diagnostic disable-next-line: undefined-field
    if _G.EquipmentFlyout_UpdateItems then
        hooksecurefunc("EquipmentFlyout_UpdateItems", function()
            if not EquipmentFlyoutFrame or type(EquipmentFlyoutFrame.buttons) ~= "table" then return end

            for _, button in pairs(EquipmentFlyoutFrame.buttons) do
                if not button.MCP_FlyoutHooked then
                    button:HookScript("OnShow", UpdateFlyoutButton)
                    button.MCP_FlyoutHooked = true
                end
                UpdateFlyoutButton(button)
            end
        end)

        ---@diagnostic disable-next-line: undefined-field
        if _G.EquipmentFlyout_DisplayButton then
            hooksecurefunc("EquipmentFlyout_DisplayButton", function(button)
                UpdateFlyoutButton(button)
            end)
        end

        if EquipmentFlyoutFrame then
            EquipmentFlyoutFrame:HookScript("OnShow", function()
                if type(EquipmentFlyoutFrame.buttons) == "table" then
                    for _, button in pairs(EquipmentFlyoutFrame.buttons) do
                        UpdateFlyoutButton(button)
                    end
                end
            end)
        end

        flyoutHooked = true
        return true
    end
    return false
end

-- Essaie immédiatement
if not AttemptHookFlyout() then
    -- Si non trouvé (parfois lié au LoadOnDemand de certains éléments), on attend
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        if AttemptHookFlyout() then
            self:Disconnect()
        end
    end)
end
