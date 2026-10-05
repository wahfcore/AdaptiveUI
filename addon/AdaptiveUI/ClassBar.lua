local _, A = ...



























A.classBar = { dot = 20, dotGap = 5, manaW = 130, manaH = 6, totem = 24, totemGap = 6, rowGap = 5,
    comboColour = { 0.86, 0.13, 0.10 }, shardItem = 6265 }

local MAX_DOTS = 8

local function sinkPower(bar, unit, power)
    bar:SetMinMaxValues(0, UnitPowerMax(unit, power))
    bar:SetValue(UnitPower(unit, power))
end

local function sinkDot(bar, unit, power)
    bar:SetValue(UnitPower(unit, power))
end

local function build(self)
    local frame = CreateFrame("Frame", "AdaptiveUICompactResource", UIParent)
    frame:EnableMouse(false)
    frame:SetSize(1, 1)
    local c = A.classBar

    frame.dots = CreateFrame("Frame", nil, frame)
    frame.dots:EnableMouse(false)
    frame.dot = {}
    for i = 1, MAX_DOTS do
        local socket = frame.dots:CreateTexture(nil, "BACKGROUND")
        socket:SetTexture(self.artPath .. "dot-socket.tga", "CLAMP", "CLAMP")
        socket:SetSize(c.dot, c.dot)
        local fill = CreateFrame("StatusBar", nil, frame.dots)
        fill:SetSize(c.dot, c.dot)
        fill:SetPoint("CENTER", socket, "CENTER", 0, 0)
        fill:SetStatusBarTexture(self.artPath .. "dot-fill.tga")
        fill:SetMinMaxValues(i - 1, i)
        fill:SetValue(0)
        fill:EnableMouse(false)
        frame.dot[i] = { socket = socket, fill = fill }
    end

    frame.mana = CreateFrame("StatusBar", nil, frame)
    frame.mana:SetSize(c.manaW, c.manaH)
    frame.mana:SetStatusBarTexture(self.artPath .. "meter.tga")
    frame.mana:SetMinMaxValues(0, 1)
    frame.mana:SetValue(0)
    frame.mana:EnableMouse(false)
    frame.manaBack = frame.mana:CreateTexture(nil, "BACKGROUND")
    frame.manaBack:SetAllPoints()
    self:Tint(frame.manaBack, "well", "color")
    frame.manaLabel = self:Label(frame, self.tokens.type.caption, 0, 0, 60, "RIGHT")
    frame.manaLabel:SetText("Mana")

    frame.totems = CreateFrame("Frame", nil, frame)
    frame.totems:EnableMouse(false)
    frame.totem = {}
    for i = 1, 4 do
        local icon = frame.totems:CreateTexture(nil, "ARTWORK")
        icon:SetSize(c.totem, c.totem)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local time = self:Label(frame.totems, self.tokens.type.caption, 0, 0, c.totem + 16, "CENTER")
        frame.totem[i] = { icon = icon, time = time }
    end

    frame.shards = CreateFrame("Frame", nil, frame)
    frame.shards:EnableMouse(false)
    frame.shardIcon = frame.shards:CreateTexture(nil, "ARTWORK")
    frame.shardIcon:SetSize(c.totem, c.totem)
    frame.shardIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.shardCount = self:Label(frame.shards, self.tokens.type.body, 0, 0, 60, "LEFT")
    return frame
end


function A:ClassBarRows(identity)
    identity = identity or self.identity or {}
    local class, power = identity.classToken, identity.powerToken
    local rows = {}
    if type(self.comboType) == "number" and (class == "ROGUE" or (class == "DRUID" and power == "ENERGY")) then
        rows.dots = true
    end
    if class == "DRUID" and power ~= nil and power ~= "MANA" then rows.mana = true end
    if class == "SHAMAN" and type(GetTotemInfo) == "function" then rows.totems = true end
    if class == "WARLOCK" then rows.shards = true end
    return rows
end

local function publicNumber(self, value)
    return self:IsPublic(value) and type(value) == "number" and value == value and value or nil
end

local function itemCount(item)
    local fn = (C_Item and C_Item.GetItemCount) or GetItemCount
    if type(fn) ~= "function" then return nil end
    local ok, n = pcall(fn, item)
    return ok and n or nil
end

local function itemIcon(item)
    local fn = (C_Item and C_Item.GetItemIconByID) or GetItemIcon
    if type(fn) ~= "function" then return nil end
    local ok, icon = pcall(fn, item)
    return ok and icon or nil
end


function A:ClassBarDotCount()
    local max, status = self:Read(UnitPowerMax, 1, "player", self.comboType)
    if status ~= "public" or type(max) ~= "number" or max ~= max or max < 1 then return 5 end
    return math.min(MAX_DOTS, math.floor(max + 0.5))
end

local function lay(self, frame, rows)
    local c = A.classBar
    local y, width = 0, 0
    local function place(region, w, h)
        region:ClearAllPoints()
        region:SetPoint("TOP", frame, "TOP", 0, -y)
        region:SetSize(w, h)
        y = y + h + c.rowGap
        if w > width then width = w end
    end
    if rows.dots then
        local n = self:ClassBarDotCount()
        local w = n * c.dot + (n - 1) * c.dotGap
        place(frame.dots, w, c.dot)
        for i = 1, MAX_DOTS do
            local d = frame.dot[i]
            d.socket:ClearAllPoints()
            d.socket:SetPoint("LEFT", frame.dots, "LEFT", (i - 1) * (c.dot + c.dotGap), 0)
            local on = i <= n
            d.socket:SetShown(on); d.fill:SetShown(on)
        end
        frame.dots:Show()
    else
        frame.dots:Hide()
    end
    if rows.mana then
        place(frame.mana, c.manaW, c.manaH)
        frame.manaLabel:ClearAllPoints()
        frame.manaLabel:SetPoint("RIGHT", frame.mana, "LEFT", -self.tokens.space.sm, 0)
        frame.mana:Show(); frame.manaLabel:Show()
    else
        frame.mana:Hide(); frame.manaLabel:Hide()
    end
    if rows.totems then
        local w = 4 * c.totem + 3 * c.totemGap
        place(frame.totems, w, c.totem + 16)
        for i = 1, 4 do
            local t = frame.totem[i]
            t.icon:ClearAllPoints()
            t.icon:SetPoint("TOPLEFT", frame.totems, "TOPLEFT", (i - 1) * (c.totem + c.totemGap), 0)
            t.time:ClearAllPoints()
            t.time:SetPoint("TOP", t.icon, "BOTTOM", 0, -1)
        end
        frame.totems:Show()
    else
        frame.totems:Hide()
    end
    if rows.shards then
        place(frame.shards, c.totem + 60, c.totem)
        frame.shardIcon:ClearAllPoints()
        frame.shardIcon:SetPoint("LEFT", frame.shards, "LEFT", 0, 0)
        frame.shardCount:ClearAllPoints()
        frame.shardCount:SetPoint("LEFT", frame.shardIcon, "RIGHT", self.tokens.space.xs, 0)
        frame.shards:Show()
    else
        frame.shards:Hide()
    end
    frame:SetSize(math.max(1, width), math.max(1, y - c.rowGap))
    return y > 0
end

local function fillDots(self, frame)



    local fillFile = self.artPath .. self:LookName("dot-fill") .. ".tga"
    local oak = fillFile:find("oak%-stud") ~= nil
    local r, g, b = 1, 1, 1
    if not oak then r, g, b = unpack(A.classBar.comboColour) end


    if oak and self.OakStudFill then fillFile, r, g, b = self:OakStudFill() end
    if frame.dotFile ~= fillFile then
        frame.dotFile = fillFile
        local socketFile = self.artPath .. self:LookName("dot-socket") .. ".tga"
        for i = 1, MAX_DOTS do
            frame.dot[i].fill:SetStatusBarTexture(fillFile)
            frame.dot[i].socket:SetTexture(socketFile, "CLAMP", "CLAMP")
        end
    end
    for i = 1, MAX_DOTS do
        frame.dot[i].fill:SetStatusBarColor(r, g, b)



        local socket = frame.dot[i].socket
        if oak then
            self:DressPaintedRegion(socket, "dot-socket")
        elseif socket.auiBodyTint then
            socket.auiBodyTint = nil
            self.themed[socket] = nil
            socket:SetVertexColor(1, 1, 1, 1)
            self:DropGlaze(socket)
        end
    end
    local value, status = self:Read(UnitPower, 1, "player", self.comboType)
    for i = 1, MAX_DOTS do
        local bar = frame.dot[i].fill
        if self.auditedSink then
            if not pcall(sinkDot, bar, "player", self.comboType) then bar:SetValue(i - 1) end
        elseif status == "public" and type(value) == "number" then
            bar:SetValue(value)
        else
            bar:SetValue(i - 1)
        end
    end
end

local function fillMana(self, frame)
    local mana = Enum and Enum.PowerType and Enum.PowerType.Mana or 0
    local colour = (PowerBarColor and PowerBarColor.MANA) or { r = 0.25, g = 0.45, b = 1 }
    frame.mana:SetStatusBarColor(colour.r, colour.g, colour.b)
    if self.auditedSink then
        if pcall(sinkPower, frame.mana, "player", mana) then return end
    end
    local value, vs = self:Read(UnitPower, 1, "player", mana)
    local max, ms = self:Read(UnitPowerMax, 1, "player", mana)
    if vs == "public" and ms == "public" and type(value) == "number" and type(max) == "number" and max > 0 then
        frame.mana:SetMinMaxValues(0, max); frame.mana:SetValue(value)
    else
        frame.mana:SetMinMaxValues(0, 1); frame.mana:SetValue(0)
    end
end

function A:ClassBarTotemText(remaining)
    if remaining >= 60 then return string.format("%d:%02d", math.floor(remaining / 60), math.floor(remaining % 60)) end
    return string.format("%d", math.ceil(remaining))
end

local function fillTotems(self, frame)
    local now = GetTime()
    for i = 1, 4 do
        local t = frame.totem[i]
        local ok, have, _, start, duration, icon = pcall(GetTotemInfo, i)
        have = ok and self:IsPublic(have) and have == true
        if have and self:IsPublic(icon) and icon then
            t.icon:SetTexture(icon); t.icon:Show()
            local s, d = publicNumber(self, start), publicNumber(self, duration)
            if s and d and d > 0 then
                local left = s + d - now
                t.time:SetText(left > 0 and self:ClassBarTotemText(left) or "")
            else
                t.time:SetText("")
            end
        else
            t.icon:Hide(); t.time:SetText("")
        end
    end
end

local function fillShards(self, frame)
    local item = A.classBar.shardItem
    local icon = itemIcon(item)
    if icon then frame.shardIcon:SetTexture(icon) end
    local n = itemCount(item)
    frame.shardCount:SetText(publicNumber(self, n) and string.format("%d", n) or "")
end


function A:SyncClassBar()
    if not self.compactHUD then self.compactHUD = build(self) end
    local frame = self.compactHUD
    local unitScale = self:LayoutMetrics().unitScale * self:MoverScale("compact")
    frame:SetScale(unitScale)
    frame:ClearAllPoints()
    local ox, oy = self:MoverOffset("compact")
    if self.plusActive and self.plus then


        local below = self:PlusBelow() + self.tokens.space.sm
        frame:SetPoint("TOP", self.plus.player, "BOTTOM", ox / unitScale, -below + oy / unitScale)
    else
        frame:SetPoint("TOP", PlayerFrame, "BOTTOM", ox / unitScale, -2 + oy / unitScale)
    end
    self:UpdateCompactHUD(self.identity)
end


function A:UpdateCompactHUD(identity)
    local frame = self.compactHUD
    if not frame then return end
    if not self.unitIntegrated or not self.db.enabled or self.sessionDisabled then
        frame:Hide()
        return
    end
    local rows = self:ClassBarRows(identity)
    local key = (rows.dots and "d" or "") .. (rows.mana and "m" or "") .. (rows.totems and "t" or "")
        .. (rows.shards and "s" or "") .. (rows.dots and self:ClassBarDotCount() or "")
    if frame.layoutKey ~= key then
        frame.layoutKey = key
        frame.any = lay(self, frame, rows)
    end
    if not frame.any then frame:Hide(); return end
    if rows.dots then fillDots(self, frame) end
    if rows.mana then fillMana(self, frame) end
    if rows.totems then fillTotems(self, frame) end
    if rows.shards then fillShards(self, frame) end
    frame.rows = rows
    frame:Show()
end


local tick = 0
function A:TickClassBar(elapsed)
    local frame = self.compactHUD
    if not (frame and frame.rows and frame.rows.totems and frame:IsShown()) then return end
    tick = tick + elapsed
    if tick < 0.25 then return end
    tick = 0
    fillTotems(self, frame)
end
