local _, A = ...










































































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
    if self:GetOption("keyboardSkin") == "base" and (self.artSlots or {}).bar04 then return "bar04" end
    return "classic"
end


function A:KeyboardBase()
    return self:KeyboardSkin() == "bar04"
end

function A:KeyboardSkinOn()
    if self:KeyboardSkin() == "classic" then return false end
    return self:KeyboardMode()
end





A.kbEmptyAlpha = { bar04 = 0.60 }
function A:KeyboardEmptyAlpha()
    if self:KeyboardSlotStyle() ~= "tile" then return nil end
    if self:KeyboardSkin() == "bar04" then return A.kbEmptyAlpha.bar04 end
    return nil
end



function A:KeyboardSlotStyle()
    if not (self.db and self.optionIndex and self.optionIndex.keyboardSlotSkin) then return "classic" end
    local style = self:GetOption("keyboardSlotSkin")
    local slots = self.artSlots or {}
    if style == "tile" and slots.kbTileSocket and slots.kbTileFace then return "tile" end
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









function A:KeyboardRowRect(def)
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


                local w, h = (x1 - x0) / scale, (y1 - y0) / scale
                return ((x0 + x1) / 2 - (bx + bw / 2)) / scale,
                       ((y0 + y1) / 2 - (by + bh / 2)) / scale, w, h, rows, "live"
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

function A:Bar04BaseRect(def, cx, cy, rowW, rowH, rows, source)
    local a, px = A.bar04Art, self:KeyboardPixel(_G[def.frame])




    local w = self:KeyboardSnap(rowW * A.bar04Base.baseF / (a.topU1 - a.topU0), px)
    local h = self:KeyboardSnap(w / a.ratio, px)
    local air = self:KeyboardSnap(A.bar04Base.air, px)
    local hostCy = (cy - rowH / 2) - air + h * a.seatV0 - h / 2
    local rise = self:Bar04Rise(def, hostCy, h)
    hostCy = hostCy + rise


    return { bar04 = true, base = true, air = air - rise, rise = rise, left = 0, right = 0, leftCap = "base", rightCap = "base",
             well = rowW, rows = rows, source = source,
             cx = cx, cy = hostCy, w = w, h = h, rowW = rowW, rowH = rowH,
             boss = 0, pageY = cy - hostCy }
end





function A:KeyboardSlabRect(def)
    if not def.head or def.vertical then return nil end
    local cx, cy, rowW, rowH, rows, source = self:KeyboardRowRect(def)
    if not cx or rows ~= 1 then return nil end
    return self:Bar04BaseRect(def, cx, cy, rowW, rowH, rows, source)
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


        for _, key in ipairs({ "mid" }) do

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




local function placeSlices(self, art, host, w, h)
    art.mid:ClearAllPoints()
    art.mid:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
    art.mid:SetSize(w, h)
    art.mid:SetTexCoord(0, 1, 0, 1)
    self:PaintedAlpha(art.mid, 1)
    art.mid:Show()
    self:SyncPainted(art.mid)
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
    return "kb-tile-socket"
end

function A:KeyboardFloorFile()
    return "kb-tile-face"
end



function A:KeyboardFloorAlpha(bound)
    local raised = bound == false and self:KeyboardEmptyAlpha()
    if raised then return raised end
    if bound == false then return 0.35 end
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









A.kbRangeIndicator = "\226\151\143"
function A:KeyboardUnbound(text)
    if type(text) ~= "string" or text == "" then return true end
    local dot = type(RANGE_INDICATOR) == "string" and RANGE_INDICATOR or A.kbRangeIndicator
    return text == dot or text == A.kbRangeIndicator
end





function A:KeyboardDrawable(text)
    if type(text) ~= "string" then return false end
    local i, n = 1, #text
    while i <= n do
        local b = text:byte(i)
        if b >= 0x20 and b <= 0x7E then
            i = i + 1
        elseif (b == 0xC2 or b == 0xC3) and i < n then
            local c = text:byte(i + 1)
            if b == 0xC2 and (c < 0xA0 or c > 0xBF) then return false end
            if b == 0xC3 and (c < 0x80 or c > 0xBF) then return false end
            i = i + 2
        else
            return false
        end
    end
    return true
end



local function utf8Head(text, limit)
    local i, n, count = 1, #text, 0
    while i <= n do
        if count == limit then return text:sub(1, i - 1) end
        local b = text:byte(i)
        local len = (b >= 0xF0 and 4) or (b >= 0xE0 and 3) or (b >= 0xC0 and 2) or 1
        i = i + len
        count = count + 1
    end
    return text
end

function A:KeyboardHotkeyText(text)
    if type(text) ~= "string" or text == "" then return text end
    if self:KeyboardUnbound(text) then return "" end


    local out = text:gsub("[a-z]", string.upper)
    for _, rule in ipairs(ABBREV) do out = out:gsub(rule[1], rule[2]) end

    for _, rule in ipairs(ABBREV) do out = out:gsub(rule[1], rule[2]) end
    return utf8Head(out, 6)
end


function A:KeyboardClientFace()
    local object = _G.NumberFontNormal
    if type(object) == "table" and type(object.GetFont) == "function" then
        local ok, file = pcall(object.GetFont, object)
        if ok and self:IsPublic(file) and type(file) == "string" and file ~= "" then return file end
    end
    return STANDARD_TEXT_FONT or self.fallbackFont
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
            local text = self:Text(hot.GetText, 1, hot)
            local short = self:KeyboardHotkeyText(text)

            local face = (type(short) ~= "string" or self:KeyboardDrawable(short)) and "ours" or "client"
            if label.kbSize ~= size or label.kbFace ~= face then
                label.kbSize, label.kbFace = size, face
                if face == "ours" then
                    self:SetThemedFont(label, size, "numeric", "OUTLINE")
                else
                    pcall(label.SetFont, label, self:KeyboardClientFace(), size, "OUTLINE")
                end
            end
            if type(short) == "string" and label.kbText ~= short then
                label.kbText = short
                label:SetText(short)
            end

            local bound = label.kbText ~= nil and label.kbText ~= ""
            if bound ~= (label:IsShown() == true) then
                if bound then label:Show() else label:Hide() end
            end


            local alpha = self:KeyboardHotkeyAlpha(empty)
            if label.kbAlpha ~= alpha then
                label.kbAlpha = alpha
                label:SetAlpha(alpha)
            end
        else
            if label and label:IsShown() then label:Hide() end


            local text = on and self:Text(hot.GetText, 1, hot) or nil
            if on and type(text) == "string" and self:KeyboardUnbound(text) then
                self:HoldHidden(state, hot)
            else
                self:ReleaseHidden(state, hot)
            end
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
    for _, key in ipairs({ prefix, prefix .. "mid", prefix .. "midAcc" }) do
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


    local file = "bar04"
    local rect = self:KeyboardSlabRect(def)
    if not rect then
        hideRail(state, bar, "kbSlab")
        book(state, bar).rect = nil
        book(state, bar).signature = nil
        self:HoldHidden(state, bar.BorderArt)
        return true
    end
    local host, _, data = railHost(self, state, bar, "kbSlab", file)
    if not host then return false end



    local signature = string.format("%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%s|%s|%d|%s|%s|%s",
        rect.cx, rect.cy, rect.w, rect.h, rect.left, rect.right,
        rect.leftCap, rect.rightCap, rect.rows, tostring(def.vertical), rect.source, file)
    if data.signature ~= signature then
        data.signature = signature
        host:ClearAllPoints()
        host:SetPoint("CENTER", bar, "CENTER", rect.cx, rect.cy)
        host:SetSize(rect.w, rect.h)
        placeSlices(self, data.art, host, rect.w, rect.h)
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
        self:ReleaseHidden(state, barFrame)
        self:ReleaseHidden(state, background)
        return false
    end


    self:HoldHidden(state, barFrame)
    self:HoldHidden(state, background)
    return true
end

















A.xpBarIndex = 4
A.xpLaneTick = 0.25
function A:XpLaneHost()
    if not (self.KeyboardSkinOn and self:KeyboardSkinOn()) then return nil end
    if self:KeyboardSkin() ~= "bar04" then return nil end
    local state = self.nativeSkins and self.nativeSkins.actions
    local bar = _G["MainActionBar"]
    local rect = state and bar and book(state, bar).rect
    if not rect or not rect.bar04 then return nil end
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











A.kbXpTop = { gap = 1, height = 4, trough = 0.35, fill = 0.85, rested = 0.55 }
function A:XpLaneRect(rect)
    if rect.bar04 and A.bar04Art.laneTop then
        local px = self:KeyboardPixel(_G["MainActionBar"])
        local t = A.kbXpTop
        local h = t.height * px


        local rowTop = rect.h / 2 - (rect.pageY or 0) - (rect.rowH or 0) / 2
        return 0, rowTop - t.gap * px - h, rect.rowW, h
    end


    local a = A.bar04Art
    local px = self:KeyboardPixel(_G["MainActionBar"])
    local top = self:KeyboardSnap(rect.h * a.footV0, px) + px
    local bot = self:KeyboardSnap(rect.h * a.footV1, px)
    local w = self:KeyboardSnap(rect.w * (a.flatU1 - a.flatU0) - 2 * A.bar04Base.laneInset, px)
    return 0, top, w, math.max(px, bot - top)
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


    local top = rect.bar04 and A.bar04Art.laneTop
    self:Tint(lane:GetStatusBarTexture(), "xp", "vertex", top and A.kbXpTop.fill or 0.95)
    self:Tint(lane.rested:GetStatusBarTexture(), "xpRested", "vertex", top and A.kbXpTop.rested or 0.6)
    if top and not lane.trough then
        pcall(function()
            lane.trough = self:Own(lane.rested:CreateTexture(nil, "BACKGROUND"))
            lane.trough:SetAllPoints(lane)
        end)
    end
    if lane.trough then
        if top then
            self:Tint(lane.trough, "shadow", "color", A.kbXpTop.trough)
            if not lane.trough:IsShown() then lane.trough:Show() end
        elseif lane.trough:IsShown() then
            lane.trough:Hide()
        end
    end
    if not lane:IsShown() then lane:Show() end

    if type(container) == "table" then
        self:HoldHidden(state, container)
        self.xpLaneHeld = true
    end
    self:UpdateXpLane()
    return true
end









A.kbFade = { alpha = 0.72, reach = 64, wide = 1.10 }






A.kbStackBars = { { "MultiBarBottomLeft", "MultiBarBottomLeftButton" }, { "MultiBarBottomRight", "MultiBarBottomRightButton" } }
function A:KeyboardStackOver()
    if self:IsCombat() then return self.kbStackOverLast or 0 end
    local bar = _G["MainActionBar"]
    local scale = type(bar) == "table" and self:Number(bar.GetEffectiveScale, 1, bar) or nil
    local bx1, by1, _, bh1 = rectOf(self, _G["ActionButton1"])
    local bxn, _, bwn = rectOf(self, _G["ActionButton12"])
    if not (scale and scale > 0.05 and by1 and bxn) then return self.kbStackOverLast or 0 end
    local row0, row1, top = bx1, bxn + bwn, by1 + bh1
    local rowTop, slotH = top, bh1
    local used = {}
    for _ = 1, #A.kbStackBars do
        local found
        for i, pair in ipairs(A.kbStackBars) do
            local frame = _G[pair[1]]
            if not used[i] and type(frame) == "table" and type(frame.IsShown) == "function"
                and self:Read(frame.IsShown, 1, frame) == true then
                local x0, x1, y0, y1
                for n = 1, 12 do
                    local x, y, w, h = rectOf(self, _G[pair[2] .. n])
                    if x then
                        x0, x1 = math.min(x0 or x, x), math.max(x1 or x + w, x + w)
                        y0, y1 = math.min(y0 or y, y), math.max(y1 or y + h, y + h)
                    end
                end
                local span = x0 and (math.min(x1, row1) - math.max(x0, row0)) or 0
                if x0 and span >= (row1 - row0) / 2 and y0 >= top - slotH / 2 and y0 - top <= slotH then
                    found = i
                    used[i] = true
                    top = math.max(top, y1)
                    break
                end
            end
        end
        if not found then break end
    end
    self.kbStackOverLast = math.max(0, (top - rowTop) / scale)
    return self.kbStackOverLast
end

local function fadeBackdrop(self, state, on)
    local bar = _G["MainActionBar"]
    if type(bar) ~= "table" then return false end
    local entries = state.decorations[bar]
    local rect = book(state, bar).rect
    local host = entries and entries.kbSlab
    local want = on and host and rect and rect.bar04
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
    local f, b = A.kbFade, A.bar04Base

    local plank = rect.base and b.back == false
    local over = plank and self:KeyboardStackOver() or 0
    local sig = string.format("%.3f|%.3f|%s|%.3f|%.3f|%s|%.3f|%.3f", rect.w, rect.h, tostring(rect.base), rect.rowH or 0,
        rect.air or 0, tostring(b.back), over, b.fadeOver or 0)
    if fade.sig ~= sig then
        fade.sig = sig
        fade:ClearAllPoints()
        if plank then







            local a, px = A.bar04Art, self:KeyboardPixel(bar)
            fade:SetPoint("BOTTOM", host, "TOP", rect.w * ((a.topU0 + a.topU1) / 2 - 0.5), -rect.h * a.seatV0)
            fade:SetSize(rect.w * (a.topU1 - a.topU0) + 2 * b.backPx * px,
                math.max(px, (rect.air or 0) + rect.rowH + over + b.fadeOver))
        else
            fade:SetPoint("BOTTOM", host, "BOTTOM", 0, 0)


            local reach = rect.base and ((rect.air or 0) + rect.rowH + b.fadeOver) or f.reach
            fade:SetSize(rect.w * f.wide, rect.h + reach)
        end
    end
    self:Tint(fade, "shadow", "vertex", plank and b.fadeAlpha or f.alpha)
    if not fade:IsShown() then fade:Show() end


    local back = entries.kbBack
    if rect.base and A.bar04Base.back ~= false then
        if not back then
            back = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -7))
            entries.kbBack = back
        end
        local px = self:KeyboardPixel(bar)
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





local function microSlab(self, state, name, holdArt)
    local frame = _G[name]
    if type(frame) ~= "table" then return false end
    for _, art in ipairs(microArt(name)) do
        if holdArt then self:HoldHidden(state, art) else self:ReleaseHidden(state, art) end
    end
    return false
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
    endCaps(self, state, on)
    self:KeyboardDividers(on)

    pageBlock(self, state, on)
    statusLane(self, state, on and self:GetOption("keyboardStatusLane") == true)

    xpInlay(self, state, on)
    fadeBackdrop(self, state, on)


    local holdMicroArt = on





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
    for _, name in ipairs(self:KeyboardMicroNames()) do
        microSlab(self, state, name, holdMicroArt)
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
                else
                    push(def.frame, "bar", x, y, w, h)
                end
            end
        end
    end
    for _, name in ipairs(self:KeyboardMicroNames()) do
        local frame = _G[name]
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
    emit(string.format("keyboard bars: %s | skin %s | centre %s | mode %s",
        self.keyboardBarsActive and "on" or "off",
        tostring(self.db and self:GetOption("keyboardSkin")),
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
