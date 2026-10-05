local _, A = ...
































































local PLAYER_W_FALLBACK = 232









local PLATE_LEVEL = 4
A.plateLevel = PLATE_LEVEL


local DEFS = {
    { id = "player", unit = "player", opt = "plusPlayerOn", color = "plusColorPlayer", native = { "PlayerFrame" } },
    { id = "target", unit = "target", opt = "plusTargetOn", color = "plusColorTarget", native = { "TargetFrame" }, marker = true },
    { id = "focus", unit = "focus", opt = "plusFocusOn", color = "plusColorFocus", native = { "FocusFrame" }, marker = true, small = true },
    { id = "pet", unit = "pet", opt = "plusPetOn", color = "plusColorPet", native = { "PetFrame" }, small = true },
    { id = "tot", unit = "targettarget", opt = "plusTotOn", color = "plusColorTot", native = {}, small = true },




    { id = "focustarget", unit = "focustarget", opt = "plusFocusTargetOn", color = "plusColorFocus", native = {}, small = true },
    { id = "focustargettarget", unit = "focustargettarget", opt = "plusFocusTargetTargetOn", color = "plusColorFocus",
      native = {}, small = true },
    { id = "party", opt = "plusPartyOn", color = "plusColorParty", native = { "PartyFrame", "CompactPartyFrame" } },
}
A.plusDefs = DEFS



local function classColor(self, unit)
    local token = self:Text(UnitClass, 2, unit)
    local color = token and RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    if type(color) == "table" and type(color.r) == "number" then return color.r, color.g, color.b end
end





local function reactionColor(self, unit)
    local reaction = self:Number(UnitReaction, 1, "player", unit)
    local role = "bad"
    if reaction and reaction >= 5 then role = "good"
    elseif reaction == 4 then role = "warn" end
    local r, g, b = self:Color(role)
    return r, g, b
end










local NAME_ROW = 28
local COMPACT_ROW = 20
A.plusNameRow, A.plusCompactRow = NAME_ROW, COMPACT_ROW








function A:PlusTypeLift()
    local lift = self:TypeLift(self.UnitScale and self:UnitScale() or 1) * self:TextScale()
    if lift ~= lift or lift < 1 then return 1 end
    return math.min(2, lift)
end
local function liftRow(self, base)
    return math.max(base, math.ceil(base * self:PlusTypeLift() / 4) * 4)
end




function A:FitPlateName(plate, compact, text)
    if not plate or not plate.name then return end
    local scale = self.UnitScale and self:UnitScale() or 1
    self:SetFittedText(plate.name, text,
        self:PixelSize(compact and "body" or "hero", scale),
        self:PixelSize("body", scale), not compact)
end

















local WIDTH_GROWTH = 1.25
local function baseWidth(self, compact)
    return math.ceil(self:GetOption(compact and "plusSmallWidth" or "plusWidth") * self:PlusTypeLift())
end







function A:PlusPlateWidth(compact)
    local base = baseWidth(self, compact)
    if compact or not self.PlusHeaderReserve then return self:PlusSnap(base) end
    local lead, tail = self:PlusHeaderReserve(false)
    local need = lead + self:PlusNumberSlot(false) + 6 + tail
        + self:PlusNameFloor(false) + self.tokens.space.sm
    return self:PlusSnap(math.max(base, math.min(math.ceil(base * WIDTH_GROWTH), need)))
end

function A:PlusNameRow() return liftRow(self, NAME_ROW) end
function A:PlusCompactRow() return liftRow(self, COMPACT_ROW) end



function A:PlusHeaderTop() return self:PlusSnap(self.tokens.space.sm + self:PlusNameRow()) end
function A:PlusCompactTop() return self:PlusSnap(self.tokens.space.sm + self:PlusCompactRow()) end


































function A:PixelSnapOn()
    if not (self.db and self.optionIndex) then return true end
    return self:GetOption("plusPixelSnap") ~= false
end






function A:PlatePixel()
    local scale = (self.UnitScale and self:UnitScale()) or 1
    if type(scale) ~= "number" or scale ~= scale or scale <= 0.05 or scale > 20 then scale = 1 end
    return math.max(0.34, math.min(4, self:PhysicalPixel(_G.UIParent) / scale))
end





function A:PlusSnap(value, px)
    value = tonumber(value) or 0
    if value == 0 or not self:PixelSnapOn() then return value end
    px = tonumber(px) or self:PlatePixel()
    if not (px and px > 0.05) then return value end
    local steps = math.floor(math.abs(value) / px + 0.5)
    if steps < 1 then steps = 1 end
    return (value < 0 and -steps or steps) * px
end







function A:PlusHealthHeight()
    local _, h = self:StandGauge(false, "health")
    return h
end
function A:PlusPowerHeight()
    if (tonumber(self:GetOption("plusPowerHeight")) or 0) <= 0 then return 0 end
    local _, h = self:StandGauge(false, "power")
    return h
end
function A:PlusInset() return self:PlusSnap(self.tokens.space.sm) end
function A:PlusGaugeGap() return self:PlusSnap(self.tokens.space.xs) end
function A:PlusSeamGap() return self:PlusSnap(self.plusSeam) end
function A:PlusFloatGap() return self:PlusSnap(self.plusFloat) end
function A:PlusFooterHeight() return self:PlusSnap(self:GetOption("dpsStripHeight")) end
function A:PlusPartyBar() return self:PlusSnap(self:GetOption("plusPartyBar")) end



































A.inlayArt = {
    ratio     = 1779 / 196,
    capL      = 132 / 1024,
    capR      = 138 / 1024,
    capLA     = 230 / 196,
    capRA     = 239 / 196,
    fillHeadA = 165 / 196,
    fillTailA = 203 / 196,
    bandTop   = 2 / 196,
    faceTop   = 31 / 196,
    faceBot   = 157 / 196,
    footTop   = 1,
    manaH     = 0.25,
    plankH = 0, inlay = true, fill = "meter",
    winL = 59 / 196, winR = 218 / 196,
    winTop = 2 / 196, winBot = 157 / 196,
    lanes = { health = { 42 / 196, 157 / 196 }, power = { 2 / 196, 42 / 196 },
              cast = { 157 / 196, 188 / 196 } },


    base = { health = { 0.1499, 0.2018, 0.2364 }, power = { 0.2480, 0.2941, 0.3287 } },
    lum = "plate02-inlay-lum", cap = "plate02-inlay-cap",
}



function A:PlateSkin()
    return "inlay"
end




function A:MantleGeometry(compact)
    local w = self:PlusPlateWidth(compact)
    local art = math.max(10, self:PlusSnap(w / self:PlateArt().ratio))
    return { w = w, art = art, plank = 0, mana = 0, artTop = 0, manaTop = art, total = art }
end



function A:StandGauge(compact, which)
    local g = self:MantleGeometry(compact)
    local lane = self:PlateArt().lanes[which == "power" and "power" or "health"]
    local top = self:PlusSnap(g.art * lane[1])
    local bot = self:PlusSnap(g.art * lane[2])
    return top, math.max(self:PlatePixel(), bot - top)
end









A.castSeamRows = { 157 / 196, 188 / 196 }
A.castSeamCols = { 99 / 196, 226 / 196 }
A.castSeamMinPx = 3
function A:CastSeam(compact)
    local g = self:MantleGeometry(compact, false)
    local px = self:PlatePixel()
    local top = self:PlusSnap(g.art * A.castSeamRows[1])
    local bot = self:PlusSnap(g.art * A.castSeamRows[2])
    local h = math.max(bot - top, self:PlusSnap(A.castSeamMinPx * px))
    local head = self:PlusSnap(g.art * A.castSeamCols[1])
    local tail = self:PlusSnap(g.art * A.castSeamCols[2])
    return g.artTop + top, h, head, tail
end






A.plateStud = { fromTail = (1779 - 1613) / 196, y = 90 / 196, size = 60 / 196 }
function A:PlateDiamond(compact)
    local g = self:MantleGeometry(compact, false)
    local s = A.plateStud
    return g.art * s.fromTail, g.artTop + g.art * s.y, g.art * s.size
end



function A:PlateArt()
    return A.inlayArt
end

function A:PlateFile()
    return "plate02-plain"
end





function A:BarPlateHeight(compact)
    return math.max(10, self:PlusSnap(self:PlusPlateWidth(compact) / self:PlateArt().ratio))
end









function A:PlusAbove(compact)
    return self:PlusSnap(compact and self:PlusCompactRow() or self:PlusNameRow())
        + self:PlusGaugeGap()
end









function A:PlusFloatType()
    return "OUTLINE"
end




function A:PlusRowHeight()
    return self:PlusHeroHeight(true) + self:PlusAbove(false)
end














A.plateShade = { alpha = 1.0, side = 0.10, depth = 1.50 }
function A:PlateShade(plate, on, width, height, mirror, tile, top)
    local file = on and type(plate) == "table" and self.OakShadeFile and self:OakShadeFile(tile) or nil
    local t = plate and plate.shade
    if not file or not (tonumber(height) and height > 0) then
        if t and t:IsShown() then t:Hide() end
        return false
    end
    if not t then
        if type(plate.CreateTexture) ~= "function" then return false end
        t = self:Own(plate:CreateTexture(nil, "BACKGROUND", nil, -8))
        plate.shade = t
    end
    local path = self.artPath .. file .. ".tga"
    if t:GetTexture() ~= path then t:SetTexture(path, "CLAMP", "CLAMP") end
    local s = A.plateShade
    top = tonumber(top) or 0
    local key = string.format("%.3f|%.3f|%.3f|%s|%.3f", width, height, top, tostring(mirror), s.alpha)
    if plate.shadeKey ~= key then
        plate.shadeKey = key
        local side = height * s.side
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", plate, "TOPLEFT", -side, -top)
        t:SetSize(width + 2 * side, height * s.depth)
        if mirror then t:SetTexCoord(1, 0, 0, 1) else t:SetTexCoord(0, 1, 0, 1) end
        t:SetAlpha(s.alpha)
    end
    if not t:IsShown() then t:Show() end
    return true
end


function A:BarFrame(host, layer, sublevel)
    local art = {}
    for _, key in ipairs({ "left", "mid", "right" }) do



        art[key] = self:PaintedTexture(host, layer or "BACKGROUND", sublevel or -7, self:PlateFile())
        art[key]:Hide()
        self:SyncPainted(art[key])
    end
    return art
end




function A:PlaceBarFrame(art, host, width, height, mirror, alpha, on, top)
    if not art then return 0 end


    top = -(tonumber(top) or 0)
    if not on then
        for _, key in ipairs({ "left", "mid", "right" }) do self:HidePainted(art[key]) end
        return 0
    end
    local a = self:PlateArt()



    local file = self:PlateFile()
    for _, key in ipairs({ "left", "mid", "right" }) do
        local entry = self.painted[art[key]]
        if entry and entry.name ~= file then self:SetPainted(art[key], file) end
    end
    local headW, tailW = height * a.capLA, height * a.capRA



    local room = width * 0.86
    if headW + tailW > room and headW + tailW > 0 then
        local k = room / (headW + tailW)
        headW, tailW = headW * k, tailW * k
    end
    local head, tail = art.left, art.right
    local hU0, hU1, tU0, tU1, mU0, mU1 = 0, a.capL, 1 - a.capR, 1, a.capL, 1 - a.capR
    if mirror then
        head, tail = art.right, art.left
        hU0, hU1, tU0, tU1, mU0, mU1 = a.capL, 0, 1, 1 - a.capR, 1 - a.capR, a.capL
    end


    local headSide = mirror and "RIGHT" or "LEFT"
    local tailSide = mirror and "LEFT" or "RIGHT"
    head:ClearAllPoints()
    head:SetPoint("TOP" .. headSide, host, "TOP" .. headSide, 0, top)
    head:SetSize(headW, height)
    head:SetTexCoord(hU0, hU1, 0, 1)
    tail:ClearAllPoints()
    tail:SetPoint("TOP" .. tailSide, host, "TOP" .. tailSide, 0, top)
    tail:SetSize(tailW, height)
    tail:SetTexCoord(tU0, tU1, 0, 1)
    art.mid:ClearAllPoints()
    art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", mirror and tailW or headW, top)
    art.mid:SetPoint("BOTTOMRIGHT", host, "TOPRIGHT", -(mirror and headW or tailW), top - height)
    art.mid:SetTexCoord(mU0, mU1, 0, 1)






    alpha = math.max(0, math.min(1, tonumber(alpha) or 1))
    for _, key in ipairs({ "left", "mid", "right" }) do
        self:PaintedAlpha(art[key], alpha)
        art[key]:Show()
        self:SyncPainted(art[key])
    end
    return headW
end


function A:PlusSmallHealthHeight()
    local _, h = self:StandGauge(true, "health")
    return h
end









function A:PlusCascade()
    return self:GetOption("plusHealthHeight") + self.tokens.space.xs
end
A.plusFloat = 4



A.plusInboard = { player = "RIGHT", target = "LEFT" }




function A:PlusHeroHeight()
    return self:MantleGeometry(false).total
end






A.plusSmallIds = { "focus", "pet", "tot", "focustarget", "focustargettarget" }
function A:TileSize(variant)
    local art = self.tileArts and self.tileArts[variant or "plain"]
    local ratio = (self.PlateArt and self:PlateArt().ratio) or 9.08
    local h = self:PlusSnap(self:PlusPlateWidth(false) / ratio)
    return self:PlusSnap(h * ((art and art.ratio) or 3.875)), h
end
function A:PlusSmallWidth(id)
    if self.SmallTile and self:SmallTile(id) then return (self:TileSize(self.tileFor[id])) end
    return self:PlusPlateWidth(true)
end
function A:PlusSmallHeight(id)
    if self.SmallTile and self:SmallTile(id) then
        local _, h = self:TileSize(self.tileFor[id])
        return h
    end
    return self:PlusCompactHeight()
end


function A:TileLane(variant, w, h)
    local lane = self.tileArts[variant].lane
    local top = self:PlusSnap(h * lane[2])
    local bot = self:PlusSnap(h * lane[4])
    local left = self:PlusSnap(w * lane[1])
    local right = self:PlusSnap(w * (1 - lane[3]))
    return top, math.max(self:PlatePixel(), bot - top), left, right
end










function A:TileLight(widget, variant, on, chip)
    local bar = widget and widget.value
    if not bar or type(bar.CreateTexture) ~= "function" then return end
    if not on then
        for _, key in ipairs({ "tileBase", "tileLum", "tileCap", "tileWood" }) do
            if widget[key] and widget[key]:IsShown() then widget[key]:Hide() end
        end
        local woodTwin = widget.tileWood and widget.tileWood.auiTwin
        if woodTwin and woodTwin:IsShown() then woodTwin:Hide() end
        local twin = widget.tileCap and widget.tileCap.auiTwin
        if twin and twin:IsShown() then twin:Hide() end
        widget.tileKey = nil
        return
    end
    local plate = widget.plate or (type(bar.GetParent) == "function" and bar:GetParent()) or nil
    if not widget.tileBase and type(plate) == "table" and type(plate.CreateTexture) == "function" then
        widget.tileBase = self:Own(plate:CreateTexture(nil, "BACKGROUND", nil, 7))
    end
    if not widget.tileLum then
        widget.tileLum = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, -8))
        widget.tileLum:SetBlendMode("MOD")
        widget.tileLum:SetAllPoints(bar)
        widget.tileCap = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 6))
    end
    local mirror = self:GetOption("plusMirror") and type(plate) == "table" and plate.mirror == true or false
    local key = variant .. "|" .. tostring(mirror) .. "|" .. self:LookName("tile-plain")
    if widget.tileKey ~= key then
        widget.tileKey = key
        local t = self.tileArts[variant].base
        if widget.tileBase then
            widget.tileBase:SetColorTexture(t[1], t[2], t[3], 1)
            widget.tileBase:ClearAllPoints()
            widget.tileBase:SetAllPoints(bar)
        end
        widget.tileLum:SetTexture(self.artPath .. self:LookName("tile-" .. variant .. "-lum") .. ".tga", "CLAMP", "CLAMP")
        widget.tileCap:ClearAllPoints()
        if type(plate) == "table" then widget.tileCap:SetAllPoints(plate) end
        local u0, u1 = 0, 1
        if mirror then u0, u1 = 1, 0 end
        widget.tileLum:SetTexCoord(u0, u1, 0, 1)
        widget.tileCap:SetTexCoord(u0, u1, 0, 1)
    end
    for _, part in ipairs({ "tileBase", "tileLum", "tileCap" }) do

        local want = part == "tileCap" or not chip
        if widget[part] and widget[part]:IsShown() ~= want then widget[part]:SetShown(want) end
    end





    if chip and not widget.tileWood and type(plate) == "table" and type(plate.CreateTexture) == "function" then
        widget.tileWood = self:Own(plate:CreateTexture(nil, "BACKGROUND", nil, 6))
    end
    local wood = widget.tileWood
    if wood then
        if chip then
            wood:ClearAllPoints()
            wood:SetAllPoints(plate)
            if mirror then wood:SetTexCoord(1, 0, 0, 1) else wood:SetTexCoord(0, 1, 0, 1) end
            if not wood:IsShown() then wood:Show() end

            self:DressPaintedRegion(wood, "tile-plain")
        else
            if wood:IsShown() then wood:Hide() end
            if wood.auiTwin and wood.auiTwin:IsShown() then wood.auiTwin:Hide() end
        end
    end


    self:DressPaintedRegion(widget.tileCap, "tile-" .. variant .. "-cap")
end

function A:PlusCompactHeight()
    return self:MantleGeometry(true).total
end








A.plusTotAirPx = 8
function A:PlusTotGap()
    return math.max(self:PlusFloatGap(), self:PlusSnap(A.plusTotAirPx * self:PlatePixel()))
end

function A:PlusBelow()
    local below = 0
    if self:GetOption("dpsStripOn") then below = self:PlusFooterHeight() + self:PlusFloatGap() end
    if self:GetOption("plusTotOn") and self:GetOption("plusTotPlacement") == "below" then
        local extra = self:PlusHeroHeight(false) + self:PlusTotGap() + self:PlusAbove(true)
            + (self.TargetCastUnderRow and self:TargetCastUnderRow() or 0)
            + self:PlusCompactHeight() - self:PlusHeroHeight(true)
        below = math.max(below, extra)
    end
    return below
end







A.plusCutFloor = 6
function A:PlusDetailFloor() return self:PlusSnap(self.plusCutFloor) - 1e-9 end





A.plusTroughTint = A.troughTint
function A:PlusTroughAlpha() return self.plusTroughTint end




local function lift(r, g, b, k)
    return r + (1 - r) * k, g + (1 - g) * k, b + (1 - b) * k
end
A.PlusLift = lift


















A.plusPowerCalm, A.plusPowerDim = 0.34, 0.92
function A:PlusPowerQuiet(r, g, b, a)
    if not r then return r, g, b, a end
    local mean = (r + g + b) / 3
    local k, v = self.plusPowerCalm, self.plusPowerDim
    return (r + (mean - r) * k) * v, (g + (mean - g) * k) * v, (b + (mean - b) * k) * v, a
end
















A.plusCarveRed = 0.20




function A:StandFill(widget, mirror, isPower)
    local bar = widget and widget.value
    if not bar then return false end
    local want = self:PlateArt().fill

    if widget.chip then want = A.chipFiles.clear end
    local key = want .. (mirror and "|m" or "")


    if widget.finish then widget.finish.barfinishfill = want .. ".tga" end
    if widget.standFill == key then return true end
    widget.standFill = key
    pcall(bar.SetStatusBarTexture, bar, self.artPath .. want .. ".tga")
    local fill = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture() or nil
    if fill and type(fill.SetTexCoord) == "function" then
        if mirror then pcall(fill.SetTexCoord, fill, 1, 0, 0, 1) else pcall(fill.SetTexCoord, fill, 0, 1, 0, 1) end
    end
    return true
end

















A.inlaySeamTone = { 0.02, 0.03, 0.035, 0.85 }
function A:InlayLight(widget, lane, on, chip)
    local bar = widget and widget.value
    if not bar or type(bar.CreateTexture) ~= "function" then return end
    if not on then
        for _, key in ipairs({ "inlayBase", "inlayLum", "inlayCap", "inlaySeam" }) do
            if widget[key] then widget[key]:Hide() end
        end
        return
    end
    local art = self:PlateArt()
    local plate = widget.plate or (type(bar.GetParent) == "function" and bar:GetParent()) or nil





    if not widget.inlayBase and type(plate) == "table" and type(plate.CreateTexture) == "function" then
        widget.inlayBase = self:Own(plate:CreateTexture(nil, "BACKGROUND", nil, 7))
    end
    if widget.inlayBase then
        local t = art.base[lane] or art.base.health
        local baseKey = string.format("%.4f|%.4f|%.4f", t[1], t[2], t[3])
        if widget.inlayBaseKey ~= baseKey then
            widget.inlayBaseKey = baseKey
            widget.inlayBase:SetColorTexture(t[1], t[2], t[3], 1)
        end
        widget.inlayBase:ClearAllPoints()
        widget.inlayBase:SetAllPoints(bar)

        widget.inlayBase:SetShown(not chip)
    end
    if not widget.inlayLum then
        local lum = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, -8))
        lum:SetBlendMode("MOD")
        lum:SetAllPoints(bar)
        widget.inlayLum = lum
        local cap = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 6))
        cap:SetTexture(self.artPath .. art.cap .. ".tga", "CLAMP", "CLAMP")
        cap:SetAllPoints(bar)
        widget.inlayCap = cap
    end

    local lumPath = self.artPath .. art.lum .. ".tga"
    if widget.inlayLum:GetTexture() ~= lumPath then widget.inlayLum:SetTexture(lumPath, "CLAMP", "CLAMP") end
    local mirror = self:GetOption("plusMirror") and type(plate) == "table" and plate.mirror == true
        and not plate.isParty or false
    local rows = art.lanes[lane] or art.lanes.health
    local span = art.winBot - art.winTop
    local v0, v1 = (rows[1] - art.winTop) / span, (rows[2] - art.winTop) / span
    local key = string.format("%s|%.4f|%.4f|%s", lane, v0, v1, tostring(mirror))
    if widget.inlayKey ~= key then
        widget.inlayKey = key
        local u0, u1 = 0, 1
        if mirror then u0, u1 = 1, 0 end
        widget.inlayLum:SetTexCoord(u0, u1, v0, v1)
        widget.inlayCap:SetTexCoord(u0, u1, v0, v1)
    end
    widget.inlayLum:SetShown(not chip)
    widget.inlayCap:Show()


    self:DressPaintedRegion(widget.inlayCap, art.cap)
    if lane == "power" then
        if not widget.inlaySeam then
            widget.inlaySeam = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, -7))
            local t = A.inlaySeamTone
            widget.inlaySeam:SetColorTexture(t[1], t[2], t[3], t[4])
        end
        local px = self:PlatePixel()
        widget.inlaySeam:ClearAllPoints()
        widget.inlaySeam:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
        widget.inlaySeam:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        widget.inlaySeam:SetHeight(px)
        widget.inlaySeam:SetShown(not chip)
    end
end





















































A.chipFiles = { head = "oak-chip-head", reveal = "oak-chip-reveal", rim = "oak-chip-rim", clear = "oak-chip-clear",
    debris = "oak-chip-debris", mask = "oak-chip-mask" }















A.chipDebrisWidth = 1.5




A.chipWidth = 1.6
A.chipTexU = 102.4 / 128



A.chipReach = (1.6 - 0.08) / 1.6



A.chipHeadMinPx = 10



function A:PlusChipOn()
    if not (self.db and self.optionIndex and self.optionIndex.plateFillStyle) then return false end
    if self.lookArtFor ~= "oakborn" then return false end
    local style = self:GetOption("plateFillStyle")
    if style ~= "auto" and style ~= "carved" then return false end
    local slots = self.artSlots or {}
    return slots.oakChipHead ~= nil and slots.oakChipReveal ~= nil and slots.oakChipRim ~= nil
        and slots.oakChipClear ~= nil
end



function A:PlusChipFor(tileVariant)
    if not self:PlusChipOn() then return false end
    local file = tileVariant and "tile-plain" or self:PlateFile()
    return self:LookName(file) ~= file
end

local function chipPiece(self, frame, sublevel, file, bar, u1)
    local t = self:Own(frame:CreateTexture(nil, "ARTWORK", nil, sublevel))
    t:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")
    if u1 then t:SetTexCoord(0, u1, 0, 1) end
    self.PlusClipToBar(self, bar, t)
    t:Hide()
    return t
end



function A:PlusChip(widget, on, height, lane, tileVariant)
    local bar = widget and widget.value
    if not bar then return false end
    if not on then
        if widget.finish and widget.finish.barfinishchip then
            widget.finish.barfinishchip = nil
            self:ApplyBarFinish(widget.finish, "barfinish")
        end
        if widget.chip then
            widget.chip, widget.chipKey, widget.chipGlide = nil, nil, nil
            for _, key in ipairs({ "chipBody", "chipHead", "chipRim", "chipDebris" }) do
                if widget[key] then widget[key]:Hide() end
            end
        end
        return false
    end
    local plate = widget.plate or (type(bar.GetParent) == "function" and bar:GetParent()) or nil
    if not widget.chipFrame then
        if type(plate) ~= "table" then return false end
        local f = self:Own(CreateFrame("Frame", nil, plate))
        local base = self:Number(plate.GetFrameLevel, 1, plate) or 1
        pcall(f.SetFrameLevel, f, base + 1)
        if type(f.EnableMouse) == "function" then f:EnableMouse(false) end
        f:SetAllPoints(bar)
        widget.chipFrame = f
        local files = A.chipFiles
        widget.chipBody = chipPiece(self, f, 1, files.reveal, bar)
        widget.chipHead = chipPiece(self, f, 2, files.head, bar, A.chipTexU)
        widget.chipRim = chipPiece(self, f, 3, files.rim, bar, A.chipTexU)
    end
    if not widget.chipDebris and (self.artSlots or {}).oakChipDebris and (self.artSlots or {}).oakChipMask then
        local f = widget.chipFrame
        widget.chipDebris = chipPiece(self, f, 4, A.chipFiles.debris, bar)
        if type(f.CreateMaskTexture) == "function" then
            local ok, mask = pcall(f.CreateMaskTexture, f, nil, "ARTWORK")
            if ok and mask then
                self:Own(mask)
                mask:SetTexture(self.artPath .. A.chipFiles.mask .. ".tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                pcall(widget.chipDebris.AddMaskTexture, widget.chipDebris, mask)
                widget.chipRevealMask = mask
            end
        end
    end
    widget.chip, widget.chipLane = true, lane

    if widget.finish and widget.finish.barfinishchip ~= true then
        widget.finish.barfinishchip = true
        self:ApplyBarFinish(widget.finish, "barfinish")
    end
    widget.chipFile = tileVariant and "tile-plain" or self:PlateFile()
    widget.chipHeight = height
    self:PlusChipAnchor(widget)

    local r, g, b = self:PaintedBodyTint(widget.chipFile)
    local rim = widget.chipRim
    local cr, cg, cb = rim:GetVertexColor()
    if math.abs((cr or 1) - r) > 1e-4 or math.abs((cg or 1) - g) > 1e-4 or math.abs((cb or 1) - b) > 1e-4 then
        rim:SetVertexColor(r, g, b, 1)
        if widget.chipDebris then widget.chipDebris:SetVertexColor(r, g, b, 1) end
    end
    return true
end



function A:PlusChipAnchor(widget)
    local bar = widget and widget.value
    if not (bar and widget.chip and widget.chipBody) then return end
    local fill = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture() or nil
    local down = widget.chipDown == true or fill == nil
    local laneH = tonumber(widget.chipHeight) or 0
    local w = math.max(self:PlatePixel(), self:PlusSnap(laneH * A.chipWidth))


    local thin = laneH < A.chipHeadMinPx * self:PlatePixel()
    local motion = self:MotionLevel()

    widget.chipGlide = (motion == "subtle" and not thin and not down and widget.chipLane ~= "power") or nil
    local trail = widget.trail
    local trailFill = trail and type(trail.GetStatusBarTexture) == "function" and trail:GetStatusBarTexture() or nil
    local crumble = motion == "full" and not thin and not down and widget.chipDebris ~= nil
        and widget.chipRevealMask ~= nil and trailFill ~= nil
    local key = string.format("%s|%s|%.4f|%s", tostring(down), tostring(thin), w, tostring(crumble))
    if widget.chipKey == key then return end
    widget.chipKey = key
    local body, head, rim = widget.chipBody, widget.chipHead, widget.chipRim
    local debris, reveal = widget.chipDebris, widget.chipRevealMask
    if debris then
        debris:ClearAllPoints()
        if crumble then

            debris:SetPoint("TOPRIGHT", trailFill, "TOPRIGHT", 0, 0)
            debris:SetPoint("BOTTOMRIGHT", trailFill, "BOTTOMRIGHT", 0, 0)
            debris:SetWidth(math.max(self:PlatePixel(), self:PlusSnap(laneH * A.chipDebrisWidth)))
            reveal:ClearAllPoints()
            reveal:SetPoint("TOPLEFT", fill, "TOPRIGHT", 0, 0)
            reveal:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
            debris:Show()
        else
            debris:Hide()
        end
    end
    body:ClearAllPoints(); head:ClearAllPoints(); rim:ClearAllPoints()
    if down then
        body:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        body:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        body:Show(); head:Hide(); rim:Hide()
        return
    end
    if thin then
        body:SetPoint("TOPLEFT", fill, "TOPRIGHT", 0, 0)
        body:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        body:Show(); head:Hide(); rim:Hide()
        return
    end
    for _, t in ipairs({ head, rim }) do
        t:SetPoint("TOPLEFT", fill, "TOPRIGHT", 0, 0)
        t:SetPoint("BOTTOMLEFT", fill, "BOTTOMRIGHT", 0, 0)
        t:SetWidth(w)
        t:Show()
    end
    body:SetPoint("TOPLEFT", fill, "TOPRIGHT", w * A.chipReach, 0)
    body:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    body:Show()
end


function A:PaintChip(widget, r, g, b)
    if not (widget and widget.chipBody and r) then return end
    widget.chipBody:SetVertexColor(r, g, b, 1)
    widget.chipHead:SetVertexColor(r, g, b, 1)
end



function A:PlusChipColour(widget, unit, kind)
    local rgb = widget and widget.lossRGB
    if not (rgb and widget.chipBody) then return "off" end
    if kind ~= "power" and widget.chipDown ~= true then
        local curve = self:LossCurve(rgb[1], rgb[2], rgb[3])
        if curve and type(UnitHealthPercent) == "function" then
            local ok, c = pcall(UnitHealthPercent, unit, true, curve)
            if ok and type(c) == "table" then

                local a = pcall(widget.chipBody.SetVertexColor, widget.chipBody, c.r, c.g, c.b, 1)
                local b = pcall(widget.chipHead.SetVertexColor, widget.chipHead, c.r, c.g, c.b, 1)
                if a and b then
                    self.carveCurveLive = true
                    return "curve"
                end
            end
        end
        self.carveCurveLive = false
    end
    self:PaintChip(widget, rgb[1], rgb[2], rgb[3])
    return "plain"
end






A.healGhostAlpha = { carved = 0.45, mantle = 0.55 }
function A:HealGhostStyle()
    if self:PlusChipOn() then return "carved" end
    return "mantle"
end
function A:PaintHealGhost(widget, r, g, b)
    local heal = widget and widget.heal
    if not heal then return end
    local style = self:HealGhostStyle()
    local alpha = A.healGhostAlpha[style]
    if style == "carved" and r then
        local lr, lg, lb = lift(r, g, b, 0.45)
        local key = string.format("c|%.3f|%.3f|%.3f", lr, lg, lb)
        if heal.auiGhostKey ~= key then
            heal.auiGhostKey = key
            self.themed[heal] = nil
            heal:SetStatusBarColor(lr, lg, lb)
            heal:SetAlpha(alpha)
        end
        return
    end
    if heal.auiGhostKey ~= style then
        heal.auiGhostKey = style
        self:Tint(heal, "gain", "bar")
        heal:SetAlpha(alpha)
    end
end

function A:PlaintedPathSafe(name)
    if type(self.PaintedPath) == "function" then return self:PaintedPath(name) end
    return self.artPath .. name .. ".tga", false
end



function A:LossCurve(r, g, b)
    if not (type(C_CurveUtil) == "table" and type(C_CurveUtil.CreateColorCurve) == "function") then return nil end
    local scheme = self:Scheme()
    local key = string.format("%s|%.3f|%.3f|%.3f", tostring(scheme and scheme.id), r, g, b)
    self.lossCurves = self.lossCurves or {}
    local curve = self.lossCurves[key]
    if curve == nil then
        local dr, dg, db = self:Color("danger")
        local function colour(cr, cg, cb)
            if type(CreateColor) == "function" then return CreateColor(cr, cg, cb, 1) end
            return { r = cr, g = cg, b = cb, a = 1 }
        end
        local ok, made = pcall(function()
            local c = C_CurveUtil.CreateColorCurve()
            local step = type(Enum) == "table" and type(Enum.LuaCurveType) == "table" and Enum.LuaCurveType.Step
            if step ~= nil and type(c.SetType) == "function" then c:SetType(step) end
            local red = self.plusCarveRed
            c:AddPoint(0, colour(dr, dg, db))
            c:AddPoint(red - 0.001, colour(dr, dg, db))
            c:AddPoint(red, colour(r, g, b))
            c:AddPoint(1, colour(r, g, b))
            return c
        end)
        curve = (ok and type(made) == "table") and made or false
        self.lossCurves[key] = curve
    end
    return curve or nil
end


function A:CarveReport()
    if self:PlusChipOn() then
        local live = type(C_CurveUtil) == "table" and type(C_CurveUtil.CreateColorCurve) == "function"
        return string.format("chip: on | plate %s | colour curve %s | last paint %s",
            tostring(self.OakPlateShape and self:OakPlateShape()), live and "available" or "ABSENT",
            self.carveCurveLive == true and "curve" or (self.carveCurveLive == false and "plain" or "none yet"))
    end
    return "chip: off"
end





























local PANEL_CORNER = {
    TOPRIGHT    = { 0, 1, 1, 0 },
    BOTTOMRIGHT = { 0, 1, 0, 1 },
    TOPLEFT     = { 1, 0, 1, 0 },
    BOTTOMLEFT  = { 1, 0, 0, 1 },
}
local function flatPanel(self, host, layer, sublevel)
    local panel = {
        body = self:Own(host:CreateTexture(nil, layer, nil, sublevel)),
        wedge = self:Own(host:CreateTexture(nil, layer, nil, sublevel)),
        tail = self:Own(host:CreateTexture(nil, layer, nil, sublevel)),
    }
    panel.wedge:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
    panel.wedge:Hide()
    panel.tail:Hide()
    return panel
end









local function placePanel(self, panel, host, x0, x1, top, bottom, corner, cut)
    local coord = corner and PANEL_CORNER[corner]
    cut = (coord and cut and cut > 1) and math.floor(cut + 0.5) or 0
    local right = corner == "TOPRIGHT" or corner == "BOTTOMRIGHT"
    panel.body:ClearAllPoints()
    panel.body:SetPoint("TOPLEFT", host, "TOPLEFT", x0 + ((cut > 0 and not right) and cut or 0), top)
    panel.body:SetPoint("BOTTOMRIGHT", host, "TOPRIGHT", x1 - ((cut > 0 and right) and cut or 0), bottom)
    panel.wedge:ClearAllPoints()
    panel.tail:ClearAllPoints()
    local tailed = false
    if cut > 0 then
        panel.wedge:SetTexCoord(coord[1], coord[2], coord[3], coord[4])
        local atTop = corner == "TOPRIGHT" or corner == "TOPLEFT"
        local vertical = atTop and "TOP" or "BOTTOM"
        local horizontal = right and "RIGHT" or "LEFT"
        local edgeX = right and x1 or x0
        panel.wedge:SetPoint(vertical .. horizontal, host, "TOP" .. horizontal,
            edgeX, atTop and top or bottom)
        panel.wedge:SetSize(cut, cut)

        tailed = (top - bottom) > cut
        if tailed then
            panel.tail:SetPoint("TOPLEFT", host, "TOP" .. horizontal,
                right and (edgeX - cut) or edgeX, atTop and (top - cut) or top)
            panel.tail:SetPoint("BOTTOMRIGHT", host, "TOP" .. horizontal,
                right and edgeX or (edgeX + cut), atTop and bottom or (bottom + cut))
        end
    end
    panel.wedge:SetShown(cut > 0)
    panel.tail:SetShown(tailed)
    return cut
end




local function tintPanel(self, panel, role, alpha)
    self:Tint(panel.body, role, "color", alpha)
    self:Tint(panel.wedge, role, "vertex", alpha)
    self:Tint(panel.tail, role, "color", alpha)
end



























local function placeRim(self, rim, host, px, x0, x1, top, bottom, corner, cut, on)
    if not rim then return 0 end
    if not on then
        rim.body:Hide(); rim.wedge:Hide(); rim.tail:Hide()
        return 0
    end
    px = math.max(0.34, math.min(4, px or 1))
    local used = placePanel(self, rim, host, x0 - px, x1 + px, top + px, bottom - px, corner, cut)
    rim.body:Show()
    return used
end

A.PlusFlatPanel, A.PlusPlacePanel, A.PlusTintPanel = flatPanel, placePanel, tintPanel
A.PlusPlaceRim = placeRim

local function newPlate(self, name, height, width, parent, compact)
    local plate = CreateFrame("Frame", name, parent or UIParent)
    self:Own(plate)
    plate:SetSize(width or PLAYER_W_FALLBACK, height)
    plate:SetFrameStrata("LOW")
    plate:SetFrameLevel(PLATE_LEVEL)
    plate:EnableMouse(false)
    local sp = self.tokens.space



    plate.hero = not compact


    plate.barFrame = self:BarFrame(plate, "BACKGROUND", -7)


    plate.veil = {}





    plate.flashFx = self:EdgeFlash(plate, plate, "f")



    plate.name = plate:CreateFontString(nil, "OVERLAY")




    self:SetPixelFont(plate.name, compact and "body" or "hero", self:UnitScale(), not compact)
    plate.name:SetPoint("TOPLEFT", plate, "TOPLEFT", sp.sm, -sp.sm)
    plate.name:SetWidth((width or PLAYER_W_FALLBACK) - 64)
    plate.name:SetJustifyH("LEFT")
    plate.name:SetWordWrap(false)
    self:Tint(plate.name, "text", "text")

    plate.level = plate:CreateFontString(nil, "OVERLAY")
    self:SetPixelFont(plate.level, compact and "caption" or "body", self:UnitScale(), false)
    plate.level:SetPoint("TOPRIGHT", plate, "TOPRIGHT", -sp.sm, -sp.sm)
    plate.level:SetWidth(compact and 18 or 22)
    plate.level:SetJustifyH("CENTER")
    self:Tint(plate.level, "accent", "text", 0.92)





    plate.sweepFx = self:Fx(plate, "sweep", "sweep-band", "OVERLAY", 7)
    return plate
end

A.plusSweepBand = 52
























local function cutPiece(self, bar, layer, sublevel)
    local body = self:Own(bar:CreateTexture(nil, layer, nil, sublevel))
    local wedge = self:Own(bar:CreateTexture(nil, layer, nil, sublevel))
    wedge:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")



    wedge:SetTexCoord(0, 1, 1, 0)
    return { body = body, wedge = wedge }
end






local function anchorCut(self, piece, bar, inset)


    piece.body:ClearAllPoints()
    piece.body:SetPoint("TOPLEFT", bar, "TOPLEFT", -inset, inset)
    piece.body:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", inset, -inset)
    piece.wedge:Hide()
    return 0
end






local function paintCut(piece, r, g, b, a)
    piece.body:SetColorTexture(r, g, b, a or 1)
    piece.wedge:SetVertexColor(r, g, b, a or 1)
end
A.PlusPaintCut = paintCut















local function clipToBar(self, bar, region)
    if not region or type(region.AddMaskTexture) ~= "function" then return nil end
    if not bar.auiClip then
        if type(bar.CreateMaskTexture) ~= "function" then return nil end
        local ok, mask = pcall(bar.CreateMaskTexture, bar, nil, "BACKGROUND")
        if not (ok and mask) then return nil end
        self:Own(mask)
        mask:SetTexture(self.artPath .. "meter.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(bar)
        bar.auiClip = mask
    end
    pcall(region.AddMaskTexture, region, bar.auiClip)
    return bar.auiClip
end
A.PlusClipToBar = clipToBar







local TICKS = { 0.25, 0.5, 0.75 }




























local function newBar(self, plate, y, height, width, compact)




    local trail = self:Own(CreateFrame("StatusBar", nil, plate))
    trail:EnableMouse(false)



    trail:SetStatusBarTexture(self.artPath .. "bar-gradient.tga")
    trail:SetMinMaxValues(0, 1)
    trail:SetValue(0)
    self:Tint(trail, "loss", "bar")
    local heal = self:Own(CreateFrame("StatusBar", nil, plate))
    heal:EnableMouse(false)
    heal:SetStatusBarTexture(self.artPath .. "meter.tga")
    heal:SetMinMaxValues(0, 1)
    heal:SetValue(0)
    self:Tint(heal, "gain", "bar")



    heal:SetAlpha(0.72)
    local bar = CreateFrame("StatusBar", nil, plate)
    self:Own(bar)
    local base = self:Number(plate.GetFrameLevel, 1, plate) or 1
    pcall(trail.SetFrameLevel, trail, base + 1)
    pcall(heal.SetFrameLevel, heal, base + 2)
    pcall(bar.SetFrameLevel, bar, base + 3)
    bar:SetPoint("TOPLEFT", plate, "TOPLEFT", self.tokens.space.sm, y)
    bar:SetSize((width or PLAYER_W_FALLBACK) - self.tokens.space.sm * 2, height)
    bar:EnableMouse(false)
    bar:SetStatusBarTexture(self.artPath .. "meter.tga")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)


















    local key = cutPiece(self, plate, "BORDER", -8)
    self:Tint(key.body, compact and "ink" or "inkDeep", "color", 0.92)
    self:Tint(key.wedge, compact and "ink" or "inkDeep", "vertex", 0.92)
    local back = cutPiece(self, plate, "BORDER", -7)
    self:Tint(back.body, "well", "color")
    self:Tint(back.wedge, "well", "vertex")


    local ghost = cutPiece(self, plate, "BORDER", -6)
    self:Tint(ghost.body, "tint", "color", self:PlusTroughAlpha())
    self:Tint(ghost.wedge, "tint", "vertex", self:PlusTroughAlpha())
    local ticks = {}
    for i = 1, #TICKS do
        local t = self:Own(plate:CreateTexture(nil, "BORDER", nil, -5))
        t:SetWidth(1)






        self:Tint(t, "muted", "color", 0.28)
        ticks[i] = t
    end

























    local redline
    do
        local stem = self:Own(plate:CreateTexture(nil, "BORDER", nil, -4))
        stem:SetWidth(1)
        self:Tint(stem, "danger", "color", 0.85)
        local notchTop = self:Own(plate:CreateTexture(nil, "BORDER", nil, -4))
        notchTop:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
        notchTop:SetTexCoord(1, 0, 0, 1)
        self:Tint(notchTop, "danger", "vertex", 0.85)
        local notchBottom = self:Own(plate:CreateTexture(nil, "BORDER", nil, -4))
        notchBottom:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
        notchBottom:SetTexCoord(1, 0, 1, 0)
        self:Tint(notchBottom, "danger", "vertex", 0.85)
        redline = { stem = stem, top = notchTop, bottom = notchBottom }
    end

    local label = bar:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(label, self.tokens.type.caption, false)
    label:Hide()




    local text = bar:CreateFontString(nil, "OVERLAY")

    self:SetThemedFont(text, self:Type("caption"), false)
    if text.SetDrawLayer then text:SetDrawLayer("OVERLAY", 5) end
    text:SetPoint("RIGHT", bar, "RIGHT", -self.tokens.space.xs, 0)
    text:SetJustifyH("RIGHT")
    self:Tint(text, compact and "muted" or "text", "text")
    local finish = {}


    self:BarFinish(finish, bar, nil, true)
    bar.auiGhostAlpha = self:PlusTroughAlpha()






    local ember = self:Fx(bar, "ember", "bar-bloom")
    local flare = self:Fx(bar, "flare", "bar-bloom")




    local danger = self:Fx(bar, "danger", "bar-bloom")





    local trailFill = type(trail.GetStatusBarTexture) == "function" and trail:GetStatusBarTexture() or nil
    local trailCut
    if trailFill and type(trailFill.SetPoint) == "function" then
        trailCut = self:Own(trail:CreateTexture(nil, "OVERLAY", nil, 3))
        trailCut:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
        trailCut:SetTexCoord(1, 0, 0, 1)
        trailCut:SetPoint("TOPRIGHT", trailFill, "TOPRIGHT", 0, 0)
        self:Tint(trailCut, "well", "vertex")
    end








    local fill = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture() or nil
    if fill and type(fill.SetPoint) == "function" then
        heal:ClearAllPoints()
        heal:SetPoint("TOPLEFT", fill, "TOPRIGHT", 0, 0)
    end
    local healFill = type(heal.GetStatusBarTexture) == "function" and heal:GetStatusBarTexture() or nil
    local healCut
    if healFill and type(healFill.SetPoint) == "function" then



        healCut = self:Own(heal:CreateTexture(nil, "OVERLAY", nil, 3))
        healCut:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
        healCut:SetTexCoord(1, 0, 0, 1)
        healCut:SetPoint("TOPRIGHT", healFill, "TOPRIGHT", 0, 0)
        self:Tint(healCut, "well", "vertex")
    end
















    local seam
    if fill and type(fill.SetPoint) == "function" then
        seam = self:Own(trail:CreateTexture(nil, "OVERLAY", nil, 4))
        seam:SetPoint("TOPLEFT", fill, "TOPRIGHT", 0, 0)
        seam:SetPoint("BOTTOMLEFT", fill, "BOTTOMRIGHT", 0, 0)
        seam:SetWidth(2)
        self:Tint(seam, "well", "color")
        clipToBar(self, bar, seam)
    end



















    local lead
    if fill and type(fill.SetPoint) == "function" then
        lead = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 3))
        lead:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
        lead:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0, 0)
        lead:SetWidth(2)
        self:Tint(lead, "tint", "color", 0.9)
        clipToBar(self, bar, lead)
        lead:Hide()
    end
    heal.auiMask = clipToBar(self, bar, healFill)
    clipToBar(self, bar, healCut)
    clipToBar(self, bar, trailCut)
    clipToBar(self, bar, finish.barfinishB8)
    return { value = bar, trail = trail, heal = heal, label = label, text = text, finish = finish,
             back = back, ghost = ghost, keyline = key, trailCut = trailCut, healCut = healCut,
             seam = seam, lead = lead,
             redlineArt = redline,
             ticks = ticks, ember = ember, flare = flare, danger = danger, cut = finish.barfinishB8 }
end





local function newMarker(self, plate)
    local marker = self:Own(plate:CreateTexture(nil, "OVERLAY"))
    marker:SetSize(16, 16)
    marker:SetPoint("LEFT", plate, "RIGHT", self.tokens.space.xs, 0)
    marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    marker:Hide()
    return marker
end

local PARTY_MAX = 4
local PARTY_ROW_H = 40





function A:PaintPlateLight(plate, r, g, b)
    if not plate or not r then return end
    plate.lightRGB = { r, g, b }
    if plate.flashFx then self:PaintEdgeFlash(plate.flashFx, lift(r, g, b, 0.35)) end
end


















A.plusSeam, A.plusStep = 4, 20
A.plusStud, A.plusStudSmall = 26, 18











A.plusShelfLean = 0.95



A.plusFootCut = 10



A.castNotch = 4





function A:PlusShelfCut(compact)
    local rowTop = compact and self:PlusCompactTop() or self:PlusHeaderTop()
    return math.max(6, math.floor(math.max(12, rowTop - self.plusSeam) * self.plusShelfLean))
end











function A:PlusShelfClear(compact)
    return self:PlusStep() + math.ceil(self:PlusShelfCut(compact) / 2)
end




































function A:PlusUnified()
    if not (self.db and self.optionIndex) then return true end
    return self:GetOption("plusUnified") ~= false
end
function A:PlusStep()
    return self:PlusUnified() and 0 or self.plusStep
end
function A:PlusSeam()
    return self:PlusUnified() and 0 or self.plusSeam
end







































function A:FramePixel(frame)
    local ui = _G.UIParent
    local uiScale = (ui and self:Number(ui.GetEffectiveScale, 1, ui)) or 1
    local pp = self:PhysicalPixel(ui)
    local scale = (frame and self:Number(frame.GetEffectiveScale, 1, frame)) or uiScale
    if pp <= 0 or scale <= 0.05 or uiScale <= 0.05 then return 0, 0, scale end
    local px = pp * uiScale / scale
    if px <= 0 then return 0, 0, scale end
    return 1 / px, px, scale
end

function A:MeasureReport(say)
    local ui = _G.UIParent
    local uiScale = ui and self:Number(ui.GetEffectiveScale, 1, ui) or 1
    local pp = self:PhysicalPixel(ui)
    say(string.format("measure | UIParent scale %.4f | physical pixel %.4f UI units | snap %s",
        uiScale or 1, pp, self:PixelSnapOn() and "on" or "off"))
    local function line(label, frame)
        if type(frame) ~= "table" or type(frame.GetRect) ~= "function" then
            say("  " .. label .. ": absent"); return
        end
        local ok, x, y, w, h = pcall(frame.GetRect, frame)
        if not ok or not self:IsPublic(x) or type(x) ~= "number" then
            say("  " .. label .. ": no rect"); return
        end
        local dev, px, scale = self:FramePixel(frame)
        say(string.format("  %-12s x %7.2f  y %7.2f  w %7.2f  h %6.2f  scale %.4f",
            label, x, y, w, h, scale))
        say(string.format("  %-12s dev px: x %8.2f  y %8.2f  w %8.2f  h %7.2f  (one pixel = %.4f of its units)",
            "", x * dev, y * dev, w * dev, h * dev, px))
    end
    local plus = self.plusActive and self.plus or nil
    if not plus then say("  No Plus plates on screen (Lite mode, or Plus was refused)."); return end
    local casts = self.castBars or {}
    line("cast strip", casts.player)
    line("plate", plus.player)
    line("shelf", plus.player and plus.player.shelf and plus.player.shelf.body)
    line("block", plus.player and plus.player.block and plus.player.block.body)
    line("health", plus.player and plus.player.health and plus.player.health.value)
    line("power", plus.player and plus.player.power and plus.player.power.value)
    line("footer", self.damageStrip)
    line("target", plus.target)
    say("  Right edges that should agree: plate / cast strip / footer, then health / power.")
    say("  Every `dev px` number should be a WHOLE pixel while snap is on (A:PlusSnap).")
end

















local ARM_ROWS = { { "top", "topBar", "TopCenteredAnchor" }, { "left", "leftBar", "LeftCenteredAnchor" },
                   { "right", "rightBar", "RightCenteredAnchor" }, { "bottom", "bottomBar", "BottomCenteredAnchor" } }

function A:MeasureCompass(say)
    local page = _G.GamepadMainActionBarFrame and _G.GamepadMainActionBarFrame.PageUnit
    local D = self.dock
    if not page or type(page.actionBars) ~= "table" or not D then
        say("  compass: no gamepad action bar on screen."); return
    end



    local function rect(frame)
        if type(frame) ~= "table" or type(frame.GetRect) ~= "function" then return nil end
        local ok, x, y, w, h = pcall(frame.GetRect, frame)
        if not ok then return nil end
        if not (self:IsPublic(x) and self:IsPublic(y) and self:IsPublic(w) and self:IsPublic(h)) then return nil end
        if type(x) ~= "number" or type(y) ~= "number" or type(w) ~= "number" or type(h) ~= "number" then return nil end
        local dev = self:FramePixel(frame)
        if dev <= 0 or w <= 0 then return nil end
        return { x = x * dev, y = y * dev, w = w * dev, h = h * dev }
    end
    local function show(label, frame, extra)
        local r = rect(frame)
        if not r then say(string.format("  %-13s no rect", label)); return nil end
        say(string.format("  %-13s x %8.2f  y %8.2f  w %8.2f  h %7.2f%s",
            label, r.x, r.y, r.w, r.h, extra and ("   " .. extra) or ""))
        return r
    end
    local ui = _G.UIParent
    local uiDev = self:FramePixel(ui)
    local uiR = rect(ui)
    local screenAxis = uiR and (uiR.x + uiR.w / 2) or 0
    say(string.format("measure compass | screen axis %.1f px | DOCK.cx %d | spread %d | layout %s | ground %s | dockScale %.3f",
        screenAxis, D.cx or 0, D.spread or 0, "live",
        self:CompassGroundMode(), self:LayoutMetrics().dockScale))
    local root = show("root", _G.GamepadMainActionBarFrame)
    local rootAxis = root and (root.x + root.w / 2) or screenAxis
    local content, grounds, allGroups = {}, {}, {}
    local decorations = self.nativeSkins and self.nativeSkins.actions
        and self.nativeSkins.actions.decorations or {}
    for _, row in ipairs(ARM_ROWS) do
        local name, barKey, anchorKey = row[1], row[2], row[3]
        local bar = page.actionBars[barKey]
        local anchor = page[anchorKey]
        local ar, br = rect(anchor), rect(bar)
        say(string.format("  arm %-9s anchor %s   bar %s   state %s", name,
            ar and string.format("x %8.2f y %8.2f", ar.x + ar.w / 2, ar.y + ar.h / 2) or "no rect",
            br and string.format("%7.2f x %6.2f", br.w, br.h) or "no rect",
            self:CompassArmState(bar)))
        local box
        local groupBoxes = {}
        for _, gkey in ipairs({ "Left", "Right" }) do
            local group = bar and bar[gkey]
            local x0, x1, y0, y1, sizes = nil, nil, nil, nil, {}
            for i = 1, 4 do
                local sr = rect(group and group["ActionButton" .. i])
                sizes[#sizes + 1] = sr and string.format("%.0f", sr.w) or "?"
                if sr then
                    if not x0 or sr.x < x0 then x0 = sr.x end
                    if not x1 or sr.x + sr.w > x1 then x1 = sr.x + sr.w end
                    if not y0 or sr.y < y0 then y0 = sr.y end
                    if not y1 or sr.y + sr.h > y1 then y1 = sr.y + sr.h end
                end
            end
            if x0 then




                local gid
                for _, e in ipairs(self.compassGroups or {}) do
                    if e.bar == barKey and e.group == gkey then gid = e.id end
                end
                local scaleNote = ""
                if gid then
                    local live = self:Number(group.GetScale, 1, group)
                    scaleNote = string.format("  scale %.2f (asked %.2f, frame %s)  layout diamond",
                        self:CompassGroupScale(gid), self:CompassGroupScaleRaw(gid),
                        live and string.format("%.3f", live) or "n/a")
                end
                say(string.format("    group %-5s box x %8.2f..%8.2f  y %8.2f..%8.2f  slots %s  centre %8.2f%s",
                    gkey:lower(), x0, x1, y0, y1, table.concat(sizes, "/"), (x0 + x1) / 2, scaleNote))
                groupBoxes[#groupBoxes + 1] = { x0, x1, y0, y1 }
                box = box and { math.min(box[1], x0), math.max(box[2], x1),
                                math.min(box[3], y0), math.max(box[4], y1) }
                    or { x0, x1, y0, y1 }
            else
                say(string.format("    group %-5s no rect", gkey:lower()))
            end
        end
        if box then content[name] = { cx = (box[1] + box[2]) / 2, cy = (box[3] + box[4]) / 2 } end
        for _, gb in ipairs(groupBoxes) do allGroups[#allGroups + 1] = gb end
        local entries = bar and decorations[bar]





        local gr
        for _, key in ipairs({ "groundRail", "groundSlab", "groundArm", "groundLeft" }) do
            local host = entries and entries[key]
            if host and self:Read(host.IsShown, 1, host) == true then gr = host; break end
        end
        local r = gr and rect(gr)
        if r then
            grounds[name] = r
            say(string.format("    ground      x %8.2f  y %8.2f  w %8.2f  h %7.2f   off its cluster %+.2f",
                r.x, r.y, r.w, r.h, box and ((r.x + r.w / 2) - (box[1] + box[2]) / 2) or 0))
        else
            say("    ground      none")
        end
    end
    local legend = show("legend", page.CenteredIcons,
        rect(page.CenteredIcons) and string.format("off the axis %+.2f",
            rect(page.CenteredIcons).x + rect(page.CenteredIcons).w / 2 - rootAxis) or nil)
    local tl = show("tab LT", page.LeftIcon)
    local tr = show("tab RT", page.RightIcon)
    show("crown", page.PageTracker)

    local rootEntries = decorations[_G.GamepadMainActionBarFrame]
    local baseHost = rootEntries and rootEntries.groundBase
    if baseHost and baseHost.baseRect then
        local b = baseHost.baseRect
        show("base", baseHost)
        say(string.format("  base strip %d x %d units (head %d), w/h %.2f, plate %.1f units at unitScale",
            b.w, b.h, b.head, b.h > 0 and b.w / b.h or 0,
            (self.PlusPlateWidth and self:PlusPlateWidth(false) or 0) * ((self.db and tonumber(self.db.scale)) or 1)))
    end

    local dividerHost = rootEntries and rootEntries.groundDivider
    if dividerHost and dividerHost.baseRect and dividerHost:IsShown() then
        local b = dividerHost.baseRect
        show("divider", dividerHost)
        say(string.format("  divider %d x %d units, w/h %.2f (the painting's 9.14), held %s / %s",
            b.w, b.h, b.h > 0 and b.w / b.h or 0,
            tostring(dividerHost.held and dividerHost.held.left), tostring(dividerHost.held and dividerHost.held.right)))
    end

    local drawn0, drawn1
    for _, c in pairs(content) do
        drawn0 = math.min(drawn0 or c.cx, c.cx); drawn1 = math.max(drawn1 or c.cx, c.cx)
    end
    local axisErr = 0
    if content.top then axisErr = math.max(axisErr, math.abs(content.top.cx - rootAxis)) end
    if content.bottom then axisErr = math.max(axisErr, math.abs(content.bottom.cx - rootAxis)) end
    local mirror = (content.left and content.right)
        and math.abs((content.left.cx + content.right.cx) / 2 - rootAxis) or -1
    local tabErr = (tl and tr) and math.abs((tl.x + tl.w / 2 + tr.x + tr.w / 2) / 2 - rootAxis) or -1
    local worst = 0
    local names = {}
    for name in pairs(grounds) do names[#names + 1] = name end
    table.sort(names)
    for i = 1, #names do
        for j = i + 1, #names do
            local a, b = grounds[names[i]], grounds[names[j]]
            local ox = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x)
            local oy = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y)
            local ov = math.min(ox, oy)
            if ov > worst then worst = ov end
        end
    end
    local plus = self.plusActive and self.plus or nil
    local pp, tp = plus and rect(plus.player), plus and rect(plus.target)
    local mid = (pp and tp) and ((pp.x + pp.w / 2 + tp.x + tp.w / 2) / 2) or nil
    say(string.format("  SUMMARY  drawn content %.1f..%.1f  root axis %.1f  screen axis %.1f"
        .. "  (your compass mover: %+.1f px)",
        drawn0 or 0, drawn1 or 0, rootAxis, screenAxis, rootAxis - screenAxis))
    say(string.format("  SUMMARY  axis error %.2f px | mirror error %s px | worst ground overlap %.2f px"
        .. " | tab mirror %s | plate pair midpoint %s",
        axisErr, mirror >= 0 and string.format("%.2f", mirror) or "n/a", worst,
        tabErr >= 0 and string.format("%.2f", tabErr) or "n/a",
        mid and string.format("%.1f px (screen axis %.1f)", mid, screenAxis) or "no plates"))


    local groupWorst = 0
    for i = 1, #allGroups do
        for j = i + 1, #allGroups do
            local a, b = allGroups[i], allGroups[j]
            local ox = math.min(a[2], b[2]) - math.max(a[1], b[1])
            local oy = math.min(a[4], b[4]) - math.max(a[3], b[3])
            if ox > 0 and oy > 0 then groupWorst = math.max(groupWorst, math.min(ox, oy)) end
        end
    end
    say(string.format("  SUMMARY  worst group overlap %.2f px | skin %s | auto-spread %s",
        groupWorst, self.CompassSkin and self:CompassSkin() or "n/a",
        tostring(self.optionIndex and self.optionIndex.compassAutoSpread and self:GetOption("compassAutoSpread") or "n/a")))
    say("  The first three must each be <= 0.5 px. The mover is the player's and is not an error.")
    return { axis = axisErr, mirror = mirror, overlap = worst, legend = legend and true or false,
             uiDev = uiDev, groupOverlap = groupWorst }
end


















function A:MeasureEffects(say)
    local plus = self.plusActive and self.plus or nil
    if not plus then return end
    local key = self:BarEffectKey()
    say(string.format("effect  style=%s  motion=%s  loops %d/%d%s", key, self:MotionLevel(),
        self:MotionLoopCount(), self.motionLoopBudget,
        self.barEffectsOff and "  [GLOBAL KILL ON]" or ""))
    local function box(frame)
        if type(frame) ~= "table" or type(frame.GetRect) ~= "function" then return nil end
        local rect = { pcall(frame.GetRect, frame) }
        if not rect[1] then return nil end
        local x, w = rect[2], rect[4]
        if not (self:IsPublic(x) and self:IsPublic(w)) then return nil end
        if type(x) ~= "number" or type(w) ~= "number" then return nil end
        return x, w, self:FramePixel(frame)
    end
    for _, id in ipairs({ "player", "target" }) do
        local plate = plus[id]
        local report = plate and self:BarEffectReport(plate.health)
        if not report then
            say(string.format("  %-6s health  no effect layer (style %s draws nothing)", id, key))
        else
            say(string.format("  %-6s health  tex %d/%d  groups %d/%d  particles %s  tint %s",
                id, report.tex, report.capTex, report.groups, report.capGroups,
                report.small and "off (below the detail floor)" or "on",
                report.r and string.format("%.2f/%.2f/%.2f", report.r, report.g, report.b) or "-"))






            say(string.format("    bursts %d (loss %d / gain %d, refused %d)  last %s%s  room %s  shift %s  playing %s",
                report.bursts, report.losses, report.gains, report.refused,
                tostring(report.last),
                report.lastAt and string.format(" at %.1f", report.lastAt) or "",
                report.room and string.format("%.1f", report.room) or "unreadable",
                report.shift and string.format("%.1f", report.shift) or "-",
                tostring(report.playing)))
            for _, pair in ipairs({ { "wound", report.window }, { "incoming", report.incoming } }) do
                local x, w, dev = box(pair[2])
                say(string.format("    %-9s %s  %s  anchor %s", pair[1],
                    x and string.format("x %8.2f  w %7.2f  (dev %6.2f)", x, w, w * (dev or 1))
                        or "x        -  w       -  (dev      -)",
                    (pair[2] and self:Read(pair[2].IsShown, 1, pair[2]) == true) and "shown " or "hidden",
                    report.twoPoint and "two-point" or "fixed width"))
            end
        end
    end
end

function A:MeasureCommand(argument)
    local out = { "-- measure --" }
    local function emit(text) self:Print(text); out[#out + 1] = text end
    self:MeasureReport(emit)
    pcall(self.MeasureEffects, self, emit)
    if type(argument) == "string" and argument:lower() == "compass" then
        self:MeasureCompass(emit)
    else
        self:Print("  (`/aui measure compass` adds every arm, ground, tab and the symmetry summary.)")
    end
    local text = table.concat(out, "\n")
    local prior = type(self.inspectText) == "string" and (self.inspectText .. "\n") or ""
    self.inspectText = prior .. text
    if self:StoreInspectReport(self.inspectText) then
        self:Print("measure saved with the inspect dump: /reload (or /logout) and it is on disk.")
    end
end





function A:PlusGaugeInset(compact)
    return self:PlusSnap(self:BarPlateHeight(compact) * self:PlateArt().winL)
end


function A:BarTailInset(compact)
    return self:PlusSnap(self:BarPlateHeight(compact) * self:PlateArt().winR)
end











function A:PlusSkin(plate, width, rowTop, mirror, compact, isParty, px)
    local height = self:Number(plate.GetHeight, 1, plate) or 0


    if self:SmallTile(plate.plusId) then
        self:PlaceBarFrame(plate.barFrame, plate, width, height, mirror, 1, false)
        local tileMirror = self:GetOption("plusMirror") and plate.mirror == true or false
        self:PlateShade(plate, true, width, height, tileMirror, true)
        return 0, -height
    end
    local alpha = plate.hero and self:Surface("panel") or self:Surface("base")
    local artH = self:MantleGeometry(compact).art
    self:PlaceBarFrame(plate.barFrame, plate, width, artH, mirror, alpha, true, 0)
    self:PlateShade(plate, true, width, artH, mirror, false, 0)
    if plate.flashFx then
        self:SizeEdgeFlash(plate.flashFx, math.max(2, px * 2))
        plate.flashFx:ClearAllPoints()
        plate.flashFx:SetPoint("TOPLEFT", plate, "TOPLEFT", -px, px)
        plate.flashFx:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", px, -px)
    end
    return 0, -height
end

function A:CreatePlusUnits()
    if self.plus then return self.plus end
    local sp = self.tokens.space
    local plus = {}
    local w, sw = self:PlusPlateWidth(false), self:PlusPlateWidth(true)
    local top, ctop = self:PlusHeaderTop(), self:PlusCompactTop()
    local hh = self:GetOption("plusHealthHeight")
    local ph = self:GetOption("plusPowerHeight")
    plus.player = newPlate(self, "AdaptiveUIPlusPlayer", self:PlusHeroHeight(true), w)
    plus.player.health = newBar(self, plus.player, -top, hh, w)
    plus.player.health.redline = true
    plus.player.power = newBar(self, plus.player, -(top + hh + sp.xs), ph, w)
    plus.target = newPlate(self, "AdaptiveUIPlusTarget", self:PlusHeroHeight(false), w)
    plus.target.health = newBar(self, plus.target, -top, hh, w)




    plus.target.health.redline = true
    plus.target.marker = newMarker(self, plus.target)



    plus.target.mirror = true


    local shh = self:PlusSmallHealthHeight()
    plus.focus = newPlate(self, "AdaptiveUIPlusFocus", self:PlusCompactHeight(), sw, nil, true)
    plus.focus.health = newBar(self, plus.focus, -ctop, shh, sw, true)
    plus.focus.marker = newMarker(self, plus.focus)
    plus.pet = newPlate(self, "AdaptiveUIPlusPet", self:PlusCompactHeight(), sw, nil, true)
    plus.pet.health = newBar(self, plus.pet, -ctop, shh, sw, true)
    plus.tot = newPlate(self, "AdaptiveUIPlusTot", self:PlusCompactHeight(), sw, nil, true)
    plus.tot.health = newBar(self, plus.tot, -ctop, shh, sw, true)

    plus.focustarget = newPlate(self, "AdaptiveUIPlusFocusTarget", self:PlusCompactHeight(), sw, nil, true)
    plus.focustarget.health = newBar(self, plus.focustarget, -ctop, shh, sw, true)
    plus.focustargettarget = newPlate(self, "AdaptiveUIPlusFocusTargetTarget", self:PlusCompactHeight(), sw, nil, true)
    plus.focustargettarget.health = newBar(self, plus.focustargettarget, -ctop, shh, sw, true)
    plus.focus.mirror, plus.tot.mirror = true, true
    plus.focustarget.mirror, plus.focustargettarget.mirror = true, true
    for _, id in ipairs(A.plusSmallIds) do plus[id].plusId = id end

    plus.party = CreateFrame("Frame", "AdaptiveUIPlusParty", UIParent)
    plus.party:SetSize(sw, PARTY_MAX * PARTY_ROW_H + (PARTY_MAX - 1) * 8)
    plus.party:SetFrameStrata("LOW")
    plus.party:EnableMouse(false)
    plus.party.members = {}
    for i = 1, PARTY_MAX do
        local member = newPlate(self, "AdaptiveUIPlusParty" .. i, PARTY_ROW_H, sw, plus.party, true)
        member.unit = "party" .. i
        member.health = newBar(self, member, -(sp.xs + 20), 8, sw, true)
        member.role = member:CreateTexture(nil, "OVERLAY")
        member.role:SetSize(14, 14)
        member.role:SetPoint("TOPRIGHT", member, "TOPRIGHT", -sp.sm, -(sp.xs + 3))
        member.role:Hide()
        member.level:Hide()


        member.leader = member:CreateTexture(nil, "OVERLAY")
        member.leader:SetSize(14, 14)
        member.leader:SetPoint("RIGHT", member.role, "LEFT", -sp.xs, 0)
        pcall(member.leader.SetTexture, member.leader, "Interface\\GroupFrame\\UI-Group-LeaderIcon")
        member.leader:Hide()
        member:Hide()
        plus.party.members[i] = member
    end



    plus.player.lightTone = "accent"
    plus.target.lightTone = "tint"
    for _, key in ipairs(A.plusSmallIds) do plus[key].lightTone = "tint" end
    for _, plate in ipairs({ plus.player, plus.target, plus.focus, plus.pet, plus.tot, plus.focustarget,
        plus.focustargettarget, plus.party }) do plate:Hide() end
    self.plus = plus

    if self.CreatePlateAuras then self:CreatePlateAuras(plus.target, "target") end
    return plus
end







function A:PlusBase(id, m)
    local swp = self:PlusPlateWidth(true)
    local dx = m.unitDX or 205
    local pw = self:PlusPlateWidth(false)
    if id == "plusPlayer" then return m.unitX - dx, m.unitY end
    if id == "plusTarget" then return m.unitX + dx, m.unitY end
    if id == "plusFocus" then return m.unitX + dx, m.unitY + 120 * m.fit end





    if id == "plusFocustarget" or id == "plusFocustargettarget" then
        local n = id == "plusFocustarget" and 1 or 2
        local s = m.unitScale
        local step = (self:PlusSmallHeight("focus") + self:PlusTotGap() + self:PlusAbove(true)) * s
        return m.unitX + dx, m.unitY + 120 * m.fit + n * step
    end
    if id == "plusTot" then
        if self:GetOption("plusTotPlacement") == "below" then




            local s = m.unitScale
            local rowTop = m.unitY + self:PlusHeroHeight(true) / 2 * s








            local tw, th = self:PlusSmallWidth("tot"), self:PlusSmallHeight("tot")


            local castRow = self.TargetCastUnderRow and self:TargetCastUnderRow() or 0
            local y = rowTop - (self:PlusHeroHeight(false) + self:PlusTotGap()
                + self:PlusAbove(true) + castRow + th / 2) * s
            return m.unitX + dx + (pw - tw) / 2 * s, y
        end
        return m.unitX + dx + (pw + self:PlusSmallWidth("tot")) / 2 * m.unitScale + self.tokens.space.sm, m.unitY
    end
    if id == "plusPet" then
        return m.unitX - dx - (pw + self:PlusSmallWidth("pet")) / 2 * m.unitScale - self.tokens.space.sm, m.unitY
    end
    if id == "plusParty" then
        return -(m.width / 2) + self.tokens.margin + swp * m.unitScale / 2, m.height * 0.6
    end
end








function A:ScreenAnchorPixel()
    local width = 1920
    if type(GetPhysicalScreenSize) == "function" then
        local ok, w = pcall(GetPhysicalScreenSize)
        if ok and type(w) == "number" and w > 0 then width = w end
    end
    return width / 2
end

















function A:PositionPlusUnits(m)
    local plus = self.plus



    local pp = self:PhysicalPixel(UIParent)
    local snap = self:PixelSnapOn() and pp > 0.05
    local origin = self:ScreenAnchorPixel()




    local rowH = self:Number(plus.player.GetHeight, 1, plus.player) or 0
    local totBelow = self:GetOption("plusTotPlacement") == "below"
    for _, def in ipairs(DEFS) do
        local plate = plus[def.id]
        local id = "plus" .. def.id:sub(1, 1):upper() .. def.id:sub(2)
        local bx, by = self:PlusBase(id, m)
        local ox, oy = self:MoverOffset(id)
        local centerLift = 0
        if def.id ~= "party" and not (def.id == "tot" and totBelow) then
            local h = self:Number(plate.GetHeight, 1, plate) or rowH
            centerLift = (rowH - h) / 2
        end
        local s = m.unitScale

        local cx, cy = bx + ox, by + oy + centerLift * s
        if snap then
            local pw = (self:Number(plate.GetWidth, 1, plate) or 0) * s
            local ph = (self:Number(plate.GetHeight, 1, plate) or 0) * s



            local left, bottom = cx - pw / 2, cy - ph / 2


            cx = cx + ((math.floor(origin + left / pp + 0.5) - origin) * pp - left)
            cy = cy + (math.floor(bottom / pp + 0.5) * pp - bottom)
        end
        plate:SetScale(s)
        plate:ClearAllPoints()
        plate:SetPoint("CENTER", UIParent, "BOTTOM", cx / s, cy / s)







        local pw = (self:Number(plate.GetWidth, 1, plate) or 0) * s
        local ph = (self:Number(plate.GetHeight, 1, plate) or 0) * s
        plate.auiSeat = { cx = cx, cy = cy, w = pw, h = ph }
        if def.id == "party" then
            for _, member in ipairs(plate.members or {}) do
                local rel = member.auiRel
                if rel then
                    local mw, mh = rel.w * s, rel.h * s
                    local mcx = cx - pw / 2 + mw / 2
                    local mcy
                    if rel.fromTop then mcy = cy + ph / 2 - (rel.dy + rel.h / 2) * s
                    else mcy = cy - ph / 2 + (rel.dy + rel.h / 2) * s end
                    member.auiSeat = { cx = mcx, cy = mcy, w = mw, h = mh }
                else
                    member.auiSeat = nil
                end
            end
        end
    end
end
























local PERCENT_W = 44


























local NAME_FLOOR_CHARS, NAME_FLOOR_CHARS_SMALL = 8, 6
function A:PlusNameFloor(compact)




    local size = self:PixelSize("body", self:UnitScale())
    return math.ceil(size * (0.55 * (compact and NAME_FLOOR_CHARS_SMALL or NAME_FLOOR_CHARS) + 0.75))
end





function A:PlusHeaderReserve(compact)
    local sp = self.tokens.space
    local pip = compact and 6 or 10
    local levelW = math.max(compact and 18 or 22, math.ceil((compact and 18 or 22) * self:PlusTypeLift()))
    local levelShown = self:GetOption("plusShowLevel")
    local withName = self:GetOption("plusLevelPos") ~= "right"
    local lead = sp.sm + pip + 6 + ((levelShown and withName) and (levelW + 6) or 0)






    local tail = ((levelShown and not withName) and (levelW + 6) or 0) + self:PlusShelfClear(compact)
    return lead, tail, levelW
end

local function slotFor(self, mode, step)
    if mode == "percent" or mode == "none" then return math.ceil(PERCENT_W * step) end
    local short = self:GetOption("plusNumberStyle") == "short"
    if mode == "current" then return math.ceil((PERCENT_W + 8 + (short and 46 or 56)) * step) end
    return math.ceil((PERCENT_W + 8 + (short and 84 or 98)) * step)
end



function A:PlusHealthDetail(compact)
    local mode = self:GetOption("plusHealthFormat")
    if compact or mode == "percent" or mode == "none" then return mode end
    local step = self:PlusTypeLift()



    local width = math.ceil(baseWidth(self, compact) * WIDTH_GROWTH)
    local lead, tail = self:PlusHeaderReserve(compact)
    local room = width - lead - self.tokens.space.sm - tail - 6 - self:PlusNameFloor(compact)
    if slotFor(self, mode, step) <= room then return mode end
    if mode == "both" and slotFor(self, "current", step) <= room then return "current" end
    return "percent"
end

local function numberSlot(self, compact)
    local step = self:PlusTypeLift()
    if compact then return math.ceil(38 * step) end




    return slotFor(self, self:PlusHealthDetail(compact), step)
end
A.PlusNumberSlot = function(self, compact) return numberSlot(self, compact) end



function A:LayoutPlus()
    local plus = self.plus
    local sp = self.tokens.space



    local uscale = self:UnitScale()





    local platePx = self:PlatePixel()
    local w, sw = self:PlusPlateWidth(false), self:PlusPlateWidth(true)


    local ph = self:PlusPowerHeight()
    local player, target = plus.player, plus.target
    player:SetSize(w, self:PlusHeroHeight(true))
    target:SetSize(w, self:PlusHeroHeight(false))
    for _, key in ipairs(A.plusSmallIds) do

        local variant = self:SmallTile(key)
        if variant then plus[key]:SetSize(self:TileSize(variant)) else plus[key]:SetSize(sw, self:PlusCompactHeight()) end
    end
    local namePos, levelPos = self:GetOption("plusNamePos"), self:GetOption("plusLevelPos")
    local hp = self:GetOption("plusHealthPos")
    local inHeader = hp == "right"
    local anchor = hp == "left" and "LEFT" or "CENTER"
    local showLevel = self:GetOption("plusShowLevel")














    local mirrorOn = self:GetOption("plusMirror")
    local function textLayout(plate, width, isParty, compact)
        local rowH = compact and self:PlusCompactRow() or self:PlusNameRow()
        local mirror = mirrorOn and plate.mirror == true and not isParty
        local lead = mirror and "RIGHT" or "LEFT"
        plate.leadSide = lead
        local tail = mirror and "LEFT" or "RIGHT"
        local sign = mirror and -1 or 1

        self:PlusSkin(plate, width, nil, mirror, compact, isParty, platePx)







        local rowTop = rowH + self:PlusGaugeGap()
        local x0, x1 = 0, 0
        local nameFloor = self:PlusNameFloor(compact)
        local levelShown = showLevel and not isParty



        local floatFlags = self:PlusFloatType()
        self:SetPixelFont(plate.name, compact and "body" or "hero", uscale, not compact, floatFlags)
        self:SetPixelFont(plate.level, compact and "caption" or "body", uscale, false, floatFlags)
        local levelW = math.max(compact and 18 or 22,
            math.ceil((compact and 18 or 22) * self:PlusTypeLift()))
        local slot = inHeader and numberSlot(self, compact) or 0
        plate.name:ClearAllPoints(); plate.level:ClearAllPoints()
        plate.name:SetHeight(rowH); plate.level:SetHeight(rowH)
        plate.level:SetWidth(levelW)
        local nameX = x0
        local reserve = (slot > 0 and (slot + 6) or 0)



        plate.level:SetPoint("TOP" .. lead, plate, "TOP" .. lead, sign * x0, rowTop)
        plate.level:SetJustifyH(lead)
        if levelShown then nameX = x0 + levelW + 6 end
        if namePos == "center" then
            plate.name:SetPoint("TOP", plate, "TOP", 0, rowTop)
            plate.name:SetJustifyH("CENTER")
        else
            plate.name:SetPoint("TOP" .. lead, plate, "TOP" .. lead, sign * nameX, rowTop)
            plate.name:SetJustifyH(lead)
        end
        plate.name:SetWidth(math.max(nameFloor, width - nameX - x1 - reserve))
        plate.level:SetShown(levelShown)
        self:FitPlateName(plate, compact)


        local text = plate.health.text
        text:ClearAllPoints()
        if inHeader then
            text:SetWidth(math.max(1, slot))
            text:SetHeight(rowH)
            if levelShown and levelPos == "right" then
                text:SetPoint("TOP" .. tail, plate.level, "TOP" .. lead, sign * 6, 0)
            else
                text:SetPoint("TOP" .. tail, plate, "TOP" .. tail, -sign * x1, rowTop)
            end
            text:SetJustifyH(tail)
        else
            text:SetWidth(width - sp.sm * 2 - 8)
            text:SetHeight(0)
            text:SetPoint(anchor, plate.health.value, anchor, hp == "left" and 4 or 0, 0)
            text:SetJustifyH(anchor)
        end





        local veiled = self:GetOption("unitVeil")
        local leanSide = (not isParty) and "RIGHT" or nil
        local leanW = (self:Number(plate.GetHeight, 1, plate) or 0) + self.veilBleed * 2
        self:Veil(plate, plate.veil, "v", "ink",
            (plate.hero and self:Surface("panel") or self:Surface("base")) * 0.5,
            nil, -sp.xs, "BOTTOM", leanSide, leanW)
        self:ShowVeil(plate.veil, "v", veiled)





        if plate.sweepFx then
            plate.sweepFx:ClearAllPoints()
            plate.sweepFx:SetWidth(A.plusSweepBand)
            plate.sweepFx:SetPoint("TOPRIGHT", plate, "TOPLEFT", 0, 2)
            plate.sweepFx:SetPoint("BOTTOMRIGHT", plate, "BOTTOMLEFT", 0, -2)
        end
    end





    local ticksOn = self:GetOption("gaugeTicks")
    local function cutTo(bar, height)



        local barPlate = bar.plate or (bar.value and type(bar.value.GetParent) == "function" and bar.value:GetParent())
        local tileVariant = type(barPlate) == "table" and self:SmallTile(barPlate.plusId) or nil
        local lane = bar == player.power and "power" or "health"

        local chip = self:PlusChipFor(tileVariant)

        if bar.cut then bar.cut:Hide() end





        local barW = self:Number(bar.value.GetWidth, 1, bar.value) or 0

        if bar.seam then
            bar.seam:SetWidth(math.max(2, math.floor(platePx * 2 + 0.5)))
            bar.seam:SetShown(self:FlatBars() and height >= self:PlusDetailFloor() and not chip)
        end





        if bar.lead then
            bar.lead:SetWidth(math.max(2, math.floor(platePx * 2 + 0.5)))
            bar.lead:SetShown(self:FlatBars() and height >= self:PlusDetailFloor() and self:GetOption("plusGlow")
                and not chip)
        end
        if bar.trail then




            pcall(bar.trail.SetStatusBarTexture, bar.trail,
                self.artPath .. (chip and (A.chipFiles.clear .. ".tga")
                    or (self:FlatBars() and "meter.tga" or "bar-gradient.tga")))
            bar.trail:ClearAllPoints()
            bar.trail:SetPoint("TOPLEFT", bar.value, "TOPLEFT", 0, 0)
            bar.trail:SetSize(barW, height)
            if bar.trailCut then bar.trailCut:Hide() end
        end
        if bar.heal then
            bar.heal:SetSize(math.max(1, barW), height)
            if bar.heal.auiMask then bar.heal.auiMask:SetAllPoints(bar.value) end
            if bar.healCut then bar.healCut:Hide() end
        end





        if bar.redlineArt then

            local art, on = bar.redlineArt, bar.redline == true and self:GetOption("plusDanger") and height >= 8
                and not chip
            if on then
                local x, notch = barW * TICKS[1], math.max(3, math.floor(height / 3))
                art.stem:ClearAllPoints()
                art.stem:SetPoint("TOP", bar.value, "TOPLEFT", x, 0)
                art.stem:SetPoint("BOTTOM", bar.value, "BOTTOMLEFT", x, 0)
                art.top:ClearAllPoints()
                art.top:SetPoint("TOPLEFT", bar.value, "TOPLEFT", x, 0)
                art.top:SetSize(notch, notch)
                art.bottom:ClearAllPoints()
                art.bottom:SetPoint("BOTTOMLEFT", bar.value, "BOTTOMLEFT", x, 0)
                art.bottom:SetSize(notch, notch)
            end
            art.stem:SetShown(on); art.top:SetShown(on); art.bottom:SetShown(on)
        end



        if bar.keyline then
            anchorCut(self, bar.keyline, bar.value, 1)
            bar.keyline.body:SetShown(not self:FlatBars())
        end



        if bar.back then
            anchorCut(self, bar.back, bar.value, 0)
            bar.back.body:Hide()
        end
        local cut = 0
        if bar.ghost then
            cut = anchorCut(self, bar.ghost, bar.value, 0)
            self:Tint(bar.ghost.body, "tint", "color", self:PlusTroughAlpha())
            self:Tint(bar.ghost.wedge, "tint", "vertex", self:PlusTroughAlpha())
            bar.ghost.body:Hide()
        end

        self:InlayLight(bar, lane, not tileVariant, chip)
        self:TileLight(bar, tileVariant, tileVariant ~= nil, chip)
        self:PlusChip(bar, chip, height, lane, tileVariant)
        if bar.ticks then
            local barWidth = self:Number(bar.value.GetWidth, 1, bar.value) or 0
            for i, tick in ipairs(bar.ticks) do
                local x = barWidth * TICKS[i]
                tick:ClearAllPoints()
                tick:SetPoint("TOP", bar.value, "TOPLEFT", x, 0)
                tick:SetPoint("BOTTOM", bar.value, "BOTTOMLEFT", x, 0)


                tick:SetShown(ticksOn and height >= self:PlusDetailFloor() and x < barWidth - cut - 1 and not chip)
            end
        end




        local fill = type(bar.value.GetStatusBarTexture) == "function" and bar.value:GetStatusBarTexture() or nil
        local host = (fill and type(fill.SetPoint) == "function") and fill or bar.value
        local spread = sp.sm
        for _, key in ipairs({ "ember", "flare" }) do
            local fx = bar[key]
            if fx then
                fx:ClearAllPoints()
                fx:SetPoint("TOPRIGHT", host, "TOPRIGHT", spread, spread)
                fx:SetPoint("BOTTOMLEFT", host, "BOTTOMRIGHT", -spread * 3, -spread)
            end
        end






        if bar.danger then
            bar.danger:ClearAllPoints()
            bar.danger:SetPoint("TOPLEFT", bar.value, "TOPLEFT", -spread, spread)
            bar.danger:SetPoint("BOTTOMRIGHT", bar.value, "BOTTOMRIGHT", spread, -spread)
        end




        self:LayoutBarEffect(bar, height)
    end
    for _, plate in ipairs({ player, target, plus.focus, plus.pet, plus.tot, plus.focustarget, plus.focustargettarget }) do
        local width = plate:GetWidth()
        local compact = not plate.hero
        local tileVariant = self:SmallTile(plate.plusId)


        local mirrored = mirrorOn and plate.mirror == true
        local inset = self:PlusGaugeInset(compact)
        local gaugeTop, barH = self:StandGauge(compact, "health")
        local tailIn = self:BarTailInset(compact)
        if tileVariant then

            local plateH = self:Number(plate.GetHeight, 1, plate) or 0
            local left, right
            gaugeTop, barH, left, right = self:TileLane(tileVariant, width, plateH)
            inset, tailIn = left, right
            if mirrored then inset, tailIn = right, left end
        end
        plate.health.value:ClearAllPoints()
        plate.health.value:SetPoint("TOPLEFT", plate, "TOPLEFT",
            mirrored and tailIn or inset, -gaugeTop)
        plate.health.value:SetSize(math.max(8, width - tailIn - inset), barH)
        cutTo(plate.health, barH)
        self:StandFill(plate.health, mirrored)
        if tileVariant and not plate.health.chip then


            local bar = plate.health.value
            if plate.health.standFill ~= "tile" then
                plate.health.standFill = "tile"
                pcall(bar.SetStatusBarTexture, bar, self.artPath .. "meter.tga")
            end
            if plate.health.finish then plate.health.finish.barfinishfill = "meter.tga" end
        elseif plate.health.standFill == "tile" then
            plate.health.standFill = nil
            self:StandFill(plate.health, mirrored)
        end
        textLayout(plate, width, false, compact)













        self:SetPixelNumberFont(plate.health.text,
            (inHeader and not compact) and "value" or "caption", uscale,


            inHeader and self:PlusFloatType() or nil)
    end


    local powerTop, powerH = self:StandGauge(false, "power")
    local powerTail, powerInset = self:BarTailInset(false), self:PlusGaugeInset(false)
    player.power.value:ClearAllPoints()
    player.power.value:SetPoint("TOPLEFT", player, "TOPLEFT", powerInset, -powerTop)
    player.power.value:SetSize(math.max(1, w - powerTail - powerInset), math.max(powerH, 1))
    player.power.value:SetShown(ph > 0)



    if player.power.finish.barfinishB6 then
        player.power.finish.barfinishB6:SetShown(ph > 0 and not self:FlatBars())
    end
    cutTo(player.power, ph)
    self:StandFill(player.power, false, true)






    local party = plus.party



    local rowH = self:MantleGeometry(true).total
    local partyTop, bar = self:StandGauge(true, "health")
    local partyTail = self:BarTailInset(true)
    local spacing = self:PlusSnap(self:GetOption("plusPartySpacing"))






    spacing = self:PlusAbove(true) + math.max(self:PlusSnap(2), self:PlatePixel())
        + math.max(0, spacing - self:PlusSnap(8))
    local direction = self:GetOption("plusPartyDirection")
    party:SetSize(sw, PARTY_MAX * rowH + (PARTY_MAX - 1) * spacing)
    for i, member in ipairs(party.members) do
        member:SetSize(sw, rowH)
        local memberLeft = self:PlusGaugeInset(true)
        member.health.value:SetSize(math.max(8, sw - memberLeft - partyTail), bar)
        member.health.value:ClearAllPoints()
        member.health.value:SetPoint("TOPLEFT", member, "TOPLEFT", memberLeft, -partyTop)
        cutTo(member.health, bar)
        self:StandFill(member.health, false)
        textLayout(member, sw, true, true)
        self:SetPixelNumberFont(member.health.text, "caption", uscale,
            inHeader and self:PlusFloatType() or nil)


        if inHeader then
            member.health.text:ClearAllPoints()
            member.health.text:SetPoint("BOTTOMRIGHT", member, "TOPRIGHT",
                -(partyTail + 36), self:PlusGaugeGap())
            member.health.text:SetHeight(self:PlusCompactRow())
        end
        member.name:SetWidth(math.max(24, sw - sp.sm * 2 - 36 - (inHeader and 46 or 0)))
        member:ClearAllPoints()
        if direction == "up" then
            member:SetPoint("BOTTOMLEFT", party, "BOTTOMLEFT", 0, (i - 1) * (rowH + spacing))
        else
            member:SetPoint("TOPLEFT", party, "TOPLEFT", 0, -(i - 1) * (rowH + spacing))
        end


        member.auiRel = { dy = (i - 1) * (rowH + spacing), w = sw, h = rowH, fromTop = direction ~= "up" }
    end
end





local function gradient(self, fraction)
    local hi, mid, lo = { self:Color("good") }, { self:Color("warn") }, { self:Color("bad") }
    local from, to, t
    if fraction >= 0.5 then from, to, t = mid, hi, (fraction - 0.5) * 2
    else from, to, t = lo, mid, fraction * 2 end
    t = math.max(0, math.min(1, t))
    return from[1] + (to[1] - from[1]) * t, from[2] + (to[2] - from[2]) * t, from[3] + (to[3] - from[3]) * t
end

local function autoColor(self, unit, isPlayerUnit)
    local r, g, b
    if isPlayerUnit then r, g, b = classColor(self, unit) end
    if r then return r, g, b end
    return reactionColor(self, unit)
end

local function healthColor(self, unit, optionKey)
    local mode = self:GetOption(optionKey)
    if mode == "custom" then
        local c = self:GetOption("plusColor")
        return c[1], c[2], c[3]
    end
    local isPlayer = unit == "player" or (unit:find("^party") ~= nil) or self:Read(UnitIsPlayer, 1, unit) == true
    if mode == "health" then
        local current = self:Number(UnitHealth, 1, unit)
        local maximum = self:Number(UnitHealthMax, 1, unit)
        if current and maximum and maximum > 0 then return gradient(self, current / maximum) end
        return autoColor(self, unit, isPlayer)
    end
    if mode == "reaction" then return reactionColor(self, unit) end
    if mode == "class" then

        if isPlayer then
            local r, g, b = classColor(self, unit)
            if r then return r, g, b end
        end
        return reactionColor(self, unit)
    end
    return autoColor(self, unit, isPlayer)
end





local function setColor(bar, r, g, b)
    if not r then return end
    bar.value:SetStatusBarColor(r, g, b)
    if bar.chip then


        bar.lossRGB = { r, g, b }
        A:PaintChip(bar, r, g, b)
    end
    A:PaintHealGhost(bar, r, g, b)
    A:PaintBarGlow(bar.value, r, g, b)
    if bar.ghost then paintCut(bar.ghost, r, g, b, A.plusTroughTint) end



    local lr, lg, lb = lift(r, g, b, 0.45)
    for _, key in ipairs({ "ember", "flare" }) do
        local fx = bar[key]
        if fx and fx.light then fx.light:SetVertexColor(lr, lg, lb, 1) end
    end


    if bar.lead then
        local cr, cg, cb = lift(r, g, b, 0.55)
        bar.lead:SetColorTexture(cr, cg, cb, 0.95)
    end






    A:BarEffectTint(bar, r, g, b)
end




































































function A:PlusTrail(widget, unit)
    local trail = widget and widget.trail
    if not trail then return false end
    if not self:GetOption("plusLossTrail") or not self:MotionOn() then



        trail:SetMinMaxValues(0, 1)
        trail:SetValue(0)
        trail:SetAlpha(0)
        trail.auiTrailUnit = nil
        self:BarEffectIdle(widget, "wound", false)
        return false
    end
    trail:SetAlpha(1)
    self:BarEffectIdle(widget, "wound", true)


    local function set(interpolation)

        if trail.auiChipTest then return true end
        return pcall(function()
            trail:SetMinMaxValues(0, UnitHealthMax(unit))
            if interpolation then
                trail:SetValue(UnitHealth(unit), interpolation)
            else
                trail:SetValue(UnitHealth(unit))
            end
        end)
    end







    if trail.auiTrailUnit ~= unit then
        trail.auiTrailUnit = unit
        return set(nil)
    end




















    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then

        return set(self.barInterpolation)
    end
    if trail.auiTrailPending then return true end
    trail.auiTrailPending = true
    return pcall(C_Timer.After, self.tokens.motion.trailDelay, function()
        trail.auiTrailPending = nil
        set(self.barInterpolation)
    end)
end

function A:PlusHealGhost(widget, unit)
    local heal = widget and widget.heal
    if not heal then return false end
    if not self:GetOption("plusHealGhost") then
        heal:SetValue(0); heal:Hide()
        self:BarEffectIdle(widget, "incoming", false)
        return false
    end
    self:BarEffectIdle(widget, "incoming", true)

    if self.healCalculator and type(heal.SetHealPredictionCalculator) == "function" then
        if not heal.auiCalc then
            local ok, calc = pcall(CreateUnitHealPredictionCalculator, unit)
            if ok and calc then
                heal.auiCalc = calc
                pcall(heal.SetHealPredictionCalculator, heal, calc)
            else
                heal.auiCalc = false
            end
        end
        if heal.auiCalc then
            if type(heal.auiCalc.Update) == "function" then pcall(heal.auiCalc.Update, heal.auiCalc) end
            heal:Show()
            return true
        end
    end
    if self.incomingHeals then
        local ok = pcall(function()
            heal:SetMinMaxValues(0, UnitHealthMax(unit))
            heal:SetValue(UnitGetIncomingHeals(unit) or 0)
        end)
        heal:SetShown(ok)
        return ok
    end
    heal:SetValue(0)
    heal:Hide()
    return false
end
























function A:BarEffectHost(widget)
    if widget.effectHost then return widget.effectHost end
    local value = widget and widget.value
    if not (value and type(CreateFrame) == "function") then return nil end
    local plate = select(2, pcall(value.GetParent, value))
    if not plate then return nil end
    local ok, made = pcall(CreateFrame, "Frame", nil, plate)
    if not (ok and made) then return nil end
    local host = self:Own(made)
    pcall(host.EnableMouse, host, false)
    local level = self:Number(value.GetFrameLevel, 1, value)
    if level then pcall(host.SetFrameLevel, host, math.max(0, level - 1)) end
    host:ClearAllPoints()
    host:SetPoint("TOPLEFT", value, "TOPLEFT", 0, 0)
    host:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 0, 0)
    widget.effectHost = host
    return host
end

function A:BarEffectFor(widget)
    if not widget or not widget.value then return nil end
    local style, key = self:BarEffect()
    local current = widget.effect
    if current and current.key == key then return current end
    if current then
        local was = self.barEffects[current.key]
        if was and type(was.teardown) == "function" then pcall(was.teardown, self, widget) end
        widget.effect = nil
    end
    if not (style and type(style.build) == "function") then return nil end
    widget.effects = widget.effects or {}
    local kept = widget.effects[key]
    if kept then
        widget.effect = kept
        if kept.host then kept.host:Show() end
        return kept
    end
    if not self:BarEffectHost(widget) then return nil end



    local fine, made = pcall(style.build, self, widget)
    if not (fine and made) then
        widget.effect = nil
        return nil
    end




    made.key = key




    local level = self:Number(made.host and made.host.GetFrameLevel, 1, made.host)
    if level then
        for _, key2 in ipairs({ "fx", "window", "inWindow" }) do
            local frame = made[key2]
            if frame and type(frame.SetFrameLevel) == "function" then
                pcall(frame.SetFrameLevel, frame, level)
            end
        end
    end
    widget.effects[key] = made
    widget.effect = made
    return made
end

function A:LayoutBarEffect(widget, height)



    if widget and widget.chip then
        if widget.effectHost and widget.effectHost:IsShown() then widget.effectHost:Hide() end
        return nil
    end
    local effect = self:BarEffectFor(widget)
    if not effect then
        if widget and widget.effectHost then widget.effectHost:Hide() end
        return nil
    end
    effect.height = height
    effect.small = (height or 0) < self:PlusDetailFloor()
    if effect.host then effect.host:Show() end
    local style = self.barEffects[effect.key]
    if style and type(style.layout) == "function" then pcall(style.layout, self, widget, height) end
    return effect
end






function A:BarEffectIdle(widget, which, on)
    local effect = widget and widget.effect
    if not effect then return false end
    local style = self.barEffects[effect.key]
    if not (style and type(style.idle) == "function") then return false end
    return select(2, pcall(style.idle, self, widget, which, on)) == true
end




























A.barEffectEdge = 1.5


A.barEffectPublicEdge = 0.005

























function A:PlusBarPublicDirection(plate, unit)
    local now = self:Number(UnitHealth, 1, unit)
    local max = self:Number(UnitHealthMax, 1, unit)
    if not (now and max) or max <= 0 then

        plate.auiBarLast, plate.auiBarLastUnit = nil, nil
        return nil
    end
    local was, wasUnit = plate.auiBarLast, plate.auiBarLastUnit
    plate.auiBarLast, plate.auiBarLastUnit = now, unit
    if was == nil or wasUnit ~= unit then return nil end
    local edge = max * self.barEffectPublicEdge
    if now < was - edge then return "down" end
    if now > was + edge then return "up" end
    return nil
end

function A:PlusBarEvent(plate, unit)
    local widget = plate and plate.health
    local effect = widget and widget.effect
    if not effect then
        if plate then plate.auiBarDir, plate.auiBarUnit = nil, nil end
        return false
    end
    local style = self.barEffects[effect.key]
    if not style then return false end



    local moved = self.barPulsePending and self.barPulsePending[unit]
    if moved then
        self.barPulsePending[unit] = nil
        if type(style.moved) == "function" then pcall(style.moved, self, widget) end
    end
    if self:Read(plate.IsShown, 1, plate) ~= true then plate.auiBarDir = nil; return false end
    local trail = widget.trail
    local live = trail and (self:Number(trail.GetAlpha, 1, trail) or 0) > 0.5
        and self:GetOption("plusLossTrail") == true


    if not live then plate.auiBarDir, plate.auiBarLast, plate.auiBarLastUnit = nil, nil, nil; return false end
    local fill = type(widget.value.GetStatusBarTexture) == "function" and widget.value:GetStatusBarTexture() or nil
    local trailFill = type(trail.GetStatusBarTexture) == "function" and trail:GetStatusBarTexture() or nil
    local fillW = fill and self:Number(fill.GetWidth, 1, fill) or nil
    local trailW = trailFill and self:Number(trailFill.GetWidth, 1, trailFill) or nil
    local direction = nil
    if fillW and trailW then
        local edge = math.max(self.barEffectEdge, (effect.height or 6) * 0.2)
        if trailW > fillW + edge then direction = "down"
        elseif fillW > trailW + edge and self:GetOption("plusHealGhost") == true then direction = "up" end
    end



    local public = self:PlusBarPublicDirection(plate, unit)
    if direction == nil and public ~= nil
        and (public == "down" or self:GetOption("plusHealGhost") == true) then
        direction = public
        effect.fromPublic = (effect.fromPublic or 0) + 1
    end







    local was = plate.auiBarDir
    plate.auiBarDir = direction
    if plate.auiBarUnit ~= unit then
        plate.auiBarUnit = unit
        return false
    end
    if direction == nil or direction == was then return false end
    local hook = direction == "up" and style.gain or style.loss
    if type(hook) ~= "function" then return false end
    return select(2, pcall(hook, self, widget)) == true
end

































A.effectTestHold = 1.5




function A:EffectTestMarker(widget, why)
    local host = widget and (widget.effectHost or widget.value)
    if not (host and type(host.CreateTexture) == "function") then return false end
    local mark = widget.auiTestMark
    if not mark then
        local ok, made = pcall(host.CreateTexture, host, nil, "OVERLAY", nil, 7)
        if not (ok and made) then return false end
        mark = self:Own(made)
        widget.auiTestMark = mark
    end
    mark:ClearAllPoints()
    pcall(mark.SetTexture, mark, self.artPath .. "meter.tga", "CLAMP", "CLAMP")
    pcall(mark.SetAllPoints, mark, widget.value)
    pcall(mark.SetVertexColor, mark, 1, 0.35, 0.1, 0.85)
    mark:Show()
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        pcall(C_Timer.After, self.effectTestHold, function() pcall(mark.Hide, mark) end)
    end
    self:Print("effecttest: DIAGNOSTIC MARKER drawn instead (" .. tostring(why)
        .. "). If you cannot see an orange bar across your health gauge for 1.5s,")
    self:Print("  nothing this addon draws on that gauge reaches the screen at all.")
    return true
end










A.chipTestHold = 2.5
function A:ChipTestCommand(holdArg)
    local out = { "-- chiptest --" }
    local function say(text) self:Print(text); out[#out + 1] = text end
    local function save()
        local text = table.concat(out, "\n")
        local prior = type(self.inspectText) == "string" and (self.inspectText .. "\n") or ""
        self.inspectText = prior .. text
        if self.StoreInspectReport and self:StoreInspectReport(self.inspectText) then
            self:Print("chiptest saved with the inspect dump: /reload and send AdaptiveUIInspectDB.")
        end
    end
    if self:IsCombat() then
        self:Print("chiptest: out of combat only (it writes test values into our own health bar).")
        return false
    end
    if self.chipTestRunning then
        self:Print("chiptest: already running.")
        return false
    end
    local plate = self.plusActive and self.plus and self.plus.player or nil
    local widget = plate and plate.health
    if not (widget and widget.chip and widget.value) then
        self:Print("chiptest: the player plate is not chipped. It needs AUI Oakborn, Plates on (/aui units plus) "
            .. "and the plate's fill style on the look's own.")
        return false
    end
    local hold = tonumber(holdArg) or self.chipTestHold
    if hold ~= hold or hold < 0.4 then hold = 0.4 elseif hold > 10 then hold = 10 end
    local value, trail = widget.value, widget.trail
    local motion = self:MotionLevel()
    local after = type(C_Timer) == "table" and type(C_Timer.After) == "function" and C_Timer.After or nil
    if not after then
        self:Print("chiptest: this client has no C_Timer.After; nothing to time the steps with.")
        return false
    end
    local interp = self.barInterpolation
    local function set(bar, v, eased)
        if not bar then return end
        pcall(bar.SetMinMaxValues, bar, 0, 100)
        if eased and interp then pcall(bar.SetValue, bar, v, interp) else pcall(bar.SetValue, bar, v) end
    end
    local function read(label, region)
        if not region then say("  " .. label .. ": none"); return end
        local ok, x, y, w, h = pcall(region.GetRect, region)
        if ok and self:IsPublic(x) and self:IsPublic(w) and type(x) == "number" and type(w) == "number" then
            say(string.format("  %s: x %.1f y %.1f  %.1f x %.1f  shown %s", label, x, y or 0, w, h or 0,
                tostring(region.IsShown and region:IsShown())))
        else
            say("  " .. label .. ": rect not public (" .. tostring(ok and "secret" or x) .. ")")
        end
    end
    local function masks(region)
        if not (region and type(region.GetNumMaskTextures) == "function") then return "?" end
        local ok, n = pcall(region.GetNumMaskTextures, region)
        return ok and tostring(n) or "error"
    end




    local token = {}
    self.chipTestRunning = token
    local function finish(why)
        if self.chipTestRunning ~= token then return end
        self.chipTestRunning = nil
        if trail then trail.auiTrailUnit, trail.auiChipTest = nil, nil end
        pcall(self.UpdatePlusUnits, self)
        say(why)
        save()
    end
    self.chipTestAbort = function() finish("chiptest aborted: combat started; your real health is back.") end
    local raw = after
    after = function(delay, fn)
        raw(delay, function()
            if self.chipTestRunning ~= token then return end
            if self:IsCombat() then return finish("chiptest aborted: combat started; your real health is back.") end
            fn()
        end)
    end

    set(value, 100); set(trail, 100)
    if trail then trail.auiTrailUnit = "chiptest"; trail.auiChipTest = true; trail:SetAlpha(1) end
    widget.chipKey = nil
    pcall(self.PlusChipAnchor, self, widget)
    say(string.format("chiptest: motion %s | easing %s | debris %s (masks %s) | hold %.1fs",
        motion, interp and "client" or "none", widget.chipDebris and (widget.chipDebris:IsShown() and "on" or "off") or "none",
        masks(widget.chipDebris), hold))
    if motion == "off" then say("  Movement is None: the break is immediate and nothing crumbles (as designed).") end
    if motion == "subtle" then say("  Movement is Reduced: the break GLIDES; no debris is drawn (as designed).") end
    say("  1/4 now: the plate at 100 %, the wood whole.")
    after(0.8, function()
        set(value, 62, widget.chipGlide)
        say("  2/4 HIT to 62 %: the break is " .. (widget.chipGlide and "gliding" or "instant")
            .. (motion == "full" and ("; the debris hangs over the fresh colour for " .. hold .. "s. SCREENSHOT NOW.") or "."))
        read("debris", widget.chipDebris)
        read("reveal mask", widget.chipRevealMask)
        local tf = trail and trail.GetStatusBarTexture and trail:GetStatusBarTexture() or nil
        read("trail edge", tf)
        after(hold, function()
            set(trail, 62, true)
            say("  3/4 CRUMBLE: the trail eases to the break; the debris slides under it. SCREENSHOT ~0.2s in.")
            after(0.25, function() read("debris (crumbling)", widget.chipDebris) end)
            after(2.0, function()
                set(value, 90, widget.chipGlide); set(trail, 90, true)
                say("  4/4 HEAL to 90 %: the colour closes, no debris on a heal.")
                after(2.0, function() finish("chiptest done: your real health is back.") end)
            end)
        end)
    end)
    return true
end

function A:EffectTestCommand(styleArg, whichArg)
    if self:IsCombat() then
        self:Print("effecttest: out of combat only. It writes two constants into our own trail bar,"
            .. " and in a fight a real value is in flight through the same sink.")
        return false
    end
    local plus = self.plusActive and self.plus or nil
    local plate = plus and plus.player
    local widget = plate and plate.health
    if not widget then
        self:Print("effecttest: no Plus player plate on screen. /aui units plus, then try again.")
        return false
    end
    local key = (type(styleArg) == "string" and styleArg ~= "") and styleArg or self:BarEffectKey()
    if not self.barEffects[key] then
        self:Print("effecttest: `" .. tostring(key) .. "` draws nothing. Try sand, ash or pulse"
            .. (self:MotionOn() and "." or " -- and Motion is Off, which switches every effect off."))
        return false
    end





    if key ~= self:BarEffectKey() then self:SetOption("barEffect", key) end
    local effect = widget.effect
    local style = self.barEffects[key]
    if not effect then
        self:Print("effecttest: " .. key .. " could not build on this client -- the gauge is drawing 0.44.2."
            .. " /aui measure prints which rung it stopped at.")
        return false
    end
    local which = (whichArg == "loss" or whichArg == "gain") and whichArg or "both"
    local out = { "-- effecttest --" }
    local function say(text) self:Print(text); out[#out + 1] = text end




    local trail, value = widget.trail, widget.value
    local restored = false
    if value then
        pcall(value.SetMinMaxValues, value, 0, 100)
        pcall(value.SetValue, value, 62)
    end
    if trail then
        pcall(trail.SetMinMaxValues, trail, 0, 100)
        pcall(trail.SetValue, trail, 100)
        trail:SetAlpha(1)
        self:BarEffectIdle(widget, "wound", true)
    end
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        restored = pcall(C_Timer.After, self.effectTestHold, function()
            if trail then trail.auiTrailUnit = nil end
            pcall(self.UpdatePlusUnits, self)
        end)
    end


    pcall(self.LayoutBarEffect, self, widget, effect.height)
    local before = effect.bursts or 0
    local fired, errors = {}, {}
    local function drive(name, hook, delay)
        if type(hook) ~= "function" then return end
        if delay then
            pcall(C_Timer.After, delay, function() pcall(hook, self, widget) end)
            fired[#fired + 1] = name .. "(+" .. tostring(delay) .. "s)"
            return
        end
        local ok, result = pcall(hook, self, widget)
        if not ok then errors[#errors + 1] = name .. ": " .. tostring(result) end
        fired[#fired + 1] = name .. (ok and (result and "" or "(returned false)") or "(ERROR)")
    end
    if which ~= "gain" then drive("loss", style.loss) end
    if which ~= "loss" then
        drive("gain", style.gain,
            (which == "both" and type(C_Timer) == "table" and type(C_Timer.After) == "function") and 0.7 or nil)
    end
    say(string.format("effecttest %s %s -- %s", key, which, table.concat(fired, " + ")))
    say(string.format("  option barEffect=%s  resolved=%s  style=%s  motion=%s  kill=%s",
        tostring(self:GetOption("barEffect")), self:BarEffectKey(),
        style and "built" or "none", self:MotionLevel(), tostring(self.barEffectsOff)))
    local room, laneW, fillW = self:BarEffectRoom(widget)
    say(string.format("  lane w=%s  fill w=%s  wound room=%s  seat shift=%s  height=%s%s",
        laneW and string.format("%.1f", laneW) or "-",
        fillW and string.format("%.1f", fillW) or "-",
        room and string.format("%.1f", room) or "unreadable",
        effect.seatShift and string.format("%.1f", effect.seatShift) or "-",
        effect.height and string.format("%.1f", effect.height) or "-",
        effect.small and "  [below the detail floor: NO PARTICLES]" or ""))
    local group = effect.fx and self.motionGroups[effect.fx] and self.motionGroups[effect.fx].burst
    say(string.format("  fx frame %s alpha=%s shown=%s | group %s playing=%s targeted=%s | tint %s (colorMode %s)",
        effect.fx and "yes" or "NO",
        effect.fx and string.format("%.2f", self:Number(effect.fx.GetAlpha, 1, effect.fx) or -1) or "-",
        effect.fx and tostring(self:Read(effect.fx.IsShown, 1, effect.fx)) or "-",
        group and "yes" or "NO",
        group and tostring(select(2, pcall(group.IsPlaying, group))) or "-",
        group and tostring(group.auiTargeted) or "-",
        effect.tintR and string.format("%.2f/%.2f/%.2f", effect.tintR, effect.tintG, effect.tintB) or "unset",
        tostring(self:GetOption("plusColorPlayer"))))


    local shown, quads = 0, effect.quads or {}
    for _, quad in ipairs(quads) do
        if self:Read(quad.IsShown, 1, quad) == true then shown = shown + 1 end
    end
    for i = 1, math.min(3, #quads) do
        local quad = quads[i]
        local x, w
        local ok, rx, _, rw = pcall(quad.GetRect, quad)
        if ok then x, w = rx, rw end
        say(string.format("    quad%d shown=%s alpha=%.2f size=%sx%s rect x=%s w=%s tex=%s masks=%s",
            i, tostring(self:Read(quad.IsShown, 1, quad)),
            self:Number(quad.GetAlpha, 1, quad) or -1,
            string.format("%.1f", self:Number(quad.GetWidth, 1, quad) or -1),
            string.format("%.1f", self:Number(quad.GetHeight, 1, quad) or -1),
            x and string.format("%.1f", x) or "-", w and string.format("%.1f", w) or "-",
            tostring(quad.texturePath or (quad.GetTexture and select(2, pcall(quad.GetTexture, quad))) or "?"),
            tostring(quad.masks and #quad.masks or "?")))
    end
    say(string.format("  quads %d, shown %d, bursts this session %d (+%d now), refused %d, last %s",
        #quads, shown, effect.bursts or 0, (effect.bursts or 0) - before,
        effect.refused or 0, tostring(effect.lastBurst)))
    for _, text in ipairs(errors) do say("  ERROR " .. text) end
    say("  both bars held for " .. tostring(self.effectTestHold) .. "s"
        .. (restored and " and then re-read from the client." or " -- NO C_Timer: run /aui units plus to restore."))


    local drew = (effect.bursts or 0) > before and shown > 0
    if not drew then
        self:EffectTestMarker(widget,
            effect.small and "the gauge is below the detail floor"
            or (not group and "no animation group on this client")
            or (shown == 0 and "no quad is shown")
            or "the style's burst returned false")
    end
    local text = table.concat(out, "\n")
    local prior = type(self.inspectText) == "string" and (self.inspectText .. "\n") or ""
    self.inspectText = prior .. text
    if self:StoreInspectReport(self.inspectText) then
        self:Print("effecttest saved with the inspect dump: /reload (or /logout) and it is on disk.")
    end
    return true
end






















A.plusDangerAt = 0.25
function A:PlusDangerPulse(plate, unit)
    local widget = plate and plate.health
    local fx = widget and widget.danger
    if not fx then return false end
    local low = false
    if widget.redline and self:GetOption("plusDanger") and self:Read(plate.IsShown, 1, plate) == true then
        local current = self:Number(UnitHealth, 1, unit)
        local maximum = self:Number(UnitHealthMax, 1, unit)
        if current and maximum and maximum > 0 then low = current <= maximum * self.plusDangerAt end
    end
    if not low then
        plate.auiLow = false
        self:StopLoop(fx, "pulse")
        return false
    end
    local m = self.tokens.motion
    local r, g, b = self:Color("danger")






    if not plate.auiLow then
        plate.auiLow = true
        if plate.flashFx and self:GetOption("plusFlash") then
            self:PlayEdgeFlash(plate.flashFx, r, g, b, 1.1)
        end
    end
    return self:PlayLoop(fx, "pulse", m.pulseLow, m.pulseHigh, r, g, b)
end



function A:PlusHealFlare(id)
    if self.healCalculator or self.incomingHeals then return false end
    local plate = self.plus and self.plus[id]
    local fx = plate and plate.health and plate.health.flare
    if not fx or not self.plusActive then return false end
    if self:Read(plate.IsShown, 1, plate) ~= true then return false end
    local r, g, b = self:Color("gain")
    return self:PlayFlare(fx, r, g, b, 0.8)
end























local STATE_WORDS = { dead = "DEAD", ghost = "GHOST", offline = "OFFLINE" }
function A:PlusStateCue(plate, unit)
    local widget = plate and plate.health
    if not widget then return nil end
    local state
    if self:Read(UnitIsConnected, 1, unit) == false then state = "offline"
    elseif self:Read(UnitIsGhost, 1, unit) == true then state = "ghost"
    elseif self:Read(UnitIsDeadOrGhost, 1, unit) == true then state = "dead" end
    plate.auiState = state
    for _, w in ipairs({ widget, plate.power or false }) do
        if w and w.chip and (w.chipDown == true) ~= (state ~= nil) then
            w.chipDown = state ~= nil
            self:PlusChipAnchor(w)
            if not state then self:PlusChipColour(w, unit, w == widget and "health" or "power") end
        end
    end
    if not state then


        if plate.auiStateAlpha then plate:SetAlpha(1); plate.auiStateAlpha = nil end
        return nil
    end

    widget.text:SetText(STATE_WORDS[state])
    widget.value:SetMinMaxValues(0, 1)
    widget.value:SetValue(0)
    if widget.trail then widget.trail:SetValue(0) end
    if widget.heal then widget.heal:SetValue(0); widget.heal:Hide() end





    setColor(widget, self:Color("offline"))
    if plate.lightTone then self:PaintPlateLight(plate, self:Color("offline")) end
    if state == "offline" then
        plate:SetAlpha(0.55)
        plate.auiStateAlpha = true
    elseif plate.auiStateAlpha then
        plate:SetAlpha(1)
        plate.auiStateAlpha = nil
    end
    return state
end




function A:PlusLightColor(plate)
    local c = plate and plate.lightRGB
    if c then return lift(c[1], c[2], c[3], 0.35) end
    if plate and plate.lightTone then
        local r, g, b = self:Color(plate.lightTone)
        return lift(r, g, b, 0.35)
    end
    return self:Color("accent")
end




function A:PlusSweep(id)
    local plate = self.plus and self.plus[id]
    if not plate or not plate.sweepFx or not self.plusActive then return false end
    if not self:Read(plate.IsShown, 1, plate) then return false end




    if plate.flashFx and self:GetOption("plusFlash") then
        local r, g, b = self:PlusLightColor(plate)
        self:PlayEdgeFlash(plate.flashFx, r, g, b, 0.85)
    end
    local width = (self:Number(plate.GetWidth, 1, plate) or 0) + self.plusSweepBand
    return self:PlaySweep(plate.sweepFx, width, self:PlusLightColor(plate))
end




function A:PlusEmbers()
    local plus = self.plus
    if not plus then return end
    local m = self.tokens.motion
    for _, id in ipairs({ "player", "target" }) do
        local plate = plus[id]
        local bar = plate and plate.health
        local fx = bar and bar.ember
        if fx then





            local want = self.plusActive and self:MotionOn() and not self:FlatBars()
                and self:Read(plate.IsShown, 1, plate) == true
            if want then
                self:PlayLoop(fx, "ember", m.emberLow * 0.5, m.emberHigh * 0.5)
            else
                self:StopLoop(fx, "ember")
            end
        end
    end
end


function A:PlusCombatFlare()
    local plus = self.plus
    if not plus or not self.plusActive then return end
    for _, id in ipairs({ "player", "target" }) do
        local plate = plus[id]
        local fx = plate and plate.health and plate.health.flare
        if fx and self:Read(plate.IsShown, 1, plate) == true then




            self:PlayFlare(fx)
        end
    end
end




local function shorten(value)
    local a = math.abs(value)
    if a >= 1e9 then return string.format("%.1fB", value / 1e9) end
    if a >= 1e6 then return string.format("%.1fM", value / 1e6) end
    if a >= 1e3 then return string.format("%.1fk", value / 1e3) end
    return string.format("%.0f", value)
end

local function number(self, value, forceShort)
    if forceShort or self:GetOption("plusNumberStyle") == "short" then return shorten(value) end
    return string.format("%.0f", value)
end
















function A:FormatPlusHealth(unit, compact)
    local mode = self:PlusHealthDetail(compact)
    local current = self:Number(UnitHealth, 1, unit)
    local maximum = self:Number(UnitHealthMax, 1, unit)
    if not current or not maximum or maximum <= 0 then return "" end
    local percent = string.format("%.0f%%", current / maximum * 100)
    if compact or mode == "percent" or mode == "none" then return percent end
    if mode == "current" then return percent .. "  " .. number(self, current) end
    return percent .. "  " .. number(self, current) .. " / " .. number(self, maximum)
end




























local sinkState = {}

local function abbreviator(self)
    if self:GetOption("plusNumberStyle") ~= "short" then
        return function(v) return v end
    end
    if type(AbbreviateNumbers) == "function" then
        if type(CreateAbbreviateConfig) == "function" and sinkState.config == nil then
            local ok, cfg = pcall(CreateAbbreviateConfig, {
                { breakpoint = 1e9, abbreviation = "B", significandDivisor = 1e8, fractionDivisor = 10, abbreviationIsGlobal = false },
                { breakpoint = 1e6, abbreviation = "M", significandDivisor = 1e5, fractionDivisor = 10, abbreviationIsGlobal = false },
                { breakpoint = 1e3, abbreviation = "k", significandDivisor = 1e2, fractionDivisor = 10, abbreviationIsGlobal = false },
            })
            sinkState.config = ok and cfg or false
        end
        local cfg = sinkState.config or nil
        return function(v) return AbbreviateNumbers(v, cfg) end
    end
    if type(AbbreviateLargeNumbers) == "function" then return AbbreviateLargeNumbers end
    return function(v) return v end
end


local function sinkNumber(self, fs, kind, unit, powerType, mode, compact)
    if type(fs.SetFormattedText) ~= "function" then return false end
    local currentAPI, maxAPI, percentAPI = UnitHealth, UnitHealthMax, UnitHealthPercent
    if kind == "power" then currentAPI, maxAPI, percentAPI = UnitPower, UnitPowerMax, UnitPowerPercent end
    if type(currentAPI) ~= "function" then return false end





    local ok = pcall(function()
        local a = abbreviator(self)
        local pct
        if type(percentAPI) == "function" then
            local scale = CurveConstants and CurveConstants.ScaleTo100
            if kind == "power" then pct = percentAPI(unit, powerType, true, scale) else pct = percentAPI(unit, true, scale) end
        end



        local p = sinkState.percentFormat or "%d"
        if pct == nil then


            if mode == "current" or mode == "percent" or mode == "none" then
                fs:SetFormattedText("%s", a(currentAPI(unit, powerType)))
            else
                fs:SetFormattedText("%s / %s", a(currentAPI(unit, powerType)), a(maxAPI(unit, powerType)))
            end
            return
        end
        local function write(format, ...)
            if pcall(fs.SetFormattedText, fs, format, ...) then return end
            sinkState.percentFormat = "%s"
            fs:SetFormattedText((format:gsub("%%d", "%%s")), ...)
        end
        if compact or mode == "percent" or mode == "none" then
            write(p .. "%%", pct)
        elseif mode == "current" then
            write(p .. "%%  %s", pct, a(currentAPI(unit, powerType)))
        else
            write(p .. "%%  %s / %s", pct, a(currentAPI(unit, powerType)), a(maxAPI(unit, powerType)))
        end
    end)
    if ok then
        if not sinkState.noted then
            sinkState.noted = true
            self:Note("plate numbers", "restricted values go straight to a text sink (SetFormattedText); no arithmetic")
        end
        return true
    end
    if not sinkState.failNoted then
        sinkState.failNoted = true
        self:Note("plate numbers", "restricted and no text sink accepted them: numbers hidden, bars unaffected")
    end
    return false
end




function A:SetPlusNumber(fs, kind, unit, powerType, compact)
    local mode = self:PlusHealthDetail(compact)
    if kind == "health" then


        local text = self:FormatPlusHealth(unit, compact)
        if text ~= "" then fs:SetText(text); return end
        if compact then mode = "percent" end
    else
        local value = self:Number(UnitPower, 1, unit, powerType)
        local max = self:Number(UnitPowerMax, 1, unit, powerType)
        if value and max and max > 0 then fs:SetText(number(self, value, compact)); return end
        mode = "current"
    end
    if not sinkNumber(self, fs, kind, unit, powerType, mode, compact) then fs:SetText("") end
end

function A:FormatPlusName(text)
    local limit = self:GetOption("plusNameMax")
    if limit >= 40 or type(text) ~= "string" then return text end

    local count, index = 0, 1
    while index <= #text do
        count = count + 1
        if count > limit then
            return text:sub(1, index - 1) .. string.char(226, 128, 166)
        end
        local byte = text:byte(index)
        index = index + (byte >= 240 and 4 or byte >= 224 and 3 or byte >= 192 and 2 or 1)
    end
    return text
end

local ROLE_ATLAS = { TANK = "roleicon-tiny-tank", HEALER = "roleicon-tiny-healer", DAMAGER = "roleicon-tiny-dps" }





A.factionColour = { Horde = { 0.90, 0.30, 0.24 }, Alliance = { 0.36, 0.58, 1.00 } }
A.petMood = { [1] = { "Unhappy", 0.90, 0.30, 0.24 }, [2] = { "Content", 0.95, 0.80, 0.30 }, [3] = { "Happy", 0.45, 0.85, 0.40 } }

function A:PlateBadge(plate, text, r, g, b)
    if not plate or not plate.level then return end
    local badge = plate.flagBadge
    if not text then
        if badge then badge:Hide() end
        return
    end
    if not badge then
        badge = plate:CreateFontString(nil, "OVERLAY")
        plate.flagBadge = badge
    end
    self:SetPixelFont(badge, "caption", self:UnitScale(), false)
    local lead = plate.leadSide or "LEFT"
    badge:ClearAllPoints()
    badge:SetPoint(lead == "LEFT" and "RIGHT" or "LEFT", plate.level, lead, lead == "LEFT" and -4 or 4, 0)
    badge:SetText(text)
    badge:SetTextColor(r or 1, g or 1, b or 1)
    badge:Show()
end


function A:PvpBadge(unit)
    if not self:GetOption("plusShowPvp") then return nil end
    local ffa, fs = self:Read(UnitIsPVPFreeForAll, 1, unit)
    if fs == "public" and ffa == true then return "FFA", 0.95, 0.80, 0.30 end
    local pvp, ps = self:Read(UnitIsPVP, 1, unit)
    if ps ~= "public" or pvp ~= true then return nil end
    local faction = self:Text(UnitFactionGroup, 1, unit)
    local c = A.factionColour[faction or ""] or { 0.95, 0.80, 0.30 }
    return "PvP", c[1], c[2], c[3]
end


function A:PetMoodBadge()
    if not self:GetOption("plusShowPetMood") or type(GetPetHappiness) ~= "function" then return nil end
    local mood, status = self:Read(GetPetHappiness, 1)
    if status ~= "public" or type(mood) ~= "number" then return nil end
    local m = A.petMood[mood]
    if not m then return nil end
    return m[1], m[2], m[3], m[4]
end


local function updateUnitPlate(self, plate, unit, def, optionKey)
    self:FitPlateName(plate, not plate.hero,
        self:FormatPlusName(self:Text(UnitName, 1, unit) or (def and def.id == "pet" and "Pet") or "Unit"))
    local level = self:Number(UnitLevel, 1, unit)
    local tag = ""
    if def and (def.id == "target" or def.id == "focus") and self:GetOption("plusShowTag") then
        tag = ({ elite = "+", rareelite = "+", worldboss = "B", rare = "R" })[self:Text(UnitClassification, 1, unit) or ""] or ""
    end
    plate.level:SetText(level and ((level < 0 and "??" or tostring(level)) .. tag) or "")
    if def and def.id == "pet" then
        self:PlateBadge(plate, self:PetMoodBadge())
    else
        self:PlateBadge(plate, self:PvpBadge(unit))
    end
    local hr, hg, hb = healthColor(self, unit, optionKey)
    setColor(plate.health, hr, hg, hb)


    if hr and plate.lightTone then self:PaintPlateLight(plate, hr, hg, hb) end
    self:UpdateBar(plate.health, "HEALTH", UnitHealth, UnitHealthMax, unit)
    if plate.health.chip then self:PlusChipColour(plate.health, unit, "health") end
    self:PlusTrail(plate.health, unit)
    self:PlusHealGhost(plate.health, unit)
    self:SetPlusNumber(plate.health.text, "health", unit, nil, not plate.hero)
    self:PlusStateCue(plate, unit)
    self:PlusDangerPulse(plate, unit)
    self:PlusBarEvent(plate, unit)
    if plate.marker then
        local index = self:Number(GetRaidTargetIndex, 1, unit)
        if self:GetOption("plusShowMarker") and index and index >= 1 and index <= 8
            and type(SetRaidTargetIconTexture) == "function" then
            SetRaidTargetIconTexture(plate.marker, index)
            plate.marker:Show()
        else
            plate.marker:Hide()
        end
    end
    plate:Show()
    if def and def.id == "target" and self.PlaceTargetAuras then self:PlaceTargetAuras() end
end

function A:UpdatePlusUnits()
    local plus = self.plus
    if not plus or not self.plusActive then return end
    local ok = pcall(function()


        local identity = self:GetIdentity()
        self.identity = identity
        local player = plus.player
        if self:GetOption("plusPlayerOn") then
            self:FitPlateName(player, false, self:FormatPlusName(identity.name))
            local level = self:Number(UnitLevel, 1, "player")
            player.level:SetText(level and tostring(level) or "")
            self:PlateBadge(player, self:PvpBadge("player"))
            setColor(player.health, healthColor(self, "player", "plusColorPlayer"))
            self:UpdateBar(player.health, "HEALTH", UnitHealth, UnitHealthMax, "player")
            if player.health.chip then self:PlusChipColour(player.health, "player", "health") end
            self:PlusTrail(player.health, "player")
            self:PlusHealGhost(player.health, "player")
            self:SetPlusNumber(player.health.text, "health", "player", nil, false)
            self:PlusStateCue(player, "player")
            self:PlusDangerPulse(player, "player")
            self:PlusBarEvent(player, "player")




            local token = identity.powerToken
            local power = token and PowerBarColor and PowerBarColor[token]

            if type(power) == "table" and type(power.r) == "number" then
                setColor(player.power, self:PlusPowerQuiet(lift(power.r, power.g, power.b, 0.38)))
            else
                setColor(player.power, self:PlusPowerQuiet(
                    self:Color(token == "ENERGY" and "warn" or (token == "RAGE" and "bad" or "info"))))
            end
            if type(identity.powerType) == "number" then
                self:UpdateBar(player.power, "POWER", UnitPower, UnitPowerMax, "player", identity.powerType)
                if player.power.chip then self:PlusChipColour(player.power, "player", "power") end
                if self:GetOption("plusPowerText") then


                    self:SetPlusNumber(player.power.text, "power", "player", identity.powerType)
                else
                    player.power.text:SetText("")
                end
            else
                self:EmptyBar(player.power, "POWER", "")
            end
            player:Show()
        else
            player:Hide()
        end

        for _, def in ipairs(DEFS) do
            if def.unit and def.id ~= "player" then
                local plate = plus[def.id]
                if self:GetOption(def.opt) and self:Read(UnitExists, 1, def.unit) == true then
                    updateUnitPlate(self, plate, def.unit, def, def.color)
                else
                    if plate.marker then plate.marker:Hide() end
                    plate:Hide()
                end
            end
        end



        local party = plus.party
        local inRaid = self:Read(IsInRaid, 1) == true
        local shown = 0
        for i, member in ipairs(party.members) do
            local unit = "party" .. i
            if self:GetOption("plusPartyOn") and not inRaid and i <= self:GetOption("plusPartyMax")
                and self:Read(UnitExists, 1, unit) == true then
                updateUnitPlate(self, member, unit, nil, "plusColorParty")
                member.level:Hide()
                local role = self:GetOption("plusPartyRole") and self:Text(UnitGroupRolesAssigned, 1, unit) or nil
                local atlas = role and ROLE_ATLAS[role]
                if atlas then
                    pcall(member.role.SetAtlas, member.role, atlas)
                    member.role:Show()
                else
                    member.role:Hide()
                end


                local alpha = 1
                if self:GetOption("plusPartyStatus") then
                    local connected = self:Read(UnitIsConnected, 1, unit)
                    local dead = self:Read(UnitIsDeadOrGhost, 1, unit)
                    if connected == false then
                        alpha = 0.4
                        member.health.text:SetText("Offline")
                    elseif dead == true then
                        alpha = 0.55
                        member.health.text:SetText("Dead")
                    end
                end
                member:SetAlpha(alpha)
                local leader = self:GetOption("plusPartyLeader") and self:Read(UnitIsGroupLeader, 1, unit) == true
                member.leader:SetShown(leader)
                shown = shown + 1
            else
                member.role:Hide()
                member.leader:Hide()
                member:Hide()
            end
        end
        party:SetShown(shown > 0)
    end)
    if not ok then

        self.plusFailed = true
        self.layoutDirty = true
        self:Note("unit frames plus", "rejected; Lite until reload")
    end




    if self.sweepPending then
        local queue = self.sweepPending
        self.sweepPending = nil
        for id in pairs(queue) do pcall(self.PlusSweep, self, id) end
    end
    pcall(self.PlusEmbers, self)
    self:UpdateCastBars()
end




function A:ApplyPlusUnits(state, m)
    local want = self.db.unitMode == "plus" and not self.plusFailed and self.auditedSink
        and self.layoutStates and self.layoutStates.units and self.layoutStates.units.active
        and PlayerFrame ~= nil and TargetFrame ~= nil
    if not want then
        if self.plusActive or (state.properties and next(state.properties)) then
            self:RestoreNativeModule(state)
        end
        self.plusActive = false
        if self.plus then
            for _, def in ipairs(DEFS) do self.plus[def.id]:Hide() end
        end

        pcall(self.ApplyUnitClicks, self)
        if self.moverHandles then self:RefreshMoverHandles() end
        self:Note("unit frames", self.db.unitMode == "plus" and "Plus unavailable: Lite" or "Lite")
        return false
    end
    self:CreatePlusUnits()


    self:LayoutPlus()
    self:PositionPlusUnits(m)


    for _, def in ipairs(DEFS) do
        local on = self:GetOption(def.opt)
        for _, name in ipairs(def.native) do
            local frame = _G[name]
            if frame then
                if on then self:HoldHidden(state, frame) else self:ReleaseHidden(state, frame) end
            end
        end
    end
    self.plusActive = true
    self:Note("unit frames", "Plus (display-only plates; native frames alpha-held)")






    pcall(self.ApplyUnitClicks, self)
    self:UpdatePlusUnits()
    if self.moverHandles then self:RefreshMoverHandles() end
    return true
end





























function A:CreateDamageStrip()
    if self.damageStrip then return self.damageStrip end
    local strip = CreateFrame("Frame", "AdaptiveUIDamage", UIParent)
    strip:SetSize(self:PlusPlateWidth(false), self:GetOption("dpsStripHeight"))
    strip:SetFrameStrata("LOW")


    strip:SetFrameLevel(PLATE_LEVEL - 1)
    strip:EnableMouse(false)
    strip.depth = {}
    self:Elevate(strip.depth, strip, "d", strip, 0, 0, strip, 0, 0, "panel")








    strip.barFrame = self:BarFrame(strip, "BACKGROUND", -7)
    strip.panel = flatPanel(self, strip, "BACKGROUND", -7)
    strip.bg = strip.panel.body
    tintPanel(self, strip.panel, "inkDeep", 1)

    strip.veil = {}
    self:Veil(strip, strip.veil, "v", "inkDeep", 1)



    strip.panelRim = flatPanel(self, strip, "BACKGROUND", -8)
    strip.panelRim.body:Hide()
    strip.bar = CreateFrame("StatusBar", nil, strip)
    strip.bar:EnableMouse(false)
    strip.bar:SetStatusBarTexture(self.artPath .. "meter.tga")
    strip.bar:SetMinMaxValues(0, 1)
    strip.bar:SetValue(0)
    self:Tint(strip.bar, "tint", "bar")
    strip.barFinish = {}



    self:BarFinish(strip.barFinish, strip.bar, nil, true, "tint")
    strip.bar:Hide()
    if strip.barFinish.barfinishB6 then strip.barFinish.barfinishB6:Hide() end





    strip.surface = {}
    self:BlockSurface(strip, strip.surface, "s", 0.12)
    strip.value = strip:CreateFontString(nil, "OVERLAY")
    self:SetPixelNumberFont(strip.value, "title", self:UnitScale())
    strip.value:SetJustifyH("LEFT")
    self:Tint(strip.value, "text", "text")
    strip.unit = strip:CreateFontString(nil, "OVERLAY")
    self:SetPixelFont(strip.unit, "caption", self:UnitScale(), false)
    strip.unit:SetJustifyH("LEFT")
    self:Tint(strip.unit, "muted", "text")
    strip.detail = strip:CreateFontString(nil, "OVERLAY")



    self:SetPixelFont(strip.detail, "caption", self:UnitScale(), false)
    strip.detail:SetJustifyH("RIGHT")
    self:Tint(strip.detail, "muted", "text")
    strip:Hide()
    self.damageStrip = strip
    return strip
end



function A:ApplyDamageStrip()
    if not self:GetOption("dpsStripOn") then
        if self.damageStrip then self.damageStrip:Hide() end
        return
    end
    local strip = self:CreateDamageStrip()
    local sp = self.tokens.space
    local plate = self.plusActive and self.plus and self:GetOption("plusPlayerOn") and self.plus.player or nil
    local host = plate or _G.PlayerFrame
    if not host then strip:Hide(); return end
    local width = plate and self:PlusPlateWidth(false) or (self:Number(host.GetWidth, 1, host) or self:PlusPlateWidth(false))






    local scale = plate and (self:Number(plate.GetScale, 1, plate) or 1) or 1
    local height = self:PlusSnap(self:GetOption("dpsStripHeight"),
        math.max(0.34, math.min(4, self:PhysicalPixel(UIParent) / scale)))




    local barSkin = plate ~= nil
    strip:SetSize(math.max(80, width), height)
    strip:SetScale(scale)


    local sscale = self:Number(strip.GetScale, 1, strip) or 1
    local footFlags = barSkin and self:PlusFloatType() or nil
    self:SetPixelNumberFont(strip.value, "title", sscale, footFlags)
    self:SetPixelFont(strip.unit, "caption", sscale, false, footFlags)
    self:SetPixelFont(strip.detail, "caption", sscale, false, footFlags)

    local spx = math.max(0.34, math.min(4, self:PhysicalPixel(UIParent) / sscale))
    self:LayoutBlockSurface(strip, strip.surface, "s",
        math.max(4, math.floor(height * 0.45)), self.tokens.space.xs, spx,
        self:GetOption("plusKeyline"))
    strip:ClearAllPoints()

    local inboard = plate and A.plusInboard.player or "RIGHT"
    local outboard = inboard == "RIGHT" and "LEFT" or "RIGHT"
    strip:SetPoint("TOP" .. outboard, host, "BOTTOM" .. outboard, 0, plate and -self:PlusFloatGap() or 0)
    strip.bar:ClearAllPoints()
    strip.bar:SetPoint("TOPLEFT", strip, "TOPLEFT", 1, -1)
    strip.bar:SetPoint("BOTTOMRIGHT", strip, "BOTTOMRIGHT", -1, 1)
    strip.value:ClearAllPoints()

    strip.value:SetPoint("LEFT", strip, "LEFT", barSkin and 0 or sp.sm, 0)
    strip.unit:ClearAllPoints()
    strip.unit:SetPoint("LEFT", strip.value, "RIGHT", sp.xs, -1)
    strip.detail:ClearAllPoints()
    strip.detail:SetPoint("RIGHT", strip, "RIGHT",
        -(barSkin and 0 or sp.sm), 0)
    strip.detail:SetWidth(math.max(60, width * 0.5))



    local veiled = self:GetOption("unitVeil")


    local footCorner = inboard == "RIGHT" and "BOTTOMLEFT" or "BOTTOMRIGHT"
    if barSkin then
        self:PlaceBarFrame(strip.barFrame, strip, math.max(80, width), 0, false, 1, false)
        for _, panel in ipairs({ strip.panel, strip.panelRim }) do
            panel.body:Hide(); panel.wedge:Hide(); panel.tail:Hide()
        end
        self:LayoutBlockSurface(strip, strip.surface, "s",
            math.max(4, math.floor(height * 0.45)), self.tokens.space.xs, spx, false)
        self:ShowVeil(strip.veil, "v", false)
        self:SuppressDepth(strip.depth, "d", true)
        return
    end
    if strip.barFrame then self:PlaceBarFrame(strip.barFrame, strip, width, 0, false, 1, false) end
    placePanel(self, strip.panel, strip, 0, 0, 0, -height, footCorner, 0)
    tintPanel(self, strip.panel, "inkDeep", self:Surface("panel"))
    A.PlusPlaceRim(self, strip.panelRim, strip, spx, 0, 0, 0, -height, footCorner, 0,
        self:GetOption("plusKeyline") and self:GetOption("plusRim"))
    tintPanel(self, strip.panelRim, "edge", nil)
    self:Veil(strip, strip.veil, "v", "inkDeep", self:Surface("panel") * 0.5)
    self:ShowVeil(strip.veil, "v", veiled)
    strip.bg:SetShown(true)
    self:SuppressDepth(strip.depth, "d", false)
end

local function publicNumber(self, value)
    if self:IsPublic(value) and type(value) == "number" and value == value then return value end
end




function A:DamageSession()
    local api = _G.C_DamageMeter
    if type(api) ~= "table" or type(api.GetCombatSessionFromType) ~= "function" then return end
    if type(api.IsDamageMeterAvailable) == "function" then
        local ok, available = pcall(api.IsDamageMeterAvailable)
        if not ok or (self:IsPublic(available) and available == false) then return end
    end
    local S = (Enum and Enum.DamageMeterSessionType) or {}
    local T = (Enum and Enum.DamageMeterType) or {}
    local overall = self:GetOption("dpsStripSession") == "overall"
    local sessionType = overall and (S.Overall or 0) or (S.Current or 1)
    local ok, session = pcall(api.GetCombatSessionFromType, sessionType, T.DamageDone or 0)
    if not ok or not self:IsPublic(session) or type(session) ~= "table" then return end
    local duration
    if type(api.GetSessionDurationSeconds) == "function" then
        local fine, value = pcall(api.GetSessionDurationSeconds, sessionType)
        if fine then duration = publicNumber(self, value) end
    end
    local sources = session.combatSources
    if not self:IsPublic(sources) or type(sources) ~= "table" then return nil, session, duration end
    for _, source in ipairs(sources) do

        if type(source) == "table" and self:IsPublic(source.isLocalPlayer) and source.isLocalPlayer == true then
            return source, session, duration
        end
    end
    return nil, session, duration
end

local function shortDuration(seconds)
    if seconds >= 3600 then return string.format("%dh%02dm", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)) end
    if seconds >= 60 then return string.format("%dm%02ds", math.floor(seconds / 60), math.floor(seconds % 60)) end
    return string.format("%ds", math.floor(seconds + 0.5))
end

function A:UpdateDamageStrip()
    local strip = self.damageStrip
    if not strip then return end
    if not self:GetOption("dpsStripOn") then strip:Hide(); return end
    local now = type(GetTime) == "function" and select(2, pcall(GetTime)) or 0
    local source, session, duration = self:DamageSession()
    local metric = self:GetOption("dpsStripMetric")
    local readable = false
    if source then
        local dps = publicNumber(self, source.amountPerSecond)
        local total = publicNumber(self, source.totalAmount)
        if total and total > 0 then
            readable = true
            self.damageSeen = now




            local lead, suffix
            if metric == "total" then
                lead, suffix = shorten(total), "done"
            else
                lead, suffix = dps and shorten(dps) or shorten(total), dps and "dps" or "done"
            end
            strip.value:SetText(lead)
            strip.unit:SetText(suffix)


            local detail = ""
            if metric == "both" and dps then
                detail = shorten(total)
                detail = (duration and duration >= 1) and (detail .. " in " .. shortDuration(duration))
                    or (detail .. " total")
            elseif duration and duration >= 1 then
                detail = "over " .. shortDuration(duration)
            end
            strip.detail:SetText(detail)
            local share = session and publicNumber(self, session.totalAmount)
            if self:GetOption("dpsStripBar") and share and share > 0 then
                strip.bar:SetMinMaxValues(0, share)
                strip.bar:SetValue(total)
                strip.bar:Show()
            else
                strip.bar:Hide()
            end




            local glow = strip.barFinish and strip.barFinish.barfinishB6
            if glow then glow:SetShown(strip.bar:IsShown()) end
        end
    end




    local seen = self.damageSeen
    local hold = self:GetOption("dpsStripHold")
    local want = seen ~= nil and (self:IsCombat() or (now - seen) <= hold)
    if not want then strip:Hide(); return end


    strip:SetAlpha(readable and 1 or 0.7)
    strip:Show()
end

function A:TickDamage(elapsed)
    if not self.initialized or not self.damageStrip then return end
    self.damageElapsed = (self.damageElapsed or 0) + elapsed
    if self.damageElapsed < 0.25 then return end
    self.damageElapsed = 0
    pcall(self.UpdateDamageStrip, self)
end

function A:SetUnitMode(mode)
    if mode ~= "lite" and mode ~= "plus" then return end
    self.db.unitMode = mode
    self.plusFailed = nil
    self.layoutDirty = true
    self:Changed()
end
