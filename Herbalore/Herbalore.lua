-- Herbalore: when you gather a herb, a voice says one of that herb's lines, the least heard first; each line, and each
-- herb, then rests longer every time (Ready, HerbReady).
-- Now and then, while you're gathering, she says a quiet line instead. Skinning has its own few lines: the first
-- skin each session, then now and then. Never in combat. /herbalore turns it on or off.
--
-- It also keeps a quiet notebook (account-wide), for tools in wow-market to read after you log off:
--   HerbalorePicks[herb]    where each herb was picked, "mapID:x:y" (x, y in thousandths), for herb routes;
--   HerbaloreUnknown[name]  anything picked from a node that has no line yet, with a count, so it can get one.
local _, ns = ...
local DIR = "Interface\\AddOns\\Herbalore\\sounds\\"
local GAP, CALM = 45, 600  -- seconds: at least GAP between lines; a quiet line at most every CALM
local MAX_PICKS = 400      -- per herb, oldest dropped first
local lastCalm, skinned = GetTime(), false  -- AlbaLast is shared with Shan'do: they never talk over each other
HerbaloreSaid = {}  -- replaced by the saved table when it loads

-- Backoff, per line: once a line is said it rests BASE seconds, then twice that, then twice again, so a line you've
-- heard a few times drops out of the evening. Kept per character across /reload; forgotten after FORGET (a new day).
local BASE, FORGET = 1200, 12 * 3600
local function Ready(k)
    local s = HerbaloreSaid[k]
    return not s or time() - s[2] > FORGET or time() - s[2] >= BASE * 2 ^ (s[1] - 1)
end
local function Mark(k)
    local s = HerbaloreSaid[k]
    if not s or time() - s[2] > FORGET then s = { 0, 0 } end
    s[1], s[2] = s[1] + 1, time()
    HerbaloreSaid[k] = s
end

local HERB_REST = 300  -- seconds a herb rests after one of its lines, doubling each time
local function HerbReady(g)
    local s = HerbaloreSaid[g]
    return not s or time() - s[2] > FORGET or time() - s[2] >= HERB_REST * 2 ^ (s[1] - 1)
end
local HerbMark = Mark

local function Say(k, text)
    AlbaLast = GetTime()
    Mark(k)
    PlaySoundFile(DIR .. k .. ".mp3", "Dialog")
    DEFAULT_CHAT_FRAME:AddMessage("|cff9fd3a8" .. text .. "|r")
end

local function Heard(k)  -- times this line has been said today
    local s = HerbaloreSaid[k]
    return (s and time() - s[2] <= FORGET) and s[1] or 0
end

-- Say the least-heard line in the list that isn't resting (ties at random), so unheard lines come first.
-- False if every line is resting.
local function SayOne(list)
    local best, fewest = {}, math.huge
    for _, c in ipairs(list) do
        if Ready(c[1]) then
            local n = Heard(c[1])
            if n < fewest then best, fewest = { c }, n elseif n == fewest then best[#best + 1] = c end
        end
    end
    if #best == 0 then return false end
    local c = best[math.random(#best)]
    Say(c[1], c[2])
    return true
end

local function IsSkin(name)
    return name:find("Leather") or name:find("Hide$") or name:find(" Scale$")
end

local function Where()
    local map = C_Map and C_Map.GetBestMapForUnit("player")
    local pos = map and C_Map.GetPlayerMapPosition(map, "player")
    if not pos then return end
    local x, y = pos:GetXY()
    return ("%d:%d:%d"):format(map, x * 1000 + 0.5, y * 1000 + 0.5)
end

local function FromNode()
    local ok, guid = pcall(GetLootSourceInfo, 1)
    return ok and type(guid) == "string" and guid:find("^GameObject") ~= nil
end

local function Note(herb)
    local at = Where()
    if not at then return end
    HerbalorePicks = HerbalorePicks or {}
    local t = HerbalorePicks[herb] or {}
    HerbalorePicks[herb] = t
    t[#t + 1] = at
    if #t > MAX_PICKS then table.remove(t, 1) end
end

-- Found alongside a herb (Forever's scarce finds and seeds) or rare in itself: these speak instead of the herb.
local RARE = {
    ["Black Lotus"] = true, ["Death Lotus"] = true, ["Frilled Lichen"] = true, ["Rosecap"] = true,
    ["Stranglevine"] = true, ["Commonplace Herb Seeds"] = true, ["Uncommon Herb Seeds"] = true,
    ["Unusual Herb Seeds"] = true, ["Scarce Herb Seeds"] = true,
}

local f = CreateFrame("Frame")
f:RegisterEvent("LOOT_OPENED")
f:SetScript("OnEvent", function()
    local herb, rare, skin, node = nil, nil, false, FromNode()
    for i = 1, GetNumLootItems() do
        local name = select(2, GetLootSlotInfo(i))
        if name then
            if ns.HERBS[name] and RARE[name] then
                rare = rare or name
            elseif ns.HERBS[name] then
                herb = herb or name
            elseif node then
                HerbaloreUnknown = HerbaloreUnknown or {}
                HerbaloreUnknown[name] = (HerbaloreUnknown[name] or 0) + 1
            elseif IsSkin(name) then
                skin = true
            end
        end
    end
    herb = herb or rare  -- the node's own herb goes in the notebook; a rare find alongside it is what she speaks of
    if herb then Note(herb) HerbaloreSession = (HerbaloreSession or 0) + 1 end  -- read by Shan'do's look-back
    if skin then SkinSession = (SkinSession or 0) + 1 end
    if HerbaloreOff or InCombatLockdown() or GetTime() - (AlbaLast or -GAP) < GAP then return end
    local spoken = rare or herb
    if spoken then
        herb = spoken
        -- the herb itself rests too (HERB_REST, doubling), so one herb's lines don't come one after another
        local gate = "herb:" .. herb
        if HerbReady(gate) and SayOne(ns.HERBS[herb]) then
            HerbMark(gate)
        elseif GetTime() - lastCalm > CALM and math.random() < 0.3 and SayOne(ns.CALM) then
            lastCalm = GetTime()
        end
    elseif skin and ns.SKIN and #ns.SKIN > 0 then
        if not skinned then
            skinned = SayOne(ns.SKIN)
        elseif GetTime() - lastCalm > CALM and math.random() < 0.25 and SayOne(ns.SKIN) then
            lastCalm = GetTime()
        end
    end
end)

SLASH_HERBALORE1 = "/herbalore"
SlashCmdList.HERBALORE = function(msg)
    if (msg or ""):lower() == "help" then ns.ShowReadme() return end
    HerbaloreOff = not HerbaloreOff
    print("|cff9fd3a8Herbalore|r: " .. (HerbaloreOff and "off" or "on"))
end
