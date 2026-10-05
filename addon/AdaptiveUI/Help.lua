local _, A = ...

















BINDING_HEADER_ADAPTIVEUI = "AdaptiveUI"
BINDING_NAME_ADAPTIVEUI_OPTIONS = "Open AdaptiveUI options"

function AdaptiveUI_ToggleOptions()
    if A:IsCombat() then
        A:Print("Options open after combat.")
        return
    end
    local ok = pcall(A.ToggleOptions, A)
    if not ok then A:Print("The options could not open. /aui status") end
end

function AdaptiveUI_OnAddonCompartmentClick()
    AdaptiveUI_ToggleOptions()
end




function A:SavedFilePath()
    local realm = type(GetRealmName) == "function" and self:Text(GetRealmName, 1) or nil
    local name = self:Text(UnitName, 1, "player")
    return string.format("World of Warcraft > _classic_beta_ > WTF > Account > (the folder named after your account) > %s > %s"
        .. " > SavedVariables > AdaptiveUI.lua", realm or "(your realm)", name or "(this character)")
end


A.reportLimit = 4000
function A:BuildReport()
    local lines = {}
    local function add(text) lines[#lines + 1] = tostring(text) end
    add("AdaptiveUI " .. tostring(self.version) .. " report")
    add("Client " .. tostring(self.buildVersion) .. "." .. tostring(self.buildNumber) .. " | interface "
        .. tostring(self.interfaceNumber) .. " | gate " .. tostring(self.buildTier)
        .. (self.buildTierReason and (" (" .. tostring(self.buildTierReason) .. ")") or ""))
    add("Profile " .. tostring(self.profileName) .. " | unit frames " .. tostring(self.db and self.db.unitMode)
        .. " | scheme " .. tostring(self:GetOption("themeScheme")) .. " | options " .. (self:GetOption("optionsAdvanced") and "advanced" or "simple"))
    if self.InputDecisionLine then
        local ok, line = pcall(self.InputDecisionLine, self)
        if ok then add(line) end
    end
    if self.PadProbeLines then
        local ok, probe = pcall(self.PadProbeLines, self)
        if ok then for i = 1, math.min(4, #probe) do add(probe[i]) end end
    end
    local trace = self.root and self.root.loadTrace
    if type(trace) == "table" then
        for i = math.max(1, #trace - 2), #trace do add("Login " .. i .. ": " .. tostring(trace[i])) end
    end
    local log = self.root and self.root.blockedLog
    if type(log) == "table" and #log > 0 then
        for i = math.max(1, #log - 2), #log do
            local e = log[i]
            add("Blocked: " .. tostring(e.func) .. " (" .. tostring(e.time) .. ", " .. tostring(e.culprit or "unattributed") .. ")")
        end
    else
        add("Blocked actions: none")
    end
    if self.PlateAuraLine then add(self:PlateAuraLine()) end
    local changed = self:ChangedKeys(nil)
    local parts = {}
    for _, key in ipairs(changed) do
        local v = self:GetOption(key)
        if type(v) == "table" then v = table.concat({ tostring(v[1]), tostring(v[2]) }, ",") end
        parts[#parts + 1] = key .. "=" .. tostring(v)
    end
    add("Changed from default (" .. #changed .. "): " .. (#parts > 0 and table.concat(parts, " ") or "none"))
    local text = table.concat(lines, "\n")
    if #text > self.reportLimit then text = text:sub(1, self.reportLimit - 20) .. "\n(cut at 4000)" end
    return text
end



function A:OpenReport()
    if self:IsCombat() then self:Print("Report a problem after combat."); return end
    local text = self:BuildReport()
    self.quietPrint, self.quietLines = true, nil
    local ok = pcall(self.InspectNativeFrames, self)
    self.quietPrint = nil
    local full = self.inspectText or ""
    pcall(self.StoreInspectReport, self, text .. "\n\n" .. full)
    self.reportText = text
    local ui = self:CreateReport()
    ui.box:SetText(text)
    pcall(ui.box.HighlightText, ui.box)
    pcall(ui.box.SetFocus, ui.box)
    ui.path:SetText(self:SavedFilePath())
    ui.status:SetText(ok and "The full report is saved to this file when you reload or log out:"
        or "The short report is below; the full frame report could not be made this time.")
    for _, other in ipairs({ self.options_ui and self.options_ui.frame, self.welcome and self.welcome.frame }) do
        if other then other:Hide() end
    end
    ui.frame:SetScale(self:WindowScale(ui.w, ui.h))
    self:PlaceWindow(ui.frame, "Report")
    ui.frame:Show()
    pcall(ui.frame.Raise, ui.frame)
    self:GamepadHighlight(ui.frame, ui.reload)
    self:Print("Report ready. The file is written when you reload or log out: " .. self:SavedFilePath())
end

function A:CreateReport()
    if self.reportUI then return self.reportUI end
    local K = self.optionsKit
    local W, H = 720, 470
    local frame = CreateFrame("Frame", "AdaptiveUIReport", UIParent)
    frame:SetSize(W, H)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    self:TopWindow(frame)
    frame:EnableMouse(true)
    frame.bg = K.fill(frame, "BACKGROUND", "ink", 0.97, -7)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "d", frame, 0, 0, frame, 0, 0, "raised")
    self:Rule(frame, 0, 0, W, 2)
    local ui = { frame = frame, w = W, h = H }
    K.text(frame, self.tokens.type.hero, true, 20, -16, W - 40):SetText("Report a problem")
    local steps = K.text(frame, 16, false, 20, -50, W - 40)
    steps:SetWordWrap(true)
    steps:SetHeight(44)
    steps:SetText("1. Press Ctrl+A, then Ctrl+C in the box, and paste it into your message. "
        .. "On a controller, take a screenshot of this window instead.")
    ui.box = K.editBox(frame, 20, -100, W - 40, self.reportLimit)
    ui.box:SetHeight(220)
    pcall(ui.box.SetMultiLine, ui.box, true)
    ui.status = K.text(frame, 14, false, 20, -330, W - 40, "LEFT", "muted")
    ui.status:SetWordWrap(true)
    ui.path = K.text(frame, 14, false, 20, -350, W - 40, "LEFT", "text")
    ui.path:SetWordWrap(true)
    ui.path:SetHeight(36)
    K.text(frame, 14, false, 20, -390, W - 40, "LEFT", "muted"):SetText(
        "2. Send that file too if we ask. It holds your settings and this character's name, nothing else.")
    ui.reload = K.uiButton(frame, "Reload now (writes the file)", 20, -(H - 44), 300, 30, function()
        if type(ReloadUI) == "function" and not A:IsCombat() then ReloadUI() end
    end)
    ui.close = K.uiButton(frame, "Close", W - 116, -(H - 44), 96, 30, function() frame:Hide() end)
    self:MakeMovableWindow(frame, "Report", 44)
    self:AttachSettingsNavigation(frame)
    frame:Hide()
    self.reportUI = ui
    return ui
end
