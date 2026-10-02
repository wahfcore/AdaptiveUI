local _, A = ...





























































local CVAR = "InputDeviceInterfaceStyle"
local OFFER_TIMEOUT, GRACE = 25, 1.5
local DECLINE_COOLDOWN, SWITCH_COOLDOWN = 600, 60
local LOGIN_DELAY, KEYBOARD_IDLE, VERIFY_AFTER = 5, 10, 2

local IS = { state = "idle", clock = 0, cooldown = { pad = 0, kb = 0 }, counts = {}, last = {}, log = {}, writes = 0 }
A.inputSwitch = IS



function A:InputOfferMemory()
    local root = self.root
    if type(root) ~= "table" then return {} end
    if type(root.inputOffer) ~= "table" then root.inputOffer = {} end
    return root.inputOffer
end




local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f, g = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d, e, f, g
end




function A:InputStyleWritable()
    local info = (type(C_CVar) == "table" and C_CVar.GetCVarInfo) or _G.GetCVarInfo
    local value = call(info, CVAR)
    if value == nil then return "absent" end
    return "manual"
end

function A:PadDeviceCount()
    if type(C_GamePad) ~= "table" then return nil end
    local ids = call(C_GamePad.GetAllDeviceIDs)
    if type(ids) == "table" then return #ids end
    return nil
end

function A:PadPresent()
    if type(C_GamePad) ~= "table" then return false end
    local count = self:PadDeviceCount()
    if count ~= nil then return count > 0 end
    return call(C_GamePad.IsEnabled) == true
end


function A:InputOfferBlocked()
    if self:IsCombat() then return "combat" end
    for _, name in ipairs({ "SettingsPanel", "EditModeManagerFrame" }) do
        local f = _G[name]
        if type(f) == "table" and self:Read(f.IsShown, 1, f) == true then return name end
    end
    if self.options_ui and self.options_ui.frame:IsShown() then return "options" end
    if self.welcome and self.welcome.frame:IsShown() then return "welcome" end
    if self.reportUI and self.reportUI.frame:IsShown() then return "report" end
    if self.moversUnlocked then return "movers" end
    return nil
end




local function b(v) if v == nil then return "n/a" end return tostring(v) end
function A:PadProbeLines()
    local lines = {}
    local function add(text) lines[#lines + 1] = "padprobe" .. text end
    local version, build = call(GetBuildInfo)
    add(string.format(": build %s.%s | interface %s | PlatformIsHandheld %s", b(version), b(build),
        b(self.interfaceNumber), b(call(_G.PlatformIsHandheld))))
    local kinds = type(Enum) == "table" and Enum.InputDeviceInterfaceType or nil
    local api = type(C_InputInterfaceStyle) == "table" and call(C_InputInterfaceStyle.GetCurrentStyle) or nil
    local get = (type(C_CVar) == "table" and C_CVar.GetCVar) or GetCVar
    add(string.format(' style: api %s | cvar raw "%s" | Enum Mkb=%s Gamepad=%s', b(api), b(call(get, CVAR)),
        b(kinds and kinds.Mkb), b(kinds and kinds.Gamepad)))
    local info = (type(C_CVar) == "table" and C_CVar.GetCVarInfo) or _G.GetCVarInfo
    local v, d, acct, char, locked, secure, readOnly = call(info, CVAR)
    if v == nil then add(" cvarinfo: n/a (the client has no " .. CVAR .. ")")
    else
        add(string.format(" cvarinfo: value %s default %s acct %s char %s locked %s secure %s readonly %s",
            b(v), b(d), b(acct), b(char), b(locked), b(secure), b(readOnly)))
    end
    local function shown(name)
        local f = _G[name]
        if type(f) ~= "table" then return "n/a" end
        return b(self:Read(f.IsShown, 1, f))
    end
    local pageUnit = type(_G.GamepadMainActionBarFrame) == "table" and _G.GamepadMainActionBarFrame.PageUnit or nil
    add(string.format(" bars: MainActionBar shown %s | GamepadMainActionBarFrame shown %s | PageUnit shown %s | StanceBar shown %s",
        shown("MainActionBar"), shown("GamepadMainActionBarFrame"),
        type(pageUnit) == "table" and b(self:Read(pageUnit.IsShown, 1, pageUnit)) or "n/a", shown("StanceBar")))
    local pad = type(C_GamePad) == "table" and C_GamePad or {}
    local ids = call(pad.GetAllDeviceIDs)
    local active = call(pad.GetActiveDeviceID)
    local mapped = active ~= nil and call(pad.GetDeviceMappedState, active) or nil
    add(string.format(' devices: C_GamePad.IsEnabled %s | count %s | ids %s | active %s | mapped name "%s" label "%s"',
        b(call(pad.IsEnabled)), type(ids) == "table" and #ids or "n/a",
        type(ids) == "table" and table.concat((function() local t = {} for i, id in ipairs(ids) do t[i] = tostring(id) end return t end)(), ",") or "n/a",
        b(active), type(mapped) == "table" and b(mapped.name) or "n/a", type(mapped) == "table" and b(mapped.labelStyle) or "n/a"))
    add(string.format(' input: IsUsingGamepad %s | IsUsingMouse %s | GamePadSingleActiveID cvar "%s"',
        b(call(IsUsingGamepad)), b(call(IsUsingMouse)), b(call(get, "GamePadSingleActiveID"))))
    local layouts = type(C_EditMode) == "table" and call(C_EditMode.GetLayouts) or nil
    local activeIndex = type(layouts) == "table" and layouts.activeLayout or nil
    local layout = type(layouts) == "table" and type(layouts.layouts) == "table" and activeIndex and layouts.layouts[activeIndex] or nil
    add(string.format(" editmode: active layout index %s type %s interfaceStyle %s | Gamepad preset present %s",
        b(activeIndex), type(layout) == "table" and b(layout.layoutType) or "n/a",
        type(layout) == "table" and b(layout.interfaceStyle) or "n/a",
        (type(Enum) == "table" and type(Enum.EditModePresetLayouts) == "table" and Enum.EditModePresetLayouts.Gamepad ~= nil)
            and "true" or "n/a"))
    local function ev(name)
        local last = IS.last[name]
        return string.format("%s %d%s", name, IS.counts[name] or 0, last and string.format(" last %.1f%s", last.t,
            last.detail and (" " .. last.detail) or "") or "")
    end
    add(" events: " .. ev("CONNECTED") .. " | " .. ev("DISCONNECTED") .. " | " .. ev("ACTIVE_CHANGED") .. " | "
        .. ev("TRANSITION") .. " | CVAR_UPDATE(" .. CVAR .. ") " .. (IS.counts.CVAR or 0))
    local order = {}
    for i = 1, math.min(8, #IS.log) do
        local e = IS.log[i]
        order[#order + 1] = string.format("%s@%+.1f", e.name, e.t - (IS.worldAt or 0))
    end
    add(" login: at PLAYER_ENTERING_WORLD " .. (IS.worldAt and string.format("t=%.1f", IS.worldAt) or "not yet")
        .. ": " .. (#order > 0 and table.concat(order, " ") or "no input events"))
    add(string.format(" frames: SettingsPanel shown %s | EditModeManagerFrame shown %s | InCombatLockdown %s",
        shown("SettingsPanel"), shown("EditModeManagerFrame"), b(call(InCombatLockdown))))
    add(string.format(" ctx: ReloadUI %s | popup %s | the style is never written by this addon (0.59.1)",
        type(ReloadUI), IS.state))
    return lines
end

function A:PadProbeCommand(argument)
    if argument == "write" then

        self:Print("padprobe write: removed. Use Esc > Options > Gamepad > Gamepad Mode.")
        return
    end
    for _, line in ipairs(self:PadProbeLines()) do self:Print(line) end
end




local SHORT = { GAME_PAD_CONNECTED = "CONNECTED", GAME_PAD_DISCONNECTED = "DISCONNECTED",
    GAME_PAD_ACTIVE_CHANGED = "ACTIVE_CHANGED", INPUT_DEVICE_INTERFACE_TRANSITION = "TRANSITION" }
local function note(name, detail)
    IS.counts[name] = (IS.counts[name] or 0) + 1
    IS.last[name] = { t = IS.clock, detail = detail }
    if #IS.log < 24 then IS.log[#IS.log + 1] = { name = name, t = IS.clock } end
end

function A:OnInputEvent(event, ...)
    local short = SHORT[event]
    if short then
        local a1, a2 = ...
        note(short, event == "INPUT_DEVICE_INTERFACE_TRANSITION" and (tostring(a1) .. "-" .. tostring(a2))
            or (event == "GAME_PAD_ACTIVE_CHANGED" and tostring(a1) or nil))
    elseif event == "CVAR_UPDATE" then
        if (...) == CVAR then note("CVAR") end
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        if not IS.worldAt then IS.worldAt = IS.clock; IS.loginCheckAt = IS.clock + LOGIN_DELAY end
    elseif event == "PLAYER_REGEN_DISABLED" then

        if IS.state == "offer" then self:HideInputOffer() end
    elseif event == "GAME_PAD_CONNECTED" then
        IS.connectAt = IS.clock
        if IS.worldAt and IS.clock >= IS.worldAt + LOGIN_DELAY then self:ConsiderInputOffer("pad", "connect") end
    elseif event == "GAME_PAD_DISCONNECTED" then
        if IS.state == "offer" and IS.direction == "pad" then self:HideInputOffer() end
        if self:GamepadStyleOn() == true then self:ConsiderInputOffer("kb", "pad gone") end
    elseif event == "GAME_PAD_ACTIVE_CHANGED" then
        local active = (...) and true or false
        if active then
            IS.padIdleSince = nil


            if IS.state == "offer" and IS.direction == "kb" then
                self:HideInputOffer()
            elseif IS.state ~= "offer" then
                self:ConsiderInputOffer("pad", "button")
            end
        else
            IS.padIdleSince = IS.clock
        end
    elseif event == "INPUT_DEVICE_INTERFACE_TRANSITION" then


        IS.relayoutAt = { IS.clock + 0.5, IS.clock + VERIFY_AFTER }

        if IS.state == "offer" then
            IS.cooldown.pad = IS.clock + SWITCH_COOLDOWN
            IS.cooldown.kb = IS.clock + SWITCH_COOLDOWN
            self:HideInputOffer()
        end
    end
end






function A:ConsiderInputOffer(direction, why)
    if not self.db or not self.optionIndex or not self.optionIndex.autoSwitchInput then return false end
    local mode = self:GetOption("autoSwitchInput")
    if mode == "off" then return false end
    if IS.state ~= "idle" then return false end
    local style = self:GamepadStyleOn()

    if direction == "pad" and style ~= false then return false end
    if direction == "kb" and style ~= true then return false end
    if self:InputStyleWritable() == "absent" then return false end
    local memory = self:InputOfferMemory()
    if memory[direction .. "NeverAsk"] then return false end
    if IS.clock < (IS.cooldown[direction] or 0) then return false end
    if self:InputOfferBlocked() then return false end


    IS.lastWhy = why
    self:ShowInputOffer(direction)
    return true
end

function A:TickInputSwitch(elapsed)
    IS.clock = IS.clock + (tonumber(elapsed) or 0)
    local now = IS.clock

    if IS.loginCheckAt and now >= IS.loginCheckAt and self.db then
        local memory = self:InputOfferMemory()
        if memory.firstRunAsked or self:GetOption("autoSwitchInput") == "off"
            or self:GamepadStyleOn() ~= false or not self:PadPresent() then
            IS.loginCheckAt = nil
        elseif IS.state ~= "idle" or self:InputOfferBlocked() then
            IS.loginCheckAt = now + 1
        else
            if self:ConsiderInputOffer("pad", "login") then memory.firstRunAsked = true end
            IS.loginCheckAt = nil
            if not memory.firstRunAsked then IS.loginCheckAt = now + 2 end
        end
    end

    if IS.padIdleSince and now - IS.padIdleSince >= KEYBOARD_IDLE then
        IS.padIdleSince = nil
        if self:GamepadStyleOn() == true then self:ConsiderInputOffer("kb", "keyboard") end
    end
    if IS.state == "offer" then
        if self:IsCombat() then self:HideInputOffer()
        elseif now >= (IS.shownAt or now) + OFFER_TIMEOUT then
            self:DeclineInputOffer()
        end
    end
    if IS.relayoutAt then
        local keep = {}
        for _, at in ipairs(IS.relayoutAt) do
            if now >= at then
                self.layoutDirty, self.nativeDirty, self.dirty = true, true, true
                self.inputRelayouts = (self.inputRelayouts or 0) + 1
            else keep[#keep + 1] = at end
        end
        IS.relayoutAt = #keep > 0 and keep or nil
    end
end




local W, H = 440, 150
local IGNORED = { PADLTRIGGER = true, PADRTRIGGER = true, PADLSTICKUP = true, PADLSTICKDOWN = true,
    PADLSTICKLEFT = true, PADLSTICKRIGHT = true, PADRSTICKUP = true, PADRSTICKDOWN = true, PADRSTICKLEFT = true,
    PADRSTICKRIGHT = true }
local DPAD = { PADDUP = true, PADDDOWN = true, PADDLEFT = true, PADDRIGHT = true }

function A:CreateInputOffer()
    if self.inputOffer then return self.inputOffer end
    local K = self.optionsKit
    local frame = CreateFrame("Frame", "AdaptiveUIInputOffer", UIParent)
    frame:SetSize(W, H)
    self:TopWindow(frame)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame.bg = K.fill(frame, "BACKGROUND", "ink", 0.96, -7)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "d", frame, 0, 0, frame, 0, 0, "raised")

    frame.rule = frame:CreateTexture(nil, "OVERLAY")
    frame.rule:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.rule:SetSize(4, H)
    self:Tint(frame.rule, "accent", "color", 1)
    local ui = { frame = frame }
    ui.title = K.text(frame, 18, true, 18, -12, W - 36)
    ui.body = K.text(frame, 14, false, 18, -38, W - 36)
    ui.body:SetWordWrap(true)
    ui.body:SetHeight(54)
    ui.accept = K.uiButton(frame, "", 18, -(H - 44), 118, 30, function() A:AcceptInputOffer() end)
    ui.decline = K.uiButton(frame, "", 142, -(H - 44), 118, 30, function() A:DeclineInputOffer() end)
    ui.never = K.uiButton(frame, "", 266, -(H - 44), 156, 30, function() A:NeverInputOffer() end)
    for _, bt in ipairs({ ui.accept, ui.decline, ui.never }) do bt.label:SetJustifyH("CENTER") end
    self:AttachSettingsNavigation(frame, function()
        if IS.state == "offer" then IS.state = "idle" end
    end)

    frame:SetScript("OnGamePadButtonDown", function(_, button) A:InputOfferButton(button) end)
    frame:SetScript("OnKeyDown", function(_, key) A:InputOfferKey(key) end)
    frame:Hide()
    self.inputOffer = ui
    return ui
end

local function propagate(frame, value)
    for _, name in ipairs({ "SetPropagateGamepadInput", "SetPropagateKeyboardInput" }) do
        if type(frame[name]) == "function" then pcall(frame[name], frame, value) end
    end
end

function A:InputOfferButton(button)
    local ui = self.inputOffer
    if not ui or self:IsCombat() then return end
    local consumed = true
    if IS.state ~= "offer" then
        consumed = false
    elseif DPAD[button] then
        self:GamepadInput(ui.frame, button)
        return
    elseif button == "PAD2" then self:DeclineInputOffer()
    elseif button == "PAD4" then self:NeverInputOffer()
    elseif IGNORED[button] or (type(button) == "string" and button:find("STICK")) then
        consumed = false
    elseif IS.clock < (IS.graceUntil or 0) then
        consumed = false
    elseif button == "PAD1" then
        local nav = self.gamepadNav and self.gamepadNav[ui.frame]
        local focused = nav and nav.current
        if focused and focused ~= ui.accept and type(focused.Click) == "function" then focused:Click()
        elseif focused == ui.accept or IS.direction == "pad" then self:AcceptInputOffer()
        else consumed = false end
    elseif IS.direction == "pad" then
        self:AcceptInputOffer()
    else


        consumed = false
    end
    propagate(ui.frame, not consumed)
end

function A:InputOfferKey(key)
    local ui = self.inputOffer
    if not ui or self:IsCombat() then return end
    if IS.state == "offer" and (key == "ENTER" or key == "NUMPADENTER") then
        self:AcceptInputOffer(); propagate(ui.frame, false)
    elseif IS.state == "offer" and key == "ESCAPE" then
        self:DeclineInputOffer()
        propagate(ui.frame, false)
    else
        propagate(ui.frame, true)
    end
end

function A:PlaceInputOffer(ui)
    local s = self:WindowScale(W, H)
    ui.frame:SetScale(s)
    local ix, iy = self:SafeInset()
    ui.frame:ClearAllPoints()

    ui.frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(ix + 8) / s, (iy + 150) / s)
end



A.inputOfferWords = {
    pad = { "Gamepad detected", "Press Esc > Options > Gamepad > Gamepad Mode to switch to the controller bars.",
        "OK", "Not now", "Don't ask again" },
    kb = { "Keyboard and mouse in use", "Press Esc > Options > Gamepad and turn off Gamepad Mode for the keyboard"
        .. " bars. Edit Mode goes back to Blizzard's default layout when you leave Gamepad Mode.",
        "OK", "Not now", "Don't ask again" },
}

function A:ShowInputOffer(direction)
    if self:IsCombat() then return end
    local ui = self:CreateInputOffer()
    local words = self.inputOfferWords[direction] or self.inputOfferWords.pad
    ui.title:SetText(words[1]); ui.body:SetText(words[2])


    ui.accept.label:SetText(words[3]); ui.decline.label:SetText(words[4])
    ui.never.label:SetText(words[5])
    ui.decline:Show(); ui.never:Show()
    IS.state, IS.direction, IS.manual = "offer", direction, true
    IS.shownAt, IS.graceUntil = IS.clock, IS.clock + GRACE
    self:PlaceInputOffer(ui)

    pcall(ui.frame.EnableGamePadButton, ui.frame, true)
    ui.frame:Show()
    pcall(ui.frame.Raise, ui.frame)
    self:GamepadHighlight(ui.frame, ui.accept)
end

function A:HideInputOffer()
    IS.state = "idle"
    if self.inputOffer then self.inputOffer.frame:Hide() end
end



function A:AcceptInputOffer()
    if IS.state ~= "offer" then return end
    IS.cooldown[IS.direction] = IS.clock + DECLINE_COOLDOWN
    self:HideInputOffer()
end

function A:DeclineInputOffer()
    if IS.state ~= "offer" then return end
    IS.cooldown[IS.direction] = IS.clock + DECLINE_COOLDOWN
    self:HideInputOffer()
end

function A:NeverInputOffer()
    if IS.state ~= "offer" then return end
    self:InputOfferMemory()[IS.direction .. "NeverAsk"] = true
    self:HideInputOffer()
    self:Print("AdaptiveUI will not ask again. Options > Controls > Gamepad Mode reminder turns it back on.")
end
