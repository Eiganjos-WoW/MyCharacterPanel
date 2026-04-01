local _, addon = ...
addon.Monnaies = {}

-- Affiche et place l'onglet des monnaies
function addon.Monnaies:Update()
    if TokenFrame then
        TokenFrame:ClearAllPoints()
        TokenFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 10, -60)
        TokenFrame:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -10, 10)

        if TokenFrame.filterDropdown then
            TokenFrame.filterDropdown:ClearAllPoints()
            TokenFrame.filterDropdown:SetPoint("TOPLEFT", TokenFrame, "TOPLEFT", 20, 20)
        end

        if TokenFrame.CurrencyTransferLogToggleButton then
            TokenFrame.CurrencyTransferLogToggleButton:ClearAllPoints()
            TokenFrame.CurrencyTransferLogToggleButton:SetPoint("LEFT", TokenFrame.filterDropdown, "RIGHT", 10, 0)
        end

        local anchor = TokenFrame.CurrencyTransferLogToggleButton or TokenFrame.filterDropdown
        addon.Outils.CreateInfoBanner(TokenFrame, addon.L["COMING_SOON"], anchor, 15, 0)

        if TokenFrame.Background then TokenFrame.Background:Hide() end
    end
end

-- Cache l'onglet des monnaies
function addon.Monnaies:Hide()
end
