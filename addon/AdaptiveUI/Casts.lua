local _, A = ...

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end



local function readCast(self, fn, unit, channel)
    if type(fn) ~= "function" then return nil, "unavailable" end
    local values = { pcall(fn, unit) }
    if not values[1] then return nil, "unavailable" end
    local name, startTime, endTime = values[2], values[5], values[6]


    local texture = self:IsPublic(values[4]) and (type(values[4]) == "number" or type(values[4]) == "string") and values[4] or nil
    local shield = self:IsPublic(values[9]) and type(values[9]) == "boolean" and values[9] or nil
    if not self:IsPublic(name) then return nil, "restricted" end
    if name == nil or name == "" then return nil, "idle" end
    if not self:IsPublic(startTime) or not self:IsPublic(endTime) then return nil, "restricted" end
    if type(name) ~= "string" or not finite(startTime) or not finite(endTime)
        or startTime < 0 or endTime <= startTime then return nil, "invalid" end
    if channel then
        local empowered = values[10]
        if not self:IsPublic(empowered) then return nil, "restricted" end
        if empowered then return nil, "empowered: native display" end
    end
    return { name = self:CleanCastName(name), startTime = startTime / 1000, endTime = endTime / 1000, channel = channel,
        texture = texture, notInterruptible = shield }, "public"
end





function A:CleanCastName(name)
    if type(name) ~= "string" then return name end
    local clean = name:gsub("%s*%-%s*[Nn]o [Tt]ext%s*$", "")
    return clean ~= "" and clean or name
end

function A:GetPublicCast(unit)
    local cast, status = readCast(self, UnitCastingInfo, unit, false)
    if not cast and (status == "idle" or status == "unavailable") then
        return readCast(self, UnitChannelInfo, unit, true)
    end
    return cast, status
end




























local function readAnyCast(self, fn, unit, channel)
    if type(fn) ~= "function" then return nil end
    local values = { pcall(fn, unit) }
    if not values[1] then return nil end
    local name, startTime, endTime = values[2], values[5], values[6]
    local publicName = self:IsPublic(name)


    if publicName and self:IsPublic(startTime) and self:IsPublic(endTime) then return nil end

    if publicName and (name == nil or name == "") then return nil end
    local texture = self:IsPublic(values[4]) and (type(values[4]) == "number" or type(values[4]) == "string")
        and values[4] or nil
    local shield = self:IsPublic(values[9]) and type(values[9]) == "boolean" and values[9] or nil
    return { name = name, startTime = startTime, endTime = endTime, channel = channel,
        texture = texture, notInterruptible = shield }
end

function A:GetRestrictedCast(unit)
    return readAnyCast(self, UnitCastingInfo, unit, false)
        or readAnyCast(self, UnitChannelInfo, unit, true)
end

function A:CreateCastModule(parent, unit, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    frame:SetSize(416, 44)
    frame:EnableMouse(false)
    frame.unit = unit
    frame.plate = self:Panel(frame, 0, 0, 416, 44, "panel")
    frame.nameText = self:Label(frame, self.tokens.type.title, 12, -7, 300)
    frame.timeText = self:Label(frame, self.tokens.type.body, 322, -8, 82, "RIGHT")
    frame.value = CreateFrame("StatusBar", nil, frame)
    frame.value:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -30)
    frame.value:SetSize(392, 7)
    frame.value:EnableMouse(false)
    frame.value:SetStatusBarTexture(self.artPath .. "meter.tga")
    frame.value:SetMinMaxValues(0, 1)
    frame.value:SetValue(0)
    local background = frame.value:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    self:Tint(background, "well", "color")
    frame.finish = {}
    self:BarFinish(frame.finish, frame.value)
    frame:Hide()
    return frame
end

function A:UpdateCastModule(frame)
    local cast, status = self:GetPublicCast(frame.unit)
    self:Note(frame.unit .. " cast", status)
    if not cast then frame:Hide(); return end
    local now = self:Number(GetTime, 1)
    if not finite(now) or now < cast.startTime or now >= cast.endTime then
        frame:Hide()
        return
    end
    local duration = cast.endTime - cast.startTime
    local remaining = cast.endTime - now
    frame.value:SetMinMaxValues(0, duration)
    frame.value:SetValue(cast.channel and remaining or (now - cast.startTime))
    frame.nameText:SetText((frame.unit == "player" and "YOU / " or "TARGET / ") .. cast.name)
    frame.timeText:SetText(string.format("%.1fs", remaining))
    frame:Show()
end

function A:SafeUpdateCasts()
    self:UpdateCastBars()
    if not self.hud or self.sessionDisabled then return end
    for _, frame in ipairs({ self.hud.playerCast, self.hud.targetCast }) do
        if self.unitIntegrated or not self.appliedCasts or frame.failed then
            frame:Hide()
        else
            local ok = pcall(self.UpdateCastModule, self, frame)
            if not ok then
                frame.failed = true
                frame:Hide()
                self:Note(frame.unit .. " cast", "display rejected; native display retained until reload")
            end
        end
    end
end
