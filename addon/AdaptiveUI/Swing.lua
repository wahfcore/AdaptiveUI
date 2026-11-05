local _, A = ...




















A.swingNames = { [0] = "Swing", [1] = "Off hand", [2] = "Ranged" }
A.swingFarAlpha = 0.4
A.swing = { [0] = {}, [1] = {}, [2] = {} }

local function now() return GetTime() end

local function running(s, t)
    return s.ends ~= nil and s.ends > t
end

function A:OnSwingEvent(event, ...)
    if event == "PLAYER_SWING" then
        local duration, kind = ...
        if not (self:IsPublic(duration) and self:IsPublic(kind)) then return end
        if type(duration) ~= "number" or duration ~= duration or duration <= 0 or duration > 10 then return end
        local s = self.swing[kind]
        if not s then return end
        s.duration, s.ends = duration, now() + duration
    elseif event == "PLAYER_SWING_RANGE_UPDATE" then
        local kind, inRange, checks = ...
        if not (self:IsPublic(kind) and self:IsPublic(inRange) and self:IsPublic(checks)) then return end
        local s = self.swing[kind]
        if not s then return end
        s.far = checks == true and inRange == false
    end
    self:UpdateCompactHUD(self.identity)
end




function A:VitalsShown()
    if not (self.GetOption and self:GetOption("swingVitals") == true) then return false end
    if self.inCombat then return true end
    if self:GetOption("plusSwing") == false then return false end
    local t = now()
    for kind = 0, 2 do
        if running(self.swing[kind], t) then return true end
    end
    return false
end

local function sinkVital(bar, kind, powerType)
    if kind == "health" then
        bar:SetMinMaxValues(0, UnitHealthMax("player"))
        bar:SetValue(UnitHealth("player"))
    else
        bar:SetMinMaxValues(0, UnitPowerMax("player", powerType))
        bar:SetValue(UnitPower("player", powerType))
    end
end

local POWER_NAMES = { MANA = "Mana", RAGE = "Rage", ENERGY = "Energy", FOCUS = "Focus", RUNIC_POWER = "Runic power" }

local POWER_COLOURS = { MANA = "trayColorMana", RAGE = "trayColorRage", ENERGY = "trayColorEnergy", FOCUS = "trayColorFocus" }




function A:TrayFree()
    return self.GetOption ~= nil and self:GetOption("trayAnchor") == "free"
end



function A:TrayFreeTop(m)
    m = m or self:LayoutMetrics()
    if self.plusActive and self.plus and self.plus.player and self.PlusBase then
        local bx, by = self:PlusBase("plusPlayer", m)
        local h = (self:Number(self.plus.player.GetHeight, 1, self.plus.player) or 54) * m.unitScale
        local below = ((self.PlusBelow and self:PlusBelow() or 0) + self.tokens.space.sm) * m.unitScale
        return bx, by - h / 2 - below
    end
    return m.unitX - (m.unitDX or 205), m.unitY - 60
end


function A:TrayBarHeight()
    local h = self.GetOption and tonumber(self:GetOption("trayBarHeight")) or A.classBar.manaH
    return math.max(4, math.min(14, math.floor(h + 0.5)))
end


function A:TrayColor(key, fallback)
    local c = self.GetOption and self:GetOption(key)
    if type(c) == "table" and type(c[1]) == "number" then return c[1], c[2], c[3] end
    return fallback[1], fallback[2], fallback[3]
end

function A:FillVitals(frame)
    local token = self:Text(UnitPowerType, 2, "player")
    local powerType = self:Number(UnitPowerType, 1, "player")
    local health, power = frame.vital.health, frame.vital.power
    health.label:SetText("Health")
    power.label:SetText(POWER_NAMES[token or ""] or "Power")
    health.bar:SetStatusBarColor(self:TrayColor("trayColorHealth", { 0.42, 0.80, 0.49 }))
    local own = POWER_COLOURS[token or ""]
    local colour = token and PowerBarColor and PowerBarColor[token]
    self.themed[power.bar] = nil
    if own then
        power.bar:SetStatusBarColor(self:TrayColor(own, { 0.25, 0.50, 1 }))
    elseif type(colour) == "table" and type(colour.r) == "number" then
        power.bar:SetStatusBarColor(colour.r, colour.g, colour.b)
    else
        self:Tint(power.bar, "info", "bar")
    end
    for kind, row in pairs(frame.vital) do
        if not pcall(sinkVital, row.bar, kind, powerType) then
            row.bar:SetMinMaxValues(0, 1); row.bar:SetValue(0)
        end

        self:SetPlusNumber(row.value, kind, "player", powerType, kind == "health")
    end
end


function A:SwingRows()
    if self.GetOption and self:GetOption("plusSwing") == false then return nil end
    local t, rows, any = now(), {}, false
    for kind = 0, 2 do
        if running(self.swing[kind], t) then rows[kind], any = true, true end
    end
    if self.inCombat then rows[0], any = true, true end
    return any and rows or nil
end

function A:FillSwing(frame)
    local t = now()
    local r, g, b = self:TrayColor("trayColorSwing", { 0.88, 0.76, 0.50 })
    for kind = 0, 2 do
        local row, s = frame.swing[kind], self.swing[kind]
        row.bar:SetStatusBarColor(r, g, b)
        if running(s, t) then
            local left = s.ends - t
            row.bar:SetMinMaxValues(0, s.duration)
            row.bar:SetValue(s.duration - left)
            row.time:SetText(string.format("%.1f", left))
        else
            row.bar:SetMinMaxValues(0, 1)
            row.bar:SetValue(0)
            row.time:SetText("")
        end
        local alpha = s.far and A.swingFarAlpha or 1
        row.bar:SetAlpha(alpha); row.label:SetAlpha(alpha); row.time:SetAlpha(alpha)
    end
end


local vitalsTick = 0
function A:TickSwing(elapsed)
    local frame = self.compactHUD
    if not (frame and self.unitIntegrated and self.db and self.db.enabled and not self.sessionDisabled) then return end
    if self:GetOption("plusSwing") == false then return end
    local rows = frame.rows and frame.rows.swing
    if not rows then

        local t = now()
        for kind = 0, 2 do
            if running(self.swing[kind], t) then self:UpdateCompactHUD(self.identity); return end
        end
        return
    end
    local want = self:SwingRows()
    for kind = 0, 2 do
        if (want and want[kind] or false) ~= (rows[kind] or false) then
            self:UpdateCompactHUD(self.identity)
            return
        end
    end
    if frame:IsShown() then
        self:FillSwing(frame)
        vitalsTick = vitalsTick + (elapsed or 0)
        if frame.rows.vitals and vitalsTick >= 0.1 then vitalsTick = 0; self:FillVitals(frame) end
    end
end
