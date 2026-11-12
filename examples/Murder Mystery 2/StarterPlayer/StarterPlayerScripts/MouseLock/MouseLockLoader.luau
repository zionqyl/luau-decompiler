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

local parent_value_2 = script.Parent.Parent
local game_value: DataModel = game
local value_4: string = "UserInputService"
local user_input_service: Instance = game_value:GetService(value_4)
local value_5: string = "MouseLock"
local mouse_lock_child = parent_value_2:WaitForChild(value_5)
local value_6: string = "PlayerModule"
local player_module_child = parent_value_2:WaitForChild(value_6)
local value_7: string = "CameraModule"
local value_1 = (player_module_child:WaitForChild(value_7))
local value_7_2: string = "MouseLockController"
local mouse_lock_controller_child = value_1:WaitForChild(value_7_2)
local camera_offset_value = script.CameraOffset
camera_offset_value.Parent = mouse_lock_controller_child
local cursor_image_value = script.CursorImage
cursor_image_value.Parent = mouse_lock_controller_child
local bound_keys_value = script.BoundKeys
bound_keys_value.Parent = mouse_lock_controller_child
local cameras_value = require(player_module_child).cameras
local add_mouse_lock_controlller
do
    local captured_value, captured_value_2 = mouse_lock_controller_child, cameras_value
    add_mouse_lock_controlller = function()
        local require_result_2 = require(captured_value)
        local value_2_3 = captured_value_2
        local new_result = require_result_2.new()
        value_2_3.activeMouseLockController = new_result
        local get_bindable_toggle_event_result = captured_value_2.activeMouseLockController:GetBindableToggleEvent()
        if get_bindable_toggle_event_result then
            local value_4_4
            do
                local captured_value_3 = captured_value_2
                if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_3) then
                    value_4_4 = closure_cache[1]
                else
                    local closure_ready
                    value_4_4 = function(): ()
                        if not closure_ready then
                            return
                        end
                        captured_value_3:OnMouseLockToggled()

                        return
                    end
                    closure_ready = true
                    if closure_cache[1] == nil then
                        closure_cache[1] = value_4_4
                        closure_cache[2] = captured_value_3
                    end
                end
            end
            get_bindable_toggle_event_result:Connect(value_4_4)
        end

        return
    end
end
local trigger_mouse_lock
do
    local captured_value_4, captured_value_5 = cameras_value, mouse_lock_child
    trigger_mouse_lock = function(argument_1)
        local active_mouse_lock_controller_value_2, active_mouse_lock_controller_value_3, active_mouse_lock_controller_value_4, active_mouse_lock_controller_value_5, active_mouse_lock_controller_value_6, active_mouse_lock_controller_value_7, is_mouse_locked_value, is_mouse_locked_value_2, is_mouse_locked_value_3, value_2_7, value_3_4, value_4_5, value_5_5, value_6_10, value_6_12, value_6_4, value_6_6, value_6_8, value_8, value_9
        local control_state = 0
        while true do
            if control_state < 9 then
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            value_2_7 = captured_value_4
                            active_mouse_lock_controller_value_2 = value_2_7.activeMouseLockController
                            is_mouse_locked_value = active_mouse_lock_controller_value_2.isMouseLocked
                            control_state = if argument_1 == true then 2 else 1
                        else
                            value_3_4 = false
                            control_state = 3
                        end
                    else
                        if control_state < 3 then
                            value_3_4 = true
                            control_state = 3
                        else
                            control_state = if argument_1 == false then 5 else 4
                        end
                    end
                else
                    if control_state < 6 then
                        if control_state < 5 then
                            value_4_5 = false
                            control_state = 6
                        else
                            value_4_5 = true
                            control_state = 6
                        end
                    else
                        if control_state < 7 then
                            control_state = if argument_1 == nil then 8 else 7
                        else
                            if control_state < 8 then
                                value_5_5 = false
                                control_state = 9
                            else
                                value_5_5 = true
                                control_state = 9
                            end
                        end
                    end
                end
            else
                if control_state < 13 then
                    if control_state < 11 then
                        if control_state < 10 then
                            control_state = if not value_3_4 then 12 else 10
                        else
                            control_state = if is_mouse_locked_value then 12 else 11
                        end
                    else
                        if control_state < 12 then
                            value_6_4 = captured_value_4
                            active_mouse_lock_controller_value_3 = value_6_4.activeMouseLockController
                            active_mouse_lock_controller_value_3:OnMouseLockToggled()
                            control_state = 17
                        else
                            control_state = if not value_4_5 then 15 else 13
                        end
                    end
                else
                    if control_state < 15 then
                        if control_state < 14 then
                            control_state = if not is_mouse_locked_value then 15 else 14
                        else
                            value_6_6 = captured_value_4
                            active_mouse_lock_controller_value_4 = value_6_6.activeMouseLockController
                            active_mouse_lock_controller_value_4:OnMouseLockToggled()
                            control_state = 17
                        end
                    else
                        if control_state < 16 then
                            control_state = if not value_5_5 then 17 else 16
                        else
                            if control_state < 17 then
                                value_6_8 = captured_value_4
                                active_mouse_lock_controller_value_5 = value_6_8.activeMouseLockController
                                active_mouse_lock_controller_value_5:OnMouseLockToggled()
                                control_state = 17
                            else
                                value_6_10 = captured_value_5
                                value_8 = "Enabled"
                                value_9 = captured_value_4
                                active_mouse_lock_controller_value_6 = value_9.activeMouseLockController
                                is_mouse_locked_value_2 = active_mouse_lock_controller_value_6.isMouseLocked
                                value_6_10:SetAttribute(value_8, is_mouse_locked_value_2)
                                value_6_12 = captured_value_4
                                active_mouse_lock_controller_value_7 = value_6_12.activeMouseLockController
                                is_mouse_locked_value_3 = active_mouse_lock_controller_value_7.isMouseLocked

                                return is_mouse_locked_value_3
                            end
                        end
                    end
                end
            end
        end
    end
end
triggerMouseLock = trigger_mouse_lock
local on_initialize
do
    local captured_value_6, captured_value_7, captured_value_8, captured_value_9 = user_input_service, cameras_value, add_mouse_lock_controlller, mouse_lock_child
    on_initialize = function()
        if captured_value_6.TouchEnabled then
            if captured_value_7.activeMouseController == nil then
                captured_value_8()
            end
        end
        local value_1_10 = captured_value_9
        local value_3_5: string = "Enabled"
        local value_4_6: boolean = false
        value_1_10:SetAttribute(value_3_5, value_4_6)
        local value_1_12 = captured_value_9
        local trigger_mouse_lock_value = triggerMouseLock
        value_1_12.OnInvoke = trigger_mouse_lock_value
        local get_bindable_toggle_event_result_2 = captured_value_7.activeMouseLockController:GetBindableToggleEvent()
        local value_3_6
        do
            local captured_value_10 = captured_value_7
            if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_10) then
                value_3_6 = closure_cache[3]
            else
                local closure_ready_2
                value_3_6 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    local mouse_lock_toggled_value = script.Parent.MouseLockToggled
                    local is_mouse_locked_value_4 = captured_value_10.activeMouseLockController.isMouseLocked
                    mouse_lock_toggled_value:Fire(is_mouse_locked_value_4)

                    return
                end
                closure_ready_2 = true
                if closure_cache[3] == nil then
                    closure_cache[3] = value_3_6
                    closure_cache[4] = captured_value_10
                end
            end
        end
        get_bindable_toggle_event_result_2:Connect(value_3_6)

        return
    end
end
on_initialize()

return
