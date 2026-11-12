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
local value_4_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
local value_5_3: string = "EventInfoService"
local require_result_2 = require_value_2(shared_services_child:WaitForChild(value_5_3))
local parent_value: Instance? = script.Parent
local value_5_4: string = "CoverPhoto"
local cover_photo_child = parent_value:WaitForChild(value_5_4)
local parent_value_2: Instance? = script.Parent
local value_6 = "EventPhoto"
local event_photo_child = parent_value_2:WaitForChild(value_6)
local parent_value_3: Instance? = script.Parent
local value_7: string = "BasePhoto"
local base_photo_child = parent_value_3:WaitForChild(value_7)
value_6 = nil
local on_initialize
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5 = require_result_2, event_photo_child, base_photo_child, cover_photo_child, require_result
    on_initialize = function()
        local get_main_event_result = captured_value:GetMainEvent()
        if get_main_event_result then
            if get_main_event_result.EventStartInfo then
                if get_main_event_result.EventStartInfo.UI then
                    if get_main_event_result.EventStartInfo.UI.ShopCover then
                        local value_2_5 = captured_value_2
                        local shop_cover_value_2 = get_main_event_result.EventStartInfo.UI.ShopCover
                        value_2_5.Image = shop_cover_value_2
                        local value_2_6 = captured_value_2
                        local value_3_8: boolean = true
                        value_2_6.Visible = value_3_8
                        local value_2_7 = captured_value_3
                        local value_3_9: boolean = false
                        value_2_7.Visible = value_3_9
                        local value_2_8 = captured_value_4
                        local value_3_10: boolean = false
                        value_2_8.Visible = value_3_10
                        if value_6 then
                            value_6:Disconnect()
                        end
                        local value_2_12 = captured_value_2
                        local value_4_9: string = "BuyItem"
                        local activated_value = value_2_12:WaitForChild(value_4_9).Activated
                        local value_4_10
                        do
                            local captured_value_6 = captured_value_5
                            if closure_cache[1] ~= nil and same_capture(
                                closure_cache[2],
                                captured_value_6
                            ) then
                                value_4_10 = closure_cache[1]
                            else
                                local closure_ready
                                value_4_10 = function(): ()
                                    if not closure_ready then
                                        return
                                    end
                                    local value_1_3 = captured_value_6
                                    local value_3_22: string = "CurrentEvent"
                                    value_1_3:ToggleFrame(value_3_22)

                                    return
                                end
                                closure_ready = true
                                if closure_cache[1] == nil then
                                    closure_cache[1] = value_4_10
                                    closure_cache[2] = captured_value_6
                                end
                            end
                        end
                        value_6 = (activated_value:Connect(value_4_10))

                        return
                    end
                end
            end
        end
        if captured_value_4.Visible then
            local value_2_16 = captured_value_2
            local value_3_14: boolean = false
            value_2_16.Visible = value_3_14
            local value_2_17 = captured_value_3
            local value_3_15: boolean = false
            value_2_17.Visible = value_3_15
            local value_2_18 = captured_value_4
            local value_4_11: string = "BuyItem"
            local activated_value_2 = value_2_18:WaitForChild(value_4_11).Activated
            local value_4_12
            do
                local captured_value_7 = captured_value_5
                if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_7) then
                    value_4_12 = closure_cache[3]
                else
                    local closure_ready_2
                    value_4_12 = function(): ()
                        if not closure_ready_2 then
                            return
                        end
                        local value_1_5 = captured_value_7
                        local value_3_23: nil = nil
                        value_1_5:ToggleFrame(value_3_23)

                        return
                    end
                    closure_ready_2 = true
                    if closure_cache[3] == nil then
                        closure_cache[3] = value_4_12
                        closure_cache[4] = captured_value_7
                    end
                end
            end
            activated_value_2:Connect(value_4_12)

            return
        end
        if value_6 then
            value_6:Disconnect()
            value_6 = nil
        end
        local value_2_25 = captured_value_2
        local value_3_19: boolean = false
        value_2_25.Visible = value_3_19
        local value_2_26 = captured_value_4
        local value_3_20: boolean = false
        value_2_26.Visible = value_3_20
        local value_2_27 = captured_value_3
        local value_3_21: boolean = true
        value_2_27.Visible = value_3_21

        return
    end
end
local value_10 = on_initialize
require_result_2:OnEventStarted(value_10)
local value_10_2 = on_initialize
require_result_2:OnEventEnded(value_10_2)
on_initialize()

return
