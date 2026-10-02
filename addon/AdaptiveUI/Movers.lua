local _, A = ...













































A.moverList = {
    { id = "plusPlayer", key = "pos.plusPlayer", label = "Player plate", scaleKey = "scale",
      frame = function(self) return self.plus and self.plus.player end },
    { id = "plusTarget", key = "pos.plusTarget", label = "Target plate",
      frame = function(self) return self.plus and self.plus.target end },
    { id = "plusFocus", key = "pos.plusFocus", label = "Focus plate",
      frame = function(self) return self.plus and self.plus.focus end },
    { id = "plusPet", key = "pos.plusPet", label = "Pet plate",
      frame = function(self) return self.plus and self.plus.pet end },
    { id = "plusTot", key = "pos.plusTot", label = "Target-of-target plate",
      frame = function(self) return self.plus and self.plus.tot end },
    { id = "plusParty", key = "pos.plusParty", label = "Party plates",
      frame = function(self) return self.plus and self.plus.party end },





















    { id = "actionCompass", key = "pos.actionCompass", label = "Action bars (gamepad)", native = true, scaleKey = "dockScale",
      handleStrata = "HIGH",
      frame = function(self) return GamepadMainActionBarFrame end },















    { id = "compassTop", key = "pos.compassTop", label = "Gamepad up arm", native = true,
      compassArm = true,
      frame = function(self)
          local page = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
          return page and page.TopCenteredAnchor
      end },
    { id = "compassLeft", key = "pos.compassLeft", label = "Gamepad left arm", native = true,
      compassArm = true,
      frame = function(self)
          local page = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
          return page and page.LeftCenteredAnchor
      end },
    { id = "compassRight", key = "pos.compassRight", label = "Gamepad right arm", native = true,
      compassArm = true,
      frame = function(self)
          local page = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
          return page and page.RightCenteredAnchor
      end },
    { id = "compassBottom", key = "pos.compassBottom", label = "Gamepad down arm", native = true,
      compassArm = true,
      frame = function(self)
          local page = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
          return page and page.BottomCenteredAnchor
      end },












    { id = "actionBar1", key = "pos.actionBar1", label = "Action bar 1 (keyboard)", native = true, scaleKey = "dockScale",
      frame = function(self) return MainActionBar end,


      anchored = function(self)
          return self:EditModeOwnsPosition(MainActionBar)
              and not (self.keyboardRowOwner and self.keyboardRowOwner.actionBar1 == "centred")
      end,
      anchoredNote = "  Edit Mode owns it: drag it there first" },
    { id = "actionBar2", key = "pos.actionBar2", label = "Action bar 2 (keyboard)", native = true,
      frame = function(self) return MultiBarBottomLeft end,
      anchored = function(self) return self:EditModeOwnsPosition(MultiBarBottomLeft) end,
      anchoredNote = "  Edit Mode owns it: drag it there first" },
    { id = "actionBar3", key = "pos.actionBar3", label = "Action bar 3 (keyboard)", native = true,
      frame = function(self) return MultiBarBottomRight end,
      anchored = function(self) return self:EditModeOwnsPosition(MultiBarBottomRight) end,
      anchoredNote = "  Edit Mode owns it: drag it there first" },








    { id = "statusBar", key = "pos.statusBar", label = "Experience bar (keyboard)", native = true,
      frame = function(self) return MainStatusTrackingBarContainer end,
      anchored = function(self)
          return not self:KeyboardCentreWanted() or self:EditModeOwnsPosition(MainStatusTrackingBarContainer)
      end,
      anchoredNote = "  Edit Mode owns it: drag it there first" },










    { id = "chat", key = "pos.chat", label = "Chat", native = true,
      frame = function(self) return ChatFrame1 end },
    { id = "minimap", key = "pos.minimap", label = "Minimap", native = true, scaleKey = "minimapScale",
      frame = function(self) return MinimapCluster end },
    { id = "objectives", key = "pos.objectives", label = "Objectives", native = true,
      frame = function(self) return ObjectiveTrackerFrame end,
      anchored = function(self) return self:EditModeOwnsPosition(ObjectiveTrackerFrame) end,
      anchoredNote = "  Edit Mode owns it: drag it there first",





      anchoredHelp = "Blizzard re-places the objectives on every fight while they sit in the default spot. Move them once in Edit Mode (Esc > Edit Mode), then this mover nudges them and they stay put." },






    { id = "auras", key = "pos.auras", label = "Buffs / debuffs", native = true,
      frame = function(self) return BuffFrame end,
      handleTo = function(self) return DebuffFrame end },



    { id = "castPlayer", key = "pos.castPlayer", label = "Player cast bar (custom)",
      frame = function(self) return self.castBars and self.castBars.player end,
      anchored = function(self) return self:CastAnchored("player") end },
    { id = "castTarget", key = "pos.castTarget", label = "Target cast bar (custom)",
      frame = function(self) return self.castBars and self.castBars.target end,
      anchored = function(self) return self:CastAnchored("target") end },
    { id = "castFocus", key = "pos.castFocus", label = "Focus cast bar (custom)",
      frame = function(self) return self.castBars and self.castBars.focus end },
    { id = "compact", key = "pos.compact", label = "Resource strip",
      frame = function(self) return self.compactHUD end },


    { id = "infoBar", key = "pos.infoBar", label = "Info bar",
      frame = function(self) return self.info and self.info.bar end },
    { id = "infoFps", key = "pos.infoFps", label = "Frame rate strip", info = "fps",
      frame = function(self) return self.info and self.info.strips.fps end },
    { id = "infoLatency", key = "pos.infoLatency", label = "Latency strip", info = "latency",
      frame = function(self) return self.info and self.info.strips.latency end },
    { id = "infoDurability", key = "pos.infoDurability", label = "Durability strip", info = "durability",
      frame = function(self) return self.info and self.info.strips.durability end },
    { id = "infoClock", key = "pos.infoClock", label = "Clock strip", info = "clock",
      frame = function(self) return self.info and self.info.strips.clock end },
    { id = "infoGold", key = "pos.infoGold", label = "Gold strip", info = "gold",
      frame = function(self) return self.info and self.info.strips.gold end },
    { id = "infoBags", key = "pos.infoBags", label = "Bag space strip", info = "bags",
      frame = function(self) return self.info and self.info.strips.bags end },
    { id = "infoCoords", key = "pos.infoCoords", label = "Coordinates strip", info = "coords",
      frame = function(self) return self.info and self.info.strips.coords end },

    { id = "legacyHud", key = "pos.legacyHud", label = "Legacy HUD",
      frame = function(self) return self.hud end },


    { id = "plusFocustarget", key = "pos.plusFocustarget", label = "Focus-target plate",
      frame = function(self) return self.plus and self.plus.focustarget end },
    { id = "plusFocustargettarget", key = "pos.plusFocustargettarget", label = "Focus-target's-target plate",
      frame = function(self) return self.plus and self.plus.focustargettarget end },
}









local EDIT_MODE_HELP = "Edit Mode places this bar while it sits in its default spot. Move it once in Edit Mode "
    .. "(Esc > Edit Mode), then this mover nudges it and it stays put."
local function extraBarMover(id, frameName, label)
    local entry = { id = id, key = "pos." .. id, label = label, native = true, extraBar = true,
        frame = function() return _G[frameName] end,

        anchored = function(self) return self:EditModeOwnsPosition(_G[frameName]) end,
        anchoredNote = "  Edit Mode owns it: drag it there first",
        anchoredHelp = EDIT_MODE_HELP }
    A.moverList[#A.moverList + 1] = entry
end
extraBarMover("actionBar4", "MultiBarRight", "Action bar 4")
extraBarMover("actionBar5", "MultiBarLeft", "Action bar 5")
extraBarMover("actionBar6", "MultiBar5", "Action bar 6")
extraBarMover("actionBar7", "MultiBar6", "Action bar 7")
extraBarMover("actionBar8", "MultiBar7", "Action bar 8")
extraBarMover("stanceBar", "StanceBar", "Stance bar")
extraBarMover("petBar", "PetActionBar", "Pet bar")
extraBarMover("possessBar", "PossessActionBar", "Possess bar")

for _, entry in ipairs(A.moverList) do
    if entry.id == "actionBar2" or entry.id == "actionBar3" then
        entry.extraBar = true
        entry.anchoredHelp = entry.anchoredHelp or EDIT_MODE_HELP
    end
end







local EDIT_MODE_OWNS = "Blizzard's Edit Mode places and sizes this bar (Esc > Edit Mode). AdaptiveUI no longer "
    .. "moves Blizzard's action bars: moving them from an addon broke the buttons' cooldowns in combat."
local BLIZZARD_OWNS_PAD = "Blizzard places the controller bars. AdaptiveUI no longer moves or sizes them: moving "
    .. "them from an addon broke the buttons' cooldowns in combat."
A.handsOffMovers = {
    actionCompass = BLIZZARD_OWNS_PAD, compassTop = BLIZZARD_OWNS_PAD, compassLeft = BLIZZARD_OWNS_PAD,
    compassRight = BLIZZARD_OWNS_PAD, compassBottom = BLIZZARD_OWNS_PAD,
    actionBar1 = EDIT_MODE_OWNS, actionBar2 = EDIT_MODE_OWNS, actionBar3 = EDIT_MODE_OWNS,
    actionBar4 = EDIT_MODE_OWNS, actionBar5 = EDIT_MODE_OWNS, actionBar6 = EDIT_MODE_OWNS,
    actionBar7 = EDIT_MODE_OWNS, actionBar8 = EDIT_MODE_OWNS, stanceBar = EDIT_MODE_OWNS,
    petBar = EDIT_MODE_OWNS, possessBar = EDIT_MODE_OWNS,
    statusBar = "Blizzard's Edit Mode places the experience bar (Esc > Edit Mode). AdaptiveUI no longer moves it.",

    auras = "Blizzard's Edit Mode places and sizes the buff and debuff rows (Esc > Edit Mode). AdaptiveUI no "
        .. "longer moves them: their timers run on values an addon's write could break.",
    objectives = "Blizzard's Edit Mode places and sizes the objectives (Esc > Edit Mode). AdaptiveUI no longer "
        .. "moves them: they are laid out together with the action bars.",
}
for _, entry in ipairs(A.moverList) do
    local why = A.handsOffMovers[entry.id]
    if why then
        entry.anchored = function() return true end
        entry.anchoredNote = entry.compassArm and "  Placed by Blizzard"
            or (entry.id == "actionCompass" and "  Placed by Blizzard") or "  Set in Edit Mode"
        entry.anchoredHelp = why
        entry.handsOff = true
    end
end

local function moverFor(id)
    for _, entry in ipairs(A.moverList) do if entry.id == id then return entry end end
end

function A:MoverOffset(id)
    local entry = moverFor(id)
    local value = entry and self:GetOption(entry.key)
    if not value then return 0, 0 end
    return value[1], value[2]
end

function A:MoverStep()
    return tonumber(self:GetOption("moverStep")) or self.tokens.space.xs
end

function A:SnapMover(value)
    if not self:GetOption("moverSnap") then return math.floor(value + 0.5) end
    local step = self:MoverStep()
    return math.floor(value / step + 0.5) * step
end



local function plateBase(self, id, m)
    if id:find("^info") then return self:InfoBase(id, m) end
    if id:find("^cast") then return self:CastBase(id, m) end
    return self:PlusBase(id, m)
end







function A:ClampNativeMover(entry, ox, oy, m)
    local frame = entry.frame(self)
    local margin = self.tokens.margin
    ox = math.max(-(m.width - 2 * margin), math.min(m.width - 2 * margin, ox))
    oy = math.max(-(m.height - 2 * margin), math.min(m.height - 2 * margin, oy))
    if not frame or type(frame.GetLeft) ~= "function" or type(frame.GetBottom) ~= "function" then
        return ox, oy
    end





    local fs = self:Number(frame.GetEffectiveScale, 1, frame)
    local us = (UIParent and self:Number(UIParent.GetEffectiveScale, 1, UIParent)) or 1
    local k = (fs and us > 0.05) and (fs / us) or 1
    local left, bottom = self:Number(frame.GetLeft, 1, frame), self:Number(frame.GetBottom, 1, frame)
    local w, h = self:Number(frame.GetWidth, 1, frame), self:Number(frame.GetHeight, 1, frame)
    if not left or not bottom or not w or not h then return ox, oy end
    left, bottom, w, h = left * k, bottom * k, w * k, h * k


    local cx, cy = self:MoverOffset(entry.id)
    local l, b = left + (ox - cx), bottom + (oy - cy)
    if l < margin then ox = ox + (margin - l)
    elseif l + w > m.width - margin then ox = ox + ((m.width - margin) - (l + w)) end
    if b < margin then oy = oy + (margin - b)
    elseif b + h > m.height - margin then oy = oy + ((m.height - margin) - (b + h)) end
    return ox, oy
end

function A:ClampMover(id, ox, oy, m)
    m = m or self:LayoutMetrics()
    local entry = moverFor(id)



    if entry and entry.compassArm then return self:ClampCompassArm(id, ox, oy, m) end
    if entry and entry.native then return self:ClampNativeMover(entry, ox, oy, m) end
    local frame = entry and entry.frame(self)
    local bx, by = plateBase(self, id, m)
    if not bx or not frame then
        return math.max(-400, math.min(400, ox)), math.max(-400, math.min(400, oy))
    end
    local margin = self.tokens.margin
    local scale = (id:find("^info") or id:find("^cast")) and 1 or m.unitScale
    local halfW = (self:Number(frame.GetWidth, 1, frame) or 232) * scale / 2
    local halfH = (self:Number(frame.GetHeight, 1, frame) or 54) * scale / 2
    local minX, maxX = -(m.width / 2 - margin - halfW) - bx, (m.width / 2 - margin - halfW) - bx
    local minY, maxY = margin + halfH - by, m.height - margin - halfH - by
    return math.max(minX, math.min(maxX, ox)), math.max(minY, math.min(maxY, oy))
end



function A:ApplyMoverPositions()
    if self:IsCombat() then self.layoutDirty = true; return false end
    local m = self:LayoutMetrics()
    if self.plusActive and self.plus then self:PositionPlusUnits(m) end
    self:SyncIntegratedHUD()
    self:ApplyInfo()
    self:ApplyCastBars()



    for _, key in ipairs({ "auras", "actions", "chat", "minimap", "objectives" }) do
        pcall(self.ReapplyLayoutAdapter, self, key)
    end
    if self.hud then self:ApplyAppearance() end
    self:RefreshMoverHandles()
    return true
end

function A:SetMoverOffset(id, x, y, drag)
    local entry = moverFor(id)
    if not entry then return false, "unknown mover" end
    if entry.info and self:InfoDocked(entry.info) then return false, "docked" end
    if entry.anchored and entry.anchored(self) then return false, "anchored" end
    if not self:CanWrite("mover", entry.frame(self)) then return false, "combat" end
    x, y = self:ClampMover(id, self:SnapMover(x), self:SnapMover(y))
    x, y = self:SnapMover(x), self:SnapMover(y)
    self:SetOption(entry.key, { x, y }, true)
    self:ApplyMoverPositions()
    if not drag then self:RefreshOptionsUI() end
    return true
end

function A:NudgeMover(id, dx, dy)
    local x, y = self:MoverOffset(id)
    local step = self:MoverStep()
    return self:SetMoverOffset(id, x + dx * step, y + dy * step)
end

function A:ResetMover(id)
    return self:SetMoverOffset(id, 0, 0)
end


local function buildHandle(self, entry)
    local h = CreateFrame("Frame", "AdaptiveUIMover_" .. entry.id, UIParent)
    h:SetFrameStrata(entry.handleStrata or "DIALOG")
    h:EnableMouse(false)
    h:Hide()
    h.fill = h:CreateTexture(nil, "BACKGROUND")
    h.fill:SetAllPoints()


    self:Tint(h.fill, "ink", "color", 0.45)
    h.edges = {}
    for i, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local edge = h:CreateTexture(nil, "OVERLAY")
        self:Tint(edge, "accent", "color", 1)
        if side == "TOP" or side == "BOTTOM" then
            edge:SetPoint(side .. "LEFT", h, side .. "LEFT"); edge:SetPoint(side .. "RIGHT", h, side .. "RIGHT")
            edge:SetHeight(2)
        else
            edge:SetPoint("TOP" .. side, h, "TOP" .. side); edge:SetPoint("BOTTOM" .. side, h, "BOTTOM" .. side)
            edge:SetWidth(2)
        end
        h.edges[i] = edge
    end
    h.label = h:CreateFontString(nil, "OVERLAY")
    self:SetThemedFont(h.label, self.tokens.type.body, true)
    h.label:SetPoint("CENTER", h, "CENTER")
    self:Tint(h.label, "text", "text")
    h.label:SetText(entry.label)


    h:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or A:IsCombat() or not A.moversUnlocked then return end




        if entry.anchored and entry.anchored(A) then
            A:Print(entry.label .. ": " .. (entry.anchoredHelp
                or "Blizzard's Edit Mode places this one. Move it once in Edit Mode (Esc > Edit Mode), then this mover works."))
            return
        end
        local cx, cy = GetCursorPosition()
        local x, y = A:MoverOffset(entry.id)
        h.drag = { cx = cx, cy = cy, x = x, y = y }
    end)
    h:SetScript("OnMouseUp", function()
        if h.drag then h.drag = nil; A:RefreshOptionsUI() end
    end)
    h:SetScript("OnUpdate", function()
        local d = h.drag
        if not d then return end
        if A:IsCombat() or not A.moversUnlocked then h.drag = nil; return end
        local cx, cy = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale() or 1
        A:SetMoverOffset(entry.id, d.x + (cx - d.cx) / scale, d.y + (cy - d.cy) / scale, true)
    end)
    return h
end





function A:RefreshMoverGrid()
    local want = self.moversUnlocked and not self:IsCombat()
    local grid = self.moverGrid
    if not want then
        if grid then grid.frame:Hide() end
        return
    end
    local w = math.floor(self:Number(UIParent.GetWidth, 1, UIParent) or 1920)
    local h = math.floor(self:Number(UIParent.GetHeight, 1, UIParent) or 1080)
    if not grid then
        grid = { lines = {} }
        grid.frame = CreateFrame("Frame", "AdaptiveUIMoverGrid", UIParent)
        grid.frame:SetAllPoints(UIParent)
        grid.frame:SetFrameStrata("BACKGROUND")
        grid.frame:EnableMouse(false)
        self.moverGrid = grid
    end
    if grid.w ~= w or grid.h ~= h then
        local step = self.tokens.space.lg
        local index = 0
        local function line(vertical, at, major)
            index = index + 1
            local t = grid.lines[index]
            if not t then t = grid.frame:CreateTexture(nil, "BACKGROUND"); grid.lines[index] = t end
            t:ClearAllPoints()
            self:Tint(t, "accent", "color", major and 0.22 or 0.09)
            if vertical then
                t:SetPoint("TOPLEFT", grid.frame, "TOPLEFT", at, 0); t:SetSize(1, h)
            else
                t:SetPoint("TOPLEFT", grid.frame, "TOPLEFT", 0, -at); t:SetSize(w, 1)
            end
            t:Show()
        end
        for x = 0, w, step do line(true, x, x % (step * 4) == 0) end
        for y = 0, h, step do line(false, y, y % (step * 4) == 0) end
        for i = index + 1, #grid.lines do grid.lines[i]:Hide() end
        grid.w, grid.h = w, h
    end
    grid.frame:Show()
end

function A:RefreshMoverHandles()
    self:RefreshMoverGrid()
    self.moverHandles = self.moverHandles or {}


    local wantHandles = (self.moversUnlocked or self.moversPreview) and not self:IsCombat()
    for _, entry in ipairs(self.moverList) do
        local frame = entry.frame(self)
        local h = self.moverHandles[entry.id]
        if wantHandles and frame and frame:IsShown() then
            if not h then h = buildHandle(self, entry); self.moverHandles[entry.id] = h end




            local far = entry.handleTo and entry.handleTo(self) or nil
            if far and not (type(far.IsShown) == "function" and far:IsShown()) then far = nil end
            h:ClearAllPoints()
            if entry.compassArm then






                local ds = self:LayoutMetrics().dockScale
                local D = self.dock
                h:SetPoint("CENTER", frame, "CENTER")
                h:SetSize((D.inkL + D.inkR) * ds, (D.inkUp + D.inkDown) * ds)
            else
                h:SetPoint("TOPLEFT", frame, "TOPLEFT")
                h:SetPoint("BOTTOMRIGHT", far or frame, "BOTTOMRIGHT")
            end
            h:EnableMouse(self.moversUnlocked == true)
            h:Show()
        elseif h then
            h.drag = nil
            h:EnableMouse(false)
            h:Hide()
        end
    end



    pcall(self.ApplyUnitClicks, self)
end



function A:SetMoverPreview(on)
    self.moversPreview = on and true or false
    self:RefreshMoverHandles()
end

function A:UnlockMovers()
    if self:IsCombat() then self:Print("Movers cannot be unlocked in combat."); return false end
    self.moversUnlocked = true
    self:RefreshMoverHandles()
    return true
end

function A:LockMovers()
    self.moversUnlocked = false
    self:RefreshMoverHandles()
    return true
end

function A:ToggleMovers()
    if self.moversUnlocked then return self:LockMovers() end
    return self:UnlockMovers()
end
