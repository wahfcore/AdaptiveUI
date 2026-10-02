local _, A = ...


























































local PROFILE = {

    { name = "test_cameraOverShoulder", value = "1.0", family = "action" },

    { name = "test_cameraDynamicPitch", value = "1", family = "action" },


    { name = "test_cameraHeadMovementStrength", value = "0", family = "action" },


    { name = "test_cameraTargetFocusEnemyEnable", value = "1", family = "action" },
    { name = "test_cameraTargetFocusEnemyStrengthYaw", value = "0.75", family = "action" },
    { name = "test_cameraTargetFocusEnemyStrengthPitch", value = "0.75", family = "action" },
    { name = "test_cameraTargetFocusInteractEnable", value = "1", family = "action" },
    { name = "cameraSmoothStyle", value = "0", family = "fixed" },
}





local PROBE_ONLY = {


    "CameraKeepCharacterCentered",



    "cameraDistanceMax", "cameraDistanceMaxZoomFactor",



    "cameraYawMoveSpeed", "cameraPitchMoveSpeed", "cameraFov", "cameraFOVSpeedSquish",
}
A.cameraProfile, A.cameraProbeOnly = PROFILE, PROBE_ONLY

local function cvarFn(name)
    local fn = _G[name]
    if type(fn) == "function" then return fn end
    fn = type(C_CVar) == "table" and C_CVar[name]
    if type(fn) == "function" then return fn end
    return nil
end





function A:CameraCVar(name)
    local info = cvarFn("GetCVarInfo")
    if not info then return nil, "no GetCVarInfo" end
    local ok, value, default, _, _, locked, secure, readOnly = pcall(info, name)
    if not ok or value == nil then return nil end
    if not self:IsPublic(value) then return nil, "restricted" end
    return {
        name = name,
        value = type(value) == "string" and value or tostring(value),
        default = type(default) == "string" and default or tostring(default),
        writable = not (locked == true or secure == true or readOnly == true),
        locked = locked == true, secure = secure == true, readOnly = readOnly == true,
    }
end



function A:CameraAvailable()
    local action, fixed = 0, 0
    for _, entry in ipairs(PROFILE) do
        local info = self:CameraCVar(entry.name)
        if info and info.writable then
            if entry.family == "action" then action = action + 1 else fixed = fixed + 1 end
        end
    end
    return action, fixed
end

local function write(self, name, value)
    local set = cvarFn("SetCVar")
    if not set then return false end
    local ok = pcall(set, name, value)
    return ok == true
end




local function remember(self, name)
    self.db.cameraRestore = self.db.cameraRestore or {}
    if self.db.cameraRestore[name] ~= nil then return end
    local get = cvarFn("GetCVar")
    local value = get and select(2, pcall(get, name)) or nil
    if type(value) ~= "string" and type(value) ~= "number" then return end
    if not self:IsPublic(value) then return end
    self.db.cameraRestore[name] = tostring(value)
end












function A:RestoreCamera(keep)
    local saved = self.db and self.db.cameraRestore
    if type(saved) ~= "table" then return 0 end
    local restored = 0
    for name, value in pairs(saved) do
        local info = self:CameraCVar(name)
        if info and info.writable and write(self, name, value) then restored = restored + 1 end
        if not keep then saved[name] = nil end
    end
    if not keep then self.db.cameraRestore = nil end
    self.cameraActive = false
    return restored
end




function A:ReleaseCamera()
    if not self.db then return end
    pcall(self.RestoreCamera, self, true)
end



function A:ApplyCamera()
    if not self.db or not self.optionIndex then return end
    local want = self:GetOption("actionCamera") == true
    if self:IsCombat() then
        if want ~= (self.cameraActive == true) then self.cameraDirty = true end
        return
    end
    self.cameraDirty = nil
    if not want then
        if self.cameraActive or (self.db.cameraRestore and next(self.db.cameraRestore)) then
            local restored = self:RestoreCamera()
            self:Note("action camera", restored > 0
                and ("off; " .. restored .. " camera settings restored") or "off")
        end
        return
    end
    if self.cameraActive then return end
    local applied, action, skipped = 0, 0, {}
    for _, entry in ipairs(PROFILE) do
        local info = self:CameraCVar(entry.name)
        if not info then
            skipped[#skipped + 1] = entry.name
        elseif not info.writable then
            skipped[#skipped + 1] = entry.name .. " (read-only)"
        else
            remember(self, entry.name)
            if write(self, entry.name, entry.value) then
                applied = applied + 1
                if entry.family == "action" then action = action + 1 end
            else
                skipped[#skipped + 1] = entry.name .. " (rejected)"
            end
        end
    end
    self.cameraActive = applied > 0
    if applied == 0 then
        self:Note("action camera", "on, but this client has none of the camera settings it needs")
        self:Print("Action camera: this client does not expose any of the camera settings it needs. Nothing was changed.")
    elseif action == 0 then
        self:Note("action camera", "on; fixed-camera only (no Retail action-camera settings in this client)")
    else
        self:Note("action camera", string.format("on; %d settings (%d action camera, %d skipped)",
            applied, action, #skipped))
    end
end




function A:CameraReport(line)
    line("-- inspect: action camera (CVar probe, READ-ONLY) --")
    line("  GetCVarInfo " .. (cvarFn("GetCVarInfo") and "available" or "MISSING")
        .. " | GetCVar " .. (cvarFn("GetCVar") and "available" or "MISSING")
        .. " | SetCVar " .. (cvarFn("SetCVar") and "available" or "MISSING"))
    local action, fixed = self:CameraAvailable()
    line(string.format("  writable: %d of the Retail action-camera settings, %d of the fixed-camera basics",
        action, fixed))
    local function report(name, applied)
        local info = self:CameraCVar(name)
        if not info then
            line("  " .. name .. ": NOT PRESENT in this client")
            return
        end
        line(string.format("  %s = %s (default %s)%s%s%s%s", name, info.value, info.default,
            info.locked and " LOCKED" or "", info.secure and " SECURE" or "",
            info.readOnly and " READONLY" or "", applied and "  <- set by the toggle" or ""))
    end
    for _, entry in ipairs(PROFILE) do report(entry.name, true) end
    for _, name in ipairs(PROBE_ONLY) do report(name, false) end
    local saved = self.db and self.db.cameraRestore
    local pending = {}
    for name in pairs(type(saved) == "table" and saved or {}) do pending[#pending + 1] = name end
    table.sort(pending)
    line("  toggle: " .. (self:GetOption("actionCamera") and "on" or "off")
        .. " | active: " .. tostring(self.cameraActive == true)
        .. " | values held for restore: " .. (#pending > 0 and table.concat(pending, ", ") or "none"))
end
