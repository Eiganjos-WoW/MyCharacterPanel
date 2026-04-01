-- Fichier gérant les réputations (TODO)
local addonName, addon = ...
addon.Reputation = {}

function addon.Reputation:Update()
    if ReputationFrame then
        ReputationFrame:ClearAllPoints()
        ReputationFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 10, -60)
        ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -10, 10)
        
        if ReputationFrame.filterDropdown then
            ReputationFrame.filterDropdown:ClearAllPoints()
            -- À gauche avec marge
            ReputationFrame.filterDropdown:SetPoint("TOPLEFT", ReputationFrame, "TOPLEFT", 20, 20)
        end

        -- On ajoute le bandeau de développement (discret, à droite du filtre)
        addon.Outils.CreateInfoBanner(ReputationFrame, addon.L["COMING_SOON"], ReputationFrame.filterDropdown, 10, 0)

        -- On s'assure que le fond par défaut ne gêne pas
        if ReputationFrame.Background then ReputationFrame.Background:Hide() end
    end
end

function addon.Reputation:Hide()
end
