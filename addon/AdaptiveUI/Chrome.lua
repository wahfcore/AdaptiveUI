local _, A = ...

























A.chromeArt = {
    map = { file = "map-bg", slot = "mapBg", ratio = 0.78866,
            face = { 0.06336, 0.05064, 0.93664, 0.97367 },
            diamond = { 0.46661, 0.87576, 0.53339, 0.92978 } },
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

local function authored(self)
    return opt(self, "chromeSkin", "authored") == "authored"
end




function A:MapSkinMode()
    if not authored(self) then return "card" end
    local skin = opt(self, "mapSkin", "painted")
    if (skin == "base" or skin == "plaque" or skin == "foot") and self:HasArt("mapMin") then return skin end
    if skin == "base" or skin == "plaque" or skin == "foot" then skin = "painted" end
    if skin == "painted" and self:HasArt("mapBg") then return "painted" end
    return "card"
end


function A:MapPainted()
    return self:MapSkinMode() ~= "card"
end



function A:MapOnPlaque()
    local mode = self:MapSkinMode()
    return mode == "base" or mode == "plaque" or mode == "foot"
end



function A:WindowSkinMode()
    local skin = opt(self, "windowSkin", "painted")
    if skin == "ledge" and self:HasArt("bar04") then return "ledge" end
    if skin == "painted" and self:HasArt("optionsBg") then return "painted" end
    return "flat"
end

function A:WindowPainted()
    return self:WindowSkinMode() == "painted"
end


function A:TrackerStyle()
    if not authored(self) then return "boxed" end
    return opt(self, "trackerStyle", "tidy")
end

function A:ChatStyle()
    if not authored(self) then return "boxed" end
    return opt(self, "chatStyle", "tidy")
end

function A:RaidTileOn()
    return opt(self, "raidSkin", "tile") == "tile" and self:HasArt("tilePlain")
end




function A:SmallTile(id)
    local variant = id and self.tileFor[id]
    if not variant then return nil end
    if opt(self, "plateSmallSkin", "inlay") ~= "tile" then return nil end
    if not (self.BarSkinOn and self:BarSkinOn()) then return nil end
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








A.mapCardPad, A.mapCardZone = 4, 26
















A.mapPlaqueArt = { ratio = 2071 / 553, upperV1 = 0.495, lowerV0 = 0.573, lowerV1 = 0.953, rakeU = 0.76,
                   diamondU = 0.863 }
A.mapPlaque = { lip = 24, overlap = 8, fadePad = 18, fadeAlpha = 0.85, textX = 22, floorPx = 14 }


























A.mapBase = { lip = 10, rimV = 1 / 256, railU = 0.075, clockU = 0.80, clockW = 52, zonePx = 12, subPx = 6.5,
              inset = 4, haloAlpha = 0.70, haloInner = 0.70, edgeAlpha = 0.55, backPx = 2, backAlpha = 0.85, haloTopF = 1.0,
              riseK = 1.8, riseAlpha = 0.60, haloSpan = "map", zoneX = 6 }











function A:MapPlaqueGeometry(mapW, mapH)
    local mode = self:MapSkinMode()
    local p, art = self.mapPlaque, self.mapPlaqueArt
    if mode == "base" then
        local b = self.mapBase
        local w = mapW + 2 * b.lip
        local h = w / art.ratio
        local overlap = h * b.rimV
        local function y(v) return overlap - v * h end
        local textX = b.railU * w - b.lip
        local clockR = b.clockU * w - b.lip
        return { plaque = true, base = true, mode = mode, w = w, h = h, lip = b.lip, overlap = overlap,
                 left = b.lip, right = b.lip, top = 0, bottom = h - overlap, mapW = mapW, mapH = mapH,
                 zoneY = y((0.05 + art.upperV1) / 2), coordY = y((art.lowerV0 + art.lowerV1) / 2),
                 zoneH = (art.upperV1 - 0.05) * h, coordH = (art.lowerV1 - art.lowerV0) * h,
                 textX = textX, textW = (art.rakeU - b.railU) * w,
                 coordW = clockR - b.clockW - textX, clockR = clockR,
                 diamondX = art.diamondU * w - b.lip, diamondY = y(0.50), diamondR = 0.025 * w }
    end
    local lip = mode == "plaque" and p.lip or 0
    local overlap = mode == "plaque" and p.overlap or 0
    local w = mapW + 2 * lip
    local h = w / art.ratio


    local upperTop, upperBot = 0, -(h * art.upperV1 - overlap)
    local lowerTop, lowerBot = -(h * art.lowerV0 - overlap), -(h * art.lowerV1 - overlap)
    return { plaque = true, mode = mode, w = w, h = h, lip = lip, overlap = overlap,
             left = lip, right = lip, top = 0, bottom = h - overlap, mapW = mapW, mapH = mapH,
             zoneY = (upperTop + upperBot) / 2, coordY = (lowerTop + lowerBot) / 2,
             zoneH = upperTop - upperBot, coordH = lowerTop - lowerBot,

             textX = p.textX - lip, textW = w * art.rakeU - p.textX }
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
    if mode == "base" then return clusterTextSize(self, self.mapBase.zonePx) end
    if mode ~= "plaque" and mode ~= "foot" then return nil end
    return clusterTextSize(self, self.mapPlaque.floorPx)
end



function A:MapPlaqueSubSize()
    if self:MapSkinMode() ~= "base" then return nil end
    return clusterTextSize(self, self.mapBase.subPx)
end

function A:MapCardGeometry(mapW, mapH)
    if self.MapOnPlaque and self:MapOnPlaque() then
        return self:MapPlaqueGeometry(mapW, mapH)
    end
    local art = self.chromeArt.map
    local f = art.face
    local w = (mapW + 2 * self.mapCardPad) / (f[3] - f[1])
    local h = w / art.ratio
    local left = self.mapCardPad + w * f[1]
    local top = self.mapCardZone + h * f[2]
    return { w = w, h = h, left = left, top = top, right = w - left - mapW, bottom = h - top - mapH }
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
    local halo, edge = entries.mapHalo, entries.mapEdge
    if want and slots.mapHalo then
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
        local sig = string.format("%.3f|%.3f|%.3f|%.3f|%.3f", padX, padY, padTop, lip, g.bottom)
        if halo.auiSig ~= sig then
            halo.auiSig = sig
            halo:ClearAllPoints()
            halo:SetPoint("TOPLEFT", map, "TOPLEFT", -(lip + padX), padTop)
            halo:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", lip + padX, -(g.bottom + padY))
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
        local d = b.backPx * self:PhysicalPixel(cluster)
        local sig = string.format("%.4f", d)
        if back.auiSig ~= sig then
            back.auiSig = sig
            back:ClearAllPoints()
            back:SetPoint("TOPLEFT", map, "TOPLEFT", -d, d)
            back:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", d, 0)
        end
        self:Tint(back, "shadow", "color", b.backAlpha)
        if not back:IsShown() then back:Show() end




        local rise = entries.mapRise


        if slots.riseWide then
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
    if want and slots.mapEdge then
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
        if entries.mapFade and entries.mapFade:IsShown() then entries.mapFade:Hide() end
        self:MapBaseFade(state, cluster, map, nil)
        return
    end


    local file = self:MapSkinMode() == "painted" and self.chromeArt.map.file or "map-min"
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
    if not entries.paint:IsShown() then entries.paint:Show() end
    self:SyncPainted(entries.paint)


    self:MapBaseFade(state, cluster, map, g)
    if g.plaque and not g.base and (self.artSlots or {}).mapFade then
        if not entries.mapFade then
            entries.mapFade = self:Own(cluster:CreateTexture(nil, "BACKGROUND", nil, -8))
            entries.mapFade:SetTexture(self.artPath .. "map-fade.tga", "CLAMP", "CLAMP")
        end
        local pad = self.mapPlaque.fadePad
        if entries.mapFade.auiPad ~= pad then
            entries.mapFade.auiPad = pad
            entries.mapFade:ClearAllPoints()
            entries.mapFade:SetPoint("TOPLEFT", map, "TOPLEFT", -pad, pad)
            entries.mapFade:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", pad, -pad)
        end
        local fr, fg, fb = self:Color("shadow")
        local cr, cg, cb, ca = entries.mapFade:GetVertexColor()
        local fa = self.mapPlaque.fadeAlpha
        if math.abs(cr - fr) > 1e-4 or math.abs(cg - fg) > 1e-4 or math.abs(cb - fb) > 1e-4 or math.abs(ca - fa) > 1e-4 then
            self:Tint(entries.mapFade, "shadow", "vertex", fa)
        end
        if not entries.mapFade:IsShown() then entries.mapFade:Show() end
    elseif entries.mapFade and entries.mapFade:IsShown() then
        entries.mapFade:Hide()
    end

    self:ChromeHide(state, cluster, "card", "rim")
    if self.SuppressDepth then self:SuppressDepth(entries, "card~", true) end
    self:HideChromeRim(state, cluster, "rim")
    self:ChromeHide(state, MinimapBackdrop or map, "border")
    state.count = state.count + 1
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











A.windowLedge = { faceMid = (0.056 + 0.811) / 2, top = 590, legendX = 64, legendW = 400,
                  resetX = 540, closeX = 808 }
function A:WindowLedgeGeometry(w)
    local a = A.bar04Art or { ratio = 1950 / 143 }
    local h = w / a.ratio
    local l = self.windowLedge
    return { w = w, h = h, top = l.top, mid = l.top + h * l.faceMid }
end

local function placeFooter(self, frame, ledge, g)
    local f = frame.auiFooter
    if not f then return end
    local l = self.windowLedge
    for key, b in pairs({ close = f.close, reset = f.reset }) do
        if b then
            local x = ledge and (key == "close" and l.closeX or l.resetX) or f.home[key][1]
            local h = self:Number(b.GetHeight, 1, b) or 28
            local y = ledge and -(g.mid - h / 2) or f.home[key][2]
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)

            if b.bg then b.bg:SetShown(not ledge) end
        end
    end
    if f.legend then
        f.legend:ClearAllPoints()

        self:SetThemedFont(f.legend, self.tokens.type.body, false)
        if ledge then
            f.legend:SetPoint("LEFT", frame, "TOPLEFT", l.legendX, -g.mid)
            f.legend:SetWidth(l.legendW)
        else
            f.legend:SetPoint("TOPLEFT", frame, "TOPLEFT", f.home.legend[1], f.home.legend[2])
            f.legend:SetWidth(f.home.legend[3])
        end
    end
end

function A:DressOptionsWindow(frame)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local mode = self:WindowSkinMode()
    local painted, ledge = mode == "painted", mode == "ledge"

    if not frame.auiPaint then
        frame.auiPaint = self:PaintedTexture(frame, "BACKGROUND", -8, self.chromeArt.options.file)
        frame.auiPaintAcc = self:PaintedTwin(frame.auiPaint)
    end
    if not frame.auiLedge then
        frame.auiLedge = self:PaintedTexture(frame, "BORDER", -4, "bar04")
        frame.auiLedgeAcc = self:PaintedTwin(frame.auiLedge)
    end
    if frame.auiPainted == mode then
        self:SyncPainted(frame.auiPaint)
        self:SyncPainted(frame.auiLedge)

        if frame.auiFooter and frame.auiFooterMode ~= mode then
            frame.auiFooterMode = mode
            placeFooter(self, frame, mode == "ledge", self:WindowLedgeGeometry(self:Number(frame.GetWidth, 1, frame) or 1000))
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
    local lg = self:WindowLedgeGeometry(w)
    frame.auiLedge:ClearAllPoints()
    frame.auiLedge:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -lg.top)
    frame.auiLedge:SetSize(lg.w, lg.h)
    if ledge then frame.auiLedge:Show() else self:HidePainted(frame.auiLedge) end
    self:SyncPainted(frame.auiLedge)
    placeFooter(self, frame, ledge, lg)
    if frame.auiFooter then frame.auiFooterMode = mode end
    if frame.bg then
        frame.bg:SetShown(not painted)

        frame.bg:ClearAllPoints()
        frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.bg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, ledge and -(lg.top + lg.h * 0.3) or -h)
    end
    if frame.rule then frame.rule:SetShown(not painted) end
    if frame.depth and self.SuppressDepth then self:SuppressDepth(frame.depth, "d", painted or ledge) end
    if type(frame.SetClampRectInsets) == "function" then
        if painted then frame:SetClampRectInsets(-g.side, g.side, g.top, -g.bottom)
        elseif ledge then frame:SetClampRectInsets(0, 0, 0, -math.max(0, lg.top + lg.h - h))
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





function A:ChatEditDress(state, edit, index, boxed)
    local entries = state.decorations[edit]
    if boxed then
        if entries then self:SuppressDepth(entries, "panel~", false) end
        return
    end
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
    if not state or self:IsCombat() or self:ChatStyle() == "boxed" then return end
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
            t:SetTexture(self.artPath .. "tile-plain.tga", "CLAMP", "CLAMP")
            entries[key] = t
        end
        local art = self.tileArts.plain
        local capU = self.raidTileCap / art.ratio
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
        entries.tileFaceLum:SetTexture(self.artPath .. "tile-plain-lum.tga", "CLAMP", "CLAMP")
        entries.tileFaceLum:SetAllPoints(bar)
        local art = self.tileArts.plain
        local capU = self.raidTileCap / art.ratio
        for _, key in ipairs({ "tileFaceL", "tileFaceM", "tileFaceR" }) do
            entries[key] = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 6))
        end
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
