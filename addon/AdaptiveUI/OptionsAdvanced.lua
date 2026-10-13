local _, A = ...




















A.advancedSections = {
    { key = "look", label = "Look", tabs = {
        { "scheme", "Colours" }, { "art", "Art" }, { "surfaces", "Surfaces" }, { "text", "Text & motion" } } },
    { key = "units", label = "Unit frames", tabs = {
        { "general", "All plates" }, { "player", "Player" }, { "target", "Target" }, { "tot", "Target of target" },
        { "focus", "Focus" }, { "pet", "Pet" }, { "party", "Party" }, { "raid", "Raid frames" },
        { "nameplates", "Nameplates" } } },
    { key = "casts", label = "Cast bars", tabs = {
        { "player", "Player" }, { "target", "Target" }, { "focus", "Focus" }, { "look", "Look" } } },
    { key = "actionbars", label = "Action bars", tabs = {
        { "bar", "Bar" }, { "buttons", "Buttons" }, { "menu", "Bags & menu" }, { "xp", "XP bar" },
        { "forms", "Forms & specs" } } },
    { key = "compass", label = "Compass / gamepad", tabs = {
        { "layout", "Layout" }, { "buttons", "Buttons" }, { "ground", "Ground & effects" }, { "sizes", "Group sizes" } } },
    { key = "mapchat", label = "Map, chat & windows", tabs = {
        { "minimap", "Minimap" }, { "chat", "Chat" }, { "tracker", "Quest tracker" }, { "windows", "Windows" },
        { "tooltips", "Tooltips" } } },
    { key = "info", label = "Buffs & info", tabs = {
        { "buffs", "Buffs" }, { "strips", "Info strips" }, { "bar", "Info bar" } } },
    { key = "layout", label = "Move & size", tabs = {
        { "move", "Move things" }, { "movers", "Every mover" }, { "elements", "Every element" } } },
    { key = "controls", label = "Controls", tabs = { { "input", "Input" }, { "camera", "Camera" } } },
    { key = "profiles", label = "Profiles" },
    { key = "help", label = "Help & tools" },
}


A.advancedGroupHome = {
    theme = { "look", "scheme" }, general = { "look", "surfaces" },
    plus = { "units", "general" }, plustext = { "units", "general" }, pluscolor = { "units", "general" },
    gauges = { "units", "general" }, plusparty = { "units", "party" }, damage = { "units", "player" },
    nameplates = { "units", "nameplates" },
    forms = { "actionbars", "forms" },
    casts = { "casts", "look" },
    keyboard = { "actionbars", "bar" },
    actions = { "compass", "buttons" }, compass = { "compass", "layout" },
    movers = { "layout", "move" },
    minimap = { "mapchat", "minimap" }, panels = { "mapchat", "chat" }, tooltip = { "mapchat", "tooltips" },
    info = { "info", "strips" }, infomore = { "info", "strips" }, infobar = { "info", "bar" },
    profiles = { "profiles", nil },
}


local home = {}
local function put(section, tab, ...)
    for i = 1, select("#", ...) do home[select(i, ...)] = { section, tab } end
end
put("look", "scheme", "look", "themeScheme", "themeCustomAccent", "themeCustomInk", "accentCustom", "accent", "recolourMarks")
put("look", "art", "artRecolour", "artMaterial", "artGlaze")
put("look", "surfaces", "themeShadow", "themeBezel", "themeTextShadow", "unitVeil", "borders", "opacity",
    "elevBase", "elevPanel", "elevRaised", "accentRule", "style")
put("look", "text", "textScale", "themeHeadingFont", "motionLevel")
put("units", "general", "barEffect", "flatBars", "plusBarTexture", "gaugeTicks", "plusPixelSnap", "plusShowPvp",
    "plateFillStyle", "oakPlate", "plateSmallSkin", "scale")
put("units", "player", "plusPlayerOn", "plusColorPlayer", "plusPowerText")
put("units", "target", "plusTargetOn", "plusColorTarget", "plusTargetAuras", "plusMirror", "plusExecute")
put("units", "tot", "plusTotOn", "plusColorTot", "plusTotPlacement")
put("units", "focus", "plusFocusOn", "plusColorFocus", "plusFocusTargetOn", "plusFocusTargetTargetOn")
put("units", "pet", "plusPetOn", "plusColorPet", "plusShowPetMood")
put("units", "party", "plusPartyOn", "plusColorParty")
put("units", "raid", "raidSkin")
put("casts", "player", "castPlayerMode", "castPlayerAnchor")
put("casts", "target", "castTargetMode", "castTargetAnchor")
put("casts", "focus", "castFocusMode")
put("casts", "look", "plateMantleCast", "castRestrictedStrip", "casts")
put("actionbars", "bar", "keyboardSkin", "keyboardBackdrop", "keyboardCentre", "keyboardLift")
put("actionbars", "buttons", "keyboardSlotSkin", "keyboardSlotInset", "keyboardHotkeyAbbrev",
    "keyboardEmptyHotkey", "emptyRecede", "iconCrop")
put("actionbars", "menu", "keyboardMicroRow", "keyboardMicroSkin", "keyboardMicroScale")
put("actionbars", "xp", "xpLane", "keyboardStatusLane")
put("compass", "layout", "compassHeroArm", "compassPreset", "compassAutoSpread", "dockScale")
put("compass", "buttons", "actionDiamond", "compassIconShape",
    "compassPromptStyle", "compassBumperSkin")
put("compass", "ground", "compassGround", "clusterTray",
    "actionWash", "compassDividerLight", "compassBumperGlow")
put("mapchat", "minimap", "mapSkin", "minimapScale", "minimapCoords", "minimapZone", "chromeCrest")
put("mapchat", "chat", "chatStyle", "chatAlpha", "chromeChat")
put("mapchat", "tracker", "trackerStyle", "trackerAlpha", "chromeTrackerHead")
put("mapchat", "windows", "windowSkin")
put("info", "buffs", "auraTray", "auraTrayEmpty")
put("layout", "move", "safeZone", "moverSnap", "moverStep")
put("controls", "input", "mode", "autoSwitchInput", "actionGlyphs")
put("controls", "camera", "actionCamera")
A.advancedKeyHome = home










local also = {}
local function alsoOn(key, ...)
    local list = also[key] or {}
    for i = 1, select("#", ...) do
        local section, tab = (select(i, ...)):match("^([^/]+)/(.+)$")
        list[#list + 1] = { section, tab }
    end
    also[key] = list
end

alsoOn("plateSmallSkin", "units/tot", "units/focus", "units/pet")
alsoOn("plusSmallWidth", "units/tot", "units/focus", "units/pet", "units/party")

alsoOn("plusWidth", "units/player", "units/target")
alsoOn("plusDanger", "units/player", "units/target")
alsoOn("plusHealthHeight", "units/player", "units/target")
alsoOn("plusPowerHeight", "units/player", "units/target")
alsoOn("playerRule", "units/player", "units/target")

alsoOn("plusShowTag", "units/target", "units/focus")
alsoOn("plusShowMarker", "units/target", "units/focus")
alsoOn("plusRankStud", "units/target", "units/focus")

alsoOn("plusColor", "units/player", "units/target", "units/tot", "units/focus", "units/pet", "units/party")
alsoOn("unitVeil", "units/general")

alsoOn("emptyRecede", "compass/buttons")
alsoOn("iconCrop", "compass/buttons")
alsoOn("keyboardSlotSkin", "actionbars/menu")
alsoOn("actionGlyphs", "compass/buttons")
alsoOn("dockScale", "actionbars/bar")

alsoOn("compassBumperGlow", "compass/buttons")

alsoOn("plusTargetAuras", "info/buffs")

alsoOn("elevBase", "mapchat/minimap", "mapchat/chat", "mapchat/tracker")
alsoOn("elevRaised", "mapchat/tooltips")
alsoOn("chromeCrest", "mapchat/windows")
A.advancedAlsoOn = also



A.advancedSectionAlias = { combat = "units", general = "look", vetoes = "look", classic = "look", advanced = "help" }
A.simpleSectionAlias = { units = "look", casts = "combat", actionbars = "layout", compass = "layout",
    mapchat = "look", info = "layout" }



function A:AdvancedHome(option)
    local simpleSection, heading = self:OptionSection(option)
    if not simpleSection then return nil end
    local key = option.key
    local at = self.advancedKeyHome[key]
    if not at and key:find("^compassGroupSize%.") then at = { "compass", "sizes" } end
    if not at and option.group then at = self.advancedGroupHome[option.group] end
    if not at then return simpleSection, nil, heading end
    return at[1], at[2], heading
end



function A:AdvancedHomes(option)
    local s, t = self:AdvancedHome(option)
    if not s then return {} end
    local out = { { s, t } }
    for _, at in ipairs(self.advancedAlsoOn[option.key] or {}) do
        if not (at[1] == s and at[2] == t) then out[#out + 1] = { at[1], at[2] } end
    end
    return out
end


function A:AdvancedListedOn(option, section, tab)
    for _, at in ipairs(self:AdvancedHomes(option)) do
        if at[1] == section and (tab == nil or at[2] == tab) then return true end
    end
    return false
end

function A:AdvancedSection(key)
    for _, s in ipairs(self.advancedSections) do if s.key == key then return s end end
    return nil
end


function A:AdvancedTab(ui, section)
    local s = self:AdvancedSection(section)
    if not (s and s.tabs) then return nil end
    ui.tabs = ui.tabs or {}
    local current = ui.tabs[section]
    for _, t in ipairs(s.tabs) do if t[1] == current then return current end end
    return s.tabs[1][1]
end


A.advancedTabLead = {
    ["units/player"] = "plusPlayerOn", ["units/target"] = "plusTargetOn", ["units/tot"] = "plusTotOn",
    ["units/focus"] = "plusFocusOn", ["units/pet"] = "plusPetOn", ["units/party"] = "plusPartyOn",
    ["units/raid"] = "raidSkin",
}




function A:AdvancedTabOptions(section, tab, filter)
    local order, buckets = {}, {}


    local candidates = self.options
    local lead = tab and self.advancedTabLead[section .. "/" .. tab]
    lead = lead and self.optionIndex and self.optionIndex[lead]
    if lead then
        candidates = { lead }
        for _, option in ipairs(self.options) do if option ~= lead then candidates[#candidates + 1] = option end end
    end
    for pass = 1, 2 do
        for _, option in ipairs(candidates) do
            local s, t, heading = self:AdvancedHome(option)
            local own = s == section and (tab == nil or t == tab)

            if not option.inline
                and ((pass == 1 and own) or (pass == 2 and not own and self:AdvancedListedOn(option, section, tab)))
                and (not filter or filter(option)) then
                heading = heading or "Settings"
                local shown = self:AdvancedHeading(heading) or heading
                if not buckets[shown] then buckets[shown] = { name = heading }; order[#order + 1] = shown end
                local list = buckets[shown]
                list[#list + 1] = option
            end
        end
    end
    local out = {}
    for _, h in ipairs(order) do
        local list = buckets[h]
        local name = list.name
        list.name = nil
        out[#out + 1] = { subsection = name, options = list }
    end
    return out
end




A.advancedHeadingNames = {
    ["Unit frames"] = "Plate", ["Party and target-of-target"] = "Plate", ["Health colours"] = "Colour",
    ["Plate text"] = "Text", ["Plate styles"] = "Style", ["Map and windows"] = "Look",
    ["Action bars (controller)"] = false, ["Action bars (keyboard)"] = false, ["Minimap and auras"] = false,
    ["Chat and objectives"] = false, ["Info strips"] = false, ["Cast bars"] = false, ["Tooltips"] = false,
    ["Input and button pictures"] = false, ["Moving things"] = "Grid", ["Screen"] = "Screen",
}
function A:AdvancedHeading(name)
    local renamed = self.advancedHeadingNames[name]
    if renamed == false then return nil end
    return renamed or name
end


function A:AdvancedPlace(option)
    local s, t = self:AdvancedHome(option)
    local sec = s and self:AdvancedSection(s)
    if not sec then return nil end
    for _, entry in ipairs(sec.tabs or {}) do
        if entry[1] == t then return sec.label .. "  /  " .. entry[2] end
    end
    return sec.label
end
