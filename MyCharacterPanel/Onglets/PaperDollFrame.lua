-- Gère les 3 onglets sur le côté : Stats, Titres, Équipement
-- On ouvre les stats par défaut

local addonName, addon = ...
addon.Statistiques     = {}

local TAB_LOGOS        = {
    [1] = "Interface\\AddOns\\MyCharacterPanel\\logo\\stats.png",
    [2] = "Interface\\AddOns\\MyCharacterPanel\\logo\\titres.png",
    [3] = "Interface\\AddOns\\MyCharacterPanel\\logo\\equipement.png",
}

local TAB_NAMES        = {
    [1] = "TAB_STATS",
    [2] = "TAB_TITLES",
    [3] = "TAB_EQUIPMENT",
}

local PANE_WIDTH       = 210
local TAB_HEIGHT       = 40
local TAB_GAP          = 4
local TAB_OUTER_OFFSET = 4 -- espace entre le bord droit du CharacterFrame et les éléments
local TAB_OFFSET_Y     = 0 -- aligné tout en haut du CharacterFrame

local COLOR_ACTIVE     = { r = 1, g = 0.85, b = 0.4 }
local COLOR_INACTIVE   = { r = 0.55, g = 0.55, b = 0.55 }

local isMCPActive      = false
local panesHooked      = false

-- Cherche une police dans la bibliothèque SharedMedia
local function GetLSMFontPath(fontKey)
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    local path = (LSM and fontKey) and LSM:Fetch("font", fontKey)
    return path or "Fonts\\FRIZQT__.TTF"
end

-- Pour changer le look d'un onglet sur le côté
local function InitTabSkin(tab, index)
    if tab.MCP_Skinned then return end

    for _, region in pairs({ tab:GetRegions() }) do
        if region:IsObjectType("Texture") then region:SetAlpha(0) end
    end
    if tab.SetNormalTexture then tab:SetNormalTexture("") end
    if tab.SetPushedTexture then tab:SetPushedTexture("") end
    if tab.SetHighlightTexture then tab:SetHighlightTexture("") end
    if tab.SetDisabledTexture then tab:SetDisabledTexture("") end

    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(tab)
    bg:SetColorTexture(0.06, 0.06, 0.06, 0.95)
    tab.MCP_BG = bg

    local border = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    border:SetAllPoints(tab)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    border:SetFrameLevel(tab:GetFrameLevel() + 1)
    tab.MCP_Border = border

    local logo = tab:CreateTexture(nil, "ARTWORK")
    logo:SetSize(24, 24)
    logo:SetPoint("LEFT", tab, "LEFT", 12, 0)
    logo:SetTexture(TAB_LOGOS[index])
    logo:SetVertexColor(COLOR_INACTIVE.r, COLOR_INACTIVE.g, COLOR_INACTIVE.b)
    tab.MCP_Logo = logo

    local text = tab:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    text:SetText(addon.L[TAB_NAMES[index]] or "")
    text:SetPoint("CENTER", tab, "CENTER", 10, 0)
    tab.MCP_Text = text

    tab:SetHeight(TAB_HEIGHT)

    local hl = tab:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(tab)
    hl:SetColorTexture(1, 1, 1, 0.07)
    hl:SetBlendMode("ADD")

    -- Barre verticale d'onglet actif
    local indicator = tab:CreateTexture(nil, "OVERLAY")
    indicator:SetWidth(4)
    indicator:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, -4)
    indicator:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 4)
    indicator:SetColorTexture(COLOR_ACTIVE.r, COLOR_ACTIVE.g, COLOR_ACTIVE.b, 1)
    indicator:Hide()
    tab.MCP_Indicator = indicator

    tab.MCP_Skinned   = true
    tab.MCP_Index     = index
end

local function UpdateTabState(tab, isActive)
    if not tab or not tab.MCP_Skinned then return end
    tab.MCP_IsActive = isActive
    if isActive then
        tab.MCP_Logo:SetVertexColor(COLOR_ACTIVE.r, COLOR_ACTIVE.g, COLOR_ACTIVE.b)
        tab.MCP_Text:SetTextColor(COLOR_ACTIVE.r, COLOR_ACTIVE.g, COLOR_ACTIVE.b)
        tab.MCP_Border:SetBackdropBorderColor(COLOR_ACTIVE.r, COLOR_ACTIVE.g, COLOR_ACTIVE.b, 0.9)
        tab.MCP_BG:SetColorTexture(0.12, 0.12, 0.12, 0.95) -- Gris neutre comme Personnage.lua
        tab.MCP_Indicator:Show()
    else
        tab.MCP_Logo:SetVertexColor(COLOR_INACTIVE.r, COLOR_INACTIVE.g, COLOR_INACTIVE.b)
        tab.MCP_Text:SetTextColor(COLOR_INACTIVE.r, COLOR_INACTIVE.g, COLOR_INACTIVE.b)
        tab.MCP_Border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        tab.MCP_BG:SetColorTexture(0.06, 0.06, 0.06, 0.95)
        tab.MCP_Indicator:Hide()
    end
end


-- Pour savoir quel onglet est actuellement affiché (Stats, Titres ou Stuff)
local function GetActiveSidebarTab()
    if CharacterStatsPane and CharacterStatsPane:IsShown() then return 1 end
    if PaperDollFrame and PaperDollFrame.TitleManagerPane and PaperDollFrame.TitleManagerPane:IsShown() then return 2 end
    if PaperDollFrame and PaperDollFrame.EquipmentManagerPane and PaperDollFrame.EquipmentManagerPane:IsShown() then return 3 end
    return 1
end

local function RefreshTabStates()
    if not isMCPActive then return end
    local active = GetActiveSidebarTab()
    for i = 1, 3 do
        local t = _G["PaperDollSidebarTab" .. i]
        if t and t.MCP_Skinned then
            UpdateTabState(t, i == active)
        end
    end
end

-- Animation pour le menu qui s'ouvre style accordéon
local animFrame = CreateFrame("Frame")
animFrame:Hide()
local animTargets = {}

local function Lerp(startV, endV, amt)
    return startV + (endV - startV) * amt
end

animFrame:SetScript("OnUpdate", function(self, elapsed)
    local allDone = true
    local speed = elapsed * 15

    for frame, target in pairs(animTargets) do
        if not frame:IsShown() then
            animTargets[frame] = nil
        else
            local frameDone = true

            if target.y then
                local currentY = frame.MCP_CurrentY
                if not currentY then
                    _, _, _, _, currentY = frame:GetPoint()
                    currentY = currentY or 0
                end

                if math.abs(target.y - currentY) < 0.5 then
                    frame.MCP_CurrentY = target.y
                    frame.MCP_SettingPos = true
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET, target.y)
                    frame.MCP_SettingPos = false
                    target.y = nil
                else
                    local newY = Lerp(currentY, target.y, speed)
                    frame.MCP_CurrentY = newY
                    frame.MCP_SettingPos = true
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET, newY)
                    frame.MCP_SettingPos = false
                    frameDone = false
                end
            end

            if target.alpha then
                local currentAlpha = frame:GetAlpha()
                if math.abs(target.alpha - currentAlpha) < 0.05 then
                    frame:SetAlpha(target.alpha)
                    target.alpha = nil
                else
                    frame:SetAlpha(Lerp(currentAlpha, target.alpha, speed))
                    frameDone = false
                end
            end

            if frameDone then
                animTargets[frame] = nil
            else
                allDone = false
            end
        end
    end
    if allDone then self:Hide() end
end)

-- Range les boutons et les fenêtres les uns sous les autres (accordéon)
local updatingLayout = false
local function UpdateSidebarLayout()
    if not isMCPActive or updatingLayout then return end
    updatingLayout = true

    local activeTabIdx = GetActiveSidebarTab()
    local currentY = TAB_OFFSET_Y
    local TAB_ORDER = { 1, 3, 2 } -- L'ordre : Stats (1), Stuff (3), Titres (2)

    for _, i in ipairs(TAB_ORDER) do
        local tab = _G["PaperDollSidebarTab" .. i]
        if tab then
            tab:SetSize(PANE_WIDTH, TAB_HEIGHT)
            tab:SetParent(CharacterFrame)
            tab:SetFrameStrata("HIGH")
            tab:Show()

            if not tab.MCP_CurrentY then
                tab.MCP_CurrentY = currentY
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET, currentY)
            else
                animTargets[tab] = animTargets[tab] or {}
                animTargets[tab].y = currentY
                animFrame:Show()
            end

            currentY = currentY - TAB_HEIGHT - TAB_GAP

            if i == activeTabIdx then
                local pane
                if i == 1 then
                    pane = CharacterStatsPane
                elseif i == 2 then
                    pane = PaperDollFrame.TitleManagerPane
                elseif i == 3 then
                    pane = PaperDollFrame.EquipmentManagerPane
                end

                if pane and pane:IsShown() and pane.MCP_Skinned then
                    pane.MCP_SettingPos = true
                    pane:SetWidth(PANE_WIDTH)

                    if not pane.MCP_CurrentY then
                        pane.MCP_CurrentY = currentY
                        pane:ClearAllPoints()
                        pane:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET, currentY)
                    else
                        animTargets[pane] = animTargets[pane] or {}
                        animTargets[pane].y = currentY

                        -- Glissement fluide (Fade In)
                        if pane.MCP_LastState ~= "OPEN" then
                            pane:SetAlpha(0)
                            animTargets[pane].alpha = 1
                            pane.MCP_CurrentY = currentY + 30
                            pane:ClearAllPoints()
                            pane:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET, currentY + 30)
                        end
                        animFrame:Show()
                    end

                    pane.MCP_SettingPos = false
                    pane.MCP_LastState = "OPEN"

                    local h = pane:GetHeight() or 150
                    currentY = currentY - h - TAB_GAP
                end
            end
        end
    end

    -- On reset l'état interne pour que l'anim se relance la prochaine fois
    for i = 1, 3 do
        if i ~= activeTabIdx then
            local p
            if i == 1 then
                p = CharacterStatsPane
            elseif i == 2 then
                p = PaperDollFrame.TitleManagerPane
            elseif i == 3 then
                p = PaperDollFrame.EquipmentManagerPane
            end
            if p then p.MCP_LastState = "CLOSED" end
        end
    end

    updatingLayout = false
end

-- Positionne la fenêtre active du menu accordéon
local function ApplyPanePosition(pane)
    if not pane or not isMCPActive then return end
    if pane.MCP_SettingPos then return end

    local C = addon.CONST
    pane.MCP_SettingPos = true

    if pane:GetParent() ~= CharacterFrame then
        pane:SetParent(CharacterFrame)
    end

    local paneWidth = PANE_WIDTH
    pane:SetWidth(paneWidth)

    -- On fabrique le fond de la fenêtre de stats/titres/stuff
    if not pane.MCP_BG then
        -- Cache les contours moches natifs du jeu
        if pane.NineSlice then pane.NineSlice:SetAlpha(0) end
        if pane.Background then pane.Background:SetAlpha(0) end
        if pane.Border then pane.Border:SetAlpha(0) end
        if pane.ScrollBox and pane.ScrollBox.NineSlice then pane.ScrollBox.NineSlice:SetAlpha(0) end

        -- Cache le reste
        for _, r in pairs({ pane:GetRegions() }) do
            if r:IsObjectType("Texture") and r ~= pane.MCP_BG then
                r:SetAlpha(0)
            end
        end

        -- Cache les contours internes
        for _, child in pairs({ pane:GetChildren() }) do
            local name = child:GetName() or ""
            if (string.find(name, "Inset") or child.NineSlice) and child ~= pane.ScrollBox then
                child:SetAlpha(0)
            end
        end

        local bg = pane:CreateTexture(nil, "BACKGROUND", nil, -1)
        bg:SetAllPoints(pane)
        bg:SetColorTexture(0.12, 0.12, 0.12, 1) -- Moins sombre que 0.08
        pane.MCP_BG = bg

        local border = CreateFrame("Frame", nil, pane, "BackdropTemplate")
        border:SetAllPoints(pane)
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        pane.MCP_PaneBorder = border
    end

    -- On ajuste la hauteur automatiquement après un court délai
    C_Timer.After(0.01, function()
        if not pane or not pane:IsShown() then return end

        local targetHeight = CharacterFrame:GetHeight() - 30

        if pane == CharacterStatsPane then
            local maxY, minY = -9999, 9999
            for _, child in pairs({ pane:GetChildren() }) do
                -- On force la largeur pour que la stat touche bien le bord droit
                if child:IsShown() and child.SetWidth then
                    child:SetWidth(paneWidth - 8)
                    -- S'assurer que le fond brown natif de la stat s'étende
                    if child.Background then
                        child.Background:ClearAllPoints()
                        child.Background:SetPoint("LEFT", child, "LEFT", 4, 0)
                        child.Background:SetPoint("RIGHT", child, "RIGHT", -4, 0)
                    end
                end

                if child ~= pane.MCP_DurabilityStat and child:IsShown() and child:GetTop() and child:GetBottom() then
                    -- On ne prend que les lignes qui sont vraiment affichées
                    if child.Value or child.Label or child.Title or child.leftGrad then
                        local t, b = child:GetTop(), child:GetBottom()
                        if t > maxY then maxY = t end
                        if b < minY then minY = b end
                    end
                end
            end
            if maxY > -9999 and minY < 9999 then
                targetHeight = (maxY - minY) +
                    40 -- Taille adaptée pour intégrer le pied de page proprement sans marge démesurée
            else
                targetHeight = 350
            end
        elseif pane.ScrollBox then
            -- Recalcule la hauteur et la limite pour pas que ça sorte de l'écran
            local function UpdateScrollHeight()
                if not pane or not pane:IsShown() then return end
                local maxAllowed = CharacterFrame:GetHeight() - 30
                local targetH = 150

                if pane == PaperDollFrame.EquipmentManagerPane then
                    local count = C_EquipmentSet and (C_EquipmentSet.GetNumEquipmentSets() + 1) or 1
                    targetH = (count * 46) + 79 -- Ajusté car on a remonté le tout de 16 pixels
                else
                    -- Pour les titres
                    local dp = pane.ScrollBox:GetDataProvider()
                    local count = dp and dp:GetSize() or 0
                    targetH = (count * 22) + 60
                end
                -- On plafonne pour éviter de déborder si la liste est immense (ex: Titres)
                local maxAllowedPaneHeight = maxAllowed - (3 * TAB_HEIGHT) - (4 * TAB_GAP)
                if pane ~= CharacterStatsPane then
                    maxAllowedPaneHeight = math.min(maxAllowedPaneHeight, maxAllowed / 1.5)
                end
                pane:SetHeight(math.min(math.max(targetH, 150), maxAllowedPaneHeight))
                UpdateSidebarLayout() -- Update de l'accordéon
            end

            -- Si on a pas encore ajouté le hook d'actualisation fluide de la taille, on le fait
            if not pane.MCP_HeightHooked then
                pane.MCP_HeightHooked = true
                -- Utilise un hook sur une mise à jour d'évènement pour réajuster en temps réel
                if pane == PaperDollFrame.EquipmentManagerPane then
                    if _G["PaperDollEquipmentManagerPane_Update"] then
                        hooksecurefunc("PaperDollEquipmentManagerPane_Update", UpdateScrollHeight)
                    elseif pane.Update then
                        hooksecurefunc(pane, "Update", UpdateScrollHeight)
                    end
                elseif pane == PaperDollFrame.TitleManagerPane then
                    if _G["PaperDollTitlesPane_Update"] then
                        hooksecurefunc("PaperDollTitlesPane_Update", UpdateScrollHeight)
                    elseif pane.Update then
                        hooksecurefunc(pane, "Update", UpdateScrollHeight)
                    end
                end
            end

            -- Exécution immédiate et avec délai pour l'asynchrone
            UpdateScrollHeight()
            C_Timer.After(0.05, UpdateScrollHeight)
            targetHeight = pane:GetHeight()

            -- Masquer les décorations natives en gardant l'intégrité du ScrollBox
            if pane.ScrollBox.NineSlice then pane.ScrollBox.NineSlice:SetAlpha(0) end
            for _, r in pairs({ pane.ScrollBox:GetRegions() }) do
                r:SetAlpha(0)
            end
        end

        local maxAllowedPaneHeight = CharacterFrame:GetHeight() - 30 - (3 * TAB_HEIGHT) - (4 * TAB_GAP)
        pane:SetHeight(math.min(math.max(targetHeight, 80), maxAllowedPaneHeight))
        UpdateSidebarLayout()
    end)

    -- On force la taille de la liste pour les titres et réputations
    if pane.ScrollBox then
        pane.ScrollBox:ClearAllPoints()

        if pane == PaperDollFrame.EquipmentManagerPane then
            -- Marge haute ajustée
            pane.ScrollBox:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -36)
            pane.ScrollBox:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -30, 15)

            if PaperDollFrame.EquipmentManagerPane.EquipSet then
                PaperDollFrame.EquipmentManagerPane.EquipSet:SetParent(pane)
                PaperDollFrame.EquipmentManagerPane.EquipSet.MCP_SettingPos = true
                PaperDollFrame.EquipmentManagerPane.EquipSet:ClearAllPoints()
                PaperDollFrame.EquipmentManagerPane.EquipSet:SetPoint("TOPLEFT", pane, "TOPLEFT", 14, -10)
                PaperDollFrame.EquipmentManagerPane.EquipSet.MCP_SettingPos = false
                PaperDollFrame.EquipmentManagerPane.EquipSet:SetSize(80, 24)
            end
            if PaperDollFrame.EquipmentManagerPane.SaveSet then
                PaperDollFrame.EquipmentManagerPane.SaveSet:SetParent(pane)
                PaperDollFrame.EquipmentManagerPane.SaveSet.MCP_SettingPos = true
                PaperDollFrame.EquipmentManagerPane.SaveSet:ClearAllPoints()
                PaperDollFrame.EquipmentManagerPane.SaveSet:SetPoint("LEFT", PaperDollFrame.EquipmentManagerPane
                    .EquipSet, "RIGHT", 4, 0)
                PaperDollFrame.EquipmentManagerPane.SaveSet.MCP_SettingPos = false
                PaperDollFrame.EquipmentManagerPane.SaveSet:SetSize(86, 24)
            end
        else
            -- Panneau des Titres
            pane.ScrollBox:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -8)
            pane.ScrollBox:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -30, 15)
        end

        -- On fixe la barre de défilement sur le côté de notre liste
        if pane.ScrollBar then
            pane.ScrollBar:ClearAllPoints()
            pane.ScrollBar:SetPoint("TOPLEFT", pane.ScrollBox, "TOPRIGHT", 5, 0)
            pane.ScrollBar:SetPoint("BOTTOMLEFT", pane.ScrollBox, "BOTTOMRIGHT", 5, 0)
        end
    end

    pane.MCP_SettingPos = false
end

-- On lance la mise à jour des positions des onglets
local function PositionTabs()
    UpdateSidebarLayout()
end

-- ========================================================
-- DRAG & DROP DES STATISTIQUES
-- ========================================================
local ALL_STATS = {}
local statsOrderInitialized = false
local draggedStatKey = nil
local dropLine = nil
local dropIsBefore = false

local function RebuildPaperDollCategories()
    if not MCP_StatsOrder then return end
    for catIndex = 1, #MCP_StatsOrder do
        if PAPERDOLL_STATCATEGORIES[catIndex] then
            PAPERDOLL_STATCATEGORIES[catIndex].stats = {}
            for _, statId in ipairs(MCP_StatsOrder[catIndex]) do
                if ALL_STATS[statId] then
                    table.insert(PAPERDOLL_STATCATEGORIES[catIndex].stats, ALL_STATS[statId])
                end
            end
        end
    end
end

local function OnStatDragStart(self)
    draggedStatKey = self.mcp_statKey
    self:SetAlpha(0.5)

    if not dropLine then
        dropLine = CharacterStatsPane:CreateTexture(nil, "OVERLAY")
        dropLine:SetColorTexture(0.3, 0.8, 1, 0.8) -- Bleu clair visible pour D&D
        dropLine:SetHeight(4)                      -- Plus épais
        dropLine:Hide()
    end
end

local function OnStatDragStop(self)
    self:SetAlpha(1)
    if dropLine then dropLine:Hide() end
    if not draggedStatKey then return end

    local dropCatIndex = nil
    local dropStatKey = nil

    if CharacterStatsPane.AttributesCategory:IsMouseOver() then
        dropCatIndex = 1
    elseif CharacterStatsPane.EnhancementsCategory:IsMouseOver() then
        dropCatIndex = 2
    else
        for sf in CharacterStatsPane.statsFramePool:EnumerateActive() do
            if sf:IsMouseOver() and sf ~= self then
                dropStatKey = sf.mcp_statKey
                break
            end
        end
    end

    if dropCatIndex or dropStatKey then
        -- On nettoie l'ordre pour éviter que la stat apparaîsse deux fois par erreur
        for c = 1, 2 do
            if MCP_StatsOrder[c] then
                for i = #MCP_StatsOrder[c], 1, -1 do
                    if MCP_StatsOrder[c][i] == draggedStatKey then
                        table.remove(MCP_StatsOrder[c], i)
                    end
                end
            end
        end

        local inserted = false
        if dropCatIndex then
            table.insert(MCP_StatsOrder[dropCatIndex], 1, draggedStatKey)
            inserted = true
        elseif dropStatKey and dropStatKey ~= draggedStatKey then
            for c = 1, 2 do
                if MCP_StatsOrder[c] then
                    for i, st in ipairs(MCP_StatsOrder[c]) do
                        if st == dropStatKey then
                            local targetI = dropIsBefore and i or (i + 1)
                            table.insert(MCP_StatsOrder[c], targetI, draggedStatKey)
                            inserted = true
                            break
                        end
                    end
                    if inserted then break end
                end
            end
        end

        if not inserted then
            -- Si on a un bug d'insertion, on la met à la fin par sécurité
            table.insert(MCP_StatsOrder[2], draggedStatKey)
        end

        -- Nettoyage complet : retirer tous les doublons de MCP_StatsOrder
        local seen = {}
        for c = 1, 2 do
            if MCP_StatsOrder[c] then
                for i = #MCP_StatsOrder[c], 1, -1 do
                    local st = MCP_StatsOrder[c][i]
                    if seen[st] then
                        table.remove(MCP_StatsOrder[c], i)
                    else
                        seen[st] = true
                    end
                end
            end
        end

        RebuildPaperDollCategories()
        if _G["PaperDollFrame_UpdateStats"] then
            _G["PaperDollFrame_UpdateStats"]()
        elseif CharacterStatsPane and CharacterStatsPane.UpdateStats then
            CharacterStatsPane:UpdateStats()
        end
    end
    draggedStatKey = nil
    dropIsBefore = false
end

local function InitStatsDragDrop()
    if statsOrderInitialized then return end
    statsOrderInitialized = true

    -- On ajoute la vitesse de course (Movespeed) de base car Blizzard l'oublie
    if PAPERDOLL_STATCATEGORIES[2] then
        local hasMoveSpeed = false
        for _, obj in ipairs(PAPERDOLL_STATCATEGORIES[2].stats) do
            if obj.stat == "MOVESPEED" then hasMoveSpeed = true end
        end
        if not hasMoveSpeed then
            table.insert(PAPERDOLL_STATCATEGORIES[2].stats, { stat = "MOVESPEED", hideAt = 0 })
        end
    end

    for catIndex, catList in ipairs(PAPERDOLL_STATCATEGORIES) do
        for _, obj in ipairs(catList.stats) do
            ALL_STATS[obj.stat] = obj
        end
    end

    if type(MCP_StatsOrder) ~= "table" then
        MCP_StatsOrder = { {}, {} }
        for catIndex, catList in ipairs(PAPERDOLL_STATCATEGORIES) do
            for _, obj in ipairs(catList.stats) do
                table.insert(MCP_StatsOrder[catIndex], obj.stat)
            end
        end
    end

    for c = 1, 2 do
        if MCP_StatsOrder[c] then
            for i = #MCP_StatsOrder[c], 1, -1 do
                if not ALL_STATS[MCP_StatsOrder[c][i]] then
                    table.remove(MCP_StatsOrder[c], i)
                end
            end
        end
    end

    local usedStats = {}
    for c = 1, 2 do
        if MCP_StatsOrder[c] then
            for _, st in ipairs(MCP_StatsOrder[c]) do
                usedStats[st] = true
            end
        end
    end
    for statId, _ in pairs(ALL_STATS) do
        if not usedStats[statId] then
            table.insert(MCP_StatsOrder[2], statId)
        end
    end

    RebuildPaperDollCategories()

    local dragFrame = CreateFrame("Frame", nil, CharacterStatsPane)
    dragFrame:SetScript("OnUpdate", function()
        if draggedStatKey and dropLine then
            local targetFound = false

            local function IsTopHalf(frame)
                local _, y = GetCursorPosition()
                local scale = frame:GetEffectiveScale()
                local top = frame:GetTop() * scale
                local bottom = frame:GetBottom() * scale
                return y > (top + bottom) / 2
            end

            if CharacterStatsPane.AttributesCategory:IsMouseOver() then
                dropLine:ClearAllPoints()
                dropLine:SetPoint("TOPLEFT", CharacterStatsPane.AttributesCategory, "BOTTOMLEFT", 10, -2)
                dropLine:SetPoint("TOPRIGHT", CharacterStatsPane.AttributesCategory, "BOTTOMRIGHT", -10, -2)
                targetFound = true
                dropIsBefore = false
            elseif CharacterStatsPane.EnhancementsCategory:IsMouseOver() then
                dropLine:ClearAllPoints()
                dropLine:SetPoint("TOPLEFT", CharacterStatsPane.EnhancementsCategory, "BOTTOMLEFT", 10, -2)
                dropLine:SetPoint("TOPRIGHT", CharacterStatsPane.EnhancementsCategory, "BOTTOMRIGHT", -10, -2)
                targetFound = true
                dropIsBefore = false
            else
                for sf in CharacterStatsPane.statsFramePool:EnumerateActive() do
                    if sf:IsMouseOver() and sf.mcp_statKey ~= draggedStatKey then
                        dropIsBefore = IsTopHalf(sf)
                        dropLine:ClearAllPoints()
                        if dropIsBefore then
                            dropLine:SetPoint("TOPLEFT", sf, "TOPLEFT", 10, 2)
                            dropLine:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -10, 2)
                        else
                            dropLine:SetPoint("TOPLEFT", sf, "BOTTOMLEFT", 10, -2)
                            dropLine:SetPoint("TOPRIGHT", sf, "BOTTOMRIGHT", -10, -2)
                        end
                        targetFound = true
                        break
                    end
                end
            end

            if targetFound then
                dropLine:Show()
            else
                dropLine:Hide()
            end
        end
    end)

    for statKey, statInfo in pairs(PAPERDOLL_STATINFO) do
        local orig_updateFunc = statInfo.updateFunc
        if orig_updateFunc then
            statInfo.updateFunc = function(statFrame, unit)
                statFrame.mcp_statKey = statKey

                if not statFrame.mcp_dragHooked then
                    statFrame:EnableMouse(true)
                    statFrame:SetMovable(true)
                    statFrame:RegisterForDrag("LeftButton")
                    statFrame:SetScript("OnDragStart", OnStatDragStart)
                    statFrame:SetScript("OnDragStop", OnStatDragStop)
                    statFrame.mcp_dragHooked = true
                end

                orig_updateFunc(statFrame, unit)

                -- On évite un crash Blizzard sur les ancrages (bug infini possible sinon)

                -- Au lieu de re-calculer les points, on se contente de forcer la largeur du composant entier.
                statFrame:SetWidth(PANE_WIDTH - 8)

                -- Justifie le texte à gauche pour que ça soit plus propre
                local slPath = GetLSMFontPath(addon.Config and addon.Config.AccordionStatLabelFont)
                local slSize = (addon.Config and addon.Config.AccordionStatLabelSize) or 12

                if statFrame.Label then
                    statFrame.Label:SetWidth(120)
                    statFrame.Label:SetJustifyH("LEFT")
                    addon.SafeSetFont(statFrame.Label, slPath, slSize, "")

                    if statKey == "MOVESPEED" and addon.L["STAT_MOVESPEED"] then
                        statFrame.Label:SetText(format(STAT_FORMAT, addon.L["STAT_MOVESPEED"]))
                    end
                end
                if statFrame.Value then
                    addon.SafeSetFont(statFrame.Value, slPath, slSize, "")
                end
            end
        end
    end

    if _G["PaperDollFrame_UpdateStats"] then
        _G["PaperDollFrame_UpdateStats"]()
    elseif CharacterStatsPane and CharacterStatsPane.UpdateStats then
        CharacterStatsPane:UpdateStats()
    end
end

-- Remet les statistiques dans l'ordre d'origine de l'addon
function addon.Personnage:ResetStatOrder()
    MCP_StatsOrder = {
        {
            "STRENGTH",
            "AGILITY",
            "INTELLECT",
            "STAMINA",
            "ARMOR"
        },
        {
            "CRITCHANCE",
            "HASTE",
            "MASTERY",
            "VERSATILITY",
            "LIFESTEAL",
            "AVOIDANCE",
            "DODGE",
            "PARRY",
            "BLOCK",
            "SPEED",
            "STAGGER",
            "MOVESPEED"
        }
    }
    statsOrderInitialized = false
    InitStatsDragDrop()
    if _G["PaperDollFrame_UpdateStats"] then
        _G["PaperDollFrame_UpdateStats"]()
    elseif CharacterStatsPane and CharacterStatsPane.UpdateStats then
        CharacterStatsPane:UpdateStats()
    end
end

-- ========================================================

-- Nettoie le panneau des statistiques natif de Blizzard
local function InitStatsPaneSkin()
    if CharacterStatsPane and not CharacterStatsPane.MCP_Skinned then
        InitStatsDragDrop()

        if CharacterStatsPane.ClassBackground then
            CharacterStatsPane.ClassBackground:Hide()
        end
        for _, region in pairs({ CharacterStatsPane:GetRegions() }) do
            if region:IsObjectType("Texture") then region:SetAlpha(0) end
        end

        local categories = {
            CharacterStatsPane.ItemLevelCategory,
            CharacterStatsPane.AttributesCategory,
            CharacterStatsPane.EnhancementsCategory
        }
        for _, cat in ipairs(categories) do
            if cat and cat.Background then
                cat.Background:SetAlpha(0)
            end
            if cat and cat.Title then
                cat.Title:SetTextColor(1, 0.85, 0.4)
                cat.Title:SetShadowColor(0, 0, 0, 1)
                cat.Title:SetShadowOffset(1, -1)

                -- Ajout d'un ruban pour habiller les titres (sur toute la largeur)
                if not cat.MCP_Ribbon then
                    local bg = cat:CreateTexture(nil, "BACKGROUND")
                    bg:SetPoint("LEFT", cat, "LEFT", 4, 0)
                    bg:SetPoint("RIGHT", cat, "RIGHT", -4, 0)
                    bg:SetHeight(24)               -- Plus haut
                    bg:SetColorTexture(0, 0, 0, 0) -- Dégradé retiré à la demande de l'utilisateur
                    cat.MCP_Ribbon = bg

                    local line = cat:CreateTexture(nil, "BORDER")
                    line:SetPoint("BOTTOMLEFT", bg, "BOTTOMLEFT", 0, 0)
                    line:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 0, 0)
                    line:SetHeight(2)                      -- Ligne plus épaisse
                    line:SetColorTexture(0.7, 0.5, 0.1, 1) -- Doré vibrant
                end
            end
        end

        local fontChildren = { CharacterStatsPane:GetChildren() }
        for _, child in pairs(fontChildren) do
            if child.Label and child.Value then
                if child.Label:GetText() and child.Label:GetText() == STAT_AVERAGE_ITEM_LEVEL then
                    -- ItemLevel géré par ApplyAccordionFonts
                else
                    child.Label:SetFontObject("GameFontNormal")
                    child.Value:SetFontObject("GameFontHighlight")
                end
            end
        end

        if CharacterStatsPane.ItemLevelFrame then
            CharacterStatsPane.ItemLevelFrame:SetHeight(55)

            if CharacterStatsPane.ItemLevelFrame.Value then
                CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(1, 1, 1)
                CharacterStatsPane.ItemLevelFrame.Value:ClearAllPoints()
                CharacterStatsPane.ItemLevelFrame.Value:SetPoint("CENTER", CharacterStatsPane.ItemLevelFrame, "CENTER", 0,
                    2)
            end
            if CharacterStatsPane.ItemLevelFrame.Background then
                CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
                CharacterStatsPane.ItemLevelFrame.Background:Hide()
            end
        end

        CharacterStatsPane.MCP_Skinned = true
    end

    if PaperDollFrame and PaperDollFrame.TitleManagerPane and not PaperDollFrame.TitleManagerPane.MCP_Skinned then
        for _, region in pairs({ PaperDollFrame.TitleManagerPane:GetRegions() }) do
            if region:IsObjectType("Texture") then region:SetAlpha(0) end
        end
        PaperDollFrame.TitleManagerPane.MCP_Skinned = true
    end

    if PaperDollFrame and PaperDollFrame.EquipmentManagerPane and not PaperDollFrame.EquipmentManagerPane.MCP_Skinned then
        for _, region in pairs({ PaperDollFrame.EquipmentManagerPane:GetRegions() }) do
            if region:IsObjectType("Texture") then region:SetAlpha(0) end
        end

        -- Bouton Equiper Stylisé
        if PaperDollFrame.EquipmentManagerPane.EquipSet and not PaperDollFrame.EquipmentManagerPane.EquipSet.MCP_BgSkin then
            PaperDollFrame.EquipmentManagerPane.EquipSet:SetFrameLevel(PaperDollFrame.EquipmentManagerPane:GetFrameLevel() +
                2)
            if PaperDollFrame.EquipmentManagerPane.EquipSet.NineSlice then
                PaperDollFrame.EquipmentManagerPane.EquipSet
                    .NineSlice:SetAlpha(0)
            end
            for _, r in pairs({ PaperDollFrame.EquipmentManagerPane.EquipSet:GetRegions() }) do
                if r:IsObjectType("Texture") then r:SetAlpha(0) end
            end
            local bg = CreateFrame("Frame", nil, PaperDollFrame.EquipmentManagerPane.EquipSet, "BackdropTemplate")
            bg:SetAllPoints()
            bg:SetFrameLevel(PaperDollFrame.EquipmentManagerPane.EquipSet:GetFrameLevel() - 1)
            bg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
            bg:SetBackdropColor(0.2, 0.2, 0.2, 1)
            bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

            local hl = PaperDollFrame.EquipmentManagerPane.EquipSet:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.1)
            hl:SetBlendMode("ADD")

            PaperDollFrame.EquipmentManagerPane.EquipSet.MCP_BgSkin = bg

            -- Lock de la position
            hooksecurefunc(PaperDollFrame.EquipmentManagerPane.EquipSet, "SetPoint", function(self)
                if self.MCP_SettingPos then return end
                self.MCP_SettingPos = true
                self:ClearAllPoints()
                self:SetPoint("TOPLEFT", PaperDollFrame.EquipmentManagerPane, "TOPLEFT", 14, -10)
                self.MCP_SettingPos = false
            end)
        end

        -- Bouton Enregistrer Stylisé
        if PaperDollFrame.EquipmentManagerPane.SaveSet and not PaperDollFrame.EquipmentManagerPane.SaveSet.MCP_BgSkin then
            PaperDollFrame.EquipmentManagerPane.SaveSet:SetFrameLevel(PaperDollFrame.EquipmentManagerPane:GetFrameLevel() +
                2)
            if PaperDollFrame.EquipmentManagerPane.SaveSet.NineSlice then
                PaperDollFrame.EquipmentManagerPane.SaveSet
                    .NineSlice:SetAlpha(0)
            end
            for _, r in pairs({ PaperDollFrame.EquipmentManagerPane.SaveSet:GetRegions() }) do
                if r:IsObjectType("Texture") then r:SetAlpha(0) end
            end
            local bg = CreateFrame("Frame", nil, PaperDollFrame.EquipmentManagerPane.SaveSet, "BackdropTemplate")
            bg:SetAllPoints()
            bg:SetFrameLevel(PaperDollFrame.EquipmentManagerPane.SaveSet:GetFrameLevel() - 1)
            bg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
            bg:SetBackdropColor(0.2, 0.2, 0.2, 1)
            bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

            local hl = PaperDollFrame.EquipmentManagerPane.SaveSet:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.1)
            hl:SetBlendMode("ADD")

            PaperDollFrame.EquipmentManagerPane.SaveSet.MCP_BgSkin = bg

            -- Lock de la position
            hooksecurefunc(PaperDollFrame.EquipmentManagerPane.SaveSet, "SetPoint", function(self)
                if self.MCP_SettingPos then return end
                self.MCP_SettingPos = true
                self:ClearAllPoints()
                self:SetPoint("LEFT", PaperDollFrame.EquipmentManagerPane.EquipSet, "RIGHT", 4, 0)
                self.MCP_SettingPos = false
            end)
        end

        PaperDollFrame.EquipmentManagerPane.MCP_Skinned = true
    end

    -- Cache les textures globales créées lors de l'accès aux onglets (sans déclencher le linter)
    local bgTop = _G["PaperDollFrameBgTop"]
    if bgTop then bgTop:SetAlpha(0) end
    local hlBar = _G["PaperDollFrameHighlightBar"]
    if hlBar then hlBar:SetAlpha(0) end
    local selBar = _G["PaperDollFrameSelectedBar"]
    if selBar then selBar:SetAlpha(0) end
end

local function MCP_UpdateStatsAdditions()
    if not isMCPActive then return end
    if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
        if CharacterStatsPane.ItemLevelFrame.Background then
            CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
            CharacterStatsPane.ItemLevelFrame.Background:Hide()
        end

        if CharacterStatsPane.ItemLevelFrame.Value then
            CharacterStatsPane.ItemLevelFrame:SetHeight(55)
            local ilvlFPath = GetLSMFontPath(addon.Config and addon.Config.AccordionIlvlFont)
            local ilvlFSize = (addon.Config and addon.Config.AccordionIlvlSize) or 40

            local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
            local iLvl = avgItemLevelEquipped or avgItemLevel or 0

            CharacterStatsPane.ItemLevelFrame.Value:SetFont(ilvlFPath, ilvlFSize, "OUTLINE")

            local r, g, b = 1, 1, 1
            if GetItemLevelColor then
                local tr, tg, tb = GetItemLevelColor()
                if tr and tg and tb then
                    r, g, b = tr, tg, tb
                end
            end

            -- Si WoW renvoie du blanc ou n'a pas encore la couleur (par erreur de chargement ou délai natif), on force vert par défaut
            if (math.abs(r - 1) < 0.01 and math.abs(g - 1) < 0.01 and math.abs(b - 1) < 0.01) or iLvl == 0 then
                r, g, b = 0.12, 1, 0 -- Vert (Inhabituel) pour cacher le flash blanc
            end

            CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(r, g, b)

            CharacterStatsPane.ItemLevelFrame.Value:ClearAllPoints()
            CharacterStatsPane.ItemLevelFrame.Value:SetPoint("CENTER", CharacterStatsPane.ItemLevelFrame, "CENTER", 0, -6)
        end
    end

    -- Ajout statistique de durabilité custom à la fin du panneau
    if CharacterStatsPane then
        if not CharacterStatsPane.MCP_DurabilityStat then
            local stat = CreateFrame("Frame", nil, CharacterStatsPane)
            stat:SetSize(180, 24)

            -- Ligne séparatrice très douce
            local div = stat:CreateTexture(nil, "ARTWORK")
            div:SetColorTexture(1, 1, 1, 0.1) -- Gris extrêmement transparent
            div:SetHeight(1)
            div:SetPoint("TOPLEFT", stat, "TOPLEFT", 20, 0)
            div:SetPoint("TOPRIGHT", stat, "TOPRIGHT", -20, 0)

            local icon = stat:CreateTexture(nil, "OVERLAY")
            icon:SetSize(18, 18)
            icon:SetAtlas("Vehicle-HammerGold-3")
            stat.Icon = icon

            local label = stat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            label:SetText(addon.L["STAT_DURABILITY"])
            stat.Label = label

            local val = stat:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            stat.Value = val

            -- On centre totalement tous les éléments pour créer un vrai style de pied de page
            label:SetPoint("CENTER", stat, "CENTER", -12, 0)
            icon:SetPoint("RIGHT", label, "LEFT", -4, 0)
            val:SetPoint("LEFT", label, "RIGHT", 4, 0)

            stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
            stat:RegisterEvent("PLAYER_ENTERING_WORLD")
            stat:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            stat:SetScript("OnEvent", function(...)
                if isMCPActive and CharacterStatsPane:IsShown() then
                    C_Timer.After(0.1, MCP_UpdateStatsAdditions)
                end
            end)

            CharacterStatsPane.MCP_DurabilityStat = stat
        end

        local stat = CharacterStatsPane.MCP_DurabilityStat

        -- Calcul durabilité
        local currentDurability = 0
        local maxDurability = 0
        for i = 1, 18 do
            local cur, max = GetInventoryItemDurability(i)
            if cur and max then
                currentDurability = currentDurability + cur
                maxDurability = maxDurability + max
            end
        end

        if maxDurability > 0 then
            stat.mcp_retryCount = 0
            local percent = math.floor((currentDurability / maxDurability) * 100)
            stat.Value:SetText(percent .. "%")
            if percent > 80 then
                stat.Value:SetTextColor(0, 1, 0)
            elseif percent > 40 then
                stat.Value:SetTextColor(1, 1, 0)
            else
                stat.Value:SetTextColor(1, 0, 0)
            end
            stat:Show()

            -- Positionnement différé pour s'assurer que les autres stats ont bien leurs coordonnées
            C_Timer.After(0.05, function()
                stat:ClearAllPoints()
                stat:SetPoint("BOTTOMLEFT", CharacterStatsPane, "BOTTOMLEFT", 0, 10)
                stat:SetPoint("BOTTOMRIGHT", CharacterStatsPane, "BOTTOMRIGHT", 0, 10)
            end)
        else
            stat:Hide()

            -- Relance la recherche pour contrer le temps de téléchargement du cache des objets post-/reload
            stat.mcp_retryCount = (stat.mcp_retryCount or 0) + 1
            if stat.mcp_retryCount < 10 then
                C_Timer.After(0.5, function()
                    if isMCPActive and CharacterStatsPane:IsShown() then
                        MCP_UpdateStatsAdditions()
                    end
                end)
            end
        end
    end
end

-- Force le verrouillage de SetPoint pour qu'il ne bouge pas
local function LockPanePosition(pane)
    if not pane or pane.MCP_PosHooked then return end
    pane.MCP_PosHooked = true
    hooksecurefunc(pane, "SetPoint", function(self)
        if isMCPActive and not self.MCP_SettingPos then
            ApplyPanePosition(self)
        end
    end)
end

-- Hooks OnShow sur les panneaux pour les repositionner automatiquement
local function HookPanes()
    if panesHooked then return end

    if CharacterStatsPane then
        CharacterStatsPane:HookScript("OnShow", function(self)
            if isMCPActive then ApplyPanePosition(self) end
        end)
        LockPanePosition(CharacterStatsPane)
    end

    -- Relancer l'affichage du level d'objet quand les stats sont refresh par le jeu (quand on change de zone, de stuff)
    if _G["PaperDollFrame_UpdateStats"] then
        hooksecurefunc("PaperDollFrame_UpdateStats", MCP_UpdateStatsAdditions)
    elseif CharacterStatsPane and CharacterStatsPane.UpdateStats then
        hooksecurefunc(CharacterStatsPane, "UpdateStats", MCP_UpdateStatsAdditions)
    end

    -- Exécute manuellement une fois pour forcer l'apparition lors du reload initial
    if isMCPActive then
        MCP_UpdateStatsAdditions()
    end

    if _G["PaperDollEquipmentManagerPane_Update"] then
        hooksecurefunc("PaperDollEquipmentManagerPane_Update", function()
            local gearPopup = _G["GearManagerPopupFrame"]
            if gearPopup and not gearPopup.MCP_Hooked then
                gearPopup.MCP_Hooked = true

                local function ForcePopupPosition(self)
                    if not isMCPActive or self.MCP_SettingPos then return end
                    self.MCP_SettingPos = true
                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET + PANE_WIDTH + 20, -50)
                    self:SetFrameLevel(CharacterFrame:GetFrameLevel() + 50)
                    self.MCP_SettingPos = false
                end

                gearPopup:HookScript("OnShow", ForcePopupPosition)
                hooksecurefunc(gearPopup, "SetPoint", ForcePopupPosition)

                if gearPopup:IsShown() then
                    ForcePopupPosition(gearPopup)
                end
            end
        end)
    elseif PaperDollFrame and PaperDollFrame.EquipmentManagerPane and PaperDollFrame.EquipmentManagerPane.Update then
        hooksecurefunc(PaperDollFrame.EquipmentManagerPane, "Update", function()
            -- Logique identique pour le popup
            local gearPopup = _G["GearManagerPopupFrame"]
            if gearPopup and not gearPopup.MCP_Hooked then
                gearPopup.MCP_Hooked = true
                local function ForcePopupPosition(self)
                    if not isMCPActive or self.MCP_SettingPos then return end
                    self.MCP_SettingPos = true
                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", TAB_OUTER_OFFSET + PANE_WIDTH + 20, -50)
                    self:SetFrameLevel(CharacterFrame:GetFrameLevel() + 50)
                    self.MCP_SettingPos = false
                end
                gearPopup:HookScript("OnShow", ForcePopupPosition)
                hooksecurefunc(gearPopup, "SetPoint", ForcePopupPosition)
                if gearPopup:IsShown() then ForcePopupPosition(gearPopup) end
            end
        end)
    end

    -- Contre fortement le ré-ancrage natif de Blizzard au changement de tab
    if _G["PaperDollFrame_SetSidebar"] then
        hooksecurefunc("PaperDollFrame_SetSidebar", function(self, index)
            if not isMCPActive then return end

            InitStatsPaneSkin()

            local pane
            if index == 1 then
                pane = CharacterStatsPane
            elseif index == 2 and PaperDollFrame then
                pane = PaperDollFrame.TitleManagerPane
            elseif index == 3 and PaperDollFrame then
                pane = PaperDollFrame.EquipmentManagerPane
            end

            if pane then
                if not pane.MCP_PosHooked then
                    pane:HookScript("OnShow", function(self)
                        if isMCPActive then ApplyPanePosition(self) end
                    end)
                    LockPanePosition(pane)
                end

                C_Timer.After(0.01, function()
                    if pane:IsShown() then
                        ApplyPanePosition(pane)
                    end
                end)
            end
        end)
    elseif PaperDollFrame and PaperDollFrame.SetSidebar then
        hooksecurefunc(PaperDollFrame, "SetSidebar", function(self, index)
            if not isMCPActive then return end
            InitStatsPaneSkin()
            local pane
            if index == 1 then
                pane = CharacterStatsPane
            elseif index == 2 then
                pane = PaperDollFrame.TitleManagerPane
            elseif index == 3 then
                pane = PaperDollFrame.EquipmentManagerPane
            end

            if pane then
                if not pane.MCP_PosHooked then
                    pane:HookScript("OnShow", function(self) if isMCPActive then ApplyPanePosition(self) end end)
                    LockPanePosition(pane)
                end
                C_Timer.After(0.01, function() if pane:IsShown() then ApplyPanePosition(pane) end end)
            end
        end)
    end

    panesHooked = true
end

-- Applique les polices personnalisées des onglets latéraux
local function UpdateTabFonts()
    local fPath = GetLSMFontPath(addon.Config and addon.Config.AccordionTabFont)
    local fSize = (addon.Config and addon.Config.AccordionTabSize) or 14
    for i = 1, 3 do
        local t = _G["PaperDollSidebarTab" .. i]
        if t and t.MCP_Text then
            addon.SafeSetFont(t.MCP_Text, fPath, fSize, "")
        end
    end
end

-- Applique les polices personnalisées des accordéons (titres, stats, iLvl)
local function ApplyAccordionFonts()
    if not CharacterStatsPane then return end

    -- Titres d'accordéon (Caractéristiques, Améliorations)
    local titleFPath = GetLSMFontPath(addon.Config and addon.Config.AccordionTitleFont)
    local titleFSize = (addon.Config and addon.Config.AccordionTitleSize) or 14
    local categories = {
        CharacterStatsPane.ItemLevelCategory,
        CharacterStatsPane.AttributesCategory,
        CharacterStatsPane.EnhancementsCategory
    }
    for _, cat in ipairs(categories) do
        if cat and cat.Title then
            addon.SafeSetFont(cat.Title, titleFPath, titleFSize, "")
        end
    end

    -- iLvl (le grand chiffre)
    if CharacterStatsPane.ItemLevelFrame and CharacterStatsPane.ItemLevelFrame.Value then
        local ilvlFPath = GetLSMFontPath(addon.Config and addon.Config.AccordionIlvlFont)
        local ilvlFSize = (addon.Config and addon.Config.AccordionIlvlSize) or 40
        addon.SafeSetFont(CharacterStatsPane.ItemLevelFrame.Value, ilvlFPath, ilvlFSize, "OUTLINE")
    end

    -- Libellés de statistique (Intelligence, Endurance, etc.)
    local slFPath = GetLSMFontPath(addon.Config and addon.Config.AccordionStatLabelFont)
    local slFSize = (addon.Config and addon.Config.AccordionStatLabelSize) or 12
    if CharacterStatsPane.statsFramePool then
        for sf in CharacterStatsPane.statsFramePool:EnumerateActive() do
            if sf.Label then addon.SafeSetFont(sf.Label, slFPath, slFSize, "") end
            if sf.Value then addon.SafeSetFont(sf.Value, slFPath, slFSize, "") end
        end
    end

    if CharacterStatsPane.MCP_DurabilityStat then
        if CharacterStatsPane.MCP_DurabilityStat.Label then addon.SafeSetFont(
            CharacterStatsPane.MCP_DurabilityStat.Label, slFPath, slFSize, "") end
        if CharacterStatsPane.MCP_DurabilityStat.Value then addon.SafeSetFont(
            CharacterStatsPane.MCP_DurabilityStat.Value, slFPath, slFSize, "") end
    end
end

function addon.Statistiques:Update()
    isMCPActive = true

    for i = 1, 3 do
        local t = _G["PaperDollSidebarTab" .. i]
        if t then InitTabSkin(t, i) end
    end

    InitStatsPaneSkin()
    HookPanes()
    PositionTabs()
    UpdateTabFonts()
    ApplyAccordionFonts()

    -- Affichage du tutoriel "Nouveau" pour le drag&drop
    if isMCPActive and HelpTip and CharacterStatsPane then
        if not addon.Config.StatsTutorialSeen then
            C_Timer.After(0.5, function()
                if CharacterStatsPane:IsShown() and not HelpTip:IsShowing(CharacterStatsPane, addon.L["DRAG_DROP_STATS"]) then
                    local helpTipInfo = {
                        text = addon.L["DRAG_DROP_STATS"],
                        buttonStyle = HelpTip.ButtonStyle.Close,
                        targetPoint = HelpTip.Point.RightEdgeCenter,
                        alignment = HelpTip.Alignment.Center,
                        offsetX = -10,
                        onHideCallback = function()
                            addon.Config.StatsTutorialSeen = true
                        end
                    }
                    HelpTip:Show(CharacterStatsPane, helpTipInfo)
                end
            end)
        end
    end

    -- Ouvre l'onglet 1 (Stats) par défaut
    local tab1 = _G["PaperDollSidebarTab1"]
    if tab1 and tab1.Click then
        tab1:Click()
    elseif CharacterStatsPane then
        ApplyPanePosition(CharacterStatsPane)
        CharacterStatsPane:Show()
    end

    -- Repositionne le panneau actuellement visible
    if CharacterStatsPane and CharacterStatsPane:IsShown() then
        ApplyPanePosition(CharacterStatsPane)
    end
    if PaperDollFrame then
        if PaperDollFrame.TitleManagerPane and PaperDollFrame.TitleManagerPane:IsShown() then
            ApplyPanePosition(PaperDollFrame.TitleManagerPane)
        end
        if PaperDollFrame.EquipmentManagerPane and PaperDollFrame.EquipmentManagerPane:IsShown() then
            ApplyPanePosition(PaperDollFrame.EquipmentManagerPane)
        end
    end

    RefreshTabStates()
end

function addon.Statistiques:Hide()
    isMCPActive = false

    if CharacterStatsPane then CharacterStatsPane:Hide() end

    if PaperDollFrame then
        if PaperDollFrame.TitleManagerPane then PaperDollFrame.TitleManagerPane:Hide() end
        if PaperDollFrame.EquipmentManagerPane then PaperDollFrame.EquipmentManagerPane:Hide() end
    end

    for i = 1, 3 do
        local t = _G["PaperDollSidebarTab" .. i]
        if t then t:Hide() end
    end
end

-- Synchronise les états visuels après chaque clic sidebar
hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
    C_Timer.After(0.01, RefreshTabStates)
end)
