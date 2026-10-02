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
A.bumperTick = 0.05





A.bumperHold = 0.10



























A.bumperArm = { gap = 4, press = 0.94, pressIn = 0.025, pressOut = 0.05, group = "topBar" }

function A:BumperSkinMode()
    if not (self.db and self.optionIndex and self.optionIndex.compassBumperSkin) then return "native" end
    local skin = self:GetOption("compassBumperSkin")
    if skin ~= "plaque" and skin ~= "arm" then return "native" end
    if (self.artSlots or {}).rblb == nil then return "native" end
    return skin
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
        host.halo = self:Own(press:CreateTexture(nil, "BACKGROUND", nil, -8))
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

            if icon then
                if mode == "arm" then self:HoldHidden(state, icon) else self:ReleaseHidden(state, icon) end
            end
            host = bumperHost(self, state, root, side)
            if host then
                local level = self:Number(page.GetFrameLevel, 1, page) or self:Number(root.GetFrameLevel, 1, root)
                if level and host:GetFrameLevel() ~= math.max(0, level - 1) then
                    pcall(host.SetFrameLevel, host, math.max(0, level - 1))
                end
                local group, tile
                if mode == "arm" then group, tile = self:BumperArmGroup(page, side) end
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
                local rimFile = self.artLayers and self.artLayers.rblb and self.artLayers.rblb.acc
                local rimPath = self.artPath .. (rimFile or "rblb") .. ".tga"
                if host.rim:GetTexture() ~= rimPath then host.rim:SetTexture(rimPath, "CLAMP", "CLAMP") end
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
    local state = self.nativeSkins and self.nativeSkins.actions
    local root = _G.GamepadMainActionBarFrame
    local entries = state and root and state.decorations[root]
    if not entries then return end
    local arm = (entries.bumperLeft and entries.bumperLeft.mode == "arm")
        or (entries.bumperRight and entries.bumperRight.mode == "arm")
    self.bumperClock = (self.bumperClock or 0) + elapsed
    local poll = self.bumperClock >= A.bumperTick
    if not arm and not poll then return end
    local since = self.bumperClock
    if poll then self.bumperClock = 0 end
    local glowOn = not (self.optionIndex and self.optionIndex.compassBumperGlow) or self:GetOption("compassBumperGlow") ~= false
    local a = A.rblbArt
    for _, side in ipairs({ "Left", "Right" }) do
        local host = entries["bumper" .. side]
        if host and host:IsShown() then
            local hl = host.highlight
            local shown = hl and type(hl.IsShown) == "function" and self:Read(hl.IsShown, 1, hl) == true or false

            local dt = arm and elapsed or since
            host.shownFor = shown and ((host.shownFor or 0) + dt) or 0
            local down = shown and host.shownFor >= A.bumperHold - 1e-9
            local held = glowOn and down or false
            host.held = held
            for key, peak in pairs({ halo = a.glow, rim = a.rim, glint = a.glint }) do
                local t = host[key]
                local want = held and peak or 0
                if math.abs((t:GetAlpha() or 0) - want) > 0.001 then t:SetAlpha(want) end
            end
            self:EaseBumperPress(host, host.mode == "arm" and down, elapsed)
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
    local su = host.mirrored and (1 - a.studU) or a.studU
    host.glint:ClearAllPoints()
    host.glint:SetPoint("CENTER", press, "TOPLEFT", w * su * s, -h * a.studV * s)
    pcall(host.glint.SetSize, host.glint, h * 0.9 * s, h * 0.9 * s)
end
