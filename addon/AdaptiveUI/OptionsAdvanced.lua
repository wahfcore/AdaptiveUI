local _, A = ...




















A.advancedSections = {
    { key = "look", label = "Look", tabs = {
        { "scheme", "Colours" }, { "art", "Art" }, { "surfaces", "Surfaces" }, { "text", "Text & motion" } } },
    { key = "units", label = "Unit frames", tabs = {
        { "general", "All plates" }, { "player", "Player" }, { "target", "Target" }, { "tot", "Target of target" },
        { "focus", "Focus" }, { "pet", "Pet" }, { "party", "Party" }, { "raid", "Raid frames" } } },
    { key = "casts", label = "Cast bars", tabs = {
        { "player", "Player" }, { "target", "Target" }, { "focus", "Focus" }, { "look", "Look" } } },
    { key = "actionbars", label = "Action bars", tabs = {
        { "bar", "Bar" }, { "buttons", "Buttons" }, { "menu", "Bags & menu" }, { "xp", "XP bar" } } },
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
put("units", "target", "plusTargetOn", "plusColorTarget", "plusTargetAuras", "plusMirror")
put("units", "tot", "plusTotOn", "plusColorTot", "plusTotPlacement")
put("units", "focus", "plusFocusOn", "plusColorFocus", "plusFocusTargetOn", "plusFocusTargetTargetOn")
put("units", "pet", "plusPetOn", "plusColorPet", "plusShowPetMood")
put("units", "party", "plusPartyOn", "plusColorParty")
put("units", "raid", "raidSkin")
put("casts", "player", "castPlayerMode", "castPlayerAnchor")
put("casts", "target", "castTargetMode", "castTargetAnchor")
put("casts", "focus", "castFocusMode")
put("casts", "look", "plateMantleCast", "castRestrictedStrip")
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



function A:AdvancedTabOptions(section, tab, filter)
    local order, buckets = {}, {}
    for _, option in ipairs(self.options) do
        local s, t, heading = self:AdvancedHome(option)
        if s == section and (t == tab or tab == nil) and not option.inline and (not filter or filter(option)) then
            heading = heading or "Settings"
            if not buckets[heading] then buckets[heading] = {}; order[#order + 1] = heading end
            local list = buckets[heading]
            list[#list + 1] = option
        end
    end
    local out = {}
    for _, h in ipairs(order) do out[#out + 1] = { subsection = h, options = buckets[h] } end
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
