local _, A = ...
local function bar(parent, x, y, width, height, labelY)
    local value = CreateFrame("StatusBar", nil, parent)
    value:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    value:SetSize(width, height)
    value:SetStatusBarTexture(A.artPath .. "meter.tga")
    value:SetMinMaxValues(0, 1)
    value:SetValue(0)
    value:EnableMouse(false)
    local background = value:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    A:Tint(background, "well", "color")



    local finish = {}
    A:BarFinish(finish, value)
    local label = A:Label(parent, A.tokens.type.title, x, labelY, width * 0.4)
    local amount = A:Label(parent, A.tokens.type.title, x + width * 0.4, labelY, width * 0.6, "RIGHT")
    return { value = value, label = label, text = amount, finish = finish }
end

function A:SyncIntegratedHUD()
    if not self.hud or self:IsCombat() then return end
    if self.unitIntegrated and not self.sessionDisabled then
        self.hud:Hide()
        if not self.compactHUD then
            local frame = CreateFrame("Frame", "AdaptiveUICompactResource", UIParent)
            self.compactHUD = frame
            frame:SetSize(232, 38)
            frame:EnableMouse(false)
            frame.plate = self:Panel(frame, 0, 0, 232, 38, "panel")
            frame.combo = bar(frame, 12, -25, 208, 7, -5)
            frame.mask = self:ArtTexture(frame.combo.value, "combo", 0, 0, 208, 7, "OVERLAY")


            self:Tint(frame.mask, "well", "vertex")
            self:SetThemedFont(frame.combo.label, self.tokens.type.caption, true)
            self:SetThemedFont(frame.combo.text, self.tokens.type.caption, false)
        end
        local frame = self.compactHUD
        frame:ClearAllPoints()

        local unitScale = self:LayoutMetrics().unitScale * self:MoverScale("compact")
        frame:SetScale(unitScale)
        local ox, oy = self:MoverOffset("compact")
        frame:SetPoint("TOP", (self.plusActive and self.plus) and self.plus.player or PlayerFrame, "BOTTOM",
            ox / unitScale, -2 + oy / unitScale)
        frame.plate:SetAlpha(self.db.opacity)
        frame.combo.value:SetStatusBarColor(unpack(self:Style().combo))
        self:UpdateCompactHUD(self.identity)
    else
        if self.compactHUD then self.compactHUD:Hide() end
        if self.db.enabled and not self.sessionDisabled then self.hud:Show() else self.hud:Hide() end
    end
end

function A:UpdateCompactHUD(identity)
    local frame = self.compactHUD
    if not frame then return end
    if not self.unitIntegrated or not self.db.enabled or self.sessionDisabled
        or not identity or identity.classToken ~= "DRUID" or identity.powerToken ~= "ENERGY" then
        frame:Hide()
        return
    end
    self:UpdateBar(frame.combo, "COMBO", UnitPower, UnitPowerMax, "player", self.comboType)
    frame:Show()
end

function A:CreateHUD()
    local frame = CreateFrame("Frame", "AdaptiveUIHUD", UIParent)
    self.hud = frame
    frame:SetSize(416, 360)
    frame.anchorExtension = 104
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("LOW")
    frame:EnableMouse(false)





    frame.playerPlate = self:Panel(frame, 0, 0, 416, 52, "panel", nil, frame, "playerPlate")
    frame.targetPlate = self:Panel(frame, 24, -64, 392, 48, "panel", nil, frame, "targetPlate")
    frame.resourcePlate = self:Panel(frame, 0, -138, 416, 100, "panel", nil, frame, "resourcePlate")
    frame.playerMark = self:Rule(frame, 14, -14, 8, 8, "muted")
    frame.targetMark = self:Rule(frame, 38, -77, 8, 8, "muted")
    frame.playerName = self:Label(frame, self.tokens.type.hero, 34, -7, 214)
    frame.targetName = self:Label(frame, self.tokens.type.hero, 58, -70, 204)
    frame.input = self:ArtTexture(frame, "pad", 382, -8, 20, 20)
    self:Tint(frame.input, "muted", "vertex")
    frame.playerHealth = bar(frame, 34, -32, 366, 10, -8)
    frame.targetHealth = bar(frame, 58, -94, 342, 8, -71)

    frame.playerHealth.label:Hide()
    frame.targetHealth.label:Hide()
    frame.playerHealth.text:ClearAllPoints()
    frame.playerHealth.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 254, -9)
    frame.playerHealth.text:SetWidth(118)
    frame.targetHealth.text:ClearAllPoints()
    frame.targetHealth.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 270, -72)
    frame.targetHealth.text:SetWidth(130)
    frame.form = self:Label(frame, self.tokens.type.body, 14, -118, 350)
    frame.crest = self:ArtTexture(frame, self:CrestFile(64), 8, -157, 64, 64)
    self:Tint(frame.crest, "muted", "vertex")
    frame.spark = self:ArtTexture(frame, "spark", 52, -146, 12, 12)

    self:Tint(frame.spark, "muted", "vertex")
    frame.energy = bar(frame, 84, -174, 316, 18, -147)
    self:SetThemedFont(frame.energy.label, self.tokens.type.hero, true)
    frame.combo = bar(frame, 84, -218, 316, 10, -197)
    self:SetThemedFont(frame.combo.label, self.tokens.type.caption, true)
    self:SetThemedFont(frame.combo.text, self.tokens.type.caption, false)

    frame.comboMask = self:ArtTexture(frame.combo.value, "combo", 0, 0, 316, 10, "OVERLAY")
    self:Tint(frame.comboMask, "well", "vertex")
    frame.playerCast = self:CreateCastModule(frame, "player", -246)
    frame.targetCast = self:CreateCastModule(frame, "target", -296)
    frame.pending = self:Label(frame, self.tokens.type.caption, 0, -346, 416, "RIGHT")
    self:ApplyAppearance()
end

function A:ApplyAppearance()
    if not self.hud then return end
    if self.sessionDisabled then
        self.hud:Hide()
        return
    end
    if self:IsCombat() then
        self.pendingAppearance = true
        return
    end
    self.pendingAppearance = nil
    local db = self.db
    self.appliedStyle = db.style
    self.appliedCasts = db.casts
    local theme = self:Style()
    local frame = self.hud
    frame:SetScale(db.scale)
    frame:ClearAllPoints()

    local anchorY = db.y - frame.anchorExtension

    local ox, oy = self:MoverOffset("legacyHud")
    ox, oy = ox / db.scale, oy / db.scale
    if db.dock == "right" then
        frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -24 + ox, anchorY + oy)
    elseif db.dock == "left" then
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 24 + ox, anchorY + oy)
    else
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", db.x + ox, anchorY + oy)
    end
    for _, plate in ipairs({ frame.playerPlate, frame.targetPlate, frame.resourcePlate,
        frame.playerCast.plate, frame.targetCast.plate }) do
        plate:SetAlpha(theme.plate * db.opacity)
    end
    self:RefreshHairlines()
    frame.crest:SetAlpha(theme.ornament)
    frame.spark:SetAlpha(theme.ornament)
    if not frame.dynamicColours then



        frame.dynamicColours = true
        for _, region in ipairs({ frame.playerMark, frame.targetMark, frame.playerName, frame.targetName, frame.form, frame.pending, frame.combo.label }) do
            self.themed[region] = nil
        end
    end
    frame.playerMark:SetColorTexture(unpack(theme.player))
    frame.targetMark:SetColorTexture(unpack(theme.target))
    frame.playerName:SetTextColor(unpack(theme.text))
    frame.targetName:SetTextColor(unpack(theme.text))
    frame.form:SetTextColor(unpack(theme.muted))
    frame.pending:SetTextColor(unpack(theme.muted))
    frame.playerHealth.value:SetStatusBarColor(unpack(theme.player))
    frame.targetHealth.value:SetStatusBarColor(unpack(theme.target))
    frame.energy.value:SetStatusBarColor(unpack(theme.energy))
    frame.combo.value:SetStatusBarColor(unpack(theme.combo))
    frame.playerCast.value:SetStatusBarColor(unpack(theme.mana))
    frame.targetCast.value:SetStatusBarColor(unpack(theme.target))
    if db.enabled and not self.unitIntegrated then frame:Show() else frame:Hide() end
end

function A:UpdateHUD()
    if not self.hud then return end
    local frame = self.hud
    local identity = self:GetIdentity()
    self.identity = identity
    frame.playerName:SetText(identity.name)
    frame.form:SetText(identity.form)
    local inputMode = self.db.mode
    if inputMode == "auto" then inputMode = self.observedInput end
    frame.input:SetTexture(self.artPath .. (inputMode == "controller" and "pad" or "keys") .. ".tga", "CLAMP", "CLAMP")
    frame.input:SetAlpha(inputMode and 1 or 0.35)
    self:UpdateBar(frame.playerHealth, "PLAYER", UnitHealth, UnitHealthMax, "player")
    self:UpdateBar(frame.targetHealth, "TARGET", UnitHealth, UnitHealthMax, "target")
    local targetName = self:Text(UnitName, 1, "target")
    frame.targetName:SetText(targetName or "Target")
    if identity.classToken == "DRUID" then
        local theme = self:Style(self.appliedStyle)
        if identity.powerToken == "ENERGY" and type(self.energyType) == "number" then
            frame.energy.value:SetStatusBarColor(unpack(theme.energy))
            frame.spark:SetVertexColor(unpack(theme.energy))
            self:UpdateBar(frame.energy, "ENERGY", UnitPower, UnitPowerMax, "player", self.energyType)
        elseif identity.powerToken == "MANA" and type(identity.powerType) == "number" then
            frame.energy.value:SetStatusBarColor(unpack(theme.mana))
            frame.spark:SetVertexColor(unpack(theme.mana))
            self:UpdateBar(frame.energy, "MANA", UnitPower, UnitPowerMax, "player", identity.powerType)
        elseif identity.powerToken == "RAGE" and type(identity.powerType) == "number" then
            frame.energy.value:SetStatusBarColor(unpack(theme.rage))
            frame.spark:SetVertexColor(unpack(theme.rage))
            self:UpdateBar(frame.energy, "RAGE", UnitPower, UnitPowerMax, "player", identity.powerType)
        else
            self:EmptyBar(frame.energy, "RESOURCE", "Native display")
        end
        if identity.powerToken == "ENERGY" and type(self.comboType) == "number" then
            self:UpdateBar(frame.combo, "COMBO", UnitPower, UnitPowerMax, "player", self.comboType)
            frame.combo.value:SetAlpha(1)
            frame.combo.label:SetTextColor(unpack(theme.combo))
        else
            self:EmptyBar(frame.combo, "COMBO", "CAT FORM")
            frame.combo.value:SetAlpha(0.35)
            frame.combo.label:SetTextColor(unpack(theme.muted))
        end
    else
        self:EmptyBar(frame.energy, "FERAL ENERGY", "Native display")
        self:EmptyBar(frame.combo, "COMBO POINTS", "Native display")
    end
    frame.pending:SetText(self.pendingAppearance and "Layout queued until combat ends" or "")
    self:UpdateCompactHUD(identity)



end
