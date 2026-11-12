--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local collection_service, game_value, game_value_2, game_value_3, game_value_4, game_value_5, get_device_info, get_mouse_result, get_property_changed_signal_result, get_screen_size, gui_service, is_mobile_device, is_ten_foot_interface_result, keyboard_and_mouse_value, local_player_value, new_result, new_value, on_initialize, on_preferred_input_changed, players_value, require_result, require_value, run_service, script_value, table_8, table_9, user_input_service, value_10, value_12, value_16_2, value_18, value_18_2, value_2, value_3, value_4, value_5, value_6, value_6_2, view_size_x_value, view_size_y_value, x_value, y_value
local control_state = 0
while true do
    if control_state < 3 then
        if control_state < 1 then
            new_value = Vector2.new
            value_2 = 768
            value_3 = 1024
            new_result = new_value(value_2, value_3)
            game_value = game
            value_4 = "UserInputService"
            user_input_service = game_value:GetService(value_4)
            game_value_2 = game
            value_5 = "CollectionService"
            collection_service = game_value_2:GetService(value_5)
            game_value_3 = game
            value_6 = "RunService"
            run_service = game_value_3:GetService(value_6)
            game_value_4 = game
            value_6_2 = "GuiService"
            gui_service = game_value_4:GetService(value_6_2)
            game_value_5 = game
            players_value = game_value_5.Players
            local_player_value = players_value.LocalPlayer
            get_mouse_result = local_player_value:GetMouse()
            require_value = require
            script_value = script
            value_10 = "KeybindImages"
            require_result = require_value(script_value:WaitForChild(value_10))
            table_8 = {Large = "Large", Medium = "Medium", Small = "Small"}
            table_9 = {[("IsMobileDevice")] = nil, [("IsMobileDevice")] = nil}
            value_10 = "Medium"
            keyboard_and_mouse_value = Enum.PreferredInput.KeyboardAndMouse
            value_12 = nil
            do
                local captured_value, captured_value_2, captured_value_3 = gui_service, get_mouse_result, new_result
                get_screen_size = function(): string
                    if (captured_value:IsTenFootInterface()) then
                        return "Large"
                    end
                    local view_size_x_value_2 = captured_value_2.ViewSizeX
                    if captured_value_3.X <= view_size_x_value_2 then
                        local view_size_y_value_2 = captured_value_2.ViewSizeY
                        if captured_value_3.Y <= view_size_y_value_2 then
                            return "Medium"
                        end
                    end

                    return "Small"
                end
            end
            do
                local captured_value_4, captured_value_5, captured_value_6, captured_value_7 = user_input_service, local_player_value, collection_service, require_result
                on_preferred_input_changed = function(): ()
                    keyboard_and_mouse_value = captured_value_4.PreferredInput
                    local value_1_9 = keyboard_and_mouse_value
                    local touch_value = Enum.PreferredInput.Touch
                    if value_1_9 == touch_value then
                        if value_12 == nil then
                            local spawn_value = task.spawn
                            do
                                local captured_value_8, closure_ready
                                touch_value = function(): ()
                                    if not closure_ready then
                                        return
                                    end
                                    local player_gui_value = captured_value_8.PlayerGui
                                    local value_3_5: string = "TouchGui"
                                    local touch_gui_child = player_gui_value:WaitForChild(
                                        value_3_5
                                    )
                                    local value_4_6: string = "TouchControlFrame"
                                    local touch_control_frame_child = touch_gui_child:WaitForChild(
                                        value_4_6
                                    )
                                    local value_4_7: string = "JumpButton"
                                    local value_3_8: boolean?
                                    if touch_control_frame_child:WaitForChild(value_4_7).Size ~= (UDim2.new(
                                        0,
                                        120,
                                        0,
                                        120
                                    )) then
                                        value_3_8 = false
                                    else
                                        value_3_8 = true
                                    end
                                    value_12 = value_3_8

                                    return
                                end
                                captured_value_8 = captured_value_5
                                closure_ready = true
                            end
                            spawn_value(touch_value)
                        end
                    end
                    local value_1_11 = keyboard_and_mouse_value
                    touch_value = Enum.PreferredInput.KeyboardAndMouse
                    local value_3_4: string?, value_4_5: nil, value_5_4, value_6_4
                    if value_1_11 == touch_value then
                        local value_1_12 = captured_value_6
                        value_3_4 = "KeybindIcon"
                        touch_value = (value_1_12:GetTagged(value_3_4))
                        value_3_4 = nil
                        value_4_5 = nil
                        for key, value in touch_value, value_3_4, value_4_5 do
                            value_5_4, value_6_4 = key, value
                            local value_7_2 = captured_value_7
                            local keyboard_button_value = value_7_2.KeyboardButton
                            value_6_4.Image = keyboard_button_value
                            local text_label_value = value_6_4.TextLabel
                            local value_9_2: boolean = true
                            text_label_value.Visible = value_9_2
                        end

                        return
                    end
                    local value_1_14 = keyboard_and_mouse_value
                    touch_value = Enum.PreferredInput.Gamepad
                    if value_1_14 == touch_value then
                        local value_1_15 = captured_value_6
                        value_3_4 = "KeybindIcon"
                        touch_value = (value_1_15:GetTagged(value_3_4))
                        value_3_4 = nil
                        value_4_5 = nil
                        for key_2, value_13 in touch_value, value_3_4, value_4_5 do
                            value_5_4, value_6_4 = key_2, value_13
                            local value_7_3 = captured_value_4
                            local value_11: string = "Keybind_Gamepad"
                            local get_string_for_key_code_result = (function(...)
                                return value_7_3:GetStringForKeyCode(...)
                            end)(value_6_4:GetAttribute(value_11))
                            local value_9_4 = captured_value_7
                            local value_8_3 = value_9_4[get_string_for_key_code_result]
                            value_6_4.Image = value_8_3
                            local text_label_value_2 = value_6_4.TextLabel
                            local value_10_3: boolean = false
                            text_label_value_2.Visible = value_10_3
                        end
                    end

                    return
                end
            end
            is_mobile_device = function<T1>(argument_1: T1): boolean
                local value_2_9: boolean?
                if keyboard_and_mouse_value ~= Enum.PreferredInput.Touch then
                    value_2_9 = false
                else
                    value_2_9 = true
                end

                return value_2_9
            end
            table_9.IsMobileDevice = is_mobile_device
            get_device_info = function<T1>(argument_1_2: T1)
                return keyboard_and_mouse_value, value_10
            end
            table_9.GetDeviceInfo = get_device_info
            do
                local captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14 = gui_service, table_8, get_mouse_result, new_result, on_preferred_input_changed, user_input_service
                on_initialize = function()
                    local get_property_changed_signal_result_2, is_ten_foot_interface_result_3, large_value, value_1_19, value_1_20, value_1_21, value_1_22, value_1_23, value_2_11, value_2_13, value_2_14, value_3_12, value_3_13, value_3_14, value_3_15, view_size_x_value_3, view_size_y_value_3, x_value_3, y_value_3
                    local control_state_2 = 0
                    while true do
                        if control_state_2 < 3 then
                            if control_state_2 < 1 then
                                value_2_11 = captured_value_9
                                is_ten_foot_interface_result_3 = value_2_11:IsTenFootInterface()
                                control_state_2 = if not is_ten_foot_interface_result_3 then 2 else 1
                            else
                                if control_state_2 < 2 then
                                    value_1_19 = captured_value_10
                                    large_value = value_1_19.Large
                                    control_state_2 = 6
                                else
                                    value_2_13 = captured_value_11
                                    view_size_x_value_3 = value_2_13.ViewSizeX
                                    value_3_12 = captured_value_12
                                    x_value_3 = value_3_12.X
                                    control_state_2 = if not (x_value_3 <= view_size_x_value_3) then 5 else 3
                                end
                            end
                        else
                            if control_state_2 < 5 then
                                if control_state_2 < 4 then
                                    value_2_14 = captured_value_11
                                    view_size_y_value_3 = value_2_14.ViewSizeY
                                    value_3_13 = captured_value_12
                                    y_value_3 = value_3_13.Y
                                    control_state_2 = if not (y_value_3 <= view_size_y_value_3) then 5 else 4
                                else
                                    value_1_20 = captured_value_10
                                    large_value = value_1_20.Medium
                                    control_state_2 = 6
                                end
                            else
                                if control_state_2 < 6 then
                                    value_1_21 = captured_value_10
                                    large_value = value_1_21.Small
                                    control_state_2 = 6
                                else
                                    value_10 = large_value
                                    value_1_22 = captured_value_13
                                    value_1_22()
                                    value_1_23 = captured_value_14
                                    value_3_14 = "PreferredInput"
                                    get_property_changed_signal_result_2 = value_1_23:GetPropertyChangedSignal(
                                        value_3_14
                                    )
                                    value_3_15 = captured_value_13
                                    get_property_changed_signal_result_2:Connect(value_3_15)

                                    return
                                end
                            end
                        end
                    end
                end
            end
            is_ten_foot_interface_result = gui_service:IsTenFootInterface()
            control_state = if not is_ten_foot_interface_result then 2 else 1
        else
            if control_state < 2 then
                value_10 = table_8.Large
                control_state = 6
            else
                view_size_x_value = get_mouse_result.ViewSizeX
                x_value = new_result.X
                control_state = if not (x_value <= view_size_x_value) then 5 else 3
            end
        end
    else
        if control_state < 5 then
            if control_state < 4 then
                view_size_y_value = get_mouse_result.ViewSizeY
                y_value = new_result.Y
                control_state = if not (y_value <= view_size_y_value) then 5 else 4
            else
                value_10 = table_8.Medium
                control_state = 6
            end
        else
            if control_state < 6 then
                value_10 = table_8.Small
                control_state = 6
            else
                value_16_2 = on_preferred_input_changed
                value_16_2()
                value_18 = "PreferredInput"
                get_property_changed_signal_result = user_input_service:GetPropertyChangedSignal(
                    value_18
                )
                value_18_2 = on_preferred_input_changed
                get_property_changed_signal_result:Connect(value_18_2)

                return table_9
            end
        end
    end
end
