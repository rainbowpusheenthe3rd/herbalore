-- A small button on the edge of the minimap, at half opacity (full when you point at it).
-- Left-click: the readme. Right-click: turn her off or on. Drag: move it round the edge (kept per character).
local _, ns = ...
local NAME, COLOUR, ICON = "Herbalore", "|cff9fd3a8", "Interface\\AddOns\\Herbalore\\icon"
local REST = 0.5

local b = CreateFrame("Button", "HerbaloreMinimapButton", Minimap)
b:SetSize(24, 24)
b:SetFrameStrata("MEDIUM")
b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
b:SetAlpha(REST)
b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
b:RegisterForDrag("LeftButton")
local tex = b:CreateTexture(nil, "ARTWORK")
tex:SetAllPoints()
tex:SetTexture(ICON)

local function Place(angle)
    local r = Minimap:GetWidth() / 2 + 6
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", r * math.cos(math.rad(angle)), r * math.sin(math.rad(angle)))
end

local function Dim() tex:SetDesaturated(HerbaloreOff and true or false) end

b:SetScript("OnEnter", function(self)
    self:SetAlpha(1)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(COLOUR .. NAME .. "|r" .. (HerbaloreOff and "  (off)" or ""))
    GameTooltip:AddLine("Left-click: about Herbalore", 1, 1, 1)
    GameTooltip:AddLine("Right-click: turn off or on", 1, 1, 1)
    GameTooltip:AddLine("Drag: move this button", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
b:SetScript("OnLeave", function(self) self:SetAlpha(REST) GameTooltip:Hide() end)
b:SetScript("OnClick", function(_, button)
    if button == "RightButton" then SlashCmdList.HERBALORE("") else ns.ShowReadme() end
    Dim()
end)
b:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local s = Minimap:GetEffectiveScale()
        HerbaloreMap = math.deg(math.atan2(cy / s - my, cx / s - mx))
        Place(HerbaloreMap)
    end)
end)
b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

b:RegisterEvent("PLAYER_LOGIN")
b:SetScript("OnEvent", function() Place(HerbaloreMap or 225) Dim() end)
