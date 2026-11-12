--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value = game
local value_4 = "ReplicatedStorage"
local replicated_storage_service = game_value:GetService(value_4)
local value_4_2 = "Modules"
local modules_child = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3 = "FriendsModule"
require_value(modules_child:WaitForChild(value_4_3)):StartRefreshing()

return
