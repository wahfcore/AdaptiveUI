local _, A = ...































local WIDTH, HEIGHT = 1000, 640
local MAST = 68
local NAV_X, NAV_W = 12, 172
local PAGE_X = NAV_X + NAV_W + 14
local PAGE_W = WIDTH - PAGE_X - 16
local PAGE_TOP = -(MAST + 8)
local FOOT = 48
local SCROLL = 26
local PAGE_H = HEIGHT - (MAST + 8) - FOOT - SCROLL
local ROW = 52
local ROW2 = 70
local HEAD = 30
local NAV_PITCH = 44
local CONTROL_W = 300
local TEXT_W = PAGE_W - CONTROL_W - 24

local LABEL, DESC = 16, 14
A.optionsWindowType = { label = LABEL, desc = DESC, width = WIDTH, height = HEIGHT }

local K









function A:DeviceScale()
    local height = 1080
    if type(GetPhysicalScreenSize) == "function" then
        local ok, _, h = pcall(GetPhysicalScreenSize)
        if ok and type(h) == "number" and h > 0 then height = h end
    end
    local s = UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent) or 1
    if type(s) ~= "number" or s <= 0.05 or s > 20 then s = 1 end
    return height / 768 * s
end

function A:WindowScale(w, h)
    local lift = self:TypeLift(self:DeviceScale())
    if lift > 1 then lift = math.ceil(lift * 1000) / 1000 end
    local uw = UIParent and self:Number(UIParent.GetWidth, 1, UIParent) or 1920
    local uh = UIParent and self:Number(UIParent.GetHeight, 1, UIParent) or 1080
    local cap = math.min(0.9 * uw / (w or WIDTH), 0.9 * uh / (h or HEIGHT))
    self.windowScaleCapped = lift > cap or nil
    return math.max(1, math.min(lift, cap))
end







A.layoutGroups = {
    { id = "units", label = "Unit frames", desc = "Your plate and your target's.", words = "plates player target",
      mover = function() return "plusPlayer" end, size = function() return "scale" end },
    { id = "actions", label = "Action bars", desc = "The bars on screen right now.", words = "compass keyboard buttons",
      mover = function(self) return self:ClickInputMode() == "controller" and "actionCompass" or "actionBar1" end,
      size = function() return "dockScale" end },
    { id = "minimap", label = "Minimap", desc = "The map and its frame.", words = "map",
      mover = function() return "minimap" end, size = function() return "minimapScale" end },
    { id = "chat", label = "Chat", desc = "The chat window.", words = "chat",
      mover = function() return "chat" end, size = function() return "scale.chat" end },
    { id = "objectives", label = "Objectives", desc = "The quest tracker.", words = "quest tracker",
      mover = function() return "objectives" end, size = function() return "scale.objectives" end },
    { id = "auras", label = "Buffs and debuffs", desc = "The buff and debuff rows.", words = "buffs debuffs auras",
      mover = function() return "auras" end, size = function() return "scale.auras" end },
    { id = "casts", label = "Cast bars", desc = "AdaptiveUI's own cast bar.", words = "cast",
      mover = function() return "castPlayer" end, size = function() return "scale.castPlayer" end },
}

A.simpleNudge = 16


A.moduleWords = {
    actions = { "Action buttons", "Button frames and cooldowns." },
    units = { "Player and target frames", "Blizzard's own player and target frames." },
    party = { "Party and raid frames", "Blizzard's own party and raid frames." },
    auras = { "Buffs and debuffs", "The buff and debuff icons." },
    minimap = { "Minimap", "The minimap's frame." },
    objectives = { "Quest tracker", "The objectives list." },
    chat = { "Chat", "The chat windows and the chat box." },
    tooltips = { "Tooltips", "Every tooltip." },
}


A.jumpTopics = {
    { "Colour scheme", "look", "themeScheme" }, { "Unit frames", "look", "unitMode" },
    { "Text size", "look", "textScale" }, { "Move things", "layout", "@moverLock" },
    { "Action bar size", "layout", "@group:actions" }, { "Minimap", "layout", "@group:minimap" },
    { "Chat", "layout", "@group:chat" }, { "Cast bars", "combat", "castPlayerMode" },
    { "Health bar colour", "combat", "@health" }, { "Controller or keyboard", "controls", "mode" },
    { "Action camera", "controls", "actionCamera" }, { "Profiles", "profiles" },
    { "Turn things off", "help", "@module:actions" }, { "Report a problem", "help", "@report" },
    { "Reset", "help", "@reset:positions" },
}






local function rowFrame(page, height)
    local row = CreateFrame("Frame", nil, page)
    row:SetSize(PAGE_W, height or ROW)
    row:Hide()

    row.tick = row:CreateTexture(nil, "OVERLAY")
    row.tick:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -4)
    row.tick:SetSize(2, (height or ROW) - 8)
    A:Tint(row.tick, "accent", "color", 1)
    row.tick:Hide()
    return row
end

local function headingRow(page, label)
    local row = rowFrame(page, HEAD)
    row.kind = "heading"
    row.text = K.text(row, DESC, false, 8, -10, PAGE_W - 16, "LEFT", "muted")
    row.text:SetText(string.upper(label))
    row.tick:Hide()
    row.refresh = function() end
    return row
end



local function describe(row, label, desc, width)
    width = width or TEXT_W
    row.label = K.text(row, LABEL, false, 10, -6, width)
    row.label:SetText(label)
    row.desc = K.text(row, DESC, false, 10, -27, width, "LEFT", "muted")
    row.desc:SetText(desc)
    local measured = select(2, pcall(row.desc.GetStringWidth, row.desc))
    if type(measured) == "number" and measured > width - 2 then
        row.desc:SetWordWrap(true)
        row.desc:SetHeight(36)
        row.height0 = ROW2
        row:SetHeight(ROW2)
        row.tick:SetHeight(ROW2 - 8)
        row.twoLines = true
    end
end

local function labelled(row, option)
    describe(row, option.label, A:OptionDescription(option))
end

local rowBuilders = {}

function rowBuilders.bool(page, option)
    local row = rowFrame(page)
    labelled(row, option)
    local b = K.uiButton(row, "", PAGE_W - CONTROL_W, 8, CONTROL_W, ROW - 16, function()
        A:SetOption(option.key, not A:GetOption(option.key))
    end)
    local box = CreateFrame("Frame", nil, b)
    box:SetPoint("TOPRIGHT", b, "TOPRIGHT", -8, -8)
    box:SetSize(18, 18)
    box.well = K.fill(box, "BACKGROUND", "ink", 1)
    box.mark = box:CreateTexture(nil, "OVERLAY")
    box.mark:SetPoint("TOPLEFT", box, "TOPLEFT", 4, -4)
    box.mark:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -4, 4)
    A:Tint(box.mark, "text", "color")
    row.control = b
    row.refresh = function()
        local on = A:GetOption(option.key) == true
        b.label:SetText(on and "On" or "Off")
        box.mark:SetShown(on)
    end
    return row
end


local function stepper(row, x, width, getValue, nudge, formatValue)
    local minus = K.uiButton(row, "-", x, 8, 56, ROW - 16, function() nudge(-1) end)
    local value = K.text(row, LABEL, true, x + 60, -16, width - 120, "CENTER")
    local plus = K.uiButton(row, "+", x + width - 56, 8, 56, ROW - 16, function() nudge(1) end)
    return minus, plus, function() value:SetText(formatValue(getValue())) end
end

function rowBuilders.number(page, option)
    local row = rowFrame(page)
    labelled(row, option)
    local minus, _, refresh = stepper(row, PAGE_W - CONTROL_W, CONTROL_W,
        function() return A:GetOption(option.key) end,
        function(direction)
            local current = A:GetOption(option.key)
            A:SetOption(option.key, K.roundTo(current + direction * (option.step or 1), option.step))
        end,
        function(v) return K.formatNumber(option, v) end)
    row.control = minus
    row.refresh = refresh
    return row
end



local function stepEnum(option, direction, values)
    local current = A:GetOption(option.key)
    local index
    for i, entry in ipairs(values) do if entry.value == current then index = i end end
    if not index then index = direction > 0 and 0 or 1 end
    for step = 1, #values do
        local nextEntry = values[(index - 1 + direction * step) % #values + 1]
        if A:SetOption(option.key, nextEntry.value) then return end
    end
end

local function simpleMode() return A:GetOption("optionsAdvanced") ~= true end



function rowBuilders.enum(page, option)
    local row = rowFrame(page)
    labelled(row, option)
    local x0 = PAGE_W - CONTROL_W
    if #option.values <= 3 then
        local n = #option.values
        local gap = 4
        local w = math.floor((CONTROL_W - (n - 1) * gap) / n)
        row.segments = {}
        for i, entry in ipairs(option.values) do
            local b = K.uiButton(row, entry.label, x0 + (i - 1) * (w + gap), 8, w, ROW - 16, function()
                local ok, why = A:SetOption(option.key, entry.value)
                if not ok and why then A:Print(tostring(why)) end
            end)
            b.value = entry.value
            b.label:SetJustifyH("CENTER")
            b.mark = b:CreateTexture(nil, "OVERLAY")
            b.mark:SetPoint("TOPLEFT", b, "TOPLEFT", 0, -(ROW - 16 - 3))
            b.mark:SetSize(w, 3)
            A:Tint(b.mark, "accent", "color", 1)
            row.segments[i] = b
        end

        row.control = row.segments[1]
        row.refresh = function()
            local current = A:GetOption(option.key)
            for i, b in ipairs(row.segments) do
                local on = b.value == current
                b.label:SetText(option.values[i].label)
                b.mark:SetShown(on)
                if b.bg then b.bg:SetAlpha(on and 1 or 0.55) end
            end
        end
        return row
    end
    local prev = K.uiButton(row, "<", x0, 8, 44, ROW - 16, function()
        stepEnum(option, -1, A:OptionValues(option, not simpleMode()))
    end)
    local b = K.uiButton(row, "", x0 + 48, 8, CONTROL_W - 96, ROW - 16, function()
        stepEnum(option, 1, A:OptionValues(option, not simpleMode()))
    end)
    b.label:SetJustifyH("CENTER")
    K.uiButton(row, ">", x0 + CONTROL_W - 44, 8, 44, ROW - 16, function()
        stepEnum(option, 1, A:OptionValues(option, not simpleMode()))
    end)
    row.control = b
    row.prev = prev
    row.refresh = function()
        local current = A:GetOption(option.key)
        local shown = current
        for _, entry in ipairs(option.values) do if entry.value == current then shown = entry.label end end
        b.label:SetText(tostring(shown))
    end
    return row
end

function rowBuilders.color(page, option)
    local row = rowFrame(page)
    labelled(row, option)
    local b = K.uiButton(row, "", PAGE_W - CONTROL_W, 8, CONTROL_W, ROW - 16, function() K.pickColour(option) end)
    b.color = b:CreateTexture(nil, "ARTWORK")
    b.color:SetPoint("TOPLEFT", b, "TOPLEFT", 4, -4)
    b.color:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -4, 4)
    row.control = b
    row.refresh = function()
        local c = A:GetOption(option.key)
        b.color:SetColorTexture(c[1], c[2], c[3], 1)
    end
    return row
end



function rowBuilders.scheme(page, option)
    local row = rowFrame(page, ROW)
    row.kind = "picker"
    row.label = K.text(row, LABEL, false, 10, -6, PAGE_W - 20)
    row.label:SetText(option.label)
    local refresh, used = K.builders.scheme(A, row, option, -30, { width = PAGE_W - 8, full = true })
    row.height0 = used * K.ROW_H + 38
    row:SetHeight(row.height0)
    row.tick:SetHeight(row.height0 - 8)
    row.refresh = refresh
    return row
end



local function moverRow(page, entry)
    local row = rowFrame(page)
    row.kind = "mover"
    row.label = K.text(row, LABEL, false, 10, -6, 176)
    row.desc = K.text(row, DESC, false, 10, -27, 176, "LEFT", "muted")
    local x = 196
    local first
    for _, spec in ipairs({ { "<", -1, 0 }, { ">", 1, 0 }, { "^", 0, 1 }, { "v", 0, -1 } }) do
        local b = K.uiButton(row, spec[1], x, 8, 40, ROW - 16, function() A:NudgeMover(entry.id, spec[2], spec[3]) end)
        first = first or b
        x = x + 44
    end
    K.uiButton(row, "Reset", x + 2, 8, 76, ROW - 16, function() A:ResetMover(entry.id) end)
    x = x + 86


    local scaleKey = entry.scaleKey or ("scale." .. entry.id)
    local scaleOption = A.optionIndex[scaleKey]
    if scaleOption and scaleOption.type == "number" then
        local function nudge(direction)
            local current = A:GetOption(scaleKey)
            A:SetOption(scaleKey, K.roundTo(current + direction * (scaleOption.step or 0.05), scaleOption.step))
        end
        K.uiButton(row, "-", x, 8, 44, ROW - 16, function() nudge(-1) end)
        row.scaleText = K.text(row, LABEL, true, x + 46, -16, 76, "CENTER")
        K.uiButton(row, "+", x + 124, 8, 44, ROW - 16, function() nudge(1) end)
    end
    row.control = first
    row.refresh = function()
        local ox, oy = A:MoverOffset(entry.id)
        row.label:SetText(entry.label)
        local available = entry.frame(A) ~= nil
        local docked = entry.info and A:InfoDocked(entry.info)
        local anchored = entry.anchored and entry.anchored(A)
        row.desc:SetText(string.format("(%d, %d)%s", ox, oy,
            anchored and (entry.anchoredNote or "  on the health bar") or (docked and "  docked" or (available and "" or "  not shown now"))))
        if row.scaleText then row.scaleText:SetText(K.formatNumber(scaleOption, A:GetOption(scaleKey))) end
        row.tick:SetShown((ox ~= 0 or oy ~= 0) or (scaleOption and A:OptionChanged(scaleKey)) or false)
    end
    row.reset = function() A:ResetMover(entry.id); if scaleOption then A:SetOption(scaleKey, A:DefaultFor(scaleOption)) end end
    return row
end

local function moverEntry(id)
    for _, e in ipairs(A.moverList) do if e.id == id then return e end end
end




local function groupRow(page, group)
    local row = rowFrame(page)
    row.kind = "group"
    row.group = group
    local textW = PAGE_W - 512
    describe(row, group.label, group.desc, textW)
    local x = PAGE_W - 452

    row.sizeCaption = K.text(row, DESC, false, x - 46, -18, 42, "RIGHT", "muted")
    row.sizeCaption:SetText("Size")
    local function sizeOption() return A.optionIndex[group.size(A)] end
    local minus = K.uiButton(row, "-", x, 8, 40, ROW - 16, function()
        local o = sizeOption()
        if o then A:SetOption(o.key, K.roundTo(A:GetOption(o.key) - (o.step or 0.05), o.step)) end
    end)
    row.sizeText = K.text(row, LABEL, true, x + 42, -16, 60, "CENTER")
    K.uiButton(row, "+", x + 104, 8, 40, ROW - 16, function()
        local o = sizeOption()
        if o then A:SetOption(o.key, K.roundTo(A:GetOption(o.key) + (o.step or 0.05), o.step)) end
    end)
    x = x + 152
    row.nudges = {}
    for _, spec in ipairs({ { "<", -1, 0 }, { ">", 1, 0 }, { "^", 0, 1 }, { "v", 0, -1 } }) do
        local b = K.uiButton(row, spec[1], x, 8, 40, ROW - 16, function()
            local id = group.mover(A)
            local ox, oy = A:MoverOffset(id)
            A:SetMoverOffset(id, ox + spec[2] * A.simpleNudge, oy + spec[3] * A.simpleNudge)
        end)
        row.nudges[#row.nudges + 1] = b
        x = x + 44
    end
    row.resetButton = K.uiButton(row, "Reset", x + 4, 8, 72, ROW - 16, function() row.reset() end)
    row.control = minus
    row.refresh = function()
        local o = sizeOption()
        row.sizeText:SetText(o and K.formatNumber(o, A:GetOption(o.key)) or "")
        local id = group.mover(A)
        local entry = moverEntry(id)
        local available = entry and entry.frame(A) ~= nil
        for _, b in ipairs(row.nudges) do b:SetShown(available and true or false) end
        local ox, oy = A:MoverOffset(id)
        row.desc:SetText(available and group.desc or (group.desc .. " Not on screen now."))
        row.tick:SetShown((ox ~= 0 or oy ~= 0) or (o and A:OptionChanged(o.key)) or false)
    end
    row.reset = function()
        A:ResetMover(group.mover(A))
        local o = sizeOption()
        if o then A:SetOption(o.key, A:ResetValue(o)) end
    end
    row.keys = function()
        local keys = {}
        local o = sizeOption()
        if o then keys[o.key] = true end
        local entry = moverEntry(group.mover(A))
        if entry and entry.key then keys[entry.key] = true end
        return keys
    end
    return row
end





local function elementRow(page, e)
    local row = rowFrame(page)
    row.kind = "element"
    row.element = e
    local desc = (e.native and "Blizzard's frame, faded by AdaptiveUI.") or (e.own and "Drawn by AdaptiveUI.")
        or (e.extraBar and "Blizzard's bar; move it in Every mover.") or "Look only."
    describe(row, e.label, desc, 256)
    local alphaKey = "alpha." .. e.id
    local alphaOption = A.optionIndex[alphaKey]
    local x = 272
    if alphaOption then
        local function nudge(direction)
            local v = K.roundTo(A:GetOption(alphaKey) + direction * alphaOption.step, alphaOption.step)
            A:SetOption(alphaKey, v)
        end
        row.alphaMinus = K.uiButton(row, "-", x, 8, 40, ROW - 16, function() nudge(-1) end)
        row.alphaText = K.text(row, LABEL, true, x + 42, -16, 64, "CENTER")
        row.alphaPlus = K.uiButton(row, "+", x + 108, 8, 40, ROW - 16, function() nudge(1) end)
    end
    x = x + 160
    local looks = A:ElementLooks(e.id)
    if looks and #looks > 0 then
        row.lookPrev = K.uiButton(row, "<", x, 8, 40, ROW - 16, function() A:StepElementLook(e.id, -1) end)
        row.lookButton = K.uiButton(row, "", x + 44, 8, PAGE_W - x - 88 - 4, ROW - 16, function()
            A:StepElementLook(e.id, 1)
        end)
        row.lookButton.label:SetJustifyH("CENTER")
        row.lookNext = K.uiButton(row, ">", PAGE_W - 44, 8, 40, ROW - 16, function() A:StepElementLook(e.id, 1) end)
    end
    row.control = row.alphaMinus or row.lookButton
    local function keys()
        local out = {}
        if alphaOption then out[alphaKey] = true end
        if A.optionIndex["skin." .. e.id] then out["skin." .. e.id] = true end
        return out
    end
    row.keys = keys
    row.refresh = function()
        if row.alphaText then row.alphaText:SetText(string.format("%d%%", math.floor(A:ElementAlpha(e.id) * 100 + 0.5))) end
        if row.lookButton then
            local index, list = A:ElementLook(e.id)
            row.lookButton.label:SetText(index and list[index].label or "Your own mix")
        end
        local changed = false
        for k in pairs(keys()) do if A:OptionChanged(k) then changed = true end end
        row.tick:SetShown(changed)
    end
    row.reset = function()
        for k in pairs(keys()) do A:SetOption(k, A:DefaultFor(A.optionIndex[k]), true) end
        A:OptionsApplied()
    end
    return row
end




local function extraBarsRow(page)
    local row = rowFrame(page)
    row.kind = "extraBars"
    describe(row, "Extra action bars", "Bars 2 to 8, stance, pet and possess.", PAGE_W - 200)
    row.resetButton = K.uiButton(row, "Reset them", PAGE_W - 180, 8, 176, ROW - 16, function() row.reset() end)
    row.resetButton.label:SetJustifyH("CENTER")
    row.control = row.resetButton
    row.keys = function()
        local out = {}
        for _, id in ipairs(A.extraBarIds) do
            for _, k in ipairs({ "pos." .. id, "skin." .. id, "scale." .. id }) do
                if A.optionIndex[k] then out[k] = true end
            end
        end
        return out
    end
    row.refresh = function()
        local n = #A:ExtraBarsShown()
        row.desc:SetText(n == 1 and "One on screen. Unlock Move things to drag it." or
            (n .. " on screen. Unlock Move things to drag them."))
        local changed = false
        for k in pairs(row.keys()) do if A:OptionChanged(k) then changed = true end end
        row.tick:SetShown(changed)
    end
    row.reset = function()
        local ok, why = A:ResetExtraBars()
        if not ok then A:Print("Not reset: " .. tostring(why)) end
    end
    return row
end


local function actionRow(page, label, desc, onClick, confirmKey, buttonLabel)
    local row = rowFrame(page)
    row.kind = "action"
    describe(row, label, desc)
    if confirmKey then
        row.control = K.confirmButton(row, buttonLabel or "Run", PAGE_W - CONTROL_W, 8, CONTROL_W, ROW - 16, confirmKey, onClick)
    else
        row.control = K.uiButton(row, buttonLabel or "Run", PAGE_W - CONTROL_W, 8, CONTROL_W, ROW - 16, onClick)
    end
    row.refresh = function() end
    return row
end


local function moduleRow(page, module)
    local words = A.moduleWords[module.key] or { module.label, "" }
    local row = rowFrame(page)
    row.kind = "module"
    describe(row, words[1], words[2])
    local half = math.floor((CONTROL_W - 4) / 2)
    row.styled = K.uiButton(row, "Styled", PAGE_W - CONTROL_W, 8, half, ROW - 16, function()
        A:SetSkinEnabled(module.key, true)
    end)
    row.blizzard = K.uiButton(row, "Blizzard's", PAGE_W - CONTROL_W + half + 4, 8, half, ROW - 16, function()
        A:SetSkinEnabled(module.key, false)
    end)
    for _, b in ipairs({ row.styled, row.blizzard }) do
        b.label:SetJustifyH("CENTER")
        b.mark = b:CreateTexture(nil, "OVERLAY")
        b.mark:SetPoint("TOPLEFT", b, "TOPLEFT", 0, -(ROW - 16 - 3))
        b.mark:SetSize(half, 3)
        A:Tint(b.mark, "accent", "color", 1)
    end
    row.control = row.styled
    row.refresh = function()
        local on = A.db.skins and A.db.skins[module.key] ~= false
        row.styled.mark:SetShown(on); row.blizzard.mark:SetShown(not on)
        row.styled.bg:SetAlpha(on and 1 or 0.55); row.blizzard.bg:SetAlpha(on and 0.55 or 1)
        row.tick:SetShown(not on)
    end
    row.reset = function() A:SetSkinEnabled(module.key, true) end
    return row
end




A.healthColourKeys = { "plusColorPlayer", "plusColorTarget", "plusColorParty" }
local function healthRow(page)
    local option = A.optionIndex.plusColorPlayer
    local row = rowFrame(page)
    row.kind = "health"
    describe(row, "Health bar colour", "Your bar, your target's and your party's, together.")
    local values = option.values
    local function current()
        local first = A:GetOption(A.healthColourKeys[1])
        for _, key in ipairs(A.healthColourKeys) do if A:GetOption(key) ~= first then return nil end end
        return first
    end
    local function step(direction)
        local now = current()
        local index = 0
        for i, entry in ipairs(values) do if entry.value == now then index = i end end
        local nextEntry = values[(index - 1 + direction) % #values + 1]
        if index == 0 then nextEntry = values[1] end
        for _, key in ipairs(A.healthColourKeys) do A:SetOption(key, nextEntry.value) end
    end
    local x0 = PAGE_W - CONTROL_W
    K.uiButton(row, "<", x0, 8, 44, ROW - 16, function() step(-1) end)
    local b = K.uiButton(row, "", x0 + 48, 8, CONTROL_W - 96, ROW - 16, function() step(1) end)
    b.label:SetJustifyH("CENTER")
    K.uiButton(row, ">", x0 + CONTROL_W - 44, 8, 44, ROW - 16, function() step(1) end)
    row.control = b
    row.refresh = function()
        local now = current()
        local shown = "Mixed"
        for _, entry in ipairs(values) do if entry.value == now then shown = entry.label end end
        b.label:SetText(shown)
        local changed = false
        for _, key in ipairs(A.healthColourKeys) do if A:OptionChanged(key) then changed = true end end
        row.tick:SetShown(changed)
    end
    row.reset = function()
        for _, key in ipairs(A.healthColourKeys) do A:SetOption(key, A:ResetValue(A.optionIndex[key])) end
    end
    row.keys = function()
        local keys = {}
        for _, key in ipairs(A.healthColourKeys) do keys[key] = true end
        return keys
    end
    return row
end




function A:CreateOptionsSections()
    if self.options_ui then return self.options_ui end
    K = self.optionsKit
    local frame = CreateFrame("Frame", "AdaptiveUIOptions", UIParent)
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    self:TopWindow(frame)
    frame:EnableMouse(true)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "d", frame, 0, 0, frame, 0, 0, "raised")
    frame.bg = K.fill(frame, "BACKGROUND", "ink", 0.97, -7)

    frame.rule = frame:CreateTexture(nil, "OVERLAY")
    self:Tint(frame.rule, "accent", "color", 1)
    frame.rule:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.rule:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.rule:SetHeight(2)


    frame.mast = {}
    local lead = 0
    if self:ChromeCrest("windows") then
        local size = self:CrestSeatSize(frame)
        self:CrestSeat(frame, frame.mast, "m", frame, 16, -(MAST - size) / 2, "ARTWORK", 1)
        lead = size + self.tokens.space.md
    end
    local title = K.text(frame, self.tokens.type.hero, true, 16 + lead, -12, 420)
    title:SetText("AdaptiveUI: A Wahf Production")
    local signature = frame:CreateTexture(nil, "ARTWORK")
    signature:SetPoint("TOPLEFT", frame, "TOPLEFT", 16 + lead, -38)
    signature:SetSize(236, 2)
    self:Tint(signature, "accent", "color")
    local measured = select(2, pcall(title.GetStringWidth, title))
    if type(measured) == "number" and measured > 40 then signature:SetWidth(math.min(420, measured)) end
    K.text(frame, DESC, false, 16 + lead, -46, 620 - lead, "LEFT", "muted"):SetText(
        "A WoW dad's answer to off-night couch gaming.")




    self:DressOptionsWindow(frame)
    local ui = { frame = frame, layout = "sections", nav = {}, rows = {}, pages = {}, refreshers = {},
                 view = { offset = 0 }, sections = {} }
    self.options_ui = ui
    self:MakeMovableWindow(frame, "Options", MAST)


    ui.search = K.editBox(frame, NAV_X, PAGE_TOP, NAV_W, 64)
    ui.searchHint = K.text(ui.search, DESC, false, 8, -6, NAV_W - 16, "LEFT", "muted")
    ui.searchHint:SetText("Search")
    local navTop = PAGE_TOP - 34
    for index, section in ipairs(self.optionSections) do
        local b = K.uiButton(frame, "", NAV_X, navTop - (index - 1) * NAV_PITCH, NAV_W, NAV_PITCH - 4, function()
            A:OpenOptionsSections(section.key)
        end)
        b.sectionKey = section.key
        b.section = section
        self:SetThemedFont(b.label, LABEL, false)
        b.label:SetText(section.label)
        b.label:ClearAllPoints()
        b.label:SetPoint("TOPLEFT", b, "TOPLEFT", 8, -4)
        b.caption = K.text(b, DESC, false, 8, -22, NAV_W - 16, "LEFT", "muted")
        b.caption:SetText(section.short or section.desc)

        b.mark = b:CreateTexture(nil, "OVERLAY")
        b.mark:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
        b.mark:SetSize(3, NAV_PITCH - 4)
        self:Tint(b.mark, "accent", "color", 1)
        ui.nav[section.key] = b
        ui.navOrder = ui.navOrder or {}
        ui.navOrder[#ui.navOrder + 1] = b
    end

    local scopeY = navTop - #self.optionSections * NAV_PITCH - 6
    local half = (NAV_W - 4) / 2
    ui.simpleButton = K.uiButton(frame, "Simple", NAV_X, scopeY, half, 30, function() A:SetOptionsMode(false) end)
    ui.advancedButton = K.uiButton(frame, "Advanced", NAV_X + half + 4, scopeY, half, 30, function() A:SetOptionsMode(true) end)
    for _, b in ipairs({ ui.simpleButton, ui.advancedButton }) do
        b.label:SetJustifyH("CENTER")
        b.mark = b:CreateTexture(nil, "OVERLAY")
        b.mark:SetPoint("TOPLEFT", b, "TOPLEFT", 0, -27)
        b.mark:SetSize(half, 3)
        self:Tint(b.mark, "accent", "color", 1)
    end

    ui.scope = { scripts = { OnClick = function() A:SetOptionsMode(A:GetOption("optionsAdvanced") ~= true) end } }
    ui.scopeCount = K.text(frame, DESC, false, NAV_X, scopeY - 34, NAV_W, "LEFT", "muted")
    ui.changedOnly = K.uiButton(frame, "", NAV_X, scopeY - 54, NAV_W, 28, function()
        A:SetOption("optionsChangedOnly", not A:GetOption("optionsChangedOnly"), true)
        ui.view.offset = 0
        A:RefreshOptionsSections()
    end)


    local page = CreateFrame("Frame", nil, frame)
    page:SetPoint("TOPLEFT", frame, "TOPLEFT", PAGE_X, PAGE_TOP)
    page:SetSize(PAGE_W, PAGE_H)
    ui.page = page
    K.fill(page, "BACKGROUND", "inkDeep", 0.35)
    page:EnableMouseWheel(true)
    page:SetScript("OnMouseWheel", function(_, delta)
        ui.view.offset = ui.view.offset - (delta > 0 and 1 or -1)
        A:RefreshOptionsSections()
    end)
    ui.earlier = K.uiButton(frame, "^  Earlier", PAGE_X, PAGE_TOP - PAGE_H - 2, 130, 22, function()
        ui.view.offset = ui.view.offset - 1; A:RefreshOptionsSections()
    end)
    ui.more = K.uiButton(frame, "v  More", PAGE_X + 138, PAGE_TOP - PAGE_H - 2, 130, 22, function()
        ui.view.offset = ui.view.offset + 1; A:RefreshOptionsSections()
    end)
    ui.earlier.auiScroll, ui.more.auiScroll = -1, 1
    ui.position = K.text(frame, DESC, false, PAGE_X + 280, PAGE_TOP - PAGE_H - 2, PAGE_W - 280, "RIGHT", "muted")






    ui.scrollTrack = frame:CreateTexture(nil, "ARTWORK")
    ui.scrollTrack:SetPoint("TOPLEFT", frame, "TOPLEFT", PAGE_X + PAGE_W + 6, PAGE_TOP)
    ui.scrollTrack:SetSize(4, PAGE_H)
    A:Tint(ui.scrollTrack, "muted", "color", 0.25)
    ui.scrollThumb = frame:CreateTexture(nil, "OVERLAY")
    ui.scrollThumb:SetWidth(4)
    A:Tint(ui.scrollThumb, "accent", "color", 0.85)
    ui.scrollTrack:Hide(); ui.scrollThumb:Hide()
    ui.empty = K.text(page, LABEL, false, 12, -14, PAGE_W - 24, "LEFT", "muted")
    ui.empty:SetText("Nothing matches. Try another word, or clear the search.")
    ui.search:SetScript("OnTextChanged", function()
        ui.searchHint:SetShown(ui.search:GetText() == "")
        ui.view.offset = 0
        ui.jump = nil
        A:RefreshOptionsSections()
    end)


    for _, option in ipairs(self.options) do
        if self:OptionSection(option) and not option.inline then
            local builder = rowBuilders[option.widget or option.type]
            if builder then
                local row = builder(page, option)
                row.option = option
                row.section, row.subsection = self:OptionSection(option)
                row.baseRefresh = row.refresh
                row.refresh = function()
                    row.baseRefresh()
                    row.tick:SetShown(A:OptionChanged(option.key))
                end
                row.reset = function() A:SetOption(option.key, A:ResetValue(option)) end
                row.sectionRow = true
                ui.rows[option.key] = row
            end
        end
    end

    ui.moverRows = {}
    for _, entry in ipairs(self.moverList) do
        local row = moverRow(page, entry)
        row.sectionRow = true
        row.section, row.subsection = "layout", "Every mover"
        row.entry = entry
        ui.moverRows[#ui.moverRows + 1] = row
    end


    ui.elementRows = {}
    for _, e in ipairs(self.elements or {}) do
        local row = elementRow(page, e)
        row.sectionRow = true
        row.section, row.subsection = "layout", "Every element"
        ui.elementRows[#ui.elementRows + 1] = row
    end
    ui.extraBarsRow = extraBarsRow(page)
    ui.extraBarsRow.sectionRow = true
    ui.extraBarsRow.section = "layout"
    ui.moverLock = actionRow(page, "Move things",
        "Unlock, then drag anything with the mouse, or use the arrows below.",
        function() A:ToggleMovers(); A:RefreshOptionsSections() end)
    ui.moverLock.sectionRow = true
    ui.moverLock.section = "layout"
    ui.moverLock.refresh = function()
        ui.moverLock.control.label:SetText(A.moversUnlocked and "Lock" or "Unlock")
    end
    ui.groupRows = {}
    for _, group in ipairs(self.layoutGroups) do
        local row = groupRow(page, group)
        row.sectionRow = true
        row.section = "layout"
        ui.groupRows[#ui.groupRows + 1] = row
        ui.groupRows[group.id] = row
    end
    ui.healthRow = healthRow(page)


    do
        local option = self.optionIndex.themeScheme
        local six = {}
        for _, id in ipairs(self.welcomeSchemes or {}) do
            for _, scheme in ipairs(self.schemes) do if scheme.id == id then six[#six + 1] = scheme end end
        end
        local row = rowFrame(page, ROW)
        row.kind = "picker"
        row.option = option
        row.label = K.text(row, LABEL, false, 10, -6, PAGE_W - 240)
        row.label:SetText(option.label)
        local refresh, used = K.builders.scheme(self, row, option, -30,
            { width = PAGE_W - 8, full = true, schemes = six, noInputs = true })
        row.more = K.uiButton(row, "More schemes", PAGE_W - 220, 2, 216, 26, function()
            ui.allSchemes = true
            A:RefreshOptionsSections()
        end)
        row.more.label:SetJustifyH("CENTER")
        row.control = row.more
        row.height0 = used * K.ROW_H + 38
        row:SetHeight(row.height0)
        row.tick:SetHeight(row.height0 - 8)
        row.refresh = function() refresh(); row.tick:SetShown(A:OptionChanged("themeScheme")) end
        row.reset = function() A:SetOption("themeScheme", A:ResetValue(option)) end
        ui.schemeSixRow = row
    end
    ui.healthRow.section = "combat"

    ui.presetRow = rowFrame(page)
    ui.presetRow.kind = "presets"
    describe(ui.presetRow, "Quick styles", "Sets a few things at once. Nothing else changes.", PAGE_W - 3 * 110 - 24)
    ui.presetRow.refresh = function() end
    ui.presetRow.sectionRow = true
    ui.presetButtons = {}
    for i, preset in ipairs(self.optionPresets) do
        local b = K.uiButton(ui.presetRow, preset.label, PAGE_W - (4 - i) * 110 + 4, 8, 104, ROW - 16, function()
            local ok, why = A:ApplyPreset(preset.key)
            if not ok then A:Print("Style not applied: " .. tostring(why)) end
        end)
        b.label:SetJustifyH("CENTER")
        b.preset = preset
        ui.presetButtons[i] = b
        ui.presetRow.control = ui.presetRow.control or b
    end

    ui.moduleRows = {}
    for _, module in ipairs(self.skinModules) do
        local row = moduleRow(page, module)
        row.module = module
        ui.moduleRows[#ui.moduleRows + 1] = row
        ui.moduleRows[module.key] = row
    end
    ui.reportRow = actionRow(page, "Report a problem",
        "Saves a report file and shows text you can copy into a message.", function() A:OpenReport() end, nil, "Open")
    ui.welcomeRow = actionRow(page, "Run the welcome again", "The one-minute setup: input, size, frames, look.",
        function() A:OpenWelcome() end, nil, "Open")
    ui.resetRows = {
        positions = actionRow(page, "Reset positions and sizes", "", function()
            local ok, count = A:ResetPositions()
            A:Print(ok and ("Positions and sizes reset (" .. count .. ").") or ("Not reset: " .. tostring(count)))
        end, function() return "reset:positions" end, "Reset"),
        profile = actionRow(page, "Reset this profile", "", function()
            local ok, err = A:ResetProfile()
            A:Print(ok and "Profile reset. Your other profiles are untouched." or ("Not reset: " .. tostring(err)))
        end, function() return "reset:" .. tostring(A.profileName) end, "Reset"),
        everything = actionRow(page, "Reset everything", "", function() A:Reset() end,
            function() return "reset:addon" end, "Reset"),
    }
    ui.resetRows.positions.refresh = function()
        local n = #A:ChangedKeys("layout")
        ui.resetRows.positions.desc:SetText(n == 0 and "Every moved or resized thing back in place. Nothing is moved now."
            or ("Every moved or resized thing back in place: " .. n .. " changed."))
    end
    ui.resetRows.profile.refresh = function()
        local n = #A:ChangedKeys(nil)
        ui.resetRows.profile.desc:SetText(string.format("All %d settings you changed on profile %s. Other profiles stay.",
            n, tostring(A.profileName)))
    end
    ui.resetRows.everything.refresh = function()
        ui.resetRows.everything.desc:SetText("This profile, and every Turn things off switch back on.")
    end

    ui.diagRows = {}
    for _, d in ipairs({
        { "About this build", "Which client build this is and how the addon treats it.", "build" },
        { "Show what loaded", "The last three logins and anything that came back empty.", "status" },
        { "Print screen sizes", "Every part of the HUD in screen pixels, in chat.", "measure" },
        { "Save the full frame report", "Writes the long report to your saved settings file.", "inspect" },
        { "Controller check", "What the game says about your controller, in chat.", "padprobe" },
        { "Retry disabled features", "Forgive a blocked action and try again after /reload.", "quarantine clear" },
    }) do
        local row = actionRow(page, d[1], d[2], function() A:Slash(d[3]) end)
        row.sectionRow = true
        ui.diagRows[#ui.diagRows + 1] = row
    end

    ui.classicRows = {
        actionRow(page, "Earlier bar, map and window looks", "Every action bar, map and window look of the release before.",
            function() A:SetCommand("set pass7 back") end, nil, "Apply"),
        actionRow(page, "Current looks", "Every action bar, map and window look as it ships now.",
            function() A:SetCommand("set pass7 on") end, nil, "Apply"),
    }

    ui.banner = rowFrame(page, 58)
    ui.banner.kind = "banner"
    ui.banner.rule = ui.banner:CreateTexture(nil, "ARTWORK")
    ui.banner.rule:SetPoint("TOPLEFT", ui.banner, "TOPLEFT", 0, -4)
    ui.banner.rule:SetSize(4, 50)
    self:Tint(ui.banner.rule, "accent", "color", 1)
    ui.banner.text = K.text(ui.banner, DESC, false, 14, -6, PAGE_W - 24, "LEFT", "text")
    ui.banner.text:SetWordWrap(true)
    ui.banner.text:SetHeight(48)
    ui.banner.refresh = function() end
    ui.inapplicableRow = actionRow(page, "Settings for another mode", "", function()
        ui.showInapplicable = not ui.showInapplicable
        A:RefreshOptionsSections()
    end, nil, "Show")

    ui.profilePage = CreateFrame("Frame", nil, page)
    ui.profilePage:SetSize(PAGE_W, 470)
    ui.profilePage:Hide()
    ui.profiles = K.buildProfiles(frame, ui.profilePage)

    ui.jumpRows = {}
    for _, topic in ipairs(self.jumpTopics) do
        local row = actionRow(page, topic[1], "Opens " .. (function()
            for _, s in ipairs(A.optionSections) do if s.key == topic[2] then return s.label end end
            return topic[2]
        end)() .. ".", function() A:JumpTo(topic[2], topic[3]) end, nil, "Go")
        row.topic = topic
        ui.jumpRows[#ui.jumpRows + 1] = row
    end


    ui.closeButton = K.uiButton(frame, "Close", WIDTH - 112, -(HEIGHT - 40), 96, 28, function() frame:Hide() end)
    ui.resetSection = K.confirmButton(frame, "Reset this page", 580, -(HEIGHT - 40), 240, 28,
        function() return "section:" .. tostring(ui.current) end, function()
            local ok, count = A:ResetPage()
            A:Print(ok and ("Reset " .. count .. " settings on this page.") or ("Not reset: " .. tostring(count)))
            A:RefreshOptionsSections()
        end)
    ui.legend = K.text(frame, DESC, false, NAV_X, -(HEIGHT - 38), 560, "LEFT", "muted")
    ui.legend:SetText("LB RB section   LT RT page   A choose   B back   Y jump   X reset")
    ui.legend:SetWordWrap(true)


    frame.auiFooter = { close = ui.closeButton, reset = ui.resetSection, legend = ui.legend,
                        home = { close = { WIDTH - 112, -(HEIGHT - 40) }, reset = { 580, -(HEIGHT - 40) },
                                 legend = { NAV_X, -(HEIGHT - 38), 560 } } }
    self:DressOptionsWindow(frame)

    self:AttachSettingsNavigation(frame, function()
        A:SetMoverPreview(false)
        A:LockMovers()
        ui.jump = nil
    end)
    self:SetGamepadShoulder(frame, function(direction)
        local visible = A:VisibleSections()
        local index = 1
        for i, key in ipairs(visible) do if key == ui.current then index = i end end
        A:OpenOptionsSections(visible[(index - 1 + direction) % #visible + 1])
    end)
    self:SetGamepadBack(frame, function()
        if ui.jump then ui.jump = nil; A:RefreshOptionsSections(); return true end
        return false
    end)


    local function onPage(w)
        while w do
            if w == page then return true end
            w = type(w.GetParent) == "function" and w:GetParent() or nil
        end
        return false
    end
    self:SetGamepadEdge(frame, function(direction, from, to)

        if not onPage(from) or (to and onPage(to)) then return nil end
        if direction == "down" and ui.more.shown then
            ui.view.offset = ui.view.offset + 1
            A:RefreshOptionsSections()
            return A:OptionsEdgeControl(direction)
        elseif direction == "up" and ui.view.offset > 0 then
            ui.view.offset = ui.view.offset - 1
            A:RefreshOptionsSections()
            return A:OptionsEdgeControl(direction)
        end
    end)
    self:SetGamepadExtra(frame, function(button, focused)
        if button == "PAD4" then

            ui.jump = not ui.jump or nil
            ui.view.offset = 0
            A:RefreshOptionsSections()
            A:GamepadHighlight(frame, ui.jump and ui.jumpRows[1].control or A:OptionsEdgeControl("up"))
            return true
        elseif button == "PAD3" and focused then

            local f = focused
            while f and f ~= page do
                if f.reset then f.reset(); A:RefreshOptionsSections(); return true end
                f = type(f.GetParent) == "function" and f:GetParent() or nil
            end
        elseif button == "PADLTRIGGER" or button == "PADRTRIGGER" then
            A:PageOptions(button == "PADRTRIGGER" and 1 or -1)
            return true
        elseif button == "PADRSTICKDOWN" or button == "PADRSTICKUP" then
            ui.view.offset = ui.view.offset + (button == "PADRSTICKDOWN" and 1 or -1)
            A:RefreshOptionsSections()
            A:KeepFocusOnPage()
            return true
        end
        return false
    end)
    frame:Hide()
    return ui
end


function A:VisibleSections()
    local out = {}
    local advanced = self:GetOption("optionsAdvanced") == true
    for _, s in ipairs(self.optionSections) do
        if advanced or not s.advanced then out[#out + 1] = s.key end
    end
    return out
end


function A:SetOptionsMode(advanced)
    local ui = self.options_ui
    local was = self:GetOption("optionsAdvanced") == true
    self:SetOption("optionsAdvanced", advanced and true or false, true)
    if advanced and not was and ui then ui.longBanner = self:GetOption("optionsAdvancedSeen") ~= true end
    if advanced then self:SetOption("optionsAdvancedSeen", true, true) end
    if not advanced and ui and ui.current == "classic" then ui.current = "look" end
    if not advanced then self:SetOption("optionsChangedOnly", false, true) end
    if ui then ui.view.offset = 0 end
    self:RefreshOptionsSections()
end


function A:OptionsCounts()
    local all, simple = 0, 0
    for _, option in ipairs(self.options) do
        if self:OptionSection(option) and not option.inline then
            all = all + 1
            if self:OptionIsBasic(option) then simple = simple + 1 end
        end
    end
    all = all + #self.moverList + #(self.elements or {})
    return all, simple
end



function A:OptionsEdgeControl(direction)
    local ui = self.options_ui
    if not ui then return nil end
    local list = ui.shownList or {}
    local pick = direction == "down" and list[#list] or list[1]
    return pick and (pick.control or pick) or nil
end

function A:KeepFocusOnPage()
    local ui = self.options_ui
    local nav = ui and self.gamepadNav and self.gamepadNav[ui.frame]
    if not nav then return end
    local current = nav.current
    local f, visible = current, current ~= nil
    while f do
        if type(f.IsShown) == "function" and not f:IsShown() then visible = false end
        f = type(f.GetParent) == "function" and f:GetParent() or nil
    end
    if not visible then self:GamepadHighlight(ui.frame, self:OptionsEdgeControl("up")) end
end


function A:PageOptions(direction)
    local ui = self.options_ui
    if not ui then return end
    local step = math.max(1, (ui.shownCount or 1) - 1)
    ui.view.offset = math.max(0, (ui.view.offset or 0) + direction * step)
    self:RefreshOptionsSections()
    self:GamepadHighlight(ui.frame, self:OptionsEdgeControl("up"))
end


local function rowChanged(row)
    if row.option then return A:OptionChanged(row.option.key) end
    if row.kind == "mover" then
        local ox, oy = A:MoverOffset(row.entry.id)
        local key = row.entry.scaleKey or ("scale." .. row.entry.id)
        return ox ~= 0 or oy ~= 0 or (A.optionIndex[key] and A:OptionChanged(key)) or false
    end
    if row.kind == "group" or row.kind == "health" or row.kind == "element" or row.kind == "extraBars" then
        for key in pairs(row.keys()) do if A:OptionChanged(key) then return true end end
        return false
    end
    if row.kind == "module" then return A.db.skins and A.db.skins[row.module.key] == false end
    return false
end


local function simpleItems(self, ui, section)
    local items = {}
    local function add(row) if row then items[#items + 1] = { row = row } end end
    local function addKeys()
        for _, key in ipairs(self.optionBasic[section] or {}) do
            local row = ui.rows[key]

            if key == "themeScheme" and ui.schemeSixRow and not ui.allSchemes then
                local current = self:GetOption("themeScheme")
                local six = false
                for _, id in ipairs(self.welcomeSchemes or {}) do if id == current then six = true end end
                if six then row = ui.schemeSixRow end
            end
            if row and not self:OptionInapplicable(row.option) then add(row) end
        end
    end
    if section == "look" then
        add(ui.presetRow); addKeys()
    elseif section == "layout" then
        add(ui.moverLock)
        for _, row in ipairs(ui.groupRows) do add(row) end

        if ui.extraBarsRow and #self:ExtraBarsShown() > 0 then add(ui.extraBarsRow) end
        addKeys()
    elseif section == "combat" then
        addKeys()
        if self.db.unitMode == "plus" then add(ui.healthRow) end
    elseif section == "profiles" then
        items[#items + 1] = { row = ui.profilePage, tall = 470 }
    elseif section == "help" then
        items[#items + 1] = { heading = "Turn things off" }
        for _, row in ipairs(ui.moduleRows) do add(row) end
        items[#items + 1] = { heading = "Help" }
        add(ui.reportRow); add(ui.welcomeRow)
        items[#items + 1] = { heading = "Reset" }
        add(ui.resetRows.positions); add(ui.resetRows.profile); add(ui.resetRows.everything)
    else
        addKeys()
    end
    return items
end


local function pageItems(self, ui)
    local items = {}
    if ui.jump then
        items[#items + 1] = { heading = "Jump to" }
        for _, row in ipairs(ui.jumpRows) do items[#items + 1] = { row = row } end
        return items, true
    end
    local term = ui.search and ui.search:GetText() or ""
    if term ~= "" then
        local seen = {}
        local function add(row) if row and not seen[row] then seen[row] = true; items[#items + 1] = { row = row } end end
        for _, extra in ipairs(self:SearchExtras(term)) do
            if extra.kind == "reset" then
                add(ui.resetRows.positions); add(ui.resetRows.profile); add(ui.resetRows.everything)
            elseif extra.kind == "turnoff" then
                for _, row in ipairs(ui.moduleRows) do add(row) end
            elseif extra.kind == "report" then add(ui.reportRow)
            elseif extra.kind == "welcome" then add(ui.welcomeRow)
            elseif extra.kind == "move" then
                add(ui.moverLock)
                for _, row in ipairs(ui.groupRows) do add(row) end
            elseif extra.kind == "group" then add(ui.groupRows[extra.id])
            elseif extra.kind == "profiles" and not seen[ui.profilePage] then
                seen[ui.profilePage] = true
                items[#items + 1] = { row = ui.profilePage, tall = 470 }
            end
        end
        if #items > 0 then table.insert(items, 1, { heading = "Tools" }) end
        local lastSection
        for _, hit in ipairs(self:SearchOptions(term)) do
            local row = ui.rows[hit.option.key]
            if row and not seen[row] then
                if hit.section ~= lastSection then
                    lastSection = hit.section
                    local label
                    for _, s in ipairs(self.optionSections) do if s.key == hit.section then label = s.label end end
                    items[#items + 1] = { heading = label .. "  /  " .. tostring(hit.subsection) }
                end
                add(row)
            end
        end
        return items, true
    end
    local section = ui.current
    local advanced = self:GetOption("optionsAdvanced") == true
    if not advanced then return simpleItems(self, ui, section), false end

    if section ~= "profiles" then items[#items + 1] = { row = ui.banner } end
    for _, item in ipairs(simpleItems(self, ui, section)) do items[#items + 1] = item end
    local shownSimple = {}
    for _, item in ipairs(items) do if item.row then shownSimple[item.row] = true end end
    local hidden = 0
    local more = {}
    local function applies(option)
        if self:OptionInapplicable(option) then
            if not ui.showInapplicable then hidden = hidden + 1; return false end
        end
        return true
    end
    for _, block in ipairs(self:SectionOptions(section, true, applies)) do
        local rows = {}
        for _, option in ipairs(block.options) do
            local row = ui.rows[option.key]
            if row and not shownSimple[row] then rows[#rows + 1] = row end
        end
        if #rows > 0 then
            more[#more + 1] = { heading = block.subsection }
            for _, row in ipairs(rows) do more[#more + 1] = { row = row } end
        end
    end
    if section == "layout" then
        more[#more + 1] = { heading = "Every mover" }
        for _, row in ipairs(ui.moverRows) do more[#more + 1] = { row = row } end

        more[#more + 1] = { heading = "Every element" }
        for _, row in ipairs(ui.elementRows or {}) do more[#more + 1] = { row = row } end
    elseif section == "help" then
        more[#more + 1] = { heading = "Diagnostics" }
        for _, row in ipairs(ui.diagRows) do more[#more + 1] = { row = row } end
    elseif section == "classic" then
        more[#more + 1] = { heading = "All at once" }
        for _, row in ipairs(ui.classicRows) do more[#more + 1] = { row = row } end
    end
    if #more > 0 and section ~= "classic" then items[#items + 1] = { heading = "More on this page" } end
    for _, item in ipairs(more) do items[#items + 1] = item end
    if hidden > 0 or ui.showInapplicable then
        ui.inapplicableCount = hidden
        items[#items + 1] = { row = ui.inapplicableRow }
    end


    if self:GetOption("optionsChangedOnly") == true then
        local kept = {}
        for _, item in ipairs(items) do
            if item.heading or item.row == ui.banner or (item.row and rowChanged(item.row)) then kept[#kept + 1] = item end
        end
        items = {}
        for i, item in ipairs(kept) do
            local nextItem = kept[i + 1]
            if not (item.heading and (not nextItem or nextItem.heading)) then items[#items + 1] = item end
        end
    end
    return items, false
end
A.OptionsPageItems = pageItems



function A:ResetPage()
    local ui = self.options_ui
    if not ui then return false, "no window" end
    local section = ui.current
    if self:GetOption("optionsAdvanced") == true then
        if section == "help" then
            for _, row in ipairs(ui.moduleRows) do row.reset() end
            return true, #ui.moduleRows
        end
        return self:ResetSection(section)
    end
    local keys, any = {}, false
    for _, item in ipairs(simpleItems(self, ui, section)) do
        local row = item.row
        if row and row.option then keys[row.option.key] = true; any = true end
        if row and row.keys then for k in pairs(row.keys()) do keys[k] = true; any = true end end
    end
    if section == "help" then
        for _, row in ipairs(ui.moduleRows) do row.reset() end
        return true, #ui.moduleRows
    end
    if not any then return false, "nothing to reset" end
    return self:ResetSection(section, keys)
end


function A:ResetPositions()
    if self:IsCombat() then return false, "combat" end
    local keys = {}
    for _, option in ipairs(self.options) do
        if option.tab == "movers" or option.key:find("^scale%.") then keys[option.key] = true end
    end
    for _, key in ipairs({ "scale", "dockScale", "minimapScale", "keyboardMicroScale", "tooltipScale" }) do
        if self.optionIndex[key] then keys[key] = true end
    end
    for _, group in ipairs(self.layoutGroups) do
        local entry = moverEntry(group.mover(self))
        if entry and entry.key then keys[entry.key] = true end
    end
    for _, entry in ipairs(self.moverList) do if entry.key then keys[entry.key] = true end end
    local ok, count = self:ResetSection("layout", keys)
    return ok, count
end


function A:JumpTo(section, target)
    local ui = self.options_ui
    if not ui then return end
    ui.jump = nil
    self:OpenOptionsSections(section)
    if not target then return end
    local want
    if target == "@moverLock" then want = ui.moverLock
    elseif target == "@health" then want = ui.healthRow
    elseif target == "@report" then want = ui.reportRow
    elseif target:find("^@group:") then want = ui.groupRows[target:sub(8)]
    elseif target:find("^@module:") then want = ui.moduleRows[target:sub(9)]
    elseif target:find("^@reset:") then want = ui.resetRows[target:sub(8)]
    else want = ui.rows[target] end
    local items = pageItems(self, ui)
    for i, item in ipairs(items) do
        if item.row == want then ui.view.offset = math.max(0, i - 1); break end
    end
    self:RefreshOptionsSections()
    if want and want.control then self:GamepadHighlight(ui.frame, want.control) end
end



function A:RefreshOptionsSections()
    local ui = self.options_ui
    if not ui or ui.layout ~= "sections" then return end
    local frame, page = ui.frame, ui.page
    self:DressOptionsWindow(frame)
    local advanced = self:GetOption("optionsAdvanced") == true
    if not advanced and ui.current == "classic" then ui.current = "look" end
    ui.current = ui.current or "look"
    local items, searching = pageItems(self, ui)
    ui.items = items

    local heights = {}
    for i, item in ipairs(items) do
        heights[i] = item.heading and HEAD or (item.tall or (item.row.height0 or ROW))
    end
    local maxOffset = 0
    do

        local total = 0
        for i = #items, 1, -1 do
            total = total + heights[i]
            if total > PAGE_H then maxOffset = i; break end
        end
    end
    ui.view.offset = math.max(0, math.min(maxOffset, ui.view.offset or 0))
    ui.headings = ui.headings or {}
    for _, h in ipairs(ui.headings) do h:Hide() end
    for _, row in pairs(ui.rows) do row:Hide() end
    for _, list in ipairs({ ui.moverRows, ui.groupRows, ui.diagRows, ui.moduleRows, ui.jumpRows, ui.classicRows,
        ui.elementRows or {} }) do
        for _, row in ipairs(list) do row:Hide() end
    end
    if ui.extraBarsRow then ui.extraBarsRow:Hide() end
    for _, row in pairs(ui.resetRows) do row:Hide() end
    if ui.schemeSixRow then ui.schemeSixRow:Hide() end
    ui.presetRow:Hide(); ui.healthRow:Hide(); ui.banner:Hide(); ui.inapplicableRow:Hide()
    ui.moverLock:Hide(); ui.welcomeRow:Hide(); ui.reportRow:Hide(); ui.profilePage:Hide()

    local all, simple = self:OptionsCounts()
    if advanced then
        ui.banner.text:SetText(ui.longBanner
            and string.format("ADVANCED: every setting AdaptiveUI has, %d of them. This is extreme customization: nothing "
                .. "here is needed to play, and Simple keeps every change you make. A tick marks what you changed; X resets a row.", all)
            or string.format("ADVANCED: all %d settings. Nothing here is needed to play; Simple keeps your changes.", all))
        ui.banner.text:SetHeight(ui.longBanner and 48 or 32)
    end
    if ui.inapplicableRow and ui.inapplicableCount then
        ui.inapplicableRow.label:SetText(ui.showInapplicable and "Settings for another mode are shown"
            or (ui.inapplicableCount .. " more settings for another mode"))
        ui.inapplicableRow.desc:SetText(ui.showInapplicable and "They do nothing until you switch mode or frames."
            or "They apply only with the other bars or with plates.")
        ui.inapplicableRow.control.label:SetText(ui.showInapplicable and "Hide" or "Show")
    end
    local y, used, shown = 0, 0, 0
    local headingIndex = 0
    ui.shownList = {}
    for i = ui.view.offset + 1, #items do
        local item, h = items[i], heights[i]
        if y + h > PAGE_H then break end


        if item.heading and items[i + 1] and not items[i + 1].heading and y + h + heights[i + 1] > PAGE_H then break end
        if item.heading then
            headingIndex = headingIndex + 1
            local hf = ui.headings[headingIndex]
            if not hf then
                hf = headingRow(page, item.heading)
                ui.headings[headingIndex] = hf
            end
            hf.text:SetText(string.upper(item.heading))
            hf:ClearAllPoints()
            hf:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
            hf:Show()
        else
            local row = item.row
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
            row:Show()
            if row.refresh then row.refresh() end
            shown = shown + 1
            if row.control then ui.shownList[#ui.shownList + 1] = row end
        end
        y = y + h
        used = i
    end
    ui.shownRows = shown
    ui.shownCount = used - ui.view.offset
    ui.empty:SetText(self:GetOption("optionsChangedOnly") == true and not searching
        and "Nothing on this page is changed from its default." or "Nothing matches. Try another word, or clear the search.")
    ui.empty:SetShown(#items == 0)
    ui.earlier:SetShown(ui.view.offset > 0)
    ui.more:SetShown(used < #items)
    ui.position:SetText(#items > 0 and (used < #items or ui.view.offset > 0)
        and string.format("%d to %d of %d", ui.view.offset + 1, used, #items) or "")

    if ui.scrollTrack then
        local total, onScreen = #items, used - ui.view.offset
        local scrolls = total > 0 and (used < total or ui.view.offset > 0)
        ui.scrollTrack:SetShown(scrolls)
        ui.scrollThumb:SetShown(scrolls)
        if scrolls then
            local h = math.max(24, PAGE_H * onScreen / total)
            local travel = math.max(1, total - onScreen)
            local top = (PAGE_H - h) * math.min(1, ui.view.offset / travel)
            ui.scrollThumb:ClearAllPoints()
            ui.scrollThumb:SetPoint("TOPLEFT", ui.scrollTrack, "TOPLEFT", 0, -top)
            ui.scrollThumb:SetHeight(h)
        end
    end
    if ui.current == "profiles" and not searching then ui.profiles.refresh() end

    for key, b in pairs(ui.nav) do
        local on = key == ui.current and not searching
        b:SetShown(advanced or not b.section.advanced)
        b.mark:SetShown(on)
        b.bg:SetAlpha(on and 1 or 0.55)
    end
    ui.simpleButton.mark:SetShown(not advanced); ui.advancedButton.mark:SetShown(advanced)
    ui.simpleButton.bg:SetAlpha(advanced and 0.55 or 1); ui.advancedButton.bg:SetAlpha(advanced and 1 or 0.55)
    ui.scopeCount:SetText(advanced and string.format("All %d settings", all)
        or string.format("Advanced: %d more", all - simple))
    ui.changedOnly:SetShown(advanced)
    ui.changedOnly.label:SetText(self:GetOption("optionsChangedOnly") == true and "Showing: what I changed"
        or "Only what I changed")
    ui.resetSection:SetShown(ui.current ~= "profiles" and not searching and not ui.jump)
    self:SetMoverPreview(frame:IsShown() and ui.current == "layout" and not searching)
    if not (ui.current == "layout" and not searching) and self.moversUnlocked then self:LockMovers() end
    self:RefreshConfirmLabels()
end



function A:OpenOptionsSections(target)
    local ui = self.options_ui
    if not ui or ui.layout ~= "sections" then return end
    local section, subsection = self:SectionKey(target), nil
    if target and not section then
        if target == "movers" then
            section, subsection = "layout", nil
        elseif self.optionGroupSection[target] then
            section, subsection = self.optionGroupSection[target][1], self.optionGroupSection[target][2]
        end
    end

    if section == "classic" and self:GetOption("optionsAdvanced") ~= true then self:SetOptionsMode(true) end
    if ui.search and ui.search:GetText() ~= "" and section then ui.search:SetText("") end
    local changed = section and section ~= ui.current
    ui.current = section or ui.current or "look"
    ui.jump = nil
    if changed or subsection then ui.view.offset = 0 end
    if subsection then


        local function find()
            for i, item in ipairs(pageItems(self, ui)) do
                if item.heading == subsection then ui.view.offset = i - 1; return true end
            end
        end
        if not find() then
            if self:GetOption("optionsAdvanced") ~= true then self:SetOptionsMode(true) end
            if not find() then ui.showInapplicable = true; find() end
        end
    end
    if self.settings then self.settings:Hide() end
    if self.nativeSettings then self.nativeSettings:Hide() end
    if self.layoutSettings then self.layoutSettings:Hide() end
    ui.frame:SetScale(self:WindowScale(WIDTH, HEIGHT))
    self:RefreshOptionsSections()
    self:PlaceWindow(ui.frame, "Options")
    ui.frame:Show()
    pcall(ui.frame.Raise, ui.frame)
    self:RefreshOptionsSections()
end
