local _, A = ...














































































A.nameplateLook = {
    lift = 0.5 / 13,




    otherAlpha = 0.8,
    floorPx = 14,
    namePx = 16,
    grey = { 0.55, 0.55, 0.55 },
    gapPx = 2,
    marginPx = 3,
    chipPadPx = 5,
    levelGlowA = 0.35,
    castShare = 0.62,
    castWellA = 0.72,
    targetGlowA = 0.32,
}



A.nameplateDifficulty = {
    trivial = { 0.50, 0.50, 0.50 }, easy = { 0.25, 0.75, 0.25 }, fair = { 1.00, 0.82, 0.00 },
    difficult = { 1.00, 0.50, 0.25 }, impossible = { 1.00, 0.10, 0.10 }, neutral = { 0.92, 0.88, 0.80 },
}

local NP = {
    overlays = {},
    byToken = {},
    held = setmetatable({}, { __mode = "k" }),
    ranks = {},
    forbidden = 0,
    key = nil,
}
A.np = NP

local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
    return nil
end




function A:NameplatesWanted()
    if not (self.db and self.optionIndex and self.optionIndex.nameplateSkin) then return false end
    if self:GetOption("nameplateSkin") ~= true then return false end
    if self.Look and self:Look() == "blizzard" then return false end
    if self.sessionDisabled then return false end
    return true
end



function A:NameplateStyleSkinnable()
    local setup, consts = _G.NamePlateSetupOptions, _G.NamePlateConstants
    if type(setup) ~= "table" or type(consts) ~= "table" or type(consts.NAME_ANCHOR_STYLES) ~= "table" then
        return true
    end
    local style = setup.unitNameAnchorStyle
    local inside = consts.NAME_ANCHOR_STYLES.InsideHealthBar
    if not (self:IsPublic(style) and self:IsPublic(inside)) then return false end
    return style == nil or style ~= inside
end


function A:NameplateCastOurs()
    return self:GetOption("nameplateCast") ~= "blizzard"
end






local function heldRegions(uf)
    if type(uf) ~= "table" then return {} end
    local container = uf.HealthBarsContainer
    local bar = type(container) == "table" and container.healthBar or nil
    return { bar, uf.name, uf.selectionHighlight }
end



local function levelRegions(uf)
    if type(uf) ~= "table" then return {} end
    return { uf.PlayerLevelDiffFrame, uf.LevelFrame }
end

local function alphaOf(region)
    local a = call(region.GetAlpha, region)
    if A:IsPublic(a) and type(a) == "number" then return a end
    return nil
end

local function setHeld(self, region, on)
    if type(region) ~= "table" or type(region.SetAlpha) ~= "function" then return end
    if on then
        if not self:CanWrite("hold", region) then return end
        NP.held[region] = true
        if alphaOf(region) ~= 0 then
            self:Trace("hold", region, "nameplate")
            pcall(region.SetAlpha, region, 0)
        end
    elseif NP.held[region] then
        NP.held[region] = nil
        if alphaOf(region) ~= 1 then pcall(region.SetAlpha, region, 1) end
    end
end


function A:NameplateHold(uf, on, level, cast)
    for _, region in ipairs(heldRegions(uf)) do setHeld(self, region, on) end
    if level == nil then level = on end
    if cast == nil then cast = on end
    for _, region in ipairs(levelRegions(uf)) do setHeld(self, region, on and level) end
    if type(uf) == "table" then setHeld(self, uf.CastBarsContainer, on and cast) end
end


function A:NameplateReleaseAll()
    local list = {}
    for region in pairs(NP.held) do list[#list + 1] = region end
    for _, region in ipairs(list) do setHeld(self, region, false) end
    for _, o in pairs(NP.overlays) do
        self:NameplateCastStop(o)
        o.uf = nil
        if o:IsShown() then o:Hide() end
    end
end




local function hiddenText(self, parent)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(fs, 10)
    fs:Hide()
    return fs
end

local function newText(self, parent, face, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(fs, 12, face, "OUTLINE")
    fs:SetJustifyH(justify)
    fs:SetWordWrap(false)
    return fs
end



local function shade(fs, px)
    pcall(fs.SetShadowColor, fs, 0, 0, 0, 0.9)
    pcall(fs.SetShadowOffset, fs, px, -px)
end

function A:NameplateOverlay(base)
    local o = NP.overlays[base]
    if o then return o end
    o = self:Own(CreateFrame("Frame", nil, base))
    o:EnableMouse(false)
    local level = self:Number(base.GetFrameLevel, 1, base) or 1


    pcall(o.SetFrameLevel, o, level + 5)
    o:Hide()

    o.targetGlow = self:Own(o:CreateTexture(nil, "BACKGROUND", nil, -8))
    o.targetGlow:SetTexture(self.artPath .. "map-halo.tga", "CLAMP", "CLAMP")
    o.targetGlow:SetBlendMode("ADD")
    o.targetGlow:Hide()
    local plate = self:Own(CreateFrame("Frame", nil, o))
    plate:EnableMouse(false)
    pcall(plate.SetFrameLevel, plate, level + 6)
    o.plate = plate
    plate.barFrame = self:BarFrame(plate, "BACKGROUND", -7)
    local bar = self:Own(CreateFrame("StatusBar", nil, plate))
    pcall(bar.SetFrameLevel, bar, level + 8)
    bar:EnableMouse(false)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    o.health = { plate = plate, value = bar, label = hiddenText(self, plate), text = hiddenText(self, plate) }

    o.executeBand = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 5))
    self:Tint(o.executeBand, "text", "color", 1)
    o.executeBand:SetBlendMode("ADD")
    o.executeEdge = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 5))
    self:Tint(o.executeEdge, "danger", "color", 0.95)


    local stud = self:Own(CreateFrame("Frame", nil, plate))
    stud:EnableMouse(false)
    pcall(stud.SetFrameLevel, stud, level + 12)
    stud:SetAllPoints(plate)
    o.studFrame = stud
    o.rankGlow = self:Own(stud:CreateTexture(nil, "ARTWORK", nil, 1))
    o.rankGlow:SetTexture(self.artPath .. "diamond-glow.tga", "CLAMP", "CLAMP")
    o.rankGlow:SetBlendMode("ADD")
    o.rankGlow:Hide()
    o.rankStud = self:Own(stud:CreateTexture(nil, "ARTWORK", nil, 2))
    o.rankStud:SetTexture(self.artPath .. "oak-stud-mark.tga", "CLAMP", "CLAMP")
    o.rankStud:Hide()

    o.name = newText(self, plate, "heading", "LEFT")
    self:Tint(o.name, "text", "text")
    o.pct = newText(self, plate, "numeric", "RIGHT")
    self:Tint(o.pct, "text", "text")

    o.pctRuler = hiddenText(self, plate)
    o.levelRuler = hiddenText(self, plate)

    local chip = self:Own(CreateFrame("Frame", nil, plate))
    chip:EnableMouse(false)
    pcall(chip.SetFrameLevel, chip, level + 11)
    chip:Hide()
    o.levelFrame = chip
    local c = A.triggerChip
    o.levelChip = self:Own(chip:CreateTexture(nil, "ARTWORK", nil, 1))
    o.levelChip:SetTexture(self.artPath .. "oak-chip.tga", "CLAMP", "CLAMP")
    o.levelChip:SetVertexColor(c.tone[1], c.tone[2], c.tone[3], c.alpha)
    o.levelChip:SetAllPoints(chip)



    o.levelGlow = {}
    for i = 1, 4 do
        local fs = chip:CreateFontString(nil, "ARTWORK")
        self:SetThemedFont(fs, 12, "numeric", "")
        fs:SetJustifyH("CENTER")
        fs:SetWordWrap(false)
        o.levelGlow[i] = fs
    end
    o.levelText = chip:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(o.levelText, 12, "numeric", "")
    o.levelText:SetJustifyH("CENTER")
    o.levelText:SetWordWrap(false)
    o.levelText:SetPoint("CENTER", chip, "CENTER", 0, 0)

    local cast = self:Own(CreateFrame("Frame", nil, plate))
    cast:EnableMouse(false)
    pcall(cast.SetFrameLevel, cast, level + 8)
    cast:Hide()
    cast.owner = o
    local lane = self:Own(CreateFrame("StatusBar", nil, cast))
    lane:EnableMouse(false)
    pcall(lane.SetFrameLevel, lane, level + 9)
    lane:SetStatusBarTexture(self.artPath .. "meter.tga")
    lane:SetMinMaxValues(0, 1)
    lane:SetValue(0)
    cast.value = lane
    cast.well = self:Own(lane:CreateTexture(nil, "BACKGROUND"))
    cast.well:SetAllPoints(lane)
    self:Tint(cast.well, "well", "color", A.nameplateLook.castWellA)
    cast.icon = self:Own(cast:CreateTexture(nil, "ARTWORK"))
    pcall(cast.icon.SetTexCoord, cast.icon, 0.08, 0.92, 0.08, 0.92)
    cast.icon:Hide()
    cast.label = newText(self, cast, "heading", "LEFT")
    self:Tint(cast.label, "text", "text")
    cast.timer = newText(self, cast, "numeric", "RIGHT")
    self:Tint(cast.timer, "text", "text")
    o.cast = cast
    o.base = base
    NP.overlays[base] = o
    return o
end




local function liveSize(region)
    local w = A:Number(region.GetWidth, 1, region)
    local h = A:Number(region.GetHeight, 1, region)
    if w and h and w > 1 and h > 1 then return w, h end
    return nil
end

local function shown(region)
    if type(region) ~= "table" then return false end
    local v = A:Read(region.IsShown, 1, region)
    return v == true
end


function A:NameplatePixelsPerUnit(o)
    local eff = o and self:Number(o.GetEffectiveScale, 1, o) or nil
    local _, h = call(GetPhysicalScreenSize)
    if not (eff and eff > 0) then eff = 1 end
    if not (type(h) == "number" and h > 0) then h = 768 end
    return eff * h / 768
end

function A:NameplateWidthShare()
    local v = tonumber(self:GetOption("nameplateWidth")) or 1.1
    return math.max(0.6, math.min(1.3, v))
end



local function levelSpan(uf)
    local f = type(uf) == "table" and uf.PlayerLevelDiffFrame or nil
    if not shown(f) then return 0 end
    local w = A:Number(f.GetWidth, 1, f)
    if not (w and w > 0) then return 0 end
    local x = A:Number(f.GetPoint, 4, f)
    return w + math.abs(x or 5)
end

local function measure(self, fs, size, face, text)
    self:SetThemedFont(fs, size, face, "OUTLINE")
    fs:SetText(text)
    return self:Number(fs.GetStringWidth, 1, fs) or size * 0.6 * #text
end

function A:NameplateLayout(o, container, bar)
    local barW, barH = liveSize(bar)
    if not barW then return false end
    local art = self:PlateArt()
    local look = A.nameplateLook
    local ppu = self:NameplatePixelsPerUnit(o)
    local px = 1 / ppu
    local baseW = o.base and A:Number(o.base.GetWidth, 1, o.base) or nil
    local span = levelSpan(o.uf)
    local chip = self:NameplateChip()
    local key = string.format("%.3f|%.3f|%.3f|%.3f|%.4f|%s|%s|%s|%.2f", barW, barH, baseW or 0, span, ppu,
        tostring(self:PlateFile()), tostring(self.lookArtFor), tostring(chip), self:NameplateWidthShare())
    if o.layoutKey == key then return true end
    o.layoutKey = key

    local floor = look.floorPx * px
    local nameSize = math.max(look.namePx * px, floor)
    local pctSize, levelSize = floor, floor
    local gap = look.gapPx * px
    local pctW = measure(self, o.pctRuler, pctSize, "numeric", "100%")
    local chipH = levelSize + look.chipPadPx * px
    local chipW = math.max(chipH * 1.15, measure(self, o.levelRuler, levelSize, "numeric", "88")
        + 2 * look.chipPadPx * px)
    local chipSpace = gap + chipW

    local W = barW * self:NameplateWidthShare()
    if baseW and baseW > 1 then
        W = math.min(W, baseW - chipSpace - 2 * look.marginPx * px)
    end
    W = math.max(W, barW * 0.6)
    local H = W / art.ratio
    local plate = o.plate

    local x = (barW + span - (W + chipSpace)) / 2
    plate:ClearAllPoints()
    plate:SetPoint("TOPLEFT", container, "TOPLEFT", x, barH * look.lift)
    plate:SetSize(W, H)
    self:PlaceBarFrame(plate.barFrame, plate, W, H, false, 1, true, 0)
    self:PlateShade(plate, true, W, H, false, false, 0)
    local lane = art.lanes.health
    local inset, tail = H * art.winL, H * art.winR
    local gaugeTop, laneH = H * lane[1], H * (lane[2] - lane[1])
    local gaugeW = math.max(4, W - inset - tail)
    local w = o.health
    w.value:ClearAllPoints()
    w.value:SetPoint("TOPLEFT", plate, "TOPLEFT", inset, -gaugeTop)
    w.value:SetSize(gaugeW, laneH)
    self:PlusChip(w, chip, laneH, "health")
    self:StandFill(w, false)
    self:InlayLight(w, "health", true, chip)

    local ex = math.max(1, gaugeW * A.plusExecuteAt)
    local edge = math.max(0.5, laneH / 10)
    o.executeBand:ClearAllPoints()
    o.executeBand:SetPoint("TOPLEFT", w.value, "TOPLEFT", 0, 0)
    o.executeBand:SetSize(ex, laneH)
    o.executeBand:SetAlpha(A.plusExecuteLight)
    o.executeEdge:ClearAllPoints()
    o.executeEdge:SetPoint("TOPLEFT", w.value, "TOPLEFT", ex - edge, 0)
    o.executeEdge:SetSize(edge, laneH)
    o.chip = chip

    local s = A.plateStud
    o.studX, o.studY, o.studSize = -H * s.fromTail, -H * s.y, H * s.size
    o.rankKey = nil


    local laneMid = gaugeTop + laneH / 2
    o.levelFrame:ClearAllPoints()
    o.levelFrame:SetPoint("LEFT", plate, "TOPRIGHT", gap, -laneMid)
    o.levelFrame:SetSize(chipW, chipH)
    self:SetThemedFont(o.levelText, levelSize, "numeric", "")
    pcall(o.levelText.SetShadowOffset, o.levelText, 0, 0)
    local offsets = { { px, 0 }, { -px, 0 }, { 0, px }, { 0, -px } }
    for i, fs in ipairs(o.levelGlow) do
        self:SetThemedFont(fs, levelSize, "numeric", "")
        pcall(fs.SetShadowOffset, fs, 0, 0)
        fs:ClearAllPoints()
        fs:SetPoint("CENTER", o.levelFrame, "CENTER", offsets[i][1], offsets[i][2])
    end
    o.chipH, o.chipW, o.levelSize, o.chipPad = chipH, chipW, levelSize, look.chipPadPx * px
    o.levelKey = nil


    self:SetThemedFont(o.name, nameSize, "heading", "OUTLINE")
    self:SetThemedFont(o.pct, pctSize, "numeric", "OUTLINE")
    shade(o.name, px); shade(o.pct, px)
    o.nameSize, o.nameFloor, o.pctSize = nameSize, floor, pctSize
    o.pct:ClearAllPoints()
    o.pct:SetPoint("BOTTOMRIGHT", plate, "TOPRIGHT", chipSpace, gap)
    o.name:ClearAllPoints()
    o.name:SetPoint("BOTTOMLEFT", plate, "TOPLEFT", inset, gap)
    o.nameBox = math.max(8, W + chipSpace - inset - pctW - 2 * gap)
    o.name:SetWidth(o.nameBox)
    o.nameText = nil

    local g = H * 0.7
    o.targetGlow:ClearAllPoints()
    o.targetGlow:SetPoint("TOPLEFT", plate, "TOPLEFT", -g, g)
    o.targetGlow:SetSize(W + chipSpace + 2 * g, H + 2 * g)


    local c = o.cast
    local castH = math.max(3 * px, H * look.castShare)
    local labelSize = floor
    local block = castH + gap + labelSize * 1.15
    c:ClearAllPoints()
    c:SetPoint("TOPLEFT", plate, "BOTTOMLEFT", inset, -gap)
    c:SetSize(gaugeW, block)
    c.value:ClearAllPoints()
    c.value:SetPoint("TOPLEFT", c, "TOPLEFT", 0, 0)
    c.value:SetSize(gaugeW, castH)
    c.icon:ClearAllPoints()
    c.icon:SetPoint("TOPRIGHT", c, "TOPLEFT", -gap, 0)
    c.icon:SetSize(block, block)
    self:SetThemedFont(c.label, labelSize, "heading", "OUTLINE")
    self:SetThemedFont(c.timer, labelSize, "numeric", "OUTLINE")
    shade(c.label, px); shade(c.timer, px)
    local timerW = measure(self, o.pctRuler, labelSize, "numeric", "8.8")
    c.label:ClearAllPoints()
    c.label:SetPoint("TOPLEFT", c.value, "BOTTOMLEFT", 0, -gap)
    c.label:SetWidth(math.max(8, gaugeW - timerW - gap))
    c.timer:ClearAllPoints()
    c.timer:SetPoint("TOPRIGHT", c.value, "BOTTOMRIGHT", 0, -gap)
    o.geometry = { W = W, H = H, barW = barW, barH = barH, laneH = laneH, gaugeW = gaugeW, castH = castH,
        chipW = chipW, chipH = chipH, x = x, span = span, pctW = pctW }
    return true
end



function A:NameplateChip()
    if self:GetOption("nameplateFill") ~= "follow" then return false end
    return self.PlusChipFor and self:PlusChipFor(nil) or false
end




function A:NameplateColour(token)
    if self:Read(UnitIsTapDenied, 1, token) == true then
        local g = A.nameplateLook.grey
        return g[1], g[2], g[3]
    end
    if self.PlusHealthColor then
        local ok, r, g, b = pcall(self.PlusHealthColor, self, token, "plusColorTarget")
        if ok and r then return r, g, b end
    end
    return self:Color("bad")
end

function A:NameplateRank(o, token)
    local rank
    if self:GetOption("plusRankStud") and self.PlateRankOf then
        local withheld
        rank, withheld = self:PlateRankOf(token)
        if withheld then rank = NP.ranks[token] else NP.ranks[token] = rank end
    end
    local spec = rank and A.plateRanks and A.plateRanks[rank]
    if not spec then
        o.rankStud:Hide(); o.rankGlow:Hide(); o.rankKey = nil
        return nil
    end
    if o.rankKey ~= rank then
        o.rankKey = rank
        local s = (o.studSize or 4) * spec.scale
        o.rankStud:ClearAllPoints()
        o.rankStud:SetPoint("CENTER", o.plate, "TOPRIGHT", o.studX or 0, o.studY or 0)
        o.rankStud:SetSize(s, s)
        o.rankStud:SetVertexColor(spec.color[1], spec.color[2], spec.color[3], 1)
        o.rankGlow:ClearAllPoints()
        o.rankGlow:SetPoint("CENTER", o.plate, "TOPRIGHT", o.studX or 0, o.studY or 0)
        o.rankGlow:SetSize(s * 2.8, s * 2.8)
        o.rankGlow:SetVertexColor(spec.glow[1], spec.glow[2], spec.glow[3], spec.glowA)
    end
    o.rankStud:Show(); o.rankGlow:Show()
    return rank
end







local function rgbOf(t, fallback)
    if type(t) == "table" and A:IsPublic(t.r) and type(t.r) == "number" and type(t.g) == "number"
        and type(t.b) == "number" then
        return t.r, t.g, t.b
    end
    return fallback[1], fallback[2], fallback[3]
end

function A:NameplateLevel(token)
    local level = self:Number(_G.UnitEffectiveLevel, 1, token) or self:Number(UnitLevel, 1, token)
    if not level then return nil end
    local D = A.nameplateDifficulty
    local tier, text
    if level <= 0 then
        tier, text = "impossible", "??"
    else
        text = tostring(math.floor(level + 0.5))
        if self:Read(_G.UnitCanAttack, 1, "player", token) ~= true then
            local r, g, b = rgbOf(_G.UNIT_LEVEL_NON_ATTACKABLE, D.neutral)
            return text, r, g, b, "neutral"
        end
        local mine = self:Number(_G.UnitEffectiveLevel, 1, "player") or self:Number(UnitLevel, 1, "player")
        if not mine then
            tier = "fair"
        else
            local diff = level - mine
            local quest = _G.C_QuestLog
            local trivial = self:Number(type(quest) == "table" and quest.GetTrivialRange or nil, 1)
                or self:Number(_G.GetQuestGreenRange, 1) or 8
            if diff < -trivial then tier = "trivial"
            elseif diff <= -3 then tier = "easy"
            elseif diff <= 2 then tier = "fair"
            elseif diff <= 4 then tier = "difficult"
            else tier = "impossible" end
        end
    end
    local globals = { trivial = "TRIVIAL_DIFFICULTY_COLOR", easy = "EASY_DIFFICULTY_COLOR",
        fair = "FAIR_DIFFICULTY_COLOR", difficult = "DIFFICULT_DIFFICULTY_COLOR",
        impossible = "IMPOSSIBLE_DIFFICULTY_COLOR" }
    local r, g, b = rgbOf(_G[globals[tier]], D[tier])
    return text, r, g, b, tier
end



function A:NameplateLevelPaint(o)
    local text, r, g, b, tier = self:NameplateLevel(o.token)
    o.levelShown = text ~= nil
    if not text then
        if o.levelFrame:IsShown() then o.levelFrame:Hide() end
        o.levelKey = nil
    else
        local key = string.format("%s|%.3f|%.3f|%.3f", text, r, g, b)
        if o.levelKey ~= key then
            o.levelKey = key
            o.levelText:SetText(text)
            o.levelText:SetTextColor(r, g, b, 1)
            local tw = self:Number(o.levelText.GetStringWidth, 1, o.levelText) or (o.levelSize or 10) * 0.6 * #text
            local chipH = o.chipH or 14
            local width = math.max(chipH * 1.15, tw + 2 * (o.chipPad or 3))
            o.levelFrame:SetSize(width, chipH)
            for _, fs in ipairs(o.levelGlow) do
                fs:SetText(text)
                fs:SetTextColor(r, g, b, A.nameplateLook.levelGlowA)
            end
            o.levelTier = tier
        end
        if not o.levelFrame:IsShown() then o.levelFrame:Show() end
    end
    if o.uf then
        for _, region in ipairs(levelRegions(o.uf)) do setHeld(self, region, o.levelShown) end
    end
    return o.levelShown
end


function A:NameplateHealth(o)
    local token = o.token
    if not token then return end
    self:UpdateBar(o.health, "Nameplate", UnitHealth, UnitHealthMax, token)
    if o.chip then self:PlusChipColour(o.health, token, "health") end
    self:SetPlusNumber(o.pct, "health", token, nil, true)
end




function A:NameplateName(o)
    local name = UnitName(o.token)
    local public = self:IsPublic(name)
    if public and o.nameText == name and o.nameText ~= nil then return end
    self:SetThemedFont(o.name, o.nameSize or 12, "heading", "OUTLINE")
    shade(o.name, 1 / self:NameplatePixelsPerUnit(o))
    pcall(o.name.SetText, o.name, name)
    o.nameText = public and name or nil
    if public and type(name) == "string" then
        self:SetFittedText(o.name, nil, o.nameSize or 12, o.nameFloor or o.nameSize or 12, false)
    end
end

function A:NameplatePaint(o)
    local token = o.token
    local r, g, b = self:NameplateColour(token)
    if r then
        o.health.value:SetStatusBarColor(r, g, b)
        if o.chip then
            o.health.lossRGB = { r, g, b }
            self:PaintChip(o.health, r, g, b)
        end
    end
    self:NameplateName(o)
    local friend = self:Read(UnitIsFriend, 1, "player", token) == true
    local executeOn = self:GetOption("plusExecute") and not friend
    o.executeBand:SetShown(executeOn and not o.chip)
    o.executeEdge:SetShown(executeOn)
    self:NameplateRank(o, token)
    self:NameplateLevelPaint(o)
    self:NameplateHealth(o)
end




function A:NameplateEmphasis(o)
    local look = A.nameplateLook
    local hasTarget = self:Read(UnitExists, 1, "target") == true
    local isTarget = hasTarget and self:Read(UnitIsUnit, 1, o.token, "target") == true
    local quiet = hasTarget and not isTarget
    local key = quiet and "quiet" or (isTarget and "target" or "plain")
    if o.emphasisKey ~= key then
        o.emphasisKey = key
        o:SetAlpha(quiet and look.otherAlpha or 1)
        if isTarget then
            local tr, tg, tb = self:Color("text")
            o.targetGlow:SetVertexColor(tr, tg, tb, look.targetGlowA)
        end
        o.targetGlow:SetShown(isTarget)
    end
    return isTarget
end









local function castTick(c, elapsed)
    local now = GetTime()
    local cast = c.publicCast
    if cast then
        if now >= cast.endTime then A:NameplateCastStop(c.owner); return end
        c.value:SetValue(cast.channel and (cast.endTime - now) or (now - cast.startTime))
        c.clock = (c.clock or 0) + (elapsed or 0)
        if c.clock >= 0.1 then
            c.clock = 0
            c.timer:SetText(string.format("%.1f", cast.endTime - now))
        end
    else
        c.value:SetValue(now * 1000)
    end
end
A.NameplateCastTick = castTick

function A:NameplateCastStop(o)
    local c = o and o.cast
    if not c then return end
    if c.live then
        c.live = nil
        c:SetScript("OnUpdate", nil)
    end
    c.publicCast = nil
    if c:IsShown() then c:Hide() end
end

function A:NameplateCastStart(o)
    local c = o and o.cast
    if not (c and o.token and o.uf and self:NameplateCastOurs()) then
        self:NameplateCastStop(o)
        return false
    end
    local now = self:Number(GetTime, 1)
    if not now then self:NameplateCastStop(o); return false end
    local cast = self:GetPublicCast(o.token)
    local ok
    if cast then
        if now >= cast.endTime then self:NameplateCastStop(o); return false end
        ok = pcall(function()
            c.value:SetMinMaxValues(0, cast.endTime - cast.startTime)
            c.value:SetValue(cast.channel and (cast.endTime - now) or (now - cast.startTime))
            c.label:SetText(cast.name)
            c.timer:SetText(string.format("%.1f", cast.endTime - now))
        end)
        c.publicCast = cast
    else
        cast = self:GetRestrictedCast(o.token)
        if not cast then self:NameplateCastStop(o); return false end
        c.publicCast = nil
        ok = pcall(function()
            c.value:SetMinMaxValues(cast.startTime, cast.endTime)
            c.value:SetValue(now * 1000)
            c.label:SetFormattedText("%s", cast.name)
            c.timer:SetText("")
        end)
    end
    if not ok then self:NameplateCastStop(o); return false end
    local role = cast.notInterruptible == true and "castShield" or (cast.channel and "castChannel" or "castNormal")
    if c.role ~= role then
        c.role = role
        self:Tint(c.value, role, "bar")
    end



    local icon = cast.texture ~= nil and cast.notInterruptible ~= true
    if icon then c.icon:SetTexture(cast.texture) end
    c.icon:SetShown(icon)
    c.clock = 0
    if not c.live then
        c.live = true
        c:SetScript("OnUpdate", castTick)
    end
    if not c:IsShown() then c:Show() end
    return true
end






function A:NameplateShouldSkin(o)
    if not self:NameplatesWanted() then return false end
    local uf = o.uf
    if type(uf) ~= "table" then return false end
    local container = uf.HealthBarsContainer
    local bar = type(container) == "table" and container.healthBar or nil
    if not (shown(container) and shown(bar)) then return false end
    if not self:NameplateStyleSkinnable() then return false end
    if not self:GetOption("nameplateFriendly") and self:Read(UnitIsFriend, 1, "player", o.token) == true then
        return false
    end
    return true
end

function A:NameplateSync(o)
    local uf = o.uf
    local want = self:NameplateShouldSkin(o)
    if want then
        local container = uf.HealthBarsContainer
        local okLayout = self:NameplateLayout(o, container, container.healthBar)
        want = okLayout
    end
    if not want then
        self:NameplateHold(uf, false)
        self:NameplateCastStop(o)
        if o:IsShown() then o:Hide() end
        return false
    end
    self:NameplatePaint(o)
    self:NameplateHold(uf, true, o.levelShown == true, self:NameplateCastOurs())
    self:NameplateEmphasis(o)
    if not o:IsShown() then o:Show() end
    self:NameplateCastStart(o)
    return true
end

local function baseFor(token)
    if type(C_NamePlate) ~= "table" then return nil end

    local base = call(C_NamePlate.GetNamePlateForUnit, token)
    if type(base) ~= "table" then return nil end
    return base
end

function A:NameplateUnbind(token)
    local o = NP.byToken[token]
    NP.byToken[token] = nil
    NP.ranks[token] = nil
    if not o then return end
    if o.uf then self:NameplateHold(o.uf, false) end
    self:NameplateCastStop(o)
    o.uf, o.token = nil, nil
    if o:IsShown() then o:Hide() end
end




function A:NameplateBind(token)
    if not self:NameplatesWanted() then return false end
    local base = baseFor(token)
    if not base then
        self:NameplateUnbind(token)
        return false
    end
    local uf = base.UnitFrame
    if type(uf) ~= "table" or type(uf.HealthBarsContainer) ~= "table" then return false end
    local o = self:NameplateOverlay(base)

    for t, other in pairs(NP.byToken) do
        if other == o and t ~= token then NP.byToken[t] = nil end
    end
    if o.uf and o.uf ~= uf then
        self:NameplateHold(o.uf, false)
        o.layoutKey = nil
    end
    if o.token ~= token then
        o.emphasisKey, o.rankKey, o.levelKey, o.nameText = nil, nil, nil, nil
        self:NameplateCastStop(o)
    end
    o.uf, o.token = uf, token
    NP.byToken[token] = o
    return self:NameplateSync(o)
end


function A:NameplateRebindAll()
    if type(C_NamePlate) ~= "table" then return end
    local plates = call(C_NamePlate.GetNamePlates)
    if type(plates) ~= "table" then return end
    for _, base in pairs(plates) do
        local token = call(base.GetUnit, base)
        if type(token) ~= "string" then
            local uf = base.UnitFrame
            token = type(uf) == "table" and uf.unit or nil
        end
        if type(token) == "string" and self:IsPublic(token) then self:NameplateBind(token) end
    end
end



function A:NameplatesApply()
    local wanted = self:NameplatesWanted()
    local key = table.concat({ tostring(wanted), tostring(self.Look and self:Look()), tostring(self.lookArtFor),
        tostring(self:GetOption("themeScheme")), tostring(self:GetOption("nameplateWidth")),
        tostring(self:GetOption("nameplateFriendly")), tostring(self:GetOption("nameplateFill")),
        tostring(self:GetOption("nameplateCast")),
        tostring(self:GetOption("plusExecute")), tostring(self:GetOption("plusRankStud")),
        tostring(self:GetOption("oakPlate")) }, "|")
    if NP.key == key then return false end
    NP.key = key
    for _, o in pairs(NP.overlays) do
        o.layoutKey, o.emphasisKey, o.rankKey, o.levelKey, o.nameText = nil, nil, nil, nil, nil
    end
    if wanted then
        self:NameplateRebindAll()
    else
        self:NameplateReleaseAll()
        for token in pairs(NP.byToken) do NP.byToken[token] = nil end
    end
    return true
end





local UNIT_EVENTS = { UNIT_HEALTH = "health", UNIT_MAXHEALTH = "health", UNIT_FACTION = "sync",
    UNIT_NAME_UPDATE = "paint", UNIT_CLASSIFICATION_CHANGED = "paint", UNIT_LEVEL = "level" }



local CAST_EVENTS = { UNIT_SPELLCAST_START = true, UNIT_SPELLCAST_STOP = true, UNIT_SPELLCAST_FAILED = true,
    UNIT_SPELLCAST_INTERRUPTED = true, UNIT_SPELLCAST_DELAYED = true, UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_CHANNEL_UPDATE = true, UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_INTERRUPTIBLE = true, UNIT_SPELLCAST_NOT_INTERRUPTIBLE = true }
A.nameplateCastEvents = CAST_EVENTS

local function plateToken(token)
    return type(token) == "string" and A:IsPublic(token) and token:find("^nameplate%d") ~= nil
end

function A:OnNameplateEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local token = ...
        if type(token) == "string" then
            if self:NameplatesWanted() then
                self:NameplateBind(token)


                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() pcall(A.NameplateBind, A, token) end)
                end
            end
        end
        return true
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local token = ...
        if type(token) == "string" then self:NameplateUnbind(token) end
        return true
    elseif event == "FORBIDDEN_NAME_PLATE_UNIT_ADDED" then
        NP.forbidden = NP.forbidden + 1
        return true
    elseif event == "FORBIDDEN_NAME_PLATE_UNIT_REMOVED" then
        return true
    end
    if CAST_EVENTS[event] then
        local token = ...
        if plateToken(token) then
            local o = NP.byToken[token]


            if o and o.uf and o:IsShown() then self:NameplateCastStart(o) end
        end
        return true
    end
    local kind = UNIT_EVENTS[event]
    if kind then
        local token = ...
        if not plateToken(token) then

            return kind == "level"
        end
        local o = NP.byToken[token]
        if o and o.uf and o:IsShown() then
            if kind == "health" then self:NameplateHealth(o)
            elseif kind == "paint" then self:NameplatePaint(o)
            elseif kind == "level" then self:NameplateLevelPaint(o)
            else self:NameplateSync(o) end
        elseif o and kind == "sync" then
            self:NameplateSync(o)
        end
        return true
    end
    if event == "PLAYER_TARGET_CHANGED" then
        for _, o in pairs(NP.byToken) do
            if o:IsShown() then self:NameplateEmphasis(o) end
        end
    elseif event == "CVAR_UPDATE" then
        if self:NameplatesWanted() then
            for token, o in pairs(NP.byToken) do
                o.layoutKey = nil
                self:NameplateBind(token)
            end
        end
    end
    return false
end






local function b(v) if v == nil then return "n/a" end return tostring(v) end
local function num(v) if type(v) == "number" then return string.format("%.3f", v) end return b(v) end
local function alphaOrNil(region) return type(region) == "table" and alphaOf(region) or nil end

function A:NameplateProbeLines()
    local lines = {}
    local function add(text) lines[#lines + 1] = "npprobe" .. text end
    local plates = type(C_NamePlate) == "table" and call(C_NamePlate.GetNamePlates) or nil
    local bound, held = 0, 0
    for _ in pairs(NP.byToken) do bound = bound + 1 end
    for _ in pairs(NP.held) do held = held + 1 end
    add(string.format(": switch %s | look %s | wanted %s | style skinnable %s | tier %s | cast %s",
        b(self:GetOption("nameplateSkin")), b(self.Look and self:Look()), b(self:NameplatesWanted()),
        b(self:NameplateStyleSkinnable()), b(self.buildTier), b(self:GetOption("nameplateCast"))))
    add(string.format(" plates: on screen %s | bound %d | held regions %d | forbidden adds seen %d",
        type(plates) == "table" and #plates or "n/a", bound, held, NP.forbidden))
    local pw, ph = call(GetPhysicalScreenSize)
    add(string.format(" scale: UIParent eff %s | screen %sx%s | cvars style %s size %s",
        num(self:Number(UIParent.GetEffectiveScale, 1, UIParent)), b(pw), b(ph),
        b(call(GetCVar, "nameplateStyle")), b(call(GetCVar, "nameplateSize"))))
    local base = type(C_NamePlate) == "table" and (call(C_NamePlate.GetNamePlateForUnit, "target")
        or (type(plates) == "table" and plates[1])) or nil
    if type(base) == "table" then
        local uf = base.UnitFrame
        local container = type(uf) == "table" and uf.HealthBarsContainer or nil
        local bar = type(container) == "table" and container.healthBar or nil
        local o = NP.overlays[base]
        add(string.format(" base: eff scale %s | px/unit %s | size %sx%s",
            num(self:Number(base.GetEffectiveScale, 1, base)), num(self:NameplatePixelsPerUnit(o or base)),
            num(self:Number(base.GetWidth, 1, base)), num(self:Number(base.GetHeight, 1, base))))
        if type(bar) == "table" then
            local w, h = liveSize(bar)
            local token = call(base.GetUnit, base)
            local _, status = self:Read(UnitHealth, 1, token)
            add(string.format(" bar: %sx%s | shown %s | alpha %s | name alpha %s | highlight alpha %s | health %s",
                num(w), num(h), b(self:Read(bar.IsShown, 1, bar)), num(alphaOf(bar)),
                num(alphaOrNil(uf.name)), num(alphaOrNil(uf.selectionHighlight)), b(status)))
            local lvl = uf.PlayerLevelDiffFrame
            local cast = uf.CastBarsContainer
            local castBar = type(cast) == "table" and cast.castBar or nil
            add(string.format(" level: box shown %s alpha %s span %s | classic level alpha %s | cast box alpha %s"
                .. " | cast bar shown %s alpha %s", b(type(lvl) == "table" and self:Read(lvl.IsShown, 1, lvl) or nil),
                num(alphaOrNil(lvl)), num(levelSpan(uf)), num(alphaOrNil(uf.LevelFrame)), num(alphaOrNil(cast)),
                b(type(castBar) == "table" and self:Read(castBar.IsShown, 1, castBar) or nil), num(alphaOrNil(castBar))))
        end
        if o and o.geometry then
            local g = o.geometry
            add(string.format(" ours: plate %sx%s | name %s units box %s | chip %sx%s level %s | cast lane %s live %s"
                .. " | overlay alpha %s", num(g.W), num(g.H), num(o.nameSize), num(o.nameBox), num(g.chipW),
                num(g.chipH), b(o.levelShown and o.levelTier or "none"), num(g.castH), b(o.cast and o.cast.live),
                num(alphaOf(o))))
        end
    else
        add(" base: none on screen (turn enemy nameplates on: V, or Esc > Options > Nameplates)")
    end
    return lines
end

function A:NameplateProbeCommand()
    for _, line in ipairs(self:NameplateProbeLines()) do self:Print(line) end
end
