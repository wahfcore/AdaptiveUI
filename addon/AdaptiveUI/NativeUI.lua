local _, A = ...

A.skinModules = {
    { key = "actions", label = "Actions / cooldowns" },
    { key = "units", label = "Player / target frames" },
    { key = "party", label = "Party / raid frames" },
    { key = "auras", label = "Buffs / debuffs" },
    { key = "minimap", label = "Minimap trim" },
    { key = "objectives", label = "Objectives" },
    { key = "chat", label = "Chat panels" },
    { key = "tooltips", label = "Tooltips" },
}

A.nativeRefreshEvents = {
    PLAYER_ENTERING_WORLD = true, PLAYER_REGEN_ENABLED = true, ADDON_LOADED = true,
    GROUP_ROSTER_UPDATE = true, UNIT_AURA = true, ACTIONBAR_SLOT_CHANGED = true,
    UPDATE_OVERRIDE_ACTIONBAR = true, UPDATE_VEHICLE_ACTIONBAR = true,
    UPDATE_BONUS_ACTIONBAR = true, PET_BAR_UPDATE = true, UPDATE_MOUSEOVER_UNIT = true,
    DISPLAY_SIZE_CHANGED = true, PLAYER_TARGET_CHANGED = true, UPDATE_SHAPESHIFT_FORMS = true,
    UI_SCALE_CHANGED = true, QUEST_LOG_UPDATE = true, UNIT_ENTERED_VEHICLE = true, UNIT_EXITED_VEHICLE = true,
}

local function path(root, ...)
    for i = 1, select("#", ...) do
        if not root then return nil end
        root = root[select(i, ...)]
    end
    return root
end

local function publicColor(self, values)
    for i = 1, 4 do
        local value = values[i]
        if not self:IsPublic(value) or type(value) ~= "number" or value ~= value then return false end
    end
    return true
end

local function stateFor(self, key)
    self.nativeSkins = self.nativeSkins or {}
    if not self.nativeSkins[key] then
        self.nativeSkins[key] = { changes = {}, decorations = {}, count = 0 }
    end
    return self.nativeSkins[key]
end


local function tint(self, state, region)
    if not region or type(region.GetVertexColor) ~= "function" or type(region.SetVertexColor) ~= "function" then return end



    if state.swapped and state.swapped[region] then return end


    if self:IsOwn(region) then return end
    local current = { region:GetVertexColor() }
    if not publicColor(self, current) then return end
    local desaturation
    if type(region.GetDesaturation) == "function" and type(region.SetDesaturation) == "function" then
        desaturation = region:GetDesaturation()
        if not self:IsPublic(desaturation) or type(desaturation) ~= "number"
            or desaturation ~= desaturation or desaturation < 0 or desaturation > 1 then return end
    end
    local record = state.changes[region]
    if not record then
        local color = current
        record = { restore = function()
            local now = { region:GetVertexColor() }
            if not publicColor(self, now) then error("Restricted cosmetic restore") end
            if desaturation ~= nil then region:SetDesaturation(desaturation) end
            region:SetVertexColor(color[1], color[2], color[3], now[4])
        end }
        state.changes[region] = record
    end
    local trim = { self:Color("tint") }

    if desaturation ~= nil and desaturation ~= 1 then region:SetDesaturation(1) end
    if current[1] ~= trim[1] or current[2] ~= trim[2] or current[3] ~= trim[3] then
        region:SetVertexColor(trim[1], trim[2], trim[3], current[4])
    end
    state.count = state.count + 1
end




























local function track(self, texture, opacity) return opacity end

local function edgeBorder(self, state, frame, thickness, padding, anchor, layer)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    anchor = anchor or frame
    padding = padding or 0
    layer = layer or "OVERLAY"
    local entries = state.decorations[frame]
    if not entries then entries = {}; state.decorations[frame] = entries end
    if not entries.border then
        local function edge()
            local texture = self:Own(frame:CreateTexture(nil, layer, nil, -1))
            self:Tint(texture, "edge", "color")
            return texture
        end
        entries.border, entries.borderBottom = edge(), edge()
        entries.borderLeft, entries.borderRight = edge(), edge()
        entries.border:SetPoint("TOPLEFT", anchor, "TOPLEFT", -padding, padding)
        entries.border:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", padding, padding)
        entries.border:SetHeight(thickness)
        entries.borderBottom:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", -padding, -padding)
        entries.borderBottom:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", padding, -padding)
        entries.borderBottom:SetHeight(thickness)
        entries.borderLeft:SetPoint("TOPLEFT", anchor, "TOPLEFT", -padding, padding)
        entries.borderLeft:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", -padding, -padding)
        entries.borderLeft:SetWidth(thickness)
        entries.borderRight:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", padding, padding)
        entries.borderRight:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", padding, -padding)
        entries.borderRight:SetWidth(thickness)
    end
    for _, key in ipairs({ "border", "borderBottom", "borderLeft", "borderRight" }) do
        local want = self:BordersOn()
        if entries[key]:IsShown() ~= want then if want then entries[key]:Show() else entries[key]:Hide() end end
    end
    state.count = state.count + 1
end



local function flatFill(self, state, frame, opacity, ambient, level)
    if not frame or type(frame.CreateTexture) ~= "function" then return end
    local entries = state.decorations[frame]
    if not entries then entries = {}; state.decorations[frame] = entries end
    if not entries.panel then
        if level then self:Elevate(entries, frame, "panel~", frame, 0, 0, frame, 0, 0, level) end
        local texture = self:Own(frame:CreateTexture(nil, "BACKGROUND", nil, -8))
        self:Tint(texture, "nativeInk", "color")
        texture:SetAllPoints(frame)
        entries.panel = texture
    end
    if level then self:ApplyDepth(entries, "panel~") end
    local want = track(self, entries.panel, opacity or 1, ambient)
    if entries.panel:GetAlpha() ~= want then entries.panel:SetAlpha(want) end
    if not entries.panel:IsShown() then entries.panel:Show() end
    state.count = state.count + 1
end










local function glassPanel(self, state, host, key, tl, tlx, tly, br, brx, bry, opacity, thickness, ambient, level)
    if not host or not tl or not br or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    local fill = entries[key]
    if not fill then

        if level then self:Elevate(entries, host, key .. "~", tl, tlx, tly, br, brx, bry, level) end
        fill = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
        self:Tint(fill, "nativeInk", "color")
        fill:SetPoint("TOPLEFT", tl, "TOPLEFT", tlx, tly)
        fill:SetPoint("BOTTOMRIGHT", br, "BOTTOMRIGHT", brx, bry)
        entries[key] = fill
        if thickness and thickness > 0 then
            local function edge(name)
                local texture = self:Own(host:CreateTexture(nil, "OVERLAY", nil, -1))
                self:Tint(texture, "edge", "color")
                entries[key .. name] = texture
                return texture
            end
            local top, bottom, left, right = edge("Top"), edge("Bottom"), edge("Left"), edge("Right")
            top:SetPoint("TOPLEFT", fill, "TOPLEFT"); top:SetPoint("TOPRIGHT", fill, "TOPRIGHT"); top:SetHeight(thickness)
            bottom:SetPoint("BOTTOMLEFT", fill, "BOTTOMLEFT"); bottom:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT"); bottom:SetHeight(thickness)
            left:SetPoint("TOPLEFT", fill, "TOPLEFT"); left:SetPoint("BOTTOMLEFT", fill, "BOTTOMLEFT"); left:SetWidth(thickness)
            right:SetPoint("TOPRIGHT", fill, "TOPRIGHT"); right:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT"); right:SetWidth(thickness)
        end
    end
    local want = track(self, fill, opacity or 1, ambient)
    if fill:GetAlpha() ~= want then fill:SetAlpha(want) end
    if level then self:ApplyDepth(entries, key .. "~") end
    for _, name in ipairs({ "", "Top", "Bottom", "Left", "Right" }) do
        local texture = entries[key .. name]
        local shown = name == "" or self:BordersOn()
        if texture and texture:IsShown() ~= shown then if shown then texture:Show() else texture:Hide() end end
    end
    state.count = state.count + 1
end


















local function veilPanel(self, state, host, key, tl, tlx, tly, br, brx, bry, opacity)
    if not host or not tl or not br or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    local B, CAP = self.veilBleed, self.veilCap
    if not entries[key .. "M"] then
        local function piece(file)
            local t = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
            t:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")
            return t
        end
        local left, right, mid = piece("veil-cap"), piece("veil-cap"), piece("veil-mid")
        left:SetWidth(CAP)
        right:SetWidth(CAP)
        right:SetTexCoord(1, 0, 0, 1)
        left:SetPoint("TOPRIGHT", tl, "TOPLEFT", tlx - B, tly + B)
        left:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT", tlx - B, bry - B)
        right:SetPoint("TOPLEFT", tl, "TOPRIGHT", brx + B, tly + B)
        right:SetPoint("BOTTOMLEFT", br, "BOTTOMRIGHT", brx + B, bry - B)
        mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
        mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
        entries[key .. "L"], entries[key .. "R"], entries[key .. "M"] = left, right, mid






        for _, suffix in ipairs({ "L", "R", "M" }) do
            self:Tint(entries[key .. suffix], "nativeInk", "vertex")
        end
    end
    local want = track(self, entries[key .. "M"], opacity or 1)
    for _, suffix in ipairs({ "L", "R", "M" }) do
        local t = entries[key .. suffix]
        if t:GetAlpha() ~= want then t:SetAlpha(want) end
    end
    state.count = state.count + 1
end




local function textChip(self, state, host, text, key, padX, padY, opacity, ambient)
    if not host or not text or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[text]
    if not entries then entries = {}; state.decorations[text] = entries end
    if not entries[key] then
        local chip = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -7))
        self:Tint(chip, "nativeInk", "color")
        chip:SetPoint("TOPLEFT", text, "TOPLEFT", -padX, padY)
        chip:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", padX, -padY)
        entries[key] = chip
    end
    local chip = entries[key]
    local want = track(self, chip, opacity or 1, ambient)
    if chip:GetAlpha() ~= want then chip:SetAlpha(want) end
    if not chip:IsShown() then chip:Show() end
    state.count = state.count + 1
end






local function fadePanel(self, state, host, key, tl, tlx, tly, br, brx, bry, opacity, flip)
    if not host or not tl or not br or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    local fill = entries[key]
    if not fill then
        fill = self:Own(host:CreateTexture(nil, "BACKGROUND", nil, -8))
        fill:SetTexture(self.artPath .. "fade.tga", "CLAMP", "CLAMP")
        self:Tint(fill, "nativeInk", "vertex", 1)
        if flip then fill:SetTexCoord(1, 0, 0, 1) end
        fill:SetPoint("TOPLEFT", tl, "TOPLEFT", tlx, tly)
        fill:SetPoint("BOTTOMRIGHT", br, "BOTTOMRIGHT", brx, bry)
        entries[key] = fill
    end
    local want = track(self, fill, opacity or 1, true)
    if fill:GetAlpha() ~= want then fill:SetAlpha(want) end
    if not fill:IsShown() then fill:Show() end
    state.count = state.count + 1
end




local function edgeRule(self, state, host, key, anchor, side, inset)
    if not host or not anchor or type(host.CreateTexture) ~= "function" then return end
    local entries = state.decorations[host]
    if not entries then entries = {}; state.decorations[host] = entries end
    local rule = entries[key]
    if not rule then
        rule = self:Own(host:CreateTexture(nil, "OVERLAY", nil, 0))
        self:Tint(rule, "accent", "color")
        rule:SetPoint("TOP" .. side, anchor, "TOP" .. side, inset or 0, 0)
        rule:SetPoint("BOTTOM" .. side, anchor, "BOTTOM" .. side, inset or 0, 0)
        rule:SetWidth(2)
        entries[key] = rule
    end
    local want = self:GetOption("accentRule")
    if rule:IsShown() ~= want then if want then rule:Show() else rule:Hide() end end
    state.count = state.count + 1
end



local function stripRegions(self, state, ...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region then self:HoldHidden(state, region); state.count = state.count + 1 end
    end
end






local function stripOwnTextures(self, state, frame)
    if not frame or type(frame.GetRegions) ~= "function" then return end
    for _, region in ipairs({ frame:GetRegions() }) do
        if type(region.IsObjectType) == "function" and region:IsObjectType("Texture")
            and not region:IsObjectType("MaskTexture") and not self:IsOwn(region) then
            self:HoldHidden(state, region)
            state.count = state.count + 1
        end
    end
end







local function hideRegion(self, state, region)
    if not region or type(region.GetAlpha) ~= "function" then return end
    if self:IsOwn(region) then return end
    local old = region:GetAlpha()
    if not self:IsPublic(old) or type(old) ~= "number" then return end
    self:RememberProperty(state, region, "alpha", function()
        return function() region:SetAlpha(old) end
    end)


    if old ~= 0 then region:SetAlpha(0) end
end




local function cropIcon(self, state, icon)
    if not icon or type(icon.SetTexCoord) ~= "function" or type(icon.GetTexCoord) ~= "function" then return end
    local coords = { icon:GetTexCoord() }
    for _, value in ipairs(coords) do
        if not self:IsPublic(value) or type(value) ~= "number" then return end
    end
    self:RememberProperty(state, icon, "texCoord", function()
        return function() icon:SetTexCoord(unpack(coords)) end
    end)
    if not (coords[1] == 0.08 and coords[2] == 0.92 and coords[3] == 0.08 and coords[4] == 0.92) then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
end







local function showIf(self, state, region, visible)
    if not region or type(region.GetAlpha) ~= "function" or type(region.SetAlpha) ~= "function" then return end
    local captured = state.properties and state.properties[region] and state.properties[region].alpha
    if not captured then
        local old = region:GetAlpha()
        if not self:IsPublic(old) or type(old) ~= "number" then return end
        self:RememberProperty(state, region, "alpha", function()
            return function() region:SetAlpha(old) end
        end)
    end
    local target = visible and 1 or 0
    local now = region:GetAlpha()
    if not self:IsPublic(now) or now ~= target then region:SetAlpha(target) end
end



























local DIAMOND_MASKED = { "icon", "Flash", "SpecialActionIcon" }









local DIAMOND_INSET, GLOW_SPILL = 4, 12






























local GLYPH_CHIP, GLYPH = 16, 13
local GEM_CHIP, GEM_GLYPH = 18, 12
















































local SOCKET_WELL = 21 / 32
local SOCKET_INSET = 6
local SOCKET_CHIP = 18
local SOCKET_PLINTH = 26
local SOCKET_INSET_R = 0.1333
local SOCKET_CHIP_R = 0.40
local SOCKET_PLINTH_R = 0.58



function A:SocketInset(w)
    w = tonumber(w) or 45
    if not self:CompassLive() then return SOCKET_INSET end
    return math.max(3, self:PlusSnap(w * SOCKET_INSET_R))
end
function A:SocketChip(w)
    if not self:CompassLive() then return SOCKET_CHIP end
    return math.max(6, (tonumber(w) or 45) * SOCKET_CHIP_R)
end
function A:SocketPlinth(w)
    if not self:CompassLive() then return SOCKET_PLINTH end
    return math.max(8, (tonumber(w) or 45) * SOCKET_PLINTH_R)
end

local SOCKET_STATES = {
    bound = { 0, 0.5, 0, 0.5 }, empty = { 0.5, 1, 0, 0.5 },
    focus = { 0, 0.5, 0.5, 1 }, focusEmpty = { 0.5, 1, 0.5, 1 },
}

function A:AuthoredSockets()
    if not (self.db and self.optionIndex) then return false end
    return self:GetOption("actionSocketSkin") == "authored"
        and self:GetOption("actionDiamond") == true
end























































local TILE_BODY = 0.659
local TILE_DIAMOND_FIT = 0.80
local TILE_FAINT = 0.35
local TILE_DIRECTIONS = { "left", "top", "right", "bottom" }

local TILE_TRANSFORMS = {
    identity = { 0, 0, 0, 1, 1, 0, 1, 1 },
    hflip    = { 1, 0, 1, 1, 0, 0, 0, 1 },
    vflip    = { 0, 1, 0, 0, 1, 1, 1, 0 },
    rot180   = { 1, 1, 1, 0, 0, 1, 0, 0 },
    rot90ccw = { 1, 0, 0, 0, 1, 1, 0, 1 },
    antiT    = { 1, 1, 0, 1, 1, 0, 0, 0 },
}
local TILE_EMPTY = {
    left = { "compass-tile-pip-tl", "identity" }, top = { "compass-tile-pip-tl", "hflip" },
    bottom = { "compass-tile-pip-bl", "identity" }, right = { "compass-tile-pip-bl", "hflip" },
}
local TILE_MAP = {
    square = {
        bound = { top = { "compass-tile-notch", "identity" }, right = { "compass-tile-notch", "antiT" },
                  left = { "compass-tile-notch", "rot90ccw" }, bottom = { "compass-tile-notch", "vflip" } },
        empty = TILE_EMPTY,
    },
    diamond = {
        bound = { top = { "compass-tile-cut", "identity" }, left = { "compass-tile-cut", "hflip" },
                  right = { "compass-tile-cut", "vflip" }, bottom = { "compass-tile-cut", "rot180" } },
        empty = TILE_EMPTY,
    },
}
A.tileArt = { body = TILE_BODY, fit = TILE_DIAMOND_FIT, faint = TILE_FAINT, directions = TILE_DIRECTIONS,
              transforms = TILE_TRANSFORMS }





function A:CompassTilesOn()
    if not (self.db and self.optionIndex and self.optionIndex.compassButtonSkin) then return false end
    if self:GetOption("compassButtonSkin") ~= "tiles" then return false end
    if not self:AuthoredSockets() then return false end
    if not self.CompassSkin or self:CompassSkin() ~= "rail" then return false end
    local s = self.artSlots
    return s ~= nil and s.compassTileNotch ~= nil and s.compassTileCut ~= nil
        and s.compassTilePipTL ~= nil and s.compassTilePipBL ~= nil
end


function A:CompassIconShape()
    if not self:CompassTilesOn() then return "diamond" end
    return self:GetOption("compassIconShape") == "diamond" and "diamond" or "square"
end


function A:CompassTileSpec(shape, kind, direction)
    local byShape = TILE_MAP[shape] or TILE_MAP.square
    local byKind = byShape[kind] or byShape.bound
    return byKind[direction] or byKind.top
end








function A:CompassTileCoords(transform, diamond)
    local t = TILE_TRANSFORMS[transform] or TILE_TRANSFORMS.identity
    local z, c = math.sqrt(2) * TILE_BODY, math.sqrt(0.5)
    local out = {}
    for i, p in ipairs({ { -0.5, -0.5 }, { -0.5, 0.5 }, { 0.5, -0.5 }, { 0.5, 0.5 } }) do
        local u, v
        if diamond then
            u, v = 0.5 + z * (c * p[1] - c * p[2]), 0.5 + z * (c * p[1] + c * p[2])
        else
            u, v = 0.5 + p[1], 0.5 + p[2]
        end

        out[2 * i - 1] = t[1] + u * (t[5] - t[1]) + v * (t[3] - t[1])
        out[2 * i] = t[2] + u * (t[6] - t[2]) + v * (t[4] - t[2])
    end
    return unpack(out)
end










function A:CompassSlotSheet()
    if not self.CompassSkin or self:CompassSkin() ~= "rail" then return "socket-facet" end
    local name = self:GetOption("compassSlotBrass") == true and "compass-slot-brass" or "compass-slot"
    if self:GetOption("compassEmptyStyle") == "socket" then name = name .. "-socket" end
    return name
end





function A:SocketMetrics(button)
    local w = self:Number(button.GetWidth, 1, button) or 45
    local inset = self:SocketInset(w)
    if w <= 2 * inset then return nil end
    return (w - 2 * inset) / SOCKET_WELL, w, inset
end

local function artTexture(self, host, file, layer, sublevel)
    local texture = host:CreateTexture(nil, layer, nil, sublevel)
    texture:SetTexture(self.artPath .. file .. ".tga", "CLAMP", "CLAMP")





    return self:Own(texture)
end
















local GLYPH_INDEX = { left = 1, top = 2, right = 3, bottom = 4 }
local GLYPH_KEYS = {
    GAMEPAD_DPAD_LEFT = { "dir", 1 }, GAMEPAD_DPAD_TOP = { "dir", 2 },
    GAMEPAD_DPAD_RIGHT = { "dir", 3 }, GAMEPAD_DPAD_BOTTOM = { "dir", 4 },
    GAMEPAD_FACE_LEFT = { "face", 1 }, GAMEPAD_FACE_TOP = { "face", 2 },
    GAMEPAD_FACE_RIGHT = { "face", 3 }, GAMEPAD_FACE_BOTTOM = { "face", 4 },
}
A.glyphIndex = GLYPH_INDEX

local function glyphSlot(self, button, family, index)
    local icon = button.ButtonIcon
    local key = icon and icon.mappedButtonKey
    if self:IsPublic(key) and type(key) == "string" then
        for name, entry in pairs(GLYPH_KEYS) do
            local value = _G[name]
            if type(value) == "string" and value == key then return entry[1], entry[2] end
        end
    end
    if (family == "dir" or family == "face") and type(index) == "number"
        and index >= 1 and index <= 4 then
        return family, index
    end
    return nil
end


local function glyphCoords(index)
    return (index - 1) / 4, index / 4, 0, 1
end
















local function inputGlyph(self, state, entries, button, family, index, on, bound)
    if not on and not entries.glyph then return false end
    if on and not entries.glyph then
        local ok = pcall(function()




            local chip = artTexture(self, button, "plate", "OVERLAY", 5)
            self:Tint(chip, "well", "vertex", 0.9)
            local glyph = artTexture(self, button, "pad-dir", "OVERLAY", 6)
            glyph:SetPoint("CENTER", chip, "CENTER", 0, 0)
            self:Tint(glyph, "text", "vertex")
            entries.glyphChip, entries.glyph = chip, glyph
        end)
        if not ok then return false end
    end
    local chip, glyph = entries.glyphChip, entries.glyph
    if not glyph then return false end





    local socket = self:GetOption("actionDiamond") == true
    local authored = self:AuthoredSockets()
















    local mode = (authored and "authored") or (socket and "socket") or "plate"



    local liveW = self:Number(button.GetWidth, 1, button) or 45
    if chip.glyphSocket ~= mode or chip.glyphSlotW ~= liveW then
        chip.glyphSocket = mode
        chip.glyphSlotW = liveW
        local art = (mode == "socket" and "diamond-mask") or (mode == "plate" and "plate") or nil
        if art then chip:SetTexture(self.artPath .. art .. ".tga", "CLAMP", "CLAMP") end
        chip:ClearAllPoints()
        glyph:ClearAllPoints()
        if authored then




            local w = liveW
            local size = self:SocketChip(w)
            local a, a2 = (w - 2 * self:SocketInset(w)) / 2, size / 2
            local offset = w / 2 - (a + a2) / 2
            chip:SetSize(size, size)
            chip:SetPoint("CENTER", button, "TOPRIGHT", -offset, -offset)



            glyph:SetSize(size, size)
            glyph:SetPoint("CENTER", button, "TOPRIGHT", -offset, -offset)
        elseif socket then
            glyph:SetPoint("CENTER", chip, "CENTER", 0, 0)




            local w = self:Number(button.GetWidth, 1, button) or 45
            local a, a2 = (w - 2 * DIAMOND_INSET) / 2, GEM_CHIP / 2
            local offset = w / 2 - (a + a2) / 2
            chip:SetSize(GEM_CHIP, GEM_CHIP)
            chip:SetPoint("CENTER", button, "TOPRIGHT", -offset, -offset)
            glyph:SetSize(GEM_GLYPH, GEM_GLYPH)
        else
            glyph:SetPoint("CENTER", chip, "CENTER", 0, 0)
            chip:SetSize(GLYPH_CHIP, GLYPH_CHIP)
            chip:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
            glyph:SetSize(GLYPH, GLYPH)
        end
    end
    local want = on and family ~= nil and bound ~= false
    local dressSheet
    if want then
        local sheet = authored and (family == "face" and "socket-glyph-face" or "socket-glyph")
            or (family == "face" and "pad-face" or "pad-dir")
        local file = self.artPath .. sheet .. ".tga"


        if authored then file = self:PaintedPath(sheet) end
        if glyph:GetTexture() ~= file then glyph:SetTexture(file, "CLAMP", "CLAMP") end
        local l, r, t, b = glyphCoords(index)
        local now = { glyph:GetTexCoord() }
        if now[1] ~= l or now[2] ~= r then glyph:SetTexCoord(l, r, t, b) end
        if authored then dressSheet = sheet end
    end
    if not (want and authored) and glyph.auiTwin and glyph.auiTwin:IsShown() then glyph.auiTwin:Hide() end
    if not (want and authored) then self:DropGlaze(glyph) end




    if authored ~= (glyph.socketPainted == true) then
        glyph.socketPainted = authored
        if authored then
            self.themed[glyph] = nil
            glyph:SetVertexColor(1, 1, 1, 1)
        else
            glyph.auiBodyTint = nil
            self:Tint(glyph, "text", "vertex")
        end
    end


    if dressSheet then self:DressPaintedRegion(glyph, dressSheet) end
    local chipWant = want and not authored
    if chip:IsShown() ~= chipWant then
        if chipWant then chip:Show() else chip:Hide() end
    end
    if glyph:IsShown() ~= want then
        if want then glyph:Show() else glyph:Hide() end
    end
    return want
end


local function isGamepadButton(button)
    return button.CircleMask ~= nil and button.SquareMask ~= nil
        and type(button.CreateMaskTexture) == "function"
end







local function inset(texture, button, amount)
    texture:SetPoint("TOPLEFT", button, "TOPLEFT", amount, -amount)
    texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -amount, amount)
end








local function tileArt(self, entries, button, shape, bound, index)
    local direction = TILE_DIRECTIONS[index or 0] or "top"
    local kind = bound == false and "empty" or "bound"
    local spec = self:CompassTileSpec(shape, kind, direction)
    local key = kind == "bound" and "tileBound" or "tileEmpty"
    local other = kind == "bound" and "tileEmpty" or "tileBound"
    if not entries[key] then
        local ok = pcall(function()


            local t = self:PaintedTexture(button, "BACKGROUND", -3, spec[1])
            t:SetPoint("CENTER", button, "CENTER", 0, 0)
            entries[key] = t
            entries[key .. "Acc"] = self:PaintedTwin(t)
        end)
        if not ok then return false end
    end
    local t = entries[key]
    if not t then return false end
    if entries[other] and entries[other]:IsShown() then self:HidePainted(entries[other]) end
    if (self.painted[t] and self.painted[t].name) ~= spec[1] then self:SetPainted(t, spec[1]) end


    local w = self:Number(button.GetWidth, 1, button) or 45
    local size = shape == "diamond" and w * TILE_DIAMOND_FIT * math.sqrt(2) or w / TILE_BODY
    if t.tileSize ~= size then
        t.tileSize = size
        t:SetSize(size, size)
    end
    local signature = spec[2] .. ":" .. shape
    if t.tileCoords ~= signature then
        t.tileCoords = signature
        t:SetTexCoord(self:CompassTileCoords(spec[2], shape == "diamond"))
    end



    local alpha = 1
    if kind == "empty" and self:GetOption("compassEmptyStyle") ~= "socket" then alpha = TILE_FAINT end
    if (self.painted[t] and self.painted[t].alpha) ~= alpha then self:PaintedAlpha(t, alpha) end
    if not t:IsShown() then t:Show() end
    self:SyncPainted(t)
    return true
end

local function diamondShape(self, state, button, on, bound, focused, index)
    if not isGamepadButton(button) then return false end
    state.diamondOn = state.diamondOn or setmetatable({}, { __mode = "k" })
    local entries = state.decorations[button]

    if not on and not state.diamondOn[button] then return false end
    if not entries then entries = {}; state.decorations[button] = entries end
    local authored = on and self:AuthoredSockets()
    if on and not entries.diamondMask then
        local ok = pcall(function()
            local mask = self:Own(button:CreateMaskTexture(nil, "BACKGROUND", nil, -1))
            mask:SetTexture(self.artPath .. "diamond-mask.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            inset(mask, button, DIAMOND_INSET)













            local glow = artTexture(self, button, "diamond-glow", "BACKGROUND", -3)
            inset(glow, button, -GLOW_SPILL)
            if type(glow.SetBlendMode) == "function" then glow:SetBlendMode("ADD") end
            self:Tint(glow, "hi", "vertex", 0.6)





            local shadow = artTexture(self, button, "diamond-shadow", "BACKGROUND", -2)
            inset(shadow, button, DIAMOND_INSET - 3)
            self:Tint(shadow, "shadow", "vertex", 0.55)
            local vignette = artTexture(self, button, "diamond-frame", "OVERLAY", 2)
            inset(vignette, button, DIAMOND_INSET)
            self:Tint(vignette, "lo", "vertex")
            entries.diamondMask, entries.diamondShadow, entries.diamondFrame = mask, shadow, vignette
            entries.diamondGlow = glow
        end)
        if not ok then return false end
    end
    local mask = entries.diamondMask
    if not mask then return false end
    if state.diamondOn[button] ~= on then
        for _, key in ipairs(DIAMOND_MASKED) do
            local region = button[key]
            if region and type(region.AddMaskTexture) == "function"
                and type(region.RemoveMaskTexture) == "function" then
                if on then
                    pcall(region.RemoveMaskTexture, region, button.CircleMask)
                    pcall(region.RemoveMaskTexture, region, button.SquareMask)
                    pcall(region.AddMaskTexture, region, mask)
                else


                    pcall(region.RemoveMaskTexture, region, mask)
                    pcall(region.AddMaskTexture, region, button.CircleMask)
                    pcall(region.AddMaskTexture, region, button.SquareMask)
                end
            end
        end






        state.diamondOn[button] = on
        state.count = state.count + 1
    end











    local want = authored and "authored" or "classic"


    local maskW = self:Number(button.GetWidth, 1, button) or 45
    if on and (mask.socketMode ~= want or mask.socketSlotW ~= maskW) then
        mask.socketMode, mask.socketSlotW = want, maskW
        mask:ClearAllPoints()
        inset(mask, button, authored and self:SocketInset(maskW) or DIAMOND_INSET)
    end



    local tiles = authored and self:CompassTilesOn()
    local shape = tiles and self:CompassIconShape() or "diamond"
    if on then
        local maskFile = self.artPath .. (shape == "square" and "minimap-mask" or "diamond-mask") .. ".tga"
        if mask:GetTexture() ~= maskFile then
            mask:SetTexture(maskFile, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        end
    end
    local socketOn = authored and not tiles
    if socketOn and not entries.socketArt then
        local ok = pcall(function()






            local art = self:PaintedTexture(button, "BACKGROUND", -3, self:CompassSlotSheet())
            art:SetPoint("CENTER", button, "CENTER", 0, 0)
            entries.socketArt = art
            entries.socketArtAcc = self:PaintedTwin(art)
        end)
        if not ok then socketOn = false end
    end
    local art = socketOn and entries.socketArt or nil
    if art then


        local sheet = self:CompassSlotSheet()
        if (self.painted[art] and self.painted[art].name) ~= sheet then self:SetPainted(art, sheet) end
        local size = self:SocketMetrics(button)
        if size and art.socketSize ~= size then
            art.socketSize = size
            art:SetSize(size, size)
        end












        local key = (focused and (bound == false and "focusEmpty" or "focus"))
            or (bound == false and "empty" or "bound")
        if art.socketState ~= key then
            art.socketState = key
            local c = SOCKET_STATES[key]
            art:SetTexCoord(c[1], c[2], c[3], c[4])
        end
        if not art:IsShown() then art:Show() end
        self:SyncPainted(art)
    elseif entries.socketArt and entries.socketArt:IsShown() then
        self:HidePainted(entries.socketArt)
    end


    if tiles then
        tileArt(self, entries, button, shape, bound, index)
    else
        for _, key in ipairs({ "tileBound", "tileEmpty" }) do
            if entries[key] and entries[key]:IsShown() then self:HidePainted(entries[key]) end
        end
    end



















    local decorate = on and bound ~= false and not authored
    for _, key in ipairs({ "diamondShadow", "diamondGlow" }) do
        local texture = entries[key]
        if texture and texture:IsShown() ~= decorate then
            if decorate then texture:Show() else texture:Hide() end
        end
    end
    local rim = entries.diamondFrame
    if rim then
        local rimOn = on and not authored
        if rim:IsShown() ~= rimOn then
            if rimOn then rim:Show() else rim:Hide() end
        end




        state.rimLit = state.rimLit or setmetatable({}, { __mode = "k" })
        if state.rimLit[button] ~= decorate then
            state.rimLit[button] = decorate
            local _, _, _, a = self:Color("lo")
            self:Tint(rim, "lo", "vertex", decorate and a or a * 0.34)
        end
    end
    return on
end















local function countPlinth(self, entries, button, on, bound)
    local count = button.Count
    if not count then return false end
    if on and not entries.countPlinth then
        local ok = pcall(function()
            local plinth = self:PaintedTexture(button, "OVERLAY", 4, "socket-plinth")
            plinth:SetPoint("CENTER", count, "CENTER", 0, 0)
            entries.countPlinth = plinth
            entries.countPlinthAcc = self:PaintedTwin(plinth)
        end)
        if not ok then return false end
    end
    local plinth = entries.countPlinth
    if not plinth then return false end



    local size = self:SocketPlinth(self:Number(button.GetWidth, 1, button) or 45)
    if plinth.plinthSize ~= size then
        plinth.plinthSize = size
        plinth:SetSize(size, size)
    end
    local text = on and bound ~= false and self:Text(count.GetText, 1, count) or nil
    local want = type(text) == "string" and text ~= "" and text ~= "1"
    if plinth:IsShown() ~= want then
        if want then plinth:Show() else plinth:Hide() end
    end
    self:SyncPainted(plinth)
    return want
end







function A:ObserveGamepadShapes()
    if type(hooksecurefunc) ~= "function" then return end
    self.layoutHooks = self.layoutHooks or {}
    for _, name in ipairs({ "GamepadActionBarButtonMixin", "GamepadActionBarStandardButtonMixin",
        "GamepadActionBarPetButtonMixin" }) do
        local mixin = _G[name]
        if type(mixin) == "table" then
            for _, method in ipairs({ "SetShapeToCircle", "SetShapeToSquare" }) do
                local id = name .. "." .. method
                if not self.layoutHooks[id] and type(mixin[method]) == "function" then
                    local ok = pcall(hooksecurefunc, mixin, method, function() A.nativeDirty = true end)
                    if ok then self.layoutHooks[id] = true end
                end
            end
        end
    end






    local mixin = _G.GamepadActionBarMixin
    if type(mixin) == "table" then
        for _, method in ipairs({ "ExpandActionButtons", "CollapseActionButtons" }) do
            local id = "GamepadActionBarMixin." .. method
            if not self.layoutHooks[id] and type(mixin[method]) == "function" then
                local ok = pcall(hooksecurefunc, mixin, method, function() A.nativeDirty = true end)
                if ok then self.layoutHooks[id] = true end
            end
        end
    end
end

local function actionButton(self, state, button, family, index, focused)
    if not button then return end
    local normal = type(button.GetNormalTexture) == "function" and button:GetNormalTexture() or nil
    hideRegion(self, state, normal)
    hideRegion(self, state, button.SlotArt)
    hideRegion(self, state, button.SlotBackground)





    hideRegion(self, state, button.SquareShadow)
    hideRegion(self, state, button.CircleShadow)
    if self:GetOption("iconCrop") then
        cropIcon(self, state, button.icon)
    else
        self:ReleaseProperty(state, button.icon, "texCoord")
    end








    local bound = true
    if type(button.HasAction) == "function" then
        local ok, result = pcall(button.HasAction, button)
        if ok and type(result) == "boolean" then bound = result end
    end
    if not self:GetOption("emptyRecede") then bound = true end





    local glyphOn = self:GetOption("actionGlyphs") == true and isGamepadButton(button)
    local ours = false
    if glyphOn or (state.decorations[button] and state.decorations[button].glyph) then
        local entries = state.decorations[button]
        if not entries then entries = {}; state.decorations[button] = entries end
        local slotFamily, slotIndex = glyphSlot(self, button, family, index)
        ours = inputGlyph(self, state, entries, button, slotFamily, slotIndex, glyphOn, bound)
    end
    showIf(self, state, button.ButtonIcon, bound and not ours)





    local _, tileIndex = glyphSlot(self, button, family, index)
    local diamond = diamondShape(self, state, button, self:GetOption("actionDiamond") == true, bound, focused,
        tileIndex)







    local keyboard = type(self.KeyboardSlotOn) == "function" and self:KeyboardSlotOn(button)









    if diamond then
        hideRegion(self, state, button.Border)
    elseif not keyboard then




        self:ReleaseProperty(state, button.Border, "alpha")
    end






    if button.Count and type(self.NativeFont) == "function" then
        local ds = (self.LayoutMetrics and self:LayoutMetrics().dockScale) or 1
        pcall(self.NativeFont, self, state, button.Count, self:PixelSize("caption", ds), false, true)
    end




    if self:AuthoredSockets() or (state.decorations[button] and state.decorations[button].countPlinth) then
        local entries = state.decorations[button]
        if not entries then entries = {}; state.decorations[button] = entries end
        countPlinth(self, entries, button, self:AuthoredSockets(), bound)
    end



    if bound and not diamond and not keyboard then
        edgeBorder(self, state, button, 1)

        if button.icon then self:IconFrame(state.decorations[button], button, button.icon) end
    else
        local entries = state.decorations[button]
        if entries then
            for _, key in ipairs({ "border", "borderBottom", "borderLeft", "borderRight", "iconframe" }) do
                if entries[key] then entries[key]:Hide() end
            end
        end
    end
end

local function walk(root, callback)
    if not root then return end
    local visited, count = {}, 0
    local function visit(frame, depth)
        if not frame or visited[frame] or depth > 6 or count >= 2048 then return end
        if A:IsOwn(frame) then return end
        visited[frame] = true
        count = count + 1
        callback(frame)
        if type(frame.GetChildren) == "function" then
            for _, child in ipairs({ frame:GetChildren() }) do visit(child, depth + 1) end
        end
    end
    visit(root, 0)
end








local function tintChrome(self, state, root)
    walk(root, function(frame)
        if type(frame.GetRegions) ~= "function" then return end
        for _, region in ipairs({ frame:GetRegions() }) do
            if type(region.IsObjectType) == "function" and region:IsObjectType("Texture") then
                tint(self, state, region)
            end
        end
    end)
end

local handlers = {}
A.NativeWalk, A.NativeBorder, A.NativeFill, A.NativeTint, A.NativeTintChrome = walk, edgeBorder, flatFill, tint, tintChrome
A.NativeGlassPanel, A.NativeTextChip, A.NativeStrip, A.NativeStripOwn =
    glassPanel, textChip, stripRegions, stripOwnTextures
A.NativeVeilPanel = veilPanel
A.NativeFadePanel, A.NativeRule = fadePanel, edgeRule



function A:CompassReport(emit)
    local bars = path(GamepadMainActionBarFrame, "PageUnit", "actionBars")
    local bar = type(bars) == "table" and bars.topBar or nil
    if not bar then
        emit("compass: no gamepad action bar found")
        return
    end
    emit(string.format("compass: diamonds %s | glyphs %s",
        tostring(self:GetOption("actionDiamond")), tostring(self:GetOption("actionGlyphs"))))
    for _, group in ipairs({ "Left", "Right" }) do
        for i = 1, 4 do
            local button = path(bar, group, "ActionButton" .. i)
            if button then
                local shown = {}
                for _, key in ipairs({ "Border", "SpellHighlightTexture", "SquareShadow", "CircleShadow",
                    "SlotBackground", "SlotArt", "PermaboundOverlay", "HighlightTexture" }) do
                    local region = button[key]
                    if region and type(region.IsShown) == "function" then
                        local ok, isShown = pcall(region.IsShown, region)
                        if ok and isShown then shown[#shown + 1] = key end
                    end
                end
                local masked = button.CircleMask ~= nil and button.SquareMask ~= nil
                emit(string.format("  %s%d: gamepad=%s square art shown: %s", group, i,
                    tostring(masked), #shown > 0 and table.concat(shown, ",") or "none"))
            end
        end
    end
end














local function barFocus(self, state, bar, authored)
    local bg = bar and bar.BackgroundFocus
    if not bg or type(bg.IsShown) ~= "function" then return false end
    if authored then hideRegion(self, state, bg) else self:ReleaseProperty(state, bg, "alpha") end
    return self:Read(bg.IsShown, 1, bg) == true
end

function handlers.actions(self, state)
    local bars = path(GamepadMainActionBarFrame, "PageUnit", "actionBars")
    if type(bars) == "table" then
        local authored = self:AuthoredSockets()
        for _, key in ipairs({ "topBar", "leftBar", "rightBar", "bottomBar", "possessBar",
            "stanceBar", "friendlyTargetingBar", "hostileTargetingBar", "shortcutsBar" }) do
            local bar = bars[key]
            if bar then
                local focused = barFocus(self, state, bar, authored) and authored





                for i = 1, 4 do
                    actionButton(self, state, path(bar, "Left", "ActionButton" .. i), "dir", i, focused)
                    actionButton(self, state, path(bar, "Right", "ActionButton" .. i), "face", i, focused)
                end
            end
        end
    end
    for _, prefix in ipairs({ "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
        "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button",
        "PetActionButton", "StanceButton" }) do
        for i = 1, 12 do actionButton(self, state, _G[prefix .. i]) end
    end





    if self.ApplyKeyboardBars then self:ApplyKeyboardBars(state) end
    for _, name in ipairs({ "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer" }) do
        walk(_G[name], function(frame)

            if frame.Icon and type(frame.Icon.SetTexture) == "function" then
                edgeBorder(self, state, frame, 1, 0, frame.Icon)
            end
        end)
    end
end




function handlers.units(self, state)
end

function handlers.party(self, state)
    for _, name in ipairs({ "PartyFrame", "CompactPartyFrame", "CompactRaidFrameContainer" }) do
        walk(_G[name], function(frame)
            local health = frame.healthBar or frame.HealthBar or path(frame, "HealthBarContainer", "HealthBar")
            if health then










                tint(self, state, frame.Texture)

            end
        end)
    end
end

function handlers.auras(self, state)
    for _, name in ipairs({ "BuffFrame", "DebuffFrame", "ExternalDefensivesFrame" }) do
        local frames = path(_G[name], "auraFrames")
        if type(frames) == "table" then
            for _, frame in ipairs(frames) do
                if frame.Icon and type(frame.Icon.SetTexture) == "function" then

                    edgeBorder(self, state, frame, 2, 2, frame.Icon, "BACKGROUND")
                    self:IconFrame(state.decorations[frame], frame, frame.Icon)




                    cropIcon(self, state, frame.Icon)
                end
            end
        end
    end
end











local NATIVE_MASK = "ui-hud-minimap-frame-generic-mask"
function A:SquareMinimap(state, map)
    if not map or type(map.SetMaskTexture) ~= "function" then return end
    if not self:CanWrite("mask", map) then return end
    self.maskWanted = true
    if not self.maskHook and type(hooksecurefunc) == "function" then
        local ok = pcall(hooksecurefunc, map, "SetMaskTexture", function()
            if A.maskWanted and not A.settingMask then
                A.maskApplied = false
                if A:IsCombat() then A.nativeDirty = true else A:ApplyMask(map) end
            end
        end)
        if ok then self.maskHook = true end
    end
    self:RememberProperty(state, map, "mask", function()
        return function()
            A.maskWanted = false
            A.settingMask = true
            pcall(map.SetMaskTexture, map, NATIVE_MASK)
            A.settingMask = nil
            A.maskApplied = false
        end
    end)
    if not self.maskApplied then self:ApplyMask(map) end
    state.count = state.count + 1
end

function A:ApplyMask(map)
    if not self:CanWrite("mask", map) then return end
    self:Trace("mask", map, "apply")
    self.settingMask = true
    local ok = pcall(map.SetMaskTexture, map, self.artPath .. "minimap-mask.tga")
    self.settingMask = nil
    self.maskApplied = ok
end





function handlers.minimap(self, state)



    tintChrome(self, state, path(MinimapCluster, "Tracking"))
    tintChrome(self, state, path(MinimapCluster, "InstanceDifficulty"))


    tintChrome(self, state, GameTimeFrame)
end

function handlers.objectives(self, state)


















    local body = path(ObjectiveTrackerFrame, "NineSlice")



    local style = self:TrackerStyle()
    if body then
        local sp = self.tokens.space
        local alpha = self:SurfaceValue(self:GetOption("trackerAlpha"))
        if style == "boxed" then
            fadePanel(self, state, ObjectiveTrackerFrame, "body", ObjectiveTrackerFrame, -60, sp.sm,
                body, -5, -sp.sm, alpha, true)
        else
            self:ChromeHide(state, ObjectiveTrackerFrame, "body")
        end
        if style == "tidy" then
            self:ChromeSoftPanel(state, ObjectiveTrackerFrame, "soft", ObjectiveTrackerFrame, -60, sp.sm * 3,
                body, -5, -sp.sm * 3, alpha, true)
        else
            self:ChromeHide(state, ObjectiveTrackerFrame, "soft")
        end
        local fill = state.decorations[ObjectiveTrackerFrame]
            and (state.decorations[ObjectiveTrackerFrame].body or state.decorations[ObjectiveTrackerFrame].soft)
        edgeRule(self, state, ObjectiveTrackerFrame, "bodyRule", fill, "RIGHT", 0)
    end
    if style == "boxed" then
        flatFill(self, state, path(ObjectiveTrackerFrame, "Header"), self:Surface("base"), true)
    else
        self:ChromeHide(state, path(ObjectiveTrackerFrame, "Header"), "panel")
    end






    local header = path(ObjectiveTrackerFrame, "Header")


    if header and not state.decorations[header] and type(header.CreateTexture) == "function" then
        state.decorations[header] = {}
    end
    local entries = header and state.decorations[header]
    if entries then
        if not entries.headFoot then
            entries.headFoot = self:Own(header:CreateTexture(nil, "BORDER", nil, 2))
            entries.headCut = self:Own(header:CreateTexture(nil, "BORDER", nil, 3))
            entries.headCut:SetTexture(self.artPath .. "bar-chamfer.tga", "CLAMP", "CLAMP")
            entries.headCut:SetTexCoord(1, 0, 1, 0)
        end
        local on = self:GetOption("chromeSkin") == "authored" and self:GetOption("chromeTrackerHead")
        local foot, cut = entries.headFoot, entries.headCut




        local tidy = style ~= "boxed"
        local title = header.Text
        local titleW = tidy and title and self:Number(title.GetStringWidth, 1, title) or nil


        state.headSignature = state.headSignature or setmetatable({}, { __mode = "k" })
        local signature = on and string.format("%.4f|%.1f|%s|%s|%.1f", self:PhysicalPixel(header),
            self:Number(header.GetHeight, 1, header) or 26, self:Scheme().id, tostring(tidy), titleW or 0) or "off"
        if state.headSignature[header] ~= signature and on and tidy and title and titleW and titleW > 0 then
            foot:ClearAllPoints()
            foot:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
            foot:SetWidth(titleW)
            foot:SetHeight(self:PhysicalPixel(header))
            self:Tint(foot, "accent", "color", 0.85)
        elseif state.headSignature[header] ~= signature and on then
            foot:ClearAllPoints()
            foot:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
            foot:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
            foot:SetHeight(self:PhysicalPixel(header))
            self:Tint(foot, "accent", "color", 0.45)
            local size = math.max(6, math.floor((self:Number(header.GetHeight, 1, header) or 26) * 0.3))
            cut:ClearAllPoints()
            cut:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
            cut:SetSize(size, size)
            self:Tint(cut, "ink", "vertex", 0.92)
        end
        state.headSignature[header] = signature
        if foot:IsShown() ~= (on and true or false) then foot:SetShown(on and true or false) end
        local cutOn = on and not tidy and true or false
        if cut:IsShown() ~= cutOn then cut:SetShown(cutOn) end
        state.count = state.count + 1
    end
    for _, name in ipairs({ "QuestObjectiveTracker", "CampaignQuestObjectiveTracker",
        "ScenarioObjectiveTracker", "AchievementObjectiveTracker", "BonusObjectiveTracker",
        "WorldQuestObjectiveTracker" }) do
        if style == "boxed" then
            flatFill(self, state, path(_G[name], "Header"), self:Surface("base"), true)
        else
            self:ChromeHide(state, path(_G[name], "Header"), "panel")
        end
    end
end

function handlers.chat(self, state)
    for i = 1, 10 do











        local frame = _G["ChatFrame" .. i]
        if frame then



            local style = self:ChatStyle()
            local alpha = self:SurfaceValue(self:GetOption("chatAlpha"))
            local sm = self.tokens.space.sm
            if style == "boxed" then
                fadePanel(self, state, frame, "fade", frame, -sm, sm, frame, 0, -sm, alpha, false)
            else
                self:ChromeHide(state, frame, "fade")
            end
            if style == "tidy" then
                self:ChromeSoftPanel(state, frame, "soft", frame, -sm, sm * 3, frame, sm * 4, -sm * 3, alpha, false)
            else
                self:ChromeHide(state, frame, "soft")
            end
        end
    end
end




function handlers.tooltips(self, state)
end

function A:LoadNativeSettings()
    if type(self.db.skins) ~= "table" then self.db.skins = {} end
    for _, module in ipairs(self.skinModules) do
        if type(self.db.skins[module.key]) ~= "boolean" then self.db.skins[module.key] = true end
    end
end

function A:RestoreNativeModule(state)
    local ok = true
    for object, properties in pairs(state.properties or {}) do
        for key, restore in pairs(properties) do


            if self:FamilyGeometry(object, key) then properties[key] = nil
            elseif pcall(restore) then properties[key] = nil else ok = false end
        end
        if next(properties) == nil then state.properties[object] = nil end
    end
    for object, record in pairs(state.changes) do
        if pcall(record.restore) then state.changes[object] = nil else ok = false end
    end
    for _, entries in pairs(state.decorations) do
        for _, texture in pairs(entries) do
            if not pcall(texture.Hide, texture) then ok = false end
        end
    end


    state.rimSignature, state.headSignature = nil, nil
    if not ok and not state.restoreWarned then
        state.restoreWarned = true
        self:Print("A native skin could not fully restore. Use /reload to restore the client's own visuals.")
    end
    state.restoreFailed = not ok
    return ok
end

function A:RefreshNativeUI()
    if not self.db then return end
    if self:IsCombat() then self.nativeDirty = true; return end
    self.nativeDirty = nil



    self:SyncDock()
    self:RefreshTheme()
    for _, module in ipairs(self.skinModules) do
        local key = module.key
        local state = stateFor(self, key)
        if not self.auditedSink or not self.db.skins[key] or state.failed then
            local restored = self:RestoreNativeModule(state)
            self:Note("skin " .. key, not restored and "restore rejected: reload required"
                or (state.failed and ("rejected: native fallback until reload (" .. tostring(state.lastError or "no detail") .. ")")
                or (not self.auditedSink and "unmatched build: native presentation" or "off")))
        else
            state.count = 0
            local ok, err = pcall(function()
                handlers[key](self, state)
                self:StyleNativeModule(key, state)
            end)
            if not ok then
                state.failed = true




                state.lastError = tostring(err or "unknown"):gsub("%s+", " "):sub(1, 220)
                local restored = self:RestoreNativeModule(state)
                self:Note("skin " .. key, restored and ("rejected: native fallback until reload (" .. state.lastError .. ")")
                    or "restore rejected: reload required")
            else
                self:Note("skin " .. key, state.count > 0 and (state.count .. " cosmetic elements styled")
                    or "native frames unavailable or unsupported")
            end
        end
    end
    self:RefreshNativeSettingsLabels()
    self:RefreshLayout()

    if self.ApplyElementAlphas then pcall(self.ApplyElementAlphas, self) end

    self:SweepGlazes()
end

function A:SetSkinEnabled(key, enabled)
    if key ~= "all" and handlers[key] == nil then return end
    for _, module in ipairs(self.skinModules) do
        if key == "all" or key == module.key then self.db.skins[module.key] = enabled end
    end
    self:Changed()
    self:RefreshNativeSettingsLabels()
end

function A:ObserveNativePresentation()
    if self.nativeCallbacksAttempted or not EventRegistry or type(EventRegistry.RegisterCallback) ~= "function" then return end
    self.nativeCallbacksAttempted = true
    local ok = pcall(function()
        for _, event in ipairs({ "Tooltip.OnShown" }) do
            EventRegistry:RegisterCallback(event, function() A.nativeDirty = true end, self)
        end



        EventRegistry:RegisterCallback("EditMode.Enter", function()
            A.editModeActive = true
            A.pendingRestore = true
        end, self)
        EventRegistry:RegisterCallback("EditMode.Exit", function()
            A.editModeActive = false
            A.layoutDirty = true
            A.nativeDirty = true
        end, self)
    end)
    self:Note("native presentation events", ok and "registered" or "unavailable; event fallback")
end




function A:InspectNativeFrames()
    local report = {}
    local function line(text)
        self:Print(text)
        report[#report + 1] = text
    end
    local function names(list)
        if #list == 0 then return "(none)" end
        table.sort(list)
        return table.concat(list, ", ")
    end





    do
        local ok = type(self.XpProbe) == "function" and pcall(self.XpProbe, self, function() end)
        report[#report + 1] = "xpprobe (every input mode probed this session):"
        if not ok then report[#report + 1] = "  xpprobe: failed in this mode" end
        local modes = {}
        for mode in pairs(self.xpProbeByMode or {}) do modes[#modes + 1] = mode end
        table.sort(modes)
        for _, mode in ipairs(modes) do
            report[#report + 1] = "  [" .. mode .. "]"
            for _, text in ipairs(self.xpProbeByMode[mode]) do report[#report + 1] = "  " .. text end
        end
        if #modes < 2 then
            report[#report + 1] = "  (only one input mode so far: switch modes, /aui inspect again, then /reload)"
        end
        self:Print("inspect: xpprobe saved for " .. (#modes > 0 and table.concat(modes, " + ") or "no mode")
            .. (#modes < 2 and " (switch input mode and /aui inspect again for the other)" or ""))
    end



    if type(self.PadProbeLines) == "function" then
        local ok, probe = pcall(self.PadProbeLines, self)
        if ok and type(probe) == "table" then
            for _, text in ipairs(probe) do report[#report + 1] = text end
        end
    end


    line("-- inspect: measure --")
    self:MeasureReport(line)

    line("-- inspect: actions --")
    local bars = path(GamepadMainActionBarFrame, "PageUnit", "actionBars")
    if type(bars) == "table" then
        local keys = {}
        for key in pairs(bars) do keys[#keys + 1] = tostring(key) end
        line("PageUnit.actionBars keys: " .. names(keys))
        for key, bar in pairs(bars) do
            local left = type(bar) == "table" and bar.Left
            local right = type(bar) == "table" and bar.Right
            line(string.format("  %s: Left=%s Right=%s", tostring(key),
                left and "present" or "nil", right and "present" or "nil"))
        end
    else
        line("GamepadMainActionBarFrame.PageUnit.actionBars: " .. type(bars)
            .. " (GamepadMainActionBarFrame " .. (GamepadMainActionBarFrame and "exists" or "nil") .. ")")
    end
    if GamepadMainActionBarFrame and type(GamepadMainActionBarFrame.GetChildren) == "function" then
        local children = {}
        for _, child in ipairs({ GamepadMainActionBarFrame:GetChildren() }) do
            children[#children + 1] = (type(child.GetName) == "function" and child:GetName()) or "(unnamed)"
        end
        line("GamepadMainActionBarFrame children: " .. names(children))
    end
    local foundLegacy, shownLegacy, styledLegacy = 0, 0, {}
    for _, prefix in ipairs({ "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
        "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button",
        "PetActionButton", "StanceButton" }) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button then
                foundLegacy = foundLegacy + 1
                if type(button.IsShown) == "function" and button:IsShown() then
                    shownLegacy = shownLegacy + 1
                    styledLegacy[#styledLegacy + 1] = prefix .. i
                end
            end
        end
    end
    line(string.format("legacy ActionButton-style globals: found=%d shown=%d (%s)",
        foundLegacy, shownLegacy, names(styledLegacy)))

    line("-- inspect: minimap / objectives / tooltips --")
    line("MinimapCluster: " .. (MinimapCluster and "present" or "nil")
        .. " | ObjectiveTrackerFrame: " .. (ObjectiveTrackerFrame and "present" or "nil"))
    local tooltip = GameTooltip
    if tooltip then
        line(string.format("GameTooltip GetBackdropColor=%s SetBackdropColor=%s NineSlice=%s",
            type(tooltip.GetBackdropColor), type(tooltip.SetBackdropColor),
            tooltip.NineSlice and "present" or "nil"))
    else
        line("GameTooltip: nil")
    end

    line("-- inspect: confirmed ground truth from prior round-trips --")



    line("  GamepadPersistentInputLegend: " .. (GamepadPersistentInputLegend and "present" or "nil"))
    line("  PlayerLevelText: " .. (PlayerLevelText and ("present, shown=" .. tostring(PlayerLevelText:IsShown())) or "nil"))
    line("  MinimapCluster.InstanceDifficulty: " .. (path(MinimapCluster, "InstanceDifficulty") and "present" or "nil"))







    if GamepadPersistentInputLegend then
        line("-- inspect: GamepadPersistentInputLegend structure --")
        if type(GamepadPersistentInputLegend.GetChildren) == "function" then
            local children = {}
            for _, child in ipairs({ GamepadPersistentInputLegend:GetChildren() }) do
                children[#children + 1] = (type(child.GetName) == "function" and child:GetName()) or "(unnamed)"
            end
            line("  children: " .. names(children))
        end
        if type(GamepadPersistentInputLegend.GetRegions) == "function" then
            local regions = {}
            for _, region in ipairs({ GamepadPersistentInputLegend:GetRegions() }) do
                local kind = type(region.IsObjectType) == "function" and "Texture" or "region"
                local atlas = type(region.GetAtlas) == "function" and self:Text(region.GetAtlas, 1, region)
                regions[#regions + 1] = kind .. (atlas and (":" .. atlas) or "")
            end
            line("  own regions: " .. names(regions))
        end
    end

    line("-- inspect: top-left screen region scan (structural, not name-guessed) --")
    if UIParent and type(UIParent.GetChildren) == "function" then
        local screenHeight = self:Number(UIParent.GetHeight, 1, UIParent) or 1080
        local found = {}
        for _, child in ipairs({ UIParent:GetChildren() }) do
            if type(child.IsShown) == "function" and type(child.GetLeft) == "function"
                and type(child.GetTop) == "function" then
                local ok, shown = pcall(child.IsShown, child)
                if ok and shown then
                    local left = self:Number(child.GetLeft, 1, child)
                    local top = self:Number(child.GetTop, 1, child)


                    if left and top and left < 340 and top > screenHeight - 160 then
                        local objName = (type(child.GetName) == "function" and child:GetName()) or "(unnamed)"
                        found[#found + 1] = string.format("%s [left=%.0f top=%.0f]", objName, left, top)
                    end
                end
            end
        end
        line("  UIParent children shown in that corner: " .. names(found))
    else
        line("  UIParent:GetChildren unavailable")
    end







    local function safe(fn, ...)
        local ok, value = pcall(fn, ...)
        if ok and self:IsPublic(value) then return value end
        return nil
    end
    local function num(value) return type(value) == "number" and string.format("%.0f", value) or "?" end
    local function describeRegion(region)
        local kind = safe(region.GetObjectType, region) or "region"
        local atlas = type(region.GetAtlas) == "function" and safe(region.GetAtlas, region) or nil
        local texture = type(region.GetTexture) == "function" and safe(region.GetTexture, region) or nil
        local width = type(region.GetWidth) == "function" and safe(region.GetWidth, region) or nil
        local height = type(region.GetHeight) == "function" and safe(region.GetHeight, region) or nil
        local shown = type(region.IsShown) == "function" and safe(region.IsShown, region)
        local alphaNow = type(region.GetAlpha) == "function" and safe(region.GetAlpha, region) or nil
        return string.format("%s atlas=%s tex=%s %sx%s shown=%s alpha=%s", tostring(kind), tostring(atlas),
            type(texture) == "string" and texture or tostring(texture), num(width), num(height),
            tostring(shown), alphaNow and string.format("%.2f", alphaNow) or "?")
    end
    local function dump(label, frame, maxChildren)
        if not frame then line("  " .. label .. ": nil"); return end
        line(string.format("  %s: %s %sx%s shown=%s", label, tostring(safe(frame.GetObjectType, frame) or "?"),
            num(safe(frame.GetWidth, frame)), num(safe(frame.GetHeight, frame)),
            tostring(type(frame.IsShown) == "function" and safe(frame.IsShown, frame))))
        if type(frame.GetRegions) == "function" then
            for i, region in ipairs({ frame:GetRegions() }) do
                if i > 24 then line("    ... more regions"); break end
                line("    region[" .. i .. "] " .. describeRegion(region))
            end
        end
        if type(frame.GetChildren) == "function" then
            for i, child in ipairs({ frame:GetChildren() }) do
                if i > (maxChildren or 16) then line("    ... more children"); break end
                local regionCount = type(child.GetNumRegions) == "function" and safe(child.GetNumRegions, child) or "?"
                line(string.format("    child[%d] %s (%s) %sx%s shown=%s regions=%s", i,
                    (type(child.GetName) == "function" and child:GetName()) or "(unnamed)",
                    tostring(safe(child.GetObjectType, child) or "?"), num(safe(child.GetWidth, child)),
                    num(safe(child.GetHeight, child)),
                    tostring(type(child.IsShown) == "function" and safe(child.IsShown, child)), tostring(regionCount)))
            end
        end
    end




    line("-- inspect: minimap text / clock / calendar (pass 7) --")
    local function anchorsOf(frame)
        local out = {}
        local n = type(frame.GetNumPoints) == "function" and safe(frame.GetNumPoints, frame) or 0
        if type(n) ~= "number" then n = 0 end
        for i = 1, math.min(n, 4) do
            local ok, p, rel, rp, x, y = pcall(frame.GetPoint, frame, i)
            if ok and self:IsPublic(p) and self:IsPublic(x) and self:IsPublic(y) then
                out[#out + 1] = string.format("%s>%s:%s %s,%s", tostring(p), tostring(self:ObjectName(rel) or "?"),
                    tostring(rp), num(x), num(y))
            end
        end
        return #out > 0 and table.concat(out, " | ") or "none"
    end
    for _, entry in ipairs({
        { "MinimapZoneText", MinimapZoneText },
        { "MinimapCluster.ZoneTextButton", path(MinimapCluster, "ZoneTextButton") },
        { "MinimapCluster.BorderTop", path(MinimapCluster, "BorderTop") },
        { "MinimapCluster.Tracking", path(MinimapCluster, "Tracking") },
        { "TimeManagerClockButton", _G.TimeManagerClockButton },
        { "TimeManagerClockTicker", _G.TimeManagerClockTicker },
        { "GameTimeFrame", _G.GameTimeFrame },
        { "MinimapContainer.PlayerCoords", path(MinimapCluster, "MinimapContainer", "PlayerCoords") },
        { "PlayerCoords.CoordText", path(MinimapCluster, "MinimapContainer", "PlayerCoords", "CoordText") },
    }) do
        local label, frame = entry[1], entry[2]
        if type(frame) ~= "table" then
            line("  " .. label .. ": nil")
        else
            local parent = type(frame.GetParent) == "function" and select(2, pcall(frame.GetParent, frame)) or nil
            local fontSize = "-"
            if type(frame.GetFont) == "function" then
                local ok, _, size = pcall(frame.GetFont, frame)
                if ok and self:IsPublic(size) then fontSize = num(size) end
            end
            line(string.format("  %s: %s parent=%s %sx%s shown=%s font=%s at %s", label,
                tostring(safe(frame.GetObjectType, frame) or "?"), tostring(self:ObjectName(parent) or "?"),
                num(safe(frame.GetWidth, frame)), num(safe(frame.GetHeight, frame)),
                tostring(type(frame.IsShown) == "function" and safe(frame.IsShown, frame)), fontSize, anchorsOf(frame)))
        end
    end
    line("-- inspect: dumps for the next redesign pass --")
    dump("MinimapCluster", MinimapCluster, 24)




    if MinimapCluster and type(MinimapCluster.GetChildren) == "function" then
        line("-- inspect: minimap cluster children, keys / anchors / art (0.57.6) --")
        local keyOf = {}
        pcall(function()
            for key, value in pairs(MinimapCluster) do
                if type(key) == "string" and type(value) == "table" then keyOf[value] = key end
            end
        end)
        for i, child in ipairs({ MinimapCluster:GetChildren() }) do
            if i > 24 then line("  ... more children"); break end
            if type(child.IsShown) == "function" and safe(child.IsShown, child) then
                local art = {}
                if type(child.GetRegions) == "function" then
                    for j, region in ipairs({ child:GetRegions() }) do
                        if j > 3 then break end
                        local atlas = type(region.GetAtlas) == "function" and safe(region.GetAtlas, region) or nil
                        local texture = type(region.GetTexture) == "function" and safe(region.GetTexture, region) or nil
                        art[#art + 1] = tostring(atlas or texture)
                    end
                end
                line(string.format("  child[%d] key=%s name=%s %sx%s at %s art=%s", i, tostring(keyOf[child] or "?"),
                    tostring((type(child.GetName) == "function" and child:GetName()) or "-"),
                    num(safe(child.GetWidth, child)), num(safe(child.GetHeight, child)), anchorsOf(child),
                    #art > 0 and table.concat(art, ",") or "-"))
            end
        end
    end
    dump("MinimapCluster.BorderTop", path(MinimapCluster, "BorderTop"), 8)
    dump("MinimapBackdrop", MinimapBackdrop, 12)
    dump("MinimapContainer.PlayerCoords", path(MinimapCluster, "MinimapContainer", "PlayerCoords"), 4)
    dump("GameTimeFrame", GameTimeFrame, 6)
    dump("ChatFrame1Tab", ChatFrame1Tab, 6)
    dump("PlayerFrameContentMain", path(PlayerFrame, "PlayerFrameContent", "PlayerFrameContentMain"), 10)
    dump("PlayerFrameContentContextual", path(PlayerFrame, "PlayerFrameContent", "PlayerFrameContentContextual"), 10)
    dump("TargetFrameContentMain", path(TargetFrame, "TargetFrameContent", "TargetFrameContentMain"), 10)
    dump("TargetFrameContentContextual", path(TargetFrame, "TargetFrameContent", "TargetFrameContentContextual"), 10)
    dump("GamepadPersistentInputLegend (rows)", GamepadPersistentInputLegend, 60)

    for _, name in ipairs({ "StatusTrackingBarManager", "MainStatusTrackingBarContainer",
        "SecondaryStatusTrackingBarContainer", "MainMenuBar", "MicroButtonAndBagsBar" }) do
        dump(name, _G[name], 12)
    end


    local function scan(title, predicate)
        line("-- inspect: scan " .. title .. " --")
        local found = {}
        if UIParent and type(UIParent.GetChildren) == "function" then
            for _, child in ipairs({ UIParent:GetChildren() }) do
                if type(child.IsShown) == "function" and safe(child.IsShown, child) then
                    local left = type(child.GetLeft) == "function" and safe(child.GetLeft, child) or nil
                    local right = type(child.GetRight) == "function" and safe(child.GetRight, child) or nil
                    local top = type(child.GetTop) == "function" and safe(child.GetTop, child) or nil
                    local bottom = type(child.GetBottom) == "function" and safe(child.GetBottom, child) or nil
                    if predicate(left, right, top, bottom) then
                        found[#found + 1] = string.format("%s [l=%s r=%s t=%s b=%s]",
                            (type(child.GetName) == "function" and child:GetName()) or "(unnamed)",
                            num(left), num(right), num(top), num(bottom))
                    end
                end
            end
        end
        line("  " .. names(found))
    end
    local screenWidth = self:Number(UIParent.GetWidth, 1, UIParent) or 1920
    local screenHeight = self:Number(UIParent.GetHeight, 1, UIParent) or 1080
    scan("top-right corner", function(l, r, t, b) return r and t and r > screenWidth - 60 and t > screenHeight - 60 end)
    scan("bottom edge", function(l, r, t, b) return b and t and b < 40 and t < 120 end)


    scan("hero band (centre, 120-520px up)", function(l, r, t, b)
        return l and r and t and b and r > screenWidth / 2 - 480 and l < screenWidth / 2 + 480
            and t < 520 and b > 120 and (r - l) < 400
    end)
    do
        local tracker = ObjectiveTrackerFrame
        if tracker then
            line(string.format("ObjectiveTrackerFrame geometry: left=%s right=%s top=%s w=%s screenW=%s",
                num(safe(tracker.GetLeft, tracker)), num(safe(tracker.GetRight, tracker)),
                num(safe(tracker.GetTop, tracker)), num(safe(tracker.GetWidth, tracker)), num(screenWidth)))
        end
        local main = path(TargetFrame, "TargetFrameContent", "TargetFrameContentMain")
        if main then
            for _, key in ipairs({ "Name", "LevelText", "ReputationColor" }) do
                local r = main[key]
                if r and type(r.GetNumPoints) == "function" then
                    local count = safe(r.GetNumPoints, r)
                    local parts = {}
                    for i = 1, (type(count) == "number" and count or 0) do
                        local p = { r:GetPoint(i) }
                        parts[#parts + 1] = string.format("%s>%s:%s(%s,%s)", tostring(p[1]),
                            (p[2] and type(p[2].GetName) == "function" and p[2]:GetName()) or "?", tostring(p[3]),
                            num(p[4]), num(p[5]))
                    end
                    line("  target " .. key .. " points: " .. names(parts))
                end
            end
        end
    end

    pcall(self.CameraReport, self, line)







    line("-- inspect: compass (`/aui measure compass` prints the same thing) --")
    do
        local budget = 40
        pcall(self.MeasureCompass, self, function(text)
            if budget > 0 then budget = budget - 1; line(text)
            elseif budget == 0 then budget = -1; line("  ... (bounded: compass output truncated)") end
        end)
    end
    line("-- inspect: write safety (blocked-action log, quarantine, protection of every frame we write) --")
    self:ReportBlocked(line, true)
    self:InfoReport(line)
    self:InspectDamageMeter(line)







    if self.KeyboardReport then pcall(self.KeyboardReport, self, line) end
    if self.UnitClickReport then pcall(self.UnitClickReport, self, line) end





    if self.MeasureEffects then pcall(self.MeasureEffects, self, line) end
    for _, name in ipairs({ "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame", "PartyFrame", "CompactPartyFrame", "GamepadMainActionBarFrame", "MinimapCluster",
        "Minimap", "ObjectiveTrackerFrame", "ChatFrame1", "PlayerCastingBarFrame", "GamepadPlayerCastingBarFrame", "GameTooltipDefaultContainer",
        "SharedTooltipDefaultContainer", "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight" }) do
        local frame = _G[name]
        if frame then
            local ok1, protected = pcall(function() return frame:IsProtected() end)
            local ok2, forbidden = pcall(function() return frame:IsForbidden() end)
            line(string.format("  %s protected=%s forbidden=%s", name, ok1 and tostring(protected) or "?", ok2 and tostring(forbidden) or "?"))
        end
    end
    do
        local parts = {}
        for _, t in ipairs(self.trace or {}) do
            parts[#parts + 1] = self:EntryKey(t) .. (t.detail and ("(" .. tostring(t.detail) .. (t.count and (" x" .. t.count) or "") .. ")") or "")
        end
        line("  last native operations: " .. (#parts > 0 and table.concat(parts, " > ") or "none"))
        local st = self.reassertStats
        line(string.format("  hold reasserts (Blizzard rewrote a held alpha): total=%d peak/s=%d",
            st and st.total or 0, st and st.peak or 0))
    end






    self.db.inspectReport = table.concat(report, "\n")
    self.db.inspectVersion = self.version
    self.inspectText = self.db.inspectReport
    self:StoreInspectReport(self.db.inspectReport)
    self:Print("Inspect saved to SavedVariables. /reload (or /logout), then it is readable from")
    self:Print("WTF/Account/<account>/SavedVariables/AdaptiveUI.lua as AdaptiveUIInspectDB.lines (in the character folder).")
end





function A:InspectDamageMeter(line)
    line("-- inspect: DamageMeter (native meter) --")
    local budget = 170
    local function emit(text)
        if budget > 0 then budget = budget - 1; line(text) end
        if budget == 0 then budget = -1; line("  ... (bounded: output truncated)") end
    end
    local function num(value) return (self:IsPublic(value) and type(value) == "number") and string.format("%.0f", value) or "?" end
    local function call(object, method, ...)
        if type(object) ~= "table" or type(object[method]) ~= "function" then return nil end
        local ok, a, b = pcall(object[method], object, ...)
        if ok and self:IsPublic(a) then return a, b end
        return nil
    end
    local function alpha(object)
        local a = call(object, "GetAlpha")
        return a and string.format("%.2f", a) or "?"
    end
    local function describe(frame, indent)
        local name = call(frame, "GetName") or "(unnamed)"
        local kind = call(frame, "GetObjectType") or "?"
        emit(string.format("%s%s (%s) %sx%s shown=%s alpha=%s regions=%s children=%s", indent, tostring(name), tostring(kind),
            num(call(frame, "GetWidth")), num(call(frame, "GetHeight")), tostring(call(frame, "IsShown")), alpha(frame),
            tostring(call(frame, "GetNumRegions") or "?"), tostring(call(frame, "GetNumChildren") or "?")))
    end
    local function regions(frame, indent)
        if type(frame.GetRegions) ~= "function" then return end
        local list = { pcall(frame.GetRegions, frame) }
        for i = 2, math.min(#list, 9) do
            local r = list[i]
            emit(string.format("%s  region[%d] %s atlas=%s tex=%s %sx%s shown=%s alpha=%s", indent, i - 1,
                tostring(call(r, "GetObjectType") or "?"), tostring(call(r, "GetAtlas")), tostring(call(r, "GetTexture")),
                num(call(r, "GetWidth")), num(call(r, "GetHeight")), tostring(call(r, "IsShown")), alpha(r)))
        end
        if #list > 9 then emit(indent .. "  ... " .. (#list - 9) .. " more regions") end
    end
    local function tree(frame, depth, indent)
        describe(frame, indent)
        regions(frame, indent)
        if depth <= 0 or type(frame.GetChildren) ~= "function" then return end
        local kids = { pcall(frame.GetChildren, frame) }
        for i = 2, math.min(#kids, 9) do tree(kids[i], depth - 1, indent .. "  ") end
        if #kids > 9 then emit(indent .. "  ... " .. (#kids - 9) .. " more children") end
    end
    local function flags(frame, label)
        local ok1, protected = pcall(function() return frame:IsProtected() end)
        local ok2, forbidden = pcall(function() return frame:IsForbidden() end)
        local system = frame.system
        local managed = type(frame.GetSystemName) == "function" or type(frame.SelectSystem) == "function" or system ~= nil
        emit(string.format("  %s protected=%s forbidden=%s editModeSystem=%s systemId=%s clampedToScreen=%s", label,
            ok1 and tostring(protected) or "?", ok2 and tostring(forbidden) or "?", tostring(managed),
            self:IsPublic(system) and tostring(system) or "?", tostring(call(frame, "IsClampedToScreen"))))
    end
    local dm = _G.DamageMeter
    if type(dm) ~= "table" then
        emit("  DamageMeter: nil (not loaded or disabled)")
    else
        flags(dm, "DamageMeter")
        tree(dm, 2, "  ")

        local list = type(dm.windowDataList) == "table" and dm.windowDataList or {}
        local count = 0
        for index, data in pairs(list) do
            count = count + 1
            local window = type(data) == "table" and data.sessionWindow or nil
            if type(window) == "table" and count <= 3 then
                emit("  session window #" .. tostring(index))
                flags(window, "window " .. tostring(index))
                tree(window, 2, "    ")
                local target = window.ScrollBox and window.ScrollBox.ScrollTarget
                if type(target) == "table" and type(target.GetChildren) == "function" then
                    local rows = { pcall(target.GetChildren, target) }
                    emit("    entry rows in scroll target: " .. (#rows - 1))
                    for i = 2, math.min(#rows, 3) do tree(rows[i], 2, "      ") end
                end
            end
        end
        emit("  session windows found: " .. count)
    end

    local names = {}
    for key, value in pairs(_G) do
        if type(key) == "string" and key:sub(1, 11) == "DamageMeter" and type(value) == "table"
            and type(value.GetObjectType) == "function" then names[#names + 1] = key end
    end
    table.sort(names)
    for i = 1, math.min(#names, 30) do
        local frame = _G[names[i]]
        emit(string.format("  global %s (%s) %sx%s shown=%s", names[i], tostring(call(frame, "GetObjectType") or "?"),
            num(call(frame, "GetWidth")), num(call(frame, "GetHeight")), tostring(call(frame, "IsShown"))))
    end

    local api = _G.C_DamageMeter
    if type(api) ~= "table" then
        emit("  C_DamageMeter: missing")
        return
    end
    local functionNames = {}
    for key, value in pairs(api) do if type(value) == "function" then functionNames[#functionNames + 1] = key end end
    table.sort(functionNames)
    emit("  C_DamageMeter functions: " .. table.concat(functionNames, ", "))
    local function state(value)
        if not self:IsPublic(value) then return "restricted" end
        if value == nil then return "nil" end
        return "public"
    end
    local function result(name, ...)
        local fn = api[name]
        if type(fn) ~= "function" then emit("    " .. name .. ": missing"); return nil end
        local ok, value, second = pcall(fn, ...)
        if not ok then emit("    " .. name .. ": call rejected"); return nil end
        emit(string.format("    %s -> %s%s", name, state(value), second ~= nil and (" / " .. state(second)) or ""))
        return value
    end
    local S = (Enum and Enum.DamageMeterSessionType) or { Overall = 0, Current = 1 }
    local T = (Enum and Enum.DamageMeterType) or { DamageDone = 0 }
    local available = result("IsDamageMeterAvailable")
    if self:IsPublic(available) and type(available) == "boolean" then emit("    available=" .. tostring(available)) end
    local sessions = result("GetAvailableCombatSessions")
    if self:IsPublic(sessions) and type(sessions) == "table" then emit("    available sessions listed: " .. tostring(#sessions)) end
    for _, kind in ipairs({ "Overall", "Current" }) do
        result("GetSessionDurationSeconds", S[kind] or 0)
        local session = result("GetCombatSessionFromType", S[kind] or 0, T.DamageDone or 0)
        if self:IsPublic(session) and type(session) == "table" then
            emit(string.format("    session(%s): totalAmount=%s maxAmount=%s durationSeconds=%s combatSources=%s", kind,
                state(session.totalAmount), state(session.maxAmount), state(session.durationSeconds),
                type(session.combatSources) == "table" and tostring(#session.combatSources) or state(session.combatSources)))
            local first = type(session.combatSources) == "table" and session.combatSources[1] or nil
            if type(first) == "table" then
                emit(string.format("    first source: name=%s classFilename=%s totalAmount=%s amountPerSecond=%s isLocalPlayer=%s specIconID=%s",
                    state(first.name), state(first.classFilename), state(first.totalAmount), state(first.amountPerSecond),
                    state(first.isLocalPlayer), state(first.specIconID)))
            end
        end
    end
    emit("    not called (mutating, or need a session/source id): ResetAllCombatSessions, GetCombatSessionFromID, GetCombatSessionSourceFromID, GetCombatSessionSourceFromType")
end

function A:TickNativeUI(elapsed)
    self.nativeElapsed = (self.nativeElapsed or 0) + elapsed
    if self.nativeElapsed < 1 then return end
    self.nativeElapsed = 0
    if not self.initialized or self:IsCombat() then return end
    self:ObserveNativePresentation()
    self:ObserveLayoutWriters()
    if self.nativeDirty then self:RefreshNativeUI() end
    if self.layoutDirty then self:RefreshLayout() end


    if self.ApplyElementAlphas then pcall(self.ApplyElementAlphas, self) end
    self:RegisterNativeSettingsCategory()
end
