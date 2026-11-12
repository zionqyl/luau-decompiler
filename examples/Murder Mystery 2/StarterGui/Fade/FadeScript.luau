--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value = game
local value_3 = "TweenService"
local tween_service = game_value:GetService(value_3)
local require_value = require
local game_value_2 = game
local value_4 = "ReplicatedStorage"
local replicated_storage_service = game_value_2:GetService(value_4)
local value_4_2 = "SharedServices"
local shared_services_child = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3 = "FadeService"
local require_result = require_value(shared_services_child:WaitForChild(value_4_3))

local function on_initialize()
    return
end

return
