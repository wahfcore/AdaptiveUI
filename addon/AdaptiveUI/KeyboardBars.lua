local _, A = ...










































































A.railArt = {
    wellF   = 166 / 224,
    wellTop = 20 / 224,
    capL    = 144 / 512,
    capR    = 48 / 512,
    capLA   = 386 / 224,
    capRA   = 96 / 224,


    seat    = 3,









    headRoom = 0.36,


    laneFloor = 16,
}














A.slab02Art = {
    wellF   = 0.72,
    wellTop = 0.14,
    capL    = 65 / 1024,
    capR    = 65 / 1024,
    capLA   = 120 / 233,
    capRA   = 120 / 233,
    bossU0  = 485 / 1024,
    bossU1  = 539 / 1024,
    bossA   = 100 / 233,
    seat    = 3,
    headRoom = 0.36,
    laneFloor = 16,
}



















A.rail03Art = {
    capL    = 100 / 2114,
    capR    = 100 / 2114,
    capLA   = 100 / 88,
    capRA   = 100 / 88,
    bossU0  = 1011 / 2114,
    bossU1  = 1104 / 2114,
    bossA   = 93 / 88,
    tipA    = 9 / 88,
    faceA   = 1914 / 88,
    ledge   = { 65 / 88, 87 / 88 },
    air     = 4,
    footAir = 8,
}



























A.bar04Art = {
    ratio   = 1950 / 143,
    seatV0  = 0.035,
    faceV0  = 0.056,
    footV0  = 0.811,
    footV1  = 0.975,
    bossU0  = 939 / 1950 - 0.004,
    bossU1  = 1001 / 1950 + 0.004,
    coverU0 = 0.4415,
    pageU   = 0.057,
    topU0   = 27 / 1024,
    topU1   = 990 / 1024,
    flatU0  = 0.09,
    flatU1  = 0.91,
    margin  = 6,
}
A.bar06Art = {
    ratio   = 2054 / 179,
    faceF   = 1630 / 2054,
    faceU0  = 210 / 2054,
    faceU1  = 1840 / 2054,
    seatV0  = 8 / 179,
    seatV1  = 149 / 179,
    rimV0   = 160 / 179,
    rimV1   = 175 / 179,
    rimU0   = 154 / 2054,
    rimU1   = 1900 / 2054,
    bossU0  = 983 / 2054,
    bossU1  = 1071 / 2054,
    coverU0 = 891 / 2054,
    coverU1 = 979 / 2054,
    pageU   = 70 / 2054,
    capL    = 210 / 2054,
    capR    = 214 / 2054,
    capA    = 210 / 179,
    bossA   = 88 / 179,
    margin  = 6,
    seatAir = 2,
    edgeBody = 0.58,
    edgeAir  = 3,
}


A.kbEmptyHotkeyAlpha = 0.45
















A.kbStyle = {
    slot = 45, small = 30, padding = 2, buttons = 12,
    barW = 454, barH = 35,
    capW = 154, capH = 95,
    laneW = 804, laneH = 11,
    hotkeyW = 32, hotkeyH = 10,
    nameW = 36, nameH = 10,
    normalW = 46, normalH = 45,
}






local BARS = {
    { key = "main", frame = "MainActionBar", prefix = "ActionButton", count = 12, head = true },
    { key = "bar2", frame = "MultiBarBottomLeft", prefix = "MultiBarBottomLeftButton", count = 12 },
    { key = "bar3", frame = "MultiBarBottomRight", prefix = "MultiBarBottomRightButton", count = 12 },
    { key = "right1", frame = "MultiBarRight", prefix = "MultiBarRightButton", count = 12, vertical = true },
    { key = "right2", frame = "MultiBarLeft", prefix = "MultiBarLeftButton", count = 12, vertical = true },
    { key = "extra1", frame = "MultiBar5", prefix = "MultiBar5Button", count = 12 },
    { key = "extra2", frame = "MultiBar6", prefix = "MultiBar6Button", count = 12 },
    { key = "extra3", frame = "MultiBar7", prefix = "MultiBar7Button", count = 12 },
    { key = "stance", frame = "StanceBar", prefix = "StanceButton", count = 10, small = true },
    { key = "pet", frame = "PetActionBar", prefix = "PetActionButton", count = 10, small = true },
    { key = "possess", frame = "PossessActionBar", prefix = "PossessButton", count = 2, small = true },
}
A.kbBars = BARS





local SLOT_CELLS = {
    bound        = { 0.00, 0.25, 0.0, 0.5 },
    empty        = { 0.25, 0.50, 0.0, 0.5 },
    pressed      = { 0.50, 0.75, 0.0, 0.5 },
    pressedEmpty = { 0.75, 1.00, 0.0, 0.5 },
    checked      = { 0.00, 0.25, 0.5, 1.0 },
    checkedEmpty = { 0.25, 0.50, 0.5, 1.0 },
    hover        = { 0.50, 0.75, 0.5, 1.0 },
    grid         = { 0.75, 1.00, 0.5, 1.0 },
}
A.kbSlotCells = SLOT_CELLS







function A:KeyboardMode()
    return self:ClickInputMode() ~= "controller"
end









function A:KeyboardSkin()
    if not (self.db and self.optionIndex and self.optionIndex.keyboardSkin) then return "classic" end
    local skin = self:GetOption("keyboardSkin")
    local slots = self.artSlots or {}










    if (skin == "bar04" or skin == "base") and slots.bar04 then return "bar04" end
    if skin == "bar04" or skin == "base" or skin == "bright" then skin = "inlay" end
    if (skin == "inlay" or skin == "edge") and slots.bar06 then return skin end
    if skin == "inlay" or skin == "edge" then skin = "footer" end
    if skin == "footer" then return slots.rail03 and "footer" or "bare" end
    if skin == "bare" then return "bare" end
    if not slots.barRail then return "classic" end
    if skin == "slab02" and slots.slab02 then return "slab02" end
    if skin == "slab02" or skin == "authored" then return "authored" end
    return "classic"
end


function A:KeyboardBase()
    if not (self.db and self.optionIndex and self.optionIndex.keyboardSkin) then return false end
    return self:GetOption("keyboardSkin") == "base" and self:KeyboardSkin() == "bar04"
end

function A:KeyboardSkinOn()
    if self:KeyboardSkin() == "classic" then return false end
    return self:KeyboardMode()
end



function A:RailArt()
    local skin = self:KeyboardSkin()
    if skin == "footer" then return A.rail03Art end
    if skin == "bar04" then return A.bar04Art end
    if skin == "inlay" or skin == "edge" then return A.bar06Art end
    return skin == "slab02" and A.slab02Art or A.railArt
end

function A:RailFile()
    local skin = self:KeyboardSkin()
    if skin == "footer" then return "rail03" end
    if skin == "bar04" then return "bar04" end
    if skin == "inlay" or skin == "edge" then return "bar06" end
    return skin == "slab02" and "slab02" or "bar-rail"
end




function A:KeyboardFloats()
    local skin = self:KeyboardSkin()
    return skin == "footer" or skin == "bare" or skin == "inlay" or skin == "edge" or skin == "bar04"
end







A.kbEmptyAlpha = { bright = 0.90, bar04 = 0.60 }
function A:KeyboardEmptyAlpha()
    if not (self.db and self.optionIndex and self.optionIndex.keyboardSkin) then return nil end
    if self:KeyboardSlotStyle() ~= "tile" then return nil end
    if self:GetOption("keyboardSkin") == "bright" and self:KeyboardSkin() == "inlay" then return A.kbEmptyAlpha.bright end
    if self:KeyboardSkin() == "bar04" then return A.kbEmptyAlpha.bar04 end
    return nil
end



function A:KeyboardSlotStyle()
    if not (self.db and self.optionIndex and self.optionIndex.keyboardSlotSkin) then return "classic" end
    local style = self:GetOption("keyboardSlotSkin")
    local slots = self.artSlots or {}
    if style == "tile" and slots.kbTile and slots.kbTileSocket and slots.kbTileFace then return "tile" end
    if style == "tile" or style == "facet" then return "facet" end
    return "classic"
end















function A:KeyboardCentreWanted()
    if not self:KeyboardSkinOn() then return false end
    return self:GetOption("keyboardCentre") == true
end







function A:KeyboardSlotOn(button)
    if not self:KeyboardSkinOn() then return false end
    if self:KeyboardSlotStyle() == "classic" then return false end
    if type(button) ~= "table" then return false end
    if button.CircleMask ~= nil and button.SquareMask ~= nil then return false end
    local name = self:Read(button.GetName, 1, button)
    if type(name) ~= "string" then return false end
    for _, def in ipairs(BARS) do
        if _G[def.frame] and name:find(def.prefix, 1, true) == 1 then
            local index = tonumber(name:sub(#def.prefix + 1))
            if index and index >= 1 and index <= def.count then

                if def.key ~= "main" and self.ExtraBarLook and self:ExtraBarLook(def.key) == "blizzard" then return false end
                return true
            end
        end
    end
    return false
end










function A:KeyboardPixel(host)
    local px = self:PhysicalPixel(host)
    if px ~= px or px <= 0.05 or px > 8 then return 1 end
    return px
end

function A:KeyboardSnap(value, px)
    value = tonumber(value) or 0
    if value == 0 then return 0 end
    if self.PixelSnapOn and not self:PixelSnapOn() then return value end
    px = tonumber(px) or 1
    if px <= 0.05 or px ~= px then return value end
    local steps = math.floor(math.abs(value) / px + 0.5)
    if steps < 1 then steps = 1 end
    return (value < 0 and -steps or steps) * px
end




local function rectOf(self, frame)
    if type(frame) ~= "table" or type(frame.GetRect) ~= "function" then return nil end
    local ok, x, y, w, h = pcall(frame.GetRect, frame)
    if not ok then return nil end
    if not (self:IsPublic(x) and self:IsPublic(y) and self:IsPublic(w) and self:IsPublic(h)) then return nil end
    if type(x) ~= "number" or type(y) ~= "number" or type(w) ~= "number" or type(h) ~= "number" then return nil end
    if x ~= x or y ~= y or w ~= w or h ~= h then return nil end
    if w <= 0 or h <= 0 then return nil end
    local scale = self:Number(frame.GetEffectiveScale, 1, frame) or 1
    if scale <= 0.05 or scale > 20 then return nil end
    return x * scale, y * scale, w * scale, h * scale
end
A.kbRectOf = rectOf









function A:KeyboardRowRect(def, alone)
    local bar = _G[def.frame]
    if type(bar) ~= "table" then return nil end
    local style = A.kbStyle
    local slot = def.small and style.small or style.slot
    local live = not self:IsCombat() and rectOf(self, bar) or nil
    if live then
        local bx, by, bw, bh = rectOf(self, bar)
        local scale = self:Number(bar.GetEffectiveScale, 1, bar) or 1
        if bx and scale > 0.05 and scale <= 20 then
            local x0, x1, y0, y1, n, slotH
            for i = 1, def.count do
                local x, y, w, h = rectOf(self, _G[def.prefix .. i])
                if x then
                    n = (n or 0) + 1
                    if not x0 or x < x0 then x0 = x end
                    if not x1 or x + w > x1 then x1 = x + w end
                    if not y0 or y < y0 then y0 = y end
                    if not y1 or y + h > y1 then y1 = y + h end
                    if not slotH or h > slotH then slotH = h end
                end
            end
            if n and n > 0 and x0 and x1 > x0 and y1 > y0 then

                local rows = math.max(1, math.floor(((y1 - y0) / scale) / math.max(1, slotH / scale) + 0.5))




                local mates = (rows == 1 and not def.vertical and not alone)
                    and self:KeyboardRowMates(def, x0, x1, y0, y1) or nil
                if mates then
                    x0, x1 = math.min(x0, mates.x0), math.max(x1, mates.x1)
                end
                local w, h = (x1 - x0) / scale, (y1 - y0) / scale
                return ((x0 + x1) / 2 - (bx + bw / 2)) / scale,
                       ((y0 + y1) / 2 - (by + bh / 2)) / scale, w, h, rows, "live", mates,
                       { x0 = x0, x1 = x1, y0 = y0, y1 = y1, scale = scale }
            end
        end
    end


    local n = def.count
    local w = n * slot + (n - 1) * style.padding
    if def.vertical then return 0, 0, slot, w, 1, "style" end
    return 0, 0, w, slot, 1, "style"
end



































A.kbBagButtons = { "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
    "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot" }







function A:KeyboardMicroNames()
    if self.microRowLifted and MicroMenu then return { "MicroMenu", "BagsBar" } end
    local menu, container = _G["MicroMenu"], _G["MicroMenuContainer"]
    if menu and container then
        local mx, my, mw, mh = rectOf(self, menu)
        local cx, cy, cw, ch = rectOf(self, container)
        if mx and cx then
            local x, y = mx + mw / 2, my + mh / 2
            if x < cx or x > cx + cw or y < cy or y > cy + ch then return { "MicroMenu", "BagsBar" } end
        end
    end
    return { "MicroMenuContainer", "BagsBar" }
end



local function microArt(name)
    local out = {}
    local frames = { _G[name] }
    if name == "MicroMenuContainer" and MicroMenu then frames[#frames + 1] = MicroMenu end
    for _, frame in ipairs(frames) do
        if type(frame) == "table" then
            for _, key in ipairs({ "BorderArt", "BackgroundArt" }) do
                if frame[key] then out[#out + 1] = frame[key] end
            end
        end
    end
    return out
end
A.KeyboardMicroArt = microArt

function A:KeyboardRowMates(def, x0, x1, y0, y1)
    if not def.head then return nil end
    local rowH = y1 - y0
    local names, mx0, mx1 = {}, x0, x1
    for _, name in ipairs(self:KeyboardMicroNames()) do
        local frame = _G[name]
        if frame and self:Read(frame.IsShown, 1, frame) == true then
            local x, y, w, h = rectOf(self, frame)
            if x then
                local overlap = math.min(y1, y + h) - math.max(y0, y)


                local gap = math.max(x - mx1, mx0 - (x + w))
                if overlap > 0.4 * math.min(rowH, h) and gap < rowH * 0.5 and gap > -w * 0.5 then
                    names[#names + 1] = name
                    mx0, mx1 = math.min(mx0, x), math.max(mx1, x + w)
                end
            end
        end
    end
    if #names == 0 then return nil end
    return { names = names, x0 = mx0, x1 = mx1 }
end








function A:KeyboardCapRoom(def, box, mates)
    local y0, y1 = box.y0, box.y1
    local band = (y1 - y0) * 0.5
    local roomL, roomR = math.huge, math.huge
    local skip = { [def.frame] = true }
    for _, name in ipairs(mates and mates.names or {}) do skip[name] = true end
    local candidates = {}
    for _, other in ipairs(BARS) do candidates[#candidates + 1] = other.frame end
    local obstacles = self:KeyboardMicroNames()
    obstacles[#obstacles + 1] = "MinimapCluster"; obstacles[#obstacles + 1] = "ObjectiveTrackerFrame"
    for _, name in ipairs(obstacles) do
        candidates[#candidates + 1] = name
    end
    for _, name in ipairs(candidates) do
        local frame = not skip[name] and _G[name] or nil
        if frame and self:Read(frame.IsShown, 1, frame) == true then
            local x, y, w, h = rectOf(self, frame)
            if x and w > 0 and h > 0 then
                local overlap = math.min(y1 + band, y + h) - math.max(y0 - band, y)
                if overlap > 0 then
                    if x + w <= box.x0 then roomL = math.min(roomL, box.x0 - (x + w))
                    elseif x >= box.x1 then roomR = math.min(roomR, x - box.x1) end
                end
            end
        end
    end
    return roomL, roomR
end





function A:FooterRailRect(def, cx, cy, rowW, rowH, rows, source, mates)
    if not def.head or def.vertical or rows ~= 1 then return nil end
    local a, px = A.rail03Art, self:KeyboardPixel(_G[def.frame])
    local body = self:KeyboardSnap(rowW / a.faceA, px)
    local cap = self:KeyboardSnap(body * a.capLA, px)
    local host = self:KeyboardSnap(body * (1 + a.tipA), px)
    local tip = host - body

    local float = self:KeyboardSnap(tip + a.air * px, px)
    local bodyTop = cy - rowH / 2 - float
    local hostCy = bodyTop + tip - host / 2
    return { rail = true, left = cap, right = cap, leftCap = "rail", rightCap = "rail",
             well = rowW, rows = rows, source = source, mates = mates and mates.names or nil,
             boss = self:KeyboardSnap(body * a.bossA, px),
             cx = cx, cy = hostCy, w = rowW + 2 * cap, h = host,
             body = body, tip = tip, float = float, rowW = rowW, rowH = rowH,
             pageY = cy - hostCy }
end







function A:InlayBarRect(def, cx, cy, rowW, rowH, rows, source, mates)
    if not def.head or def.vertical or rows ~= 1 then return nil end
    local a, px = A.bar06Art, self:KeyboardPixel(_G[def.frame])









    local byWidth = (rowW / 2 + a.margin) / math.min(0.5 - a.faceU0, a.faceU1 - 0.5)
    local byHeight = (rowH + 2 * a.seatAir) / (a.seatV1 - a.seatV0) * a.ratio
    local w = self:KeyboardSnap(math.max(byWidth, byHeight), px)
    local h = self:KeyboardSnap(w / a.ratio, px)
    local seat = (a.seatV0 + a.seatV1) / 2
    local hostCy = cy - (0.5 - seat) * h







    local drop = 0
    local lane = _G["MainStatusTrackingBarContainer"]
    local bar = _G[def.frame]
    if lane and bar and self:Read(lane.IsShown, 1, lane) == true then
        local bx, by, bw, bh = rectOf(self, bar)
        local lx, ly, lw = rectOf(self, lane)
        local bs = self:Number(bar.GetEffectiveScale, 1, bar)
        if bx and lx and bs and bs > 0.05 then
            local laneFoot = (ly - (by + bh / 2)) / bs
            local rowL = bx + bw / 2 + (cx - rowW / 2) * bs
            local over = lx < rowL + rowW * bs and lx + lw > rowL
            local top = hostCy + h / 2
            if over and laneFoot > cy and laneFoot < top then
                local room = math.max(0, (h * (a.seatV1 - a.seatV0) - rowH) / 2)
                drop = self:KeyboardSnap(math.min(top - laneFoot, room), px)
                if drop > room + 1e-9 then drop = math.max(0, drop - px) end
                hostCy = hostCy - drop
            end
        end
    end
    return { inlay = true, left = 0, right = 0, leftCap = "inlay", rightCap = "inlay", laneRail = drop > 0,
             well = rowW, rows = rows, source = source, mates = mates and mates.names or nil,
             cx = cx, cy = hostCy, w = w, h = h, rowW = rowW, rowH = rowH,
             seatTop = h * a.seatV0, seatBottom = h * a.seatV1,
             boss = 0, pageY = cy - hostCy }
end





























A.bar04Base = { baseF = 1.0, laneInset = 4, air = 6, fadeOver = 44, backPx = 2, backAlpha = 0.70, riseH = 34 }









function A:Bar04Rise(def, hostCy, h)
    if self:IsCombat() then return 0 end
    local bar = _G[def.frame]
    local _, by, _, bh = rectOf(self, bar)
    local scale = by and self:Number(bar.GetEffectiveScale, 1, bar) or nil
    if not (by and scale and scale > 0.05) then return 0 end
    local foot = by + bh / 2 + (hostCy - h / 2) * scale
    if foot >= -1e-6 then return 0 end

    local want, px = -foot / scale, self:KeyboardPixel(bar)
    if self.PixelSnapOn and not self:PixelSnapOn() then return want end
    return math.ceil(want / px - 1e-6) * px
end

function A:Bar04BaseRect(def, cx, cy, rowW, rowH, rows, source, mates)
    local a, px = A.bar04Art, self:KeyboardPixel(_G[def.frame])




    local w = self:KeyboardSnap(rowW * A.bar04Base.baseF / (a.topU1 - a.topU0), px)
    local h = self:KeyboardSnap(w / a.ratio, px)
    local air = self:KeyboardSnap(A.bar04Base.air, px)
    local hostCy = (cy - rowH / 2) - air + h * a.seatV0 - h / 2
    local rise = self:Bar04Rise(def, hostCy, h)
    hostCy = hostCy + rise


    return { bar04 = true, base = true, air = air - rise, rise = rise, left = 0, right = 0, leftCap = "base", rightCap = "base",
             well = rowW, rows = rows, source = source, mates = mates and mates.names or nil,
             cx = cx, cy = hostCy, w = w, h = h, rowW = rowW, rowH = rowH,
             boss = 0, pageY = cy - hostCy }
end

function A:Bar04Rect(def, cx, cy, rowW, rowH, rows, source, mates)
    if not def.head or def.vertical or rows ~= 1 then return nil end
    if self:KeyboardBase() then return self:Bar04BaseRect(def, cx, cy, rowW, rowH, rows, source, mates) end
    local a, px = A.bar04Art, self:KeyboardPixel(_G[def.frame])
    local byWidth = (rowW / 2 + a.margin) / (0.5 - a.flatU0)
    local byHeight = rowH / (a.footV0 - a.seatV0) * a.ratio
    local w = self:KeyboardSnap(math.max(byWidth, byHeight), px)
    local h = self:KeyboardSnap(w / a.ratio, px)
    local hostCy = cy - rowH / 2 + (a.footV0 - 0.5) * h
    local rise = self:Bar04Rise(def, hostCy, h)
    hostCy = hostCy + rise
    return { bar04 = true, rise = rise, left = 0, right = 0, leftCap = "bar04", rightCap = "bar04",
             well = rowW, rows = rows, source = source, mates = mates and mates.names or nil,
             cx = cx, cy = hostCy, w = w, h = h, rowW = rowW, rowH = rowH,
             boss = 0, pageY = cy - hostCy }
end






function A:EdgeBarRect(def, cx, cy, rowW, rowH, rows, source, mates)
    if not def.head or def.vertical or rows ~= 1 then return nil end
    local a, px = A.bar06Art, self:KeyboardPixel(_G[def.frame])
    local h = self:KeyboardSnap(rowH * a.edgeBody, px)
    local cap = self:KeyboardSnap(h * a.capA, px)
    local air = self:KeyboardSnap(a.edgeAir * px, px)
    local hostCy = cy - rowH / 2 - air - h / 2
    return { rail = true, edge = true, left = cap, right = cap, leftCap = "rail", rightCap = "rail",
             well = rowW, rows = rows, source = source, mates = mates and mates.names or nil,
             boss = self:KeyboardSnap(h * a.bossA, px),
             cx = cx, cy = hostCy, w = rowW + 2 * cap, h = h,
             body = h, tip = 0, float = air, rowW = rowW, rowH = rowH,
             pageY = cy - hostCy }
end

function A:KeyboardSlabRect(def)





    local alone = self:KeyboardFloats() and self:KeyboardBase()
    local cx, cy, rowW, rowH, rows, source, mates, box = self:KeyboardRowRect(def, alone)
    if not cx then return nil end
    if self:KeyboardFloats() then
        local skin = self:KeyboardSkin()
        if skin == "bar04" then return self:Bar04Rect(def, cx, cy, rowW, rowH, rows, source, mates) end
        if skin == "inlay" then return self:InlayBarRect(def, cx, cy, rowW, rowH, rows, source, mates) end
        if skin == "edge" then return self:EdgeBarRect(def, cx, cy, rowW, rowH, rows, source, mates) end
        if skin ~= "footer" then return nil end
        return self:FooterRailRect(def, cx, cy, rowW, rowH, rows, source, mates)
    end

    local slab02 = not def.vertical and self:KeyboardSkin() == "slab02"
    local art, px = slab02 and A.slab02Art or A.railArt, self:KeyboardPixel(_G[def.frame])
    local across = def.vertical and rowW or rowH
    local along = def.vertical and rowH or rowW
    local slab = self:KeyboardSnap((across + 2 * art.seat) / art.wellF, px)
    local well = self:KeyboardSnap(along + 2 * art.seat, px)
    local tail = self:KeyboardSnap(slab * art.capRA, px)
    local head = self:KeyboardSnap(slab * art.capLA, px)
    local mast = self:GetOption("keyboardMastHead")
    local left, right = "tail", "tail"
    if slab02 then


        left, right, head = "cap", "cap", tail
    elseif def.head and rows == 1 and not def.vertical and mast ~= "none" then



        if 2 * head <= art.headRoom * (well + 2 * head) then
            left = "head"
            right = (mast == "left") and "tail" or "head"
        end
    end




    local roomL, roomR = math.huge, math.huge
    if box and not def.vertical then
        local absL, absR = self:KeyboardCapRoom(def, box, mates)
        roomL = absL / box.scale - art.seat
        roomR = absR / box.scale - art.seat
    end
    local function fit(kind, room)
        local size = (kind == "head") and head or tail
        if size <= room then return kind, size end
        if kind == "head" and tail <= room then return "tail", tail end
        return "none", 0
    end
    local lw, rw
    left, lw = fit(left, roomL)
    right, rw = fit(right, roomR)





    local rect = { left = lw, right = rw, leftCap = left, rightCap = right,
                   well = well, rows = rows, source = source,
                   mates = mates and mates.names or nil,
                   boss = slab02 and self:KeyboardSnap(slab * art.bossA, px) or 0,
                   roomL = roomL < math.huge and roomL or nil, roomR = roomR < math.huge and roomR or nil }
    if def.vertical then

        rect.cx, rect.cy = cx, cy + (lw - rw) / 2
        rect.w, rect.h = slab, well + lw + rw
    else
        rect.cx, rect.cy = cx + (rw - lw) / 2, cy
        rect.w, rect.h = well + lw + rw, slab
    end
    return rect
end












local function book(state, object)
    state.kb = state.kb or setmetatable({}, { __mode = "k" })
    local entry = state.kb[object]
    if not entry then entry = {}; state.kb[object] = entry end
    return entry
end
A.kbBook = book





local function railHost(self, state, owner, prefix, file)
    local entries = state.decorations[owner]
    if not entries then entries = {}; state.decorations[owner] = entries end
    local data = book(state, owner)
    if entries[prefix] then return entries[prefix], entries, data end
    local ok = pcall(function()
        local host = self:Own(CreateFrame("Frame", nil, owner))


        local level = self:Number(owner.GetFrameLevel, 1, owner) or 1
        pcall(host.SetFrameLevel, host, math.max(0, level - 1))
        local art = {}


        for _, key in ipairs({ "head", "mid", "boss", "mid2", "tail" }) do

            local t = self:PaintedTexture(host, "BACKGROUND", -6, file)
            t:Hide()
            self:SyncPainted(t)
            art[key] = t



            entries[prefix .. key] = t
            entries[prefix .. key .. "Acc"] = self:PaintedTwin(t)
        end
        entries[prefix] = host
        data.art = art
    end)
    if not ok then return nil end
    return entries[prefix], entries, data
end














local function sliceU(a, which, atRight)
    local u0, u1
    if which == "head" then u0, u1 = 0, a.capL else u0, u1 = 1 - a.capR, 1 end


    if (which == "head") == (atRight == true) then return u1, u0 end
    return u0, u1
end

local function placeSlices(self, art, host, w, h, rect, vertical, file)
    local a = A.railArt
    local left, right = rect.left, rect.right


    if file then
        for _, key in ipairs({ "head", "mid", "boss", "mid2", "tail" }) do
            local entry = self.painted[art[key]]
            if entry and entry.name ~= file then self:SetPainted(art[key], file) end
        end
    end


    local function bossLayer(sub)
        art.boss:SetDrawLayer("BACKGROUND", sub)
        local entry = self.painted[art.boss]
        if entry and entry.twin then entry.twin:SetDrawLayer("BACKGROUND", sub + 1) end
    end
    if file == "bar04" and rect.bar04 then



        local b = A.bar04Art
        art.mid:ClearAllPoints()
        art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        art.mid:SetSize(w, h)
        art.mid:SetTexCoord(0, 1, 0, 1)


        local covered = not rect.base
        bossLayer(-4)
        art.boss:ClearAllPoints()
        art.boss:SetPoint("TOPLEFT", host, "TOPLEFT", w * b.bossU0, 0)
        art.boss:SetSize(math.max(1, w * (b.bossU1 - b.bossU0)), h * b.footV0)
        art.boss:SetTexCoord(b.coverU0, b.coverU0 + (b.bossU1 - b.bossU0), 0, b.footV0)
        for _, key in ipairs({ "head", "mid2", "tail" }) do
            if art[key] then self:HidePainted(art[key]) end
        end
        if not covered then self:HidePainted(art.boss) end
        for _, key in ipairs(covered and { "mid", "boss" } or { "mid" }) do
            self:PaintedAlpha(art[key], 1)
            art[key]:Show()
            self:SyncPainted(art[key])
        end
        return
    end
    if file == "bar06" and rect.inlay then






        local b = A.bar06Art
        art.mid:ClearAllPoints()
        art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        art.mid:SetSize(w, h)
        art.mid:SetTexCoord(0, 1, 0, 1)
        bossLayer(-4)
        art.boss:ClearAllPoints()
        art.boss:SetPoint("TOPLEFT", host, "TOPLEFT", w * b.bossU0, 0)
        art.boss:SetSize(math.max(1, w * (b.bossU1 - b.bossU0)), h)
        art.boss:SetTexCoord(b.coverU0, b.coverU1, 0, 1)
        for _, key in ipairs({ "head", "mid2", "tail" }) do
            if art[key] then self:HidePainted(art[key]) end
        end
        for _, key in ipairs({ "mid", "boss" }) do
            self:PaintedAlpha(art[key], 1)
            art[key]:Show()
            self:SyncPainted(art[key])
        end
        return
    end
    bossLayer(-6)
    local slab02 = file == "slab02" or file == "rail03" or file == "bar06"
    if slab02 then




        a = (file == "rail03" and A.rail03Art) or (file == "bar06" and A.bar06Art) or A.slab02Art
        local boss = rect.boss or self:KeyboardSnap(h * a.bossA, self:KeyboardPixel(host))
        local inner = math.max(2, w - left - right)
        local bossW = math.min(boss, inner)
        local midL = (inner - bossW) / 2
        art.head:ClearAllPoints()
        art.head:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        art.head:SetSize(math.max(1, left), h)
        art.head:SetTexCoord(0, a.capL, 0, 1)
        art.tail:ClearAllPoints()
        art.tail:SetPoint("TOPRIGHT", host, "TOPRIGHT", 0, 0)
        art.tail:SetSize(math.max(1, right), h)
        art.tail:SetTexCoord(1 - a.capR, 1, 0, 1)
        art.mid:ClearAllPoints()
        art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", left, 0)
        art.mid:SetSize(math.max(1, midL), h)
        art.mid:SetTexCoord(a.capL, a.bossU0, 0, 1)
        art.boss:ClearAllPoints()
        art.boss:SetPoint("TOPLEFT", host, "TOPLEFT", left + midL, 0)
        art.boss:SetSize(math.max(1, bossW), h)
        art.boss:SetTexCoord(a.bossU0, a.bossU1, 0, 1)
        art.mid2:ClearAllPoints()
        art.mid2:SetPoint("TOPLEFT", host, "TOPLEFT", left + midL + bossW, 0)
        art.mid2:SetSize(math.max(1, inner - midL - bossW), h)
        art.mid2:SetTexCoord(a.bossU1, 1 - a.capR, 0, 1)
        for _, key in ipairs({ "head", "mid", "boss", "mid2", "tail" }) do
            self:PaintedAlpha(art[key], 1)
            art[key]:Show()
        end
        if left < 1 then art.head:Hide() end
        if right < 1 then art.tail:Hide() end
        for _, key in ipairs({ "head", "mid", "boss", "mid2", "tail" }) do self:SyncPainted(art[key]) end
        return
    end
    for _, key in ipairs({ "boss", "mid2" }) do
        if art[key] then self:HidePainted(art[key]) end
    end
    if vertical then



        art.head:ClearAllPoints()
        art.head:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        art.head:SetSize(w, left)
        art.head:SetTexCoord(0, 1, 0, a.capR)
        art.tail:ClearAllPoints()
        art.tail:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
        art.tail:SetSize(w, right)
        art.tail:SetTexCoord(0, 1, 1 - a.capR, 1)
        art.mid:ClearAllPoints()
        art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -left)
        art.mid:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", 0, right)
        art.mid:SetTexCoord(0, 1, a.capR, 1 - a.capR)
    else




        local lu0, lu1 = sliceU(a, rect.leftCap == "none" and "tail" or rect.leftCap, false)
        local ru0, ru1 = sliceU(a, rect.rightCap == "none" and "tail" or rect.rightCap, true)
        art.head:ClearAllPoints()
        art.head:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
        art.head:SetSize(math.max(1, left), h)
        art.head:SetTexCoord(lu0, lu1, 0, 1)
        art.tail:ClearAllPoints()
        art.tail:SetPoint("TOPRIGHT", host, "TOPRIGHT", 0, 0)
        art.tail:SetSize(math.max(1, right), h)
        art.tail:SetTexCoord(ru0, ru1, 0, 1)
        art.mid:ClearAllPoints()
        art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", left, 0)
        art.mid:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -right, 0)
        art.mid:SetTexCoord(a.capL, 1 - a.capR, 0, 1)
    end
    for _, key in ipairs({ "head", "mid", "tail" }) do
        self:PaintedAlpha(art[key], 1)
        art[key]:Show()
    end
    if not vertical then
        if left < 1 then art.head:Hide() end
        if right < 1 then art.tail:Hide() end
    end
    for _, key in ipairs({ "head", "mid", "tail" }) do self:SyncPainted(art[key]) end
end









local function restCell(bound)
    return bound == false and "empty" or "bound"
end




local cellOf = setmetatable({}, { __mode = "k" })
local function slotCoord(texture, key)
    local c = SLOT_CELLS[key] or SLOT_CELLS.bound
    if cellOf[texture] ~= key then
        cellOf[texture] = key
        texture:SetTexCoord(c[1], c[2], c[3], c[4])
    end
end



local function floorSkin(self, floor, bound)
    local file = self:KeyboardFloorFile()
    if floor.kbFloorFile ~= file then
        floor.kbFloorFile = file
        self:SetPainted(floor, file)
        cellOf[floor] = nil
    end
    if file == "kb-tile-face" then
        slotCoord(floor, bound == false and "empty" or "bound")
    elseif cellOf[floor] ~= "whole" then
        cellOf[floor] = "whole"
        floor:SetTexCoord(0, 1, 0, 1)
    end
end






function A:KeyboardSlotFile()


    if self:KeyboardSlotStyle() == "tile" then

        if self:KeyboardEmptyAlpha() then return "kb-tile-socket" end
        return self:GetOption("keyboardEmptyStyle") == "socket" and "kb-tile-socket" or "kb-tile"
    end
    local name = self:GetOption("keyboardSlotBrass") == true and "kb-slot-brass" or "kb-slot"
    if self:GetOption("keyboardEmptyStyle") == "socket" then name = name .. "-socket" end
    return name
end



function A:KeyboardFloorFile()
    return self:KeyboardSlotStyle() == "tile" and "kb-tile-face" or "kb-floor"
end




function A:KeyboardFloorAlpha(bound)
    local raised = bound == false and self:KeyboardEmptyAlpha()
    if raised then return raised end
    if bound == false and self:GetOption("keyboardEmptyStyle") ~= "socket" then return 0.35 end
    return 1
end







function A:KeyboardSlotInset(w)
    local inset = tonumber(self:GetOption("keyboardSlotInset")) or 0.125
    if inset ~= inset or inset < 0.04 or inset > 0.2 then inset = 0.125 end
    return (tonumber(w) or A.kbStyle.slot) * inset
end
















local function microButtonSlot(self, state, button, on)
    local entries = state.decorations[button]
    if not on and not (entries and entries.kbBezel) then
        if button.Background then self:ReleaseHidden(state, button.Background) end
        if button.PushedBackground then self:ReleaseHidden(state, button.PushedBackground) end
        return false
    end
    if not entries then entries = {}; state.decorations[button] = entries end
    if on and not entries.kbBezel then
        local ok = pcall(function()
            local floor = self:PaintedTexture(button, "BACKGROUND", -2, self:KeyboardFloorFile())
            local bezel = self:PaintedTexture(button, "OVERLAY", -1, self:KeyboardSlotFile())
            entries.kbFloor, entries.kbBezel = floor, bezel
            entries.kbBezelAcc = self:PaintedTwin(bezel)
            entries.kbFloorAcc = self:PaintedTwin(floor)
        end)
        if not ok then return false end
    end
    local bezel, floor = entries.kbBezel, entries.kbFloor
    if not bezel then return false end
    if not on then
        self:HidePainted(bezel)
        if floor then self:HidePainted(floor) end
        if button.Background then self:ReleaseHidden(state, button.Background) end
        if button.PushedBackground then self:ReleaseHidden(state, button.PushedBackground) end
        return false
    end
    if button.Background then self:HoldHidden(state, button.Background) end
    if button.PushedBackground then self:HoldHidden(state, button.PushedBackground) end
    local w = self:Number(button.GetWidth, 1, button) or 32
    local signature = string.format("%.2f", w)
    if bezel.kbMicroSize ~= signature then
        bezel.kbMicroSize = signature
        for _, t in ipairs({ bezel, floor }) do
            if t then
                t:ClearAllPoints()
                t:SetPoint("CENTER", button, "CENTER", 0, 0)
                t:SetSize(w, w)
            end
        end
    end
    local file = self.artPath .. self:KeyboardSlotFile() .. ".tga"
    if bezel.kbFile ~= file then
        bezel.kbFile = file
        self:SetPainted(bezel, self:KeyboardSlotFile())
        cellOf[bezel] = nil
    end
    slotCoord(bezel, restCell(true))
    if floor then floorSkin(self, floor, true) end
    if not bezel:IsShown() then bezel:Show() end
    if floor and not floor:IsShown() then floor:Show() end
    self:SyncPainted(bezel)
    if floor then self:SyncPainted(floor) end
    return true
end
A.KeyboardMicroButtonSlot = microButtonSlot

local function keyboardSlot(self, state, button, on, bound)
    local entries = state.decorations[button]
    if not on and not (entries and entries.kbBezel) then return false end
    if not entries then entries = {}; state.decorations[button] = entries end
    if on and not entries.kbBezel then
        local ok = pcall(function()





            local floor = self:PaintedTexture(button, "BACKGROUND", -2, self:KeyboardFloorFile())
            floor:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
            floor:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

            local bezel = self:PaintedTexture(button, "ARTWORK", 2, self:KeyboardSlotFile())
            bezel:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
            bezel:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
            entries.kbFloor, entries.kbBezel = floor, bezel
            entries.kbBezelAcc = self:PaintedTwin(bezel)
            entries.kbFloorAcc = self:PaintedTwin(floor)
        end)
        if not ok then return false end
    end
    local bezel, floor = entries.kbBezel, entries.kbFloor
    if not bezel then return false end
    if not on then




        self:HidePainted(bezel)
        if floor then self:HidePainted(floor) end




        local data = book(state, button)
        if data.stateKey then
            data.stateKey = nil
            for _, setter in ipairs({ "SetPushedTexture", "SetHighlightTexture", "SetCheckedTexture" }) do
                self:ReleaseProperty(state, button, setter)
            end
        end
        return false
    end
    local file = self.artPath .. self:KeyboardSlotFile() .. ".tga"
    if bezel.kbFile ~= file then
        bezel.kbFile = file


        self:SetPainted(bezel, self:KeyboardSlotFile())
        cellOf[bezel] = nil
    end
    slotCoord(bezel, restCell(bound))
    if floor then floorSkin(self, floor, bound) end
    if not bezel:IsShown() then bezel:Show() end
    if floor and not floor:IsShown() then floor:Show() end
    self:SyncPainted(bezel)

    local ba = (bound == false and self:KeyboardEmptyAlpha()) or 1
    if bezel.kbBezelAlpha ~= ba then
        bezel.kbBezelAlpha = ba
        self:PaintedAlpha(bezel, ba)
    end
    if floor then
        self:SyncPainted(floor)
        local fa = self:KeyboardFloorAlpha(bound)
        if floor.kbFloorAlpha ~= fa then
            floor.kbFloorAlpha = fa
            self:PaintedAlpha(floor, fa)
        end
    end










    local stateFile, recoloured = self:PaintedPath(self:KeyboardSlotFile())
    local want = stateFile .. "|" .. tostring(bound == false)
    if book(state, button).stateKey ~= want then
        file = stateFile
        local setters = {
            { "SetPushedTexture", "GetPushedTexture", bound == false and "pressedEmpty" or "pressed" },
            { "SetHighlightTexture", "GetHighlightTexture", "hover" },
            { "SetCheckedTexture", "GetCheckedTexture", bound == false and "checkedEmpty" or "checked" },
        }
        local applied = true
        for _, entry in ipairs(setters) do
            local setter, getter, cell = entry[1], entry[2], entry[3]
            if type(button[setter]) == "function" and type(button[getter]) == "function" then
                if not self:CanWrite("slot", button) then applied = false; break end


                self:RememberProperty(state, button, setter, function()
                    local old = button[getter](button)
                    local atlas = old and type(old.GetAtlas) == "function" and old:GetAtlas() or nil
                    local path = old and type(old.GetTexture) == "function" and old:GetTexture() or nil
                    return function()
                        if atlas and type(old.SetAtlas) == "function" then
                            old:SetAtlas(atlas)
                            old:SetTexCoord(0, 1, 0, 1)
                        elseif path then
                            old:SetTexture(path)
                            old:SetTexCoord(0, 1, 0, 1)
                        end
                    end
                end)
                local ok = pcall(button[setter], button, file)
                if ok then
                    local region = button[getter](button)
                    if region and type(region.SetTexCoord) == "function" then
                        cellOf[region] = nil
                        slotCoord(region, cell)
                    end
                    if region and type(region.SetVertexColor) == "function" then
                        if recoloured then self:Tint(region, "material", "vertex", 1)
                        else
                            self.themed[region] = nil
                            region:SetVertexColor(1, 1, 1, 1)
                        end
                    end
                else
                    applied = false
                end
            end
        end
        if applied then book(state, button).stateKey = want end
    end
    return true
end



















local ABBREV = {
    { "^SHIFT%-", "S-" }, { "^CTRL%-", "C-" }, { "^ALT%-", "A-" },
    { "^S%-A%-", "SA-" }, { "^C%-A%-", "CA-" }, { "^S%-C%-", "SC-" },
    { "NUMPAD", "N" }, { "^MOUSEWHEELUP$", "MWU" }, { "^MOUSEWHEELDOWN$", "MWD" },
    { "^MOUSEBUTTON", "M" }, { "^BUTTON", "M" }, { "^MIDDLEMOUSE$", "M3" },
    { "^SPACE$", "SPC" }, { "^INSERT$", "INS" }, { "^DELETE$", "DEL" },
    { "^PAGEUP$", "PGU" }, { "^PAGEDOWN$", "PGD" }, { "^BACKSPACE$", "BSP" },
}




function A:KeyboardHotkeyText(text)
    if type(text) ~= "string" or text == "" then return text end
    local out = text:upper()
    for _, rule in ipairs(ABBREV) do out = out:gsub(rule[1], rule[2]) end

    for _, rule in ipairs(ABBREV) do out = out:gsub(rule[1], rule[2]) end
    if #out > 6 then out = out:sub(1, 6) end
    return out
end



function A:KeyboardHotkeyAlpha(empty)
    if empty ~= true then return 1 end
    local mode = self.optionIndex and self.optionIndex.keyboardEmptyHotkey and self:GetOption("keyboardEmptyHotkey")
    if mode == "none" then return 0 end
    if mode == "full" then return 1 end
    return A.kbEmptyHotkeyAlpha
end









A.kbHotkeyPixels = 12

function A:KeyboardType(px, host)
    local scale = 1
    if host and type(host.GetEffectiveScale) == "function" then
        local value = self:Number(host.GetEffectiveScale, 1, host)
        if type(value) == "number" and value > 0.05 and value < 20 then scale = value end
    end
    local size = (tonumber(px) or 12) * self:TextScale() / scale
    size = math.ceil(size * 2) / 2
    return math.max(8, math.min(64, size))
end






local function kbFont(self, state, region, size, flags)
    if not region or type(region.GetFont) ~= "function" then return false end
    local file, old, oldFlags = region:GetFont()
    if not (self:IsPublic(file) and self:IsPublic(old) and self:IsPublic(oldFlags)) then return false end
    if type(file) ~= "string" or type(old) ~= "number" then return false end







    state.explicitFonts = state.explicitFonts or {}
    state.explicitFonts[region] = true
    self:RememberProperty(state, region, "font", function()
        return function() region:SetFont(file, old, oldFlags or "") end
    end)
    if math.abs(old - size) < 0.01 and (oldFlags or "") == (flags or "") then return true end
    self:SetThemedFont(region, size, "numeric", flags, true)
    return true
end
A.kbFont = kbFont







local function slotType(self, state, button, on, empty)
    local entries = state.decorations[button]
    if not entries then entries = {}; state.decorations[button] = entries end
    local hot = button.HotKey or (button.TextOverlayContainer and button.TextOverlayContainer.HotKey)
    local count = button.Count or (button.TextOverlayContainer and button.TextOverlayContainer.Count)
    local abbrev = on and self:GetOption("keyboardHotkeyAbbrev") == true
    if hot then
        if abbrev then
            if not entries.kbHotkey then
                local ok = pcall(function()
                    local label = self:Own(button:CreateFontString(nil, "OVERLAY"))
                    label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -2)
                    label:SetJustifyH("RIGHT")
                    entries.kbHotkey = label
                end)
                if not ok then abbrev = false end
            end
        end
        local label = entries.kbHotkey
        local size = self:KeyboardType(A.kbHotkeyPixels, button)
        if abbrev and label then


            self:HoldHidden(state, hot)





            state.explicitFonts = state.explicitFonts or {}
            state.explicitFonts[label] = true
            if label.kbSize ~= size then
                label.kbSize = size
                self:SetThemedFont(label, size, "numeric", "OUTLINE")
            end
            local text = self:Text(hot.GetText, 1, hot)
            local short = self:KeyboardHotkeyText(text)
            if type(short) == "string" and label.kbText ~= short then
                label.kbText = short
                label:SetText(short)
            end
            if not label:IsShown() then label:Show() end


            local alpha = self:KeyboardHotkeyAlpha(empty)
            if label.kbAlpha ~= alpha then
                label.kbAlpha = alpha
                label:SetAlpha(alpha)
            end
        else
            if label and label:IsShown() then label:Hide() end
            self:ReleaseHidden(state, hot)
            if on then kbFont(self, state, hot, size, "OUTLINE") end
        end
    end
    local data = book(state, button)
    if on then
        if count then


            kbFont(self, state, count, self:PixelSize("caption", 1), "OUTLINE")
        end
        data.typed = true
    elseif data.typed then




        data.typed = nil
        local regions = {}
        if hot then regions[#regions + 1] = hot end
        if count then regions[#regions + 1] = count end
        for _, region in ipairs(regions) do
            self:ReleaseProperty(state, region, "font")
            if state.explicitFonts then state.explicitFonts[region] = nil end
        end
    end


    if on and not entries.kbPlinth then
        pcall(function()
            local plinth = self:PaintedTexture(button, "ARTWORK", 3, "kb-plinth")
            if count then plinth:SetPoint("CENTER", count, "CENTER", 0, 0) end
            entries.kbPlinth = plinth
        end)
    end
    local plinth = entries.kbPlinth
    if plinth then
        local w = self:Number(button.GetWidth, 1, button) or A.kbStyle.slot
        local pw = math.max(12, w * 0.52)
        if plinth.kbSize ~= pw then
            plinth.kbSize = pw
            plinth:SetSize(pw, pw / 2)
        end



        local text = on and count and self:Text(count.GetText, 1, count) or nil
        local want = type(text) == "string" and text ~= "" and text ~= "1"
        if plinth:IsShown() ~= want then
            if want then plinth:Show() else plinth:Hide() end
        end
        self:SyncPainted(plinth)
    end
end





local function hideRail(state, owner, prefix)
    local entries = state.decorations[owner]
    if not entries then return end
    for _, key in ipairs({ prefix, prefix .. "head", prefix .. "mid", prefix .. "boss", prefix .. "mid2", prefix .. "tail",
                           prefix .. "headAcc", prefix .. "midAcc", prefix .. "bossAcc", prefix .. "mid2Acc", prefix .. "tailAcc" }) do
        local region = entries[key]
        if region and type(region.IsShown) == "function" and region:IsShown() then region:Hide() end
    end
end


local function keyboardBar(self, state, def, on)
    local bar = _G[def.frame]
    if type(bar) ~= "table" then return false end
    if not on then
        hideRail(state, bar, "kbSlab")
        self:ReleaseHidden(state, bar.BorderArt)
        return false
    end
    local file = def.vertical and "bar-rail-v" or self:RailFile()


    if self:KeyboardFloats() then
        local rect = self:KeyboardSlabRect(def)
        if not rect then
            hideRail(state, bar, "kbSlab")
            book(state, bar).rect = nil
            book(state, bar).signature = nil
            self:HoldHidden(state, bar.BorderArt)
            return true
        end

        file = self:RailFile()
    end
    local host, _, data = railHost(self, state, bar, "kbSlab", file)
    if not host then return false end
    local rect = self:KeyboardSlabRect(def)
    if not rect then return false end



    local signature = string.format("%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%s|%s|%d|%s|%s|%s",
        rect.cx, rect.cy, rect.w, rect.h, rect.left, rect.right,
        rect.leftCap, rect.rightCap, rect.rows, tostring(def.vertical), rect.source, file)
    if data.signature ~= signature then
        data.signature = signature
        host:ClearAllPoints()
        host:SetPoint("CENTER", bar, "CENTER", rect.cx, rect.cy)
        host:SetSize(rect.w, rect.h)
        placeSlices(self, data.art, host, rect.w, rect.h, rect, def.vertical, file)
    end
    if not host:IsShown() then host:Show() end
    data.rect = rect


    self:HoldHidden(state, bar.BorderArt)
    return true
end





local function endCaps(self, state, on)
    local bar = _G["MainActionBar"]
    local caps = bar and bar.EndCaps
    if type(caps) ~= "table" then return false end
    for _, key in ipairs({ "LeftEndCap", "RightEndCap" }) do
        local cap = caps[key]
        local region = cap and (cap.Texture or cap)
        if region then
            if on then self:HoldHidden(state, region) else self:ReleaseHidden(state, region) end
        end
    end
    return true
end







function A:KeyboardDividers(on)
    local bar = _G["MainActionBar"]
    if type(bar) ~= "table" then return 0 end
    local state = self.nativeSkins and self.nativeSkins.actions
    if not state then return 0 end
    local n = 0
    for _, poolKey in ipairs({ "HorizontalDividersPool", "VerticalDividersPool" }) do
        local pool = bar[poolKey]
        if type(pool) == "table" and type(pool.EnumerateActive) == "function" then
            local ok = pcall(function()
                for divider in pool:EnumerateActive() do
                    if on then self:HoldHidden(state, divider) else self:ReleaseHidden(state, divider) end
                    n = n + 1
                end
            end)
            if not ok then return n end
        end
    end
    return n
end










A.kbPageAir = 6
function A:KeyboardPageX(rect, page)
    local pw = (page and self:Number(page.GetWidth, 1, page)) or 17
    if pw <= 0 or pw > 200 then pw = 17 end
    if rect.leftCap == "cap" then return -(rect.w / 2) + rect.left / 2 end
    if rect.leftCap == "inlay" then return -(rect.w / 2) + rect.w * A.bar06Art.pageU end
    if rect.leftCap == "bar04" then return -(rect.w / 2) + rect.w * A.bar04Art.pageU end
    if rect.leftCap == "base" then return -(rect.rowW / 2) - A.kbPageAir - pw / 2 end
    return -(rect.w / 2) + rect.left - A.kbPageAir - pw / 2
end

local function pageBlock(self, state, on)
    local bar = _G["MainActionBar"]
    local page = bar and bar.ActionBarPageNumber
    if type(page) ~= "table" then return false end
    if not on then
        local data = book(state, page)
        if data.released then return false end
        data.released = true
        self:ReleaseProperty(state, page.Text, "font")
        if state.explicitFonts then state.explicitFonts[page.Text] = nil end
        return false
    end
    book(state, page).released = nil
    if page.Text then kbFont(self, state, page.Text, self:PixelSize("caption", 1), "OUTLINE") end
    return true
end










local function statusLane(self, state, on)
    local container = _G["MainStatusTrackingBarContainer"]
    if type(container) ~= "table" then return false end
    local barFrame = container.BarFrameTexture
    local background = container.StatusBar and container.StatusBar.Background
    if not on then
        hideRail(state, container, "kbLane")
        self:ReleaseHidden(state, barFrame)
        self:ReleaseHidden(state, background)
        return false
    end





    if self:KeyboardFloats() then
        hideRail(state, container, "kbLane")
        self:HoldHidden(state, barFrame)
        self:HoldHidden(state, background)
        return true
    end


    self:HoldHidden(state, barFrame)
    self:HoldHidden(state, background)
    local host, _, data = railHost(self, state, container, "kbLane", "bar-rail")
    if not host then return false end
    local px = self:KeyboardPixel(container)
    local lane = self:Number(container.GetHeight, 1, container) or A.kbStyle.laneH
    local width = self:Number(container.GetWidth, 1, container) or A.kbStyle.laneW



    local h = math.max(A.railArt.laneFloor, self:KeyboardSnap(lane / A.railArt.wellF, px))
    local cap = self:KeyboardSnap(h * A.railArt.capRA, px)
    local signature = string.format("%.2f|%.2f|%.2f", width, h, cap)
    if data.signature ~= signature then
        data.signature = signature
        host:ClearAllPoints()
        host:SetPoint("CENTER", container, "CENTER", 0, 0)
        host:SetSize(width + 2 * cap, h)
        placeSlices(self, data.art, host, width + 2 * cap, h,
            { left = cap, right = cap, leftCap = "tail", rightCap = "tail" }, false)
    end
    if not host:IsShown() then host:Show() end
    return true
end
















































A.xpBarIndex = 4
A.xpLaneTick = 0.25
function A:XpLaneHost()
    if not (self.KeyboardSkinOn and self:KeyboardSkinOn()) then return nil end
    local skin = self:KeyboardSkin()
    if skin ~= "bar04" and skin ~= "inlay" then return nil end
    local state = self.nativeSkins and self.nativeSkins.actions
    local bar = _G["MainActionBar"]
    local rect = state and bar and book(state, bar).rect
    if not rect or not (rect.bar04 or rect.inlay) then return nil end
    local entries = state.decorations[bar]
    return entries and entries.kbSlab, rect
end


function A:BlizzardShowsXp()
    local c = _G["MainStatusTrackingBarContainer"]
    local bars = type(c) == "table" and c.bars
    local xp = type(bars) == "table" and bars[A.xpBarIndex]
    return type(xp) == "table" and type(xp.IsShown) == "function" and self:Read(xp.IsShown, 1, xp) == true or false
end

function A:XpLaneHolding()
    return self.xpLaneHeld == true
end



function A:XpLaneRect(rect)
    if rect.bar04 then
        local a = A.bar04Art
        local px = self:KeyboardPixel(_G["MainActionBar"])
        local top = self:KeyboardSnap(rect.h * a.footV0, px) + px
        local bot = self:KeyboardSnap(rect.h * a.footV1, px)


        local w = rect.rowW
        if rect.base then
            w = self:KeyboardSnap(rect.w * (a.flatU1 - a.flatU0) - 2 * A.bar04Base.laneInset, px)
        end
        return 0, top, w, math.max(px, bot - top)
    end
    local a = A.bar06Art
    return 0, rect.h * a.rimV0, rect.rowW, rect.h * (a.rimV1 - a.rimV0)
end



local function setBar(bar, lo, hi, v)
    if bar.auiMax ~= hi then bar.auiMax = hi; bar:SetMinMaxValues(lo, hi) end
    if bar.auiValue ~= v then bar.auiValue = v; bar:SetValue(v) end
end


function A:UpdateXpLane()
    local lane = self.xpLaneFrame
    if not lane or not lane:IsShown() then return end
    local xp = type(UnitXP) == "function" and UnitXP("player")
    local max = type(UnitXPMax) == "function" and UnitXPMax("player")
    if not (self:IsPublic(xp) and self:IsPublic(max) and type(max) == "number" and max > 0) then return end
    setBar(lane, 0, max, xp)
    local rested = type(GetXPExhaustion) == "function" and GetXPExhaustion() or nil
    local restedTo = xp
    if self:IsPublic(rested) and type(rested) == "number" and rested > 0 then restedTo = math.min(max, xp + rested) end
    setBar(lane.rested, 0, max, restedTo)
end

function A:TickXpLane(elapsed)
    self.xpLaneClock = (self.xpLaneClock or 0) + (tonumber(elapsed) or 0)
    if self.xpLaneClock < A.xpLaneTick then return end
    self.xpLaneClock = 0
    self:UpdateXpLane()
end

local function xpInlay(self, state, on)
    local container = _G["MainStatusTrackingBarContainer"]
    local host, rect = self:XpLaneHost()
    local want = on and host and self:XpLaneMode() == "inlay" and self:BlizzardShowsXp()
    local lane = self.xpLaneFrame
    if not want then
        if lane and lane:IsShown() then lane:Hide() end
        if self.xpLaneHeld and type(container) == "table" then self:ReleaseHidden(state, container) end
        self.xpLaneHeld = nil
        return false
    end
    if not lane or lane:GetParent() ~= host then
        local ok = pcall(function()
            lane = self:Own(CreateFrame("StatusBar", nil, host))
            lane:SetStatusBarTexture(self.artPath .. "meter.tga")
            lane.rested = self:Own(CreateFrame("StatusBar", nil, lane))
            lane.rested:SetStatusBarTexture(self.artPath .. "meter.tga")
            lane.rested:SetAllPoints(lane)
            pcall(lane.rested.SetFrameLevel, lane.rested, math.max(0, (lane:GetFrameLevel() or 1) - 1))
        end)
        if not ok then return false end
        self.xpLaneFrame = lane
        state.decorations[_G["MainActionBar"]].kbXpLane = lane
    end
    local x, y, w, h = self:XpLaneRect(rect)
    local sig = string.format("%.3f|%.3f|%.3f|%.3f", x, y, w, h)
    if lane.sig ~= sig then
        lane.sig = sig
        lane:ClearAllPoints()
        lane:SetPoint("TOP", host, "TOP", x, -y)
        lane:SetSize(w, h)
    end
    self:Tint(lane:GetStatusBarTexture(), "xp", "vertex", 0.95)
    self:Tint(lane.rested:GetStatusBarTexture(), "xpRested", "vertex", 0.6)
    if not lane:IsShown() then lane:Show() end

    if type(container) == "table" then
        self:HoldHidden(state, container)
        self.xpLaneHeld = true
    end
    self:UpdateXpLane()
    return true
end









A.kbFade = { alpha = 0.72, reach = 64, wide = 1.10 }
local function fadeBackdrop(self, state, on)
    local bar = _G["MainActionBar"]
    if type(bar) ~= "table" then return false end
    local entries = state.decorations[bar]
    local rect = book(state, bar).rect
    local host = entries and entries.kbSlab
    local want = on and host and rect and (rect.bar04 or rect.inlay)
        and self:GetOption("keyboardBackdrop") == "fade" and (self.artSlots or {}).kbFade
    local fade = entries and entries.kbFade
    if not want then
        if fade and fade:IsShown() then fade:Hide() end
        local back = entries and entries.kbBack
        if back and back:IsShown() then back:Hide() end
        local rise = entries and entries.kbRise
        if rise and rise:IsShown() then rise:Hide() end
        return false
    end
    if not fade then
        fade = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
        fade:SetTexture(self.artPath .. "kb-fade.tga", "CLAMP", "CLAMP")
        entries.kbFade = fade
    end
    local f = A.kbFade
    local sig = string.format("%.3f|%.3f|%s|%.3f|%.3f", rect.w, rect.h, tostring(rect.base), rect.rowH or 0, rect.air or 0)
    if fade.sig ~= sig then
        fade.sig = sig
        fade:ClearAllPoints()
        fade:SetPoint("BOTTOM", host, "BOTTOM", 0, 0)


        local reach = rect.base and ((rect.air or 0) + rect.rowH + A.bar04Base.fadeOver) or f.reach
        fade:SetSize(rect.w * f.wide, rect.h + reach)
    end
    self:Tint(fade, "shadow", "vertex", f.alpha)
    if not fade:IsShown() then fade:Show() end

    local back = entries.kbBack
    if rect.base then
        if not back then
            back = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -7))
            entries.kbBack = back
        end
        local b, px = A.bar04Base, self:KeyboardPixel(bar)
        local d = b.backPx * px
        local rim = rect.h * A.bar04Art.seatV0
        local bsig = string.format("%.3f|%.3f|%.3f|%.3f|%.4f|%.3f", rect.w, rect.h, rect.rowW or 0, rect.rowH or 0, d,
            rect.air or 0)
        if back.sig ~= bsig then
            back.sig = bsig
            back:ClearAllPoints()
            back:SetPoint("BOTTOM", host, "TOP", 0, -rim)
            back:SetSize((rect.rowW or rect.w) + 2 * d, (rect.air or 0) + (rect.rowH or 0) + d)
        end
        self:Tint(back, "shadow", "color", b.backAlpha)
        if not back:IsShown() then back:Show() end
        local rise = entries.kbRise
        if (self.artSlots or {}).rise then
            if not rise then
                rise = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -7))
                rise:SetTexture(self.artPath .. "rise.tga", "CLAMP", "CLAMP")
                entries.kbRise = rise
            end
            if rise.sig ~= bsig then
                rise.sig = bsig
                rise:ClearAllPoints()
                rise:SetPoint("BOTTOM", back, "TOP", 0, 0)
                rise:SetSize((rect.rowW or rect.w) + 2 * d, b.riseH)
            end
            self:Tint(rise, "shadow", "vertex", b.backAlpha)
            if not rise:IsShown() then rise:Show() end
        end
    else
        if back and back:IsShown() then back:Hide() end
        if entries.kbRise and entries.kbRise:IsShown() then entries.kbRise:Hide() end
    end
    return true
end

A.kbShelf = { air = 7, laneReach = 48, tuck = 2, hearthAir = 6, innerK = 0.2, rim = 0.32, lip = 0.80,
              band = 0.92, foot = 0.45 }
local function shelfCard(self, state, on)
    local bar = _G["MainActionBar"]
    if type(bar) ~= "table" then return false end
    local entries = state.decorations[bar]
    local data = book(state, bar)
    local rect = data.rect
    local host = entries and entries.kbSlab
    local mode = self:GetOption("keyboardBackdrop")
    local want = on and self:KeyboardSkin() == "footer" and rect and rect.rail and host
        and (mode == "shelf" or mode == "hearth")
    local card = entries and entries.kbShelf
    if not want then
        if card and card:IsShown() then card:Hide() end

        if host and card then
            local level = self:Number(bar.GetFrameLevel, 1, bar) or 1
            if self:Number(host.GetFrameLevel, 1, host) ~= math.max(0, level - 1) then
                pcall(host.SetFrameLevel, host, math.max(0, level - 1))
            end
        end
        data.shelf = nil
        return false
    end
    if not card then
        local ok = pcall(function()
            card = self:Own(CreateFrame("Frame", nil, bar))
            local level = self:Number(bar.GetFrameLevel, 1, bar) or 2
            pcall(card.SetFrameLevel, card, math.max(0, level - 2))
            local parts = {}
            for _, key in ipairs({ "main", "top", "band" }) do
                parts[key] = self:Own(card:CreateTexture(nil, "BACKGROUND", nil, -5))
            end
            for _, key in ipairs({ "cutL", "cutR", "bandL", "bandR" }) do
                local t = self:Own(card:CreateTexture(nil, "BACKGROUND", nil, -5))
                t:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
                parts[key] = t
            end



            parts.cutL:SetTexCoord(1, 0, 1, 0); parts.bandL:SetTexCoord(1, 0, 1, 0)
            parts.cutR:SetTexCoord(0, 1, 1, 0); parts.bandR:SetTexCoord(0, 1, 1, 0)
            parts.inner = self:Own(card:CreateTexture(nil, "BACKGROUND", nil, -4))
            parts.inner:SetTexture(self.artPath .. "inner-shadow.tga", "CLAMP", "CLAMP")
            parts.inner:SetTexCoord(0, 1, 1, 0)
            for _, key in ipairs({ "rimL", "rimR", "lip", "foot" }) do
                parts[key] = self:Own(card:CreateTexture(nil, "BACKGROUND", nil, -3))
            end
            card.parts = parts
            card.depth = {}
            self:Elevate(card.depth, card, "d", card, 0, 0, card, 0, 0, "base")
            entries.kbShelf = card
        end)
        if not ok or not card then return false end
    end
    local parts = card.parts






    do
        local level = self:Number(bar.GetFrameLevel, 1, bar) or 1
        local hostLevel = math.max(1, level)
        if self:Number(host.GetFrameLevel, 1, host) ~= hostLevel then pcall(host.SetFrameLevel, host, hostLevel) end
        if self:Number(card.GetFrameLevel, 1, card) ~= hostLevel - 1 then
            pcall(card.SetFrameLevel, card, hostLevel - 1)
        end
    end
    local px = self:KeyboardPixel(bar)
    local cfg = A.kbShelf


    local faceTop = -rect.tip
    local rowTop = rect.float - rect.tip + rect.rowH
    local top = rowTop + self:KeyboardSnap(cfg.air * px, px)
    local lip = "own"

    local lane = _G["MainStatusTrackingBarContainer"]
    local bx, by, bw, bh = rectOf(self, bar)
    local lx, ly, lw = rectOf(self, lane)
    local bs = self:Number(bar.GetEffectiveScale, 1, bar)
    if bx and lx and bs and bs > 0.05 and self:Read(lane.IsShown, 1, lane) == true then
        local hostTop = by + bh / 2 + (rect.cy + rect.h / 2) * bs
        local laneBottom = (ly - hostTop) / bs
        local rowL = bx + bw / 2 + (rect.cx - rect.rowW / 2) * bs
        local rowR = rowL + rect.rowW * bs
        local overlaps = lx < rowR and lx + lw > rowL
        if overlaps and laneBottom >= rowTop - 1e-6 and laneBottom <= rowTop + cfg.laneReach then
            top, lip = laneBottom, "lane"
        end
    end
    local bottom = faceTop - self:KeyboardSnap(cfg.tuck * px, px)

    local hearthTop
    if mode == "hearth" then
        local micro = _G["MicroMenu"]
        local mx, my, _, mh = rectOf(self, micro)
        if bx and mx and bs and bs > 0.05 then
            local hostTop = by + bh / 2 + (rect.cy + rect.h / 2) * bs
            local microTop = (my + mh - hostTop) / bs
            local _, gy, _, gh = rectOf(self, _G["BagsBar"])
            if gy then microTop = math.max(microTop, (gy + gh - hostTop) / bs) end
            if microTop > top then hearthTop = microTop + self:KeyboardSnap(cfg.hearthAir * px, px) end
        end
        if not hearthTop and micro then


            local mh2 = self:Number(micro.GetHeight, 1, micro) or 0
            local ms = self:Number(micro.GetEffectiveScale, 1, micro) or 0
            if mh2 > 0 and ms > 0.05 and bs and bs > 0.05 then
                hearthTop = top + (A.microRowGap or 6) * px + mh2 * ms / bs
                    + self:KeyboardSnap(cfg.hearthAir * px, px)
            end
        end
    end
    local cardTop = hearthTop or top
    local height = cardTop - bottom
    local width = rect.w
    local cut = self:KeyboardSnap(math.max(6 * px, math.min(width, height) / 12), px)
    cut = math.min(cut, height / 2)
    local signature = string.format("%.2f|%.2f|%.2f|%.2f|%.2f|%s|%s", rect.w, height, cardTop, bottom, cut, lip,
        tostring(hearthTop))
    if data.shelf ~= signature then
        data.shelf = signature
        card:ClearAllPoints()
        card:SetPoint("BOTTOMLEFT", host, "TOPLEFT", 0, bottom)
        card:SetSize(width, height)
        local function box(t, x0, y0, x1, y1)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", card, "TOPLEFT", x0, -y0)
            t:SetSize(math.max(0.01, x1 - x0), math.max(0.01, y1 - y0))
        end
        box(parts.main, 0, cut, width, height)
        box(parts.top, cut, 0, width - cut, cut)
        box(parts.cutL, 0, 0, cut, cut)
        box(parts.cutR, width - cut, 0, width, cut)


        local bandH = hearthTop and (hearthTop - top) or 0
        box(parts.band, cut, 0, width - cut, math.max(cut, bandH))
        box(parts.bandL, 0, 0, cut, cut)
        box(parts.bandR, width - cut, 0, width, cut)
        local innerTop = hearthTop and bandH or 0
        box(parts.inner, 0, innerTop, width, innerTop + math.max(4 * px, (height - innerTop) * cfg.innerK))
        box(parts.rimL, 0, cut, px, height)
        box(parts.rimR, width - px, cut, width, height)
        box(parts.lip, cut, 0, width - cut, px)
        box(parts.foot, cut, bandH - px, width - cut, bandH)
    end
    local alpha = self:Surface("base")
    self:Tint(parts.main, "nativeInk", "color", alpha)
    self:Tint(parts.top, "nativeInk", "color", alpha)
    self:Tint(parts.cutL, "nativeInk", "vertex", alpha)
    self:Tint(parts.cutR, "nativeInk", "vertex", alpha)
    self:Tint(parts.band, "inkStep", "color", alpha * cfg.band)
    self:Tint(parts.bandL, "inkStep", "vertex", alpha * cfg.band)
    self:Tint(parts.bandR, "inkStep", "vertex", alpha * cfg.band)
    self:Tint(parts.inner, "shadow", "vertex", 0.55)
    self:Tint(parts.rimL, "accent", "color", cfg.rim)
    self:Tint(parts.rimR, "accent", "color", cfg.rim)
    self:Tint(parts.lip, "accent", "color", cfg.lip)
    self:Tint(parts.foot, "accent", "color", cfg.foot)
    local hearth = hearthTop ~= nil
    for _, key in ipairs({ "band", "bandL", "bandR", "foot" }) do parts[key]:SetShown(hearth) end
    parts.lip:SetShown(lip == "own" and not hearth)
    for _, key in ipairs({ "main", "top", "cutL", "cutR", "inner", "rimL", "rimR" }) do parts[key]:Show() end
    if not card:IsShown() then card:Show() end
    data.shelfRect = { w = width, h = height, top = cardTop, bottom = bottom, lip = lip, cut = cut,
                       rowTop = rowTop, faceTop = faceTop, hearth = hearth }
    return true
end
A.kbShelfCard = shelfCard







local function microSlab(self, state, name, on, spanTo, holdArt)
    local frame = _G[name]
    if type(frame) ~= "table" then return false end





    local skinNow = on and self:KeyboardSkin()
    if skinNow == "bare" or skinNow == "inlay" or skinNow == "edge" or skinNow == "bar04" then on = false end
    if not on then
        hideRail(state, frame, "kbMicro")
        for _, art in ipairs(microArt(name)) do
            if holdArt then self:HoldHidden(state, art) else self:ReleaseHidden(state, art) end
        end
        return false
    end
    for _, art in ipairs(microArt(name)) do self:HoldHidden(state, art) end
    local file = self:RailFile()
    local host, _, data = railHost(self, state, frame, "kbMicro", file)
    if not host then return false end
    local px = self:KeyboardPixel(frame)
    local rail = self:RailArt()
    local w = self:Number(frame.GetWidth, 1, frame) or 232
    local row = self:Number(frame.GetHeight, 1, frame) or 28



    local shift = 0
    if spanTo and type(_G[spanTo]) == "table" then
        local fx, _, fw = rectOf(self, frame)
        local sx, _, sw = rectOf(self, _G[spanTo])
        local s = self:Number(frame.GetEffectiveScale, 1, frame) or 1
        local us = (UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)) or 1
        if fx and sx and s > 0.05 and us > 0.05 then
            local right = math.max(fx + fw, sx + sw)
            local wide = (right - fx) * us / s
            if wide > w then shift = (wide - w) / 2; w = wide end
        end
    end
    if file == "rail03" then


        local a = A.rail03Art
        local body = self:KeyboardSnap(w / a.faceA, px)
        local capW = self:KeyboardSnap(body * a.capLA, px)
        local hostH = self:KeyboardSnap(body * (1 + a.tipA), px)
        local tip = hostH - body
        local float = self:KeyboardSnap(tip + a.air * px, px)
        local signature = string.format("r|%.2f|%.2f|%.2f|%.2f", w, body, capW, shift)
        if data.signature ~= signature then
            data.signature = signature
            host:ClearAllPoints()
            host:SetPoint("TOP", frame, "BOTTOM", shift, -float + tip)
            host:SetSize(w + 2 * capW, hostH)
            placeSlices(self, data.art, host, w + 2 * capW, hostH,
                { left = capW, right = capW, leftCap = "rail", rightCap = "rail",
                  boss = self:KeyboardSnap(body * a.bossA, px) }, false, file)
        end
        data.rect = { w = w + 2 * capW, h = hostH, body = body, face = w }
        if not host:IsShown() then host:Show() end
        return true
    end
    local h = self:KeyboardSnap((row + 2 * rail.seat) / rail.wellF, px)
    local cap = self:KeyboardSnap(h * rail.capRA, px)
    local capKind = file == "slab02" and "cap" or "tail"
    local signature = string.format("%.2f|%.2f|%.2f|%.2f|%s", w, h, cap, shift, file)
    if data.signature ~= signature then
        data.signature = signature
        host:ClearAllPoints()
        host:SetPoint("CENTER", frame, "CENTER", shift, 0)
        host:SetSize(w + 2 * rail.seat + 2 * cap, h)
        placeSlices(self, data.art, host,
            w + 2 * rail.seat + 2 * cap, h,
            { left = cap, right = cap, leftCap = capKind, rightCap = capKind,
              boss = file == "slab02" and self:KeyboardSnap(h * rail.bossA, px) or 0 }, false, file)
    end
    if not host:IsShown() then host:Show() end
    return true
end



function A:ApplyKeyboardBars(state)
    if type(state) ~= "table" then return false end


    if self:IsCombat() then
        self.nativeDirty = true
        return false
    end
    local on = self:KeyboardSkinOn()
    local slots = on and self:KeyboardSlotStyle() ~= "classic"
    local touched = 0
    for _, def in ipairs(BARS) do



        local barOn = on and (def.key == "main" or not self.ExtraBarLook or self:ExtraBarLook(def.key) ~= "blizzard")
        local barSlots = slots and barOn
        if keyboardBar(self, state, def, barOn) then touched = touched + 1 end
        local bar = _G[def.frame]
        if bar then
            for i = 1, def.count do
                local button = _G[def.prefix .. i]
                if button then
                    local bound = true
                    if type(button.HasAction) == "function" then
                        local ok, result = pcall(button.HasAction, button)
                        if ok and type(result) == "boolean" then bound = result end
                    end



                    local empty = bound == false
                    if not self:GetOption("emptyRecede") then bound = true end
                    local wore = keyboardSlot(self, state, button, barSlots, bound)
                    slotType(self, state, button, wore, empty)




                    if wore then self:HoldHidden(state, button.Border)
                    else self:ReleaseHidden(state, button.Border) end
                    if wore then touched = touched + 1 end
                end
            end
        end
    end

    shelfCard(self, state, on)
    endCaps(self, state, on)
    self:KeyboardDividers(on)
    pageBlock(self, state, on and self:GetOption("keyboardMastHead") ~= "none")
    statusLane(self, state, on and self:GetOption("keyboardStatusLane") == true)

    xpInlay(self, state, on)
    fadeBackdrop(self, state, on)



    local micro = on and self:GetOption("keyboardMicroSlab") == true


    local holdMicroArt = on and self:KeyboardFloats()
    local mainRect = book(state, _G["MainActionBar"] or {}).rect
    local mated = {}
    for _, name in ipairs(mainRect and mainRect.mates or {}) do mated[name] = true end
    local lifted = self.microRowLifted and MicroMenu and true or false





    local bagSkin = on and self:KeyboardSlotStyle() ~= "classic"
    for _, name in ipairs(A.kbBagButtons) do
        local button = _G[name]
        if type(button) == "table" then
            local bound = true
            if name ~= "MainMenuBarBackpackButton" and type(GetInventoryItemTexture) == "function"
                and type(button.GetID) == "function" then
                local ok, id = pcall(button.GetID, button)
                if ok and type(id) == "number" then
                    local okT, tex = pcall(GetInventoryItemTexture, "player", id)
                    if okT then bound = tex ~= nil end
                end
            end
            local wore = keyboardSlot(self, state, button, bagSkin, bound)
            local normal = type(button.GetNormalTexture) == "function" and button:GetNormalTexture() or nil
            if wore then self:HoldHidden(state, normal) else self:ReleaseHidden(state, normal) end




            local icon = button.icon or _G[name .. "IconTexture"]
            if icon then
                if wore and not bound then self:HoldHidden(state, icon) else self:ReleaseHidden(state, icon) end
            end
        end
    end



    local microOn = bagSkin and self:GetOption("keyboardMicroSkin") ~= false
    if MicroMenu and type(MicroMenu.GetChildren) == "function" then
        for _, child in ipairs({ MicroMenu:GetChildren() }) do
            if type(child) == "table" and child.layoutIndex then
                microButtonSlot(self, state, child, microOn)
            end
        end
    end

    if lifted and MicroMenuContainer then hideRail(state, MicroMenuContainer, "kbMicro") end
    for _, name in ipairs(self:KeyboardMicroNames()) do
        if mated[name] and on then
            local frame = _G[name]
            if frame then
                hideRail(state, frame, "kbMicro")
                for _, art in ipairs(microArt(name)) do self:HoldHidden(state, art) end
            end
        elseif lifted and name == "BagsBar" then

            local frame = _G[name]
            if frame then
                hideRail(state, frame, "kbMicro")
                for _, art in ipairs(microArt(name)) do
                    if micro or holdMicroArt then self:HoldHidden(state, art) else self:ReleaseHidden(state, art) end
                end
            end
        else
            microSlab(self, state, name, micro, (lifted and name == "MicroMenu") and "BagsBar" or nil, holdMicroArt)
        end
    end
    state.count = (state.count or 0) + touched
    self.keyboardBarsActive = on
    return on
end








function A:KeyboardBoxes()
    local boxes = {}
    local us = (UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)) or 1
    if us <= 0.05 then return boxes end
    local state = self.nativeSkins and self.nativeSkins.actions
    local function push(id, kind, x, y, w, h)
        boxes[#boxes + 1] = { id = id, kind = kind, l = x / us, b = y / us, r = (x + w) / us, t = (y + h) / us }
    end
    local mated = {}
    for _, def in ipairs(BARS) do
        local bar = _G[def.frame]
        if bar and self:Read(bar.IsShown, 1, bar) == true then
            local x, y, w, h = rectOf(self, bar)
            if x then
                local rect = state and self.keyboardBarsActive and book(state, bar).rect or nil
                if rect then
                    local scale = self:Number(bar.GetEffectiveScale, 1, bar) or 1
                    local cx, cy = x + w / 2 + rect.cx * scale, y + h / 2 + rect.cy * scale
                    local sw, sh = rect.w * scale, rect.h * scale
                    push(def.frame, "bar", cx - sw / 2, cy - sh / 2, sw, sh)
                    for _, name in ipairs(rect.mates or {}) do mated[name] = true end
                else
                    push(def.frame, "bar", x, y, w, h)
                end
            end
        end
    end
    for _, name in ipairs(self:KeyboardMicroNames()) do
        local frame = not mated[name] and _G[name] or nil
        if frame and self:Read(frame.IsShown, 1, frame) == true then
            local x, y, w, h = rectOf(self, frame)
            if x then push(name, name == "BagsBar" and "bags" or "micro", x, y, w, h) end
        end
    end
    for _, name in ipairs(A.statusLaneFrames) do
        local frame = _G[name]
        if frame and self:Read(frame.IsShown, 1, frame) == true then
            local x, y, w, h = rectOf(self, frame)
            if x then push(name, "lane", x, y, w, h) end
        end
    end
    return boxes
end

























local HOOKS = {
    { "ActionBarMixin", "UpdateGridLayout", "dirty" },
    { "ActionBarMixin", "UpdateShownButtons", "dirty" },
    { "EditModeActionBarMixin", "UpdateVisibility", "dirty" },
    { "MainActionBarMixin", "EditModeSetScale", "dirty" },
    { "MainActionBarMixin", "UpdateEndCaps", "caps" },
    { "MainActionBarMixin", "UpdateDividers", "dividers" },
    { "MainMenuBarEndCapMixin", "UpdateVisibility", "caps" },
}
A.kbHookSpec = HOOKS

local function hookBody(kind)
    if kind == "caps" then
        return function()
            A.nativeDirty = true
            if A.keyboardBarsActive and not A:IsCombat() then
                local state = A.nativeSkins and A.nativeSkins.actions
                if state then pcall(endCaps, A, state, true) end
            end
        end
    end
    if kind == "dividers" then
        return function()
            A.nativeDirty = true
            if A.keyboardBarsActive and not A:IsCombat() then
                pcall(A.KeyboardDividers, A, true)
            end
        end
    end
    return function() A.nativeDirty = true end
end

function A:ObserveKeyboardBars()
    if type(hooksecurefunc) ~= "function" then return end
    self.layoutHooks = self.layoutHooks or {}
    self.kbHooks = self.kbHooks or {}
    for _, spec in ipairs(HOOKS) do
        local name, method, kind = spec[1], spec[2], spec[3]
        local mixin = _G[name]
        local id = name .. "." .. method
        if type(mixin) == "table" and not self.layoutHooks[id] and type(mixin[method]) == "function" then
            local ok = pcall(hooksecurefunc, mixin, method, hookBody(kind))
            if ok then
                self.layoutHooks[id] = true
                self.kbHooks[id] = name
            end
        end
    end
end








function A:KeyboardReport(emit)
    emit(string.format("keyboard bars: %s | skin %s | mast head %s | centre %s | mode %s",
        self.keyboardBarsActive and "on" or "off",
        tostring(self.db and self:GetOption("keyboardSkin")),
        tostring(self.db and self:GetOption("keyboardMastHead")),
        tostring(self.db and self:GetOption("keyboardCentre")),
        self:ClickInputMode()))




    if self.InputDecisionLine then emit("  " .. self:InputDecisionLine()) end
    for _, def in ipairs(BARS) do
        local bar = _G[def.frame]
        if bar then
            local x, y, w, h = rectOf(self, bar)
            local r = self:KeyboardSlabRect(def)




            local owner = self.EditModeOwnsPosition and (self:EditModeOwnsPosition(bar) and "editmode" or "mover") or "?"
            emit(string.format("  %s: rect %s | slab %s | placed by %s%s%s",
                def.frame,
                x and string.format("%.0f,%.0f %.0fx%.0f", x, y, w, h) or "(no rect)",
                r and string.format("%.0f,%.0f %.0fx%.0f caps %s %.0f / %s %.0f rows %d (%s)%s",
                    r.cx, r.cy, r.w, r.h, r.leftCap, r.left, r.rightCap, r.right,
                    r.rows, r.source, (r.rise or 0) > 0 and string.format(" risen %.0f", r.rise) or "") or "(none)",
                owner,
                (r and r.mates) and (" | row mates " .. table.concat(r.mates, "+")) or "",
                r and string.format(" | cap room %s / %s",
                    r.roomL and string.format("%.0f", r.roomL) or "open",
                    r.roomR and string.format("%.0f", r.roomR) or "open") or ""))
        end
    end
    local reported = self:KeyboardMicroNames()
    reported[#reported + 1] = "MainStatusTrackingBarContainer"
    for _, name in ipairs(reported) do
        local frame = _G[name]
        if frame then
            local x, y, w, h = rectOf(self, frame)
            emit(string.format("  %s: %s | placed by %s", name,
                x and string.format("%.0f,%.0f %.0fx%.0f", x, y, w, h) or "(no rect)",
                self.EditModeOwnsPosition and (self:EditModeOwnsPosition(frame) and "editmode" or "mover") or "?"))
        end
    end
    local caps = _G["MainActionBar"] and _G["MainActionBar"].EndCaps
    for _, key in ipairs({ "LeftEndCap", "RightEndCap" }) do
        local cap = caps and caps[key]
        if cap then
            local x, y, w, h = rectOf(self, cap)
            emit(string.format("  %s: %s", key,
                x and string.format("%.0f,%.0f %.0fx%.0f", x, y, w, h) or "(no rect)"))
        end
    end
end
