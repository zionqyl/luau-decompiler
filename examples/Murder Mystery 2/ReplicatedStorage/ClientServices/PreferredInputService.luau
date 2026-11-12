--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("DeviceUpdated")] = nil, [("DeviceUpdated")] = nil}
local game_value: DataModel = game
local value_4: string = "UserInputService"
local user_input_service: Instance = game_value:GetService(value_4)
local game_value_2: DataModel = game
local value_5 = "GuiService"
local gui_service: Instance = game_value_2:GetService(value_5)
local game_value_3: DataModel = game
local value_6 = "RunService"
local is_studio_result = game_value_3:GetService(value_6):IsStudio()
value_5 = nil
value_6 = nil
local table_7 = {Small = "Small", Medium = "Medium", Large = "Large"}
local table_8: { Gamepad: string, KeyboardAndMouse: string, Touch: string } = {
    KeyboardAndMouse = "KeyboardAndMouse",
    Gamepad = "Gamepad",
    Touch = "Touch",
}
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.DeviceUpdated = new_result

local function get_device_info<T1>(argument_1: T1)
    return value_5, value_6
end

table_1.GetDeviceInfo = get_device_info
do
    local captured_value = gui_service

    local function update_screen_size(): ()
        if (captured_value:IsTenFootInterface()) then
            value_6 = "Large"

            return
        end
        if 600 <= workspace.CurrentCamera.ViewportSize.Y then
            value_6 = "Medium"

            return
        end
        value_6 = "Small"

        return
    end
end
local on_preferred_input_changed
do
    local captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6 = gui_service, table_7, user_input_service, is_studio_result, table_1
    on_preferred_input_changed = function()
        local current_camera_value_2, device_updated_value, gamepad_value, is_ten_foot_interface_result_2, keyboard_and_mouse_value, large_value, medium_value, preferred_input_value, small_value, touch_enabled_value, touch_value, value_1_4, value_1_6, value_1_7, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_8, value_2_9, viewport_size_value_2, workspace_value_2, y_value_2
        local control_state = 0
        while true do
            if control_state < 7 then
                if control_state < 3 then
                    if control_state < 1 then
                        value_1_4 = captured_value_2
                        is_ten_foot_interface_result_2 = value_1_4:IsTenFootInterface()
                        control_state = if not is_ten_foot_interface_result_2 then 2 else 1
                    else
                        if control_state < 2 then
                            value_1_6 = captured_value_3
                            large_value = value_1_6.Large
                            value_6 = large_value
                            control_state = 5
                        else
                            workspace_value_2 = workspace
                            current_camera_value_2 = workspace_value_2.CurrentCamera
                            viewport_size_value_2 = current_camera_value_2.ViewportSize
                            y_value_2 = viewport_size_value_2.Y
                            value_2_8 = 600
                            control_state = if not (value_2_8 <= y_value_2) then 4 else 3
                        end
                    end
                else
                    if control_state < 5 then
                        if control_state < 4 then
                            value_2_9 = captured_value_3
                            medium_value = value_2_9.Medium
                            value_6 = medium_value
                            control_state = 5
                        else
                            value_2_10 = captured_value_3
                            small_value = value_2_10.Small
                            value_6 = small_value
                            control_state = 5
                        end
                    else
                        if control_state < 6 then
                            value_1_7 = captured_value_4
                            preferred_input_value = value_1_7.PreferredInput
                            value_2_11 = captured_value_5
                            control_state = if not value_2_11 then 8 else 6
                        else
                            value_2_12 = captured_value_4
                            touch_enabled_value = value_2_12.TouchEnabled
                            control_state = if not touch_enabled_value then 8 else 7
                        end
                    end
                end
            else
                if control_state < 11 then
                    if control_state < 9 then
                        if control_state < 8 then
                            value_2_13 = "Touch"
                            value_5 = value_2_13
                            control_state = 14
                        else
                            keyboard_and_mouse_value = Enum.PreferredInput.KeyboardAndMouse
                            control_state = if preferred_input_value ~= keyboard_and_mouse_value then 10 else 9
                        end
                    else
                        if control_state < 10 then
                            value_2_14 = "KeyboardAndMouse"
                            value_5 = value_2_14
                            control_state = 14
                        else
                            gamepad_value = Enum.PreferredInput.Gamepad
                            control_state = if preferred_input_value ~= gamepad_value then 12 else 11
                        end
                    end
                else
                    if control_state < 13 then
                        if control_state < 12 then
                            value_2_15 = "Gamepad"
                            value_5 = value_2_15
                            control_state = 14
                        else
                            touch_value = Enum.PreferredInput.Touch
                            control_state = if preferred_input_value ~= touch_value then 14 else 13
                        end
                    else
                        if control_state < 14 then
                            value_2_16 = "Touch"
                            value_5 = value_2_16
                            control_state = 14
                        else
                            value_2_17 = captured_value_6
                            device_updated_value = value_2_17.DeviceUpdated
                            device_updated_value:Fire()

                            return
                        end
                    end
                end
            end
        end
    end
end
do
    local captured_value_7, captured_value_8 = user_input_service, on_preferred_input_changed

    local function on_initialize()
        local value_1_8: Instance = captured_value_7
        local value_3_5: string = "PreferredInput"
        local get_property_changed_signal_result_2: RBXScriptSignal<> = value_1_8:GetPropertyChangedSignal(
            value_3_5
        )
        local value_3_6 = captured_value_8
        get_property_changed_signal_result_2:Connect(value_3_6)
        captured_value_8()

        return
    end
end
local value_14: string = "PreferredInput"
local get_property_changed_signal_result: RBXScriptSignal<> = user_input_service:GetPropertyChangedSignal(
    value_14
)
local value_14_2 = on_preferred_input_changed
get_property_changed_signal_result:Connect(value_14_2)
on_preferred_input_changed()

return table_1
