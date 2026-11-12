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

local function on_show_teammates(argument_1): ()
    local value_2_4 = argument_1
    local value_3_6: nil = nil
    local value_4_4: nil = nil
    for key, value in value_2_4, value_3_6, value_4_4 do
        local value_5_3, value_6 = key, value
        local game_value_2: DataModel = game
        local players_value = game_value_2.Players
        local value_9 = value_6
        local find_first_child_result = players_value:FindFirstChild(value_9)
        if not find_first_child_result then
            continue
        end
        local game_value_3: DataModel = game
        local players_value_2 = game_value_3.Players
        local local_player_value = players_value_2.LocalPlayer
        if find_first_child_result == local_player_value then
            continue
        end
        local character_value = find_first_child_result.Character
        if not character_value then
            return
        end
        local value_11: string = "HumanoidRootPart"
        local humanoid_root_part_child = character_value:FindFirstChild(value_11)
        local value_7_2 = humanoid_root_part_child
        if not value_7_2 then
            return
        end
        local script_value: LuaSourceContainer = script
        local team_mate_value = script_value.TeamMate
        local cloned_value = team_mate_value:Clone()
        local value_9_4: boolean = true
        cloned_value.Enabled = value_9_4
        cloned_value.Parent = value_7_2
    end

    return
end

local value_5: string = "ShowTeammates"
local on_client_event_value = gameplay_child:WaitForChild(value_5).OnClientEvent
local value_5_2 = on_show_teammates
on_client_event_value:Connect(value_5_2)

return
