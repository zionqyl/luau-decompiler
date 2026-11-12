--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
    [("GetCurrentEvent")] = nil,
}
local script_value: LuaSourceContainer = script
local value_4: string = "BattlePasses"
local battle_passes_child: Instance? = script_value:WaitForChild(value_4)
local script_value_2: LuaSourceContainer = script
local value_4_2: string = "MysteryBoxes"
local mystery_boxes_child: Instance? = script_value_2:WaitForChild(value_4_2)
local script_value_3: LuaSourceContainer = script
local value_4_3: string = "ShopData"
local shop_data_child: Instance? = script_value_3:WaitForChild(value_4_3)
local script_value_4: LuaSourceContainer = script
local value_4_4: string = "EventList"
local event_list_child: Instance? = script_value_4:WaitForChild(value_4_4)
local table_2 = {
    Inactive = "Inactive",
    PreUpdate = "PreUpdate",
    PreLiveEvent = "PreLiveEvent",
    Active = "Active",
    PostUpdate = "PostUpdate",
}
local value_3 = script
local value_5: string = "CurrentEventState"
value_3 = value_3:GetAttribute(value_5)

local function get_current_event<T1>(argument_1: T1): nil
    return nil
end

table_1.GetCurrentEvent = get_current_event

local function get_current_item_pack<T1>(argument_1_2: T1): nil
    return nil
end

table_1.GetCurrentItemPack = get_current_item_pack

local function get_event_state<T1>(argument_1_3: T1)
    return value_3
end

table_1.GetEventState = get_event_state
local is_in_state
do
    local captured_value = table_2
    is_in_state = function<T1>(argument_1_4: T1, argument_2: string)
        if not captured_value[argument_2] then
            warn("Invalid event state: ", argument_2)

            return false
        end
        local value_3_4: boolean?
        if value_3 ~= argument_2 then
            value_3_4 = false
        else
            value_3_4 = true
        end

        return value_3_4
    end
end
table_1.IsInState = is_in_state

local function is_event_active<T1>(argument_1_5: T1): boolean
    local value_2_8: boolean = false
    if value_3 == "Active" then
        value_2_8 = false
    end

    return value_2_8
end

table_1.IsEventActive = is_event_active
local are_items_currently_purchasable
do
    local captured_value_2 = table_1
    are_items_currently_purchasable = function<T1>(argument_1_6: T1)
        local value_2_9 = captured_value_2
        local value_4_11: string = "Active"
        local is_in_state_result = value_2_9:IsInState(value_4_11)
        if not is_in_state_result then
            local value_2_11 = captured_value_2
            local value_4_12: string = "PostUpdate"
            is_in_state_result = value_2_11:IsInState(value_4_12)
        end

        return is_in_state_result
    end
end
table_1.AreItemsCurrentlyPurchasable = are_items_currently_purchasable

local function get_event_name<T1>(argument_1_7: T1): nil
    return nil
end

table_1.GetEventName = get_event_name

local function get_event_title<T1>(argument_1_8: T1): nil
    return nil
end

table_1.GetEventTitle = get_event_title

local function get_event_currency<T1>(argument_1_9: T1): nil
    return nil
end

table_1.GetEventCurrency = get_event_currency

local function get_event_key<T1>(argument_1_10: T1): nil
    return nil
end

table_1.GetEventKey = get_event_key

local function get_event_remotes<T1>(argument_1_11: T1): nil
    return nil
end

table_1.GetEventRemotes = get_event_remotes

local function get_battle_pass<T1>(argument_1_12: T1)
    return (nil).BattlePass
end

table_1.GetBattlePass = get_battle_pass

local function get_mystery_box_data<T1>(argument_1_13: T1)
    if not (nil).MysteryBox then
        return nil
    end

    return (nil).MysteryBox
end

table_1.GetMysteryBoxData = get_mystery_box_data

local function get_shop_items<T1>(argument_1_14: T1)
    if not (nil).ShopItems then
        return {}
    end

    return (nil).ShopItems
end

table_1.GetShopItems = get_shop_items

local function get_currency_dev_products<T1>(argument_1_15: T1)
    return {}
end

table_1.GetCurrencyDevProducts = get_currency_dev_products

local function get_leaderboard_info<T1>(argument_1_16: T1)
    return (nil).Leaderboards
end

table_1.GetLeaderboardInfo = get_leaderboard_info

local function get_leaderboard_status<T1>(argument_1_17: T1)
    local floor_result, floor_value, get_server_time_now_result, leaderboard_end_time_value, leaderboards_value_2, leaderboards_value_3, leaderboards_value_4, pause_end_time_value, pause_start_time_value, points_value, points_value_2, points_value_3, value_3_10, value_3_11, value_3_12, value_3_9: nil, value_4_14, value_6_3: nil, value_7: nil, value_8: nil, value_8_2, value_9, workspace_value
    local control_state = 0
    while true do
        if control_state < 5 then
            if control_state < 2 then
                if control_state < 1 then
                    workspace_value = workspace
                    get_server_time_now_result = workspace_value:GetServerTimeNow()
                    floor_value = math.floor
                    floor_result = floor_value(get_server_time_now_result)
                    value_3_9 = nil
                    value_4_14 = nil
                    value_6_3 = nil
                    leaderboards_value_2 = value_6_3.Leaderboards
                    points_value = leaderboards_value_2.Points
                    pause_start_time_value = points_value.PauseStartTime
                    value_7 = nil
                    leaderboards_value_3 = value_7.Leaderboards
                    points_value_2 = leaderboards_value_3.Points
                    pause_end_time_value = points_value_2.PauseEndTime
                    value_8 = nil
                    leaderboards_value_4 = value_8.Leaderboards
                    points_value_3 = leaderboards_value_4.Points
                    leaderboard_end_time_value = points_value_3.LeaderboardEndTime
                    value_8_2 = nil
                    control_state = if not (floor_result < pause_start_time_value) then 2 else 1
                else
                    value_3_10 = false
                    value_4_14 = pause_start_time_value - floor_result
                    value_8_2 = "pausingSoon"
                    control_state = 10
                end
            else
                if control_state < 3 then
                    control_state = if not (pause_start_time_value <= floor_result) then 5 else 3
                else
                    if control_state < 4 then
                        control_state = if not (floor_result < pause_end_time_value) then 5 else 4
                    else
                        value_3_11 = true
                        value_4_14 = pause_end_time_value - floor_result
                        value_8_2 = "paused"
                        control_state = 10
                    end
                end
            end
        else
            if control_state < 8 then
                if control_state < 6 then
                    control_state = if not (pause_end_time_value <= floor_result) then 8 else 6
                else
                    if control_state < 7 then
                        control_state = if not (floor_result <= leaderboard_end_time_value) then 8 else 7
                    else
                        value_3_12 = false
                        value_4_14 = leaderboard_end_time_value - floor_result
                        value_8_2 = "endingSoon"
                        control_state = 10
                    end
                end
            else
                if control_state < 9 then
                    control_state = if not (leaderboard_end_time_value <= floor_result) then 10 else 9
                else
                    if control_state < 10 then
                        value_8_2 = "ended"
                        value_4_14 = 0
                        control_state = 10
                    else
                        value_9 = value_4_14

                        return value_8_2, value_9
                    end
                end
            end
        end
    end
end

table_1.GetLeaderboardStatus = get_leaderboard_status

local function is_live_event_launch<T1>(argument_1_18: T1): nil
    return nil
end

table_1.IsLiveEventLaunch = is_live_event_launch
local get_live_event_time_left
do
    local captured_value_3 = table_1
    get_live_event_time_left = function<T1>(argument_1_19: T1)
        if not (captured_value_3:IsLiveEventLaunch()) then
            warn("Not live event!")

            return nil
        end
        local unix_timestamp_value: number = DateTime.now().UnixTimestamp

        return (nil).LiveLaunchEvent - unix_timestamp_value
    end
end
table_1.GetLiveEventTimeLeft = get_live_event_time_left
local on_event_started
do
    local captured_value_4 = table_1
    on_event_started = function<T1>(argument_1_20: T1, argument_2_2)
        if (captured_value_4:IsLiveEventLaunch()) then
            if not (captured_value_4:IsEventActive()) then
                local event_value = (nil).LiveEventStarted.Event
                local value_5_5 = argument_2_2
                event_value:Connect(value_5_5)

                return true
            end
            argument_2_2()

            return true
        end
        if (captured_value_4:IsEventActive()) then
            argument_2_2()

            return true
        end

        return false
    end
end
table_1.OnEventStarted = on_event_started
local is_leaderboard_active
do
    local captured_value_5 = table_1
    is_leaderboard_active = function<T1>(argument_1_21: T1)
        if not (nil).Leaderboards then
            return false
        end
        local get_leaderboard_status_result, value_3_31 = captured_value_5:GetLeaderboardStatus()
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
local script_value_5: LuaSourceContainer = script
local value_6: string = "CurrentEventState"
local get_attribute_changed_signal_result: RBXScriptSignal<> = script_value_5:GetAttributeChangedSignal(
    value_6
)

local function value_6_2(): ()
    local script_value_6: LuaSourceContainer = script
    local value_3_32: string = "CurrentEventState"
    value_3 = (script_value_6:GetAttribute(value_3_32))

    return
end

get_attribute_changed_signal_result:Connect(value_6_2)

return table_1
