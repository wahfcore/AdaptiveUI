local _, A = ...



























local WIDTH, HEIGHT = 680, 672
local TAB_W, ROW_H, TAB_H = 150, 34, 30
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

function builders.bool(A_, parent, option, y)
    local b = uiButton(parent, "", 0, y, 430, ROW_H - 6, function()
        A:SetOption(option.key, not A:GetOption(option.key))
    end)
    local box = CreateFrame("Frame", nil, b)
    box:SetPoint("TOPRIGHT", b, "TOPRIGHT", -8, -6)
    box:SetSize(14, 14)





    box.well = fill(box, "BACKGROUND", "ink", 1)
    box.mark = box:CreateTexture(nil, "OVERLAY")
    box.mark:SetPoint("TOPLEFT", box, "TOPLEFT", 3, -3)
    box.mark:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -3, 3)
    A:Tint(box.mark, "text", "color")
    return function()
        b.label:SetText(option.label)
        box.mark:SetShown(A:GetOption(option.key) == true)
    end
end

function builders.number(A_, parent, option, y)
    local label = text(parent, A.tokens.type.body, false, 8, y - 8, 250)
    local value = text(parent, A.tokens.type.body, true, 320, y - 8, 70, "CENTER")
    local function nudge(direction)
        local current = A:GetOption(option.key)
        A:SetOption(option.key, roundTo(current + direction * (option.step or 1), option.step))
    end
    uiButton(parent, "-", 270, y, 44, ROW_H - 6, function() nudge(-1) end)
    uiButton(parent, "+", 396, y, 44, ROW_H - 6, function() nudge(1) end)
    return function()
        label:SetText(option.label)
        value:SetText(formatNumber(option, A:GetOption(option.key)))
    end
end

function builders.enum(A_, parent, option, y)
    local b
    b = uiButton(parent, "", 0, y, 430, ROW_H - 6, function()
        local current = A:GetOption(option.key)
        for i, entry in ipairs(option.values) do
            if entry.value == current then
                A:SetOption(option.key, option.values[i % #option.values + 1].value)
                return
            end
        end
    end)
    return function()
        local current = A:GetOption(option.key)
        local shown = current
        for _, entry in ipairs(option.values) do if entry.value == current then shown = entry.label end end
        b.label:SetText(option.label .. ":  " .. tostring(shown))
    end
end




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


    local cols = ctx.full and 4 or #schemes
    local gap = ctx.full and 4 or 2
    local tileW = math.floor((width - (cols - 1) * gap) / cols)
    local tileH = ctx.full and 46 or 24
    local pitch = ctx.full and (tileH + 6) or ROW_H
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
        local thumbW, thumbH = tileW - 2 * inset, tileH - 2 * inset
        if ctx.full then
            thumbW = math.floor(tileW * 0.42)
        end
        tile.thumb = {}
        A:SchemeThumb(tile, tile.thumb, "t", scheme, inset, -inset, thumbW, thumbH, not ctx.full, "ARTWORK", 1)
        if ctx.full then
            tile.label:ClearAllPoints()
            tile.label:SetPoint("TOPLEFT", tile, "TOPLEFT", inset + thumbW + 8, -7)
            tile.label:SetWidth(tileW - thumbW - inset - 12)
            tile.label:SetText(A.schemeShort[id] or scheme.name)
            tile.tag = text(tile, A.tokens.type.body, false, inset + thumbW + 8, -25, tileW - thumbW - inset - 12, "LEFT", "muted")
            tile.tag:SetText(scheme.cvdSafe and "CVD safe" or (scheme.light and "light" or "dark"))
        else
            tile.label:SetText("")
        end


        tile.mark = tile:CreateTexture(nil, "OVERLAY")
        tile.mark:SetPoint("TOPLEFT", tile, "TOPLEFT", 0, 0)
        tile.mark:SetSize(tileW, 2)
        A:Tint(tile.mark, "accent", "color", 1)
        tiles[#tiles + 1] = tile
    end




    local customTile = tiles[#tiles]
    local inputs = {}
    local swW = ctx.full and 60 or 26
    local swH = ctx.full and 24 or (ROW_H - 6)
    local slotX = ctx.full and 0 or 374
    local slotY = top - rows * pitch
    for i, key in ipairs(ctx.noInputs and {} or { "themeCustomInk", "themeCustomAccent" }) do
        local swOption = A.optionIndex[key]
        if swOption then
            local sx = slotX + (i - 1) * (swW + (ctx.full and 8 or 4))
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
    if ctx.full and not ctx.noInputs then
        caption = text(parent, A.tokens.type.body, false, 2 * (swW + 8) + 4, slotY - 5, width - 2 * (swW + 8) - 8, "LEFT", "muted")
    end


    local label, name, used
    if not ctx.full then
        local ny = top - rows * ROW_H
        label = text(parent, A.tokens.type.body, false, 8, ny - 8, 100)
        name = text(parent, A.tokens.type.title, true, 150, ny - 8, 170, "CENTER")
        local function step(direction)
            local list = option.values
            local index = 1
            for i, entry in ipairs(list) do if entry.value == A:GetOption(option.key) then index = i end end
            for _ = 1, #list do
                index = (index - 1 + direction) % #list + 1
                if A:SetOption(option.key, list[index].value) then return end
            end
        end
        uiButton(parent, "<", 106, ny, 40, ROW_H - 6, function() step(-1) end)
        uiButton(parent, ">", 326, ny, 40, ROW_H - 6, function() step(1) end)
        used = rows + 1
    else
        used = math.ceil((rows * pitch + (ctx.noInputs and 0 or swH + 6)) / ROW_H)
    end
    return function()
        local current = A:GetOption(option.key)
        if label then label:SetText(option.label) end
        if name then name:SetText(A:Scheme().name) end


        local custom = A:CustomScheme() or A.customScheme
        if custom and customTile and customTile.schemeId == "custom" then
            local inset = 2
            local thumbW = ctx.full and math.floor(tileW * 0.42) or (tileW - 2 * inset)
            A:SchemeThumb(customTile, customTile.thumb, "t", custom, inset, -inset, thumbW, tileH - 2 * inset,
                not ctx.full, "ARTWORK", 1)
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

function builders.color(A_, parent, option, y)
    local label = text(parent, A.tokens.type.body, false, 8, y - 8, 300)
    local swatch = uiButton(parent, "", 340, y, 100, ROW_H - 6, function() pickColour(option) end)
    swatch.color = swatch:CreateTexture(nil, "ARTWORK")
    swatch.color:SetPoint("TOPLEFT", swatch, "TOPLEFT", 4, -4)
    swatch.color:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -4, 4)
    return function()
        label:SetText(option.label)
        local c = A:GetOption(option.key)
        swatch.color:SetColorTexture(c[1], c[2], c[3], 1)
    end
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







local MOVER_WINDOW = 7
local function buildMovers(frame, panel, firstRow)
    local rows = {}
    local y0 = -firstRow * ROW_H
    local view = { offset = 0 }
    local lock = uiButton(panel, "", 0, y0, 430, ROW_H - 6, function()
        A:ToggleMovers()
        A:RefreshOptionsUI()
    end)
    local hint = text(panel, A.tokens.type.caption, false, 8, y0 - ROW_H - 2, 430)
    hint:SetText("Nudge with the buttons (works with a controller). Dragging needs Unlock and is off in combat.")
    local listTop = y0 - ROW_H - 24
    local up = uiButton(panel, "^  Earlier", 0, listTop, 210, 22, function()
        view.offset = math.max(0, view.offset - 1); view.relayout()
    end)
    local down = uiButton(panel, "v  More", 220, listTop, 210, 22, function()
        view.offset = math.min(math.max(0, #rows - MOVER_WINDOW), view.offset + 1); view.relayout()
    end)
    local rowsTop = listTop - 26
    for _, entry in ipairs(A.moverList) do
        local row = { entry = entry, parts = {} }
        row.label = text(panel, A.tokens.type.body, false, 8, 0, 150)
        row.parts[#row.parts + 1] = { widget = row.label, x = 8, dy = -8 }
        local x = 150
        for _, spec in ipairs({ { "<", -1, 0 }, { ">", 1, 0 }, { "^", 0, 1 }, { "v", 0, -1 } }) do
            local b = uiButton(panel, spec[1], x, 0, 36, ROW_H - 6, function() A:NudgeMover(entry.id, spec[2], spec[3]) end)
            row.parts[#row.parts + 1] = { widget = b, x = x, dy = 0 }
            x = x + 40
        end
        row.reset = uiButton(panel, "Reset", x + 4, 0, 100, ROW_H - 6, function() A:ResetMover(entry.id) end)
        row.parts[#row.parts + 1] = { widget = row.reset, x = x + 4, dy = 0 }
        rows[#rows + 1] = row
    end
    view.relayout = function()
        for i, row in ipairs(rows) do
            local slot = i - view.offset
            local visible = slot >= 1 and slot <= MOVER_WINDOW
            for _, part in ipairs(row.parts) do
                part.widget:ClearAllPoints()
                part.widget:SetPoint("TOPLEFT", panel, "TOPLEFT", part.x, rowsTop - (slot - 1) * ROW_H + part.dy)
                part.widget:SetShown(visible)
            end
        end
        up:SetShown(view.offset > 0)
        down:SetShown(view.offset < #rows - MOVER_WINDOW)
    end
    panel:EnableMouseWheel(true)
    panel:SetScript("OnMouseWheel", function(_, delta)
        view.offset = math.max(0, math.min(math.max(0, #rows - MOVER_WINDOW), view.offset - (delta > 0 and 1 or -1)))
        view.relayout()
    end)
    view.relayout()
    A.moversView = view
    return function()
        lock.label:SetText(A.moversUnlocked and "Dragging: unlocked (click to lock)" or "Dragging: locked (click to unlock)")
        for _, row in ipairs(rows) do
            local x, yy = A:MoverOffset(row.entry.id)
            local available = row.entry.frame(A) ~= nil
            local docked = row.entry.info and A:InfoDocked(row.entry.info)
            local anchored = row.entry.anchored and row.entry.anchored(A)
            row.label:SetText(string.format("%s  (%d, %d)%s", row.entry.label, x, yy,
                anchored and (row.entry.anchoredNote or "  on the health bar")
                or (docked and "  docked" or (available and "" or "  n/a"))))
        end
    end
end












local function buildCompassPicker(panel, firstRow)
    local y0 = -firstRow * ROW_H
    local picked = "bottomL"
    local picker = { buttons = {}, byId = {} }
    local BW, BH = 48, ROW_H - 8
    local pairs_ = {
        { "topL", "topR", 430 / 2 - BW - 2, y0 },
        { "leftL", "leftR", 0, y0 - ROW_H },
        { "rightL", "rightR", 430 - 2 * BW - 4, y0 - ROW_H },
        { "bottomL", "bottomR", 430 / 2 - BW - 2, y0 - 2 * ROW_H },
    }
    local function refreshPicked()
        for id, b in pairs(picker.byId) do b.bg:SetAlpha(id == picked and 1 or 0.55) end
    end
    for _, row in ipairs(pairs_) do
        for i = 1, 2 do
            local id = row[i]
            local b = uiButton(panel, i == 1 and "Pad" or "Face", row[3] + (i - 1) * (BW + 4), row[4], BW, BH,
                function() picked = id; A:RefreshOptionsUI() end)
            picker.buttons[#picker.buttons + 1] = b
            picker.byId[id] = b
        end
    end
    local key = function() return "compassGroupSize." .. picked end
    local mx = 2 * BW + 4 + 10
    local value = text(panel, A.tokens.type.body, true, mx + 38, y0 - ROW_H - 8, 56, "CENTER")
    local function nudge(direction)
        local option = A.optionIndex[key()]
        A:SetOption(key(), roundTo(A:GetOption(key()) + direction * option.step, option.step))
    end
    uiButton(panel, "-", mx, y0 - ROW_H, 34, BH, function() nudge(-1) end)
    uiButton(panel, "+", mx + 98, y0 - ROW_H, 34, BH, function() nudge(1) end)
    local function same()
        local size = A:GetOption(key())
        for _, id in ipairs(A.compassGroupOrder) do A:SetOption("compassGroupSize." .. id, size, true) end
        A:OptionsApplied()
    end
    uiButton(panel, "All same", mx + 140, y0 - ROW_H, (430 - 2 * BW - 4) - (mx + 140) - 6, BH, same)

    local which = text(panel, A.tokens.type.caption, false, 8, y0 - 3 * ROW_H - 4, 480, "LEFT")
    local hint = text(panel, A.tokens.type.caption, false, 8, y0 - 3 * ROW_H - 20, 480, "LEFT", "muted")
    hint:SetText("A row is not offered: Blizzard re-anchors every compass button on every press of it.")
    picker.pick = function(id) picked = id; refreshPicked() end
    picker.nudge = nudge
    picker.same = same
    picker.refresh = function()
        refreshPicked()
        local option = A.optionIndex[key()]
        value:SetText(formatNumber(option, A:GetOption(key())))
        which:SetText("Sizing: " .. (A.compassGroupLabels[picked] or picked) .. ".  Pad = the d-pad group, Face = the face buttons.")
    end
    return picker
end



A.optionsKit = { text = text, fill = fill, uiButton = uiButton, confirmButton = confirmButton, editBox = editBox,
    builders = builders, buildProfiles = buildProfiles, pickColour = pickColour, ROW_H = ROW_H, formatNumber = formatNumber,
    roundTo = roundTo }



function A:OptionsLayout()
    local value = self.db and self.optionIndex and self:GetOption("optionsLayout") or "sections"
    if value == "sections" and type(self.CreateOptionsSections) ~= "function" then return "tabs" end
    return value
end

function A:CreateOptions()
    if self.options_ui then return self.options_ui end
    if self:OptionsLayout() == "sections" then return self:CreateOptionsSections() end
    local frame = CreateFrame("Frame", "AdaptiveUIOptions", UIParent)
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "d", frame, 0, 0, frame, 0, 0, "raised")

    frame.bg = fill(frame, "BACKGROUND", "ink", 0.97, -7)
    frame.rule = frame:CreateTexture(nil, "OVERLAY")
    self:Tint(frame.rule, "accent", "color", 1)
    frame.rule:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.rule:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.rule:SetHeight(2)



    frame.mast = {}
    local lead = 0
    if self:ChromeCrest("windows") then
        local size = self:CrestSeatSize(frame)
        self:CrestSeat(frame, frame.mast, "m", frame, 16, -(68 - size) / 2, "ARTWORK", 1)
        lead = size + self.tokens.space.md
    end
    local title = text(frame, self.tokens.type.hero, true, 16 + lead, -14, 400)
    title:SetText("Adaptive UI : A Wahf Production")


    local signature = frame:CreateTexture(nil, "ARTWORK")
    signature:SetPoint("TOPLEFT", frame, "TOPLEFT", 16 + lead, -40)
    signature:SetSize(236, 2)
    self:Tint(signature, "accent", "color")
    local measured = select(2, pcall(title.GetStringWidth, title))
    if type(measured) == "number" and measured > 40 then signature:SetWidth(math.min(400, measured)) end
    text(frame, self.tokens.type.caption, false, 16 + lead, -50, 600 - lead):SetText(
        "Changes save to the active profile and apply out of combat. Drag the title bar to move this window.")
    local ui = { frame = frame, tabs = {}, panels = {}, refreshers = {}, layout = "tabs" }
    self.options_ui = ui
    self:MakeMovableWindow(frame, "Options", 68)
    for index, group in ipairs(self.optionGroups) do
        local tab = uiButton(frame, group.label, 12, -72 - (index - 1) * TAB_H, TAB_W - 12, TAB_H - 4, function()
            A:OpenOptions(group.key)
        end)
        tab.groupKey = group.key
        ui.tabs[group.key] = tab
        local panel = CreateFrame("Frame", nil, frame)
        panel:SetPoint("TOPLEFT", frame, "TOPLEFT", TAB_W + 16, -76)
        panel:SetSize(WIDTH - TAB_W - 32, HEIGHT - 108)
        panel:Hide()
        ui.panels[group.key] = panel
        if group.key == "profiles" then
            ui.profiles = buildProfiles(frame, panel)
        else
            local row = 0
            for _, option in ipairs(self.options) do


                local builder = option.group == group.key and not option.inline and builders[option.widget or option.type]
                if builder then
                    local refresh, used = builder(self, panel, option, -row * ROW_H)
                    ui.refreshers[#ui.refreshers + 1] = refresh
                    row = row + (used or 1)
                end
            end
            if group.key == "theme" then
                uiButton(panel, "Use the scheme's accent color", 0, -row * ROW_H, 430, ROW_H - 6, function()
                    A:SetOption("accentCustom", false)
                end)
            end
            if group.key == "general" then
                uiButton(panel, "Run the welcome setup again", 0, -row * ROW_H, 430, ROW_H - 6, function()
                    A:OpenWelcome()
                end)
            end
            if group.key == "movers" then
                ui.refreshers[#ui.refreshers + 1] = buildMovers(frame, panel, row)
            end
            if group.key == "compass" then
                ui.compassPicker = buildCompassPicker(panel, row)
                ui.refreshers[#ui.refreshers + 1] = ui.compassPicker.refresh
            end
        end
    end
    uiButton(frame, "Close", WIDTH - 112, -(HEIGHT - 42), 96, 28, function() frame:Hide() end)
    ui.resetTab = confirmButton(frame, "Reset this tab to defaults", TAB_W + 16, -(HEIGHT - 42), 250, 28,
        function() return "tab:" .. tostring(ui.current) end, function()
            local ok, count = A:ResetTab(ui.current)
            A:Print(ok and ("Reset " .. count .. " options on this tab.") or ("Reset failed: " .. tostring(count)))
            A:RefreshOptionsUI()
        end)

    self:AttachSettingsNavigation(frame, function()
        A:SetMoverPreview(false)
        A:LockMovers()
    end)

    self:SetGamepadShoulder(frame, function(direction)
        local index = 1
        for i, group in ipairs(A.optionGroups) do if group.key == ui.current then index = i end end
        local target = A.optionGroups[(index - 1 + direction) % #A.optionGroups + 1]
        A:OpenOptions(target.key)
    end)
    frame:Hide()
    return ui
end

function A:RefreshOptionsUI()
    local ui = self.options_ui
    if not ui then return end
    if ui.layout == "sections" then return self:RefreshOptionsSections() end
    for _, refresh in ipairs(ui.refreshers) do refresh() end
    if ui.profiles then ui.profiles.refresh() end
    for key, panel in pairs(ui.panels) do panel:SetShown(key == ui.current) end
    if ui.current ~= "movers" and self.moversUnlocked then self:LockMovers() end
    self:SetMoverPreview(ui.frame:IsShown() and ui.current == "movers")
    for key, tab in pairs(ui.tabs) do
        tab.bg:SetAlpha(key == ui.current and 1 or 0.55)
    end
    if ui.resetTab then ui.resetTab:SetShown(ui.current ~= "profiles") end
    self:RefreshConfirmLabels()
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


    if self.options_ui and self.options_ui.layout ~= self:OptionsLayout() then
        self.options_ui.frame:Hide()
        self.options_ui = nil
    end
    local ui = self:CreateOptions()
    if ui.layout == "sections" then return self:OpenOptionsSections(tab) end
    ui.current = self.optionIndex and (ui.panels[tab or ui.current or "general"] and (tab or ui.current or "general")) or "general"
    if self.settings then self.settings:Hide() end
    if self.nativeSettings then self.nativeSettings:Hide() end
    if self.layoutSettings then self.layoutSettings:Hide() end
    self:RefreshOptionsUI()
    self:PlaceWindow(ui.frame, "Options")
    ui.frame:Show()
    self:SetMoverPreview(ui.current == "movers")
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
