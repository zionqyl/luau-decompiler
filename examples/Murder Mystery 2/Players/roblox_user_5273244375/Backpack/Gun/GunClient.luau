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

local game_value: DataModel = game
local value_3: string = "ContentProvider"
local content_provider_service: Instance = game_value:GetService(value_3)
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "WeaponService"
local require_result = require_value(client_services_child:WaitForChild(value_5_3))
local game_value_3: DataModel = game
local value_5_4: string = "UserInputService"
local user_input_service: Instance = game_value_3:GetService(value_5_4)
local game_value_4: DataModel = game
local value_6: string = "RunService"
local run_service: Instance = game_value_4:GetService(value_6)
local parent_value: Instance? = script.Parent
local value_8: string = "Handle"
local handle_child = parent_value:WaitForChild(value_8)
local local_player_value = game.Players.LocalPlayer
local get_mouse_result = local_player_value:GetMouse()
local player_gui_value = local_player_value.PlayerGui
local value_10 = "Animations"
local animations_child = parent_value:WaitForChild(value_10)
local value_9 = nil
value_10 = nil
local value_11 = nil
local value_12 = false
local script_value_2: LuaSourceContainer = script
local value_15: string = "CantShoot"
local cant_shoot_child: Instance? = script_value_2:WaitForChild(value_15)
local table_14 = {Shoot = nil, Reload = nil, CustomHold = nil}
local load_animations
do
    local captured_value, captured_value_2, captured_value_3 = table_14, animations_child, parent_value
    load_animations = function()
        local value_1_2 = value_9
        local value_3_6: string = "Animator"
        local animator_child = value_1_2:WaitForChild(value_3_6)
        local value_2_3 = captured_value
        local value_5_6 = captured_value_2
        local value_7_3: string = "Shoot"
        local load_animation_result = (function(...)
            return animator_child:LoadAnimation(...)
        end)(value_5_6:WaitForChild(value_7_3))
        value_2_3.Shoot = load_animation_result
        local value_2_4 = captured_value
        local value_5_8 = captured_value_2
        local value_7_4: string = "Reload"
        local load_animation_result_2 = (function(...)
            return animator_child:LoadAnimation(...)
        end)(value_5_8:WaitForChild(value_7_4))
        value_2_4.Reload = load_animation_result_2
        local value_2_5: Instance? = captured_value_3
        local value_4_8: string = "CustomHold"
        if (value_2_5:FindFirstChild(value_4_8)) then
            local value_2_7 = captured_value
            local value_5_10: Instance? = captured_value_3
            local value_7_5: string = "CustomHold"
            local load_animation_result_3 = (function(...)
                return animator_child:LoadAnimation(...)
            end)(value_5_10:FindFirstChild(value_7_5))
            value_2_7.CustomHold = load_animation_result_3
        end

        return
    end
end
do
    local captured_value_4 = local_player_value

    local function get_shot_origin_c_frame()
        if not captured_value_4.Character then
            return
        end
        local character_value_2 = captured_value_4.Character
        local value_3_11: string = "HumanoidRootPart"
        local humanoid_root_part_child = character_value_2:WaitForChild(value_3_11)
        local value_4_10: string = "GunRaycastAttachment"
        local gun_raycast_attachment_child = humanoid_root_part_child:FindFirstChild(value_4_10)
        if not gun_raycast_attachment_child then
            return
        end

        return gun_raycast_attachment_child.WorldCFrame
    end
end
do
    local captured_value_5, captured_value_6 = local_player_value, parent_value

    local function shoot_gun(argument_1: CFrame): ()
        if not value_12 then
            return
        end
        local value_2_11
        if not captured_value_5.Character then
            value_2_11 = nil
        else
            local character_value_4 = captured_value_5.Character
            local value_5_12: string = "HumanoidRootPart"
            local humanoid_root_part_child_2 = character_value_4:WaitForChild(value_5_12)
            local value_6_6: string = "GunRaycastAttachment"
            local gun_raycast_attachment_child_2 = humanoid_root_part_child_2:FindFirstChild(
                value_6_6
            )
            if not gun_raycast_attachment_child_2 then
                value_2_11 = nil
            else
                value_2_11 = gun_raycast_attachment_child_2.WorldCFrame
            end
        end
        local shoot_value = captured_value_6.Shoot
        local value_5_14 = value_2_11
        local value_6_7: CFrame = argument_1
        shoot_value:FireServer(value_5_14, value_6_7)

        return
    end
end
local on_update: ((number) -> ())?
do
    local captured_value_7, captured_value_8 = local_player_value, cant_shoot_child
    on_update = function(argument_1_2: number): ()
        local new_result: RaycastParams = RaycastParams.new()
        local table_3 = {captured_value_7.Character}
        new_result.FilterDescendantsInstances = table_3
        if not captured_value_7.Character then
            return
        end
        local character_value_7 = captured_value_7.Character
        local value_5_15: string = "Head"
        local head_child = character_value_7:FindFirstChild(value_5_15)
        if not head_child then
            return
        end
        local position_value = head_child.Position
        local value_5_16 = value_11.WorldPosition - position_value
        local workspace_value: Workspace = workspace
        local value_8_4 = position_value
        local value_9_2 = value_5_16
        local value_10_2: RaycastParams = new_result
        local value_3_22: RaycastResult? = (workspace_value:Raycast(
            value_8_4,
            value_9_2,
            value_10_2
        ))
        if value_3_22 then
            if value_3_22.Instance then
                local value_6_9: Instance? = captured_value_8
                local value_7_7: boolean = true
                value_6_9.Enabled = value_7_7

                return
            end
        end
        local value_6_10: Instance? = captured_value_8
        local value_7_8: boolean = false
        value_6_10.Enabled = value_7_8

        return
    end
end
do
    local captured_value_9, captured_value_10 = user_input_service, get_mouse_result

    local function update_mouse_icon(): ()
        if value_12 then
            if captured_value_9.PreferredInput ~= Enum.PreferredInput.Gamepad then
                local value_1_9 = captured_value_10
                local value_2_12: string = "rbxassetid://79658449"
                value_1_9.Icon = value_2_12

                return
            end
        end
        local value_1_10 = captured_value_10
        local value_2_13: string = ""
        value_1_10.Icon = value_2_13

        return
    end
end
local on_initialize
do
    local captured_value_11, captured_value_12, captured_value_13, captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21, captured_value_22 = local_player_value, load_animations, parent_value, user_input_service, get_mouse_result, table_14, require_result, content_provider_service, animations_child, cant_shoot_child, run_service, on_update
    on_initialize = function()
        local character_value_8 = captured_value_11.Character
        if not character_value_8 then
            return
        end
        local value_4_16: string = "Humanoid"
        value_9 = (character_value_8:WaitForChild(value_4_16))
        captured_value_12()
        local equipped_value = captured_value_13.Equipped
        local value_4_17: (() -> ())?
        do
            local captured_value_23, captured_value_24, captured_value_25, closure_ready
            value_4_17 = function(): ()
                if not closure_ready then
                    return
                end
                local custom_hold_value, custom_hold_value_2, gamepad_value_2, preferred_input_value_2, value_1_12, value_1_13, value_1_14, value_1_15, value_1_16, value_1_17, value_1_18, value_2_35, value_2_36
                local control_state = 0
                while true do
                    if control_state < 3 then
                        if control_state < 1 then
                            value_1_12 = true
                            value_12 = value_1_12
                            value_1_13 = value_12
                            control_state = if not value_1_13 then 3 else 1
                        else
                            if control_state < 2 then
                                value_1_14 = captured_value_23
                                preferred_input_value_2 = value_1_14.PreferredInput
                                gamepad_value_2 = Enum.PreferredInput.Gamepad
                                control_state = if preferred_input_value_2 == gamepad_value_2 then 3 else 2
                            else
                                value_1_15 = captured_value_24
                                value_2_35 = "rbxassetid://79658449"
                                value_1_15.Icon = value_2_35
                                control_state = 4
                            end
                        end
                    else
                        if control_state < 5 then
                            if control_state < 4 then
                                value_1_16 = captured_value_24
                                value_2_36 = ""
                                value_1_16.Icon = value_2_36
                                control_state = 4
                            else
                                value_1_17 = captured_value_25
                                custom_hold_value = value_1_17.CustomHold
                                control_state = if not custom_hold_value then 6 else 5
                            end
                        else
                            if control_state < 6 then
                                value_1_18 = captured_value_25
                                custom_hold_value_2 = value_1_18.CustomHold
                                custom_hold_value_2:Play()
                                control_state = 6
                            else
                                return
                            end
                        end
                    end
                end
            end
            captured_value_23, captured_value_24, captured_value_25 = captured_value_14, captured_value_15, captured_value_16
            closure_ready = true
        end
        equipped_value:Connect(value_4_17)
        local unequipped_value = captured_value_13.Unequipped
        local value_4_18: (() -> ())?
        do
            local captured_value_26, captured_value_27, captured_value_28, closure_ready_2
            value_4_18 = function(): ()
                if not closure_ready_2 then
                    return
                end
                local custom_hold_value_3, custom_hold_value_4, gamepad_value_3, preferred_input_value_3, value_1_20, value_1_21, value_1_22, value_1_23, value_1_24, value_1_25, value_1_26, value_2_38, value_2_39
                local control_state_2 = 0
                while true do
                    if control_state_2 < 3 then
                        if control_state_2 < 1 then
                            value_1_20 = false
                            value_12 = value_1_20
                            value_1_21 = value_12
                            control_state_2 = if not value_1_21 then 3 else 1
                        else
                            if control_state_2 < 2 then
                                value_1_22 = captured_value_26
                                preferred_input_value_3 = value_1_22.PreferredInput
                                gamepad_value_3 = Enum.PreferredInput.Gamepad
                                control_state_2 = if preferred_input_value_3 == gamepad_value_3 then 3 else 2
                            else
                                value_1_23 = captured_value_27
                                value_2_38 = "rbxassetid://79658449"
                                value_1_23.Icon = value_2_38
                                control_state_2 = 4
                            end
                        end
                    else
                        if control_state_2 < 5 then
                            if control_state_2 < 4 then
                                value_1_24 = captured_value_27
                                value_2_39 = ""
                                value_1_24.Icon = value_2_39
                                control_state_2 = 4
                            else
                                value_1_25 = captured_value_28
                                custom_hold_value_3 = value_1_25.CustomHold
                                control_state_2 = if not custom_hold_value_3 then 6 else 5
                            end
                        else
                            if control_state_2 < 6 then
                                value_1_26 = captured_value_28
                                custom_hold_value_4 = value_1_26.CustomHold
                                custom_hold_value_4:Stop()
                                control_state_2 = 6
                            else
                                return
                            end
                        end
                    end
                end
            end
            captured_value_26, captured_value_27, captured_value_28 = captured_value_14, captured_value_15, captured_value_16
            closure_ready_2 = true
        end
        unequipped_value:Connect(value_4_18)
        local value_2_20: Instance = captured_value_14
        local value_4_19: string = "PreferredInput"
        local get_property_changed_signal_result: RBXScriptSignal<> = value_2_20:GetPropertyChangedSignal(
            value_4_19
        )
        local value_4_20: (() -> ())?
        do
            local captured_value_29, captured_value_30, closure_ready_3
            value_4_20 = function(): ()
                if not closure_ready_3 then
                    return
                end
                if value_12 then
                    if value_12 then
                        if captured_value_29.PreferredInput ~= Enum.PreferredInput.Gamepad then
                            local value_1_31 = captured_value_30
                            local value_2_41: string = "rbxassetid://79658449"
                            value_1_31.Icon = value_2_41

                            return
                        end
                    end
                    local value_1_32 = captured_value_30
                    local value_2_42: string = ""
                    value_1_32.Icon = value_2_42
                end

                return
            end
            captured_value_29, captured_value_30 = captured_value_14, captured_value_15
            closure_ready_3 = true
        end
        get_property_changed_signal_result:Connect(value_4_20)
        local activated_value = captured_value_13.Activated
        local value_4_21: (() -> ())?
        do
            local captured_value_31, captured_value_32, captured_value_33, captured_value_34, closure_ready_4
            value_4_21 = function(): ()
                if not closure_ready_4 then
                    return
                end
                if captured_value_31.PreferredInput == Enum.PreferredInput.Touch then
                    return
                end
                local get_mouse_target_c_frame_result = captured_value_32:GetMouseTargetCFrame()
                if not value_12 then
                    return
                end
                local value_2_45
                if not captured_value_33.Character then
                    value_2_45 = nil
                else
                    local character_value_10 = captured_value_33.Character
                    local value_5_18: string = "HumanoidRootPart"
                    local humanoid_root_part_child_5 = character_value_10:WaitForChild(value_5_18)
                    local value_6_11: string = "GunRaycastAttachment"
                    local gun_raycast_attachment_child_4 = humanoid_root_part_child_5:FindFirstChild(
                        value_6_11
                    )
                    if not gun_raycast_attachment_child_4 then
                        value_2_45 = nil
                    else
                        value_2_45 = gun_raycast_attachment_child_4.WorldCFrame
                    end
                end
                local shoot_value_2 = captured_value_34.Shoot
                local value_5_20 = value_2_45
                local value_6_12 = get_mouse_target_c_frame_result
                shoot_value_2:FireServer(value_5_20, value_6_12)

                return
            end
            captured_value_31, captured_value_32, captured_value_33, captured_value_34 = captured_value_14, captured_value_17, captured_value_11, captured_value_13
            closure_ready_4 = true
        end
        activated_value:Connect(value_4_21)
        local touch_tap_in_world_value = captured_value_14.TouchTapInWorld
        local value_4_22: ((Vector2, boolean) -> ())?
        do
            local captured_value_35, captured_value_36, captured_value_37, closure_ready_5
            value_4_22 = function(argument_1_3: Vector2, argument_2: boolean): ()
                if not closure_ready_5 then
                    return
                end
                if argument_2 then
                    return
                end
                if (captured_value_35:IsMouseLockEnabled()) then
                    local get_mouse_target_c_frame_result_2 = captured_value_35:GetMouseTargetCFrame()
                    if not value_12 then
                        return
                    end
                    local value_4_35
                    if not captured_value_36.Character then
                        value_4_35 = nil
                    else
                        local character_value_12 = captured_value_36.Character
                        local value_7_9: string = "HumanoidRootPart"
                        local humanoid_root_part_child_6 = character_value_12:WaitForChild(
                            value_7_9
                        )
                        local value_8_5: string = "GunRaycastAttachment"
                        local gun_raycast_attachment_child_5 = humanoid_root_part_child_6:FindFirstChild(
                            value_8_5
                        )
                        if not gun_raycast_attachment_child_5 then
                            value_4_35 = nil
                        else
                            value_4_35 = gun_raycast_attachment_child_5.WorldCFrame
                        end
                    end
                    local shoot_value_3 = captured_value_37.Shoot
                    local value_7_11 = value_4_35
                    local value_8_6 = get_mouse_target_c_frame_result_2
                    shoot_value_3:FireServer(value_7_11, value_8_6)

                    return
                end
                local value_3_47 = captured_value_35
                local x_value: number = argument_1_3.X
                local y_value: number = argument_1_3.Y
                local get_target_position_result = value_3_47:GetTargetPosition(x_value, y_value)
                if not value_12 then
                    return
                end
                local value_4_38
                if not captured_value_36.Character then
                    value_4_38 = nil
                else
                    local character_value_14 = captured_value_36.Character
                    local value_7_12: string = "HumanoidRootPart"
                    local humanoid_root_part_child_7 = character_value_14:WaitForChild(value_7_12)
                    local value_8_7: string = "GunRaycastAttachment"
                    local gun_raycast_attachment_child_6 = humanoid_root_part_child_7:FindFirstChild(
                        value_8_7
                    )
                    if not gun_raycast_attachment_child_6 then
                        value_4_38 = nil
                    else
                        value_4_38 = gun_raycast_attachment_child_6.WorldCFrame
                    end
                end
                local shoot_value_4 = captured_value_37.Shoot
                local value_7_14 = value_4_38
                local value_8_8 = get_target_position_result
                shoot_value_4:FireServer(value_7_14, value_8_8)

                return
            end
            captured_value_35, captured_value_36, captured_value_37 = captured_value_17, captured_value_11, captured_value_13
            closure_ready_5 = true
        end
        touch_tap_in_world_value:Connect(value_4_22)
        local spawn_value = task.spawn
        local value_3_30
        do
            local captured_value_38, captured_value_39 = captured_value_18, captured_value_19
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_38) and same_capture(
                closure_cache[3],
                captured_value_39
            ) then
                value_3_30 = closure_cache[1]
            else
                local closure_ready_6
                value_3_30 = function(): ()
                    if not closure_ready_6 then
                        return
                    end
                    local value_1_36: Instance = captured_value_38
                    local table_3_2 = {nil, nil}
                    local value_4_39 = captured_value_39
                    local value_6_19: string = "Shoot"
                    local animation_id_value = value_4_39:WaitForChild(value_6_19).AnimationId
                    local value_5_32 = captured_value_39
                    local value_7_15: string = "Reload"
                    local animation_id_value_2 = value_5_32:WaitForChild(value_7_15).AnimationId
                    table_3_2[1], table_3_2[2] = animation_id_value, animation_id_value_2
                    value_1_36:PreloadAsync(table_3_2)

                    return
                end
                closure_ready_6 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_30
                    closure_cache[2], closure_cache[3] = captured_value_38, captured_value_39
                end
            end
        end
        spawn_value(value_3_30)
        local value_4_23: string = "HumanoidRootPart"
        local humanoid_root_part_child_3 = character_value_8:WaitForChild(value_4_23)
        local value_4_24: string = "GunRaycastAttachment"
        value_11 = (humanoid_root_part_child_3:WaitForChild(value_4_24))
        local value_4_25: string = "HumanoidRootPart"
        local humanoid_root_part_child_4 = character_value_8:WaitForChild(value_4_25)
        local value_4_26: string = "GunShoulderAttachment"
        value_10 = (humanoid_root_part_child_4:WaitForChild(value_4_26))
        local value_2_31: Instance? = captured_value_20
        local value_3_35: Instance? = captured_value_13
        value_2_31.Parent = value_3_35
        local pre_simulation_value = captured_value_21.PreSimulation
        local value_4_27: (number) -> () = captured_value_22
        pre_simulation_value:Connect(value_4_27)
        local players_value_2 = game.Players
        local parent_value_2 = captured_value_13.Parent
        local value_2_34: boolean?
        if (players_value_2:GetPlayerFromCharacter(parent_value_2)) == nil then
            value_2_34 = false
        else
            value_2_34 = true
        end
        value_12 = value_2_34

        return
    end
end
on_initialize()

return
