--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function shared_function(): ()
    return
end

local function shared_function_2(): ()
    return
end

local table_1 = {[("createButton")] = nil}

local function create_button(argument_1, argument_2, argument_3)
    local table_4 = {
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
    }
    table_4.Frame = argument_1
    local container_value = argument_1.Container
    table_4.Container = container_value
    local container_value_2 = table_4.Container
    container_value_2 = container_value_2.Shadow
    container_value_2 = container_value_2.Position
    container_value_2 = container_value_2.X
    container_value_2 = container_value_2.Offset
    container_value = math.abs
    container_value = container_value(container_value_2)
    table_4.shadowSize = container_value
    container_value = argument_3
    container_value = container_value or shared_function
    table_4.clickStart = container_value
    container_value = argument_2
    container_value = container_value or shared_function_2
    table_4.clickEnd = container_value
    container_value = false
    container_value_2 = true
    local reset: (<T1>(T1) -> ())?
    do
        local captured_value, closure_ready
        reset = function<T1>(argument_1_2: T1): ()
            if not closure_ready then
                return
            end
            container_value = false
            local container_value_3 = captured_value.Container
            local new_result = UDim2.new(1, 0, 1, 0)
            local out_value = Enum.EasingDirection.Out
            local back_value = Enum.EasingStyle.Back
            local value_7_5: number = 0.2
            local value_8_5: boolean = true
            container_value_3:TweenSize(new_result, out_value, back_value, value_7_5, value_8_5)
            local shadow_value = captured_value.Container.Shadow
            local new_result_2 = UDim2.new(
                1,
                captured_value.shadowSize * 2,
                1,
                captured_value.shadowSize * 3
            )
            local out_value_2 = Enum.EasingDirection.Out
            local back_value_2 = Enum.EasingStyle.Back
            local value_7_8: number = 0.2
            local value_8_7: boolean = true
            shadow_value:TweenSize(new_result_2, out_value_2, back_value_2, value_7_8, value_8_7)

            return
        end
        captured_value = table_4
        closure_ready = true
    end
    table_4.Reset = reset
    local press: (<T1>(T1) -> ())?
    do
        local captured_value_2, closure_ready_2
        press = function<T1>(argument_1_3: T1): ()
            if not closure_ready_2 then
                return
            end
            if not container_value_2 then
                return
            end
            container_value = true
            local container_value_5 = captured_value_2.Container
            local new_result_3 = UDim2.new(0.95, 0, 0.95, 0)
            local out_value_3 = Enum.EasingDirection.Out
            local quad_value = Enum.EasingStyle.Quad
            local value_7_10: number = 0.05
            local value_8_9: boolean = true
            container_value_5:TweenSize(
                new_result_3,
                out_value_3,
                quad_value,
                value_7_10,
                value_8_9
            )
            local shadow_value_2 = captured_value_2.Container.Shadow
            local new_result_4 = UDim2.new(
                1,
                captured_value_2.shadowSize * 2,
                1,
                captured_value_2.shadowSize * 2
            )
            local out_value_4 = Enum.EasingDirection.Out
            local quad_value_2 = Enum.EasingStyle.Quad
            local value_7_13: number = 0.05
            local value_8_11: boolean = true
            shadow_value_2:TweenSize(
                new_result_4,
                out_value_4,
                quad_value_2,
                value_7_13,
                value_8_11
            )

            return
        end
        captured_value_2 = table_4
        closure_ready_2 = true
    end
    table_4.Press = press
    local disable: (<T1>(T1) -> ())?
    do
        local captured_value_3, closure_ready_3
        disable = function<T1>(argument_1_4: T1): ()
            if not closure_ready_3 then
                return
            end
            container_value_2 = false
            local background_value = captured_value_3.Container.Background
            local value_3_5: boolean = false
            background_value.Visible = value_3_5

            return
        end
        captured_value_3 = table_4
        closure_ready_3 = true
    end
    table_4.Disable = disable
    local enable: (<T1>(T1) -> ())?
    do
        local captured_value_4, closure_ready_4
        enable = function<T1>(argument_1_5: T1): ()
            if not closure_ready_4 then
                return
            end
            container_value_2 = true
            local background_value_2 = captured_value_4.Container.Background
            local value_3_6: boolean = true
            background_value_2.Visible = value_3_6

            return
        end
        captured_value_4 = table_4
        closure_ready_4 = true
    end
    table_4.Enable = enable
    local get_enabled
    do
        local closure_ready_5
        get_enabled = function<T1>(argument_1_6: T1)
            if not closure_ready_5 then
                return
            end

            return container_value_2
        end
        closure_ready_5 = true
    end
    table_4.GetEnabled = get_enabled
    local clicked: (<T1>(T1) -> ())?
    do
        local captured_value_5, closure_ready_6
        clicked = function<T1>(argument_1_7: T1): ()
            if not closure_ready_6 then
                return
            end
            if container_value then
                if container_value_2 then
                    captured_value_5:Reset()
                    captured_value_5.clickStart()
                    task.wait(0.025)
                    captured_value_5.clickEnd()

                    return
                end
            end
            captured_value_5:Reset()

            return
        end
        captured_value_5 = table_4
        closure_ready_6 = true
    end
    table_4.Clicked = clicked
    local mouse_button1_down_value = table_4.Frame.Button.MouseButton1Down
    local press_value = table_4.Press
    mouse_button1_down_value:Connect(press_value)
    local mouse_button1_up_value = table_4.Frame.Button.MouseButton1Up
    local clicked_value = table_4.Clicked
    mouse_button1_up_value:Connect(clicked_value)
    local mouse_leave_value = table_4.Frame.MouseLeave
    local reset_value = table_4.Reset
    mouse_leave_value:Connect(reset_value)

    return table_4
end

table_1.createButton = create_button

return table_1
