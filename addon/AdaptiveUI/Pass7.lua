local _, A = ...



































A.rblbArt = {
    ratio = 2138 / 556,
    seatU = 0.40,
    seatV = 0.33,
    bodyV1 = 0.66,
    studU = 0.845, studV = 0.30,
    glowPadX = 0.06, glowPadY = 0.18,
    height = 24,
    glow = 0.85,
    rim = 0.55,
    glint = 0.70,
}





A.bumperHold = 0.10




























A.bumperArm = { gap = 4, press = 0.94, pressIn = 0.025, pressOut = 0.05, group = "topBar" }

function A:BumperSkinMode()
    if not (self.db and self.optionIndex and self.optionIndex.compassBumperSkin) then return "native" end
    local skin = self:GetOption("compassBumperSkin")
    if skin ~= "arm" then return "native" end
    if (self.artSlots or {}).rblb == nil then return "native" end
    return "arm"
end

function A:BumperPlaqueOn()
    return self:BumperSkinMode() ~= "native"
end


function A:BumperArmGroup(page, side)
    local bars = type(page) == "table" and page.actionBars
    local bar = type(bars) == "table" and bars[A.bumperArm.group]
    local group = type(bar) == "table" and bar[side]
    local tile = type(group) == "table" and group.ActionButton2
    if type(tile) ~= "table" then return nil end
    return group, tile
end



function A:BumperArmScale(root, group)
    local gs = group and self:Number(group.GetEffectiveScale, 1, group)
    local rs = root and self:Number(root.GetEffectiveScale, 1, root)
    if not gs or not rs or gs <= 0.05 or rs <= 0.05 then return 1 end
    local s = gs / rs
    if s ~= s or s < 0.5 or s > 2.5 then return 1 end
    return s
end




function A:BumperPlaqueRect(side, scale)
    local a = A.rblbArt
    local h = a.height * (scale or 1)
    local w = h * a.ratio
    local mirrored = side == "Right"
    local u = mirrored and (1 - a.seatU) or a.seatU
    return -u * w, a.seatV * h, w, h, mirrored
end

local function bumperHost(self, state, root, side)
    local entries = state.decorations[root]
    if not entries then entries = {}; state.decorations[root] = entries end
    local key = "bumper" .. side
    local host = entries[key]
    if host then return host, entries end
    local ok = pcall(function()
        host = self:Own(CreateFrame("Frame", nil, root))
        host:EnableMouse(false)


        local press = self:Own(CreateFrame("Frame", nil, host))
        press:EnableMouse(false)
        press:SetPoint("CENTER", host, "CENTER", 0, 0)
        host.press = press
        host.pressScale = 1
        host.art = self:PaintedTexture(press, "BACKGROUND", -6, "rblb")
        host.art:SetAllPoints(press)

        host.shadow = self:Own(press:CreateTexture(nil, "BACKGROUND", nil, -8))
        host.shadow:SetAlpha(0)
        host.halo = self:Own(press:CreateTexture(nil, "BACKGROUND", nil, -7))
        host.halo:SetTexture(self.artPath .. "rblb-glow.tga", "CLAMP", "CLAMP")
        host.halo:SetBlendMode("ADD")
        host.halo:SetAlpha(0)
        host.rim = self:Own(press:CreateTexture(nil, "ARTWORK", nil, 1))
        host.rim:SetBlendMode("ADD")
        host.rim:SetAlpha(0)
        host.glint = self:Own(press:CreateTexture(nil, "ARTWORK", nil, 2))
        host.glint:SetTexture(self.artPath .. "diamond-glow.tga", "CLAMP", "CLAMP")
        host.glint:SetBlendMode("ADD")
        host.glint:SetAlpha(0)
        entries[key] = host
        entries[key .. "Art"] = host.art
        entries[key .. "Acc"] = self:PaintedTwin(host.art)
    end)
    if not ok then return nil end
    return host, entries
end


function A:BumperPlaques(state, page, on)
    local root = _G.GamepadMainActionBarFrame
    if type(root) ~= "table" or type(page) ~= "table" then return false end
    local mode = on and self:BumperSkinMode() or "native"
    on = mode ~= "native"
    for _, side in ipairs({ "Left", "Right" }) do
        local bg, hl = page[side .. "ShoulderBackground"], page[side .. "ShoulderHighlight"]
        local icon = page[side .. "ShoulderIcon"]
        local entries = state.decorations[root]
        local host = entries and entries["bumper" .. side]
        if not on or not bg then
            if host and host:IsShown() then host:Hide() end
            if bg then self:ReleaseHidden(state, bg) end
            if hl then self:ReleaseHidden(state, hl) end
            if icon then self:ReleaseHidden(state, icon) end
        else
            self:HoldHidden(state, bg)
            if hl then self:HoldHidden(state, hl) end

            if icon then self:HoldHidden(state, icon) end
            host = bumperHost(self, state, root, side)
            if host then
                local level = self:Number(page.GetFrameLevel, 1, page) or self:Number(root.GetFrameLevel, 1, root)
                if level and host:GetFrameLevel() ~= math.max(0, level - 1) then
                    pcall(host.SetFrameLevel, host, math.max(0, level - 1))
                end
                local group, tile = self:BumperArmGroup(page, side)
                local scale = group and self:BumperArmScale(root, group) or 1
                local x, y, w, h, mirrored = self:BumperPlaqueRect(side, scale)
                local gap = A.bumperArm.gap * scale
                local sig = string.format("%.3f|%.3f|%.3f|%.3f|%s|%s", x, y, w, h, tostring(mirrored), tostring(tile))
                if host.sig ~= sig then
                    host.sig = sig
                    host:ClearAllPoints()
                    if tile then


                        host:SetPoint("BOTTOM", tile, "TOP", 0, gap)
                    else
                        host:SetPoint("TOPLEFT", bg, "CENTER", x, y)
                    end
                    host:SetSize(w, h)
                    host.baseW, host.baseH, host.mirrored = w, h, mirrored
                    local u0, u1 = 0, 1
                    if mirrored then u0, u1 = 1, 0 end
                    host.art:SetTexCoord(u0, u1, 0, 1)
                    host.halo:ClearAllPoints()
                    host.halo:SetPoint("CENTER", host.press, "CENTER", 0, 0)
                    host.halo:SetTexCoord(u0, u1, 0, 1)
                    host.rim:SetAllPoints(host.press)
                    host.rim:SetTexCoord(u0, u1, 0, 1)


                    self:SizeBumperPress(host)
                end
                host.mode = mode

                local plaque = self:LookName("rblb")
                local rimFile = self.artLayers and self.artLayers[plaque] and self.artLayers[plaque].acc
                local rimPath = self.artPath .. (rimFile or plaque) .. ".tga"
                local haloPath = self.artPath .. self:LookName("rblb-glow") .. ".tga"
                if host.halo and host.halo:GetTexture() ~= haloPath then host.halo:SetTexture(haloPath, "CLAMP", "CLAMP") end
                if host.rim:GetTexture() ~= rimPath then host.rim:SetTexture(rimPath, "CLAMP", "CLAMP") end
                host.shadowPiece = plaque
                host.shadowFile = self:CompassShadowFile(plaque)
                self:SizeBumperPress(host)
                self:PaintedAlpha(host.art, 1)
                if not host.art:IsShown() then host.art:Show() end
                self:SyncPainted(host.art)
                self:Tint(host.halo, "mark", "vertex", 1)
                self:Tint(host.rim, "mark", "vertex", 1)
                self:Tint(host.glint, "mark", "vertex", 1)
                host.highlight = hl
                if not host:IsShown() then host:Show() end
            end
        end
    end
    return on
end







function A:TickBumpers(elapsed)
    elapsed = tonumber(elapsed) or 0

    self:TickTriggerChips()
    local state = self.nativeSkins and self.nativeSkins.actions
    local root = _G.GamepadMainActionBarFrame
    local entries = state and root and state.decorations[root]
    if not (entries and (entries.bumperLeft or entries.bumperRight)) then return end
    local glowOn = not (self.optionIndex and self.optionIndex.compassBumperGlow) or self:GetOption("compassBumperGlow") ~= false
    local a = A.rblbArt
    for _, side in ipairs({ "Left", "Right" }) do
        local host = entries["bumper" .. side]
        if host and host:IsShown() then
            local hl = host.highlight
            local shown = hl and type(hl.IsShown) == "function" and self:Read(hl.IsShown, 1, hl) == true or false
            host.shownFor = shown and ((host.shownFor or 0) + elapsed) or 0
            local down = shown and host.shownFor >= A.bumperHold - 1e-9
            local held = glowOn and down or false
            host.held = held
            for key, peak in pairs({ halo = a.glow, rim = a.rim, glint = a.glint }) do
                local t = host[key]
                local want = held and peak or 0
                if math.abs((t:GetAlpha() or 0) - want) > 0.001 then t:SetAlpha(want) end
            end

            local sh = host.shadow
            if sh and host.shadowFile then
                local want = A.compassShadow.alpha * (down and A.compassShadow.pressed or 1)
                if math.abs((sh:GetAlpha() or 0) - want) > 0.001 then sh:SetAlpha(want) end
            end
            self:EaseBumperPress(host, down, elapsed)
        end
    end
end




function A:EaseBumperPress(host, down, elapsed)
    local press = host and host.press
    if not press then return end
    local b = A.bumperArm
    local target = down and b.press or 1
    local now = host.pressScale or 1
    if math.abs(now - target) < 1e-6 then return end
    local tau = down and b.pressIn or b.pressOut
    local k = (elapsed and elapsed > 0) and (1 - math.exp(-elapsed / tau)) or 1
    local nextScale = now + (target - now) * k
    if math.abs(nextScale - target) < 0.002 then nextScale = target end
    host.pressScale = nextScale
    self:SizeBumperPress(host)
end





function A:SizeBumperPress(host)
    local press, w, h = host.press, host.baseW, host.baseH
    if not press or not w or not h then return end
    local s = host.pressScale or 1
    local a = A.rblbArt
    pcall(press.SetSize, press, w * s, h * s)
    pcall(host.halo.SetSize, host.halo, w * (1 + 2 * a.glowPadX) * s, h * (1 + 2 * a.glowPadY) * s)
    if host.shadow then self:CompassShadow(host.shadow, press, host.shadowPiece, w * s, h * s, host.mirrored) end
    local su = host.mirrored and (1 - a.studU) or a.studU
    host.glint:ClearAllPoints()
    host.glint:SetPoint("CENTER", press, "TOPLEFT", w * su * s, -h * a.studV * s)
    pcall(host.glint.SetSize, host.glint, h * 0.9 * s, h * 0.9 * s)
end

















A.compassShadow = {
    pad = 0.60,
    alpha = 0.90,
    pressed = 0.55,
    files = { ["oak-divider"] = "oak-divider-shadow", ["oak-bumper"] = "oak-bumper-shadow" },
}


function A:CompassShadowFile(painting)
    local file = painting and A.compassShadow.files[painting]
    if not file then return nil end
    for _, installed in pairs(self.artSlots or {}) do
        if installed == file then return file end
    end
    return nil
end



function A:CompassShadow(region, anchor, painting, w, h, mirrored)
    if not region then return false end
    local file = self:CompassShadowFile(painting)
    if not file or not anchor or not w or not h or w <= 0 or h <= 0 then
        if region.auiShadowOn then region:SetAlpha(0); region.auiShadowOn = nil end
        return false
    end
    local path = self.artPath .. file .. ".tga"
    if region:GetTexture() ~= path then region:SetTexture(path, "CLAMP", "CLAMP") end
    local pad = A.compassShadow.pad * h
    region:ClearAllPoints()
    region:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    pcall(region.SetSize, region, w + 2 * pad, h + 2 * pad)
    if mirrored then region:SetTexCoord(1, 0, 0, 1) else region:SetTexCoord(0, 1, 0, 1) end
    if not region.auiShadowOn then
        region.auiShadowOn = true
        region:SetAlpha(A.compassShadow.alpha)
    end
    return true
end






















A.triggerChip = {
    height = 20,
    padX = 6,
    minW = 28,
    gap = 5,
    plus = 20,
    tone = { 0.045, 0.045, 0.05 },
    alpha = 0.94,
    ink = { 1, 1, 1 },
    text = "body",
}
A.triggerChipKeys = { "LeftIcon", "RightIcon", "CenteredIcons" }

function A:TriggerChipMode()
    if not (self.artSlots and self.artSlots.oakChip) then return "native" end
    local style = "auto"
    if self.db and self.optionIndex and self.optionIndex.compassPromptStyle then
        style = self:GetOption("compassPromptStyle")
    end
    if style == "flat" then return "flat" end
    if style == "native" then return "native" end
    return self:Look() == "oakborn" and "flat" or "native"
end


local LABELS = {
    xbox = { "LT", "RT" },
    shapes = { "L2", "R2" },
    nintendo = { "ZL", "ZR" },
}
function A:TriggerLabelStyle()
    local pad = type(C_GamePad) == "table" and C_GamePad or nil
    if not pad or type(pad.GetActiveDeviceID) ~= "function" or type(pad.GetDeviceMappedState) ~= "function" then
        return "xbox"
    end
    local ok, id = pcall(pad.GetActiveDeviceID)
    if not ok or id == nil or not self:IsPublic(id) then return "xbox" end
    local ok2, mapped = pcall(pad.GetDeviceMappedState, id)
    if not ok2 or type(mapped) ~= "table" then return "xbox" end
    local words = {}
    for _, key in ipairs({ "labelStyle", "name" }) do
        local v = mapped[key]
        if v ~= nil and self:IsPublic(v) and (type(v) == "string" or type(v) == "number") then
            words[#words + 1] = string.lower(tostring(v))
        end
    end
    local text = table.concat(words, " ")
    if text:find("shape") or text:find("playstation") or text:find("dualsense") or text:find("dualshock") then
        return "shapes"
    end
    if text:find("reverse") or text:find("nintendo") or text:find("switch") then return "nintendo" end
    return "xbox"
end

function A:TriggerLabels()
    local pair = LABELS[self:TriggerLabelStyle()] or LABELS.xbox
    return pair[1], pair[2]
end


function A:TriggerChipTextSize(root)
    local size = self:Type(A.triggerChip.text)
    local rs = root and self:Number(root.GetEffectiveScale, 1, root)
    local us = UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)
    if rs and us and us > 0.05 then size = size * self:TypeLift(rs / us) end
    return size
end

local function chipPart(self, parent, label)
    local plate = self:Own(parent:CreateTexture(nil, "ARTWORK", nil, 1))
    plate:SetTexture(self.artPath .. "oak-chip.tga", "CLAMP", "CLAMP")
    local c = A.triggerChip
    plate:SetVertexColor(c.tone[1], c.tone[2], c.tone[3], c.alpha)
    local text = self:Own(parent:CreateFontString(nil, "OVERLAY"))
    text:SetPoint("CENTER", plate, "CENTER", 0, 0)
    pcall(text.SetFont, text, self:FontPath("numeric"), self:Type("body"), "")
    text:SetText(label)
    return { plate = plate, text = text }
end

local function chipHost(self, state, root, key)
    local entries = state.decorations[root]
    if not entries then entries = {}; state.decorations[root] = entries end
    local host = entries["trigger" .. key]
    if host then return host end
    local ok = pcall(function()
        host = self:Own(CreateFrame("Frame", nil, root))
        host:EnableMouse(false)
        local inner = self:Own(CreateFrame("Frame", nil, host))
        inner:EnableMouse(false)
        inner:SetAllPoints(host)
        inner:SetAlpha(0)
        host.inner = inner
        host.chips = {}
        if key == "CenteredIcons" then
            host.chips[1] = chipPart(self, inner, "LT")
            host.chips[2] = chipPart(self, inner, "RT")
            host.plus = self:Own(inner:CreateFontString(nil, "OVERLAY"))
            pcall(host.plus.SetFont, host.plus, self:FontPath("numeric"), A.triggerChip.plus, "")
            host.plus:SetText("+")
        else
            host.chips[1] = chipPart(self, inner, key == "LeftIcon" and "LT" or "RT")
        end
        entries["trigger" .. key] = host
    end)
    if not ok then return nil end
    return host
end


function A:LayoutTriggerChip(host, key, size, left, right)
    local c = A.triggerChip
    local h = math.max(c.height, size + 6)
    local names = key == "CenteredIcons" and { left, right } or { key == "LeftIcon" and left or right }
    local ink = c.ink
    local widths, total = {}, 0
    for i, part in ipairs(host.chips) do
        local t = part.text
        local fontOk = pcall(t.SetFont, t, self:FontPath("numeric"), size, "")
        if not fontOk then pcall(t.SetFont, t, STANDARD_TEXT_FONT or self.fallbackFont, size, "") end
        pcall(t.SetShadowOffset, t, 0, 0)
        t:SetTextColor(ink[1], ink[2], ink[3], 1)
        t:SetText(names[i] or "")
        local tw = self:Number(t.GetStringWidth, 1, t) or size * 1.1
        widths[i] = math.max(c.minW, tw + 2 * c.padX)
        total = total + widths[i]
    end
    if host.plus then
        local ps = c.plus * size / self:Type("body")
        local fontOk = pcall(host.plus.SetFont, host.plus, self:FontPath("numeric"), ps, "")
        if not fontOk then pcall(host.plus.SetFont, host.plus, STANDARD_TEXT_FONT or self.fallbackFont, ps, "") end
        pcall(host.plus.SetShadowOffset, host.plus, 0, 0)
        host.plus:SetTextColor(ink[1], ink[2], ink[3], 1)
        total = total + 2 * c.gap + c.plus
    end
    host:SetSize(total, h)
    local x = 0
    for i, part in ipairs(host.chips) do
        part.plate:ClearAllPoints()
        part.plate:SetPoint("LEFT", host.inner, "LEFT", x, 0)
        part.plate:SetSize(widths[i], h)
        x = x + widths[i]
        if i == 1 and host.plus then
            host.plus:ClearAllPoints()
            host.plus:SetPoint("CENTER", host.inner, "LEFT", x + c.gap + c.plus / 2, 0)
            x = x + 2 * c.gap + c.plus
        end
    end
    host.chipW, host.chipH = total, h
end


function A:TriggerChips(state, page, on)
    local root = _G.GamepadMainActionBarFrame
    if type(root) ~= "table" or type(page) ~= "table" then return false end
    local flat = on and self:TriggerChipMode() == "flat"
    local left, right = self:TriggerLabels()
    local size = self:TriggerChipTextSize(root)
    for _, key in ipairs(A.triggerChipKeys) do
        local prompt = page[key]
        local entries = state.decorations[root]
        local host = entries and entries["trigger" .. key]
        if not flat or not prompt then
            if prompt then self:ReleaseHidden(state, prompt) end
            if host then
                host.prompt = nil
                if host.inner:GetAlpha() ~= 0 then host.inner:SetAlpha(0) end
                if host:IsShown() then host:Hide() end
            end
        else
            self:HoldHidden(state, prompt)
            host = chipHost(self, state, root, key)
            if host then
                local level = self:Number(prompt.GetFrameLevel, 1, prompt)
                if level and host:GetFrameLevel() ~= level then pcall(host.SetFrameLevel, host, level) end
                local sig = string.format("%s|%s|%s|%.2f", tostring(prompt), left, right, size)
                if host.sig ~= sig then
                    host.sig = sig
                    host:ClearAllPoints()
                    host:SetPoint("CENTER", prompt, "CENTER", 0, 0)
                    self:LayoutTriggerChip(host, key, size, left, right)
                end
                host.prompt = prompt
                if not host:IsShown() then host:Show() end
            end
        end
    end
    self:TickTriggerChips()
    return flat
end



function A:TickTriggerChips()
    local state = self.nativeSkins and self.nativeSkins.actions
    local root = _G.GamepadMainActionBarFrame
    local entries = state and root and state.decorations[root]
    if not entries then return end
    for _, key in ipairs(A.triggerChipKeys) do
        local host = entries["trigger" .. key]
        local prompt = host and host.prompt
        if host and host.inner then
            local seen = false
            if prompt then
                local probe = type(prompt.IsVisible) == "function" and prompt.IsVisible or prompt.IsShown
                seen = type(probe) == "function" and self:Read(probe, 1, prompt) == true or false
            end
            local want = seen and 1 or 0
            if host.inner:GetAlpha() ~= want then host.inner:SetAlpha(want) end
        end
    end
end
