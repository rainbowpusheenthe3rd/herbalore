-- The in-game readme: Options > AddOns > Herbalore, or /herbalore help. Describes what it does, never its lines.
local _, ns = ...

local TEXT = [[
|cff9fd3a8Herbalore|r gives each herb a voice. When you gather one, she says a line about it: what it is, where it likes to grow, or simply something worth noticing. Every herb has three lines, and the ones you haven't heard come first.

|cffffd100When she speaks|r
  - Gathering a herb: one of its lines. Each line, and each herb, then rests longer every time, so the same herb won't speak over and over.
  - Now and then while gathering, a quiet line instead, about slowing down.
  - Skinning: a word of thanks the first time each session, then now and then.
  - Never in combat, and never within 45 seconds of Shan'do or of herself.

|cffffd100The notebook|r
Herbalore quietly keeps a notebook for the whole account: where each herb was picked (for drawing herb routes later), and anything picked from a node that has no line yet (so it can be given one). It is kept in your saved variables and never leaves your computer.

|cffffd100Settings|r
Left-click the leaf by the minimap (or |cff9fd3a8/herbalore options|r): on or off, and how often herbs speak. Right-click it to turn her off or on; drag it to move it.

|cffffd100Commands|r
  |cff9fd3a8/herbalore|r  turn her off or on
  |cff9fd3a8/herbalore options|r  settings
  |cff9fd3a8/herbalore help|r  this page

|cff888888Voice: the same designed voice as Shan'do, recorded for each line.|r

Every herb you pick will grow back.
]]

local panel = CreateFrame("Frame")
panel.name = "Herbalore"
local icon = panel:CreateTexture(nil, "ARTWORK")
icon:SetSize(56, 56)
icon:SetPoint("TOPLEFT", 16, -16)
icon:SetTexture("Interface\\AddOns\\Herbalore\\icon")
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
title:SetPoint("LEFT", icon, "RIGHT", 12, 6)
title:SetText("Herbalore")
local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
sub:SetText("A voice for every herb.")

local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -12)
scroll:SetPoint("BOTTOMRIGHT", -32, 16)
local body = CreateFrame("Frame", nil, scroll)
body:SetSize(560, 10)
scroll:SetScrollChild(body)
local text = body:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
text:SetPoint("TOPLEFT")
text:SetJustifyH("LEFT")
text:SetSpacing(3)
text:SetText(TEXT)
scroll:SetScript("OnSizeChanged", function(_, w)
    body:SetWidth(w)
    text:SetWidth(w - 8)
    body:SetHeight(text:GetStringHeight() + 16)
end)

local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

function ns.ShowReadme()
    if category and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
