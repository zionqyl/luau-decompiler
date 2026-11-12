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
local value_3_3: string = "Events"
local events_child = remotes_child:WaitForChild(value_3_3)
local value_3_4: string = "Generic"
local generic_child = events_child:WaitForChild(value_3_4)
local value_4: string = "GetGiftsLeft"
local invoke_server_result = generic_child:WaitForChild(value_4):InvokeServer()
local player_gui_value = game.Players.LocalPlayer.PlayerGui
local value_5: string = "Gifter"
local gifter_child = player_gui_value:WaitForChild(value_5)
local value_4_3: boolean = false
gifter_child.Enabled = value_4_3
local player_gui_value_2 = game.Players.LocalPlayer.PlayerGui
local value_4_4: string = "MainGUI"
local main_gui_child = player_gui_value_2:WaitForChild(value_4_4)
local value_5_2: string = "Chat"
local value_1_5 = (main_gui_child:FindFirstChild(value_5_2))
if value_1_5 then
    local value_5_3: string = "Gift"
    local gift_child = value_1_5:FindFirstChild(value_5_3)
    GiftTip = gift_child
    if GiftTip then
        local gift_tip_value_2 = GiftTip
        local value_4_7: boolean = false
        gift_tip_value_2.Visible = value_4_7
    end
end

return
