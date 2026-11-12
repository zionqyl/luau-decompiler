--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local closure_cache = {}

local function same_capture(left_capture, right_capture): boolean
    if left_capture == nil or right_capture == nil then
        return left_capture == right_capture
    end
    if left_capture ~= left_capture or right_capture ~= right_capture then
        return false
    end
    local identity_lookup = {[left_capture] = true}

    return identity_lookup[right_capture] == true
end

local local_player_value = game.Players.LocalPlayer
local parent_value: Instance? = script.Parent
local value_4: string = "Game"
local game_child = parent_value:WaitForChild(value_4)
local require_value = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "CurrentRoundClient"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local get_mouse_result = local_player_value:GetMouse()
local target_code_name_value = game_child.TargetCodeName
local value_2_2 = (require(game.ReplicatedStorage.CodeImages))
local value_6_4: boolean = true
if game.PlaceId ~= 333740520 then
    if game.PlaceId ~= 335132309 then
        value_6_4 = false
    else
        value_6_4 = true
    end
end
if not value_6_4 then
    return
end
local update
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6 = get_mouse_result, value_6_4, require_result, local_player_value, target_code_name_value, value_2_2
    update = function(argument_1: number)
        local value_3_2
        do
            local captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12 = captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_7) and same_capture(
                closure_cache[3],
                captured_value_8
            ) and same_capture(closure_cache[4], captured_value_9) and same_capture(
                closure_cache[5],
                captured_value_10
            ) and same_capture(closure_cache[6], captured_value_11) and same_capture(
                closure_cache[7],
                captured_value_12
            ) then
                value_3_2 = closure_cache[1]
            else
                local closure_ready
                value_3_2 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local code_name_value, color_value, color_value_2, dead_value, game_value_7, get_player_from_character_result, name_value, name_value_2, name_value_3, name_value_4, name_value_5, parent_value_2, parent_value_3, player_data_value, player_data_value_2, player_data_value_3, player_data_value_4, player_data_value_5, players_value_2, target_value, transparency_value, upper_torso_value, value_1, value_2_3, value_2_5, value_3_10, value_3_11, value_3_4, value_3_5, value_3_6, value_3_7, value_3_8, value_3_9, value_4_10, value_4_11, value_4_12, value_4_6, value_4_7, value_4_8, value_4_9, value_5_5, value_5_6, value_5_7, value_5_8, value_6_5, value_6_6, value_7_3, value_8_3
                    local control_state = 0
                    while true do
                        if control_state < 6 then
                            if control_state < 3 then
                                if control_state < 1 then
                                    value_1 = captured_value_7
                                    target_value = value_1.Target
                                    control_state = if target_value == nil then 10 else 1
                                else
                                    if control_state < 2 then
                                        value_2_3 = captured_value_8
                                        control_state = if not value_2_3 then 10 else 2
                                    else
                                        game_value_7 = game
                                        players_value_2 = game_value_7.Players
                                        parent_value_2 = target_value.Parent
                                        get_player_from_character_result = players_value_2:GetPlayerFromCharacter(
                                            parent_value_2
                                        )
                                        control_state = if get_player_from_character_result == nil then 9 else 3
                                    end
                                end
                            else
                                if control_state < 4 then
                                    value_4_6 = captured_value_9
                                    player_data_value = value_4_6.PlayerData
                                    name_value = get_player_from_character_result.Name
                                    value_3_4 = player_data_value[name_value]
                                    control_state = if value_3_4 == nil then 8 else 4
                                else
                                    if control_state < 5 then
                                        value_4_7 = captured_value_9
                                        player_data_value_2 = value_4_7.PlayerData
                                        value_5_5 = captured_value_10
                                        name_value_2 = value_5_5.Name
                                        value_3_5 = player_data_value_2[name_value_2]
                                        control_state = if value_3_5 == nil then 8 else 5
                                    else
                                        value_5_6 = captured_value_9
                                        player_data_value_3 = value_5_6.PlayerData
                                        value_6_5 = captured_value_10
                                        name_value_3 = value_6_5.Name
                                        value_4_8 = player_data_value_3[name_value_3]
                                        dead_value = value_4_8.Dead
                                        control_state = if dead_value ~= false then 11 else 6
                                    end
                                end
                            end
                        else
                            if control_state < 9 then
                                if control_state < 7 then
                                    parent_value_3 = target_value.Parent
                                    upper_torso_value = parent_value_3.UpperTorso
                                    transparency_value = upper_torso_value.Transparency
                                    control_state = if transparency_value ~= 0 then 11 else 7
                                else
                                    if control_state < 8 then
                                        value_3_6 = captured_value_11
                                        value_5_7 = captured_value_12
                                        value_8_3 = captured_value_9
                                        player_data_value_4 = value_8_3.PlayerData
                                        name_value_4 = get_player_from_character_result.Name
                                        value_7_3 = player_data_value_4[name_value_4]
                                        code_name_value = value_7_3.CodeName
                                        value_4_9 = value_5_7[code_name_value]
                                        value_3_6.Image = value_4_9
                                        value_3_7 = captured_value_11
                                        value_6_6 = captured_value_9
                                        player_data_value_5 = value_6_6.PlayerData
                                        name_value_5 = get_player_from_character_result.Name
                                        value_5_8 = player_data_value_5[name_value_5]
                                        color_value = value_5_8.Color
                                        color_value_2 = color_value.Color
                                        value_3_7.ImageColor3 = color_value_2
                                        value_3_8 = captured_value_11
                                        value_4_10 = true
                                        value_3_8.Visible = value_4_10

                                        return
                                    else
                                        value_3_9 = captured_value_11
                                        value_4_11 = false
                                        value_3_9.Visible = value_4_11

                                        return
                                    end
                                end
                            else
                                if control_state < 10 then
                                    value_3_10 = captured_value_11
                                    value_4_12 = false
                                    value_3_10.Visible = value_4_12

                                    return
                                else
                                    if control_state < 11 then
                                        value_2_5 = captured_value_11
                                        value_3_11 = false
                                        value_2_5.Visible = value_3_11
                                        control_state = 11
                                    else
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_2
                    closure_cache[2], closure_cache[3], closure_cache[4], closure_cache[5], closure_cache[6], closure_cache[7] = captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12
                end
            end
        end
        pcall(value_3_2)

        return
    end
end
Update = update
local game_value_6: DataModel = game
local value_9: string = "RunService"
local pre_simulation_value = game_value_6:GetService(value_9).PreSimulation
local update_value = Update
pre_simulation_value:Connect(update_value)

return
