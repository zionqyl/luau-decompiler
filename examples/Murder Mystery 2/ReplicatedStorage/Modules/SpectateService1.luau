--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("SpectateStarted")] = nil,
    [("SpectateStarted")] = nil,
    [("SpectateStarted")] = nil,
    [("SpectateStarted")] = nil,
    [("SpectateStarted")] = nil,
}
local game_value: DataModel = game
local value_4: string = "ContextActionService"
local context_action_service: Instance = game_value:GetService(value_4)
local require_value = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "CurrentRoundClient"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local local_player_value = game.Players.LocalPlayer
local current_camera_value: Camera = workspace.CurrentCamera
local table_6 = {nil, nil}
local q_value = Enum.KeyCode.Q
local button_l1_value = Enum.KeyCode.ButtonL1
table_6[1], table_6[2] = q_value, button_l1_value
local table_7 = {nil, nil}
button_l1_value = Enum.KeyCode.E
local button_r1_value = Enum.KeyCode.ButtonR1
table_7[1], table_7[2] = button_l1_value, button_r1_value
button_l1_value = {}
button_r1_value = false
local value_10 = 1
local value_11 = nil
local script_value: LuaSourceContainer = script
local value_14: string = "SpectateStarted"
local spectate_started_child: Instance? = script_value:WaitForChild(value_14)
table_1.SpectateStarted = spectate_started_child
local script_value_2: LuaSourceContainer = script
local value_14_2: string = "SpectateCancelled"
local spectate_cancelled_child: Instance? = script_value_2:WaitForChild(value_14_2)
table_1.SpectateCancelled = spectate_cancelled_child
local script_value_3: LuaSourceContainer = script
local value_14_3: string = "SpectateTargetChanged"
local spectate_target_changed_child: Instance? = script_value_3:WaitForChild(value_14_3)
table_1.SpectateTargetChanged = spectate_target_changed_child
do
    local captured_value, captured_value_2 = require_result, local_player_value

    local function is_alive()
        local value_1 = captured_value.PlayerData[captured_value_2.Name]
        if value_1 then
            if captured_value.PlayerData[captured_value_2.Name].Dead == true then
                value_1 = false
            else
                value_1 = true
            end
        end

        return value_1
    end
end
do
    local captured_value_3 = current_camera_value

    local function focus_camera(argument_1): boolean
        if not argument_1.Character then
            return false
        end
        local character_value_2 = argument_1.Character
        local value_4_6: string = "Humanoid"
        local find_first_child_of_class_result = character_value_2:FindFirstChildOfClass(value_4_6)
        if not find_first_child_of_class_result then
            return false
        end
        value_11 = argument_1
        local value_3_6: Camera = captured_value_3
        value_3_6.CameraSubject = find_first_child_of_class_result

        return true
    end
end
do
    local captured_value_4 = context_action_service

    local function unbind_spectate_keybind(): ()
        local value_1_2: Instance = captured_value_4
        local value_3_8: string = "SpectateLeft"
        value_1_2:UnbindAction(value_3_8)
        local value_1_4: Instance = captured_value_4
        local value_3_9: string = "SpectateRight"
        value_1_4:UnbindAction(value_3_9)

        return
    end
end
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8 = local_player_value, current_camera_value, context_action_service, table_1

    local function cancel_spectate()
        button_r1_value = false
        local value_1_7 = captured_value_5
        if not value_1_7.Character then
        else
            local character_value_4 = value_1_7.Character
            local value_4_7: string = "Humanoid"
            local find_first_child_of_class_result_2 = character_value_4:FindFirstChildOfClass(
                value_4_7
            )
            if not find_first_child_of_class_result_2 then
            else
                value_11 = value_1_7
                local value_3_11: Camera = captured_value_6
                value_3_11.CameraSubject = find_first_child_of_class_result_2
            end
        end
        local value_1_8: Instance = captured_value_7
        local value_3_12: string = "SpectateLeft"
        value_1_8:UnbindAction(value_3_12)
        local value_1_10: Instance = captured_value_7
        local value_3_13: string = "SpectateRight"
        value_1_10:UnbindAction(value_3_13)
        captured_value_8.SpectateCancelled:Fire()

        return
    end
end
local cancel_spectate_2
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12 = local_player_value, current_camera_value, context_action_service, table_1
    cancel_spectate_2 = function<T1>(argument_1_2: T1)
        button_r1_value = false
        local value_2_13 = captured_value_9
        if not value_2_13.Character then
        else
            local character_value_6 = value_2_13.Character
            local value_5_4: string = "Humanoid"
            local find_first_child_of_class_result_3 = character_value_6:FindFirstChildOfClass(
                value_5_4
            )
            if not find_first_child_of_class_result_3 then
            else
                value_11 = value_2_13
                local value_4_9: Camera = captured_value_10
                value_4_9.CameraSubject = find_first_child_of_class_result_3
            end
        end
        local value_2_14: Instance = captured_value_11
        local value_4_10: string = "SpectateLeft"
        value_2_14:UnbindAction(value_4_10)
        local value_2_16: Instance = captured_value_11
        local value_4_11: string = "SpectateRight"
        value_2_16:UnbindAction(value_4_11)
        captured_value_12.SpectateCancelled:Fire()

        return
    end
end
table_1.CancelSpectate = cancel_spectate_2
do
    local captured_value_13, captured_value_14, captured_value_15, captured_value_16 = current_camera_value, table_1, local_player_value, context_action_service

    local function update_camera_focus()
        local value_1_14 = button_l1_value[value_10]
        if value_1_14 then
            if button_r1_value then
                if not value_1_14.Character then
                else
                    local character_value_8 = value_1_14.Character
                    local value_4_12: string = "Humanoid"
                    local find_first_child_of_class_result_4 = character_value_8:FindFirstChildOfClass(
                        value_4_12
                    )
                    if not find_first_child_of_class_result_4 then
                    else
                        value_11 = value_1_14
                        local value_3_20: Camera = captured_value_13
                        value_3_20.CameraSubject = find_first_child_of_class_result_4
                    end
                end
                local spectate_target_changed_value = captured_value_14.SpectateTargetChanged
                local value_4_13 = value_1_14
                spectate_target_changed_value:Fire(value_4_13)

                return
            end
        end
        button_r1_value = false
        local value_2_26 = captured_value_15
        if not value_2_26.Character then
        else
            local character_value_10 = value_2_26.Character
            local value_5_5: string = "Humanoid"
            local find_first_child_of_class_result_5 = character_value_10:FindFirstChildOfClass(
                value_5_5
            )
            if not find_first_child_of_class_result_5 then
            else
                value_11 = value_2_26
                local value_4_15: Camera = captured_value_13
                value_4_15.CameraSubject = find_first_child_of_class_result_5
            end
        end
        local value_2_27: Instance = captured_value_16
        local value_4_16: string = "SpectateLeft"
        value_2_27:UnbindAction(value_4_16)
        local value_2_29: Instance = captured_value_16
        local value_4_17: string = "SpectateRight"
        value_2_29:UnbindAction(value_4_17)
        captured_value_14.SpectateCancelled:Fire()

        return
    end
end
local update_spectatable_players
do
    local captured_value_17, captured_value_18 = require_result, local_player_value
    update_spectatable_players = function()
        button_l1_value = {}
        local table_1_2 = captured_value_17.PlayerData
        local value_2_33: nil = nil
        local value_3_26: nil = nil
        for key, value in table_1_2, value_2_33, value_3_26 do
            local value_4_18, value_5_6 = key, value
            local value_6_4 = captured_value_18
            local name_value_3 = value_6_4.Name
            if value_4_18 == name_value_3 then
                continue
            end
            local game_value_4: DataModel = game
            local players_value_2 = game_value_4.Players
            local value_8 = value_4_18
            local find_first_child_result = players_value_2:FindFirstChild(value_8)
            if not find_first_child_result then
                continue
            end
            local dead_value_2 = value_5_6.Dead
            if dead_value_2 == true then
                continue
            end
            local value_8_2 = button_l1_value
            local value_9 = find_first_child_result
            local insert_value = table.insert
            insert_value(value_8_2, value_9)
        end

        return
    end
end
local navigate_spectate
do
    local captured_value_19, captured_value_20, captured_value_21, captured_value_22 = current_camera_value, table_1, local_player_value, context_action_service
    navigate_spectate = function<T1>(argument_1_3: T1, argument_2: number)
        value_10 = value_10 + argument_2
        local value_3_29 = value_10
        if #button_l1_value < value_3_29 then
            value_10 = 1
        else
            if value_10 < 1 then
                value_10 = #button_l1_value
            end
        end
        local value_3_33 = button_l1_value[value_10]
        if value_3_33 then
            if button_r1_value then
                if not value_3_33.Character then
                else
                    local character_value_12 = value_3_33.Character
                    local value_6_6: string = "Humanoid"
                    local find_first_child_of_class_result_6 = character_value_12:FindFirstChildOfClass(
                        value_6_6
                    )
                    if not find_first_child_of_class_result_6 then
                    else
                        value_11 = value_3_33
                        local value_5_10: Camera = captured_value_19
                        value_5_10.CameraSubject = find_first_child_of_class_result_6
                    end
                end
                local spectate_target_changed_value_2 = captured_value_20.SpectateTargetChanged
                local value_6_7 = value_3_33
                spectate_target_changed_value_2:Fire(value_6_7)

                return
            end
        end
        button_r1_value = false
        local value_4_28 = captured_value_21
        if not value_4_28.Character then
        else
            local character_value_14 = value_4_28.Character
            local value_7_2: string = "Humanoid"
            local find_first_child_of_class_result_7 = character_value_14:FindFirstChildOfClass(
                value_7_2
            )
            if not find_first_child_of_class_result_7 then
            else
                value_11 = value_4_28
                local value_6_9: Camera = captured_value_19
                value_6_9.CameraSubject = find_first_child_of_class_result_7
            end
        end
        local value_4_29: Instance = captured_value_22
        local value_6_10: string = "SpectateLeft"
        value_4_29:UnbindAction(value_6_10)
        local value_4_31: Instance = captured_value_22
        local value_6_11: string = "SpectateRight"
        value_4_31:UnbindAction(value_6_11)
        captured_value_20.SpectateCancelled:Fire()

        return
    end
end
table_1.NavigateSpectate = navigate_spectate
local on_spectate_keybind
do
    local captured_value_23 = table_1
    on_spectate_keybind = function<T3>(argument_1_4: string, argument_2_2, argument_3: T3)
        if argument_2_2 ~= Enum.UserInputState.Begin then
            return
        end
        if argument_1_4 == "SpectateLeft" then
            local value_4_35 = captured_value_23
            local value_6_12: number = -1
            value_4_35:NavigateSpectate(value_6_12)

            return
        end
        local value_4_37 = captured_value_23
        local value_6_13: number = 1
        value_4_37:NavigateSpectate(value_6_13)

        return
    end
end
do
    local captured_value_24, captured_value_25, captured_value_26, captured_value_27 = context_action_service, on_spectate_keybind, table_6, table_7

    local function bind_spectate_keybinds()
        local value_1_15: Instance = captured_value_24
        local value_3_34: string = "SpectateLeft"
        local value_4_39 = captured_value_25
        local value_5_18: boolean = false
        local value_7_3 = captured_value_26
        local unpack_value = unpack
        ;(function(...)
            return value_1_15:BindAction(value_3_34, value_4_39, value_5_18, ...)
        end)(unpack_value(value_7_3))
        local value_1_17: Instance = captured_value_24
        local value_3_35: string = "SpectateRight"
        local value_4_40 = captured_value_25
        local value_5_19: boolean = false
        local value_7_4 = captured_value_27
        local unpack_value_2 = unpack
        ;(function(...)
            return value_1_17:BindAction(value_3_35, value_4_40, value_5_19, ...)
        end)(unpack_value_2(value_7_4))

        return
    end
end
do
    local captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35 = table_1, update_spectatable_players, current_camera_value, local_player_value, context_action_service, on_spectate_keybind, table_6, table_7

    local function begin_spectate()
        local character_value_15, character_value_16, character_value_17, character_value_18, find_first_child_of_class_result_8, find_first_child_of_class_result_9, spectate_cancelled_value_5, spectate_started_value, spectate_target_changed_value_3, unpack_value_3, unpack_value_4, value_1_19, value_1_20, value_1_21, value_1_23, value_1_24, value_1_25, value_1_27, value_2_37, value_2_38, value_2_40, value_2_42, value_2_43, value_2_44, value_2_46, value_2_48, value_3_36, value_3_38, value_3_44, value_3_45, value_4_41, value_4_42, value_4_44, value_4_45, value_4_46, value_4_47, value_4_48, value_5_20, value_5_21, value_5_22, value_7_5, value_7_6
        local control_state = 0
        while true do
            if control_state < 7 then
                if control_state < 3 then
                    if control_state < 1 then
                        value_1_19 = true
                        button_r1_value = value_1_19
                        value_1_20 = 1
                        value_10 = value_1_20
                        value_1_21 = captured_value_28
                        spectate_started_value = value_1_21.SpectateStarted
                        spectate_started_value:Fire()
                        value_1_23 = captured_value_29
                        value_1_23()
                        value_2_37 = button_l1_value
                        value_3_36 = value_10
                        value_1_24 = value_2_37[value_3_36]
                        control_state = if not value_1_24 then 8 else 1
                    else
                        if control_state < 2 then
                            value_2_38 = button_r1_value
                            control_state = if not value_2_38 then 8 else 2
                        else
                            character_value_15 = value_1_24.Character
                            control_state = if character_value_15 then 4 else 3
                        end
                    end
                else
                    if control_state < 5 then
                        if control_state < 4 then
                            control_state = 7
                        else
                            character_value_16 = value_1_24.Character
                            value_4_41 = "Humanoid"
                            find_first_child_of_class_result_8 = character_value_16:FindFirstChildOfClass(
                                value_4_41
                            )
                            control_state = if find_first_child_of_class_result_8 then 6 else 5
                        end
                    else
                        if control_state < 6 then
                            control_state = 7
                        else
                            value_11 = value_1_24
                            value_3_38 = captured_value_30
                            value_3_38.CameraSubject = find_first_child_of_class_result_8
                            control_state = 7
                        end
                    end
                end
            else
                if control_state < 11 then
                    if control_state < 9 then
                        if control_state < 8 then
                            value_2_40 = captured_value_28
                            spectate_target_changed_value_3 = value_2_40.SpectateTargetChanged
                            value_4_42 = value_1_24
                            spectate_target_changed_value_3:Fire(value_4_42)
                            control_state = 14
                        else
                            value_2_42 = false
                            button_r1_value = value_2_42
                            value_2_43 = captured_value_31
                            character_value_17 = value_2_43.Character
                            control_state = if character_value_17 then 10 else 9
                        end
                    else
                        if control_state < 10 then
                            control_state = 13
                        else
                            character_value_18 = value_2_43.Character
                            value_5_20 = "Humanoid"
                            find_first_child_of_class_result_9 = character_value_18:FindFirstChildOfClass(
                                value_5_20
                            )
                            control_state = if find_first_child_of_class_result_9 then 12 else 11
                        end
                    end
                else
                    if control_state < 13 then
                        if control_state < 12 then
                            control_state = 13
                        else
                            value_11 = value_2_43
                            value_4_44 = captured_value_30
                            value_4_44.CameraSubject = find_first_child_of_class_result_9
                            control_state = 13
                        end
                    else
                        if control_state < 14 then
                            value_2_44 = captured_value_32
                            value_4_45 = "SpectateLeft"
                            value_2_44:UnbindAction(value_4_45)
                            value_2_46 = captured_value_32
                            value_4_46 = "SpectateRight"
                            value_2_46:UnbindAction(value_4_46)
                            value_2_48 = captured_value_28
                            spectate_cancelled_value_5 = value_2_48.SpectateCancelled
                            spectate_cancelled_value_5:Fire()
                            control_state = 14
                        else
                            value_1_25 = captured_value_32
                            value_3_44 = "SpectateLeft"
                            value_4_47 = captured_value_33
                            value_5_21 = false
                            value_7_5 = captured_value_34
                            unpack_value_3 = unpack
                            ;(function(...)
                                return value_1_25:BindAction(
                                    value_3_44,
                                    value_4_47,
                                    value_5_21,
                                    ...
                                )
                            end)(unpack_value_3(value_7_5))
                            value_1_27 = captured_value_32
                            value_3_45 = "SpectateRight"
                            value_4_48 = captured_value_33
                            value_5_22 = false
                            value_7_6 = captured_value_35
                            unpack_value_4 = unpack
                            ;(function(...)
                                return value_1_27:BindAction(
                                    value_3_45,
                                    value_4_48,
                                    value_5_22,
                                    ...
                                )
                            end)(unpack_value_4(value_7_6))

                            return
                        end
                    end
                end
            end
        end
    end
end
local toggle_spectate
do
    local captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44 = require_result, local_player_value, table_1, update_spectatable_players, current_camera_value, context_action_service, on_spectate_keybind, table_6, table_7
    toggle_spectate = function<T1>(argument_1_5: T1)
        local character_value_19, character_value_20, character_value_21, character_value_22, character_value_23, character_value_24, dead_value_3, find_first_child_of_class_result_10, find_first_child_of_class_result_11, find_first_child_of_class_result_12, name_value_4, name_value_5, player_data_value_3, player_data_value_4, spectate_cancelled_value_6, spectate_cancelled_value_7, spectate_started_value_2, spectate_target_changed_value_4, unpack_value_5, unpack_value_6, value_2_52, value_2_53, value_2_54, value_2_55, value_2_56, value_2_58, value_2_59, value_2_60, value_2_62, value_2_64, value_2_65, value_2_66, value_2_68, value_2_70, value_3_46, value_3_47, value_3_49, value_3_50, value_3_52, value_3_54, value_3_55, value_3_56, value_3_58, value_3_60, value_4_49, value_4_50, value_4_51, value_4_53, value_4_59, value_4_60, value_4_62, value_4_63, value_4_64, value_5_23, value_5_24, value_5_25, value_5_27, value_5_28, value_5_29, value_5_30, value_5_31, value_5_32, value_6_14, value_6_15, value_6_16, value_8_3, value_8_4
        local control_state_2 = 0
        while true do
            if control_state_2 < 13 then
                if control_state_2 < 6 then
                    if control_state_2 < 3 then
                        if control_state_2 < 1 then
                            value_2_52 = button_r1_value
                            control_state_2 = if value_2_52 then 21 else 1
                        else
                            if control_state_2 < 2 then
                                value_3_46 = captured_value_36
                                player_data_value_3 = value_3_46.PlayerData
                                value_4_49 = captured_value_37
                                name_value_4 = value_4_49.Name
                                value_2_53 = player_data_value_3[name_value_4]
                                control_state_2 = if not value_2_53 then 5 else 2
                            else
                                value_4_50 = captured_value_36
                                player_data_value_4 = value_4_50.PlayerData
                                value_5_23 = captured_value_37
                                name_value_5 = value_5_23.Name
                                value_3_47 = player_data_value_4[name_value_5]
                                dead_value_3 = value_3_47.Dead
                                control_state_2 = if dead_value_3 ~= true then 4 else 3
                            end
                        end
                    else
                        if control_state_2 < 4 then
                            value_2_53 = false
                            control_state_2 = 5
                        else
                            if control_state_2 < 5 then
                                value_2_53 = true
                                control_state_2 = 5
                            else
                                control_state_2 = if value_2_53 then 21 else 6
                            end
                        end
                    end
                else
                    if control_state_2 < 9 then
                        if control_state_2 < 7 then
                            value_2_54 = true
                            button_r1_value = value_2_54
                            value_2_55 = 1
                            value_10 = value_2_55
                            value_2_56 = captured_value_38
                            spectate_started_value_2 = value_2_56.SpectateStarted
                            spectate_started_value_2:Fire()
                            value_2_58 = captured_value_39
                            value_2_58()
                            value_3_49 = button_l1_value
                            value_4_51 = value_10
                            value_2_59 = value_3_49[value_4_51]
                            control_state_2 = if not value_2_59 then 14 else 7
                        else
                            if control_state_2 < 8 then
                                value_3_50 = button_r1_value
                                control_state_2 = if not value_3_50 then 14 else 8
                            else
                                character_value_19 = value_2_59.Character
                                control_state_2 = if character_value_19 then 10 else 9
                            end
                        end
                    else
                        if control_state_2 < 11 then
                            if control_state_2 < 10 then
                                control_state_2 = 13
                            else
                                character_value_20 = value_2_59.Character
                                value_5_24 = "Humanoid"
                                find_first_child_of_class_result_10 = character_value_20:FindFirstChildOfClass(
                                    value_5_24
                                )
                                control_state_2 = if find_first_child_of_class_result_10 then 12 else 11
                            end
                        else
                            if control_state_2 < 12 then
                                control_state_2 = 13
                            else
                                value_11 = value_2_59
                                value_4_53 = captured_value_40
                                value_4_53.CameraSubject = find_first_child_of_class_result_10
                                control_state_2 = 13
                            end
                        end
                    end
                end
            else
                if control_state_2 < 20 then
                    if control_state_2 < 16 then
                        if control_state_2 < 14 then
                            value_3_52 = captured_value_38
                            spectate_target_changed_value_4 = value_3_52.SpectateTargetChanged
                            value_5_25 = value_2_59
                            spectate_target_changed_value_4:Fire(value_5_25)
                            control_state_2 = 20
                        else
                            if control_state_2 < 15 then
                                value_3_54 = false
                                button_r1_value = value_3_54
                                value_3_55 = captured_value_37
                                character_value_21 = value_3_55.Character
                                control_state_2 = if character_value_21 then 16 else 15
                            else
                                control_state_2 = 19
                            end
                        end
                    else
                        if control_state_2 < 18 then
                            if control_state_2 < 17 then
                                character_value_22 = value_3_55.Character
                                value_6_14 = "Humanoid"
                                find_first_child_of_class_result_11 = character_value_22:FindFirstChildOfClass(
                                    value_6_14
                                )
                                control_state_2 = if find_first_child_of_class_result_11 then 18 else 17
                            else
                                control_state_2 = 19
                            end
                        else
                            if control_state_2 < 19 then
                                value_11 = value_3_55
                                value_5_27 = captured_value_40
                                value_5_27.CameraSubject = find_first_child_of_class_result_11
                                control_state_2 = 19
                            else
                                value_3_56 = captured_value_41
                                value_5_28 = "SpectateLeft"
                                value_3_56:UnbindAction(value_5_28)
                                value_3_58 = captured_value_41
                                value_5_29 = "SpectateRight"
                                value_3_58:UnbindAction(value_5_29)
                                value_3_60 = captured_value_38
                                spectate_cancelled_value_6 = value_3_60.SpectateCancelled
                                spectate_cancelled_value_6:Fire()
                                control_state_2 = 20
                            end
                        end
                    end
                else
                    if control_state_2 < 23 then
                        if control_state_2 < 21 then
                            value_2_60 = captured_value_41
                            value_4_59 = "SpectateLeft"
                            value_5_30 = captured_value_42
                            value_6_15 = false
                            value_8_3 = captured_value_43
                            unpack_value_5 = unpack
                            ;(function(...)
                                return value_2_60:BindAction(
                                    value_4_59,
                                    value_5_30,
                                    value_6_15,
                                    ...
                                )
                            end)(unpack_value_5(value_8_3))
                            value_2_62 = captured_value_41
                            value_4_60 = "SpectateRight"
                            value_5_31 = captured_value_42
                            value_6_16 = false
                            value_8_4 = captured_value_44
                            unpack_value_6 = unpack
                            ;(function(...)
                                return value_2_62:BindAction(
                                    value_4_60,
                                    value_5_31,
                                    value_6_16,
                                    ...
                                )
                            end)(unpack_value_6(value_8_4))

                            return
                        else
                            if control_state_2 < 22 then
                                value_2_64 = false
                                button_r1_value = value_2_64
                                value_2_65 = captured_value_37
                                character_value_23 = value_2_65.Character
                                control_state_2 = if character_value_23 then 23 else 22
                            else
                                control_state_2 = 26
                            end
                        end
                    else
                        if control_state_2 < 25 then
                            if control_state_2 < 24 then
                                character_value_24 = value_2_65.Character
                                value_5_32 = "Humanoid"
                                find_first_child_of_class_result_12 = character_value_24:FindFirstChildOfClass(
                                    value_5_32
                                )
                                control_state_2 = if find_first_child_of_class_result_12 then 25 else 24
                            else
                                control_state_2 = 26
                            end
                        else
                            if control_state_2 < 26 then
                                value_11 = value_2_65
                                value_4_62 = captured_value_40
                                value_4_62.CameraSubject = find_first_child_of_class_result_12
                                control_state_2 = 26
                            else
                                value_2_66 = captured_value_41
                                value_4_63 = "SpectateLeft"
                                value_2_66:UnbindAction(value_4_63)
                                value_2_68 = captured_value_41
                                value_4_64 = "SpectateRight"
                                value_2_68:UnbindAction(value_4_64)
                                value_2_70 = captured_value_38
                                spectate_cancelled_value_7 = value_2_70.SpectateCancelled
                                spectate_cancelled_value_7:Fire()

                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
table_1.ToggleSpectate = toggle_spectate
local on_player_data_updated
do
    local captured_value_45, captured_value_46, captured_value_47, captured_value_48, captured_value_49, captured_value_50 = require_result, local_player_value, current_camera_value, context_action_service, table_1, update_spectatable_players
    on_player_data_updated = function()
        local value_1_29 = captured_value_45.PlayerData[captured_value_46.Name]
        if value_1_29 then
            if captured_value_45.PlayerData[captured_value_46.Name].Dead == true then
                value_1_29 = false
            else
                value_1_29 = true
            end
        end
        if value_1_29 then
            button_r1_value = false
            local value_1_31 = captured_value_46
            if not value_1_31.Character then
            else
                local character_value_26 = value_1_31.Character
                local value_4_66: string = "Humanoid"
                local find_first_child_of_class_result_13 = character_value_26:FindFirstChildOfClass(
                    value_4_66
                )
                if not find_first_child_of_class_result_13 then
                else
                    value_11 = value_1_31
                    local value_3_71: Camera = captured_value_47
                    value_3_71.CameraSubject = find_first_child_of_class_result_13
                end
            end
            local value_1_32: Instance = captured_value_48
            local value_3_72: string = "SpectateLeft"
            value_1_32:UnbindAction(value_3_72)
            local value_1_34: Instance = captured_value_48
            local value_3_73: string = "SpectateRight"
            value_1_34:UnbindAction(value_3_73)
            captured_value_49.SpectateCancelled:Fire()
        end
        captured_value_50()
        while true do
            local value_2_78 = button_l1_value
            local value_3_74 = value_10
            local value_1_39 = value_2_78[value_3_74]
            if value_1_39 ~= nil then
                break
            end
            local value_1_40 = value_10
            local value_2_79: number = 1
            if not (value_2_79 < value_1_40) then
                break
            end
            local value_1_41 = value_10
            local value_1_42 = value_1_41 - 1
            value_10 = value_1_42
        end
        if button_r1_value then
            local value_1_44 = button_l1_value[value_10]
            if value_1_44 then
                if button_r1_value then
                    if not value_1_44.Character then
                    else
                        local character_value_28 = value_1_44.Character
                        local value_4_67: string = "Humanoid"
                        local find_first_child_of_class_result_14 = character_value_28:FindFirstChildOfClass(
                            value_4_67
                        )
                        if not find_first_child_of_class_result_14 then
                        else
                            value_11 = value_1_44
                            local value_3_77: Camera = captured_value_47
                            value_3_77.CameraSubject = find_first_child_of_class_result_14
                        end
                    end
                    local spectate_target_changed_value_5 = captured_value_49.SpectateTargetChanged
                    local value_4_68 = value_1_44
                    spectate_target_changed_value_5:Fire(value_4_68)

                    return
                end
            end
            button_r1_value = false
            local value_2_86 = captured_value_46
            if not value_2_86.Character then
            else
                local character_value_30 = value_2_86.Character
                local value_5_33: string = "Humanoid"
                local find_first_child_of_class_result_15 = character_value_30:FindFirstChildOfClass(
                    value_5_33
                )
                if not find_first_child_of_class_result_15 then
                else
                    value_11 = value_2_86
                    local value_4_70: Camera = captured_value_47
                    value_4_70.CameraSubject = find_first_child_of_class_result_15
                end
            end
            local value_2_87: Instance = captured_value_48
            local value_4_71: string = "SpectateLeft"
            value_2_87:UnbindAction(value_4_71)
            local value_2_89: Instance = captured_value_48
            local value_4_72: string = "SpectateRight"
            value_2_89:UnbindAction(value_4_72)
            captured_value_49.SpectateCancelled:Fire()
        end

        return
    end
end
update_spectatable_players()
local event_value = require_result.PlayerDataChanged.Event
local value_24 = on_player_data_updated
event_value:Connect(value_24)

return table_1
