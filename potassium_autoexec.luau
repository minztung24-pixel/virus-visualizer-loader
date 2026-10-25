-- Potassium autoexec bootstrap for THT Item Visualizer.
-- Steal An Egg starts on first install; the in-game switch then controls later joins.
if not game:IsLoaded() then game.Loaded:Wait() end
print("[THT Auto Execute] file đã chạy; PlaceId=" .. tostring(game.PlaceId))

local settingsPath = "THT_Item_Visualizer_" .. tostring(game.PlaceId) .. ".json"
local enabled = game.PlaceId == 107778070777162 -- Steal An Egg
if type(readfile) == "function" then
    local readOk, raw = pcall(readfile, settingsPath)
    if readOk and type(raw) == "string" then
        local decodeOk, settings = pcall(function()
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if decodeOk and type(settings) == "table"
            and type(settings.autoExecute) == "boolean" then
            enabled = settings.autoExecute
        end
    end
end
if not enabled then
    warn("[THT Auto Execute] đang tắt hoặc không phải place Steal An Egg đã cấu hình.")
    return
end

local env = type(getgenv) == "function" and getgenv() or _G
if env.__THTItemVisualizerAutoStarted
    or (env.__giftPlayerWeaponPicker and env.__giftPlayerWeaponPicker.alive) then
    print("[THT Auto Execute] giao diện đã chạy, bỏ qua bản trùng.")
    return
end
env.__THTItemVisualizerAutoStarted = true
local ok, problem = pcall(function()
    local url = "https://raw.githubusercontent.com/minztung24-pixel/virus-visualizer-loader/main/client.lua"
    assert(loadstring(game:HttpGet(url)))()
end)
if not ok then
    env.__THTItemVisualizerAutoStarted = nil
    warn("[THT Auto Execute] " .. tostring(problem))
else
    print("[THT Auto Execute] đã tải client.lua thành công.")
end
