--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {}
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local game_value_2: DataModel = game
local value_5: string = "GuiService"
local is_ten_foot_interface_result = game_value_2:GetService(value_5):IsTenFootInterface()
local on_radio_song_played
do
    local captured_value = is_ten_foot_interface_result
    on_radio_song_played = function(argument_1, argument_2: string): ()
        if captured_value then
            return
        end
        if argument_1.SoundId == argument_2 then
            if argument_1.IsPlaying then
                argument_1:Stop()

                return
            end
        end
        argument_1:Stop()
        argument_1.SoundId = argument_2
        argument_1:Play()

        return
    end
end
local value_7: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_7)
local value_7_2: string = "PlaySong"
local on_client_event_value = inventory_child:WaitForChild(value_7_2).OnClientEvent
local value_7_3 = on_radio_song_played
on_client_event_value:Connect(value_7_3)

return table_1
