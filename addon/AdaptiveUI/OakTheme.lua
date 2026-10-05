local _, A = ...









































A.oakAsPaintedScheme = "oakborn"
A.oakHueRef = 0.6
A.oakHueChroma = 1.8
A.oakHueC0 = 0.20
A.oakGainMax = 2.0

local function luma(r, g, b) return 0.2126 * r + 0.7152 * g + 0.0722 * b end
local function norm(v) return math.sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3]) end



function A:OakAsPainted()
    if not (self.db and self.optionIndex and self.optionIndex.themeScheme) then return false end
    if self:GetOption("themeScheme") ~= self.oakAsPaintedScheme then return false end
    return not (self.optionIndex.accentCustom and self:GetOption("accentCustom"))
end


function A:IsOakWood(name)
    return name ~= nil and self.oakWood ~= nil and self.oakWood[name] ~= nil
end


function A:OakGain(name)
    local w = self.oakWood and self.oakWood[name]
    if not w or self:OakAsPainted() then return 1, 1, 1 end
    local s = self:GlazeStrength() / self.oakHueRef
    if s <= 0 then return 1, 1, 1 end
    local Lw = luma(w[1], w[2], w[3])
    if Lw <= 1e-4 then return 1, 1, 1 end
    local dw = { w[1] / Lw - 1, w[2] / Lw - 1, w[3] / Lw - 1 }
    local cw = norm(dw)
    local r, g, b = self:Color("accent")
    local La = luma(r, g, b)
    local dh = { 0, 0, 0 }
    if La > 1e-4 then dh = { r / La - 1, g / La - 1, b / La - 1 } end
    local ch = norm(dh)
    local sat = math.min(1, ch / self.oakHueC0)
    local dir = { 0, 0, 0 }
    for i = 1, 3 do
        dir[i] = (ch > 1e-6 and sat * dh[i] / ch or 0) + (cw > 1e-6 and (1 - sat) * dw[i] / cw or 0)
    end
    local cd = norm(dir)
    if cd <= 1e-6 then return 1, 1, 1 end
    local f = {}
    for i = 1, 3 do
        local t = Lw * (1 + dir[i] * cw * self.oakHueChroma / cd)
        local gain = w[i] > 1e-4 and t / w[i] or 1
        gain = 1 + (gain - 1) * s
        f[i] = math.max(0, math.min(self.oakGainMax, gain))
    end
    return f[1], f[2], f[3]
end


function A:OakMaterial(name)
    local r, g, b = self:OakGain(name)
    return math.min(1, r), math.min(1, g), math.min(1, b), 1
end

function A:OakGlaze(name)
    local r, g, b = self:OakGain(name)
    return math.max(0, r - 1), math.max(0, g - 1), math.max(0, b - 1), 1
end




function A:PaintedAcc(name, layers)
    local role = self:MarkRole()
    local r, g, b = self:Color(role)
    local m = self.oakMark and self.oakMark[name]
    if not m then return self.artPath .. layers.acc .. ".tga", r, g, b, nil end
    if self:OakAsPainted() then return self.artPath .. layers.acc .. ".tga", 1, 1, 1, name end
    local L = luma(r, g, b)
    local k = L > 1e-4 and m.hi / L or 1
    return self.artPath .. m.file .. ".tga", math.min(1, r * k), math.min(1, g * k), math.min(1, b * k), name
end




function A:OakStudFill()
    local raw = self.artPath .. "oak-stud.tga"
    local m = self.oakMark and self.oakMark["oak-stud"]
    if not m or self:OakAsPainted() or not self:ArtRecolourOn() then return raw, 1, 1, 1 end
    local file, r, g, b = self:PaintedAcc("oak-stud", { acc = "oak-stud" })
    return file, r, g, b
end
