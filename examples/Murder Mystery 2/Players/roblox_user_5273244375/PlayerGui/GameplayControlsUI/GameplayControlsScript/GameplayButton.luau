--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("new")] = nil}
local player_gui_value = game.Players.LocalPlayer.PlayerGui
local value_4: string = "InputContext"
local input_context_child = player_gui_value:WaitForChild(value_4)
local value_5: string = "GameplayContext"
local gameplay_context_child = input_context_child:WaitForChild(value_5)
local new
do
    local captured_value = gameplay_context_child
    new = function(argument_1)
        local table_2 = {[("Enabled")] = nil, [("Enabled")] = nil, [("Enabled")] = nil}
        local value_3_3 = captured_value
        local name_value = argument_1.Name
        local wait_for_child_result = value_3_3:WaitForChild(name_value)
        local value_4_4: boolean = true
        table_2.Enabled = value_4_4
        table_2.ImageButton = argument_1
        local new_result: BindableEvent = Instance.new("BindableEvent")
        table_2.Activated = new_result
        local set_enabled: (<T1>(T1, boolean) -> ())?
        do
            local captured_value_2, captured_value_3, closure_ready
            set_enabled = function<T1>(argument_1_2: T1, argument_2: boolean): ()
                if not closure_ready then
                    return
                end
                if argument_2 == true then
                    local control_text_value = captured_value_2.ControlText
                    local value_4_5: number = 0
                    control_text_value.TextTransparency = value_4_5
                    local control_icon_value = captured_value_2.ControlIcon
                    local value_4_6: number = 0
                    control_icon_value.ImageTransparency = value_4_6
                    local value_3_7 = captured_value_2
                    local value_4_7: number = 0
                    value_3_7.ImageTransparency = value_4_7
                else
                    local control_text_value_2 = captured_value_2.ControlText
                    local value_4_8: number = 0.7
                    control_text_value_2.TextTransparency = value_4_8
                    local control_icon_value_2 = captured_value_2.ControlIcon
                    local value_4_9: number = 0.7
                    control_icon_value_2.ImageTransparency = value_4_9
                    local value_3_10 = captured_value_2
                    local value_4_10: number = 0.7
                    value_3_10.ImageTransparency = value_4_10
                    local value_3_11 = captured_value_2
                    local from_rgb_result: Color3 = Color3.fromRGB(0, 0, 0)
                    value_3_11.ImageColor3 = from_rgb_result
                end
                local value_3_12 = captured_value_3
                local value_4_11: boolean?
                if argument_2 ~= true then
                    value_4_11 = false
                else
                    value_4_11 = true
                end
                value_3_12.Enabled = value_4_11

                return
            end
            captured_value_2, captured_value_3 = argument_1, table_2
            closure_ready = true
        end
        table_2.SetEnabled = set_enabled
        if wait_for_child_result then
            local touch_binding_value = wait_for_child_result.TouchBinding
            touch_binding_value.UIButton = argument_1
            local on_pressed: (() -> ())?
            do
                local captured_value_4, captured_value_5, closure_ready_2
                on_pressed = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    if not captured_value_4.Enabled then
                        return
                    end
                    local value_1_2 = captured_value_5
                    local from_rgb_result_2: Color3 = Color3.fromRGB(170, 170, 170)
                    value_1_2.ImageColor3 = from_rgb_result_2
                    captured_value_4.Activated:Fire()

                    return
                end
                captured_value_4, captured_value_5 = table_2, argument_1
                closure_ready_2 = true
            end
            local on_released: (() -> ())?
            do
                local captured_value_6, closure_ready_3
                on_released = function(): ()
                    if not closure_ready_3 then
                        return
                    end
                    local value_1_5 = captured_value_6
                    local from_rgb_result_3: Color3 = Color3.fromRGB(0, 0, 0)
                    value_1_5.ImageColor3 = from_rgb_result_3

                    return
                end
                captured_value_6 = argument_1
                closure_ready_3 = true
            end
            local pressed_value = wait_for_child_result.Pressed
            local value_8: () -> () = on_pressed
            pressed_value:Connect(value_8)
            local released_value = wait_for_child_result.Released
            local value_8_2: () -> () = on_released
            released_value:Connect(value_8_2)
            local mouse_leave_value = argument_1.MouseLeave
            local value_8_3: (() -> ())?
            do
                local captured_value_7, closure_ready_4
                value_8_3 = function(): ()
                    if not closure_ready_4 then
                        return
                    end
                    local value_1_6 = captured_value_7
                    local value_3_15: boolean = false
                    value_1_6:Fire(value_3_15)

                    return
                end
                captured_value_7 = wait_for_child_result
                closure_ready_4 = true
            end
            mouse_leave_value:Connect(value_8_3)
        end

        return table_2
    end
end
table_1.new = new

return table_1
