local _, A = ...



















local placed = setmetatable({}, { __mode = "k" })

A.plateAuras = { size = 24, spacing = 3, perRow = 8, debuffs = 8, buffs = 16, gap = 4 }












local function initButton(button)
    local c = A.plateAuras
    pcall(function()
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(button)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button:SetIcon(icon)
    end)
    pcall(function()
        local edge = button:CreateTexture(nil, "BACKGROUND")
        edge:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
        edge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
        A:Tint(edge, "shadow", "color", 0.85)
    end)
    pcall(function()
        local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cd:SetAllPoints(button)
        if cd.SetDrawEdge then cd:SetDrawEdge(false) end
        if cd.SetHideCountdownNumbers then cd:SetHideCountdownNumbers(true) end
        button:SetDurationCooldown(cd)
    end)
    pcall(function()
        local count = button:CreateFontString(nil, "OVERLAY")

        count:SetFont(A:FontPath(false), c.countPx or 11, "OUTLINE")
        count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
        button:SetApplicationCount(count)
    end)
end
A.PlateAuraButton = initButton

local function configure(container, unit)
    local c = A.plateAuras
    local layout = { elementWidth = c.size, elementHeight = c.size, elementSpacing = c.spacing,
        lineSpacing = c.spacing, groupLineSpacing = c.spacing, forceNewLine = true }
    container:SetUnit(unit)
    container:AddAuraGroup("debuffs", "HARMFUL", { maxFrameCount = c.debuffs, layout = layout, initializeFrame = initButton })
    container:AddAuraGroup("buffs", "HELPFUL", { maxFrameCount = c.buffs, layout = layout, initializeFrame = initButton })



    container:SetEnabled(true)
end











function A:CreatePlateAuras(plate, unit)
    if not plate or plate.auraContainer ~= nil then return plate and plate.auraContainer end
    plate.auraContainer = false
    local base = plate:GetName()
    local holder = CreateFrame("Frame", base and (base .. "AuraHolder") or nil, plate)
    holder:SetSize(1, 1)
    plate.auraHolder = holder
    local ok, container = pcall(CreateFrame, "AuraContainer", base and (base .. "Auras") or nil,
        holder, "CustomAuraContainerTemplate")
    if not ok or type(container) ~= "table" or type(container.AddAuraGroup) ~= "function" then
        self.plateAuraStatus = "unavailable: this client has no CustomAuraContainerTemplate"
        return nil
    end


    local mirrored = self.db and self:GetOption("plusMirror") and plate.mirror == true
    local side = mirrored and "TOPRIGHT" or "TOPLEFT"
    local seated = pcall(function()
        container:ClearAllPoints()
        container:SetPoint(side, holder, side, 0, 0)
    end)
    if not seated then
        self.plateAuraStatus = "refused: the container could not be seated"
        return nil
    end
    plate.auraSide = mirrored and "RIGHT" or "LEFT"
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
    if not on then if plate.auraHolder then plate.auraHolder:Hide() end; return end
    local anchor = plate
    if self:GetOption("plusTotOn") and self:GetOption("plusTotPlacement") == "below" and plus.tot and plus.tot:IsShown() then
        anchor = plus.tot
    end

    local holder = plate.auraHolder
    local side = plate.auraSide or "LEFT"
    local seat = placed[holder]
    if not seat or seat[1] ~= anchor or seat[2] ~= side then
        placed[holder] = { anchor, side }
        holder:ClearAllPoints()
        holder:SetPoint("TOP" .. side, anchor, "BOTTOM" .. side, 0, -A.plateAuras.gap)
    end
    if not holder:IsShown() then holder:Show() end




    if self.targetAurasStale then
        self.targetAurasStale = nil
        pcall(container.UpdateAllAuras, container)
    end
end


function A:PlateAuraLine()
    local plate = self.plus and self.plus.target
    local container = plate and plate.auraContainer
    local enabled = container and type(container.IsEnabled) == "function" and select(2, pcall(container.IsEnabled, container))
    return "Target auras: " .. tostring(self.plateAuraStatus or "not created (plates off)")
        .. (container and (" | enabled " .. tostring(enabled) .. " | shown " .. tostring(container:IsShown())) or "")
end





local function show(self, v)
    if not self:IsPublic(v) then return "secret" end
    if type(v) == "number" then return string.format("%.1f", v) end
    if type(v) == "string" or type(v) == "boolean" or v == nil then return tostring(v) end
    return type(v)
end

local function call(self, obj, name, ...)
    local okIndex, fn = pcall(function() return obj[name] end)
    if not okIndex then return "refused" end
    if type(fn) ~= "function" then return "n/a" end
    local res = { pcall(fn, obj, ...) }
    if not res[1] then return "error" end
    local out = {}
    for i = 2, math.min(#res, 5) do out[#out + 1] = show(self, res[i]) end
    return #out > 0 and table.concat(out, " ") or "-"
end

local function count(self, filter)
    local api = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(api) ~= "function" then return "n/a" end
    local n = 0
    for i = 1, 40 do
        local ok, data = pcall(api, "target", i, filter)
        if not ok then return "error" end
        if data == nil then break end
        n = n + 1
    end
    return tostring(n)
end

function A:AuraProbe(say)
    say(self:PlateAuraLine())
    local plate = self.plus and self.plus.target
    say("  plates on " .. tostring(self.plusActive) .. " | target plate shown " .. tostring(plate and plate:IsShown())
        .. " | option " .. tostring(self.db and self:GetOption("plusTargetAuras")))
    say("  the game sees on target: buffs " .. count(self, "HELPFUL") .. " | debuffs " .. count(self, "HARMFUL"))
    local holder = plate and plate.auraHolder
    if holder then
        say("  holder shown " .. call(self, holder, "IsShown") .. " | visible " .. call(self, holder, "IsVisible")
            .. " | rect " .. call(self, holder, "GetRect") .. " | strata " .. call(self, holder, "GetFrameStrata")
            .. " | level " .. call(self, holder, "GetFrameLevel"))
    end
    local c = plate and plate.auraContainer
    if not c then return end
    say("  unit " .. call(self, c, "GetUnit") .. " | enabled " .. call(self, c, "IsEnabled") .. " | shown "
        .. call(self, c, "IsShown") .. " | visible " .. call(self, c, "IsVisible"))
    say("  rect " .. call(self, c, "GetRect") .. " | alpha " .. call(self, c, "GetEffectiveAlpha")
        .. " | level " .. call(self, c, "GetFrameLevel") .. " | points " .. call(self, c, "GetNumPoints"))
    say("  frames before refresh: debuffs " .. call(self, c, "GetAuraGroupFrameCount", "debuffs")
        .. " | buffs " .. call(self, c, "GetAuraGroupFrameCount", "buffs")
        .. " | groups " .. call(self, c, "HasAuraGroup", "debuffs") .. "/" .. call(self, c, "HasAuraGroup", "buffs"))
    say("  refresh " .. call(self, c, "UpdateAllAuras") .. " | after: debuffs "
        .. call(self, c, "GetAuraGroupFrameCount", "debuffs") .. " | buffs " .. call(self, c, "GetAuraGroupFrameCount", "buffs"))
    for _, group in ipairs({ "buffs", "debuffs" }) do
        local ok, first = pcall(function() return c:GetAuraGroupFrame(group, 1) end)
        if ok and type(first) == "table" then
            say("  first " .. group .. " frame: shown " .. call(self, first, "IsShown") .. " | visible "
                .. call(self, first, "IsVisible") .. " | rect " .. call(self, first, "GetRect") .. " | alpha "
                .. call(self, first, "GetEffectiveAlpha"))
        else
            say("  first " .. group .. " frame: " .. (ok and "none" or "refused"))
        end
    end
end
