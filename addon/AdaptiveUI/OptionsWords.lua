local _, A = ...
















local EARLIER = " (earlier look)"

A.optionWords = {

    themeScheme = { "Colour scheme", "Sixteen schemes for the whole HUD. Each tile is its own preview." },
    accentCustom = { "Use my own accent colour", "Replace the scheme's accent with a colour you pick." },
    accent = { "Accent colour", "Your accent: lines, marks and the focus ring." },
    themeShadow = { "Shadow strength", "How deep the drop shadows under panels go." },
    themeBezel = { "Soft edge highlight on panels", "A faint lit edge and sheen on raised panels." },
    themeTextShadow = { "Soft text shadow", "A soft shadow under every line of text." },
    unitVeil = { "Soft shadow behind the plates", "A soft pool of shade behind the unit plates." },
    flatBars = { "One-colour bars", "One colour in the fill, one in the empty channel." },
    plusBarTexture = { "Textured bars", "A little grain and depth in the health and mana fills." },
    motionLevel = { "Movement", "How much the HUD moves: full, reduced, or none.",
        { full = "Full", subtle = "Reduced", off = "None" } },
    barEffect = { "Health bar effect", "When health changes: a glow, falling sand, a slice, or a pulse.",
        { off = "None", classic = "Soft glow", sand = "Falling sand", ash = "Falling sand, grey", shear = "Slice",
          pulse = "Pulse" } },
    gaugeTicks = { "Quarter marks on the bars", "Thin marks at a quarter, a half and three quarters." },
    themeHeadingFont = { "Heading font", "The typeface for names and titles.",
        { spectral = "Spectral (warm serif)", barlow = "Barlow (condensed)", chakra = "Chakra Petch (angular)" } },
    borders = { "Thin borders", "One-pixel outlines on panels and slots." },
    plusPixelSnap = { "Sharpen plate edges", "Rounds every plate edge to a whole screen pixel." },
    opacity = { "Panel solidity", "How solid the panels are. Lower lets the world through." },
    artRecolour = { "Colour the artwork to match", "The scheme tints the painted plates, bars and buttons." },
    recolourMarks = { "Metal details follow the scheme", "The painted gold details take the scheme's colour.",
        { matched = "Scheme colour", accent = "Accent" .. EARLIER } },
    artMaterial = { "Painted art follows the colour scheme", "Every painted plate, bar and plaque takes the scheme's tint.",
        { scheme = "Yes (default)", painted = "No, keep the art as painted" } },
    artGlaze = { "Colour glaze on painted art", "How strongly the painted stone takes the scheme's hue. Off keeps only the tint." },
    elevBase = { "Chat and map panels: solidity", "How solid the chat, map and tracker panels are." },
    elevPanel = { "Main panels: solidity", "How solid the large panels are." },
    elevRaised = { "Tooltips: solidity", "How solid tooltips and the chat box are." },
    textScale = { "Text size", "Every piece of text on the HUD, together." },
    style = { "HUD style", "Full draws every panel; Minimal draws less.", { rpg = "Full", minimal = "Minimal" } },
    accentRule = { "Accent line on the right column", "A thin accent line along the right-hand column." },
    actionWash = { "Shade under the controller arms", "How dark the ground under each controller arm is." },

    unitMode = { "Unit frames", "AdaptiveUI's plates, or Blizzard's own frames restyled.",
        { lite = "Blizzard's, restyled", plus = "AdaptiveUI plates" } },
    plateSkin = { "Plate design", "How the painted plate holds your health and mana.",
        { inlay = "Bars in the painting" } },
    plateMantleCast = { "Cast bar look", "Where your cast shows on the plate.",
        { above = "Above the name", seam = "Glow line" } },
    plateFillStyle = { "Fill look", "The look's own: under AUI Oakborn the wood chips away to show your colour.",
        { auto = "The look's own", color = "Solid colour" } },
    oakPlate = { "Plate shape", "Which oak plate your unit frames wear under AUI Oakborn.",
        { smooth = "Smooth", rough = "Rough", straight = "Straight" } },
    plateSmallSkin = { "Small frames", "Target's target, focus and pet: a tile or the plate painting.",
        { tile = "Tile", inlay = "Plate painting" } },
    raidSkin = { "Raid frames", "Styled with the raid tile, or Blizzard's own.", { tile = "Styled", native = "Blizzard's" } },
    plusPlayerOn = { "Player plate", "Show your own plate." },
    plusTargetOn = { "Target plate", "Show your target's plate." },
    plusFocusOn = { "Focus plate", "Show your focus's plate." },
    plusPetOn = { "Pet plate", "Show your pet's plate." },
    plusPartyOn = { "Party plates", "Show a plate for each party member." },
    plusTotOn = { "Target-of-target plate", "Show who your target is targeting." },
    plusFocusTargetOn = { "Focus-target plate", "Show your focus's target." },
    plusFocusTargetTargetOn = { "Focus-target's-target plate", "Show who your focus's target is targeting." },
    plusSmallWidth = { "Small plate width", "Width of the focus, pet and party plates." },
    plusWidth = { "Plate width", "Width of your plate and your target's; the height follows." },
    plusHealthHeight = { "Health bar height", "How tall the health bar is." },
    plusPowerHeight = { "Mana bar height", "How tall the mana, rage or energy bar is. 0 hides it." },
    plusShowLevel = { "Show level", "The level beside the name." },
    plusShowTag = { "Elite or rare tag", "Marks elite and rare enemies." },
    plusShowMarker = { "Raid marker", "The raid marker on your target and focus." },
    plusNameMax = { "Name length", "Longer names are cut, never below eight letters. 40 is the full name." },
    plusMirror = { "Mirror the target side", "The target-side plates face yours." },
    plusNamePos = { "Name position", "Where the name sits above the bar.", { left = "Left", center = "Centre" } },
    plusLevelPos = { "Level position", "Where the level sits.", { left = "With the name", right = "At the health number" } },
    plusHealthFormat = { "Health number", "What the number shows. With current and max, long names may be cut.",
        { both = "Percent, current, max", current = "Percent and current", percent = "Percent", none = "Percent, no value" } },
    plusHealthPos = { "Health number position", "Where the health number sits.",
        { right = "Above the bar, right", center = "In the bar, centre", left = "In the bar, left" } },
    plusNumberStyle = { "Number style", "12345 or 12.3k.", { full = "Full (12345)", short = "Short (12.3k)" } },
    plusPowerText = { "Show your mana as a number", "Your mana, rage or energy as a number on your plate." },
    playerRule = { "Colour marker on the plates", "A small class-colour marker on your plate and your target's." },
    plusKeyline = { "Gold lines", "Thin gold rules and edges on the plates." },
    plusRim = { "Sharp outline", "A crisp outline on the plate's planes." },
    plusGlow = { "Edge highlights", "Lit edges on the end cap and the bars." },
    plusFlash = { "Flash on change", "An edge flash when something changes, and on the focus ring." },
    plusCorner = { "Extra corner cut", "A second angled cut on each plate." },
    plusUnified = { "Join plate pieces", "The plate's pieces read as one object." },

    emptyRecede = { "Fade empty slots", "A slot with nothing in it fades back." },
    iconCrop = { "Tight icon crop", "Trims the icons' own border." },
    actionDiamond = { "Diamond-shaped controller slots", "Diamond slots on the controller bars instead of squares." },
    compassIconShape = { "Controller icon shape", "Square icons, or turned to diamonds.",
        { square = "Square", diamond = "Diamond" } },
    keyboardSkin = { "Keyboard bar design", "The painted bar under your keyboard buttons.",
        { base = "Painted, buttons standing on it", classic = "Blizzard's frame" } },
    keyboardBackdrop = { "Shade behind the keyboard bar", "A fade, or nothing.",
        { fade = "Fade", off = "None" } },
    keyboardSlotSkin = { "Button style", "Painted tiles, or Blizzard's frames.",
        { tile = "Painted", classic = "Blizzard's" } },
    keyboardEmptyHotkey = { "Key name on an empty slot", "Faint, full, or hidden.",
        { faint = "Faint", full = "Full", none = "Hidden" } },
    look = { "Look", "Everything painted at once. AUI Oakborn is the flagship.",
        { oakborn = "AUI Oakborn", dusk = "AUI Dusk", blizzard = "Blizzard" } },
    mapSkin = { "Minimap frame", "The painted panel the minimap sits on.",
        { shelf = "Oak shelf", base = "Map standing on the panel", card = "Card" } },
    windowSkin = { "Window frames", "How this window and the others are framed.",
        { branch = "Flat, oak foot", painted = "Painted", flat = "Flat" } },
    trackerStyle = { "Quest tracker look", "Tidy, or no backing.",
        { tidy = "Tidy", bare = "No backing" } },
    chatStyle = { "Chat look", "Tidy shows the chat input only while you type.",
        { tidy = "Tidy", bare = "No backing" } },
    chromeCrest = { "Crest emblem", "The crest on the windows, or off.",
        { both = "Map and windows", map = "Map only", windows = "Windows", off = "Off" } },
    chromeTrackerHead = { "Tracker header like the zone name", "The quest tracker's header matches the zone strip." },

    safeZone = { "Screen margin", "Keeps everything this far from the screen edge. 5% suits a TV." },
    scale = { "Unit frame size", "Your plates or Blizzard's frames, bigger or smaller." },
    dockScale = { "Action bar size", "The controller bars and the keyboard bars." },
    compassGround = { "Behind the controller bars", "A divider, or nothing under the cross.",
        { divider = "Divider", none = "Nothing" } },
    compassHeroArm = { "Biggest controller group", "Make one arm of the controller bars bigger.",
        { none = "All the same", compassTop = "Top", compassLeft = "Left (LT)", compassRight = "Right (RT)",
          compassBottom = "Bottom" } },
    compassPreset = { "Controller bar sizes", "A starting point for the eight group sizes; they stay yours after.",
        { classic = "All equal", heroTop = "Top bigger", heroThumb = "Bottom bigger", heroLeft = "Left bigger",
          heroRight = "Right bigger" } },
    compassAutoSpread = { "Widen for big groups", "Big groups push the side arms out instead of shrinking." },
    clusterTray = { "Backing under button groups", "A tray under each group of buttons." },
    compassDividerLight = { "Triggers light the divider", "Holding LT or RT lights the divider from that side." },
    compassBumperGlow = { "Bumpers glow while held", "The LB and RB plaques glow while you hold them." },
    compassPromptStyle = { "Trigger prompts look", "Plain black chips with white names, or the controller pictures.",
        { auto = "Match the look", flat = "Plain black", native = "Controller pictures" } },
    keyboardCentre = { "Centre the keyboard bar", "Keeps the keyboard bars centred on screen." },
    keyboardMicroRow = { "Bags and menu buttons", "A small row above the bar, or beside it.",
        { above = "Row above", row = "Beside" } },
    keyboardMicroSkin = { "Style the menu buttons", "The menu and bag buttons match the bar." },
    keyboardMicroScale = { "Bags and menu size", "Size of the menu and bag buttons." },
    keyboardSlotInset = { "Button border width", "A thinner border shows more of the icon.",
        { ["0.125"] = "Standard", ["0.089"] = "Thin" } },
    keyboardHotkeyAbbrev = { "Short key names", "S-1 instead of Shift-1." },
    keyboardStatusLane = { "XP bar on the action bar", "The experience bar sits inside the bar's backing." },
    keyboardLift = { "Lift the bar off the edge", "Keeps the keyboard bar clear of the screen's bottom edge." },
    xpLane = { "Experience bar", "Blizzard's own, or inside the painted keyboard bar.",
        { blizzard = "Blizzard's", inlay = "In the painted bar" } },
    minimapScale = { "Minimap size", "The minimap and everything on it." },
    minimapCoords = { "Coordinates under the map", "Where you are, under the minimap." },
    minimapZone = { "Zone name", "The zone name above the minimap." },
    auraTray = { "Tidy buff and debuff rows", "Buffs and debuffs in an even row on both plates." },
    auraTrayEmpty = { "Keep the empty buff row", "Show the buff row's backing even when it is empty." },
    trackerAlpha = { "Quest tracker backing", "How solid the backing behind the objectives is." },
    chatAlpha = { "Chat backing", "How solid the backing behind the chat is." },
    chromeChat = { "Style the chat box and tabs", "The chat input and tabs match the map." },
    infoFpsOn = { "Frame rate", "Frames per second, as a small strip." },
    infoFpsStyle = { "Frame rate text", "How the frame rate reads." },
    infoLatencyOn = { "Latency", "Your connection's delay, as a small strip." },
    infoLatencyStyle = { "Latency text", "Home, world, or the worse of the two.",
        { both = "Home / world", home = "Home only", worst = "The worse one" } },
    infoDurabilityOn = { "Durability", "How worn your gear is." },
    infoDurabilityStyle = { "Durability text", "The most worn item, or the average." },
    infoClockOn = { "Clock", "A clock, as a small strip." },
    infoClockSource = { "Clock source", "Your computer's time or the server's." },
    infoClockFormat = { "Clock format", "24-hour or 12-hour." },
    infoTextSize = { "Strip text size", "Normal is the size you can read mid-fight." },
    infoColorize = { "Warning colours", "Low frame rate, high latency and worn gear turn red." },
    infoGoldOn = { "Gold", "Your gold, as a small strip." },
    infoGoldStyle = { "Gold text", "Gold only, or gold, silver and copper." },
    infoBagsOn = { "Bag space", "Free bag slots, as a small strip." },
    infoBagsStyle = { "Bag space text", "Free slots, or free and total." },
    infoCoordsOn = { "Coordinates", "Where you are on the map, as a small strip." },
    infoCoordsStyle = { "Coordinates text", "One decimal, or whole numbers." },
    infoBar = { "Info bar", "One bar along a screen edge that holds the info strips.",
        { off = "Off", top = "Top edge", bottom = "Bottom edge" } },
    infoBarHeight = { "Info bar height", "How tall the info bar is." },
    infoFpsInBar = { "Frame rate in the bar", "Show the frame rate in the info bar." },
    infoLatencyInBar = { "Latency in the bar", "Show the latency in the info bar." },
    infoDurabilityInBar = { "Durability in the bar", "Show the durability in the info bar." },
    infoClockInBar = { "Clock in the bar", "Show the clock in the info bar." },
    infoGoldInBar = { "Gold in the bar", "Show your gold in the info bar." },
    infoBagsInBar = { "Bag space in the bar", "Show your bag space in the info bar." },
    infoCoordsInBar = { "Coordinates in the bar", "Show your coordinates in the info bar." },

    plusLossTrail = { "Damage leaves a trail", "A hit leaves a fading trail behind the health fill." },
    plusHealGhost = { "Show incoming heals", "Heals on their way show ahead of the health fill." },
    plusDanger = { "Low-health warning", "Low health shows a bracket and a pulse, not colour alone." },
    plusColorPlayer = { "Your health bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColorTarget = { "Target health bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColorFocus = { "Focus health bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColorPet = { "Pet health bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColorParty = { "Party health bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColorTot = { "Target-of-target bar colour", "Automatic, class, reaction, a gradient, or your own." },
    plusColor = { "My own health colour", "Used by any plate set to My own colour." },
    plusPartyMax = { "Party members shown", "How many party plates to draw, up to four." },
    plusPartyDirection = { "Party stack direction", "Stack the party plates up or down.", { down = "Down", up = "Up" } },
    plusPartySpacing = { "Space between party plates", "The gap between one party plate and the next." },
    plusPartyBar = { "Party health bar height", "How tall each party member's health bar is." },
    plusPartyStatus = { "Dim dead or offline members", "Dims a party member who is dead or offline." },
    plusPartyLeader = { "Leader tag", "Marks the group leader." },
    plusPartyRole = { "Role icon", "Tank, healer or damage, when the game shares it." },
    plusTotPlacement = { "Target-of-target placement", "Under the target, or beside it.", { below = "Under", side = "Beside" } },
    dpsStripOn = { "Damage under your plate", "A small readout of your own damage, from the game's meter." },
    dpsStripMetric = { "Damage readout shows", "Damage and DPS, or one of them.",
        { both = "Damage and DPS", dps = "DPS only", total = "Damage only" } },
    dpsStripSession = { "Which fight", "This fight, or everything since you logged in.",
        { current = "This fight", overall = "Since login" } },
    dpsStripHold = { "Stays after the fight", "How long the readout stays once combat ends." },
    dpsStripHeight = { "Damage readout height", "How tall the damage readout is." },
    dpsStripBar = { "Share-of-fight bar", "In a group: a bar showing your share of the damage." },
    castPlayerMode = { "Your cast bar", "Blizzard's bar restyled, or AdaptiveUI's own that you can move.",
        { native = "Blizzard's", custom = "AdaptiveUI's" } },
    castTargetMode = { "Target cast bar", "Blizzard's bar restyled, or AdaptiveUI's own that you can move.",
        { native = "Blizzard's", custom = "AdaptiveUI's" } },
    castFocusMode = { "Focus cast bar", "Blizzard's bar restyled, or AdaptiveUI's own that you can move.",
        { native = "Blizzard's", custom = "AdaptiveUI's" } },
    castPlayerAnchor = { "Your cast bar placement", "On the health bar, or free to move.",
        { anchored = "On the health bar", independent = "Free" } },
    castTargetAnchor = { "Target cast bar placement", "On the health bar, or free to move.",
        { anchored = "On the health bar", independent = "Free" } },
    castWidth = { "Cast bar width", "Width of AdaptiveUI's cast bars." },
    castHeight = { "Cast bar height", "Height of AdaptiveUI's cast bars." },
    castShowIcon = { "Spell icon", "The spell's icon, when the game shares it." },
    castShowName = { "Spell name", "The name of the spell being cast." },
    castShowTime = { "Time left", "Seconds left on the cast." },
    castRestrictedStrip = { "Show casts the game hides", "A plain bar when the game hides a cast's details." },

    mode = { "Button pictures", "Controller buttons or keyboard keys on your action bars.",
        { auto = "Detect", controller = "Controller", keyboard = "Keyboard" } },
    autoSwitchInput = { "Gamepad Mode reminder", "Picking up a controller says where Gamepad Mode is.",
        { ask = "Remind me", off = "Never" } },
    actionGlyphs = { "Controller button pictures", "Draws the controller button under each slot." },
    actionCamera = { "Action camera", "Moves the game camera over your shoulder. Off by default." },
    moverSnap = { "Snap to a grid", "Things you drag land on the grid." },
    moverStep = { "Nudge distance", "How far one nudge moves a thing, and the grid size." },
    tooltipScale = { "Tooltip size", "Bigger tooltips, for reading from the sofa." },
    tooltipCorner = { "Tooltip corner", "Which screen corner tooltips appear in." },
    tooltipOffsetX = { "Tooltip distance from the side", "How far tooltips sit from the screen's side edge." },
    tooltipOffsetY = { "Tooltip distance from the edge", "How far tooltips sit from the screen's top or bottom." },
    tooltipHealthBar = { "Health bar in tooltips", "A health bar in unit tooltips." },

    compassButtonSkin = { "Controller button backing", "Painted tiles behind each button.",
        { tiles = "Painted tiles" } },
    compassBumperSkin = { "Bumper plaques", "The painted plaque behind LB and RB, or Blizzard's chips.",
        { arm = "Painted plaque on its arm", native = "Blizzard's" } },
    casts = { "Cast strips on the old HUD", "The cast strips of the original floating HUD." },
}


local ARM = { top = "Up", left = "Left", right = "Right", bottom = "Down" }
for _, id in ipairs(A.compassGroupOrder or {}) do
    local arm, side = id:match("^(%a-)([LR])$")
    A.optionWords["compassGroupSize." .. id] = { string.format("%s group: %s", ARM[arm] or arm,
        side == "L" and "d-pad buttons" or "face buttons"), "Size of this group on the controller bars." }
end


local HEALTH = { auto = "Automatic", class = "Class colour", reaction = "Reaction colour", health = "Health gradient",
    custom = "My own colour" }
for _, key in ipairs({ "plusColorPlayer", "plusColorTarget", "plusColorFocus", "plusColorPet", "plusColorParty", "plusColorTot" }) do
    if A.optionWords[key] then A.optionWords[key][3] = HEALTH end
end




function A:ApplyOptionWords()
    for _, option in ipairs(self.options) do
        local words = self.optionWords[option.key]
        if words then
            if words[1] then option.label = words[1] end
            if words[2] then self.optionDesc[option.key] = words[2] end
            if words[3] and option.values then
                for _, entry in ipairs(option.values) do
                    local name = words[3][tostring(entry.value)]
                    if name then entry.label = name end
                end
            end
        end
        for _, entry in ipairs(option.values or {}) do
            if type(entry.label) == "string" and entry.label:find("%(0%.%d") then
                entry.label = entry.label:gsub("%s*%(0%.[^%)]*%)", "") .. EARLIER
            end
        end
    end

    for _, preset in ipairs(self.optionPresets or {}) do
        local name = ({ console = "Console", minimal = "Minimal", fullrpg = "Everything on" })[preset.key]
        if name then preset.label = name end
    end
end
A:ApplyOptionWords()










local KEYBOARD_EDIT = "Not applied: set it in Edit Mode (Esc > Edit Mode)."
local PAD_EDIT = "Not applied: Blizzard places the controller bars (Edit Mode for the rest)."
A.handsOffWords = {
    dockScale = KEYBOARD_EDIT,
    keyboardCentre = KEYBOARD_EDIT,
    keyboardMicroRow = KEYBOARD_EDIT,
    keyboardMicroScale = KEYBOARD_EDIT,
    keyboardLift = KEYBOARD_EDIT,
    compassHeroArm = PAD_EDIT,
    compassHeroSize = PAD_EDIT,
    compassPreset = PAD_EDIT,
    compassAutoSpread = PAD_EDIT,
    ["scale.actionBar6"] = KEYBOARD_EDIT,
    ["scale.actionBar7"] = KEYBOARD_EDIT,
    ["scale.actionBar8"] = KEYBOARD_EDIT,

    tooltipCorner = "Not applied: set the tooltip's corner in Edit Mode (Esc > Edit Mode > HUD Tooltip).",
    tooltipOffsetX = "Not applied: set the tooltip's position in Edit Mode (Esc > Edit Mode > HUD Tooltip).",
    tooltipOffsetY = "Not applied: set the tooltip's position in Edit Mode (Esc > Edit Mode > HUD Tooltip).",
    tooltipScale = "Not applied: set tooltips in Edit Mode (Esc > Edit Mode).",
    ["scale.auras"] = "Not applied: set it in Edit Mode (Esc > Edit Mode > Buff Frame, Debuff Frame).",
    ["scale.objectives"] = "Not applied: set it in Edit Mode (Esc > Edit Mode > Objective Tracker).",
}
for _, id in ipairs(A.compassGroupOrder or {}) do A.handsOffWords["compassGroupSize." .. id] = PAD_EDIT end
A.handsOffOptions = {}
for key in pairs(A.handsOffWords) do A.handsOffOptions[#A.handsOffOptions + 1] = key end
table.sort(A.handsOffOptions)
function A:ApplyHandsOffWords()
    for key, words in pairs(self.handsOffWords) do
        if self.optionIndex and self.optionIndex[key] then self.optionDesc[key] = words end
    end
end
A:ApplyHandsOffWords()
