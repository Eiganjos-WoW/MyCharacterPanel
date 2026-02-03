local addonName, addon = ...
local L = addon.L
local C = addon.Consts
local Utils = addon.Utils

local format = string.format
local insert = table.insert
local abs = math.abs
local ipairs = ipairs
local type = type
local max = math.max
local strsplit = strsplit
local pcall = pcall

local GetSpellCritChance = GetSpellCritChance
local GetRangedCritChance = GetRangedCritChance
local GetCritChance = GetCritChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetMasteryEffect = GetMasteryEffect
local GetVersatilityBonus = GetVersatilityBonus
local GetLifesteal = GetLifesteal
local GetAvoidance = GetAvoidance
local GetSpeed = GetSpeed
local GetShieldBlock = GetShieldBlock
local GetBlockChance = GetBlockChance
local GetDodgeChance = GetDodgeChance
local GetParryChance = GetParryChance
local GetHaste = GetHaste
local UnitStat = UnitStat
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local GetAverageItemLevel = GetAverageItemLevel
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local C_PaperDollInfo = C_PaperDollInfo
local C_Item = C_Item
local C_Spell = C_Spell
local GetInventoryItemID = GetInventoryItemID
local GetSpecializationMasterySpells = GetSpecializationMasterySpells
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetParryChanceFromAttribute = GetParryChanceFromAttribute

addon.StatsMixin = {}
local StatsMixin = addon.StatsMixin

local function SafeFormat(formatString, ...)
    if not formatString then return "" end
    local success, result = pcall(format, formatString, ...)
    if success then 
        return result 
    else
        return formatString 
    end
end

local function FormatValue(val)
    if BreakUpLargeNumbers then
        return BreakUpLargeNumbers(val)
    end
    return Utils.FormatNumber(val)
end

local function IsWearingShield()
    local itemID = GetInventoryItemID("player", 17) 
    if itemID then
        local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemID)
        return equipLoc == "INVTYPE_SHIELD"
    end
    return false
end

function StatsMixin:OnStatEnter(frame)
    if frame.Highlight then frame.Highlight:Show() end
    
    local tt = addon.Tooltip
    tt:SetOwner(frame, "ANCHOR_RIGHT", 10, -10)
    tt:ClearLines()
    
    local statKey = frame.statKey

    -- Logique des tooltips

    
    if statKey == "CRIT" then
        local spellCrit = GetSpellCritChance() or 0
        local rangedCrit = GetRangedCritChance() or 0
        local meleeCrit = GetCritChance() or 0
        local ratingID = CR_CRIT_MELEE 
        
        if (spellCrit >= rangedCrit) and (spellCrit >= meleeCrit) then 
            ratingID = CR_CRIT_SPELL
        elseif (rangedCrit >= meleeCrit) then 
            ratingID = CR_CRIT_RANGED 
        end
        
        local ratingValue = GetCombatRating(ratingID) or 0
        local ratingBonus = GetCombatRatingBonus(ratingID) or 0 

        -- Score formaté (Titre)

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_CRITICAL_STRIKE"], FormatValue(ratingValue), ratingBonus), 1, 1, 1)

        -- Description Native

        local description = _G["CR_CRIT_TOOLTIP"]
        if description then
            local splitDesc = strsplit("\n", description)
            if splitDesc then
                tt:AddLine(splitDesc, 1, 0.82, 0, true)
            end
        end

        -- Parade pour les Tanks

        local _, classFile = UnitClass("player")
        if classFile == "WARRIOR" or classFile == "PALADIN" or classFile == "DEATHKNIGHT" then
            local parryBonus = GetCombatRatingBonus(CR_PARRY) or 0
            if parryBonus > 0 then
                local parryString = _G["CR_PARRY_CHANCE_FROM_ATTRIBUTE"] or L["PARRY_TOOLTIP_FALLBACK"]
                tt:AddLine(format(parryString, parryBonus), 0.7, 0.7, 0.7, true)
            end
        end

    elseif statKey == "HASTE" then
        local rating = GetCombatRating(CR_HASTE_MELEE) or 0
        local hasteBonus = GetCombatRatingBonus(CR_HASTE_MELEE) or 0
        
        -- Score formaté (Titre)

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_HASTE"], FormatValue(rating), hasteBonus), 1, 1, 1)

        -- Description

        if _G["STAT_HASTE_TOOLTIP"] then
            local splitDesc = strsplit("\n", _G["STAT_HASTE_TOOLTIP"])
            tt:AddLine(splitDesc, 1, 0.82, 0, true)
        end
        
    elseif statKey == "MASTERY" then
        local rating = GetCombatRating(CR_MASTERY) or 0
        local _, bonusCoeff = GetMasteryEffect()
        local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * (bonusCoeff or 1)

        local specID = GetSpecialization()
        if specID then
            local masterySpellID = GetSpecializationMasterySpells(specID)
            if masterySpellID then
                local spellInfo = C_Spell.GetSpellInfo(masterySpellID)
                if spellInfo and spellInfo.name then
                    tt:AddLine(spellInfo.name, 1, 1, 1)
                end
                
                local description = C_Spell.GetSpellDescription(masterySpellID)
                if description then
                    tt:AddLine(description, 1, 0.82, 0, true)
                end
            end
        end
        
        tt:AddLine(" ")
        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_MASTERY"], FormatValue(rating), masteryBonus), 1, 1, 1, true)

    elseif statKey == "VERSATILITY" then
        local rating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0
        local versBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
        local versTaken = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
        
        -- Score formaté (Titre)

        tt:AddLine(format("%s : %s [+%.2f%% / -%.2f%%]", _G["STAT_VERSATILITY"], FormatValue(rating), versBonus, versTaken), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_VERSATILITY_TOOLTIP"], versBonus, versTaken, FormatValue(rating), versBonus, versTaken)
        if fullText then
            local desc = strsplit("\n", fullText) -- On garde seulement la première ligne (description)
            tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "LEECH" then
        local rating = GetCombatRating(CR_LIFESTEAL) or 0
        local ratingBonus = GetCombatRatingBonus(CR_LIFESTEAL) or 0
        
        -- Titre

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_LIFESTEAL"], FormatValue(rating), ratingBonus), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_LIFESTEAL_TOOLTIP"], FormatValue(rating), ratingBonus)
        if fullText then
            local desc = strsplit("\n", fullText)
            tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "AVOIDANCE" then
        local rating = GetCombatRating(CR_AVOIDANCE) or 0
        local ratingBonus = GetCombatRatingBonus(CR_AVOIDANCE) or 0
        
        -- Titre

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_AVOIDANCE"], FormatValue(rating), ratingBonus), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_AVOIDANCE_TOOLTIP"], FormatValue(rating), ratingBonus)
        if fullText then
             local desc = strsplit("\n", fullText)
             tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "SPEED" then
        local rating = GetCombatRating(CR_SPEED) or 0
        local ratingBonus = GetCombatRatingBonus(CR_SPEED) or 0
        
        -- Titre

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_SPEED"], FormatValue(rating), ratingBonus), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_SPEED_TOOLTIP"], FormatValue(rating), ratingBonus)
        if fullText then
            local desc = strsplit("\n", fullText)
            tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "DODGE" then
        local rating = GetCombatRating(CR_DODGE) or 0
        local bonus = GetCombatRatingBonus(CR_DODGE) or 0
        
        -- Titre

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_DODGE"], FormatValue(rating), bonus), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_DODGE_TOOLTIP"], FormatValue(rating), bonus)
        if fullText then
            local desc = strsplit("\n", fullText)
            tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "PARRY" then
        local rating = GetCombatRating(CR_PARRY) or 0
        local bonus = GetCombatRatingBonus(CR_PARRY) or 0
        
        -- Titre

        tt:AddLine(format("%s : %s [+%.2f%%]", _G["STAT_PARRY"], FormatValue(rating), bonus), 1, 1, 1)
        
        -- Description

        local fullText = SafeFormat(_G["CR_PARRY_TOOLTIP"], FormatValue(rating), bonus)
        if fullText then
            local desc = strsplit("\n", fullText)
            tt:AddLine(desc, 1, 0.82, 0, true)
        end

    elseif statKey == "BLOCK" then
        local chance = GetBlockChance() or 0
        local rating = GetCombatRating(CR_BLOCK) or 0
        local bonus = GetCombatRatingBonus(CR_BLOCK) or 0
        local shieldBlockValue = GetShieldBlock() or 0
        
        -- Titre

        tt:AddLine(format(BLOCK_CHANCE, chance), 1, 1, 1)

        -- Infos supplémentaires

        if rating > 0 then
             local fullText = SafeFormat(_G["CR_BLOCK_TOOLTIP"], FormatValue(rating), bonus)
             if fullText then
                 local desc = strsplit("\n", fullText)
                 tt:AddLine(desc, 1, 0.82, 0, true)
             end
        end

        if IsWearingShield() then
             local reduction = C_PaperDollInfo.GetArmorEffectiveness(shieldBlockValue, UnitLevel("player")) * 100
             local blockTooltipText = _G["CR_BLOCK_TOOLTIP"]
             local formatString = blockTooltipText and strsplit("\n", blockTooltipText) or L["BLOCK_TOOLTIP_FALLBACK"]
             tt:AddLine(SafeFormat(formatString, reduction), 1, 0.82, 0, true)
        else
            tt:AddLine(L["NOT_ENCHANTED"], 0.5, 0.5, 0.5, true)
        end

    elseif statKey == "ARMOR" then
         local _, effectiveArmor = UnitArmor("player")
         local reduction = C_PaperDollInfo.GetArmorEffectiveness(effectiveArmor, UnitLevel("player")) or 0
         
         -- Titre

         tt:AddLine(format("%s : %s", _G["STAT_ARMOR"], FormatValue(effectiveArmor)), 1, 1, 1)
         
         -- Description

         tt:AddLine(SafeFormat(_G["STAT_ARMOR_TOOLTIP"], reduction * 100), 1, 0.82, 0, true)

    elseif type(statKey) == "number" then
        -- Stats primaires (Force, Agi, Int, Endu)
        local statID = statKey
        local stat, effectiveStat, posBuff, negBuff = UnitStat("player", statID)
        local statName = _G["SPELL_STAT"..statID.."_NAME"]
        
        -- Titre : "Force (Base + Bonus)"
        local text = HIGHLIGHT_FONT_COLOR_CODE..statName
        
        if (posBuff == 0 and negBuff == 0) then
            text = text..FONT_COLOR_CODE_CLOSE
        else
            text = text..FONT_COLOR_CODE_CLOSE.." ("
            local base = stat - posBuff - negBuff
            text = text..FormatValue(base)
            
            if posBuff > 0 then 
                text = text..GREEN_FONT_COLOR_CODE.." +"..FormatValue(posBuff)..FONT_COLOR_CODE_CLOSE 
            end
            if negBuff < 0 then 
                text = text..RED_FONT_COLOR_CODE.." "..FormatValue(negBuff)..FONT_COLOR_CODE_CLOSE 
            end
            text = text..")"
        end

        tt:AddLine(text)

        local desc = _G["DEFAULT_STAT"..statID.."_TOOLTIP"]
        
        if statID == 3 then -- Endurance
            local hpBonus = effectiveStat * 20
            tt:AddLine(SafeFormat(desc, FormatValue(hpBonus)), 1, 0.82, 0, true)
        else
            -- Force, Agi, Intel
            tt:AddLine(desc, 1, 0.82, 0, true)
            
            -- Spécial Tank (Force -> Parade)
            local _, classFile = UnitClass("player")
            if statID == 1 and (classFile == "WARRIOR" or classFile == "PALADIN" or classFile == "DEATHKNIGHT") then
                local parryFromStat = 0
                if GetParryChanceFromAttribute then
                     parryFromStat = GetParryChanceFromAttribute()
                end
                
                if parryFromStat > 0 then
                    local parryString = _G["CR_PARRY_CHANCE_FROM_ATTRIBUTE"] or L["PARRY_TOOLTIP_FALLBACK"]
                    tt:AddLine(format(parryString, parryFromStat), 0.7, 0.7, 0.7, true)
                end
            end
        end
    end
    
    tt:Show()
end

function StatsMixin:OnStatLeave(frame)
    if frame.Highlight then frame.Highlight:Hide() end
    addon.Tooltip:Hide()
end

-- Initialisation graphique


function StatsMixin:OnLoad()
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

    StatsMixin.layoutOrder = {} 

    -- État fermé

    self.CenterContainer = CreateFrame("Frame", nil, self)
    self.CenterContainer:SetPoint("TOPLEFT", 0, 0)
    self.CenterContainer:SetPoint("BOTTOMRIGHT", 0, 0)
    
    -- Configuration de l'icône

    self.Icon = self.CenterContainer:CreateTexture(nil, "ARTWORK")
    self.Icon:SetSize(26, 26)
    -- On ancre le CENTRE de l'icône sur le HAUT du cadre.
    self.Icon:SetPoint("CENTER", self.CenterContainer, "TOP", 0, 13) 

    self.Icon:SetTexture("Interface\\AddOns\\MyCharacterPanel\\Utils\\logo\\stats.png")
    self.Icon:SetTexCoord(0, 1, 0, 1) 
    
    -- === CONFIGURATION DU TEXTE ===
    self.VerticalLabel = self.CenterContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    
    -- Ajout d'espaces pour le padding

    local labelText = L["TITLE_ATTRIBUTES"]
    self.VerticalLabel:SetText("   " .. labelText)

    self.VerticalLabel:SetTextColor(1, 0.82, 0)
    self.VerticalLabel:SetRotation(math.rad(270))
    self.VerticalLabel:SetJustifyH("CENTER")
    self.VerticalLabel:SetJustifyV("MIDDLE")
    self.VerticalLabel:SetWordWrap(false)

    -- Centrage absolu (y=0)

    local valeurX = 9 
    self.VerticalLabel:SetPoint("CENTER", self.CenterContainer, "CENTER", valeurX, 0)
    
    -- Effet de lueur (Glow)

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
        if parent.ToggleStats then parent:ToggleStats(true) end
    end)

    -- Contenu ouvert

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
        if parent.ToggleStats then parent:ToggleStats() end
    end)

    self.HeaderContainer = CreateFrame("Frame", nil, self.Content)
    self.HeaderContainer:SetSize(240, 90)
    self.HeaderContainer:SetPoint("TOP", 0, 0)
    
    self.Ring = self.HeaderContainer:CreateTexture(nil, "BACKGROUND")
    self.Ring:SetAtlas("ChallengeMode-Runes-Background")
    self.Ring:SetSize(100, 100)
    self.Ring:SetPoint("CENTER", 0, -5)
    self.Ring:SetAlpha(0.2)
    self.Ring:SetVertexColor(1, 0.82, 0)
    
    self.ILVLTitle = self.HeaderContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
    self.ILVLTitle:SetPoint("TOP", 0, -25) 
    self.ILVLTitle:SetText(L["TITLE_ILVL"])
    self.ILVLTitle:SetTextColor(0.8, 0.8, 0.8)
    self.ILVLTitle:SetScale(1.1)
    
    self.ILVLValue = self.HeaderContainer:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Huge1") 
    self.ILVLValue:SetPoint("TOP", 0, -45) 
    self.ILVLValue:SetTextColor(1, 1, 1)
    self.ILVLValue:SetScale(1.35)
    
    -- === DRAG AND DROP HANDLERS ===
    
    -- === DRAG AND DROP HANDLERS ===
    
    function StatsMixin:OnDragStart(frame)
        if not frame:IsMovable() then return end
        frame:StartMoving()
        frame.isMoving = true 
        -- Niveau relatif pour être sûr d'être au dessus mais pas dans l'espace
        frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 50)
        frame:SetAlpha(0.6) 
        
        frame:SetScript("OnUpdate", function(self)
             StatsMixin:OnDragUpdate(self)
        end)
    end
    
    function StatsMixin:OnDragUpdate(frame)
        -- 1. Récupération de la position relative du curseur
        local uiScale = UIParent:GetEffectiveScale()
        local frameScale = frame:GetEffectiveScale() -- Scale effectif de la frame
        local cx, cy = GetCursorPosition()
        
        -- On convertit cy pour qu'il soit dans l'espace de coordonnées de la frame
        -- cy est l'écran global, on divise par frameScale pour avoir des unités locales
        local cy_local = cy / frameScale
        
        local content = frame:GetParent()
        local top = content:GetTop()
        if not top then return end
        
        -- Position Y du curseur par rapport au HAUT du contenu
        local cursorY = cy_local - top 
        
        -- 2. Extraction des autres éléments (l'ordre relatif des autres ne change pas)
        local others = {}
        for _, f in ipairs(StatsMixin.layoutOrder) do
            if f ~= frame then
                table.insert(others, f)
            end
        end
        
        -- 3. Logique Géométrique (Remplacement de la simulation)
        local insertIndex = #others + 1 
        
        for i, other in ipairs(others) do
            local top = other:GetTop()
            local bottom = other:GetBottom()
            if top and bottom then
                local s = other:GetEffectiveScale()
                local cursorY_scaled = cy / s
                local center = (top + bottom) / 2
                
                if cursorY_scaled > center then
                    insertIndex = i
                    break
                end
            end
        end

        if insertIndex < 2 then insertIndex = 2 end
        
        -- 4. Reconstruction
        local newOrder = {}
        local inserted = false
        
        if insertIndex > #others then
            for _, f in ipairs(others) do table.insert(newOrder, f) end
            table.insert(newOrder, frame)
        else
            local current = 1
            for i = 1, #others do
                if current == insertIndex then
                    table.insert(newOrder, frame)
                    inserted = true
                end
                table.insert(newOrder, others[i])
                current = current + 1
            end
            if not inserted then table.insert(newOrder, frame) end
        end
        
        -- 5. Application
        local changed = false
        if #newOrder ~= #StatsMixin.layoutOrder then changed = true
        else
            for i=1, #newOrder do
                if newOrder[i] ~= StatsMixin.layoutOrder[i] then changed = true; break end
            end
        end

        if changed then
            StatsMixin.layoutOrder = newOrder
            local instance = content:GetParent() -- StatsFrame
            if instance and instance.ReflowLayout then
                instance:ReflowLayout(frame)
            end
        end
    end

    -- Nouvelle fonction pour repositionner tout le monde sans toucher au frame en cours de drag
    function StatsMixin:ReflowLayout(draggingFrame)
        local currentY = -105
        
        for _, f in ipairs(StatsMixin.layoutOrder) do
            if f:IsShown() then
                 if f == draggingFrame then
                     -- On ne touche PAS au Point de celui qui est drag, 
                     -- mais on doit quand même avancer le curseur currentY pour laisser le "trou"
                     if f.isHeader then
                        currentY = currentY - 32
                     else
                        currentY = currentY - 24
                     end
                 else
                     -- On repositionne les autres
                     f:ClearAllPoints()
                     f:SetPoint("TOP", self.Content, "TOP", 0, currentY)
                     
                     if f.isHeader then
                        currentY = currentY - 32
                     else
                        currentY = currentY - 24
                     end
                 end
            end
        end
    end

    function StatsMixin:OnDragStop(frame)
        frame:StopMovingOrSizing()
        frame:SetUserPlaced(false) -- CRITIQUE: Permet au layout de reprendre le contrôle
        frame.isMoving = false
        frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 10) 
        frame:SetAlpha(1.0)
        frame:SetScript("OnUpdate", nil)

        -- Sauvegarde de l'ordre FINAL
        local newOrder = {}
        for _, f in ipairs(StatsMixin.layoutOrder) do
            if f.statKey then
                insert(newOrder, f.statKey)
            end
        end
        
        if MyCharacterPanelDB then
            local guid = UnitGUID("player")
            if not MyCharacterPanelDB.char then MyCharacterPanelDB.char = {} end
            if not MyCharacterPanelDB.char[guid] then MyCharacterPanelDB.char[guid] = {} end
            
            MyCharacterPanelDB.char[guid].statOrder = newOrder
        end
        
        -- On fait un propre UpdateStats pour tout remettre au pixel près et gérer les fonds pairs/impairs (zebra)
        local instance = frame:GetParent():GetParent()
        if instance and instance.UpdateStats then
            instance:UpdateStats()
        end
    end

    -- Fonction Helper pour créer les lignes
    local function CreateStatRow(parent, label, statKey)
        local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        f:SetSize(220, 24)
        f:EnableMouse(true)
        f.Bg = f:CreateTexture(nil, "BACKGROUND")
        f.Bg:SetAllPoints()
        f.Bg:SetColorTexture(1, 1, 1, 0.05)
        f.Bg:Hide()
        
        f.Highlight = f:CreateTexture(nil, "BACKGROUND", nil, 1)
        f.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        f.Highlight:SetBlendMode("ADD")
        f.Highlight:SetAllPoints()
        f.Highlight:SetAlpha(0.2)
        f.Highlight:Hide()
        
        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.Label:SetPoint("LEFT", f, "LEFT", 10, 0)
        f.Label:SetText(label)
        f.Label:SetTextColor(0.7, 0.7, 0.7)
        f.Label:SetJustifyV("MIDDLE") 
        
        f.Value = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.Value:SetPoint("RIGHT", f, "RIGHT", -10, 0)
        f.Value:SetTextColor(1, 1, 1)
        f.Value:SetJustifyV("MIDDLE") 
        
        f.statKey = statKey
        f.isStatRow = true
        
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function(self) StatsMixin:OnDragStart(self) end)
        f:SetScript("OnDragStop", function(self) StatsMixin:OnDragStop(self) end)
        
        f:SetScript("OnEnter", function(self) StatsMixin:OnStatEnter(self) end)
        f:SetScript("OnLeave", function(self) StatsMixin:OnStatLeave(self) end)
        insert(StatsMixin.layoutOrder, f)
        return f
    end

    local function CreateHeader(parent, text, key)
        local f = CreateFrame("Frame", nil, parent)
        f:SetSize(C.STATS_WIDTH_OPEN - 20, 26) 
        f.Bg = f:CreateTexture(nil, "BACKGROUND")
        f.Bg:SetAllPoints()
        f.Bg:SetColorTexture(0, 0, 0, 0.3)
        f.Line = f:CreateTexture(nil, "ARTWORK")
        f.Line:SetHeight(1)
        if C.COLOR_GOLD then
            f.Line:SetColorTexture(C.COLOR_GOLD.r, C.COLOR_GOLD.g, C.COLOR_GOLD.b, 0.4)
        else
            f.Line:SetColorTexture(1, 0.82, 0, 0.4)
        end
        f.Line:SetPoint("BOTTOMLEFT", 0, 0)
        f.Line:SetPoint("BOTTOMRIGHT", 0, 0)
        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        
        -- Header ouvert : sans icône, texte centré

        f.Label:SetPoint("CENTER", 0, 0) 
        f.Label:SetJustifyH("CENTER")
        f.Label:SetText(string.upper(text))
        
        if C.COLOR_GOLD then
            f.Label:SetTextColor(C.COLOR_GOLD.r, C.COLOR_GOLD.g, C.COLOR_GOLD.b) 
        else
             f.Label:SetTextColor(1, 0.82, 0)
        end
        f.isHeader = true
        f.statKey = key -- Clé pour la sauvegarde
        
        -- Les bannières ne sont PLUS déplacables
        f:SetMovable(false)
        
        insert(StatsMixin.layoutOrder, f)
        return f
    end

    self.CatStats = CreateHeader(self.Content, L["TITLE_ATTRIBUTES"], "CAT_ATTRIBUTES")
    self.Str = CreateStatRow(self.Content, _G["SPELL_STAT1_NAME"], 1)
    self.Agi = CreateStatRow(self.Content, _G["SPELL_STAT2_NAME"], 2)
    self.Int = CreateStatRow(self.Content, _G["SPELL_STAT4_NAME"], 4)
    self.Sta = CreateStatRow(self.Content, _G["SPELL_STAT3_NAME"], 3)
    self.Armor = CreateStatRow(self.Content, _G["STAT_ARMOR"], "ARMOR") 

    self.CatEnhance = CreateHeader(self.Content, L["TITLE_ENHANCEMENTS"], "CAT_ENHANCEMENTS")
    self.Crit = CreateStatRow(self.Content, _G["STAT_CRITICAL_STRIKE"], "CRIT")
    self.Haste = CreateStatRow(self.Content, _G["STAT_HASTE"], "HASTE")
    self.Mastery = CreateStatRow(self.Content, _G["STAT_MASTERY"], "MASTERY")
    self.Vers = CreateStatRow(self.Content, _G["STAT_VERSATILITY"], "VERSATILITY")
    self.Leech = CreateStatRow(self.Content, _G["STAT_LIFESTEAL"], "LEECH")
    self.Avoid = CreateStatRow(self.Content, _G["STAT_AVOIDANCE"], "AVOIDANCE")
    self.Speed = CreateStatRow(self.Content, _G["STAT_SPEED"], "SPEED")
    self.Dodge = CreateStatRow(self.Content, _G["STAT_DODGE"], "DODGE")
    self.Parry = CreateStatRow(self.Content, _G["STAT_PARRY"], "PARRY")
    self.Block = CreateStatRow(self.Content, _G["STAT_BLOCK"], "BLOCK")
end

function StatsMixin:UpdateStats()
    -- Initialisation de l'ordre sauvegardé
    if not self.layoutInitialized then
        if MyCharacterPanelDB then
            local guid = UnitGUID("player")
            local charDb = MyCharacterPanelDB.char and MyCharacterPanelDB.char[guid]
            if charDb and charDb.statOrder and #charDb.statOrder > 0 then
                -- Création d'une map pour l'ordre
                local orderMap = {}
                for i, key in ipairs(charDb.statOrder) do
                    orderMap[key] = i
                end
                
                table.sort(StatsMixin.layoutOrder, function(a, b)
                    local idxA = orderMap[a.statKey] or 999
                    local idxB = orderMap[b.statKey] or 999
                    return idxA < idxB
                end)
            end
        end
        self.layoutInitialized = true
    end

    local _, equippedIlvl = GetAverageItemLevel()
    self.ILVLValue:SetText(format("%.1f", equippedIlvl or 0))
    
    local str = UnitStat("player", 1) or 0
    local agi = UnitStat("player", 2) or 0
    local intel = UnitStat("player", 4) or 0
    local sta = UnitStat("player", 3) or 0
    local _, effectiveArmor = UnitArmor("player")
    effectiveArmor = effectiveArmor or 0
    
    local spec = GetSpecialization()
    local primaryStatID = 0
    if spec then
        local _, _, _, _, _, _, pStat = GetSpecializationInfo(spec)
        primaryStatID = pStat or 0
    else
        local _, classFile = UnitClass("player")
        if C.CLASS_DEFAULT_STAT then
            primaryStatID = C.CLASS_DEFAULT_STAT[classFile] or 4
        else
            primaryStatID = 4
        end
    end

    if not primaryStatID or primaryStatID == 0 then
        if intel > str and intel > agi then primaryStatID = 4
        elseif agi > str and agi > intel then primaryStatID = 2
        else primaryStatID = 1 end
    end

    self.Str:SetShown(primaryStatID == 1)
    self.Agi:SetShown(primaryStatID == 2)
    self.Int:SetShown(primaryStatID == 4)
    self.Sta:SetShown(true)
    self.Armor:SetShown(true)

    self.Str.Value:SetText(FormatValue(str))
    self.Agi.Value:SetText(FormatValue(agi))
    self.Int.Value:SetText(FormatValue(intel))
    self.Sta.Value:SetText(FormatValue(sta))
    self.Armor.Value:SetText(FormatValue(effectiveArmor))

    -- Calcul Critique
    local spellCrit = GetSpellCritChance() or 0
    local rangedCrit = GetRangedCritChance() or 0
    local meleeCrit = GetCritChance() or 0
    local critVal = meleeCrit
    if (spellCrit >= rangedCrit) and (spellCrit >= meleeCrit) then critVal = spellCrit
    elseif (rangedCrit >= meleeCrit) then critVal = rangedCrit end

    local hasteVal = GetHaste() or 0
    local masteryVal = GetMasteryEffect() or 0
    local versVal = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local leechVal = GetLifesteal() or 0
    local avoidVal = GetAvoidance() or 0
    local speedVal = GetSpeed() or 0
    local dodgeVal = GetDodgeChance() or 0
    local dodgeRating = GetCombatRating(CR_DODGE) or 0 
    local parryVal = GetParryChance() or 0
    local blockChance = GetBlockChance() or 0

    self.Crit.Value:SetText(format("%.2f%%", critVal))
    self.Haste.Value:SetText(format("%.2f%%", hasteVal))
    self.Mastery.Value:SetText(format("%.2f%%", masteryVal))
    self.Vers.Value:SetText(format("%.2f%%", versVal))
    self.Leech.Value:SetText(format("%.2f%%", leechVal))
    self.Avoid.Value:SetText(format("%.2f%%", avoidVal))
    self.Speed.Value:SetText(format("%.2f%%", speedVal))
    self.Dodge.Value:SetText(format("%.2f%%", dodgeVal))
    self.Parry.Value:SetText(format("%.2f%%", parryVal))
    self.Block.Value:SetText(format("%.2f%%", blockChance))

    self.Crit:SetShown(critVal > 0)
    self.Haste:SetShown(hasteVal > 0)
    self.Mastery:SetShown(masteryVal > 0)
    self.Vers:SetShown(versVal > 0)
    self.Leech:SetShown(leechVal > 0)
    self.Avoid:SetShown(avoidVal > 0)
    self.Speed:SetShown(speedVal > 0)
    self.Dodge:SetShown(dodgeRating > 0)
    self.Parry:SetShown(parryVal > 0)
    self.Block:SetShown(blockChance > 0 and IsWearingShield())
    
    local currentY = -105 
    local zebraIndex = 0

    for _, frame in ipairs(StatsMixin.layoutOrder) do
        if frame:IsShown() then
            if frame:IsMovable() then frame:SetUserPlaced(false) end -- Sécurité supplémentaire
            frame:ClearAllPoints()
            frame:SetPoint("TOP", self.Content, "TOP", 0, currentY)
            
            if frame.isHeader then
                currentY = currentY - 32 
                zebraIndex = 0 
            else
                currentY = currentY - 24 
                if frame.Bg then
                    if (zebraIndex % 2 == 0) then
                        frame.Bg:Show()
                        frame.Bg:SetColorTexture(1, 1, 1, 0.03) 
                    else
                        frame.Bg:Hide() 
                    end
                end
                zebraIndex = zebraIndex + 1
            end
        end
    end

    self.fullHeight = abs(currentY) + 10
    
    local parent = self:GetParent()
    if parent and parent.UpdateStatsHeight then 
        parent:UpdateStatsHeight(self.fullHeight)
    elseif parent and parent.isStatsOpen then 
        self:SetHeight(self.fullHeight) 
    end
end