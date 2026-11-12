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

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "EventInfoService"
local require_result = require_value(shared_services_child:WaitForChild(value_4_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
local value_5_3: string = "WindowService"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_5_3))
local parent_value: Instance? = script.Parent
local value_6: string = "CenterIcon"
local center_icon_child = parent_value:WaitForChild(value_6)
local on_event_start
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = require_result, parent_value, center_icon_child, require_result_2
    on_event_start = function()
        local get_main_event_result = captured_value:GetMainEvent()
        local ui_value = get_main_event_result.EventStartInfo.UI
        do
            local take_fallback = not ui_value
            if not take_fallback then
                take_fallback = not get_main_event_result.EventStartInfo.UI.ShopButton
            end
            if take_fallback then
                return
            end
        end
        local value_2_5: Instance? = captured_value_2
        local value_3_7: boolean = true
        value_2_5.Visible = value_3_7
        local value_2_6 = captured_value_3
        local shop_button_value_2 = get_main_event_result.EventStartInfo.UI.ShopButton
        value_2_6.Image = shop_button_value_2
        local value_2_7 = captured_value_3
        local value_3_8: boolean = true
        value_2_7.Visible = value_3_8
        if get_main_event_result.EventStartInfo.UI.PrimaryColor then
            local value_2_8: Instance? = captured_value_2
            local value_4_8: string = "Background"
            local background_child = value_2_8:WaitForChild(value_4_8)
            local primary_color_value_2 = get_main_event_result.EventStartInfo.UI.PrimaryColor
            background_child.BackgroundColor3 = primary_color_value_2
        else
            local value_2_10: Instance? = captured_value_2
            local value_4_9: string = "Background"
            local background_child_2 = value_2_10:WaitForChild(value_4_9)
            local from_rgb_result: Color3 = Color3.fromRGB(0, 0, 0)
            background_child_2.BackgroundColor3 = from_rgb_result
            local value_2_12: Instance? = captured_value_2
            local value_4_11: string = "Background"
            local background_child_3 = value_2_12:WaitForChild(value_4_11)
            local value_3_12: number = 0.6
            background_child_3.Transparency = value_3_12
        end
        local activated_value = captured_value_2.Activated
        local value_4_12
        do
            local captured_value_5 = captured_value_4
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_5) then
                value_4_12 = closure_cache[1]
            else
                local closure_ready
                value_4_12 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local value_1_3 = captured_value_5
                    local value_3_14: string = "CurrentEvent"
                    value_1_3:ToggleFrame(value_3_14)

                    return
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_12
                    closure_cache[2] = captured_value_5
                end
            end
        end
        activated_value:Connect(value_4_12)

        return
    end
end
local value_6_2: boolean = false
parent_value.Visible = value_6_2
local value_8 = on_event_start
require_result:OnMainEventStarted(value_8)
local value_8_2
do
    local captured_value_6 = parent_value
    value_8_2 = function(argument_1): ()
        local event_start_info_value_6, priority_value, shop_button_value_3, ui_value_6, ui_value_7, value_3_15, value_4_13
        local control_state = 0
        while true do
            if control_state < 3 then
                if control_state < 1 then
                    priority_value = argument_1.Priority
                    control_state = if priority_value == "Main" then 2 else 1
                else
                    if control_state < 2 then
                        return
                    else
                        event_start_info_value_6 = argument_1.EventStartInfo
                        control_state = if not event_start_info_value_6 then 5 else 3
                    end
                end
            else
                if control_state < 5 then
                    if control_state < 4 then
                        ui_value_6 = event_start_info_value_6.UI
                        control_state = if not ui_value_6 then 5 else 4
                    else
                        ui_value_7 = event_start_info_value_6.UI
                        shop_button_value_3 = ui_value_7.ShopButton
                        control_state = if shop_button_value_3 then 6 else 5
                    end
                else
                    if control_state < 6 then
                        value_3_15 = captured_value_6
                        value_4_13 = false
                        value_3_15.Visible = value_4_13
                        control_state = 6
                    else
                        return
                    end
                end
            end
        end
    end
end
require_result:OnEventEnded(value_8_2)

return
