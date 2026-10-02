local _, A = ...
A.artPath = "Interface\\AddOns\\AdaptiveUI\\Art\\"
A.fallbackFont = "Fonts\\ARIALN.TTF"


















A.headingFonts = {
    barlow = "Interface\\AddOns\\AdaptiveUI\\Fonts\\BarlowSemiCondensed-SemiBold.ttf",
    chakra = "Interface\\AddOns\\AdaptiveUI\\Fonts\\ChakraPetch-SemiBold.ttf",



    spectral = "Interface\\AddOns\\AdaptiveUI\\Fonts\\Spectral-SemiBold.ttf",
}
A.fontPath = A.headingFonts.barlow
A.bodyFontPath = "Interface\\AddOns\\AdaptiveUI\\Fonts\\BarlowSemiCondensed-Medium.ttf"








A.numericFontPath = "Interface\\AddOns\\AdaptiveUI\\Fonts\\BarlowSemiCondensed-SemiBold.ttf"

function A:HeadingFontPath()
    local choice = self.db and self.optionIndex and self:GetOption("themeHeadingFont")
    return self.headingFonts[choice] or self.fontPath
end

function A:FontPath(heading)
    local locale = type(GetLocale) == "function" and GetLocale() or "enUS"
    if locale == "koKR" or locale == "zhCN" or locale == "zhTW" or locale == "ruRU" then
        return STANDARD_TEXT_FONT or self.fallbackFont
    end
    if heading == "numeric" then return self.numericFontPath end
    return heading and self:HeadingFontPath() or self.bodyFontPath
end



function A:SetNumberFont(region, size)
    self:SetThemedFont(region, size, "numeric")
end










A.themedFonts = setmetatable({}, { __mode = "k" })







































A.safeCap = 0.12
function A:SafeInset(m)
    local width = (m and m.width) or (UIParent and self:Number(UIParent.GetWidth, 1, UIParent)) or 1920
    local height = (m and m.height) or (UIParent and self:Number(UIParent.GetHeight, 1, UIParent)) or 1080
    local zone = 0
    if self.db and self.optionIndex then zone = self:GetOption("safeZone") or 0 end
    if zone > self.safeCap then zone = self.safeCap end
    local base = self.tokens.margin
    local x = math.max(base, math.floor(width * zone + 0.5))
    local y = math.max(base, math.floor(height * zone + 0.5))
    return x, y
end

function A:Type(name)
    local size = self.tokens.type[name] or self.tokens.type.body
    local floor = self.tokens.type.body
    return size < floor and floor or size
end






















function A:TypeLift(scale)
    local s = tonumber(scale)
    if type(s) ~= "number" or s ~= s or s <= 0.05 or s > 20 then return 1 end
    if s >= 1 then return 1 end
    return 1 / s
end





function A:TextScale()
    local value = self.db and self.db.textScale
    if type(value) ~= "number" or value ~= value then return 1 end
    return math.max(0.85, math.min(1.2, value))
end





function A:PixelSize(name, scale)
    local size = self:Type(name) * self:TextScale() * self:TypeLift(scale)



    size = math.ceil(size * 2) / 2
    return math.max(8, math.min(64, size))
end



function A:SetPixelFont(region, name, scale, heading, flags)
    self:SetThemedFont(region, self:PixelSize(name, scale), heading, flags)
end





function A:SetPixelNumberFont(region, name, scale, flags)
    self:SetThemedFont(region, self:PixelSize(name, scale), "numeric", flags)
end




















A.textFits = setmetatable({}, { __mode = "k" })
function A:SetFittedText(region, text, maxSize, minSize, heading)
    if not region or type(region.GetStringWidth) ~= "function" then return end
    if text ~= nil then region:SetText(text) end
    local box = self:Number(region.GetWidth, 1, region)
    if not box or box <= 1 then return end
    local shown = self:Text(region.GetText, 1, region)
    if type(shown) ~= "string" or shown == "" then return end
    local signature = string.format("%s|%.1f|%.1f", shown, box, maxSize)
    if self.textFits[region] == signature then return end
    self.textFits[region] = signature
    local file, _, flags = region:GetFont()
    if type(file) ~= "string" then return end
    local function widthAt(size)
        if not pcall(region.SetFont, region, file, size, flags or "") then return nil end
        return self:Number(region.GetStringWidth, 1, region)
    end
    local want = widthAt(maxSize)
    if not want or want <= 0 or want <= box then return end
    local size = math.floor(maxSize * (box / want) * 2) / 2
    if size < minSize then size = minSize end
    if size > maxSize then size = maxSize end
    for _ = 1, 6 do
        local at = widthAt(size)
        if not at or at <= box or size <= minSize then
            if heading == true then self.themedFonts[region] = { size = size, flags = flags } end
            return
        end
        size = size - 0.5
        if size < minSize then size = minSize end
    end
    if heading == true then self.themedFonts[region] = { size = size, flags = flags } end
end













function A:PhysicalPixel(frame)
    local height = 1080
    if type(GetPhysicalScreenSize) == "function" then
        local ok, _, h = pcall(GetPhysicalScreenSize)
        if ok and type(h) == "number" and h > 0 then height = h end
    end
    local scale = 1
    if frame and type(frame.GetEffectiveScale) == "function" then
        local value = self:Number(frame.GetEffectiveScale, 1, frame)
        if type(value) == "number" and value > 0.05 and value < 20 then scale = value end
    end
    local unit = 768 / height / scale
    if unit ~= unit or unit <= 0 then return 1 end



    return math.max(0.34, math.min(4, unit))
end

function A:SetThemedFont(region, size, heading, flags, native)



    if self.textFits then self.textFits[region] = nil end
    local ok, result = pcall(region.SetFont, region, self:FontPath(heading), size, flags or "")
    if not ok or result == false then
        region:SetFont(STANDARD_TEXT_FONT or self.fallbackFont, size, flags or "")
    end
    if not native then




        if heading == true then self.themedFonts[region] = { size = size, flags = flags } end
        self:StyleShadow(region)
    end
end


function A:RefreshHeadingFont()
    local path = self:FontPath(true)
    for region, entry in pairs(self.themedFonts) do
        local ok, file = pcall(region.GetFont, region)
        if ok and file ~= path then
            pcall(region.SetFont, region, path, entry.size, entry.flags or "")
        end
    end
end




A.themes = {
    rpg = {
        text = { 0.89, 0.95, 0.93 }, muted = { 0.59, 0.70, 0.71 },
        player = { 0.46, 0.87, 0.67 }, target = { 0.91, 0.48, 0.40 },
        energy = { 1.00, 0.78, 0.31 }, mana = { 0.35, 0.70, 1.00 },
        rage = { 1.00, 0.38, 0.29 }, combo = { 1.00, 0.84, 0.44 },
        ornament = 1, plate = 1,
    },
    minimal = {
        text = { 0.86, 0.92, 0.91 }, muted = { 0.56, 0.64, 0.66 },
        player = { 0.48, 0.72, 0.62 }, target = { 0.72, 0.47, 0.44 },
        energy = { 0.82, 0.76, 0.51 }, mana = { 0.41, 0.62, 0.79 },
        rage = { 0.80, 0.43, 0.37 }, combo = { 0.83, 0.78, 0.59 },
        ornament = 0.35, plate = 0.86,
    },
}















A.artSlots = A.artSlots or {}
A.artFallback = {
    obsidian = "plate", banner = "fade", crest = "crest",
    brassCorner = "bar-chamfer", parchment = "plate", minimapRim = "minimap-mask",
}




A.sigilGlyphs = { "moon", "leaf", "sun", "drop", "diamond", "spark", "seed", "spiral" }






A.artFallback["sigil-moon"] = "sigil-moon"
A.artFallback["sigil-leaf"] = "sigil-leaf"
A.artFallback["sigil-sun"] = "sigil-sun"
A.artFallback["sigil-drop"] = "sigil-drop"
A.artFallback["sigil-spark"] = "sigil-spark"
A.artFallback["sigil-spiral"] = "sigil-spiral"
A.artFallback["sigil-diamond"] = "diamond-mask"
A.artFallback["sigil-seed"] = "diamond-mask"












A.sigilLine = { leaf = true, sun = true, spiral = true, seed = true }
A.sigilDetailSize = 24
function A:SigilFile(glyph, size)
    glyph = glyph or "diamond"
    if self.sigilLine[glyph] and (tonumber(size) or 0) < self.sigilDetailSize then
        return self.artFallback["sigil-" .. glyph] or "diamond-mask"
    end
    return self:SlotFile("sigil-" .. glyph)
end












function A:SigilBadge(host, store, key, size, glyph, layer, sublevel)
    store, key = store or host, key or "sigil"
    if not host or type(host.CreateTexture) ~= "function" then return end
    layer, sublevel = layer or "ARTWORK", sublevel or 0
    if not store[key .. "Disc"] then
        local disc = self:Own(host:CreateTexture(nil, layer, nil, sublevel))
        disc:SetTexture(self.artPath .. "sigil-disc.tga", "CLAMP", "CLAMP")
        self:Tint(disc, "inkDeep", "vertex", 0.95)
        local mark = self:Own(host:CreateTexture(nil, layer, nil, sublevel + 1))
        self:Tint(mark, "accent", "vertex", 0.92)
        store[key .. "Disc"], store[key .. "Glyph"] = disc, mark
    end
    local disc, mark = store[key .. "Disc"], store[key .. "Glyph"]
    local inner = math.max(6, math.floor(size * 0.62 + 0.5))
    disc:SetSize(size, size)
    mark:SetTexture(self.artPath .. self:SigilFile(glyph, inner) .. ".tga", "CLAMP", "CLAMP")
    mark:SetSize(inner, inner)
    mark:ClearAllPoints()
    mark:SetPoint("CENTER", disc, "CENTER", 0, 0)
    return disc, mark
end


function A:SlotFile(slot)
    local installed = self.artSlots and self.artSlots[slot]
    if type(installed) == "string" and installed ~= "" then return installed end
    return self.artFallback[slot] or slot
end


function A:HasArt(slot)
    return type(self.artSlots and self.artSlots[slot]) == "string"
end










A.crestDetailSize = 48
function A:CrestFile(size)
    if (tonumber(size) or 0) >= self.crestDetailSize then return self:SlotFile("crest") end
    return "crest"
end













A.crestSeatPixels = 64
function A:ChromeCrest(where)
    if self.db and self.optionIndex then
        if self:GetOption("chromeSkin") ~= "authored" then return false end
        local want = self:GetOption("chromeCrest")
        if want == "off" or (want ~= "both" and want ~= where) then return false end
    end
    return true
end

function A:CrestSeatSize(host)
    return self.crestSeatPixels * self:PhysicalPixel(host)
end




function A:CrestSeat(host, store, key, relative, x, y, layer, sublevel)
    if not host or type(host.CreateTexture) ~= "function" then return 0 end
    layer, sublevel = layer or "ARTWORK", sublevel or 1
    if not store[key .. "Seat"] then
        store[key .. "Well"] = self:Own(host:CreateTexture(nil, layer, nil, sublevel))
        store[key .. "Crest"] = self:Own(host:CreateTexture(nil, layer, nil, sublevel + 1))



        store[key .. "Seat"] = self:PaintedTexture(host, layer, sublevel + 2, "chrome-seat")
        store[key .. "SeatAcc"] = self:PaintedTwin(store[key .. "Seat"])
    end
    local seat, well, crest = store[key .. "Seat"], store[key .. "Well"], store[key .. "Crest"]
    local px = self:PhysicalPixel(host)
    local size = self.crestSeatPixels * px
    local inner = size * 0.75
    local detail = self.crestSeatPixels * 0.75


    self.seatSignature = self.seatSignature or setmetatable({}, { __mode = "k" })
    local signature = string.format("%.4f|%s|%.2f|%.2f|%s", px, tostring(relative), x, y, self:Scheme().id)
    for _, t in ipairs({ seat, well, crest }) do
        if not t:IsShown() then t:Show() end
    end
    self:SyncPainted(seat)
    if self.seatSignature[seat] == signature then return size end
    self.seatSignature[seat] = signature
    crest:SetTexture(self.artPath .. self:CrestFile(detail) .. ".tga", "CLAMP", "CLAMP")
    seat:ClearAllPoints()
    seat:SetPoint("TOPLEFT", relative, "TOPLEFT", x, y)
    seat:SetSize(size, size)
    local off = (size - inner) / 2
    for _, t in ipairs({ well, crest }) do
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", relative, "TOPLEFT", x + off, y - off)
        t:SetSize(inner, inner)
    end
    self:Tint(well, "ink", "color", 1)
    self:Tint(crest, "accent", "vertex", 1)
    return size
end

function A:HideCrestSeat(store, key)
    for _, suffix in ipairs({ "Seat", "SeatAcc", "Well", "Crest" }) do
        local t = store and store[key .. suffix]
        if t and t:IsShown() then t:Hide() end
    end
end































A.painted = setmetatable({}, { __mode = "k" })



function A:PaintedTexture(host, layer, sublevel, name)
    layer, sublevel = layer or "ARTWORK", sublevel or 0
    local region = self:Own(host:CreateTexture(nil, layer, nil, sublevel))
    local entry = { name = name, alpha = 1 }
    self.painted[region] = entry
    local layers = self.artLayers and self.artLayers[name]
    if layers and layers.acc then
        local twin = self:Own(host:CreateTexture(nil, layer, nil, math.min(7, sublevel + 1)))
        twin:SetAllPoints(region)
        twin:Hide()
        entry.twin = twin
    end
    self:SetPainted(region, name)
    return region
end









function A:DressPaintedRegion(region, name, alpha)
    if not region or type(region.SetTexture) ~= "function" then return end
    local file, on, layers = self:PaintedPath(name)
    if region:GetTexture() ~= file then region:SetTexture(file, "CLAMP", "CLAMP") end




    if type(region.SetVertexColor) == "function" then
        local _, _, _, ca = region:GetVertexColor()
        ca = ca or 1
        if on and self:ArtFollowsScheme() then
            local r, g, b = self:PaintedMaterial(name)
            local cr, cg, cb = region:GetVertexColor()
            if math.abs((cr or 1) - r) > 1e-4 or math.abs((cg or 1) - g) > 1e-4 or math.abs((cb or 1) - b) > 1e-4 then
                region:SetVertexColor(r, g, b, ca)
            end
            region.auiBodyTint = name
            self.themed[region] = { role = "material", piece = name, kind = "vertex", alpha = ca }
        elseif region.auiBodyTint then
            region.auiBodyTint = nil
            self.themed[region] = nil
            region:SetVertexColor(1, 1, 1, ca)
        end
        self:SyncGlaze(region, name, ca, on)
    end
    local twin = region.auiTwin
    local want = on and layers and layers.acc and region:IsShown() and true or false
    if not twin and want then
        local parent = type(region.GetParent) == "function" and region:GetParent() or nil
        if not parent or type(parent.CreateTexture) ~= "function" then return end
        local layer, sub = "ARTWORK", 0
        if type(region.GetDrawLayer) == "function" then
            local l, s = region:GetDrawLayer()
            if type(l) == "string" then layer = l end
            if type(s) == "number" then sub = s end
        end
        twin = self:Own(parent:CreateTexture(nil, layer, nil, math.min(7, sub + 1)))
        twin:SetAllPoints(region)
        region.auiTwin = twin
    end
    if not twin then return end
    if not want then
        if twin:IsShown() then twin:Hide() end
        self.themed[twin] = nil
        return
    end
    local accFile = self.artPath .. layers.acc .. ".tga"
    if twin:GetTexture() ~= accFile then twin:SetTexture(accFile, "CLAMP", "CLAMP") end
    local c = { region:GetTexCoord() }
    local sig = table.concat(c, ",")
    if twin.auiCoord ~= sig then twin.auiCoord = sig; twin:SetTexCoord(unpack(c)) end
    local role = self:MarkRole()
    local r, g, b = self:Color(role)
    local a = alpha or 1
    local cr, cg, cb, ca = twin:GetVertexColor()
    if math.abs((cr or 1) - r) > 1e-4 or math.abs((cg or 1) - g) > 1e-4 or math.abs((cb or 1) - b) > 1e-4
        or math.abs((ca or 1) - a) > 1e-4 then
        twin:SetVertexColor(r, g, b, a)
    end
    self.themed[twin] = { role = role, kind = "vertex", alpha = a }
    if not twin:IsShown() then twin:Show() end
end

function A:PaintedTwin(region)
    local entry = self.painted[region]
    return entry and entry.twin or nil
end







function A:PaintedPath(name)
    local layers = self.artLayers and self.artLayers[name]
    local on = self:ArtRecolourOn() and (layers ~= nil or self:ArtFollowsScheme())


    return self.artPath .. (on and layers and (layers.body or layers.mat) or name) .. ".tga", on, layers
end








function A:ArtFollowsScheme()
    if not (self.db and self.optionIndex and self.optionIndex.artMaterial) then return false end
    return self:GetOption("artMaterial") == "scheme"
end











A.paintedMinLight = { bar04 = 0.92, slab02 = 0.95, ["tile-notch-cap"] = 0.95, ["tile-pipnotchr-cap"] = 0.94 }

local function luma(r, g, b) return 0.2126 * r + 0.7152 * g + 0.0722 * b end



function A:PaintedMaterial(name)
    local r, g, b = self:Color("material")
    local floor = name and self.paintedMinLight[name]
    if floor then
        local l = luma(r, g, b)
        if l < floor and l < 1 then
            local t = (floor - l) / (1 - l)
            r, g, b = r + (1 - r) * t, g + (1 - g) * t, b + (1 - b) * t
        end
    end
    return r, g, b, 1
end



function A:MarkRole()
    if self.db and self.optionIndex and self.optionIndex.recolourMarks and self:GetOption("recolourMarks") == "accent" then
        return "accent"
    end
    return "mark"
end



function A:SetPainted(region, name)
    local entry = self.painted[region]
    if not entry then return end
    entry.name = name
    local file, on, layers = self:PaintedPath(name)
    entry.on = on
    if region:GetTexture() ~= file then region:SetTexture(file, "CLAMP", "CLAMP") end
    local twin = entry.twin
    if twin and on and layers.acc then
        local accFile = self.artPath .. layers.acc .. ".tga"
        if twin:GetTexture() ~= accFile then twin:SetTexture(accFile, "CLAMP", "CLAMP") end
    end
    self:PaintedAlpha(region, entry.alpha)
    self:SyncPainted(region)
end

local function vertexDiffers(region, r, g, b, a)
    local cr, cg, cb, ca = region:GetVertexColor()
    return math.abs((cr or 1) - r) > 1e-4 or math.abs((cg or 1) - g) > 1e-4
        or math.abs((cb or 1) - b) > 1e-4 or math.abs((ca or 1) - a) > 1e-4
end





















A.paintedMarkOnly = { plate02 = true, slab02 = true, ["plate02-plain"] = true }















A.glazeNeutral = 0.7


A.paintedGlazeMax = {}
A.glazes = setmetatable({}, { __mode = "k" })

function A:GlazeStrength()
    if not (self.db and self.optionIndex and self.optionIndex.artGlaze) then return 0 end
    local v = tonumber(self:GetOption("artGlaze")) or 0
    return math.max(0, math.min(1, v))
end

function A:GlazeOn()
    return self:ArtRecolourOn() and self:ArtFollowsScheme() and self:GlazeStrength() > 0
end

function A:GlazeColour(name)
    local r, g, b = self:Color("accent")
    local top = math.max(r, g, b, 1e-6)
    r, g, b = r / top, g / top, b / top
    local low = math.min(r, g, b) * A.glazeNeutral
    local k = self:GlazeStrength() * (name and self.paintedGlazeMax[name] or 1)
    return (r - low) * k, (g - low) * k, (b - low) * k, 1
end




function A:SyncGlaze(region, name, alpha, on)
    if not region then return end
    local glaze = region.auiGlaze


    local want = on and self:GlazeOn() and true or false
    if not glaze then
        if not (want and region:IsShown()) then return end
        local parent = type(region.GetParent) == "function" and region:GetParent() or nil
        if not parent or type(parent.CreateTexture) ~= "function" then return end
        local layer, sub = "ARTWORK", 0
        if type(region.GetDrawLayer) == "function" then
            local l, s2 = region:GetDrawLayer()
            if type(l) == "string" then layer = l end
            if type(s2) == "number" then sub = s2 end
        end
        glaze = self:Own(parent:CreateTexture(nil, layer, nil, math.min(7, sub + 1)))
        glaze:SetAllPoints(region)
        glaze:SetBlendMode("ADD")
        region.auiGlaze = glaze
        self.glazes[glaze] = region
    end
    glaze.auiWant = want
    if not want then
        if glaze:IsShown() then glaze:Hide() end
        self.themed[glaze] = nil
        return
    end
    local file = region:GetTexture()
    if glaze:GetTexture() ~= file then glaze:SetTexture(file, "CLAMP", "CLAMP") end
    local c = { region:GetTexCoord() }
    local sig = table.concat(c, ",")
    if glaze.auiCoord ~= sig then glaze.auiCoord = sig; glaze:SetTexCoord(unpack(c)) end
    local r, g, b = self:GlazeColour(name)
    local a = alpha or 1
    local cr, cg, cb, ca = glaze:GetVertexColor()
    if math.abs((cr or 1) - r) > 1e-4 or math.abs((cg or 1) - g) > 1e-4 or math.abs((cb or 1) - b) > 1e-4
        or math.abs((ca or 1) - a) > 1e-4 then
        glaze:SetVertexColor(r, g, b, a)
    end
    self.themed[glaze] = { role = "glaze", piece = name, glaze = true, kind = "vertex", alpha = a }
    local shown = region:IsShown() and true or false
    if glaze:IsShown() ~= shown then glaze:SetShown(shown) end
end



function A:DropGlaze(region)
    local glaze = region and region.auiGlaze
    if not glaze then return end
    glaze.auiWant = false
    if glaze:IsShown() then glaze:Hide() end
    self.themed[glaze] = nil
end



function A:SweepGlazes()


    local on = self:GlazeOn()
    for glaze, region in pairs(self.glazes) do
        local want = on and glaze.auiWant and region:IsShown() and true or false
        if glaze:IsShown() ~= want then glaze:SetShown(want) end
    end
end



function A:PaintedBodyTint(name)

    if self:ArtFollowsScheme() then
        local r, g, b = self:PaintedMaterial(name)
        return r, g, b
    end


    if self.paintedMarkOnly[name] then return 1, 1, 1 end
    local layers = self.artLayers and self.artLayers[name]
    if not layers or layers.body then return 1, 1, 1 end
    return self:Color("material")
end


function A:PaintedBodyThemed(name)
    if self:ArtFollowsScheme() then return true end
    if self.paintedMarkOnly[name] then return false end
    local layers = self.artLayers and self.artLayers[name]
    return layers ~= nil and not layers.body
end



function A:PaintedAlpha(region, alpha)
    local entry = self.painted[region]
    if not entry then return end
    alpha = math.max(0, math.min(1, tonumber(alpha) or 1))
    entry.alpha = alpha
    local twin = entry.twin
    if entry.on then
        local r, g, b = self:PaintedBodyTint(entry.name)
        if vertexDiffers(region, r, g, b, alpha) then region:SetVertexColor(r, g, b, alpha) end



        if not self:PaintedBodyThemed(entry.name) then
            self.themed[region] = nil
        else
            self.themed[region] = { role = "material", piece = self:ArtFollowsScheme() and entry.name or nil,
                                    kind = "vertex", alpha = alpha }
        end
        if twin then
            local role = self:MarkRole()
            local ar, ag, ab = self:Color(role)
            if vertexDiffers(twin, ar, ag, ab, alpha) then twin:SetVertexColor(ar, ag, ab, alpha) end
            self.themed[twin] = { role = role, kind = "vertex", alpha = alpha }
        end
    else
        self.themed[region] = nil
        if vertexDiffers(region, 1, 1, 1, alpha) then region:SetVertexColor(1, 1, 1, alpha) end
        if twin then self.themed[twin] = nil end
    end
    if region.auiGlaze then self:SyncGlaze(region, entry.name, alpha, entry.on) end
end



function A:SyncPainted(region)
    local entry = self.painted[region]
    if entry then self:SyncGlaze(region, entry.name, entry.alpha, entry.on) end
    local twin = entry and entry.twin
    if not twin then return end


    local layers = self.artLayers and self.artLayers[entry.name]
    local want = entry.on and layers ~= nil and layers.acc ~= nil and region:IsShown() and true or false
    if twin:IsShown() ~= want then twin:SetShown(want) end
    if not want then return end
    local c = { region:GetTexCoord() }
    local signature = table.concat(c, ",")
    if twin.auiCoord ~= signature then
        twin.auiCoord = signature
        twin:SetTexCoord(unpack(c))
    end
end



function A:HidePainted(region)
    if region:IsShown() then region:Hide() end
    local entry = self.painted[region]
    if entry and entry.twin and entry.twin:IsShown() then entry.twin:Hide() end
    if region.auiGlaze and region.auiGlaze:IsShown() then region.auiGlaze:Hide() end
end



function A:RefreshPaintedArt()
    for region, entry in pairs(self.painted) do
        pcall(self.SetPainted, self, region, entry.name)
    end
    self:SweepGlazes()
end

function A:ArtTexture(parent, file, x, y, width, height, layer, sublevel)
    local texture = parent:CreateTexture(nil, layer or "ARTWORK", nil, sublevel)
    texture:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    texture:SetSize(width, height)

    texture:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")
    return texture
end

function A:Label(parent, size, x, y, width, justify)
    local text = parent:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(text, size, size >= 16)
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    text:SetWidth(width)
    text:SetWordWrap(false)
    text:SetJustifyH(justify or "LEFT")
    self:Tint(text, "text", "text")
    return text
end



















































































































































































































































A.tokens = {
    margin = 16,
    space = { xs = 4, sm = 8, md = 12, lg = 16, xl = 24 },




    surface = { ink = { 0.063, 0.059, 0.075 } },
    elevation = { wash = 0.35, base = 0.7, panel = 0.94, raised = 0.9 },
    edge = { 0.482, 0.388, 0.220, 0.85 },
    accent = { 0.851, 0.694, 0.388, 0.85 },













    type = { caption = 12, body = 14, value = 16, title = 16, hero = 20 },







    safe = 0.05,











    motion = {
        quick = 0.16,
        beat = 0.28,
        sweep = 0.42,
        breath = 1.60,
        flare = 0.8,
        band = 0.55,
        pulseLow = 0.30, pulseHigh = 0.75,
        emberLow = 0.45, emberHigh = 0.85,










        trailDelay = 0.40, trailHold = 1.10, trailDrain = 0.55,



        ghostFade = 0.30,
    },
}
























A.schemes = {




























    { id = "dusk", name = "Dusk over Elwynn", light = false,
      ink = { 0.063, 0.059, 0.075 }, nativeInk = { 0.063, 0.059, 0.075 }, well = { 0.028, 0.026, 0.034 },
      edge = { 0.482, 0.388, 0.220, 0.85 }, accent = { 0.851, 0.694, 0.388, 0.85 },
      text = { 0.957, 0.922, 0.843 }, muted = { 0.706, 0.678, 0.612 },
      good = { 0.42, 0.80, 0.49 }, warn = { 0.94, 0.77, 0.26 }, bad = { 0.93, 0.42, 0.32 }, info = { 0.44, 0.70, 0.96 },
      tint = { 0.74, 0.62, 0.42 },
      shadow = { 0.02, 0.015, 0.010 }, hi = { 1.0, 0.90, 0.70, 0.14 }, lo = { 0.02, 0.01, 0.0, 0.58 },
      textShadow = { 0.02, 0.01, 0.0, 0.80 } },
    { id = "indigo", name = "Deep indigo", light = false,
      ink = { 0.055, 0.055, 0.105 }, nativeInk = { 0.055, 0.055, 0.105 }, well = { 0.03, 0.03, 0.06 },
      edge = { 0.16, 0.15, 0.26, 0.7 }, accent = { 0.56, 0.60, 0.98, 0.7 },
      text = { 0.89, 0.95, 0.93 }, muted = { 0.59, 0.70, 0.71 },
      good = { 0.42, 0.78, 0.52 }, warn = { 0.90, 0.78, 0.42 }, bad = { 0.91, 0.48, 0.40 }, info = { 0.35, 0.70, 1.00 },
      tint = { 0.55, 0.58, 0.85 },
      shadow = { 0.0, 0.0, 0.03 }, hi = { 0.80, 0.82, 1.0, 0.16 }, lo = { 0.0, 0.0, 0.02, 0.55 }, textShadow = { 0, 0, 0.02, 0.75 } },
    { id = "graphite", name = "Graphite", light = false,
      ink = { 0.070, 0.075, 0.085 }, nativeInk = { 0.070, 0.075, 0.085 }, well = { 0.035, 0.038, 0.045 },
      edge = { 0.20, 0.21, 0.24, 0.75 }, accent = { 0.62, 0.70, 0.78, 0.75 },
      text = { 0.92, 0.93, 0.94 }, muted = { 0.66, 0.69, 0.73 },
      good = { 0.45, 0.78, 0.55 }, warn = { 0.90, 0.78, 0.45 }, bad = { 0.94, 0.50, 0.45 }, info = { 0.45, 0.72, 0.98 },
      tint = { 0.60, 0.64, 0.70 },
      shadow = { 0.0, 0.0, 0.0 }, hi = { 0.90, 0.92, 0.96, 0.15 }, lo = { 0.0, 0.0, 0.0, 0.55 }, textShadow = { 0, 0, 0, 0.75 } },
    { id = "ember", name = "Ember", light = false,
      ink = { 0.105, 0.065, 0.055 }, nativeInk = { 0.105, 0.065, 0.055 }, well = { 0.055, 0.032, 0.026 },
      edge = { 0.30, 0.18, 0.13, 0.75 }, accent = { 1.00, 0.62, 0.30, 0.8 },
      text = { 0.96, 0.92, 0.88 }, muted = { 0.76, 0.67, 0.60 },
      good = { 0.62, 0.80, 0.45 }, warn = { 0.98, 0.80, 0.40 }, bad = { 0.96, 0.50, 0.42 }, info = { 0.55, 0.75, 0.95 },
      tint = { 0.82, 0.56, 0.40 },
      shadow = { 0.03, 0.0, 0.0 }, hi = { 1.0, 0.86, 0.72, 0.15 }, lo = { 0.03, 0.0, 0.0, 0.55 }, textShadow = { 0.03, 0, 0, 0.75 } },
    { id = "verdant", name = "Verdant", light = false,
      ink = { 0.045, 0.085, 0.065 }, nativeInk = { 0.045, 0.085, 0.065 }, well = { 0.022, 0.045, 0.034 },
      edge = { 0.13, 0.26, 0.19, 0.75 }, accent = { 0.45, 0.85, 0.55, 0.8 },
      text = { 0.90, 0.96, 0.92 }, muted = { 0.64, 0.76, 0.68 },
      good = { 0.50, 0.86, 0.58 }, warn = { 0.92, 0.80, 0.42 }, bad = { 0.95, 0.52, 0.45 }, info = { 0.45, 0.75, 0.95 },
      tint = { 0.48, 0.72, 0.56 },
      shadow = { 0.0, 0.03, 0.0 }, hi = { 0.80, 1.0, 0.86, 0.15 }, lo = { 0.0, 0.03, 0.0, 0.55 }, textShadow = { 0, 0.03, 0, 0.75 } },
    { id = "arctic", name = "Arctic", light = false,
      ink = { 0.045, 0.085, 0.100 }, nativeInk = { 0.045, 0.085, 0.100 }, well = { 0.022, 0.045, 0.055 },
      edge = { 0.13, 0.26, 0.30, 0.75 }, accent = { 0.35, 0.85, 0.90, 0.8 },
      text = { 0.90, 0.97, 0.98 }, muted = { 0.62, 0.77, 0.82 },
      good = { 0.48, 0.84, 0.62 }, warn = { 0.92, 0.80, 0.45 }, bad = { 0.95, 0.52, 0.48 }, info = { 0.50, 0.78, 1.00 },
      tint = { 0.48, 0.74, 0.82 },
      shadow = { 0.0, 0.02, 0.04 }, hi = { 0.80, 0.97, 1.0, 0.16 }, lo = { 0.0, 0.02, 0.04, 0.55 }, textShadow = { 0, 0.02, 0.04, 0.75 } },
    { id = "porcelain", name = "Porcelain (light)", light = true,
      ink = { 0.94, 0.95, 0.97 }, nativeInk = { 0.090, 0.100, 0.150 }, well = { 0.30, 0.33, 0.42 },
      edge = { 0.60, 0.63, 0.74, 0.9 }, accent = { 0.28, 0.32, 0.82, 0.85 },
      text = { 0.10, 0.11, 0.16 }, muted = { 0.31, 0.34, 0.43 },
      good = { 0.04, 0.40, 0.20 }, warn = { 0.52, 0.33, 0.00 }, bad = { 0.66, 0.10, 0.10 }, info = { 0.08, 0.36, 0.72 },
      tint = { 0.36, 0.40, 0.62 },
      shadow = { 0.16, 0.18, 0.30 }, hi = { 1.0, 1.0, 1.0, 0.85 }, lo = { 0.20, 0.22, 0.34, 0.22 }, textShadow = { 1, 1, 1, 0.55 } },
















    { id = "obsidian", name = "Obsidian and steel", light = false,
      ink = { 0.052, 0.054, 0.060 }, nativeInk = { 0.052, 0.054, 0.060 }, well = { 0.024, 0.025, 0.029 },
      edge = { 0.34, 0.37, 0.42, 0.75 }, accent = { 0.78, 0.83, 0.88, 0.8 },
      text = { 0.94, 0.95, 0.97 }, muted = { 0.68, 0.71, 0.75 },
      good = { 0.44, 0.82, 0.54 }, warn = { 0.93, 0.79, 0.36 }, bad = { 0.94, 0.45, 0.38 }, info = { 0.46, 0.73, 0.98 },
      tint = { 0.62, 0.66, 0.72 },
      shadow = { 0.0, 0.0, 0.01 }, hi = { 0.90, 0.94, 1.0, 0.15 }, lo = { 0.0, 0.0, 0.01, 0.55 }, textShadow = { 0, 0, 0.01, 0.75 } },



    { id = "bloodmoon", name = "Bloodmoon", light = false,
      ink = { 0.085, 0.048, 0.055 }, nativeInk = { 0.085, 0.048, 0.055 }, well = { 0.042, 0.024, 0.028 },
      edge = { 0.38, 0.17, 0.20, 0.75 }, accent = { 0.93, 0.44, 0.44, 0.8 },
      text = { 0.97, 0.91, 0.90 }, muted = { 0.78, 0.66, 0.66 },
      good = { 0.52, 0.84, 0.58 }, warn = { 0.97, 0.81, 0.40 }, bad = { 0.99, 0.55, 0.48 }, info = { 0.55, 0.76, 0.98 },
      tint = { 0.80, 0.48, 0.48 },
      shadow = { 0.03, 0.0, 0.0 }, hi = { 1.0, 0.80, 0.80, 0.15 }, lo = { 0.03, 0.0, 0.0, 0.55 }, textShadow = { 0.03, 0, 0, 0.75 } },
    { id = "void", name = "Void violet", light = false,
      ink = { 0.068, 0.048, 0.098 }, nativeInk = { 0.068, 0.048, 0.098 }, well = { 0.034, 0.024, 0.050 },
      edge = { 0.30, 0.20, 0.44, 0.75 }, accent = { 0.72, 0.52, 0.98, 0.8 },
      text = { 0.94, 0.91, 0.98 }, muted = { 0.72, 0.68, 0.80 },
      good = { 0.46, 0.84, 0.56 }, warn = { 0.95, 0.80, 0.42 }, bad = { 0.96, 0.48, 0.44 }, info = { 0.48, 0.74, 1.00 },
      tint = { 0.64, 0.52, 0.88 },
      shadow = { 0.02, 0.0, 0.04 }, hi = { 0.90, 0.82, 1.0, 0.15 }, lo = { 0.02, 0.0, 0.04, 0.55 }, textShadow = { 0.02, 0, 0.04, 0.75 } },


    { id = "frost", name = "Frost", light = false,
      ink = { 0.048, 0.070, 0.092 }, nativeInk = { 0.048, 0.070, 0.092 }, well = { 0.024, 0.036, 0.048 },
      edge = { 0.20, 0.32, 0.42, 0.75 }, accent = { 0.62, 0.84, 1.00, 0.8 },
      text = { 0.92, 0.96, 0.99 }, muted = { 0.68, 0.78, 0.86 },
      good = { 0.46, 0.84, 0.60 }, warn = { 0.94, 0.82, 0.46 }, bad = { 0.96, 0.53, 0.48 }, info = { 0.52, 0.80, 1.00 },
      tint = { 0.56, 0.74, 0.90 },
      shadow = { 0.0, 0.02, 0.04 }, hi = { 0.84, 0.94, 1.0, 0.16 }, lo = { 0.0, 0.02, 0.04, 0.55 }, textShadow = { 0, 0.02, 0.04, 0.75 } },



    { id = "sandstone", name = "Sandstone", light = false,
      ink = { 0.098, 0.086, 0.068 }, nativeInk = { 0.098, 0.086, 0.068 }, well = { 0.050, 0.044, 0.034 },
      edge = { 0.40, 0.34, 0.22, 0.75 }, accent = { 0.92, 0.80, 0.52, 0.8 },
      text = { 0.97, 0.94, 0.88 }, muted = { 0.79, 0.74, 0.65 },
      good = { 0.50, 0.82, 0.52 }, warn = { 0.96, 0.80, 0.38 }, bad = { 0.95, 0.47, 0.38 }, info = { 0.50, 0.74, 0.97 },
      tint = { 0.78, 0.68, 0.48 },
      shadow = { 0.03, 0.02, 0.01 }, hi = { 1.0, 0.94, 0.80, 0.15 }, lo = { 0.03, 0.02, 0.0, 0.55 }, textShadow = { 0.03, 0.02, 0, 0.75 } },


    { id = "mossveil", name = "Mossveil", light = false,
      ink = { 0.052, 0.072, 0.052 }, nativeInk = { 0.052, 0.072, 0.052 }, well = { 0.026, 0.038, 0.026 },
      edge = { 0.20, 0.32, 0.20, 0.75 }, accent = { 0.86, 0.76, 0.40, 0.8 },
      text = { 0.94, 0.96, 0.92 }, muted = { 0.70, 0.76, 0.69 },
      good = { 0.52, 0.86, 0.58 }, warn = { 0.95, 0.82, 0.42 }, bad = { 0.96, 0.52, 0.44 }, info = { 0.48, 0.76, 0.97 },
      tint = { 0.56, 0.72, 0.54 },
      shadow = { 0.0, 0.03, 0.0 }, hi = { 0.92, 0.96, 0.80, 0.15 }, lo = { 0.0, 0.03, 0.0, 0.55 }, textShadow = { 0, 0.03, 0, 0.75 } },



    { id = "mono", name = "Mono (high contrast)", light = false,
      ink = { 0.035, 0.035, 0.038 }, nativeInk = { 0.035, 0.035, 0.038 }, well = { 0.012, 0.012, 0.014 },
      edge = { 0.52, 0.52, 0.55, 0.85 }, accent = { 1.00, 1.00, 1.00, 0.85 },
      text = { 1.00, 1.00, 1.00 }, muted = { 0.78, 0.78, 0.80 },
      good = { 0.62, 0.92, 0.70 }, warn = { 1.00, 0.88, 0.50 }, bad = { 1.00, 0.58, 0.52 }, info = { 0.62, 0.84, 1.00 },
      tint = { 0.80, 0.80, 0.82 },
      shadow = { 0.0, 0.0, 0.0 }, hi = { 1.0, 1.0, 1.0, 0.18 }, lo = { 0.0, 0.0, 0.0, 0.60 }, textShadow = { 0, 0, 0, 0.85 } },




    { id = "beacon", name = "Beacon (colour-vision safe)", light = false, cvdSafe = true,
      ink = { 0.055, 0.058, 0.068 }, nativeInk = { 0.055, 0.058, 0.068 }, well = { 0.026, 0.028, 0.034 },
      edge = { 0.30, 0.34, 0.40, 0.75 }, accent = { 0.95, 0.76, 0.20, 0.8 },
      text = { 0.95, 0.95, 0.96 }, muted = { 0.72, 0.74, 0.78 },
      good = { 0.00, 0.62, 0.45 }, warn = { 0.90, 0.62, 0.00 }, bad = { 0.80, 0.37, 0.00 }, info = { 0.34, 0.71, 0.91 },
      tint = { 0.62, 0.68, 0.76 },
      shadow = { 0.0, 0.0, 0.01 }, hi = { 1.0, 0.92, 0.70, 0.15 }, lo = { 0.0, 0.0, 0.01, 0.55 }, textShadow = { 0, 0, 0.01, 0.75 } },



    { id = "parchment", name = "Parchment (light)", light = true,
      ink = { 0.96, 0.95, 0.91 }, nativeInk = { 0.110, 0.100, 0.085 }, well = { 0.34, 0.32, 0.27 },
      edge = { 0.62, 0.58, 0.48, 0.9 }, accent = { 0.46, 0.30, 0.06, 0.85 },
      text = { 0.14, 0.12, 0.09 }, muted = { 0.36, 0.33, 0.28 },
      good = { 0.05, 0.38, 0.20 }, warn = { 0.50, 0.32, 0.00 }, bad = { 0.62, 0.11, 0.08 }, info = { 0.08, 0.34, 0.68 },
      tint = { 0.46, 0.40, 0.30 },
      shadow = { 0.20, 0.17, 0.12 }, hi = { 1.0, 1.0, 1.0, 0.85 }, lo = { 0.24, 0.21, 0.16, 0.22 }, textShadow = { 1, 1, 1, 0.55 } },
}




A.schemeShort = {
    dusk = "Dusk", indigo = "Indigo", graphite = "Graphite", ember = "Ember", verdant = "Verdant",
    arctic = "Arctic", porcelain = "Porcelain", obsidian = "Obsidian", bloodmoon = "Bloodmoon",
    void = "Void", frost = "Frost", sandstone = "Sandstone", mossveil = "Mossveil", mono = "Mono",
    beacon = "Beacon", parchment = "Parchment", custom = "Custom",
}
A.schemeIndex = {}



local function scaled(c, k) return { c[1] * k, c[2] * k, c[3] * k } end
local function clamp1(v) return v < 0 and 0 or (v > 1 and 1 or v) end


local function lift(c, k, a)
    return { clamp1(c[1] + (1 - c[1]) * k), clamp1(c[2] + (1 - c[2]) * k), clamp1(c[3] + (1 - c[3]) * k), a }
end



local function saturate(c, k)
    local mean = (c[1] + c[2] + c[3]) / 3
    return { clamp1(mean + (c[1] - mean) * (1 + k)), clamp1(mean + (c[2] - mean) * (1 + k)), clamp1(mean + (c[3] - mean) * (1 + k)) }
end
















local function srgbToLinear(c)
    if c <= 0.04045 then return c / 12.92 end
    return ((c + 0.055) / 1.055) ^ 2.4
end
local function linearToSrgb(c)
    if c <= 0 then return 0 end
    if c <= 0.0031308 then return c * 12.92 end
    return 1.055 * c ^ (1 / 2.4) - 0.055
end
local function toOklab(c)
    local r, g, b = srgbToLinear(clamp1(c[1])), srgbToLinear(clamp1(c[2])), srgbToLinear(clamp1(c[3]))
    local l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)
    local m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)
    local s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ^ (1 / 3)
    return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
        1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
        0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
end




local function linearFromOklab(L, a, b)
    local l = (L + 0.3963377774 * a + 0.2158037573 * b) ^ 3
    local m = (L - 0.1055613458 * a - 0.0638541728 * b) ^ 3
    local s = (L - 0.0894841775 * a - 1.2914855480 * b) ^ 3
    return 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end
local function fromOklab(L, a, b)
    local r, g, bl = linearFromOklab(L, a, b)
    return { clamp1(linearToSrgb(r)), clamp1(linearToSrgb(g)), clamp1(linearToSrgb(bl)) }
end
local function inGamut(L, a, b)
    local r, g, bl = linearFromOklab(L, a, b)
    return r > -5e-4 and r < 1.0005 and g > -5e-4 and g < 1.0005 and bl > -5e-4 and bl < 1.0005
end





local function toneAt(base, L)
    local _, a, b = toOklab(base)
    if inGamut(L, a, b) then return fromOklab(L, a, b) end
    local lo, hi = 0, 1
    for _ = 1, 32 do
        local mid = (lo + hi) / 2
        if inGamut(L, a * mid, b * mid) then lo = mid else hi = mid end
    end
    return fromOklab(L, a * lo, b * lo)
end
local function relLum(c)
    return 0.2126 * srgbToLinear(clamp1(c[1])) + 0.7152 * srgbToLinear(clamp1(c[2]))
        + 0.0722 * srgbToLinear(clamp1(c[3]))
end
local function contrast(a, b)
    local ya, yb = relLum(a), relLum(b)
    if ya < yb then ya, yb = yb, ya end
    return (ya + 0.05) / (yb + 0.05)
end



A.toneFloor = 1.28









A.castTone = { 0.93, 0.83, 0.73 }




local function stepFor(L, a, b, previous, down)
    local lo, hi = 0, down and L or (1 - L)
    if contrast(fromOklab(down and (L - hi) or (L + hi), a, b), previous) < A.toneFloor then
        return hi
    end
    for _ = 1, 48 do
        local mid = (lo + hi) / 2
        if contrast(fromOklab(down and (L - mid) or (L + mid), a, b), previous) >= A.toneFloor then
            hi = mid
        else
            lo = mid
        end
    end
    return hi
end



local function drain(c, k)
    local mean = (c[1] + c[2] + c[3]) / 3
    return { clamp1(c[1] + (mean - c[1]) * k), clamp1(c[2] + (mean - c[2]) * k), clamp1(c[3] + (mean - c[3]) * k) }
end















A.materialKDefault = 0.70








A.materialK = {
    indigo = 0.83, graphite = 0.84, ember = 0.84, verdant = 0.78, arctic = 0.80, porcelain = 0.92,



    bloodmoon = 0.99, void = 0.86, sandstone = 0.73, parchment = 0.93,
}













A.markRef = 0.2126 * 0.851 + 0.7152 * 0.694 + 0.0722 * 0.388
function A.MarkColour(accent)
    local r, g, b = accent[1], accent[2], accent[3]
    local L = 0.2126 * r + 0.7152 * g + 0.0722 * b
    local ref = A.markRef
    if L <= 1e-6 then return { ref, ref, ref, 1 } end
    if L >= ref then
        local k = ref / L
        return { r * k, g * k, b * k, 1 }
    end
    local t = (ref - L) / math.max(1e-6, 1 - L)
    return { r + t * (1 - r), g + t * (1 - g), b + t * (1 - b), 1 }
end






function A.XpColours(mark)
    local rested = {}
    for i = 1, 3 do rested[i] = mark[i] + 0.5 * (1 - mark[i]) end
    rested[4] = 1
    return { mark[1], mark[2], mark[3], 1 }, rested
end




local function deriveScheme(scheme)
    scheme.barText = { 0.96, 0.97, 0.99 }
















    scheme.loss = saturate(lift(scheme.bad, 0.05), 0.40)
    scheme.gain = saturate(lift(scheme.good, 0.12), 0.30)


    scheme.heal = saturate(lift(scheme.good, 0.24), 0.30)
    scheme.heal[4] = 0.55



    scheme.absorb = lift(scheme.info, 0.62, 0.60)



    scheme.danger = saturate(lift(scheme.bad, scheme.light and -0.05 or 0.08), 0.45)







    scheme.hostile, scheme.neutral, scheme.friendly = scheme.bad, scheme.warn, scheme.good


    scheme.tapped = drain(scheme.bad, 0.88)

    scheme.offline = scaled(drain(scheme.muted, 0.9), scheme.light and 1.15 or 0.78)



























    scheme.castNormal = toneAt(scheme.info, A.castTone[1])
    scheme.castChannel = toneAt(scheme.good, A.castTone[2])
    scheme.castShield = toneAt(scheme.warn, A.castTone[3])

















    scheme.inkDeep = scaled(scheme.ink, scheme.light and 0.90 or 0.42)





























    local L, ca, cb = toOklab(scheme.ink)
    local down = scheme.light and true or false
    local d1 = stepFor(L, ca, cb, scheme.ink, down)
    local mid = down and (L - d1) or (L + d1)
    local d = math.max(d1, stepFor(mid, ca, cb, fromOklab(mid, ca, cb), down))
    local sign = down and -1 or 1
    scheme.inkStep = fromOklab(L + sign * d, ca, cb)
    scheme.inkStud = fromOklab(L + sign * 2 * d, ca, cb)
    scheme.inkStepL = d


    scheme.materialK = A.materialK[scheme.id] or A.materialKDefault
    scheme.material = lift(scheme.accent, scheme.materialK, 1)

    scheme.mark = A.MarkColour(scheme.accent)
    scheme.xp, scheme.xpRested = A.XpColours(scheme.mark)
    return scheme
end
for _, scheme in ipairs(A.schemes) do
    deriveScheme(scheme)
    A.schemeIndex[scheme.id] = scheme
end








function A:SchemeFailures(sc)
    local out = {}
    local function need(name, ratio, minimum)
        if ratio < minimum then out[#out + 1] = string.format("%s %.2f<%.2f", name, ratio, minimum) end
    end
    need("text/ink", contrast(sc.text, sc.ink), 7)
    need("text/inkDeep", contrast(sc.text, sc.inkDeep), 7)
    need("text/inkStep", contrast(sc.text, sc.inkStep), 4.5)
    need("muted/ink", contrast(sc.muted, sc.ink), 4.5)
    need("muted/inkDeep", contrast(sc.muted, sc.inkDeep), 4.5)
    for _, role in ipairs({ "good", "warn", "bad", "info" }) do
        need(role .. "/ink", contrast(sc[role], sc.ink), 4.5)
        need(role .. "/inkDeep", contrast(sc[role], sc.inkDeep), 4.5)
    end
    need("accent/ink", contrast(sc.accent, sc.ink), 3)
    need("accent/inkDeep", contrast(sc.accent, sc.inkDeep), 3)
    need("accent/inkStep", contrast(sc.accent, sc.inkStep), 3)
    need("edge/ink", contrast(sc.edge, sc.ink), 1.2)
    need("ladder ink/inkStep", contrast(sc.ink, sc.inkStep), A.toneFloor)
    need("ladder inkStep/inkStud", contrast(sc.inkStep, sc.inkStud), A.toneFloor)
    need("cast normal/channel", contrast(sc.castNormal, sc.castChannel), A.toneFloor)
    need("cast channel/shield", contrast(sc.castChannel, sc.castShield), A.toneFloor)
    need("cast normal/well", contrast(sc.castNormal, sc.well), 3)
    need("danger/ink", contrast(sc.danger, sc.ink), 3)
    need("barText/well", contrast(sc.barText, sc.well), 4.5)
    need("native text/nativeInk", contrast({ 0.92, 0.92, 0.92 }, sc.nativeInk), 7)
    need("native title/nativeInk", contrast({ 1, 0.82, 0 }, sc.nativeInk), 7)
    return out
end










local function mix(a, b, t, alpha)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t, alpha }
end
function A:DeriveScheme(id, name, accent, ink)
    local L = toOklab(ink)
    local light = L > 0.6
    local base = light and self.schemeIndex.porcelain or self.schemeIndex.dusk
    local sc = { id = id, name = name, light = light,
        ink = { clamp1(ink[1]), clamp1(ink[2]), clamp1(ink[3]) },
        accent = { clamp1(accent[1]), clamp1(accent[2]), clamp1(accent[3]), light and 0.85 or 0.8 } }


    sc.nativeInk = light and toneAt(sc.ink, 0.28) or sc.ink


    sc.well = light and toneAt(sc.ink, 0.42) or scaled(sc.ink, 0.45)

    sc.edge = mix(sc.accent, sc.ink, 0.5, light and 0.9 or 0.75)


    local hue = drain(sc.accent, 0.75)
    if light then
        sc.text = toneAt(sc.ink, 0.22)
        sc.muted = toneAt(sc.ink, 0.42)
    else
        sc.text = lift(hue, 0.88)
        sc.text[4] = nil
        sc.muted = lift(hue, 0.62)
        sc.muted[4] = nil
    end
    sc.good, sc.warn, sc.bad, sc.info = base.good, base.warn, base.bad, base.info
    sc.tint = drain(sc.accent, 0.4)
    sc.shadow = scaled(sc.ink, light and 0.2 or 0.3)
    sc.hi = light and { 1, 1, 1, 0.85 } or lift(sc.accent, 0.5, 0.15)
    sc.lo = light and { 0.20, 0.22, 0.34, 0.22 } or { sc.shadow[1], sc.shadow[2], sc.shadow[3], 0.55 }
    sc.textShadow = light and { 1, 1, 1, 0.55 } or { sc.shadow[1], sc.shadow[2], sc.shadow[3], 0.75 }
    return deriveScheme(sc)
end





function A:CustomScheme()
    if not (self.db and self.optionIndex) then return nil end
    local accent, ink = self:GetOption("themeCustomAccent"), self:GetOption("themeCustomInk")
    local signature = string.format("%.3f,%.3f,%.3f|%.3f,%.3f,%.3f", accent[1], accent[2], accent[3], ink[1], ink[2], ink[3])
    if self.customSchemeSignature ~= signature then
        self.customSchemeSignature = signature
        self.customScheme = self:DeriveScheme("custom", "Custom", accent, ink)
        self.customSchemeFailures = self:SchemeFailures(self.customScheme)
    end
    if #self.customSchemeFailures == 0 then return self.customScheme end
    return nil
end

function A:Scheme()
    local id = self.db and self.optionIndex and self:GetOption("themeScheme") or nil
    if id == "custom" then
        return self:CustomScheme() or self.schemes[1]
    end
    return self.schemeIndex[id] or self.schemes[1]
end




function A:PickerSchemes()
    local out = {}
    for i, scheme in ipairs(self.schemes) do out[i] = scheme end
    local custom = self:CustomScheme()
    if not custom and self.db and self.optionIndex then
        custom = self.customScheme
    end
    out[#out + 1] = custom or self:DeriveScheme("custom", "Custom", self.schemes[1].accent, self.schemes[1].ink)
    return out
end













local function flatSample(t, c, alpha)
    t:SetColorTexture(c[1], c[2], c[3], alpha or 1)
    A.themed[t] = nil
end
function A:SchemeThumb(host, store, key, scheme, x, y, w, h, compact, layer, sublevel)
    store, key = store or host, key or "thumb"
    layer, sublevel = layer or "ARTWORK", sublevel or 0
    if not store[key .. "Body"] then
        for i, part in ipairs({ "Body", "Band", "Rule", "Well", "Fill", "Type", "Good", "Warn", "Bad", "Info" }) do
            store[key .. part] = self:Own(host:CreateTexture(nil, layer, nil, math.min(7, sublevel + (i > 1 and 1 or 0))))
        end
    end
    local body, band, rule = store[key .. "Body"], store[key .. "Band"], store[key .. "Rule"]
    local px = math.max(1, math.floor(self:PhysicalPixel(host) + 0.5))
    local bandH = math.max(3, math.floor(h * 0.30 + 0.5))
    local function place(t, tx, ty, tw, th)
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", host, "TOPLEFT", x + tx, y - ty)
        t:SetSize(math.max(1, tw), math.max(1, th))
    end
    place(body, 0, 0, w, h); flatSample(body, scheme.ink)
    place(band, 0, 0, w, bandH); flatSample(band, scheme.inkStep)
    place(rule, 0, bandH, w, px); flatSample(rule, scheme.accent)
    local detail = { "Well", "Fill", "Type", "Good", "Warn", "Bad", "Info" }
    for _, part in ipairs(detail) do store[key .. part]:SetShown(not compact) end
    if not compact then


        local pad = math.max(3, math.floor(w * 0.08 + 0.5))
        local gaugeY = bandH + px + math.max(3, math.floor((h - bandH) * 0.22))
        local gaugeH = math.max(3, math.floor((h - bandH) * 0.26 + 0.5))
        local gaugeW = w - 2 * pad
        place(store[key .. "Well"], pad, gaugeY, gaugeW, gaugeH); flatSample(store[key .. "Well"], scheme.well)
        place(store[key .. "Fill"], pad + px, gaugeY + px, math.floor((gaugeW - 2 * px) * 0.66), gaugeH - 2 * px)
        flatSample(store[key .. "Fill"], scheme.tint)

        local typeY = gaugeY + gaugeH + math.max(2, math.floor((h - bandH) * 0.12))
        place(store[key .. "Type"], pad, typeY, math.floor(gaugeW * 0.45), px * 2); flatSample(store[key .. "Type"], scheme.text)

        local mark = math.max(3, px * 3)
        for i, role in ipairs({ "good", "warn", "bad", "info" }) do
            local t = store[key .. ({ "Good", "Warn", "Bad", "Info" })[i]]
            place(t, pad + gaugeW - (5 - i) * (mark + px), typeY - (mark - 2 * px) / 2, mark, mark)
            flatSample(t, scheme[role])
        end
    end
    for _, part in ipairs({ "Body", "Band", "Rule" }) do
        if not store[key .. part]:IsShown() then store[key .. part]:Show() end
    end
    return store
end



function A:Color(role)
    local scheme = self:Scheme()
    if role == "accent" then
        if self.db and self.optionIndex and self:GetOption("accentCustom") then
            local c = self:GetOption("accent")
            return c[1], c[2], c[3], c[4]
        end
        local c = scheme.accent
        return c[1], c[2], c[3], c[4] or 1
    end

    if (role == "mark" or role == "xp" or role == "xpRested")
        and self.db and self.optionIndex and self:GetOption("accentCustom") then
        local mark = A.MarkColour(self:GetOption("accent"))
        local xp, rested = A.XpColours(mark)
        local c = (role == "mark" and mark) or (role == "xp" and xp) or rested
        return c[1], c[2], c[3], 1
    end










    if role == "material" and self.db and self.optionIndex and self:GetOption("accentCustom") then
        local c, k = self:GetOption("accent"), scheme.materialK or A.materialKDefault
        return c[1] + (1 - c[1]) * k, c[2] + (1 - c[2]) * k, c[3] + (1 - c[3]) * k, 1
    end
    if role == "control" then
        local c = scheme.inkStep
        return c[1], c[2], c[3], 1
    end
    local c = scheme[role]
    if not c then c = scheme.text end
    return c[1], c[2], c[3], c[4] or 1
end




A.styleCache = {}
function A:Style(styleName)
    styleName = styleName or (self.db and self.db.style)
    local base = self.themes[styleName] or self.themes.rpg
    local scheme = self:Scheme()
    if scheme.id == "indigo" then return base end
    local key = scheme.id .. ":" .. tostring(styleName)
    local cached = self.styleCache[key]
    if cached then return cached end
    local merged = {}
    for k, v in pairs(base) do merged[k] = v end
    merged.text, merged.muted = scheme.text, scheme.muted
    merged.player, merged.target, merged.combo, merged.mana = scheme.good, scheme.bad, scheme.warn, scheme.info
    self.styleCache[key] = merged
    return merged
end





A.themed = setmetatable({}, { __mode = "k" })
A.themedShadow = setmetatable({}, { __mode = "k" })



















A.ownArt = setmetatable({}, { __mode = "k" })
function A:Own(object)
    if object ~= nil then self.ownArt[object] = true end
    return object
end
function A:IsOwn(object)
    return object ~= nil and self.ownArt[object] == true
end

local function paint(region, kind, r, g, b, a)
    if kind == "color" then region:SetColorTexture(r, g, b, a or 1)
    elseif kind == "vertex" then region:SetVertexColor(r, g, b, a or 1)
    elseif kind == "text" then region:SetTextColor(r, g, b, 1)
    elseif kind == "bar" then region:SetStatusBarColor(r, g, b) end
end



function A:Tint(region, role, kind, alpha)
    local r, g, b, a = self:Color(role)
    paint(region, kind, r, g, b, alpha or a)
    self.themed[region] = { role = role, kind = kind, alpha = alpha }
    return region
end

function A:ThemeSignature()
    local scheme = self:Scheme()
    local accent = { self:Color("accent") }














    local id = scheme.id == "custom" and ("custom:" .. tostring(self.customSchemeSignature)) or scheme.id


    return string.format("%s|%.3f%.3f%.3f%.3f|%.2f|%s|%s|%s|%s|%s|%.4f|%s", id, accent[1], accent[2], accent[3], accent[4],
        self.db and self.optionIndex and self:GetOption("themeShadow") or 0.6,
        tostring(self.db and self.optionIndex and self:GetOption("themeBezel")),
        tostring(self.db and self.optionIndex and self:GetOption("themeTextShadow")),
        tostring(self.db and self.optionIndex and self:GetOption("themeHeadingFont")),
        tostring(self:FlatBars()),
        tostring(self:BarTextureOn()),
        self:PhysicalPixel(UIParent),
        tostring(self:ArtRecolourOn()) .. "|" .. self:MarkRole() .. "|"
            .. tostring(self.db and self.optionIndex and self.optionIndex.artMaterial and self:GetOption("artMaterial"))
            .. "|" .. string.format("%.3f", self:GlazeStrength()))
end



function A:RefreshTheme(force)
    local signature = self:ThemeSignature()
    if not force and signature == self.themeSignature then return false end
    self.themeSignature = signature
    for region, entry in pairs(self.themed) do

        local r, g, b, a
        if entry.glaze then r, g, b, a = self:GlazeColour(entry.piece)
        elseif entry.piece then r, g, b, a = self:PaintedMaterial(entry.piece)
        else r, g, b, a = self:Color(entry.role) end
        pcall(paint, region, entry.kind, r, g, b, entry.alpha or a)
    end
    for region in pairs(self.themedShadow) do self:StyleShadow(region) end
    self:RefreshPaintedArt()
    self:RefreshHeadingFont()
    self:RefreshDepth()
    return true
end


function A:StyleShadow(region)
    if type(region.SetShadowColor) ~= "function" then return end
    self.themedShadow[region] = true
    local on = not (self.db and self.optionIndex) or self:GetOption("themeTextShadow")
    if on then
        local c = self:Scheme().textShadow
        region:SetShadowColor(c[1], c[2], c[3], c[4])
        region:SetShadowOffset(1, -1)
    else
        region:SetShadowColor(0, 0, 0, 0)
        region:SetShadowOffset(0, 0)
    end
end


local LEVEL = {
    base = { spread = 6, shadow = 0.55, hi = 0.65, gloss = 0.55, lo = 0.6 },
    panel = { spread = 10, shadow = 0.85, hi = 0.9, gloss = 0.85, lo = 0.85 },
    raised = { spread = 12, shadow = 1.0, hi = 1.0, gloss = 1.0, lo = 1.0 },
}
A.depthLevels = LEVEL
local SHADOW_PARTS = { "TL", "T", "TR", "L", "R", "BL", "B", "BR" }
A.depth = setmetatable({}, { __mode = "k" })

local function art(host, file, layer, sub)
    local t = host:CreateTexture(nil, layer, nil, sub)
    t:SetTexture(A.artPath .. file .. ".tga", "CLAMP", "CLAMP")
    return A:Own(t)
end







function A:Elevate(store, host, key, tl, tlx, tly, br, brx, bry, level)
    if not host or not tl or not br or type(host.CreateTexture) ~= "function" then return end
    local info = self.depth[store]
    if not info then info = {}; self.depth[store] = info end
    local entry = info[key]
    if not entry then
        entry = { level = level }
        info[key] = entry
        local cfg = LEVEL[level] or LEVEL.base


        local ref = self:Own(CreateFrame("Frame", nil, host))
        ref:EnableMouse(false)
        ref:SetPoint("TOPLEFT", tl, "TOPLEFT", tlx, tly)
        ref:SetPoint("BOTTOMRIGHT", br, "BOTTOMRIGHT", brx, bry)
        entry.ref = ref
        local s, drop = cfg.spread, 2
        local function shadowPiece(name, file, w, h, p1, r1, p2, r2, coords)
            local t = art(host, file, "BACKGROUND", -8)
            if w then t:SetWidth(w) end
            if h then t:SetHeight(h) end
            t:SetPoint(p1, ref, r1, 0, -drop)
            if p2 then t:SetPoint(p2, ref, r2, 0, -drop) end
            if coords then t:SetTexCoord(unpack(coords)) end
            store[key .. "S" .. name] = t
            return t
        end
        shadowPiece("TL", "shadow-corner", s, s, "BOTTOMRIGHT", "TOPLEFT", nil, nil, { 0, 1, 0, 1 })
        shadowPiece("TR", "shadow-corner", s, s, "BOTTOMLEFT", "TOPRIGHT", nil, nil, { 1, 0, 0, 1 })
        shadowPiece("BL", "shadow-corner", s, s, "TOPRIGHT", "BOTTOMLEFT", nil, nil, { 0, 1, 1, 0 })
        shadowPiece("BR", "shadow-corner", s, s, "TOPLEFT", "BOTTOMRIGHT", nil, nil, { 1, 0, 1, 0 })
        shadowPiece("T", "shadow-h", nil, s, "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "TOPRIGHT", { 0, 1, 0, 1 })
        shadowPiece("B", "shadow-h", nil, s, "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "BOTTOMRIGHT", { 0, 1, 1, 0 })
        shadowPiece("L", "shadow-v", s, nil, "TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT", { 0, 1, 0, 1 })
        shadowPiece("R", "shadow-v", s, nil, "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", { 1, 0, 0, 1 })


        local hiTop = art(host, "bezel-h", "BACKGROUND", -6)
        hiTop:SetHeight(1); hiTop:SetPoint("TOPLEFT", ref, "TOPLEFT", 0, 0); hiTop:SetPoint("TOPRIGHT", ref, "TOPRIGHT", 0, 0)
        local hiLeft = art(host, "bezel-v", "BACKGROUND", -6)
        hiLeft:SetWidth(1); hiLeft:SetPoint("TOPLEFT", ref, "TOPLEFT", 0, 0); hiLeft:SetPoint("BOTTOMLEFT", ref, "BOTTOMLEFT", 0, 0)
        local inner = art(host, "inner-shadow", "BACKGROUND", -6)
        inner:SetHeight(6); inner:SetPoint("BOTTOMLEFT", ref, "BOTTOMLEFT", 0, 0); inner:SetPoint("BOTTOMRIGHT", ref, "BOTTOMRIGHT", 0, 0)
        local gloss = art(host, "gloss", "BACKGROUND", -6)
        gloss:SetHeight(22); gloss:SetPoint("TOPLEFT", ref, "TOPLEFT", 0, 0); gloss:SetPoint("TOPRIGHT", ref, "TOPRIGHT", 0, 0)
        store[key .. "B1"], store[key .. "B2"], store[key .. "B3"], store[key .. "B4"] = hiTop, hiLeft, inner, gloss
    end
    entry.level = level
    self:ApplyDepth(store, key)
    return entry
end






function A:SuppressDepth(store, key, suppressed)
    local info = self.depth[store]
    local entry = info and info[key]
    if not entry then return end
    suppressed = suppressed and true or false
    if entry.suppressed == suppressed then return end
    entry.suppressed, entry.signature = suppressed, nil
    self:ApplyDepth(store, key)
end



function A:ApplyDepth(store, key)
    local info = self.depth[store]
    local entry = info and info[key]
    if not entry then return end
    local cfg = LEVEL[entry.level] or LEVEL.base
    local strength = (self.db and self.optionIndex) and self:GetOption("themeShadow") or 0.6
    local bezel = (not (self.db and self.optionIndex)) or self:GetOption("themeBezel")
    if entry.suppressed then strength, bezel = 0, false end
    local scheme = self:Scheme()
    local signature = scheme.id .. string.format("|%.2f|%s|%s|%s", strength, tostring(bezel), entry.level,
        tostring(entry.suppressed))
    local first = store[key .. "STL"]
    local wantShown = strength > 0.01
    if entry.signature == signature and first and (first:IsShown() == wantShown) then return end
    entry.signature = signature
    local sr, sg, sb = scheme.shadow[1], scheme.shadow[2], scheme.shadow[3]
    local shadowAlpha = math.min(1, strength * cfg.shadow * 0.7)
    for _, name in ipairs(SHADOW_PARTS) do
        local t = store[key .. "S" .. name]
        if t then
            t:SetVertexColor(sr, sg, sb, shadowAlpha)
            if wantShown then t:Show() else t:Hide() end
        end
    end
    local hi, lo = scheme.hi, scheme.lo
    local parts = { store[key .. "B1"], store[key .. "B2"], store[key .. "B3"], store[key .. "B4"] }
    if parts[1] then
        parts[1]:SetVertexColor(hi[1], hi[2], hi[3], hi[4] * cfg.hi)
        parts[2]:SetVertexColor(hi[1], hi[2], hi[3], hi[4] * cfg.hi * 0.7)
        parts[3]:SetVertexColor(lo[1], lo[2], lo[3], lo[4] * cfg.lo)
        parts[4]:SetVertexColor(hi[1], hi[2], hi[3], math.min(1, hi[4] * 0.45 * cfg.gloss))
        for _, t in ipairs(parts) do if bezel then t:Show() else t:Hide() end end
    end
end

function A:RefreshDepth()
    for store, info in pairs(self.depth) do
        for key in pairs(info) do self:ApplyDepth(store, key) end
    end
    for store, key in pairs(self.barStores or {}) do self:ApplyBarFinish(store, key) end
    if self.hairlines then self:RefreshHairlines() end
end



















































local VEIL_BLEED = 6
local VEIL_CAP = 48
A.veilBleed, A.veilCap = VEIL_BLEED, VEIL_CAP










function A:Veil(parent, store, key, role, alpha, bottom, bottomDy, bottomPoint, lean, leanSize)
    store, key = store or parent, key or "veil"
    local B = VEIL_BLEED
    if not store[key .. "M"] then
        local function piece(file)
            local t = self:Own(parent:CreateTexture(nil, "BACKGROUND", nil, -7))
            t:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")
            return t
        end
        local left, right, mid = piece("veil-cap"), piece("veil-cap"), piece("veil-mid")
        left:SetWidth(VEIL_CAP)
        right:SetWidth(VEIL_CAP)
        right:SetTexCoord(1, 0, 0, 1)
        store[key .. "L"], store[key .. "R"], store[key .. "M"] = left, right, mid
    end


    do
        local width = math.max(VEIL_CAP, math.floor((leanSize or 0) + 0.5))
        for _, side in ipairs({ "L", "R" }) do
            local t = store[key .. side]
            local leaning = lean == (side == "L" and "LEFT" or "RIGHT")
            local file = leaning and "veil-wedge" or "veil-cap"
            if t.auiVeilArt ~= file then
                t.auiVeilArt = file
                t:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")
            end






            local mirror = leaning and (side == "L") or (not leaning and side == "R")
            if mirror then t:SetTexCoord(1, 0, 0, 1) else t:SetTexCoord(0, 1, 0, 1) end
            t:SetWidth(leaning and width or VEIL_CAP)
        end
    end



    local left, right, mid = store[key .. "L"], store[key .. "R"], store[key .. "M"]
    local point = bottom and (bottomPoint or "TOP") or "BOTTOM"
    local host = bottom or parent
    local dy = bottomDy or (bottom and 2 or -B)
    left:ClearAllPoints()
    left:SetPoint("TOPRIGHT", parent, "TOPLEFT", -B, B)
    left:SetPoint("BOTTOMRIGHT", host, point .. "LEFT", -B, dy)
    right:ClearAllPoints()
    right:SetPoint("TOPLEFT", parent, "TOPRIGHT", B, B)
    right:SetPoint("BOTTOMLEFT", host, point .. "RIGHT", B, dy)
    mid:ClearAllPoints()
    mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
    mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
    for _, suffix in ipairs({ "L", "R", "M" }) do
        self:Tint(store[key .. suffix], role or "inkDeep", "vertex", alpha)
    end
    return mid
end



















function A:BlockSurface(host, store, key, strength)
    store, key = store or host, key or "surface"
    if not store[key .. "Sheen"] then
        local sheen = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -6))
        sheen:SetTexture(self.artPath .. "gloss.tga", "CLAMP", "CLAMP")
        store[key .. "Sheen"] = sheen
        local lip = self:Own(host:CreateTexture(nil, "BORDER", nil, 1))
        store[key .. "Lip"] = lip
    end
    self:Tint(store[key .. "Sheen"], "hi", "vertex", strength or 0.17)
    self:Tint(store[key .. "Lip"], "accent", "color", (strength or 0.17) * 2.6)
    return store[key .. "Sheen"], store[key .. "Lip"]
end











function A:LayoutBlockSurface(host, store, key, top, inset, px, shown, sheenTo, lipTo)
    store, key = store or host, key or "surface"
    local sheen, lip = store[key .. "Sheen"], store[key .. "Lip"]
    if not sheen then return end




    shown = shown and true or false
    sheenTo, lipTo = sheenTo or host, lipTo or host
    sheen:ClearAllPoints()
    sheen:SetPoint("TOPLEFT", sheenTo, "TOPLEFT", 0, 0)
    sheen:SetPoint("TOPRIGHT", sheenTo, "TOPRIGHT", 0, 0)
    sheen:SetHeight(math.max(4, top or 12))
    sheen:SetShown(shown and true or false)
    lip:ClearAllPoints()
    lip:SetPoint("BOTTOMLEFT", lipTo, "BOTTOMLEFT", inset or 0, 0)
    lip:SetPoint("BOTTOMRIGHT", lipTo, "BOTTOMRIGHT", -(inset or 0), 0)
    lip:SetHeight(px or 1)
    lip:SetShown(shown and true or false)
end




















A.grainAlpha = 0.32
function A:Grain(host, store, key, width, height, alpha)
    store, key = store or host, key or "grain"
    if not host or type(host.CreateTexture) ~= "function" then return end
    local grain = store[key]
    if not grain then
        grain = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -6))
        grain:SetAllPoints()
        if type(grain.SetBlendMode) == "function" then grain:SetBlendMode("ADD") end
        store[key] = grain
    end
    local file = self:SlotFile("obsidian")
    if grain.auiGrainFile ~= file then
        grain.auiGrainFile = file
        grain:SetTexture(self.artPath .. file .. ".tga", "REPEAT", "REPEAT")
    end


    local tile = 512
    if self:HasArt("obsidian") and type(grain.SetTexCoord) == "function" then
        pcall(grain.SetTexCoord, grain, 0, (width or 256) / tile, 0, (height or 256) / tile)
    end
    self:Tint(grain, "hi", "vertex", (alpha or self.grainAlpha))



    grain:SetShown(true)
    return grain
end





















function A:Masthead(frame, width, height, store, key, margin)
    store, key = store or frame, key or "mast"
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local full = self:Number(frame.GetHeight, 1, frame) or height * 6
    self:Grain(frame, store, key .. "Grain", width, full)
    if not store[key .. "Banner"] then
        store[key .. "Banner"] = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -5))
        store[key .. "Scrim"] = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -4))
        store[key .. "Foot"] = self:Own(frame:CreateTexture(nil, "BORDER", nil, 1))






        store[key .. "Wedge"] = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -5))
        store[key .. "Wedge"]:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
        store[key .. "Wedge"]:SetTexCoord(1, 0, 0, 1)
        store[key .. "Tail"] = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -5))
    end
    local banner, scrim, foot = store[key .. "Banner"], store[key .. "Scrim"], store[key .. "Foot"]
    local wedge, tail = store[key .. "Wedge"], store[key .. "Tail"]



    local cut = 0
    if (not (self.db and self.optionIndex)) or self:GetOption("plusCorner") then
        cut = math.max(0, math.min(16, math.floor(height * 0.35)))
    end
    banner:ClearAllPoints()
    banner:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    banner:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -cut, 0)
    banner:SetHeight(height)

















    local painted = self:HasArt("banner") and not self:Scheme().light
        and (not (self.db and self.optionIndex) or self:GetOption("windowBanner"))
    banner:SetTexture(self.artPath .. (painted and self:SlotFile("banner") or "plate") .. ".tga", "CLAMP", "CLAMP")
    if painted then



        banner:SetTexCoord(0.02, 0.98, 0.18, 0.86)
        banner:SetVertexColor(1, 1, 1, 0.92)
        self.themed[banner] = nil
    else



        banner:SetTexCoord(0, 1, 0, 1)
        self:Tint(banner, "inkStep", "vertex", 1)
    end


    local cutting = cut > 0 and not painted
    wedge:ClearAllPoints()
    wedge:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -height)
    wedge:SetSize(math.max(1, cut), math.max(1, cut))
    wedge:SetShown(cutting)
    self:Tint(wedge, "inkStep", "vertex", 1)
    tail:ClearAllPoints()
    tail:SetPoint("TOPLEFT", frame, "TOPRIGHT", -cut, 0)
    tail:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -(height - cut))
    tail:SetShown(cutting and height > cut)
    self:Tint(tail, "inkStep", "color", 1)
    if painted then
        banner:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    end


    scrim:SetTexture(self.artPath .. "fade.tga", "CLAMP", "CLAMP")
    scrim:SetAllPoints(banner)
    self:Tint(scrim, "ink", "vertex", 0.97)
    scrim:SetShown(painted)
    foot:ClearAllPoints()
    foot:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -height)




    foot:SetPoint("TOPRIGHT", frame, "TOPRIGHT", cutting and -cut or 0, -height)
    foot:SetHeight(self:PhysicalPixel(frame))
    self:Tint(foot, "accent", "color", 0.45)
    if not store[key .. "Crest"] then
        store[key .. "Crest"] = self:ArtTexture(frame, self:CrestFile(48),
            width - self.tokens.margin - 48 - 8, -(height - 48) / 2, 48, 48)
    end
    self:Tint(store[key .. "Crest"], "accent", "vertex", 1)





    local classic = self.db and self.optionIndex and self:GetOption("chromeSkin") ~= "authored"
    store[key .. "Crest"]:SetShown(classic and true or false)
    if self:ChromeCrest("windows") then
        margin = margin or self.tokens.margin
        local size = self:CrestSeatSize(frame)
        self:CrestSeat(frame, store, key .. "Medal", frame, margin, -(height - size) / 2, "ARTWORK", 1)
        store[key .. "Lead"] = size + self.tokens.space.md
    else
        self:HideCrestSeat(store, key .. "Medal")
        store[key .. "Lead"] = 0
    end
    return banner
end

function A:ShowVeil(store, key, shown)
    for _, suffix in ipairs({ "L", "R", "M" }) do
        local t = store[(key or "veil") .. suffix]
        if t then t:SetShown(shown) end
    end
end









function A:BarFinish(store, bar, key, lit, glowRole)
    if not bar or type(bar.CreateTexture) ~= "function" then return end
    key = key or "barfinish"
    local existing = store[key .. "B1"]
    if not existing then
        local gloss = art(bar, "gloss", "OVERLAY", 1)
        gloss:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        gloss:SetPoint("BOTTOMRIGHT", bar, "RIGHT", 0, 0)
        local inner = art(bar, "inner-shadow", "OVERLAY", 1)
        inner:SetHeight(3)
        inner:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
        inner:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)














        local tip, spec
        if type(bar.GetStatusBarTexture) == "function" then
            local fill = bar:GetStatusBarTexture()
            if fill and type(fill.SetPoint) == "function" then
                tip = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 2))
                tip:SetTexture(self.artPath .. "bar-spark.tga", "CLAMP", "CLAMP")
                tip:SetBlendMode("ADD")
                tip:SetWidth(self.barSparkWidth)
                tip:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
                tip:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT", 0, 0)



                spec = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 1))
                spec:SetPoint("TOPLEFT", fill, "TOPLEFT", 0, 0)
                spec:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
                spec:SetHeight(1)
            end
        end








































        local sheen = art(bar, "gloss", "ARTWORK", 2)
        sheen:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        sheen:SetPoint("BOTTOMRIGHT", bar, "RIGHT", 0, 0)
        local shade = art(bar, "inner-shadow", "ARTWORK", 2)
        shade:SetPoint("TOPLEFT", bar, "LEFT", 0, 0)
        shade:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
        store[key .. "M0"] = bar
        store[key .. "M2"], store[key .. "M3"] = sheen, shade
        store[key .. "B7"] = spec
        store[key .. "B1"], store[key .. "B3"], store[key .. "B5"] = gloss, inner, tip
        self.barStores = self.barStores or setmetatable({}, { __mode = "k" })
        self.barStores[store] = key
    end
    if lit and not store[key .. "B6"] then




        local host = type(bar.GetParent) == "function" and bar:GetParent() or nil
        if host and type(host.CreateTexture) == "function" then
            local glow = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
            glow:SetTexture(self.artPath .. "bar-bloom.tga", "CLAMP", "CLAMP")


            local spread = self.tokens.space.sm
            glow:SetPoint("TOPLEFT", bar, "TOPLEFT", -spread, spread)




            local fill = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture() or nil
            glow:SetPoint("BOTTOMRIGHT", (fill and type(fill.SetPoint) == "function") and fill or bar,
                "BOTTOMRIGHT", spread, -spread)
            store[key .. "B6"] = glow
            bar.auiGlow = glow



            bar.auiSpark = store[key .. "B5"]
        end


        pcall(bar.SetStatusBarTexture, bar, self.artPath .. "bar-gradient.tga")





        local fill = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture() or nil
        if fill and type(fill.SetPoint) == "function" then
            local wedge = self:Own(bar:CreateTexture(nil, "OVERLAY", nil, 3))
            wedge:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
            wedge:SetTexCoord(1, 0, 0, 1)
            wedge:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
            wedge:SetSize(4, 4)
            self:Tint(wedge, "well", "vertex", 1)
            store[key .. "B8"] = wedge
            bar.auiWedge = wedge
        end
        store[key .. "lit"] = true
        store[key .. "bar"] = bar
        store[key .. "glowRole"] = glowRole
    end
    self:ApplyBarFinish(store, key)
end













A.barGlowAlpha, A.barGlowAlphaLight = 0.45, 0.30
A.barSparkWidth, A.barSparkAlpha = 12, 0.6







A.troughTint = 0.13
function A:PaintBarGlow(bar, r, g, b)
    if not bar or not r then return end
    local glow = bar.auiGlow
    if glow then
        local light = self:Scheme().light == true
        glow:SetBlendMode(light and "BLEND" or "ADD")
        glow:SetVertexColor(r, g, b, light and self.barGlowAlphaLight or self.barGlowAlpha)
    end

    if bar.auiSpark then
        bar.auiSpark:SetVertexColor(r + (1 - r) * 0.55, g + (1 - g) * 0.55, b + (1 - b) * 0.55, self.barSparkAlpha)
    end


    if bar.auiWedge then
        local wr, wg, wb = self:Color("well")
        local t = bar.auiGhostAlpha or 0
        bar.auiWedge:SetVertexColor(wr + (r - wr) * t, wg + (g - wg) * t, wb + (b - wb) * t, 1)
    end
end













function A:FlatBars()
    if not (self.db and self.optionIndex) then return true end
    return self:GetOption("flatBars") ~= false
end






A.barSheenAlpha, A.barShadeAlpha = 0.06, 0.10
function A:BarTextureOn()
    if not (self.db and self.optionIndex) then return true end
    return self:GetOption("plusBarTexture") ~= false
end



function A:ArtRecolourOn()
    if not (self.db and self.optionIndex) then return false end
    return self:GetOption("artRecolour") == true
end

A.depthSig = setmetatable({}, { __mode = "k" })
function A:ApplyBarFinish(store, key)
    local gloss, inner, tip = store[key .. "B1"], store[key .. "B3"], store[key .. "B5"]
    if not gloss then return end
    local scheme = self:Scheme()
    local flat = self:FlatBars()



    local material = flat and self:BarTextureOn()
    local sheen, shade = store[key .. "M2"], store[key .. "M3"]
    if sheen then




        local sig = scheme.id .. tostring(material)
        if store[key .. "Msig"] ~= sig then
            store[key .. "Msig"] = sig
            if material then
                local hi, lo = scheme.hi, scheme.lo
                sheen:SetVertexColor(hi[1], hi[2], hi[3], self.barSheenAlpha)
                shade:SetVertexColor(lo[1], lo[2], lo[3], self.barShadeAlpha)
                sheen:Show(); shade:Show()
            else
                sheen:Hide(); shade:Hide()
            end












            local host = store[key .. "M0"]
            if host and store[key .. "lit"] ~= true and self:IsOwn(host) then
                pcall(host.SetStatusBarTexture, host,
                    self.artPath .. (store[key .. "fill"] or (material and "bar-obsidian.tga" or "meter.tga")))
            end
        end
    end
    local lit = store[key .. "lit"] == true and not flat




    local bar = store[key .. "bar"]
    if store[key .. "lit"] == true and bar then
        pcall(bar.SetStatusBarTexture, bar, self.artPath
            .. (store[key .. "fill"] or (flat and (material and "bar-obsidian.tga" or "meter.tga") or "bar-gradient.tga")))
    end
    for _, suffix in ipairs({ "B5", "B6", "B7", "B8" }) do
        local region = store[key .. suffix]
        if region and store[key .. "lit"] == true then region:SetShown(not flat) end
    end



    local on = (not lit) and (not flat) and ((not (self.db and self.optionIndex)) or self:GetOption("themeBezel"))
    local glowRole = store[key .. "glowRole"]
    if glowRole and store[key .. "B6"] then
        self:PaintBarGlow(store[key .. "bar"] or { auiGlow = store[key .. "B6"], auiSpark = tip }, self:Color(glowRole))
    end

    local signature = scheme.id .. tostring(on) .. tostring(lit)
    if self.depthSig[gloss] == signature and gloss:IsShown() == on then return end
    self.depthSig[gloss] = signature
    local hi, lo = scheme.hi, scheme.lo
    gloss:SetVertexColor(hi[1], hi[2], hi[3], math.min(1, hi[4] * 0.9))
    inner:SetVertexColor(lo[1], lo[2], lo[3], lo[4] * 0.8)
    if tip then



        tip:SetVertexColor(hi[1], hi[2], hi[3], 0.9)
    end
    local spec = store[key .. "B7"]
    if spec then spec:SetColorTexture(hi[1], hi[2], hi[3], math.min(1, hi[4] * 3)) end
    if on then gloss:Show(); inner:Show() else gloss:Hide(); inner:Hide() end
end


function A:IconFrame(store, host, anchor, key)
    if not host or not anchor or type(host.CreateTexture) ~= "function" then return end
    key = key or "iconframe"
    local t = store[key]
    if not t then
        t = art(host, "icon-frame", "OVERLAY", 2)
        t:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
        t:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
        store[key] = t
        self.iconFrames = self.iconFrames or setmetatable({}, { __mode = "k" })
        self.iconFrames[t] = true
    end
    local scheme = self:Scheme()
    if self.depthSig[t] ~= scheme.id then
        self.depthSig[t] = scheme.id
        local lo = scheme.lo
        t:SetVertexColor(lo[1], lo[2], lo[3], math.min(1, lo[4] * 1.3))
    end
    if not t:IsShown() then t:Show() end
end



local SURFACE_OPTION = { base = "elevBase", panel = "elevPanel", raised = "elevRaised", wash = "actionWash" }
function A:SurfaceValue(value)
    return math.min(0.95, value * ((self.db and self.db.opacity or 0.85) / 0.85))
end
function A:Surface(level)
    local value = self.tokens.elevation[level] or self.tokens.elevation.base
    local key = SURFACE_OPTION[level]
    if key and self.db and self.optionIndex then value = self:GetOption(key) end
    return self:SurfaceValue(value)
end

function A:Accent()
    local r, g, b, a = self:Color("accent")
    return { r, g, b, a }
end
function A:BordersOn()
    if self.db and self.optionIndex then return self:GetOption("borders") end
    return true
end



A.hairlines = setmetatable({}, { __mode = "k" })
function A:Hairline(host, anchor, store, key, thickness)
    if not host or not anchor or type(host.CreateTexture) ~= "function" then return end
    store, key, thickness = store or host, key or "hairline", thickness or 1
    if not store[key .. "1"] then
        for i, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
            local edge = self:Own(host:CreateTexture(nil, "BORDER"))
            self:Tint(edge, "edge", "color")
            local vertical = not (side == "TOP" or side == "BOTTOM")
            if not vertical then
                edge:SetPoint(side .. "LEFT", anchor, side .. "LEFT")
                edge:SetPoint(side .. "RIGHT", anchor, side .. "RIGHT")
            else
                edge:SetPoint("TOP" .. side, anchor, "TOP" .. side)
                edge:SetPoint("BOTTOM" .. side, anchor, "BOTTOM" .. side)
            end
            store[key .. i] = edge



            self.hairlines[edge] = { host = host, mult = thickness, vertical = vertical }
        end
    end
    self:RefreshHairlines()
end





function A:RefreshHairlines()
    local on = self:BordersOn()
    for edge, entry in pairs(self.hairlines) do
        if type(entry) == "table" then
            local px = self:PhysicalPixel(entry.host) * (entry.mult or 1)
            if entry.vertical then
                if edge:GetWidth() ~= px then edge:SetWidth(px) end
            else
                if edge:GetHeight() ~= px then edge:SetHeight(px) end
            end
        end
        if edge:IsShown() ~= on then if on then edge:Show() else edge:Hide() end end
    end
end







function A:Panel(parent, x, y, width, height, level, role, store, key)
    store, key = store or parent, key or "panel"
    local fill = self:ArtTexture(parent, "plate", x, y, width, height, "BACKGROUND", -7)
    self:Tint(fill, role or "ink", "vertex")
    self:Elevate(store, parent, key .. "~", fill, 0, 0, fill, 0, 0, level or "panel")
    self:Hairline(parent, fill, store, key .. "E")
    return fill
end







function A:HoverTint(region, hovered)
    local entry = region and self.themed[region]
    if not entry then return end
    if not hovered then self:Tint(region, entry.role, entry.kind, entry.alpha); return end
    local r, g, b, a = self:Color(entry.role)
    a = entry.alpha or a
    local text, t = self:Scheme().text, 0.22
    r, g, b = r + (text[1] - r) * t, g + (text[2] - g) * t, b + (text[3] - b) * t
    if entry.kind == "color" then region:SetColorTexture(r, g, b, a)
    else region:SetVertexColor(r, g, b, a) end
end















function A:WindowPositionKey(id) return "pos.win" .. id end

function A:SaveWindowPosition(frame, id)
    local key = self:WindowPositionKey(id)
    if not self.optionIndex[key] then return end
    local fx = self:Number(frame.GetCenter, 1, frame)
    local fy = self:Number(frame.GetCenter, 2, frame)
    local ux = self:Number(UIParent.GetCenter, 1, UIParent)
    local uy = self:Number(UIParent.GetCenter, 2, UIParent)
    if not (fx and fy and ux and uy) then return end


    local s = self:Number(frame.GetScale, 1, frame) or 1
    local x, y = math.floor(fx * s - ux + 0.5), math.floor(fy * s - uy + 0.5)
    self:SetOption(key, { x, y }, true)
    self:PlaceWindow(frame, id)
end






A.windowStrata = "FULLSCREEN_DIALOG"
function A:TopWindow(frame)
    frame:SetFrameStrata(self.windowStrata)
    if type(frame.SetToplevel) == "function" then pcall(frame.SetToplevel, frame, true) end
    return frame
end



function A:PlaceWindow(frame, id)
    local value = self:GetOption(self:WindowPositionKey(id))
    local x, y = 0, 0
    if type(value) == "table" then x, y = value[1] or 0, value[2] or 0 end
    local s = self:Number(frame.GetScale, 1, frame) or 1
    if s <= 0 then s = 1 end
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x / s, y / s)
end

function A:MakeMovableWindow(frame, id, gripHeight)
    if frame.auiGrip then return frame.auiGrip end


    if type(frame.SetMovable) ~= "function" or type(frame.StartMoving) ~= "function" then return end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    local grip = CreateFrame("Frame", nil, frame)
    grip:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    grip:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    grip:SetHeight(gripHeight or 44)
    grip:EnableMouse(true)
    grip:RegisterForDrag("LeftButton")
    grip:SetScript("OnDragStart", function()


        if A:IsCombat() then return end
        pcall(frame.StartMoving, frame)
        frame.auiMoving = true
    end)
    local function drop()
        if not frame.auiMoving then return end
        frame.auiMoving = nil
        pcall(frame.StopMovingOrSizing, frame)
        pcall(A.SaveWindowPosition, A, frame, id)
    end
    grip:SetScript("OnDragStop", drop)
    grip:SetScript("OnHide", drop)
    frame.auiGrip = grip
    frame.auiWindowId = id
    return grip
end

function A:Rule(parent, x, y, width, height, role)
    local texture = parent:CreateTexture(nil, "ARTWORK")
    texture:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    texture:SetSize(width, height)
    self:Tint(texture, role or "accent", "color")
    return texture
end




























































A.motionLevelKeys = { full = true, subtle = true, off = true }


A.motionLoopBudget = 6
A.motionGroups = setmetatable({}, { __mode = "k" })
A.motionFx = setmetatable({}, { __mode = "k" })
A.motionLoops = setmetatable({}, { __mode = "k" })

function A:MotionLevel()
    if not (self.db and self.optionIndex) then return "full" end
    local level = self:GetOption("motionLevel")
    return self.motionLevelKeys[level] and level or "full"
end
function A:MotionOn() return self:MotionLevel() ~= "off" end




function A:MotionRepeats() return self:MotionLevel() == "full" end
function A:MotionAmount() return self:MotionLevel() == "subtle" and 0.5 or 1 end

function A:MotionLoopCount()
    local n = 0
    for group in pairs(self.motionLoops) do
        if type(group.IsPlaying) == "function" and select(2, pcall(group.IsPlaying, group)) == true then n = n + 1 end
    end
    return n
end











function A:Fx(host, key, artName, layer, sublevel)
    if not host or type(host.CreateTexture) ~= "function" then return end
    if type(CreateFrame) ~= "function" then return end
    local store = self.motionFx[host]
    if not store then store = {}; self.motionFx[host] = store end
    local fx = store[key]
    if fx then return fx end
    local own = self:IsOwn(host)
    local ok, made = pcall(CreateFrame, "Frame", nil, own and host or UIParent)
    if not ok or not made then return end
    fx = self:Own(made)
    fx.auiAnchoredHost, fx.auiOwnHost = host, own
    pcall(fx.EnableMouse, fx, false)
    if not own then


        pcall(fx.SetFrameStrata, fx, "MEDIUM")
    end
    fx.light = self:Own(fx:CreateTexture(nil, layer or "OVERLAY", nil, sublevel or 6))
    fx.light:SetTexture(self.artPath .. (artName or "sweep-band") .. ".tga", "CLAMP", "CLAMP")
    fx.light:SetAllPoints()
    fx.light:SetBlendMode("ADD")
    fx:SetAlpha(0)
    fx:Hide()
    store[key] = fx
    return fx
end



















function A:EdgeFlash(host, store, key, thickness, spread)
    store, key = store or host, key or "flash"
    if store[key .. "Fx"] then return store[key .. "Fx"] end
    if not host or type(host.CreateTexture) ~= "function" then return end
    if type(CreateFrame) ~= "function" then return end
    local own = self:IsOwn(host)
    local ok, made = pcall(CreateFrame, "Frame", nil, own and host or UIParent)
    if not ok or not made then return end
    local fx = self:Own(made)
    fx.auiAnchoredHost, fx.auiOwnHost = host, own
    pcall(fx.EnableMouse, fx, false)
    if not own then pcall(fx.SetFrameStrata, fx, "MEDIUM") end
    local out = spread or 0
    fx:ClearAllPoints()
    fx:SetPoint("TOPLEFT", host, "TOPLEFT", -out, out)
    fx:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", out, -out)
    fx.bars = {}
    for i, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local bar = self:Own(fx:CreateTexture(nil, "OVERLAY", nil, 7))
        bar:SetTexture(self.artPath .. "meter.tga", "CLAMP", "CLAMP")
        if type(bar.SetBlendMode) == "function" then bar:SetBlendMode("ADD") end
        if side == "TOP" or side == "BOTTOM" then
            bar:SetPoint(side .. "LEFT", fx, side .. "LEFT")
            bar:SetPoint(side .. "RIGHT", fx, side .. "RIGHT")
        else
            bar:SetPoint("TOP" .. side, fx, "TOP" .. side)
            bar:SetPoint("BOTTOM" .. side, fx, "BOTTOM" .. side)
        end
        fx.bars[i] = bar
    end


    fx.light = fx.bars[1]
    self:SizeEdgeFlash(fx, thickness or 2)
    self:PaintEdgeFlash(fx, self:Color("accent"))
    fx:SetAlpha(0)
    fx:Hide()
    store[key .. "Fx"] = fx
    return fx
end



function A:SizeEdgeFlash(fx, thickness)
    if not fx or not fx.bars then return end
    local t = math.max(0.34, math.min(8, thickness or 2))
    for i, bar in ipairs(fx.bars) do
        if i <= 2 then bar:SetHeight(t) else bar:SetWidth(t) end
    end
end

function A:PaintEdgeFlash(fx, r, g, b)
    if not fx or not fx.bars or type(r) ~= "number" then return end
    for _, bar in ipairs(fx.bars) do bar:SetVertexColor(r, g, b, 1) end
end






function A:SpreadEdgeFlash(fx, spread)
    local host = fx and fx.auiAnchoredHost
    if not host then return end
    local out = math.max(0, math.min(24, tonumber(spread) or 0))
    fx:ClearAllPoints()
    fx:SetPoint("TOPLEFT", host, "TOPLEFT", -out, out)
    fx:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", out, -out)
end














A.textOutline = { 0, 0, 0 }
function A:ReadableOnFill(role)
    local r, g, b = self:Color(role)
    if type(r) ~= "number" then return 21 end
    local fill = { r, g, b }
    return math.max(A.Contrast(self:Scheme().barText, fill), A.Contrast(A.textOutline, fill))
end



function A:PlayEdgeFlash(fx, r, g, b, strength)
    if not fx then return false end
    if type(r) == "number" then self:PaintEdgeFlash(fx, r, g, b) end
    return self:PlayFlare(fx, nil, nil, nil, strength or 1)
end



function A:MotionOwns()
    for host in pairs(self.motionGroups) do
        if not self:IsOwn(host) then return false, host end
    end
    return true
end

local function animate(group, kind, order, duration, delay, smoothing)
    local ok, a = pcall(group.CreateAnimation, group, kind)
    if not ok or not a then return end
    pcall(a.SetOrder, a, order or 1)
    pcall(a.SetDuration, a, duration or 0.2)
    if delay and delay > 0 then pcall(a.SetStartDelay, a, delay) end
    if smoothing then pcall(a.SetSmoothing, a, smoothing) end
    return a
end




function A:MotionGroup(fx, key, build)
    if not fx or type(fx.CreateAnimationGroup) ~= "function" then return end
    if not self:IsOwn(fx) then return end
    local store = self.motionGroups[fx]
    if not store then store = {}; self.motionGroups[fx] = store end
    local group = store[key]
    if group then return group end
    local ok, made = pcall(fx.CreateAnimationGroup, fx)
    if not ok or not made then return end
    store[key] = made
    if build then pcall(build, made, animate) end
    return made
end

local function play(group)
    if not group then return false end
    if type(group.IsPlaying) == "function" then
        local fine, playing = pcall(group.IsPlaying, group)
        if fine and playing == true then return true end
    end
    return pcall(group.Play, group) == true
end

local function stop(group)
    if group and type(group.Stop) == "function" then pcall(group.Stop, group) end
end







function A:PlaySweep(fx, dx, r, g, b)
    if not fx or not self:MotionOn() then return false end
    local m = self.tokens.motion
    local peak = m.band * self:MotionAmount()
    if r then fx.light:SetVertexColor(r, g, b, 1) end
    local group = self:MotionGroup(fx, "sweep", function(gr, anim)
        local slide = anim(gr, "Translation", 1, m.sweep, 0, "NONE")
        if slide then pcall(slide.SetOffset, slide, 0, 0) end
        gr.auiSlide = slide
        local rise = anim(gr, "Alpha", 1, m.sweep * 0.30, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(peak) end
        gr.auiRise = rise
        local fall = anim(gr, "Alpha", 1, m.sweep * 0.55, m.sweep * 0.45, "IN")
        if fall then fall:SetFromAlpha(peak); fall:SetToAlpha(0) end
        gr.auiFall = fall
    end)
    if not group then return false end


    if group.auiRise then group.auiRise:SetToAlpha(peak) end
    if group.auiFall then group.auiFall:SetFromAlpha(peak) end
    if group.auiSlide then pcall(group.auiSlide.SetOffset, group.auiSlide, dx or 0, 0) end
    fx:SetAlpha(0)
    fx:Show()
    return play(group)
end






function A:PlayFlare(fx, r, g, b, strength)
    if not fx or not self:MotionOn() then return false end
    local m = self.tokens.motion
    local peak = math.min(1, m.flare * (strength or 1) * self:MotionAmount())
    if r then fx.light:SetVertexColor(r, g, b, 1) end
    local group = self:MotionGroup(fx, "flare", function(gr, anim)
        local rise = anim(gr, "Alpha", 1, m.quick, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(peak) end
        gr.auiRise = rise
        local fall = anim(gr, "Alpha", 2, m.beat, 0, "IN")
        if fall then fall:SetFromAlpha(peak); fall:SetToAlpha(0) end
        gr.auiFall = fall
    end)
    if not group then return false end
    if group.auiRise then group.auiRise:SetToAlpha(peak) end
    if group.auiFall then group.auiFall:SetFromAlpha(peak) end
    fx:SetAlpha(0)
    fx:Show()
    return play(group)
end









function A:PlayIgnite(fx, r, g, b, strength, opts)
    if not fx then return false end
    local m = self.tokens.motion
    local hold = (opts and opts.peak) or (m.flare * (strength or 1))
    local seconds = (opts and opts.rise) or m.quick
    local peak = math.min(1, hold * self:MotionAmount())
    if r then fx.light:SetVertexColor(r, g, b, 1) end
    if not self:MotionOn() then


        fx:SetAlpha(math.min(1, hold))
        fx:Show()
        return false
    end
    local group = self:MotionGroup(fx, "ignite", function(gr, anim)
        if type(gr.SetToFinalAlpha) == "function" then pcall(gr.SetToFinalAlpha, gr, true) end
        local rise = anim(gr, "Alpha", 1, seconds, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(peak) end
        gr.auiRise = rise
    end)
    if not group then fx:SetAlpha(peak); fx:Show(); return false end
    if group.auiRise then
        group.auiRise:SetToAlpha(peak)
        pcall(group.auiRise.SetDuration, group.auiRise, seconds)
    end
    if fx:IsShown() and (self:Number(fx.GetAlpha, 1, fx) or 0) > 0.01 then return true end
    fx:SetAlpha(0)
    fx:Show()
    return play(group)
end



function A:Quench(fx, seconds)
    if not fx then return end
    stop(self.motionGroups[fx] and self.motionGroups[fx].ignite)
    stop(self.motionGroups[fx] and self.motionGroups[fx].pulse)
    if self.motionGroups[fx] then self.motionLoops[self.motionGroups[fx].pulse or fx] = nil end
    if not self:MotionOn() then fx:SetAlpha(0); fx:Hide(); return end
    local m = self.tokens.motion
    seconds = tonumber(seconds) or m.beat
    local group = self:MotionGroup(fx, "quench", function(gr, anim)
        if type(gr.SetToFinalAlpha) == "function" then pcall(gr.SetToFinalAlpha, gr, true) end
        local fall = anim(gr, "Alpha", 1, seconds, 0, "IN")
        if fall then fall:SetFromAlpha(1); fall:SetToAlpha(0) end
        gr.auiFall = fall
    end)
    if not group then fx:SetAlpha(0); fx:Hide(); return end
    if group.auiFall then
        group.auiFall:SetFromAlpha(self:Number(fx.GetAlpha, 1, fx) or 1)
        pcall(group.auiFall.SetDuration, group.auiFall, seconds)
    end
    play(group)
end






function A:PlayLoop(fx, key, low, high, r, g, b)
    if not fx then return false end
    local m = self.tokens.motion
    if not self:MotionRepeats() then


        local store = self.motionGroups[fx]
        local running = store and store[key]
        if running then stop(running); self.motionLoops[running] = nil end


        if r then fx.light:SetVertexColor(r, g, b, 1) end
        fx:SetAlpha(self:MotionOn() and (low + high) / 2 or 0)
        fx:SetShown(self:MotionOn())
        return false
    end
    if r then fx.light:SetVertexColor(r, g, b, 1) end
    local group = self:MotionGroup(fx, key, function(gr, anim)
        if type(gr.SetLooping) == "function" then pcall(gr.SetLooping, gr, "REPEAT") end
        local up = anim(gr, "Alpha", 1, m.breath, 0, "IN_OUT")
        if up then up:SetFromAlpha(low); up:SetToAlpha(high) end
        local down = anim(gr, "Alpha", 2, m.breath, 0, "IN_OUT")
        if down then down:SetFromAlpha(high); down:SetToAlpha(low) end
        gr.auiUp, gr.auiDown = up, down
    end)
    if not group then return false end
    if group.auiUp then group.auiUp:SetFromAlpha(low); group.auiUp:SetToAlpha(high) end
    if group.auiDown then group.auiDown:SetFromAlpha(high); group.auiDown:SetToAlpha(low) end
    local already = type(group.IsPlaying) == "function" and select(2, pcall(group.IsPlaying, group)) == true
    if not already and self:MotionLoopCount() >= self.motionLoopBudget then


        fx:SetAlpha((low + high) / 2); fx:Show()
        return false
    end
    self.motionLoops[group] = true
    fx:Show()
    return play(group)
end

function A:StopLoop(fx, key)
    local store = self.motionGroups[fx]
    local group = store and store[key]
    if group then
        stop(group)
        self.motionLoops[group] = nil
    end
    if fx then fx:SetAlpha(0); fx:Hide() end
end




















































A.barEffectsOff = false

A.barEffectOrder = { "off", "classic", "sand", "ash", "pulse", "shear" }
A.barEffectKeys = {}
for _, key in ipairs(A.barEffectOrder) do A.barEffectKeys[key] = true end




A.barEffectPool = 20
A.barEffectCells = 4




A.barEffects = {}

function A:BarEffectKey()
    if self.barEffectsOff then return "off" end





    if not self:MotionOn() then return "off" end
    if not (self.db and self.optionIndex) then return "classic" end
    local key = self:GetOption("barEffect")
    if type(key) ~= "string" or not self.barEffectKeys[key] then return "classic" end
    return key
end


function A:BarEffect()
    local key = self:BarEffectKey()
    return self.barEffects[key], key
end





function A:FxQuads(fx, n, artName, cols, rows)
    if not fx or type(fx.CreateTexture) ~= "function" then return nil end
    if fx.quads then return fx.quads end
    cols, rows = cols or 1, rows or cols or 1
    local quads = {}
    for i = 1, (n or 1) do
        local t = self:Own(fx:CreateTexture(nil, "ARTWORK", nil, 3))
        t:SetTexture(self.artPath .. (artName or "meter") .. ".tga", "CLAMP", "CLAMP")
        if type(t.SetBlendMode) == "function" then t:SetBlendMode("ADD") end
        if (cols > 1 or rows > 1) and type(t.SetTexCoord) == "function" then
            local c = (i - 1) % cols
            local r = math.floor((i - 1) / cols) % rows
            pcall(t.SetTexCoord, t, c / cols, (c + 1) / cols, r / rows, (r + 1) / rows)
        end
        t:Hide()
        quads[i] = t
    end
    fx.quads = quads
    return quads
end



















function A:BarEffectWindow(host, fromRegion, toRegion, fallbackWidth)
    if not (host and fromRegion and type(CreateFrame) == "function") then return nil end
    local ok, made = pcall(CreateFrame, "Frame", nil, host)
    if not (ok and made) then return nil end
    local window = self:Own(made)
    pcall(window.EnableMouse, window, false)
    local fine = toRegion ~= nil and pcall(function()
        window:ClearAllPoints()
        window:SetPoint("TOPLEFT", fromRegion, "TOPRIGHT", 0, 0)
        window:SetPoint("BOTTOMRIGHT", toRegion, "BOTTOMRIGHT", 0, 0)
    end) or false
    window.auiTwoPoint = fine and true or false
    if not fine then
        pcall(function()
            window:ClearAllPoints()
            window:SetPoint("TOPLEFT", fromRegion, "TOPRIGHT", 0, 0)
            window:SetPoint("BOTTOMLEFT", fromRegion, "BOTTOMRIGHT", 0, 0)
            window:SetWidth(math.max(2, fallbackWidth or 12))
        end)
    end
    window:Hide()
    return window
end




























function A:BarEffectRoom(bar)
    local value = bar and bar.value
    if not (value and type(value.GetStatusBarTexture) == "function") then return nil end
    local fill = value:GetStatusBarTexture()
    if not fill then return nil end
    local laneW = self:Number(value.GetWidth, 1, value)
    local fillW = self:Number(fill.GetWidth, 1, fill)
    if not (laneW and fillW) then return nil end
    local room = laneW - fillW
    if room ~= room then return nil end
    if room < 0 then room = 0 end
    return room, laneW, fillW
end




function A:BarEffectShift(bar, h, direction, reach)
    local span = ((direction == "up" and reach.up or reach.down) or 1) * (h or 1)
    local room = self:BarEffectRoom(bar)
    if room == nil or span <= 0 then return 0, 1, nil end
    local shift = room - span
    if shift > 0 then shift = 0 end
    local amount = (span + shift) / span
    if amount < 0.35 then amount = 0.35 end
    return shift, amount, room
end





function A:BarEffectFadeOut(fx, life)
    if not fx then return false end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then return false end
    return pcall(C_Timer.After, life or 0.5, function()
        pcall(fx.SetAlpha, fx, 0)
        pcall(fx.Hide, fx)
    end)
end




function A:BarEffectNoteBurst(effect, direction, played)
    if type(effect) ~= "table" then return played end
    effect.lastBurst = direction
    if played then
        effect.bursts = (effect.bursts or 0) + 1
        effect[direction == "up" and "gains" or "losses"] =
            (effect[direction == "up" and "gains" or "losses"] or 0) + 1
        effect.lastBurstAt = self:Number(GetTime, 1) or effect.lastBurstAt
    else
        effect.refused = (effect.refused or 0) + 1
    end
    return played
end




function A:BarEffectTint(bar, r, g, b)
    local effect = bar and bar.effect
    if not (effect and type(r) == "number") then return false end
    local style = self.barEffects[effect.key]
    if style and style.neutral then r, g, b = self:Color("muted") end
    effect.tintR, effect.tintG, effect.tintB = r, g, b
    if style and type(style.tint) == "function" then pcall(style.tint, self, bar, r, g, b) end
    return true
end




function A:BarEffectReport(bar)
    local effect = bar and bar.effect
    if not effect then return nil end
    local style = self.barEffects[effect.key]



    local groups = 0
    for _, key in ipairs({ "fx", "ring" }) do
        local store = effect[key] and self.motionGroups[effect[key]]
        if store then for _ in pairs(store) do groups = groups + 1 end end
    end
    return {
        key = effect.key, tex = effect.tex or 0, groups = groups,
        capTex = style and style.cost and style.cost.tex or 0,
        capGroups = style and style.cost and style.cost.groups or 0,
        window = effect.window, incoming = effect.inWindow,
        twoPoint = effect.window and effect.window.auiTwoPoint or false,
        small = effect.small == true,
        r = effect.tintR, g = effect.tintG, b = effect.tintB,
        bursts = effect.bursts or 0, losses = effect.losses or 0,
        gains = effect.gains or 0, refused = effect.refused or 0,
        last = effect.lastBurst, lastAt = effect.lastBurstAt,
        shift = effect.seatShift, room = effect.seatRoom,
        playing = effect.fx and self.motionGroups[effect.fx]
            and self.motionGroups[effect.fx].burst
            and select(2, pcall(self.motionGroups[effect.fx].burst.IsPlaying,
                self.motionGroups[effect.fx].burst)) == true or false,
    }
end






















































local MOTES = {

    { x =  0.05, y =  0.10, size = 0.62, cell = 1, out = 2.90, fall = 0.55, life = 0.85, delay = 0.000, alpha = 1.00, ease = "OUT" },
    { x =  0.15, y = -0.15, size = 0.55, cell = 1, out = 2.50, fall = 0.80, life = 0.80, delay = 0.010, alpha = 1.00, ease = "OUT" },
    { x = -0.05, y =  0.30, size = 0.50, cell = 4, out = 2.20, fall = 0.40, life = 0.75, delay = 0.000, alpha = 1.00, ease = "OUT" },
    { x =  0.20, y = -0.30, size = 0.58, cell = 1, out = 3.10, fall = 1.00, life = 0.90, delay = 0.020, alpha = 0.95, ease = "OUT" },
    { x = -0.15, y =  0.00, size = 0.66, cell = 4, out = 2.60, fall = 0.65, life = 0.85, delay = 0.015, alpha = 0.95, ease = "OUT" },

    { x = -0.45, y =  0.20, size = 0.80, cell = 3, out = 1.80, fall = 0.90, life = 1.05, delay = 0.030, alpha = 0.80, ease = "IN_OUT" },
    { x =  0.35, y = -0.25, size = 0.70, cell = 2, out = 2.30, fall = 1.10, life = 1.10, delay = 0.045, alpha = 0.85, ease = "IN_OUT" },
    { x = -0.30, y = -0.35, size = 0.72, cell = 2, out = 1.50, fall = 0.60, life = 1.00, delay = 0.060, alpha = 0.85, ease = "IN_OUT" },
    { x =  0.50, y =  0.35, size = 0.85, cell = 3, out = 2.00, fall = 0.85, life = 1.15, delay = 0.040, alpha = 0.75, ease = "IN_OUT" },
    { x = -0.50, y = -0.10, size = 0.60, cell = 2, out = 1.20, fall = 1.20, life = 1.00, delay = 0.075, alpha = 0.85, ease = "IN_OUT" },
    { x =  0.10, y =  0.40, size = 0.66, cell = 2, out = 2.40, fall = 0.45, life = 1.10, delay = 0.090, alpha = 0.85, ease = "IN_OUT" },
    { x = -0.20, y = -0.45, size = 0.78, cell = 3, out = 1.60, fall = 1.05, life = 1.20, delay = 0.055, alpha = 0.75, ease = "IN_OUT" },
    { x =  0.45, y =  0.05, size = 0.56, cell = 2, out = 2.10, fall = 0.70, life = 1.05, delay = 0.105, alpha = 0.85, ease = "IN_OUT" },
    { x = -0.40, y =  0.45, size = 0.64, cell = 2, out = 1.40, fall = 0.95, life = 1.15, delay = 0.120, alpha = 0.80, ease = "IN_OUT" },

    { x = -0.10, y = -0.20, size = 0.42, cell = 1, out = 1.00, fall = 0.75, life = 1.25, delay = 0.140, alpha = 0.70, ease = "IN" },
    { x =  0.25, y =  0.25, size = 0.38, cell = 4, out = 1.40, fall = 0.50, life = 1.20, delay = 0.160, alpha = 0.70, ease = "IN" },
    { x = -0.35, y =  0.10, size = 0.45, cell = 1, out = 0.80, fall = 0.85, life = 1.30, delay = 0.170, alpha = 0.65, ease = "IN" },
    { x =  0.30, y = -0.40, size = 0.40, cell = 1, out = 1.60, fall = 0.60, life = 1.25, delay = 0.180, alpha = 0.65, ease = "IN" },
    { x = -0.25, y = -0.05, size = 0.36, cell = 4, out = 1.10, fall = 0.95, life = 1.30, delay = 0.200, alpha = 0.60, ease = "IN" },
    { x =  0.05, y =  0.15, size = 0.48, cell = 1, out = 1.30, fall = 0.70, life = 1.30, delay = 0.200, alpha = 0.60, ease = "IN" },
}
A.barEffectMotes = MOTES
local GAIN_COUNT = 14



local function gainSeat(m) return 0.30 + m.out * 0.60, m.y - 0.45 end





do
    local down, up = 0, 0
    for _, m in ipairs(MOTES) do
        down = math.max(down, m.x + m.out + m.size / 2)
        local gx = gainSeat(m)
        up = math.max(up, gx + m.size / 2)
    end
    A.barEffectReach = { down = down, up = up }
end






function A.SandTint(r, g, b, up)
    local liftBy = A.PlusLift




    local k = up and 0.72 or 0.22
    local lr, lg, lb = liftBy(r, g, b, k)
    return math.min(1, lr + 0.05), lg * 0.97, lb * 0.86
end









function A:BarEffectSeat(effect, host, h, direction, shift)
    local up = direction == "up"
    shift = tonumber(shift) or 0
    for i, quad in ipairs(effect.quads or {}) do
        local m = MOTES[i] or MOTES[#MOTES]
        local x, y = m.x, m.y
        if up then x, y = gainSeat(m) end
        quad:ClearAllPoints()
        quad:SetPoint("CENTER", host, "RIGHT", x * h + shift, y * h)
    end
end

local function sandFill(bar)
    local value = bar and bar.value
    if not (value and type(value.GetStatusBarTexture) == "function") then return nil end
    local fill = value:GetStatusBarTexture()
    if fill and type(fill.SetPoint) == "function" then return fill end
    return nil
end

local function sandBuild(self, bar)
    local host, value = bar and bar.effectHost, bar and bar.value
    local fill = sandFill(bar)
    if not (host and value and fill) then return nil end
    local fx = self:Fx(host, "burst", "fx-mote", "ARTWORK", 4)
    if not fx then return nil end



    fx.light:SetTexture(self.artPath .. "meter.tga", "CLAMP", "CLAMP")
    fx.light:ClearAllPoints()
    local quads = self:FxQuads(fx, self.barEffectPool, "fx-mote", self.barEffectCells, 1)
    if not quads then return nil end

    for i, quad in ipairs(quads) do
        local m = MOTES[i] or MOTES[#MOTES]
        local c = (m.cell - 1) / self.barEffectCells
        pcall(quad.SetTexCoord, quad, c, c + 1 / self.barEffectCells, 0, 1)
    end
    local trailFill = bar.trail and type(bar.trail.GetStatusBarTexture) == "function"
        and bar.trail:GetStatusBarTexture() or nil
    local healFill = bar.heal and type(bar.heal.GetStatusBarTexture) == "function"
        and bar.heal:GetStatusBarTexture() or nil
    local window = self:BarEffectWindow(host, fill, trailFill, 12)
    local inWindow = self:BarEffectWindow(host, fill, healFill, 12)


    local function layer(parent, sublevel)
        if not parent then return nil end
        local t = self:Own(parent:CreateTexture(nil, "ARTWORK", nil, sublevel))
        t:SetTexture(self.artPath .. "meter.tga", "CLAMP", "CLAMP")
        if type(t.SetBlendMode) == "function" then t:SetBlendMode("ADD") end
        t:SetAllPoints(parent)
        t:Hide()
        return t
    end
    local effect = {
        key = "sand", host = host, fx = fx, quads = quads,
        window = window, inWindow = inWindow,
        wound = layer(window, 1), incoming = layer(inWindow, 1), flow = layer(host, 0),
    }





    local clip = self.PlusClipToBar
    if type(clip) == "function" then
        for _, region in ipairs(quads) do clip(self, value, region) end
        for _, key in ipairs({ "wound", "incoming", "flow" }) do clip(self, value, effect[key]) end
        clip(self, value, fx.light)
    end
    effect.tex = #quads + 1
    for _, key in ipairs({ "wound", "incoming", "flow" }) do
        if effect[key] then effect.tex = effect.tex + 1 end
    end
    return effect
end

local function sandLayout(self, bar, height)
    local effect = bar and bar.effect
    local value, fill = bar and bar.value, sandFill(bar)
    if not (effect and value) then return end
    local host = fill or value
    local h = math.max(2, height or 2)
    if effect.flow then effect.flow:SetAllPoints(value) end
    local px = math.max(2, math.floor((self.PlatePixel and self:PlatePixel() or 1) * 2 + 0.5))
    if effect.fx then
        effect.fx:ClearAllPoints()
        effect.fx:SetPoint("TOPLEFT", value, "TOPLEFT", 0, 0)
        effect.fx:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 0, 0)
        effect.fx.light:ClearAllPoints()
        effect.fx.light:SetPoint("TOPLEFT", host, "TOPRIGHT", 0, 0)
        effect.fx.light:SetPoint("BOTTOMLEFT", host, "BOTTOMRIGHT", 0, 0)
        effect.fx.light:SetWidth(px)
    end



    for i, quad in ipairs(effect.quads or {}) do
        local m = MOTES[i] or MOTES[#MOTES]
        local size = math.max(2, h * m.size)
        quad:SetSize(size, size)
    end
    local shift, _, room = self:BarEffectShift(bar, h, "down", self.barEffectReach)
    effect.seatShift, effect.seatRoom = shift, room
    self:BarEffectSeat(effect, host, h, "down", shift)
    if effect.window and not effect.window.auiTwoPoint then effect.window:SetWidth(h * 2.5) end
    if effect.inWindow and not effect.inWindow.auiTwoPoint then effect.inWindow:SetWidth(h * 2.5) end
end

local function sandTint(self, bar, r, g, b)
    local effect = bar and bar.effect
    if not effect then return end
    local liftBy = self.PlusLift
    if type(liftBy) ~= "function" then return end
    local gr, gg, gb = A.SandTint(r, g, b, false)
    for i, quad in ipairs(effect.quads or {}) do
        local m = MOTES[i] or MOTES[#MOTES]
        quad:SetVertexColor(gr, gg, gb, m.alpha)
    end
    local lr, lg, lb = liftBy(r, g, b, 0.60)
    if effect.fx and effect.fx.light then effect.fx.light:SetVertexColor(lr, lg, lb, 1) end
    if effect.wound then effect.wound:SetVertexColor(gr, gg, gb, 0.28) end
    if effect.incoming then effect.incoming:SetVertexColor(lr, lg, lb, 0.30) end
    if effect.flow then effect.flow:SetVertexColor(gr, gg, gb, 0.05) end
end




local function sandBurst(self, bar, direction)
    local effect = bar and bar.effect
    if not (effect and effect.fx and effect.quads) then return false end
    if not self:MotionOn() then return false end



    if effect.small then return false end
    local up = direction == "up"
    local count = up and math.min(GAIN_COUNT, #effect.quads) or #effect.quads
    local life = up and 0.42 or 0.55
    local peak = math.min(1, (up and 0.90 or 0.72) * self:MotionAmount())
    local h = math.max(2, effect.height or 10)
    local fx = effect.fx
    local group = self:MotionGroup(fx, "burst", function(gr, anim)
        gr.auiMoves = {}
        for i = 1, #effect.quads do
            local m = MOTES[i] or MOTES[#MOTES]




            local move = anim(gr, "Translation", 1, life, m.delay, m.ease or "OUT")




            if move and select(1, pcall(move.SetTarget, move, effect.quads[i])) then
                gr.auiMoves[i] = move
            end
        end
        gr.auiTargeted = next(gr.auiMoves) ~= nil
        if not gr.auiTargeted then
            gr.auiSlide = anim(gr, "Translation", 1, life, 0, "OUT")
        end
        local rise = anim(gr, "Alpha", 1, 0.06, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(peak) end
        gr.auiRise = rise


        local fall = anim(gr, "Alpha", 1, life, life * 0.55, "IN")
        if fall then fall:SetFromAlpha(peak); fall:SetToAlpha(0) end
        gr.auiFall = fall
    end)
    if not group then return false end
    local away = up and -1 or 1



    local shift, amount, room = self:BarEffectShift(bar, h, direction, self.barEffectReach)
    effect.seatShift, effect.seatRoom = shift, room
    self:BarEffectSeat(effect, sandFill(bar) or bar.value, h, direction, shift)
    for i, move in pairs(group.auiMoves or {}) do
        local m = MOTES[i] or MOTES[#MOTES]
        local travel = up and (m.out * 0.60) or m.out
        pcall(move.SetDuration, move, life * m.life)
        pcall(move.SetOffset, move, travel * h * away * amount, up and (m.fall * 0.45 * h) or (-m.fall * h))
    end
    if group.auiSlide then
        pcall(group.auiSlide.SetDuration, group.auiSlide, life)
        pcall(group.auiSlide.SetOffset, group.auiSlide, h * 1.6 * away * amount, 0)
    end
    if group.auiRise then group.auiRise:SetToAlpha(peak) end
    if group.auiFall then
        group.auiFall:SetFromAlpha(peak)
        pcall(group.auiFall.SetDuration, group.auiFall, life)
        pcall(group.auiFall.SetStartDelay, group.auiFall, life * 0.55)
    end













    local mode = up and "ADD" or "BLEND"
    if effect.tintR then
        local qr, qg, qb = A.SandTint(effect.tintR, effect.tintG, effect.tintB, up)
        for i, quad in ipairs(effect.quads) do
            local m = MOTES[i] or MOTES[#MOTES]
            quad:SetVertexColor(qr, qg, qb, m.alpha)
            if quad.auiBlend ~= mode and type(quad.SetBlendMode) == "function" then
                quad.auiBlend = mode
                pcall(quad.SetBlendMode, quad, mode)
            end
        end
    end
    for i, quad in ipairs(effect.quads) do quad:SetShown(i <= count) end
    if fx.light then fx.light:Show() end
    stop(group)





    fx:SetAlpha(group.auiRise and 0 or peak)
    fx:Show()
    local played = play(group)
    if not group.auiRise then self:BarEffectFadeOut(fx, life * 1.6) end
    return self:BarEffectNoteBurst(effect, direction, played)
end

local function sandIdle(self, bar, which, on)
    local effect = bar and bar.effect
    if not effect then return false end
    local frame = which == "incoming" and effect.inWindow or effect.window
    local layer = which == "incoming" and effect.incoming or effect.wound
    local show = on and true or false
    if frame then frame:SetShown(show) end
    if layer then layer:SetShown(show) end
    if effect.flow then effect.flow:SetShown(not effect.small) end
    return show
end

local function sandTeardown(self, bar)
    local effect = bar and bar.effect
    if not effect then return end
    if effect.fx then
        stop(self.motionGroups[effect.fx] and self.motionGroups[effect.fx].burst)
        effect.fx:SetAlpha(0)
        effect.fx:Hide()
    end
    for _, quad in ipairs(effect.quads or {}) do quad:Hide() end
    for _, key in ipairs({ "wound", "incoming", "flow" }) do
        if effect[key] then effect[key]:Hide() end
    end
    for _, key in ipairs({ "window", "inWindow", "host" }) do
        if effect[key] then effect[key]:Hide() end
    end
end

local SAND = {
    build = sandBuild, layout = sandLayout, tint = sandTint, idle = sandIdle,
    teardown = sandTeardown,
    loss = function(self, bar) return sandBurst(self, bar, "down") end,
    gain = function(self, bar) return sandBurst(self, bar, "up") end,
    cost = { tex = 24, groups = 1 }, sheet = "fx-mote",
}
A.barEffects.sand = SAND



A.barEffects.ash = setmetatable({ neutral = true }, { __index = SAND })










local function pulseBuild(self, bar)
    local host = bar and bar.effectHost
    if not host then return nil end
    local effect = { key = "pulse", host = host }
    local fx = self:EdgeFlash(host, effect, "ring", 2, 2)
    if not fx then return nil end
    effect.fx, effect.tex = fx, 4
    return effect
end

local function pulseLayout(self, bar, height)
    local effect = bar and bar.effect
    if not (effect and effect.fx) then return end
    local px = self.PlatePixel and self:PlatePixel() or 1
    self:SizeEdgeFlash(effect.fx, math.max(2, math.floor(px * 2 + 0.5)))
    self:SpreadEdgeFlash(effect.fx, math.max(2, math.floor((height or 10) * 0.28 + 0.5)))
end

local function pulseTint(self, bar, r, g, b)
    local effect = bar and bar.effect
    local liftBy = self.PlusLift
    if not (effect and effect.fx and type(liftBy) == "function") then return end
    self:PaintEdgeFlash(effect.fx, liftBy(r, g, b, 0.55))
end

local function pulseRing(self, bar, direction)
    local effect = bar and bar.effect
    if not (effect and effect.fx) then return false end
    if effect.small then return false end
    return self:BarEffectNoteBurst(effect, direction or "moved",
        self:PlayEdgeFlash(effect.fx, nil, nil, nil, 1))
end

local function pulseTeardown(self, bar)
    local effect = bar and bar.effect
    if effect and effect.fx then effect.fx:SetAlpha(0); effect.fx:Hide() end
    if effect and effect.host then effect.host:Hide() end
end

A.barEffects.pulse = {
    build = pulseBuild, layout = pulseLayout, tint = pulseTint,
    loss = function(self, bar) return pulseRing(self, bar, "down") end,
    gain = function(self, bar) return pulseRing(self, bar, "up") end,
    moved = function(self, bar) return pulseRing(self, bar, "moved") end,
    idle = function() return false end,
    teardown = pulseTeardown,
    cost = { tex = 4, groups = 1 },
}






















local SLAB_X    = { 0.50, 1.25, 2.05 }
local SLAB_Y    = { 0.10, -0.16, 0.06 }
local SLAB_OUT  = { 1.20, 1.90, 2.60 }
local SLAB_FALL = { 0.34, 0.60, 0.22 }


A.shearReach = { down = 2.05 + 0.31, up = 2.05 + 2.60 + 0.31 }

local function shearBuild(self, bar)
    local host, value = bar and bar.effectHost, bar and bar.value
    local fill = sandFill(bar)
    if not (host and value and fill) then return nil end
    local fx = self:Fx(host, "slabs", "fx-slab", "ARTWORK", 4)
    if not fx then return nil end


    fx.light:SetTexture(self.artPath .. "meter.tga", "CLAMP", "CLAMP")
    fx.light:ClearAllPoints()



    local quads = self:FxQuads(fx, 3, "fx-slab", 2, 1)
    if not quads then return nil end
    if type(quads[1].SetTexCoord) == "function" then
        pcall(quads[1].SetTexCoord, quads[1], 0, 0.5, 0, 1)
        pcall(quads[2].SetTexCoord, quads[2], 0.5, 1, 0, 1)
        pcall(quads[3].SetTexCoord, quads[3], 0.5, 1, 0, 1)
    end
    local effect = { key = "shear", host = host, fx = fx, quads = quads }


    local ring = self:EdgeFlash(host, effect, "ring", 2, 2)
    if not ring then return nil end
    effect.ring = ring
    local clip = self.PlusClipToBar
    if type(clip) == "function" then
        for _, region in ipairs(quads) do clip(self, value, region) end
        clip(self, value, fx.light)
    end
    effect.tex = #quads + 1 + 4
    return effect
end

local function shearLayout(self, bar, height)
    local effect = bar and bar.effect
    local value, fill = bar and bar.value, sandFill(bar)
    if not (effect and value) then return end
    local host = fill or value
    local h = math.max(2, height or 2)
    local px = math.max(2, math.floor((self.PlatePixel and self:PlatePixel() or 1) * 2 + 0.5))
    effect.fx:ClearAllPoints()
    effect.fx:SetPoint("TOPLEFT", value, "TOPLEFT", 0, 0)
    effect.fx:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 0, 0)
    effect.fx.light:ClearAllPoints()
    effect.fx.light:SetPoint("TOPLEFT", host, "TOPRIGHT", 0, 0)
    effect.fx.light:SetPoint("BOTTOMLEFT", host, "BOTTOMRIGHT", 0, 0)
    effect.fx.light:SetWidth(px)



    for _, quad in ipairs(effect.quads) do quad:SetSize(h * 0.62, h * 1.30) end
    local shift, _, room = self:BarEffectShift(bar, h, "down", self.shearReach)
    effect.seatShift, effect.seatRoom = shift, room
    self:ShearSeat(effect, host, h, "down", shift)
    if effect.ring then
        self:SizeEdgeFlash(effect.ring, px)
        self:SpreadEdgeFlash(effect.ring, math.max(2, math.floor(h * 0.28 + 0.5)))
    end
end

function A:ShearSeat(effect, host, h, direction, shift)
    local out = direction == "up"
    shift = tonumber(shift) or 0
    for i, quad in ipairs(effect.quads or {}) do
        quad:ClearAllPoints()
        quad:SetPoint("CENTER", host, "RIGHT",
            (SLAB_X[i] + (out and SLAB_OUT[i] or 0)) * h + shift, SLAB_Y[i] * h)
    end
end

local function shearTint(self, bar, r, g, b)
    local effect = bar and bar.effect
    local liftBy = self.PlusLift
    if not (effect and type(liftBy) == "function") then return end
    local sr, sg, sb = liftBy(r, g, b, 0.45)
    for _, quad in ipairs(effect.quads or {}) do quad:SetVertexColor(sr, sg, sb, 1) end
    if effect.fx and effect.fx.light then effect.fx.light:SetVertexColor(liftBy(r, g, b, 0.55)) end
    if effect.ring then self:PaintEdgeFlash(effect.ring, liftBy(r, g, b, 0.70)) end
end

local function shearBurst(self, bar, direction)
    local effect = bar and bar.effect
    if not (effect and effect.fx and effect.quads) then return false end
    if not self:MotionOn() then return false end
    if effect.small then return false end
    local up = direction == "up"
    local count = up and 2 or 3
    local life = up and 0.18 or 0.26
    local peak = math.min(1, (up and 0.85 or 0.78) * self:MotionAmount())
    local h = math.max(2, effect.height or 10)
    local fx = effect.fx
    local group = self:MotionGroup(fx, "burst", function(gr, anim)
        gr.auiMoves = {}
        for i = 1, #effect.quads do
            local move = anim(gr, "Translation", 1, life, (i - 1) * 0.055, "OUT")
            if move and select(1, pcall(move.SetTarget, move, effect.quads[i])) then
                gr.auiMoves[i] = move
            end
        end
        if next(gr.auiMoves) == nil then gr.auiSlide = anim(gr, "Translation", 1, life, 0, "OUT") end
        local rise = anim(gr, "Alpha", 1, 0.06, 0, "OUT")
        if rise then rise:SetFromAlpha(0); rise:SetToAlpha(peak) end
        gr.auiRise = rise
        local fall = anim(gr, "Alpha", 1, life, 0.08, "IN")
        if fall then fall:SetFromAlpha(peak); fall:SetToAlpha(0) end
        gr.auiFall = fall
    end)
    if not group then return false end
    local away = up and -1 or 1
    local shift, amount, room = self:BarEffectShift(bar, h, direction, self.shearReach)
    effect.seatShift, effect.seatRoom = shift, room
    self:ShearSeat(effect, sandFill(bar) or bar.value, h, direction, shift)
    for i, move in pairs(group.auiMoves or {}) do
        pcall(move.SetDuration, move, life)
        pcall(move.SetOffset, move, SLAB_OUT[i] * h * away * amount,
            -SLAB_FALL[i] * h * (up and -0.3 or 1))
    end
    if group.auiSlide then
        pcall(group.auiSlide.SetDuration, group.auiSlide, life)
        pcall(group.auiSlide.SetOffset, group.auiSlide, h * 1.4 * away * amount, 0)
    end
    if group.auiRise then group.auiRise:SetToAlpha(peak) end
    if group.auiFall then
        group.auiFall:SetFromAlpha(peak)
        pcall(group.auiFall.SetDuration, group.auiFall, life)
    end
    for i, quad in ipairs(effect.quads) do quad:SetShown(i <= count) end
    if fx.light then fx.light:Show() end
    stop(group)
    fx:SetAlpha(group.auiRise and 0 or peak)
    fx:Show()
    if not group.auiRise then self:BarEffectFadeOut(fx, life) end









    if up and effect.ring then self:PlayEdgeFlash(effect.ring, nil, nil, nil, 0.8) end
    return self:BarEffectNoteBurst(effect, direction, play(group))
end

A.barEffects.shear = {
    build = shearBuild, layout = shearLayout, tint = shearTint,
    loss = function(self, bar) return shearBurst(self, bar, "down") end,
    gain = function(self, bar) return shearBurst(self, bar, "up") end,
    idle = function() return false end,
    teardown = function(self, bar)
        local effect = bar and bar.effect
        if effect then
            for _, quad in ipairs(effect.quads or {}) do quad:Hide() end
            if effect.ring then effect.ring:SetAlpha(0); effect.ring:Hide() end
        end
        pulseTeardown(self, bar)
    end,
    cost = { tex = 8, groups = 2 }, sheet = "fx-slab",
}



local function linear(c) return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4 end
function A.Luminance(color) return 0.2126 * linear(color[1]) + 0.7152 * linear(color[2]) + 0.0722 * linear(color[3]) end
function A.Contrast(a, b)
    local la, lb = A.Luminance(a), A.Luminance(b)
    if la < lb then la, lb = lb, la end
    return (la + 0.05) / (lb + 0.05)
end
