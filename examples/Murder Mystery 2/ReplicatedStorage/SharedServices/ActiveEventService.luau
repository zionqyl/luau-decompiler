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
local value_4_2: string = "Types"
local types_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "EventType"
local require_result = require_value(types_child:WaitForChild(value_4_3))
local game_value_2: DataModel = game
local value_3_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_3_4)
local value_3_5: string = "ActiveEvents"
local active_events_child: Instance? = replicated_storage_service_2:WaitForChild(value_3_5)
local table_2 = {}
local table_3 = {
    [("EventAdded")] = nil,
    [("EventAdded")] = nil,
    [("EventAdded")] = nil,
    [("EventAdded")] = nil,
    [("EventAdded")] = nil,
}
local new_result: BindableEvent = Instance.new("BindableEvent")
table_3.EventAdded = new_result
local new_result_2: BindableEvent = Instance.new("BindableEvent")
table_3.EventChanged = new_result_2
local new_result_3: RemoteEvent = Instance.new("RemoteEvent")
table_3.EventUpdated = new_result_3
local get_main_event
do
    local captured_value = table_2
    get_main_event = function<T1>(argument_1: T1)
        local value_2_6 = captured_value
        local value_3_6: nil = nil
        local value_4_4: nil = nil
        for key, value in value_2_6, value_3_6, value_4_4 do
            local value_5_4, value_6_2 = key, value
            local priority_value = value_6_2.Priority
            if priority_value ~= "Main" then
                continue
            end

            return value_6_2
        end

        return nil
    end
end
table_3.GetMainEvent = get_main_event
local get_active_events
do
    local captured_value_2 = table_2
    get_active_events = function<T1>(argument_1_2: T1)
        return captured_value_2
    end
end
table_3.GetActiveEvents = get_active_events
local bind_client
do
    local captured_value_3, captured_value_4 = table_3, table_2
    bind_client = function<T1>(argument_1_3: T1)
        local on_client_event_value = captured_value_3.EventUpdated.OnClientEvent
        local value_4_5
        do
            local captured_value_5, captured_value_6 = captured_value_4, captured_value_3
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_5) and same_capture(
                closure_cache[3],
                captured_value_6
            ) then
                value_4_5 = closure_cache[1]
            else
                local closure_ready
                value_4_5 = function(argument_1_4: string, argument_2)
                    if not closure_ready then
                        return
                    end
                    local value_3_8 = captured_value_5
                    value_3_8[argument_1_4] = argument_2
                    local event_changed_value = captured_value_6.EventChanged
                    local value_5_5: string = argument_1_4
                    event_changed_value:Fire(value_5_5)

                    return
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_5
                    closure_cache[2], closure_cache[3] = captured_value_5, captured_value_6
                end
            end
        end
        on_client_event_value:Connect(value_4_5)

        return
    end
end
table_3.BindClient = bind_client
do
    local captured_value_7, captured_value_8 = table_2, table_3

    local function on_event_added(argument_1_5)
        local name_value = argument_1_5.Name
        local value_3_11 = captured_value_7
        local require_result_2 = require(argument_1_5)
        value_3_11[name_value] = require_result_2
        local event_added_value = captured_value_8.EventAdded
        local value_5_7 = name_value
        event_added_value:Fire(value_5_7)
        local event_changed_value_2 = captured_value_8.EventChanged
        local value_5_8 = name_value
        event_changed_value_2:Fire(value_5_8)

        return
    end
end
local on_initialize
do
    local captured_value_9, captured_value_10, captured_value_11 = active_events_child, table_2, table_3
    on_initialize = function()
        local value_1_3, value_2_10, value_3_16 = captured_value_9:GetChildren()
        for key_2, value_10 in value_1_3, value_2_10, value_3_16 do
            local value_4_9, value_5_9 = key_2, value_10
            local name_value_2 = value_5_9.Name
            local value_7 = captured_value_10
            local require_value_3 = require
            local value_9 = value_5_9
            local require_result_3 = require_value_3(value_9)
            value_7[name_value_2] = require_result_3
            local value_7_2 = captured_value_11
            local event_added_value_2 = value_7_2.EventAdded
            local value_9_2 = name_value_2
            event_added_value_2:Fire(value_9_2)
            local value_7_4 = captured_value_11
            local event_changed_value_3 = value_7_4.EventChanged
            local value_9_3 = name_value_2
            event_changed_value_3:Fire(value_9_3)
        end
        value_1_3 = captured_value_9.ChildAdded
        do
            local captured_value_12, captured_value_13 = captured_value_10, captured_value_11
            if closure_cache[4] ~= nil and same_capture(closure_cache[5], captured_value_12) and same_capture(
                closure_cache[6],
                captured_value_13
            ) then
                value_3_16 = closure_cache[4]
            else
                local closure_ready_2
                value_3_16 = function(argument_1_6)
                    if not closure_ready_2 then
                        return
                    end
                    local value_4_10: string = "ModuleScript"
                    if not (argument_1_6:IsA(value_4_10)) then
                        return
                    end
                    local name_value_3 = argument_1_6.Name
                    local value_3_18 = captured_value_12
                    local require_result_4 = require(argument_1_6)
                    value_3_18[name_value_3] = require_result_4
                    local event_added_value_3 = captured_value_13.EventAdded
                    local value_5_11 = name_value_3
                    event_added_value_3:Fire(value_5_11)
                    local event_changed_value_4 = captured_value_13.EventChanged
                    local value_5_12 = name_value_3
                    event_changed_value_4:Fire(value_5_12)

                    return
                end
                closure_ready_2 = true
                if closure_cache[4] == nil then
                    closure_cache[4] = value_3_16
                    closure_cache[5], closure_cache[6] = captured_value_12, captured_value_13
                end
            end
        end
        value_1_3:Connect(value_3_16)

        return
    end
end
on_initialize()

return table_3
