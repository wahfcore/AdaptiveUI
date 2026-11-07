local _, A = ...























A.comboDiamond = {
    low = { 0.32, 0.62, 1.00 }, high = { 1.00, 0.78, 0.30 }, empty = { 0.16, 0.17, 0.20, 0.95 },
    glow = 2.2, pulse = 3.0, star = 1.7,


    pulseFrom = 0.4, pulseTo = 1, pulsePeriod = 0.8, sparkFrom = 0.45, sparkPeriod = 0.8, spin = 4,

    goldAt = 0.5, pulseAt = 0.7, sparkAt = 0.95,
}
local STAR = "Interface\\Cooldown\\star4"

function A:ComboStyle()
    if not (self.db and self.optionIndex and self.optionIndex.comboStyle) then return "diamond" end
    return self:GetOption("comboStyle")
end

local function colourOf(c)
    if type(CreateColor) == "function" then return CreateColor(c[1], c[2], c[3], 1) end
    return { r = c[1], g = c[2], b = c[3], a = 1 }
end


function A:ComboCurves()
    if self.comboCurves ~= nil then return self.comboCurves or nil end
    local cd = A.comboDiamond
    local ok, made = pcall(function()
        local step = type(Enum) == "table" and type(Enum.LuaCurveType) == "table" and Enum.LuaCurveType.Step
        local colour = C_CurveUtil.CreateColorCurve()
        if step ~= nil then colour:SetType(step) end
        local lo, hi = colourOf(cd.low), colourOf(cd.high)
        colour:AddPoint(0, lo); colour:AddPoint(cd.goldAt, hi)
        colour:AddPoint(1.01, lo); colour:AddPoint(cd.goldAt * 100, hi)
        local function gate(at)
            local c = C_CurveUtil.CreateCurve()
            if step ~= nil then c:SetType(step) end
            c:AddPoint(0, 0); c:AddPoint(at, 1); c:AddPoint(1.01, 0); c:AddPoint(at * 100, 1)
            return c
        end
        return { colour = colour, pulse = gate(cd.pulseAt), spark = gate(cd.sparkAt) }
    end)
    self.comboCurves = (ok and type(made) == "table") and made or false
    return self.comboCurves or nil
end

local function bar(parent, file, size, i, add)
    local b = CreateFrame("StatusBar", nil, parent)
    b:SetSize(size, size)
    b:SetStatusBarTexture(file)
    b:SetMinMaxValues(i - 1, i)
    b:SetValue(0)
    b:EnableMouse(false)
    if add then
        local t = b:GetStatusBarTexture()
        if t and type(t.SetBlendMode) == "function" then t:SetBlendMode("ADD") end
    end
    return b
end

local function loop(frame, target, from, to, period)
    local g = frame:CreateAnimationGroup()
    g:SetLooping("BOUNCE")
    local a = g:CreateAnimation("Alpha")
    a:SetFromAlpha(from); a:SetToAlpha(to); a:SetDuration(period)
    if target then a:SetTarget(target) end
    return g
end


local function build(self, frame, MAX)
    local cd, c = A.comboDiamond, A.classBar
    local stud, glow = self.artPath .. "oak-stud-mark.tga", self.artPath .. "diamond-glow.tga"
    local dots = frame.dots
    frame.dGlow = CreateFrame("Frame", nil, dots); frame.dGlow:SetAllPoints(dots); frame.dGlow:EnableMouse(false)
    frame.dPulseGate = CreateFrame("Frame", nil, dots); frame.dPulseGate:SetAllPoints(dots); frame.dPulseGate:EnableMouse(false)
    frame.dPulse = CreateFrame("Frame", nil, frame.dPulseGate); frame.dPulse:SetAllPoints(dots); frame.dPulse:EnableMouse(false)
    frame.dSparkGate = CreateFrame("Frame", nil, dots); frame.dSparkGate:SetAllPoints(dots); frame.dSparkGate:EnableMouse(false)
    frame.dSpark = CreateFrame("Frame", nil, frame.dSparkGate); frame.dSpark:SetAllPoints(dots); frame.dSpark:EnableMouse(false)
    frame.dStuds = CreateFrame("Frame", nil, dots); frame.dStuds:SetAllPoints(dots); frame.dStuds:EnableMouse(false)
    local base = (self:Number(dots.GetFrameLevel, 1, dots) or 1)
    frame.dGlow:SetFrameLevel(base + 1); frame.dPulseGate:SetFrameLevel(base + 2); frame.dPulse:SetFrameLevel(base + 2)
    frame.dStuds:SetFrameLevel(base + 4); frame.dSparkGate:SetFrameLevel(base + 6); frame.dSpark:SetFrameLevel(base + 6)
    frame.dPulseAnim = loop(frame.dPulse, nil, cd.pulseFrom, cd.pulseTo, cd.pulsePeriod)
    frame.dSparkAnim = loop(frame.dSpark, nil, cd.sparkFrom, 1, cd.sparkPeriod)

    dots:HookScript("OnHide", function() A:ComboLoops(frame, false) end)
    dots:HookScript("OnShow", function() if frame.dWanted then A:ComboLoops(frame, true) end end)
    for i = 1, MAX do
        local d = frame.dot[i]
        d.dEmpty = frame.dStuds:CreateTexture(nil, "BACKGROUND")
        d.dEmpty:SetTexture(stud, "CLAMP", "CLAMP")
        d.dEmpty:SetVertexColor(cd.empty[1], cd.empty[2], cd.empty[3], cd.empty[4])
        d.dFill = bar(frame.dStuds, stud, c.dot, i, false)
        d.dGlow = bar(frame.dGlow, glow, c.dot * cd.glow, i, true)
        d.dPulse = bar(frame.dPulse, glow, c.dot * cd.pulse, i, true)
        d.dStar = frame.dSpark:CreateTexture(nil, "OVERLAY")
        d.dStar:SetTexture(STAR)
        d.dStar:SetBlendMode("ADD")
        d.dStar:SetSize(c.dot * cd.star, c.dot * cd.star)
        d.dStar:SetVertexColor(cd.high[1], cd.high[2], cd.high[3], 1)


        pcall(function()
            local r = frame.dSparkAnim:CreateAnimation("Rotation")
            r:SetDegrees((i % 2 == 0) and 90 or -90); r:SetDuration(cd.sparkPeriod); r:SetTarget(d.dStar)
        end)
    end
end

local function parts(d)
    return { d.dEmpty, d.dFill, d.dGlow, d.dPulse, d.dStar }
end


function A:ComboDiamondsShown(frame, n, MAX)
    local on = self:ComboStyle() ~= "dots"
    if on and not frame.dStuds then
        if not pcall(build, self, frame, MAX) then
            frame.dStuds = nil
            return false
        end
    end
    local c = A.classBar
    for i = 1, MAX do
        local d = frame.dot[i]
        local show = i <= n
        d.socket:SetShown(show and not on); d.fill:SetShown(show and not on)
        if d.dEmpty then
            for _, p in ipairs(parts(d)) do p:SetShown(show and on) end
            if on and show then
                for _, p in ipairs({ d.dEmpty, d.dFill, d.dGlow, d.dPulse, d.dStar }) do
                    p:ClearAllPoints(); p:SetPoint("CENTER", d.socket, "CENTER", 0, 0)
                end
                d.dEmpty:SetSize(c.dot, c.dot)
            end
        end
    end
    if frame.dStuds then
        for _, f in ipairs({ frame.dGlow, frame.dPulseGate, frame.dSparkGate, frame.dStuds }) do f:SetShown(on) end




        local level = self:MotionLevel()
        local want = on and self:ComboLoopsWanted() or false
        if want ~= (frame.dWanted == true) or level ~= frame.dLevel then
            frame.dWanted, frame.dLevel = want or nil, level
            self:ComboLoops(frame, want)
        end
    end
    return on
end

function A:ComboLoopsWanted()
    if self.inCombat then return true end
    local value, status = self:Read(UnitPower, 1, "player", self.comboType)
    local max = self:ClassBarDotCount()
    return status == "public" and type(value) == "number" and max > 0 and value / max >= A.comboDiamond.pulseAt
end


function A:ComboRecheck()
    local frame = self.compactHUD
    if frame and frame.dStuds and frame.dots and frame.dots:IsShown() then
        self:ComboDiamondsShown(frame, self:ClassBarDotCount(), #frame.dot)
    end
end


function A:ComboLoops(frame, on)
    local cd = A.comboDiamond
    for _, pair in ipairs({ { frame.dPulseAnim, frame.dPulse, cd.pulseFrom }, { frame.dSparkAnim, frame.dSpark, cd.sparkFrom } }) do
        local group, host, low = pair[1], pair[2], pair[3]
        local playing = group:IsPlaying()
        if on and self:MotionRepeats() and (playing or self:MotionLoopCount() < self.motionLoopBudget) then
            if not playing then group:Play() end
            self.motionLoops[group] = true
        else
            if playing then group:Stop() end
            self.motionLoops[group] = nil
            host:SetAlpha(on and self:MotionOn() and (low + 1) / 2 or (on and 1 or 0))
        end
    end
end

local function paint(textures, r, g, b)
    for _, t in ipairs(textures) do pcall(t.SetVertexColor, t, r, g, b, 1) end
end


function A:FillComboDiamonds(frame, MAX, comboType)
    local cd = A.comboDiamond
    local tex = {}
    for i = 1, MAX do
        local d = frame.dot[i]
        for _, b in ipairs({ d.dFill, d.dGlow, d.dPulse }) do
            if not pcall(function() b:SetValue(UnitPower("player", comboType)) end) then b:SetValue(i - 1) end
            tex[#tex + 1] = b:GetStatusBarTexture()
        end
    end
    local curves = self:ComboCurves()
    if curves and type(UnitPowerPercent) == "function" then
        local okc, col = pcall(UnitPowerPercent, "player", comboType, false, curves.colour)
        local okp, pulse = pcall(UnitPowerPercent, "player", comboType, false, curves.pulse)
        local oks, spark = pcall(UnitPowerPercent, "player", comboType, false, curves.spark)
        if okc and type(col) == "table" and okp and oks and pulse ~= nil and spark ~= nil then

            paint(tex, col.r, col.g, col.b)
            local a = pcall(frame.dPulseGate.SetAlpha, frame.dPulseGate, pulse)
            local b = pcall(frame.dSparkGate.SetAlpha, frame.dSparkGate, spark)
            if a and b then
                self.comboPath = "curve"
                return "curve"
            end
        end
    end

    local value, status = self:Read(UnitPower, 1, "player", comboType)
    local max = self:ClassBarDotCount()
    if status == "public" and type(value) == "number" and max > 0 then
        local f = value / max
        local c = f >= cd.goldAt and cd.high or cd.low
        paint(tex, c[1], c[2], c[3])
        frame.dPulseGate:SetAlpha(f >= cd.pulseAt and 1 or 0)
        frame.dSparkGate:SetAlpha(f >= cd.sparkAt and 1 or 0)
        self.comboPath = "public"
        return "public"
    end
    for i = 1, MAX do
        local d = frame.dot[i]
        local c = (i / max) >= cd.goldAt and cd.high or cd.low
        paint({ d.dFill:GetStatusBarTexture(), d.dGlow:GetStatusBarTexture(), d.dPulse:GetStatusBarTexture() }, c[1], c[2], c[3])
    end
    frame.dPulseGate:SetAlpha(0); frame.dSparkGate:SetAlpha(0)
    self.comboPath = "static"
    return "static"
end
