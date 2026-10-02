local _, A = ...
































local function plusHolds(self, id)
    if self.plusFailed or self:GetOption("unitMode") ~= "plus" then return false end
    return self:GetOption(id == "target" and "plusTargetOn" or "plusFocusOn") == true
end

local BARS = {








    { id = "player", unit = "player", option = "castPlayerMode", mover = "castPlayer",





      native = { "PlayerCastingBarFrame", "CastingBarFrame", "GamepadPlayerCastingBarFrame" },
      anchorOption = "castPlayerAnchor", plateOption = "plusPlayerOn" },
    { id = "target", unit = "target", option = "castTargetMode", mover = "castTarget", native = { "TargetFrameSpellBar" }, holdFrame = "TargetFrame",
      anchorOption = "castTargetAnchor", plateOption = "plusTargetOn" },


    { id = "focus", unit = "focus", option = "castFocusMode", mover = "castFocus", native = { "FocusFrameSpellBar" }, holdFrame = "FocusFrame" },
}
A.castDefs = BARS
A.castRestricted = {}




A.castSinkFailed = {}






local function wantsAnchor(self, def)
    if not def.anchorOption then return false end
    if self:GetOption(def.anchorOption) ~= "anchored" then return false end
    if self.plusFailed or not self.auditedSink then return false end



    if self.plusActive == false then return false end
    if self:GetOption("unitMode") ~= "plus" then return false end
    return self:GetOption(def.plateOption) == true
end

function A:CastAnchored(id)
    for _, def in ipairs(BARS) do
        if def.id == id then return wantsAnchor(self, def) and self:CastEffectiveMode(def) == "custom" end
    end
    return false
end



















local function anchorHost(self, def)
    if not wantsAnchor(self, def) then return nil end
    local plus = self.plus
    if not plus and type(self.CreatePlusUnits) == "function" then plus = self:CreatePlusUnits() end
    local plate = plus and plus[def.id]
    if plate and type(plate.GetWidth) == "function" then return plate end
    return nil
end



function A:CastEffectiveMode(def)
    local mode = self:GetOption(def.option)
    if mode ~= "custom" then return "native" end
    if self.castRestricted[def.id] and def.holdFrame then
        if not plusHolds(self, def.id) then return "native" end
    end
    return "custom"
end

local function newStrip(self, def)
    local sp = self.tokens.space
    local strip = CreateFrame("Frame", "AdaptiveUICast_" .. def.id, UIParent)
    self:Own(strip)
    strip:SetFrameStrata("LOW")
    strip:EnableMouse(false)
    strip.depth = {}
    self:Elevate(strip.depth, strip, "d", strip, 0, 0, strip, 0, 0, "panel")








    strip.barFrame = self:BarFrame(strip, "BACKGROUND", -7)
    strip.panel = A.PlusFlatPanel(self, strip, "BACKGROUND", -7)
    strip.bg = strip.panel.body
    A.PlusTintPanel(self, strip.panel, "inkDeep", 1)





    strip.veil = {}
    self:Veil(strip, strip.veil, "v", "inkDeep", 1)






    strip.surface = {}
    self:BlockSurface(strip, strip.surface, "s", 0.12)




    strip.panelRim = A.PlusFlatPanel(self, strip, "BACKGROUND", -8)
    strip.panelRim.body:Hide()
    strip.icon = self:Own(strip:CreateTexture(nil, "ARTWORK"))
    strip.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)




    strip.iconArt = {}
    self:IconFrame(strip.iconArt, strip, strip.icon, "casticon")
    strip.value = CreateFrame("StatusBar", nil, strip)
    self:Own(strip.value)
    strip.value:EnableMouse(false)
    strip.value:SetStatusBarTexture(self.artPath .. "meter.tga")
    strip.value:SetMinMaxValues(0, 1)
    strip.value:SetValue(0)
    strip.trough = self:Own(strip.value:CreateTexture(nil, "BACKGROUND"))
    strip.trough:SetAllPoints()
    self:Tint(strip.trough, "well", "color")






    strip.ghost = self:Own(strip.value:CreateTexture(nil, "BACKGROUND", nil, 1))
    strip.ghost:SetAllPoints()
    strip.role = "castNormal"
    self:Tint(strip.value, strip.role, "bar")
    self:Tint(strip.ghost, strip.role, "color", self.troughTint)
    strip.finish = {}










    self:BarFinish(strip.finish, strip.value, nil, true, strip.role)



















    strip.leadEdge = self:Own(strip.value:CreateTexture(nil, "OVERLAY", nil, 5))
    strip.leadEdge:SetTexture(self.artPath .. "meter.tga", "CLAMP", "CLAMP")
    do
        local fill = type(strip.value.GetStatusBarTexture) == "function"
            and strip.value:GetStatusBarTexture() or nil
        if fill and type(fill.SetPoint) == "function" then
            strip.leadEdge:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
            strip.leadEdge:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0, 0)
        end
    end
    strip.leadEdge:SetWidth(2)
    strip.leadEdge:Hide()






    strip.cut = strip.finish.barfinishB8



    if A.PlusClipToBar then A.PlusClipToBar(self, strip.value, strip.cut) end
    strip.nameText = strip.value:CreateFontString(nil, "OVERLAY")





    self:SetPixelFont(strip.nameText, "caption", self:UnitScale(), false)
    strip.nameText:SetPoint("LEFT", strip.value, "LEFT", sp.xs, 0)
    strip.nameText:SetJustifyH("LEFT")
    strip.nameText:SetWordWrap(false)
    self:Tint(strip.nameText, "barText", "text")
    strip.timeText = strip.value:CreateFontString(nil, "OVERLAY")
    self:SetPixelNumberFont(strip.timeText, "caption", self:UnitScale())
    strip.timeText:SetPoint("RIGHT", strip.value, "RIGHT", -sp.xs, 0)
    strip.timeText:SetJustifyH("RIGHT")
    self:Tint(strip.timeText, "barText", "text")






















    strip.igniteFx = self:Fx(strip, "ignite", "bar-bloom", "OVERLAY", 6)
    if strip.igniteFx then
        strip.igniteFx:SetPoint("TOPLEFT", strip, "TOPLEFT", -sp.md, sp.md)
        strip.igniteFx:SetPoint("BOTTOMRIGHT", strip, "BOTTOMRIGHT", sp.md, -sp.md)
    end
    strip.flareFx = self:Fx(strip.value, "flare", "bar-bloom", "OVERLAY", 6)
    if strip.flareFx then
        local fill = type(strip.value.GetStatusBarTexture) == "function" and strip.value:GetStatusBarTexture() or nil
        local host = (fill and type(fill.SetPoint) == "function") and fill or strip.value
        strip.flareFx:SetPoint("TOPRIGHT", host, "TOPRIGHT", sp.sm, sp.sm)
        strip.flareFx:SetPoint("BOTTOMLEFT", host, "BOTTOMRIGHT", -sp.sm * 3, -sp.sm)
    end






    strip.flashFx = self:EdgeFlash(strip, strip, "f")
















    strip.laneFx = self:EdgeFlash(strip, strip, "lane")














    strip.seamHead = self:Own(strip.value:CreateTexture(nil, "OVERLAY", nil, 6))
    strip.seamHead:SetTexture(self.artPath .. "bar-spark.tga", "CLAMP", "CLAMP")
    strip.seamHead:SetBlendMode("ADD")
    strip.seamHead:Hide()
    strip.seamFx = self:Fx(strip.value, "seam", "meter", "OVERLAY", 5)
    strip.flash2Fx = self:EdgeFlash(strip, strip, "f2")
    strip.frame = strip
    strip:Hide()
    return strip
end
















local function fxStrip(self, id)
    return self.castActive and self.castActive[id] or nil
end






A.castGlow = { peak = 0.55, rise = 0.14, fall = 0.22 }

A.castFaceAlpha = 0.5


A.castSeamGlow = { peak = 0.50, rise = 0.14, fall = 0.22 }
A.castInterruptGap = 0.09
A.castInterruptSecond = 0.62 / 0.92
A.castSeamHead = { w = 4, h = 2.2 }

function A:CastIgnite(id)
    local strip = fxStrip(self, id)
    if not strip then return false end
    local r, g, b = self:Color(strip.role or "castNormal")



    if strip.flashFx and self:GetOption("plusFlash") then
        self:PlayEdgeFlash(strip.flashFx, r, g, b, 0.9)
    end




    if strip.seamOn and strip.seamFx then
        for _, fx in ipairs({ strip.laneFx, strip.igniteFx }) do
            if fx then fx:SetAlpha(0); fx:Hide() end
        end
        return self:PlayIgnite(strip.seamFx, r, g, b, 1, A.castSeamGlow)
    end
    local lane = strip.laneOn and strip.laneFx or nil
    local off = lane and strip.igniteFx or strip.laneFx
    if off then off:SetAlpha(0); off:Hide() end
    if lane then
        self:PaintEdgeFlash(lane, r, g, b)
        return self:PlayIgnite(lane, nil, nil, nil, 1, A.castGlow)
    end
    if not strip.igniteFx then return false end
    return self:PlayIgnite(strip.igniteFx, r, g, b, 0.9)
end

function A:CastQuench(id)
    local strip = fxStrip(self, id)
    if not strip then return end
    if strip.laneFx then self:Quench(strip.laneFx, A.castGlow.fall) end
    if strip.igniteFx then self:Quench(strip.igniteFx) end
    if strip.seamFx then self:Quench(strip.seamFx, A.castGlow.fall) end
end



function A:CastFlare(id, kind)
    local strip = fxStrip(self, id)
    if not strip or not strip.flareFx then return false end
    local role = kind == "interrupted" and "bad" or (strip.role or "castNormal")
    if strip.flashFx and self:GetOption("plusFlash") then
        local r, g, b = self:Color(role)
        self:PlayEdgeFlash(strip.flashFx, r, g, b, kind == "interrupted" and 1.1 or 0.85)



        if kind == "interrupted" and strip.flash2Fx and self:MotionOn()
            and type(C_Timer) == "table" and type(C_Timer.After) == "function" then
            pcall(C_Timer.After, A.castInterruptGap, function()
                A:PlayEdgeFlash(strip.flash2Fx, r, g, b, A.castInterruptSecond)
            end)
        end
    end




    if kind == "done" and strip.seamOn and strip.diamondFx and not strip.endedRestricted then
        self:PlayFlare(strip.diamondFx, self:Color("accent"))
    end
    return self:PlayFlare(strip.flareFx, self:Color(role), kind == "interrupted" and 1.1 or 0.85)
end



local function showIcon(strip, shown)
    strip.icon:SetShown(shown)
    local frame = strip.iconArt and strip.iconArt.casticon
    if frame then frame:SetShown(shown) end
end









local function paintRole(self, strip, role)
    strip.role = role
    self:Tint(strip.value, role, "bar")
    if strip.ghost then self:Tint(strip.ghost, role, "color", self.troughTint) end


    strip.finish.barfinishglowRole = role
    self:PaintBarGlow(strip.value, self:Color(role))
    local r, g, b = self:Color(role)
    if strip.leadEdge and type(r) == "number" then
        strip.leadEdge:SetVertexColor(r + (1 - r) * 0.6, g + (1 - g) * 0.6, b + (1 - b) * 0.6, 1)
    end
end









function A:LayoutCastSeam(strip, host, h, px, mirrored, compact)
    local fill = type(strip.value.GetStatusBarTexture) == "function" and strip.value:GetStatusBarTexture() or nil
    local on = strip.seamOn == true and fill ~= nil
    local want = on and "meter.tga" or nil

    if strip.finish then strip.finish.barfinishfill = want end
    if strip.seamFill ~= want then
        strip.seamFill = want
        local flat = self:FlatBars()
        local material = flat and self.BarTextureOn and self:BarTextureOn()
        pcall(strip.value.SetStatusBarTexture, strip.value, self.artPath .. (want
            or (flat and (material and "bar-obsidian.tga" or "meter.tga") or "bar-gradient.tga")))
    end
    if strip.seamHead then
        strip.seamHead:ClearAllPoints()
        if on then


            local hh = math.max(h * A.castSeamHead.h, 8 * px)
            strip.seamHead:SetPoint("RIGHT", fill, "RIGHT", px, 0)
            strip.seamHead:SetSize(math.max(A.castSeamHead.w * h, 12 * px), hh)
            local r, g, b = self:Color(strip.role or "castNormal")
            if type(r) == "number" then
                strip.seamHead:SetVertexColor(r + (1 - r) * 0.7, g + (1 - g) * 0.7, b + (1 - b) * 0.7, 1)
            end
        end
        strip.seamHead:SetShown(on)
    end
    if strip.seamFx then
        strip.seamFx:ClearAllPoints()
        if on then
            local band = math.max(1, 3 * px)
            strip.seamFx:SetPoint("BOTTOMLEFT", strip.value, "TOPLEFT", 0, 0)
            strip.seamFx:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, band)
        else
            strip.seamFx:SetAlpha(0); strip.seamFx:Hide()
        end
    end
    if strip.flash2Fx then self:SizeEdgeFlash(strip.flash2Fx, math.max(2, px * 2)) end

    if on and host and self.PlateDiamond then
        strip.diamondFx = strip.diamondFx or self:Fx(host, "castDiamond", "diamond-glow", "OVERLAY", 7)
        if strip.diamondFx then
            local fromTail, y, size = self:PlateDiamond(compact)
            local tailSide = mirrored and "LEFT" or "RIGHT"
            strip.diamondFx:ClearAllPoints()
            strip.diamondFx:SetPoint("CENTER", host, "TOP" .. tailSide, (mirrored and 1 or -1) * fromTail, -y)
            strip.diamondFx:SetSize(size * 2.2, size * 2.2)
        end
    end
end











function A:CastBase(id, m)
    local dx = m.unitDX or 205
    local gap = self.tokens.space.sm
    local below = m.unitY - (m.plateH or 60) / 2 * m.unitScale - gap - self:GetOption("castHeight")
    if id == "castPlayer" then
        local strip = self:GetOption("dpsStripOn") and self:GetOption("dpsStripHeight") or 0
        return m.unitX - dx, below - strip * m.unitScale
    end
    if id == "castTarget" then return m.unitX + dx, below end
    if id == "castFocus" then return m.unitX + dx, m.unitY + 120 * m.fit
        - (m.plateH or 60) / 2 * m.unitScale - gap - self:GetOption("castHeight") end
end



function A:ApplyCastBars()
    if self:IsCombat() then self.layoutDirty = true; return false end
    self.castBars = self.castBars or {}
    self.castActive = self.castActive or {}
    local m = self:LayoutMetrics()
    local sp = self.tokens.space
    local baseW, baseH = self:GetOption("castWidth"), self:GetOption("castHeight")
    for _, def in ipairs(BARS) do
        local custom = self:CastEffectiveMode(def) == "custom"




        local host = custom and anchorHost(self, def) or nil
        self.castActive[def.id] = nil
        local strip = self.castBars[def.id]
        if custom and not strip then strip = newStrip(self, def); self.castBars[def.id] = strip end
        if strip then
            if custom then
                self.castActive[def.id] = strip


                local width = math.ceil(baseW * self:TypeLift(1) * self:TextScale())






                if host then
                    width = self:Number(host.GetWidth, 1, host) or self:PlusPlateWidth(false)






                    local trim = (self.PlusUnified and self:PlusUnified()) and 0 or self:PlusCascade()



                    if self.BarSkinOn and self:BarSkinOn() then trim = 0 end
                    width = math.max(80, width - trim)
                end
                local barSkin = (host and self.BarSkinOn and self:BarSkinOn()) or false






                local castMode = nil
                if barSkin and self.PlateStands and self:PlateStands() then




                    local choice, skin = self:GetOption("plateMantleCast"), self:PlateSkin()
                    if choice == "above" or skin == "tinted" then
                        castMode = "above"
                    elseif skin == "inlay" or choice == "seam" then
                        castMode = "seam"
                    else
                        castMode = "face"
                    end
                end
                strip.castMode = castMode







                local hostScale = host and (self:Number(host.GetScale, 1, host) or 1) or 1
                local lift = self:TypeLift(hostScale) * self:TextScale()
                local h = math.max(baseH, math.ceil(baseH * lift / 2) * 2)







                if host and self.PlusSnap then
                    h = self:PlusSnap(h, math.max(0.34, math.min(4,
                        self:PhysicalPixel(UIParent) / hostScale)))
                end

















                local castTop, castLeft, castRight = 0, 0, 0
                local hostCompact = barSkin and host.hero ~= true or false
                if castMode == "face" then
                    local castH
                    castTop, castH, castLeft, castRight = self:MantleFace(hostCompact)
                    h = math.max(2, castH)
                    width = math.max(16, width - castLeft - castRight)
                elseif castMode == "seam" then
                    local castH
                    castTop, castH, castLeft, castRight = self:CastSeam(hostCompact)
                    h = castH
                    width = math.max(16, width - castLeft - castRight)
                elseif castMode == "above" then

                    local g = self:MantleGeometry(hostCompact, false)
                    h = math.max(2, self:PlusSnap(g.art * (self:PlateArt().manaH or 0.25)))
                elseif barSkin then
                    local plateH = self:Number(host.GetHeight, 1, host) or h
                    local castH
                    castTop, castH = self:BarGauge(plateH, "cast")
                    castLeft = self:PlusGaugeInset(hostCompact)
                    castRight = self:BarTailInset(hostCompact)
                    h = math.max(2, castH)
                    width = math.max(16, width - castLeft - castRight)
                end
                strip:SetSize(width, h)






                local mirrored = barSkin and self:GetOption("plusMirror")
                    and (A.plusInboard[def.id] or "RIGHT") == "LEFT" or false
                local bandTop, bandH, leftPad, rightPad = 2, h - 4, 2, 2
                if barSkin then bandTop, bandH, leftPad, rightPad = 0, h, 0, 0 end







                local rowH = barSkin and (hostCompact and self:PlusCompactRow()
                    or self:PlusNameRow()) or 0
                local floatUp = barSkin
                    and (castTop + self:PlusAbove(hostCompact) + self:PlusGaugeGap()) or 0

                if castMode == "above" then floatUp = self:PlusGaugeGap() end
                local lead = mirrored and "RIGHT" or "LEFT"
                local tailEnd = mirrored and "LEFT" or "RIGHT"
                local sign = mirrored and -1 or 1
                local icon = barSkin and rowH or bandH
                strip.icon:ClearAllPoints()
                if barSkin then
                    strip.icon:SetPoint("BOTTOM" .. lead, strip, "TOP" .. lead, 0, floatUp)
                else
                    strip.icon:SetPoint("TOPLEFT", strip, "TOPLEFT", leftPad, -bandTop)
                end
                strip.icon:SetSize(icon, icon)
                strip.value:ClearAllPoints()



                local left = (not barSkin) and self:GetOption("castShowIcon")
                    and (leftPad + icon + sp.xs) or leftPad
                local right = rightPad
                strip.value:SetPoint("TOPLEFT", strip, "TOPLEFT", left, -bandTop)
                strip.value:SetPoint("BOTTOMRIGHT", strip, "TOPRIGHT", -right, -(bandTop + bandH))








                local barH = math.max(1, bandH)
                local cut = self:PlusCutSize(barH)
                strip.cut:SetSize(cut, cut)



                local barW = math.max(1, width - left - right)
                strip.timeText:ClearAllPoints()



                local timerInset = cut + sp.xs
                strip.timeText:ClearAllPoints()
                strip.nameText:ClearAllPoints()
                if castMode == "face" then



                    local lead0 = mirrored and "RIGHT" or "LEFT"
                    local tail0 = mirrored and "LEFT" or "RIGHT"
                    local sgn = mirrored and -1 or 1
                    strip.nameText:SetPoint(lead0, strip.value, lead0, sgn * sp.xs, 0)
                    strip.nameText:SetHeight(h)
                    strip.nameText:SetWidth(math.max(16, width - sp.xs * 3 - 44))
                    strip.nameText:SetJustifyH(lead0)
                    strip.timeText:SetPoint(tail0, strip.value, tail0, -sgn * sp.xs, 0)
                    strip.timeText:SetHeight(h)
                    strip.timeText:SetJustifyH(tail0)
                elseif barSkin then




                    local nameX = self:GetOption("castShowIcon") and (icon + sp.xs) or 0
                    strip.nameText:SetPoint("BOTTOM" .. lead, strip, "TOP" .. lead,
                        sign * nameX, floatUp)
                    strip.nameText:SetHeight(rowH)
                    strip.nameText:SetWidth(math.max(16, width - nameX - 52))
                    strip.nameText:SetJustifyH(lead)
                    strip.timeText:SetPoint("BOTTOM" .. tailEnd, strip, "TOP" .. tailEnd, 0, floatUp)
                    strip.timeText:SetHeight(rowH)
                    strip.timeText:SetJustifyH(tailEnd)
                else
                    strip.timeText:SetPoint("RIGHT", strip.value, "RIGHT", -timerInset, 0)
                    strip.nameText:SetPoint("LEFT", strip.value, "LEFT", sp.xs, 0)
                    strip.nameText:SetWidth(math.max(16, barW - sp.xs - timerInset - 44))
                    strip.nameText:SetJustifyH("LEFT")
                end












                local floatFlags = (barSkin and self.PlusFloatType and self:PlusFloatType())
                    or "OUTLINE"
                self:SetPixelFont(strip.nameText,
                    (barSkin or h >= 20 * lift) and "body" or "caption", hostScale, false, floatFlags)

                self:SetPixelNumberFont(strip.timeText,
                    (castMode == "face" or castMode == "seam") and "body" or "caption", hostScale,
                    castMode == "face" and "OUTLINE" or floatFlags)
                strip.nameText:SetShown(self:GetOption("castShowName"))
                strip.timeText:SetShown(self:GetOption("castShowTime"))


                showIcon(strip, castMode ~= "face" and self:GetOption("castShowIcon") and strip.hasIcon == true)



                local fillTex = type(strip.value.GetStatusBarTexture) == "function"
                    and strip.value:GetStatusBarTexture() or nil
                local fillAlpha = castMode == "face" and A.castFaceAlpha or 1
                if fillTex and type(fillTex.SetAlpha) == "function" and strip.fillAlpha ~= fillAlpha then
                    strip.fillAlpha = fillAlpha
                    fillTex:SetAlpha(fillAlpha)
                end
                strip:ClearAllPoints()
                if host then



                    strip:SetScale(self:Number(host.GetScale, 1, host) or 1)
                    local inboard = A.plusInboard[def.id] or "RIGHT"
                    local outboard = inboard == "RIGHT" and "LEFT" or "RIGHT"
                    local level = self:Number(host.GetFrameLevel, 1, host) or 2
                    if barSkin and castMode ~= "above" then





                        strip:SetPoint("TOPLEFT", host, "TOPLEFT",
                            mirrored and castRight or castLeft, -castTop)




                        strip:SetFrameLevel(level + 4)
                    else




                        strip:SetPoint("BOTTOM" .. outboard, host, "TOP" .. outboard, 0,
                            (self.PlusFloatGap and self:PlusFloatGap() or A.plusFloat)
                            + (self.PlusAbove and self:PlusAbove(false) or 0))






                        strip:SetFrameLevel(math.max(1, level - 1))
                    end
                else


                    local cs = self:MoverScale(def.mover)
                    strip:SetScale(cs)
                    local bx, by = self:CastBase(def.mover, m)
                    local ox, oy = self:MoverOffset(def.mover)
                    strip:SetPoint("CENTER", UIParent, "BOTTOM", (bx + ox) / cs, (by + oy) / cs)
                end




                local px = math.max(0.34, math.min(4, self:PhysicalPixel(UIParent) / hostScale))



                self:LayoutBlockSurface(strip, strip.surface, "s",
                    math.max(4, math.floor(h * 0.45)), sp.xs, px, self:GetOption("plusKeyline"),
                    strip.panel.body, strip.panel.body)
                if strip.flashFx then self:SizeEdgeFlash(strip.flashFx, math.max(2, px * 2)) end







                strip.laneOn = barSkin and castMode ~= "seam"
                strip.seamOn = castMode == "seam"
                self:LayoutCastSeam(strip, host, h, px, mirrored, hostCompact)
                if strip.laneFx then



                    local rim = math.max(2, px * 2)
                    self:SizeEdgeFlash(strip.laneFx, rim)
                    self:SpreadEdgeFlash(strip.laneFx, barSkin and rim or 0)
                    if not barSkin then strip.laneFx:SetAlpha(0); strip.laneFx:Hide() end
                end
                if strip.leadEdge then

                    strip.leadEdge:SetWidth(math.max(1, px * (strip.seamOn and 3 or 2)))
                    strip.leadEdge:SetShown(barSkin)
                end
                paintRole(self, strip, strip.role or "castNormal")


                local veiled = self:GetOption("unitVeil")






















                local inboardEnd = A.plusInboard[def.id] or "RIGHT"
                local notchCorner = "TOP" .. inboardEnd
                local unified = self.PlusUnified and self:PlusUnified()




                local lean = (unified and host) and math.max(A.castNotch, math.floor(h * 0.5)) or A.castNotch
                local notch = (host and self:GetOption("plusCorner")) and lean or 0










                if barSkin then
                    if strip.barFrame then
                        self:PlaceBarFrame(strip.barFrame, strip, width, 0, false, 1, false)
                    end
                    for _, panel in ipairs({ strip.panel, strip.panelRim }) do
                        panel.body:Hide(); panel.wedge:Hide(); panel.tail:Hide()
                    end
                    self:LayoutBlockSurface(strip, strip.surface, "s",
                        math.max(4, math.floor(h * 0.45)), sp.xs, px, false)
                    self:ShowVeil(strip.veil, "v", false)
                    self:SuppressDepth(strip.depth, "d", true)


                    if strip.trough then
                        if castMode == "above" then
                            local t = A.mantleTroughTone or { 0.11, 0.15, 0.17 }
                            self.themed[strip.trough] = nil
                            strip.trough:SetColorTexture(t[1], t[2], t[3], A.mantleTroughAlpha or 0.22)
                            strip.trough:Show()
                            strip.troughWash = true
                        else
                            strip.trough:Hide()
                        end
                    end
                else
                    if strip.troughWash then
                        strip.troughWash = nil
                        self:Tint(strip.trough, "well", "color")
                    end
                    if strip.trough then strip.trough:Show() end
                    if strip.barFrame then
                        self:PlaceBarFrame(strip.barFrame, strip, width, 0, false, 1, false)
                    end
                    A.PlusPlacePanel(self, strip.panel, strip, 0, 0, 0, -h, notchCorner, notch)
                    A.PlusTintPanel(self, strip.panel, "inkDeep", self:Surface("panel"))
                    A.PlusPlaceRim(self, strip.panelRim, strip, px, 0, 0, 0, -h, notchCorner, notch,
                        self:GetOption("plusKeyline") and self:GetOption("plusRim"))



                    A.PlusTintPanel(self, strip.panelRim, (unified and host) and "accent" or "edge",
                        (unified and host) and 0.80 or nil)
                    self:Veil(strip, strip.veil, "v", "inkDeep", self:Surface("panel") * 0.5)
                    self:ShowVeil(strip.veil, "v", veiled)
                    strip.bg:SetShown(true)

                    self:SuppressDepth(strip.depth, "d", false)
                end
            else
                strip:Hide()
            end
        end
    end
    return true
end











function A:GuardNativeCastBars()
    local held = self.heldHidden
    if not held then return end
    for _, def in ipairs(BARS) do
        if self:CastEffectiveMode(def) == "custom" then
            for _, name in ipairs(def.native) do
                local bar = _G[name]
                if bar and held[bar] and type(bar.GetAlpha) == "function" then
                    local alpha = bar:GetAlpha()
                    if self:IsPublic(alpha) and type(alpha) == "number" and alpha ~= 0 then
                        pcall(self.ReassertHidden, self, bar)
                    end
                end
            end
        end
    end
end



function A:CastBarReport(emit)
    for _, def in ipairs(BARS) do
        local mode = self:CastEffectiveMode(def)
        local seen = false
        for _, name in ipairs(def.native) do
            local bar = _G[name]
            if bar then
                seen = true
                local alpha = type(bar.GetAlpha) == "function" and self:Number(bar.GetAlpha, 1, bar)
                local shown = type(bar.IsShown) == "function" and self:Read(bar.IsShown, 1, bar)
                emit(string.format("cast %s: %s | %s held=%s alpha=%s shown=%s", def.id, mode, name,
                    tostring((self.heldHidden and self.heldHidden[bar]) and true or false),
                    alpha and string.format("%.2f", alpha) or "restricted",
                    tostring(shown)))
            end
        end
        if not seen then
            emit(string.format("cast %s: %s | no native frame found (%s)", def.id, mode,
                table.concat(def.native, ", ")))
        end
    end
end

function A:StyleNativeCastBars(state, stripChrome, fonts)
    for _, def in ipairs(BARS) do
        local custom = self:CastEffectiveMode(def) == "custom"
        for _, name in ipairs(def.native) do
            local bar = _G[name]
            if bar then
                if custom then
                    self:HoldHidden(state, bar)
                    self.castShowHooks = self.castShowHooks or setmetatable({}, { __mode = "k" })
                    if not self.castShowHooks[bar] and type(bar.HookScript) == "function" then
                        if pcall(bar.HookScript, bar, "OnShow", function(frame)
                            if A.heldHidden and A.heldHidden[frame] then pcall(A.ReassertHidden, A, frame) end
                        end) then self.castShowHooks[bar] = true end
                    end
                else
                    self:ReleaseHidden(state, bar)

                    self.NativeGlassPanel(self, state, bar, "cast", bar, -2, 2, bar, 2, -2, self:Surface("base"), 1, false, "base")
                    stripChrome(self, state, bar)
                    self:BarFinish(state.decorations[bar], bar, "cast")
                    fonts(self, state, bar, self:Type("caption"))
                end
            end
        end
    end
end










function A:DrawRestrictedCast(def, strip)
    if not self:GetOption("castRestrictedStrip") then return false end
    if self.castSinkFailed[def.id] then return false end
    local cast = self:GetRestrictedCast(def.unit)
    if not cast then return false end
    local now = self:Number(GetTime, 1)
    if not now then return false end
    local ok = pcall(function()


        strip.value:SetMinMaxValues(cast.startTime, cast.endTime)
        strip.value:SetValue(now * 1000)
        if strip.nameText then
            strip.nameText:SetFormattedText("%s", cast.name)
            strip.timeText:SetText("")
            strip.hasIcon = cast.texture ~= nil
            if cast.texture ~= nil then strip.icon:SetTexture(cast.texture) end
            showIcon(strip, strip.castMode ~= "face" and self:GetOption("castShowIcon") and strip.hasIcon)
        end
    end)
    if not ok then



        self.castSinkFailed[def.id] = true
        strip.frame:Hide()
        return false
    end
    local role = cast.notInterruptible == true and "castShield"
        or (cast.channel and "castChannel" or "castNormal")
    if strip.role ~= role then paintRole(self, strip, role) end





    local started = strip.castKey ~= "restricted"
    strip.castKey, strip.castEnd, strip.castWasRestricted = "restricted", nil, true
    if started then pcall(self.CastIgnite, self, def.id) end
    strip.frame:Show()
    return true
end




function A:UpdateCastBars()
    self:GuardNativeCastBars()



    local active = self.castActive
    if not active then return end
    for _, def in ipairs(BARS) do
        local strip = active[def.id]
        if strip then





            local function endCast(interrupted)
                if not strip.castKey then return end






                if strip.castWasRestricted then interrupted = false end


                strip.endedRestricted = strip.castWasRestricted == true
                strip.castKey, strip.castEnd, strip.castWasRestricted = nil, nil, nil
                pcall(self.CastQuench, self, def.id)
                pcall(self.CastFlare, self, def.id, interrupted and "interrupted" or "done")
            end
            local ok = pcall(function()
                if self:CastEffectiveMode(def) ~= "custom" then strip.frame:Hide(); endCast(true); return end
                local exists = def.unit == "player" or self:Read(UnitExists, 1, def.unit) == true
                if not exists then strip.frame:Hide(); endCast(true); return end
                local cast, status = self:GetPublicCast(def.unit)
                self:Note("cast " .. def.id, status)
                if status == "restricted" then


                    if self:DrawRestrictedCast(def, strip) then
                        self:Note("cast " .. def.id, "restricted: drawn through sinks, no timer")
                        return
                    end
                    if def.holdFrame and not self.castRestricted[def.id] then

                        self.castRestricted[def.id] = true
                        self.layoutDirty, self.nativeDirty = true, true
                        self.castRestrictedNotice = self.castRestrictedNotice or {}
                        self.castRestrictedNotice[def.id] = true
                    end
                end
                local now = self:Number(GetTime, 1)
                if not cast or not now or now < cast.startTime or now >= cast.endTime then
                    strip.frame:Hide()


                    endCast(not (now and strip.castEnd and now >= strip.castEnd - 0.15))
                    return
                end
                local duration, remaining = cast.endTime - cast.startTime, cast.endTime - now
                local key = tostring(cast.name) .. "@" .. tostring(cast.startTime)
                local started = strip.castKey ~= key
                strip.castKey, strip.castEnd = key, cast.endTime
                strip.value:SetMinMaxValues(0, duration)
                strip.value:SetValue(cast.channel and remaining or (now - cast.startTime))
                local role = cast.notInterruptible == true and "castShield" or (cast.channel and "castChannel" or "castNormal")
                if strip.role ~= role then paintRole(self, strip, role) end


                if started then pcall(self.CastIgnite, self, def.id) end
                if strip.nameText then
                    strip.nameText:SetText(cast.name)
                    strip.timeText:SetText(string.format("%.1fs", remaining))
                    strip.hasIcon = cast.texture ~= nil
                    if cast.texture ~= nil then strip.icon:SetTexture(cast.texture) end
                    showIcon(strip, strip.castMode ~= "face" and self:GetOption("castShowIcon") and strip.hasIcon)
                end
                strip.frame:Show()
            end)
            if not ok then strip.frame:Hide() end
        end
    end
end



function A:CastFallbackNotices()
    for id in pairs(self.castRestrictedNotice or {}) do
        self.castRestrictedNotice[id] = nil
        self:Print(id .. " cast data is restricted here and this client would not take it through the "
            .. "bar's own setters; " .. (plusHolds(self, id)
            and "in Plus mode the native bar is hidden with its frame, so the strip shows nothing while it is restricted. Use Native for this bar, or Lite unit frames."
            or "showing the native cast bar for it again."))
    end
end
