local _, A = ...




































A.formLabelStyle = {
    gap = 6,
    topGap = 2,
    laneGap = 2,
    studGap = 6,
    classicGap = 4,
    fadeIn = 0.15, fadeOut = 0.25, flashHold = 2.5, flashFade = 0.4,
    pulseIn = 0.15, pulseOut = 0.45, pulsePeak = 0.55,
    preview = 3,
    tick = 0.25,
}

A.formPadSlots = 8



A.formUsualBar = {
    [768] = 7,
    [5487] = 9, [9634] = 9,
    [24858] = 10,
    [783] = 0, [1066] = 0,
    [2457] = 7, [71] = 8, [2458] = 9,
    [1784] = 7, [1785] = 7, [1786] = 7, [1787] = 7,
    [2645] = 0,
}


local FB = { gen = 0 }
A.formBarsState = FB






local function api(name)
    local t = rawget(_G, "C_ActionBar")
    local fn = type(t) == "table" and t[name] or nil
    if type(fn) == "function" then return fn end
    fn = rawget(_G, name)
    return type(fn) == "function" and fn or nil
end
A.FormApi = function(_, name) return api(name) end


local function needBool(self, name, ...)
    local fn = api(name)
    if not fn then return nil, "missing" end
    local v, status = self:Read(fn, 1, ...)
    if type(v) ~= "boolean" then return nil, status ~= "public" and status or "not a boolean" end
    return v, "public"
end



local function optBool(self, fn, ...)
    if type(fn) ~= "function" then return false, "missing" end
    local v, status = self:Read(fn, 1, ...)
    if type(v) == "boolean" then return v, "public" end
    if v == nil and status == "public" then return false, "public" end
    return nil, status
end

local function readCVar(self, name)
    local get = (type(C_CVar) == "table" and C_CVar.GetCVar) or rawget(_G, "GetCVar")
    if type(get) ~= "function" then return nil, "missing" end
    local v, status = self:Read(get, 1, name)
    if v == nil then return nil, status == "public" and "missing" or status end
    if type(v) ~= "string" and type(v) ~= "number" then return nil, "restricted" end
    return tostring(v), "public"
end






A.stanceOverrideArms = {
    [2] = { 1, "left" }, [3] = { 1, "right" }, [4] = { 1, "bottom" },
    [5] = { 2, "top" }, [6] = { 2, "left" }, [7] = { 2, "right" }, [8] = { 2, "bottom" },
    [9] = { 3, "top" }, [10] = { 3, "left" }, [11] = { 3, "right" }, [12] = { 3, "bottom" },
}
local stanceNames
function A:StanceOverrideInfo()
    local raw, status = readCVar(self, "GamepadStanceBarOverride")
    local value = raw and tonumber(raw) or nil
    local info = { raw = raw, status = status, value = value }
    local enum = type(Enum) == "table" and rawget(Enum, "GamepadStanceBarOverride") or nil
    info.enum = type(enum) == "table" and "public" or "missing"
    if stanceNames == nil then
        stanceNames = {}
        for name, v in pairs(type(enum) == "table" and enum or {}) do
            if type(name) == "string" and type(v) == "number" then stanceNames[v] = name end
        end
    end
    if not value then return info end
    info.name = stanceNames[value]
    local noneValue = type(enum) == "table" and type(rawget(enum, "None")) == "number" and enum.None or 1
    if value == noneValue then
        info.none = true
        return info
    end
    local arm = A.stanceOverrideArms[value]
    if arm then info.page, info.arm = arm[1], arm[2] end
    return info
end

function A:ForgetStanceNames() stanceNames = nil end


local ARM_WORDS = { left = "LT", right = "RT", bottom = "LT + RT", top = "the top arm" }
function A:StanceArmWords(info)
    if not info or info.none then return nil end
    if not info.arm then return nil end
    return string.format("%s, page %d", ARM_WORDS[info.arm] or info.arm, info.page or 1)
end




function A:FormFamily()
    local kb, pad = rawget(_G, "MainActionBar"), rawget(_G, "GamepadMainActionBarFrame")
    local ks, ps = false, false
    if type(kb) == "table" then ks = self:Read(kb.IsShown, 1, kb) end
    if type(pad) == "table" then ps = self:Read(pad.IsShown, 1, pad) end
    if type(ks) == "boolean" and type(ps) == "boolean" then
        if ks and not ps then return "keyboard" end
        if ps and not ks then return "controller" end
        return nil
    end
    local mode = self:EffectiveInput()
    if mode == "controller" or mode == "keyboard" then return mode end
    return nil
end



function A:GamepadPageNow()
    local root = rawget(_G, "GamepadMainActionBarFrame")
    local pu = type(root) == "table" and root.PageUnit or nil
    if type(pu) ~= "table" then return nil end
    for _, holder in ipairs({ pu.PageTracker, pu }) do
        if type(holder) == "table" then
            local v = rawget(holder, "currentPage")
            if type(v) == "number" and self:IsPublic(v) then return v end
        end
    end
    return nil
end


local function formInfo(self, i)
    local fn = rawget(_G, "GetShapeshiftFormInfo")
    if type(fn) ~= "function" then return nil end
    local icon = self:Read(fn, 1, i)
    local active = self:Read(fn, 2, i)
    local spellID = self:Number(fn, 4, i)
    local name
    if spellID and type(C_Spell) == "table" then name = self:Text(C_Spell.GetSpellName, 1, spellID) end
    local short = name and name:gsub(" Form$", ""):gsub(" Stance$", "") or nil
    return { index = i, spellID = spellID, name = name, short = short,
             icon = (type(icon) == "number" or type(icon) == "string") and icon or nil,
             active = active == true }
end


function A:BarFill(index, count, first)
    local has = api("HasAction")
    if not has or type(index) ~= "number" then return nil end
    count = count or 12
    first = first or ((index - 1) * 12 + 1)
    local n = 0
    for slot = first, first + count - 1 do
        local v = self:Read(has, 1, slot)
        if v == nil then return nil end
        if v == true then n = n + 1 end
    end
    return n, count
end




function A:FormState()
    local s = { forms = {} }
    local num = rawget(_G, "GetNumShapeshiftForms")
    s.numForms = type(num) == "function" and self:Number(num, 1) or nil
    for i = 1, math.min(10, s.numForms or 0) do s.forms[i] = formInfo(self, i) end
    local current = rawget(_G, "GetShapeshiftForm")
    s.formIndex = type(current) == "function" and self:Number(current, 1) or nil
    if s.formIndex and s.formIndex > 0 then
        s.active = s.forms[s.formIndex] or formInfo(self, s.formIndex)
    end
    s.bonus = needBool(self, "HasBonusActionBar")
    s.page = self:Number(api("GetActionBarPage"), 1)
    s.bonusIndex = self:Number(api("GetBonusBarIndex"), 1)
    s.bonusOffset = self:Number(api("GetBonusBarOffset"), 1)
    if not s.bonusIndex and s.bonusOffset and s.bonusOffset > 0 then s.bonusIndex = 6 + s.bonusOffset end
    s.vehicle = optBool(self, api("HasVehicleActionBar"))
    s.override = optBool(self, api("HasOverrideActionBar"))
    s.temp = optBool(self, api("HasTempShapeshiftActionBar"))
    s.possess = optBool(self, rawget(_G, "IsPossessBarVisible"))
    local pb = rawget(_G, "C_PetBattles")
    s.petBattle = optBool(self, type(pb) == "table" and pb.IsInBattle or nil)
    s.outranked = s.vehicle ~= false or s.override ~= false or s.temp ~= false or s.possess ~= false
        or s.petBattle ~= false
    s.family = self:FormFamily()
    s.stance = self:StanceOverrideInfo()
    s.padPage = self:GamepadPageNow()
    return s
end




function A:FormLabelMode()
    if not (self.db and self.optionIndex and self.optionIndex.formLabel) then return "off" end
    if self.Look and self:Look() == "blizzard" then return "off" end
    if type(self.db.skins) == "table" and self.db.skins.actions == false then return "off" end
    return self:GetOption("formLabel")
end





function A:FormLabelPlan(s)
    s = s or self:FormState()
    local f = s.active
    if not f or not f.spellID or not f.short then return nil, "no readable form" end
    if s.bonus ~= true then return nil, "the form pages nothing" end
    if s.outranked then return nil, "a vehicle, override, possess, temp or pet battle bar outranks it" end
    local family = s.family
    if family == "keyboard" then
        if s.page ~= 1 then return nil, "a page the player chose" end
        if not s.bonusIndex then return nil, "no readable bonus bar" end
        local n = self:BarFill(s.bonusIndex)
        local empty = n == 0
        local tail = "  bar " .. s.bonusIndex
        local long, short = tail, tail
        if empty then
            short = tail .. "  empty"
            long = self:IsCombat() and short or (tail .. "  empty: drag moves here")
        end
        return { family = "keyboard", word = f.short, tail = long, tailShort = short, tailMin = tail,
                 empty = empty, bonusIndex = s.bonusIndex, spellID = f.spellID }
    elseif family == "controller" then
        local st = s.stance
        if not st or st.none or not st.arm then return nil, "the Stance bar takes no arm" end
        local page = s.padPage
        if page and page ~= st.page then return nil, "the form's arm is on another page" end
        if not page and st.page ~= 1 then return nil, "the gamepad page cannot be read" end

        if not self:FormLegendAnchor(st.arm) then return nil, "Blizzard hides the arm's legend" end
        local empty
        local gp = rawget(_G, "C_GamepadUI")
        local first = type(gp) == "table"
            and self:Number(gp.GetFirstGamepadActionBarStorageSlotIndexForActiveStance, 1) or nil
        if first then empty = self:PadEmptyKnown(first, A.formPadSlots) == true end
        return { family = "controller", word = f.short, tail = empty and "  empty" or "",
                 tailShort = empty and "  empty" or "", tailMin = "", empty = empty == true,
                 arm = st.arm, page = st.page, spellID = f.spellID }
    end
    return nil, "no single bar family on screen"
end





function A:BarFillFrom(first, count)
    local has = api("HasAction")
    if not has then return nil end
    local n = 0
    for slot = first, first + count - 1 do
        local v = self:Read(has, 1, slot)
        if v == nil then return nil end
        if v == true then n = n + 1 end
    end
    if n > 0 then FB.padSlotsConfirmed = true end
    return n
end
function A:PadEmptyKnown(first, count)
    local n = self:BarFillFrom(first, count)
    if n == nil then return nil end
    if not FB.padSlotsConfirmed then return nil end
    return n == 0
end



local LEGEND = { left = "LeftIcon", right = "RightIcon", bottom = "CenteredIcons" }
function A:FormLegendAnchor(arm)
    local root = rawget(_G, "GamepadMainActionBarFrame")
    local pu = type(root) == "table" and root.PageUnit or nil
    if type(pu) ~= "table" then return nil end
    if arm == "top" then




        local anchor = pu.TopCenteredAnchor
        if type(anchor) == "table" then return anchor, "anchor" end
        return nil
    end
    local key = LEGEND[arm]
    local icon = key and pu[key]
    if type(icon) ~= "table" then return nil end
    if self:Read(icon.IsShown, 1, icon) ~= true then return nil end
    local state = self.nativeSkins and self.nativeSkins.actions
    local entries = state and state.decorations[root]
    local chip = entries and entries["trigger" .. key]
    if chip and chip:IsShown() then return chip, "chip" end
    return icon, "legend"
end





local function labelFrame(self)
    if FB.frame then return FB.frame end
    local f = self:Own(CreateFrame("Frame", nil, UIParent))
    pcall(f.EnableMouse, f, false)
    pcall(f.SetFrameStrata, f, "MEDIUM")
    pcall(f.SetFrameLevel, f, 100)
    f:SetSize(10, 10)
    f.word = self:Own(f:CreateFontString(nil, "OVERLAY"))
    f.tail = self:Own(f:CreateFontString(nil, "OVERLAY"))
    self:SetPixelFont(f.word, "body", 1, false, "OUTLINE")
    self:SetPixelFont(f.tail, "body", 1, false, "OUTLINE")
    f.word:SetText("")
    f.tail:SetText("")
    self:Tint(f.word, "text", "text")
    self:Tint(f.tail, "muted", "text")
    f:SetAlpha(0)
    f:Hide()
    FB.frame = f
    return f
end



function A:FormLabelTypeRatio(frame)
    local us = self:Number(UIParent.GetEffectiveScale, 1, UIParent)
    local fs = frame and self:Number(frame.GetEffectiveScale, 1, frame)
    if not (us and fs and us > 0.05 and fs > 0.05) then return 1 end
    return fs / us
end

local function width(self, region)
    return self:Number(region.GetStringWidth, 1, region) or 0
end



function A:FormPlankSeat(lineH)
    if not (self.KeyboardSkinOn and self:KeyboardSkinOn() and self:KeyboardBase()) then return nil end
    local host, rect = self:XpLaneHost()
    if not (host and rect and host:IsShown()) then return nil end
    local a = self:KeyboardPlank()
    local hs = self:Number(host.GetEffectiveScale, 1, host)
    local us = self:Number(UIParent.GetEffectiveScale, 1, UIParent)
    local k = (hs and us and us > 0.05) and hs / us or 1
    local w, h = rect.w, rect.h
    local faceTop, faceBot, studU
    if a.slate then
        faceTop, faceBot, studU = a.seatV0, a.ledgeV0, a.studU0
    else
        faceTop, faceBot, studU = a.faceV0, a.footV0, a.bossU0
    end


    local rowBottom = ((h / 2 - (rect.pageY or 0)) + (rect.rowH or 0) / 2) * k
    local visTop = math.max(h * faceTop * k, rowBottom)
    local visBot = h * faceBot * k


    local laneTop
    if a.slate or not a.laneTop then
        local _, ly = self:XpLaneRect(rect)
        laneTop = ly and ly * k or nil
    end
    if laneTop then visBot = math.min(visBot, laneTop - A.formLabelStyle.laneGap) end
    local left = w * (a.topU0 or 0) * k
    local room = (w * (studU or 1) * k) - left - A.formLabelStyle.studGap
    local seat = { host = host, left = left, room = room, laneTop = laneTop, k = k,
                   faceTop = h * faceTop * k, faceBot = h * faceBot * k, visTop = visTop, visBot = visBot }
    if visBot - visTop < lineH - 1e-6 then

        seat.beside = true
        return seat
    end
    seat.top = (visTop + visBot) / 2 - lineH / 2
    return seat
end


function A:FormLabelPlace(plan)
    local f = labelFrame(self)
    local ratio = self:FormLabelTypeRatio(f)
    self:SetPixelFont(f.word, "body", ratio, false, "OUTLINE")
    self:SetPixelFont(f.tail, "body", ratio, false, "OUTLINE")
    local _, size = f.word:GetFont()
    local lineH = tonumber(size) or 14
    f.word:SetText(plan.word)
    f.word:ClearAllPoints(); f.tail:ClearAllPoints(); f:ClearAllPoints()
    FB.seat = nil
    if plan.family == "keyboard" then
        local seat = self:FormPlankSeat(lineH)
        local tail = plan.tail
        if seat and seat.beside then
            local bar = rawget(_G, "MainActionBar")
            local block = type(bar) == "table" and bar.ActionBarPageNumber or nil
            local b1 = rawget(_G, "ActionButton1")
            local beside = (type(block) == "table" and self:Read(block.IsShown, 1, block) == true) and block or b1
            if type(beside) ~= "table" then return false end
            f.tail:SetText(tail)
            f:SetPoint("RIGHT", beside, "LEFT", -A.formLabelStyle.gap, 0)
            FB.seat = seat
            FB.tailShown = tail
            f.tail:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
            f.word:SetPoint("RIGHT", f.tail, "LEFT", 0, 0)
            local w = width(self, f.word) + width(self, f.tail)
            f:SetSize(math.max(1, w), lineH)
            FB.lineH = lineH
            return true
        elseif seat then

            for _, t in ipairs({ plan.tail, plan.tailShort, plan.tailMin }) do
                tail = t
                f.tail:SetText(t)
                if width(self, f.word) + width(self, f.tail) <= seat.room then break end
            end
            f:SetPoint("TOPLEFT", seat.host, "TOPLEFT", seat.left, -seat.top)
            FB.seat = seat
        else
            local b1 = rawget(_G, "ActionButton1")
            if type(b1) ~= "table" then return false end
            f.tail:SetText(tail)
            f:SetPoint("BOTTOMLEFT", b1, "TOPLEFT", 0, A.formLabelStyle.classicGap)
        end
        FB.tailShown = tail
        f.word:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
        f.tail:SetPoint("LEFT", f.word, "RIGHT", 0, 0)
    else
        local anchor = self:FormLegendAnchor(plan.arm)
        if not anchor then return false end
        f.tail:SetText(plan.tail)
        FB.tailShown = plan.tail
        local gap = A.formLabelStyle.gap
        if plan.arm == "right" then

            f:SetPoint("RIGHT", anchor, "LEFT", -gap, 0)
            f.tail:SetPoint("RIGHT", f, "RIGHT", 0, 0)
            f.word:SetPoint("RIGHT", f.tail, "LEFT", 0, 0)
        elseif plan.arm == "top" then
            f:SetPoint("BOTTOM", anchor, "TOP", 0, A.formLabelStyle.topGap)
            f.word:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
            f.tail:SetPoint("LEFT", f.word, "RIGHT", 0, 0)
        else
            f:SetPoint("LEFT", anchor, "RIGHT", gap, 0)
            f.word:SetPoint("LEFT", f, "LEFT", 0, 0)
            f.tail:SetPoint("LEFT", f.word, "RIGHT", 0, 0)
        end
    end
    local w = width(self, f.word) + width(self, f.tail)
    f:SetSize(math.max(1, w), lineH)
    if f.pulse then
        f.pulse:ClearAllPoints()
        f.pulse:SetPoint("CENTER", f.word, "CENTER", 0, 0)
        f.pulse:SetSize(width(self, f.word) + 2 * lineH, lineH * 2)
    end
    FB.lineH = lineH
    return true
end




local function after(delay, fn)
    if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
        pcall(C_Timer.After, delay, fn)
        return true
    end
    return false
end

local function fadeGroup(self, f, key, from, to, duration)
    return self:MotionGroup(f, key, function(group, anim)
        local a = anim(group, "Alpha", 1, duration, 0, to > from and "OUT" or "IN")
        if a then a:SetFromAlpha(from); a:SetToAlpha(to) end
        pcall(group.SetToFinalAlpha, group, true)
    end)
end

local function stopAll(self, f)
    local store = self.motionGroups[f]
    for _, g in pairs(store or {}) do pcall(g.Stop, g) end
    local pstore = f.pulse and self.motionGroups[f.pulse]
    for _, g in pairs(pstore or {}) do pcall(g.Stop, g) end
end

local function pulse(self, f)
    if not self:MotionRepeats() then return end
    local fx = f.pulse
    if not fx then
        fx = self:Fx(f, "formPulse", "bar-bloom", "BACKGROUND", 1)
        if not fx then return end
        f.pulse = fx
        fx:ClearAllPoints()
        fx:SetPoint("CENTER", f.word, "CENTER", 0, 0)
        fx:SetSize(width(self, f.word) + 2 * (FB.lineH or 14), (FB.lineH or 14) * 2)
        local r, g, b = self:Color("accent")
        fx.light:SetVertexColor(r, g, b, 1)
    end
    local st = A.formLabelStyle
    local group = self:MotionGroup(fx, "formPulse", function(gr, anim)
        local rise = anim(gr, "Alpha", 1, st.pulseIn, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(st.pulsePeak) end
        local fall = anim(gr, "Alpha", 2, st.pulseOut, 0, "IN")
        if fall then fall:SetFromAlpha(st.pulsePeak); fall:SetToAlpha(0) end
    end)
    if group then
        fx:Show(); fx:SetAlpha(0)
        pcall(group.Stop, group); pcall(group.Play, group)
    end
end


local function showLabel(self, flash, pulseIt)
    local f = labelFrame(self)
    FB.gen = FB.gen + 1
    local gen = FB.gen
    stopAll(self, f)
    f:Show()
    local st = A.formLabelStyle
    if self:MotionOn() then
        if not FB.visible then f:SetAlpha(0) end
        local g = fadeGroup(self, f, "formIn", 0, 1, st.fadeIn)
        if g and not FB.visible then pcall(g.Play, g) else f:SetAlpha(1) end
        if pulseIt then pulse(self, f) end
    else
        f:SetAlpha(1)
    end
    FB.visible = true
    if flash and not (FB.plan and FB.plan.empty) then
        after(st.flashHold, function()
            if FB.gen ~= gen then return end
            A:FormLabelHide(st.flashFade)
        end)
    end
end

function A:FormLabelHide(duration)
    local f = FB.frame
    FB.visible = false
    if not f or not f:IsShown() then return end
    FB.gen = FB.gen + 1
    local gen = FB.gen
    stopAll(self, f)
    if self:MotionOn() then
        local key = duration == A.formLabelStyle.flashFade and "formFlashOut" or "formOut"
        local g = fadeGroup(self, f, key, 1, 0, duration or A.formLabelStyle.fadeOut)
        if g then
            f:SetAlpha(1)
            pcall(g.Play, g)
            after(duration or A.formLabelStyle.fadeOut, function()
                if FB.gen == gen and f then f:Hide() end
            end)
            return
        end
    end
    f:SetAlpha(0)
    f:Hide()
end






local function planKey(plan, mode)
    if not plan then return "none|" .. tostring(mode) end
    return table.concat({ mode, plan.family, plan.word, tostring(plan.empty), tostring(plan.arm), tostring(plan.page),
        tostring(plan.bonusIndex) }, "|")
end


local function placeKey(plan)
    return plan and (plan.tail .. "|" .. plan.tailShort) or "-"
end



local function cheapKey(self)
    local rect = self.XpLaneHost and select(2, self:XpLaneHost())
    return table.concat({ tostring(self:FormLabelMode()), tostring(self:MotionLevel()),
        tostring(self.KeyboardSkin and self:KeyboardSkin()), rect and string.format("%.2f|%.2f|%.2f", rect.w, rect.h, rect.pageY or 0) or "-",
        tostring(self.Look and self:Look()), tostring(self.TriggerChipMode and self:TriggerChipMode()) }, "|")
end

function A:FormBarsApply(force)

    if not force and not self.formDirty and not FB.visible and not FB.previewUntil
        and self:FormLabelMode() == "off" then return false end
    local cheap = cheapKey(self)
    if not force and not self.formDirty and FB.cheap == cheap then return false end
    self.formDirty = nil
    FB.cheap = cheap
    local s = self:FormState()
    self:FormLearn(s)
    self:FormNoneCheck(s)
    local mode = self:FormLabelMode()
    local plan, why = nil, "off"
    if mode ~= "off" then plan, why = self:FormLabelPlan(s) end
    local key = planKey(plan, mode)
    if FB.previewUntil then

        if key == FB.keyBeforePreview then return true end
        FB.previewUntil = nil
        FB.key, FB.placed = FB.keyBeforePreview, nil
    end
    FB.why = plan and "shown" or why
    local place = placeKey(plan) .. "|" .. cheap
    if key == FB.key and FB.placed == place then return false end
    local changed = key ~= FB.key
    FB.key, FB.placed = key, place
    FB.plan = plan
    if not plan then
        self:FormLabelHide(A.formLabelStyle.fadeOut)
        return true
    end
    if not self:FormLabelPlace(plan) then
        FB.why = "nowhere to stand"
        self:FormLabelHide(A.formLabelStyle.fadeOut)
        return true
    end
    if mode == "static" then
        if not FB.visible then showLabel(self, false, true)
        elseif changed then showLabel(self, false, true) end
    elseif mode == "flash" then

        if changed then showLabel(self, true, true) end
    end
    return true
end


function A:TickFormBars(elapsed)
    FB.clock = (FB.clock or 0) + (tonumber(elapsed) or 0)
    if FB.clock < A.formLabelStyle.tick then return end
    FB.clock = 0
    if FB.previewUntil and (GetTime and GetTime() or 0) >= FB.previewUntil then
        FB.previewUntil = nil

        FB.key, FB.placed, FB.plan = FB.keyBeforePreview, nil, nil
        self:FormLabelHide(A.formLabelStyle.fadeOut)
        self.formDirty = true
    end
    if not FB.plan and self:FormLabelMode() == "off" then return end
    local fam = self:FormFamily()
    local legend = "-"
    if FB.plan and FB.plan.arm and FB.plan.arm ~= "top" then
        legend = tostring(self:FormLegendAnchor(FB.plan.arm) ~= nil)
    end
    local sig = tostring(fam) .. "|" .. legend
    if sig ~= FB.tickSig then
        FB.tickSig = sig
        self.formDirty = true
        self:FormBarsApply()
    end
end




function A:FormStore(create)
    if type(AdaptiveUICharDB) ~= "table" then
        if not create then return nil end
        AdaptiveUICharDB = {}
    end
    local fb = AdaptiveUICharDB.formBars
    if type(fb) ~= "table" then
        if not create then return nil end
        fb = {}
        AdaptiveUICharDB.formBars = fb
    end
    return fb
end

local function publicNumber(self, v)
    return type(v) == "number" and self:IsPublic(v) and v == v and v > -1e9 and v < 1e9
end

function A:FormLearn(s)
    local f = s and s.active
    if not (f and publicNumber(self, f.spellID) and publicNumber(self, s.formIndex)) then return false end

    if not (publicNumber(self, s.numForms) and s.formIndex >= 1 and s.formIndex <= s.numForms) then return false end


    if s.outranked or s.page ~= 1 then return false end
    if s.bonus == true and publicNumber(self, s.bonusIndex) and s.bonusIndex > 0 then
        local fb = self:FormStore(true)
        fb.byIndex = type(fb.byIndex) == "table" and fb.byIndex or {}
        local cur = fb.byIndex[s.bonusIndex]
        if not (type(cur) == "table" and cur.spellID == f.spellID and cur.formIndex == s.formIndex) then
            fb.byIndex[s.bonusIndex] = { spellID = f.spellID, formIndex = s.formIndex }
        end
        if type(fb.none) == "table" then fb.none[f.spellID] = nil end
        return true
    elseif s.bonus == false then
        local fb = self:FormStore(true)
        for _, e in pairs(type(fb.byIndex) == "table" and fb.byIndex or {}) do
            if type(e) == "table" and e.spellID == f.spellID then return false end
        end
        fb.none = type(fb.none) == "table" and fb.none or {}
        if fb.none[f.spellID] ~= true then fb.none[f.spellID] = true end
        return true
    end
    return false
end


function A:FormSeenBars(spellID)
    local fb = self:FormStore(false)
    local out = {}
    if not fb or type(spellID) ~= "number" then return out end
    for index, e in pairs(type(fb.byIndex) == "table" and fb.byIndex or {}) do
        if type(e) == "table" and e.spellID == spellID and type(index) == "number" then out[#out + 1] = index end
    end
    table.sort(out)
    if #out == 0 and type(fb.none) == "table" and fb.none[spellID] == true then out[1] = 0 end
    return out
end




A.formNoneLine = "on the controller your forms don't change an arm. To give them one: "
    .. "Esc > Options > Gamepad > Stance bar. Type /aui forms to see this again."

function A:FormNoneCheck(s)
    if self:FormLabelMode() == "off" then return end
    if s.family ~= "controller" or s.bonus ~= true or not (s.stance and s.stance.none) then return end
    local fb = self:FormStore(false)
    if fb and fb.noneShown == true then return end
    if self:IsCombat() then
        self.formNonePending = true
        return
    end
    self.formNonePending = nil
    self:Print(A.formNoneLine)
    self:FormStore(true).noneShown = true
end


function A:FormsCommand()
    local st = self:StanceOverrideInfo()
    if st.none then
        self:Print(A.formNoneLine)
    elseif st.arm then
        self:Print("on the controller your forms take " .. self:StanceArmWords(st)
            .. ". Blizzard's setting: Esc > Options > Gamepad > Stance bar.")
    else
        self:Print("the controller's Stance bar setting cannot be read here; /aui formprobe shows what is read.")
    end
    local s = self:FormState()
    if #s.forms == 0 then self:Print("this character has no forms or stances.") end
    for _, f in ipairs(s.forms) do
        local bars = f.spellID and self:FormSeenBars(f.spellID) or {}
        local words = #bars == 0 and "not learned yet" or (bars[1] == 0 and "pages nothing")
            or ("bar " .. table.concat(bars, ", bar "))
        self:Print(string.format("  %s: %s%s", f.name or "Unknown form", words, f.active and " (now)" or ""))
    end
    self:Print("Options: Advanced > Action bars > Forms & specs.")
end




function A:SpecGroups()
    local count, status
    local g = rawget(_G, "GetNumSpecGroups")
    local csi = rawget(_G, "C_SpecializationInfo")
    if type(g) ~= "function" and type(csi) == "table" and type(csi.GetNumSpecGroups) == "function" then
        g = csi.GetNumSpecGroups
    end
    if type(g) == "function" then
        count, status = self:Number(g, 1), "public"
        if not count then status = "restricted" end
    else
        status = "missing"
    end
    local active
    local ga = type(csi) == "table" and csi.GetActiveSpecGroup or nil
    if type(ga) ~= "function" then ga = rawget(_G, "GetActiveSpecGroup") or rawget(_G, "GetActiveTalentGroup") end
    if type(ga) == "function" then active = self:Number(ga, 1) end
    return count, active, status
end



function A:SpecRowWanted()
    local count = self:SpecGroups()
    if count then return count >= 2 end
    local fb = self:FormStore(false)
    return fb ~= nil and fb.specEvent == true
end


local function specProbeOn(self)
    local count = self:SpecGroups()
    if count then return count >= 2 end
    return true
end

function A:ActionFingerprint()
    local has = api("HasAction")
    if not has then return nil end
    local out = {}
    for slot = 1, 120 do
        local v = self:Read(has, 1, slot)
        out[slot] = v == true and "1" or (v == false and "0" or "x")
    end
    return table.concat(out)
end

local function diff(a, b)
    if not (a and b) or #a ~= #b then return nil end
    local n, filled = 0, 0
    for i = 1, #a do
        local x, y = a:sub(i, i), b:sub(i, i)
        if x ~= y then n = n + 1 end
        if x == "1" then filled = filled + 1 end
    end
    return n, filled
end


function A:SpecSentence()
    local count = self:SpecGroups()
    local fb = self:FormStore(false)
    local result = fb and fb.specResult
    local lead = count and count >= 2 and (count == 2 and "Two specs" or (count .. " specs")) or "Specs"
    if result == "perSpec" then return lead .. ": Blizzard keeps one set of bars per spec." end
    if result == "shared" then return lead .. ": your bars stay the same when you change spec." end
    return lead .. ". Change spec once and this says whether your bars change with it."
end




A.specProbeLate = 5
function A:SpecProbeFinish(gen)
    local p = FB.spec
    if not p or p.gen ~= gen then return end
    local after2 = self:ActionFingerprint()
    local n, filled = diff(p.before, after2)
    if not n then FB.spec = nil; return end
    local fb = self:FormStore(true)
    if n >= math.max(4, math.floor(0.25 * math.max(filled, 1))) then
        fb.specResult = "perSpec"
    elseif n == 0 and (p.slotEvents or 0) == 0 and filled >= 1 then
        if not p.late then
            p.late = true
            after(A.specProbeLate, function() A:SpecProbeFinish(gen) end)
            return
        end
        fb.specResult = "shared"
    end
    FB.spec = nil
    FB.fingerprint = after2
end

function A:OnFormEvent(event, ...)
    if event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS" or event == "UPDATE_BONUS_ACTIONBAR"
        or event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_OVERRIDE_ACTIONBAR"
        or event == "UPDATE_POSSESS_BAR" or event == "UPDATE_TEMP_SHAPESHIFT_ACTIONBAR"
        or event == "PET_BATTLE_OPENING_START" or event == "PET_BATTLE_CLOSE"
        or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE"
        or event == "INPUT_DEVICE_INTERFACE_TRANSITION" or event == "PLAYER_ENTERING_WORLD"
        or event == "GAMEPAD_STANCE_BAR_OVERRIDE_CHANGED" then
        self.formDirty = true
    elseif event == "ACTIONBAR_SLOT_CHANGED" then
        self.formDirty = true
        if FB.spec then FB.spec.slotEvents = (FB.spec.slotEvents or 0) + 1
        elseif self:SpecGroups() then FB.fingerprintStale = true end
    elseif event == "CVAR_UPDATE" then
        local name = ...
        if name == "GamepadStanceBarOverride" or name == nil then self.formDirty = true end
    elseif event == "PLAYER_REGEN_ENABLED" then

        self.formDirty = true
    elseif event == "PLAYER_REGEN_DISABLED" then
        self.formDirty = true
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        self.formDirty = true
        local fb = self:FormStore(true)
        if fb.specEvent ~= true then fb.specEvent = true end
        if specProbeOn(self) and FB.fingerprint then
            FB.specGen = (FB.specGen or 0) + 1
            local gen = FB.specGen
            FB.spec = { gen = gen, before = FB.fingerprint, slotEvents = 0 }
            after(2, function() A:SpecProbeFinish(gen) end)
        end
    end
end


function A:FormFingerprintTick()
    if FB.spec or self:IsCombat() then return end
    if FB.fingerprint and not FB.fingerprintStale then return end
    if not specProbeOn(self) then return end
    FB.fingerprint = self:ActionFingerprint()
    FB.fingerprintStale = nil
end


function A:FormBarsRefresh()
    self:FormBarsApply()
    self:FormFingerprintTick()
end




function A:PreviewFormLabel(entry)
    if not entry then return false end
    local s = self:FormState()
    local family = s.family or self:EffectiveInput()
    local plan
    if family == "controller" then
        local st = s.stance
        if not st or st.none or not st.arm then
            self:Print(A.formNoneLine)
            return false
        end
        plan = { family = "controller", word = entry.short or "?", tail = "", tailShort = "", tailMin = "", arm = st.arm }
    else
        local bars = entry.spellID and self:FormSeenBars(entry.spellID) or {}
        local bar = (bars[1] and bars[1] > 0 and bars[1]) or (entry.spellID and A.formUsualBar[entry.spellID]) or nil
        local tail = (bar and bar > 0) and ("  bar " .. bar) or ""
        plan = { family = "keyboard", word = entry.short or "?", tail = tail, tailShort = tail, tailMin = tail }
    end
    if not self:FormLabelPlace(plan) then
        self:Print("the form label has nowhere to show right now.")
        return false
    end
    if not FB.previewUntil then FB.keyBeforePreview = FB.key end
    FB.previewUntil = (GetTime and GetTime() or 0) + A.formLabelStyle.preview
    FB.key = "preview"
    FB.plan = plan
    showLabel(self, false, true)
    return true
end




local function word(v, status)
    if v == nil then return status or "nil" end
    return tostring(v)
end

function A:FormProbeLines()
    local lines = {}
    local function add(text) lines[#lines + 1] = "formprobe" .. text end
    local function rd(name, ...)
        local fn = api(name)
        if not fn then return "missing" end
        local v, status = self:Read(fn, 1, ...)
        if status ~= "public" then return status end
        return tostring(v)
    end
    local s = self:FormState()
    add(string.format(": label %s | family %s | why %s | look %s", self:FormLabelMode(), tostring(s.family),
        tostring(FB.why or "-"), tostring(self.Look and self:Look())))
    add(string.format(" forms: count %s | active index %s", word(s.numForms, "unreadable"), word(s.formIndex, "unreadable")))
    for _, f in ipairs(s.forms) do
        add(string.format("  form %d: spellID %s | name %s | icon %s | active %s | seen %s", f.index,
            word(f.spellID, "restricted"), word(f.name, "restricted"), f.icon and "public" or "restricted/none",
            tostring(f.active), table.concat(f.spellID and self:FormSeenBars(f.spellID) or {}, ",")))
    end
    add(string.format(" bars: HasBonusActionBar %s | GetBonusBarIndex %s | GetBonusBarOffset %s | GetActionBarPage %s",
        rd("HasBonusActionBar"), rd("GetBonusBarIndex"), rd("GetBonusBarOffset"), rd("GetActionBarPage")))
    local pb = rawget(_G, "C_PetBattles")
    local function rdf(fn)
        if type(fn) ~= "function" then return "missing" end
        local v, status = self:Read(fn, 1)
        return status == "public" and tostring(v) or status
    end
    add(string.format(" outrank: vehicle %s | override %s | temp shapeshift %s | possess %s | pet battle %s",
        rd("HasVehicleActionBar"), rd("HasOverrideActionBar"), rd("HasTempShapeshiftActionBar"),
        rdf(rawget(_G, "IsPossessBarVisible")), rdf(type(pb) == "table" and pb.IsInBattle or nil)))
    local st = s.stance
    add(string.format(" stance bar: GamepadStanceBarOverride %s (%s) | name %s | Enum %s | arm %s",
        word(st.raw, st.status), st.status, tostring(st.name), st.enum, tostring(self:StanceArmWords(st) or (st.none and "none") or "-")))
    local gp = rawget(_G, "C_GamepadUI")
    add(string.format(" gamepad: storage slot for the active stance %s | page now %s | legend %s",
        type(gp) == "table" and rdf(gp.GetFirstGamepadActionBarStorageSlotIndexForActiveStance) or "missing",
        word(s.padPage, "unreadable"), st.arm and tostring(self:FormLegendAnchor(st.arm) ~= nil) or "-"))
    local seed = api("GetBonusBarIndexForSlot")
    local seen = {}
    if seed then
        for slot = 73, 120, 12 do
            local v, status = self:Read(seed, 1, slot)
            seen[#seen + 1] = slot .. "->" .. (status == "public" and tostring(v) or status)
        end
    end
    add(" GetBonusBarIndexForSlot: " .. (seed and table.concat(seen, " ") or "missing"))
    local count, active, cstatus = self:SpecGroups()
    local fb = self:FormStore(false)
    add(string.format(" specs: GetNumSpecGroups %s (%s) | active group %s | event seen %s | result %s",
        word(count, cstatus), cstatus, word(active, "unreadable"), tostring(fb and fb.specEvent or false),
        tostring(fb and fb.specResult or "none yet")))
    local map = {}
    for index, e in pairs(fb and type(fb.byIndex) == "table" and fb.byIndex or {}) do
        map[#map + 1] = tostring(index) .. "=" .. tostring(type(e) == "table" and e.spellID)
    end
    table.sort(map)
    add(" learned: " .. (#map > 0 and table.concat(map, " ") or "nothing yet")
        .. " | the None line shown " .. tostring(fb and fb.noneShown == true or false))
    return lines
end

function A:FormProbeCommand()
    for _, text in ipairs(self:FormProbeLines()) do self:Print(text) end
end
