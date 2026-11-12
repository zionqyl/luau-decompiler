--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local game_value_2: DataModel = game
local value_3_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_3_4)
local value_3_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_3_5)
local value_3_6: string = "Shop"
local shop_child = remotes_child:WaitForChild(value_3_6)
local require_result_2 = require(game.ReplicatedStorage.Modules.BoxModule)
local game_value_4: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_5)
local require_value_3 = require
local value_7: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_7)
local value_7_2: string = "MysteryBoxService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_7_2))
local event_value = game.ReplicatedStorage.Remotes.Shop.BoxController.Event
local value_7_3
do
    local captured_value, captured_value_2 = require_result_3, shop_child
    value_7_3 = function(argument_1): ()
        local value_2_7 = captured_value
        local value_4_5 = argument_1
        value_2_7:PlayOpeningAnimation(value_4_5)
        value_2_7 = argument_1
        local value_3_8: nil = nil
        value_4_5 = nil
        for key, value in value_2_7, value_3_8, value_4_5 do
            local value_5_6, value_6_5 = key, value
            local value_7_5 = captured_value_2
            local new_item_received_value = value_7_5.NewItemReceived
            local rewarded_item_id_value = value_6_5.RewardedItemId
            local value_10: string = "Weapons"
            new_item_received_value:Fire(rewarded_item_id_value, value_10)
            local game_value_7: DataModel = game
            local replicated_storage_value_4 = game_value_7.ReplicatedStorage
            local remotes_value_3 = replicated_storage_value_4.Remotes
            local inventory_value = remotes_value_3.Inventory
            local update_salvage_client_value = inventory_value.UpdateSalvageClient
            update_salvage_client_value:Fire()
            local game_value_8: DataModel = game
            local replicated_storage_value_5 = game_value_8.ReplicatedStorage
            local remotes_value_4 = replicated_storage_value_5.Remotes
            local shop_value_3 = remotes_value_4.Shop
            local crate_complete_value = shop_value_3.CrateComplete
            local rewarded_item_id_value_2 = value_6_5.RewardedItemId
            crate_complete_value:FireServer(rewarded_item_id_value_2)
        end

        return
    end
end
event_value:connect(value_7_3)
local event_value_2 = game.ReplicatedStorage.Remotes.Shop.EggController.Event
local value_7_4
do
    local captured_value_3, captured_value_4 = require_result_2, shop_child
    value_7_4 = function(argument_1_2, argument_2): ()
        captured_value_3.HatchEgg(argument_1_2, argument_2)
        local new_item_received_value_2 = captured_value_4.NewItemReceived
        local value_5_8 = argument_2
        local value_6_6: string = "Pets"
        new_item_received_value_2:Fire(value_5_8, value_6_6)
        local crate_complete_value_2 = game.ReplicatedStorage.Remotes.Shop.CrateComplete
        local value_5_9 = argument_2
        crate_complete_value_2:FireServer(value_5_9)

        return
    end
end
event_value_2:connect(value_7_4)

return
