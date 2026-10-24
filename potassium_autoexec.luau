-- Potassium autoexec bootstrap for THT Item Visualizer.
-- The in-game Auto Execute switch is stored separately for each place.
if not game:IsLoaded() then game.Loaded:Wait() end
if type(readfile) ~= "function" then return end

local settingsPath = "THT_Item_Visualizer_" .. tostring(game.PlaceId) .. ".json"
local readOk, raw = pcall(readfile, settingsPath)
if not readOk or type(raw) ~= "string" then return end
local decodeOk, settings = pcall(function()
    return game:GetService("HttpService"):JSONDecode(raw)
end)
if not decodeOk or type(settings) ~= "table" or settings.autoExecute ~= true then return end

local env = type(getgenv) == "function" and getgenv() or _G
if env.__THTItemVisualizerAutoStarted
    or (env.__giftPlayerWeaponPicker and env.__giftPlayerWeaponPicker.alive) then return end
env.__THTItemVisualizerAutoStarted = true
local ok, problem = pcall(function()
    local url = "https://raw.githubusercontent.com/minztung24-pixel/virus-visualizer-loader/main/client.lua"
    assert(loadstring(game:HttpGet(url)))()
end)
if not ok then
    env.__THTItemVisualizerAutoStarted = nil
    warn("[THT Auto Execute] " .. tostring(problem))
end
