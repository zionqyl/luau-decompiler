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
local value_3: string = "RunService"
local run_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "GuiService"
local gui_service: Instance = game_value_2:GetService(value_4)
local require_value = require
local replicated_storage_value = game.ReplicatedStorage
local value_6 = "ClientServices"
local client_services_child = replicated_storage_value:WaitForChild(value_6)
value_6 = "PerkService"
local require_result = require_value(client_services_child:WaitForChild(value_6))
local local_player_value = game.Players.LocalPlayer
local value_7 = "PlayerGui"
local player_gui_child = local_player_value:WaitForChild(value_7)
value_6 = nil
value_7 = nil
local value_8 = nil
local value_9 = nil
local value_10 = nil

local function reset_perks(): ()
    local workspace_value: Workspace = workspace
    local value_3_3: string = "Footsteps"
    if (workspace_value:FindFirstChild(value_3_3)) then
        local workspace_value_2: Workspace = workspace
        local value_3_4: string = "Footsteps"
        workspace_value_2:FindFirstChild(value_3_4):Destroy()
    end
    local g_value = _G
    local value_2_6: boolean = false
    g_value.Sleight = value_2_6
    local g_value_2 = _G
    local value_2_7: boolean = false
    g_value_2.Ninja = value_2_7
    local g_value_3 = _G
    local value_2_8: boolean = false
    g_value_3.Haste = value_2_8

    return
end

local on_perk_added
do
    local captured_value, captured_value_2 = require_result, gui_service
    on_perk_added = function(argument_1): ()
        local value_2_9 = captured_value
        local name_value = argument_1.Name
        local get_perk_info_result = value_2_9:GetPerkInfo(name_value)
        local value_3_5 = captured_value
        value_3_5 = value_3_5.PerkButton
        while true do
            if value_3_5 ~= nil then
                break
            end
            name_value = captured_value
            value_3_5 = name_value.PerkButton
            name_value = task.wait
            local value_5_4: number = 0.1
            name_value(value_5_4)
        end
        name_value = value_3_5.ControlText
        local display_name_value = get_perk_info_result.DisplayName
        name_value.Text = display_name_value
        name_value = value_3_5.ControlIcon
        local image_value = get_perk_info_result.Image
        name_value.Image = image_value
        local value_6_2: string = "PassiveLabel"
        name_value = value_3_5:FindFirstChild(value_6_2)
        if name_value then
            name_value = value_3_5.PassiveLabel
            local value_5_6: boolean?
            if get_perk_info_result.Passive ~= true then
                value_5_6 = false
            else
                value_5_6 = true
            end
            name_value.Visible = value_5_6
        end
        local value_6_3: string = "UIGradient"
        name_value = value_3_5:FindFirstChild(value_6_3)
        if name_value then
            name_value = value_3_5.UIGradient
            local value_5_8: boolean?
            if get_perk_info_result.Passive == true then
                value_5_8 = false
            else
                value_5_8 = true
            end
            name_value.Enabled = value_5_8
        end
        local value_6_4: string = "Keybind"
        name_value = value_3_5:FindFirstChild(value_6_4)
        if name_value then
            name_value = value_3_5.Keybind
            local value_5_10: boolean?
            if get_perk_info_result.Passive == true then
                value_5_10 = false
            else
                value_5_10 = true
            end
            name_value.Visible = value_5_10
        end
        name_value = argument_1.Name
        if name_value == "FakeGun" then
            name_value = captured_value_2
            name_value = name_value:IsTenFootInterface()
            if name_value then
                name_value = value_3_5.Keybind
                local value_5_12: boolean = true
                name_value.Visible = value_5_12
            end
        end
        name_value = value_3_5.Charges
        local value_5_13: boolean?
        if get_perk_info_result.Charges == nil then
            value_5_13 = false
        else
            value_5_13 = true
        end
        name_value.Visible = value_5_13
        name_value = value_3_5.ControlIcon
        local from_rgb_result: Color3 = Color3.fromRGB(255, 255, 255)
        name_value.ImageColor3 = from_rgb_result
        name_value = nil
        local ancestry_changed_value = argument_1.AncestryChanged
        local value_7_3: (() -> ())?
        do
            local captured_value_3, captured_value_4, closure_ready
            value_7_3 = function(): ()
                if not closure_ready then
                    return
                end
                local value_1_5 = captured_value_3
                local game_value_5: DataModel = game
                if not (value_1_5:IsDescendantOf(game_value_5)) then
                    name_value:Disconnect()
                    value_10 = nil
                    local value_1_10 = value_3_5
                    local value_2_13: boolean = false
                    value_1_10.Visible = value_2_13
                    local value_1_11 = captured_value_4
                    local value_2_14: boolean = false
                    value_1_11.PerkIsActive = value_2_14
                    local workspace_value_3: Workspace = workspace
                    local value_3_6: string = "Footsteps"
                    if (workspace_value_3:FindFirstChild(value_3_6)) then
                        local workspace_value_4: Workspace = workspace
                        local value_3_7: string = "Footsteps"
                        workspace_value_4:FindFirstChild(value_3_7):Destroy()
                    end
                    local g_value_4 = _G
                    local value_2_18: boolean = false
                    g_value_4.Sleight = value_2_18
                    local g_value_5 = _G
                    local value_2_19: boolean = false
                    g_value_5.Ninja = value_2_19
                    local g_value_6 = _G
                    local value_2_20: boolean = false
                    g_value_6.Haste = value_2_20
                end

                return
            end
            captured_value_3, captured_value_4 = argument_1, captured_value
            closure_ready = true
        end
        name_value = (ancestry_changed_value:Connect(value_7_3))
        local update_perk: (() -> ())?
        do
            local captured_value_5, closure_ready_2
            update_perk = function(): ()
                if not closure_ready_2 then
                    return
                end
                local value_1_15 = captured_value_5
                local value_3_8: string = "ActiveTime"
                value_8 = (value_1_15:GetAttribute(value_3_8))
                local value_1_17 = captured_value_5
                local value_3_9: string = "Cooldown"
                value_7 = (value_1_17:GetAttribute(value_3_9))
                local value_1_19 = captured_value_5
                local value_3_10: string = "Charges"
                value_9 = (value_1_19:GetAttribute(value_3_10))

                return
            end
            captured_value_5 = argument_1
            closure_ready_2 = true
        end
        local update_charges: (() -> ())?
        do
            local captured_value_6, closure_ready_3
            update_charges = function(): ()
                if not closure_ready_3 then
                    return
                end
                local value_1_21 = captured_value_6
                local value_3_11: string = "Charges"
                local charges_value_7 = value_1_21:GetAttribute(value_3_11)
                if not charges_value_7 then
                    return
                end
                local charges_value_8 = value_3_5.Charges
                local value_3_12 = "(" .. charges_value_7 .. ")"
                charges_value_8.Text = value_3_12
                if charges_value_7 <= 0 then
                    local control_icon_value_2 = value_3_5.ControlIcon
                    local from_rgb_result_3: Color3 = Color3.fromRGB(90, 90, 90)
                    control_icon_value_2.ImageColor3 = from_rgb_result_3
                end
                local value_2_28 = captured_value_6
                local value_4_6: string = "ActiveTime"
                value_8 = (value_2_28:GetAttribute(value_4_6))
                local value_2_30 = captured_value_6
                local value_4_7: string = "Cooldown"
                value_7 = (value_2_30:GetAttribute(value_4_7))
                local value_2_32 = captured_value_6
                local value_4_8: string = "Charges"
                value_9 = (value_2_32:GetAttribute(value_4_8))

                return
            end
            captured_value_6 = argument_1
            closure_ready_3 = true
        end
        local value_8_3: string = "ActiveTime"
        local get_attribute_changed_signal_result = argument_1:GetAttributeChangedSignal(value_8_3)
        local value_8_4: () -> () = update_perk
        get_attribute_changed_signal_result:Connect(value_8_4)
        local value_8_5: string = "Cooldown"
        local get_attribute_changed_signal_result_2 = argument_1:GetAttributeChangedSignal(
            value_8_5
        )
        local value_8_6: () -> () = update_perk
        get_attribute_changed_signal_result_2:Connect(value_8_6)
        local value_8_7: string = "LastUse"
        local get_attribute_changed_signal_result_3 = argument_1:GetAttributeChangedSignal(
            value_8_7
        )
        local value_8_8: (() -> ())?
        do
            local closure_ready_4
            value_8_8 = function(): ()
                if not closure_ready_4 then
                    return
                end
                value_6 = (os.clock())

                return
            end
            closure_ready_4 = true
        end
        get_attribute_changed_signal_result_3:Connect(value_8_8)
        local value_8_9: string = "Charges"
        local get_attribute_changed_signal_result_4 = argument_1:GetAttributeChangedSignal(
            value_8_9
        )
        local value_8_10: () -> () = update_charges
        get_attribute_changed_signal_result_4:Connect(value_8_10)
        local value_8_11: string = "Charges"
        local charges_value_2 = argument_1:GetAttribute(value_8_11)
        if not charges_value_2 then
        else
            local charges_value_3 = value_3_5.Charges
            local value_8_12 = "(" .. charges_value_2 .. ")"
            charges_value_3.Text = value_8_12
            if charges_value_2 <= 0 then
                local control_icon_value = value_3_5.ControlIcon
                local from_rgb_result_2: Color3 = Color3.fromRGB(90, 90, 90)
                control_icon_value.ImageColor3 = from_rgb_result_2
            end
            local value_9_4: string = "ActiveTime"
            value_8 = (argument_1:GetAttribute(value_9_4))
            local value_9_5: string = "Cooldown"
            value_7 = (argument_1:GetAttribute(value_9_5))
            local value_9_6: string = "Charges"
            value_9 = (argument_1:GetAttribute(value_9_6))
        end
        local value_8_16: string = "ActiveTime"
        value_8 = (argument_1:GetAttribute(value_8_16))
        local value_8_17: string = "Cooldown"
        value_7 = (argument_1:GetAttribute(value_8_17))
        local value_8_18: string = "Charges"
        value_9 = (argument_1:GetAttribute(value_8_18))
        value_6 = -100
        value_10 = argument_1
        local value_6_20: boolean = true
        value_3_5.Visible = value_6_20
        local value_6_21 = captured_value
        local value_7_20: boolean = true
        value_6_21.PerkIsActive = value_7_20

        return
    end
end
local on_player_gui_child_added
do
    local captured_value_7 = on_perk_added
    on_player_gui_child_added = function(argument_1_2): ()
        local value_4_9: string = "Perk"
        if (argument_1_2:HasTag(value_4_9)) then
            captured_value_7(argument_1_2)
        end

        return
    end
end
local on_pre_simulation: ((number) -> ())?
do
    local captured_value_8 = require_result
    on_pre_simulation = function(argument_1_3: number): ()
        local ceil_result, ceil_result_2, ceil_value, ceil_value_2, clock_result_2, clock_value_2, cooldown_value_10, cooldown_value_11, cooldown_value_12, cooldown_value_13, cooldown_value_5, cooldown_value_6, cooldown_value_7, cooldown_value_8, cooldown_value_9, from_rgb_result_4, from_rgb_result_5, from_rgb_value_4, from_rgb_value_5, passive_value_4, perk_button_value, perk_button_value_10, perk_button_value_11, perk_button_value_12, perk_button_value_13, perk_button_value_14, perk_button_value_15, perk_button_value_2, perk_button_value_3, perk_button_value_4, perk_button_value_5, perk_button_value_6, perk_button_value_7, perk_button_value_8, perk_button_value_9, value_2_36, value_2_37, value_2_38, value_2_39, value_3_18, value_3_19, value_3_20, value_3_21, value_3_22, value_3_23, value_3_24, value_3_25, value_3_26, value_3_27, value_3_28, value_3_29, value_3_30, value_3_31, value_3_32, value_4_10, value_4_11, value_4_12, value_4_13, value_4_14, value_4_15, value_4_16, value_4_17, value_4_18, value_5_17, value_5_18, value_5_19, value_5_20, value_5_21, value_5_22, value_5_23, value_5_24, value_5_25, value_6_24, value_6_25, value_6_26, value_6_27, value_6_28, value_7_21, value_7_22, value_7_23, value_8_19, value_9_7, visible_value
        local control_state = 0
        while true do
            if control_state < 8 then
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            value_2_36 = value_10
                            control_state = if value_2_36 then 2 else 1
                        else
                            return
                        end
                    else
                        if control_state < 3 then
                            value_2_37 = captured_value_8
                            perk_button_value = value_2_37.PerkButton
                            control_state = if perk_button_value then 4 else 3
                        else
                            return
                        end
                    end
                else
                    if control_state < 6 then
                        if control_state < 5 then
                            value_2_38 = captured_value_8
                            perk_button_value_2 = value_2_38.PerkButton
                            visible_value = perk_button_value_2.Visible
                            control_state = if visible_value then 6 else 5
                        else
                            return
                        end
                    else
                        if control_state < 7 then
                            clock_value_2 = os.clock
                            clock_result_2 = clock_value_2()
                            value_4_10 = value_6
                            value_2_39 = clock_result_2 - value_4_10
                            value_3_18 = value_8
                            control_state = if not value_3_18 then 9 else 7
                        else
                            value_3_19 = value_8
                            control_state = if not (value_2_39 < value_3_19) then 9 else 8
                        end
                    end
                end
            else
                if control_state < 12 then
                    if control_state < 10 then
                        if control_state < 9 then
                            value_3_20 = captured_value_8
                            perk_button_value_3 = value_3_20.PerkButton
                            cooldown_value_5 = perk_button_value_3.Cooldown
                            value_6_24 = value_8
                            value_5_17 = value_6_24 - value_2_39
                            ceil_value = math.ceil
                            ceil_result = ceil_value(value_5_17)
                            cooldown_value_5.Text = ceil_result
                            value_3_21 = captured_value_8
                            perk_button_value_4 = value_3_21.PerkButton
                            cooldown_value_6 = perk_button_value_4.Cooldown
                            value_4_11 = true
                            cooldown_value_6.Visible = value_4_11
                            value_3_22 = captured_value_8
                            perk_button_value_5 = value_3_22.PerkButton
                            cooldown_value_7 = perk_button_value_5.Cooldown
                            from_rgb_value_4 = Color3.fromRGB
                            value_5_18 = 50
                            value_6_25 = 200
                            value_7_21 = 50
                            from_rgb_result_4 = from_rgb_value_4(
                                value_5_18,
                                value_6_25,
                                value_7_21
                            )
                            cooldown_value_7.TextColor3 = from_rgb_result_4
                            value_3_23 = captured_value_8
                            perk_button_value_6 = value_3_23.PerkButton
                            cooldown_value_8 = perk_button_value_6.Cooldown
                            value_4_12 = 1
                            cooldown_value_8.BackgroundTransparency = value_4_12
                            value_3_24 = captured_value_8
                            perk_button_value_7 = value_3_24.PerkButton
                            value_4_13 = false
                            perk_button_value_7.AutoButtonColor = value_4_13

                            return
                        else
                            value_3_25 = value_7
                            control_state = if not value_3_25 then 12 else 10
                        end
                    else
                        if control_state < 11 then
                            value_3_26 = value_7
                            control_state = if not (value_2_39 < value_3_26) then 12 else 11
                        else
                            value_4_14 = value_7
                            value_3_27 = value_4_14 - value_2_39
                            value_5_19 = value_3_27
                            ceil_value_2 = math.ceil
                            ceil_result_2 = ceil_value_2(value_5_19)
                            value_5_20 = captured_value_8
                            perk_button_value_8 = value_5_20.PerkButton
                            cooldown_value_9 = perk_button_value_8.Cooldown
                            cooldown_value_9.Text = ceil_result_2
                            value_5_21 = captured_value_8
                            perk_button_value_9 = value_5_21.PerkButton
                            cooldown_value_10 = perk_button_value_9.Cooldown
                            value_6_26 = true
                            cooldown_value_10.Visible = value_6_26
                            value_5_22 = captured_value_8
                            perk_button_value_10 = value_5_22.PerkButton
                            cooldown_value_11 = perk_button_value_10.Cooldown
                            from_rgb_value_5 = Color3.fromRGB
                            value_7_22 = 200
                            value_8_19 = 200
                            value_9_7 = 200
                            from_rgb_result_5 = from_rgb_value_5(value_7_22, value_8_19, value_9_7)
                            cooldown_value_11.TextColor3 = from_rgb_result_5
                            value_5_23 = captured_value_8
                            perk_button_value_11 = value_5_23.PerkButton
                            cooldown_value_12 = perk_button_value_11.Cooldown
                            value_6_27 = 0.5
                            cooldown_value_12.BackgroundTransparency = value_6_27
                            value_5_24 = captured_value_8
                            perk_button_value_12 = value_5_24.PerkButton
                            value_6_28 = false
                            perk_button_value_12.AutoButtonColor = value_6_28

                            return
                        end
                    end
                else
                    if control_state < 14 then
                        if control_state < 13 then
                            value_3_28 = value_9
                            control_state = if not value_3_28 then 15 else 13
                        else
                            value_3_29 = value_9
                            value_4_15 = 0
                            control_state = if not (value_3_29 <= value_4_15) then 15 else 14
                        end
                    else
                        if control_state < 15 then
                            value_3_30 = captured_value_8
                            perk_button_value_13 = value_3_30.PerkButton
                            value_4_16 = false
                            perk_button_value_13.AutoButtonColor = value_4_16
                            control_state = 16
                        else
                            if control_state < 16 then
                                value_3_31 = captured_value_8
                                perk_button_value_14 = value_3_31.PerkButton
                                value_5_25 = value_10
                                value_7_23 = "Passive"
                                passive_value_4 = value_5_25:GetAttribute(value_7_23)
                                value_4_17 = not passive_value_4
                                perk_button_value_14.AutoButtonColor = value_4_17
                                control_state = 16
                            else
                                value_3_32 = captured_value_8
                                perk_button_value_15 = value_3_32.PerkButton
                                cooldown_value_13 = perk_button_value_15.Cooldown
                                value_4_18 = false
                                cooldown_value_13.Visible = value_4_18

                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
local on_initialize
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14 = local_player_value, on_perk_added, run_service, on_pre_simulation, player_gui_child, on_player_gui_child_added
    on_initialize = function()
        local workspace_value_5: Workspace = workspace
        local value_3_33: string = "Footsteps"
        if (workspace_value_5:FindFirstChild(value_3_33)) then
            local workspace_value_6: Workspace = workspace
            local value_3_34: string = "Footsteps"
            workspace_value_6:FindFirstChild(value_3_34):Destroy()
        end
        local g_value_7 = _G
        local value_2_43: boolean = false
        g_value_7.Sleight = value_2_43
        local g_value_8 = _G
        local value_2_44: boolean = false
        g_value_8.Ninja = value_2_44
        local g_value_9 = _G
        local value_2_45: boolean = false
        g_value_9.Haste = value_2_45
        local character_added_value = captured_value_9.CharacterAdded
        local value_3_35
        do
            local captured_value_15 = captured_value_10
            if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_15) then
                value_3_35 = closure_cache[3]
            else
                local closure_ready_6
                value_3_35 = function(argument_1_4)
                    if not closure_ready_6 then
                        return
                    end
                    local workspace_value_7: Workspace = workspace
                    local value_4_19: string = "Footsteps"
                    if (workspace_value_7:FindFirstChild(value_4_19)) then
                        local workspace_value_8: Workspace = workspace
                        local value_4_20: string = "Footsteps"
                        workspace_value_8:FindFirstChild(value_4_20):Destroy()
                    end
                    local g_value_10 = _G
                    local value_3_41: boolean = false
                    g_value_10.Sleight = value_3_41
                    local g_value_11 = _G
                    local value_3_42: boolean = false
                    g_value_11.Ninja = value_3_42
                    local g_value_12 = _G
                    local value_3_43: boolean = false
                    g_value_12.Haste = value_3_43
                    local child_added_value_2 = argument_1_4.ChildAdded
                    local value_4_21
                    do
                        local captured_value_16 = captured_value_15
                        if closure_cache[1] ~= nil and same_capture(
                            closure_cache[2],
                            captured_value_16
                        ) then
                            value_4_21 = closure_cache[1]
                        else
                            local closure_ready_5
                            value_4_21 = function(argument_1_5): ()
                                if not closure_ready_5 then
                                    return
                                end
                                local value_4_22: string = "Perk"
                                if (argument_1_5:HasTag(value_4_22)) then
                                    captured_value_16(argument_1_5)
                                end

                                return
                            end
                            closure_ready_5 = true
                            if closure_cache[1] == nil then
                                closure_cache[1] = value_4_21
                                closure_cache[2] = captured_value_16
                            end
                        end
                    end
                    child_added_value_2:Connect(value_4_21)

                    return
                end
                closure_ready_6 = true
                if closure_cache[3] == nil then
                    closure_cache[3] = value_3_35
                    closure_cache[4] = captured_value_15
                end
            end
        end
        character_added_value:Connect(value_3_35)
        local pre_simulation_value = captured_value_11.PreSimulation
        local value_3_36: (number) -> () = captured_value_12
        pre_simulation_value:Connect(value_3_36)
        local child_added_value = captured_value_13.ChildAdded
        local value_3_37 = captured_value_14
        child_added_value:Connect(value_3_37)

        return
    end
end
on_initialize()

return
