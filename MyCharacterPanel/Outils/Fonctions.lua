-- Des petites fonctions pour nous aider à coder plus vite

local addonName, addon = ...
addon.Outils = {}

-- Ça sert à cacher ou montrer les fenêtres normales de WoW
function addon.Outils.ToggleNative(show)
    local alpha = show and 1 or 0
    local function Set(frame)
        if frame then
            if frame.SetShown then frame:SetShown(show) end
            if frame.SetAlpha then frame:SetAlpha(alpha) end
        end
    end
    Set(CharacterFrameBg)
    Set(CharacterFrameInset)
    Set(CharacterFrameInsetRight)
    Set(CharacterFramePortrait)
    if CharacterFrame.TitleContainer then Set(CharacterFrame.TitleContainer) end
    if CharacterFrame.NineSlice then Set(CharacterFrame.NineSlice) end

    for _, region in pairs({ CharacterFrame:GetRegions() }) do
        if region:IsObjectType("Texture") and region ~= CharacterFrame.MCP_MainBG then
            if region:GetAlpha() ~= alpha then
                region:SetAlpha(alpha)
            end
        end
    end
end

-- On utilise ça pour dégager un cadre proprement
function addon.Outils.KillFrame(frame)
    if frame then
        frame:Hide()
        frame:SetAlpha(0)
        frame:EnableMouse(false)
        frame:SetParent(nil)
    end
end

-- Pour enlever les images d'un cadre et le vider
function addon.Outils.StripTextures(frame)
    if not frame then return end
    for _, region in pairs({ frame:GetRegions() }) do
        if region:IsObjectType("Texture") then
            region:SetAlpha(0)
            region:Hide()
        end
    end
end

-- =====================================================================
-- GROUPE TOUTE LA LOGIQUE DE DÉPLACEMENT ET DE SAUVEGARDE DE LA FENÊTRE
-- =====================================================================

function addon.Outils.InitDeplacementFenetre(frame, dragFrames, isReskinnedFunc)
    local isMCPDragging = false

    -- Sauvegarde de la position actuelle
    local function MCP_SavePosition()
        if not frame then return end
        if not addon.Config then addon.Config = {} end

        local left = frame:GetLeft()
        local top  = frame:GetTop()
        if not left or not top then return end

        addon.Config.CharFrameX = left
        addon.Config.CharFrameY = top - UIParent:GetHeight()
        frame:SetUserPlaced(true)
    end

    -- Restauration de la position sauvegardée
    local function MCP_RestorePosition()
        if not isReskinnedFunc() then return end
        if not addon.Config or not addon.Config.CharFrameX or not addon.Config.CharFrameY then return end

        if InCombatLockdown() then return end

        frame:SetMovable(true)
        frame:SetUserPlaced(true)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", addon.Config.CharFrameX, addon.Config.CharFrameY)
    end

    -- Application des événements de déplacement (Drag & Drop)
    local function ApplyDrag(f)
        if not f then return end
        f:RegisterForDrag("LeftButton")

        f:HookScript("OnDragStart", function()
            if isReskinnedFunc() and not InCombatLockdown() and not isMCPDragging then
                isMCPDragging = true
                frame.mcp_isDragging = true
                frame:SetMovable(true)
                -- Réancrage à la position visuelle actuelle pour éviter le décalage au drag
                local left = frame:GetLeft()
                local top  = frame:GetTop()
                if left and top then
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top - UIParent:GetHeight())
                end
                frame:SetUserPlaced(true)
                frame:StartMoving()
            end
        end)

        f:HookScript("OnDragStop", function()
            if isReskinnedFunc() and isMCPDragging then
                isMCPDragging = false
                frame.mcp_isDragging = false
                frame:StopMovingOrSizing()
                MCP_SavePosition()
            end
        end)
    end

    -- On applique le drag sur tous les éléments demandés
    for _, f in ipairs(dragFrames) do
        ApplyDrag(f)
    end

    -- Sécurité : sauvegarde à la fermeture au cas où un autre addon l'aurait bougée
    frame:HookScript("OnHide", function()
        if isReskinnedFunc() and not InCombatLockdown() then
            MCP_SavePosition()
        end
    end)

    return MCP_SavePosition, MCP_RestorePosition
end

-- Crée une petite info discrète à côté d'un élément
function addon.Outils.CreateInfoBanner(parent, message, anchorFrame, xOff, yOff)
    if parent.MCP_InfoBannerDismissed then return end
    if parent.MCP_InfoBanner then
        parent.MCP_InfoBanner:Show()
        return
    end

    local banner = CreateFrame("Frame", nil, parent)
    banner:SetHeight(20)

    -- On utilise une police normale (plus lisible)
    local text = banner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetText(message)
    text:SetTextColor(1, 0.2, 0.2, 0.9)
    text:SetPoint("LEFT", banner, "LEFT")

    -- On ajuste la largeur du cadre au texte
    banner:SetWidth(text:GetStringWidth() + 25)

    if anchorFrame then
        banner:SetPoint("LEFT", anchorFrame, "RIGHT", 15, 0)
    else
        banner:SetPoint("TOP", parent, "TOP", 0, 10)
    end

    local close = CreateFrame("Button", nil, banner)
    close:SetSize(12, 12)
    close:SetPoint("LEFT", text, "RIGHT", 6, 0)
    close:SetNormalAtlas("uitools-icon-close")
    close:SetAlpha(0.8)
    close:SetScript("OnClick", function()
        banner:Hide()
        parent.MCP_InfoBannerDismissed = true
    end)

    parent.MCP_InfoBanner = banner
end
