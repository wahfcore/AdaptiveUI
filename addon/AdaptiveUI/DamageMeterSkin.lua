local _, A = ...























local MAX_WINDOWS = 6
A.meterSkins = A.meterSkins or setmetatable({}, { __mode = "k" })

function A:DamageMeterSkinOn()
    return self.db ~= nil and self.optionIndex ~= nil and self:GetOption("damageMeterSkin") ~= "off"
end

local function remember(self, state, region, key, capture)
    self:RememberProperty(state, region, key, capture)
end


local function tintTexture(self, state, tex, role, alpha)
    if not tex or type(tex.SetVertexColor) ~= "function" then return end
    remember(self, state, tex, "meterTint", function()
        local r, g, b, a = tex:GetVertexColor()
        local desat = type(tex.IsDesaturated) == "function" and tex:IsDesaturated() or false
        return function()
            if type(tex.SetDesaturated) == "function" then tex:SetDesaturated(desat) end
            tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
        end
    end)
    if type(tex.SetDesaturated) == "function" then tex:SetDesaturated(true) end
    local r, g, b = self:Color(role)
    tex:SetVertexColor(r, g, b, alpha or 1)
    state.count = (state.count or 0) + 1
end

local function untintTexture(self, state, tex)
    if tex then self:ReleaseProperty(state, tex, "meterTint") end
end



local function buttonTextures(button)
    local out = {}
    if type(button) ~= "table" then return out end
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetDisabledTexture", "GetHighlightTexture" }) do
        if type(button[getter]) == "function" then
            local ok, t = pcall(button[getter], button)
            if ok and t then out[#out + 1] = { t, getter == "GetHighlightTexture" } end
        end
    end
    if type(button.GetRegions) == "function" then
        for _, region in ipairs({ button:GetRegions() }) do
            if type(region.IsObjectType) == "function" and region:IsObjectType("Texture") then
                out[#out + 1] = { region, false }
            end
        end
    end
    return out
end

local HEADER_BUTTONS = { "MinimizeButton", "SettingsDropdown", "SessionDropdown", "DamageMeterTypeDropdown" }

local function panelFor(self, window)
    local panel = self.meterSkins[window]
    if panel then return panel end
    panel = self:Own(CreateFrame("Frame", nil, window))
    panel:EnableMouse(false)
    panel:SetAllPoints(window)
    panel.fill = panel:CreateTexture(nil, "BACKGROUND", nil, -8)
    panel.fill:SetAllPoints(panel)
    panel:SetScript("OnSizeChanged", function(p, w)

        if p.footMode then pcall(A.SeatWindowFeet, A, p, p.footMode, w) end
    end)
    self.meterSkins[window] = panel
    return panel
end

local function skinWindow(self, state, window)
    local panel = panelFor(self, window)
    local level = self:Number(window.GetFrameLevel, 1, window) or 1
    panel:SetFrameLevel(math.max(0, level - 1))
    self:Tint(panel.fill, "ink", "color", self:Surface("base"))

    local mode = (self:GetOption("damageMeterFoot") == true and self:HasArt("bar03")) and "slate" or nil
    panel.footMode = mode
    local w = self:Number(panel.GetWidth, 1, panel) or 300
    self:SeatWindowFeet(panel, mode, w)
    if panel.auiSlate then self:SyncPainted(panel.auiSlate) end
    panel:Show()
    state.decorations[window] = state.decorations[window] or {}
    state.decorations[window].meterPanel = panel

    self:HoldHidden(state, window.Header)
    local container = window.MinimizeContainer
    if container then self:HoldHidden(state, container.Background) end

    for _, key in ipairs(HEADER_BUTTONS) do
        for _, pair in ipairs(buttonTextures(window[key])) do
            if pair[2] then tintTexture(self, state, pair[1], "accent", 0.45)
            else tintTexture(self, state, pair[1], "text") end
        end
    end
    local resize = container and container.ResizeButton
    for _, pair in ipairs(buttonTextures(resize)) do tintTexture(self, state, pair[1], "muted") end

    local scroll = container and container.ScrollBox
    local target = scroll and (scroll.ScrollTarget or scroll)
    local entries = {}
    if target and type(target.GetChildren) == "function" then
        for _, child in ipairs({ target:GetChildren() }) do entries[#entries + 1] = child end
    end
    if container and container.LocalPlayerEntry then entries[#entries + 1] = container.LocalPlayerEntry end
    local file = self.artPath .. "meter.tga"
    for _, entry in ipairs(entries) do
        local bar = type(entry) == "table" and entry.StatusBar
        if bar and type(bar.GetStatusBarTexture) == "function" then
            local tex = bar:GetStatusBarTexture()
            if tex and not (state.meterBars and state.meterBars[tex]) then
                remember(self, state, tex, "meterBar", function()
                    local atlas = type(tex.GetAtlas) == "function" and tex:GetAtlas() or nil
                    local path = type(tex.GetTexture) == "function" and tex:GetTexture() or nil
                    return function()
                        if atlas and self:IsPublic(atlas) then tex:SetAtlas(atlas) elseif path then tex:SetTexture(path) end
                    end
                end)
                tex:SetTexture(file)
                state.meterBars = state.meterBars or setmetatable({}, { __mode = "k" })
                state.meterBars[tex] = true
                state.count = (state.count or 0) + 1
            end
        end
    end
end

local function unskinWindow(self, state, window)
    local panel = self.meterSkins[window]
    if panel then
        panel:Hide()
        panel.footMode = nil
    end
    self:ReleaseHidden(state, window.Header)
    local container = window.MinimizeContainer
    if container then self:ReleaseHidden(state, container.Background) end
    for _, key in ipairs(HEADER_BUTTONS) do
        for _, pair in ipairs(buttonTextures(window[key])) do untintTexture(self, state, pair[1]) end
    end
    for _, pair in ipairs(buttonTextures(container and container.ResizeButton)) do untintTexture(self, state, pair[1]) end
    for tex in pairs(state.meterBars or {}) do self:ReleaseProperty(state, tex, "meterBar") end
    state.meterBars = nil
end


function A:StyleDamageMeter(state)
    local on = self:DamageMeterSkinOn()
    for i = 1, MAX_WINDOWS do
        local window = _G["DamageMeterSessionWindow" .. i]
        if type(window) == "table" then
            if on then skinWindow(self, state, window) else unskinWindow(self, state, window) end
        end
    end
end
