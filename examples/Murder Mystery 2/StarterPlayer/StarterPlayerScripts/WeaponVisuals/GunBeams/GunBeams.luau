--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_result = require(script.CreateBeam)
local replicated_storage_value = game.ReplicatedStorage
local value_4: string = "WeaponEvents"
local weapon_events_child = replicated_storage_value:WaitForChild(value_4)
local value_4_2: string = "GunBeam"
local on_client_event_value = weapon_events_child:WaitForChild(value_4_2).OnClientEvent
local value_5 = require_result
on_client_event_value:connect(value_5)

return
