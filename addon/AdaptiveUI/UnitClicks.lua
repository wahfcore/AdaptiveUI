local _, A = ...
















































































local CLICKS = {
    { id = "Player", plate = "player", unit = "player",       opt = "plusPlayerOn" },
    { id = "Target", plate = "target", unit = "target",       opt = "plusTargetOn" },
    { id = "Focus",  plate = "focus",  unit = "focus",        opt = "plusFocusOn"  },
    { id = "Pet",    plate = "pet",    unit = "pet",          opt = "plusPetOn"    },
    { id = "Tot",    plate = "tot",    unit = "targettarget", opt = "plusTotOn"    },

    { id = "FocusTarget", plate = "focustarget", unit = "focustarget", opt = "plusFocusTargetOn" },
    { id = "FocusTargetTarget", plate = "focustargettarget", unit = "focustargettarget", opt = "plusFocusTargetTargetOn" },
}
A.unitClickDefs = CLICKS




function A:GamepadStyleOn()
    if type(C_InputInterfaceStyle) ~= "table" or type(Enum) ~= "table" then return nil end
    local style = self:Read(C_InputInterfaceStyle.GetCurrentStyle, 1)
    local kinds = Enum.InputDeviceInterfaceType
    if style == nil or type(kinds) ~= "table" or kinds.Gamepad == nil then return nil end
    return style == kinds.Gamepad
end







function A:GamepadStyleCVar()
    local get = (type(C_CVar) == "table" and C_CVar.GetCVar) or GetCVar
    if type(get) ~= "function" then return nil end
    local raw = self:Read(get, 1, "InputDeviceInterfaceStyle")
    local value = tonumber(raw)
    if value == nil then return nil end
    local kinds = type(Enum) == "table" and Enum.InputDeviceInterfaceType or nil
    if type(kinds) ~= "table" or kinds.Gamepad == nil or kinds.Mkb == nil then return nil end
    if value == kinds.Gamepad then return true end
    if value == kinds.Mkb then return false end
    return nil
end















function A:GamepadBarsShown()
    local pad, keys = _G["GamepadMainActionBarFrame"], _G["MainActionBar"]
    local padOn = pad and self:Read(pad.IsShown, 1, pad) or nil
    local keysOn = keys and self:Read(keys.IsShown, 1, keys) or nil
    if padOn == true and keysOn ~= true then return true end
    if keysOn == true and padOn ~= true then return false end
    return nil
end




function A:ClientInputStyle()
    local api = self:GamepadStyleOn()
    if api ~= nil then return api and "controller" or "keyboard", "api" end
    local cvar = self:GamepadStyleCVar()
    if cvar ~= nil then return cvar and "controller" or "keyboard", "cvar" end
    local bars = self:GamepadBarsShown()
    if bars ~= nil then return bars and "controller" or "keyboard", "bars" end
    return nil, "unreadable"
end


























function A:ClickInputMode()
    local style = self:ClientInputStyle()
    if style then return style end
    local chosen = self.db and self.db.mode
    if chosen == "controller" or chosen == "keyboard" then return chosen end
    if self.observedInput == "controller" then return "controller" end
    return "keyboard"
end



function A:InputDecision()
    local style, source = self:ClientInputStyle()
    return {
        style = style, source = source,
        api = self:GamepadStyleOn(),
        cvar = self:GamepadStyleCVar(),
        bars = self:GamepadBarsShown(),
        explicit = (self.db and self.db.mode) or "auto",
        observed = self.observedInput,
        clicks = self:ClickInputMode(),
        prompts = self.EffectiveInput and self:EffectiveInput() or nil,
        skin = (self.KeyboardSkinOn and self:KeyboardSkinOn()) and true or false,
    }
end

local function yesNo(value, yes, no)
    if value == nil then return "unknown" end
    return value and yes or no
end




function A:InputDecisionLine()
    local d = self:InputDecision()
    return string.format(
        "input: client %s (via %s; api %s, cvar %s, bars %s) | /aui mode %s | observed %s"
            .. " -> clicks %s, keyboard skin %s, prompts %s",
        d.style or "unreadable", d.source,
        yesNo(d.api, "gamepad", "mouse/keys"),
        yesNo(d.cvar, "gamepad", "mouse/keys"),
        yesNo(d.bars, "gamepad", "mouse/keys"),
        tostring(d.explicit), tostring(d.observed),
        d.clicks, d.skin and "on" or "off", tostring(d.prompts))
end





function A:UnitClicksWanted()
    if self.unitClicksEnabled == false then return false end
    if not self.plusActive then return false end
    if self.moversUnlocked or self.moversPreview then return false end
    return self:ClickInputMode() ~= "controller"
end

local function onEnter(button)
    local unit = button.auiUnit
    if not unit or type(GameTooltip) ~= "table" then return end
    pcall(GameTooltip.SetOwner, GameTooltip, button, "ANCHOR_RIGHT")
    pcall(GameTooltip.SetUnit, GameTooltip, unit)
    button.auiTooltip = unit
end

local function onLeave(button)
    button.auiTooltip = nil
    if type(GameTooltip) ~= "table" then return end
    pcall(GameTooltip.Hide, GameTooltip)
end




function A:CreateUnitClick(id, unit)
    if type(CreateFrame) ~= "function" then return nil end
    local ok, button = pcall(CreateFrame, "Button", "AdaptiveUIClick" .. id, UIParent, "SecureUnitButtonTemplate")
    if not ok or not button then
        self:Note("unit clicks", "secure template refused; plates stay display-only")
        return nil
    end
    self:Own(button)
    button.auiUnit = unit




    pcall(button.SetFrameStrata, button, "MEDIUM")
    pcall(button.RegisterForClicks, button, "AnyUp")





    pcall(button.SetAttribute, button, "unit", unit)
    pcall(button.SetAttribute, button, "*type1", "target")
    pcall(button.SetAttribute, button, "*type2", "togglemenu")



    pcall(button.SetAttribute, button, "shift-type1", "focus")
    pcall(button.SetScript, button, "OnEnter", onEnter)
    pcall(button.SetScript, button, "OnLeave", onLeave)
    pcall(button.Hide, button)
    return button
end



function A:ReleaseUnitClicks()
    if not self.unitClicks then return false end
    if self:IsCombat() then self.layoutDirty = true; return false end
    for _, button in pairs(self.unitClicks) do
        if button.auiWatched then
            pcall(UnregisterUnitWatch, button)
            button.auiWatched = nil
        end
        pcall(button.EnableMouse, button, false)
        pcall(button.Hide, button)
    end
    self.unitClicksActive = false
    return true
end
























local function seat(self, button, plate)
    local r = plate and plate.auiSeat
    if not r then
        if button.auiSeated then
            pcall(button.ClearAllPoints, button)
            button.auiSeated = nil
        end
        return false
    end
    local key = string.format("%.2f|%.2f|%.2f|%.2f", r.cx, r.cy, r.w, r.h)
    if button.auiSeated == key then return true end
    pcall(button.ClearAllPoints, button)
    pcall(button.SetPoint, button, "CENTER", UIParent, "BOTTOM", r.cx, r.cy)
    pcall(button.SetSize, button, math.max(1, r.w), math.max(1, r.h))
    button.auiSeated = key
    return true
end





function A:SecureDependencies()
    local out = {}
    for id, button in pairs(self.unitClicks or {}) do
        local names = {}
        local parent = self:Read(button.GetParent, 1, button)
        names[#names + 1] = "parent " .. self:ObjectName(parent)
        local count = self:Number(button.GetNumPoints, 1, button) or 0
        for i = 1, count do
            local ok, _, relative = pcall(button.GetPoint, button, i)
            if ok then names[#names + 1] = "anchor " .. self:ObjectName(relative or parent) end
        end
        out[id] = names
    end
    return out
end

function A:ApplyUnitClicks()


    if self:IsCombat() then self.layoutDirty = true; return false end
    if not self:UnitClicksWanted() then
        self:ReleaseUnitClicks()
        return false
    end
    local plus = self.plus
    if not plus then return false end
    self.unitClicks = self.unitClicks or {}
    local made = 0
    for _, def in ipairs(CLICKS) do
        local plate = plus[def.plate]
        local want = plate ~= nil and self:GetOption(def.opt) == true
        local button = self.unitClicks[def.id]
        if want and not button then
            button = self:CreateUnitClick(def.id, def.unit)
            if button then self.unitClicks[def.id] = button; made = made + 1 end
        end
        if button then self:SeatUnitClick(button, plate, want) end
    end
    for index, member in ipairs(plus.party and plus.party.members or {}) do
        local id = "Party" .. index
        local want = self:GetOption("plusPartyOn") == true
        local button = self.unitClicks[id]
        if want and not button then
            button = self:CreateUnitClick(id, member.unit or ("party" .. index))
            if button then self.unitClicks[id] = button; made = made + 1 end
        end
        if button then self:SeatUnitClick(button, member, want) end
    end
    self.unitClicksActive = true
    if made > 0 then
        self:Note("unit clicks", "secure overlays on the plates (keyboard mode)")
    end
    return true
end




function A:SeatUnitClick(button, plate, want)
    if want and plate and not seat(self, button, plate) then want = false end
    if want and plate then
        pcall(button.EnableMouse, button, true)
        if not button.auiWatched then



            local ok = pcall(RegisterUnitWatch, button)
            button.auiWatched = ok or nil
            if not ok then pcall(button.Show, button) end
        end
    else
        if button.auiWatched then
            pcall(UnregisterUnitWatch, button)
            button.auiWatched = nil
        end
        pcall(button.EnableMouse, button, false)
        pcall(button.Hide, button)
    end
end

function A:UnitClickReport(emit)
    emit("Plate clicks: " .. (self.unitClicksActive and "on" or "off"))
    emit("  " .. self:InputDecisionLine())


    local deps = self:SecureDependencies()
    local ids = {}
    for id in pairs(deps) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        emit("  click " .. id .. ": " .. table.concat(deps[id], ", "))
    end
end
