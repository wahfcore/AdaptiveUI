local _, A = ...
local defaults = { unitMode = "lite", style = "rpg", mode = "auto", scale = 1, opacity = 0.9, casts = true,
    dock = "right", x = 360, y = 190, enabled = true }

function A:Print(message)

    if self.quietPrint then
        self.quietLines = self.quietLines or {}
        self.quietLines[#self.quietLines + 1] = message
        return
    end
    if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffbdcf9dAdaptiveUI|r " .. message)
    end
end





A.displayPresets = {


    desktop = { scale = 0.85, legacy = 1, textScale = 1, dockScale = 0.9 },
    tv = { scale = 1.05, legacy = 1.25, textScale = 1.15, dockScale = 1.05 },
    handheld = { scale = 1.25, legacy = 1.25, textScale = 1.2, dockScale = 1 },
}
function A:SetDisplayPreset(preset)
    local set = self.displayPresets[preset]
    if not set then return end
    self.db.scale = self.db.layout == false and set.legacy or set.scale
    if self.optionIndex and self.optionIndex.textScale then
        self:SetOption("textScale", set.textScale, true)
        self:SetOption("dockScale", set.dockScale, true)
    end
    self.layoutDirty = true
    self:Changed()
end


function A:DisplayPreset()
    local text = self.db.textScale or 1
    local dock = self.db.dockScale or 0.9
    for _, name in ipairs({ "desktop", "tv", "handheld" }) do
        local set = self.displayPresets[name]
        local scale = self.db.layout == false and set.legacy or set.scale
        if math.abs((self.db.scale or 1) - scale) < 0.01 and math.abs(text - set.textScale) < 0.01
            and math.abs(dock - set.dockScale) < 0.01 then return name end
    end
    return nil
end

function A:LoadSettings(profileSwitched)
    if not profileSwitched then



        local atLogin = self:DescribeRoot(AdaptiveUIDB)
        pcall(self.RecoverFromMirror, self)
        if type(AdaptiveUIDB) ~= "table" then AdaptiveUIDB = {} end
        self.root = AdaptiveUIDB
        self:MigrateProfiles(self.root)
        self.db = self:SelectProfile(self.root)
        self.root.sessions = (tonumber(self.root.sessions) or 0) + 1

        self:ScrubTransient()
        pcall(self.RecordLoadTrace, self, atLogin)


        if type(self.root.quarantine) == "table" then self.root.quarantine.focus = nil end
    end
    if self.db.dock == nil then

        local customAnchor = type(self.db.x) == "number" and type(self.db.y) == "number"
            and (self.db.x ~= 360 or self.db.y ~= 190)
        self.db.dock = customAnchor and "custom" or "right"
    end
    for key, value in pairs(defaults) do
        if type(self.db[key]) ~= type(value) then self.db[key] = value end
    end
    if self.db.unitMode ~= "lite" and self.db.unitMode ~= "plus" then self.db.unitMode = "lite" end
    if self.db.style ~= "rpg" and self.db.style ~= "minimal" then self.db.style = "rpg" end
    if self.db.mode ~= "auto" and self.db.mode ~= "controller" and self.db.mode ~= "keyboard" then self.db.mode = "auto" end
    if self.db.dock ~= "right" and self.db.dock ~= "left" and self.db.dock ~= "custom" then self.db.dock = "right" end
    self.db.scale = math.max(0.7, math.min(1.8, self.db.scale))
    if self.db.opacity ~= self.db.opacity then self.db.opacity = defaults.opacity end
    self.db.opacity = math.max(0.25, math.min(1, self.db.opacity))
    self.db.x = math.max(-1000, math.min(1000, self.db.x))
    self.db.y = math.max(40, math.min(700, self.db.y))
    self:LoadNativeSettings()
    self:LoadLayoutSettings()


    self:NormalizeProfile(self.db)



    if not profileSwitched and self.db.setupDone ~= true then
        self.pendingWelcome = true
        self.welcomeDelay = 4
    end
end

function A:SetObservedInput(mode)
    self.observedInput = mode
    self.dirty = true
    self.nativeDirty = true
    self.layoutDirty = true
end





function A:EffectiveInput()
    if not self.db then return self.observedInput end
    return self.db.mode == "auto" and self.observedInput or self.db.mode
end

function A:GetInputLabel()
    local mode = self:EffectiveInput()
    if mode == "controller" then return "CONTROLLER" end
    if mode == "keyboard" then return "MOUSE / KEYS" end
    return "NATIVE INPUT"
end

function A:DisableHUD(capability, reason, message)
    self.sessionDisabled = true
    self.pendingCreate = nil
    self.pendingAppearance = nil

    if self.hud then pcall(self.hud.Hide, self.hud) end
    if self.compactHUD then pcall(self.compactHUD.Hide, self.compactHUD) end
    self:Note(capability, reason)
    self:Print(message)
end

function A:SafeRefresh()














    pcall(self.UpdatePlusUnits, self)
    if self.sessionDisabled then return end
    local ok = pcall(self.UpdateHUD, self)
    if not ok then
        self:DisableHUD("HUD refresh", "disabled after rejected API; native UI unaffected",
            "A beta API rejected a HUD update. Display hidden; native UI is untouched. Use /aui status, then /reload after reporting.")
    end
    self:SafeUpdateCasts()
    self:SweepGlazes()
end

function A:Changed()
    self:ApplyAppearance()
    self:SafeRefresh()
    self:RefreshNativeUI()
    self:RefreshSettingsLabels()
    self:RefreshNativeSettingsLabels()
    self:RefreshOptionsUI()
    if self:IsCombat() then self:Print("Configuration saved; appearance applies after combat.") end
end

function A:Diagnostics()
    self:Print("v" .. self.version .. " | source audit " .. self.sourceCommit)
    self:Print("Client " .. self.buildVersion .. "." .. self.buildNumber .. " | Interface " .. tostring(self.interfaceNumber or "unavailable"))
    self:Print("Build gate: " .. tostring(self.buildTier) .. (self.buildTierReason and (" (" .. self.buildTierReason .. ")") or ""))
    self:Print("Style " .. self.db.style .. " | mode " .. self.db.mode .. " | observed " .. (self.observedInput or "unknown") .. " | scale " .. self.db.scale)
    if self.CarveReport then self:Print(self:CarveReport()) end


    if self.ChromeV2Line then pcall(function() self:Print(self:ChromeV2Line()) end) end




    if self.InputDecisionLine then pcall(function() self:Print(self:InputDecisionLine()) end) end
    if self.UnitClickReport then pcall(self.UnitClickReport, self, function(line) self:Print(line) end) end
    self:Print("Placement " .. self.db.dock .. " | anchor " .. self.db.x .. ", " .. self.db.y)
    self:Print(string.format("Panel opacity %.0f%% | cast strips %s (public metadata only)", self.db.opacity * 100, self.db.casts and "on" or "off"))
    if self.CastBarReport then self:CastBarReport(function(line) self:Print(line) end) end
    if self.CompassReport then pcall(self.CompassReport, self, function(line) self:Print(line) end) end




    if self.KeyboardReport then pcall(self.KeyboardReport, self, function(line) self:Print(line) end) end
    self:PersistenceReport(function(line) self:Print(line) end)
    self:ReportBlocked(function(line) self:Print(line) end)
    self:Print("This is a source-audited beta slice, not a completed runtime compatibility test.")
    local keys = {}
    for key in pairs(self.capabilities) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do self:Print(key .. ": " .. self.capabilities[key]) end
    if self.windowScaleCapped then
        self:Print("Options window: held inside the screen, so its text is under 14 px on this display.")
    end
    self:Print("No binding writes. One CVar, only from your own press on the controller popup: Gamepad Mode"
        .. " (InputDeviceInterfaceStyle). No rotation advice, aura automation, or protected controls replaced.")
end

local function label(parent, value, size, x, y, width)
    local font = parent:CreateFontString(nil, "OVERLAY")


    A:SetThemedFont(font, size, size >= 16)
    font:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    font:SetWidth(width)
    font:SetJustifyH("LEFT")
    A:Tint(font, "text", "text")
    font:SetText(value)
    return font
end

local function button(parent, value, x, y, width, callback)
    local frame = CreateFrame("Button", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    frame:SetSize(width, 40)


    frame.background = A:Panel(frame, 0, 0, width, 40, "base", "control")
    frame.title = label(frame, value, A.tokens.type.body, 12, -12, width - 24)
    A:AddFocusable(frame)
    frame:SetScript("OnEnter", function() A:HoverTint(frame.background, true) end)
    frame:SetScript("OnLeave", function() A:HoverTint(frame.background, false) end)
    frame:SetScript("OnClick", function()
        if A:IsCombat() then A:Print("Settings controls are unavailable in combat."); return end
        callback()
    end)
    return frame
end

function A:SettingsButton(...)
    return button(...)
end

function A:CreateSettings()
    if self.settings then return end


    local M, FULL, COL, STEP = 16, 408, 200, 120
    local COL2, MID, PLUS = M + COL + 8, M + STEP + 8, M + STEP + 8 + 152 + 8
    local GAP = 44


    local function row(index) return -104 - (index - 1) * GAP end
    local frame = CreateFrame("Frame", "AdaptiveUISettings", UIParent)
    frame:SetSize(440, 600)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame.background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    frame.background:SetAllPoints()
    self:Tint(frame.background, "ink", "color", 0.98)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "panel~", frame, 0, 0, frame, 0, 0, "raised")



    frame.mast = {}
    self:Masthead(frame, 440, 104, frame.mast, "m", M)
    local lead = frame.mast.mLead or 0
    self:Rule(frame, 0, 0, 440, 2)






    local title = label(frame, "Adaptive UI : A Wahf Production", A.tokens.type.hero, M + lead, -16, math.min(360, FULL - lead))
    local signature = self:Rule(frame, M + lead, -44, 236, 2)
    local measured = select(2, pcall(title.GetStringWidth, title))
    if type(measured) == "number" and measured > 40 then signature:SetWidth(math.min(360, FULL - lead, measured)) end
    label(frame, "A WoW dad's answer to off-night couch gaming.", A.tokens.type.body, M + lead, -54, FULL - lead)
    label(frame, "Appearance only. Native controls stay in charge.", A.tokens.type.caption, M + lead, -80, FULL - lead)
    button(frame, "Ultra-minimal", M, row(1), COL, function() A.db.style = "minimal"; A:Changed() end)
    button(frame, "Console RPG", COL2, row(1), COL, function() A.db.style = "rpg"; A:Changed() end)
    frame.mode = button(frame, "Input: auto", M, row(2), FULL, function()
        local nextMode = { auto = "controller", controller = "keyboard", keyboard = "auto" }
        A.db.mode = nextMode[A.db.mode]
        A.layoutDirty = true
        A:Changed()
    end)
    button(frame, "Scale -", M, row(3), STEP, function() A.db.scale = math.max(0.7, A.db.scale - 0.1); A:Changed() end)
    frame.scale = label(frame, "Scale 1.0", A.tokens.type.body, MID, row(3) - 13, 152)
    frame.scale:SetJustifyH("CENTER")
    button(frame, "Scale +", PLUS, row(3), STEP, function() A.db.scale = math.min(1.8, A.db.scale + 0.1); A:Changed() end)
    frame.dock = button(frame, "Dock: right", M, row(4), COL, function()
        A.db.dock = A.db.dock == "right" and "left" or "right"
        A:Changed()
    end)



    frame.reset = button(frame, "Reset this addon", COL2, row(4), COL, function()
        if A:Confirmed("reset:addon", 6) then
            A:Reset()
            frame.reset.title:SetText("Reset this addon")
        else
            frame.reset.title:SetText("Press again to reset")
        end
    end)
    button(frame, "Opacity -", M, row(5), STEP, function() A.db.opacity = math.max(0.25, A.db.opacity - 0.05); A:Changed() end)
    frame.opacity = label(frame, "Opacity", A.tokens.type.body, MID, row(5) - 13, 152)
    frame.opacity:SetJustifyH("CENTER")
    button(frame, "Opacity +", PLUS, row(5), STEP, function() A.db.opacity = math.min(1, A.db.opacity + 0.05); A:Changed() end)
    button(frame, "Handheld size", M, row(6), COL, function() A:SetDisplayPreset("handheld") end)
    button(frame, "Desktop size", COL2, row(6), COL, function() A:SetDisplayPreset("desktop") end)
    frame.casts = button(frame, "Cast strips", M, row(7), FULL, function() A.db.casts = not A.db.casts; A:Changed() end)
    frame.units = button(frame, "Unit frames: Lite", M, row(8), FULL, function()
        A:SetUnitMode(A.db.unitMode == "plus" and "lite" or "plus")
    end)
    button(frame, "Native UI modules", M, row(9), COL, function() A:OpenNativeSettings() end)
    button(frame, "All options...", COL2, row(9), COL, function() A:OpenOptions() end)
    label(frame, "Drag the title bar to move this window.\nPlace the HUD with /aui anchor X Y. Details: /aui status",
        A.tokens.type.caption, M, row(10) + 4, FULL)
    button(frame, "Close", M, row(11), FULL, function() frame:Hide() end)
    self.settings = frame
    self:MakeMovableWindow(frame, "Settings", 44)
    self:AttachSettingsNavigation(frame)
    self:RefreshSettingsLabels()
end

function A:RefreshSettingsLabels()
    if not self.settings then return end
    self.settings.mode.title:SetText("Input: " .. self.db.mode .. " (click to cycle)")
    self.settings.scale:SetText(string.format("Scale %.1f", self.db.scale))
    self.settings.dock.title:SetText("Dock: " .. self.db.dock)
    self.settings.opacity:SetText(string.format("Opacity %.0f%%", self.db.opacity * 100))
    self.settings.units.title:SetText(self.db.unitMode == "plus" and "Unit frames: Plates (custom, display-only)" or "Unit frames: Lite (native, restyled)")
    self.settings.casts.title:SetText(self.db.casts and "Cast strips: on (public data only)" or "Cast strips: off")
end

function A:OpenSettings()
    if self:IsCombat() then self:Print("Open settings after combat. Slash changes can be queued."); return end
    self:CreateSettings()
    if self.nativeSettings then self.nativeSettings:Hide() end
    if self.layoutSettings then self.layoutSettings:Hide() end
    self:PlaceWindow(self.settings, "Settings")
    self.settings:Show()
end

function A:Reset()
    for key, value in pairs(defaults) do self.db[key] = value end
    for _, module in ipairs(self.skinModules) do self.db.skins[module.key] = true end
    self:ResetProfile()
    self:Print("Only AdaptiveUI settings reset. Blizzard settings and bindings were not changed.")
end

function A:Slash(message)
    local command, argument, second, third = string.match(message or "", "^%s*(%S*)%s*(%S*)%s*(%S*)%s*(%S*)")
    command = string.lower(command or "")
    argument = string.lower(argument or "")


    if command == "" or command == "settings" or command == "config" then self:OpenOptions()
    elseif command == "modules" then self:OpenOptions("help")
    elseif command == "options" then self:OpenOptions(argument ~= "" and argument or nil)
    elseif command == "movers" then
        if argument == "unlock" then self:UnlockMovers()
        elseif argument == "lock" then self:LockMovers()
        elseif argument == "reset" then
            for _, entry in ipairs(self.moverList) do if second == "" or second == entry.id then self:ResetMover(entry.id) end end
        else self:OpenOptions("movers") end
    elseif command == "quarantine" then self:QuarantineCommand(argument)
    elseif command == "profile" then self:ProfileCommand(argument, second, third)
    elseif command == "layout" then
        if argument == "on" or argument == "off" then self:SetReplacementLayout(argument == "on")
        elseif argument == "restore" then self:RestorePreviousHUD()
        else self:OpenOptions("layout") end
    elseif command == "dockscale" and tonumber(argument) then
        self.db.dockScale = math.max(0.7, math.min(1.2, tonumber(argument))); self:Changed()
    elseif command == "textscale" and tonumber(argument) then
        self.db.textScale = math.max(0.85, math.min(1.2, tonumber(argument))); self:Changed()
    elseif command == "unitanchor" and tonumber(argument) and tonumber(second) then
        self.db.layoutX = math.max(-300, math.min(300, tonumber(argument)))
        self.db.layoutY = math.max(-150, math.min(300, tonumber(second))); self:Changed()
    elseif command == "units" and (argument == "lite" or argument == "plus") then self:SetUnitMode(argument)
    elseif command == "skin" and (second == "on" or second == "off") then self:SetSkinEnabled(argument, second == "on")
    elseif command == "build" then
        self:Print("Client build " .. tostring(self.buildVersion) .. "." .. tostring(self.buildNumber) .. " | interface "
            .. tostring(self.interfaceNumber) .. " | gate: " .. tostring(self.buildTier)
            .. (self.buildTierReason and (" | " .. self.buildTierReason) or ""))
        local stood = self.root and self.root.buildStandDown
        if type(stood) == "table" and next(stood) then
            for build, info in pairs(stood) do
                self:Print("  stood down on " .. tostring(build) .. ": " .. tostring(info.reason) .. " (" .. tostring(info.time) .. ")")
            end
            self:Print("  /aui quarantine clear, then /reload, to try again.")
        end
    elseif command == "welcome" or command == "setup" then self:OpenWelcome()
    elseif command == "save" then
        local ok = pcall(self.SnapshotMirror, self)
        self:Print(ok and "Backup copy written. Settings reach disk when you /reload or log out."
            or "Backup copy could not be written.")
    elseif command == "status" or command == "diagnostic" then self:Diagnostics()


    elseif command == "set" then self:SetCommand(message)
    elseif command == "inspect" then self:InspectNativeFrames()
    elseif command == "measure" then self:MeasureCommand(argument)



    elseif command == "effecttest" then self:EffectTestCommand(argument, second)
    elseif command == "chiptest" then self:ChipTestCommand(argument)
    elseif command == "castprobe" then self:CastProbeCommand()


    elseif command == "compasstest" then self:CompassTestCommand(argument)


    elseif command == "spike" then self:SpikeCommand(argument, second)
    elseif command == "xpprobe" then self:XpProbe()
    elseif command == "style" and (argument == "rpg" or argument == "minimal") then self.db.style = argument; self:Changed()



    elseif command == "mode" and (argument == "auto" or argument == "controller" or argument == "keyboard") then self.db.mode = argument; self.layoutDirty = true; self:Changed()
    elseif command == "scale" and tonumber(argument) then
        self.db.scale = math.max(0.7, math.min(1.8, tonumber(argument))); self:Changed()
    elseif command == "opacity" and tonumber(argument) then
        self.db.opacity = math.max(0.25, math.min(1, tonumber(argument))); self:Changed()
    elseif command == "preset" and (argument == "handheld" or argument == "desktop") then
        self:SetDisplayPreset(argument)
    elseif command == "casts" and (argument == "on" or argument == "off") then
        self.db.casts = argument == "on"; self:Changed()
    elseif command == "dock" and (argument == "right" or argument == "left") then
        self.db.dock = argument; self:Changed()
    elseif command == "anchor" and tonumber(argument) and tonumber(second) then
        self.db.dock = "custom"
        self.db.x = math.max(-1000, math.min(1000, tonumber(argument)))
        self.db.y = math.max(40, math.min(700, tonumber(second)))
        self:Changed()
    elseif command == "show" or command == "hide" then self.db.enabled = command == "show"; self:Changed()
    elseif command == "reset" then
        if not self:Confirmed("reset:addon", 10) then
            self:Print("This resets every AdaptiveUI setting on this profile and turns every styled part back on."
                .. " Type /aui reset again within 10 seconds to do it.")
            return
        end
        self:Reset()
    elseif command == "report" then self:OpenReport()
    elseif command == "padprobe" then self:PadProbeCommand(argument, second)


    elseif command == "taint" then self:TaintHelp()

    elseif command == "auras" then self:AuraProbe(function(text) self:Print(text) end)
    else

        self:Print("/aui  opens the options (or bind a key: Key Bindings > AddOns > AdaptiveUI).")
        self:Print("/aui welcome  the setup again  |  /aui report  report a problem  |  /aui status  what loaded")
        self:Print("/aui movers unlock|lock|reset  |  /aui profile list|use|new|export|import  |  /aui set KEY VALUE")
        self:Print("Safe buttons: /aui skin all off  |  /aui units lite  |  /aui hide  |  /aui reset  |  /aui quarantine clear")
        self:Print("A Blizzard error naming AdaptiveUI or 'secret values'? /aui taint  how to record it")
    end
end




function A:TaintHelp()
    self:Print("To record a taint report for AdaptiveUI:")
    self:Print("  1. Type  /console taintLog 2  and press Enter.")
    self:Print("  2. /reload, then do what causes the error (a fight, a skill press).")
    self:Print("  3. Type  /console taintLog 0  to stop logging, then /reload or log out.")
    self:Print("  4. The file is  World of Warcraft\\_classic_beta_\\Logs\\taint.log  -- send it with /aui status.")
end

function A:Initialize()
    if self.initialized then return end
    self.initialized = true
    self:LoadSettings()
    self:Discover()
    self:ObserveInput()
    self:ObserveNativePresentation()
    self:RefreshNativeUI()
    self:RegisterNativeSettingsCategory()
    if not self:IsCombat() then
        local ok = pcall(self.CreateHUD, self)
        if not ok then
            self:DisableHUD("HUD creation", "failed; stock display retained",
                "HUD could not initialize on this beta. Display hidden; native UI is unchanged. /aui status")
        end
    else
        self.pendingCreate = true
    end
    self:SafeRefresh()
    self:SyncIntegratedHUD()


    if not self.sessionDisabled and not self.pendingWelcome then
        self:Print("ready. Options: /aui, Esc > Options > AddOns, or a key you bind in Key Bindings > AddOns.")
    end


    if not self.loginNotesFlushed then
        self.loginNotesFlushed = true
        for _, note in ipairs(self.pendingNotes or {}) do self:Print(note) end
        self.pendingNotes = nil
    end
    if self.recovered then
        self:Print("Your saved settings came up empty at login, so they were restored from this character's backup"
            .. " (saved " .. tostring(self.recovered.savedAt) .. "). /aui status for details.")
    end
    if self.pendingBuildNotice then
        self.pendingBuildNotice = nil
        self:Print("New client build " .. tostring(self.buildNumber) .. " has not been audited. Running in provisional mode"
            .. " (the frames this addon needs are all present); it stands down by itself if the client blocks an action."
            .. " /aui build for details.")
    end
    if self.buildTier == "refused" then
        self:Print("Client build " .. tostring(self.buildNumber) .. ": the native UI is left alone (" .. tostring(self.buildTierReason) .. ").")
    end
    if self.pendingWelcome then
        self:Print("is ready. A one-minute setup opens now; you can run it again any time from the options.")
        if self.observedInput == "controller" then self:Print("Controller found.") end
    end
end

local events = CreateFrame("Frame")
A.events = events

A.inputEventNames = { GAME_PAD_CONNECTED = true, GAME_PAD_DISCONNECTED = true, GAME_PAD_ACTIVE_CHANGED = true,
    INPUT_DEVICE_INTERFACE_TRANSITION = true, CVAR_UPDATE = true, PLAYER_ENTERING_WORLD = true,
    PLAYER_REGEN_DISABLED = true, PLAYER_REGEN_ENABLED = true, ADDON_ACTION_BLOCKED = true, ADDON_ACTION_FORBIDDEN = true }
for _, event in ipairs({
    "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_POWER_UPDATE",
    "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UPDATE_SHAPESHIFT_FORM",
    "UPDATE_SHAPESHIFT_FORMS", "UNIT_NAME_UPDATE", "ADDON_LOADED", "GROUP_ROSTER_UPDATE",
    "UNIT_AURA", "ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_PAGE_CHANGED",
    "UPDATE_OVERRIDE_ACTIONBAR", "UPDATE_VEHICLE_ACTIONBAR",
    "UPDATE_BONUS_ACTIONBAR", "PET_BAR_UPDATE", "UPDATE_MOUSEOVER_UNIT", "DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED",
    "QUEST_LOG_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE",
    "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN", "GAME_PAD_ACTIVE_CHANGED", "GAME_PAD_DISCONNECTED",


    "GAME_PAD_CONNECTED", "CVAR_UPDATE",




    "INPUT_DEVICE_INTERFACE_TRANSITION",


    "PLAYER_LOGOUT",
    "UPDATE_INVENTORY_DURABILITY", "PLAYER_SPECIALIZATION_CHANGED", "UNIT_TARGET",


    "DAMAGE_METER_COMBAT_SESSION_UPDATED", "DAMAGE_METER_CURRENT_SESSION_UPDATED", "DAMAGE_METER_RESET",

    "PLAYER_TOTEM_UPDATE", "BAG_UPDATE_DELAYED", "UNIT_PET", "UNIT_HAPPINESS", "PET_UI_UPDATE",
    "PLAYER_FLAGS_CHANGED", "UNIT_FACTION",
}) do A:RegisterOptionalEvent(events, event) end
events:SetScript("OnEvent", function(_, event, ...)


    if A.OnInputEvent and A.inputEventNames[event] then pcall(A.OnInputEvent, A, event, ...) end
    if event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        A:OnActionBlocked(event, ...)
        return
    end
    if event == "PLAYER_SPECIALIZATION_CHANGED" then

        if (...) == "player" or (...) == nil then A.specSwitchPending = true end
        return
    end
    if event == "UPDATE_INVENTORY_DURABILITY" then
        A.infoDurabilityDirty = true
        return
    end
    if event == "DAMAGE_METER_RESET" then


        A.damageSeen = nil
        pcall(A.UpdateDamageStrip, A)
        return
    end
    if event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" or event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
        pcall(A.UpdateDamageStrip, A)
        return
    end
    if event == "INPUT_DEVICE_INTERFACE_TRANSITION" then






        local gamepad = A:GamepadStyleOn()
        if gamepad ~= nil then A:SetObservedInput(gamepad and "controller" or "keyboard")
        else A.layoutDirty = true end
        return
    end
    if event == "GAME_PAD_ACTIVE_CHANGED" then

        A:SetObservedInput((...) and "controller" or "keyboard")
        return
    elseif event == "GAME_PAD_DISCONNECTED" then
        A:SetObservedInput("keyboard")
        return
    end
    if event == "ADDON_LOADED" and (...) == A.name then


        pcall(A.NoteSavedVariables, A)
    end
    if event == "PLAYER_LOGOUT" then
        pcall(A.ReleaseCamera, A)
        pcall(A.ScrubTransient, A)
        pcall(A.NoteSaveSize, A)


        pcall(A.SnapshotMirror, A)
        return
    end












    if event == "UNIT_HEALTH" then
        local unit = ...
        if type(unit) == "string" then
            A.barPulsePending = A.barPulsePending or {}
            A.barPulsePending[unit] = true
        end
    end
    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        if event == "PLAYER_TARGET_CHANGED" then A.targetAurasStale = true end

        A.rankFresh = A.rankFresh or {}
        A.rankFresh[event == "PLAYER_TARGET_CHANGED" and "target" or "focus"] = true
        A.sweepPending = A.sweepPending or {}
        if event == "PLAYER_FOCUS_CHANGED" then
            A.sweepPending.focus = true
        else
            A.sweepPending.target, A.sweepPending.tot = true, true
        end
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        A:Initialize()
        A:ObserveInput()
    elseif event == "PLAYER_REGEN_DISABLED" then
        A.inCombat = true

        if A.chipTestRunning and A.chipTestAbort then pcall(A.chipTestAbort) end


        if A.plusActive then pcall(A.PlusCombatFlare, A) end
        if A.settings then A.settings:Hide() end
        if A.nativeSettings then A.nativeSettings:Hide() end
        if A.layoutSettings then A.layoutSettings:Hide() end
        if A.options_ui then A.options_ui.frame:Hide() end
        if A.welcome then A.welcome.frame:Hide() end
        A:LockMovers()
    elseif event == "PLAYER_REGEN_ENABLED" then
        A.inCombat = false
        if A.pendingCreate and A.initialized then
            A.pendingCreate = nil
            local ok = pcall(A.CreateHUD, A)
            if not ok then
                A:DisableHUD("HUD creation", "failed; stock display retained",
                    "HUD could not initialize after combat. Display hidden; native UI is unchanged. /aui status")
            end
        end
        if A.initialized then A:ApplyAppearance() end
    end
    A.dirty = true
    if A.nativeRefreshEvents[event] then A.nativeDirty = true end
    if event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" or event == "PLAYER_REGEN_ENABLED"
        or event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" then A.layoutDirty = true end
end)
local elapsedTime = 0
events:SetScript("OnUpdate", function(_, elapsed)
    if A.specSwitchPending and not A:IsCombat() and A.initialized then
        pcall(A.ApplySpecProfile, A)
    end
    if A.pendingOptionsApplied and not A:IsCombat() then
        A.pendingOptionsApplied = nil
        pcall(A.OptionsApplied, A)
    end
    if A.pendingRestore then
        A.pendingRestore = nil
        pcall(A.RestoreLayout, A)
    end
    if A.pendingWelcome and A.initialized and not A:IsCombat() then
        A.welcomeDelay = (A.welcomeDelay or 0.5) - elapsed
        if A.welcomeDelay <= 0 then
            A.pendingWelcome, A.welcomeDelay = nil, nil
            pcall(A.OpenWelcome, A)
        end
    end
    A:TickNativeUI(elapsed)
    A:TickInfo(elapsed)
    A:TickAuraTrays(elapsed)
    A:TickDamage(elapsed)
    if A.TickCompassDivider then A:TickCompassDivider(elapsed) end
    if A.TickBumpers then A:TickBumpers(elapsed) end
    if A.TickXpLane then A:TickXpLane(elapsed) end
    if A.TickInputSwitch then A:TickInputSwitch(elapsed) end
    if A.TickClassBar then A:TickClassBar(elapsed) end
    if A.TickMapShelf then A:TickMapShelf(elapsed) end
    elapsedTime = elapsedTime + elapsed
    if elapsedTime < 0.10 then return end
    elapsedTime = 0
    if A.initialized then
        if A.dirty then
            A.dirty = false
            A:SafeRefresh()
        else
            A:SafeUpdateCasts()
        end
    end
end)
SLASH_ADAPTIVEUI1 = "/aui"
SLASH_ADAPTIVEUI2 = "/adaptiveui"
SlashCmdList.ADAPTIVEUI = function(message)
    A:Initialize()
    local ok = pcall(A.Slash, A, message)
    if not ok then A:Print("This beta rejected the configuration request. Native UI is unchanged. /aui status") end
end
