-- Commande de test pour la db 
-- /run MyCharacterPanelDB.lastSeenVersion = nil; ReloadUI()

-- Gestion des mises à jour de l'addon
local addonName, addon = ...
local L = addon.L

-- Création du namespace global pour l'appeler depuis Main.lua
addon.McpUpdate = {}

function addon.McpUpdate:Check()
    if not MyCharacterPanelDB then MyCharacterPanelDB = {} end
    
    local currentVersion = C_AddOns.GetAddOnMetadata(addonName, "Version")
    local lastVersion = MyCharacterPanelDB.lastSeenVersion
    
    -- Comparaison de version
    if lastVersion ~= currentVersion then
        self:ShowWhatsNew(currentVersion)
        MyCharacterPanelDB.lastSeenVersion = currentVersion
    end
end

function addon.McpUpdate:ShowWhatsNew(version)
    -- Frame principale agrandie pour plus de lisibilité
    local f = CreateFrame("Frame", "MCP_UpdateFrame", UIParent, "BackdropTemplate")
    f:SetSize(500, 480) -- Augmentation de la hauteur pour 4 features
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Fond noir
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 11, -12)
    bg:SetPoint("BOTTOMRIGHT", -12, 11)
    bg:SetColorTexture(0, 0, 0, 1)
    
    -- Titre
    f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    f.Title:SetPoint("TOP", 0, -30)
    -- Correction format (1 seul argument attendu : la version)
    f.Title:SetText(format(L["MAJ_TITLE"], version)) 
    f.Title:SetTextColor(1, 0.82, 0) 
    
    -- Ligne
    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetWidth(450)
    line:SetPoint("TOP", 0, -60)
    line:SetColorTexture(1, 1, 1, 0.2)

    -- Contenu texte (Descendu pour éviter chevauchement)
    f.Content = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.Content:SetPoint("TOPLEFT", 50, -90)
    f.Content:SetPoint("RIGHT", -50, 0)
    f.Content:SetJustifyH("LEFT")
    f.Content:SetJustifyV("TOP")
    f.Content:SetSpacing(8) -- Espacement entre les lignes
    f.Content:SetTextColor(1, 1, 1)
    
    local features = {
        L["MAJ_FEATURE_1"],
        L["MAJ_FEATURE_2"],
        L["MAJ_FEATURE_3"],
        L["MAJ_FEATURE_4"],
        L["MAJ_FEATURE_5"]
    }
    
    f.Content:SetText(table.concat(features, "\n\n")) -- Double saut de ligne pour aérer
    
    -- Note (repositionnée plus haut pour éviter le chevauchement)
    local infoText = "N'oubliez pas que des options sont disponibles via l'icône |TInterface\\Buttons\\UI-OptionsButton:16:16:0:-1|t de l'addon ou via la commande |cff00ccff/mcp config|r en jeu !"
    if L and L["MAJ_NOTE_OPTIONS"] then infoText = L["MAJ_NOTE_OPTIONS"] end
    
    local note = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    note:SetPoint("BOTTOM", 0, 85) -- Monté de 70 à 85
    note:SetWidth(420)
    note:SetJustifyH("CENTER")
    note:SetText(infoText)
    note:SetTextColor(0.6, 0.6, 0.6)
    
    -- Bouton OK
    local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btn:SetSize(160, 35)
    btn:SetPoint("BOTTOM", 0, 25)
    btn:SetText(L["OK"])
    btn:SetScript("OnClick", function() 
        f:Hide() 
    end)

    f:Show()
end
