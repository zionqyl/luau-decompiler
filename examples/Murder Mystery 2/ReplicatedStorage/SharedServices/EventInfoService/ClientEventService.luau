--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value = game
local value_4: string = "ReplicatedStorage"
game_value = game_value:GetService(value_4)
local value_4_2: string = "Types"
game_value = game_value:WaitForChild(value_4_2)
local value_4_3: string = "EventType"
local require_result = require_value(game_value:WaitForChild(value_4_3))
local table_1 = {[("GetEvents")] = nil, [("GetEvents")] = nil, [("GetEvents")] = nil}
game_value = {}
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local require_value_2 = require
local game_value_3: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_7)
local value_7_2: string = "Database"
local database_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "Sync"
local require_result_2 = require_value_2(database_child:WaitForChild(value_7_3))
local value_7_4: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_7_4)
local value_7_5: string = "Events"
local events_child = remotes_child:WaitForChild(value_7_5)
local value_6: boolean = false

local function get_events<T1>(argument_1: T1)
    return game_value
end

table_1.GetEvents = get_events
local table_3 = {}

local function get_main_event<T1>(argument_1_2: T1)
    local value_2_2 = game_value
    local value_3_5: nil = nil
    local value_4_5: nil = nil
    for key, value in value_2_2, value_3_5, value_4_5 do
        local value_5_7, value_6_2 = key, value
        local event_start_info_value = value_6_2.EventStartInfo
        if not event_start_info_value then
            continue
        end
        local priority_value = value_6_2.Priority
        if priority_value ~= "Main" then
            continue
        end

        return value_6_2
    end

    return
end

table_1.GetMainEvent = get_main_event
local on_event_started
do
    local captured_value = table_3
    on_event_started = function<T1>(argument_1_3: T1, argument_2)
        local value_3_6
        while true do
            if value_6 then
                break
            end
            value_3_6 = task.wait
            value_3_6()
        end
        value_3_6 = game_value
        local value_4_6 = nil
        local value_5_8 = nil
        for key_2, value_10 in value_3_6, value_4_6, value_5_8 do
            local value_6_3, value_7_6 = key_2, value_10
            local event_start_info_value_2 = value_7_6.EventStartInfo
            if not event_start_info_value_2 then
                continue
            end
            local value_8 = argument_2
            local value_9_2 = value_7_6
            value_8(value_9_2)
        end
        value_4_6 = captured_value
        value_5_8 = argument_2
        table.insert(value_4_6, value_5_8)

        return
    end
end
table_1.OnEventStarted = on_event_started
local start_event
do
    local captured_value_2, captured_value_3 = require_result_2, table_3
    start_event = function(argument_1_4)
        local event_start_info_value_3 = argument_1_4.EventStartInfo
        local items_value, value_4_7: nil, value_5_9: nil, value_6_4, value_7_7, value_8_2, value_9_3
        if event_start_info_value_3 then
            items_value = event_start_info_value_3.Items
            if items_value then
                items_value = event_start_info_value_3.Items
                value_4_7 = nil
                value_5_9 = nil
                for key_4, value_16 in items_value, value_4_7, value_5_9 do
                    value_6_4, value_7_7 = key_4, value_16
                    value_8_2 = value_7_7
                    value_9_3 = nil
                    local value_10_2: nil = nil
                    for key_3, value_15 in value_8_2, value_9_3, value_10_2 do
                        local value_11, value_12 = key_3, value_15
                        local value_14 = captured_value_2
                        local value_13 = value_14[value_6_4]
                        value_13[value_11] = value_12
                    end
                end
            end
            items_value = event_start_info_value_3.ShopData
            if items_value then
                items_value = event_start_info_value_3.ShopData
                value_4_7 = nil
                value_5_9 = nil
                for key_5, value_17 in items_value, value_4_7, value_5_9 do
                    value_6_4, value_7_7 = key_5, value_17
                    value_8_2 = captured_value_2.NewShop
                    value_8_2[value_6_4] = value_7_7
                end
            end
        end
        items_value = captured_value_3
        value_4_7 = nil
        value_5_9 = nil
        for key_6, value_18 in items_value, value_4_7, value_5_9 do
            value_6_4, value_7_7 = key_6, value_18
            value_8_2 = value_7_7
            value_9_3 = argument_1_4
            value_8_2(value_9_3)
        end

        return
    end
end
local on_initialize
do
    local captured_value_4, captured_value_5 = events_child, start_event
    on_initialize = function()
        local value_1 = captured_value_4
        local value_3_7 = "GetEvents"
        game_value = (value_1:WaitForChild(value_3_7):InvokeServer())
        value_1 = game_value
        local value_2_3: nil = nil
        value_3_7 = nil
        for key_7, value_19 in value_1, value_2_3, value_3_7 do
            local value_4_8, value_5_10 = key_7, value_19
            local event_start_info_value_4 = value_5_10.EventStartInfo
            if not event_start_info_value_4 then
                continue
            end
            local value_6_5 = captured_value_5
            local value_7_8 = value_5_10
            value_6_5(value_7_8)
        end
        value_1 = captured_value_4
        value_3_7 = "EventChanged"
        value_1 = value_1:WaitForChild(value_3_7).OnClientEvent
        do
            local captured_value_6, closure_ready
            value_3_7 = function(argument_1_5, argument_2_2): ()
                if not closure_ready then
                    return
                end
                local value_3_8: boolean = false
                if game_value[argument_1_5] then
                    if not game_value[argument_1_5].EventStartInfo then
                        if argument_2_2.EventStartInfo then
                            value_3_8 = true
                        end
                    end
                end
                local value_4_11 = game_value
                value_4_11[argument_1_5] = argument_2_2
                if value_3_8 then
                    captured_value_6(argument_2_2)
                end

                return
            end
            captured_value_6 = captured_value_5
            closure_ready = true
        end
        value_1:Connect(value_3_7)
        value_6 = true
        print("Events", game_value)

        return
    end
end
on_initialize()

return table_1
