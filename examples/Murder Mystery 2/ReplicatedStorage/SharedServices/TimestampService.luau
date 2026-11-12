--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("GetCurrentDayPST")] = nil,
    [("GetCurrentDayPST")] = nil,
    [("GetCurrentDayPST")] = nil,
    [("GetCurrentDayPST")] = nil,
    [("GetCurrentDayPST")] = nil,
}

local function get_current_day_pst<T1>(argument_1: T1): number
    local now_result: DateTime = DateTime.now()
    local to_universal_time_result = now_result:ToUniversalTime()
    local value_3_2: number = now_result.UnixTimestamp + -28800
    local to_universal_time_result_2 = DateTime.fromUnixTimestamp(value_3_2):ToUniversalTime()

    return DateTime.fromUniversalTime(
        to_universal_time_result_2.Year,
        to_universal_time_result_2.Month,
        to_universal_time_result_2.Day,
        0,
        0,
        0,
        0
    ).UnixTimestamp - -28800
end

table_1.GetCurrentDayPST = get_current_day_pst

local function get_current_period_start_pst<T1>(argument_1_2: T1, argument_2: number, argument_3: number?)
    local value_4_4: number = DateTime.now().UnixTimestamp + -28800
    local value_5_2 = (argument_3 or 0) + -28800
    local value_5_3 = value_5_2 - value_5_2 % 86400
    local value_6_3 = value_4_4 - value_5_3

    return value_5_3 + (value_6_3 - value_6_3 % argument_2) - -28800
end

table_1.GetCurrentPeriodStartPST = get_current_period_start_pst

local function get_current_day_utc<T1>(argument_1_3: T1): number
    local to_universal_time_result_3 = DateTime.now():ToUniversalTime()

    return DateTime.fromUniversalTime(
        to_universal_time_result_3.Year,
        to_universal_time_result_3.Month,
        to_universal_time_result_3.Day,
        0,
        0,
        0,
        0
    ).UnixTimestamp
end

table_1.GetCurrentDayUTC = get_current_day_utc

local function format_time_left_in_seconds<T1>(argument_1_4: T1, argument_2_2: number)
    local value_4_7: number = argument_2_2 / 3600
    local floor_result = math.floor(value_4_7)
    local value_5_4: number = argument_2_2 % 3600 / 60
    local floor_result_2 = math.floor(value_5_4)
    local value_5_5: number = argument_2_2 % 60
    if 0 < floor_result then
        return string.format("%dh, %dm", floor_result, floor_result_2)
    end
    if 0 < floor_result_2 then
        return string.format("%dm", floor_result_2)
    end

    return string.format("%ds", value_5_5)
end

table_1.FormatTimeLeftInSeconds = format_time_left_in_seconds

local function get_time_left_text<T1>(argument_1_5: T1, argument_2_3: number)
    local value_4_8: number = argument_2_3 / 86400
    local floor_result_3 = math.floor(value_4_8)
    local value_5_6: number = argument_2_3 % 86400 / 3600
    local floor_result_4 = math.floor(value_5_6)
    local value_6_8: number = argument_2_3 % 3600 / 60
    local floor_result_5 = math.floor(value_6_8)
    local value_7_7: number = argument_2_3 % 60
    local floor_result_6 = math.floor(value_7_7)
    local value_7_8: string = ""
    if 0 < floor_result_3 then
        return (string.format("%dd, %dh, %dm", floor_result_3, floor_result_4, floor_result_5))
    end
    if 0 < floor_result_4 then
        return (string.format("%dh, %dm", floor_result_4, floor_result_5))
    end
    if 0 < floor_result_5 then
        if floor_result_5 <= 5 then
            return (string.format("%dm, %ds", floor_result_5, floor_result_6))
        end

        return (string.format("%dm", floor_result_5))
    end

    return (string.format("%ds", floor_result_6))
end

table_1.GetTimeLeftText = get_time_left_text

local function get_leaderboard_time_text<T1>(argument_1_6: T1, argument_2_4)
    local value_4_9 = argument_2_4 / 86400
    local floor_result_7 = math.floor(value_4_9)
    local value_5_7 = argument_2_4 % 86400 / 3600
    local floor_result_8 = math.floor(value_5_7)
    local value_5_8 = floor_result_7 .. "d, " .. floor_result_8 .. "h"
    if floor_result_7 < 1 then
        value_5_8 = floor_result_8 .. "h"
        if floor_result_8 == 1 then
            value_5_8 = "Less than 2 hours"
        end
    end
    if argument_2_4 <= 3600 then
        value_5_8 = "Less than 1 hour!"
    end
    if argument_2_4 <= 0 then
        value_5_8 = "ENDED!"
    end

    return value_5_8
end

table_1.GetLeaderboardTimeText = get_leaderboard_time_text

return table_1
