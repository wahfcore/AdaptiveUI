local _, A = ...






















A.looks = { "oakborn", "dusk", "blizzard" }

function A:Look()
    if not (self.db and self.optionIndex and self.optionIndex.look) then return "dusk" end
    return self:GetOption("look")
end


A.oakSwap = {
    ["plate02-plain"] = "oak-plate-plain",
    ["tile-plain"] = "oak-small-plain",
    ["tile-plain-cap"] = "oak-small-cap", ["tile-notch-cap"] = "oak-small-cap", ["tile-pip-cap"] = "oak-small-cap",
    ["tile-pipnotch-cap"] = "oak-small-cap", ["tile-pipnotchr-cap"] = "oak-small-cap",
    ["tile-plain-lum"] = "oak-small-lum", ["tile-notch-lum"] = "oak-small-lum", ["tile-pip-lum"] = "oak-small-lum",
    ["tile-pipnotch-lum"] = "oak-small-lum", ["tile-pipnotchr-lum"] = "oak-small-lum",
    ["compass-tile-notch"] = "oak-compass-tile", ["compass-tile-cut"] = "oak-tile",
    ["compass-tile-pip-tl"] = "oak-tile-pip", ["compass-tile-pip-bl"] = "oak-tile-pip",
    ["compass-divider"] = "oak-divider",
    ["rblb"] = "oak-bumper", ["rblb-glow"] = "oak-bumper-glow",
    ["bar04"] = "oak-rail",
    ["kb-tile-face"] = "oak-kb-face", ["kb-tile-socket"] = "oak-kb-socket",
    ["dot-fill"] = "oak-stud", ["dot-socket"] = "oak-knot",
}


local installed
local function isInstalled(self, file)
    if not installed then
        installed = {}
        for _, f in pairs(self.artSlots or {}) do
            if type(f) == "string" then installed[f] = true end
        end
    end
    return installed[file] == true
end


function A:ForgetLookManifest()
    installed = nil
    self.lookArtFor = nil
end


function A:LookName(name)
    if not name or self.lookArtFor ~= "oakborn" then return name end
    local oak = self.oakSwap[name]
    if oak and isInstalled(self, oak) then return oak end
    return name
end






local SMALL = { ratio = 2286 / 631, lane = { 0.02756, 0.08082, 0.97244, 0.89065 }, base = { 0.2364, 0.2710, 0.2941 } }
A.oakArt = {

    inlayArt = { file = "oak-plate-plain", values = {
        ratio = 3843 / 410, capL = 80 / 1024, capR = 81 / 1024, capLA = 300 / 410, capRA = 303 / 410,
        fillHeadA = 300 / 410, fillTailA = 478 / 410, bandTop = 6 / 410, faceTop = 70 / 410, faceBot = 316 / 410,
        footTop = 371 / 410, manaH = 0.25, plankH = 0, inlay = true, fill = "meter",
        winL = 300 / 410, winR = 303 / 410, winTop = 6 / 410, winBot = 316 / 410,
        lanes = { health = { 70 / 410, 316 / 410 }, power = { 6 / 410, 70 / 410 }, cast = { 316 / 410, 371 / 410 } },
        base = { health = { 0.1788, 0.2191, 0.2537 }, power = { 0.2134, 0.2768, 0.3057 } },
        lum = "oak-plate-lum", cap = "oak-plate-cap",
    } },
    castSeamRows = { file = "oak-plate-plain", list = { 316 / 410, 371 / 410 } },
    castSeamCols = { file = "oak-plate-plain", list = { 300 / 410, 303 / 410 } },
    plateStud = { file = "oak-plate-plain", values = { fromTail = 535 / 410, y = 177.5 / 410, size = 114 / 410 } },




    bar04Art = { file = "oak-rail", values = {
        ratio = 2075 / 134, seatV0 = 21 / 134, faceV0 = 25 / 134, footV0 = 0.66, footV1 = 0.88,
        bossU0 = 1006 / 2075 - 0.004, bossU1 = 1078 / 2075 + 0.004, coverU0 = 0.44, pageU = 0.04,
        topU0 = 39 / 2075, topU1 = 2037 / 2075, flatU0 = 0.05, flatU1 = 0.95, laneTop = true,
    } },




    bar04Base = { file = "oak-rail", values = { air = 0, fadeOver = 44, back = false, fadeAlpha = 0.55 } },

    dividerArt = { file = "oak-divider", values = {
        ratio = 2570 / 261, faceV0 = 0.45, faceV1 = 0.85, faceU0 = 0.05, faceU1 = 0.95,
        diamondU = 0.499, diamondV = 0.72, diamondA = 0.49, notchU = 0.95,
    } },


    ["tileArts.plain"] = { file = "oak-small-plain", values = SMALL },
    ["tileArts.notch"] = { file = "oak-small-plain", values = SMALL },
    ["tileArts.pip"] = { file = "oak-small-plain", values = SMALL },
    ["tileArts.pipnotch"] = { file = "oak-small-plain", values = SMALL },
    ["tileArts.pipnotchr"] = { file = "oak-small-plain", values = SMALL },
    rblbArt = { file = "oak-bumper", values = {
        ratio = 2987 / 384, seatU = 0.80, seatV = 0.50, bodyV1 = 0.70, studU = 0.625, studV = 0.44,
        glowPadX = 0.03, glowPadY = 0.12, height = 20,
    } },
}







A.oakPlates = {
    smooth = { file = "oak-plate-plain", shade = "oak-plate-shade" },
    rough = { file = "oak-plate2-plain", shade = "oak-plate2-shade", src = "oakborn-unit-plate-02.png", inlay = {
        ratio = 1873 / 285, capL = 70 / 1024, capR = 83 / 1024, capLA = 128 / 285, capRA = 152 / 285,
        fillHeadA = 128 / 285, fillTailA = 306 / 285, bandTop = 19 / 285, faceTop = 58 / 285, faceBot = 232 / 285,
        footTop = 272 / 285, manaH = 0.25, plankH = 0, inlay = true, fill = "meter",
        winL = 128 / 285, winR = 152 / 285, winTop = 19 / 285, winBot = 232 / 285,
        lanes = { health = { 58 / 285, 232 / 285 }, power = { 19 / 285, 58 / 285 }, cast = { 236 / 285, 272 / 285 } },
        base = { health = { 0.1499, 0.2422, 0.2999 }, power = { 0.2537, 0.3403, 0.4095 } },
        lum = "oak-plate2-lum", cap = "oak-plate2-cap",
      },
      seamRows = { 236 / 285, 272 / 285 }, seamCols = { 150 / 285, 108 / 285 },
      stud = { fromTail = 351.5 / 285, y = 149 / 285, size = 91 / 285 } },
    straight = { file = "oak-plate3-plain", shade = "oak-plate3-shade", src = "oakborn-unit-plate-03.png", inlay = {
        ratio = 1770 / 224, capL = 56 / 1024, capR = 57 / 1024, capLA = 97 / 224, capRA = 98 / 224,
        fillHeadA = 97 / 224, fillTailA = 317 / 224, bandTop = 16 / 224, faceTop = 40 / 224, faceBot = 148 / 224,
        footTop = 188 / 224, manaH = 0.25, plankH = 0, inlay = true, fill = "meter",
        winL = 97 / 224, winR = 98 / 224, winTop = 16 / 224, winBot = 148 / 224,
        lanes = { health = { 40 / 224, 148 / 224 }, power = { 16 / 224, 40 / 224 }, cast = { 150 / 224, 188 / 224 } },
        base = { health = { 0.1557, 0.2480, 0.2999 }, power = { 0.1903, 0.2768, 0.3460 } },
        lum = "oak-plate3-lum", cap = "oak-plate3-cap",
      },
      seamRows = { 150 / 224, 188 / 224 }, seamCols = { 80 / 224, 75 / 224 },
      stud = { fromTail = 352.5 / 224, y = 112.5 / 224, size = 71 / 224 } },
}


A.duskArt = A.duskArt or {}

local function snapshot(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

local function fill(target, from)
    for k in pairs(target) do target[k] = nil end
    for k, v in pairs(from) do target[k] = v end
end


function A:OakPlateShape()
    if not (self.db and self.optionIndex and self.optionIndex.oakPlate) then return "smooth" end
    local shape = self:GetOption("oakPlate")
    local plate = self.oakPlates[shape]
    if not (plate and plate.inlay and isInstalled(self, plate.file)
        and isInstalled(self, plate.inlay.lum) and isInstalled(self, plate.inlay.cap)) then
        return "smooth"
    end
    return shape
end



function A:SyncOakPlate()
    local shape = self:OakPlateShape()
    if self.oakPlateFor == shape then return shape end
    local oak, smooth = self.oakArt, self.oakPlates.smooth
    if not smooth.inlay then
        smooth.inlay = snapshot(oak.inlayArt.values)
        smooth.seamRows = snapshot(oak.castSeamRows.list)
        smooth.seamCols = snapshot(oak.castSeamCols.list)
        smooth.stud = snapshot(oak.plateStud.values)
    end
    local p = self.oakPlates[shape]
    oak.inlayArt.file, oak.castSeamRows.file, oak.castSeamCols.file, oak.plateStud.file = p.file, p.file, p.file, p.file
    fill(oak.inlayArt.values, p.inlay)
    fill(oak.castSeamRows.list, p.seamRows)
    fill(oak.castSeamCols.list, p.seamCols)
    fill(oak.plateStud.values, p.stud)
    self.oakSwap["plate02-plain"] = p.file
    self.oakPlateShade = p.shade
    self.oakPlateFor = shape
    return shape
end





A.oakSmallShade = "oak-small-shade"
function A:OakShadeFile(tile)
    if self.lookArtFor ~= "oakborn" then return nil end
    local painting = tile and "tile-plain" or (self.PlateFile and self:PlateFile()) or "plate02-plain"
    if self:LookName(painting) == painting then return nil end
    local file = tile and self.oakSmallShade or self.oakPlateShade
    if file and isInstalled(self, file) then return file end
    return nil
end



function A:SyncLookArt()
    local look = self:Look()
    local plate = self:SyncOakPlate()
    if self.lookArtFor == look and self.lookPlateFor == plate then return false end
    for name, spec in pairs(self.oakArt) do
        local target = self
        for part in name:gmatch("[^%.]+") do target = type(target) == "table" and target[part] or nil end
        if type(target) == "table" then
            if not self.duskArt[name] then self.duskArt[name] = snapshot(target) end
            local dusk = self.duskArt[name]
            if look == "oakborn" and isInstalled(self, spec.file) then
                local merged = snapshot(dusk)
                if spec.list then
                    merged = snapshot(spec.list)
                else
                    for k, v in pairs(spec.values) do merged[k] = v end
                end
                fill(target, merged)
            else
                fill(target, dusk)
            end
        end
    end
    self.lookArtFor, self.lookPlateFor = look, plate

    self.dirty, self.nativeDirty, self.layoutDirty = true, true, true
    self.themeSignature = nil
    return true
end



A.lookPresets = {
    oakborn = {
        unitMode = "plus", plateSkin = "inlay", plateSmallSkin = "tile", raidSkin = "tile",
        keyboardSkin = "base", keyboardSlotSkin = "tile", keyboardBackdrop = "fade", xpLane = "inlay",
        compassGround = "divider", compassButtonSkin = "tiles", compassBumperSkin = "arm",
        mapSkin = "shelf", windowSkin = "branch", chromeCrest = "off",
        trackerStyle = "tidy", chatStyle = "tidy",
        castPlayerMode = "custom",
        ["skins.actions"] = true, ["skins.units"] = true, ["skins.party"] = true, ["skins.auras"] = true,
        ["skins.minimap"] = true, ["skins.objectives"] = true, ["skins.chat"] = true, ["skins.tooltips"] = true,
    },
    dusk = {
        unitMode = "plus", plateSkin = "inlay", plateSmallSkin = "tile", raidSkin = "tile",
        keyboardSkin = "base", keyboardSlotSkin = "tile", keyboardBackdrop = "fade", xpLane = "inlay",
        compassGround = "divider", compassButtonSkin = "tiles", compassBumperSkin = "arm",
        mapSkin = "base", windowSkin = "painted", chromeCrest = "windows",
        trackerStyle = "tidy", chatStyle = "tidy",
        castPlayerMode = "custom",
        ["skins.actions"] = true, ["skins.units"] = true, ["skins.party"] = true, ["skins.auras"] = true,
        ["skins.minimap"] = true, ["skins.objectives"] = true, ["skins.chat"] = true, ["skins.tooltips"] = true,
    },


    blizzard = {
        unitMode = "lite", raidSkin = "native",
        keyboardSkin = "classic", keyboardSlotSkin = "classic", keyboardBackdrop = "off", xpLane = "blizzard",
        compassGround = "none", compassBumperSkin = "native",
        mapSkin = "card", windowSkin = "flat", chromeCrest = "off",
        castPlayerMode = "native",
        ["skins.actions"] = false, ["skins.units"] = false, ["skins.party"] = false, ["skins.auras"] = false,
        ["skins.minimap"] = false, ["skins.objectives"] = false, ["skins.chat"] = false, ["skins.tooltips"] = false,
    },
}






function A:ApplyLook(look)
    local preset = self.lookPresets[look]
    if not preset then return false end
    local from = self.lookArtFor
    local modules = look == "blizzard" or from == "blizzard" or from == nil
    for key, value in pairs(preset) do
        local option = self.optionIndex[key]
        local skip = not modules and key:find("^skins%.") ~= nil
        if option and not skip and self:ValidateOption(option, value) ~= nil then self:SetOption(key, value, true) end
    end
    self:SyncLookArt()
    return true
end


function A:LookChanged()
    local preset = self.lookPresets[self:Look()]
    local n, keys = 0, {}
    for key, value in pairs(preset or {}) do
        local option = self.optionIndex[key]
        if option and self:ValidateOption(option, value) ~= nil and self:GetOption(key) ~= value then
            n = n + 1
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return n, keys
end


function A:ResetLook()
    return self:ApplyLook(self:Look())
end




A.lookNote = "Your look is now AUI Oakborn. Options > Look > Look switches between AUI Oakborn, AUI Dusk and Blizzard."





A.lookSettleKeys = { mapSkin = { base = true, branch = true, shelf = true }, windowSkin = { painted = true, branch = true } }
function A:SettleLook(profile)
    if profile.lookSettled == true then return false end
    profile.lookSettled = true
    if profile.look ~= nil and profile.look ~= "dusk" then return false end
    profile.look = "oakborn"
    for key, from in pairs(self.lookSettleKeys) do
        local value = self.lookPresets.oakborn[key]
        local option = self.optionIndex and self.optionIndex[key]
        local have = profile[key]
        if option and self:ValidateOption(option, value) ~= nil and (have == nil or from[have]) then profile[key] = value end
    end
    self.pendingNotes = self.pendingNotes or {}
    self.pendingNotes[#self.pendingNotes + 1] = A.lookNote
    return true
end














A.retiredOptions = {

    "compassV3Settled", "plateStylesSettled", "barsV4Settled", "barsV5Settled", "barsV6Settled",
    "chromeV2Settled", "crestMapSettled", "pass7Settled", "pass9Settled", "themeFollowSettled",
    "oakFeetSettled", "oakShelfSettled",

    "plusSigil", "plusStud", "plusAccentMark",

    "keyboardMastHead", "keyboardSlotBrass", "keyboardMicroSlab", "keyboardEmptyStyle",

    "actionSocketSkin", "compassSkin", "compassRailArms", "compassRhombus", "compassGroundEdge",
    "compassSlotBrass", "compassEmptyStyle", "compassLayout", "compassPromptSeat",

    "chromeSkin", "windowBanner",

    "optionsLayout",
}
A.scrubNote = { one = "1 setting from an earlier look now follows %s.",
    many = "%d settings from earlier looks now follow %s." }


function A:ScrubValue(look, option)
    local preset = self.lookPresets[look]
    local value = preset and preset[option.key]
    if value ~= nil and self:ValidateOption(option, value) ~= nil then return value end
    value = self.shippedDefaults and self.shippedDefaults[option.key]
    if value ~= nil and self:ValidateOption(option, value) ~= nil then return value end
    return self:DefaultFor(option)
end






A.scrubMovedDefaults = { "plateSkin", "plateMantleCast", "compassGround", "keyboardSkin", "keyboardBackdrop",
    "keyboardSlotSkin", "mapSkin", "windowSkin", "xpLane", "compassBumperSkin" }

function A:ScrubProfile(profile, fresh)
    if type(profile) ~= "table" then return 0 end
    local lookOption = self.optionIndex and self.optionIndex.look
    local look = lookOption and self:ValidateOption(lookOption, profile.look) or "oakborn"
    local moved = 0
    for _, key in ipairs(self.scrubMovedDefaults) do
        local option = self.optionIndex and self.optionIndex[key]
        if option and self:ReadRaw(profile, key) == nil then
            self:StoreRaw(profile, key, self:ScrubValue(look, option))
        end
    end
    for _, option in ipairs(self.options) do


        if option.type == "enum" and option.key ~= "look" then
            local raw = self:ReadRaw(profile, option.key)
            if raw ~= nil and self:ValidateOption(option, raw) == nil then
                self:StoreRaw(profile, option.key, self:ScrubValue(look, option))
                moved = moved + 1
            end
        end
    end
    for _, key in ipairs(self.retiredOptions) do
        if profile[key] ~= nil then profile[key] = nil end
    end
    if moved > 0 and not fresh then
        local label = look
        for _, entry in ipairs(lookOption and lookOption.values or {}) do
            if entry.value == look then label = entry.label end
        end
        self.pendingNotes = self.pendingNotes or {}
        self.pendingNotes[#self.pendingNotes + 1] = moved == 1 and string.format(A.scrubNote.one, label)
            or string.format(A.scrubNote.many, moved, label)
    end
    return moved
end


function A:LookLine()
    local n = self:LookChanged()
    return string.format("look: %s (art %s) | %d changed", tostring(self:Look()), tostring(self.lookArtFor), n)
end
