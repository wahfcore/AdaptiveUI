local _, A = ...














A.combatGlow = { color = { 1.00, 0.18, 0.12 }, stud = { 1.00, 0.30, 0.24 }, alpha = 0.85, from = 1, to = 0.35, period = 0.6 }

local function pulse(frame, target)
    local g = frame:CreateAnimationGroup()
    g:SetLooping("BOUNCE")
    local a = g:CreateAnimation("Alpha")
    a:SetFromAlpha(A.combatGlow.from); a:SetToAlpha(A.combatGlow.to); a:SetDuration(A.combatGlow.period)
    a:SetTarget(target)
    return g
end

local function glowHost(self, parent)
    local host = self:Own(CreateFrame("Frame", nil, parent))
    host:EnableMouse(false)
    host:SetSize(1, 1)
    host.glow = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 6))
    host.glow:SetTexture(self.artPath .. "diamond-glow.tga", "CLAMP", "CLAMP")
    host.glow:SetBlendMode("ADD")
    local c = A.combatGlow.color
    host.glow:SetVertexColor(c[1], c[2], c[3], A.combatGlow.alpha)
    host.pulse = pulse(host, host.glow)
    host:Hide()
    return host
end

function A:CombatDiamondsOn()
    return self.db ~= nil and self.optionIndex ~= nil and self:GetOption("combatDiamonds") ~= false
end


local function plateDiamond(self, on)
    local plate = self.plusActive and self.plus and self.plus.player
    local host = self.combatPlateHost
    if not plate then
        if host and host:IsShown() then host.pulse:Stop(); host:Hide() end
        return false
    end
    if not host then
        host = glowHost(self, plate)
        host:SetAllPoints(plate)
        host.stud = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 7))
        host.stud:SetTexture(self.artPath .. "oak-stud-mark.tga", "CLAMP", "CLAMP")
        local s = A.combatGlow.stud
        host.stud:SetVertexColor(s[1], s[2], s[3], 1)
        self.combatPlateHost = host
    end
    if not on then
        if host:IsShown() then host.pulse:Stop(); host:Hide() end
        return false
    end
    local level = (self:Number(plate.GetFrameLevel, 1, plate) or 1) + (A.plateRankLift or 10) + 1
    if host:GetFrameLevel() ~= level then host:SetFrameLevel(level) end
    local fromTail, y, size = self:PlateDiamond(false)
    local mirror = self:GetOption("plusMirror") and plate.mirror == true or false
    local side = mirror and "LEFT" or "RIGHT"
    local x = (mirror and 1 or -1) * fromTail
    local s = self:PlusSnap(size * 1.25)
    host.stud:ClearAllPoints(); host.stud:SetPoint("CENTER", plate, "TOP" .. side, x, -y); host.stud:SetSize(s, s)
    host.glow:ClearAllPoints(); host.glow:SetPoint("CENTER", plate, "TOP" .. side, x, -y); host.glow:SetSize(s * 2.8, s * 2.8)
    if not host:IsShown() then host:Show(); host.pulse:Play() end
    return true
end


local function slateDiamond(self, on)
    local stud = self.slateStud
    local host = self.combatSlateHost
    if not (on and stud and stud:IsShown()) then
        if host and host:IsShown() then host.pulse:Stop(); host:Hide() end
        return false
    end
    if not host then
        host = glowHost(self, UIParent)
        self.combatSlateHost = host
    end




    local owner = type(stud.GetParent) == "function" and stud:GetParent() or nil
    local strata = owner and self:Text(owner.GetFrameStrata, 1, owner) or "MEDIUM"
    if host.auiStrata ~= strata then host.auiStrata = strata; host:SetFrameStrata(strata) end
    local level = ((owner and self:Number(owner.GetFrameLevel, 1, owner)) or 1) + 2
    if host:GetFrameLevel() ~= level then host:SetFrameLevel(level) end
    local h = self:Number(stud.GetHeight, 1, stud) or 16
    host:ClearAllPoints()
    host:SetPoint("CENTER", stud, "CENTER", 0, 0)
    host:SetSize(h, h)
    host.glow:ClearAllPoints()
    host.glow:SetPoint("CENTER", stud, "CENTER", 0, 0)
    host.glow:SetSize(h * 2.6, h * 2.6)
    if not host:IsShown() then host:Show(); host.pulse:Play() end
    return true
end


function A:SetCombatDiamonds(fighting)
    local on = fighting == true and self:CombatDiamondsOn()
    pcall(plateDiamond, self, on)
    pcall(slateDiamond, self, on)
end
