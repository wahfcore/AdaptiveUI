local _, A = ...
























A.elementAlphaMin = 0.2

local function list(...)
    local out = {}
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v ~= nil then out[#out + 1] = v end
    end
    return out
end

local function plate(unit)
    return function(self) return list(self.plus and self.plus[unit]) end
end


local function decorations(self, module)
    local state = self.nativeSkins and self.nativeSkins[module]
    return state and state.decorations or {}
end



local function keyboardArt(self)
    local entries = decorations(self, "actions")[_G["MainActionBar"] or false]
    return list(entries and entries.kbSlab)
end



local function compassArt(self)
    local out = {}
    for _, entries in pairs(decorations(self, "actions")) do
        if type(entries) == "table" then
            for _, key in ipairs({ "groundDivider", "bumperLeft", "bumperRight" }) do
                if entries[key] then out[#out + 1] = entries[key] end
            end
        end
    end
    return out
end



local function mapArt(self)
    local out = {}
    local entries = decorations(self, "minimap")[_G["MinimapCluster"] or false]
    if type(entries) ~= "table" then return out end
    for _, key in ipairs({ "paint", "paintAcc", "mapHalo", "mapBack", "mapRise", "mapFade", "mapEdgeHost" }) do
        if entries[key] then out[#out + 1] = entries[key] end
    end
    return out
end

local function global(...)
    local names = { ... }
    return function() local out = {}; for _, n in ipairs(names) do if _G[n] then out[#out + 1] = _G[n] end end; return out end
end





A.elements = {
    { id = "plusPlayer", label = "Player plate", own = true, frames = plate("player"), look = "plates", mover = "plusPlayer" },
    { id = "plusTarget", label = "Target plate", own = true, frames = plate("target"), look = "plates", mover = "plusTarget" },
    { id = "plusFocus", label = "Focus plate", own = true, frames = plate("focus"), look = "smallPlates", mover = "plusFocus" },
    { id = "plusPet", label = "Pet plate", own = true, frames = plate("pet"), look = "smallPlates", mover = "plusPet" },
    { id = "plusTot", label = "Target of target", own = true, frames = plate("tot"), look = "smallPlates", mover = "plusTot" },
    { id = "plusFocustarget", label = "Focus's target", own = true, frames = plate("focustarget"), look = "smallPlates",
      mover = "plusFocustarget" },
    { id = "plusFocustargettarget", label = "Focus's target's target", own = true, frames = plate("focustargettarget"),
      look = "smallPlates", mover = "plusFocustargettarget" },
    { id = "plusParty", label = "Party plates", own = true, frames = plate("party"), look = "smallPlates", mover = "plusParty" },
    { id = "raid", label = "Raid frames", look = "raid" },
    { id = "damageStrip", label = "Damage strip", own = true, frames = function(self) return list(self.damageStrip) end },
    { id = "compact", label = "Resource strip", own = true, frames = function(self) return list(self.compactHUD) end,
      mover = "compact" },
    { id = "castPlayer", label = "Player cast bar", own = true, look = "castPlayer", mover = "castPlayer",
      frames = function(self) return list(self.castBars and self.castBars.player) end },
    { id = "castTarget", label = "Target cast bar", own = true, look = "castTarget", mover = "castTarget",
      frames = function(self) return list(self.castBars and self.castBars.target) end },
    { id = "castFocus", label = "Focus cast bar", own = true, look = "castFocus", mover = "castFocus",
      frames = function(self) return list(self.castBars and self.castBars.focus) end },
    { id = "actionCompass", label = "Controller bars", look = "compass", mover = "actionCompass" },
    { id = "compassArt", label = "Divider and bumper plaques", own = true, frames = compassArt, look = "bumpers" },
    { id = "actionBar1", label = "Action bar 1", look = "keyboard", mover = "actionBar1" },
    { id = "keyboardArt", label = "Painting under bar 1", own = true, frames = keyboardArt },
    { id = "actionBar2", label = "Action bar 2", extraBar = "MultiBarBottomLeft", look = "extraBar", mover = "actionBar2" },
    { id = "actionBar3", label = "Action bar 3", extraBar = "MultiBarBottomRight", look = "extraBar", mover = "actionBar3" },
    { id = "actionBar4", label = "Action bar 4", extraBar = "MultiBarRight", look = "extraBar", mover = "actionBar4" },
    { id = "actionBar5", label = "Action bar 5", extraBar = "MultiBarLeft", look = "extraBar", mover = "actionBar5" },
    { id = "actionBar6", label = "Action bar 6", extraBar = "MultiBar5", look = "extraBar", mover = "actionBar6" },
    { id = "actionBar7", label = "Action bar 7", extraBar = "MultiBar6", look = "extraBar", mover = "actionBar7" },
    { id = "actionBar8", label = "Action bar 8", extraBar = "MultiBar7", look = "extraBar", mover = "actionBar8" },
    { id = "stanceBar", label = "Stance bar", extraBar = "StanceBar", look = "extraBar", mover = "stanceBar" },
    { id = "petBar", label = "Pet bar", extraBar = "PetActionBar", look = "extraBar", mover = "petBar" },
    { id = "possessBar", label = "Possess bar", extraBar = "PossessActionBar", look = "extraBar", mover = "possessBar" },
    { id = "minimap", label = "Minimap", native = true, frames = global("MinimapCluster"), look = "minimap", mover = "minimap" },
    { id = "mapArt", label = "Map plaque and shadow", own = true, frames = mapArt },
    { id = "objectives", label = "Objectives", native = true, frames = global("ObjectiveTrackerFrame"), look = "objectives",
      mover = "objectives" },
    { id = "chat", label = "Chat", native = true, frames = global("ChatFrame1"), look = "chat", mover = "chat" },
    { id = "auras", label = "Buffs and debuffs", native = true, frames = global("BuffFrame", "DebuffFrame"), look = "auras",
      mover = "auras" },
    { id = "infoBar", label = "Info bar", own = true, frames = function(self) return list(self.info and self.info.bar) end,
      mover = "infoBar" },
    { id = "windows", label = "Options windows", look = "windows" },
}
A.elementIndex = {}
for _, e in ipairs(A.elements) do A.elementIndex[e.id] = e end



A.extraBarIds = { "actionBar2", "actionBar3", "actionBar4", "actionBar5", "actionBar6", "actionBar7", "actionBar8",
    "stanceBar", "petBar", "possessBar" }

A.kbBarElement = { bar2 = "actionBar2", bar3 = "actionBar3", right1 = "actionBar4", right2 = "actionBar5",
    extra1 = "actionBar6", extra2 = "actionBar7", extra3 = "actionBar8", stance = "stanceBar", pet = "petBar",
    possess = "possessBar" }



A.extraBarScaled = { actionBar6 = true, actionBar7 = true, actionBar8 = true }





local function addOption(option)
    if A.optionIndex[option.key] then return end
    option.sparse = true
    A.options[#A.options + 1] = option
    A.optionIndex[option.key] = option
end

for _, e in ipairs(A.elements) do
    if e.own or e.native then
        addOption({ key = "alpha." .. e.id, tab = "elements", label = e.label .. ": opacity", type = "number",
            default = 1, min = A.elementAlphaMin, max = 1, step = 0.05, format = "%.0f%%", scale = 100 })
    end
    if e.extraBar then
        addOption({ key = "skin." .. e.id, tab = "elements", label = e.label .. ": look", type = "enum", default = "tiles",
            values = {
                { value = "tiles", label = "AdaptiveUI's tiles" },
                { value = "blizzard", label = "Blizzard's" },
            } })
    end
end

for _, id in ipairs(A.extraBarIds) do
    addOption({ key = "pos." .. id, tab = "movers", type = "offset", default = { 0, 0 } })
end
for id in pairs(A.extraBarScaled) do
    addOption({ key = "scale." .. id, tab = "movers", label = A.elementIndex[id].label .. " size", type = "number",
        default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" })
end

if A.ApplyHandsOffWords then A:ApplyHandsOffWords() end





function A:ElementAlpha(id)
    local key = "alpha." .. id
    if not self.optionIndex[key] then return 1 end
    local v = tonumber(self:GetOption(key)) or 1
    if v ~= v then return 1 end
    return math.max(self.elementAlphaMin, math.min(1, v))
end








local EPS = 1 / 512
local function holdsFor(self)
    self.alphaHolds = self.alphaHolds or setmetatable({}, { __mode = "k" })
    return self.alphaHolds
end

local function writeHeld(self, obj, h)
    local want = h.base * h.mul
    if h.native and not self:CanWrite("hold", obj) then
        self.nativeDirty = true
        return
    end
    if h.native then self:Trace("hold", obj, "alpha") end
    self.alphaWriting = true
    pcall(obj.SetAlpha, obj, want)
    self.alphaWriting = nil
    h.shown = want
end

local function onAlphaWrite(obj, value)
    if A.alphaWriting then return end
    local h = A.alphaHolds and A.alphaHolds[obj]
    if not h then return end
    if not A:IsPublic(value) or type(value) ~= "number" or value ~= value then return end
    if h.shown and math.abs(value - h.shown) <= EPS then return end
    h.base = math.max(0, math.min(1, value))
    writeHeld(A, obj, h)
end
local function alphaHook(obj, value)
    pcall(onAlphaWrite, obj, value)
end

local function hold(self, obj, mul, native)
    if type(obj) ~= "table" or type(obj.SetAlpha) ~= "function" or type(obj.GetAlpha) ~= "function" then return false end
    local holds = holdsFor(self)
    local h = holds[obj]
    if not h then

        local base = obj:GetAlpha()
        if not self:IsPublic(base) or type(base) ~= "number" or base ~= base then return false end
        h = { base = base, native = native }
        holds[obj] = h
    end
    self.alphaHooked = self.alphaHooked or setmetatable({}, { __mode = "k" })
    if not self.alphaHooked[obj] and type(hooksecurefunc) == "function" then
        if pcall(hooksecurefunc, obj, "SetAlpha", alphaHook) then self.alphaHooked[obj] = true end
    end
    if h.mul ~= mul then
        h.mul = mul
        writeHeld(self, obj, h)
    end
    return true
end



function A:ReleaseAlpha(obj)
    local holds = self.alphaHolds
    local h = holds and holds[obj]
    if not h then return false end
    holds[obj] = nil
    if h.native and not self:CanWrite("hold", obj) then self.nativeDirty = true; holds[obj] = h; return false end
    self.alphaWriting = true
    pcall(obj.SetAlpha, obj, h.base)
    self.alphaWriting = nil
    return true
end







function A:HoldAlpha(_, frame, mul)
    mul = tonumber(mul) or 1
    if mul >= 1 - 1e-6 then return self:ReleaseAlpha(frame) end
    if self:IsOwn(frame) then return false end
    if not self:CanWrite("hold", frame) then return false end
    return hold(self, frame, mul, true)
end



function A:OwnAlpha(frame, mul)
    mul = tonumber(mul) or 1
    if mul >= 1 - 1e-6 then return self:ReleaseAlpha(frame) end
    return hold(self, frame, mul, false)
end



function A:ApplyElementAlphas()
    if not self.db then return end
    local nativeOK = self.auditedSink and not self.editModeActive
    self.elementFrames = self.elementFrames or {}
    for _, e in ipairs(self.elements) do
        if e.frames then
            local mul = self:ElementAlpha(e.id)
            local ok, frames = pcall(e.frames, self)
            frames = ok and frames or {}
            local seen = {}
            for _, f in ipairs(frames) do
                seen[f] = true
                if e.native then
                    if nativeOK then self:HoldAlpha(nil, f, mul) else self:ReleaseAlpha(f) end
                else
                    self:OwnAlpha(f, mul)
                end
            end

            for _, f in ipairs(self.elementFrames[e.id] or {}) do
                if not seen[f] then self:ReleaseAlpha(f) end
            end
            self.elementFrames[e.id] = frames
        end
    end
end







local function valuesOf(self, key, extra, rename)
    local option = self.optionIndex[key]
    local out = {}
    if not option then return out end
    for _, entry in ipairs(option.values) do
        local set = { [key] = entry.value }
        for k, v in pairs(extra or {}) do set[k] = v end
        out[#out + 1] = { label = (rename and rename[entry.value]) or entry.label, set = set }
    end
    return out
end

local function withBlizzard(out, module)
    for _, entry in ipairs(out) do entry.set["skins." .. module] = true end
    out[#out + 1] = { label = "Blizzard's", set = { ["skins." .. module] = false } }
    return out
end

A.elementLooks = {
    plates = function(self)
        local out = valuesOf(self, "plateSkin", { unitMode = "plus" })
        out[#out + 1] = { label = "Blizzard's", set = { unitMode = "lite" } }
        return out
    end,
    smallPlates = function(self) return valuesOf(self, "plateSmallSkin") end,
    raid = function(self) return withBlizzard(valuesOf(self, "raidSkin"), "party") end,
    castPlayer = function(self) return valuesOf(self, "castPlayerMode") end,
    castTarget = function(self) return valuesOf(self, "castTargetMode") end,
    castFocus = function(self) return valuesOf(self, "castFocusMode") end,
    compass = function(self) return withBlizzard(valuesOf(self, "compassGround"), "actions") end,
    bumpers = function(self) return valuesOf(self, "compassBumperSkin") end,
    keyboard = function(self) return valuesOf(self, "keyboardSkin", nil, { classic = "Blizzard's" }) end,
    minimap = function(self) return withBlizzard(valuesOf(self, "mapSkin"), "minimap") end,
    objectives = function(self) return withBlizzard(valuesOf(self, "trackerStyle"), "objectives") end,
    chat = function(self) return withBlizzard(valuesOf(self, "chatStyle"), "chat") end,
    auras = function(self)
        return { { label = "Styled", set = { ["skins.auras"] = true } }, { label = "Blizzard's", set = { ["skins.auras"] = false } } }
    end,
    windows = function(self) return valuesOf(self, "windowSkin") end,
}

function A:ElementLooks(id)
    local e = self.elementIndex[id]
    if not e or not e.look then return nil end
    if e.look == "extraBar" then return valuesOf(self, "skin." .. id) end
    local build = self.elementLooks[e.look]
    return build and build(self) or nil
end

local function holds(self, set)
    for k, v in pairs(set) do
        if not self.optionIndex[k] or self:GetOption(k) ~= v then return false end
    end
    return true
end


function A:ElementLook(id)
    local looks = self:ElementLooks(id)
    if not looks then return nil end
    for i, entry in ipairs(looks) do if holds(self, entry.set) then return i, looks end end
    return nil, looks
end

function A:SetElementLook(id, index)
    local looks = self:ElementLooks(id)
    local entry = looks and looks[index]
    if not entry then return false, "no such look" end
    for k, v in pairs(entry.set) do
        local ok, why = self:SetOption(k, v, true)
        if not ok then return false, why end
    end
    self:OptionsApplied()
    return true
end

function A:StepElementLook(id, direction)
    local index, looks = self:ElementLook(id)
    if not looks or #looks == 0 then return false end
    index = index or (direction > 0 and 0 or 1)
    return self:SetElementLook(id, (index - 1 + direction) % #looks + 1)
end


function A:ExtraBarLook(key)
    local id = self.kbBarElement[key] or key
    if not self.elementIndex[id] or not self.elementIndex[id].extraBar then return "tiles" end
    return self:GetOption("skin." .. id) or "tiles"
end


function A:ExtraBarsShown()
    local out = {}
    for _, id in ipairs(self.extraBarIds) do
        local frame = _G[self.elementIndex[id].extraBar]
        if type(frame) == "table" and self:Read(frame.IsShown, 1, frame) == true then out[#out + 1] = id end
    end
    return out
end


function A:ResetExtraBars()
    if self:IsCombat() then return false, "combat" end
    for _, id in ipairs(self.extraBarIds) do
        self:SetOption("pos." .. id, { 0, 0 }, true)
        self:SetOption("skin." .. id, "tiles", true)
        if self.optionIndex["scale." .. id] then self:SetOption("scale." .. id, 1, true) end
    end
    self:OptionsApplied()
    return true
end


function A:ElementStateText(id)
    local e = self.elementIndex[id]
    if not e then return "" end
    local parts = {}
    if e.own or e.native then parts[#parts + 1] = string.format("Opacity %d%%.", math.floor(self:ElementAlpha(id) * 100 + 0.5)) end
    local index, looks = self:ElementLook(id)
    if looks then parts[#parts + 1] = "Look: " .. (index and looks[index].label or "your own mix") .. "." end
    if #parts == 0 then return "" end
    return table.concat(parts, " ")
end















A.spikeScale, A.spikeAlpha = 1.2, 0.5

function A:SpikeCommand(first, second)
    local bar = _G.MultiBarBottomLeft
    first, second = (first or ""):lower(), (second or ""):lower()
    local prop, action = "scale", first
    if first == "scale" or first == "alpha" then prop, action = first, second end
    local out = {}
    local function say(text) self:Print(text); out[#out + 1] = text end
    if type(bar) ~= "table" then say("spike: Action bar 2 (MultiBarBottomLeft) is not on this client."); return false end
    if action ~= "read" and self:IsCombat() then say("spike: not in combat (only `read` works in a fight)."); return false end
    self.spikeState = self.spikeState or { properties = {} }
    local state = self.spikeState
    local function num(method)
        local ok, v = pcall(bar[method], bar)
        if not ok then return "error" end
        if not self:IsPublic(v) then return "SECRET" end
        return type(v) == "number" and string.format("%.3f", v) or tostring(v)
    end
    local blocked = function()
        local log = self.root and self.root.blockedLog
        return type(log) == "table" and #log or 0
    end
    if action == "on" then
        if prop == "scale" then


            say("spike scale on: retired -- Action bar 2's size is set in Edit Mode (Esc > Edit Mode). Nothing changed; "
                .. "its scale reads " .. num("GetScale") .. ".")
        else
            self:HoldAlpha(state, bar, self.spikeAlpha)
            say(string.format("spike alpha on: Action bar 2 held at %d%%; alpha reads %s.", self.spikeAlpha * 100, num("GetAlpha")))
        end
        self.spikeBlocked = blocked()
    elseif action == "off" then
        if prop == "scale" then
            say("spike scale off: retired -- nothing was scaled (" .. num("GetScale") .. ").")
        else
            self:ReleaseAlpha(bar)
            say("spike alpha off: Blizzard's own alpha is back (" .. num("GetAlpha") .. ").")
        end
    elseif action == "read" then
        say("spike read (" .. (self:IsCombat() and "IN combat" or "out of combat") .. ")")
        local ok, x, y, w, h = pcall(bar.GetRect, bar)
        local public = ok and self:IsPublic(x) and self:IsPublic(y) and self:IsPublic(w) and self:IsPublic(h)
        say(public and type(x) == "number" and string.format("  rect %.1f %.1f %.1f %.1f (public)", x, y, w or 0, h or 0)
            or "  rect: " .. (ok and "SECRET or missing" or "error"))
        say("  scale " .. num("GetScale") .. "  effective " .. num("GetEffectiveScale") .. "  alpha " .. num("GetAlpha")
            .. "  shown " .. num("IsShown"))
        say("  Edit Mode default spot: " .. (type(bar.IsInDefaultPosition) == "function" and num("IsInDefaultPosition") or "n/a")
            .. "  Bar Visible: " .. tostring(self:IsPublic(bar.visibility) and bar.visibility or "?"))
        local okOver, over = pcall(function() return MouseIsOver(bar) end)
        if not okOver then say("  MouseIsOver: error")
        elseif not self:IsPublic(over) then say("  MouseIsOver: SECRET (not public; a hover reveal must fail closed)")
        else say("  MouseIsOver: " .. tostring(over) .. " (public)") end
        say(string.format("  blocked actions: %d on file, %d since `on`", blocked(), blocked() - (self.spikeBlocked or blocked())))
    else
        say(string.format("spike: would hold Action bar 2's opacity at %d%% (`/aui spike alpha on|read|off`). "
            .. "Its size and place are Edit Mode's. Nothing changed.", self.spikeAlpha * 100))
    end
    local text = table.concat(out, "\n")
    local prior = type(self.inspectText) == "string" and (self.inspectText .. "\n") or ""
    self.inspectText = prior .. text
    if self.StoreInspectReport and self:StoreInspectReport(self.inspectText) then
        self:Print("spike saved with the inspect dump: /reload and send AdaptiveUIInspectDB.")
    end
    return true
end
