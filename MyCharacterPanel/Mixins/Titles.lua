local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

local CreateFrame = CreateFrame
local GetKnownTitles = GetKnownTitles or C_PlayerInfo.GetKnownTitles
local GetCurrentTitle = GetCurrentTitle
local SetCurrentTitle = SetCurrentTitle
local strfind, lower, sort, wipe, tinsert, tremove = string.find, string.lower, table.sort, table.wipe, table.insert, table.remove
local ipairs, pairs, math = ipairs, pairs, math
local strtrim = string.trim

addon.TitlesMixin = {}
local TitlesMixin = addon.TitlesMixin

function TitlesMixin:OnLoad()
    -- FOND ET STYLE
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

    -- ÉTAT FERMÉ (Bandeau Vertical)
    self.CenterContainer = CreateFrame("Frame", nil, self)
    self.CenterContainer:SetPoint("TOPLEFT", 0, 0)
    self.CenterContainer:SetPoint("BOTTOMRIGHT", 0, 0)
    
    -- Configuration de l'icône

    self.Icon = self.CenterContainer:CreateTexture(nil, "ARTWORK")
    self.Icon:SetSize(26, 26)
    self.Icon:SetPoint("CENTER", self.CenterContainer, "TOP", 0, 12) 
    self.Icon:SetTexture("Interface\\AddOns\\MyCharacterPanel\\Utils\\logo\\titres.png")
    self.Icon:SetTexCoord(0, 1, 0, 1)

    -- Configuration du texte

    self.VerticalLabel = self.CenterContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local labelText = L["TITLE_TITLES"]
    self.VerticalLabel:SetText("   " .. labelText)
    
    self.VerticalLabel:SetTextColor(1, 0.82, 0)
    self.VerticalLabel:SetRotation(math.rad(270)) 
    self.VerticalLabel:SetJustifyH("CENTER") 
    self.VerticalLabel:SetJustifyV("MIDDLE") 
    self.VerticalLabel:SetWordWrap(false)

    local valeurX = 9 
    self.VerticalLabel:SetPoint("CENTER", self.CenterContainer, "CENTER", valeurX, 0)
    
    -- Effet de lueur

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
        if parent.ToggleTitles then parent:ToggleTitles(true) end
    end)

    -- ÉTAT OUVERT (Contenu)
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
        if parent.ToggleTitles then parent:ToggleTitles() end
    end)

    self.HeaderTitle = self.Content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.HeaderTitle:SetPoint("TOP", 0, -15)
    self.HeaderTitle:SetText(L["TITLE_TITLES"])
    self.HeaderTitle:SetTextColor(1, 0.82, 0)

    -- BARRE DE RECHERCHE
    self.SearchBox = CreateFrame("EditBox", nil, self.Content, "SearchBoxTemplate")
    self.SearchBox:SetSize(180, 20)
    self.SearchBox:SetPoint("TOP", self.HeaderTitle, "BOTTOM", 0, -10)
    self.SearchBox:SetScript("OnTextChanged", function(box)
        SearchBoxTemplate_OnTextChanged(box)
        self:UpdateTitles(box:GetText())
    end)

    -- SCROLL FRAME
    self.ScrollFrame = CreateFrame("ScrollFrame", nil, self.Content, "UIPanelScrollFrameTemplate")
    self.ScrollFrame:SetPoint("TOPLEFT", 10, -75)
    self.ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    self.ScrollChild = CreateFrame("Frame", nil, self.ScrollFrame)
    self.ScrollChild:SetSize(200, 1) 
    self.ScrollFrame:SetScrollChild(self.ScrollChild)

    self.buttons = {}
    self.titleList = {}
end

function TitlesMixin:UpdateTitles(filterText)
    if not MyCharacterPanelDB then MyCharacterPanelDB = {} end
    if not MyCharacterPanelDB.favorites then MyCharacterPanelDB.favorites = {} end

    local currentTitleId = GetCurrentTitle()
    local titles = GetKnownTitles() or {}
    local favs = MyCharacterPanelDB.favorites
    
    wipe(self.titleList)
    
    local tempTitles = {}
    local safeFilter = filterText and lower(filterText) or ""

    -- Récupération des titres

    for _, titleInfo in ipairs(titles) do
        local id, name
        if type(titleInfo) == "table" then
            id = titleInfo.id
            if titleInfo.name then name = titleInfo.name else name = GetTitleName(id) end
        else
            id = titleInfo
            name = GetTitleName(id)
        end
        
        if name then
            local cleanName = strtrim(name)
            if cleanName ~= "" then
                if safeFilter == "" or strfind(lower(cleanName), safeFilter) then
                    tinsert(tempTitles, { id = id, name = cleanName })
                end
            end
        end
    end
    
    -- Tri : Favoris d'abord, puis alphabétique

    sort(tempTitles, function(a, b)
        local isFavA = favs[a.id]
        local isFavB = favs[b.id]
        
        if isFavA and not isFavB then return true 
        elseif not isFavA and isFavB then return false 
        else return a.name < b.name end 
    end)
    
    -- Le titre actif remonte en haut

    if currentTitleId and currentTitleId ~= -1 then
        for i, t in ipairs(tempTitles) do
            if t.id == currentTitleId then
                tremove(tempTitles, i)
                tinsert(tempTitles, 1, t) 
                break
            end
        end
    end

    -- Ajout de "Sans titre" (Toujours en premier sans filtre)

    if safeFilter == "" then
        tinsert(self.titleList, { id = -1, name = L["NO_TITLE"] }) 
    end
    
    for _, t in ipairs(tempTitles) do
        tinsert(self.titleList, t)
    end

    -- Affichage et calcul des hauteurs

    local totalHeight = 0
    local BASE_HEIGHT = 20 
    
    for i, titleData in ipairs(self.titleList) do
        local btn = self.buttons[i]
        if not btn then
            -- Création
            btn = CreateFrame("Button", nil, self.ScrollChild)
            btn:SetWidth(190) -- Largeur totale du bouton
            
            local hl = btn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            hl:SetBlendMode("ADD")
            hl:SetAllPoints()
            
            -- Coche (gauche)
            btn.Check = btn:CreateTexture(nil, "ARTWORK")
            btn.Check:SetAtlas("common-icon-checkmark")
            btn.Check:SetSize(14, 14)
            btn.Check:SetPoint("LEFT", 5, 0)
            
            -- Etoile (droite)
            btn.FavButton = CreateFrame("Button", nil, btn)
            btn.FavButton:SetSize(16, 16)
            btn.FavButton:SetPoint("RIGHT", -5, 0)
            btn.FavButton.Texture = btn.FavButton:CreateTexture(nil, "ARTWORK")
            btn.FavButton.Texture:SetAllPoints()
            
            btn.FavButton:SetScript("OnClick", function(favBtn)
                local parentBtn = favBtn:GetParent()
                local tid = parentBtn.titleID
                if tid and tid ~= -1 then
                    if MyCharacterPanelDB.favorites[tid] then
                        MyCharacterPanelDB.favorites[tid] = nil
                    else
                        MyCharacterPanelDB.favorites[tid] = true
                    end
                    self:UpdateTitles(self.SearchBox:GetText())
                end
            end)
            
            -- Texte
            btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft")
            btn.Text:SetPoint("LEFT", 25, 0)
            btn.Text:SetPoint("RIGHT", -25, 0) -- Laisse la place pour l'étoile
            btn.Text:SetWordWrap(true) -- Autorise les retours à la ligne
            btn.Text:SetJustifyV("MIDDLE")
            
            btn:SetScript("OnClick", function(b)
                if b.titleID == -1 then SetCurrentTitle(-1) else SetCurrentTitle(b.titleID) end
                self:UpdateSelection(b.titleID)
                self:UpdateTitles(self.SearchBox:GetText())
            end)
            
            self.buttons[i] = btn
        end
        
        -- Configuration du bouton
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", 0, -totalHeight)
        
        if titleData.id == -1 then
            btn.Text:SetText("< " .. titleData.name .. " >")
            btn.Text:SetTextColor(0.6, 0.6, 0.6) 
        else
            btn.Text:SetText(titleData.name)
        end
        btn.titleID = titleData.id
        
        -- Calcul précis de la hauteur

        btn.Text:SetWidth(145) 
        
        local textHeight = btn.Text:GetStringHeight()
        local rowHeight = BASE_HEIGHT
        
        if textHeight > 14 then
            rowHeight = textHeight + 10 
        end
        
        btn:SetHeight(rowHeight)
        
        -- État de sélection
        local isSelected = (titleData.id == currentTitleId)
        if titleData.id == -1 and (not currentTitleId or currentTitleId == -1) then isSelected = true end

        if isSelected then
            btn.Check:Show()
            if titleData.id == -1 then
                btn.Text:SetTextColor(0.8, 0.8, 0.8)
            else
                btn.Text:SetTextColor(1, 0.82, 0)
            end
        else
            btn.Check:Hide()
            if titleData.id ~= -1 then
                btn.Text:SetTextColor(1, 1, 1)
            end
        end
        
        -- État Favori
        if titleData.id == -1 then
            btn.FavButton:Hide()
        else
            btn.FavButton:Show()
            
            -- Réinitialisation propre
            btn.FavButton.Texture:SetAtlas("PetJournal-FavoritesIcon", true)
            
            if favs[titleData.id] then
                -- Favori actif : Doré

                btn.FavButton.Texture:SetDesaturated(false) -- Couleur naturelle (Or)
                btn.FavButton.Texture:SetVertexColor(1, 1, 1) -- Pleine luminosité
                btn.FavButton:SetAlpha(1)
            else
                -- Non favori : Argent

                btn.FavButton.Texture:SetDesaturated(true) -- Niveau de gris
                btn.FavButton.Texture:SetVertexColor(0.8, 0.8, 0.8) -- Argenté (Gris clair)
                btn.FavButton:SetAlpha(0.5) -- Semi-transparent
            end
            
            -- Gestion du survol pour effet "Highlight" sur l'étoile argentée
            btn.FavButton:SetScript("OnEnter", function(f) 
                if not favs[titleData.id] then 
                    f:SetAlpha(1) -- Devient opaque
                    f.Texture:SetVertexColor(1, 1, 1) -- Devient argent brillant (blanc)
                end 
            end)
            
            btn.FavButton:SetScript("OnLeave", function(f) 
                if not favs[titleData.id] then 
                    f:SetAlpha(0.5) -- Retourne à l'état discret
                    f.Texture:SetVertexColor(0.8, 0.8, 0.8) 
                end 
            end)
        end
        
        btn:Show()
        totalHeight = totalHeight + rowHeight
    end
    
    for i = #self.titleList + 1, #self.buttons do self.buttons[i]:Hide() end
    self.ScrollChild:SetHeight(totalHeight)
end

function TitlesMixin:UpdateSelection(selectedID)
    for _, btn in ipairs(self.buttons) do
        if btn:IsShown() then
            local isSelected = (btn.titleID == selectedID)
            if isSelected then
                btn.Check:Show()
                if btn.titleID ~= -1 then btn.Text:SetTextColor(1, 0.82, 0) end
            else
                btn.Check:Hide()
                if btn.titleID ~= -1 then btn.Text:SetTextColor(1, 1, 1) end
            end
        end
    end
end