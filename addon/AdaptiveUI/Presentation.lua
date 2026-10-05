local _, A = ...

local function path(root, ...)
    for i = 1, select("#", ...) do
        if not root then return nil end
        root = root[select(i, ...)]
    end
    return root
end

local function alpha(self, state, region, value)
    if not region or type(region.GetAlpha) ~= "function" then return end
    local old = region:GetAlpha()
    if not self:IsPublic(old) or type(old) ~= "number" then return end
    self:RememberProperty(state, region, "alpha", function()
        return function() region:SetAlpha(old) end
    end)
    if old ~= value then region:SetAlpha(value) end
end




local function nativeShadow(self, state, region)
    if type(region.GetShadowColor) ~= "function" or type(region.SetShadowColor) ~= "function"
        or type(region.GetShadowOffset) ~= "function" or type(region.SetShadowOffset) ~= "function" then return end
    local r, g, b, a = region:GetShadowColor()
    local x, y = region:GetShadowOffset()
    for _, v in ipairs({ r, g, b, a, x, y }) do
        if not self:IsPublic(v) or type(v) ~= "number" then return end
    end
    self:RememberProperty(state, region, "shadow", function()
        return function() region:SetShadowColor(r, g, b, a); region:SetShadowOffset(x, y) end
    end)
    local on = self:GetOption("themeTextShadow")
    local c = self:Scheme().textShadow
    local wr, wg, wb, wa, wx, wy = c[1], c[2], c[3], c[4], 1, -1
    if not on then wr, wg, wb, wa, wx, wy = 0, 0, 0, 0, 0, 0 end
    if math.abs(r - wr) > 0.001 or math.abs(g - wg) > 0.001 or math.abs(b - wb) > 0.001
        or math.abs(a - wa) > 0.001 or x ~= wx or y ~= wy then
        region:SetShadowColor(wr, wg, wb, wa)
        region:SetShadowOffset(wx, wy)
    end
end

local function font(self, state, region, size, heading, bulk, wantFlags)
    if not region or type(region.GetFont) ~= "function" then return end




    state.explicitFonts = state.explicitFonts or {}
    if bulk then
        if state.explicitFonts[region] then return end
    else
        state.explicitFonts[region] = true
    end
    local file, oldSize, flags = region:GetFont()
    if not self:IsPublic(file) or not self:IsPublic(oldSize) or not self:IsPublic(flags)
        or type(file) ~= "string" or type(oldSize) ~= "number" then return end
    self:RememberProperty(state, region, "font", function()
        return function() region:SetFont(file, oldSize, flags or "") end
    end)




    local target = size * self.db.textScale






    state.nativeFontFlags = state.nativeFontFlags or setmetatable({}, { __mode = "k" })
    local want = flags
    if wantFlags then
        if state.nativeFontFlags[region] == nil then state.nativeFontFlags[region] = flags or "" end
        want = wantFlags
    elseif state.nativeFontFlags[region] ~= nil then
        want = state.nativeFontFlags[region]
        if (flags or "") == (want or "") then state.nativeFontFlags[region] = nil end
    end
    if file == self:FontPath(heading) and math.abs(oldSize - target) < 0.01 and (flags or "") == (want or "") then
        nativeShadow(self, state, region)
        return
    end

    self:SetThemedFont(region, target, heading, want, true)
    nativeShadow(self, state, region)
end
















local function textColor(self, state, region, role)
    if not region or type(region.GetTextColor) ~= "function" or type(region.SetTextColor) ~= "function" then return end
    local r, g, b, a = region:GetTextColor()
    for _, value in ipairs({ r, g, b, a }) do
        if not self:IsPublic(value) or type(value) ~= "number" then return end
    end
    self:RememberProperty(state, region, "textColor", function()
        return function() region:SetTextColor(r, g, b, a) end
    end)
    local wr, wg, wb = self:Color(role or "text")


    local now = { region:GetTextColor() }
    if math.abs((now[1] or 0) - wr) > 0.004 or math.abs((now[2] or 0) - wg) > 0.004
        or math.abs((now[3] or 0) - wb) > 0.004 then
        region:SetTextColor(wr, wg, wb, now[4] or a)
    end
    state.count = state.count + 1
end

























local function trayHost(self, state, frame, fixedW, fixedH)
    local entries = state.decorations[frame]
    if not entries then entries = {}; state.decorations[frame] = entries end
    local host = entries.trayHost
    if not host then
        host = self:Own(CreateFrame("Frame", nil, frame))
        host:EnableMouse(false)
        entries.trayHost = host
    end
    local level = self:Number(frame.GetFrameLevel, 1, frame)
    if level then pcall(host.SetFrameLevel, host, math.max(0, level - 1)) end
    host:ClearAllPoints()
    if fixedW then








        host:SetPoint("CENTER", frame, "CENTER", 0, 0)
        host:SetSize(fixedW, fixedH or fixedW)
    else
        host:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        host:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    end


    host.auiFit = nil
    return host
end

local function tray(self, state, frame, pad, opacity, fixedW, fixedH)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    pad = pad or self.tokens.space.sm
    local host = trayHost(self, state, frame, fixedW, fixedH)
    self.NativeGlassPanel(self, state, host, "tray", host, -pad, pad, host, pad, -pad,
        opacity or self:Surface("wash"), 1, true, "base")
    if not host:IsShown() then host:Show() end
    return host
end











local function compassDivider(self, state, root, page, bar, on)
    if not root or type(root.CreateTexture) ~= "function" then return false end
    local entries = state.decorations[root]
    if not entries then entries = {}; state.decorations[root] = entries end
    local host = entries.groundDivider
    if not on then
        if host and host:IsShown() then host:Hide() end
        return false
    end
    if type(CreateFrame) ~= "function" then return false end
    local anchor = page and page.BottomCenteredAnchor
    if not anchor then return false end
    if not host then
        local ok, made = pcall(CreateFrame, "Frame", nil, root)
        if not ok or not made then return false end
        host = self:Own(made)
        host:EnableMouse(false)
        host.art = self:PaintedTexture(host, "BACKGROUND", -6, "compass-divider")
        host.art:SetAllPoints(host)
        host.art:SetTexCoord(0, 1, 0, 1)

        host.shadow = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
        host.shadow:SetAlpha(0)
        host.lights = {}
        for _, side in ipairs({ "left", "right" }) do
            local t = self:Own(host:CreateTexture(nil, "ARTWORK", nil, 2))
            t:SetTexture(self.artPath .. "bar-spark.tga", "CLAMP", "CLAMP")
            t:SetBlendMode("ADD")

            if side == "left" then t:SetTexCoord(1, 0, 0, 1) else t:SetTexCoord(0, 1, 0, 1) end
            t:SetAlpha(0)
            host.lights[side] = t
        end
        local glint = self:Own(host:CreateTexture(nil, "ARTWORK", nil, 3))
        glint:SetTexture(self.artPath .. "diamond-glow.tga", "CLAMP", "CLAMP")
        glint:SetBlendMode("ADD")
        glint:SetAlpha(0)
        host.glint = glint
        entries.groundDivider = host
    end
    local level = self:Number(page.GetFrameLevel, 1, page) or self:Number(root.GetFrameLevel, 1, root)
    if level then pcall(host.SetFrameLevel, host, math.max(0, level - 1)) end
    local cx, cy, w, h = self:CompassBaseRect()
    local bias = self:CompassArmBias(bar)
    local d = A.dividerArt
    local signature = string.format("%.3f|%.3f|%.3f|%.3f", cy, w, h, bias)
    if host.signature ~= signature then
        host.signature = signature
        host:ClearAllPoints()
        host:SetPoint("CENTER", anchor, "CENTER", -bias, cy - self.dock.bottom)
        host:SetSize(w, h)
        local faceTop, faceH = h * d.faceV0, h * (d.faceV1 - d.faceV0)
        local reach = w * d.reach
        local left, right = host.lights.left, host.lights.right
        left:ClearAllPoints()
        left:SetPoint("TOPLEFT", host, "TOPLEFT", w * d.faceU0, -faceTop)
        left:SetSize(reach, faceH)
        right:ClearAllPoints()
        right:SetPoint("TOPRIGHT", host, "TOPLEFT", w * d.faceU1, -faceTop)
        right:SetSize(reach, faceH)
        local g = h * d.diamondA * 1.8
        host.glint:ClearAllPoints()
        host.glint:SetPoint("CENTER", host, "TOPLEFT", w * d.diamondU, -h * d.diamondV)
        host.glint:SetSize(g, g)
    end
    self:CompassShadow(host.shadow, host, self:LookName("compass-divider"), w, h, false)
    if (self.painted[host.art] and self.painted[host.art].name) ~= "compass-divider" then
        self:SetPainted(host.art, "compass-divider")
    end
    self:PaintedAlpha(host.art, 1)
    host.art:Show()
    self:SyncPainted(host.art)

    self:Tint(host.lights.left, "accent", "vertex", 1)
    self:Tint(host.lights.right, "accent", "vertex", 1)
    self:Tint(host.glint, "accent", "vertex", 1)
    host.bars = { left = page.actionBars and page.actionBars.leftBar, right = page.actionBars and page.actionBars.rightBar }
    host.baseRect = { cx = cx, cy = cy, w = w, h = h, head = 0, divider = true }
    if not host:IsShown() then host:Show() end
    return true
end
A.CompassDividerHost = compassDivider

















A.compassDividerTick = 0.05
A.compassDividerHold = 0.15
function A:TickCompassDivider(elapsed)
    self.dividerClock = (self.dividerClock or 0) + (tonumber(elapsed) or 0)
    if self.dividerClock < A.compassDividerTick then return end
    local dt = self.dividerClock
    self.dividerClock = 0
    local state = self.nativeSkins and self.nativeSkins.actions
    local root = _G.GamepadMainActionBarFrame
    local entries = state and root and state.decorations[root]
    local host = entries and entries.groundDivider
    if not host or not host.lights or not host:IsShown() then return end
    local on = not (self.optionIndex and self.optionIndex.compassDividerLight) or self:GetOption("compassDividerLight") ~= false
    local peak = A.dividerArt.light
    local lit = {}
    for _, side in ipairs({ "left", "right" }) do
        local bar = host.bars and host.bars[side]
        local bg = bar and bar.BackgroundFocus
        local shown = on and bg and type(bg.IsShown) == "function" and self:Read(bg.IsShown, 1, bg) == true or false
        host.shownFor = host.shownFor or {}
        host.shownFor[side] = shown and ((host.shownFor[side] or 0) + dt) or 0
        local held = shown and host.shownFor[side] >= A.compassDividerHold - 1e-9
        lit[side] = held
        local want = held and peak or 0
        local t = host.lights[side]
        if math.abs((t:GetAlpha() or 0) - want) > 0.001 then t:SetAlpha(want) end
    end
    local g = lit.left and peak * 0.65 or 0
    if math.abs((host.glint:GetAlpha() or 0) - g) > 0.001 then host.glint:SetAlpha(g) end
    host.held = lit
end



local function hideTray(self, state, frame)
    local entries = frame and state.decorations[frame]
    local host = entries and entries.trayHost
    if host and host:IsShown() then host:Hide() end
end






































local function auraUnion(self, container, list)
    if type(container) ~= "table" then return nil end
    local kids = list
    if type(kids) ~= "table" and type(container.GetChildren) == "function" then
        local ok, result = pcall(function() return { container:GetChildren() } end)
        kids = ok and result or nil
    end
    if type(kids) ~= "table" then return nil end
    local x0, y0, x1, y1, n = nil, nil, nil, nil, 0
    for _, child in ipairs(kids) do
        if type(child) == "table" and type(child.IsShown) == "function" and child.isAuraAnchor ~= true then
            local shown = self:Read(child.IsShown, 1, child)
            if shown == nil then return nil end
            if shown == true then
                local x, y, w, h = self.kbRectOf(self, child)
                if not x then return nil end
                if w > 4 and h > 4 then
                    n = n + 1
                    if not x0 or x < x0 then x0 = x end
                    if not y0 or y < y0 then y0 = y end
                    if not x1 or x + w > x1 then x1 = x + w end
                    if not y1 or y + h > y1 then y1 = y + h end
                end
            end
        end
    end
    return x0, y0, x1, y1, n
end






local function fitAuraTray(self, row, keepEmpty)
    local host, container = row.host, row.container
    if not (host and container and type(host.SetShown) == "function") then return end
    local x0, y0, x1, y1, n = auraUnion(self, container, row.list)
    local want = false
    if n and n > 0 then
        local cx, cy, _, ch = self.kbRectOf(self, container)
        local cs = self:Number(container.GetEffectiveScale, 1, container)
        if cx and cs and cs > 0.05 then



            local l, t = (x0 - cx) / cs, (y1 - (cy + ch)) / cs
            local w, h = (x1 - x0) / cs, (y1 - y0) / cs
            local key = string.format("%.1f|%.1f|%.1f|%.1f", l, t, w, h)
            if host.auiFit ~= key then
                host.auiFit = key
                host:ClearAllPoints()
                host:SetPoint("TOPLEFT", container, "TOPLEFT", l, t)
                host:SetSize(math.max(1, w), math.max(1, h))
            end
            want = true
        end
    elseif n == 0 and keepEmpty then
        local cw = self:Number(container.GetWidth, 1, container)
        local ch = self:Number(container.GetHeight, 1, container)
        if cw and ch and host.auiFit ~= "container" then
            host.auiFit = "container"
            host:ClearAllPoints()
            host:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
            host:SetSize(math.max(1, cw), math.max(1, ch))
        end
        want = cw ~= nil and ch ~= nil
    end
    if host:IsShown() ~= want then pcall(host.SetShown, host, want) end
end
A.auraUnion = auraUnion





function A:TickAuraTrays(elapsed)
    local rows = self.auraTrayRows
    if not rows or #rows == 0 then return end
    self.auraTrayElapsed = (self.auraTrayElapsed or 0) + (elapsed or 0)
    if self.auraTrayElapsed < 0.25 then return end
    self.auraTrayElapsed = 0
    local keepEmpty = self:GetOption("auraTrayEmpty") == true
    for _, row in ipairs(rows) do pcall(fitAuraTray, self, row, keepEmpty) end
end

local function fonts(self, state, root, size)
    self.NativeWalk(root, function(frame)
        if type(frame.GetRegions) ~= "function" then return end
        for _, region in ipairs({ frame:GetRegions() }) do
            if type(region.IsObjectType) == "function" and region:IsObjectType("FontString") then
                font(self, state, region, size, false, true)
            end
        end
    end)
end





A.NativeFont = font





function A:MinimapRim(state, cluster, map)
    return self:ChromeRim(state, cluster, map, "rim", { "TOPRIGHT", "BOTTOMRIGHT" })
end









local CORNER_KEY = { TOPLEFT = "TL", TOPRIGHT = "TR", BOTTOMLEFT = "BL", BOTTOMRIGHT = "BR" }
local CORNER_COORDS = {
    TOPLEFT = { 0, 1, 0, 1 }, TOPRIGHT = { 1, 0, 0, 1 },
    BOTTOMLEFT = { 0, 1, 1, 0 }, BOTTOMRIGHT = { 1, 0, 1, 0 },
}
function A:ChromeRim(state, host, window, prefix, cuts)
    if not window or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    if not entries[prefix .. "T"] then
        for _, side in ipairs({ "T", "B", "L", "R" }) do
            entries[prefix .. side] = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 2))
        end
        for _, corner in ipairs(cuts) do
            local cut = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 3))
            cut:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
            entries[prefix .. CORNER_KEY[corner]] = cut
        end
        entries[prefix .. "Inner"] = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 1))
        entries[prefix .. "Inner"]:SetTexture(self.artPath .. "inner-shadow.tga", "CLAMP", "CLAMP")
    end






    local px = self:PhysicalPixel(host)
    local width = self:Number(window.GetWidth, 1, window) or 198
    local height = self:Number(window.GetHeight, 1, window) or width
    local signature = string.format("%.3f|%.1f|%.1f|%s|%s", px, width, height,
        tostring(self:BordersOn()), self:Scheme().id)
    state.rimSignature = state.rimSignature or {}
    local cache = state.rimSignature[host]
    if not cache then cache = {}; state.rimSignature[host] = cache end
    if cache[prefix] == signature then return end
    cache[prefix] = signature
    local function side(key, p1, p2, horizontal, strength)
        local t = entries[prefix .. key]
        t:ClearAllPoints()
        t:SetPoint(p1, window, p1, 0, 0)
        t:SetPoint(p2, window, p2, 0, 0)
        if horizontal then t:SetHeight(px) else t:SetWidth(px) end
        self:Tint(t, "accent", "color", strength)
        t:SetShown(self:BordersOn())
    end

    side("T", "TOPLEFT", "TOPRIGHT", true, 0.80)
    side("B", "BOTTOMLEFT", "BOTTOMRIGHT", true, 0.55)
    side("L", "TOPLEFT", "BOTTOMLEFT", false, 0.32)
    side("R", "TOPRIGHT", "BOTTOMRIGHT", false, 0.32)




    local cut = math.min(math.max(6, math.floor(math.min(width, height) / 12)), math.floor(math.min(width, height) / 2))
    for _, corner in ipairs(cuts) do
        local t = entries[prefix .. CORNER_KEY[corner]]
        t:ClearAllPoints()
        t:SetPoint(corner, window, corner, 0, 0)
        t:SetSize(cut, cut)
        t:SetTexCoord(unpack(CORNER_COORDS[corner]))
        self:Tint(t, "ink", "vertex", 0.92)
        t:SetShown(true)
    end

    local inner = entries[prefix .. "Inner"]
    inner:ClearAllPoints()
    inner:SetPoint("TOPLEFT", window, "TOPLEFT", 0, 0)
    inner:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
    inner:SetHeight(math.min(math.max(4, math.floor(width / 22)), math.floor(height / 2)))
    inner:SetTexCoord(0, 1, 1, 0)
    self:Tint(inner, "shadow", "vertex", 0.55)
    inner:SetShown(true)
    state.count = state.count + 1
end

function A:HideChromeRim(state, host, prefix)
    local entries = state.decorations[host]
    if not entries then return end
    for _, key in ipairs({ "T", "B", "L", "R", "TL", "TR", "BL", "BR", "Inner" }) do
        local t = entries[prefix .. key]
        if t and t:IsShown() then t:Hide() end
    end
    if state.rimSignature and state.rimSignature[host] then state.rimSignature[host][prefix] = nil end
end



function A:ChromeChat()
    if not (self.db and self.optionIndex) then return true end

    return self:GetOption("chromeChat") and true or false
end






local function chatSkinLive(self)
    local st = self.nativeSkins and self.nativeSkins.chat
    return self.db and self.db.skins and self.db.skins.chat and self.auditedSink and st and not st.failed
end

function A:ChatLiveMark(state, tab)
    if not tab or type(tab.CreateTexture) ~= "function" then return end
    local entries = state.decorations[tab]
    if not entries then entries = {}; state.decorations[tab] = entries end
    if not entries.liveMark then
        local mark = self:Own(tab:CreateTexture(nil, "OVERLAY", nil, 4))
        mark:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", self.tokens.space.xs, 0)
        mark:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -self.tokens.space.xs, 0)
        mark:SetHeight(2)
        self:Tint(mark, "accent", "color", 1)
        entries.liveMark = mark
        self.chatLiveMarks = self.chatLiveMarks or setmetatable({}, { __mode = "k" })
        self.chatLiveMarks[tab] = mark
    end
    if not self.chatLiveHooked and type(hooksecurefunc) == "function" and type(FCFTab_UpdateColors) == "function" then
        self.chatLiveHooked = true
        pcall(hooksecurefunc, "FCFTab_UpdateColors", function(hooked, selected)
            local mark = A.chatLiveMarks and A.chatLiveMarks[hooked]
            if not mark or not chatSkinLive(A) then return end
            local want = (selected and A:ChromeChat()) and true or false
            if mark:IsShown() ~= want then mark:SetShown(want) end
        end)
    end
    local active = tab.ActiveMiddle
    local live = self:ChromeChat() and active and type(active.IsShown) == "function" and active:IsShown() and true or false
    if entries.liveMark:IsShown() ~= live then entries.liveMark:SetShown(live) end
    state.count = state.count + 1
end





local function asset(self, state, region, name, coords, role)
    if not region or type(region.GetTexture) ~= "function" then return end
    local file = region:GetTexture()
    local atlas = type(region.GetAtlas) == "function" and region:GetAtlas() or nil
    if not self:IsPublic(file) or not self:IsPublic(atlas) then return end
    if type(file) ~= "string" and type(file) ~= "number" and type(atlas) ~= "string" then return end
    local texCoords = type(region.GetTexCoord) == "function" and { region:GetTexCoord() } or nil
    if texCoords then
        for _, value in ipairs(texCoords) do
            if not self:IsPublic(value) or type(value) ~= "number" then return end
        end
    end





    local hasColor = type(region.GetVertexColor) == "function" and type(region.SetVertexColor) == "function"
    local color
    if hasColor then
        color = { region:GetVertexColor() }
        for i = 1, 4 do
            local value = color[i]
            if not self:IsPublic(value) or type(value) ~= "number" or value ~= value then hasColor = false; break end
        end
    end





    local firstCapture = not (state.properties and state.properties[region] and state.properties[region].asset)
    self:RememberProperty(state, region, "asset", function()
        return function()
            if type(atlas) == "string" and atlas ~= "" then region:SetAtlas(atlas)
            else region:SetTexture(file) end
            if texCoords then region:SetTexCoord(unpack(texCoords)) end


            if role and hasColor then
                local now = { region:GetVertexColor() }
                region:SetVertexColor(color[1], color[2], color[3], now[4] or color[4])
            end
        end
    end)



    local target = self.artPath .. name .. ".tga"
    if not (file == target and (atlas == nil or atlas == "")) then
        region:SetTexture(target, "CLAMP", "CLAMP")
    end
    if coords and type(region.SetTexCoord) == "function" then
        local same = texCoords ~= nil
        if same then for i = 1, 4 do if texCoords[i] ~= coords[i] then same = false end end end
        if not same then region:SetTexCoord(unpack(coords)) end
    end
    if hasColor and role then


        state.swapped = state.swapped or setmetatable({}, { __mode = "k" })
        state.swapped[region] = true
        local r, g, b = self:Color(role)
        local now = { region:GetVertexColor() }
        if now[1] ~= r or now[2] ~= g or now[3] ~= b then region:SetVertexColor(r, g, b, now[4]) end
    elseif hasColor and firstCapture then
        region:SetVertexColor(1, 1, 1, color[4])
    end
    state.count = state.count + 1
end





local chromeWords = { "border", "frame", "background", "backdrop", "divider", "ornament",
    "shadow", "nineslice", "edge", "gold", "metal", "plate" }
local function stripChrome(self, state, root)
    self.NativeWalk(root, function(frame)
        if type(frame.GetRegions) ~= "function" then return end
        for _, region in ipairs({ frame:GetRegions() }) do
            if type(region.IsObjectType) == "function" and region:IsObjectType("Texture")
                and type(region.GetAtlas) == "function" then
                local atlas = region:GetAtlas()
                if self:IsPublic(atlas) and type(atlas) == "string" then
                    local lower = atlas:lower()

                    for _, word in ipairs(chromeWords) do
                        if not lower:find("shield", 1, true) and lower:find(word, 1, true) then
                            self:HoldHidden(state, region)
                            state.count = state.count + 1
                            break
                        end
                    end
                end
            end
        end
    end)
end






local cornerCoords = {
    TopLeftCorner = { 0, 1, 0, 1 }, TopRightCorner = { 1, 0, 0, 1 },
    BottomLeftCorner = { 0, 1, 1, 0 }, BottomRightCorner = { 1, 0, 1, 0 },
}

local function nineSlice(self, state, frame)
    if not frame then return end
    for key, coords in pairs(cornerCoords) do asset(self, state, frame[key], "tooltip-corner", coords) end
    for _, key in ipairs({ "TopEdge", "BottomEdge", "LeftEdge", "RightEdge" }) do
        asset(self, state, frame[key], "tooltip-edge", { 0, 1, 0, 1 })
    end
end

local function unit(self, state, frame, player)
    if not frame then return end
    local container = player and frame.PlayerFrameContainer or frame.TargetFrameContainer
    local content = player and frame.PlayerFrameContent or frame.TargetFrameContent
    local main = content and (player and content.PlayerFrameContentMain or content.TargetFrameContentMain)
    if not container or not main then return end
    local contextual = content and (player and content.PlayerFrameContentContextual
        or content.TargetFrameContentContextual)









    self.NativeStrip(self, state,
        container.FrameTexture, container.VehicleFrameTexture, container.AlternatePowerFrameTexture,
        container.FrameFlash, container.Flash, container.BossPortraitFrameTexture,
        main.StatusTexture, main.PvpBackgroundCircle, main.PvpBackgroundIcon, main.LevelBackgroundCircle,
        contextual and contextual.AttackIcon, contextual and contextual.PlayerPortraitCornerIcon)






    if contextual and type(contextual.GetRegions) == "function" then
        for _, region in ipairs({ contextual:GetRegions() }) do
            if type(region.GetAtlas) == "function" then
                local atlas = region:GetAtlas()
                if self:IsPublic(atlas) and type(atlas) == "string" and atlas:lower():find("smallcircle", 1, true) then
                    self:HoldHidden(state, region)
                    state.count = state.count + 1
                end
            end
        end
    end




    self:HoldHidden(state, main.ReputationColor)




    local portrait = player and container.PlayerPortrait or container.Portrait
    self:HoldHidden(state, portrait)



    local tot = frame.totFrame
    if tot then
        self:HoldHidden(state, (tot.TargetFrameContainer and tot.TargetFrameContainer.Portrait) or tot.Portrait)
    end
    local healthContainer = main.HealthBarsContainer
    local health = healthContainer and healthContainer.HealthBar
    local mana = player and main.ManaBarArea and main.ManaBarArea.ManaBar or main.ManaBar








    if healthContainer then
        local gutter = player and 34 or 8
        local br = mana or healthContainer













        local veiled = self:GetOption("unitVeil")
        if veiled then
            self.NativeVeilPanel(self, state, frame, "unitveil", healthContainer, -gutter, 22,
                br, 8, -6, self:Surface("panel"))
        else
            self.NativeGlassPanel(self, state, frame, "unit", healthContainer, -gutter, 22,
                br, 8, -6, self:Surface("panel"), 1, false, "panel")
        end
        local entries = state.decorations[frame]
        if entries then
            for _, name in ipairs({ "unit", "unitTop", "unitBottom", "unitLeft", "unitRight" }) do
                local t = entries[name]
                if t and veiled and t:IsShown() then t:Hide() end
            end
            for _, suffix in ipairs({ "L", "R", "M" }) do
                local t = entries["unitveil" .. suffix]
                if t and t:IsShown() ~= veiled then if veiled then t:Show() else t:Hide() end end
            end

            self:SuppressDepth(entries, "unit~", veiled)
        end
    end
    if health then
        self.NativeBorder(self, state, health, 1)
        self:BarFinish(state.decorations[health], health)
    end
    if mana then
        self.NativeBorder(self, state, mana, 1)
        self:BarFinish(state.decorations[mana], mana)
    end

















    local type_ = self.tokens.type
    fonts(self, state, frame, type_.body)



    font(self, state, player and PlayerName or main.Name, type_.hero, true)
    if player and PlayerLevelText then
        font(self, state, PlayerLevelText, type_.body, false)
    elseif main.LevelText then
        font(self, state, main.LevelText, type_.body, false)
    end
end

function A:StyleNativeModule(key, state)
    if key == "units" then
        unit(self, state, PlayerFrame, true)
        for _, name in ipairs({ "TargetFrame", "FocusFrame", "Boss1TargetFrame", "Boss2TargetFrame",
            "Boss3TargetFrame", "Boss4TargetFrame", "Boss5TargetFrame" }) do unit(self, state, _G[name], false) end


        self:StyleNativeCastBars(state, stripChrome, fonts)





        for _, name in ipairs({ "SwingTimerMainHandFrame", "SwingTimerOffHandFrame", "SwingTimerRangedFrame" }) do
            local timer = _G[name]
            local bar = timer and timer.StatusBar
            if bar then
                self.NativeGlassPanel(self, state, timer, "cast", timer, -2, 2, timer, 2, -2, self:Surface("base"), 1, false, "base")
                for _, region in ipairs({ timer.Background, timer.Border, bar.TypeLabelShadow }) do
                    if region then self:HoldHidden(state, region) end
                end
                state.decorations[bar] = state.decorations[bar] or {}
                self:BarFinish(state.decorations[bar], bar, "cast")
                fonts(self, state, timer, self:Type("caption"))
            end
        end
    elseif key == "party" then
        for _, name in ipairs({ "PartyFrame", "CompactPartyFrame", "CompactRaidFrameContainer" }) do
            local root = _G[name]
            fonts(self, state, root, self.tokens.type.body)
            self.NativeWalk(root, function(frame)
                if frame.healthBar or frame.HealthBar or frame.HealthBarContainer then



                    local tile = self:IsCompactUnitFrame(frame) and self:RaidTileOn()
                    if tile then
                        self:ChromeHide(state, frame, "panel", "border")
                    else
                        self.NativeFill(self, state, frame, self:Surface("panel"))
                        self.NativeBorder(self, state, frame, 1)
                    end
                    if self:IsCompactUnitFrame(frame) then self:RaidTile(state, frame, tile) end
                    self.NativeStrip(self, state, frame.Texture)
                end
            end)
        end
    elseif key == "actions" then
        local page = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
        if page then


            if not (self.BumperPlaques and self:BumperPlaques(state, page, true)) then
                self.NativeTint(self, state, page.LeftShoulderBackground)
                self.NativeTint(self, state, page.RightShoulderBackground)
            end

            if self.TriggerChips then self:TriggerChips(state, page, true) end
        end
        if page and type(page.actionBars) == "table" then


































            local bars = {}
            local w, h = 0, 0
            for _, barKey in ipairs({ "topBar", "leftBar", "rightBar", "bottomBar" }) do
                local bar = page.actionBars[barKey]
                if bar then
                    bars[#bars + 1] = bar
                    local bw = self:Number(bar.GetWidth, 1, bar)
                    local bh = self:Number(bar.GetHeight, 1, bar)
                    if bw and bw > w then w = bw end
                    if bh and bh > h then h = bh end
                end
            end









            local D = self.dock
            local capW = D and D.trayW or 276
            local capH = D and D.trayH or 124
            local armPad = (D and D.trayPad) or self.tokens.space.xs
            w = (w >= 32 and w <= capW) and w or math.min(math.max(w, 32), capW)
            h = (h >= 24 and h <= capH) and h or math.min(math.max(h, 24), capH)








            local mode = self:CompassGroundMode()
            local armTrays = self:GetOption("clusterTray") and not (D and D.socket)
            for _, bar in ipairs(bars) do


                local watermark = bar.BackgroundWatermark
                if watermark then self:ReleaseProperty(state, watermark, "alpha") end
                if armTrays then




                    tray(self, state, bar, armPad, self:Surface("wash"), w, h)
                else
                    hideTray(self, state, bar)
                end
            end

            compassDivider(self, state, GamepadMainActionBarFrame, page, page.actionBars.bottomBar,
                mode == "divider" and self:AuthoredSockets() and true or false)
        end
        if GamepadPersistentInputLegend then















            self.NativeStripOwn(self, state, GamepadPersistentInputLegend)
            self.NativeFill(self, state, GamepadPersistentInputLegend, self:Surface("base"), true, "base")




            self.NativeBorder(self, state, GamepadPersistentInputLegend, 1, 0)


            stripChrome(self, state, GamepadPersistentInputLegend)




            for _, child in ipairs({ GamepadPersistentInputLegend:GetChildren() }) do
                local h = type(child.GetHeight) == "function" and self:Number(child.GetHeight, 1, child)
                if h and h >= 60 then
                    self.NativeStripOwn(self, state, child)






                    self.NativeFill(self, state, child, self:Surface("base"), true, "base")
                    self.NativeBorder(self, state, child, 1, 0)
                end
            end



            fonts(self, state, GamepadPersistentInputLegend, self:Type("caption"))
        end




        for _, name in ipairs({ "EssentialCooldownViewer", "UtilityCooldownViewer",
            "BuffIconCooldownViewer", "BuffBarCooldownViewer" }) do
            local viewer = _G[name]
            if viewer then
                if self:GetOption("clusterTray") then
                    tray(self, state, viewer, self.tokens.space.xs, self:Surface("wash"))
                else
                    hideTray(self, state, viewer)
                end
            end
        end





        for _, name in ipairs({ "StatusTrackingBarManager", "MainStatusTrackingBarContainer" }) do
            local bars = _G[name]
            if bars then
                stripChrome(self, state, bars)
                fonts(self, state, bars, self.tokens.type.caption)
            end
        end
        do
            local main = _G.MainStatusTrackingBarContainer
            if main then




                self.NativeFill(self, state, main, self:Surface("base"), true, "base")
                self.NativeBorder(self, state, main, 1)
            end
        end
        for _, name in ipairs({ "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight",
            "MultiBarLeft", "MultiBarRight", "StanceBar", "PetActionBar" }) do
            local root = _G[name]
            if root then
















                fonts(self, state, root, self.tokens.type.caption)
                self.NativeWalk(root, function(frame)
                    for _, regionKey in ipairs({ "HotKey", "Count" }) do
                        local region = frame[regionKey]
                        if type(region) == "table" and type(region.IsObjectType) == "function"
                            and self:Read(region.IsObjectType, 1, region, "FontString") == true then













                            font(self, state, region, self:Type("caption"), false, false)
                        end
                    end
                end)
                if root.Background then alpha(self, state, root.Background, 0) end
            end
        end
    elseif key == "auras" then

















        local on = self:GetOption("auraTray")
        local containers = {}
        for _, name in ipairs({ "BuffFrame", "DebuffFrame" }) do
            local root = _G[name]
            local container = root and root.AuraContainer
            if container then containers[#containers + 1] = { container, type(root.auraFrames) == "table" and root.auraFrames or nil } end
        end








        local heldPlus = { TargetFrame = "plusTargetOn", FocusFrame = "plusFocusOn" }
        local hidden = 0
        for _, name in ipairs({ "TargetFrame", "FocusFrame" }) do

            local container = path(_G[name], "TargetFrameContent", "TargetFrameContentContextual", "Auras")
            if container then
                if self.plusActive and self:GetOption(heldPlus[name]) then
                    hideTray(self, state, container)
                    hidden = hidden + 1
                else
                    containers[#containers + 1] = { container }
                end
            end
        end
        self:Note("auras target rows", hidden > 0
            and "hidden with the native frame in Plus mode; Plus plates show no auras"
            or "native rows styled")
        self.auraTrayRows = {}
        for _, entry in ipairs(containers) do
            local container = entry[1]
            if on then

















                local host = tray(self, state, container, self.tokens.space.xs, self:Surface("base"))





                if host then
                    self.auraTrayRows[#self.auraTrayRows + 1] =
                        { host = host, container = container, list = entry[2] }
                end
            else
                hideTray(self, state, container)
            end
        end
        self:TickAuraTrays(1)
    elseif key == "minimap" then
        if MinimapCluster then







            local sp = self.tokens.space
            local map = path(MinimapCluster, "MinimapContainer", "Minimap")
            self:SquareMinimap(state, map)


            self.NativeStrip(self, state, MinimapCompassTexture, MinimapCompassTextureUnderlay)



            local painted = map and self:MapPainted()
            if map then self:ChromeMapCard(state, MinimapCluster, map, painted) end
            if map and not painted then
                local pad = sp.sm
                local cardEntries = state.decorations[MinimapCluster]
                if cardEntries then self:SuppressDepth(cardEntries, "card~", false) end
                self.NativeGlassPanel(self, state, MinimapCluster, "card", map, -pad, 26,
                    map, pad, -26, self:Surface("base"), 1, true, "base")
                local card = state.decorations[MinimapCluster] and state.decorations[MinimapCluster].card
                self.NativeRule(self, state, MinimapCluster, "cardRule", card, "RIGHT", 0)




















                self.NativeBorder(self, state, MinimapBackdrop or map, 1, 2, map, "BACKGROUND")
                self:MinimapRim(state, MinimapCluster, map)
            end
            if map then










                local entries = state.decorations[MinimapCluster]
                if not entries.medallionHost then
                    local host = self:Own(CreateFrame("Frame", nil, MinimapCluster))
                    host:EnableMouse(false)
                    host:SetAllPoints(map)
                    entries.medallionHost = host
                end
                local host = entries.medallionHost
                local want = (self:Number(map.GetFrameLevel, 1, map) or 1) + 5
                if host:GetFrameLevel() ~= want then host:SetFrameLevel(want) end
                if self:ChromeCrest("map") then
                    if not host:IsShown() then host:Show() end
                    local inset = 2 * self:PhysicalPixel(host)
                    self:CrestSeat(host, entries, "medallion", map, inset, -inset, "OVERLAY", 4)
                    state.count = state.count + 1
                else
                    self:HideCrestSeat(entries, "medallion")
                end
            end
            local top = MinimapCluster.BorderTop
            if top and map then


                self.NativeStripOwn(self, state, top)
            end
            local tracking = MinimapCluster.Tracking
            if tracking then self.NativeStrip(self, state, tracking.Background) end
            local coords = path(MinimapCluster, "MinimapContainer", "PlayerCoords")



            local plaqueText = self.MapPlaqueTextSize and self:MapPlaqueTextSize()



            local sub = self.MapPlaqueSubSize and self:MapPlaqueSubSize()
            if coords and coords.CoordText then
                font(self, state, coords.CoordText, sub or plaqueText or self.tokens.type.caption, false)
                self:NativeJustify(state, coords.CoordText, sub and "LEFT" or nil)
                if sub then textColor(self, state, coords.CoordText, "muted")
                else self:ReleaseProperty(state, coords.CoordText, "textColor") end
            end
            local ticker = _G.TimeManagerClockTicker
            if ticker then
                if sub then
                    font(self, state, ticker, sub, false)
                    textColor(self, state, ticker, "muted")
                    state.baseTicker = true
                elseif state.baseTicker then

                    state.baseTicker = nil
                    self:ReleaseProperty(state, ticker, "font")
                    self:ReleaseProperty(state, ticker, "textColor")
                    if state.explicitFonts then state.explicitFonts[ticker] = nil end
                end
            end


            if coords then
                if self:GetOption("minimapCoords") then self:ReleaseHidden(state, coords)
                else self:HoldHidden(state, coords) end
            end
            local zone = MinimapCluster.ZoneTextButton
            if zone then
                if self:GetOption("minimapZone") then self:ReleaseHidden(state, zone)
                else self:HoldHidden(state, zone) end
            end
            fonts(self, state, MinimapCluster, self.tokens.type.caption)
            if MinimapZoneText then




                local onBase = self.MapBaseLike and self:MapBaseLike()
                local zoneSize = (onBase and plaqueText and self.mapZoneFit and math.min(plaqueText, self.mapZoneFit))
                    or plaqueText or self.tokens.type.body
                font(self, state, MinimapZoneText, zoneSize, not onBase)



                if onBase and plaqueText then self:FitMapZone(state, plaqueText) end





                textColor(self, state, MinimapZoneText, "text")
            end
        end
        if WorldMapFrame and WorldMapFrame.BorderFrame then
            local border = WorldMapFrame.BorderFrame





            local slice = border.NineSlice
            if slice then
                for _, piece in ipairs({ "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
                    "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "Center" }) do
                    if slice[piece] then self:HoldHidden(state, slice[piece]) end
                end
            end
            self.NativeBorder(self, state, border, 2)
            font(self, state, border.TitleText or (border.TitleContainer and border.TitleContainer.TitleText), self.tokens.type.hero, true)
            if WorldMapFrame.OverscrollBG then self.NativeTint(self, state, WorldMapFrame.OverscrollBG.Texture) end
        end
    elseif key == "objectives" then
        for _, name in ipairs({ "ObjectiveTrackerFrame", "QuestObjectiveTracker", "CampaignQuestObjectiveTracker",
            "ScenarioObjectiveTracker", "AchievementObjectiveTracker", "BonusObjectiveTracker", "WorldQuestObjectiveTracker" }) do
            local frame = _G[name]
            if frame then
                fonts(self, state, frame, self.tokens.type.body)
                nineSlice(self, state, frame.NineSlice)
                local header = frame.Header
                if header then







                    asset(self, state, header.Background, "clear", { 0, 1, 0, 1 })
                    self:ChromeHide(state, header, "border")
                    font(self, state, header.Text, self.tokens.type.title, true)

























                    local role = frame == ObjectiveTrackerFrame and "text" or "muted"
                    textColor(self, state, header.Text, role)
                    if type(header.GetRegions) == "function" then
                        for _, region in ipairs({ header:GetRegions() }) do
                            if type(region.IsObjectType) == "function" and region:IsObjectType("FontString") then
                                textColor(self, state, region, role)
                            end
                        end
                    end





                    self.NativeTintChrome(self, state, header)
                end
            end
        end
    elseif key == "chat" then
        for i = 1, 10 do
            local frame, tab = _G["ChatFrame" .. i], _G["ChatFrame" .. i .. "Tab"]
            if frame then
                font(self, state, frame, self.tokens.type.body, false)
                local edit = frame.editBox or _G["ChatFrame" .. i .. "EditBox"]
                if edit then
                    font(self, state, edit, self.tokens.type.body, false)



                    local name = edit:GetName() or ("ChatFrame" .. i .. "EditBox")
                    for _, suffix in ipairs({ "Left", "Right", "Mid", "FocusLeft", "FocusRight", "FocusMid" }) do
                        self.NativeStrip(self, state, _G[name .. suffix])
                    end
                    self:WatchChatFocus()
                    self:ChatEditDress(state, edit, i)
                end












                self.NativeStrip(self, state, _G["ChatFrame" .. i .. "Background"])
                for _, suffix in ipairs({ "TopLeftTexture", "TopRightTexture", "BottomLeftTexture",
                    "BottomRightTexture", "LeftTexture", "RightTexture", "TopTexture", "BottomTexture" }) do
                    self.NativeStrip(self, state, _G["ChatFrame" .. i .. suffix])
                end
            end
            if tab then






                self.NativeStrip(self, state, tab.Left, tab.Middle, tab.Right,
                    tab.ActiveLeft, tab.ActiveMiddle, tab.ActiveRight,
                    tab.HighlightLeft, tab.HighlightMiddle, tab.HighlightRight)



                self:ChromeHide(state, tab, "panel")
                font(self, state, tab.Text, self.tokens.type.caption, false, nil, "OUTLINE")







                self:ChatLiveMark(state, tab)
            end
        end


        self:ChatGutter(state, true)
    elseif key == "tooltips" then
        for _, name in ipairs({ "GameTooltip", "ShoppingTooltip1", "ShoppingTooltip2", "ItemRefTooltip",
            "ItemRefShoppingTooltip1", "ItemRefShoppingTooltip2" }) do
            local frame = _G[name]
            if frame then




                local ns = frame.NineSlice
                if ns then
                    self.NativeStrip(self, state, ns.TopLeftCorner, ns.TopRightCorner, ns.BottomLeftCorner,
                        ns.BottomRightCorner, ns.TopEdge, ns.BottomEdge, ns.LeftEdge, ns.RightEdge, ns.Center)
                end
                self.NativeGlassPanel(self, state, frame, "card", frame, 0, 0, frame, 0, 0, self:Surface("raised"), 1, false, "raised")
                fonts(self, state, frame, self.tokens.type.body)
                font(self, state, frame.TextLeft1, self.tokens.type.hero, true)




            end
        end



        if GameTooltipStatusBar then
            self.NativeBorder(self, state, GameTooltipStatusBar, 1)
            if self:GetOption("tooltipHealthBar") then self:ReleaseHidden(state, GameTooltipStatusBar)
            else self:HoldHidden(state, GameTooltipStatusBar) end
        end
    end
end
