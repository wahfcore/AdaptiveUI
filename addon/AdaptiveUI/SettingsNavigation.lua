local _, A = ...




local M, FULL, COL, COL2 = 16, 408, 200, 224
local function row(index) return -80 - (index - 1) * 44 end
A.dialogGrid = { margin = M, full = FULL, col = COL, col2 = COL2, row = row }



local function dialogSurface(self, frame)
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetAllPoints()
    self:Tint(bg, "ink", "color", 0.98)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "panel~", frame, 0, 0, frame, 0, 0, "raised")
    self:Rule(frame, 0, 0, 440, 2)
    return bg
end

function A:OpenLayoutSettings()
    if self:IsCombat() then self:Print("Open layout settings after combat."); return end
    if not self.layoutSettings then
        local frame = CreateFrame("Frame", "AdaptiveUILayoutSettings", UIParent)
        self.layoutSettings = frame
        frame:SetSize(440, 488)
        frame:SetPoint("CENTER")
        frame:SetClampedToScreen(true)
        frame:SetFrameStrata("DIALOG")
        frame:EnableMouse(true)
        dialogSurface(self, frame)
        self:Label(frame, self.tokens.type.hero, M, -16, FULL):SetText("Adaptive UI / Layout")
        self:Label(frame, self.tokens.type.body, M, -48, FULL):SetText("Layout, unit frame mode and typography.")
        frame.units = self:SettingsButton(frame, "Unit frames: Lite", M, row(1), FULL, function()
            A:SetUnitMode(A.db.unitMode == "plus" and "lite" or "plus")
        end)
        self:SettingsButton(frame, "Enable integrated layout", M, row(2), FULL, function() A:SetReplacementLayout(true) end)
        self:SettingsButton(frame, "Restore Blizzard layout", M, row(3), FULL, function() A:SetReplacementLayout(false) end)
        self:SettingsButton(frame, "Action bar -", M, row(4), COL, function() A:Slash("dockscale " .. (A.db.dockScale - 0.05)) end)
        self:SettingsButton(frame, "Action bar +", COL2, row(4), COL, function() A:Slash("dockscale " .. (A.db.dockScale + 0.05)) end)
        self:SettingsButton(frame, "Text -", M, row(5), COL, function() A:Slash("textscale " .. (A.db.textScale - 0.05)) end)
        self:SettingsButton(frame, "Text +", COL2, row(5), COL, function() A:Slash("textscale " .. (A.db.textScale + 0.05)) end)
        self:SettingsButton(frame, "Unit frames lower", M, row(6), COL, function() A:Slash("unitanchor " .. A.db.layoutX .. " " .. (A.db.layoutY - 20)) end)
        self:SettingsButton(frame, "Unit frames higher", COL2, row(6), COL, function() A:Slash("unitanchor " .. A.db.layoutX .. " " .. (A.db.layoutY + 20)) end)
        self:SettingsButton(frame, "Restore previous HUD profile", M, row(7), FULL, function() A:RestorePreviousHUD() end)
        self:Label(frame, self.tokens.type.caption, M, row(8) + 4, FULL)
            :SetText("Heading font: Appearance tab (Spectral, Barlow or Chakra Petch)\nLayout changes wait until combat ends.")
        self:SettingsButton(frame, "Back to modules", M, row(9), FULL, function() frame:Hide(); A:OpenNativeSettings() end)
        self:MakeMovableWindow(frame, "Layout", 44)
        self:AttachSettingsNavigation(frame)
    end
    if self.settings then self.settings:Hide() end
    if self.nativeSettings then self.nativeSettings:Hide() end
    self:PlaceWindow(self.layoutSettings, "Layout")
    self.layoutSettings:Show()
    self:RefreshNativeSettingsLabels()
end





















A.focusables = setmetatable({}, { __mode = "k" })

function A:AddFocusable(widget, kind)
    self.focusables[widget] = kind or "button"
    return widget
end

local function ancestor(widget, root)
    local f = widget
    while f do
        if f == root then return true end
        f = type(f.GetParent) == "function" and f:GetParent() or nil
    end
    return false
end

local function visible(widget)
    local f = widget
    while f do
        if type(f.IsShown) == "function" and not f:IsShown() then return false end
        f = type(f.GetParent) == "function" and f:GetParent() or nil
    end
    return true
end

local function propagate(frame, value)
    local fn = frame.SetPropagateGamepadInput or frame.SetPropagateKeyboardInput
    if type(fn) == "function" then pcall(fn, frame, value) end
    if type(frame.SetPropagateKeyboardInput) == "function" then pcall(frame.SetPropagateKeyboardInput, frame, value) end
end

function A:GamepadItems(frame)
    local items = {}
    for widget in pairs(self.focusables) do
        if ancestor(widget, frame) and visible(widget) and type(widget.GetCenter) == "function" then
            local cx, cy = widget:GetCenter()
            if type(cx) == "number" and type(cy) == "number" then
                items[#items + 1] = { widget = widget, cx = cx, cy = cy, kind = self.focusables[widget] }
            end
        end
    end
    table.sort(items, function(a, b)
        if math.abs(a.cy - b.cy) > 4 then return a.cy > b.cy end
        return a.cx < b.cx
    end)
    return items
end

function A:GamepadHighlight(frame, widget)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if not nav then return end
    local h = nav.highlight
    if not h then
        h = self:Own(CreateFrame("Frame", nil, frame))
        h:SetFrameStrata("FULLSCREEN_DIALOG")
        h:EnableMouse(false)
        h.edges = {}
        for i, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
            local edge = self:Own(h:CreateTexture(nil, "OVERLAY"))
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












        h.glow = self:EdgeFlash(h, h, "g", 3, 2)
        nav.highlight = h
    end
    local moved = nav.current ~= widget
    nav.current = widget
    if widget then
        local px = math.max(0.34, math.min(4, self:PhysicalPixel(h) * 2))
        for i, edge in ipairs(h.edges) do
            if i <= 2 then edge:SetHeight(px) else edge:SetWidth(px) end
        end



        if h.glow then self:SizeEdgeFlash(h.glow, math.max(3, px * 1.5)) end
        h:ClearAllPoints()
        h:SetPoint("TOPLEFT", widget, "TOPLEFT", -2, 2)
        h:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", 2, -2)
        h:Show()
        if moved and h.glow and self:GetOption("plusFlash") then
            local r, g, b = self:Color("accent")
            self:PlayEdgeFlash(h.glow, r, g, b, 0.9)
        end
    else
        h:Hide()
    end
end

function A:GamepadClear(frame)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if nav then
        nav.current = nil
        if nav.highlight then nav.highlight:Hide() end
    end
end



function A:GamepadMove(frame, direction)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if not nav then return end
    local items = self:GamepadItems(frame)
    if #items == 0 then return end
    local current
    for _, item in ipairs(items) do if item.widget == nav.current then current = item end end
    if not current then self:GamepadHighlight(frame, items[1].widget); return end
    local best, bestScore
    for _, item in ipairs(items) do
        if item ~= current then
            local dx, dy = item.cx - current.cx, current.cy - item.cy
            local rowTolerance = 8
            local score


            if direction == "down" and dy > rowTolerance then score = dy + 3 * math.abs(dx)
            elseif direction == "up" and -dy > rowTolerance then score = -dy + 3 * math.abs(dx)
            elseif direction == "right" and math.abs(dy) <= rowTolerance and dx > 0 then score = dx
            elseif direction == "left" and math.abs(dy) <= rowTolerance and dx < 0 then score = -dx end
            if score and (not bestScore or score < bestScore) then best, bestScore = item, score end
        end
    end




    if nav.edge and (direction == "down" or direction == "up") then
        local target = nav.edge(direction, current.widget, best and best.widget)
        if target then self:GamepadHighlight(frame, target); return end
    end
    if best then self:GamepadHighlight(frame, best.widget) end
end

function A:SetGamepadEdge(frame, fn)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if nav then nav.edge = fn end
end

function A:GamepadActivate(frame)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    local widget = nav and nav.current
    if not widget then self:GamepadMove(frame, "down"); return end
    if self.focusables[widget] == "edit" then
        pcall(widget.SetFocus, widget)
    elseif type(widget.Click) == "function" then
        pcall(widget.Click, widget)
    end
end




function A:SetGamepadBack(frame, fn)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if nav then nav.back = fn end
end

function A:GamepadBack(frame, hardClose)
    for widget, kind in pairs(self.focusables) do
        if kind == "edit" and ancestor(widget, frame) and type(widget.HasFocus) == "function" and widget:HasFocus() then
            widget:ClearFocus()
            return
        end
    end
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if not hardClose and nav and nav.back and nav.back() then return end
    frame:Hide()
end

local DIRECTIONS = { PADDUP = "up", PADDDOWN = "down", PADDLEFT = "left", PADDRIGHT = "right" }

function A:GamepadInput(frame, button)
    if self:IsCombat() then return end
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if not nav then return end
    local handled = true
    if DIRECTIONS[button] then self:GamepadMove(frame, DIRECTIONS[button])
    elseif button == "PAD1" then self:GamepadActivate(frame)
    elseif button == "PAD2" then self:GamepadBack(frame)
    elseif (button == "PADLSHOULDER" or button == "PADRSHOULDER") and nav.shoulder then
        nav.shoulder(button == "PADRSHOULDER" and 1 or -1)




    elseif nav.extra and nav.extra(button, nav.current) then
        handled = true
    else handled = false end
    propagate(frame, not handled)
end

function A:SetGamepadExtra(frame, fn)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if nav then nav.extra = fn end
end

function A:KeyboardInput(frame, key)
    if self:IsCombat() then return end
    if key == "ESCAPE" then
        propagate(frame, false)
        self:GamepadBack(frame, true)
    else
        propagate(frame, true)
    end
end

function A:SetGamepadShoulder(frame, fn)
    local nav = self.gamepadNav and self.gamepadNav[frame]
    if nav then nav.shoulder = fn end
end

function A:AttachSettingsNavigation(frame, onHide)
    self.gamepadNav = self.gamepadNav or {}
    self.gamepadNav[frame] = {}
    pcall(frame.EnableGamePadButton, frame, true)
    pcall(frame.EnableKeyboard, frame, true)
    frame:SetScript("OnGamePadButtonDown", function(_, button) A:GamepadInput(frame, button) end)


    frame:SetScript("OnGamePadButtonUp", function() if not A:IsCombat() then propagate(frame, true) end end)
    frame:SetScript("OnKeyDown", function(_, key) A:KeyboardInput(frame, key) end)
    frame:SetScript("OnKeyUp", function() if not A:IsCombat() then propagate(frame, true) end end)
    frame:SetScript("OnHide", function()
        A:GamepadClear(frame)
        if onHide then onHide() end
    end)
end

function A:RegisterNativeSettingsCategory()
    if self.settingsCategory or self.settingsCategoryFailed or not self:CanWrite("category") then return end
    if not Settings or type(Settings.RegisterCanvasLayoutCategory) ~= "function"
        or type(Settings.RegisterAddOnCategory) ~= "function" then
        self:Note("settings category", "native Settings API unavailable; /aui settings")
        return
    end
    local ok = pcall(function()
        local canvas = CreateFrame("Frame")
        self.settingsCanvas = canvas
        local title = self:Label(canvas, 22, 16, -16, 440)
        title:SetText("AdaptiveUI")
        local description = self:Label(canvas, 15, 16, -55, 540)
        description:SetText("A WoW dad's answer to off-night couch gaming.")

        self:SettingsButton(canvas, "Open AdaptiveUI options", 16, -100, 310, function() A:OpenOptions() end)
        local tip = self:Label(canvas, 15, 16, -156, 540)
        tip:SetText("Tip: bind a key or a controller button to it in Key Bindings > AddOns > AdaptiveUI.")
        self:Trace("category", canvas, "register")
        local category = Settings.RegisterCanvasLayoutCategory(canvas, "AdaptiveUI")
        Settings.RegisterAddOnCategory(category)
        self.settingsCategory = category
        self:Note("settings category", "registered in native Settings")
    end)
    if not ok then
        self.settingsCategoryFailed = true
        if self.settingsCanvas then self.settingsCanvas:Hide() end
        self:Note("settings category", "registration rejected; /aui settings")
    end
end

function A:OpenNativeSettings()
    if self:IsCombat() then self:Print("Open settings after combat. Slash changes can be queued."); return end
    if not self.nativeSettings then
        local frame = CreateFrame("Frame", "AdaptiveUINativeSettings", UIParent)
        self.nativeSettings = frame
        frame:SetSize(440, 576)
        frame:SetPoint("CENTER")
        frame:SetClampedToScreen(true)
        frame:SetFrameStrata("DIALOG")
        frame:EnableMouse(true)
        dialogSurface(self, frame)
        local title = self:Label(frame, self.tokens.type.hero, M, -16, FULL)
        title:SetText("Adaptive UI / Native modules")
        local subtitle = self:Label(frame, self.tokens.type.body, M, -48, FULL)
        subtitle:SetText("Visuals only. Native gameplay remains in control.")
        frame.buttons = {}
        local last = 0
        for i, module in ipairs(self.skinModules) do
            local key = module.key
            frame.buttons[key] = self:SettingsButton(frame, module.label, M, row(i), FULL,
                function() A:SetSkinEnabled(key, not A.db.skins[key]) end)
            last = i
        end
        self:SettingsButton(frame, "Restore native look", M, row(last + 1), COL, function() A:SetSkinEnabled("all", false) end)
        self:SettingsButton(frame, "Enable all styles", COL2, row(last + 1), COL, function() A:SetSkinEnabled("all", true) end)
        self:SettingsButton(frame, "Layout / typography", M, row(last + 2), FULL, function() frame:Hide(); A:OpenLayoutSettings() end)
        self:SettingsButton(frame, "Back to appearance", M, row(last + 3), FULL, function() frame:Hide(); A:OpenSettings() end)
        self:MakeMovableWindow(frame, "Modules", 44)
        self:AttachSettingsNavigation(frame)
    end
    if self.settings then self.settings:Hide() end
    if self.layoutSettings then self.layoutSettings:Hide() end
    self:RefreshNativeSettingsLabels()
    self:PlaceWindow(self.nativeSettings, "Modules")
    self.nativeSettings:Show()
end

function A:RefreshNativeSettingsLabels()
    if self.layoutSettings and self.layoutSettings.units then
        self.layoutSettings.units.title:SetText(self.db.unitMode == "plus"
            and "Unit frames: Plates (custom, display-only)" or "Unit frames: Lite (native, restyled)")
    end
    if not self.nativeSettings then return end
    for _, module in ipairs(self.skinModules) do
        local state = self.nativeSkins and self.nativeSkins[module.key]
        local status = "off"
        if self.db.skins[module.key] then
            if state and state.restoreFailed then status = "reload required"
            elseif not self.auditedSink then status = "unverified build"
            elseif state and state.failed then status = "native fallback"
            elseif not state or state.count == 0 then status = "unavailable"
            else status = "on" end
        end
        self.nativeSettings.buttons[module.key].title:SetText(module.label .. ": " .. status)
    end
end
