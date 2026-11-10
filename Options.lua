-- Settings: left-click the minimap button (or /herbalore options). On/off, how often herbs speak, and the guide.
-- The quiet gap between lines is shared with Shan'do and set in her panel.
local _, ns = ...
local COLOUR = "|cff9fd3a8"

local PACE = { 3, 2, 1, 0.5 }  -- HerbalorePace multiplies every line's rest: higher is quieter
local PACE_NAME = { "rarely", "less often", "as usual", "more often" }
local function PaceIndex() for i, p in ipairs(PACE) do if math.abs(p - (HerbalorePace or 1)) < 0.01 then return i end end return 3 end

local f
local function Build()
    local ok
    ok, f = pcall(CreateFrame, "Frame", "HerbaloreOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
    if not ok then
        f = CreateFrame("Frame", "HerbaloreOptionsFrame", UIParent, "BackdropTemplate")
        f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } })
        CreateFrame("Button", nil, f, "UIPanelCloseButton"):SetPoint("TOPRIGHT", -4, -4)
    end
    f:SetSize(320, 230)
    f:SetPoint("CENTER", 0, -40)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    tinsert(UISpecialFrames, "HerbaloreOptionsFrame")
    local t = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    t:SetPoint("TOP", 0, -6)
    t:SetText(COLOUR .. "Herbalore|r")
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("TOPLEFT", 16, -30)
    icon:SetTexture("Interface\\AddOns\\Herbalore\\icon")
    local sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", 64, -38)
    sub:SetWidth(240)
    sub:SetJustifyH("LEFT")
    sub:SetText("A voice for every herb, rare find and seed. Quiet lines now and then; thanks when skinning.")

    local c = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    c:SetPoint("TOPLEFT", 16, -78)
    local cl = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cl:SetPoint("LEFT", c, "RIGHT", 4, 0)
    cl:SetText("On")
    c:SetScript("OnClick", function(self)
        if (self:GetChecked() and true or false) == (HerbaloreOff and true or false) then SlashCmdList.HERBALORE("") end
    end)

    local l = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    l:SetPoint("TOPLEFT", 22, -112)
    local s = CreateFrame("Slider", nil, f, "BackdropTemplate")
    s:SetOrientation("HORIZONTAL")
    s:SetSize(270, 16)
    s:SetPoint("TOPLEFT", 22, -130)
    s:SetBackdrop({ bgFile = "Interface\\Buttons\\UI-SliderBar-Background", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8, insets = { left = 3, right = 3, top = 6, bottom = 6 } })
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    s:SetMinMaxValues(1, #PACE)
    s:SetValueStep(1)
    if s.SetObeyStepDrag then s:SetObeyStepDrag(true) end
    s:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v + 0.5)
        HerbalorePace = PACE[v]
        l:SetText("How often herbs speak: " .. PACE_NAME[v])
    end)

    local note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", 22, -156)
    note:SetText("The quiet gap between lines is set in Shan'do's panel.")

    local guide = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    guide:SetSize(130, 24)
    guide:SetPoint("BOTTOM", 0, 16)
    guide:SetText("Guide and features")
    guide:SetScript("OnClick", function() f:Hide() ns.ShowReadme() end)
    f:SetScript("OnShow", function()
        c:SetChecked(not HerbaloreOff)
        local i = PaceIndex()
        s:SetValue(i)
        l:SetText("How often herbs speak: " .. PACE_NAME[i])
    end)
end

function ns.ShowOptions()
    if not f then Build() end
    f:SetShown(not f:IsShown())
end
