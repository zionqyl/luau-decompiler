--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_3)
local value_3_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_3_2)
local value_4: string = "Gameplay"
local gameplay_child = remotes_child:WaitForChild(value_4)
local value_4_2: string = "GetCurrentPlayerData"
local get_current_player_data_child = gameplay_child:WaitForChild(value_4_2)
local table_3 = {[("PlayerData")] = nil, [("PlayerData")] = nil, [("PlayerData")] = nil}
local table_4 = {}
table_3.PlayerData = table_4
local script_value: LuaSourceContainer = script
local value_6: string = "PlayerDataChanged"
local player_data_changed_child: Instance? = script_value:WaitForChild(value_6)
table_3.PlayerDataChanged = player_data_changed_child
local on_player_data_changed
do
    local captured_value = table_3
    on_player_data_changed = function(argument_1)
        local value_2_5 = captured_value
        value_2_5.PlayerData = argument_1
        captured_value.PlayerDataChanged:Fire()

        return
    end
end
local get_latest_player_data
do
    local captured_value_2 = get_current_player_data_child
    get_latest_player_data = function()
        return captured_value_2:InvokeServer()
    end
end
table_3.GetLatestPlayerData = get_latest_player_data
local get_murderer_perk
do
    local captured_value_3 = table_3
    get_murderer_perk = function()
        local value_1_5 = captured_value_3.PlayerData
        local value_2_9: nil = nil
        local value_3_6: nil = nil
        for key, value in value_1_5, value_2_9, value_3_6 do
            local value_4_4, value_5_6 = key, value
            local role_value = value_5_6.Role
            if role_value ~= "Murderer" then
                continue
            end
            local perk_value = value_5_6.Perk

            return perk_value
        end

        return nil
    end
end
table_3.GetMurdererPerk = get_murderer_perk
local invoke_server_result = (get_current_player_data_child:InvokeServer()) or ({})
table_3.PlayerData = invoke_server_result
local value_7: string = "Gameplay"
local gameplay_child_2 = remotes_child:WaitForChild(value_7)
local value_7_2: string = "PlayerDataChanged"
local on_client_event_value = gameplay_child_2:WaitForChild(value_7_2).OnClientEvent
local value_7_3 = on_player_data_changed
on_client_event_value:Connect(value_7_3)

return table_3
