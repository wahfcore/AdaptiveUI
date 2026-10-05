local _, A = ...

local function finite(self, value)
    return self:IsPublic(value) and type(value) == "number" and value == value
        and value > -math.huge and value < math.huge
end


function A:RememberProperty(state, object, key, capture)
    state.properties = state.properties or {}
    local properties = state.properties[object]
    if not properties then properties = {}; state.properties[object] = properties end
    if not properties[key] then properties[key] = capture() end
end


















function A:ReassertHidden(region)
    if self.reasserting then return end
    if not self:CanWrite("hold", region) then
        self.nativeDirty = true
        return
    end
    self:Trace("hold", region, "reassert")
    self.reasserting = true
    pcall(region.SetAlpha, region, 0)
    self.reasserting = nil
end







local function onHeldAlpha(target, value)
    local held = A.heldHidden
    if held and held[target] and value ~= 0 and A:IsPublic(value) then
        A:ReassertHidden(target)
    end
end
local function holdHook(target, value)
    pcall(onHeldAlpha, target, value)
end

function A:HoldHidden(state, region)
    if not region or type(region.GetAlpha) ~= "function" or type(region.SetAlpha) ~= "function" then return end





    if self:IsOwn(region) then return end
    if not self:CanWrite("hold", region) then return end
    local captured = state.properties and state.properties[region] and state.properties[region].alpha
    if not captured then
        local old = region:GetAlpha()
        if not self:IsPublic(old) or type(old) ~= "number" then return end
        self:RememberProperty(state, region, "alpha", function()
            return function()


                if A.heldHidden then A.heldHidden[region] = nil end
                region:SetAlpha(old)
            end
        end)
    end
    self.heldHidden = self.heldHidden or {}
    self.holdHooks = self.holdHooks or {}
    self.heldHidden[region] = true
    if not self.holdHooks[region] and type(hooksecurefunc) == "function" then
        local ok = pcall(hooksecurefunc, region, "SetAlpha", holdHook)
        if ok then self.holdHooks[region] = true end
    end
    local current = region:GetAlpha()
    if self:IsPublic(current) and current ~= 0 then
        self:Trace("hold", region, "hide")
        region:SetAlpha(0)
    end
end



































A.handsOff = true
A.actionBarFamily = {
    MainActionBar = true, MainMenuBar = true, MultiBarBottomLeft = true, MultiBarBottomRight = true,
    MultiBarRight = true, MultiBarLeft = true, MultiBar5 = true, MultiBar6 = true, MultiBar7 = true,
    StanceBar = true, PetActionBar = true, PossessActionBar = true, OverrideActionBar = true,
    MainMenuBarVehicleLeaveButton = true, MicroButtonAndBagsBar = true, MicroMenuContainer = true,
    MicroMenu = true, BagsBar = true, StatusTrackingBarManager = true,
    MainStatusTrackingBarContainer = true, SecondaryStatusTrackingBarContainer = true,
    GamepadMainActionBarFrame = true, ExtraActionBarFrame = true, ZoneAbilityFrame = true,
    ExtraAbilityContainer = true,
}
A.actionBarFamilyPatterns = {
    "^ActionButton%d", "^MultiBar", "^StanceButton", "^PetActionButton", "^PossessButton",
    "^OverrideActionBar", "MicroButton$", "^CharacterBag%dSlot", "^CharacterReagentBag%dSlot",
    "^MainMenuBarBackpackButton", "^ExtraActionButton", "^ActionBarPage", "^GamepadMainActionBar",
}
local function familyName(name)
    if type(name) ~= "string" then return false end
    if A.actionBarFamily[name] then return true end
    for _, pattern in ipairs(A.actionBarFamilyPatterns) do
        if name:find(pattern) then return true end
    end
    return false
end
local function parentOf(object)
    if type(object) ~= "table" or type(object.GetParent) ~= "function" then return nil end
    local ok, parent = pcall(object.GetParent, object)
    if ok and type(parent) == "table" then return parent end
    return nil
end
function A:IsActionBarFamily(object)
    local node = object
    for _ = 1, 24 do
        if type(node) ~= "table" then return false end

        if self.IsOwn and self:IsOwn(node) then return false end
        if familyName(self:ObjectName(node)) then return true end
        node = parentOf(node)
    end
    return false
end































A.secretAdjacentFrames = {
    PlayerFrame = true, TargetFrame = true, FocusFrame = true, TargetFrameToT = true, FocusFrameToT = true,
    PetFrame = true, PartyFrame = true, CompactPartyFrame = true, CompactRaidFrameContainer = true,
    CompactRaidFrameManager = true, BossTargetFrameContainer = true, PlayerLevelText = true, PlayerName = true,
    PlayerCastingBarFrame = true, OverlayPlayerCastingBarFrame = true, TargetFrameSpellBar = true,
    FocusFrameSpellBar = true, PetCastingBarFrame = true, BuffFrame = true, DebuffFrame = true,
    TemporaryEnchantFrame = true, GameTooltip = true, GameTooltipDefaultContainer = true,
    SharedTooltipDefaultContainer = true, GameTooltipStatusBar = true, ObjectiveTrackerFrame = true,
    EssentialCooldownViewer = true, UtilityCooldownViewer = true, BuffIconCooldownViewer = true,
    BuffBarCooldownViewer = true,
}
A.secretAdjacentPatterns = {
    "^PlayerFrame", "^TargetFrame", "^FocusFrame", "^PetFrame", "^PartyMemberFrame", "^CompactRaid",
    "^CompactParty", "^CompactUnitFrame", "^NamePlate", "^Boss%dTargetFrame", "Tooltip%d*$", "CastingBar",
    "^ObjectiveTracker", "CooldownViewer$",
}
local function secretName(name)
    if type(name) ~= "string" or name:find("^AdaptiveUI") then return false end
    if A.secretAdjacentFrames[name] then return true end
    for _, pattern in ipairs(A.secretAdjacentPatterns) do
        if name:find(pattern) then return true end
    end
    return false
end


local function secretGlobal(node)
    for name in pairs(A.secretAdjacentFrames) do
        if _G[name] == node then return true end
    end
    return false
end
function A:IsSecretAdjacent(object)
    local node = object
    for _ = 1, 24 do
        if type(node) ~= "table" then return false end
        if self.IsOwn and self:IsOwn(node) then return false end
        if secretName(self:ObjectName(node)) or secretGlobal(node) then return true end
        node = parentOf(node)
    end
    return false
end

function A:IsHandsOff(object)
    return self:IsActionBarFamily(object) or self:IsSecretAdjacent(object)
end




A.geometryProperties = { geometry = true, scale = true, size = true, points = true }
function A:FamilyGeometry(object, key)
    return A.geometryProperties[key] == true and self:IsHandsOff(object)
end



function A:SettleHandsOff()

    if not (self.db and self.db.setupDone == true) then return false end
    return self:NoteOnce("handsOff", "action bars, unit frames, cast bar, buffs, tooltip and objectives: "
        .. "their position and size are set in Edit Mode now (Esc > Edit Mode). AdaptiveUI no longer moves "
        .. "or resizes Blizzard's frames; its art follows them wherever you put them.")
end



function A:ReleaseProperty(state, object, key)
    local props = state.properties and state.properties[object]
    local restore = props and props[key]
    if restore then
        if not self:FamilyGeometry(object, key) then pcall(restore) end
        props[key] = nil
    end
end

function A:ReleaseHidden(state, region)
    if region then self:ReleaseProperty(state, region, "alpha") end
end

local function rememberGeometry(self, state, frame)
    assert(frame and type(frame.GetNumPoints) == "function", "Layout frame unavailable")
    self:RememberProperty(state, frame, "geometry", function()
        local points = {}
        local count = frame:GetNumPoints()
        assert(finite(self, count) and count >= 0 and count <= 16, "Restricted anchors")
        for i = 1, count do
            local point = { frame:GetPoint(i) }
            assert(self:IsPublic(point[1]) and self:IsPublic(point[2]) and self:IsPublic(point[3])
                and finite(self, point[4]) and finite(self, point[5]), "Restricted anchor")
            points[#points + 1] = point
        end
        local width, height, scale = frame:GetWidth(), frame:GetHeight(), frame:GetScale()
        assert(finite(self, width) and finite(self, height) and finite(self, scale), "Restricted size")
        return function()
            frame:SetScale(scale)
            frame:SetSize(width, height)
            frame:ClearAllPoints()
            for _, point in ipairs(points) do frame:SetPoint(unpack(point)) end
        end
    end)
end

function A:PlaceNative(state, frame, point, relative, relativePoint, x, y, scale, width, height)


    if not self:CanWrite("place", frame) then return end
    rememberGeometry(self, state, frame)
    self:Trace("place", frame, point)
    if scale then
        local current = frame:GetScale()
        assert(finite(self, current), "Restricted scale")
        if current ~= scale then frame:SetScale(scale) end
    end
    if width and height then
        local w, h = frame:GetWidth(), frame:GetHeight()
        assert(finite(self, w) and finite(self, h), "Restricted dimensions")
        if w ~= width or h ~= height then frame:SetSize(width, height) end
    end
    local count = frame:GetNumPoints()
    assert(finite(self, count), "Restricted anchor count")
    local current = count == 1 and { frame:GetPoint(1) } or {}
    for i = 1, 5 do assert(self:IsPublic(current[i]), "Restricted current anchor") end
    if count ~= 1 or current[1] ~= point or current[2] ~= relative
        or current[3] ~= relativePoint or current[4] ~= x or current[5] ~= y then
        frame:ClearAllPoints()
        frame:SetPoint(point, relative, relativePoint, x, y)
    end
end





function A:MoverScale(id)
    local key = "scale." .. id
    if not (self.optionIndex and self.optionIndex[key]) then return 1 end
    local v = tonumber(self:GetOption(key)) or 1
    if v ~= v or v <= 0.05 then return 1 end
    return v
end




















A.compassTestScale = 1.25
function A:CompassTestCommand(argument)
    local page = _G.GamepadMainActionBarFrame and _G.GamepadMainActionBarFrame.PageUnit
    local bar = page and type(page.actionBars) == "table" and page.actionBars.bottomBar or nil
    local group = type(bar) == "table" and bar.Left or nil
    if not group then self:Print("compasstest: no gamepad action bar on screen."); return end
    if self:IsCombat() then self:Print("compasstest: not in combat."); return end
    argument = type(argument) == "string" and argument:lower() or ""
    local state = self.layoutStates and self.layoutStates.actions
    if not state then self:Print("compasstest: the action-bar layout is not active."); return end
    local out = {}
    local function say(text) self:Print(text); out[#out + 1] = text end
    local function num(frame, method)
        local v = self:Number(frame[method], 1, frame)
        return v and string.format("%.3f", v) or "n/a"
    end
    local function rect(label, frame)
        if type(frame) ~= "table" or type(frame.GetRect) ~= "function" then say("  " .. label .. ": no frame"); return end
        local ok, x, y, w, h = pcall(frame.GetRect, frame)
        if ok and self:IsPublic(x) and self:IsPublic(y) and self:IsPublic(w) and self:IsPublic(h)
            and type(x) == "number" and type(w) == "number" then
            say(string.format("  %-9s rect %8.2f %8.2f %7.2f %7.2f  scale %s  effective %s", label, x, y, w, h,
                num(frame, "GetScale"), num(frame, "GetEffectiveScale")))
        else
            say("  " .. label .. ": rect not public")
        end
    end



    if argument == "on" or argument == "off" then
        say("compasstest " .. argument .. ": retired -- AdaptiveUI no longer scales Blizzard's action bars "
            .. "(the write tainted the action buttons). Nothing changed; the rects below are read only.")
    elseif argument == "read" then
        say("compasstest read: the live rects, read only")
    else
        say("compasstest: read only now (`read`). Nothing is written to Blizzard's action bars.")
    end
    rect("bar", bar)
    rect("Bar.Left", group)
    for i = 1, 4 do rect("button" .. i, group["ActionButton" .. i]) end
    local text = table.concat(out, "\n")
    local prior = type(self.inspectText) == "string" and (self.inspectText .. "\n") or ""
    self.inspectText = prior .. text
    if self.StoreInspectReport and self:StoreInspectReport(self.inspectText) then
        self:Print("compasstest saved with the inspect dump: /reload and send AdaptiveUIInspectDB.")
    end
end



function A:SizeNative(state, frame, width, height)
    if not frame or type(frame.GetWidth) ~= "function" then return end
    if not self:CanWrite("place", frame) then return end
    self:RememberProperty(state, frame, "size", function()
        local w, h = frame:GetWidth(), frame:GetHeight()
        assert(finite(self, w) and finite(self, h), "Restricted size")
        return function() frame:SetSize(w, h) end
    end)
    local w, h = frame:GetWidth(), frame:GetHeight()
    assert(finite(self, w) and finite(self, h), "Restricted size")
    if math.abs(w - width) > 0.01 or math.abs(h - height) > 0.01 then
        self:Trace("size", frame, width)
        frame:SetSize(width, height)
    end
end




function A:NativeJustify(state, region, want)
    if not region or type(region.GetJustifyH) ~= "function" or type(region.SetJustifyH) ~= "function" then return end
    if not want then
        if state.properties and state.properties[region] and state.properties[region].justifyH
            and self:CanWrite("place", region) then
            self:ReleaseProperty(state, region, "justifyH")
        end
        return
    end
    if not self:CanWrite("place", region) then return end
    local old = region:GetJustifyH()
    if not self:IsPublic(old) or type(old) ~= "string" then return end
    self:RememberProperty(state, region, "justifyH", function()
        return function() region:SetJustifyH(old) end
    end)
    if region:GetJustifyH() ~= want then region:SetJustifyH(want) end
end

function A:LoadLayoutSettings()
    local db = self.db
    if db.layoutVersion ~= 1 then
        db.previousLayout = {}
        for _, key in ipairs({ "scale", "dock", "x", "y", "opacity", "style", "casts", "enabled" }) do
            db.previousLayout[key] = db[key]
        end
        if db.layout ~= false then db.scale = math.max(0.7, db.scale * 0.85) end
        db.layoutVersion = 1
    end
    if type(db.layout) ~= "boolean" then db.layout = true end
    for key, default in pairs({ dockScale = 0.9, textScale = 1, layoutX = 0, layoutY = 0 }) do
        if not finite(self, db[key]) then db[key] = default end
    end
    db.dockScale = math.max(0.7, math.min(1.2, db.dockScale))
    db.textScale = math.max(0.85, math.min(1.2, db.textScale))
    db.layoutX = math.max(-300, math.min(300, db.layoutX))
    db.layoutY = math.max(-150, math.min(300, db.layoutY))
end








































































local ARM_L, ARM_R, ARM_UP, ARM_DOWN = 151, 141, 66, 56
local ARM_HALF = math.max(ARM_L, ARM_R)




local INK_PAD = 4
local TRAY_PAD, TRAY_GAP = 4, 8
local DOCK = {
    base = 16,
    bottom = 64, hub = 134, top = 204,
    armL = ARM_L, armR = ARM_R, armDown = ARM_DOWN, armUp = ARM_UP,
    armHalf = ARM_HALF,
    armClear = ARM_UP,
    inkL = ARM_L - INK_PAD, inkR = ARM_R - INK_PAD,
    inkUp = ARM_UP - INK_PAD, inkDown = ARM_DOWN - INK_PAD,
    spreadTray = 292, spreadSocket = 250,
    trayPad = TRAY_PAD,




    armBias = { collapsed = 3, expanded = 5 },
    groundPad = 8,
    groundGap = 10,
    tabInboard = 34, tabDrop = 6,







    slabH = 12,
    slabDrop = 4,
    slabCap = 1.6,
}
DOCK.crown = DOCK.top + DOCK.armClear + 14
DOCK.height = DOCK.crown + 28



DOCK.trayH = (DOCK.top - DOCK.bottom) - 2 * TRAY_PAD - TRAY_GAP
A.dock = DOCK























A.dockStyle = {
    slots = { "L", "T", "R", "B" },
    collapsed = {
        barW = 208, barH = 68, shadow = 4, identifier = 30, identifierY = 38,
        left  = { size = 30, L = { -92, 0 }, T = { -58, 17 }, R = { -24, 0 }, B = { -58, -17 } },
        right = { size = 32, L = { 25, 0 },  T = { 55, 18 },  R = { 85, 0 },  B = { 55, -18 } },
    },
    expanded = {
        barW = 266, barH = 86, shadow = 13, identifier = 35, identifierY = 48,
        left  = { size = 38, L = { -119, 0 }, T = { -75, 23 }, R = { -31, 0 }, B = { -75, -23 } },
        right = { size = 40, L = { 32, 0 },   T = { 70, 23 },  R = { 108, 0 }, B = { 70, -23 } },
    },
}


































A.compassGroups = {
    { id = "topL",    arm = "compassTop",    group = "Left",  bar = "topBar",    role = "dpad" },
    { id = "topR",    arm = "compassTop",    group = "Right", bar = "topBar",    role = "face" },
    { id = "leftL",   arm = "compassLeft",   group = "Left",  bar = "leftBar",   role = "dpad" },
    { id = "leftR",   arm = "compassLeft",   group = "Right", bar = "leftBar",   role = "face" },
    { id = "rightL",  arm = "compassRight",  group = "Left",  bar = "rightBar",  role = "dpad" },
    { id = "rightR",  arm = "compassRight",  group = "Right", bar = "rightBar",  role = "face" },
    { id = "bottomL", arm = "compassBottom", group = "Left",  bar = "bottomBar", role = "dpad" },
    { id = "bottomR", arm = "compassBottom", group = "Right", bar = "bottomBar", role = "face" },
}
A.compassGroupScaleMin, A.compassGroupScaleMax = 0.8, 1.6
local COMPASS_BAR_OF = { compassTop = "topBar", compassBottom = "bottomBar",
                         compassLeft = "leftBar", compassRight = "rightBar" }
A.compassBarOf = COMPASS_BAR_OF






function A:CompassSkin()
    if not (self.db and self.optionIndex) then return "classic" end
    if self.AuthoredSockets and not self:AuthoredSockets() then return "classic" end
    return "rail"
end




function A:CompassGroupScaleRaw(id)




    if A.handsOff then return 1 end
    if self:CompassSkin() ~= "rail" then return 1 end



    local hero = self:CompassHeroArm()
    if hero then
        for _, e in ipairs(self.compassGroups) do
            if e.id == id and e.arm == hero then
                local size = tonumber(self:GetOption("compassHeroSize")) or 1.2
                if size ~= size then size = 1.2 end
                return math.max(self.compassGroupScaleMin, math.min(self.compassGroupScaleMax, size))
            end
        end
    end
    local option = self.optionIndex and self.optionIndex["compassGroupSize." .. tostring(id)]
    if not option then return 1 end
    local value = tonumber(self:GetOption(option.key)) or 1
    if value ~= value then return 1 end
    return math.max(self.compassGroupScaleMin, math.min(self.compassGroupScaleMax, value))
end


function A:CompassHeroArm()
    if not (self.db and self.optionIndex and self.optionIndex.compassHeroArm) then return nil end
    local arm = self:GetOption("compassHeroArm")
    if arm == "none" or not COMPASS_BAR_OF[arm] then return nil end
    return arm
end



function A:CompassGroupScale(id)
    local fit = self.compassScaleFit and self.compassScaleFit[id]
    if fit then return fit end
    return self:CompassGroupScaleRaw(id)
end



function A:CompassArmOfBar(bar)
    if type(bar) ~= "table" then return nil end
    local page = _G.GamepadMainActionBarFrame and _G.GamepadMainActionBarFrame.PageUnit
    local bars = page and type(page.actionBars) == "table" and page.actionBars or nil
    if not bars then return nil end
    for id, key in pairs(COMPASS_BAR_OF) do
        if bars[key] == bar then return id end
    end
    return nil
end


function A:CompassArmScales(arm)
    local id = type(arm) == "string" and arm or self:CompassArmOfBar(arm)
    if not id then return 1, 1 end
    local l, r = 1, 1
    for _, e in ipairs(self.compassGroups) do
        if e.arm == id then
            if e.group == "Left" then l = self:CompassGroupScale(e.id) else r = self:CompassGroupScale(e.id) end
        end
    end
    return l, r
end






A.compassPresets = {
    classic   = { all = 1.00, hero = "none" },
    heroTop   = { all = 1.00, hero = "compassTop" },
    heroThumb = { all = 1.00, hero = "compassBottom" },
    heroLeft  = { all = 1.00, hero = "compassLeft" },
    heroRight = { all = 1.00, hero = "compassRight" },
}
function A:ApplyCompassPreset(key)
    local preset = self.compassPresets[key]
    if not preset or not self.SetOption then return false end
    for _, e in ipairs(self.compassGroups) do
        self:SetOption("compassGroupSize." .. e.id, preset[e.arm] or preset.all or 1, true)
    end
    if preset.hero and self.optionIndex and self.optionIndex.compassHeroArm then
        self:SetOption("compassHeroArm", preset.hero, true)
    end
    return true
end










function A:CompassRootScale()
    local root = _G.GamepadMainActionBarFrame
    local us = (UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)) or 1
    local rs = type(root) == "table" and type(root.GetEffectiveScale) == "function"
        and self:Number(root.GetEffectiveScale, 1, root) or nil
    if not rs or us <= 0.05 then return 1 end
    local s = rs / us
    if s ~= s or s <= 0.05 or s > 20 then return 1 end
    return s
end

function A:DockPixel()
    local ds = math.max(0.3, self:CompassRootScale())
    local px = self:PhysicalPixel(_G.UIParent) / ds
    if px ~= px or px <= 0.05 or px > 8 then return 1 end
    return px
end

function A:DockSnap(value)
    value = tonumber(value) or 0
    if value == 0 then return 0 end
    if self.PixelSnapOn and not self:PixelSnapOn() then return value end
    local px = self:DockPixel()
    local steps = math.floor(math.abs(value) / px + 0.5)
    if steps < 1 then steps = 1 end
    return (value < 0 and -steps or steps) * px
end





function A:CompassGroundMode()
    if self.db and self.optionIndex and self.optionIndex.compassGround
        and self:GetOption("compassGround") == "divider" and self:CompassDividerOn() then
        return "divider"
    end
    return "none"
end



function A:CompassFootGround(mode)
    return (mode or self:CompassGroundMode()) == "divider"
end

function A:CompassDividerOn()
    if self:CompassSkin() ~= "rail" then return false end
    return (self.artSlots and self.artSlots.compassDivider) ~= nil
end








A.compassBase = { seat = 2, promptDrop = 9 }



A.dividerArt = {
    ratio    = 1983 / 217,
    faceV0   = 38 / 217,
    faceV1   = 152 / 217,
    faceU0   = 118 / 1983,
    faceU1   = 1850 / 1983,
    diamondU = 149 / 1983,
    diamondV = 93 / 217,
    diamondA = 66 / 217,
    notchU   = 1830 / 1983,
    reach    = 0.45,
    light    = 0.70,
}
function A:CompassBaseRect()
    local l, r = self:CompassArmScales("compassBottom")
    local _, rcy, _, rh = self:CompassStyleBox("collapsed", nil, { left = l, right = r })
    local plate = (self.PlusPlateWidth and self:PlusPlateWidth(false)) or 339


    local unit = (self.db and self.UnitScale and self:UnitScale()) or 0.85
    local dock = self:CompassRootScale()
    if not unit or unit <= 0.05 then unit = 0.85 end
    if not dock or dock <= 0.05 then dock = 0.9 end
    local w = self:DockSnap(plate * unit / dock)
    local top0 = DOCK.bottom + rcy - rh / 2 - self.compassBase.seat




    local d = A.dividerArt
    local h = self:DockSnap(math.max(0, math.min(top0, w / d.ratio)))
    if h > top0 then h = math.max(0, h - self:DockPixel()) end
    return DOCK.cx, top0 - h / 2, self:DockSnap(h * d.ratio), h, 0, top0
end









function A:CompassStyleBox(state, group, scales)
    local style = self.dockStyle[state] or self.dockStyle.collapsed
    local keys = group and { group } or { "left", "right" }
    local x0, x1, y0, y1
    for _, key in ipairs(keys) do
        local g = style[key]
        local s = (scales and tonumber(scales[key])) or 1
        local half = g.size * s / 2
        for _, slot in ipairs(self.dockStyle.slots) do
            local at = g[slot]
            local ax, ay = at[1] * s, at[2] * s
            local l, r, b, t = ax - half, ax + half, ay - half, ay + half
            if not x0 or l < x0 then x0 = l end
            if not x1 or r > x1 then x1 = r end
            if not y0 or b < y0 then y0 = b end
            if not y1 or t > y1 then y1 = t end
        end
    end
    return (x0 + x1) / 2, (y0 + y1) / 2, x1 - x0, y1 - y0
end




function A:CompassArmState(bar)
    if type(bar) ~= "table" then return "collapsed" end
    local w = self:Number(bar.GetWidth, 1, bar)
    if w and w >= (self.dockStyle.collapsed.barW + self.dockStyle.expanded.barW) / 2 then
        return "expanded"
    end
    return "collapsed"
end








function A:CompassArmBias(bar)
    local state = self:CompassArmState(bar)
    local arm = self:CompassArmOfBar(bar)
    if not arm then return DOCK.armBias[state] or DOCK.armBias.collapsed end
    local l, r = self:CompassArmScales(arm)
    local cx = self:CompassStyleBox(state, nil, { left = l, right = r })
    return -cx
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



function A:CompassGroupRect(bar, group)
    if self:IsCombat() then return nil end
    if type(bar) ~= "table" or type(group) ~= "table" then return nil end
    local bx, by, bw, bh = rectOf(self, bar)
    if not bx then return nil end
    local scale = self:Number(bar.GetEffectiveScale, 1, bar) or 1
    if scale <= 0.05 or scale > 20 then return nil end
    local x0, x1, y0, y1
    for i = 1, 4 do
        local x, y, w, h = rectOf(self, group["ActionButton" .. i])
        if not x then return nil end
        if not x0 or x < x0 then x0 = x end
        if not x1 or x + w > x1 then x1 = x + w end
        if not y0 or y < y0 then y0 = y end
        if not y1 or y + h > y1 then y1 = y + h end
    end
    local ccx, ccy = bx + bw / 2, by + bh / 2
    return ((x0 + x1) / 2 - ccx) / scale, ((y0 + y1) / 2 - ccy) / scale,
           (x1 - x0) / scale, (y1 - y0) / scale
end




function A:CompassArmRect(bar)
    local lx, ly, lw, lh = self:CompassGroupRect(bar, bar and bar.Left)
    local rx, ry, rw, rh = self:CompassGroupRect(bar, bar and bar.Right)
    if lx and rx then
        local x0 = math.min(lx - lw / 2, rx - rw / 2)
        local x1 = math.max(lx + lw / 2, rx + rw / 2)
        local y0 = math.min(ly - lh / 2, ry - rh / 2)
        local y1 = math.max(ly + lh / 2, ry + rh / 2)
        return (x0 + x1) / 2, (y0 + y1) / 2, x1 - x0, y1 - y0, "live"
    end
    local state = self:CompassArmState(bar)


    local l, r = self:CompassArmScales(bar)
    local cx, cy, w, h = self:CompassStyleBox(state, nil, { left = l, right = r })
    return cx, cy, w, h, "style"
end









function A:DockBase(m)
    local _, safeY = self:SafeInset(m)
    return math.max(DOCK.base, safeY)
end




























A.compassArmClear = 12
A.compassArmRange = 160







A.statusLaneFrames = { "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer" }
A.actionBarRows = {
    { "MainActionBar", "actionBar1", "Action bar 1 (keyboard)" },
    { "MultiBarBottomLeft", "actionBar2", "Action bar 2 (keyboard)" },
    { "MultiBarBottomRight", "actionBar3", "Action bar 3 (keyboard)" },
}

A.compassArmList = {
    { id = "compassTop", anchor = "TopCenteredAnchor", label = "Gamepad up arm" },
    { id = "compassLeft", anchor = "LeftCenteredAnchor", label = "Gamepad left arm" },
    { id = "compassRight", anchor = "RightCenteredAnchor", label = "Gamepad right arm" },
    { id = "compassBottom", anchor = "BottomCenteredAnchor", label = "Gamepad down arm" },
}







function A:CompassArmBase(id, bias)
    bias = tonumber(bias) or DOCK.armBias.collapsed
    local cx = DOCK.cx + bias
    if id == "compassTop" then return cx, DOCK.top end
    if id == "compassBottom" then return cx, DOCK.bottom end
    if id == "compassLeft" then return cx - DOCK.spread, DOCK.hub end
    if id == "compassRight" then return cx + DOCK.spread, DOCK.hub end
end














local function armButtons(ax, ay, out, state, scales)
    local style = A.dockStyle[state or "collapsed"] or A.dockStyle.collapsed
    for _, key in ipairs({ "left", "right" }) do
        local g = style[key]


        local s = (scales and scales[key]) or 1
        local half = g.size * s / 2
        for _, slot in ipairs(A.dockStyle.slots) do
            local at = g[slot]
            out[#out + 1] = { ax + at[1] * s - half, ay + at[2] * s - half,
                              ax + at[1] * s + half, ay + at[2] * s + half }
        end
    end
end






function A:CompassGroupBoxes(state, override)
    local out = {}
    for _, e in ipairs(self.compassGroups) do
        local l, r = self:CompassArmScales(e.arm)
        if override then
            for _, o in ipairs(self.compassGroups) do
                if o.arm == e.arm and override[o.id] then
                    if o.group == "Left" then l = override[o.id] else r = override[o.id] end
                end
            end
        end
        local scales = { left = l, right = r }
        local bias = -self:CompassStyleBox(state, nil, scales)
        local ax, ay = self:CompassArmBase(e.arm, bias)
        local gx, gy, gw, gh = self:CompassStyleBox(state, e.group == "Left" and "left" or "right", scales)
        out[#out + 1] = { id = e.id, arm = e.arm, cx = ax + gx, cy = ay + gy, w = gw, h = gh }
    end
    return out
end



function A:CompassWorstGroupOverlap(state, override)
    local boxes = self:CompassGroupBoxes(state, override)
    local worst = 0
    for i = 1, #boxes do
        for j = i + 1, #boxes do
            local a, b = boxes[i], boxes[j]
            local ox = math.min(a.cx + a.w / 2, b.cx + b.w / 2) - math.max(a.cx - a.w / 2, b.cx - b.w / 2)
            local oy = math.min(a.cy + a.h / 2, b.cy + b.h / 2) - math.max(a.cy - a.h / 2, b.cy - b.h / 2)
            if ox > 0 and oy > 0 then worst = math.max(worst, math.min(ox, oy)) end
        end
    end
    return worst
end



function A:CompassArmReach(arm, state, scales)
    local _, _, w, h = self:CompassStyleBox(state, nil, scales)
    return w / 2, h / 2
end











function A:CompassNeededSpread(override)
    local reach = {}
    local maxHalfW, maxHalfH = 0, 0
    for _, id in ipairs({ "compassTop", "compassLeft", "compassRight", "compassBottom" }) do
        local l, r = self:CompassArmScales(id)
        if override then
            for _, o in ipairs(self.compassGroups) do
                if o.arm == id and override[o.id] then
                    if o.group == "Left" then l = override[o.id] else r = override[o.id] end
                end
            end
        end
        local scales = { left = l, right = r }
        local rw, rh = self:CompassArmReach(id, "expanded", scales)
        reach[id] = rw
        maxHalfW, maxHalfH = math.max(maxHalfW, rw), math.max(maxHalfH, rh)
    end
    local need = DOCK.spreadTray
    for _, pair in ipairs({ { "compassLeft", "compassTop" }, { "compassLeft", "compassBottom" },
                            { "compassRight", "compassTop" }, { "compassRight", "compassBottom" } }) do
        need = math.max(need, reach[pair[1]] + reach[pair[2]] + DOCK.groundGap)
    end
    return need, maxHalfW, maxHalfH, math.max(reach.compassTop, reach.compassBottom)
end


function A:CompassArmsClear(id, ox, oy, m)
    m = m or self:LayoutMetrics()
    local ds = m.dockScale
    local arms = {}
    for _, entry in ipairs(self.compassArmList) do
        local ax, ay = self:CompassArmBase(entry.id)
        local dx, dy
        if entry.id == id then dx, dy = ox, oy else dx, dy = self:MoverOffset(entry.id) end
        local rects = {}
        local l, r = self:CompassArmScales(entry.id)
        armButtons(ax + dx / ds, ay + dy / ds, rects, nil, { left = l, right = r })
        arms[#arms + 1] = rects
    end
    for i = 1, #arms do
        for j = i + 1, #arms do
            for _, a in ipairs(arms[i]) do
                for _, b in ipairs(arms[j]) do
                    local gap = math.max(math.max(b[1] - a[3], a[1] - b[3]),
                                         math.max(b[2] - a[4], a[2] - b[4]))
                    if gap < self.compassArmClear then return false end
                end
            end
        end
    end



    local ax, ay = self:CompassArmBase(id)
    if not ax then return true end
    local cox, coy = self:MoverOffset("actionCompass")



    local safeX, safeY = self:SafeInset(m)


    local down = DOCK.armDown
    if id == "compassBottom" and self:CompassFootGround() then
        local _, bcy, _, bh = self:CompassBaseRect()
        down = math.max(down, DOCK.bottom - (bcy - bh / 2))
    end
    local function inside(dx, dy)
        local sx = m.width / 2 - DOCK.width * ds / 2 + cox + (ax + dx / ds) * ds
        local sy = self:DockBase(m) + coy + (ay + dy / ds) * ds




        return sx - DOCK.armL * ds >= safeX and sx + DOCK.armR * ds <= m.width - safeX
            and sy - down * ds >= safeY and sy + DOCK.armClear * ds <= m.height - safeY
    end
    if inside(0, 0) and not inside(ox, oy) then return false end
    return true
end




function A:ClampCompassArm(id, ox, oy, m)





    if ox == 0 and oy == 0 then
        local moved = false
        for _, entry in ipairs(self.compassArmList) do
            local x, y = self:MoverOffset(entry.id)
            if x ~= 0 or y ~= 0 then moved = true break end
        end
        if not moved then return 0, 0 end
    end
    m = m or self:LayoutMetrics()
    local cap = self.compassArmRange
    ox = math.max(-cap, math.min(cap, ox))
    oy = math.max(-cap, math.min(cap, oy))
    if self:CompassArmsClear(id, ox, oy, m) then return ox, oy end
    local step = self:MoverStep()
    local steps = math.ceil(math.max(math.abs(ox), math.abs(oy)) / step)
    for i = steps - 1, 1, -1 do
        local t = i / steps
        local tx, ty = self:SnapMover(ox * t), self:SnapMover(oy * t)
        if self:CompassArmsClear(id, tx, ty, m) then return tx, ty end
    end
    return 0, 0
end





function A:SyncDock()
    local socket = self.db and self.optionIndex and self:GetOption("actionDiamond") == true
    DOCK.socket = socket == true
    DOCK.trayW = DOCK.spreadTray - 2 * TRAY_PAD - TRAY_GAP






    DOCK.spread = DOCK.spreadTray



    DOCK.cx = DOCK.spread + ARM_HALF
    DOCK.width = 2 * DOCK.cx
    DOCK.armUp, DOCK.armDown = 56, 56
    DOCK.armL, DOCK.armR, DOCK.armHalf, DOCK.armClear = ARM_L, ARM_R, ARM_HALF, ARM_UP







    self.compassScaleFit = nil
    if self:CompassSkin() == "rail" then
        local auto = not (self.optionIndex and self.optionIndex.compassAutoSpread)
            or self:GetOption("compassAutoSpread") ~= false
        local need, halfW, halfH, centreReach = self:CompassNeededSpread()
        if not auto and need > DOCK.spreadTray then




            local fit = {}
            for _, e in ipairs(self.compassGroups) do fit[e.id] = self:CompassGroupScaleRaw(e.id) end
            for _ = 1, 8 * 16 do
                need, halfW, halfH, centreReach = self:CompassNeededSpread(fit)
                if need <= DOCK.spreadTray + 1e-6 then break end
                local largest, size = nil, 0
                for _, e in ipairs(self.compassGroups) do
                    if fit[e.id] > size + 1e-9 then largest, size = e.id, fit[e.id] end
                end
                if not largest or size <= self.compassGroupScaleMin + 1e-9 then break end
                fit[largest] = math.max(self.compassGroupScaleMin, size - 0.05)
            end
            self.compassScaleFit = fit
            need = DOCK.spreadTray
        end
        DOCK.spread = need
        DOCK.armHalf = math.max(ARM_HALF, halfW)
        DOCK.armL, DOCK.armR = math.max(ARM_L, centreReach), math.max(ARM_R, centreReach)
        DOCK.armUp, DOCK.armDown = math.max(56, halfH), math.max(56, halfH)
        DOCK.armClear = math.max(ARM_UP, halfH)
        DOCK.cx = DOCK.spread + DOCK.armHalf
        DOCK.width = 2 * DOCK.cx
    end
    DOCK.axis = DOCK.cx
    DOCK.inkUp, DOCK.inkDown = DOCK.armUp - INK_PAD, DOCK.armDown - INK_PAD
    DOCK.inkL, DOCK.inkR = DOCK.armL - INK_PAD, DOCK.armR - INK_PAD
    DOCK.crown = DOCK.top + DOCK.armClear + 14
    DOCK.height = DOCK.crown + 28
    return DOCK
end
A:SyncDock()






function A:LayoutFit()
    local width = self:Number(UIParent.GetWidth, 1, UIParent) or 1920
    local height = self:Number(UIParent.GetHeight, 1, UIParent) or 1080
    return math.min(1, width / 1600, height / 900)
end



function A:UnitScale()
    local scale = (self.db and tonumber(self.db.scale)) or 1
    scale = scale * self:LayoutFit()
    if scale ~= scale or scale <= 0.05 or scale > 20 then return 1 end
    return scale
end





function A:CompassLiveBox(width)
    local root = _G.GamepadMainActionBarFrame
    local page = type(root) == "table" and root.PageUnit or nil
    local bars = page and type(page.actionBars) == "table" and page.actionBars or nil
    if not bars or not self.BoxOf or not self.kbRectOf then return nil end
    if self:Read(root.IsShown, 1, root) ~= true then return nil end

    if self.KeyboardMode and self:KeyboardMode() then return nil end
    width = width or self:Number(UIParent.GetWidth, 1, UIParent) or 1920




    local s = self:CompassRootScale()
    local top, centreHalf
    for _, key in ipairs({ "TopCenteredAnchor", "LeftCenteredAnchor", "RightCenteredAnchor", "BottomCenteredAnchor" }) do
        local box = self:BoxOf(page[key])
        if box then
            local cx, cy = (box.l + box.r) / 2, (box.b + box.t) / 2
            local t = cy + DOCK.armClear * s
            if not top or t > top then top = t end
            if key == "TopCenteredAnchor" or key == "BottomCenteredAnchor" then
                local half = math.max(cx + DOCK.armR * s - width / 2, width / 2 - (cx - DOCK.armL * s))
                if not centreHalf or half > centreHalf then centreHalf = half end
            end
        end
    end
    if not top or not centreHalf then return nil end
    return { t = top, centreHalf = centreHalf }
end

function A:LayoutMetrics()
    self:SyncDock()
    local width = self:Number(UIParent.GetWidth, 1, UIParent) or 1920
    local height = self:Number(UIParent.GetHeight, 1, UIParent) or 1080
    local fit = self:LayoutFit()





    local dockScale = math.max(0.3, self:CompassRootScale())
    local unitScale = self.db.scale * fit
    local margin = self.tokens.margin
    local function opt(key, fallback)
        if self.db and self.optionIndex and self.optionIndex[key] then return self:GetOption(key) end
        return fallback
    end












    local hh, ph = opt("plusHealthHeight", 12), opt("plusPowerHeight", 4)














    local plateH = (self.db and self.optionIndex and self.PlusRowHeight)
        and self:PlusRowHeight()
        or (self.tokens.space.sm + (self.PlusNameRow and self:PlusNameRow() or self.plusNameRow or 24) + hh
            + (ph > 0 and (self.tokens.space.xs + ph) or 0) + self.tokens.space.sm)




    local plateW = (self.PlusPlateWidth and self:PlusPlateWidth(false)) or opt("plusWidth", 232)
    local strip = opt("dpsStripOn", true) and opt("dpsStripHeight", 20) or 0



    if self.db and self.optionIndex and self.PlusBelow then strip = self:PlusBelow() end


















    local dockBase = self:DockBase({ width = width, height = height })






    local snapSlack = (self.PixelSnapOn and self:PixelSnapOn())
        and self:PhysicalPixel(UIParent) / 2 or 0





    local function guards(ds)
        local top = dockBase + (DOCK.top + DOCK.armClear) * ds
        return top + margin + snapSlack + (plateH / 2 + strip) * unitScale,
               DOCK.armL * ds + margin + plateW * unitScale / 2
    end


    local defaultDock = (self.optionIndex and self.optionIndex.dockScale
        and self.optionIndex.dockScale.default) or 0.9
    local baseY, baseDX = guards(math.max(0.3, defaultDock * fit))




    local liveY, liveDX = baseY, baseDX
    local armTop = dockBase + (DOCK.top + DOCK.armClear) * defaultDock * fit
    local live = self:CompassLiveBox(width)
    if live then
        liveY = live.t + margin + snapSlack + (plateH / 2 + strip) * unitScale
        liveDX = live.centreHalf + margin + plateW * unitScale / 2
        armTop = math.max(armTop, live.t)
    end
    local unitY = math.max(height * 0.24, baseY, liveY) + self.db.layoutY





    if self.KeyboardChatBand and self.db and self.optionIndex then
        local safeX = self:SafeInset({ width = width, height = height })
        local free, _, chatTop = self:KeyboardChatBand(width, height, safeX, 128 * fit)
        if free and free < 240 and chatTop then
            unitY = math.max(unitY, chatTop + margin + snapSlack + (plateH / 2 + strip) * unitScale)
        end
    end
    unitY = math.min(unitY, height * 0.62)
    local unitDX = math.max(baseDX, liveDX)


    local safeX = self:SafeInset({ width = width, height = height })
    unitDX = math.min(unitDX, math.max(plateW * unitScale / 2, width / 2 - safeX - plateW * unitScale / 2))
    return { width = width, height = height, fit = fit, dockScale = dockScale,
        unitScale = unitScale, unitY = unitY, unitX = self.db.layoutX,
        unitDX = unitDX, plateH = plateH, armTop = armTop }
end




























A.editModeManagedFrames = {
    MainActionBar = true, MultiBarBottomLeft = true, MultiBarBottomRight = true,
    MainStatusTrackingBarContainer = true, SecondaryStatusTrackingBarContainer = true,
    StanceBar = true, PetActionBar = true, PossessActionBar = true, MainMenuBarVehicleLeaveButton = true,
    MultiBarRight = true, MultiBarLeft = true,
    MicroMenuContainer = true, BagsBar = true, ObjectiveTrackerFrame = true,
}

function A:EditModeOwnsPosition(frame)
    if type(frame) ~= "table" then return false end
    if not A.editModeManagedFrames[self:ObjectName(frame)] then return false end
    if type(frame.IsInDefaultPosition) ~= "function" then return true end
    local value = self:Read(frame.IsInDefaultPosition, 1, frame)
    if value == nil then return true end
    return value == true
end
























A.keyboardStackFrames = { "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MicroMenuContainer", "BagsBar" }




function A:NoteOnce(key, text)
    self.notedOnce = self.notedOnce or {}
    if self.notedOnce[key] then return false end
    self.notedOnce[key] = true
    if self.loginNotesFlushed and self.Print then
        self:Print(text)
    else
        self.pendingNotes = self.pendingNotes or {}
        self.pendingNotes[#self.pendingNotes + 1] = text
    end
    return true
end



function A:MicroRowWanted() return false end



function A:KeyboardStackTop()
    local top
    for _, name in ipairs({ "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight",
        "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer" }) do

        local held = name == "MainStatusTrackingBarContainer" and self.XpLaneHolding and self:XpLaneHolding()
        local box = not held and self:BoxOf(_G[name])
        if box and (not top or box.t > top) then top = box.t end
    end
    local skin = self.KeyboardSkin and self:KeyboardSkin()
    if skin == "bar04" and self.KeyboardBoxes then
        for _, box in ipairs(self:KeyboardBoxes()) do
            if box.id == "MainActionBar" and box.kind == "bar" and (not top or box.t > top) then top = box.t end
        end
    end
    return top
end








function A:BoxOf(frame)
    if type(frame) ~= "table" then return nil end
    if self:Read(frame.IsShown, 1, frame) ~= true then return nil end
    local x, y, w, h = self.kbRectOf(self, frame)
    if not x then return nil end
    local us = (UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)) or 1
    if us <= 0.05 then return nil end
    return { l = x / us, b = y / us, r = (x + w) / us, t = (y + h) / us }
end

function A:OccupiedBoxes()
    local boxes = {}
    local function add(id, kind, box)
        if box then box.id, box.kind = id, kind; boxes[#boxes + 1] = box end
    end
    if self.KeyboardBoxes then
        for _, box in ipairs(self:KeyboardBoxes()) do add(box.id, box.kind, box) end
    end
    add("ChatFrame1", "chat", self:BoxOf(ChatFrame1))
    add("MinimapCluster", "minimap", self:BoxOf(MinimapCluster))
    add("ObjectiveTrackerFrame", "objectives", self:BoxOf(ObjectiveTrackerFrame))
    add("BuffFrame", "auras", self:BoxOf(BuffFrame))
    add("DebuffFrame", "auras", self:BoxOf(DebuffFrame))
    if GamepadMainActionBarFrame then add("GamepadMainActionBarFrame", "compass", self:BoxOf(GamepadMainActionBarFrame)) end
    if self.plusActive and self.plus then
        for _, key in ipairs({ "player", "target", "focus", "pet", "tot", "party" }) do
            local plate = self.plus[key]
            local seat = plate and plate.auiSeat
            if seat and self:Read(plate.IsShown, 1, plate) == true then


                local width = self:Number(UIParent.GetWidth, 1, UIParent) or 1920
                local cx = width / 2 + seat.cx
                add("AdaptiveUIPlus" .. key, "plate",
                    { l = cx - seat.w / 2, r = cx + seat.w / 2, b = seat.cy - seat.h / 2, t = seat.cy + seat.h / 2 })
            end
        end
    end
    return boxes
end











function A:KeyboardChatBand(width, height, safeX, paneH)
    if not (self.KeyboardMode and self:KeyboardMode() and self.KeyboardBoxes) then return nil end
    local tk = self.tokens
    local left, top
    for _, box in ipairs(self:KeyboardBoxes()) do
        if box.t < height * 0.45 then
            if not left or box.l < left then left = box.l end
            if not top or box.t > top then top = box.t end
        end
    end
    if not left then return nil end
    local free = left - safeX - tk.space.sm
    local above = top + tk.space.sm
    return free, above, above + paneH
end

local adapters = {}

function adapters.units(self, state, m)
    local player = PlayerFrame and PlayerFrame.PlayerFrameContent and PlayerFrame.PlayerFrameContent.PlayerFrameContentMain
    local target = TargetFrame and TargetFrame.TargetFrameContent and TargetFrame.TargetFrameContent.TargetFrameContentMain
    if not player or not target or not player.HealthBarsContainer or not target.HealthBarsContainer then return false end
    if not player.HealthBarsContainer.HealthBar or not target.HealthBarsContainer.HealthBar then return false end









    return true
end
















function adapters.actions(self, state, m)
    self.keyboardRowOwner = self.keyboardRowOwner or {}
    for _, row in ipairs(A.actionBarRows) do self.keyboardRowOwner[row[2]] = "editmode" end

    self:SettleHandsOff()



    if self.db and self.db.setupDone == true
        and self.GetOption and self.optionIndex and self.optionIndex.keyboardLift and self:GetOption("keyboardLift") == true
        and self.KeyboardSkinOn and self:KeyboardSkinOn() and self.KeyboardBoxes then


        local rect = self.KeyboardSlabRect and self.kbBars and self:KeyboardSlabRect(self.kbBars[1])
        local under = rect and (rect.rise or 0) > 0
        for _, box in ipairs(under and {} or self:KeyboardBoxes()) do
            if box.id == "MainActionBar" and box.b < -0.01 then under = true; break end
        end
        if under then
            self:NoteOnce("keyboardLift", "keyboard bar: there is no room under the action bar for its art -- raise the "
                .. "action bar a few pixels in Edit Mode (Esc > Edit Mode)")
        end
    end
    return false
end








A.xpProbeNames = { "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer",
    "StatusTrackingBarManager", "MainMenuExpBar", "ReputationWatchBar", "MainMenuBarExpBar",
    "ExhaustionTick", "HonorWatchBar", "PetExpBar" }
A.xpProbePattern = { "StatusTracking", "ExpBar", "ExperienceBar", "XPBar", "Reputation", "Honor", "Exhaustion" }
function A:XpProbe(emit)
    emit = emit or function(line) self:Print(line) end
    local out = {}
    local function say(line) out[#out + 1] = line; emit(line) end
    local function num(v) return v and string.format("%.1f", v) or "?" end
    local function describe(label, frame)
        if type(frame) ~= "table" then return end
        local kind = self:Text(frame.GetObjectType, 1, frame) or "?"
        local shown = self:Read(frame.IsShown, 1, frame)
        local visible = self:Read(frame.IsVisible, 1, frame)
        local w = self:Number(frame.GetWidth, 1, frame)
        local h = self:Number(frame.GetHeight, 1, frame)
        local a = self:Number(frame.GetAlpha, 1, frame)
        local parent = type(frame.GetParent) == "function" and select(2, pcall(frame.GetParent, frame)) or nil
        local anchor = "?"
        if type(frame.GetPoint) == "function" then
            local ok, p1, rel, p3, x, y = pcall(frame.GetPoint, frame, 1)
            if ok and type(p1) == "string" then
                anchor = string.format("%s %s %s %s %s", p1, tostring(self:ObjectName(rel) or "?"), tostring(p3),
                    num(self:IsPublic(x) and x or nil), num(self:IsPublic(y) and y or nil))
            end
        end
        say(string.format("  %s [%s] shown %s visible %s alpha %s size %s x %s parent %s at %s", label, kind,
            tostring(shown), tostring(visible), num(a), num(w), num(h), tostring(self:ObjectName(parent) or "?"), anchor))
        if type(frame.GetMinMaxValues) == "function" then
            local ok, lo, hi = pcall(frame.GetMinMaxValues, frame)
            local okV, v = pcall(frame.GetValue, frame)
            say(string.format("    bar %s .. %s value %s", ok and self:IsPublic(lo) and tostring(lo) or "secret/?",
                ok and self:IsPublic(hi) and tostring(hi) or "secret/?", okV and self:IsPublic(v) and tostring(v) or "secret/?"))
        end
    end
    say("xpprobe: input mode " .. tostring(self.ClickInputMode and self:ClickInputMode() or "?")
        .. " | keyboard skin " .. tostring(self.KeyboardSkin and self:KeyboardSkin() or "?")
        .. " | compass ground " .. tostring(self:CompassGroundMode()) .. " | xpLane " .. tostring(self:GetOption("xpLane")))
    local seen = {}
    for _, name in ipairs(A.xpProbeNames) do
        local frame = _G[name]
        if type(frame) == "table" then
            seen[frame] = true
            describe(name, frame)
            for i, child in ipairs(type(frame.bars) == "table" and frame.bars or {}) do
                if type(child) == "table" then
                    seen[child] = true
                    describe(string.format("%s.bars[%d] %s", name, i, tostring(self:ObjectName(child) or "")), child)
                    if type(child.StatusBar) == "table" then describe("    .StatusBar", child.StatusBar) end
                end
            end
        else
            say("  " .. name .. ": not on this client")
        end
    end




    local extra = 0
    for _, parent in ipairs({ _G.UIParent, _G.GamepadMainActionBarFrame }) do
        if type(parent) == "table" and type(parent.GetChildren) == "function" then
            local ok, kids = pcall(function() return { parent:GetChildren() } end)
            for _, frame in ipairs(ok and kids or {}) do
                if extra >= 12 then break end
                local name = type(frame) == "table" and not seen[frame] and self:ObjectName(frame)
                if type(name) == "string" then
                    for _, pattern in ipairs(A.xpProbePattern) do
                        if name:find(pattern, 1, true) then
                            extra = extra + 1
                            seen[frame] = true
                            describe(name, frame)
                            break
                        end
                    end
                end
            end
        end
    end
    local function call(label, fn, ...)
        if type(fn) ~= "function" then return say("  " .. label .. ": n/a") end
        local res = { pcall(fn, ...) }
        if not res[1] then return say("  " .. label .. ": error") end
        local parts = {}
        for i = 2, math.min(#res, 5) do
            parts[#parts + 1] = self:IsPublic(res[i]) and tostring(res[i]) or "secret"
        end
        say("  " .. label .. ": " .. table.concat(parts, ", "))
    end
    call("UnitLevel", _G.UnitLevel, "player")
    call("GetMaxPlayerLevel", _G.GetMaxPlayerLevel)
    call("IsXPUserDisabled", _G.IsXPUserDisabled)
    call("UnitXP / UnitXPMax", function() return _G.UnitXP("player"), _G.UnitXPMax("player") end)
    call("GetXPExhaustion", _G.GetXPExhaustion)
    call("GetWatchedFactionInfo", _G.GetWatchedFactionInfo)
    call("UnitHonor / UnitHonorMax", function() return _G.UnitHonor("player"), _G.UnitHonorMax("player") end)
    say("xpprobe: done (" .. #out .. " lines). Saved for /aui inspect: run it in the other input mode too, "
        .. "then /aui inspect and /reload.")







    local mode = (self.GamepadBarsShown and self:GamepadBarsShown()) and "gamepad" or "keyboard"
    self.xpProbeByMode = self.xpProbeByMode or {}
    self.xpProbeByMode[mode] = out
    return out
end







local MAP_HALF, MAP_TOP, MAP_DX, CARD_TOP = 99, 44, 10, 26
















A.mapButtonSeats = { "Tracking", "GameTimeFrame", "InstanceDifficulty", "TimeManagerClockButton" }
function A:MapButtonFrames()
    return {
        Tracking = MinimapCluster and MinimapCluster.Tracking,
        GameTimeFrame = _G.GameTimeFrame,
        InstanceDifficulty = MinimapCluster and MinimapCluster.InstanceDifficulty,
        TimeManagerClockButton = _G.TimeManagerClockButton,
        TimeManagerClockTicker = _G.TimeManagerClockTicker,
    }
end

function A:SeatMapButtons(state, map, g)
    local frames = self:MapButtonFrames()
    if not g then
        for _, name in ipairs(A.mapButtonSeats) do
            local f = frames[name]
            if type(f) == "table" and state.properties and state.properties[f] and state.properties[f].geometry
                and self:CanWrite("place", f) then
                self:ReleaseProperty(state, f, "geometry")
            end
        end
        return
    end
    local ms = self:Number(map.GetEffectiveScale, 1, map)
    local function k(f)
        local fs = self:Number(f.GetEffectiveScale, 1, f)
        if not ms or not fs or fs <= 0.01 or ms <= 0.01 then return 1 end
        return ms / fs
    end
    local inset = self.mapBase.inset
    local ok, err = pcall(function()
        local tracking = frames.Tracking
        if type(tracking) == "table" and type(tracking.GetNumPoints) == "function" then
            local s = k(tracking)




            local dx, dy = 0, 0
            local button = tracking.Button
            if type(button) == "table" then
                local tw, th = self:Number(tracking.GetWidth, 1, tracking), self:Number(tracking.GetHeight, 1, tracking)
                local bw, bh = self:Number(button.GetWidth, 1, button), self:Number(button.GetHeight, 1, button)
                if tw and bw and tw > bw and tw - bw < 16 then dx = (tw - bw) / 2 end
                if th and bh and th > bh and th - bh < 16 then dy = (th - bh) / 2 end
            end

            self:PlaceNative(state, tracking, "TOPLEFT", map, "TOPLEFT", inset * s - dx, -((g.trackY or inset) * s - dy))
        end
        local cal = frames.GameTimeFrame
        local calH = 20
        if type(cal) == "table" and type(cal.GetNumPoints) == "function" then
            local s = k(cal)
            self:PlaceNative(state, cal, "TOPRIGHT", map, "TOPRIGHT", -inset * s, -inset * s)
            local h = self:Number(cal.GetHeight, 1, cal)
            if h and h > 0 and h < 64 then calH = h / s end
        end
        local diff = frames.InstanceDifficulty
        if type(diff) == "table" and type(diff.GetNumPoints) == "function" then
            local s = k(diff)
            self:PlaceNative(state, diff, "TOPRIGHT", map, "TOPRIGHT", -inset * s, -(inset + calH + 2) * s)
        end
        local clock = frames.TimeManagerClockButton
        if type(clock) == "table" and type(clock.GetNumPoints) == "function" then
            local s = k(clock)





            local w = self.mapBase.clockW
            local ticker = frames.TimeManagerClockTicker
            local sw = type(ticker) == "table" and self:Number(ticker.GetStringWidth, 1, ticker)
            if sw and sw > 4 and sw < 200 then
                local ts = k(ticker) / s
                w = math.floor(sw / (ts > 0.01 and ts or 1) / s + 0.5) + 2
            end

            self:PlaceNative(state, clock, "RIGHT", map, "BOTTOMLEFT", g.clockR * s, (g.clockY or g.coordY) * s, nil,
                w * s, (g.clockH or g.coordH) * s)
        end
    end)
    self.mapButtonSeatError = (not ok) and tostring(err) or nil
end


A.minimapCard = { half = MAP_HALF, top = MAP_TOP, dx = MAP_DX, cardTop = CARD_TOP }
function adapters.minimap(self, state, m)
    if not MinimapCluster then return false end
    local tokens = self.tokens
    local scale = math.max(0.5, m.fit * 0.95 * self:GetOption("minimapScale"))
    local asked = scale
    local safeX, safeY = self:SafeInset(m)










    local above, below, side = CARD_TOP, CARD_TOP, tokens.space.sm
    if self.MapPainted and self:MapPainted() then
        local g = self:MapCardGeometry(2 * MAP_HALF, 2 * MAP_HALF)
        above, below, side = g.top, g.bottom, g.right
    end
    local gap = safeX
    local tracker = ObjectiveTrackerFrame
    if tracker and type(tracker.GetRight) == "function" then
        local right = self:Number(tracker.GetRight, 1, tracker)


        if right then right = right * (self:Number(tracker.GetScale, 1, tracker) or 1) end
        if right and right > m.width * 0.5 and right <= m.width + 1 then
            gap = math.max(tokens.space.sm, m.width - right)
        end
    end
    if tracker and type(tracker.GetTop) == "function" then








        local top = self:Number(tracker.GetTop, 1, tracker)
        if top then top = top * (self:Number(tracker.GetScale, 1, tracker) or 1) end
        if top and top > m.height * 0.25 and top <= m.height + 1 then
            local room = (m.height - top) - safeY - tokens.space.sm


            local cardH = above + 2 * MAP_HALF + below
            if room > 0 then scale = math.max(0.5, math.min(scale, room / cardH)) end
        end
    end



    local ox, oy = self:MoverOffset("minimap")

    self.mapCardCap = (scale < asked - 0.0005) and { asked = asked, got = scale } or nil
    local x = -(gap + (side + MAP_HALF + MAP_DX) * scale) + ox
    local y = -safeY + (MAP_TOP - above) * scale + oy
    self:PlaceNative(state, MinimapCluster, "TOP", UIParent, "TOPRIGHT", x / scale, y / scale, scale)



    local map = MinimapCluster.MinimapContainer and MinimapCluster.MinimapContainer.Minimap
    local plaque = self.MapOnPlaque and self:MapOnPlaque()


    local base = plaque and self:MapBaseLike()
    if map then self:SeatMapButtons(state, map, base and self:MapPlaqueGeometry(2 * MAP_HALF, 2 * MAP_HALF) or nil) end
    if plaque and map then










        local g = self:MapPlaqueGeometry(2 * MAP_HALF, 2 * MAP_HALF)
        if MinimapCluster.BorderTop then

            self:PlaceNative(state, MinimapCluster.BorderTop, "LEFT", map, "BOTTOMLEFT", g.textX - self.mapBase.zoneX, g.zoneY)
        end




        state.plaqueSized = state.plaqueSized or setmetatable({}, { __mode = "k" })
        local function sizeOnce(frame, w, h)
            local sig = string.format("%.3f|%.3f", w, h)
            if state.plaqueSized[frame] == sig then return end
            self:SizeNative(state, frame, w, h)
            state.plaqueSized[frame] = sig
        end
        local ok, err = pcall(function()
            local zone = MinimapCluster.ZoneTextButton
            if zone then sizeOnce(zone, g.textW, g.zoneH) end
            if MinimapZoneText then
                sizeOnce(MinimapZoneText, g.textW - 4, g.zoneH)


                self.mapZoneBoxW = not g.shelf and (g.textW - 4) or nil
            end
            local coords = MinimapCluster.MinimapContainer.PlayerCoords
            if coords then


                self:PlaceNative(state, coords, "LEFT", map, "BOTTOMLEFT", g.textX, g.coordY, nil,
                    g.coordW, g.coordH)
            end
        end)
        self.mapPlaqueSeatError = (not ok) and tostring(err) or nil
        return true
    end

    if map then
        local coords = MinimapCluster.MinimapContainer.PlayerCoords
        if coords and self:CanWrite("place", coords) then self:ReleaseProperty(state, coords, "geometry") end
        local zone = MinimapCluster.ZoneTextButton
        if zone and self:CanWrite("place", zone) then self:ReleaseProperty(state, zone, "size") end
        if MinimapZoneText and self:CanWrite("place", MinimapZoneText) then
            self:ReleaseProperty(state, MinimapZoneText, "size")
        end
        if state.plaqueSized then
            if zone then state.plaqueSized[zone] = nil end
            if MinimapZoneText then state.plaqueSized[MinimapZoneText] = nil end
        end
    end
    if MinimapCluster.BorderTop and map then
        self:PlaceNative(state, MinimapCluster.BorderTop, "BOTTOMLEFT", map, "TOPLEFT", 28, 4)
    end
    return true
end

function adapters.objectives(self, state, m)
    if not ObjectiveTrackerFrame then return false end































    return false
end

function adapters.chat(self, state, m)
    if not ChatFrame1 then return false end








    local tk = self.tokens
    local safeX, safeY = self:SafeInset(m)


    local free = m.width / 2 - (DOCK.spread + DOCK.armL) * m.dockScale - safeX - tk.space.sm
    local above = self:DockBase(m) + DOCK.height * m.dockScale + tk.space.sm









    local paneH = 128 * m.fit
    local plateLeft
    local kbFree, kbAbove = self:KeyboardChatBand(m.width, m.height, safeX, paneH)
    if kbFree then
        free, above = kbFree, kbAbove




        for _, box in ipairs(self:OccupiedBoxes()) do
            if box.kind == "plate" and box.b < above + paneH + tk.space.sm and box.t > above then
                if not plateLeft or box.l < plateLeft then plateLeft = box.l end
            end
        end
    end
    local width = math.max(240, math.min(390 * m.fit, free))
    local y = safeY + tk.space.xl + tk.space.xs
    if width > free then
        y = above
        if plateLeft then width = math.max(240, math.min(width, plateLeft - safeX - tk.space.sm)) end
    end

    local ox, oy = self:MoverOffset("chat")



    local cs = self:MoverScale("chat")
    self:PlaceNative(state, ChatFrame1, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", (safeX + ox) / cs, (y + oy) / cs,
        cs, width / cs, paneH / cs)
    return true
end














A.auraFrameNames = { "BuffFrame", "DebuffFrame" }

function adapters.auras()
    return false
end






function A:ReapplyLayoutAdapter(key)
    if self:IsCombat() or not self.db or not self.db.layout then return false end
    if self.editModeActive or not self.auditedSink then return false end
    local adapter = adapters[key]
    local state = self.layoutStates and self.layoutStates[key]
    if not adapter or not state or state.failed or not self.db.skins[key] then return false end
    if self.nativeSkins and self.nativeSkins[key] and self.nativeSkins[key].failed then return false end
    self.applyingLayout = true
    local ok, applied = pcall(adapter, self, state, self:LayoutMetrics())
    self.applyingLayout = nil
    return ok and applied == true
end

function A:ApplyAuraAnchor() return self:ReapplyLayoutAdapter("auras") end










function adapters.tooltips()
    return false
end

function A:RestoreLayout()
    if self:IsCombat() then self.layoutDirty = true; return end
    for _, state in pairs(self.layoutStates or {}) do
        self:RestoreNativeModule(state)
        state.active = false
    end
    self.unitIntegrated = false
    self.plusActive = false
    if self.plus then self.plus.player:Hide(); self.plus.target:Hide() end
    self:SyncIntegratedHUD()
end

function A:RefreshLayout()
    if not self.db then return end
    if self:IsCombat() then self.layoutDirty = true; return end
    self.layoutDirty = false



    pcall(self.ApplyCamera, self)
    self:RefreshTheme()

    self:ApplyInfo()
    self:ApplyCastBars()
    self:CastFallbackNotices()
    if not self.db.layout or not self.auditedSink or self.editModeActive then self:RestoreLayout(); return end
    self.layoutStates = self.layoutStates or {}
    local metrics = self:LayoutMetrics()





    local order = {}
    for key in pairs(adapters) do if key ~= "actions" then order[#order + 1] = key end end
    table.sort(order)
    if adapters.actions then table.insert(order, 1, "actions") end
    for _, key in ipairs(order) do
        local adapter = adapters[key]
        local state = self.layoutStates[key]
        if not state then
            state = { changes = {}, decorations = {} }
            self.layoutStates[key] = state
        end
        if not self.db.skins[key] or state.failed or (self.nativeSkins[key] and self.nativeSkins[key].failed) then
            self:RestoreNativeModule(state)
            state.active = false
        else
            self.applyingLayout = true
            local ok, active = pcall(adapter, self, state, metrics)
            self.applyingLayout = nil
            if not ok then
                state.failed = true
                self:RestoreNativeModule(state)
                state.active = false
            else
                state.active = active == true
            end
        end



        if key == "actions" and self.layoutDirty then
            self.layoutDirty = false
            metrics = self:LayoutMetrics()
        end
        self:Note("layout " .. key, state.restoreFailed and "restore rejected: reload required"
            or (state.failed and "native fallback until reload" or (state.active and "integrated" or "native layout")))
    end
    self.unitIntegrated = self.layoutStates.units.active == true


    local plusState = self.layoutStates.plus
    if not plusState then plusState = { changes = {}, decorations = {} }; self.layoutStates.plus = plusState end
    self.applyingLayout = true
    local ok = pcall(self.ApplyPlusUnits, self, plusState, metrics)
    self.applyingLayout = nil
    if not ok then
        self.plusFailed = true
        self.plusActive = false
        self:RestoreNativeModule(plusState)
        if self.plus then self.plus.player:Hide(); self.plus.target:Hide() end
        self:Note("unit frames", "Plus rejected; Lite until reload")
    end





    self:ApplyCastBars()


    pcall(self.ApplyDamageStrip, self)
    self:SyncIntegratedHUD()
end

function A:ObserveLayoutWriters()
    if type(hooksecurefunc) ~= "function" then return end
    self.layoutHooks = self.layoutHooks or {}
    local function observe(object, method)
        if not object or type(object[method]) ~= "function" then return end
        local id = tostring(object) .. method
        if self.layoutHooks[id] then return end
        local ok = pcall(hooksecurefunc, object, method, function()
            if not A.applyingLayout then A.layoutDirty = true; A.nativeDirty = true end
        end)
        if ok then self.layoutHooks[id] = true end
    end
    observe(GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit, "RefreshCompactLayout")




    observe(WorldMapFrame, "OnShow")
    observe(EditModeManagerFrame, "UpdateLayoutInfo")
    observe(_G, "SharedTooltip_SetBackdropStyle")
    self:ObserveGamepadShapes()



    if self.ObserveKeyboardBars then self:ObserveKeyboardBars() end

end

function A:SetReplacementLayout(enabled)
    self.db.layout = enabled
    self.layoutDirty = true
    self:Changed()
end

function A:RestorePreviousHUD()
    if type(self.db.previousLayout) == "table" then
        for _, key in ipairs({ "scale", "dock", "x", "y", "opacity", "style", "casts", "enabled" }) do
            local value = self.db.previousLayout[key]
            if value ~= nil then self.db[key] = value end
        end
    end
    self:SetReplacementLayout(false)
end
