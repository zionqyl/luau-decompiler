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

local table_1 = {
    [("FriendsOnline")] = nil,
    [("FriendsOnline")] = nil,
    [("FriendsOnline")] = nil,
    [("FriendsOnline")] = nil,
    [("FriendsOnline")] = nil,
}
local local_player_value = game.Players.LocalPlayer
local game_value_2: DataModel = game
local value_5: string = "TeleportService"
local teleport_service: Instance = game_value_2:GetService(value_5)
local require_value = require
local game_value_3: DataModel = game
local value_7 = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_3:GetService(value_7)
value_7 = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_7)
value_7 = "Sync"
local sync_child = database_child:WaitForChild(value_7)
value_7 = "GameModes"
local require_result = require_value(sync_child:WaitForChild(value_7))
local table_5 = {}
table_1.FriendsOnline = table_5
local new_value: (string, Instance?) -> (Instance) = Instance.new
local value_6 = "BindableEvent"
local new_result: Instance = new_value(value_6)
value_6 = new_result.Event
table_1.Updated = value_6
value_6 = false
value_7 = ""
local value_8 = 0
local value_9: boolean?
if game.GameId ~= 119460199 then
    value_9 = false
else
    value_9 = true
end
local value_10: string?
if value_9 then
    value_10 = "Main Server"
else
    value_10 = "Testing Server"
end
local table_11 = {}
local table_12 = {}
local value_13 = require_result
local value_14 = nil
local value_15: nil = nil
for key, value in value_13, value_14, value_15 do
    local value_16, value_17 = key, value
    local live_id_value
    do
        local take_fallback = not value_9
        if not take_fallback then
            live_id_value = value_17.LiveID
            take_fallback = not live_id_value
        end
        if take_fallback then
            live_id_value = value_17.TestID
        end
    end
    local place_id_value = value_17.PlaceID
    local value_20: boolean = true
    table_11[place_id_value] = value_20
    local value_19: boolean = true
    table_11[live_id_value] = value_19
    local value_19_2: boolean = true
    table_12[live_id_value] = value_19_2
end

local function get_list_key(argument_1)
    local table_2 = {}
    local value_3_2 = argument_1
    local value_4_2: nil = nil
    local value_5_6: nil = nil
    for key_2, value_2 in value_3_2, value_4_2, value_5_6 do
        local value_6_2, value_7_2 = key_2, value_2
        local value_10_2: string = "%*:%*:%*"
        local visitor_id_value = value_7_2.VisitorId
        local place_id_value_2 = value_7_2.PlaceId
        local game_id_value_2 = value_7_2.GameId
        local format_result = value_10_2:format(
            visitor_id_value,
            place_id_value_2,
            game_id_value_2
        )
        local value_9_2 = table_2
        local insert_value = table.insert
        insert_value(value_9_2, format_result)
    end
    table.sort(table_2)

    return table.concat(table_2, ",")
end

local refresh
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, closure_ready_2
    refresh = function()
        if not closure_ready_2 then
            return
        end
        local value_2_2
        do
            local captured_value_8 = captured_value
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_8) then
                value_2_2 = closure_cache[1]
            else
                local closure_ready
                value_2_2 = function()
                    if not closure_ready then
                        return
                    end

                    return captured_value_8:GetFriendsOnline()
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_2_2
                    closure_cache[2] = captured_value_8
                end
            end
        end
        local pcall_result, value_2_3 = pcall(value_2_2)
        if pcall_result then
            local table_3 = {}
            local value_4_3 = value_2_3
            local value_5_7 = nil
            local value_6_3: nil = nil
            for key_3, value_12 in value_4_3, value_5_7, value_6_3 do
                local value_7_3, value_8_2 = key_3, value_12
                local value_10_4 = captured_value_2
                local place_id_value_3 = value_8_2.PlaceId
                local value_9_3 = value_10_4[place_id_value_3]
                if not value_9_3 then
                    continue
                end
                local value_10_5 = captured_value_3
                local place_id_value_4 = value_8_2.PlaceId
                local value_9_4 = value_10_5[place_id_value_4]
                if value_9_4 then
                    local value_9_5: string? = captured_value_4
                    value_8_2.OtherServer = value_9_5
                end
                local value_10_6 = table_3
                local value_11_2 = value_8_2
                local insert_value_2 = table.insert
                insert_value_2(value_10_6, value_11_2)
            end
            value_4_3 = captured_value_5(table_3)
            value_5_7 = value_7
            if value_4_3 ~= value_5_7 then
                value_7 = value_4_3
                value_5_7 = captured_value_6
                value_5_7.FriendsOnline = table_3
                captured_value_7:Fire()
            end
        end

        return
    end
    captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7 = local_player_value, table_11, table_12, value_10, get_list_key, table_1, new_result
    closure_ready_2 = true
end
do
    local captured_value_9 = table_1
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_9) then
        value_13 = closure_cache[3]
    else
        local closure_ready_3
        value_13 = function<T1>(argument_1_2: T1)
            if not closure_ready_3 then
                return
            end

            return captured_value_9.FriendsOnline
        end
        closure_ready_3 = true
        if closure_cache[3] == nil then
            closure_cache[3] = value_13
            closure_cache[4] = captured_value_9
        end
    end
end
table_1.GetFriendsOnline = value_13
do
    local captured_value_10, captured_value_11 = teleport_service, local_player_value
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_10) and same_capture(
        closure_cache[7],
        captured_value_11
    ) then
        value_13 = closure_cache[5]
    else
        local closure_ready_6
        value_13 = function(argument_1_3)
            if not closure_ready_6 then
                return
            end
            local value_2_6 = nil
            local teleport_init_failed_value = captured_value_10.TeleportInitFailed
            local value_5_8
            do
                local captured_value_12, closure_ready_4
                value_5_8 = function(argument_1_4, argument_2): ()
                    if not closure_ready_4 then
                        return
                    end
                    if argument_1_4 == captured_value_12 then
                        value_2_6 = argument_2
                    end

                    return
                end
                captured_value_12 = captured_value_11
                closure_ready_4 = true
            end
            local connection = teleport_init_failed_value:Connect(value_5_8)
            local value_5_9: (() -> ())?
            do
                local captured_value_13, captured_value_14, captured_value_15, closure_ready_5
                value_5_9 = function(): ()
                    if not closure_ready_5 then
                        return
                    end
                    local value_1_3: Instance? = captured_value_13
                    local place_id_value_5 = captured_value_14.PlaceId
                    local game_id_value_3 = captured_value_14.GameId
                    local value_5_12 = captured_value_15
                    local value_6_7: string = ""
                    local table_7 = {Joined = true}
                    value_1_3:TeleportToPlaceInstance(
                        place_id_value_5,
                        game_id_value_3,
                        value_5_12,
                        value_6_7,
                        table_7
                    )

                    return
                end
                captured_value_13, captured_value_14, captured_value_15 = captured_value_10, argument_1_3, captured_value_11
                closure_ready_5 = true
            end
            if not (pcall(value_5_9)) then
                value_2_6 = Enum.TeleportResult.Failure
            end
            local clock_result = os.clock()
            while true do
                if value_2_6 ~= nil then
                    break
                end
                local clock_value_2 = os.clock
                local clock_result_2 = clock_value_2()
                local value_5_10 = clock_result_2 - clock_result
                local value_6_4: number = 15
                if not (value_5_10 < value_6_4) then
                    break
                end
                local wait_value: (number?) -> (number) = task.wait
                local value_6_5: number = 0.1
                wait_value(value_6_5)
            end
            connection:Disconnect()

            return value_2_6
        end
        closure_ready_6 = true
        if closure_cache[5] == nil then
            closure_cache[5] = value_13
            closure_cache[6], closure_cache[7] = captured_value_10, captured_value_11
        end
    end
end
do
    local captured_value_16, closure_ready_7
    value_14 = function<T1>(argument_1_5: T1, argument_2_2, argument_3, argument_4): ()
        if not closure_ready_7 then
            return
        end
        if argument_2_2.GameId == game.JobId then
            argument_4()

            return
        end
        value_8 = value_8 + 1
        local value_5_16 = value_8
        local value_6_8: number = 0
        while true do
            local value_7_4 = captured_value_16
            local value_8_3 = argument_2_2
            local value_7_5 = value_7_4(value_8_3)
            local value_8_4 = value_8
            if value_5_16 ~= value_8_4 then
                return
            end
            local game_full_value = Enum.TeleportResult.GameFull
            if value_7_5 ~= game_full_value then
                local value_8_5 = argument_4
                value_8_5()

                return
            end
            value_6_8 = value_6_8 + 1
            local value_8_6 = argument_3
            local value_9_6: number = value_6_8
            value_8_6(value_9_6)
            local wait_value_2: (number?) -> (number) = task.wait
            local value_9_7: number = 5
            wait_value_2(value_9_7)
            local value_8_7 = value_8
            if value_5_16 ~= value_8_7 then
                return
            end
        end
    end
    captured_value_16 = value_13
    closure_ready_7 = true
end
table_1.JoinFriend = value_14
do
    local closure_ready_8
    value_14 = function<T1>(argument_1_6: T1): ()
        if not closure_ready_8 then
            return
        end
        value_8 = value_8 + 1

        return
    end
    closure_ready_8 = true
end
table_1.CancelJoin = value_14
do
    local captured_value_17, captured_value_18, closure_ready_10
    value_14 = function<T1>(argument_1_7: T1)
        if not closure_ready_10 then
            return
        end
        local value_2_10 = value_6
        do
            local take_fallback_2 = value_2_10
            if not take_fallback_2 then
                take_fallback_2 = captured_value_17.UserId <= 0
            end
            if take_fallback_2 then
                return
            end
        end
        value_6 = true
        local spawn_value = task.spawn
        local value_3_8
        do
            local captured_value_19 = captured_value_18
            if closure_cache[8] ~= nil and same_capture(closure_cache[9], captured_value_19) then
                value_3_8 = closure_cache[8]
            else
                local closure_ready_9
                value_3_8 = function(): ()
                    if not closure_ready_9 then
                        return
                    end
                    while true do
                        local value_1_5 = captured_value_19
                        value_1_5()
                        local wait_value_3: (number?) -> (number) = task.wait
                        local value_2_13: number = 30
                        wait_value_3(value_2_13)
                    end
                end
                closure_ready_9 = true
                if closure_cache[8] == nil then
                    closure_cache[8] = value_3_8
                    closure_cache[9] = captured_value_19
                end
            end
        end
        spawn_value(value_3_8)

        return
    end
    captured_value_17, captured_value_18 = local_player_value, refresh
    closure_ready_10 = true
end
table_1.StartRefreshing = value_14

return table_1
