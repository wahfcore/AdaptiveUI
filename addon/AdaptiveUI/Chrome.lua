local _, A = ...

























A.chromeArt = {
    options = { file = "options-bg", slot = "optionsBg", ratio = 1.55152,
                face = { 0.04028, 0.08193, 0.96026, 0.91807 },
                ledge = { 0.92399, 0.95693 } },
}




A.tileArts = {
    plain = { ratio = 3.875, lane = { 0.03906, 0.05303, 0.96094, 0.94318 }, base = { 0.2134, 0.2364, 0.2653 } },
    notch = { ratio = 3.88973, lane = { 0.03906, 0.05323, 0.96094, 0.94297 }, base = { 0.2537, 0.2710, 0.2999 } },
    pip = { ratio = 3.86415, lane = { 0.03906, 0.05660, 0.96094, 0.94340 }, base = { 0.1442, 0.1615, 0.1788 } },
    pipnotch = { ratio = 3.87879, lane = { 0.03906, 0.05303, 0.96094, 0.94318 }, base = { 0.1788, 0.2018, 0.2249 } },
    pipnotchr = { ratio = 3.88973, lane = { 0.03906, 0.05323, 0.96094, 0.94297 }, base = { 0.2018, 0.2249, 0.2480 } },
}




A.tileFor = { tot = "notch", focus = "pip", focustarget = "pipnotch", focustargettarget = "pipnotchr", pet = "plain" }


local function opt(self, key, fallback)
    if not (self.db and self.optionIndex and self.optionIndex[key]) then return fallback end
    return self:GetOption(key)
end






function A:MapSkinMode()
    local skin = opt(self, "mapSkin", "base")
    if skin == "shelf" and self:HasArt("oakMapMantle") then return "shelf" end
    if (skin == "shelf" or skin == "base") and self:HasArt("mapMin") then return "base" end
    return "card"
end


function A:MapPainted()
    return self:MapSkinMode() ~= "card"
end


function A:MapOnPlaque()
    local mode = self:MapSkinMode()
    return mode == "base" or mode == "shelf"
end



function A:MapBaseLike(mode)
    mode = mode or self:MapSkinMode()
    return mode == "base" or mode == "shelf"
end




function A:WindowSkinMode()
    local skin = opt(self, "windowSkin", "painted")
    if skin == "branch" and self:HasArt("oakWindowBranch") then return "branch" end
    if skin == "branch" then skin = "painted" end
    if skin == "painted" and self:HasArt("optionsBg") then return "painted" end
    return "flat"
end



function A:TrackerStyle()
    return opt(self, "trackerStyle", "tidy")
end

function A:ChatStyle()
    return opt(self, "chatStyle", "tidy")
end

function A:RaidTileOn()
    return opt(self, "raidSkin", "tile") == "tile" and self:HasArt("tilePlain")
end



function A:SmallTile(id)
    local variant = id and self.tileFor[id]
    if not variant then return nil end
    if opt(self, "plateSmallSkin", "inlay") ~= "tile" then return nil end
    if not (self:HasArt("tile-" .. variant .. "-cap") and self:HasArt("tile-" .. variant .. "-lum")) then return nil end
    return variant, self.tileArts[variant]
end


local function entriesFor(state, host)
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    return entries
end



function A:ChromeHide(state, host, ...)
    local entries = host and state.decorations[host]
    if not entries then return end
    for key, texture in pairs(entries) do
        for i = 1, select("#", ...) do
            local prefix = select(i, ...)
            if type(key) == "string" and key:sub(1, #prefix) == prefix
                and type(texture) == "table" and type(texture.IsShown) == "function" and texture:IsShown() then
                texture:Hide()
            end
        end
    end
end





function A:ChromeSoftPanel(state, host, key, tl, tlx, tly, br, brx, bry, opacity, flip)
    if not host or not tl or not br or type(host.CreateTexture) ~= "function" then return end
    local entries = entriesFor(state, host)
    local fill = entries[key]
    if not fill then
        fill = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
        fill:SetTexture(self.artPath .. "fade-soft.tga", "CLAMP", "CLAMP")
        self:Tint(fill, "nativeInk", "vertex", 1)
        if flip then fill:SetTexCoord(1, 0, 0, 1) end
        fill:SetPoint("TOPLEFT", tl, "TOPLEFT", tlx, tly)
        fill:SetPoint("BOTTOMRIGHT", br, "BOTTOMRIGHT", brx, bry)
        entries[key] = fill
    end
    local want = math.max(0, math.min(1, opacity or 1))
    if math.abs(fill:GetAlpha() - want) > 0.001 then fill:SetAlpha(want) end
    if not fill:IsShown() then fill:Show() end
    state.count = state.count + 1
end







A.mapPlaqueArt = { ratio = 2071 / 553, upperV1 = 0.495, lowerV0 = 0.573, lowerV1 = 0.953, rakeU = 0.76,
                   diamondU = 0.863 }


























A.mapBase = { lip = 10, rimV = 1 / 256, railU = 0.075, clockU = 0.80, clockW = 52, zonePx = 12, subPx = 6.5,
              inset = 4, haloAlpha = 0.70, haloInner = 0.70, edgeAlpha = 0.55, backPx = 2, backAlpha = 0.85, haloTopF = 1.0,
              riseK = 1.8, riseAlpha = 0.60, haloSpan = "map", zoneX = 6 }




































A.mapMantle = { file = "oak-map-mantle", ratio = 1679 / 252, topU0 = 73 / 1679, topU1 = 1605 / 1679,
                rimV = 2 / 252, back = "square", backPad = 3, backAlpha = 1, feather = false,



                pad = 5, gap = 8, zonePx = 12, clockPx = 11, coordPx = 10, zoneMinPx = 10, calRoom = 30,


                black = { 0, 0, 0 }, scrimAlpha = 0.80, scrimSolid = 0.62, light = { 0.94, 0.91, 0.85 }, lightMuted = { 0.74, 0.72, 0.68 } }

function A:MapShelfGeometry(mapW, mapH)
    local m = self.mapMantle
    local d = m.backPad

    local w = (mapW + 2 * d) / (m.topU1 - m.topU0)
    local h = w / m.ratio
    local overlap = h * m.rimV
    local left = m.topU0 * w + d
    local zs = self:MapPlaqueTextSize() or m.zonePx
    local cs = self:MapPlaqueSubSize() or m.coordPx
    local ks = self:MapClockSize() or m.clockPx
    local coordsOn = opt(self, "minimapCoords", true) ~= false
    local zoneH, clockH = zs * 1.25, ks * 1.25
    local coordH = cs * 1.25

    local zoneY = mapH - m.pad - zoneH / 2

    local rowH = math.max(coordsOn and coordH or 0, clockH)
    local rowY = m.pad + rowH / 2
    local textTop = m.pad + rowH
    local zoneFoot = m.pad + zoneH
    return { plaque = true, base = true, shelf = true, mode = "shelf", w = w, h = h, overlap = overlap,
             left = left, right = w - left - mapW, top = d, bottom = h - overlap, mapW = mapW, mapH = mapH,
             backPad = d, lip = 0,
             zoneY = zoneY, zoneH = zoneH, coordY = rowY, coordH = coordH,
             clockY = rowY, clockH = clockH, clockR = mapW - m.pad,
             textX = m.pad, textW = mapW - 2 * m.pad - m.calRoom, coordW = mapW - 2 * m.pad,
             trackY = zoneFoot + 2,
             textTop = textTop, scrimH = math.min(mapH, textTop / m.scrimSolid),
             topScrimH = math.min(mapH, zoneFoot / m.scrimSolid) }
end

function A:MapPlaqueGeometry(mapW, mapH)
    if self:MapSkinMode() == "shelf" then return self:MapShelfGeometry(mapW, mapH) end
    local b, art = self.mapBase, self.mapPlaqueArt
    local w = mapW + 2 * b.lip
    local h = w / art.ratio
    local overlap = h * b.rimV
    local function y(v) return overlap - v * h end
    local textX = b.railU * w - b.lip
    local clockR = b.clockU * w - b.lip
    return { plaque = true, base = true, mode = "base", w = w, h = h, lip = b.lip, overlap = overlap,
             left = b.lip, right = b.lip, top = 0, bottom = h - overlap, mapW = mapW, mapH = mapH,
             zoneY = y((0.05 + art.upperV1) / 2), coordY = y((art.lowerV0 + art.lowerV1) / 2),
             zoneH = (art.upperV1 - 0.05) * h, coordH = (art.lowerV1 - art.lowerV0) * h,
             textX = textX, textW = (art.rakeU - b.railU) * w,
             coordW = clockR - b.clockW - textX, clockR = clockR,
             diamondX = art.diamondU * w - b.lip, diamondY = y(0.50), diamondR = 0.025 * w }
end




local function clusterTextSize(self, px)
    local cluster = _G.MinimapCluster
    local eff = cluster and self:Number(cluster.GetEffectiveScale, 1, cluster) or nil
    if not eff or eff <= 0.05 then eff = 0.55 end
    local ts = (self.db and tonumber(self.db.textScale)) or 1
    if ts <= 0.05 then ts = 1 end
    return math.ceil(px / (eff * ts) * 2) / 2
end





A.mapZoneMinPx = 9
function A:FitMapZone(state, size)
    local fs, boxW = _G.MinimapZoneText, self.mapZoneBoxW
    if type(fs) ~= "table" or not boxW or boxW <= 0 then return end
    local _, cur = fs:GetFont()
    local getter = fs.GetUnboundedStringWidth or fs.GetStringWidth
    local sw = type(getter) == "function" and self:Number(getter, 1, fs) or nil
    if type(cur) ~= "number" or cur <= 0 or not sw or sw <= 0 then return end
    local per = sw / cur
    local floor = clusterTextSize(self, A.mapZoneMinPx)
    local want = math.max(floor, math.min(size, math.floor(boxW / per * 2) / 2))
    local ts = (self.db and tonumber(self.db.textScale)) or 1
    if math.abs(cur - want * ts) < 0.01 then return end
    local _, _, flags = fs:GetFont()
    self:SetThemedFont(fs, want * ts, false, flags, true)
    self.mapZoneFit = want
end

function A:MapPlaqueTextSize()
    local mode = self:MapSkinMode()
    if mode == "shelf" then return clusterTextSize(self, self.mapMantle.zonePx) end
    if mode == "base" then return clusterTextSize(self, self.mapBase.zonePx) end
    return nil
end



function A:MapPlaqueSubSize()
    if not self:MapBaseLike() then return nil end
    if self:MapSkinMode() == "shelf" then return clusterTextSize(self, self.mapMantle.coordPx) end
    return clusterTextSize(self, self.mapBase.subPx)
end



function A:MapClockSize()
    if self:MapSkinMode() == "shelf" then return clusterTextSize(self, self.mapMantle.clockPx) end
    return self:MapPlaqueSubSize()
end




function A:MapOwnTextSize(px)
    local ts = (self.db and tonumber(self.db.textScale)) or 1
    if ts <= 0.05 then ts = 1 end
    return clusterTextSize(self, px) * ts
end

function A:MapCardGeometry(mapW, mapH)
    return self:MapPlaqueGeometry(mapW, mapH)
end




local function tintOnce(self, t, role, alpha)
    local r, gg, b = self:Color(role)
    local cr, cg, cb, ca = t:GetVertexColor()
    if math.abs(cr - r) > 1e-4 or math.abs(cg - gg) > 1e-4 or math.abs(cb - b) > 1e-4 or math.abs((ca or 1) - alpha) > 1e-4 then
        self:Tint(t, role, "vertex", alpha)
    end
end



function A:MapHaloSpan(g)
    if self.mapBase.haloSpan == "plaque" then return g.w or (g.mapW or 0) end
    return g.mapW or g.w or 0
end

function A:MapBaseFade(state, cluster, map, g)
    local entries = entriesFor(state, cluster)
    local slots = self.artSlots or {}
    local b = self.mapBase
    local want = g and g.base


    local square = want and g.shelf and self.mapMantle.back == "square"
    local halo, edge = entries.mapHalo, entries.mapEdge
    if want and not square and slots.mapHalo then
        if not halo then
            halo = self:Own(cluster:CreateTexture(nil, "BACKGROUND", nil, -8))
            halo:SetTexture(self.artPath .. "map-halo.tga", "CLAMP", "CLAMP")
            entries.mapHalo = halo
        end


        local objW, objH = self:MapHaloSpan(g), g.mapH + g.bottom
        local lip = b.haloSpan == "plaque" and g.lip or 0
        local padX = objW * (1 - b.haloInner) / (2 * b.haloInner)
        local padY = objH * (1 - b.haloInner) / (2 * b.haloInner)


        local padTop = padY * b.haloTopF
        local padBot = padY
        local sig = string.format("%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", padX, padY, padTop, lip, g.bottom, padBot)
        if halo.auiSig ~= sig then
            halo.auiSig = sig
            halo:ClearAllPoints()
            halo:SetPoint("TOPLEFT", map, "TOPLEFT", -(lip + padX), padTop)
            halo:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", lip + padX, -(g.bottom + padBot))
        end
        tintOnce(self, halo, "shadow", b.haloAlpha)
        if not halo:IsShown() then halo:Show() end
    elseif halo and halo:IsShown() then
        halo:Hide()
    end



    local back = entries.mapBack
    if want then
        if not back then
            back = self:Own(cluster:CreateTexture(nil, "BACKGROUND", nil, -7))
            entries.mapBack = back
        end


        local d = square and g.backPad or b.backPx * self:PhysicalPixel(cluster)
        local foot = square and g.overlap or 0
        local sig = string.format("%.4f|%.4f", d, foot)
        if back.auiSig ~= sig then
            back.auiSig = sig
            back:ClearAllPoints()
            back:SetPoint("TOPLEFT", map, "TOPLEFT", -d, d)
            back:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", d, -foot)
        end
        if square then


            local a, k = self.mapMantle.backAlpha, self.mapMantle.black
            if back.auiBlack ~= a then
                back.auiBlack = a
                back:SetColorTexture(k[1], k[2], k[3], a)
            end
            if self.themed then self.themed[back] = nil end
        else
            back.auiBlack = nil
            self:Tint(back, "shadow", "color", b.backAlpha)
        end
        if not back:IsShown() then back:Show() end




        local rise = entries.mapRise


        if square then
            if rise and rise:IsShown() then rise:Hide() end
        elseif slots.riseWide then
            if not rise then
                rise = self:Own(cluster:CreateTexture(nil, "BACKGROUND", nil, -7))
                rise:SetTexture(self.artPath .. "rise-wide.tga", "CLAMP", "CLAMP")
                entries.mapRise = rise
            end


            local objH = (g.mapH or 0) + (g.bottom or 0)
            local rh = b.riseK * objH * (1 - b.haloInner) / (2 * b.haloInner)

            local objW = self:MapHaloSpan(g)
            local lip = b.haloSpan == "plaque" and (g.lip or 0) or 0
            local sideX = lip + objW * (1 - b.haloInner) / (2 * b.haloInner)
            local rsig = string.format("%.4f|%.3f|%.3f", d, rh, sideX)
            if rise.auiSig ~= rsig then
                rise.auiSig = rsig
                rise:ClearAllPoints()
                rise:SetPoint("BOTTOMLEFT", map, "TOPLEFT", -sideX, d)
                rise:SetPoint("BOTTOMRIGHT", map, "TOPRIGHT", sideX, d)
                rise:SetHeight(rh)
            end
            tintOnce(self, rise, "shadow", b.riseAlpha)
            if not rise:IsShown() then rise:Show() end
        end
    else
        if back and back:IsShown() then back:Hide() end
        if entries.mapRise and entries.mapRise:IsShown() then entries.mapRise:Hide() end
    end
    if want and slots.mapEdge and (not square or self.mapMantle.feather) then
        local host = entries.mapEdgeHost
        if not host then
            host = self:Own(CreateFrame("Frame", nil, cluster))
            host:EnableMouse(false)
            host:SetAllPoints(map)
            entries.mapEdgeHost = host
            edge = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 1))
            edge:SetTexture(self.artPath .. "map-edge.tga", "CLAMP", "CLAMP")
            edge:SetAllPoints(host)
            entries.mapEdge = edge
        end


        local level = (self:Number(map.GetFrameLevel, 1, map) or 1) + 2
        if host:GetFrameLevel() ~= level then host:SetFrameLevel(level) end
        tintOnce(self, edge, "shadow", b.edgeAlpha)
        if not host:IsShown() then host:Show() end
        if not edge:IsShown() then edge:Show() end
    elseif entries.mapEdgeHost and entries.mapEdgeHost:IsShown() then
        entries.mapEdgeHost:Hide()
    end
end

function A:ChromeMapCard(state, cluster, map, on)
    if not cluster or not map or type(cluster.CreateTexture) ~= "function" then return end
    local entries = entriesFor(state, cluster)
    if not on then
        if entries.paint then self:HidePainted(entries.paint) end
        self:MapBaseFade(state, cluster, map, nil)
        self:MapShelf(state, entries, cluster, map, nil)
        return
    end


    local file = "map-min"
    if not entries.paint then
        local paint = self:PaintedTexture(cluster, "BACKGROUND", -7, file)
        entries.paint = paint
        entries.paintAcc = self:PaintedTwin(paint)
    end
    if (self.painted[entries.paint] and self.painted[entries.paint].name) ~= file then
        self:SetPainted(entries.paint, file)
    end
    local mw = self:Number(map.GetWidth, 1, map) or 198
    local mh = self:Number(map.GetHeight, 1, map) or mw
    local g = self:MapCardGeometry(mw, mh)
    local signature = string.format("%.2f|%.2f|%s|%s", mw, mh, file, tostring(g.mode))
    state.mapPaintSignature = state.mapPaintSignature or setmetatable({}, { __mode = "k" })
    if state.mapPaintSignature[cluster] ~= signature then
        state.mapPaintSignature[cluster] = signature
        entries.paint:ClearAllPoints()
        if g.plaque then
            entries.paint:SetPoint("TOPLEFT", map, "BOTTOMLEFT", -g.left, g.overlap)
            entries.paint:SetSize(g.w, g.h)
        else
            entries.paint:SetPoint("TOPLEFT", map, "TOPLEFT", -g.left, g.top)
            entries.paint:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", g.right, -g.bottom)
        end
    end
    self:PaintedAlpha(entries.paint, 1)
    if g.shelf then
        self:HidePainted(entries.paint)
    elseif not entries.paint:IsShown() then entries.paint:Show() end
    self:SyncPainted(entries.paint)
    self:MapShelf(state, entries, cluster, map, g)


    self:MapBaseFade(state, cluster, map, g)

    self:ChromeHide(state, cluster, "card", "rim")
    if self.SuppressDepth then self:SuppressDepth(entries, "card~", true) end
    self:HideChromeRim(state, cluster, "rim")
    self:ChromeHide(state, MinimapBackdrop or map, "border")
    state.count = state.count + 1
end










A.oakBranches = { window = { file = "oak-window-branch", ratio = 12.129, wide = 1.04, drop = 0.06, legendLift = 8 } }







function A:MapShelfSources()
    local container = MinimapCluster and MinimapCluster.MinimapContainer
    local coords = container and container.PlayerCoords
    return { zone = _G.MinimapZoneText, coords = coords and coords.CoordText, clock = _G.TimeManagerClockTicker }
end

function A:MapShelf(state, entries, cluster, map, g)
    local on = g and g.shelf
    local src = self:MapShelfSources()
    if not on then
        if entries.mapShelf then self:HidePainted(entries.mapShelf) end
        if entries.mapShelfHost and entries.mapShelfHost:IsShown() then entries.mapShelfHost:Hide() end
        if state.shelfHeld then
            state.shelfHeld = nil
            for _, key in ipairs({ "zone", "coords", "clock" }) do
                if src[key] then self:ReleaseHidden(state, src[key]) end
            end
        end
        if self.mapShelfEntries == entries then self.mapShelfEntries = nil end
        return
    end
    local m = self.mapMantle
    if not entries.mapShelf then
        entries.mapShelf = self:PaintedTexture(cluster, "BORDER", 1, m.file)
        entries.mapShelfAcc = self:PaintedTwin(entries.mapShelf)
    end
    local shelf = entries.mapShelf
    local sig = string.format("%.3f|%.3f|%.3f|%.3f", g.w, g.h, g.left, g.overlap)
    if shelf.auiSig ~= sig then
        shelf.auiSig = sig
        shelf:ClearAllPoints()

        shelf:SetPoint("TOPLEFT", map, "BOTTOMLEFT", -g.left, g.overlap)
        shelf:SetSize(g.w, g.h)
    end
    if not shelf:IsShown() then shelf:Show() end
    self:SyncPainted(shelf)

    local host = entries.mapShelfHost
    if not host then
        host = self:Own(CreateFrame("Frame", nil, cluster))
        host:EnableMouse(false)
        host:SetAllPoints(map)
        entries.mapShelfHost = host
        entries.mapScrim = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, 0))
        entries.mapScrimTop = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, 0))
        entries.mapShelfZone = self:Own(host:CreateFontString(nil, "OVERLAY"))
        entries.mapShelfCoords = self:Own(host:CreateFontString(nil, "OVERLAY"))
        entries.mapShelfClock = self:Own(host:CreateFontString(nil, "OVERLAY"))
        entries.mapShelfZone:SetJustifyH("LEFT")
        entries.mapShelfCoords:SetJustifyH("LEFT")
        entries.mapShelfClock:SetJustifyH("RIGHT")
        for _, fs in ipairs({ entries.mapShelfZone, entries.mapShelfCoords, entries.mapShelfClock }) do
            if type(fs.SetWordWrap) == "function" then fs:SetWordWrap(false) end




            self:SetThemedFont(fs, self.mapMantle.zonePx or 14, false, "", false)
        end
    end
    local level = (self:Number(map.GetFrameLevel, 1, map) or 1) + 3
    if host:GetFrameLevel() ~= level then host:SetFrameLevel(level) end
    if not host:IsShown() then host:Show() end


    for _, s in ipairs({ { entries.mapScrim, "BOTTOMLEFT", g.scrimH, false },
                         { entries.mapScrimTop, "TOPLEFT", g.topScrimH, true } }) do
        local scrim, corner, sh, flip = s[1], s[2], s[3], s[4]
        if scrim and sh and (self.artSlots or {}).mapScrim then
            local file = self.artPath .. "map-scrim.tga"
            if scrim:GetTexture() ~= file then scrim:SetTexture(file, "CLAMP", "CLAMP") end
            local ssig = string.format("%.3f|%.3f", g.mapW, sh)
            if scrim.auiSig ~= ssig then
                scrim.auiSig = ssig
                scrim:ClearAllPoints()
                scrim:SetPoint(corner, host, corner, 0, 0)
                scrim:SetSize(g.mapW, sh)
                if flip then scrim:SetTexCoord(0, 1, 1, 0) else scrim:SetTexCoord(0, 1, 0, 1) end
            end
            local _, _, _, a = scrim:GetVertexColor()
            if scrim.auiAlpha ~= m.scrimAlpha or math.abs((a or 1) - m.scrimAlpha) > 1e-4 then
                scrim.auiAlpha = m.scrimAlpha
                scrim:SetVertexColor(m.black[1], m.black[2], m.black[3], m.scrimAlpha)
            end
            if not scrim:IsShown() then scrim:Show() end
        elseif scrim and scrim:IsShown() then
            scrim:Hide()
        end
    end

    for _, key in ipairs({ "zone", "coords", "clock" }) do
        if src[key] then self:HoldHidden(state, src[key]) end
    end
    state.shelfHeld = true

    host.auiGeometry = g
    self.mapShelfEntries = entries
    self.mapShelfTextSig = nil
    self:SyncMapShelfText()
end



function A:MapShelfColours()
    local scheme = self:Scheme()
    local m = self.mapMantle
    if scheme and scheme.light then
        return m.light, m.lightMuted
    end
    local tr, tg, tb = self:Color("text")
    local mr, mg, mb = self:Color("muted")
    return { tr, tg, tb }, { mr, mg, mb }
end



local function mirror(self, fs, src)
    if type(src) ~= "table" or type(src.GetText) ~= "function" then
        if fs.auiText ~= "" then fs.auiText = ""; fs:SetText("") end
        return
    end
    local text = src:GetText()
    if self:IsPublic(text) then
        text = text or ""
        if fs.auiText ~= text then fs.auiText = text; fs:SetText(text); return true end
        return false
    end

    fs.auiText = nil
    fs:SetFormattedText("%s", text)
    return true
end

local function setFontOnce(self, fs, size, sig)
    if fs.auiFontSig ~= sig then
        fs.auiFontSig = sig
        self:SetThemedFont(fs, size, false, "", false)
    end
end

local function stringWidth(self, fs)
    local getter = fs.GetUnboundedStringWidth or fs.GetStringWidth
    local w = type(getter) == "function" and self:Number(getter, 1, fs) or nil
    if type(w) ~= "number" or w ~= w or w < 0 then return nil end
    return w
end



function A:SyncMapShelfText()
    local e = self.mapShelfEntries
    local host = e and e.mapShelfHost
    local g = host and host.auiGeometry
    if not g or not host or not host:IsShown() then return end
    local m = self.mapMantle
    local src = self:MapShelfSources()
    local zone, coords, clock = e.mapShelfZone, e.mapShelfCoords, e.mapShelfClock
    local face = self:FontPath(false)
    local zs, cs, ks = self:MapOwnTextSize(m.zonePx), self:MapOwnTextSize(m.coordPx), self:MapOwnTextSize(m.clockPx)
    setFontOnce(self, clock, ks, face .. ks)
    setFontOnce(self, coords, cs, face .. cs)
    local zoneChanged = mirror(self, zone, src.zone)
    mirror(self, coords, src.coords)
    mirror(self, clock, src.clock)

    local zoneOn = opt(self, "minimapZone", true) ~= false
    local coordsOn = opt(self, "minimapCoords", true) ~= false
    local button = _G.TimeManagerClockButton
    local clockOn = type(src.clock) == "table" and type(button) == "table" and type(button.IsShown) == "function"
    if clockOn then
        local shown = button:IsShown()
        clockOn = self:IsPublic(shown) and shown == true
    end
    for fs, want in pairs({ [zone] = zoneOn, [coords] = coordsOn, [clock] = clockOn }) do
        if want and not fs:IsShown() then fs:Show() elseif not want and fs:IsShown() then fs:Hide() end
    end

    local clockW = clockOn and stringWidth(self, clock) or nil
    if clockOn and not clockW then clockW = ks * 2.9 end


    local boxW = g.textW
    local coordW = clockOn and (g.clockR - clockW - m.gap - g.textX) or g.coordW
    local zoneText = zone.auiText
    local sig = string.format("%s|%.2f|%.2f|%.2f|%.3f|%.3f|%.3f|%s|%s", face, zs, boxW, coordW, g.zoneY, g.coordY, g.clockY,
        tostring(zoneText), tostring(zoneChanged and zoneText == nil))
    if self.mapShelfTextSig ~= sig then
        self.mapShelfTextSig = sig

        setFontOnce(self, zone, zs, face .. zs)
        local size = zs
        local w = zoneText and stringWidth(self, zone) or nil
        if w and w > boxW and w > 0 then
            local floor = self:MapOwnTextSize(m.zoneMinPx)
            size = math.max(floor, math.floor(zs * boxW / w * 2) / 2)
            setFontOnce(self, zone, size, face .. size)
        end
        self.mapShelfZoneSize = size
        zone:ClearAllPoints()
        zone:SetPoint("LEFT", host, "BOTTOMLEFT", g.textX, g.zoneY)
        zone:SetSize(math.max(1, boxW), g.zoneH)
        coords:ClearAllPoints()
        coords:SetPoint("LEFT", host, "BOTTOMLEFT", g.textX, g.coordY)
        coords:SetSize(math.max(1, coordW), g.coordH)
    end
    local csig = string.format("%.2f|%.3f", clockW or 0, g.clockR)
    if clock.auiSig ~= csig then
        clock.auiSig = csig
        clock:ClearAllPoints()
        clock:SetPoint("RIGHT", host, "BOTTOMLEFT", g.clockR, g.clockY)
        clock:SetSize(math.max(1, (clockW or 0) + 2), g.clockH)
    end
    local text, muted = self:MapShelfColours()
    local colourSig = table.concat({ text[1], text[2], text[3], muted[1], muted[2], muted[3] }, ",")
    if host.auiColour ~= colourSig then
        host.auiColour = colourSig
        zone:SetTextColor(text[1], text[2], text[3], 1)
        clock:SetTextColor(text[1], text[2], text[3], 1)
        coords:SetTextColor(muted[1], muted[2], muted[3], 1)
    end
end




function A:TickMapShelf(elapsed)
    if not self.mapShelfEntries then return end
    self.mapShelfElapsed = (self.mapShelfElapsed or 0) + (elapsed or 0)
    if self.mapShelfElapsed < 0.25 then return end
    self.mapShelfElapsed = 0
    self:SyncMapShelfText()
end








A.windowFoot = 48
function A:WindowPaintGeometry(w, h)
    local art = self.chromeArt.options
    local f = art.face
    local inFace = h - self.windowFoot + 8
    local ph = inFace / (f[4] - f[2])
    local pw = ph * art.ratio
    if pw * (f[3] - f[1]) < w + 16 then
        pw = (w + 16) / (f[3] - f[1])
        ph = pw / art.ratio
    end
    local side = (pw - w) / 2
    local top = ph * f[2] + 4
    return { w = pw, h = ph, side = side, top = top, bottom = ph - top - h }
end





local function placeFooter(self, frame)
    local f = frame.auiFooter
    if not f then return end
    for key, b in pairs({ close = f.close, reset = f.reset }) do
        if b then
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", frame, "TOPLEFT", f.home[key][1], f.home[key][2])
            if b.bg then b.bg:SetShown(true) end
        end
    end
    if f.legend then
        f.legend:ClearAllPoints()
        self:SetThemedFont(f.legend, self.tokens.type.body, false)
        local lift = self:WindowSkinMode() == "branch" and self.oakBranches.window.legendLift or 0
        f.legend:SetPoint("TOPLEFT", frame, "TOPLEFT", f.home.legend[1], f.home.legend[2] + lift)
        f.legend:SetWidth(f.home.legend[3])
    end
end



function A:WindowBranchFoot(frame)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local on = self:WindowSkinMode() == "branch"
    if not frame.auiBranch then
        if not on then return end
        frame.auiBranch = self:PaintedTexture(frame, "BORDER", 2, self.oakBranches.window.file)
        frame.auiBranchAcc = self:PaintedTwin(frame.auiBranch)
    end
    local w = self:Number(frame.GetWidth, 1, frame) or 520
    local ba = self.oakBranches.window
    local bw = w * ba.wide
    local bh = bw / ba.ratio
    frame.auiBranch:ClearAllPoints()
    frame.auiBranch:SetPoint("CENTER", frame, "BOTTOM", 0, -bh * ba.drop)
    frame.auiBranch:SetSize(bw, bh)
    if on then frame.auiBranch:Show() else self:HidePainted(frame.auiBranch) end
    self:SyncPainted(frame.auiBranch)
    if frame.depth and self.SuppressDepth then self:SuppressDepth(frame.depth, "panel~", on) end
    if type(frame.SetClampRectInsets) == "function" then
        if on then frame:SetClampRectInsets(-(bw - w) / 2, (bw - w) / 2, 0, -(bh * (0.5 + ba.drop)))
        else frame:SetClampRectInsets(0, 0, 0, 0) end
    end
end

function A:DressOptionsWindow(frame)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local mode = self:WindowSkinMode()
    local painted = mode == "painted"

    if not frame.auiPaint then
        frame.auiPaint = self:PaintedTexture(frame, "BACKGROUND", -8, self.chromeArt.options.file)
        frame.auiPaintAcc = self:PaintedTwin(frame.auiPaint)
    end






    if not frame.auiBranch then
        frame.auiBranch = self:PaintedTexture(frame, "BORDER", 2, self.oakBranches.window.file)
        frame.auiBranchAcc = self:PaintedTwin(frame.auiBranch)
    end
    if frame.auiPainted == mode then
        self:SyncPainted(frame.auiPaint)
        self:SyncPainted(frame.auiBranch)

        if frame.auiFooter and frame.auiFooterMode ~= mode then
            frame.auiFooterMode = mode
            placeFooter(self, frame)
        end
        return
    end
    frame.auiPainted = mode
    local w = self:Number(frame.GetWidth, 1, frame) or 1000
    local h = self:Number(frame.GetHeight, 1, frame) or 640
    local g = self:WindowPaintGeometry(w, h)
    frame.auiPaint:ClearAllPoints()
    frame.auiPaint:SetPoint("TOPLEFT", frame, "TOPLEFT", -g.side, g.top)
    frame.auiPaint:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", g.side, -g.bottom)
    if painted then frame.auiPaint:Show() else self:HidePainted(frame.auiPaint) end
    self:SyncPainted(frame.auiPaint)
    local branch = mode == "branch"
    local ba = self.oakBranches.window
    local bw = w * ba.wide
    local bh = bw / ba.ratio
    frame.auiBranch:ClearAllPoints()
    frame.auiBranch:SetPoint("CENTER", frame, "BOTTOM", 0, -bh * ba.drop)
    frame.auiBranch:SetSize(bw, bh)
    if branch then frame.auiBranch:Show() else self:HidePainted(frame.auiBranch) end
    self:SyncPainted(frame.auiBranch)
    placeFooter(self, frame)
    if frame.auiFooter then frame.auiFooterMode = mode end
    if frame.bg then
        frame.bg:SetShown(not painted)
        frame.bg:ClearAllPoints()
        frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.bg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -h)
    end

    if frame.rule then frame.rule:SetShown(not painted and not branch) end
    if frame.depth and self.SuppressDepth then self:SuppressDepth(frame.depth, "d", painted or branch) end
    if type(frame.SetClampRectInsets) == "function" then
        if painted then frame:SetClampRectInsets(-g.side, g.side, g.top, -g.bottom)
        elseif branch then frame:SetClampRectInsets(-(bw - w) / 2, (bw - w) / 2, 0, -(bh * (0.5 + ba.drop)))
        else frame:SetClampRectInsets(0, 0, 0, 0) end
    end
end







function A:ChatEditTyping(edit)
    return edit and type(edit.HasFocus) == "function" and edit:HasFocus() == true or false
end

function A:WatchChatFocus()
    if self.chatFocusWatched then return end
    if type(EventRegistry) ~= "table" or type(EventRegistry.RegisterCallback) ~= "function" then return end
    self.chatFocusWatched = true
    local function changed()

        A.nativeDirty = true
        if A.RefreshChatEdit then pcall(A.RefreshChatEdit, A) end
    end
    pcall(EventRegistry.RegisterCallback, EventRegistry, "ChatFrame.OnEditBoxFocusGained", changed, self)
    pcall(EventRegistry.RegisterCallback, EventRegistry, "ChatFrame.OnEditBoxFocusLost", changed, self)
end



function A:ChatEditDress(state, edit, index)
    local entries = state.decorations[edit]
    if self:ChatEditTyping(edit) then
        local e = entriesFor(state, edit)
        self:SuppressDepth(e, "panel~", false)
        self.NativeFill(self, state, edit, self:Surface("raised"), false, "raised")
        self.NativeBorder(self, state, edit, 1, 2)
        self:ChromeRim(state, edit, edit, "rim", { "BOTTOMLEFT" })
    elseif entries then
        self:ChromeHide(state, edit, "panel", "border")
        self:SuppressDepth(entries, "panel~", true)
        self:HideChromeRim(state, edit, "rim")
    end
end



function A:RefreshChatEdit()
    local state = self.nativeSkins and self.nativeSkins.chat
    if not state or self:IsCombat() then return end
    for i = 1, 10 do
        local frame = _G["ChatFrame" .. i]
        local edit = frame and (frame.editBox or _G["ChatFrame" .. i .. "EditBox"])
        if edit and self.ChatEditDress then self:ChatEditDress(state, edit, i) end
    end
end



function A:QuietTexture(state, texture, on)
    if not texture or type(texture.SetVertexColor) ~= "function" then return end
    if not on then
        self:ReleaseProperty(state, texture, "quiet")
        return
    end
    local props = state.properties and state.properties[texture]
    if props and props.quiet then return end
    local r, g, b, a = 1, 1, 1, 1
    if type(texture.GetVertexColor) == "function" then r, g, b, a = texture:GetVertexColor() end
    for _, v in ipairs({ r, g, b, a }) do
        if not self:IsPublic(v) or type(v) ~= "number" then return end
    end
    local desat = type(texture.IsDesaturated) == "function" and texture:IsDesaturated() or false
    if not self:IsPublic(desat) then return end
    self:RememberProperty(state, texture, "quiet", function()
        return function()
            if type(texture.SetDesaturated) == "function" then texture:SetDesaturated(desat and true or false) end
            texture:SetVertexColor(r, g, b, a)
        end
    end)
    if type(texture.SetDesaturated) == "function" then texture:SetDesaturated(true) end
    local mr, mg, mb = self:Color("muted")
    texture:SetVertexColor(mr, mg, mb, 0.55)
end

A.chatGutterButtons = { "ChatFrameMenuButton", "ChatFrameChannelButton", "TextToSpeechButton", "QuickJoinToastButton" }
A.chatButtonFrameRegions = { "Background", "TopLeftTexture", "TopRightTexture", "BottomLeftTexture",
    "BottomRightTexture", "LeftTexture", "RightTexture", "TopTexture", "BottomTexture" }
function A:ChatGutter(state, quiet)
    for _, name in ipairs(self.chatGutterButtons) do
        local button = _G[name]
        if button and type(button.GetNormalTexture) == "function" then
            self:QuietTexture(state, button:GetNormalTexture(), quiet)
        end
    end
    for i = 1, 10 do
        for _, suffix in ipairs(self.chatButtonFrameRegions) do
            local region = _G["ChatFrame" .. i .. "ButtonFrame" .. suffix]
            if region then
                if quiet then self:HoldHidden(state, region) else self:ReleaseHidden(state, region) end
            end
        end
    end
end


























A.raidTileCap = 0.5
A.raidTileBleed = 2
function A:RaidTile(state, frame, on)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local entries = entriesFor(state, frame)
    if not on then
        self:ChromeHide(state, frame, "tile")
        if frame.background then self:ReleaseHidden(state, frame.background) end
        return
    end
    if not entries.tileL then
        for _, key in ipairs({ "tileL", "tileM", "tileR" }) do
            local t = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -8))
            entries[key] = t
        end
    end

    local look = self:LookName("tile-plain")
    if entries.tileLook ~= look then
        entries.tileLook = look
        local capU = self.raidTileCap / self.tileArts.plain.ratio
        entries.tileL:SetTexCoord(0, capU, 0, 1)
        entries.tileR:SetTexCoord(1 - capU, 1, 0, 1)
        entries.tileM:SetTexCoord(capU, 1 - capU, 0, 1)
    end
    local h = self:Number(frame.GetHeight, 1, frame) or 36
    local cap = h * self.raidTileCap
    if state.raidTileSignature == nil then state.raidTileSignature = setmetatable({}, { __mode = "k" }) end
    local signature = string.format("%.2f", cap)
    if state.raidTileSignature[frame] ~= signature then
        state.raidTileSignature[frame] = signature
        local b = self.raidTileBleed
        entries.tileL:ClearAllPoints()
        entries.tileL:SetPoint("TOPLEFT", frame, "TOPLEFT", -b, b)
        entries.tileL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -b, -b)
        entries.tileL:SetWidth(cap + b)
        entries.tileR:ClearAllPoints()
        entries.tileR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", b, b)
        entries.tileR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", b, -b)
        entries.tileR:SetWidth(cap + b)
        entries.tileM:ClearAllPoints()
        entries.tileM:SetPoint("TOPLEFT", entries.tileL, "TOPRIGHT", 0, 0)
        entries.tileM:SetPoint("BOTTOMRIGHT", entries.tileR, "BOTTOMLEFT", 0, 0)
    end
    for _, key in ipairs({ "tileL", "tileM", "tileR" }) do
        if not entries[key]:IsShown() then entries[key]:Show() end

        self:DressPaintedRegion(entries[key], "tile-plain")
    end
    if frame.background then self:HoldHidden(state, frame.background) end
    self:RaidTileFace(entries, frame, cap)
    state.count = state.count + 1
end









function A:RaidTileFace(entries, frame, cap)
    local bar = frame.healthBar
    if type(bar) ~= "table" or type(bar.CreateTexture) ~= "function" then return end
    if not entries.tileFaceLum then
        entries.tileFaceLum = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, -8))
        entries.tileFaceLum:SetBlendMode("MOD")
        entries.tileFaceLum:SetAllPoints(bar)
        for _, key in ipairs({ "tileFaceL", "tileFaceM", "tileFaceR" }) do
            entries[key] = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 6))
        end
    end
    local look = self:LookName("tile-plain-lum")
    if entries.tileFaceLook ~= look then
        entries.tileFaceLook = look
        entries.tileFaceLum:SetTexture(self.artPath .. look .. ".tga", "CLAMP", "CLAMP")
        local capU = self.raidTileCap / self.tileArts.plain.ratio
        entries.tileFaceL:SetTexCoord(0, capU, 0, 1)
        entries.tileFaceR:SetTexCoord(1 - capU, 1, 0, 1)
        entries.tileFaceM:SetTexCoord(capU, 1 - capU, 0, 1)
    end
    if entries.tileFaceSize ~= cap then
        entries.tileFaceSize = cap
        local b = self.raidTileBleed
        entries.tileFaceL:ClearAllPoints()
        entries.tileFaceL:SetPoint("TOPLEFT", frame, "TOPLEFT", -b, b)
        entries.tileFaceL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -b, -b)
        entries.tileFaceL:SetWidth(cap + b)
        entries.tileFaceR:ClearAllPoints()
        entries.tileFaceR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", b, b)
        entries.tileFaceR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", b, -b)
        entries.tileFaceR:SetWidth(cap + b)
        entries.tileFaceM:ClearAllPoints()
        entries.tileFaceM:SetPoint("TOPLEFT", entries.tileFaceL, "TOPRIGHT", 0, 0)
        entries.tileFaceM:SetPoint("BOTTOMRIGHT", entries.tileFaceR, "BOTTOMLEFT", 0, 0)
    end
    if not entries.tileFaceLum:IsShown() then entries.tileFaceLum:Show() end
    for _, key in ipairs({ "tileFaceL", "tileFaceM", "tileFaceR" }) do
        if not entries[key]:IsShown() then entries[key]:Show() end
        self:DressPaintedRegion(entries[key], "tile-plain-cap")
    end
end




function A:IsCompactUnitFrame(frame)
    return type(frame) == "table" and type(frame.healthBar) == "table" and type(frame.background) == "table"
        and type(frame.CreateTexture) == "function"
end
