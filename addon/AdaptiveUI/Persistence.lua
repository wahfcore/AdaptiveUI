local _, A = ...































local MIRROR_VERSION = 1


local TRANSIENT = { inspectReport = true }
local MAX_DEPTH = 8




local function plainCopy(value, depth)
    depth = depth or 0
    local kind = type(value)
    if kind == "table" then
        if depth > MAX_DEPTH then return nil end
        local out = {}
        for key, entry in pairs(value) do
            local keyKind = type(key)
            if (keyKind == "string" or keyKind == "number") and not (depth == 0 and TRANSIENT[key]) then
                local copy = plainCopy(entry, depth + 1)
                if copy ~= nil then out[key] = copy end
            end
        end
        return out
    elseif kind == "string" or kind == "boolean" then
        return value
    elseif kind == "number" then
        if value == value and value ~= math.huge and value ~= -math.huge then return value end
    end
    return nil
end
A.PlainCopy = function(_, value) return plainCopy(value, 0) end

local function stamp()
    if type(date) == "function" then
        local ok, text = pcall(date, "%Y-%m-%d %H:%M:%S")
        if ok and type(text) == "string" then return text end
    end
    return "unknown"
end





local function rootIsEmpty(root)
    if type(root) ~= "table" then return true end
    if type(root.profiles) ~= "table" then return next(root) == nil end
    for _, profile in pairs(root.profiles) do
        if type(profile) == "table" and next(profile) ~= nil then return false end
    end
    return true
end
A.RootIsEmpty = function(_, root) return rootIsEmpty(root) end

local function mirrorIsUsable(mirror)
    if type(mirror) ~= "table" or mirror.version ~= MIRROR_VERSION then return false end
    if type(mirror.profiles) ~= "table" or type(mirror.active) ~= "string" then return false end
    local active = mirror.profiles[mirror.active]
    return type(active) == "table" and next(active) ~= nil
end



function A:RecoverFromMirror()
    self.recovered = nil
    if not rootIsEmpty(AdaptiveUIDB) then return false end
    local mirror = AdaptiveUICharDB
    if not mirrorIsUsable(mirror) then return false end
    local profiles = {}
    for name, profile in pairs(mirror.profiles) do
        if type(profile) == "table" and self.IsValidProfileName and self.IsValidProfileName(name) then
            profiles[name] = plainCopy(profile, 0)
        end
    end
    if type(profiles[mirror.active]) ~= "table" then return false end
    local root = type(AdaptiveUIDB) == "table" and AdaptiveUIDB or {}
    root.profiles = profiles
    root.profileKeys = { [self:CharacterKey()] = mirror.active }
    if type(mirror.specMap) == "table" then
        root.specProfiles = { [self:CharacterKey()] = plainCopy(mirror.specMap, 0) }
    end
    AdaptiveUIDB = root
    self.recovered = { profile = mirror.active, savedAt = mirror.savedAt, sessions = mirror.sessions }
    return true
end


























local INSPECT_CHUNK, INSPECT_MAX_LINES = 160, 900






















local function publicText(self, text)
    if type(text) ~= "string" then return false end
    if type(issecretvalue) ~= "function" then return true end
    return self:IsPublic(text)
end

function A:StoreInspectReport(text)
    if not publicText(self, text) then return false end
    local lines = {}
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        if #line <= INSPECT_CHUNK then
            lines[#lines + 1] = line
        else
            for i = 1, #line, INSPECT_CHUNK do
                lines[#lines + 1] = (i > 1 and "   +" or "") .. line:sub(i, i + INSPECT_CHUNK - 1)
            end
        end
        if #lines >= INSPECT_MAX_LINES then lines[#lines + 1] = "-- (report truncated)"; break end
    end
    AdaptiveUIInspectDB = { version = self.version, savedAt = stamp(), lines = lines }
    self.inspectStoredThisSession = true
    return true
end


function A:ScrubTransient()
    if type(self.db) == "table" then
        self.db.inspectReport, self.db.inspectVersion = nil, nil
    end

    if type(self.root) == "table" then self.root.inspect = nil end



    if self.inspectSeenAtLogin and not self.inspectStoredThisSession then AdaptiveUIInspectDB = nil end
end





local TRACE_KEEP = 8



local function estimateBytes(value, depth)
    depth = depth or 0
    local kind = type(value)
    if kind == "string" then return #value + 4 end
    if kind == "number" then return 12 end
    if kind == "boolean" then return 6 end
    if kind ~= "table" or depth > MAX_DEPTH then return 0 end
    local total = 6
    for key, entry in pairs(value) do total = total + estimateBytes(key, depth + 1) + estimateBytes(entry, depth + 1) + 4 end
    return total
end
A.EstimateBytes = function(_, value) return estimateBytes(value, 0) end

local function describeRoot(root)
    if type(root) ~= "table" then return type(root) end
    local profiles, filled = 0, 0
    for _, profile in pairs(type(root.profiles) == "table" and root.profiles or {}) do
        profiles = profiles + 1
        if type(profile) == "table" and next(profile) ~= nil then filled = filled + 1 end
    end
    return string.format("table(%d profiles, %d with data)", profiles, filled)
end

A.DescribeRoot = function(_, root) return describeRoot(root) end

function A:NoteSavedVariables()
    self.svAtAddonLoaded = describeRoot(AdaptiveUIDB)
end

function A:RecordLoadTrace(atLoginBefore)
    local root = self.root
    if type(root) ~= "table" then return end
    self.inspectSeenAtLogin = AdaptiveUIInspectDB ~= nil
    if type(root.loadTrace) ~= "table" then root.loadTrace = {} end
    local trace = root.loadTrace
    local last = type(root.lastSave) == "table" and root.lastSave or nil
    trace[#trace + 1] = string.format("%s v%s | previous save ~%s | at addon load: %s | at login: %s | %s",
        stamp(), tostring(self.version), last and (math.floor(last.bytes / 102.4 + 0.5) / 10 .. "KB") or "unknown",
        self.svAtAddonLoaded or "event not seen", atLoginBefore or "?",
        self.recovered and ("RESTORED from backup saved " .. tostring(self.recovered.savedAt)) or "used as loaded")
    while #trace > TRACE_KEEP do table.remove(trace, 1) end
end



function A:NoteSaveSize()
    local root = self.root
    if type(root) ~= "table" then return end
    root.lastSave = nil
    root.lastSave = { bytes = estimateBytes(root, 0), at = stamp() }
end

function A:SnapshotMirror()
    local root = self.root
    if type(root) ~= "table" or type(self.db) ~= "table" or type(root.profiles) ~= "table" then return false end




    local old = AdaptiveUICharDB
    if mirrorIsUsable(old) and self.db.setupDone == false then
        local previous = old.profiles[old.active]
        if type(previous) == "table" and previous.setupDone == true then return false end
    end
    local profiles = {}
    for name, profile in pairs(root.profiles) do
        if type(profile) == "table" and (not self.IsValidProfileName or self.IsValidProfileName(name)) then
            profiles[name] = plainCopy(profile, 0)
        end
    end
    local key = self:CharacterKey()
    local specs = type(root.specProfiles) == "table" and root.specProfiles[key] or nil
    AdaptiveUICharDB = {
        version = MIRROR_VERSION,
        addon = self.version,
        savedAt = stamp(),
        sessions = tonumber(root.sessions) or 0,
        active = self.profileName,
        profiles = profiles,
        specMap = type(specs) == "table" and plainCopy(specs, 0) or nil,
    }
    return true
end


function A:PersistenceReport(emit)
    local count = 0
    for _ in pairs(self.db or {}) do count = count + 1 end
    emit(string.format("Saved settings: profile \"%s\", %d stored fields, session %d.",
        tostring(self.profileName), count, tonumber(self.root and self.root.sessions) or 0))
    local mirror = AdaptiveUICharDB
    if mirrorIsUsable(mirror) then
        emit("Backup copy (this character): saved " .. tostring(mirror.savedAt) .. ", profile \"" .. mirror.active .. "\".")
    else
        emit("Backup copy (this character): not written yet; it is written when you /reload or log out.")
    end
    if self.recovered then
        emit("This session's settings were RESTORED from that backup (saved " .. tostring(self.recovered.savedAt)
            .. "): the account-wide save came up empty.")
    end
    local trace = self.root and self.root.loadTrace
    if type(trace) == "table" then
        for i = math.max(1, #trace - 2), #trace do emit("Login " .. i .. ": " .. tostring(trace[i])) end
    end
    emit("Settings reach disk when you /reload or log out; a crash or a killed client writes nothing.")
end
