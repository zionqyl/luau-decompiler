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
local value_4_2: string = "Types"
local types_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "EventType"
local require_result = require_value(types_child:WaitForChild(value_4_3))
local table_1 = {
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
    [("Initialized")] = nil,
}
local value_2_4: boolean = false
table_1.Initialized = value_2_4
local table_2 = {}
local table_3 = {}
local table_4 = {}
local table_5 = {}
local table_6 = {}
local get_main_event
do
    local captured_value = table_2
    get_main_event = function<T1>(argument_1: T1)
        local value_2_5 = captured_value
        local value_3_4: nil = nil
        local value_4_4: nil = nil
        for key, value in value_2_5, value_3_4, value_4_4 do
            local value_5, value_6 = key, value
            local priority_value = value_6.Priority
            if priority_value ~= "Main" then
                continue
            end

            return value_6
        end

        return nil
    end
end
table_1.GetMainEvent = get_main_event
local get_active_events
do
    local captured_value_2 = table_3
    get_active_events = function<T1>(argument_1_2: T1)
        return captured_value_2
    end
end
table_1.GetActiveEvents = get_active_events
local is_event_active
do
    local captured_value_3 = table_3
    is_event_active = function<T1>(argument_1_3: T1, argument_2)
        local value_3_5: boolean?
        if captured_value_3[argument_2.Title] == nil then
            value_3_5 = false
        else
            value_3_5 = true
        end

        return value_3_5
    end
end
table_1.IsEventActive = is_event_active
local is_event_type_active
do
    local captured_value_4, captured_value_5 = table_2, table_1
    is_event_type_active = function<T1>(argument_1_4: T1, argument_2_2: string)
        local value_3_6 = captured_value_4
        local value_4_6: nil = nil
        local value_5_3: nil = nil
        for key_2, value_11 in value_3_6, value_4_6, value_5_3 do
            local value_6_2, value_7 = key_2, value_11
            local name_value = value_7.Name
            if name_value ~= argument_2_2 then
                continue
            end
            local value_8 = captured_value_5
            local value_10 = value_7
            local is_event_active_result = value_8:IsEventActive(value_10)
            if not is_event_active_result then
                continue
            end
            local value_8_3: boolean = true

            return value_8_3
        end

        return false
    end
end
table_1.IsEventTypeActive = is_event_type_active

local function get_leaderboard_status<T1>(argument_1_5: T1, argument_2_3)
    local end_time_value, event_start_info_value, event_start_info_value_2, event_start_info_value_3, event_start_info_value_4, floor_result, floor_value, get_server_time_now_result, leaderboards_value, leaderboards_value_2, leaderboards_value_3, leaderboards_value_4, pause_end_time_value, pause_start_time_value, points_value, points_value_2, points_value_3, points_value_4, start_time_value, value_10_2, value_11_2, value_4_10, value_4_11, value_4_12, value_4_8: nil, value_4_9, value_5_5, workspace_value
    local control_state = 0
    while true do
        if control_state < 7 then
            if control_state < 3 then
                if control_state < 1 then
                    workspace_value = workspace
                    get_server_time_now_result = workspace_value:GetServerTimeNow()
                    floor_value = math.floor
                    floor_result = floor_value(get_server_time_now_result)
                    value_4_8 = nil
                    value_5_5 = nil
                    event_start_info_value = argument_2_3.EventStartInfo
                    leaderboards_value = event_start_info_value.Leaderboards
                    points_value = leaderboards_value.Points
                    start_time_value = points_value.StartTime
                    event_start_info_value_2 = argument_2_3.EventStartInfo
                    leaderboards_value_2 = event_start_info_value_2.Leaderboards
                    points_value_2 = leaderboards_value_2.Points
                    pause_start_time_value = points_value_2.PauseStartTime
                    event_start_info_value_3 = argument_2_3.EventStartInfo
                    leaderboards_value_3 = event_start_info_value_3.Leaderboards
                    points_value_3 = leaderboards_value_3.Points
                    pause_end_time_value = points_value_3.PauseEndTime
                    event_start_info_value_4 = argument_2_3.EventStartInfo
                    leaderboards_value_4 = event_start_info_value_4.Leaderboards
                    points_value_4 = leaderboards_value_4.Points
                    end_time_value = points_value_4.EndTime
                    value_10_2 = nil
                    control_state = if not start_time_value then 3 else 1
                else
                    if control_state < 2 then
                        control_state = if not (floor_result < start_time_value) then 3 else 2
                    else
                        value_4_9 = false
                        value_5_5 = start_time_value - floor_result
                        value_10_2 = "notStarted"
                        control_state = 13
                    end
                end
            else
                if control_state < 5 then
                    if control_state < 4 then
                        control_state = if not (floor_result < pause_start_time_value) then 5 else 4
                    else
                        value_4_10 = false
                        value_5_5 = pause_start_time_value - floor_result
                        value_10_2 = "pausingSoon"
                        control_state = 13
                    end
                else
                    if control_state < 6 then
                        control_state = if not (pause_start_time_value <= floor_result) then 8 else 6
                    else
                        control_state = if not (floor_result < pause_end_time_value) then 8 else 7
                    end
                end
            end
        else
            if control_state < 10 then
                if control_state < 8 then
                    value_4_11 = true
                    value_5_5 = pause_end_time_value - floor_result
                    value_10_2 = "paused"
                    control_state = 13
                else
                    if control_state < 9 then
                        control_state = if not (pause_end_time_value <= floor_result) then 11 else 9
                    else
                        control_state = if not (floor_result <= end_time_value) then 11 else 10
                    end
                end
            else
                if control_state < 12 then
                    if control_state < 11 then
                        value_4_12 = false
                        value_5_5 = end_time_value - floor_result
                        value_10_2 = "endingSoon"
                        control_state = 13
                    else
                        control_state = if not (end_time_value <= floor_result) then 13 else 12
                    end
                else
                    if control_state < 13 then
                        value_10_2 = "ended"
                        value_5_5 = 0
                        control_state = 13
                    else
                        value_11_2 = value_5_5

                        return value_10_2, value_11_2
                    end
                end
            end
        end
    end
end

table_1.GetLeaderboardStatus = get_leaderboard_status
local is_leaderboard_active
do
    local captured_value_6 = table_1
    is_leaderboard_active = function<T1>(argument_1_6: T1, argument_2_4)
        if not argument_2_4.EventStartInfo then
            return false
        end
        if not argument_2_4.EventStartInfo.Leaderboards then
            return false
        end
        local value_3_9 = captured_value_6
        local value_5_6 = argument_2_4
        local get_leaderboard_status_result, value_4_14 = value_3_9:GetLeaderboardStatus(value_5_6)
        do
            local take_fallback = get_leaderboard_status_result == "pausingSoon"
            if take_fallback or get_leaderboard_status_result == "endingSoon" then
                return true
            end
        end

        return false
    end
end
table_1.IsLeaderboardActive = is_leaderboard_active

local function get_time_elapsed_since_event_start<T1>(argument_1_7: T1, argument_2_5)
    local value_6_3 = DateTime.now().UnixTimestamp - argument_2_5.EventStartTime
    local value_7_2: number = 0

    return (math.max(value_6_3, value_7_2))
end

table_1.GetTimeElapsedSinceEventStart = get_time_elapsed_since_event_start

local function get_time_elapsed_since_event_end<T1>(argument_1_8: T1, argument_2_6)
    local value_6_4 = DateTime.now().UnixTimestamp - argument_2_6.EventEndTime
    local value_7_3: number = 0

    return (math.max(value_6_4, value_7_3))
end

table_1.GetTimeElapsedSinceEventEnd = get_time_elapsed_since_event_end

local function get_time_until_event_start<T1>(argument_1_9: T1, argument_2_7)
    local unix_timestamp_value_3: number = DateTime.now().UnixTimestamp
    local event_start_time_value_2 = argument_2_7.EventStartTime
    local value_6_5 = event_start_time_value_2 - unix_timestamp_value_3
    local value_7_4: number = 0
    local value_8_4 = event_start_time_value_2

    return (math.clamp(value_6_5, value_7_4, value_8_4))
end

table_1.GetTimeUntilEventStart = get_time_until_event_start

local function get_time_until_event_end<T1>(argument_1_10: T1, argument_2_8)
    local unix_timestamp_value_4: number = DateTime.now().UnixTimestamp
    local event_end_time_value_2 = argument_2_8.EventEndTime
    local value_6_6 = event_end_time_value_2 - unix_timestamp_value_4
    local value_7_5: number = 0
    local value_8_5 = event_end_time_value_2

    return (math.clamp(value_6_6, value_7_5, value_8_5))
end

table_1.GetTimeUntilEventEnd = get_time_until_event_end

local function get_event_status<T1>(argument_1_11: T1, argument_2_9): string
    local unix_timestamp_value_5: number = DateTime.now().UnixTimestamp
    if unix_timestamp_value_5 < argument_2_9.EventStartTime then
        return "NotStarted"
    end
    if unix_timestamp_value_5 < argument_2_9.EventEndTime then
        return "Active"
    end

    return "Ended"
end

table_1.GetEventStatus = get_event_status
local register_event
do
    local captured_value_7 = table_2
    register_event = function<T1>(argument_1_12: T1, argument_2_10, argument_3)
        local value_4_18 = captured_value_7
        value_4_18[argument_2_10] = argument_3

        return
    end
end
table_1.RegisterEvent = register_event
local get_event
do
    local captured_value_8 = table_2
    get_event = function<T1>(argument_1_13: T1, argument_2_11: string)
        return captured_value_8[argument_2_11]
    end
end
table_1.GetEvent = get_event
local get_registered_events
do
    local captured_value_9 = table_2
    get_registered_events = function<T1>(argument_1_14: T1)
        return captured_value_9
    end
end
table_1.GetRegisteredEvents = get_registered_events
local start_event
do
    local captured_value_10, captured_value_11, captured_value_12 = table_4, table_5, table_3
    start_event = function<T1>(argument_1_15: T1, argument_2_12)
        local value_3_12 = captured_value_10
        local value_4_20 = nil
        local value_5_9: nil = nil
        local value_6_7, value_7_6
        for key_3, value_12 in value_3_12, value_4_20, value_5_9 do
            value_6_7, value_7_6 = key_3, value_12
            local spawn_value = task.spawn
            local value_9_2 = value_7_6
            local value_10_3 = argument_2_12
            spawn_value(value_9_2, value_10_3)
        end
        value_3_12 = argument_2_12.Priority
        if value_3_12 == "Main" then
            value_3_12 = captured_value_11
            value_4_20 = nil
            value_5_9 = nil
            for key_4, value_13 in value_3_12, value_4_20, value_5_9 do
                value_6_7, value_7_6 = key_4, value_13
                local spawn_value_2 = task.spawn
                local value_9_3 = value_7_6
                local value_10_4 = argument_2_12
                spawn_value_2(value_9_3, value_10_4)
            end
        end
        value_3_12 = captured_value_12
        value_4_20 = argument_2_12.Title
        value_3_12[value_4_20] = argument_2_12

        return
    end
end
table_1._StartEvent = start_event
local end_event
do
    local captured_value_13, captured_value_14 = table_6, table_3
    end_event = function<T1>(argument_1_16: T1, argument_2_13)
        local value_3_13 = captured_value_13
        local value_4_21 = nil
        local value_5_10: nil = nil
        for key_5, value_14 in value_3_13, value_4_21, value_5_10 do
            local value_6_8, value_7_7 = key_5, value_14
            local spawn_value_3 = task.spawn
            local value_9_4 = value_7_7
            local value_10_5 = argument_2_13
            spawn_value_3(value_9_4, value_10_5)
        end
        value_3_13 = captured_value_14
        value_4_21 = argument_2_13.Title
        value_5_10 = nil
        value_3_13[value_4_21] = value_5_10

        return
    end
end
table_1._EndEvent = end_event
local wait_for_initialized_async
do
    local captured_value_15 = table_1
    wait_for_initialized_async = function<T1>(argument_1_17: T1)
        while true do
            local value_2_8 = captured_value_15
            local initialized_value = value_2_8.Initialized
            if initialized_value then
                break
            end
            local wait_value: (number?) -> (number) = task.wait
            wait_value()
        end

        return captured_value_15
    end
end
table_1.WaitForInitializedAsync = wait_for_initialized_async
local on_main_event_started
do
    local captured_value_16, captured_value_17 = table_1, table_5
    on_main_event_started = function<T1>(argument_1_18: T1, argument_2_14)
        local event_end_info_value, event_end_info_value_2, get_main_event_result, insert_value, remove_ui_value, spawn_value_4, status_value, status_value_2, value_3_14, value_3_16, value_5_11, value_6_10, value_6_9, value_7_8
        local control_state_2 = 0
        while true do
            if control_state_2 < 5 then
                if control_state_2 < 2 then
                    if control_state_2 < 1 then
                        value_3_14 = captured_value_16
                        value_3_14:WaitForInitializedAsync()
                        value_3_16 = captured_value_16
                        get_main_event_result = value_3_16:GetMainEvent()
                        control_state_2 = if not get_main_event_result then 9 else 1
                    else
                        event_end_info_value = get_main_event_result.EventEndInfo
                        control_state_2 = if not event_end_info_value then 5 else 2
                    end
                else
                    if control_state_2 < 3 then
                        event_end_info_value_2 = get_main_event_result.EventEndInfo
                        remove_ui_value = event_end_info_value_2.RemoveUI
                        control_state_2 = if remove_ui_value == false then 4 else 3
                    else
                        if control_state_2 < 4 then
                            event_end_info_value = false
                            control_state_2 = 5
                        else
                            event_end_info_value = true
                            control_state_2 = 5
                        end
                    end
                end
            else
                if control_state_2 < 7 then
                    if control_state_2 < 6 then
                        status_value = get_main_event_result.Status
                        control_state_2 = if status_value == "Started" then 8 else 6
                    else
                        status_value_2 = get_main_event_result.Status
                        control_state_2 = if status_value_2 ~= "Ended" then 9 else 7
                    end
                else
                    if control_state_2 < 8 then
                        control_state_2 = if not event_end_info_value then 9 else 8
                    else
                        if control_state_2 < 9 then
                            spawn_value_4 = task.spawn
                            value_6_9 = argument_2_14
                            value_7_8 = get_main_event_result
                            spawn_value_4(value_6_9, value_7_8)
                            control_state_2 = 9
                        else
                            value_5_11 = captured_value_17
                            value_6_10 = argument_2_14
                            insert_value = table.insert
                            insert_value(value_5_11, value_6_10)

                            return
                        end
                    end
                end
            end
        end
    end
end
table_1.OnMainEventStarted = on_main_event_started
local on_event_started
do
    local captured_value_18, captured_value_19, captured_value_20 = table_1, table_2, table_4
    on_event_started = function<T1>(argument_1_19: T1, argument_2_15)
        captured_value_18:WaitForInitializedAsync()
        local value_3_18 = captured_value_19
        local value_4_24 = nil
        local value_5_12 = nil
        for key_6, value_15 in value_3_18, value_4_24, value_5_12 do
            local value_6_11, value_7_9 = key_6, value_15
            local status_value_3 = value_7_9.Status
            if status_value_3 ~= "Started" then
                continue
            end
            local spawn_value_5 = task.spawn
            local value_9_5 = argument_2_15
            local value_10_6 = value_7_9
            spawn_value_5(value_9_5, value_10_6)
        end
        value_4_24 = captured_value_20
        value_5_12 = argument_2_15
        table.insert(value_4_24, value_5_12)

        return
    end
end
table_1.OnEventStarted = on_event_started
local on_event_ended
do
    local captured_value_21, captured_value_22, captured_value_23 = table_1, table_2, table_6
    on_event_ended = function<T1>(argument_1_20: T1, argument_2_16)
        captured_value_21:WaitForInitializedAsync()
        local value_3_19 = captured_value_22
        local value_4_25 = nil
        local value_5_13 = nil
        for key_7, value_16 in value_3_19, value_4_25, value_5_13 do
            local value_6_12, value_7_10 = key_7, value_16
            local status_value_4 = value_7_10.Status
            if status_value_4 ~= "Ended" then
                continue
            end
            local spawn_value_6 = task.spawn
            local value_9_6 = argument_2_16
            local value_10_7 = value_7_10
            spawn_value_6(value_9_6, value_10_7)
        end
        value_4_25 = captured_value_23
        value_5_13 = argument_2_16
        table.insert(value_4_25, value_5_13)

        return
    end
end
table_1.OnEventEnded = on_event_ended

return table_1
