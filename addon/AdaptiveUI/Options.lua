local _, A = ...















local PROFILE_VERSION = 2
local RESERVED = { profiles = true, profileKeys = true, profileVersion = true, blockedLog = true, quarantine = true, specProfiles = true,
    sessions = true, inspect = true, loadTrace = true, lastSave = true,
    buildStandDown = true, buildNoticed = true, inputOffer = true }

local function choice(...)
    local list = {}
    for i = 1, select("#", ...), 2 do list[#list + 1] = { value = (select(i, ...)), label = (select(i + 1, ...)) } end
    return list
end




local function colorModes()
    return {
        { value = "auto", label = "Automatic (class / reaction)" }, { value = "class", label = "Class color" },
        { value = "reaction", label = "Reaction color" }, { value = "health", label = "Health gradient (when public)" },
        { value = "custom", label = "Custom color" },
    }
end
local COLORMODES = colorModes()
local SCHEME_VALUES = {}
for _, scheme in ipairs(A.schemes) do SCHEME_VALUES[#SCHEME_VALUES + 1] = { value = scheme.id, label = scheme.name } end



SCHEME_VALUES[#SCHEME_VALUES + 1] = { value = "custom", label = "Custom" }

A.optionGroups = {
    { key = "general", label = "General" },
    { key = "theme", label = "Theme" },
    { key = "casts", label = "Cast bars" },
    { key = "plus", label = "Unit frames" },





    { key = "gauges", label = "Gauges and marks" },
    { key = "plustext", label = "Plate text" },
    { key = "pluscolor", label = "Plate colors" },
    { key = "plusparty", label = "Party / ToT" },
    { key = "damage", label = "Damage strip" },
    { key = "info", label = "Info strips" },
    { key = "infomore", label = "More strips" },
    { key = "infobar", label = "Info bar" },
    { key = "movers", label = "Movers" },
    { key = "actions", label = "Action bars" },






    { key = "keyboard", label = "Keyboard bars" },





    { key = "compass", label = "Compass" },
    { key = "minimap", label = "Minimap / auras" },
    { key = "panels", label = "Tracker / chat" },
    { key = "tooltip", label = "Tooltips" },
    { key = "profiles", label = "Profiles" },
}

A.options = {






    { key = "themeScheme", group = "theme", label = "Color scheme", type = "enum", widget = "scheme", default = "dusk", values = SCHEME_VALUES,


      accept = function(self, value)
          if value ~= "custom" or self:CustomScheme() then return true end
          return false, "custom scheme fails: " .. table.concat(self.customSchemeFailures or {}, ", ")
      end },






    { key = "themeCustomAccent", group = "theme", label = "Custom scheme: accent", type = "color", inline = "themeScheme",
      default = { 0.851, 0.694, 0.388, 1 } },
    { key = "themeCustomInk", group = "theme", label = "Custom scheme: body", type = "color", inline = "themeScheme",
      default = { 0.063, 0.059, 0.075, 1 } },
    { key = "accentCustom", group = "theme", label = "Use a custom accent color", type = "bool", default = false },
    { key = "accent", group = "theme", label = "Custom accent color", type = "color", default = { 0.56, 0.60, 0.98, 0.7 } },
    { key = "themeShadow", group = "theme", label = "Shadow strength", type = "number", default = 0.6, min = 0, max = 1, step = 0.1, format = "%.0f%%", scale = 100 },
    { key = "themeBezel", group = "theme", label = "Faded bezel and sheen", type = "bool", default = true },
    { key = "themeTextShadow", group = "theme", label = "Soft text shadow", type = "bool", default = true },






    { key = "unitVeil", group = "theme", label = "Soft glow behind the unit frames", type = "bool", default = false },




    { key = "flatBars", group = "theme", label = "Flat bar fills", type = "bool", default = true },










    { key = "plusBarTexture", group = "theme", label = "Obsidian grain and depth in the gauges", type = "bool", default = true },




















    { key = "motionLevel", group = "theme", label = "Motion", type = "enum", default = "full",
      values = choice("full", "Full", "subtle", "Subtle (reduced motion)", "off", "Off") },































    { key = "barEffect", group = "theme", label = "Effect on the health gauges", type = "enum",
      default = "classic", values = choice("off", "Off", "classic", "Classic (0.44 lights)",
                                           "sand", "Sand", "ash", "Sand, neutral",
                                           "shear", "Shear", "pulse", "Pulse only") },




    { key = "gaugeTicks", group = "gauges", label = "Quarter marks on the gauges", type = "bool", default = false },
















    { key = "themeHeadingFont", group = "theme", label = "Heading font", type = "enum", default = "spectral",
      values = choice("spectral", "Spectral (warm serif, default)", "barlow", "Barlow Semi Condensed",
                      "chakra", "Chakra Petch (bolder, cut corners)") },








    { key = "safeZone", group = "general", label = "Screen safe zone", type = "number", default = 0.05, min = 0, max = 0.08, step = 0.01, format = "%.0f%%", scale = 100 },






    { key = "plusLossTrail", group = "gauges", label = "Damage leaves a fading trail", type = "bool", default = true },



    { key = "plusHealGhost", group = "gauges", label = "Incoming heals show ahead of the fill", type = "bool", default = true },

    { key = "plusDanger", group = "gauges", label = "Low health warns with a bracket", type = "bool", default = false },















    { key = "borders", group = "general", label = "Hairline borders", type = "bool", default = true },




















    { key = "plusPixelSnap", group = "general", label = "Snap the plates to the pixel grid", type = "bool", default = true },
    { key = "opacity", group = "general", label = "Surface opacity", type = "number", default = 0.9, min = 0.25, max = 1, step = 0.05, format = "%.0f%%", scale = 100 },























    { key = "windowBanner", group = "general", label = "Painted masthead on the windows", type = "bool", default = false },











    { key = "artRecolour", group = "general", label = "Themes recolour the painted art", type = "bool", default = true },
    { key = "elevBase", group = "general", label = "Ambient surfaces", type = "number", default = 0.7, min = 0.2, max = 0.95, step = 0.05, format = "%.0f%%", scale = 100 },
    { key = "elevPanel", group = "general", label = "Hero panels", type = "number", default = 0.94, min = 0.2, max = 0.95, step = 0.05, format = "%.0f%%", scale = 100 },
    { key = "elevRaised", group = "general", label = "Tooltips / edit box", type = "number", default = 0.9, min = 0.2, max = 0.95, step = 0.05, format = "%.0f%%", scale = 100 },
    { key = "textScale", group = "general", label = "Font scale", type = "number", default = 1, min = 0.85, max = 1.2, step = 0.05, format = "%.2f" },
    { key = "style", group = "general", label = "HUD style", type = "enum", default = "rpg", values = choice("rpg", "Console RPG", "minimal", "Ultra-minimal") },
    { key = "mode", group = "general", label = "Input glyphs", type = "enum", default = "auto", values = choice("auto", "Auto", "controller", "Controller", "keyboard", "Keyboard") },

    { key = "unitMode", group = "plus", label = "Unit frame mode", type = "enum", default = "lite", values = choice("lite", "Lite (native, restyled)", "plus", "Plates (AdaptiveUI's own)") },
























    { key = "plateSkin", group = "plustext", label = "Unit plate style", type = "enum",
      default = "bar", values = {





          { value = "inlay", label = "Inlay (the bars are the painting)" },
          { value = "mantle", label = "Mantle (health on the painting)" },
          { value = "tinted", label = "Tinted (the painting is the bar)" },
          { value = "plate02", label = "Plate 02 (painted, 0.50)" },
          { value = "bar", label = "Bar (painted, 0.43)" },
          { value = "classic", label = "Classic (0.41)" },
      } },






    { key = "plateMantleCast", label = "Cast bar on the mantle", type = "enum",
      default = "face", values = {
          { value = "face", label = "In the painting's face" },
          { value = "above", label = "A plank above the name" },



          { value = "seam", label = "Light in the painting's seam" },
      } },








    { key = "plateFillStyle", group = "pluscolor", label = "Health and mana fill", type = "enum",
      default = "color", values = {
          { value = "color", label = "Colour fill in the channel" },
          { value = "carved", label = "Carved: the art chips away to the colour" },
      } },
    { key = "plusPlayerOn", group = "plus", label = "Player plate", type = "bool", default = true },
    { key = "plusTargetOn", group = "plus", label = "Target plate", type = "bool", default = true },
    { key = "plusFocusOn", group = "plus", label = "Focus plate", type = "bool", default = true },
    { key = "plusPetOn", group = "plus", label = "Pet plate", type = "bool", default = true },
    { key = "plusPartyOn", group = "plus", label = "Party plates", type = "bool", default = true },
    { key = "plusTotOn", group = "plus", label = "Target-of-target plate", type = "bool", default = true },



    { key = "plusFocusTargetOn", label = "Focus-target plate", type = "bool", default = true },
    { key = "plusFocusTargetTargetOn", label = "Focus-target's-target plate", type = "bool", default = true },
















    { key = "plusSmallWidth", group = "plus", label = "Focus / pet / party plate width", type = "number", default = 216, min = 140, max = 300, step = 4, format = "%.0f" },
    { key = "plusWidth", group = "plus", label = "Plate width", type = "number", default = 288, min = 180, max = 360, step = 4, format = "%.0f" },




















    { key = "plusHealthHeight", group = "plus", label = "Health bar height", type = "number", default = 16, min = 6, max = 28, step = 2, format = "%.0f" },
    { key = "plusPowerHeight", group = "plus", label = "Power bar height (0 = off)", type = "number", default = 6, min = 0, max = 12, step = 2, format = "%.0f" },
    { key = "plusShowLevel", group = "plustext", label = "Show level", type = "bool", default = true },
    { key = "plusShowTag", group = "plustext", label = "Elite / rare tag", type = "bool", default = true },
    { key = "plusShowMarker", group = "plustext", label = "Raid marker on target / focus", type = "bool", default = true },
    { key = "plusColorPlayer", group = "pluscolor", label = "Player health color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColorTarget", group = "pluscolor", label = "Target health color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColorFocus", group = "pluscolor", label = "Focus health color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColorPet", group = "pluscolor", label = "Pet health color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColorParty", group = "pluscolor", label = "Party health color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColorTot", group = "pluscolor", label = "Target-of-target color", type = "enum", default = "auto", values = COLORMODES },
    { key = "plusColor", group = "pluscolor", label = "Custom health color", type = "color", default = { 0.42, 0.78, 0.52, 1 } },

    { key = "plusPartyMax", group = "plusparty", label = "Members shown (max 4)", type = "number", default = 4, min = 1, max = 4, step = 1, format = "%.0f" },
    { key = "plusPartyDirection", group = "plusparty", label = "Stack direction", type = "enum", default = "down", values = choice("down", "Downward", "up", "Upward") },
    { key = "plusPartySpacing", group = "plusparty", label = "Spacing between plates", type = "number", default = 8, min = 4, max = 24, step = 4, format = "%.0f" },
    { key = "plusPartyBar", group = "plusparty", label = "Health bar height", type = "number", default = 8, min = 6, max = 20, step = 2, format = "%.0f" },
    { key = "plusPartyStatus", group = "plusparty", label = "Dead / offline styling", type = "bool", default = true },
    { key = "plusPartyLeader", group = "plusparty", label = "Leader tag", type = "bool", default = true },
    { key = "plusPartyRole", group = "plusparty", label = "Role icon (public role only)", type = "bool", default = true },



    { key = "dpsStripOn", group = "damage", label = "Personal damage strip", type = "bool", default = true },
    { key = "dpsStripMetric", group = "damage", label = "Strip shows", type = "enum", default = "both",
      values = choice("both", "Damage and DPS", "dps", "DPS only", "total", "Damage done only") },
    { key = "dpsStripSession", group = "damage", label = "Which fight", type = "enum", default = "current",
      values = choice("current", "This fight", "overall", "Everything since login") },
    { key = "dpsStripHold", group = "damage", label = "Stays up after combat", type = "number", default = 12, min = 4, max = 60, step = 2, format = "%.0f s" },
    { key = "dpsStripHeight", group = "damage", label = "Strip height", type = "number", default = 20, min = 16, max = 28, step = 2, format = "%.0f" },



    { key = "dpsStripBar", group = "damage", label = "Share-of-fight bar (for groups)", type = "bool", default = false },
    { key = "scale", group = "plus", label = "Unit frame scale", type = "number", default = 1, min = 0.7, max = 1.8, step = 0.1, format = "%.1f" },
    { key = "casts", group = "general", label = "Cast strips (legacy HUD)", type = "bool", default = true },

    { key = "plusNameMax", group = "plustext", label = "Name length (40 = full)", type = "number", default = 40, min = 8, max = 40, step = 2, format = "%.0f" },





    { key = "plusMirror", group = "plustext", label = "Mirror the target-side plates", type = "bool", default = true },
    { key = "plusNamePos", group = "plustext", label = "Name position", type = "enum", default = "left", values = choice("left", "Left", "center", "Center") },






    { key = "plusLevelPos", group = "plustext", label = "Level position", type = "enum", default = "left", values = choice("left", "With the name", "right", "At the health number") },









    { key = "plusHealthFormat", group = "plustext", label = "Health text detail", type = "enum", default = "percent",
      values = choice("both", "Percent + current / max", "current", "Percent + current", "percent", "Percent only", "none", "Percent only (no value)") },


    { key = "plusHealthPos", group = "plustext", label = "Health text position", type = "enum", default = "right", values = choice("right", "Above the bar, right", "center", "In the bar, centre", "left", "In the bar, left") },
    { key = "plusNumberStyle", group = "plustext", label = "Number style", type = "enum", default = "full", values = choice("full", "Full (12345)", "short", "Short (12.3k)") },
    { key = "plusPowerText", group = "plustext", label = "Power number on player", type = "bool", default = false },

    { key = "infoFpsOn", group = "info", label = "Frame rate strip", type = "bool", default = false },
    { key = "infoFpsStyle", group = "info", label = "Frame rate text", type = "enum", default = "value", values = choice("value", "60 fps", "label", "FPS 60", "short", "60") },
    { key = "infoLatencyOn", group = "info", label = "Latency strip", type = "bool", default = false },
    { key = "infoLatencyStyle", group = "info", label = "Latency text", type = "enum", default = "both", values = choice("both", "Home / world", "home", "Home only", "worst", "Worse of the two") },
    { key = "infoDurabilityOn", group = "info", label = "Durability strip", type = "bool", default = false },
    { key = "infoDurabilityStyle", group = "info", label = "Durability text", type = "enum", default = "lowest", values = choice("lowest", "Lowest item", "average", "Average") },
    { key = "infoClockOn", group = "info", label = "Clock strip", type = "bool", default = false },
    { key = "infoClockSource", group = "info", label = "Clock source", type = "enum", default = "local", values = choice("local", "Local time", "server", "Server time") },
    { key = "infoClockFormat", group = "info", label = "Clock format", type = "enum", default = "24", values = choice("24", "24 hour", "12", "12 hour") },
    { key = "infoTextSize", group = "info", label = "Strip text size", type = "enum", default = "caption", values = choice("caption", "Small (12)", "body", "Normal (14)") },
    { key = "infoColorize", group = "info", label = "Warn colours (low fps, high latency, worn gear)", type = "bool", default = true },
    { key = "infoGoldOn", group = "infomore", label = "Gold strip", type = "bool", default = false },
    { key = "infoGoldStyle", group = "infomore", label = "Gold text", type = "enum", default = "gold", values = choice("gold", "Gold only (1,234g)", "full", "Gold, silver, copper") },
    { key = "infoBagsOn", group = "infomore", label = "Bag space strip", type = "bool", default = false },
    { key = "infoBagsStyle", group = "infomore", label = "Bag space text", type = "enum", default = "free", values = choice("free", "Free slots", "both", "Free / total") },
    { key = "infoCoordsOn", group = "infomore", label = "Coordinates strip", type = "bool", default = false },
    { key = "infoCoordsStyle", group = "infomore", label = "Coordinates text", type = "enum", default = "decimal", values = choice("decimal", "One decimal (45.2, 67.8)", "integer", "Whole numbers (45, 68)") },
    { key = "infoBar", group = "infobar", label = "Info bar edge", type = "enum", default = "off", values = choice("off", "Off", "top", "Top edge", "bottom", "Bottom edge") },
    { key = "infoBarHeight", group = "infobar", label = "Bar height", type = "number", default = 24, min = 20, max = 36, step = 2, format = "%.0f" },
    { key = "infoFpsInBar", group = "infobar", label = "Frame rate in bar", type = "bool", default = true },
    { key = "infoLatencyInBar", group = "infobar", label = "Latency in bar", type = "bool", default = true },
    { key = "infoDurabilityInBar", group = "infobar", label = "Durability in bar", type = "bool", default = true },
    { key = "infoClockInBar", group = "infobar", label = "Clock in bar", type = "bool", default = true },
    { key = "infoGoldInBar", group = "infobar", label = "Gold in bar", type = "bool", default = true },
    { key = "infoBagsInBar", group = "infobar", label = "Bag space in bar", type = "bool", default = true },
    { key = "infoCoordsInBar", group = "infobar", label = "Coordinates in bar", type = "bool", default = true },



    { key = "moverSnap", group = "movers", label = "Snap to grid", type = "bool", default = true },
    { key = "moverStep", group = "movers", label = "Grid / nudge step (px)", type = "enum", default = "4", values = choice("4", "4", "8", "8", "16", "16") },
    { key = "pos.plusPlayer", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusTarget", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusTot", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoBar", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.legacyHud", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoGold", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoBags", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoCoords", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoFps", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoLatency", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoDurability", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.infoClock", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusFocus", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusFocustarget", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusFocustargettarget", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusPet", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.plusParty", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.compact", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.auras", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.actionCompass", tab = "movers", type = "offset", default = { 0, 0 } },


    { key = "pos.compassTop", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.compassLeft", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.compassRight", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.compassBottom", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.actionBar1", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.actionBar2", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.actionBar3", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.statusBar", tab = "movers", type = "offset", default = { 0, 0 } },

    { key = "pos.chat", tab = "movers", type = "offset", default = { 0, 0 } },
    { key = "pos.minimap", tab = "movers", type = "offset", default = { 0, 0 } },





    { key = "scale.chat", tab = "movers", label = "Chat size", type = "number", default = 1, min = 0.7, max = 1.5, step = 0.05, format = "%.2f" },
    { key = "scale.objectives", tab = "movers", label = "Objectives size", type = "number", default = 1, min = 0.6, max = 1.3, step = 0.05, format = "%.2f" },
    { key = "scale.auras", tab = "movers", label = "Buffs and debuffs size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "scale.castPlayer", tab = "movers", label = "Player cast bar size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "scale.castTarget", tab = "movers", label = "Target cast bar size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "scale.castFocus", tab = "movers", label = "Focus cast bar size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "scale.compact", tab = "movers", label = "Resource strip size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "scale.infoBar", tab = "movers", label = "Info bar size", type = "number", default = 1, min = 0.6, max = 1.6, step = 0.05, format = "%.2f" },
    { key = "pos.objectives", tab = "movers", type = "offset", default = { 0, 0 } },







    { key = "tooltipScale", group = "tooltip", label = "Tooltip scale", type = "number", default = 1, min = 0.8, max = 1.3, step = 0.05, format = "%.2f" },
    { key = "tooltipCorner", group = "tooltip", label = "Default anchor corner", type = "enum", default = "BOTTOMRIGHT", values = choice("BOTTOMRIGHT", "Bottom right", "BOTTOMLEFT", "Bottom left", "TOPRIGHT", "Top right", "TOPLEFT", "Top left") },
    { key = "tooltipOffsetX", group = "tooltip", label = "Anchor offset X (from edge)", type = "number", default = 16, min = 0, max = 400, step = 4, format = "%.0f" },
    { key = "tooltipOffsetY", group = "tooltip", label = "Anchor offset Y (from edge)", type = "number", default = 32, min = 0, max = 400, step = 4, format = "%.0f" },
    { key = "tooltipHealthBar", group = "tooltip", label = "Unit health bar in tooltip", type = "bool", default = true },





    { key = "castPlayerMode", group = "casts", label = "Player cast bar", type = "enum", default = "custom", values = choice("native", "Native (restyled)", "custom", "Custom (movable)") },
    { key = "castTargetMode", group = "casts", label = "Target cast bar", type = "enum", default = "custom", values = choice("native", "Native (restyled)", "custom", "Custom (movable)") },
    { key = "castFocusMode", group = "casts", label = "Focus cast bar", type = "enum", default = "native", values = choice("native", "Native (restyled)", "custom", "Custom (movable)") },






    { key = "castPlayerAnchor", group = "casts", label = "Player bar placement", type = "enum", default = "anchored", values = choice("anchored", "On the health bar", "independent", "Free-floating") },
    { key = "castTargetAnchor", group = "casts", label = "Target bar placement", type = "enum", default = "anchored", values = choice("anchored", "On the health bar", "independent", "Free-floating") },
    { key = "castWidth", group = "casts", label = "Custom bar width", type = "number", default = 288, min = 160, max = 420, step = 4, format = "%.0f" },
    { key = "castHeight", group = "casts", label = "Custom bar height", type = "number", default = 20, min = 14, max = 36, step = 2, format = "%.0f" },
    { key = "castShowIcon", group = "casts", label = "Spell icon (when public)", type = "bool", default = true },
    { key = "castShowName", group = "casts", label = "Spell name", type = "bool", default = true },
    { key = "castShowTime", group = "casts", label = "Time remaining", type = "bool", default = true },









    { key = "castRestrictedStrip", group = "casts", label = "Draw casts the client will not let us read", type = "bool", default = true },
    { key = "pos.castPlayer", tab = "casts", type = "offset", default = { 0, 0 } },
    { key = "pos.castTarget", tab = "casts", type = "offset", default = { 0, 0 } },
    { key = "pos.castFocus", tab = "casts", type = "offset", default = { 0, 0 } },

















    { key = "actionWash", group = "actions", label = "Bar panel opacity", type = "number", default = 0.42, min = 0, max = 0.9, step = 0.05, format = "%.0f%%", scale = 100 },
    { key = "emptyRecede", group = "actions", label = "Recede empty slots", type = "bool", default = true },
    { key = "iconCrop", group = "actions", label = "Flush icon crop", type = "bool", default = true },














    { key = "actionDiamond", group = "actions", label = "Diamond gamepad buttons", type = "bool", default = true },

















    { key = "actionSocketSkin", group = "actions", label = "Action slot skin", type = "enum",
      default = "authored", values = {
          { value = "authored", label = "Authored socket" },
          { value = "classic", label = "Classic (0.40)" },
      } },



















    { key = "compassLayout", group = "compass", label = "Compass layout", type = "enum",
      default = "live", values = {
          { value = "live", label = "Live (centred)" },
          { value = "classic", label = "Classic (0.43)" },
      } },






























    { key = "compassGround", group = "compass", label = "Under the compass", type = "enum",
      default = "base", values = {


          { value = "divider", label = "Your divider under the cross" },
          { value = "base", label = "Base strip under the cross" },
          { value = "none", label = "Nothing" },
          { value = "rail", label = "Rail under the hero arm (0.48)" },
          { value = "slab", label = "Obsidian slab under each arm (0.44.1)" },
          { value = "frame", label = "Frame (0.44)" },
      } },





    { key = "compassHeroArm", group = "compass", label = "Hero arm (bigger)", type = "enum",
      default = "none", values = {
          { value = "none", label = "None (all one size)" },
          { value = "compassTop", label = "Top arm" },
          { value = "compassLeft", label = "Left arm (LT)" },
          { value = "compassRight", label = "Right arm (RT)" },
          { value = "compassBottom", label = "Bottom arm (thumb)" },
      } },
    { key = "compassHeroSize", tab = "compass", label = "Hero arm size", type = "number",
      default = 1.20, min = 1.05, max = 1.6, step = 0.05, format = "%.2f" },




    { key = "compassEmptyStyle", group = "compass", label = "Empty compass slot", type = "enum",
      default = "faint", values = {
          { value = "faint", label = "Faint socket" },
          { value = "socket", label = "Full socket with pip (0.48)" },
      } },














    { key = "compassButtonSkin", tab = "compass", label = "Compass button skin", type = "enum",
      default = "tiles", values = {
          { value = "tiles", label = "Painted tiles (compass_bg)" },
          { value = "socket", label = "Authored socket (0.49)" },
      } },







    { key = "compassIconShape", tab = "compass", label = "Compass icon shape", type = "enum",
      default = "square", values = {
          { value = "square", label = "Square (matches the keyboard bar)" },
          { value = "diamond", label = "Diamond (tiles turned 45 degrees)" },
      } },



    { key = "compassPromptSeat", tab = "compass", label = "Trigger prompt seat", type = "enum",
      default = "arm", values = {
          { value = "arm", label = "Under its own arm" },
          { value = "shelf", label = "On the shelf's cap (0.44)" },
      } },























    { key = "compassSkin", group = "compass", label = "Compass skin", type = "enum",
      default = "rail", values = {
          { value = "rail", label = "Keyboard-bar family (rail)" },
          { value = "classic", label = "Classic (0.47)" },
      } },



    { key = "compassSlotBrass", group = "compass", label = "Brass lip on every compass slot", type = "bool", default = false },





    { key = "compassRailArms", group = "compass", label = "Rail under", type = "enum",
      default = "hero", values = {
          { value = "hero", label = "Enlarged arms only (hero)" },
          { value = "all", label = "Every arm" },
          { value = "none", label = "No arm (shelf only)" },
      } },










    { key = "compassPreset", group = "compass", label = "Compass preset", type = "enum",
      default = "classic", values = {
          { value = "classic", label = "Classic diamonds (all 1.00, no hero)" },
          { value = "heroTop", label = "Hero top arm" },
          { value = "heroThumb", label = "Hero bottom arm (thumb)" },
          { value = "heroLeft", label = "Hero left arm (LT)" },
          { value = "heroRight", label = "Hero right arm (RT)" },
          { value = "rows", label = "All rows (0.48 rails, 1.25)" },
      },
      apply = function(self, value) self:ApplyCompassPreset(value) end },





    { key = "compassAutoSpread", group = "compass", label = "Widen the compass for big groups", type = "bool", default = true },









    { key = "compassGroundEdge", group = "actions", label = "Lit edge on the frame ground", type = "bool", default = true },







    { key = "actionGlyphs", group = "actions", label = "Controller button glyphs", type = "bool", default = true },




    { key = "clusterTray", group = "actions", label = "Backing tray under icon groups", type = "bool", default = true },







    { key = "compassRhombus", group = "actions", label = "Rhombus outline round the compass", type = "bool", default = false },






    { key = "auraTray", group = "minimap", label = "Even aura tray on both unit frames", type = "bool", default = true },
    { key = "auraTraySlots", group = "minimap", label = "Aura tray width (slots; unused since 0.45.2, the tray fits its icons)", type = "number", default = 8, min = 4, max = 12, step = 1, format = "%.0f" },







    { key = "auraTrayEmpty", group = "minimap", label = "Keep the aura tray when it is empty", type = "bool", default = false },
    { key = "dockScale", group = "actions", label = "Action bar size", type = "number", default = 0.9, min = 0.7, max = 1.2, step = 0.05, format = "%.2f" },







    { key = "actionCamera", group = "actions", label = "Action camera (changes the game camera)", type = "bool", default = false },





























    { key = "keyboardSkin", group = "keyboard", label = "Keyboard bar style", type = "enum",
      default = "authored", values = {









          { value = "base", label = "Bar 04 under the buttons" },
          { value = "bar04", label = "Bar 04 (the buttons set into it)" },
          { value = "bright", label = "Inlay, buttons fully backed" },
          { value = "inlay", label = "Inlay (the row in your painted bar)" },
          { value = "edge", label = "Edge (tiles over your painted bar)" },
          { value = "footer", label = "Footer (tiles over the painted rail)" },
          { value = "bare", label = "Bare (tiles alone)" },
          { value = "slab02", label = "Slab 02 (painted, 0.50)" },
          { value = "authored", label = "Carved bar (0.45)" },
          { value = "classic", label = "Classic (0.44)" },
      } },
















    { key = "keyboardBackdrop", label = "Backdrop behind the bar", type = "enum",
      default = "shelf", values = {

          { value = "fade", label = "Black fade (behind the bar and the menu row)" },
          { value = "shelf", label = "Shelf (behind the buttons)" },
          { value = "hearth", label = "Hearth (the whole stack)" },
          { value = "off", label = "None (0.51)" },
      } },
    { key = "keyboardMastHead", group = "keyboard", label = "Mast head", type = "enum",
      default = "both", values = {
          { value = "both", label = "Both ends" },
          { value = "left", label = "Left end only" },
          { value = "none", label = "Neither (plain caps)" },
      } },

















    { key = "keyboardCentre", group = "keyboard", label = "Centre the action bar", type = "bool", default = true },






    { key = "keyboardMicroRow", group = "keyboard", label = "Bags and menu", type = "enum",
      default = "above", values = {
          { value = "above", label = "Small row above the bars" },
          { value = "row", label = "Beside the action bar" },
      } },




    { key = "keyboardMicroSkin", label = "Skin the menu buttons", type = "bool", default = true },
    { key = "keyboardMicroScale", group = "keyboard", label = "Bags and menu size", type = "number",
      default = 0.75, min = 0.5, max = 1, step = 0.05, format = "%.2f" },








    { key = "keyboardSlotSkin", group = "keyboard", label = "Slot style", type = "enum",
      default = "facet", values = {
          { value = "tile", label = "Painted tile" },
          { value = "facet", label = "Square facet (0.45)" },
          { value = "classic", label = "Blizzard's icon frame" },
      } },





    { key = "keyboardSlotBrass", group = "keyboard", label = "Brass lip on every slot", type = "bool", default = false },



    { key = "keyboardSlotInset", group = "keyboard", label = "Bezel width", type = "enum",
      default = "0.125", values = {
          { value = "0.125", label = "Standard" },
          { value = "0.089", label = "Thin (more icon)" },
      } },








    { key = "keyboardHotkeyAbbrev", group = "keyboard", label = "Abbreviate keybind labels", type = "bool", default = true },



    { key = "keyboardStatusLane", group = "keyboard", label = "Experience bar in the same slab", type = "bool", default = true },




    { key = "keyboardMicroSlab", group = "keyboard", label = "Slab behind the micro menu and bags", type = "bool", default = true },







    { key = "keyboardEmptyHotkey", label = "Keybind on an empty slot", type = "enum",
      default = "faint", values = {
          { value = "faint", label = "Faint" },
          { value = "full", label = "Full (0.50)" },
          { value = "none", label = "Hidden" },
      } },
    { key = "keyboardEmptyStyle", group = "keyboard", label = "Empty slot", type = "enum",
      default = "faint", values = {
          { value = "faint", label = "Faint socket" },
          { value = "socket", label = "Full socket with pip (0.45)" },
      } },





    { key = "keyboardLift", group = "keyboard", label = "Lift the bar clear of the screen edge", type = "bool", default = true },

    { key = "minimapScale", group = "minimap", label = "Minimap scale", type = "number", default = 1, min = 0.7, max = 1.3, step = 0.05, format = "%.2f" },
    { key = "minimapCoords", group = "minimap", label = "Show coordinates", type = "bool", default = true },
    { key = "minimapZone", group = "minimap", label = "Show zone name", type = "bool", default = true },



    { key = "chromeSkin", group = "minimap", label = "Map and window chrome", type = "enum",
      default = "authored", values = {
          { value = "authored", label = "Authored (0.46)" },
          { value = "classic", label = "Classic (0.45)" },
      } },




    { key = "chromeCrest", group = "minimap", label = "Crest", type = "enum",
      default = "windows", values = {
          { value = "both", label = "Map and windows" },
          { value = "map", label = "Map only" },
          { value = "windows", label = "Windows only" },
          { value = "off", label = "Off" },
      } },
    { key = "chromeTrackerHead", group = "minimap", label = "Objectives header like the zone strip", type = "bool", default = true },

    { key = "trackerAlpha", group = "panels", label = "Objectives backing", type = "number", default = 0.6, min = 0, max = 0.95, step = 0.05, format = "%.0f%%", scale = 100 },
    { key = "chatAlpha", group = "panels", label = "Chat backing", type = "number", default = 0.6, min = 0, max = 0.95, step = 0.05, format = "%.0f%%", scale = 100 },


    { key = "chromeChat", group = "panels", label = "Chat input and tabs like the map", type = "bool", default = true },













    { key = "mapSkin", label = "Map card", type = "enum", default = "painted", values = {





          { value = "base", label = "Base (the map standing on your minimal panel)" },
          { value = "plaque", label = "Plaque (the map on your minimal panel)" },
          { value = "foot", label = "Foot (your minimal panel under the map)" },
          { value = "painted", label = "Painted (your map panel)" },
          { value = "card", label = "Card (0.46-0.52)" },
      } },
    { key = "windowSkin", label = "Settings window", type = "enum", default = "painted", values = {

          { value = "ledge", label = "Flat, bar 04 as its foot" },
          { value = "painted", label = "Painted (your options panel)" },
          { value = "flat", label = "Flat (0.47-0.52)" },
      } },
    { key = "trackerStyle", label = "Objectives", type = "enum", default = "tidy", values = {
          { value = "tidy", label = "Tidy (no header boxes)" },
          { value = "bare", label = "Bare (no backing)" },
          { value = "boxed", label = "Boxed headers (0.52)" },
      } },
    { key = "chatStyle", label = "Chat", type = "enum", default = "tidy", values = {
          { value = "tidy", label = "Tidy (input only while typing)" },
          { value = "bare", label = "Bare (no backing)" },
          { value = "boxed", label = "Boxed (0.52)" },
      } },






    { key = "plateSmallSkin", label = "Small plates", type = "enum", default = "inlay", values = {
          { value = "tile", label = "Raid tile" },
          { value = "inlay", label = "The plate painting (0.52)" },
      } },
    { key = "raidSkin", label = "Raid frames", type = "enum", default = "tile", values = {
          { value = "tile", label = "Raid tile" },
          { value = "native", label = "Blizzard's own" },
      } },





    { key = "accentRule", group = "panels", label = "Accent rule on the right column", type = "bool", default = false },










    { key = "playerRule", group = "plus", label = "Colour marker on your plate and your target's", type = "bool", default = true },







































    { key = "plusSigil", group = "gauges", label = "Sigil badge on the unit plates", type = "bool", default = true },
    { key = "plusStud", group = "gauges", label = "End stud on the unit plates", type = "bool", default = true },
    { key = "plusAccentMark", group = "gauges", label = "Accent mark on the unit plates", type = "bool", default = true },
    { key = "plusKeyline", group = "gauges", label = "Brass rules and edges on the unit plates", type = "bool", default = true },
    { key = "plusRim", group = "gauges", label = "Crisp outline on the plate planes", type = "bool", default = true },
    { key = "plusGlow", group = "gauges", label = "Lit edges on the stud and the gauges", type = "bool", default = true },
    { key = "plusFlash", group = "gauges", label = "Edge flash on state changes", type = "bool", default = true },
    { key = "plusCorner", group = "gauges", label = "Second 45-degree cut on the plates", type = "bool", default = true },













    { key = "plusUnified", group = "gauges", label = "Plates read as one object", type = "bool", default = true },



    { key = "plusTotPlacement", group = "plusparty", label = "Target-of-target placement", type = "enum", default = "below", values = choice("below", "Under the target", "side", "Beside the target") },





    { key = "plusDesign", type = "number", default = 7, min = 0, max = 100, step = 1, format = "%.0f" },

    { key = "pos.winSettings", type = "offset", default = { 0, 0 } },
    { key = "pos.winOptions", type = "offset", default = { 0, 0 } },
    { key = "pos.winLayout", type = "offset", default = { 0, 0 } },
    { key = "pos.winModules", type = "offset", default = { 0, 0 } },
    { key = "pos.winColorPicker", type = "offset", default = { 0, 0 } },
    { key = "pos.winWelcome", type = "offset", default = { 0, 0 } },

    { key = "pos.winReport", type = "offset", default = { 0, 0 } },
    { key = "enabled", type = "bool", default = true },




    { key = "setupDone", type = "bool", default = false },
    { key = "layout", type = "bool", default = true },
    { key = "dock", type = "enum", default = "right", values = choice("right", "Right", "left", "Left", "custom", "Custom") },
    { key = "x", type = "number", default = 360, min = -1000, max = 1000 },
    { key = "y", type = "number", default = 190, min = 40, max = 700 },
    { key = "layoutX", type = "number", default = 0, min = -300, max = 300 },
    { key = "layoutY", type = "number", default = 0, min = -150, max = 300 },









    { key = "optionsLayout", type = "enum", default = "sections", values = choice("sections", "Six sections", "tabs", "Nineteen tabs (0.46)") },
    { key = "optionsAdvanced", type = "bool", default = false },
}
for _, name in ipairs({ "actions", "units", "party", "auras", "minimap", "objectives", "chat", "tooltips" }) do
    A.options[#A.options + 1] = { key = "skins." .. name, type = "bool", default = true }
end








A.compassGroupLabels = {
    topL = "Up arm, d-pad", topR = "Up arm, face buttons",
    leftL = "Left arm, d-pad", leftR = "Left arm, face buttons",
    rightL = "Right arm, d-pad", rightR = "Right arm, face buttons",
    bottomL = "Down arm, d-pad", bottomR = "Down arm, face buttons",
}
A.compassGroupOrder = { "topL", "topR", "leftL", "leftR", "rightL", "rightR", "bottomL", "bottomR" }


A.compassHeroDefaults = { bottomL = 1.35, bottomR = 1.35 }
for _, id in ipairs(A.compassGroupOrder) do
    A.options[#A.options + 1] = { key = "compassGroupSize." .. id, tab = "compass",
        label = "Size: " .. A.compassGroupLabels[id], type = "number",
        default = 1.0, min = 0.8, max = 1.6, step = 0.05, format = "%.2f" }
end

A.options[#A.options + 1] = { key = "compassHeroSeeded", type = "bool", default = false }

A.options[#A.options + 1] = { key = "compassV3Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "barsV4Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "barsV5Settled", type = "bool", default = false }







A.options[#A.options + 1] = { key = "compassDividerLight", label = "Held trigger lights the divider", type = "bool",
    default = true }
A.options[#A.options + 1] = { key = "xpLane", label = "Experience bar", type = "enum", default = "blizzard",
    values = {
        { value = "blizzard", label = "Blizzard's own, where Edit Mode puts it" },
        { value = "inlay", label = "Inside the painted bar (pass 7)" },
    } }















A.options[#A.options + 1] = { key = "compassBumperSkin", label = "Bumper chips", type = "enum", default = "plaque",
    values = {
        { value = "arm", label = "Your rb+lb plaque on its arm" },
        { value = "plaque", label = "Your rb+lb plaque (0.56)" },
        { value = "native", label = "Blizzard's own (0.54)" },
    } }
A.options[#A.options + 1] = { key = "compassBumperGlow", label = "Bumper plaque glows while held", type = "bool", default = true }
A.options[#A.options + 1] = { key = "recolourMarks", label = "Brass follows the theme", type = "enum", default = "matched",
    values = {
        { value = "matched", label = "In the theme's colour, at brass brightness" },
        { value = "accent", label = "The theme's accent (0.54)" },
    } }
A.options[#A.options + 1] = { key = "artMaterial", label = "Painted art follows the colour scheme", type = "enum", default = "scheme",
    values = {
        { value = "scheme", label = "Yes (default)" },
        { value = "painted", label = "No, keep the art as painted" },
    } }



A.options[#A.options + 1] = { key = "artGlaze", label = "Painted art: colour glaze", type = "number", default = 0.6,
    min = 0, max = 1, step = 0.1, format = "%.0f%%", scale = 100 }

A.options[#A.options + 1] = { key = "themeFollowSettled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "pass7Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "pass9Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "barsV6Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "chromeV2Settled", type = "bool", default = false }

A.options[#A.options + 1] = { key = "crestMapSettled", type = "bool", default = false }









A.options[#A.options + 1] = { key = "autoSwitchInput", label = "Gamepad Mode reminder", type = "enum",
    default = "ask", values = {
        { value = "ask", label = "Remind me" },
        { value = "off", label = "Never" },
    } }
A.options[#A.options + 1] = { key = "firstRunDefaults", type = "bool", default = false }
A.options[#A.options + 1] = { key = "optionsChangedOnly", type = "bool", default = false }
A.options[#A.options + 1] = { key = "optionsAdvancedSeen", type = "bool", default = false }

A.optionIndex = {}
for _, option in ipairs(A.options) do A.optionIndex[option.key] = option end


local function finite(v) return type(v) == "number" and v == v and v > -math.huge and v < math.huge end

local function copyColor(c) return { c[1], c[2], c[3], c[4] } end


function A:ValidateOption(option, value)
    local kind = option.type
    if kind == "bool" then
        if type(value) == "boolean" then return value end
    elseif kind == "number" then
        if finite(value) then return math.max(option.min or -math.huge, math.min(option.max or math.huge, value)) end
    elseif kind == "enum" then
        for _, entry in ipairs(option.values) do if entry.value == value then return value end end
    elseif kind == "color" then
        if type(value) == "table" then
            local out = {}
            for i = 1, 4 do
                local channel = value[i]
                if i == 4 and channel == nil then channel = option.default[4] end
                if not finite(channel) then return nil end
                out[i] = math.max(0, math.min(1, channel))
            end
            return out
        end
    elseif kind == "text" then
        if type(value) == "string" and #value <= (option.max or 256) then return value end
    elseif kind == "offset" then
        if type(value) == "table" and finite(value[1]) and finite(value[2]) then
            return { math.max(-3000, math.min(3000, value[1])), math.max(-3000, math.min(3000, value[2])) }
        end
    end
    return nil
end

local function getRaw(profile, key)
    local skin = key:match("^skins%.(.+)$")
    if skin then
        if type(profile.skins) ~= "table" then return nil end
        return profile.skins[skin]
    end
    return profile[key]
end









local function sameValue(a, b)
    if type(a) == "table" and type(b) == "table" then
        for i = 1, math.max(#a, #b) do
            if type(a[i] or 0) ~= "number" or type(b[i] or 0) ~= "number" then return false end
            if math.abs((a[i] or 0) - (b[i] or 0)) > 1e-9 then return false end
        end
        return true
    end
    if type(a) == "number" and type(b) == "number" then return math.abs(a - b) <= 1e-9 end
    return a == b
end

local function sparseDefault(key, value)
    local option = A.optionIndex and A.optionIndex[key]
    if not (option and option.sparse) then return false end
    return value == nil or sameValue(value, option.default)
end

local function setRaw(profile, key, value)
    if sparseDefault(key, value) then value = nil end
    local skin = key:match("^skins%.(.+)$")
    if skin then
        if type(profile.skins) ~= "table" then profile.skins = {} end
        profile.skins[skin] = value
    else
        profile[key] = value
    end
end








A.shippedDefaults = {
    plateSkin = "inlay", keyboardSkin = "base", keyboardSlotSkin = "tile", keyboardMicroSlab = false,
    keyboardBackdrop = "fade", xpLane = "inlay", mapSkin = "base", windowSkin = "ledge", compassGround = "divider",
    compassBumperSkin = "arm",
}
function A:ResetValue(option)
    local shipped = self.shippedDefaults[option.key]
    if shipped ~= nil then return shipped end

    if option.key == "scale" and self.db and self.db.layout ~= false then return 0.85 end
    return self:DefaultFor(option)
end

function A:DefaultFor(option)
    if option.type == "color" then return copyColor(option.default) end
    if option.type == "offset" then return { option.default[1], option.default[2] } end
    return option.default
end


function A:StoreRaw(profile, key, value) setRaw(profile, key, value) end
function A:IsSparseDefault(key, value) return sparseDefault(key, value) end

function A:GetOption(key)
    local option = self.optionIndex[key]
    local value = option and getRaw(self.db, key)
    local valid = option and self:ValidateOption(option, value)
    if valid == nil and option then return self:DefaultFor(option) end
    return valid
end




function A:SetOption(key, value, quiet)
    local option = self.optionIndex[key]
    if not option then return false, "unknown option" end
    local valid = self:ValidateOption(option, value)
    if valid == nil then return false, "invalid value" end



    if type(option.accept) == "function" then
        local ok, why = option.accept(self, valid)
        if not ok then return false, why or "refused" end
    end
    setRaw(self.db, key, valid)



    if type(option.apply) == "function" then option.apply(self, valid) end
    if not quiet then self:OptionsApplied() end
    return true
end



function A:QueueOptionsApplied()
    self.pendingOptionsApplied = true
end

function A:OptionsApplied()
    self.dirty, self.nativeDirty, self.layoutDirty = true, true, true
    self.plusFailed = nil
    self:Changed()
end











local ACTION_BAR_ROWS = { "pos.actionBar1", "pos.actionBar2", "pos.actionBar3" }


A.legacyOptions = {
    ["pos.actionBars"] = { key = "pos.actionBars", type = "offset", default = { 0, 0 } },
}
function A:MigrateActionBars(profile)
    local old = profile["pos.actionBars"]
    if type(old) ~= "table" or (old[1] == 0 and old[2] == 0) then
        profile["pos.actionBars"] = nil
        return false
    end
    for _, key in ipairs(ACTION_BAR_ROWS) do
        local current = profile[key]
        if type(current) ~= "table" or (current[1] == 0 and current[2] == 0) then
            profile[key] = { old[1], old[2] }
        end
    end
    profile["pos.actionBars"] = nil
    return true
end








function A:SeedCompassHero(profile)
    if profile.compassHeroSeeded == true then return false end
    profile.compassHeroSeeded = true
    if profile.compassPreset ~= "classic" then return false end
    for _, id in ipairs(A.compassGroupOrder or {}) do
        if profile["compassGroupSize." .. id] ~= 1 then return false end
    end
    profile.compassPreset = "heroThumb"
    for _, id in ipairs(A.compassGroupOrder or {}) do
        profile["compassGroupSize." .. id] = A.compassHeroDefaults[id] or 0.90
    end
    return true
end











function A:SettleCompassV3(profile)
    if profile.compassV3Settled == true then return false end
    profile.compassV3Settled = true
    local notes = {}
    if profile.compassPreset == "heroThumb" then
        local seeded = true
        for _, id in ipairs(A.compassGroupOrder or {}) do
            local want = A.compassHeroDefaults[id] or 0.90
            if math.abs((tonumber(profile["compassGroupSize." .. id]) or 1) - want) > 0.0005 then
                seeded = false
            end
        end
        if seeded then
            profile.compassPreset = "classic"
            for _, id in ipairs(A.compassGroupOrder or {}) do profile["compassGroupSize." .. id] = 1 end
            notes[#notes + 1] = "compass: the 0.48.1 hero-thumb sizes are back to one size; "
                .. "pick a hero arm under Compass if you want one bigger"
        end
    end
    if profile.compassGround == "slab" or profile.compassGround == nil then
        profile.compassGround = "base"
        notes[#notes + 1] = "compass: the base strip is under the cross now (Compass > Under the compass)"
    end
    if #notes > 0 then
        self.pendingNotes = self.pendingNotes or {}
        for _, note in ipairs(notes) do self.pendingNotes[#self.pendingNotes + 1] = note end
    end
    return #notes > 0
end










A.plateStyleSettle = {
    { key = "plateSkin", from = "bar", to = "plate02",
      note = "unit plates: the new painted plate is on (Look > Plate styles to change it)" },
    { key = "keyboardSkin", from = "authored", to = "slab02",
      note = "keyboard bars: the new painted slab is on (Look > Plate styles)" },
    { key = "keyboardSlotSkin", from = "facet", to = "tile",
      note = "keyboard slots: the painted button tiles are on (Look > Plate styles)" },
}
function A:SettlePlateStyles(profile)
    if profile.plateStylesSettled == true then return false end
    profile.plateStylesSettled = true
    local notes = {}
    for _, step in ipairs(self.plateStyleSettle) do
        local have = profile[step.key]
        if have == nil or have == step.from then
            profile[step.key] = step.to
            notes[#notes + 1] = step.note
        end
    end
    if #notes > 0 then
        self.pendingNotes = self.pendingNotes or {}
        for _, note in ipairs(notes) do self.pendingNotes[#self.pendingNotes + 1] = note end
    end
    return #notes > 0
end













A.barsV4Settle = {
    { key = "plateSkin", from = { plate02 = true }, to = "mantle",
      note = "unit plates: the new mantle is on -- the health bar stands on your painting. "
          .. "Back to 0.50: /aui set plateSkin plate02 (Look > Plate styles)" },
    { key = "keyboardSkin", from = { slab02 = true }, to = "footer",
      note = "keyboard bar: the new footer rail is on, the tiles float over it. "
          .. "Back to 0.50: /aui set keyboardSkin slab02 and /aui set keyboardMicroSlab on (Look > Plate styles)" },
}
function A:SettleBarsV4(profile)
    if profile.barsV4Settled == true then return false end
    profile.barsV4Settled = true
    local notes, moved = {}, {}
    for _, step in ipairs(self.barsV4Settle) do
        local have = profile[step.key]
        if have == nil or step.from[have] then
            profile[step.key] = step.to
            notes[#notes + 1] = step.note
            moved[step.key] = have or "default"
        end
    end
    if moved.keyboardSkin and (profile.keyboardMicroSlab == nil or profile.keyboardMicroSlab == true) then
        profile.keyboardMicroSlab = false
    end

    self.barsV4Moved = moved
    if #notes > 0 then
        self.pendingNotes = self.pendingNotes or {}

        local drop = {}
        for _, step in ipairs(self.plateStyleSettle or {}) do
            if moved[step.key] then drop[step.note] = true end
        end
        local kept = {}
        for _, note in ipairs(self.pendingNotes) do
            if not drop[note] then kept[#kept + 1] = note end
        end
        self.pendingNotes = kept
        for _, note in ipairs(notes) do self.pendingNotes[#self.pendingNotes + 1] = note end
    end
    return #notes > 0
end










A.barsV5Back = "Back to 0.51: /aui set plateSkin mantle and /aui set keyboardBackdrop off"
A.barsV5Settle = {
    { key = "plateSkin", from = { mantle = true }, to = "inlay",
      note = "unit plates: the inlay is on -- the health and mana bars are your painting now, the cast "
          .. "runs in its seam, and the keyboard bar stands on a shelf. " .. A.barsV5Back
          .. " (Look > Plate styles)" },
}
function A:SettleBarsV5(profile)
    if profile.barsV5Settled == true then return false end
    profile.barsV5Settled = true
    local notes, moved = {}, {}
    for _, step in ipairs(self.barsV5Settle) do
        local have = profile[step.key]
        if have == nil or step.from[have] then
            profile[step.key] = step.to
            notes[#notes + 1] = step.note
            moved[step.key] = have or "default"
        end
    end
    self.barsV5Moved = moved
    if #notes > 0 then
        self.pendingNotes = self.pendingNotes or {}
        local drop = {}
        for _, step in ipairs(self.barsV4Settle or {}) do
            if moved[step.key] then drop[step.note] = true end
        end
        for _, step in ipairs(self.plateStyleSettle or {}) do
            if moved[step.key] then drop[step.note] = true end
        end
        local kept = {}
        for _, note in ipairs(self.pendingNotes) do
            if not drop[note] then kept[#kept + 1] = note end
        end
        self.pendingNotes = kept
        for _, note in ipairs(notes) do self.pendingNotes[#self.pendingNotes + 1] = note end
    end
    return #notes > 0
end











A.barsV6Back = "Back to 0.52: /aui set keyboardSkin footer and /aui set compassGround base"
A.barsV6Settle = {
    { key = "keyboardSkin", from = { footer = true },
      note = "your new action bar is on with the buttons inside it (tiles over it instead: /aui set keyboardSkin edge)",
      to = "inlay" },
    { key = "compassGround", from = { base = true },
      note = "your compass divider is under the cross (nothing there: /aui set compassGround none)",
      to = "divider" },
}
function A:SettleBarsV6(profile)
    if profile.barsV6Settled == true then return false end
    profile.barsV6Settled = true
    local parts, moved = {}, {}
    for _, step in ipairs(self.barsV6Settle) do
        local have = profile[step.key]
        if have == nil or step.from[have] then
            profile[step.key] = step.to
            parts[#parts + 1] = step.note
            moved[step.key] = have or "default"
        end
    end
    self.barsV6Moved = moved
    if #parts == 0 then return false end
    self.pendingNotes = self.pendingNotes or {}
    local drop = {}
    for _, list in ipairs({ self.barsV5Settle or {}, self.barsV4Settle or {}, self.plateStyleSettle or {} }) do
        for _, step in ipairs(list) do
            if moved[step.key] then drop[step.note] = true end
        end
    end
    if moved.compassGround then
        drop["compass: the base strip is under the cross now (Compass > Under the compass)"] = true
    end
    local kept = {}
    for _, note in ipairs(self.pendingNotes) do
        if not drop[note] then kept[#kept + 1] = note end
    end
    self.pendingNotes = kept
    self.pendingNotes[#self.pendingNotes + 1] = "bars v6: " .. table.concat(parts, "; ") .. ". "
        .. A.barsV6Back .. " (Look > Plate styles)"
    return true
end





function A:XpLaneMode()
    if not (self.db and self.optionIndex and self.optionIndex.xpLane) then return "blizzard" end
    if self:GetOption("xpLane") ~= "inlay" then return "blizzard" end
    if self.XpLaneHost and self:XpLaneHost() then return "inlay" end
    return "blizzard"
end










A.pass7Back = "Back to 0.54: /aui set pass7 back"
A.pass7Settle = {
    { key = "keyboardSkin", from = { inlay = true }, to = "bar04" },
    { key = "keyboardBackdrop", from = { shelf = true }, to = "fade" },
    { key = "xpLane", from = { blizzard = true }, to = "inlay" },
    { key = "mapSkin", from = { painted = true }, to = "plaque" },
    { key = "windowSkin", from = { painted = true }, to = "ledge" },
}

A.pass7Values = {
    back = { keyboardSkin = "inlay", keyboardBackdrop = "shelf", xpLane = "blizzard", mapSkin = "painted",
             windowSkin = "painted", compassBumperSkin = "native", recolourMarks = "accent" },
    on = { keyboardSkin = "bar04", keyboardBackdrop = "fade", xpLane = "inlay", mapSkin = "plaque",
           windowSkin = "ledge", compassBumperSkin = "plaque", recolourMarks = "matched" },
}
A.pass7Note = "pass 7: your action bar 04 holds the buttons over a black fade with your XP inside it, your "
    .. "rb+lb plaques sit behind the bumper chips, the map sits on your minimal panel and the Settings window "
    .. "stands on bar 04; brass follows the theme. Your 0.54 bar with brighter buttons instead: /aui set "
    .. "keyboardSkin bright. The panel under the map: /aui set mapSkin foot. " .. A.pass7Back
function A:SettlePass7(profile)
    if profile.pass7Settled == true then return false end
    profile.pass7Settled = true
    local moved = {}
    local any = false
    for _, step in ipairs(self.pass7Settle) do
        local have = profile[step.key]
        if have == nil or step.from[have] then
            profile[step.key] = step.to
            moved[step.key] = have or "default"
            any = true
        end
    end
    self.pass7Moved = moved
    if not any then return false end
    self.pendingNotes = self.pendingNotes or {}
    self.pendingNotes[#self.pendingNotes + 1] = A.pass7Note
    return true
end







A.pass9Back = "Back to 0.56: /aui set pass9 back"
A.pass9Settle = {
    { key = "keyboardSkin", from = { bar04 = true }, to = "base" },
    { key = "mapSkin", from = { plaque = true }, to = "base" },
    { key = "compassBumperSkin", from = { plaque = true }, to = "arm" },
}
A.pass9Values = {
    back = { keyboardSkin = "bar04", mapSkin = "plaque", compassBumperSkin = "plaque" },
    on = { keyboardSkin = "base", mapSkin = "base", compassBumperSkin = "arm" },
}
A.pass9Note = "pass 9: your bar 04 is under the buttons now, the map stands on its panel with the text set in "
    .. "and the clock beside the coordinates, and the bumper plaques sit on their arms without the red and "
    .. "green marks. " .. A.pass9Back
function A:SettlePass9(profile)
    if profile.pass9Settled == true then return false end
    profile.pass9Settled = true
    local moved, any = {}, false
    for _, step in ipairs(self.pass9Settle) do
        local have = profile[step.key]
        if have == nil or step.from[have] then
            profile[step.key], moved[step.key], any = step.to, have or "default", true
        end
    end
    self.pass9Moved = moved
    if not any then return false end
    self.pendingNotes = self.pendingNotes or {}
    self.pendingNotes[#self.pendingNotes + 1] = A.pass9Note
    return true
end







A.themeFollowNote = "Your painted art now follows your colour scheme (back: /aui set artMaterial painted)"
function A:SettleThemeFollow(profile)
    if profile.themeFollowSettled == true then return false end
    profile.themeFollowSettled = true
    local have = profile.artMaterial
    if have ~= nil and have ~= "painted" then return false end
    profile.artMaterial = "scheme"
    self.themeFollowMoved = have or "default"
    self.pendingNotes = self.pendingNotes or {}
    self.pendingNotes[#self.pendingNotes + 1] = A.themeFollowNote
    return true
end

function A:Pass7Line()
    if not (self.db and self.optionIndex) then return "pass 7: no profile" end
    return string.format("pass 7: keyboard %s (wearing %s) | backdrop %s | xp %s (live %s) | bumpers %s | map %s | "
        .. "window %s | marks %s | stone %s | settled %s",
        tostring(self:GetOption("keyboardSkin")), tostring(self.KeyboardSkin and self:KeyboardSkin() or "?"),
        tostring(self:GetOption("keyboardBackdrop")), tostring(self:GetOption("xpLane")), self:XpLaneMode(),
        tostring(self:GetOption("compassBumperSkin")), tostring(self:GetOption("mapSkin")),
        tostring(self:GetOption("windowSkin")), tostring(self:GetOption("recolourMarks")),
        tostring(self:GetOption("artMaterial")), tostring(self:GetOption("pass7Settled")))
end

function A:BarsV6Line()
    if not (self.db and self.optionIndex) then return "bars v6: no profile" end
    local moved = self.barsV6Moved or {}
    local parts = {}
    for key, from in pairs(moved) do parts[#parts + 1] = key .. " from " .. tostring(from) end
    table.sort(parts)
    return string.format("bars v6: keyboard %s (wearing %s) | compass ground %s (wearing %s) | xp %s | settled %s%s",
        tostring(self:GetOption("keyboardSkin")), tostring(self.KeyboardSkin and self:KeyboardSkin() or "?"),
        tostring(self:GetOption("compassGround")), tostring(self.CompassGroundMode and self:CompassGroundMode() or "?"),
        tostring(self:GetOption("xpLane")) .. " (live: " .. self:XpLaneMode() .. ")", tostring(self:GetOption("barsV6Settled")),
        #parts > 0 and (" this login (" .. table.concat(parts, ", ") .. "; " .. A.barsV6Back .. ")") or "")
end










A.chromeV2Back = "Back to 0.52: /aui set mapSkin card, windowSkin flat, trackerStyle boxed, "
    .. "chatStyle boxed, raidSkin native"
A.chromeV2Note = "chrome v2: your map and options panels are the map card and the Settings window, the "
    .. "chat input shows only while you type, the objectives lost their header boxes, and the raid frames "
    .. "wear your raid tile. " .. A.chromeV2Back .. ". To try the raid tile on the small plates too: "
    .. "/aui set plateSmallSkin tile"
function A:SettleChromeV2(profile)
    if profile.chromeV2Settled == true then return false end
    profile.chromeV2Settled = true
    local fresh = true
    for _, key in ipairs({ "mapSkin", "windowSkin", "trackerStyle", "chatStyle", "plateSmallSkin", "raidSkin" }) do
        if profile[key] ~= nil then fresh = false end
    end
    self.chromeV2Moved = fresh
    if fresh then
        self.pendingNotes = self.pendingNotes or {}
        self.pendingNotes[#self.pendingNotes + 1] = A.chromeV2Note
    end
    return fresh
end





A.crestMapMove = { both = "windows", map = "off" }
function A:SettleCrestMap(profile)
    if profile.crestMapSettled == true then return false end
    profile.crestMapSettled = true
    local to = A.crestMapMove[profile.chromeCrest]
    if not to then return false end
    local from = profile.chromeCrest
    profile.chromeCrest = to
    self.crestMapNote = "the crest is off the minimap (back: /aui set chromeCrest " .. from .. ")"
    self.pendingNotes = self.pendingNotes or {}
    self.pendingNotes[#self.pendingNotes + 1] = self.crestMapNote
    return true
end

function A:ChromeV2Line()
    if not (self.db and self.optionIndex) then return "chrome v2: no profile" end


    local cap = self.mapCardCap
    local cover = cap and string.format(" | map card scaled %.2f -> %.2f so it clears the objectives "
        .. "(your minimapScale is unchanged)", cap.asked, cap.got) or ""
    return string.format("chrome v2: map %s | window %s | objectives %s | chat %s | small plates %s | raid %s | settled %s%s%s",
        tostring(self:GetOption("mapSkin")), tostring(self:GetOption("windowSkin")),
        tostring(self:GetOption("trackerStyle")), tostring(self:GetOption("chatStyle")),
        tostring(self:GetOption("plateSmallSkin")), tostring(self:GetOption("raidSkin")),
        tostring(self:GetOption("chromeV2Settled")),
        self.chromeV2Moved and (" this login (" .. A.chromeV2Back .. ")") or "", cover)
end





function A:SetCommand(message)
    local key, value = string.match(message or "", "^%s*%S+%s+(%S+)%s+(%S+)")

    if key and key:lower() == "pass7" and value and self.pass7Values[value:lower()] then
        if self:IsCombat() then
            self:Print("Out of combat, please: pass 7 was not changed.")
            return false
        end
        local set = self.pass7Values[value:lower()]
        local names = {}
        for name in pairs(set) do names[#names + 1] = name end
        table.sort(names)
        for _, name in ipairs(names) do self:SetOption(name, set[name]) end
        self:Print("pass 7 " .. value:lower() .. ": " .. table.concat(names, ", "))
        return true
    end

    if key and key:lower() == "pass9" and value and self.pass9Values[value:lower()] then
        if self:IsCombat() then
            self:Print("Out of combat, please: pass 9 was not changed.")
            return false
        end
        local set = self.pass9Values[value:lower()]
        local names = {}
        for name in pairs(set) do names[#names + 1] = name end
        table.sort(names)
        for _, name in ipairs(names) do self:SetOption(name, set[name]) end
        self:Print("pass 9 " .. value:lower() .. ": " .. table.concat(names, ", "))
        return true
    end
    local option = key and self.optionIndex[key]
    if not option then

        for name, candidate in pairs(self.optionIndex) do
            if key and name:lower() == key:lower() then option, key = candidate, name end
        end
    end
    if not option or value == nil then
        self:Print("usage: /aui set KEY VALUE, e.g. /aui set plateSkin plate02")
        return false
    end
    local v = value
    if option.type == "bool" then
        local lower = value:lower()
        if lower == "on" or lower == "true" or lower == "1" then v = true
        elseif lower == "off" or lower == "false" or lower == "0" then v = false
        else v = nil end
    elseif option.type == "number" then
        v = tonumber(value)
    elseif option.type ~= "enum" then
        self:Print(key .. " is not set from chat; use /aui settings")
        return false
    end
    if self:IsCombat() then
        self:Print("Out of combat, please: " .. key .. " was not changed.")
        return false
    end
    local ok = v ~= nil and self:SetOption(key, v)
    if not ok then
        local allowed = {}
        for _, entry in ipairs(option.values or {}) do allowed[#allowed + 1] = tostring(entry.value) end
        self:Print(key .. ": " .. tostring(value) .. " is not a value it takes"
            .. (#allowed > 0 and (" (" .. table.concat(allowed, ", ") .. ")") or ""))
        return false
    end
    self:Print(key .. " = " .. tostring(self:GetOption(key)))
    return true
end



function A:BarsV5Line()
    if not (self.db and self.optionIndex) then return "bars v5: no profile" end
    local moved = self.barsV5Moved or {}
    local parts = {}
    for key, from in pairs(moved) do parts[#parts + 1] = key .. " from " .. tostring(from) end
    table.sort(parts)
    return string.format("bars v5: plate %s (wearing %s) | backdrop %s | settled %s%s",
        tostring(self:GetOption("plateSkin")), tostring(self.PlateSkin and self:PlateSkin() or "?"),
        tostring(self:GetOption("keyboardBackdrop")), tostring(self:GetOption("barsV5Settled")),
        #parts > 0 and (" this login (" .. table.concat(parts, ", ") .. "; " .. A.barsV5Back .. ")") or "")
end

function A:BarsV4Line()
    if not (self.db and self.optionIndex) then return "bars v4: no profile" end
    local moved = self.barsV4Moved or {}
    local parts = {}
    for key, from in pairs(moved) do parts[#parts + 1] = key .. " from " .. tostring(from) end
    table.sort(parts)
    return string.format("bars v4: plate %s (wearing %s) | keyboard %s | settled %s%s",
        tostring(self:GetOption("plateSkin")), tostring(self.PlateSkin and self:PlateSkin() or "?"),
        tostring(self:GetOption("keyboardSkin")),
        tostring(self:GetOption("barsV4Settled")),
        #parts > 0 and (" this login (" .. table.concat(parts, ", ") .. "; back: /aui set plateSkin plate02, "
            .. "/aui set keyboardSkin slab02)") or "")
end

function A:NormalizeProfile(profile)





    local fresh = self.freshProfiles and self.freshProfiles[profile] or false
    local heard = self.pendingNotes and #self.pendingNotes or 0
    self:MigrateActionBars(profile)
    self:SeedCompassHero(profile)
    self:SettleCompassV3(profile)
    self:SettlePlateStyles(profile)
    self:SettleBarsV4(profile)
    self:SettleBarsV5(profile)
    self:SettleBarsV6(profile)
    self:SettleChromeV2(profile)
    self:SettleCrestMap(profile)
    self:SettlePass7(profile)
    self:SettlePass9(profile)
    self:SettleThemeFollow(profile)
    if fresh and self.pendingNotes then
        for i = #self.pendingNotes, heard + 1, -1 do table.remove(self.pendingNotes, i) end
        if #self.pendingNotes == 0 then self.pendingNotes = nil end
        self.silencedSettles = true
    end
    for _, option in ipairs(self.options) do
        local valid = self:ValidateOption(option, getRaw(profile, option.key))
        if valid == nil then valid = self:DefaultFor(option) end
        setRaw(profile, option.key, valid)
    end
end


function A:CharacterKey()
    local name = self:Text(UnitName, 1, "player") or "Player"
    local realm = type(GetRealmName) == "function" and self:Text(GetRealmName, 1) or "Realm"
    return name .. "-" .. realm
end

local function validName(name)
    return type(name) == "string" and #name >= 1 and #name <= 24 and name:match("^[%w][%w _%-]*$") ~= nil
end
A.IsValidProfileName = validName

function A:MigrateProfiles(root)
    if type(root.profiles) ~= "table" then


        local moved = {}
        for key, value in pairs(root) do
            if not RESERVED[key] then moved[key] = value end
        end
        for key in pairs(moved) do root[key] = nil end
        root.profiles = { Default = moved }
    end
    if type(root.profileKeys) ~= "table" then root.profileKeys = {} end
    root.profileVersion = PROFILE_VERSION
    for name, profile in pairs(root.profiles) do
        if type(profile) ~= "table" or not validName(name) then root.profiles[name] = nil end
    end





    for _, profile in pairs(root.profiles) do
        if profile.setupDone == nil and next(profile) ~= nil then profile.setupDone = true end
    end
    if next(root.profiles) == nil then root.profiles.Default = {} end


    self.freshProfiles = self.freshProfiles or setmetatable({}, { __mode = "k" })
    for _, profile in pairs(root.profiles) do
        if next(profile) == nil then self.freshProfiles[profile] = true end
    end

    for _, profile in pairs(root.profiles) do
        if profile.plusHealthText == false and profile.plusHealthFormat == nil then profile.plusHealthFormat = "none" end
        profile.plusHealthText = nil



        if profile.accentCustom == nil and type(profile.accent) == "table" then
            local d = { 0.56, 0.60, 0.98, 0.7 }
            local same = true
            for i = 1, 4 do
                if type(profile.accent[i]) ~= "number" or math.abs(profile.accent[i] - d[i]) > 0.005 then same = false end
            end
            profile.accentCustom = not same
        end





        if profile.plusTargetCast ~= nil then
            if profile.castTargetMode == nil and profile.unitMode == "plus" then
                profile.castTargetMode = profile.plusTargetCast ~= false and "custom" or "native"
            end
            profile.plusTargetCast = nil
        end



        self:MigrateActionBars(profile)













        if (tonumber(profile.plusDesign) or 0) < 1 then
            for key, olds in pairs({ plusHealthHeight = { 14, 20 }, plusPowerHeight = { 6, 8 },
                plusPartyBar = { 12, 14 }, castHeight = { 22 } }) do
                for _, old in ipairs(olds) do
                    if profile[key] == old then profile[key] = nil end
                end
            end


            if profile.plusHealthFormat == "both" then profile.plusHealthFormat = nil end
            profile.plusDesign = 1
        end








        if (tonumber(profile.plusDesign) or 0) < 2 then
            if profile.actionDiamond == false then profile.actionDiamond = nil end
            profile.plusDesign = 2
        end














        if (tonumber(profile.plusDesign) or 0) < 3 then
            if profile.themeScheme == "indigo" then profile.themeScheme = nil end
            profile.plusDesign = 3
        end









        if (tonumber(profile.plusDesign) or 0) < 4 then
            if profile.gaugeTicks == true then profile.gaugeTicks = false end
            if profile.plusDanger == true then profile.plusDanger = false end
            if profile.compassRhombus == true then profile.compassRhombus = false end
            if profile.plusHealthFormat == "current" then profile.plusHealthFormat = "percent" end
            profile.plusDesign = 4
        end









        if (tonumber(profile.plusDesign) or 0) < 5 then
            if profile.plusWidth == 232 then profile.plusWidth = nil end
            if profile.plusSmallWidth == 180 then profile.plusSmallWidth = nil end
            if profile.castWidth == 232 then profile.castWidth = nil end
            if profile.plusLevelPos == "right" then profile.plusLevelPos = nil end
            profile.plusDesign = 5
        end









        if (tonumber(profile.plusDesign) or 0) < 6 then
            for key, old in pairs({ plusWidth = 268, plusSmallWidth = 200, castWidth = 268,
                plusHealthHeight = 12, elevBase = 0.5, elevPanel = 0.78,
                opacity = 0.78, plusPowerHeight = 4, actionWash = 0.45 }) do
                if profile[key] == old then profile[key] = nil end
            end

            if profile.unitVeil == true then profile.unitVeil = nil end

            if profile.borders == true then profile.borders = nil end
            profile.plusDesign = 6
        end

















        if (tonumber(profile.plusDesign) or 0) < 7 then
            if profile.borders == false then profile.borders = nil end
            if profile.plusKeyline == false then profile.plusKeyline = nil end
            profile.plusDesign = 7
        end















        if profile.plusColorMode ~= nil then
            for _, key in ipairs({ "plusColorPlayer", "plusColorTarget", "plusColorFocus", "plusColorPet", "plusColorParty" }) do
                if profile[key] == nil and profile.plusColorMode ~= "auto" then profile[key] = profile.plusColorMode end
            end
            profile.plusColorMode = nil
        end
    end
end


function A:SelectProfile(root)
    local key = self:CharacterKey()
    local name = root.profileKeys[key]
    if not name or not root.profiles[name] then
        name = root.profiles.Default and "Default" or next(root.profiles)
        root.profileKeys[key] = name
    end
    self.profileName = name
    return root.profiles[name]
end

function A:ListProfiles()
    local names = {}
    for name in pairs(self.root.profiles) do names[#names + 1] = name end
    table.sort(names)
    return names
end

local function deepSchemaCopy(self, from, to)
    for _, option in ipairs(self.options) do
        local valid = self:ValidateOption(option, getRaw(from, option.key))


        if valid ~= nil or option.sparse then setRaw(to, option.key, valid) end
    end
end




local function guard(self)
    if self:IsCombat() then
        self:Print("Profile changes are unavailable in combat.")
        return false
    end
    return true
end

function A:UseProfile(name)
    if not guard(self) then return false, "combat" end
    local profile = self.root.profiles[name]
    if not profile then return false, "no such profile" end
    self.root.profileKeys[self:CharacterKey()] = name
    self.profileName = name
    self.db = profile
    self:LoadSettings(true)
    self:OptionsApplied()
    return true
end

function A:CreateProfile(name)
    if not guard(self) then return false, "combat" end
    if not validName(name) then return false, "invalid name (letters, digits, space, - _; max 24)" end
    if self.root.profiles[name] then return false, "already exists" end
    local profile = {}
    self:NormalizeProfile(profile)
    self.root.profiles[name] = profile
    local ok, err = self:UseProfile(name)

    if ok then self.pendingWelcome = true end
    return ok, err
end

function A:CopyProfile(from)
    if not guard(self) then return false, "combat" end
    local source = self.root.profiles[from]
    if not source then return false, "no such profile" end
    if source == self.db then return false, "already active" end
    deepSchemaCopy(self, source, self.db)
    self:NormalizeProfile(self.db)
    self:OptionsApplied()
    return true
end

function A:DeleteProfile(name)
    if not guard(self) then return false, "combat" end
    if not self.root.profiles[name] then return false, "no such profile" end
    if name == self.profileName then return false, "cannot delete the active profile" end
    self.root.profiles[name] = nil
    for key, mapped in pairs(self.root.profileKeys) do
        if mapped == name then self.root.profileKeys[key] = nil end
    end
    return true
end

function A:ResetProfile()
    if not guard(self) then return false, "combat" end
    for _, option in ipairs(self.options) do setRaw(self.db, option.key, self:ResetValue(option)) end

    self.pendingWelcome = true
    self:OptionsApplied()
    return true
end

function A:RenameProfile(old, new)
    if not guard(self) then return false, "combat" end
    local profile = self.root.profiles[old]
    if not profile then return false, "no such profile" end
    if not validName(new) then return false, "invalid name (letters, digits, space, - _; max 24)" end
    if old == new then return false, "same name" end
    if self.root.profiles[new] then return false, "a profile with that name already exists" end
    self.root.profiles[new] = profile
    self.root.profiles[old] = nil
    for key, mapped in pairs(self.root.profileKeys) do
        if mapped == old then self.root.profileKeys[key] = new end
    end
    for _, specs in pairs(self.root.specProfiles or {}) do
        for spec, mapped in pairs(specs) do if mapped == old then specs[spec] = new end end
    end
    if self.profileName == old then self.profileName = new end
    return true
end



function A:ResetTab(groupKey)
    if not guard(self) then return false, "combat" end
    local count = 0
    for _, option in ipairs(self.options) do
        if (option.group or option.tab) == groupKey then
            setRaw(self.db, option.key, self:ResetValue(option))
            count = count + 1
        end
    end
    if count == 0 then return false, "nothing to reset" end
    self:OptionsApplied()
    return true, count
end
















A.optionSections = {





    { key = "look", label = "Look", short = "Colours, frames, text", desc = "Colour, unit frames, text, and how much of the HUD is drawn." },
    { key = "layout", label = "Layout", short = "Where things sit, size", desc = "Where everything sits, and how big it is." },
    { key = "combat", label = "Combat", short = "What fights show you", desc = "What the HUD tells you while you are fighting." },
    { key = "controls", label = "Controls", short = "Pad, keys, camera", desc = "Controller or keyboard, button pictures, camera, tooltips." },
    { key = "profiles", label = "Profiles", short = "Saved setups, per spec", desc = "Saved setups, per character and per spec." },
    { key = "help", label = "Help & tools", short = "Report, reset, turn off", desc = "Turn things off, report a problem, reset, run the welcome." },
    { key = "classic", label = "Classic looks", short = "Go back to earlier looks", advanced = true,
      desc = "Every earlier look AdaptiveUI has shipped, one switch each." },
}

A.optionSectionAlias = { advanced = "help", general = "look", vetoes = "classic" }



A.optionGroupSection = {
    theme = { "look", "Theme and colour" },
    general = { "look", "Surfaces and type" },
    plus = { "look", "Unit frames" },
    plustext = { "look", "Plate text" },
    pluscolor = { "combat", "Health colours" },
    gauges = { "combat", "Gauges and marks" },
    casts = { "combat", "Cast bars" },
    damage = { "combat", "Damage strip" },
    plusparty = { "combat", "Party and target-of-target" },
    actions = { "layout", "Action bars (controller)" },
    compass = { "layout", "Action bars (controller)" },
    keyboard = { "layout", "Action bars (keyboard)" },
    movers = { "controls", "Moving things" },
    minimap = { "layout", "Minimap and auras" },
    panels = { "layout", "Chat and objectives" },
    info = { "layout", "Info strips" },
    infomore = { "layout", "Info strips" },
    infobar = { "layout", "Info strips" },
    tooltip = { "controls", "Tooltips" },
    profiles = { "profiles", "Profiles" },
}



A.optionKeySection = {


    plateSkin = { "look", "Plate styles" },
    plateFillStyle = { "look", "Plate styles" },
    plateMantleCast = { "look", "Plate styles" },
    keyboardSkin = { "look", "Plate styles" },
    keyboardEmptyHotkey = { "look", "Plate styles" },
    keyboardBackdrop = { "look", "Plate styles" },
    keyboardSlotSkin = { "look", "Plate styles" },
    plateSmallSkin = { "look", "Plate styles" },
    raidSkin = { "look", "Plate styles" },
    keyboardMicroSkin = { "layout", "Action bars (keyboard)" },
    mode = { "controls", "Input and button pictures" },
    autoSwitchInput = { "controls", "Input and button pictures" },
    actionGlyphs = { "controls", "Input and button pictures" },
    actionCamera = { "controls", "Camera" },
    moverSnap = { "controls", "Moving things" },
    moverStep = { "controls", "Moving things" },
    safeZone = { "layout", "Screen" },
    dockScale = { "layout", "Action bars (controller)" },
    scale = { "layout", "Unit frames" },
    actionDiamond = { "look", "Action slots" },
    compassIconShape = { "look", "Action slots" },
    keyboardMastHead = { "look", "Action slots" },
    emptyRecede = { "look", "Action slots" },
    iconCrop = { "look", "Action slots" },
    style = { "look", "Surfaces and type" },
    textScale = { "look", "Surfaces and type" },
    opacity = { "look", "Surfaces and type" },
    artRecolour = { "look", "Theme and colour" },
    recolourMarks = { "look", "Theme and colour" },
    artMaterial = { "look", "Theme and colour" },
    artGlaze = { "look", "Theme and colour" },
    chromeCrest = { "look", "Map and windows" },
    chromeTrackerHead = { "look", "Map and windows" },
    mapSkin = { "look", "Map and windows" },
    windowSkin = { "look", "Map and windows" },
    trackerStyle = { "look", "Map and windows" },
    chatStyle = { "look", "Map and windows" },
    plusFocusTargetOn = { "look", "Unit frames" },
    plusFocusTargetTargetOn = { "look", "Unit frames" },

    plusUnified = { "look", "Plate details" }, plusRim = { "look", "Plate details" },
    plusGlow = { "look", "Plate details" }, plusFlash = { "look", "Plate details" },
    plusCorner = { "look", "Plate details" }, plusKeyline = { "look", "Plate details" },
    plusStud = { "look", "Plate details" }, plusSigil = { "look", "Plate details" },
    plusAccentMark = { "look", "Plate details" }, plusBarTexture = { "look", "Plate details" },
    flatBars = { "look", "Plate details" }, gaugeTicks = { "look", "Plate details" },
    plusNumberStyle = { "look", "Plate details" }, plusPixelSnap = { "look", "Plate details" },
    unitVeil = { "look", "Surfaces and depth" }, themeBezel = { "look", "Surfaces and depth" },
    themeShadow = { "look", "Surfaces and depth" }, themeTextShadow = { "look", "Surfaces and depth" },
    elevBase = { "look", "Surfaces and depth" }, elevPanel = { "look", "Surfaces and depth" },
    elevRaised = { "look", "Surfaces and depth" }, windowBanner = { "look", "Surfaces and depth" },
    borders = { "look", "Surfaces and depth" }, accentRule = { "look", "Surfaces and depth" },
    actionWash = { "look", "Surfaces and depth" },

    keyboardHotkeyAbbrev = { "layout", "Action bars (keyboard)" },
    keyboardSlotInset = { "layout", "Action bars (keyboard)" },
    keyboardSlotBrass = { "layout", "Action bars (keyboard)" },
    xpLane = { "layout", "Action bars (keyboard)" },
    compassRhombus = { "layout", "Action bars (controller)" },
    compassGroundEdge = { "layout", "Action bars (controller)" },
    clusterTray = { "layout", "Action bars (controller)" },
    compassSlotBrass = { "layout", "Action bars (controller)" },
    compassAutoSpread = { "layout", "Action bars (controller)" },
    compassDividerLight = { "layout", "Action bars (controller)" },
    compassBumperGlow = { "layout", "Action bars (controller)" },
    auraTrayEmpty = { "layout", "Minimap and auras" },
    castRestrictedStrip = { "combat", "Cast bars" },


    actionSocketSkin = { "classic", "Earlier looks" },
    compassSkin = { "classic", "Earlier looks" },
    compassButtonSkin = { "classic", "Earlier looks" },
    compassBumperSkin = { "classic", "Earlier looks" },
    compassPromptSeat = { "classic", "Earlier looks" },
    chromeSkin = { "classic", "Earlier looks" },
    casts = { "classic", "Earlier looks" },
}


for _, id in ipairs(A.compassGroupOrder) do
    A.optionKeySection["compassGroupSize." .. id] = { "layout", "Action bars (controller)" }
end





A.optionUnlisted = { auraTraySlots = true, optionsLayout = true, optionsAdvanced = true, optionsChangedOnly = true,
    optionsAdvancedSeen = true, firstRunDefaults = true }

A.optionAdvancedKeys = {}





A.optionBasic = {
    look = { "themeScheme", "unitMode", "plateSkin", "motionLevel", "textScale", "opacity", "style" },
    layout = { "safeZone" },
    combat = { "castPlayerMode", "castTargetMode", "dpsStripOn", "plusDanger" },
    controls = { "mode", "autoSwitchInput", "actionGlyphs", "actionCamera", "tooltipScale" },
    profiles = {},
    help = {},
    classic = {},
}


A.optionSimpleValues = {
    plateSkin = { inlay = true, mantle = true, tinted = true },
}




local PLATE_GROUPS = { plus = true, plustext = true, pluscolor = true, plusparty = true }
local PAD_GROUPS = { actions = true, compass = true }
A.optionRequireKeys = {
    plateSkin = "plates", plateFillStyle = "plates", plateMantleCast = "plates", plusFocusTargetOn = "plates",
    plusFocusTargetTargetOn = "plates", plateSmallSkin = "plates", unitVeil = "plates", flatBars = "plates",
    plusBarTexture = "plates", gaugeTicks = "plates", plusUnified = "plates", plusRim = "plates", plusGlow = "plates",
    plusCorner = "plates", plusKeyline = "plates", plusStud = "plates", plusSigil = "plates", plusAccentMark = "plates",
    plusPixelSnap = "plates", plusLossTrail = "plates", plusHealGhost = "plates", plusDanger = "plates",
    keyboardSkin = "keyboard", keyboardBackdrop = "keyboard", keyboardSlotSkin = "keyboard",
    keyboardEmptyHotkey = "keyboard", keyboardMicroSkin = "keyboard", keyboardMastHead = "keyboard", xpLane = "keyboard",
    actionDiamond = "controller", compassIconShape = "controller", compassBumperGlow = "controller",
    compassDividerLight = "controller", actionWash = "controller", actionSocketSkin = "controller",
    compassSkin = "controller", compassButtonSkin = "controller", compassBumperSkin = "controller",
    compassPromptSeat = "controller",
}

A.optionRequireExempt = { unitMode = true, scale = true, actionCamera = true, dockScale = true, emptyRecede = true,
    iconCrop = true, actionGlyphs = true }
function A:OptionRequirement(option)
    local key = option.key
    if self.optionRequireKeys[key] then return self.optionRequireKeys[key] end
    if key:find("^compassGroupSize%.") then return "controller" end
    if self.optionRequireExempt[key] then return nil end
    local group = option.group
    if group and PLATE_GROUPS[group] then return "plates" end
    if group and PAD_GROUPS[group] then return "controller" end
    if group == "keyboard" then return "keyboard" end
    return nil
end

A.optionRequireWhy = { plates = "with AdaptiveUI plates", controller = "with the controller bars",
    keyboard = "with the keyboard bars", frame = "with the frame under the controller bars" }
function A:OptionInapplicable(option)
    if option.key == "compassGroundEdge" and self.db and self:GetOption("compassGround") ~= "frame" then return "frame" end
    local need = self:OptionRequirement(option)
    if not need or not self.db then return nil end
    if need == "plates" then return self.db.unitMode ~= "plus" and need or nil end
    local bars = self.ClickInputMode and self:ClickInputMode() or "keyboard"
    if need == "controller" then return bars ~= "controller" and need or nil end
    if need == "keyboard" then return bars ~= "keyboard" and need or nil end
    return nil
end



A.optionTags = {
    theme = "colour theme scheme accent palette dark light",
    general = "transparency font text",
    plus = "unit frame player target health mana plate",
    plustext = "name level percent number text plate",
    pluscolor = "class colour reaction health bar",
    gauges = "trail heal ghost low health danger ticks marks",
    casts = "cast bar channel spell timer interrupt",
    damage = "dps damage meter strip recount",
    plusparty = "party group raid tot target of target",
    actions = "action bar compass controller socket icon diamond",
    compass = "compass arm group bigger rail row preset hero d-pad face",
    keyboard = "action bar keybind hotkey slot bar1 mainbar xp",
    movers = "move drag position anchor grid snap nudge",
    minimap = "minimap map zone coordinates buff debuff aura",
    panels = "chat objectives quest tracker backing",
    info = "fps latency durability clock strip",
    infomore = "gold bags coordinates strip",
    infobar = "info bar edge strip",
    tooltip = "tooltip mouseover anchor",
    profiles = "profile export import spec character copy reset",
}

A.optionKeywords = {
    mode = "controller gamepad keyboard mouse glyphs icons button pictures input",
    autoSwitchInput = "controller gamepad keyboard switch detect automatic compass popup",
    actionGlyphs = "controller gamepad button pictures glyphs icons",
    themeScheme = "colour theme scheme palette",
    unitMode = "unit frames plates blizzard lite player target",
    plateSkin = "plate design painted unit frame",
    textScale = "text font size bigger smaller tv couch read",
    opacity = "solidity transparent transparency see through panels",
    motionLevel = "motion movement animation reduced",
    style = "hud style minimal full panels",
    dockScale = "action bar size bigger smaller",
    scale = "unit frame size bigger smaller plates",
    minimapScale = "minimap map size bigger smaller",
    tooltipScale = "tooltip size bigger smaller",
    safeZone = "screen edge margin tv overscan safe",
    actionCamera = "camera action combat over the shoulder",
    castPlayerMode = "cast bar player",
    castTargetMode = "cast bar target",
    dpsStripOn = "damage dps meter",
    plusDanger = "low health warning danger",
    plusColorPlayer = "health bar colour class reaction",
    plusColorTarget = "health bar colour class reaction",
    moverSnap = "move grid snap",
    moverStep = "move nudge distance",
    infoBar = "info bar fps latency clock gold",
    chatAlpha = "chat backing transparent",
    trackerAlpha = "quest tracker objectives backing transparent",
    keyboardSkin = "keyboard action bar design painted",
    compassLayout = "controller compass layout",
    mapSkin = "minimap map frame",
    windowSkin = "window options frame",
}


A.searchSynonyms = {
    gamepad = "controller", pad = "controller", joypad = "controller", controler = "controller",
    color = "colour", colors = "colour", colours = "colour", theme = "colour", themes = "colour",
    bigger = "size", smaller = "size", larger = "size", scale = "size", resize = "size", big = "size", small = "size",
    hide = "turn off", disable = "turn off", remove = "turn off", off = "turn off", ["get rid"] = "turn off",
    drag = "move", position = "move", place = "move", unlock = "move", nudge = "move",
    default = "reset", defaults = "reset", undo = "reset", restore = "reset",
    share = "profile", copy = "profile", export = "profile", import = "profile",
    transparent = "solidity", transparency = "solidity", opacity = "solidity", alpha = "solidity",
    tv = "size", couch = "size", sofa = "size", font = "text",
    keybind = "keyboard", keys = "keyboard", mouse = "keyboard",
    bug = "report", problem = "report", crash = "report", error = "report",
}


A.optionDesc = {
    compassDividerLight = "Holding LT or RT lights your compass divider from that trigger's end. Off: the divider stays as painted.",
    xpLane = "Blizzard's own experience bar. An XP lane inside your painted bar waits on /aui xpprobe from your client.",
    themeScheme = "Sixteen materials for the same design, and a custom one. The tile is the preview.",
    accentCustom = "Replace the scheme's metal with a colour of your own.",
    accent = "The one accent: rules, marks, the focus ring.",
    artRecolour = "Themes retint the painted plate, slabs and bezels. Off keeps the paintings' own colour.",
    themeShadow = "How deep the drop shadows go.",
    themeBezel = "A faint lit edge and sheen on raised panels.",
    themeTextShadow = "A soft shadow under every line of type.",
    unitVeil = "A soft pool of ink behind the unit plates.",
    flatBars = "One colour in the fill, one in the channel.",
    plusBarTexture = "Obsidian grain and a little depth in the gauges.",
    motionLevel = "Full moves on events. Subtle is reduced motion. Off never moves.",
    barEffect = "What the health gauge does when it moves: lights, sand, shear or a pulse.",
    gaugeTicks = "Hairlines at a quarter, a half and three quarters.",
    themeHeadingFont = "The face for names and titles.",
    safeZone = "Keeps everything this far inside the screen edge. 5% is the television number.",
    plusLossTrail = "A hit leaves a fading trail behind the fill.",
    plusHealGhost = "Incoming heals show ahead of the fill.",
    plusDanger = "Low health is a bracket and a pulse, never colour alone.",
    borders = "One-pixel outlines on panels and slots.",
    plusPixelSnap = "Round every plate edge to a whole screen pixel.",
    opacity = "Lower lets the world through.",
    windowBanner = "The painted dusk valley behind window titles.",
    elevBase = "Opacity of the ambient panels: chat, map card, tracker.",
    elevPanel = "Opacity of the hero panels.",
    elevRaised = "Opacity of tooltips and the edit box.",
    textScale = "Every size on the HUD, together.",
    style = "Console RPG draws full panels; Ultra-minimal draws less.",
    mode = "Which glyphs and which action-bar layout you get.",
    unitMode = "Lite restyles Blizzard's frames. Plates are AdaptiveUI's own.",
    plateSkin = "Inlay: the health and mana are your painting. Mantle: the health stands on it (0.51). Tinted, or the 0.50 plate, the 0.43 bar, the 0.41 plate.",
    plateMantleCast = "The cast as light in the painting's seam, in its face at half strength (mantle), or a plank above the name.",
    mapSkin = "Painted: your map panel is the minimap card. Card: the 0.46 card.",
    windowSkin = "Painted: your options panel is this window. Flat: the 0.47 window.",
    trackerStyle = "Tidy: no header boxes, one soft backing. Bare: no backing. Boxed: 0.52.",
    chatStyle = "Tidy: the input shows only while you type. Bare: no backing. Boxed: 0.52.",
    plateSmallSkin = "Tile: target of target, focus, its targets and pet wear the raid tile. Inlay: the plate painting (0.52).",
    raidSkin = "Tile: Blizzard's raid frames wear the raid tile (appearance only). Native: untouched.",
    plusFocusTargetOn = "A plate for your focus's target.",
    plusFocusTargetTargetOn = "A plate for your focus's target's target.",
    keyboardBackdrop = "A card behind the buttons that rises off the painted rail, the experience bar its edge. Hearth: the whole stack. None: 0.51.",
    keyboardEmptyHotkey = "The keybind on a slot with nothing in it: faint, full, or hidden.",
    plateFillStyle = "Carved chips the painting away to reveal your lost health in your colour, red under a fifth.",
    plusWidth = "Height follows: the painting keeps its shape.",
    plusSmallWidth = "The focus, pet and party plates.",
    scale = "The whole unit frame cluster.",
    plusHealthFormat = "What the number beside the bar says.",
    plusHealthPos = "Where the health number sits.",
    plusNumberStyle = "12345 or 12.3k.",
    plusNamePos = "Where the name sits on the floating row.",
    plusNameMax = "Longer names are cut, never below eight letters.",
    plusMirror = "Target-side plates face the player's.",
    plusColorTarget = "Class colour, reaction colour, a health gradient or your own.",
    plusColorPlayer = "Class colour, reaction colour, a health gradient or your own.",
    plusColor = "Used by any plate set to Custom colour.",
    dpsStripOn = "A small readout of your own damage under your plate.",
    dpsStripMetric = "Damage and DPS, or one of them.",
    dpsStripHold = "How long it stays after the fight.",
    castPlayerMode = "Native restyles Blizzard's bar. Custom is AdaptiveUI's own, movable.",
    castTargetMode = "Native restyles Blizzard's bar. Custom is AdaptiveUI's own, movable.",
    castFocusMode = "Native restyles Blizzard's bar. Custom is AdaptiveUI's own, movable.",
    castPlayerAnchor = "Docked on the health bar, or free.",
    castTargetAnchor = "Docked on the health bar, or free.",
    castRestrictedStrip = "Draw a cast the client will not let us read, without a timer.",
    dockScale = "The controller compass and its arms.",
    compassLayout = "Live follows Blizzard's own geometry; the others are fixed patterns.",
    actionGlyphs = "Draw the controller button under each slot.",
    actionDiamond = "Diamond slots instead of squares.",
    actionSocketSkin = "The authored socket, or the 0.40 slot.",
    compassButtonSkin = "Your painted compass tiles behind each button, or the 0.49 authored socket.",
    compassIconShape = "Square icons on the tile as painted (the keyboard bar's shape), or the tile turned to a diamond.",
    actionWash = "How dark the ground under an arm is drawn.",
    emptyRecede = "An unbound slot fades to its empty socket.",
    compassGround = "Your divider under the cross, the 0.52 strip, a slab under each arm, a frame, or nothing.",
    compassSkin = "The keyboard bar's slot and rail on the compass, or the 0.47 look exactly.",
    compassSlotBrass = "The 0.41 brass lip on every slot. Off keeps one accent per object.",
    compassRailArms = "Which arms stand in the keyboard bar's slab: the enlarged ones, all, or none.",
    compassPreset = "Writes the eight group sizes as a starting point. The sizes stay yours afterwards.",
    compassAutoSpread = "Big groups push the side arms out. Off keeps the width and caps the sizes.",
    actionCamera = "Over-the-shoulder action camera. Changes the game camera; off by default.",
    keyboardSkin = "Inlay: the buttons sit in your painted bar. Edge: they float over it. Footer: the 0.52 rail. Bare, slabs, or Blizzard's frame.",
    keyboardMastHead = "The notch, boss and diamond at the ends of the slab.",
    keyboardCentre = "Centre the keyboard bar cluster on the screen.",
    keyboardSlotSkin = "The painted tile, the square facet or Blizzard's frame on every action slot, bag slot and menu button.",
    keyboardSlotBrass = "A brass lip on every slot, not only the checked one.",
    keyboardHotkeyAbbrev = "S-1 instead of Shift-1.",
    minimapScale = "The map card and everything on it.",
    minimapCoords = "Your coordinates under the map.",
    minimapZone = "The zone name above the map.",
    chromeSkin = "The map, windows and tracker in the authored chrome, or as 0.45 drew them.",
    chromeCrest = "Where the seated crest appears.",
    chromeTrackerHead = "The objectives header cut and footed like the zone strip.",
    trackerAlpha = "The backing behind the objectives.",
    chatAlpha = "The backing behind the chat, opaque at the screen edge.",
    accentRule = "A two-unit accent rule on the right column.",
    auraTray = "Buffs and debuffs in an even tray on both hero plates.",
    infoBar = "One bar along a screen edge for the info readouts.",
    infoTextSize = "12 is chrome you read standing still; 14 is the fighting floor.",
    tooltipScale = "Bigger tooltips from the sofa.",
    tooltipCorner = "Which corner tooltips grow from.",
    tooltipHealthBar = "A health bar in unit tooltips.",
    moverSnap = "Dragged things land on the grid.",
    moverStep = "How far a nudge moves, and the grid pitch.",
    plusPartyMax = "How many party plates to draw.",
    plusPartyDirection = "Stack the party up or down from the first plate.",
    plusTotPlacement = "Under the target, or beside it.",
    optionsLayout = "Six sections with search, or the nineteen-tab column of 0.46.",
    optionsAdvanced = "Show every option, or the Basic set.",
}


A.optionPresets = {
    { key = "console", label = "Console", desc = "AdaptiveUI's plates, damage strip, full motion, glyphs.",
      set = { unitMode = "plus", style = "rpg", dpsStripOn = true, motionLevel = "full", actionGlyphs = true } },
    { key = "minimal", label = "Minimal", desc = "Lite frames, fewer panels, subtle motion.",
      set = { unitMode = "lite", style = "minimal", dpsStripOn = false, motionLevel = "subtle", infoBar = "off" } },
    { key = "fullrpg", label = "Full RPG", desc = "Everything on: sand in the gauges, the danger bracket.",
      set = { unitMode = "plus", style = "rpg", dpsStripOn = true, motionLevel = "full", barEffect = "sand", plusDanger = true } },
}


function A:OptionSection(option)
    if self.optionUnlisted[option.key] then return nil end
    local over = self.optionKeySection[option.key]
    if over then return over[1], over[2] end
    local group = option.group and self.optionGroupSection[option.group]
    if group then return group[1], group[2] end
    return nil
end


function A:SectionKey(key)
    if type(key) ~= "string" then return nil end
    key = self.optionSectionAlias[key] or key
    for _, s in ipairs(self.optionSections) do if s.key == key then return key end end
    return nil
end


function A:OptionIsBasic(option)
    local section = self:OptionSection(option)
    for _, key in ipairs(self.optionBasic[section] or {}) do
        if key == option.key then return true end
    end
    return false
end

function A:OptionDescription(option)
    local line = self.optionDesc[option.key]
    if line then return line end
    if option.type == "enum" then
        local names = {}
        for i, entry in ipairs(option.values) do if i <= 4 then names[#names + 1] = entry.label end end
        return "Choices: " .. table.concat(names, ", ") .. (#option.values > 4 and ", ..." or "") .. "."
    elseif option.type == "number" then
        local scale = option.scale or 1
        return string.format("From %s to %s.", string.format(option.format or "%.2f", (option.min or 0) * scale),
            string.format(option.format or "%.2f", (option.max or 1) * scale))
    elseif option.type == "color" then
        return "Opens the colour picker."
    end
    return "On or off."
end



function A:OptionValues(option, all)
    local keep = not all and self.optionSimpleValues[option.key]
    if not keep then return option.values end
    local current = self.db and self:GetOption(option.key)
    local list = {}
    for _, entry in ipairs(option.values) do
        if keep[entry.value] or entry.value == current then list[#list + 1] = entry end
    end
    return list
end




function A:SectionOptions(sectionKey, all, filter)
    local order, buckets = {}, {}
    for _, option in ipairs(self.options) do
        local section, sub = self:OptionSection(option)
        if section == sectionKey and not option.inline and (all or self:OptionIsBasic(option))
            and (not filter or filter(option)) then
            if not buckets[sub] then buckets[sub] = {}; order[#order + 1] = sub end
            local list = buckets[sub]
            list[#list + 1] = option
        end
    end
    local out = {}
    for _, sub in ipairs(order) do out[#out + 1] = { subsection = sub, options = buckets[sub] } end
    return out
end


function A:SearchForms(term)
    local forms = { term }
    local same = self.searchSynonyms[term]
    if same then forms[#forms + 1] = same end

    if #term > 3 and term:sub(-1) == "s" then forms[#forms + 1] = term:sub(1, -2) end
    return forms
end




function A:SearchOptions(term)
    term = (term or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if term == "" then return {} end
    local forms = self:SearchForms(term)
    local function has(text)
        if type(text) ~= "string" or text == "" then return false end
        text = text:lower()
        for _, f in ipairs(forms) do if text:find(f, 1, true) then return true end end
        return false
    end
    local sectionLabel = {}
    for _, s in ipairs(self.optionSections) do sectionLabel[s.key] = s.label end
    local hits, tagHits = {}, 0
    for _, option in ipairs(self.options) do
        local section, sub = self:OptionSection(option)

        if section == "classic" and self.db and self:GetOption("optionsAdvanced") ~= true then section = nil end
        if section then
            local score = 0
            if has(option.label) then score = 3
            elseif has(self.optionKeywords[option.key]) or has(option.key) then score = 2
            else
                local valueHit = false
                for _, entry in ipairs(option.values or {}) do if has(entry.label) then valueHit = true end end
                if valueHit or has(sub) or has(self.optionDesc[option.key]) then score = 1
                elseif has(sectionLabel[section]) or has(self.optionTags[option.group or ""]) then score = 0.5 end
            end
            if score == 0.5 then
                tagHits = tagHits + 1
                if tagHits > 5 then score = 0 end
            end
            if score > 0 then
                local shown = option.inline and self.optionIndex[option.inline] or option
                hits[#hits + 1] = { option = shown, score = score, section = section, subsection = sub,
                    basic = self:OptionIsBasic(shown) }
            end
        end
    end


    table.sort(hits, function(a, b)
        if a.basic ~= b.basic then return a.basic end
        if a.score ~= b.score then return a.score > b.score end
        if a.section ~= b.section then return a.section < b.section end
        return (a.option.label or a.option.key) < (b.option.label or b.option.key)
    end)

    local seen, out = {}, {}
    for _, hit in ipairs(hits) do
        if not seen[hit.option] then seen[hit.option] = true; out[#out + 1] = hit end
    end
    return out
end




A.searchPins = {
    { kind = "reset", words = { "reset" } },
    { kind = "turnoff", words = { "turn off" } },
    { kind = "report", words = { "report" } },
    { kind = "welcome", words = { "welcome", "setup", "walkthrough" } },
    { kind = "move", words = { "move" } },
    { kind = "profiles", words = { "profile", "spec" } },
}
function A:SearchExtras(term)
    term = (term or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if term == "" then return {} end
    local forms = self:SearchForms(term)
    local out, seen = {}, {}
    local function add(entry)
        local k = entry.kind .. ":" .. tostring(entry.id)
        if not seen[k] then seen[k] = true; out[#out + 1] = entry end
    end
    for _, pin in ipairs(self.searchPins) do
        for _, word in ipairs(pin.words) do
            for _, f in ipairs(forms) do
                if f == word or word:find(f, 1, true) == 1 then add({ kind = pin.kind }) end
            end
        end
    end

    for _, group in ipairs(self.layoutGroups or {}) do
        for _, f in ipairs(forms) do
            if #f >= 3 and (group.label:lower():find(f, 1, true) or (group.words or ""):find(f, 1, true)) then
                add({ kind = "group", id = group.id })
            end
        end
    end
    return out
end

function A:ApplyPreset(key)
    if not guard(self) then return false, "combat" end
    for _, preset in ipairs(self.optionPresets) do
        if preset.key == key then
            for k, v in pairs(preset.set) do
                if self.optionIndex[k] then setRaw(self.db, k, self:ValidateOption(self.optionIndex[k], v)) end
            end
            self:OptionsApplied()
            return true
        end
    end
    return false, "unknown preset"
end



function A:ResetSection(sectionKey, keys)
    if not guard(self) then return false, "combat" end
    local count = 0
    for _, option in ipairs(self.options) do
        if (keys and keys[option.key]) or (not keys and self:OptionSection(option) == sectionKey) then
            setRaw(self.db, option.key, self:ResetValue(option))
            count = count + 1
        end
    end
    if sectionKey == "layout" and not keys then
        for _, option in ipairs(self.options) do

            if option.tab == "movers" or option.tab == "elements" then
                setRaw(self.db, option.key, self:DefaultFor(option)); count = count + 1
            end
        end
    end
    if count == 0 then return false, "nothing to reset" end
    self:OptionsApplied()
    return true, count
end




function A:ChangedKeys(sectionKey)
    local out = {}
    for _, option in ipairs(self.options) do
        local section = self:OptionSection(option)
        if section and (sectionKey == nil or section == sectionKey) and not option.inline
            and self:OptionChanged(option.key) then
            out[#out + 1] = option.key
        end
    end
    if sectionKey == nil or sectionKey == "layout" then
        for _, option in ipairs(self.options) do
            if (option.tab == "movers" or option.key:find("^scale%.")) and self:OptionChanged(option.key) then
                out[#out + 1] = option.key
            end
        end
    end
    return out
end


function A:OptionChanged(key)
    local option = self.optionIndex[key]
    if not option then return false end
    local value, default = self:GetOption(key), self:ResetValue(option)
    if type(value) == "table" and type(default) == "table" then
        for i = 1, math.max(#value, #default) do
            if math.abs((value[i] or 0) - (default[i] or 0)) > 1e-6 then return true end
        end
        return false
    end
    if type(value) == "number" and type(default) == "number" then return math.abs(value - default) > 1e-9 end
    return value ~= default
end




function A:Confirmed(key, seconds)
    local now = type(GetTime) == "function" and select(2, pcall(GetTime)) or 0
    local armed = self.confirmArmed
    if armed and armed.key == key and now <= armed.expires then
        self.confirmArmed = nil
        return true
    end
    self.confirmArmed = { key = key, expires = now + (seconds or 5) }
    return false
end

function A:ClearConfirm()
    self.confirmArmed = nil
end







function A:SpecMap()
    local root = self.root
    if type(root.specProfiles) ~= "table" then root.specProfiles = {} end
    local key = self:CharacterKey()
    if type(root.specProfiles[key]) ~= "table" then root.specProfiles[key] = {} end
    return root.specProfiles[key]
end




function A:SpecProbe()
    local candidates = {}
    if type(C_SpecializationInfo) == "table" then
        candidates[#candidates + 1] = { "C_SpecializationInfo.GetSpecialization", C_SpecializationInfo.GetSpecialization }
    else
        candidates[#candidates + 1] = { "C_SpecializationInfo.GetSpecialization", nil }
    end
    candidates[#candidates + 1] = { "GetSpecialization", type(GetSpecialization) == "function" and GetSpecialization or nil }
    local report, chosen = {}, nil
    for _, c in ipairs(candidates) do
        local state = "missing"
        if type(c[2]) == "function" then
            local value, status = self:Read(c[2], 1)
            state = status == "public" and (type(value) == "number" and "public" or "nil") or status
            if state == "public" and not chosen then chosen = c[2] end
        end
        report[#report + 1] = { name = c[1], state = state }
    end
    return chosen, report
end

function A:CurrentSpec()
    local fn = self:SpecProbe()
    if not fn then return nil end
    return self:Number(fn, 1)
end

function A:SetSpecProfile(spec, name)
    if not guard(self) then return false, "combat" end
    if type(spec) ~= "number" or spec < 1 or spec > 4 then return false, "spec 1-4" end
    if name ~= nil and not self.root.profiles[name] then return false, "no such profile" end
    self:SpecMap()[spec] = name
    return true
end



function A:ApplySpecProfile()
    self.specSwitchPending = nil
    local spec = self:CurrentSpec()
    if not spec then return false end
    local name = self:SpecMap()[spec]
    if not name or name == self.profileName or not self.root.profiles[name] then return false end
    local ok = self:UseProfile(name)
    if ok then self:Print("Specialization " .. spec .. ": switched to profile \"" .. name .. "\".") end
    return ok
end





local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)
        local n = a * 65536 + (b or 0) * 256 + (c or 0)
        local c1, c2, c3, c4 = math.floor(n / 262144) % 64, math.floor(n / 4096) % 64, math.floor(n / 64) % 64, n % 64
        out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
            .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
    end
    return table.concat(out)
end

local B64INDEX = {}
for i = 1, #B64 do B64INDEX[B64:sub(i, i)] = i - 1 end

local function b64decode(text)
    if #text % 4 ~= 0 then return nil end
    local out = {}
    for i = 1, #text, 4 do
        local chunk = text:sub(i, i + 3)
        local v = {}
        for j = 1, 4 do
            local ch = chunk:sub(j, j)
            if ch == "=" then v[j] = 0 else
                v[j] = B64INDEX[ch]
                if v[j] == nil then return nil end
            end
        end
        local n = v[1] * 262144 + v[2] * 4096 + v[3] * 64 + v[4]
        local bytes = { math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256 }
        local keep = 3 - (chunk:sub(4, 4) == "=" and 1 or 0) - (chunk:sub(3, 3) == "=" and 1 or 0)
        for j = 1, keep do out[#out + 1] = string.char(bytes[j]) end
    end
    return table.concat(out)
end

local function checksum(data)
    local h = 5381
    for i = 1, #data do h = (h * 33 + data:byte(i)) % 4294967291 end
    return string.format("%08x", h)
end

local function escape(text)
    return (text:gsub("[%%\n=;]", function(ch) return string.format("%%%02X", ch:byte()) end))
end

local function unescape(text)
    return (text:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end))
end

local function encodeValue(option, value)
    if option.type == "bool" then return "b:" .. (value and "1" or "0") end
    if option.type == "number" then return "n:" .. string.format("%.6g", value) end
    if option.type == "color" then
        return "c:" .. string.format("%02x%02x%02x%02x", math.floor(value[1] * 255 + 0.5), math.floor(value[2] * 255 + 0.5),
            math.floor(value[3] * 255 + 0.5), math.floor(value[4] * 255 + 0.5))
    end
    if option.type == "offset" then return "o:" .. string.format("%.6g,%.6g", value[1], value[2]) end
    return "s:" .. escape(tostring(value))
end

local function decodeValue(option, text)
    local tag, body = text:match("^(%a):(.*)$")
    if not tag then return nil end
    if tag == "b" and option.type == "bool" then
        if body == "1" then return true elseif body == "0" then return false end
    elseif tag == "n" and option.type == "number" then return tonumber(body)
    elseif tag == "s" and (option.type == "enum" or option.type == "text") then return unescape(body)
    elseif tag == "o" and option.type == "offset" then
        local x, y = body:match("^(-?[%d%.e+-]+),(-?[%d%.e+-]+)$")
        if x and tonumber(x) and tonumber(y) then return { tonumber(x), tonumber(y) } end
    elseif tag == "c" and option.type == "color" then
        local r, g, b, a = body:match("^(%x%x)(%x%x)(%x%x)(%x%x)$")
        if r then return { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 } end
    end
    return nil
end

function A:ExportProfile()
    local lines = {}
    for _, option in ipairs(self.options) do
        local value = self:GetOption(option.key)
        if not sparseDefault(option.key, value) then
            lines[#lines + 1] = option.key .. "=" .. encodeValue(option, value)
        end
    end
    return self:PackPayload(table.concat(lines, "\n"))
end

function A:PackPayload(payload)
    return "AUI1:" .. b64encode(payload) .. ":" .. checksum(payload)
end


function A:ParseProfileString(text)
    if type(text) ~= "string" then return nil, "not text" end
    text = text:gsub("%s+", "")
    local body, sum = text:match("^AUI1:([A-Za-z0-9+/=]+):(%x+)$")
    if not body then return nil, "not an AdaptiveUI profile string" end
    local payload = b64decode(body)
    if not payload then return nil, "corrupted (bad encoding)" end
    if checksum(payload) ~= sum:lower() then return nil, "corrupted (checksum mismatch)" end
    local values, accepted, rejected = {}, 0, 0
    for line in (payload .. "\n"):gmatch("([^\n]*)\n") do
        local key, encoded = line:match("^([%w%.]+)=(.*)$")



        local option = key and (self.optionIndex[key] or self.legacyOptions[key])
        if option then
            local valid = self:ValidateOption(option, decodeValue(option, encoded))
            if valid ~= nil then values[key] = valid; accepted = accepted + 1 else rejected = rejected + 1 end
        end
    end
    if accepted == 0 then return nil, "no recognised settings" end
    return values, accepted, rejected
end



function A:ImportProfile(text, name)
    if not guard(self) then return false, "combat" end
    local values, accepted, rejected = self:ParseProfileString(text)
    if not values then return false, accepted end
    local target
    if name then
        if not validName(name) then return false, "invalid profile name" end
        if self.root.profiles[name] then return false, "a profile with that name already exists" end
        target = {}
        self:NormalizeProfile(target)
    else
        target = self.db
    end
    for key, value in pairs(values) do setRaw(target, key, value) end


    for _, option in ipairs(self.options) do
        if option.sparse and values[option.key] == nil then setRaw(target, option.key, nil) end
    end
    self:NormalizeProfile(target)
    if name then
        self.root.profiles[name] = target
        return self:UseProfile(name), accepted, rejected
    end
    self:OptionsApplied()
    return true, accepted, rejected
end
