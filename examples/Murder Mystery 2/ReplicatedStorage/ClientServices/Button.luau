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

local game_value: DataModel = game
local value_3: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_3)
local new_result: TweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local new_result_2: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local table_3 = {[("createButton")] = nil}
local create_button
do
    local captured_value, captured_value_2 = tween_service, new_result
    create_button = function(argument_1, argument_2, argument_3)
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
        local position_value = table_4.Container.Position
        local position_value_2 = table_4.Container.Shadow.Position
        local reset: (<T1>(T1) -> ())?
        do
            local captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, closure_ready
            reset = function<T1>(argument_1_2: T1): ()
                if not closure_ready then
                    return
                end
                container_value = false
                local value_2_3: Instance? = captured_value_3
                local container_value_5 = captured_value_4.Container
                local value_5: TweenInfo? = captured_value_5
                local table_6 = {
                    Size = UDim2.fromScale(1, 1),
                    Position = captured_value_6,
                }
                value_2_3:Create(container_value_5, value_5, table_6):Play()
                local value_2_6: Instance? = captured_value_3
                local shadow_value_2 = captured_value_4.Container.Shadow
                local value_5_2: TweenInfo? = captured_value_5
                local table_6_2 = {
                    Size = UDim2.new(
                        1,
                        captured_value_4.shadowSize * 2,
                        1,
                        captured_value_4.shadowSize * 3
                    ),
                    Position = captured_value_7,
                }
                value_2_6:Create(shadow_value_2, value_5_2, table_6_2):Play()

                return
            end
            captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7 = captured_value, table_4, captured_value_2, position_value, position_value_2
            closure_ready = true
        end
        table_4.Reset = reset
        local press: (<T1>(T1) -> ())?
        do
            local captured_value_8, captured_value_9, captured_value_10, closure_ready_2
            press = function<T1>(argument_1_3: T1): ()
                if not closure_ready_2 then
                    return
                end
                if not container_value_2 then
                    return
                end
                container_value = true
                local value_2_11: Instance? = captured_value_8
                local container_value_7 = captured_value_9.Container
                local value_5_3: TweenInfo? = captured_value_10
                local table_6_3 = {
                    Size = UDim2.fromScale(0.95, 0.95),
                    Position = captured_value_9.Container.Position + (UDim2.new(0, 0, 0, 2)),
                }
                value_2_11:Create(container_value_7, value_5_3, table_6_3):Play()
                local value_2_14: Instance? = captured_value_8
                local shadow_value_3 = captured_value_9.Container.Shadow
                local value_5_4: TweenInfo? = captured_value_10
                local table_6_4 = {
                    Size = UDim2.new(
                        1,
                        captured_value_9.shadowSize * 2,
                        1,
                        captured_value_9.shadowSize * 2
                    ),
                    Position = captured_value_9.Container.Shadow.Position,
                }
                value_2_14:Create(shadow_value_3, value_5_4, table_6_4):Play()

                return
            end
            captured_value_8, captured_value_9, captured_value_10 = captured_value, table_4, captured_value_2
            closure_ready_2 = true
        end
        table_4.Press = press
        local disable: (<T1>(T1) -> ())?
        do
            local captured_value_11, closure_ready_3
            disable = function<T1>(argument_1_4: T1): ()
                if not closure_ready_3 then
                    return
                end
                container_value_2 = false
                local background_value = captured_value_11.Container.Background
                local value_3_11: boolean = false
                background_value.Visible = value_3_11

                return
            end
            captured_value_11 = table_4
            closure_ready_3 = true
        end
        table_4.Disable = disable
        local enable: (<T1>(T1) -> ())?
        do
            local captured_value_12, closure_ready_4
            enable = function<T1>(argument_1_5: T1): ()
                if not closure_ready_4 then
                    return
                end
                container_value_2 = true
                local background_value_2 = captured_value_12.Container.Background
                local value_3_12: boolean = true
                background_value_2.Visible = value_3_12

                return
            end
            captured_value_12 = table_4
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
            local captured_value_13, closure_ready_6
            clicked = function<T1>(argument_1_7: T1): ()
                if not closure_ready_6 then
                    return
                end
                if container_value then
                    if container_value_2 then
                        captured_value_13:Reset()
                        captured_value_13.clickStart()
                        task.wait(0.025)
                        captured_value_13.clickEnd()

                        return
                    end
                end
                captured_value_13:Reset()

                return
            end
            captured_value_13 = table_4
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
end
table_3.createButton = create_button

return table_3
