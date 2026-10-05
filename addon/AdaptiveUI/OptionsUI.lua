local _, A = ...











local ROW_H = 34
local PALETTE = { { 0.56, 0.60, 0.98 }, { 0.46, 0.87, 0.67 }, { 0.91, 0.48, 0.40 }, { 1.00, 0.78, 0.31 },
    { 0.35, 0.70, 1.00 }, { 0.85, 0.85, 0.90 } }

local function text(parent, size, heading, x, y, width, justify, role)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    A:SetThemedFont(fs, size, heading)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetWidth(width)
    fs:SetJustifyH(justify or "LEFT")
    fs:SetWordWrap(false)
    A:Tint(fs, role or "text", "text")
    return fs
end



local function fill(parent, layer, role, alpha, sublevel)
    local t = parent:CreateTexture(nil, layer, nil, sublevel)
    t:SetAllPoints()
    A:Tint(t, role, "color", alpha)
    return t
end


local function uiButton(parent, label, x, y, width, height, onClick, keepConfirm)
    local b = CreateFrame("Button", nil, parent)
    A:AddFocusable(b)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(width, height)
    b.bg = fill(b, "BACKGROUND", "control")
    b.label = text(b, A.tokens.type.body, false, 8, -((height - 14) / 2), width - 16, "LEFT")
    b.label:SetText(label)
    b:SetScript("OnEnter", function() A:HoverTint(b.bg, true) end)
    b:SetScript("OnLeave", function() A:HoverTint(b.bg, false) end)
    b:SetScript("OnClick", function()
        if A:IsCombat() then A:Print("Settings controls are unavailable in combat."); return end

        if not keepConfirm and A.confirmArmed then A:ClearConfirm(); A:RefreshConfirmLabels() end
        onClick(b)
    end)
    return b
end




local function confirmButton(parent, label, x, y, width, height, keyFn, action)
    local b
    b = uiButton(parent, label, x, y, width, height, function()
        if A:Confirmed(keyFn(), 6) then
            A:RefreshConfirmLabels()
            action()
        else
            A:RefreshConfirmLabels()
        end
    end, true)
    b.baseLabel, b.confirmKey = label, keyFn
    A.confirmButtons = A.confirmButtons or setmetatable({}, { __mode = "k" })
    A.confirmButtons[b] = true
    return b
end

function A:RefreshConfirmLabels()
    local now = type(GetTime) == "function" and select(2, pcall(GetTime)) or 0
    for b in pairs(self.confirmButtons or {}) do
        local armed = self.confirmArmed
        local isArmed = armed and now <= armed.expires and armed.key == b.confirmKey()

        local armedText = "Press again: " .. b.baseLabel .. (#b.baseLabel <= 12 and " (6 s)" or "")
        b.label:SetText(isArmed and armedText or b.baseLabel)
    end
end

local function editBox(parent, x, y, width, letters)
    local e = CreateFrame("EditBox", nil, parent)
    A:AddFocusable(e, "edit")
    e:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    e:SetSize(width, 26)
    e:SetAutoFocus(false)
    e:SetMaxLetters(letters or 64)
    A:SetThemedFont(e, A.tokens.type.body, false)
    fill(e, "BACKGROUND", "well")
    e:SetScript("OnEscapePressed", function() e:ClearFocus() end)
    e:SetScript("OnEnterPressed", function() e:ClearFocus() end)
    return e
end

local function roundTo(value, step)
    if not step then return value end
    return math.floor(value / step + 0.5) * step
end

local function formatNumber(option, value)
    return string.format(option.format or "%.2f", value * (option.scale or 1))
end


local builders = {}




local function pickColour(option)
    local c = A:GetOption(option.key)


    local function apply(r, g, b)
        local old = A:GetOption(option.key)
        A:SetOption(option.key, { r, g, b, old[4] }, true)
        if option.key == "accent" then A:SetOption("accentCustom", true, true) end
        A:QueueOptionsApplied()
    end
    if A:OwnColorPickerOnly() then
        A:OpenColorPicker(option.key, option.hasOpacity, option.label)
        return
    end
    local picker = _G.ColorPickerFrame
    A:Trace("picker", picker, "show")
    local ok = pcall(picker.SetupColorPickerAndShow, picker, {
        r = c[1], g = c[2], b = c[3], hasOpacity = false,
        swatchFunc = function() apply(picker:GetColorRGB()) end,
        cancelFunc = function() A:SetOption(option.key, c, true); A:QueueOptionsApplied() end,
    })
    if ok then return end

    local index = 0
    for i, p in ipairs(PALETTE) do
        if math.abs(p[1] - c[1]) < 0.01 and math.abs(p[2] - c[2]) < 0.01 then index = i end
    end
    local p = PALETTE[index % #PALETTE + 1]
    apply(p[1], p[2], p[3])
end











function builders.scheme(A_, parent, option, y, ctx)
    ctx = ctx or {}
    local width = ctx.width or 430
    local schemes = ctx.schemes or A:PickerSchemes()
    local cols, gap = 4, 4
    local tileW = math.floor((width - (cols - 1) * gap) / cols)
    local tileH = 46
    local pitch = tileH + 6
    local rows = math.ceil(#schemes / cols)
    local tiles = {}
    local top = y
    for i, scheme in ipairs(schemes) do
        local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
        local tx, ty = col * (tileW + gap), top - row * pitch
        local id = scheme.id
        local tile = uiButton(parent, "", tx, ty, tileW, tileH, function()
            local ok, why = A:SetOption(option.key, id)
            if not ok then A:Print(why or "That scheme cannot be used.") end
        end)
        tile.schemeId = id

        local inset = 2
        local thumbW, thumbH = math.floor(tileW * 0.42), tileH - 2 * inset
        tile.thumb = {}
        A:SchemeThumb(tile, tile.thumb, "t", scheme, inset, -inset, thumbW, thumbH, false, "ARTWORK", 1)
        tile.label:ClearAllPoints()
        tile.label:SetPoint("TOPLEFT", tile, "TOPLEFT", inset + thumbW + 8, -7)
        tile.label:SetWidth(tileW - thumbW - inset - 12)
        tile.label:SetText(A.schemeShort[id] or scheme.name)
        tile.tag = text(tile, A.tokens.type.body, false, inset + thumbW + 8, -25, tileW - thumbW - inset - 12, "LEFT", "muted")
        tile.tag:SetText(scheme.cvdSafe and "CVD safe" or (scheme.light and "light" or "dark"))


        tile.mark = tile:CreateTexture(nil, "OVERLAY")
        tile.mark:SetPoint("TOPLEFT", tile, "TOPLEFT", 0, 0)
        tile.mark:SetSize(tileW, 2)
        A:Tint(tile.mark, "accent", "color", 1)
        tiles[#tiles + 1] = tile
    end



    local customTile = tiles[#tiles]
    local inputs = {}
    local swW, swH = 60, 24
    local slotX = 0
    local slotY = top - rows * pitch
    for i, key in ipairs(ctx.noInputs and {} or { "themeCustomInk", "themeCustomAccent" }) do
        local swOption = A.optionIndex[key]
        if swOption then
            local sx = slotX + (i - 1) * (swW + 8)
            local b = uiButton(parent, "", sx, slotY, swW, swH, function() pickColour(swOption) end)
            b.label:SetText("")
            b.inputColor = b:CreateTexture(nil, "ARTWORK")
            b.inputColor:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
            b.inputColor:SetSize(swW - 6, swH - 6)
            b.optionKey = key
            inputs[#inputs + 1] = b
        end
    end
    local caption
    if not ctx.noInputs then
        caption = text(parent, A.tokens.type.body, false, 2 * (swW + 8) + 4, slotY - 5, width - 2 * (swW + 8) - 8, "LEFT", "muted")
    end
    local used = math.ceil((rows * pitch + (ctx.noInputs and 0 or swH + 6)) / ROW_H)
    return function()
        local current = A:GetOption(option.key)


        local custom = A:CustomScheme() or A.customScheme
        if custom and customTile and customTile.schemeId == "custom" then
            local inset = 2
            local thumbW = math.floor(tileW * 0.42)
            A:SchemeThumb(customTile, customTile.thumb, "t", custom, inset, -inset, thumbW, tileH - 2 * inset,
                false, "ARTWORK", 1)
        end
        for _, tile in ipairs(tiles) do tile.mark:SetShown(tile.schemeId == current) end
        for _, b in ipairs(inputs) do
            local c = A:GetOption(b.optionKey)
            b.inputColor:SetColorTexture(c[1], c[2], c[3], 1)
        end
        if caption then
            local failures = A.customSchemeFailures
            if current == "custom" then
                caption:SetText("Custom: body and accent. Everything else is derived.")
            elseif failures and #failures > 0 then
                caption:SetText("Custom fails: " .. failures[1])
            else
                caption:SetText("Custom: pick a body and an accent, then choose the tile.")
            end
        end
    end, used
end









































local COLOR_CHANNELS = { { "r", "Red", 1 }, { "g", "Green", 2 }, { "b", "Blue", 3 }, { "a", "Opacity", 4 } }

local function buildColorPicker()
    if A.colorPicker then return A.colorPicker end
    local win = CreateFrame("Frame", "AdaptiveUIColorPicker", UIParent)
    win:SetSize(300, 268)
    win:SetFrameStrata("FULLSCREEN_DIALOG")


    if type(win.SetToplevel) == "function" then pcall(win.SetToplevel, win, true) end
    if type(win.SetFrameLevel) == "function" then pcall(win.SetFrameLevel, win, 200) end
    win:EnableMouse(true)
    A:Panel(win, 0, 0, 300, 268, "raised", "ink")
    A:MakeMovableWindow(win, "ColorPicker", 34)
    win.title = text(win, A.tokens.type.title, true, 12, -10, 200)


    local well = win:CreateTexture(nil, "ARTWORK")
    well:SetPoint("TOPLEFT", win, "TOPLEFT", 12, -38)
    well:SetSize(276, 40)
    A:Tint(well, "well", "color")
    win.sample = win:CreateTexture(nil, "OVERLAY")
    win.sample:SetPoint("TOPLEFT", win, "TOPLEFT", 14, -40)
    win.sample:SetSize(272, 36)
    win.rows = {}
    for index, channel in ipairs(COLOR_CHANNELS) do
        local row = { key = channel[1], slot = channel[3] }
        local ry = -86 - (index - 1) * 30
        row.label = text(win, A.tokens.type.body, false, 12, ry + 4, 70)
        row.label:SetText(channel[2])
        row.value = text(win, A.tokens.type.body, true, 86, ry + 4, 48, "CENTER")
        local function nudge(direction)
            local current = A.colorPicker.working
            if not current then return end
            local slot = row.slot
            local next_ = math.max(0, math.min(1, (current[slot] or 1) + direction * 0.05))
            current[slot] = math.floor(next_ * 100 + 0.5) / 100
            A:ApplyColorPicker()
        end
        row.minus = uiButton(win, "-", 140, ry, 44, 24, function() nudge(-1) end)
        row.plus = uiButton(win, "+", 244, ry, 44, 24, function() nudge(1) end)



        row.track = win:CreateTexture(nil, "ARTWORK")
        row.track:SetPoint("TOPLEFT", win, "TOPLEFT", 188, ry - 9)
        row.track:SetSize(52, 6)
        A:Tint(row.track, "well", "color")
        row.level = win:CreateTexture(nil, "OVERLAY")
        row.level:SetPoint("TOPLEFT", win, "TOPLEFT", 188, ry - 9)
        row.level:SetHeight(6)
        A:Tint(row.level, "text", "color", 0.8)
        win.rows[index] = row
    end


    win.swatches = {}
    for i, p in ipairs(PALETTE) do
        local b = uiButton(win, "", 12 + (i - 1) * 46, -206, 42, 22, function()
            local working = A.colorPicker.working
            working[1], working[2], working[3] = p[1], p[2], p[3]
            A:ApplyColorPicker()
        end)
        b.swatch = b:CreateTexture(nil, "OVERLAY")
        b.swatch:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
        b.swatch:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
        b.swatch:SetColorTexture(p[1], p[2], p[3], 1)
        win.swatches[i] = b
    end
    uiButton(win, "Use this colour", 12, -234, 160, 24, function() A:CloseColorPicker(true) end)
    uiButton(win, "Cancel", 178, -234, 110, 24, function() A:CloseColorPicker(false) end)
    win:Hide()
    A.colorPicker = win


    if type(A.AttachSettingsNavigation) == "function" then
        pcall(A.AttachSettingsNavigation, A, win)
    end
    return win
end



function A:ApplyColorPicker()
    local win = self.colorPicker
    local working = win and win.working
    if not working then return end
    win.sample:SetColorTexture(working[1], working[2], working[3], 1)
    for _, row in ipairs(win.rows) do
        local value = working[row.slot]
        local shown = row.slot == 4 and win.hasOpacity
        row.label:SetShown(shown or row.slot < 4)
        row.value:SetShown(shown or row.slot < 4)
        row.minus:SetShown(shown or row.slot < 4)
        row.plus:SetShown(shown or row.slot < 4)
        row.track:SetShown(shown or row.slot < 4)
        row.level:SetShown(shown or row.slot < 4)
        row.value:SetText(string.format("%d%%", math.floor((value or 1) * 100 + 0.5)))
        row.level:SetWidth(math.max(1, 52 * math.max(0, math.min(1, value or 1))))
    end
    self:SetOption(win.optionKey, { working[1], working[2], working[3], working[4] }, true)
    if win.optionKey == "accent" then self:SetOption("accentCustom", true, true) end
    self:QueueOptionsApplied()
end

function A:CloseColorPicker(keep)
    local win = self.colorPicker
    if not win then return end
    if not keep and win.original then
        self:SetOption(win.optionKey, win.original, true)
        self:QueueOptionsApplied()
    end
    win.working, win.original, win.optionKey = nil, nil, nil
    win:Hide()
    self:RefreshOptionsUI()
end




function A:OwnColorPickerOnly()
    local picker = _G.ColorPickerFrame
    if not picker or type(picker.SetupColorPickerAndShow) ~= "function" then return true end
    if not self:CanWrite("picker") then return true end
    return self:EffectiveInput() == "controller"
end

function A:OpenColorPicker(optionKey, hasOpacity, title)
    local win = buildColorPicker()
    local c = self:GetOption(optionKey)
    win.optionKey = optionKey
    win.hasOpacity = hasOpacity == true
    win.original = { c[1], c[2], c[3], c[4] }
    win.working = { c[1], c[2], c[3], c[4] }
    win.title:SetText(title or "Colour")
    self:PlaceWindow(win, "ColorPicker")
    win:Show()
    self:ApplyColorPicker()
    return win
end


local function buildProfiles(frame, parent)
    local ui = { rows = {} }
    ui.title = text(parent, A.tokens.type.title, true, 8, -4, 420)
    ui.status = text(parent, A.tokens.type.body, false, 8, -404, 430)
    local function say(message) ui.status:SetText(message or "") end
    ui.selected = nil
    for i = 1, 6 do
        ui.rows[i] = uiButton(parent, "", 0, -34 - (i - 1) * 30, 430, 26, function(b)
            ui.selected = b.profileName
            A:RefreshOptionsUI()
        end)
    end
    ui.name = editBox(parent, 0, -222, 260, 24)
    ui.nameHint = text(parent, A.tokens.type.body, false, 268, -227, 170, "LEFT", "muted")
    ui.nameHint:SetText("Profile name")
    local function report(ok, err)
        say(ok and "Done." or ("Not done: " .. tostring(err)))
        ui.selected = nil
        A:RefreshOptionsUI()
    end
    uiButton(parent, "Use selected", 0, -254, 140, 26, function()
        report(A:UseProfile(ui.selected or A.profileName))
    end)
    uiButton(parent, "Copy selected into active", 146, -254, 170, 26, function()
        if not ui.selected then say("Select a profile first."); return end
        report(A:CopyProfile(ui.selected))
    end)
    ui.delete = confirmButton(parent, "Delete selected", 322, -254, 108, 26,
        function() return "delete:" .. tostring(ui.selected) end, function()
            if not ui.selected then say("Select a profile first."); return end
            report(A:DeleteProfile(ui.selected))
        end)
    uiButton(parent, "New profile (from name)", 0, -284, 210, 26, function()
        report(A:CreateProfile(ui.name:GetText()))
    end)
    uiButton(parent, "Rename selected to name", 216, -284, 214, 26, function()
        report(A:RenameProfile(ui.selected or A.profileName, ui.name:GetText()))
    end)
    ui.reset = confirmButton(parent, "Reset active profile to defaults", 0, -314, 430, 26,
        function() return "reset:" .. tostring(A.profileName) end, function() report(A:ResetProfile()) end)
    ui.io = editBox(parent, 0, -348, 430, 4096)

    ui.ioHint = text(parent, A.tokens.type.body, false, 440, -353, 300, "LEFT", "muted")
    ui.ioHint:SetText("Share: Export fills this box to copy")
    uiButton(parent, "Export active", 0, -378, 140, 22, function()
        ui.io:SetText(A:ExportProfile())
        say("Exported: copy the string above.")
    end)
    uiButton(parent, "Import (new profile = name)", 146, -378, 284, 22, function()
        local name = ui.name:GetText()
        local ok, err = A:ImportProfile(ui.io:GetText(), name ~= "" and name or nil)
        if ok then say(name ~= "" and "Imported into new profile." or "Imported into the active profile.")
        else say("Not imported: " .. tostring(err)) end
        A:RefreshOptionsUI()
    end)

    ui.specs = {}

    local specCount = 4
    if type(GetNumSpecializations) == "function" then
        local ok, n = pcall(GetNumSpecializations)
        if ok and type(n) == "number" and n >= 1 and n <= 4 then specCount = n end
    end
    ui.specHint = text(parent, A.tokens.type.body, false, 440, -431, 300, "LEFT", "muted")
    ui.specHint:SetText("One profile per specialization")
    for i = 1, specCount do
        ui.specs[i] = uiButton(parent, "", (i - 1) * 144, -428, 140, 24, function()
            if not A:CurrentSpec() then say("Spec profiles unavailable: no public specialization query on this client."); return end
            local names, current = { false }, A:SpecMap()[i]
            for _, n in ipairs(A:ListProfiles()) do names[#names + 1] = n end
            local index = 1
            for k, n in ipairs(names) do if n == current then index = k end end
            local nextName = names[index % #names + 1]
            local ok, err = A:SetSpecProfile(i, nextName or nil)
            say(ok and "Saved." or ("Not saved: " .. tostring(err)))
            A:RefreshOptionsUI()
        end)
    end
    ui.refresh = function()
        ui.title:SetText("Active profile: " .. tostring(A.profileName))
        local names = A:ListProfiles()
        for i, row in ipairs(ui.rows) do
            local name = names[i]
            row.profileName = name
            row:SetShown(name ~= nil)
            if name then
                local mark = (name == A.profileName and "   (active)" or "") .. (name == ui.selected and "   (selected)" or "")
                row.label:SetText(name .. mark)
            end
        end
        local map = A:SpecMap()
        for i, b in ipairs(ui.specs) do b.label:SetText("Spec " .. i .. ": " .. tostring(map[i] or "-")) end
    end
    return ui
end



A.optionsKit = { text = text, fill = fill, uiButton = uiButton, confirmButton = confirmButton, editBox = editBox,
    builders = builders, buildProfiles = buildProfiles, pickColour = pickColour, ROW_H = ROW_H, formatNumber = formatNumber,
    roundTo = roundTo }

function A:CreateOptions()
    if self.options_ui then return self.options_ui end
    return self:CreateOptionsSections()
end

function A:RefreshOptionsUI()
    if self.options_ui then return self:RefreshOptionsSections() end
end



function A:ToggleOptions()
    if self.options_ui and self.options_ui.frame:IsShown() then
        self.options_ui.frame:Hide()
        return
    end
    self:OpenOptions()
end

function A:OpenOptions(tab)
    if self:IsCombat() then self:Print("Open options after combat. Slash changes can be queued."); return end
    self:CreateOptions()
    return self:OpenOptionsSections(tab)
end


function A:ProfileCommand(action, argument, second)
    action = action or ""
    if action == "list" or action == "" then
        self:Print("Profiles: " .. table.concat(self:ListProfiles(), ", ") .. " (active: " .. tostring(self.profileName) .. ")")
        return
    end
    local ok, err
    if action == "use" then ok, err = self:UseProfile(argument)
    elseif action == "new" then ok, err = self:CreateProfile(argument)
    elseif action == "rename" then ok, err = self:RenameProfile(argument, second)
    elseif action == "copy" then ok, err = self:CopyProfile(argument)
    elseif action == "delete" then
        if not self:Confirmed("delete:" .. argument, 10) then
            self:Print("Repeat the same command within 10 seconds to delete profile \"" .. argument .. "\".")
            return
        end
        ok, err = self:DeleteProfile(argument)
    elseif action == "reset" then
        if not self:Confirmed("reset:" .. tostring(self.profileName), 10) then
            self:Print("Repeat the same command within 10 seconds to reset the active profile to defaults.")
            return
        end
        ok, err = self:ResetProfile()
    elseif action == "resettab" then
        if not self:Confirmed("tab:" .. argument, 10) then
            self:Print("Repeat the same command within 10 seconds to reset that tab to defaults.")
            return
        end
        ok, err = self:ResetTab(argument)
    elseif action == "spec" then
        local spec = tonumber(argument)
        ok, err = self:SetSpecProfile(spec, (second ~= "" and second ~= "none") and second or nil)
    elseif action == "export" then self:Print("AdaptiveUI profile: " .. self:ExportProfile()); return
    elseif action == "import" then ok, err = self:ImportProfile(argument, nil)
    else self:Print("/aui profile list | use NAME | new NAME | rename OLD NEW | copy NAME | delete NAME | reset | resettab TAB | spec N NAME|none | export | import STRING"); return end
    self:Print(ok and ("profile " .. action .. ": done") or ("profile " .. action .. ": " .. tostring(err)))
end
