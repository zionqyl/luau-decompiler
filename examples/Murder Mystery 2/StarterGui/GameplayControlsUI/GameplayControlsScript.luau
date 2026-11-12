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
local value_3: string = "UserInputService"
local user_input_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "GuiService"
local gui_service: Instance = game_value_2:GetService(value_4)
local require_value = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_6_3))
local require_value_2 = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_7_3))
local require_value_3 = require
local game_value_5: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_5:GetService(value_8)
local value_8_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_8_2)
local value_8_3: string = "PerkService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_8_3))
local require_value_4 = require
local game_value_6: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_6:GetService(value_9)
local value_9_2: string = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_9_2)
local value_9_3: string = "WeaponService"
local require_result_4 = require_value_4(client_services_child_2:WaitForChild(value_9_3))
local require_value_5 = require
local game_value_7: DataModel = game
local value_9_4: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_7:GetService(value_9_4)
local value_9_5: string = "ClientServices"
local client_services_child_3: Instance? = replicated_storage_service_5:WaitForChild(value_9_5)
local value_9_6: string = "DeviceService"
local require_result_5 = require_value_5(client_services_child_3:WaitForChild(value_9_6))
local game_value_8: DataModel = game
local value_8_10: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_8:GetService(value_8_10)
local value_8_11: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_6:WaitForChild(value_8_11)
local parent_value: Instance? = script.Parent
local local_player_value = game.Players.LocalPlayer
local player_gui_value = local_player_value.PlayerGui
local value_12: string = "InputContext"
local input_context_child = player_gui_value:WaitForChild(value_12)
local value_13 = "GameplayContext"
local gameplay_context_child = input_context_child:WaitForChild(value_13)
local require_value_6 = require
value_13 = script
local value_15: string = "GameplayButton"
local value_10_2 = (require_value_6(value_13:WaitForChild(value_15)))
local new_value: (number?, number?) -> (Vector2) = Vector2.new
value_13 = 50
local value_14: boolean | number = 90
local new_result: Vector2 = new_value(value_13, value_14)
local new_value_2: (number?, number?) -> (Vector2) = Vector2.new
value_13 = 25
value_14 = 20
local new_result_2: Vector2 = new_value_2(value_13, value_14)
value_13 = nil
value_14 = false
local value_17: string = "TouchControls"
local value_12_3 = (parent_value:WaitForChild(value_17))
local value_17_2: string = "RightBar"
local right_bar_child = value_12_3:WaitForChild(value_17_2)
local value_18 = "BottomBar"
local bottom_bar_child = value_12_3:WaitForChild(value_18)
local value_19: string = "_"
local child = parent_value:WaitForChild(value_19)
value_18 = nil
local value_21: string = "EquipWeapon"
local value_7_15 = (right_bar_child:WaitForChild(value_21))
local value_21_2: string = "Throw"
local throw_child = right_bar_child:WaitForChild(value_21_2)
local value_22: string = "Perk"
local perk_child = bottom_bar_child:WaitForChild(value_22)
local table_21 = {nil, nil, nil}
local value_22_2 = value_7_15
local value_23 = perk_child
local value_24 = throw_child
table_21[1], table_21[2], table_21[3] = value_22_2, value_23, value_24
local new_result_3 = value_10_2.new(throw_child)
local new_result_4 = value_10_2.new(value_7_15)
local new_result_5 = value_10_2.new(perk_child)

local function is_weapon_equipped(): boolean
    local character_value = game.Players.LocalPlayer.Character
    if not character_value then
        return false
    end
    local value_2_3, value_3_3, value_4_5 = character_value:GetChildren()
    for key, value in value_2_3, value_3_3, value_4_5 do
        local value_5_7, value_6_12 = key, value
        local value_9_7: string = "Weapon_Knife"
        local has_tag_result = value_6_12:HasTag(value_9_7)
        do
            local take_fallback = has_tag_result
            if not take_fallback then
                local value_9_8: string = "Weapon_Gun"
                local has_tag_result_2 = value_6_12:HasTag(value_9_8)
                take_fallback = has_tag_result_2
            end
            if take_fallback then
                local value_9_9: string = "Tool"
                local is_a_result = value_6_12:IsA(value_9_9)
                if not is_a_result then
                    continue
                end
                local value_7_19: boolean = true

                return value_7_19
            end
        end
    end

    return false
end

local on_weapon_given
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8 = require_result_2, value_7_15, require_result, new_result_3, is_weapon_equipped, throw_child, perk_child, table_21
    on_weapon_given = function(argument_1: string)
        local value_2_4, value_3_4, value_4_6, value_5_8
        if argument_1 == "Knife" then
            value_2_4 = captured_value.Weapons.Equipped.Knife
            value_3_4 = captured_value_2.ControlIcon
            value_4_6 = captured_value_3.Weapons[value_2_4].Image
            value_3_4.Image = value_4_6
            value_3_4 = captured_value_4
            value_5_8 = captured_value_5()
            value_3_4:SetEnabled(value_5_8)
            value_3_4 = captured_value_2
            value_4_6 = true
            value_3_4.Visible = value_4_6
            value_3_4 = captured_value_6
            value_4_6 = true
            value_3_4.Visible = value_4_6
            value_3_4 = captured_value_7
            value_4_6 = true
            value_3_4.Visible = value_4_6
        else
            if argument_1 == "Gun" then
                value_2_4 = captured_value.Weapons.Equipped.Gun
                value_3_4 = captured_value_2.ControlIcon
                value_4_6 = captured_value_3.Weapons[value_2_4].Image
                value_3_4.Image = value_4_6
                value_3_4 = captured_value_2
                value_4_6 = true
                value_3_4.Visible = value_4_6
            else
                value_2_4 = captured_value_8
                value_3_4 = nil
                value_4_6 = nil
                for key_2, value_26 in value_2_4, value_3_4, value_4_6 do
                    local value_6_13
                    value_5_8, value_6_13 = key_2, value_26
                    local value_7_20: boolean = false
                    value_6_13.Visible = value_7_20
                end
            end
        end
        value_2_4 = captured_value_2.Equipped
        value_3_4 = captured_value_5()
        value_2_4.Visible = value_3_4

        return
    end
end
do
    local captured_value_9 = is_weapon_equipped

    local function equip_weapon(): ()
        local backpack_value = game.Players.LocalPlayer.Backpack
        if not backpack_value then
            return
        end
        local character_value_2 = game.Players.LocalPlayer.Character
        if not character_value_2 then
            return
        end
        local value_5_9 = "Humanoid"
        local find_first_child_of_class_result = character_value_2:FindFirstChildOfClass(value_5_9)
        if not find_first_child_of_class_result then
            return
        end
        local value_4_7, value_6_14
        value_4_7, value_5_9, value_6_14 = backpack_value:GetChildren()
        for key_3, value_27 in value_4_7, value_5_9, value_6_14 do
            local value_7_21, value_8_15 = key_3, value_27
            local value_11_3: string = "Weapon_Knife"
            local has_tag_result_3 = value_8_15:HasTag(value_11_3)
            do
                local take_fallback_2 = has_tag_result_3
                if not take_fallback_2 then
                    local value_11_4: string = "Weapon_Gun"
                    local has_tag_result_4 = value_8_15:HasTag(value_11_4)
                    take_fallback_2 = has_tag_result_4
                end
                if take_fallback_2 then
                    local value_11_5: string = "Tool"
                    local is_a_result_2 = value_8_15:IsA(value_11_5)
                    if not is_a_result_2 then
                        continue
                    end
                    local value_11_6 = value_8_15
                    find_first_child_of_class_result:EquipTool(value_11_6)

                    return
                end
            end
        end
        if (captured_value_9()) then
            find_first_child_of_class_result:UnequipTools()

            return
        end

        return
    end
end
local on_equip_button_activated: (() -> ())?
do
    local captured_value_10, captured_value_11, captured_value_12, captured_value_13 = new_result_3, value_7_15, is_weapon_equipped, gui_service
    on_equip_button_activated = function(): ()
        local backpack_value_2 = game.Players.LocalPlayer.Backpack
        if not backpack_value_2 then
            return
        end
        local character_value_3 = game.Players.LocalPlayer.Character
        if not character_value_3 then
            return
        end
        local value_5_10 = "Humanoid"
        local find_first_child_of_class_result_2 = character_value_3:FindFirstChildOfClass(
            value_5_10
        )
        if not find_first_child_of_class_result_2 then
            return
        end
        local value_4_8, value_6_15
        value_4_8, value_5_10, value_6_15 = backpack_value_2:GetChildren()
        for key_4, value_28 in value_4_8, value_5_10, value_6_15 do
            local value_7_22, value_8_16 = key_4, value_28
            local value_11_7: string = "Weapon_Knife"
            local has_tag_result_5 = value_8_16:HasTag(value_11_7)
            do
                local take_fallback_3 = has_tag_result_5
                if not take_fallback_3 then
                    local value_11_8: string = "Weapon_Gun"
                    local has_tag_result_6 = value_8_16:HasTag(value_11_8)
                    take_fallback_3 = has_tag_result_6
                end
                if take_fallback_3 then
                    local value_11_9: string = "Tool"
                    local is_a_result_3 = value_8_16:IsA(value_11_9)
                    if not is_a_result_3 then
                        continue
                    end
                    local value_11_10 = value_8_16
                    find_first_child_of_class_result_2:EquipTool(value_11_10)
                    local value_9_18 = captured_value_10
                    local value_11_11: boolean = true
                    value_9_18:SetEnabled(value_11_11)
                    local value_9_20 = captured_value_11
                    local equipped_value = value_9_20.Equipped
                    local value_10_12: boolean = true
                    equipped_value.Visible = value_10_12

                    return
                end
            end
        end
        value_4_8 = captured_value_12()
        if value_4_8 then
            value_4_8 = captured_value_10
            value_6_15 = false
            value_4_8:SetEnabled(value_6_15)
            value_4_8 = captured_value_11.Equipped
            value_5_10 = false
            value_4_8.Visible = value_5_10
            find_first_child_of_class_result_2:UnequipTools()

            return
        end
        if (captured_value_13:IsTenFootInterface()) then
            find_first_child_of_class_result_2:UnequipTools()
        end

        return
    end
end
local intialize_touch_controls: (() -> ())?
do
    local captured_value_14, captured_value_15, captured_value_16, captured_value_17 = player_gui_value, bottom_bar_child, right_bar_child, value_12_3
    intialize_touch_controls = function(): ()
        value_14 = true
        local value_1_3 = captured_value_14
        local value_3_7: string = "TouchGui"
        value_13 = (value_1_3:WaitForChild(value_3_7))
        local value_1_5 = value_13
        local value_3_8: string = "TouchControlFrame"
        local touch_control_frame_child = value_1_5:WaitForChild(value_3_8)
        local value_3_9: string = "JumpButton"
        local value_2_8: boolean?
        if touch_control_frame_child:WaitForChild(value_3_9).Size ~= (UDim2.new(0, 120, 0, 120)) then
            value_2_8 = false
        else
            value_2_8 = true
        end
        if value_2_8 then
            local value_3_10 = captured_value_15
            local value_5_12: string = "UIScale"
            local ui_scale_child = value_3_10:WaitForChild(value_5_12)
            local value_4_10: number = 1.21
            ui_scale_child.Scale = value_4_10
            local value_3_12 = captured_value_16
            local value_5_13: string = "UIScale"
            local ui_scale_child_2 = value_3_12:WaitForChild(value_5_13)
            local value_4_12: number = 1.21
            ui_scale_child_2.Scale = value_4_12
            local value_3_14 = captured_value_16
            local new_result_7 = UDim2.new(1, -15, 1, -215, 0)
            value_3_14.Position = new_result_7
            local value_3_15 = captured_value_15
            local new_result_8 = UDim2.new(1, -145, 1, -15)
            value_3_15.Position = new_result_8
        end
        local value_3_16 = captured_value_17
        local value_4_13: boolean = true
        value_3_16.Visible = value_4_13

        return
    end
end
local on_preferred_input_changed: (() -> ())?
do
    local captured_value_18, captured_value_19, captured_value_20, captured_value_21, captured_value_22 = user_input_service, intialize_touch_controls, require_result_3, perk_child, value_12_3
    on_preferred_input_changed = function(): ()
        if captured_value_18.PreferredInput == Enum.PreferredInput.Touch then
            if not value_14 then
                captured_value_19()
            end
            local value_2_11 = captured_value_20
            local value_3_17 = captured_value_21
            value_2_11.PerkButton = value_3_17
            local value_2_12 = captured_value_21
            local perk_is_active_value = captured_value_20.PerkIsActive
            value_2_12.Visible = perk_is_active_value
            local value_2_13 = captured_value_22
            local value_3_19: boolean = true
            value_2_13.Visible = value_3_19

            return
        end
        local value_2_14 = captured_value_22
        local value_3_20: boolean = false
        value_2_14.Visible = value_3_20

        return
    end
end
local on_initialize
do
    local captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42 = value_12_3, remotes_child, on_weapon_given, table_21, gui_service, gameplay_context_child, new_result_4, on_equip_button_activated, new_result_5, require_result_3, throw_child, local_player_value, new_result_3, value_7_15, is_weapon_equipped, user_input_service, intialize_touch_controls, perk_child, on_preferred_input_changed, child
    on_initialize = function()
        local value_1_9 = captured_value_23
        local value_2_15 = false
        value_1_9.Visible = value_2_15
        value_1_9 = captured_value_24
        local value_3_21 = "Gameplay"
        value_1_9 = value_1_9:WaitForChild(value_3_21)
        value_3_21 = "GiveWeapon"
        value_1_9 = value_1_9:WaitForChild(value_3_21).OnClientEvent
        value_3_21 = captured_value_25
        value_1_9:Connect(value_3_21)
        value_1_9 = captured_value_26
        value_2_15 = nil
        value_3_21 = nil
        local value_4_14, value_5_16, value_6_19
        for key_5, value_29 in value_1_9, value_2_15, value_3_21 do
            value_4_14, value_5_16 = key_5, value_29
            value_6_19 = false
            value_5_16.Visible = value_6_19
        end
        value_1_9 = captured_value_27:IsTenFootInterface()
        if value_1_9 then
            value_1_9 = script
            value_3_21 = "EquipAction"
            value_1_9, value_2_15, value_3_21 = value_1_9:WaitForChild(value_3_21):GetChildren()
            for key_6, value_31 in value_1_9, value_2_15, value_3_21 do
                value_4_14, value_5_16 = key_6, value_31
                value_6_19 = captured_value_28
                local value_8_20: string = "EquipWeapon"
                value_6_19 = value_6_19:WaitForChild(value_8_20)
                value_5_16.Parent = value_6_19
            end
        end
        value_1_9 = captured_value_29.Activated.Event
        value_3_21 = captured_value_30
        value_1_9:Connect(value_3_21)
        value_1_9 = captured_value_31.Activated.Event
        do
            local captured_value_43 = captured_value_32
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_43) then
                value_3_21 = closure_cache[1]
            else
                local closure_ready
                value_3_21 = function(): ()
                    if not closure_ready then
                        return
                    end
                    captured_value_43:ActivatePerk()

                    return
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_21
                    closure_cache[2] = captured_value_43
                end
            end
        end
        value_1_9:Connect(value_3_21)
        value_1_9 = captured_value_28
        value_3_21 = "Throw"
        value_1_9 = value_1_9:WaitForChild(value_3_21)
        value_3_21 = "TouchBinding"
        value_1_9 = value_1_9:WaitForChild(value_3_21)
        value_2_15 = captured_value_33
        value_1_9.UIButton = value_2_15
        value_1_9 = captured_value_34.Backpack
        value_2_15 = value_1_9.ChildAdded
        do
            local captured_value_44, captured_value_45, captured_value_46, captured_value_47, closure_ready_3
            value_4_14 = function(argument_1_2): ()
                if not closure_ready_3 then
                    return
                end
                local value_4_15: string = "Weapon"
                local value_2_17 = argument_1_2:HasTag(value_4_15)
                if not value_2_17 then
                    return
                end
                value_18 = argument_1_2
                value_2_17 = nil
                local ancestry_changed_value = argument_1_2.AncestryChanged
                local value_5_17: (() -> ())?
                do
                    local captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52, closure_ready_2
                    value_5_17 = function(): ()
                        if not closure_ready_2 then
                            return
                        end
                        if captured_value_48.Parent == nil then
                            value_2_17:Disconnect()
                            value_18 = nil

                            return
                        end
                        if captured_value_49.Parent == captured_value_50.Backpack then
                            local value_1_17 = captured_value_51
                            local value_3_24: boolean = false
                            value_1_17:SetEnabled(value_3_24)
                            local equipped_value_2 = captured_value_52.Equipped
                            local value_2_21: boolean = false
                            equipped_value_2.Visible = value_2_21

                            return
                        end
                        if captured_value_49.Parent == captured_value_50.Character then
                            local value_1_21 = captured_value_51
                            local value_3_25: boolean = true
                            value_1_21:SetEnabled(value_3_25)
                            local equipped_value_3 = captured_value_52.Equipped
                            local value_2_24: boolean = true
                            equipped_value_3.Visible = value_2_24

                            return
                        end
                        value_2_17:Disconnect()
                        value_18 = nil

                        return
                    end
                    captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52 = captured_value_44, argument_1_2, captured_value_45, captured_value_46, captured_value_47
                    closure_ready_2 = true
                end
                value_2_17 = (ancestry_changed_value:Connect(value_5_17))

                return
            end
            captured_value_44, captured_value_45, captured_value_46, captured_value_47 = value_1_9, captured_value_34, captured_value_35, captured_value_36
            closure_ready_3 = true
        end
        value_2_15:Connect(value_4_14)
        value_2_15 = captured_value_26
        value_3_21 = nil
        value_4_14 = nil
        for key_7, value_32 in value_2_15, value_3_21, value_4_14 do
            value_5_16, value_6_19 = key_7, value_32
            local value_7_27: boolean = false
            value_6_19.Visible = value_7_27
        end
        value_2_15 = captured_value_36.Equipped
        value_3_21 = captured_value_37()
        value_2_15.Visible = value_3_21
        value_2_15 = captured_value_38.PreferredInput
        value_3_21 = Enum.PreferredInput.Touch
        if value_2_15 == value_3_21 then
            if not value_14 then
                captured_value_39()
            end
            value_3_21 = captured_value_32
            value_4_14 = captured_value_40
            value_3_21.PerkButton = value_4_14
            value_3_21 = captured_value_40
            value_4_14 = captured_value_32.PerkIsActive
            value_3_21.Visible = value_4_14
            value_3_21 = captured_value_23
            value_4_14 = true
            value_3_21.Visible = value_4_14
        else
            value_3_21 = captured_value_23
            value_4_14 = false
            value_3_21.Visible = value_4_14
        end
        value_2_15 = captured_value_38
        value_4_14 = "PreferredInput"
        value_2_15 = value_2_15:GetPropertyChangedSignal(value_4_14)
        value_4_14 = captured_value_41
        value_2_15:Connect(value_4_14)
        value_2_15 = captured_value_42
        value_3_21 = false
        value_2_15.Visible = value_3_21

        return
    end
end
on_initialize()

return
