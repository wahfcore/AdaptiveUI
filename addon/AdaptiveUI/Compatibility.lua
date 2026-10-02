local addonName, A = ...
A.name = addonName




A.version = "0.60.3-beta"
do
    local getMeta = (type(C_AddOns) == "table" and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    if type(getMeta) == "function" then
        local ok, value = pcall(getMeta, addonName, "Version")
        if ok and type(value) == "string" and value ~= "" then A.version = value end
    end
end
A.sourceCommit = "70ef1b2fd78061a73f886c4a1e79dc5b5cff6d5e"
A.capabilities = {}
A.failures = {}

function A:Note(key, value)
    self.capabilities[key] = value
end

function A:IsPublic(value)
    if type(issecretvalue) ~= "function" then
        return false
    end
    local ok, secret = pcall(issecretvalue, value)
    return ok and not secret
end

function A:Read(fn, index, ...)
    if type(fn) ~= "function" then
        return nil, "unavailable"
    end
    local values = { pcall(fn, ...) }
    if not values[1] then
        return nil, "unavailable"
    end
    local value = values[(index or 1) + 1]
    if not self:IsPublic(value) then
        return nil, "restricted"
    end
    return value, "public"
end

function A:Text(fn, index, ...)
    local value = self:Read(fn, index, ...)
    if type(value) == "string" then
        return value
    end
    return nil
end

function A:Number(fn, index, ...)
    local value = self:Read(fn, index, ...)
    if type(value) == "number" then
        return value
    end
    return nil
end

function A:IsCombat()
    if self.inCombat then
        return true
    end
    if type(InCombatLockdown) ~= "function" then
        return true
    end
    local value, status = self:Read(InCombatLockdown, 1)
    if status ~= "public" then
        return true
    end
    return value == true
end









local TRACE_MAX = 12
local GLOBAL_KINDS = { focus = true, picker = true, category = true, mask = true }




local function callName(object) return object.GetName and object:GetName() end
local function callParent(object) return object.GetParent and object:GetParent() end
local function callForbidden(object) return object.IsForbidden and object:IsForbidden() end

function A:ObjectName(object)
    if not object then return "unnamed" end
    local ok, name = pcall(callName, object)
    if ok and type(name) == "string" and name ~= "" then return name end
    return "unnamed"
end

function A:KeyFor(kind, object)
    if GLOBAL_KINDS[kind] or not object then return kind end
    local name = self:ObjectName(object)
    if name == "unnamed" then
        local ok, parent = pcall(callParent, object)
        if ok and parent then name = self:ObjectName(parent) .. "/unnamed" end
    end
    return kind .. ":" .. name
end

function A:Quarantined(key)
    local q = self.root and self.root.quarantine
    return type(q) == "table" and q[key] ~= nil
end






function A:EntryKey(entry)
    return entry.key or self:KeyFor(entry.kind, entry.region)
end

function A:Trace(kind, object, detail)
    local now = type(GetTime) == "function" and select(2, pcall(GetTime)) or 0
    local ring = self.trace
    if not ring then ring = {}; self.trace = ring end
    if detail == "reassert" then
        self.reassertStats = self.reassertStats or { total = 0, second = 0, count = 0, peak = 0 }
        local st = self.reassertStats
        st.total = st.total + 1
        local bucket = math.floor(now)
        if st.second ~= bucket then st.second, st.count = bucket, 0 end
        st.count = st.count + 1
        if st.count > st.peak then st.peak = st.count end
        local last = ring[#ring]
        if last and last.reassert then
            last.kind, last.region, last.time, last.count = kind, object, now, last.count + 1
            return
        end
        ring[#ring + 1] = { kind = kind, region = object, detail = "reassert", reassert = true, count = 1, time = now }
    else
        ring[#ring + 1] = { key = self:KeyFor(kind, object), detail = detail, time = now }
    end
    if #ring > TRACE_MAX then table.remove(ring, 1) end
end


































local GEOMETRY_KINDS = { place = true, move = true, scale = true, size = true }
function A:CanWrite(kind, object)
    if kind ~= "hold" and self:IsCombat() then return false end
    if object and GEOMETRY_KINDS[kind] and self.IsHandsOff and self:IsHandsOff(object) then
        return false
    end
    if object then
        local ok, forbidden = pcall(callForbidden, object)
        if ok and forbidden == true then return false end
    end
    local q = self.root and self.root.quarantine
    if type(q) == "table" and next(q) ~= nil and q[self:KeyFor(kind, object)] ~= nil then return false end
    return true
end





function A:OnActionBlocked(event, blockedAddon, functionName)
    if blockedAddon ~= self.name or not self.root then return end
    local now = type(GetTime) == "function" and select(2, pcall(GetTime)) or 0
    local last = self.trace and self.trace[#self.trace]
    local culprit = last and last.time == now and self:EntryKey(last) or nil
    local lockdown = select(2, pcall(function() return InCombatLockdown() end))
    local stack
    if type(debugstack) == "function" then
        local ok, text = pcall(debugstack, 1, 8, 0)
        if ok and type(text) == "string" then stack = text:sub(1, 700) end
    end
    local recent = {}
    for i = math.max(1, #(self.trace or {}) - 5), #(self.trace or {}) do
        local e = self.trace[i]
        recent[#recent + 1] = self:EntryKey(e) .. (e.detail and ("(" .. tostring(e.detail) .. (e.count and (" x" .. e.count) or "") .. ")") or "")
    end
    local entry = {
        time = type(date) == "function" and date("%Y-%m-%d %H:%M:%S") or tostring(now),
        event = tostring(event), func = tostring(functionName), lockdown = lockdown == true,
        profile = self.profileName, unitMode = self.db and self.db.unitMode,
        culprit = culprit, recent = table.concat(recent, " > "), stack = stack, version = self.version,
    }
    local log = self.root.blockedLog
    if type(log) ~= "table" then log = {}; self.root.blockedLog = log end
    log[#log + 1] = entry
    while #log > 20 do table.remove(log, 1) end
    if culprit then
        if type(self.root.quarantine) ~= "table" then self.root.quarantine = {} end
        self.root.quarantine[culprit] = entry.time
        self.layoutDirty, self.nativeDirty = true, true
    end


    if self.buildTier == "provisional" then
        self:StandDownBuild(entry.func .. (culprit and (" after " .. culprit) or ""))
        return
    end




    self.blockedSeen = self.blockedSeen or {}
    local seen = self.blockedSeen[entry.func]
    self.blockedSeen[entry.func] = (seen or 0) + 1
    if seen then return end
    self:Print("A Blizzard-only action was blocked (" .. entry.func .. "). "
        .. (culprit and ("Quarantined: " .. culprit .. ". ") or "Cause not attributed. ")
        .. (self:BlockedDiagnosis(entry.func) or "") .. "See /aui status. (Repeats are counted there, not printed.)")
end








function A:BlockedDiagnosis(func)
    if type(func) ~= "string" or not func:find("^AdaptiveUI") then return nil end
    local frameName = func:match("^([%w_]+)")
    if not frameName or type(self.SecureDependencies) ~= "function" then return nil end
    local deps = self:SecureDependencies()
    for id, names in pairs(deps) do
        for _, n in ipairs(names) do
            if n:find(frameName, 1, true) then
                return "Our frame " .. frameName .. " is protected by association: secure click target "
                    .. id .. " depends on it (" .. n .. "). "
            end
        end
    end
    return "Our frame " .. frameName .. ", and no secure frame of ours depends on it. "
end

function A:ReportBlocked(emit, full)
    local log = self.root and self.root.blockedLog or {}
    emit(string.format("Blocked native actions attributed to AdaptiveUI: %d (log keeps the last 20)", #log))
    for i = full and 1 or math.max(1, #log - 2), #log do
        local e = log[i]
        emit(string.format("  [%s] %s %s | lockdown=%s profile=%s units=%s | culprit=%s | v%s",
            tostring(e.time), tostring(e.event), tostring(e.func), tostring(e.lockdown), tostring(e.profile),
            tostring(e.unitMode), tostring(e.culprit), tostring(e.version)))
        if full then
            emit("    recent native ops: " .. tostring(e.recent))
            emit("    stack: " .. (tostring(e.stack):gsub("%c+", " | ")))
        end
    end
    local keys = {}
    for key in pairs(self.root and self.root.quarantine or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    emit("Quarantined operations (skipped until /aui quarantine clear): " .. (#keys > 0 and table.concat(keys, ", ") or "none"))


    local funcs = {}
    for func in pairs(self.blockedSeen or {}) do funcs[#funcs + 1] = func end
    table.sort(funcs)
    for _, func in ipairs(funcs) do
        emit(string.format("  this session: %s x%d %s", func, self.blockedSeen[func], self:BlockedDiagnosis(func) or ""))
    end
end

function A:QuarantineCommand(argument)
    if argument == "clear" and self.root then
        self.root.quarantine = {}


        self.root.buildStandDown = {}
        self.layoutDirty, self.nativeDirty = true, true
        self:Print("Quarantine cleared; skipped operations will be retried. /reload to re-check this client build.")
        return
    end
    self:ReportBlocked(function(line) self:Print(line) end, true)
end

























A.AUDITED_VERSION, A.AUDITED_INTERFACE = "1.60.1", 16001
A.auditedBuilds = { ["69893"] = true, ["69913"] = true, ["69977"] = true, ["70009"] = true, ["70058"] = true, ["70124"] = true, ["70170"] = true }



local STRUCTURE = {
    { "PlayerFrame" }, { "TargetFrame" }, { "MinimapCluster" }, { "ObjectiveTrackerFrame" },
    { "PlayerCastingBarFrame" }, { "BuffFrame" },
    { "GamepadMainActionBarFrame" }, { "GamepadMainActionBarFrame", "PageUnit" },
}
local APIS = { "hooksecurefunc", "issecretvalue", "CreateFrame", "InCombatLockdown" }

function A:ProbeStructure()
    local missing = {}
    for _, path in ipairs(STRUCTURE) do
        local node, name = _G, {}
        for _, key in ipairs(path) do
            name[#name + 1] = key
            node = type(node) == "table" and node[key] or nil
            if node == nil then break end
        end
        if node == nil then missing[#missing + 1] = table.concat(name, ".") end
    end
    for _, api in ipairs(APIS) do
        if type(_G[api]) ~= "function" then missing[#missing + 1] = api .. "()" end
    end
    return missing
end


function A:ClassifyBuild(version, build, interface)
    local stood = self.root and type(self.root.buildStandDown) == "table" and self.root.buildStandDown[build]
    if stood then
        if self.auditedBuilds[build] and version == self.AUDITED_VERSION then return "audited" end
        return "refused", "stood down on this build (" .. tostring(stood.reason) .. ", " .. tostring(stood.time) .. ")"
    end
    if version == self.AUDITED_VERSION and self.auditedBuilds[build] then return "audited" end
    if version ~= self.AUDITED_VERSION or interface ~= self.AUDITED_INTERFACE then
        return "refused", string.format("a different patch line (%s / interface %s; audited: %s / %s): needs a real audit",
            tostring(version), tostring(interface), self.AUDITED_VERSION, tostring(self.AUDITED_INTERFACE))
    end
    local missing = self:ProbeStructure()
    if #missing > 0 then return "refused", "structure probe failed: " .. table.concat(missing, ", ") end
    return "provisional", "same patch line, structure probes passed"
end




function A:StandDownBuild(reason)
    if self.buildTier ~= "provisional" or not self.root then return false end
    if type(self.root.buildStandDown) ~= "table" then self.root.buildStandDown = {} end
    local when = type(date) == "function" and date("%Y-%m-%d %H:%M:%S") or "unknown"
    self.root.buildStandDown[self.buildNumber] = { reason = tostring(reason), time = when, version = self.version }
    self.buildTier, self.buildTierReason = "refused", "stood down: " .. tostring(reason)
    self.auditedSink = false
    self.nativeDirty, self.layoutDirty, self.dirty = true, true, true
    self:Note("build gate", "refused: " .. self.buildTierReason)
    self:Print("Client build " .. tostring(self.buildNumber) .. " is not audited and just blocked an action ("
        .. tostring(reason) .. "). Standing down on this build: native UI is being handed back. /aui build for details.")
    return true
end

function A:Discover()
    local version = self:Text(GetBuildInfo, 1)
    local build = self:Read(GetBuildInfo, 2)
    local interface = self:Number(GetBuildInfo, 4)
    self.buildVersion = version or "unavailable"
    self.buildNumber = (type(build) == "string" or type(build) == "number") and tostring(build) or "unavailable"
    self.interfaceNumber = interface






















    self.buildTier, self.buildTierReason = self:ClassifyBuild(version, self.buildNumber, interface)
    self.auditedSink = self.buildTier == "audited" or self.buildTier == "provisional"
    self:Note("build gate", self.buildTier .. (self.buildTierReason and (": " .. self.buildTierReason) or ""))
    if self.buildTier == "provisional" and self.root then
        if type(self.root.buildNoticed) ~= "table" then self.root.buildNoticed = {} end
        if not self.root.buildNoticed[self.buildNumber] then
            self.root.buildNoticed[self.buildNumber] = true
            self.pendingBuildNotice = true
        end
    end
    self:Note("secret detector", type(issecretvalue) == "function" and "available" or "missing: public reads disabled")









    if type(C_Secrets) == "table" then
        local names = {}
        for key in pairs(C_Secrets) do names[#names + 1] = tostring(key) end
        table.sort(names)
        self:Note("C_Secrets", #names > 0 and table.concat(names, ", ") or "present but empty")
    else
        self:Note("C_Secrets", "unavailable on this client")
    end
    if type(C_RestrictedActions) == "table" and type(C_RestrictedActions.IsAddOnRestrictionTypeActive) == "function" then
        self:Note("restriction states", "C_RestrictedActions.IsAddOnRestrictionTypeActive available")
    end
    self:Note("StatusBar sink", self.auditedSink and "matching-source direct sink; runtime test required" or "unmatched build: public values only")
    self:DiscoverBarMotion()
    self:Note("native controls", "cosmetic styling only; gameplay, bindings and CVars retained")
    self:Note("cooldown/aura replacement", "native displays styled; no custom timers or aura logic")
    self.energyType = Enum and Enum.PowerType and Enum.PowerType.Energy
    self.comboType = Enum and Enum.PowerType and Enum.PowerType.ComboPoints
    self:Note("energy enum", type(self.energyType) == "number" and "available" or "unavailable")
    self:Note("combo enum", type(self.comboType) == "number" and "available" or "unavailable")
end
























































function A:DiscoverBarMotion()

    local eased
    if type(Enum) == "table" and type(Enum.StatusBarInterpolation) == "table" then
        local value = Enum.StatusBarInterpolation.ExponentialEaseOut
        if self:IsPublic(value) and type(value) == "number" then eased = value end
    end



    if eased and type(CreateFrame) == "function" then
        local ok, probe = pcall(CreateFrame, "StatusBar", nil, UIParent)
        if ok and probe then
            self:Own(probe)
            pcall(probe.Hide, probe)
            pcall(probe.SetMinMaxValues, probe, 0, 1)
            if pcall(probe.SetValue, probe, 0.5, eased) then self.barInterpolation = eased end
        end
    end
    self:Note("bar interpolation", self.barInterpolation
        and "Enum.StatusBarInterpolation.ExponentialEaseOut accepted: eased loss trail"
        or "unavailable: loss trail runs on a delayed re-read instead")
    self.healCalculator = type(CreateUnitHealPredictionCalculator) == "function"
    self.incomingHeals = type(UnitGetIncomingHeals) == "function"
    self:Note("heal prediction", self.healCalculator and "CreateUnitHealPredictionCalculator"
        or (self.incomingHeals and "UnitGetIncomingHeals into an anchored sink"
            or "unavailable: the heal ghost is a one-shot light instead"))
end

local function directSink(bar, valueAPI, maxAPI, unit, power)
    bar:SetMinMaxValues(0, maxAPI(unit, power))
    bar:SetValue(valueAPI(unit, power))
end

function A:EmptyBar(widget, label, reason)
    widget.value:SetMinMaxValues(0, 1)
    widget.value:SetValue(0)
    widget.label:SetText(label)
    widget.text:SetText(reason or "Native display")
end

function A:UpdateBar(widget, label, valueAPI, maxAPI, unit, power)
    if widget.failed then
        self:EmptyBar(widget, label, "Native display")
        return
    end
    if type(valueAPI) ~= "function" or type(maxAPI) ~= "function" then
        self:EmptyBar(widget, label, "Native display")
        self:Note(label, "API unavailable; stock display retained")
        return
    end
    local current, currentStatus = self:Read(valueAPI, 1, unit, power)
    local maximum, maximumStatus = self:Read(maxAPI, 1, unit, power)
    local publicNumbers = currentStatus == "public" and maximumStatus == "public"
        and type(current) == "number" and type(maximum) == "number"
    local ok
    if self.auditedSink then


        ok = pcall(directSink, widget.value, valueAPI, maxAPI, unit, power)
    elseif publicNumbers and maximum > 0 then
        ok = pcall(function()
            widget.value:SetMinMaxValues(0, maximum)
            widget.value:SetValue(current)
        end)
    else
        self:EmptyBar(widget, label, "Native display")
        self:Note(label, "restricted/unknown; stock display retained")
        return
    end
    if not ok then
        widget.failed = true
        self.failures[label] = true
        self:EmptyBar(widget, label, "Native display")
        self:Note(label, "sink rejected; disabled until reload")
        return
    end
    widget.label:SetText(label)
    if publicNumbers then
        widget.text:SetText(string.format("%.0f / %.0f", current, maximum))
        self:Note(label, "native bar + public number text")
    else
        widget.text:SetText("")
        self:Note(label, "direct native sink; no number inspection")
    end
end

function A:GetIdentity()
    local name = self:Text(UnitName, 1, "player") or "Player"
    local className = self:Text(UnitClass, 1, "player") or "Class unavailable"
    local classToken = self:Text(UnitClass, 2, "player")
    local race = self:Text(UnitRace, 1, "player") or "Race unavailable"
    local faction = self:Text(UnitFactionGroup, 1, "player") or "Faction unavailable"
    local powerToken = self:Text(UnitPowerType, 2, "player")
    local powerType = self:Number(UnitPowerType, 1, "player")
    local form = "Native shapeshift controls"
    local slot = self:Number(GetShapeshiftForm, 1)
    if slot and slot > 0 then
        local spellID = self:Number(GetShapeshiftFormInfo, 4, slot)
        local spellName = C_Spell and self:Text(C_Spell.GetSpellName, 1, spellID)
        form = spellName or ("Form slot " .. slot)
    elseif slot == 0 then
        form = "Caster form"
    end
    return {
        name = name, className = className, classToken = classToken,
        race = race, faction = faction, form = form, powerToken = powerToken, powerType = powerType,
    }
end

function A:RegisterOptionalEvent(frame, event)
    local ok = pcall(frame.RegisterEvent, frame, event)
    self:Note("event " .. event, ok and "registered" or "unavailable")
    return ok
end




function A:ObserveInput()
    if self.inputRegistered then
        return
    end
    self.inputRegistered = true
    local enabled
    if type(C_GamePad) == "table" then enabled = self:Read(C_GamePad.IsEnabled, 1) end
    if enabled == true then self:SetObservedInput("controller")
    elseif enabled == false then self:SetObservedInput("keyboard") end
    self:Note("input observer", type(C_GamePad) == "table" and "C_GamePad + GAME_PAD_* events"
        or "unavailable: use /aui mode controller|keyboard")
end
