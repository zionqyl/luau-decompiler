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
local value_4: string = "CollectionService"
local collection_service: Instance = game_value_2:GetService(value_4)
local table_3 = {
    ButtonA = true,
    ButtonB = true,
    ButtonX = true,
    ButtonY = true,
    ButtonL1 = true,
    ButtonL2 = true,
    ButtonR1 = true,
    ButtonR2 = true,
    ButtonSelect = true,
}
local table_4 = {
    ButtonA = "http://www.roblox.com/asset/?id=15026911220",
    ButtonCross = "http://www.roblox.com/asset/?id=15026902225",
    ButtonB = "http://www.roblox.com/asset/?id=15026912025",
    ButtonCircle = "http://www.roblox.com/asset/?id=15026903433",
    ButtonX = "http://www.roblox.com/asset/?id=15026867363",
    ButtonSquare = "http://www.roblox.com/asset/?id=15026893733",
    ButtonY = "http://www.roblox.com/asset/?id=15026912593",
    ButtonTriangle = "http://www.roblox.com/asset/?id=15026902848",
    ButtonLB = "http://www.roblox.com/asset/?id=15027131598",
    ButtonL1 = "http://www.roblox.com/asset/?id=15027138014",
    ButtonLT = "http://www.roblox.com/asset/?id=15027130434",
    ButtonL2 = "http://www.roblox.com/asset/?id=15027139880",
    ButtonRB = "http://www.roblox.com/asset/?id=15027131051",
    ButtonR1 = "http://www.roblox.com/asset/?id=15027138772",
    ButtonRT = "http://www.roblox.com/asset/?id=15027129964",
    ButtonR2 = "http://www.roblox.com/asset/?id=15027140259",
    ButtonSelect = "http://www.roblox.com/asset/?id=285737050",
    ButtonShare = "http://www.roblox.com/asset/?id=15027162581",
    ButtonTouchpad = "http://www.roblox.com/asset/?id=15027162581",
}
local get_button_icon
do
    local captured_value, captured_value_2 = user_input_service, table_4
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) and same_capture(
        closure_cache[3],
        captured_value_2
    ) then
        get_button_icon = closure_cache[1]
    else
        local closure_ready
        get_button_icon = function(argument_1)
            if not closure_ready then
                return
            end
            local value_2_3: Instance = captured_value
            local value_4_2 = argument_1

            return captured_value_2[(value_2_3:GetStringForKeyCode(value_4_2))]
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = get_button_icon
            closure_cache[2], closure_cache[3] = captured_value, captured_value_2
        end
    end
end
local g_value = _G
g_value.GetButtonIcon = get_button_icon
do
    local captured_value_3, captured_value_4 = user_input_service, table_4
    local on_button_icon_added
    if closure_cache[4] ~= nil and same_capture(closure_cache[5], captured_value_3) and same_capture(
        closure_cache[6],
        captured_value_4
    ) then
        on_button_icon_added = closure_cache[4]
    else
        local closure_ready_2
        on_button_icon_added = function(argument_1_2: string, argument_2)
            if not closure_ready_2 then
                return
            end
            local value_3_5: Instance = captured_value_3
            local value_5: string = argument_1_2
            local value_4_5 = captured_value_4[(value_3_5:GetStringForKeyCode(value_5))]
            argument_2.Image = value_4_5

            return
        end
        closure_ready_2 = true
        if closure_cache[4] == nil then
            closure_cache[4] = on_button_icon_added
            closure_cache[5], closure_cache[6] = captured_value_3, captured_value_4
        end
    end
end
local on_initialize
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8 = table_3, collection_service, user_input_service, table_4
    if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_5) and same_capture(
        closure_cache[9],
        captured_value_6
    ) and same_capture(closure_cache[10], captured_value_7) and same_capture(
        closure_cache[11],
        captured_value_8
    ) then
        on_initialize = closure_cache[7]
    else
        local closure_ready_4
        on_initialize = function()
            if not closure_ready_4 then
                return
            end
            local value_1_2 = captured_value_5
            local value_2_5: nil = nil
            local value_3_7: nil = nil
            for key_2, value_15 in value_1_2, value_2_5, value_3_7 do
                local value_4_6, value_5_3 = key_2, value_15
                local value_6 = "ButtonIcon_" .. value_4_6
                local value_7_3 = captured_value_6
                local value_9_2 = value_6
                local value_8_2
                value_7_3, value_8_2, value_9_2 = value_7_3:GetTagged(value_9_2)
                for key, value in value_7_3, value_8_2, value_9_2 do
                    local value_10, value_11 = key, value
                    local value_12: Instance = captured_value_7
                    local value_14 = value_4_6
                    local get_string_for_key_code_result_3 = value_12:GetStringForKeyCode(value_14)
                    local value_14_2 = captured_value_8
                    local value_13_2 = value_14_2[get_string_for_key_code_result_3]
                    value_11.Image = value_13_2
                end
                value_7_3 = captured_value_6
                value_9_2 = value_6
                value_7_3 = value_7_3:GetInstanceAddedSignal(value_9_2)
                do
                    local captured_value_9, captured_value_10, captured_value_11, closure_ready_3
                    value_9_2 = function(argument_1_3): ()
                        if not closure_ready_3 then
                            return
                        end
                        local value_2_6 = captured_value_9
                        local value_3_8 = captured_value_10
                        local value_5_4 = value_2_6
                        local value_4_8 = captured_value_11[(value_3_8:GetStringForKeyCode(
                            value_5_4
                        ))]
                        argument_1_3.Image = value_4_8

                        return
                    end
                    captured_value_9, captured_value_10, captured_value_11 = value_4_6, captured_value_7, captured_value_8
                    closure_ready_3 = true
                end
                value_7_3:Connect(value_9_2)
            end

            return
        end
        closure_ready_4 = true
        if closure_cache[7] == nil then
            closure_cache[7] = on_initialize
            closure_cache[8], closure_cache[9], closure_cache[10], closure_cache[11] = captured_value_5, captured_value_6, captured_value_7, captured_value_8
        end
    end
end
while true do
    local wait_value: (number?) -> (number) = task.wait
    wait_value()
    local game_value_3: DataModel = game
    local players_value = game_value_3.Players
    local local_player_value = players_value.LocalPlayer
    local player_gui_value = local_player_value.PlayerGui
    local value_9: string = "MainGUI"
    local main_gui_child = player_gui_value:FindFirstChild(value_9)
    if main_gui_child then
        break
    end
end
on_initialize()

return
