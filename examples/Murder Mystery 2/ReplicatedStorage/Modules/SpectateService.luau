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
local table_6 = {Enum.KeyCode.Q}
local table_7 = {nil}
local e_value = Enum.KeyCode.E
table_7[1] = e_value
e_value = {}
local value_9 = nil
local script_value: LuaSourceContainer = script
local value_12: string = "SpectateStarted"
local spectate_started_child: Instance? = script_value:WaitForChild(value_12)
table_1.SpectateStarted = spectate_started_child
local script_value_2: LuaSourceContainer = script
local value_12_2: string = "SpectateCancelled"
local spectate_cancelled_child: Instance? = script_value_2:WaitForChild(value_12_2)
table_1.SpectateCancelled = spectate_cancelled_child
local script_value_3: LuaSourceContainer = script
local value_12_3: string = "SpectateTargetChanged"
local spectate_target_changed_child: Instance? = script_value_3:WaitForChild(value_12_3)
table_1.SpectateTargetChanged = spectate_target_changed_child
do
    local captured_value = require_result
    local get_player_round_data
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        get_player_round_data = closure_cache[1]
    else
        local closure_ready
        get_player_round_data = function(argument_1)
            if not closure_ready then
                return
            end

            return captured_value.PlayerData[argument_1.Name]
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = get_player_round_data
            closure_cache[2] = captured_value
        end
    end
end
do
    local captured_value_2 = require_result
    local player_is_alive
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) then
        player_is_alive = closure_cache[3]
    else
        local closure_ready_2
        player_is_alive = function(argument_1_2): (...boolean)
            if not closure_ready_2 then
                return
            end
            local value_2_3 = captured_value_2.PlayerData[argument_1_2.Name]
            if not value_2_3 then
                return false
            end
            local value_3_5: boolean?
            if value_2_3.Dead == true then
                value_3_5 = false
            else
                value_3_5 = true
            end

            return value_3_5
        end
        closure_ready_2 = true
        if closure_cache[3] == nil then
            closure_cache[3] = player_is_alive
            closure_cache[4] = captured_value_2
        end
    end
end
do
    local captured_value_3 = require_result
    local is_player_spectatable
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_3) then
        is_player_spectatable = closure_cache[5]
    else
        local closure_ready_3
        is_player_spectatable = function(argument_1_3): (...boolean)
            if not closure_ready_3 then
                return
            end
            if argument_1_3 == nil then
                return false
            end
            if argument_1_3.Parent == nil then
                return false
            end
            if not argument_1_3.Character then
                return false
            end
            local character_value_4 = argument_1_3.Character
            local value_4_5: string = "Humanoid"
            if not (character_value_4:FindFirstChildOfClass(value_4_5)) then
                return false
            end
            local value_2_8 = captured_value_3.PlayerData[argument_1_3.Name]
            local value_3_8: boolean?
            if not value_2_8 then
                value_3_8 = false
            else
                if value_2_8.Dead == true then
                    value_3_8 = false
                else
                    value_3_8 = true
                end
            end
            if not value_3_8 then
                return false
            end

            return true
        end
        closure_ready_3 = true
        if closure_cache[5] == nil then
            closure_cache[5] = is_player_spectatable
            closure_cache[6] = captured_value_3
        end
    end
end
do
    local captured_value_4, captured_value_5 = local_player_value, current_camera_value
    local reset_camera
    if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_4) and same_capture(
        closure_cache[9],
        captured_value_5
    ) then
        reset_camera = closure_cache[7]
    else
        local closure_ready_4
        reset_camera = function(): ()
            if not closure_ready_4 then
                return
            end
            if not captured_value_4.Character then
                local value_1_2: Camera = captured_value_5
                local value_2_9: nil = nil
                value_1_2.CameraSubject = value_2_9

                return
            end
            local character_value_6 = captured_value_4.Character
            local value_3_11: string = "Humanoid"
            local find_first_child_of_class_result_3 = character_value_6:FindFirstChildOfClass(
                value_3_11
            )
            if not find_first_child_of_class_result_3 then
                local value_2_11: Camera = captured_value_5
                local value_3_12: nil = nil
                value_2_11.CameraSubject = value_3_12

                return
            end
            local value_2_12: Camera = captured_value_5
            value_2_12.CameraSubject = find_first_child_of_class_result_3

            return
        end
        closure_ready_4 = true
        if closure_cache[7] == nil then
            closure_cache[7] = reset_camera
            closure_cache[8], closure_cache[9] = captured_value_4, captured_value_5
        end
    end
end
do
    local captured_value_6 = context_action_service
    local unbind_spectate_keybind
    if closure_cache[10] ~= nil and same_capture(closure_cache[11], captured_value_6) then
        unbind_spectate_keybind = closure_cache[10]
    else
        local closure_ready_5
        unbind_spectate_keybind = function(): ()
            if not closure_ready_5 then
                return
            end
            local value_1_5: Instance = captured_value_6
            local value_3_13: string = "SpectateLeft"
            value_1_5:UnbindAction(value_3_13)
            local value_1_7: Instance = captured_value_6
            local value_3_14: string = "SpectateRight"
            value_1_7:UnbindAction(value_3_14)

            return
        end
        closure_ready_5 = true
        if closure_cache[10] == nil then
            closure_cache[10] = unbind_spectate_keybind
            closure_cache[11] = captured_value_6
        end
    end
end
do
    local captured_value_7, captured_value_8, captured_value_9, captured_value_10 = local_player_value, current_camera_value, context_action_service, table_1
    local cancel_spectate
    if closure_cache[12] ~= nil and same_capture(closure_cache[13], captured_value_7) and same_capture(
        closure_cache[14],
        captured_value_8
    ) and same_capture(closure_cache[15], captured_value_9) and same_capture(
        closure_cache[16],
        captured_value_10
    ) then
        cancel_spectate = closure_cache[12]
    else
        local closure_ready_6
        cancel_spectate = function()
            if not closure_ready_6 then
                return
            end
            local value_1_9: boolean = false
            isSpectating = value_1_9
            if not captured_value_7.Character then
                local value_1_11: Camera = captured_value_8
                local value_2_15: nil = nil
                value_1_11.CameraSubject = value_2_15
            else
                local character_value_8 = captured_value_7.Character
                local value_3_15: string = "Humanoid"
                local find_first_child_of_class_result_4 = character_value_8:FindFirstChildOfClass(
                    value_3_15
                )
                if not find_first_child_of_class_result_4 then
                    local value_2_17: Camera = captured_value_8
                    local value_3_16: nil = nil
                    value_2_17.CameraSubject = value_3_16
                else
                    local value_2_18: Camera = captured_value_8
                    value_2_18.CameraSubject = find_first_child_of_class_result_4
                end
            end
            local value_1_14: Instance = captured_value_9
            local value_3_17: string = "SpectateLeft"
            value_1_14:UnbindAction(value_3_17)
            local value_1_16: Instance = captured_value_9
            local value_3_18: string = "SpectateRight"
            value_1_16:UnbindAction(value_3_18)
            captured_value_10.SpectateCancelled:Fire()

            return
        end
        closure_ready_6 = true
        if closure_cache[12] == nil then
            closure_cache[12] = cancel_spectate
            closure_cache[13], closure_cache[14], closure_cache[15], closure_cache[16] = captured_value_7, captured_value_8, captured_value_9, captured_value_10
        end
    end
end
local update_camera_focus: (() -> ())?
do
    local captured_value_11, captured_value_12, captured_value_13, captured_value_14, closure_ready_7
    update_camera_focus = function(): ()
        if not closure_ready_7 then
            return
        end
        if not isSpectating then
            return
        end
        if value_9 == nil then
            local value_1_21: boolean = false
            isSpectating = value_1_21
            if not captured_value_11.Character then
                local value_1_23: Camera? = captured_value_12
                local value_2_22: nil = nil
                value_1_23.CameraSubject = value_2_22
            else
                local character_value_10 = captured_value_11.Character
                local value_3_19: string = "Humanoid"
                local find_first_child_of_class_result_5 = character_value_10:FindFirstChildOfClass(
                    value_3_19
                )
                if not find_first_child_of_class_result_5 then
                    local value_2_24: Camera? = captured_value_12
                    local value_3_20: nil = nil
                    value_2_24.CameraSubject = value_3_20
                else
                    local value_2_25: Camera? = captured_value_12
                    value_2_25.CameraSubject = find_first_child_of_class_result_5
                end
            end
            local value_1_26: Instance? = captured_value_13
            local value_3_21: string = "SpectateLeft"
            value_1_26:UnbindAction(value_3_21)
            local value_1_28: Instance? = captured_value_13
            local value_3_22: string = "SpectateRight"
            value_1_28:UnbindAction(value_3_22)
            captured_value_14.SpectateCancelled:Fire()

            return
        end
        if not value_9.Character then
            local value_1_33: boolean = false
            isSpectating = value_1_33
            if not captured_value_11.Character then
                local value_1_35: Camera? = captured_value_12
                local value_2_29: nil = nil
                value_1_35.CameraSubject = value_2_29
            else
                local character_value_13 = captured_value_11.Character
                local value_3_23: string = "Humanoid"
                local find_first_child_of_class_result_6 = character_value_13:FindFirstChildOfClass(
                    value_3_23
                )
                if not find_first_child_of_class_result_6 then
                    local value_2_31: Camera? = captured_value_12
                    local value_3_24: nil = nil
                    value_2_31.CameraSubject = value_3_24
                else
                    local value_2_32: Camera? = captured_value_12
                    value_2_32.CameraSubject = find_first_child_of_class_result_6
                end
            end
            local value_1_38: Instance? = captured_value_13
            local value_3_25: string = "SpectateLeft"
            value_1_38:UnbindAction(value_3_25)
            local value_1_40: Instance? = captured_value_13
            local value_3_26: string = "SpectateRight"
            value_1_40:UnbindAction(value_3_26)
            captured_value_14.SpectateCancelled:Fire()

            return
        end
        local character_value_14 = value_9.Character
        local value_3_27: string = "Humanoid"
        local find_first_child_of_class_result_7 = character_value_14:FindFirstChildOfClass(
            value_3_27
        )
        if not find_first_child_of_class_result_7 then
            local value_2_37: boolean = false
            isSpectating = value_2_37
            if not captured_value_11.Character then
                local value_2_39: Camera? = captured_value_12
                local value_3_28: nil = nil
                value_2_39.CameraSubject = value_3_28
            else
                local character_value_16 = captured_value_11.Character
                local value_4_7: string = "Humanoid"
                local find_first_child_of_class_result_8 = character_value_16:FindFirstChildOfClass(
                    value_4_7
                )
                if not find_first_child_of_class_result_8 then
                    local value_3_30: Camera? = captured_value_12
                    local value_4_8: nil = nil
                    value_3_30.CameraSubject = value_4_8
                else
                    local value_3_31: Camera? = captured_value_12
                    value_3_31.CameraSubject = find_first_child_of_class_result_8
                end
            end
            local value_2_42: Instance? = captured_value_13
            local value_4_9: string = "SpectateLeft"
            value_2_42:UnbindAction(value_4_9)
            local value_2_44: Instance? = captured_value_13
            local value_4_10: string = "SpectateRight"
            value_2_44:UnbindAction(value_4_10)
            captured_value_14.SpectateCancelled:Fire()

            return
        end
        local value_2_48: Camera? = captured_value_12
        value_2_48.CameraSubject = find_first_child_of_class_result_7
        local spectate_target_changed_value = captured_value_14.SpectateTargetChanged
        local value_4_11 = value_9
        spectate_target_changed_value:Fire(value_4_11)

        return
    end
    captured_value_11, captured_value_12, captured_value_13, captured_value_14 = local_player_value, current_camera_value, context_action_service, table_1
    closure_ready_7 = true
end
local cancel_spectate_2
do
    local captured_value_15, captured_value_16, captured_value_17, captured_value_18 = local_player_value, current_camera_value, context_action_service, table_1
    if closure_cache[17] ~= nil and same_capture(closure_cache[18], captured_value_15) and same_capture(
        closure_cache[19],
        captured_value_16
    ) and same_capture(closure_cache[20], captured_value_17) and same_capture(
        closure_cache[21],
        captured_value_18
    ) then
        cancel_spectate_2 = closure_cache[17]
    else
        local closure_ready_8
        cancel_spectate_2 = function<T1>(argument_1_4: T1)
            if not closure_ready_8 then
                return
            end
            local value_2_51: boolean = false
            isSpectating = value_2_51
            if not captured_value_15.Character then
                local value_2_53: Camera = captured_value_16
                local value_3_36: nil = nil
                value_2_53.CameraSubject = value_3_36
            else
                local character_value_18 = captured_value_15.Character
                local value_4_12: string = "Humanoid"
                local find_first_child_of_class_result_9 = character_value_18:FindFirstChildOfClass(
                    value_4_12
                )
                if not find_first_child_of_class_result_9 then
                    local value_3_38: Camera = captured_value_16
                    local value_4_13: nil = nil
                    value_3_38.CameraSubject = value_4_13
                else
                    local value_3_39: Camera = captured_value_16
                    value_3_39.CameraSubject = find_first_child_of_class_result_9
                end
            end
            local value_2_56: Instance = captured_value_17
            local value_4_14: string = "SpectateLeft"
            value_2_56:UnbindAction(value_4_14)
            local value_2_58: Instance = captured_value_17
            local value_4_15: string = "SpectateRight"
            value_2_58:UnbindAction(value_4_15)
            captured_value_18.SpectateCancelled:Fire()

            return
        end
        closure_ready_8 = true
        if closure_cache[17] == nil then
            closure_cache[17] = cancel_spectate_2
            closure_cache[18], closure_cache[19], closure_cache[20], closure_cache[21] = captured_value_15, captured_value_16, captured_value_17, captured_value_18
        end
    end
end
table_1.CancelSpectate = cancel_spectate_2
local navigate_spectate
do
    local captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, closure_ready_9
    navigate_spectate = function<T1>(argument_1_5: T1, argument_2: number)
        if not closure_ready_9 then
            return
        end
        local find_result = table.find(e_value, value_9)
        if not find_result then
            local value_4_17: boolean = false
            isSpectating = value_4_17
            if not captured_value_19.Character then
                local value_4_19: Camera? = captured_value_20
                local value_5_5: nil = nil
                value_4_19.CameraSubject = value_5_5
            else
                local character_value_20 = captured_value_19.Character
                local value_6_4: string = "Humanoid"
                local find_first_child_of_class_result_10 = character_value_20:FindFirstChildOfClass(
                    value_6_4
                )
                if not find_first_child_of_class_result_10 then
                    local value_5_7: Camera? = captured_value_20
                    local value_6_5: nil = nil
                    value_5_7.CameraSubject = value_6_5
                else
                    local value_5_8: Camera? = captured_value_20
                    value_5_8.CameraSubject = find_first_child_of_class_result_10
                end
            end
            local value_4_22: Instance? = captured_value_21
            local value_6_6: string = "SpectateLeft"
            value_4_22:UnbindAction(value_6_6)
            local value_4_24: Instance? = captured_value_21
            local value_6_7: string = "SpectateRight"
            value_4_24:UnbindAction(value_6_7)
            captured_value_22.SpectateCancelled:Fire()

            return
        end
        local value_4_28 = find_result + argument_2
        if #e_value < value_4_28 then
            value_4_28 = 1
        else
            if value_4_28 < 1 then
                value_4_28 = #e_value
            end
        end
        local value_3_43 = e_value[value_4_28]
        if value_3_43 then
            value_9 = value_3_43
            captured_value_23()

            return
        end
        local value_5_17: boolean = false
        isSpectating = value_5_17
        if not captured_value_19.Character then
            local value_5_19: Camera? = captured_value_20
            local value_6_9: nil = nil
            value_5_19.CameraSubject = value_6_9
        else
            local character_value_22 = captured_value_19.Character
            local value_6_10: string = "Humanoid"
            local find_first_child_of_class_result_11 = character_value_22:FindFirstChildOfClass(
                value_6_10
            )
            if not find_first_child_of_class_result_11 then
                local value_5_21: Camera? = captured_value_20
                local value_6_11: nil = nil
                value_5_21.CameraSubject = value_6_11
            else
                local value_5_22: Camera? = captured_value_20
                value_5_22.CameraSubject = find_first_child_of_class_result_11
            end
        end
        local value_5_23: Instance? = captured_value_21
        local value_7: string = "SpectateLeft"
        value_5_23:UnbindAction(value_7)
        local value_5_25: Instance? = captured_value_21
        local value_7_2: string = "SpectateRight"
        value_5_25:UnbindAction(value_7_2)
        captured_value_22.SpectateCancelled:Fire()

        return
    end
    captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23 = local_player_value, current_camera_value, context_action_service, table_1, update_camera_focus
    closure_ready_9 = true
end
table_1.NavigateSpectate = navigate_spectate
local on_spectate_keybind
do
    local captured_value_24 = table_1
    if closure_cache[22] ~= nil and same_capture(closure_cache[23], captured_value_24) then
        on_spectate_keybind = closure_cache[22]
    else
        local closure_ready_10
        on_spectate_keybind = function<T3>(argument_1_6: string, argument_2_2, argument_3: T3)
            if not closure_ready_10 then
                return
            end
            if argument_2_2 ~= Enum.UserInputState.Begin then
                return
            end
            if argument_1_6 == "SpectateLeft" then
                local value_4_31 = captured_value_24
                local value_6_15: number = -1
                value_4_31:NavigateSpectate(value_6_15)

                return
            end
            local value_4_33 = captured_value_24
            local value_6_16: number = 1
            value_4_33:NavigateSpectate(value_6_16)

            return
        end
        closure_ready_10 = true
        if closure_cache[22] == nil then
            closure_cache[22] = on_spectate_keybind
            closure_cache[23] = captured_value_24
        end
    end
end
do
    local captured_value_25, captured_value_26, captured_value_27, captured_value_28 = context_action_service, on_spectate_keybind, table_6, table_7
    local bind_spectate_keybinds
    if closure_cache[24] ~= nil and same_capture(closure_cache[25], captured_value_25) and same_capture(
        closure_cache[26],
        captured_value_26
    ) and same_capture(closure_cache[27], captured_value_27) and same_capture(
        closure_cache[28],
        captured_value_28
    ) then
        bind_spectate_keybinds = closure_cache[24]
    else
        local closure_ready_11
        bind_spectate_keybinds = function()
            if not closure_ready_11 then
                return
            end
            local value_1_46: Instance = captured_value_25
            local value_3_44: string = "SpectateLeft"
            local value_4_35 = captured_value_26
            local value_5_31: boolean = false
            local value_7_3 = captured_value_27
            local unpack_value = unpack
            ;(function(...)
                return value_1_46:BindAction(value_3_44, value_4_35, value_5_31, ...)
            end)(unpack_value(value_7_3))
            local value_1_48: Instance = captured_value_25
            local value_3_45: string = "SpectateRight"
            local value_4_36 = captured_value_26
            local value_5_32: boolean = false
            local value_7_4 = captured_value_28
            local unpack_value_2 = unpack
            ;(function(...)
                return value_1_48:BindAction(value_3_45, value_4_36, value_5_32, ...)
            end)(unpack_value_2(value_7_4))

            return
        end
        closure_ready_11 = true
        if closure_cache[24] == nil then
            closure_cache[24] = bind_spectate_keybinds
            closure_cache[25], closure_cache[26], closure_cache[27], closure_cache[28] = captured_value_25, captured_value_26, captured_value_27, captured_value_28
        end
    end
end
do
    local captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, closure_ready_12

    local function begin_spectate()
        if not closure_ready_12 then
            return
        end
        local value_1_50: boolean = true
        isSpectating = value_1_50
        captured_value_29.SpectateStarted:Fire()
        if value_9 == nil then
            value_9 = e_value[1]
        end
        local value_1_55: Instance? = captured_value_30
        local value_3_46: string = "SpectateLeft"
        local value_4_37 = captured_value_31
        local value_5_33: boolean = false
        local value_7_5 = captured_value_32
        local unpack_value_3 = unpack
        ;(function(...)
            return value_1_55:BindAction(value_3_46, value_4_37, value_5_33, ...)
        end)(unpack_value_3(value_7_5))
        local value_1_57: Instance? = captured_value_30
        local value_3_47: string = "SpectateRight"
        local value_4_38 = captured_value_31
        local value_5_34: boolean = false
        local value_7_6 = captured_value_33
        local unpack_value_4 = unpack
        ;(function(...)
            return value_1_57:BindAction(value_3_47, value_4_38, value_5_34, ...)
        end)(unpack_value_4(value_7_6))
        captured_value_34()

        return
    end

    captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34 = table_1, context_action_service, on_spectate_keybind, table_6, table_7, update_camera_focus
    closure_ready_12 = true
end
local toggle_spectate
do
    local captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, closure_ready_13
    toggle_spectate = function<T1>(argument_1_7: T1)
        if not closure_ready_13 then
            return
        end
        if not isSpectating then
            local value_3_48 = captured_value_35
            local value_4_39 = captured_value_36.PlayerData[value_3_48.Name]
            local value_2_68: boolean?
            if not value_4_39 then
                value_2_68 = false
            else
                if value_4_39.Dead == true then
                    value_2_68 = false
                else
                    value_2_68 = true
                end
            end
            if not value_2_68 then
                local value_2_69: boolean = true
                isSpectating = value_2_69
                captured_value_37.SpectateStarted:Fire()
                if value_9 == nil then
                    value_9 = e_value[1]
                end
                local value_2_74: Instance? = captured_value_38
                local value_4_40: string = "SpectateLeft"
                local value_5_36 = captured_value_39
                local value_6_17: boolean = false
                local value_8 = captured_value_40
                local unpack_value_5 = unpack
                ;(function(...)
                    return value_2_74:BindAction(value_4_40, value_5_36, value_6_17, ...)
                end)(unpack_value_5(value_8))
                local value_2_76: Instance? = captured_value_38
                local value_4_41: string = "SpectateRight"
                local value_5_37 = captured_value_39
                local value_6_18: boolean = false
                local value_8_2 = captured_value_41
                local unpack_value_6 = unpack
                ;(function(...)
                    return value_2_76:BindAction(value_4_41, value_5_37, value_6_18, ...)
                end)(unpack_value_6(value_8_2))
                captured_value_42()

                return
            end
        end
        local value_2_79: boolean = false
        isSpectating = value_2_79
        if not captured_value_35.Character then
            local value_2_81: Camera? = captured_value_43
            local value_3_53: nil = nil
            value_2_81.CameraSubject = value_3_53
        else
            local character_value_24 = captured_value_35.Character
            local value_4_42: string = "Humanoid"
            local find_first_child_of_class_result_12 = character_value_24:FindFirstChildOfClass(
                value_4_42
            )
            if not find_first_child_of_class_result_12 then
                local value_3_55: Camera? = captured_value_43
                local value_4_43: nil = nil
                value_3_55.CameraSubject = value_4_43
            else
                local value_3_56: Camera? = captured_value_43
                value_3_56.CameraSubject = find_first_child_of_class_result_12
            end
        end
        local value_2_84: Instance? = captured_value_38
        local value_4_44: string = "SpectateLeft"
        value_2_84:UnbindAction(value_4_44)
        local value_2_86: Instance? = captured_value_38
        local value_4_45: string = "SpectateRight"
        value_2_86:UnbindAction(value_4_45)
        captured_value_37.SpectateCancelled:Fire()

        return
    end
    captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43 = local_player_value, require_result, table_1, context_action_service, on_spectate_keybind, table_6, table_7, update_camera_focus, current_camera_value
    closure_ready_13 = true
end
table_1.ToggleSpectate = toggle_spectate
local set_spectating
do
    local captured_value_44, captured_value_45, captured_value_46, captured_value_47, captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52, closure_ready_14
    set_spectating = function<T1>(argument_1_8: T1, argument_2_3: boolean)
        if not closure_ready_14 then
            return
        end
        local character_value_25, character_value_26, dead_value_5, find_first_child_of_class_result_13, is_spectating_value_3, name_value_6, player_data_value_6, spectate_cancelled_value_9, spectate_started_value_3, unpack_value_7, unpack_value_8, value_3_60, value_3_61, value_3_62, value_3_64, value_3_65, value_3_66, value_3_68, value_3_70, value_3_71, value_3_72, value_3_73, value_3_74, value_3_75, value_3_76, value_3_78, value_3_80, value_3_82, value_4_46, value_4_48, value_4_51: nil, value_4_53, value_4_54, value_5_38, value_5_39, value_5_40, value_5_41, value_5_42: nil, value_5_43, value_5_44, value_6_19, value_6_20, value_6_21, value_7_7, value_7_8, value_9_2, value_9_3
        local control_state = 0
        while true do
            if control_state < 9 then
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            is_spectating_value_3 = isSpectating
                            control_state = if is_spectating_value_3 then 13 else 1
                        else
                            value_4_46 = captured_value_44
                            value_6_19 = captured_value_45
                            player_data_value_6 = value_6_19.PlayerData
                            name_value_6 = value_4_46.Name
                            value_5_38 = player_data_value_6[name_value_6]
                            control_state = if value_5_38 then 3 else 2
                        end
                    else
                        if control_state < 3 then
                            value_3_60 = false
                            control_state = 6
                        else
                            dead_value_5 = value_5_38.Dead
                            control_state = if dead_value_5 ~= true then 5 else 4
                        end
                    end
                else
                    if control_state < 6 then
                        if control_state < 5 then
                            value_3_60 = false
                            control_state = 6
                        else
                            value_3_60 = true
                            control_state = 6
                        end
                    else
                        if control_state < 7 then
                            control_state = if value_3_60 then 13 else 7
                        else
                            if control_state < 8 then
                                control_state = if not argument_2_3 then 13 else 8
                            else
                                value_3_61 = true
                                isSpectating = value_3_61
                                value_3_62 = captured_value_46
                                spectate_started_value_3 = value_3_62.SpectateStarted
                                spectate_started_value_3:Fire()
                                value_3_64 = value_9
                                control_state = if value_3_64 ~= nil then 10 else 9
                            end
                        end
                    end
                end
            else
                if control_state < 15 then
                    if control_state < 11 then
                        if control_state < 10 then
                            value_4_48 = e_value
                            value_3_65 = value_4_48[1]
                            value_9 = value_3_65
                            control_state = 10
                        else
                            value_3_66 = captured_value_47
                            value_5_39 = "SpectateLeft"
                            value_6_20 = captured_value_48
                            value_7_7 = false
                            value_9_2 = captured_value_49
                            unpack_value_7 = unpack
                            ;(function(...)
                                return value_3_66:BindAction(
                                    value_5_39,
                                    value_6_20,
                                    value_7_7,
                                    ...
                                )
                            end)(unpack_value_7(value_9_2))
                            value_3_68 = captured_value_47
                            value_5_40 = "SpectateRight"
                            value_6_21 = captured_value_48
                            value_7_8 = false
                            value_9_3 = captured_value_50
                            unpack_value_8 = unpack
                            ;(function(...)
                                return value_3_68:BindAction(
                                    value_5_40,
                                    value_6_21,
                                    value_7_8,
                                    ...
                                )
                            end)(unpack_value_8(value_9_3))
                            value_3_70 = captured_value_51
                            value_3_70()
                            value_3_71 = value_9
                            control_state = if value_3_71 == nil then 19 else 11
                        end
                    else
                        if control_state < 13 then
                            value_3_72 = true

                            return value_3_72
                        else
                            if control_state < 14 then
                                value_3_73 = false
                                isSpectating = value_3_73
                                value_3_74 = captured_value_44
                                character_value_25 = value_3_74.Character
                                control_state = if character_value_25 then 15 else 14
                            else
                                value_3_75 = captured_value_52
                                value_4_51 = nil
                                value_3_75.CameraSubject = value_4_51
                                control_state = 18
                            end
                        end
                    end
                else
                    if control_state < 17 then
                        if control_state < 16 then
                            value_3_76 = captured_value_44
                            character_value_26 = value_3_76.Character
                            value_5_41 = "Humanoid"
                            find_first_child_of_class_result_13 = character_value_26:FindFirstChildOfClass(
                                value_5_41
                            )
                            control_state = if find_first_child_of_class_result_13 then 17 else 16
                        else
                            value_4_53 = captured_value_52
                            value_5_42 = nil
                            value_4_53.CameraSubject = value_5_42
                            control_state = 18
                        end
                    else
                        if control_state < 18 then
                            value_4_54 = captured_value_52
                            value_4_54.CameraSubject = find_first_child_of_class_result_13
                            control_state = 18
                        else
                            if control_state < 19 then
                                value_3_78 = captured_value_47
                                value_5_43 = "SpectateLeft"
                                value_3_78:UnbindAction(value_5_43)
                                value_3_80 = captured_value_47
                                value_5_44 = "SpectateRight"
                                value_3_80:UnbindAction(value_5_44)
                                value_3_82 = captured_value_46
                                spectate_cancelled_value_9 = value_3_82.SpectateCancelled
                                spectate_cancelled_value_9:Fire()
                                control_state = 19
                            else
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    captured_value_44, captured_value_45, captured_value_46, captured_value_47, captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52 = local_player_value, require_result, table_1, context_action_service, on_spectate_keybind, table_6, table_7, update_camera_focus, current_camera_value
    closure_ready_14 = true
end
table_1.SetSpectating = set_spectating
local on_player_data_updated
do
    local captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58, closure_ready_15
    on_player_data_updated = function()
        if not closure_ready_15 then
            return
        end
        local value_2_90 = captured_value_53
        local value_4_58 = captured_value_54.PlayerData
        local name_value_7 = value_2_90.Name
        local value_3_84 = value_4_58[name_value_7]
        local value_1_60
        if not value_3_84 then
            value_1_60 = false
        else
            value_4_58 = value_3_84.Dead
            if value_4_58 == true then
                value_1_60 = false
            else
                value_1_60 = true
            end
        end
        if value_1_60 then
            value_1_60 = false
            isSpectating = value_1_60
            value_1_60 = captured_value_53.Character
            if not value_1_60 then
                value_1_60 = captured_value_55
                value_2_90 = nil
                value_1_60.CameraSubject = value_2_90
            else
                value_1_60 = captured_value_53.Character
                value_3_84 = "Humanoid"
                value_1_60 = value_1_60:FindFirstChildOfClass(value_3_84)
                if not value_1_60 then
                    value_2_90 = captured_value_55
                    value_3_84 = nil
                    value_2_90.CameraSubject = value_3_84
                else
                    value_2_90 = captured_value_55
                    value_2_90.CameraSubject = value_1_60
                end
            end
            value_1_60 = captured_value_56
            value_3_84 = "SpectateLeft"
            value_1_60:UnbindAction(value_3_84)
            value_1_60 = captured_value_56
            value_3_84 = "SpectateRight"
            value_1_60:UnbindAction(value_3_84)
            captured_value_57.SpectateCancelled:Fire()
        end
        e_value = {}
        value_1_60, value_2_90, value_3_84 = game.Players:GetPlayers()
        for key, value in value_1_60, value_2_90, value_3_84 do
            value_4_58, name_value_7 = key, value
            local value_6_22: boolean?
            if name_value_7 == nil then
                value_6_22 = false
            else
                local parent_value_3 = name_value_7.Parent
                if parent_value_3 == nil then
                    value_6_22 = false
                else
                    local character_value_27 = name_value_7.Character
                    if not character_value_27 then
                        value_6_22 = false
                    else
                        local character_value_28 = name_value_7.Character
                        local value_9_4: string = "Humanoid"
                        local find_first_child_of_class_result_14 = character_value_28:FindFirstChildOfClass(
                            value_9_4
                        )
                        if not find_first_child_of_class_result_14 then
                            value_6_22 = false
                        else
                            local value_9_5 = captured_value_54
                            local player_data_value_7 = value_9_5.PlayerData
                            local name_value_8 = name_value_7.Name
                            local value_7_10 = player_data_value_7[name_value_8]
                            local value_8_4: boolean?
                            if not value_7_10 then
                                value_8_4 = false
                            else
                                local dead_value_6 = value_7_10.Dead
                                if dead_value_6 == true then
                                    value_8_4 = false
                                else
                                    value_8_4 = true
                                end
                            end
                            if not value_8_4 then
                                value_6_22 = false
                            else
                                value_6_22 = true
                            end
                        end
                    end
                end
            end
            if not value_6_22 then
                continue
            end
            local value_7_11 = e_value
            local value_8_5 = name_value_7
            local insert_value_2 = table.insert
            insert_value_2(value_7_11, value_8_5)
        end
        if value_9 ~= nil then
            if not (table.find(e_value, value_9)) then
                if 0 < #e_value then
                    value_9 = e_value[(math.random(1, #e_value))]
                else
                    value_9 = nil
                end
            end
        end
        captured_value_58()

        return
    end
    captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58 = local_player_value, require_result, current_camera_value, context_action_service, table_1, update_camera_focus
    closure_ready_15 = true
end
local game_value_4, value_22, value_23 = game.Players:GetPlayers()
for key_2, value_13 in game_value_4, value_22, value_23 do
    local value_24, value_25 = key_2, value_13
    local value_26: boolean?
    if value_25 == nil then
        value_26 = false
    else
        local parent_value = value_25.Parent
        if parent_value == nil then
            value_26 = false
        else
            local character_value = value_25.Character
            if not character_value then
                value_26 = false
            else
                local character_value_2 = value_25.Character
                local value_29: string = "Humanoid"
                local find_first_child_of_class_result = character_value_2:FindFirstChildOfClass(
                    value_29
                )
                if not find_first_child_of_class_result then
                    value_26 = false
                else
                    local player_data_value = require_result.PlayerData
                    local name_value = value_25.Name
                    local value_27_2 = player_data_value[name_value]
                    local value_28_2: boolean?
                    if not value_27_2 then
                        value_28_2 = false
                    else
                        local dead_value = value_27_2.Dead
                        if dead_value == true then
                            value_28_2 = false
                        else
                            value_28_2 = true
                        end
                    end
                    if not value_28_2 then
                        value_26 = false
                    else
                        value_26 = true
                    end
                end
            end
        end
    end
    if not value_26 then
        continue
    end
    local value_27_3 = e_value
    local value_28_3 = value_25
    local insert_value = table.insert
    insert_value(value_27_3, value_28_3)
end
game_value_4 = require_result.PlayerDataChanged.Event
value_23 = on_player_data_updated
game_value_4:Connect(value_23)

return table_1
