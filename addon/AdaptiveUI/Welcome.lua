local _, A = ...






























local W, H, M = 520, 600, 24


local BANNER = 96

local SCHEME_PITCH, SCHEME_TILE = 44, 40
local CONTENT = W - 2 * M
local GUTTER = 8
local HALF = (CONTENT - GUTTER) / 2
local THIRD = (CONTENT - GUTTER * 2) / 3
local STEP_COUNT = 6



local BODY, TITLE = 14, 16


A.welcomeSchemes = { "dusk", "ember", "frost", "obsidian", "verdant", "porcelain" }

local function text(parent, size, heading, x, y, width, role, wrap, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    A:SetThemedFont(fs, size, heading)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetWidth(width)
    fs:SetJustifyH(justify or "LEFT")
    if type(fs.SetJustifyV) == "function" then fs:SetJustifyV("TOP") end
    fs:SetWordWrap(wrap and true or false)
    A:Tint(fs, role or "text", "text")
    return fs
end

local function fill(parent, layer, role, alpha, sublevel)
    local t = parent:CreateTexture(nil, layer, nil, sublevel)
    t:SetAllPoints()
    A:Tint(t, role, "color", alpha)
    return t
end




local function tile(parent, x, y, width, height, title, desc, onClick)
    local b = CreateFrame("Button", nil, parent)
    A:AddFocusable(b)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(width, height)
    b.bg = fill(b, "BACKGROUND", "control")
    b.bar = b:CreateTexture(nil, "OVERLAY")



    b.bar:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    b.bar:SetSize(3, height)
    A:Tint(b.bar, "accent", "color", 1)
    b.bar:Hide()
    b.dot = b:CreateTexture(nil, "OVERLAY")
    b.dot:SetSize(10, 10)
    b.dot:SetPoint("TOPLEFT", b, "TOPLEFT", width - 22, -12)
    A:Tint(b.dot, "muted", "color", 0.45)
    b.dotOn = b:CreateTexture(nil, "OVERLAY", nil, 1)
    b.dotOn:SetSize(10, 10)
    b.dotOn:SetPoint("TOPLEFT", b, "TOPLEFT", width - 22, -12)
    A:Tint(b.dotOn, "accent", "color", 1)
    b.dotOn:Hide()
    b.title = text(b, TITLE, true, 14, -8, width - 44, "text", false)
    b.title:SetText(title)
    if desc then
        b.desc = text(b, BODY, false, 14, -29, width - 26, "muted", true)
        b.desc:SetHeight(height - 32)
        b.desc:SetText(desc)
    end
    b:SetScript("OnEnter", function() A:HoverTint(b.bg, true) end)
    b:SetScript("OnLeave", function() A:HoverTint(b.bg, false) end)
    b:SetScript("OnClick", function()
        if A:IsCombat() then A:Print("Settings controls are unavailable in combat."); return end
        onClick(b)
    end)
    function b:SetChosen(chosen)
        self.chosen = chosen and true or false
        self.bar:SetShown(self.chosen)
        self.dotOn:SetShown(self.chosen)
    end
    return b
end




local function swatch(tileFrame, scheme, width)
    tileFrame.thumb = {}
    A:SchemeThumb(tileFrame, tileFrame.thumb, "t", scheme, 7, -7, 28, SCHEME_TILE - 14, true, "ARTWORK", 1)
    tileFrame.title:ClearAllPoints()
    tileFrame.title:SetPoint("TOPLEFT", tileFrame, "TOPLEFT", 42, -12)
    tileFrame.title:SetWidth(width - 50)
    A:SetThemedFont(tileFrame.title, BODY, true)
    tileFrame.title:SetText(A.schemeShort[scheme.id] or scheme.name)
    for _, dot in ipairs({ tileFrame.dot, tileFrame.dotOn }) do
        dot:ClearAllPoints()
        dot:SetSize(6, 6)
        dot:SetPoint("TOPLEFT", tileFrame, "TOPLEFT", width - 10, -4)
    end
end

local function schemeName(id)
    for _, scheme in ipairs(A.schemes) do if scheme.id == id then return scheme.name end end
    return tostring(id)
end
local function schemeById(id)
    for _, scheme in ipairs(A.schemes) do if scheme.id == id then return scheme end end
end

local INPUT_LABEL = { auto = "Detect", controller = "Controller", keyboard = "Mouse and keyboard" }
local STYLE_LABEL = { rpg = "Full", minimal = "Minimal" }
local MOTION_LABEL = { full = "full", subtle = "reduced", off = "no" }
local SIZE_LABEL = { desktop = "Monitor", tv = "TV", handheld = "Handheld" }






function A:ApplyFirstRunDefaults()
    if not self.db or self.db.setupDone == true or self:GetOption("firstRunDefaults") == true then return false end
    self:SetOption("firstRunDefaults", true, true)
    if self.db.unitMode ~= "plus" and self.SetUnitMode then self:SetUnitMode("plus") end
    return true
end




function A:CreateWelcome()
    if self.welcome then return self.welcome end
    local frame = CreateFrame("Frame", "AdaptiveUIWelcome", UIParent)
    frame:SetSize(W, H)
    frame:SetPoint("CENTER")
    frame:SetClampedToScreen(true)
    self:TopWindow(frame)
    frame:EnableMouse(true)
    frame.background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    frame.background:SetAllPoints()
    self:Tint(frame.background, "ink", "color", 0.98)
    frame.depth = {}
    self:Elevate(frame.depth, frame, "panel~", frame, 0, 0, frame, 0, 0, "raised")


    frame.mast = {}
    self:Masthead(frame, W, BANNER, frame.mast, "m", M)
    self:Rule(frame, 0, 0, W, 2)

    local lead = frame.mast.mLead or 0
    local measure = CONTENT - lead
    local title = text(frame, self.tokens.type.hero, true, M + lead, -18, math.min(400, measure), "text", false)
    title:SetText("AdaptiveUI: A Wahf Production")
    local signature = self:Rule(frame, M + lead, -46, 236, 2)
    local measured = select(2, pcall(title.GetStringWidth, title))
    if type(measured) == "number" and measured > 40 then signature:SetWidth(math.min(400, measure, measured)) end
    text(frame, BODY, false, M + lead, -56, measure, "muted", false):SetText("A WoW dad's answer to off-night couch gaming.")

    local ui = { frame = frame, steps = {}, step = 1, primary = {}, tiles = {} }
    self.welcome = ui

    local function newStep(index, heading, sub)
        local step = CreateFrame("Frame", nil, frame)
        step:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -BANNER)
        step:SetSize(W, H - BANNER - 92)
        step:Hide()
        ui.steps[index] = step
        step.heading = text(step, self.tokens.type.title, true, M, -4, CONTENT, "text", false)
        step.heading:SetText(heading)
        if sub then
            step.sub = text(step, BODY, false, M, -26, CONTENT, "muted", false)
            step.sub:SetText(sub)
        end
        return step
    end

    local function section(step, y, label)
        local fs = text(step, BODY, false, M, y, CONTENT, "muted", false)
        fs:SetText(string.upper(label))
        return fs
    end



    local refreshers = {}
    local function group(step, defs, resolve)
        local created = {}
        for _, def in ipairs(defs) do
            local t = tile(step, def.x, def.y, def.w, def.h, def.title, def.desc, function()
                def.apply()
                ui.refresh()
            end)
            if def.scheme then swatch(t, def.scheme, def.w) end
            t.def = def
            created[#created + 1] = t
            ui.tiles[#ui.tiles + 1] = t
        end
        refreshers[#refreshers + 1] = function()
            local current = resolve()
            for _, t in ipairs(created) do t:SetChosen(t.def.value == current) end
        end
        return created
    end


    local s1 = newStep(1, "Welcome", "About a minute. Every choice applies as you make it.")
    local rule = s1:CreateTexture(nil, "ARTWORK")
    rule:SetPoint("TOPLEFT", s1, "TOPLEFT", M, -64)
    rule:SetSize(3, 56)
    self:Tint(rule, "accent", "color", 1)
    local promise = text(s1, TITLE, true, M + 16, -64, CONTENT - 16, "text", true)
    promise:SetHeight(60)
    promise:SetText("AdaptiveUI restyles the game's own interface. Your keybinds, macros and controls are never touched.")
    section(s1, -150, "Getting around")
    ui.howTo = {}
    for i, line in ipairs({
        "Controller: D-pad moves, A chooses, B goes back, X keeps the defaults.",
        "Mouse and keyboard: click. Esc closes.",
        "Everything here can be changed later in the options.",
    }) do
        ui.howTo[i] = text(s1, BODY, false, M, -172 - (i - 1) * 24, CONTENT, "text", false)
        ui.howTo[i]:SetText(line)
    end


    local s2 = newStep(2, "How do you play?", "Button pictures and bars for how you hold the game.")
    section(s2, -52, "Input")
    local inputTiles = group(s2, {
        { value = "controller", title = "Controller", desc = "Controller button pictures and the controller bars.",
          x = M, y = -70, w = CONTENT, h = 50, apply = function() A.db.mode = "controller"; A.layoutDirty = true; A:Changed() end },
        { value = "keyboard", title = "Mouse and keyboard", desc = "Key names on the keyboard bars.",
          x = M, y = -124, w = CONTENT, h = 50, apply = function() A.db.mode = "keyboard"; A.layoutDirty = true; A:Changed() end },
        { value = "auto", title = "Detect", desc = "Follows whichever you touched last.",
          x = M, y = -178, w = CONTENT, h = 50, apply = function() A.db.mode = "auto"; A.layoutDirty = true; A:Changed() end },
    }, function() return A.db.mode end)
    ui.autoTile = inputTiles[3]
    section(s2, -242, "Screen")
    group(s2, {
        { value = "desktop", title = "Monitor", desc = "At a desk.",
          x = M, y = -260, w = THIRD, h = 52, apply = function() A:SetDisplayPreset("desktop") end },
        { value = "tv", title = "TV", desc = "From the sofa.",
          x = M + THIRD + GUTTER, y = -260, w = THIRD, h = 52, apply = function() A:SetDisplayPreset("tv") end },
        { value = "handheld", title = "Handheld", desc = "A small screen.",
          x = M + 2 * (THIRD + GUTTER), y = -260, w = THIRD, h = 52, apply = function() A:SetDisplayPreset("handheld") end },
    }, function() return A:DisplayPreset() end)
    text(s2, BODY, false, M, -320, CONTENT, "muted", false):SetText("Sets text, action bars and unit frames together.")
    text(s2, BODY, false, M, -368, CONTENT, "muted", false):SetText(
        "With a controller, a box offers the controller bars when you pick it up.")
    ui.sample = text(s2, BODY, false, M, -344, CONTENT, "text", false)
    ui.sample:SetText("This is how big HUD text will be.")
    ui.primary[2] = inputTiles[1]


    local s3 = newStep(3, "Unit frames", "Your player, target and party frames.")
    local unitTiles = group(s3, {
        { value = "plus", title = "AdaptiveUI plates",
          desc = "The painted plates this addon is built around. Display only: if the game refuses anything, "
              .. "Blizzard's frames come back by themselves.",
          x = M, y = -52, w = CONTENT, h = 88, apply = function() A:SetUnitMode("plus") end },
        { value = "lite", title = "Blizzard's frames, restyled",
          desc = "The safest choice: the game's own frames, only restyled.",
          x = M, y = -148, w = CONTENT, h = 70, apply = function() A:SetUnitMode("lite") end },
    }, function() return A.db.unitMode end)
    ui.plusTile = unitTiles[1]
    ui.unitNote = text(s3, BODY, false, M, -232, CONTENT, "muted", true)
    ui.unitNote:SetHeight(40)
    ui.primary[3] = unitTiles[1]


    local s4 = newStep(4, "Your look", "The game behind this window shows each choice.")
    section(s4, -52, "Colour scheme")
    local schemeDefs = {}
    for i, id in ipairs(A.welcomeSchemes) do
        local scheme = schemeById(id)
        if scheme then
            local col, rowIndex = (i - 1) % 3, math.floor((i - 1) / 3)
            schemeDefs[#schemeDefs + 1] = { value = scheme.id, title = scheme.name, scheme = scheme,
                x = M + col * (THIRD + GUTTER), y = -70 - rowIndex * SCHEME_PITCH, w = THIRD, h = SCHEME_TILE,
                apply = function() A:SetOption("themeScheme", scheme.id) end }
        end
    end
    local schemeTiles = group(s4, schemeDefs, function() return A:GetOption("themeScheme") end)
    local afterSchemes = -70 - math.ceil(#schemeDefs / 3) * SCHEME_PITCH
    text(s4, BODY, false, M, afterSchemes - 2, CONTENT, "muted", false):SetText(
        "Ten more schemes, and your own colours, in Options > Look.")
    local styleTop = afterSchemes - 30
    section(s4, styleTop, "HUD style")
    group(s4, {
        { value = "rpg", title = "Full", desc = "Every panel.",
          x = M, y = styleTop - 18, w = HALF, h = 52, apply = function() A.db.style = "rpg"; A:Changed() end },
        { value = "minimal", title = "Minimal", desc = "Fewer panels, more world.",
          x = M + HALF + GUTTER, y = styleTop - 18, w = HALF, h = 52, apply = function() A.db.style = "minimal"; A:Changed() end },
    }, function() return A.db.style end)


    local motionTop = styleTop - 82
    section(s4, motionTop, "Movement")
    local motionDefs = {}
    for i, def in ipairs({
        { "full", "Full", "Light moves." },
        { "subtle", "Reduced", "Feedback only." },
        { "off", "None", "Nothing moves." },
    }) do
        motionDefs[i] = { value = def[1], title = def[2], desc = def[3],
            x = M + (i - 1) * (THIRD + GUTTER), y = motionTop - 18, w = THIRD, h = 52,
            apply = function() A:SetOption("motionLevel", def[1]) end }
    end
    group(s4, motionDefs, function() return A:MotionLevel() end)
    ui.primary[4] = schemeTiles[1]


    local s5 = newStep(5, "Extras", "Two optional extras, and how to move things.")
    local extras = {}
    local function toggleTile(y, height, key, tileTitle, desc)
        local t = tile(s5, M, y, CONTENT, height, tileTitle, desc, function()
            A:SetOption(key, not A:GetOption(key))
            ui.refresh()
        end)
        refreshers[#refreshers + 1] = function() t:SetChosen(A:GetOption(key) == true) end
        ui.tiles[#ui.tiles + 1] = t
        extras[#extras + 1] = t
        return t
    end
    toggleTile(-52, 70, "actionCamera", "Action camera",
        "Moves the game camera over your shoulder. Off by default; your own camera comes back when you turn it off.")
    toggleTile(-128, 52, "dpsStripOn", "Damage under your plate", "A small readout of your own damage.")
    section(s5, -196, "Moving things")
    ui.moveTile = tile(s5, M, -214, CONTENT, 70, "Try moving things",
        "Unlocks everything for 20 seconds: drag with the mouse. On a controller, use Options > Layout.", function()
            if A:UnlockMovers() then
                ui.moveUntil = true
                if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
                    C_Timer.After(20, function()
                        if ui.moveUntil then ui.moveUntil = nil; A:LockMovers(); ui.refresh() end
                    end)
                end
            end
            ui.refresh()
        end)
    refreshers[#refreshers + 1] = function() ui.moveTile:SetChosen(A.moversUnlocked == true) end
    ui.primary[5] = extras[1]
    ui.extras = extras


    local s6 = newStep(6, "You're set", "Here is what you chose.")
    ui.summaryLines = {}
    for i = 1, 4 do ui.summaryLines[i] = text(s6, BODY, false, M, -52 - (i - 1) * 22, CONTENT, "text", false) end


    ui.tipPaths = {
        { "Help & tools", "Report a problem" }, { "Layout", "Move things" }, { "Help & tools", "Reset" },
        { "Look", "Unit frames" }, { "Look" },
    }
    ui.tips = {}
    for i, tip in ipairs({
        { "Open the options", "Bind a key or a controller button: Key Bindings > AddOns > AdaptiveUI. "
            .. "Or Esc > Options > AddOns > AdaptiveUI, or type /aui." },
        { "Move things", "Options > Layout > Move things." },
        { "Undo", "Options > Help & tools > Reset." },
        { "Report a problem", "Options > Help & tools > Report a problem." },
    }) do
        local y = -148 - (i - 1) * 60
        local bar = s6:CreateTexture(nil, "ARTWORK")
        bar:SetPoint("TOPLEFT", s6, "TOPLEFT", M, y)
        bar:SetSize(3, 52)
        self:Tint(bar, "accent", "color", 1)
        text(s6, BODY, true, M + 12, y, CONTENT - 12, "text", false):SetText(tip[1])
        local body = text(s6, BODY, false, M + 12, y - 18, CONTENT - 12, "muted", true)
        body:SetHeight(36)
        body:SetText(tip[2])
        ui.tips[i] = body
    end


    ui.progress = text(frame, BODY, false, M, -(H - 88), CONTENT, "muted", false, "RIGHT")
    ui.back = self:SettingsButton(frame, "Back", M, -(H - 64), 110, function() ui.go(ui.step - 1) end)
    ui.skip = self:SettingsButton(frame, "Skip setup", M + 118, -(H - 64), 170, function() ui.complete(true) end)
    ui.next = self:SettingsButton(frame, "Next", W - M - 170, -(H - 64), 170, function()
        if ui.step >= STEP_COUNT then ui.complete(false) else ui.go(ui.step + 1) end
    end)

    function ui.refresh()
        for _, fn in ipairs(refreshers) do fn() end
        if ui.autoTile and ui.autoTile.desc then
            ui.autoTile.desc:SetText(A.observedInput == "controller"
                and "Follows whichever you touched last. A controller is connected now."
                or "Follows whichever you touched last.")
        end
        if ui.sample then
            A:SetThemedFont(ui.sample, math.max(BODY, A:PixelSize("body", A:LayoutMetrics().unitScale)), false)
        end
        if ui.plusTile and ui.unitNote then
            local usable = A.auditedSink and not A.plusFailed
            ui.unitNote:SetText(usable and "Change it any time: Options > Look > Unit frames."
                or "The plates are not available on this client build yet, so Blizzard's frames are used for now.")
        end
        local size = A:DisplayPreset()
        local lines = {
            "Input:  " .. (INPUT_LABEL[A.db.mode] or A.db.mode) .. "   |   Screen:  " .. (SIZE_LABEL[size] or "your own sizes"),
            "Unit frames:  " .. (A.db.unitMode == "plus" and "AdaptiveUI plates" or "Blizzard's, restyled"),
            "Look:  " .. schemeName(A:GetOption("themeScheme")) .. ", " .. (STYLE_LABEL[A.db.style] or A.db.style)
                .. ", " .. (MOTION_LABEL[A:MotionLevel()] or A:MotionLevel()) .. " movement",
            "Extras:  action camera " .. (A:GetOption("actionCamera") and "on" or "off")
                .. ", damage readout " .. (A:GetOption("dpsStripOn") and "on" or "off"),
        }
        for i, line in ipairs(lines) do ui.summaryLines[i]:SetText(line) end
    end

    function ui.summaryText()
        local out = {}
        for i, fs in ipairs(ui.summaryLines) do out[i] = fs:GetText() or "" end
        return table.concat(out, "\n")
    end

    function ui.go(index)
        index = math.max(1, math.min(STEP_COUNT, index))
        ui.step = index
        for i, step in ipairs(ui.steps) do step:SetShown(i == index) end
        ui.back:SetShown(index > 1)
        ui.skip:SetShown(index < STEP_COUNT)
        ui.skip:ClearAllPoints()
        ui.skip:SetPoint("TOPLEFT", frame, "TOPLEFT", index > 1 and (M + 118) or M, -(H - 64))
        ui.skip.title:SetText(index == 1 and "Use the defaults" or "Skip setup")
        ui.next.title:SetText(index == 1 and "Start setup" or (index == STEP_COUNT and "Finish" or "Next"))
        ui.progress:SetText(string.format("Screen %d of %d", index, STEP_COUNT))
        ui.refresh()

        if A:EffectiveInput() == "controller" then
            A:GamepadHighlight(frame, ui.primary[index] or ui.next)
        end
    end



    function ui.complete(skipped)
        ui.finishing = true
        ui.active = nil
        A:SetOption("setupDone", true, true)
        if ui.moveUntil then ui.moveUntil = nil; A:LockMovers() end
        frame:Hide()
        ui.finishing = nil
        if skipped then
            A:Print("Setup closed; your choices so far are kept. The options: /aui, or bind a key in Key Bindings > AddOns.")
        else
            A:Print("Setup complete. The options: /aui, Esc > Options > AddOns, or a key you bind in Key Bindings > AddOns.")
        end
    end

    self:MakeMovableWindow(frame, "Welcome", 76)
    self:AttachSettingsNavigation(frame, function()



        if not ui.active then return end
        ui.active = nil
        if ui.finishing then return end
        if A:IsCombat() then

            if A.db and A.db.setupDone ~= true then A.pendingWelcome, A.welcomeDelay = true, 2 end
            return
        end
        if A.db and A.db.setupDone ~= true then A:SetOption("setupDone", true, true) end
    end)
    self:SetGamepadShoulder(frame, function(direction) ui.go(ui.step + direction) end)
    self:SetGamepadBack(frame, function()
        if ui.step > 1 then ui.go(ui.step - 1); return true end
    end)

    self:SetGamepadExtra(frame, function(button)
        if button == "PAD3" and ui.step == 1 then ui.complete(true); return true end
        return false
    end)
    frame:Hide()
    return ui
end

function A:OpenWelcome()
    if self:IsCombat() then self:Print("Open the welcome setup after combat."); return end
    if not self.db then return end
    self:ApplyFirstRunDefaults()
    local ui = self:CreateWelcome()
    self.pendingWelcome, self.welcomeDelay = nil, nil
    for _, other in ipairs({ self.settings, self.nativeSettings, self.layoutSettings }) do
        if other then other:Hide() end
    end
    if self.options_ui then self.options_ui.frame:Hide() end
    if self.HideInputOffer and self.inputSwitch and self.inputSwitch.state == "offer" then self:HideInputOffer() end
    ui.finishing = nil
    ui.frame:SetScale(self:WindowScale(W, H))
    ui.go(1)
    self:PlaceWindow(ui.frame, "Welcome")
    ui.active = true
    ui.frame:Show()
    pcall(ui.frame.Raise, ui.frame)
end
