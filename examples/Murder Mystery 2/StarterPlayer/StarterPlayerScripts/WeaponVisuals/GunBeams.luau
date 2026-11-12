--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_result = require(script.CreateBeam)
local require_value_2 = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "WeaponService"
local on_client_event_value = require_value_2(client_services_child:WaitForChild(value_5_3)).GunFired.OnClientEvent
local value_5_4 = require_result
on_client_event_value:Connect(value_5_4)

return
