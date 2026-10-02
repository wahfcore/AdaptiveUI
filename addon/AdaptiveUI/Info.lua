local _, A = ...















local ORDER = { "fps", "latency", "durability", "clock", "gold", "bags", "coords" }


local STRIP_H = 24
local GAP = 8


local WIDTHS = {
    caption = { fps = 76, latency = 112, durability = 88, clock = 84, gold = 120, bags = 76, coords = 108 },
    body = { fps = 84, latency = 124, durability = 100, clock = 92, gold = 132, bags = 84, coords = 120 },
}
local PERIOD = { fps = 0.5, latency = 2, durability = 5, clock = 1, gold = 1, bags = 3, coords = 0.5 }
local OPTION_ON = { fps = "infoFpsOn", latency = "infoLatencyOn", durability = "infoDurabilityOn", clock = "infoClockOn",
    gold = "infoGoldOn", bags = "infoBagsOn", coords = "infoCoordsOn" }
local OPTION_BAR = { fps = "infoFpsInBar", latency = "infoLatencyInBar", durability = "infoDurabilityInBar", clock = "infoClockInBar",
    gold = "infoGoldInBar", bags = "infoBagsInBar", coords = "infoCoordsInBar" }
local MOVER_ID = { fps = "infoFps", latency = "infoLatency", durability = "infoDurability", clock = "infoClock",
    gold = "infoGold", bags = "infoBags", coords = "infoCoords" }

local DURABILITY_SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10, 15, 16, 17 }





local function warn(self, level)
    local r, g, b = self:Color(level == 2 and "bad" or (level == 1 and "warn" or "text"))
    return r, g, b
end


local producers = {}

function producers.fps(self)
    local fps = self:Number(GetFramerate, 1)
    if not fps then return "--", 0 end
    local style = self:GetOption("infoFpsStyle")
    local text = style == "label" and string.format("FPS %.0f", fps)
        or (style == "short" and string.format("%.0f", fps) or string.format("%.0f fps", fps))
    return text, fps < 30 and 2 or (fps < 60 and 1 or 0)
end

function producers.latency(self)
    local home, world = self:Number(GetNetStats, 3), self:Number(GetNetStats, 4)
    if not home and not world then return "--", 0 end
    local style = self:GetOption("infoLatencyStyle")
    local shown
    if style == "home" then shown = home
    elseif style == "worst" then shown = (home and world) and math.max(home, world) or (home or world)
    end
    if style == "both" then
        if home and world then return string.format("%.0f / %.0f ms", home, world), (math.max(home, world) >= 300 and 2)
            or (math.max(home, world) >= 150 and 1 or 0) end
        shown = home or world
    end
    if not shown then return "--", 0 end
    return string.format("%.0f ms", shown), shown >= 300 and 2 or (shown >= 150 and 1 or 0)
end

function producers.durability(self)
    local lowest, sum, count = nil, 0, 0
    for _, slot in ipairs(DURABILITY_SLOTS) do
        local current = self:Number(GetInventoryItemDurability, 1, slot)
        local maximum = self:Number(GetInventoryItemDurability, 2, slot)
        if current and maximum and maximum > 0 then
            local pct = current / maximum * 100
            lowest = lowest and math.min(lowest, pct) or pct
            sum, count = sum + pct, count + 1
        end
    end
    if count == 0 then return "--", 0 end
    local value = self:GetOption("infoDurabilityStyle") == "average" and (sum / count) or lowest
    return string.format("Dur %.0f%%", value), value < 25 and 2 or (value < 50 and 1 or 0)
end

function producers.clock(self)
    local hour, minute
    if self:GetOption("infoClockSource") == "server" then
        hour, minute = self:Number(GetGameTime, 1), self:Number(GetGameTime, 2)
    else
        local h, mnt = self:Text(date, 1, "%H"), self:Text(date, 1, "%M")
        hour, minute = tonumber(h), tonumber(mnt)
    end
    if not hour or not minute then return "--", 0 end
    if self:GetOption("infoClockFormat") == "12" then
        local suffix = hour >= 12 and "PM" or "AM"
        local h12 = hour % 12
        if h12 == 0 then h12 = 12 end
        return string.format("%d:%02d %s", h12, minute, suffix), 0
    end
    return string.format("%02d:%02d", hour, minute), 0
end


local function grouped(n)
    local s = string.format("%d", n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

function producers.gold(self)
    local copper = self:Number(GetMoney, 1)
    if not copper or copper < 0 then return "--", 0 end
    local gold, silver, cents = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
    if self:GetOption("infoGoldStyle") == "full" then
        return string.format("%sg %ds %dc", grouped(gold), silver, cents), 0
    end
    return grouped(gold) .. "g", 0
end



function producers.bags(self)
    local container = type(C_Container) == "table" and C_Container or nil
    if not container or type(container.GetContainerNumSlots) ~= "function"
        or type(container.GetContainerNumFreeSlots) ~= "function" then return "--", 0 end
    local free, total = 0, 0
    for bag = 0, 4 do
        local slots = self:Number(container.GetContainerNumSlots, 1, bag)
        local open = self:Number(container.GetContainerNumFreeSlots, 1, bag)
        if slots and open then free, total = free + open, total + slots end
    end
    if total == 0 then return "--", 0 end
    local level = free <= 2 and 2 or (free <= 6 and 1 or 0)
    if self:GetOption("infoBagsStyle") == "both" then return string.format("%d / %d", free, total), level end
    return string.format("%d free", free), level
end



function producers.coords(self)
    if type(C_Map) ~= "table" or type(C_Map.GetBestMapForUnit) ~= "function"
        or type(C_Map.GetPlayerMapPosition) ~= "function" then return "--", 0 end
    local mapID = self:Number(C_Map.GetBestMapForUnit, 1, "player")
    if not mapID then return "--", 0 end
    local position = self:Read(C_Map.GetPlayerMapPosition, 1, mapID, "player")

    if (type(position) ~= "table" and type(position) ~= "userdata") or type(position.GetXY) ~= "function" then return "--", 0 end
    local x, y = self:Number(position.GetXY, 1, position), self:Number(position.GetXY, 2, position)
    if not x or not y then return "--", 0 end
    if self:GetOption("infoCoordsStyle") == "integer" then return string.format("%.0f, %.0f", x * 100, y * 100), 0 end
    return string.format("%.1f, %.1f", x * 100, y * 100), 0
end


local function newStrip(self, id)
    local strip = CreateFrame("Frame", "AdaptiveUIInfo_" .. id, UIParent)
    strip:SetSize(WIDTHS.caption[id], STRIP_H)
    strip:SetFrameStrata("LOW")
    strip:EnableMouse(false)
    strip.depth = {}
    self:Elevate(strip.depth, strip, "d", strip, 0, 0, strip, 0, 0, "base")

    strip.bg = strip:CreateTexture(nil, "BACKGROUND", nil, -7)
    strip.bg:SetAllPoints()
    self:Tint(strip.bg, "ink", "color")
    strip.edges = {}
    for i, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local edge = strip:CreateTexture(nil, "BORDER")
        self:Tint(edge, "edge", "color")
        if side == "TOP" or side == "BOTTOM" then
            edge:SetPoint(side .. "LEFT", strip, side .. "LEFT"); edge:SetPoint(side .. "RIGHT", strip, side .. "RIGHT")
            edge:SetHeight(1)
        else
            edge:SetPoint("TOP" .. side, strip, "TOP" .. side); edge:SetPoint("BOTTOM" .. side, strip, "BOTTOM" .. side)
            edge:SetWidth(1)
        end
        strip.edges[i] = edge
    end
    strip.text = strip:CreateFontString(nil, "OVERLAY")


    self:SetThemedFont(strip.text, self:Type("caption"), false)
    strip.text:SetPoint("CENTER", strip, "CENTER")
    strip.text:SetJustifyH("CENTER")
    self:Tint(strip.text, "text", "text")
    strip.text:SetText("--")
    strip:Hide()
    return strip
end

function A:CreateInfo()
    if self.info then return self.info end
    local info = { strips = {} }
    info.bar = CreateFrame("Frame", "AdaptiveUIInfoBar", UIParent)
    info.bar:SetFrameStrata("LOW")
    info.bar:EnableMouse(false)
    info.bar.depth = {}
    self:Elevate(info.bar.depth, info.bar, "d", info.bar, 0, 0, info.bar, 0, 0, "panel")
    info.bar.bg = info.bar:CreateTexture(nil, "BACKGROUND", nil, -7)
    info.bar.bg:SetAllPoints()
    self:Tint(info.bar.bg, "ink", "color")
    info.bar.edge = info.bar:CreateTexture(nil, "BORDER")
    self:Tint(info.bar.edge, "edge", "color")
    info.bar:Hide()
    for _, id in ipairs(ORDER) do info.strips[id] = newStrip(self, id) end
    self.info = info
    return info
end






function A:InfoBarSpan(m)
    local edge = self:GetOption("infoBar")
    if edge == "off" then return nil end




    local margin = self:SafeInset(m)
    local reserved
    if edge == "top" then
        local scale = math.max(0.5, m.fit * 0.95 * self:GetOption("minimapScale"))
        reserved = (198 + self.tokens.space.sm * 2 + 26) * scale + margin * 2
    else
        reserved = margin + math.max(280, 390 * m.fit) + margin
    end
    local width = math.min(720, m.width - 2 * reserved)
    if width < 200 then return nil, "no room" end
    return width, edge
end

function A:InfoDocked(id)
    return self.infoDockedSet ~= nil and self.infoDockedSet[id] == true
end



function A:InfoBase(id, m)
    if id == "infoBar" then
        local edge = self:GetOption("infoBar")
        local h = self:GetOption("infoBarHeight")
        local sp = self.tokens.space
        if edge == "bottom" then return 0, sp.sm + 17 + sp.sm + h / 2 end
        return 0, m.height - sp.sm - h / 2
    end
    local stripId
    for sid, mid in pairs(MOVER_ID) do if mid == id then stripId = sid end end
    local slot = self.infoSlots and stripId and self.infoSlots[stripId]
    if slot then return slot[1], slot[2] end
    return 0, m.height - select(2, self:SafeInset(m)) - STRIP_H / 2
end

function A:ApplyInfo()
    if self:IsCombat() then self.layoutDirty = true; return false end
    local any = false
    for _, id in ipairs(ORDER) do if self:GetOption(OPTION_ON[id]) then any = true end end
    if not any and not self.info then return false end
    local ok = pcall(function()
        local info = self:CreateInfo()
        local m = self:LayoutMetrics()
        local sp = self.tokens.space
        local size = self:GetOption("infoTextSize")
        local widths = WIDTHS[size] or WIDTHS.caption
        local barWidth, edge = self:InfoBarSpan(m)
        local height = self:GetOption("infoBarHeight")
        self.infoBarWidth = barWidth
        self.infoDockedSet = {}
        local bar = info.bar

        local dockedWidth, docked = 0, {}
        if barWidth then
            for _, id in ipairs(ORDER) do
                if self:GetOption(OPTION_ON[id]) and self:GetOption(OPTION_BAR[id]) then
                    local w = widths[id]
                    if dockedWidth + w + (#docked > 0 and GAP or 0) <= barWidth - sp.sm * 2 then
                        dockedWidth = dockedWidth + w + (#docked > 0 and GAP or 0)
                        docked[#docked + 1] = id
                        self.infoDockedSet[id] = true
                    end
                end
            end
        end

        if barWidth and #docked > 0 then
            local inset = sp.sm
            bar:SetSize(barWidth, height)
            bar:ClearAllPoints()


            local bx, by = self:MoverOffset("infoBar")


            local is = self:MoverScale("infoBar")
            bar:SetScale(is)
            if edge == "top" then bar:SetPoint("TOP", UIParent, "TOP", bx / is, (-inset + by) / is)
            else bar:SetPoint("BOTTOM", UIParent, "BOTTOM", bx / is, (inset + 17 + sp.sm + by) / is) end
            bar.edge:ClearAllPoints()
            if edge == "top" then
                bar.edge:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT"); bar.edge:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
            else
                bar.edge:SetPoint("TOPLEFT", bar, "TOPLEFT"); bar.edge:SetPoint("TOPRIGHT", bar, "TOPRIGHT")
            end
            bar.edge:SetHeight(1)
            bar.edge:SetShown(self:BordersOn())
            bar.bg:SetAlpha(self:Surface("base"))
            bar:Show()
        else
            bar:Hide()
        end



        local scaleMap = math.max(0.5, m.fit * 0.95 * self:GetOption("minimapScale"))
        local safeX, safeY = self:SafeInset(m)
        local maxRow = math.max(240, m.width - 2 * ((198 + sp.sm * 2 + 26) * scaleMap + safeX * 2))
        local rowsOfStrips, current, currentWidth = {}, {}, 0
        for _, id in ipairs(ORDER) do
            if self:GetOption(OPTION_ON[id]) and not self.infoDockedSet[id] then
                local w = widths[id]
                if #current > 0 and currentWidth + GAP + w > maxRow then
                    rowsOfStrips[#rowsOfStrips + 1] = { ids = current, width = currentWidth }
                    current, currentWidth = {}, 0
                end
                currentWidth = currentWidth + (#current > 0 and GAP or 0) + w
                current[#current + 1] = id
            end
        end
        if #current > 0 then rowsOfStrips[#rowsOfStrips + 1] = { ids = current, width = currentWidth } end
        self.infoSlots = {}
        local baseY = m.height - safeY - STRIP_H / 2

        if barWidth and #docked > 0 and edge == "top" then baseY = baseY - height - sp.sm end
        for rowIndex, row in ipairs(rowsOfStrips) do
            local x = -row.width / 2
            for _, id in ipairs(row.ids) do
                self.infoSlots[id] = { x + widths[id] / 2, baseY - (rowIndex - 1) * (STRIP_H + GAP) }
                x = x + widths[id] + GAP
            end
        end
        local dx = -dockedWidth / 2
        for _, id in ipairs(ORDER) do
            local strip = info.strips[id]
            local wanted = self:GetOption(OPTION_ON[id])
            strip:SetSize(widths[id], STRIP_H)
            self:SetThemedFont(strip.text, self.tokens.type[size], false)
            if wanted and self.infoDockedSet[id] then
                strip:ClearAllPoints()
                strip:SetPoint("LEFT", bar, "CENTER", dx, 0)
                strip:SetFrameLevel(bar:GetFrameLevel() + 1)
                dx = dx + widths[id] + GAP
                strip.bg:Hide()
                for _, e in ipairs(strip.edges) do e:Hide() end
                strip:Show()
            elseif wanted then
                local slot = self.infoSlots[id]
                local ox, oy = self:MoverOffset(MOVER_ID[id])
                strip:ClearAllPoints()
                strip:SetPoint("CENTER", UIParent, "BOTTOM", slot[1] + ox, slot[2] + oy)
                strip.bg:Show()
                strip.bg:SetAlpha(self:Surface("base"))
                for _, e in ipairs(strip.edges) do e:SetShown(self:BordersOn()) end
                strip:Show()
            else
                strip:Hide()
            end
        end
        self.infoDirty = true
    end)
    if not ok then

        self.infoFailed = true
        if self.info then
            for _, strip in pairs(self.info.strips) do strip:Hide() end
            self.info.bar:Hide()
        end
        self:Note("info strips", "rejected; hidden until reload")
    end
    return true
end


function A:TickInfo(elapsed)
    local info = self.info
    if not info or self.infoFailed then return end
    self.infoTimers = self.infoTimers or {}
    for _, id in ipairs(ORDER) do
        local strip = info.strips[id]
        if strip:IsShown() then
            local t = (self.infoTimers[id] or PERIOD[id]) + elapsed
            local due = t >= PERIOD[id] or self.infoDirty or (id == "durability" and self.infoDurabilityDirty)
            if due then
                t = 0
                local ok, text, level = pcall(producers[id], self)
                if not ok then text, level = "--", 0 end
                if strip.shownText ~= text then strip.text:SetText(text); strip.shownText = text end
                local r, g, b
                if self:GetOption("infoColorize") then r, g, b = warn(self, level) else r, g, b = warn(self, 0) end
                strip.text:SetTextColor(r, g, b)
            end
            self.infoTimers[id] = t
        end
    end
    self.infoDirty, self.infoDurabilityDirty = nil, nil
end



function A:InfoReport(line)
    local function state(fn, index, ...)
        if type(fn) ~= "function" then return "missing" end
        local value, status = self:Read(fn, index, ...)
        if status == "public" then return type(value) == "nil" and "nil" or "public" end
        return status
    end
    line("-- inspect: info strips / bar --")
    line(string.format("  GetFramerate=%s GetNetStats(home)=%s GetNetStats(world)=%s GetGameTime=%s date=%s",
        state(GetFramerate, 1), state(GetNetStats, 3), state(GetNetStats, 4), state(GetGameTime, 1), state(date, 1, "%H")))
    local slots = {}
    for _, slot in ipairs(DURABILITY_SLOTS) do slots[#slots + 1] = slot .. ":" .. state(GetInventoryItemDurability, 1, slot) end
    line("  durability slots: " .. table.concat(slots, " "))
    line(string.format("  party status APIs: UnitIsConnected=%s UnitIsDeadOrGhost=%s UnitIsGroupLeader=%s (out-of-range: not used)",
        state(UnitIsConnected, 1, "player"), state(UnitIsDeadOrGhost, 1, "player"), state(UnitIsGroupLeader, 1, "player")))
    local bagsFn = type(C_Container) == "table" and C_Container.GetContainerNumFreeSlots or nil
    local mapFn = type(C_Map) == "table" and C_Map.GetBestMapForUnit or nil
    local mapID = mapFn and self:Number(mapFn, 1, "player") or nil
    local positionState = "missing"
    if mapID and type(C_Map.GetPlayerMapPosition) == "function" then
        local position, status = self:Read(C_Map.GetPlayerMapPosition, 1, mapID, "player")
        positionState = position == nil and (status == "public" and "nil (restricted here, e.g. instance)" or status) or "public"
    end
    line(string.format("  more strips: GetMoney=%s C_Container.GetContainerNumFreeSlots(bag0)=%s C_Map.GetBestMapForUnit=%s GetPlayerMapPosition=%s",
        state(GetMoney, 1), bagsFn and state(bagsFn, 1, 0) or "missing", mapFn and state(mapFn, 1, "player") or "missing", positionState))
    local chosen, probes = self:SpecProbe()
    local parts = {}
    for _, probe in ipairs(probes) do parts[#parts + 1] = probe.name .. "=" .. probe.state end
    local numSpecs = type(C_SpecializationInfo) == "table" and state(C_SpecializationInfo.GetNumSpecializations, 1) or "missing"
    line(string.format("  spec profiles: %s GetNumSpecializations=%s C_SpecializationInfo.GetNumSpecializations=%s -> %s",
        table.concat(parts, " "), state(GetNumSpecializations, 1), numSpecs, chosen and "active" or "dormant"))
    line(string.format("  target-of-target: UnitExists(targettarget)=%s UnitName=%s UnitHealth=%s",
        state(UnitExists, 1, "targettarget"), state(UnitName, 1, "targettarget"), state(UnitHealth, 1, "targettarget")))
    local docked = {}
    for id in pairs(self.infoDockedSet or {}) do docked[#docked + 1] = id end
    table.sort(docked)
    line(string.format("  bar edge=%s span=%s docked=%s failed=%s", tostring(self:GetOption("infoBar")),
        tostring(self.infoBarWidth), table.concat(docked, ","), tostring(self.infoFailed)))
end
