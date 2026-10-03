local _, A = ...



















local placed = setmetatable({}, { __mode = "k" })

A.plateAuras = { size = 24, spacing = 3, perRow = 8, debuffs = 8, buffs = 16, gap = 4 }

local function configure(container, unit)
    local c = A.plateAuras
    local layout = { elementWidth = c.size, elementHeight = c.size, elementSpacing = c.spacing,
        lineSpacing = c.spacing, groupLineSpacing = c.spacing, forceNewLine = true }
    container:SetUnit(unit)
    container:AddAuraGroup("debuffs", "HARMFUL", { maxFrameCount = c.debuffs, layout = layout })
    container:AddAuraGroup("buffs", "HELPFUL", { maxFrameCount = c.buffs, layout = layout })
end

function A:CreatePlateAuras(plate, unit)
    if not plate or plate.auraContainer ~= nil then return plate and plate.auraContainer end
    plate.auraContainer = false
    local ok, container = pcall(CreateFrame, "AuraContainer", plate:GetName() and (plate:GetName() .. "Auras") or nil,
        plate, "CustomAuraContainerTemplate")
    if not ok or type(container) ~= "table" or type(container.AddAuraGroup) ~= "function" then
        self.plateAuraStatus = "unavailable: this client has no CustomAuraContainerTemplate"
        return nil
    end
    local configured, err = pcall(configure, container, unit)
    if not configured then
        self.plateAuraStatus = "refused: " .. tostring(err):sub(1, 120)
        pcall(container.Hide, container)
        return nil
    end
    plate.auraContainer = container
    self.plateAuraStatus = "client aura container on " .. unit
    return container
end



function A:PlaceTargetAuras()
    local plus = self.plus
    local plate = plus and plus.target
    local container = plate and plate.auraContainer
    if not container then return end
    local on = self.db and self.optionIndex and self.optionIndex.plusTargetAuras and self:GetOption("plusTargetAuras")
    if not on then container:Hide(); return end
    local anchor = plate
    if self:GetOption("plusTotOn") and self:GetOption("plusTotPlacement") == "below" and plus.tot and plus.tot:IsShown() then
        anchor = plus.tot
    end
    local mirrored = self:GetOption("plusMirror") and plate.mirror == true
    local side = mirrored and "RIGHT" or "LEFT"


    local seat = placed[container]
    if not seat or seat[1] ~= anchor or seat[2] ~= side then
        placed[container] = { anchor, side }
        container:ClearAllPoints()
        container:SetPoint("TOP" .. side, anchor, "BOTTOM" .. side, 0, -A.plateAuras.gap)
    end
    if not container:IsShown() then container:Show() end
end
