--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "EventInfoService"
local require_result = require_value(shared_services_child:WaitForChild(value_4_3))
local game_value_2: DataModel = game
local value_4_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_4_4)
local value_4_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_4_5)
local require_value_2 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result_2 = require_value_2(database_child:WaitForChild(value_6_3))
local require_value_3 = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "Types"
local types_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "EventType"
local require_result_3 = require_value_3(types_child:WaitForChild(value_7_3))
local value_6_7: string = "Events"
local events_child = remotes_child:WaitForChild(value_6_7)

local function did_event_start(argument_1): boolean
    local value_2_6: boolean?
    if argument_1.Status ~= "Started" then
        value_2_6 = false
    else
        value_2_6 = true
    end

    return value_2_6
end

local function did_event_end(argument_1_2): boolean
    local value_2_7: boolean?
    if argument_1_2.Status ~= "Ended" then
        value_2_7 = false
    else
        value_2_7 = true
    end

    return value_2_7
end

local start_event: ((string) -> ())?
do
    local captured_value, captured_value_2 = require_result, require_result_2
    start_event = function(argument_1_3: string): ()
        local value_2_8 = captured_value
        local value_4_10 = argument_1_3
        local get_event_result = value_2_8:GetEvent(value_4_10)
        local event_start_info_value = get_event_result.EventStartInfo
        local value_6_8
        if event_start_info_value then
            value_4_10 = event_start_info_value.Items
            local value_5_8: nil, value_7_4, value_8_2, value_9
            if value_4_10 then
                value_4_10 = event_start_info_value.Items
                value_5_8 = nil
                value_6_8 = nil
                for key_2, value_16 in value_4_10, value_5_8, value_6_8 do
                    value_7_4, value_8_2 = key_2, value_16
                    value_9 = value_8_2
                    local value_10: nil = nil
                    local value_11: nil = nil
                    for key, value in value_9, value_10, value_11 do
                        local value_12, value_13 = key, value
                        local value_15 = captured_value_2
                        local value_14 = value_15[value_7_4]
                        value_14[value_12] = value_13
                    end
                end
            end
            value_4_10 = event_start_info_value.ShopData
            if value_4_10 then
                value_4_10 = event_start_info_value.ShopData
                value_5_8 = nil
                value_6_8 = nil
                for key_3, value_17 in value_4_10, value_5_8, value_6_8 do
                    value_7_4, value_8_2 = key_3, value_17
                    value_9 = captured_value_2.NewShop
                    value_9[value_7_4] = value_8_2
                end
            end
        end
        value_4_10 = captured_value
        value_6_8 = get_event_result
        value_4_10:_StartEvent(value_6_8)

        return
    end
end
local end_event
do
    local captured_value_3, captured_value_4 = require_result, require_result_2
    end_event = function(argument_1_4: string, argument_2): ()
        local value_3_7 = captured_value_3
        local value_5_9 = argument_1_4
        local get_event_result_2 = value_3_7:GetEvent(value_5_9)
        local event_start_info_value_2 = get_event_result_2.EventStartInfo
        if event_start_info_value_2 then
            event_start_info_value_2 = get_event_result_2.EventStartInfo.ShopData
        end
        local event_start_info_value_4 = argument_2.EventStartInfo
        if event_start_info_value_4 then
            event_start_info_value_4 = argument_2.EventStartInfo.ShopData
        end
        local value_7_5, value_8_3
        if event_start_info_value_2 then
            value_5_9 = event_start_info_value_2
            local value_6_9: nil = nil
            value_7_5 = nil
            for key_4 in value_5_9, value_6_9, value_7_5 do
                value_8_3 = key_4
                local value_10_2 = captured_value_4
                local new_shop_value = value_10_2.NewShop
                local value_11_2
                do
                    local take_fallback = not event_start_info_value_4
                    if not take_fallback then
                        value_11_2 = event_start_info_value_4[value_8_3]
                        take_fallback = not value_11_2
                    end
                    if take_fallback then
                        value_11_2 = nil
                    end
                end
                new_shop_value[value_8_3] = value_11_2
            end
        end
        value_5_9 = captured_value_3
        value_7_5 = argument_1_4
        value_8_3 = argument_2
        value_5_9:RegisterEvent(value_7_5, value_8_3)
        value_5_9 = captured_value_3
        value_7_5 = argument_2
        value_5_9:_EndEvent(value_7_5)

        return
    end
end
local update_event
do
    local captured_value_5, captured_value_6, captured_value_7 = require_result, start_event, end_event
    update_event = function(argument_1_5: string, argument_2_2): ()
        local value_3_9 = captured_value_5
        local value_5_10: string = argument_1_5
        local get_event_result_3 = value_3_9:GetEvent(value_5_10)
        if not get_event_result_3 then
            local value_4_13 = captured_value_5
            local value_6_10: string = argument_1_5
            local value_7_6 = argument_2_2
            value_4_13:RegisterEvent(value_6_10, value_7_6)
            if argument_2_2.Status == "Started" then
                captured_value_6(argument_1_5)

                return
            end
            if argument_2_2.Status == "Ended" then
                captured_value_6(argument_1_5)
                captured_value_7(argument_1_5, argument_2_2)
            end

            return
        end
        if get_event_result_3.Status == "NotStarted" then
            if argument_2_2.Status == "Started" then
                local value_4_18 = captured_value_5
                local value_6_12: string = argument_1_5
                local value_7_7 = argument_2_2
                value_4_18:RegisterEvent(value_6_12, value_7_7)
                captured_value_6(argument_1_5)

                return
            end
        end
        if get_event_result_3.Status ~= "Ended" then
            if argument_2_2.Status == "Ended" then
                captured_value_7(argument_1_5, argument_2_2)

                return
            end
        end

        return
    end
end
local on_initialize: (() -> ())?
do
    local captured_value_8, captured_value_9, captured_value_10 = events_child, update_event, require_result
    on_initialize = function(): ()
        local value_1 = captured_value_8
        local value_3_11: nil | boolean | string = "GetEvents"
        local value_2_10 = (value_1:WaitForChild(value_3_11):InvokeServer())
        value_3_11 = nil
        local value_4_22 = nil
        for key_5, value_18 in value_2_10, value_3_11, value_4_22 do
            local value_5_18, value_6_14 = key_5, value_18
            local value_7_8 = captured_value_9
            local value_8_4 = value_5_18
            local value_9_3 = value_6_14
            value_7_8(value_8_4, value_9_3)
        end
        value_2_10 = captured_value_8
        value_4_22 = "EventChanged"
        value_2_10 = value_2_10:WaitForChild(value_4_22).OnClientEvent
        value_4_22 = captured_value_9
        value_2_10:Connect(value_4_22)
        value_2_10 = captured_value_10
        value_3_11 = true
        value_2_10.Initialized = value_3_11

        return
    end
end
on_initialize()

return
