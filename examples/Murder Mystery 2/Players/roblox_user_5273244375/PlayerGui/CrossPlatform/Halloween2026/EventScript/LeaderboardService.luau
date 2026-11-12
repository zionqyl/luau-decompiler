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
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "ItemService"
local require_result = require_value(client_services_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "EventInfoService"
local wait_for_initialized_async_result = require_value_2(shared_services_child:WaitForChild(
    value_6_3
)):WaitForInitializedAsync()
local require_value_3 = require
local parent_value: Instance? = script.Parent
local value_7: string = "NavigationService"
local require_result_3 = require_value_3(parent_value:WaitForChild(value_7))
local require_value_4 = require
local game_value_3: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_8)
local value_8_2: string = "SharedServices"
local shared_services_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_8_2)
local value_8_3: string = "TimestampService"
local require_result_4 = require_value_4(shared_services_child_2:WaitForChild(value_8_3))
local require_value_5 = require
local game_value_4: DataModel = game
local value_9 = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_9)
value_9 = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_9)
value_9 = "Button"
local require_result_5 = require_value_5(client_services_child_2:WaitForChild(value_9))
local parent_value_3 = script.Parent.Parent
local value_10: string = "MainEvent"
local main_event_child = parent_value_3:WaitForChild(value_10)
local value_11: string = "Title"
value_9 = main_event_child:WaitForChild(value_11)
local value_7_8 = value_9
local value_11_2: string = "Main"
value_9 = main_event_child:WaitForChild(value_11_2)
local value_7_9 = value_9
local value_10_4: string = "Leaderboard"
local leaderboard_child = value_7_9:WaitForChild(value_10_4)
value_9 = {Tokens = 0}
local table_10 = {Global = {}, Friends = {}}
value_9.Tokens = table_10
local value_7_10 = (wait_for_initialized_async_result:GetMainEvent())
local table_10_2 = {
    Gold = "EmberbowGold",
    Silver = "EmberbowSilver",
    Bronze = "EmberbowBronze",
    Top100 = "EmberbowBlue",
}
local currency_name_value = value_7_10.EventStartInfo.CurrencyName
local game_value_5: DataModel = game
local value_14 = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_14)
value_14 = "Remotes"
local remotes_child: Instance? = replicated_storage_service_5:WaitForChild(value_14)
value_14 = "Events"
local events_child = remotes_child:WaitForChild(value_14)
value_14 = value_7_10.Title .. "Remotes"
local wait_for_child_result = events_child:WaitForChild(value_14)
local value_13: string = "Points"
value_14 = string.find
value_14 = value_14(currency_name_value, "Tokens")
if value_14 then
    value_13 = "Tokens"
else
    value_14 = string.find
    value_14 = value_14(currency_name_value, "Candies")
    if value_14 then
        value_13 = "Candies"
    else
        value_14 = string.find
        value_14 = value_14(currency_name_value, "Beach")
        if value_14 then
            value_13 = "Beach balls"
        end
    end
end
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = wait_for_initialized_async_result, value_7_10, require_result_4, leaderboard_child
    value_14 = function<T1>(argument_1: T1): ()
        local value_2 = captured_value
        local value_4_8 = captured_value_2
        local get_leaderboard_status_result, value_3_6 = value_2:GetLeaderboardStatus(value_4_8)
        local value_4_9 = captured_value_3
        local value_6_8 = value_3_6
        local get_leaderboard_time_text_result = value_4_9:GetLeaderboardTimeText(value_6_8)
        if get_leaderboard_status_result == "notStarted" then
            local pause_value = captured_value_4.Timer.Pause
            local value_6_9 = "Leaderboards open in: " .. get_leaderboard_time_text_result
            pause_value.Text = value_6_9

            return
        end
        if get_leaderboard_status_result == "pausingSoon" then
            local pause_value_2 = captured_value_4.Timer.Pause
            local value_6_10 = value_13 .. " leaderboard pauses for Christmas in: " .. get_leaderboard_time_text_result
            pause_value_2.Text = value_6_10

            return
        end
        if get_leaderboard_status_result == "paused" then
            local pause_value_3 = captured_value_4.Timer.Pause
            local value_6_11 = value_13 .. " leaderboard resumes in: " .. get_leaderboard_time_text_result
            pause_value_3.Text = value_6_11

            return
        end
        if get_leaderboard_status_result == "endingSoon" then
            local pause_value_4 = captured_value_4.Timer.Pause
            local value_6_12 = "Leaderboards end in: " .. get_leaderboard_time_text_result
            pause_value_4.Text = value_6_12

            return
        end
        if get_leaderboard_status_result == "ended" then
            local pause_value_5 = captured_value_4.Timer.Pause
            local value_6_13: string = "Leaderboards have ended!"
            pause_value_5.Text = value_6_13
        end

        return
    end
end
local table_1 = {
    [("UpdateStatus")] = nil,
    [("UpdateStatus")] = nil,
    [("UpdateStatus")] = nil,
    [("UpdateStatus")] = nil,
    [("UpdateStatus")] = nil,
}
table_1.UpdateStatus = value_14
local request_leaderboard
do
    local captured_value_5, captured_value_6 = wait_for_child_result, value_7_10
    request_leaderboard = function(argument_1_2: string)
        local table_2 = {[("Global")] = nil, [("Global")] = nil}
        local get_leaderboard_value = captured_value_5.GetLeaderboard
        local title_value_2 = captured_value_6.Title
        local value_6_14: string = argument_1_2
        local value_7_15: string = "Global"
        local invoke_server_result = get_leaderboard_value:InvokeServer(
            title_value_2,
            value_6_14,
            value_7_15
        )
        table_2.Global = invoke_server_result
        local get_leaderboard_value_2 = captured_value_5.GetLeaderboard
        local title_value_3 = captured_value_6.Title
        local value_6_15: string = argument_1_2
        local value_7_16: string = "Friends"
        local invoke_server_result_2 = get_leaderboard_value_2:InvokeServer(
            title_value_3,
            value_6_15,
            value_7_16
        )
        table_2.Friends = invoke_server_result_2

        return table_2
    end
end
do
    local captured_value_7, captured_value_8 = require_result, leaderboard_child
    value_14 = function(argument_1_3, argument_2, argument_3): ()
        local value_4_13 = argument_3
        local value_5_16: nil = nil
        local value_6_16: nil = nil
        for key, value in value_4_13, value_5_16, value_6_16 do
            local value_7_17, value_8_13 = key, value
            local script_value_3: LuaSourceContainer = script
            local value_13_2: string = "Place"
            local value_14_2 = value_7_17
            local value_12_5 = value_13_2 .. value_14_2
            local find_first_child_result: Instance? = script_value_3:FindFirstChild(value_12_5)
            local value_9_4
            do
                local take_fallback = not find_first_child_result
                if not take_fallback then
                    local value_10_7: string = "Place"
                    local value_11_5 = value_7_17
                    value_9_4 = value_10_7 .. value_11_5
                    take_fallback = not value_9_4
                end
                if take_fallback then
                    value_9_4 = "Place"
                end
            end
            local script_value_4: LuaSourceContainer = script
            local value_10_8 = script_value_4[value_9_4]
            local cloned_value = value_10_8:Clone()
            local value_11_7: number = 4
            if value_7_17 < value_11_7 then
                local container_value = cloned_value.Container
                local player_image_value = container_value.PlayerImage
                local game_value_6: DataModel = game
                local replicated_storage_value = game_value_6.ReplicatedStorage
                local get_player_image_value = replicated_storage_value.GetPlayerImage
                local user_name_value = value_8_13.userName
                local invoke_result = get_player_image_value:Invoke(user_name_value)
                player_image_value.Image = invoke_result
            end
            local value_11_8: nil = nil
            local find_value = string.find
            local value_13_4 = argument_1_3
            local value_14_3: string = "Gifts"
            local find_result = find_value(value_13_4, value_14_3)
            local value_11_9: string?
            if find_result then
                value_11_9 = "Gifts"
            else
                value_11_9 = value_13
            end
            local container_value_2 = cloned_value.Container
            local username_value = container_value_2.Username
            local value_14_4: string = "#"
            local value_15_4 = value_7_17
            local value_16_5: string = " - "
            local user_name_value_2 = value_8_13.userName
            local value_13_5 = value_14_4 .. value_15_4 .. value_16_5 .. user_name_value_2
            username_value.Text = value_13_5
            local container_value_3 = cloned_value.Container
            local token_count_value = container_value_3.TokenCount
            local value_14_5 = captured_value_7
            local points_value = value_8_13.points
            local comma_number_result = value_14_5:CommaNumber(points_value)
            local value_15_6: string = " "
            local lower_value = string.lower
            local value_17: string = value_11_9
            local lower_result = lower_value(value_17)
            local value_13_6 = comma_number_result .. value_15_6 .. lower_result
            token_count_value.Text = value_13_6
            local value_12_7: boolean = true
            cloned_value.Visible = value_12_7
            cloned_value.LayoutOrder = value_7_17
            local value_14_7 = captured_value_8
            local leaderboards_value = value_14_7.Leaderboards
            local value_13_7 = leaderboards_value[argument_1_3]
            local value_12_8 = value_13_7[argument_2]
            cloned_value.Parent = value_12_8
        end

        return
    end
end
table_1.Generate = value_14
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12 = table_1, value_7_10, request_leaderboard, leaderboard_child
    value_14 = function<T1>(argument_1_4: T1)
        captured_value_9:UpdateStatus()
        value_9 = {}
        local leaderboards_value_2 = captured_value_10.EventStartInfo.Leaderboards
        local value_3_11 = leaderboards_value_2.Points
        local value_4_14
        if value_3_11 then
            value_3_11 = value_9
            value_4_14 = captured_value_11("Points")
            value_3_11.Tokens = value_4_14
        end
        value_3_11 = leaderboards_value_2.Gifts
        if value_3_11 then
            value_3_11 = value_9
            value_4_14 = captured_value_11("Gifts")
            value_3_11.Gifts = value_4_14
        end
        local value_5_17
        value_3_11, value_4_14, value_5_17 = captured_value_12.Leaderboards:GetChildren()
        for key_3, value_22 in value_3_11, value_4_14, value_5_17 do
            local value_6_17, value_7_18 = key_3, value_22
            if not value_9[value_7_18.Name] then
                continue
            end
            local value_8_14, value_9_5, name_value = value_7_18:GetChildren()
            for key_2, value_21 in value_8_14, value_9_5, name_value do
                local value_11_10, value_12_9 = key_2, value_21
                local name_value_2 = value_7_18.Name
                local name_value_3 = value_12_9.Name
                local value_15_7 = captured_value_9
                local generate_value = value_15_7.Generate
                local value_16_6 = name_value_2
                local value_17_2 = name_value_3
                local value_20 = value_9
                local value_19 = value_20[name_value_2]
                local value_18 = value_19[name_value_3]
                generate_value(value_16_6, value_17_2, value_18)
            end
        end

        return
    end
end
table_1.Create = value_14
do
    local captured_value_13, captured_value_14, captured_value_15, captured_value_16 = value_7_10, table_1, request_leaderboard, leaderboard_child
    value_14 = function<T1>(argument_1_5: T1)
        local leaderboards_value_3 = captured_value_13.EventStartInfo.Leaderboards
        captured_value_14:UpdateStatus()
        value_9 = {}
        local value_3_12 = leaderboards_value_3.Points
        local value_4_15
        if value_3_12 then
            value_3_12 = value_9
            value_4_15 = captured_value_15("Points")
            value_3_12.Tokens = value_4_15
        end
        value_3_12 = leaderboards_value_3.Gifts
        if value_3_12 then
            value_3_12 = value_9
            value_4_15 = captured_value_15("Gifts")
            value_3_12.Gifts = value_4_15
        end
        value_3_12 = value_9
        value_4_15 = nil
        local value_5_18: nil = nil
        for key_6, value_25 in value_3_12, value_4_15, value_5_18 do
            local value_6_18, value_7_19 = key_6, value_25
            local value_8_15 = value_7_19
            local value_9_6: nil = nil
            local value_10_10: nil = nil
            for key_5, value_24 in value_8_15, value_9_6, value_10_10 do
                local value_11_11, value_12_10 = key_5, value_24
                local value_2_7 = captured_value_16.Leaderboards[value_6_18][value_11_11]
                local value_13_8, value_14_8, value_15_8 = value_2_7:GetChildren()
                local value_16_7
                for key_4, value_23 in value_13_8, value_14_8, value_15_8 do
                    local value_17_3
                    value_16_7, value_17_3 = key_4, value_23
                    local value_20_2: string = "Frame"
                    local is_a_result = value_17_3:IsA(value_20_2)
                    if not is_a_result then
                        continue
                    end
                    value_17_3:Destroy()
                end
                value_13_8 = captured_value_14.Generate
                value_14_8 = value_6_18
                value_15_8 = value_11_11
                value_16_7 = value_12_10
                value_13_8(value_14_8, value_15_8, value_16_7)
            end
        end

        return
    end
end
table_1.Update = value_14
value_14 = -60
do
    local captured_value_17 = table_1

    local function on_leaderboard_opened()
        if 60 <= (os.clock()) - value_14 then
            value_14 = (os.clock())
            captured_value_17.Update()
        end

        return
    end
end
local initialize
do
    local captured_value_18, captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24 = value_7_10, require_result_5, leaderboard_child, table_10_2, require_result, require_result_3, table_1
    initialize = function()
        local gifts_value = {}
        local value_3_14 = {}
        local leaderboards_value_4 = captured_value_18.EventStartInfo.Leaderboards
        gifts_value.value = leaderboards_value_4.Gifts
        local value_4_16
        if gifts_value.value ~= nil then
            gifts_value.value = nil
            value_3_14.value = nil
            value_4_16 = captured_value_19.createButton(captured_value_20.Info.TypeButtons.Tokens)
            gifts_value.value = value_4_16
            do
                local captured_value_25, captured_value_26, captured_value_27, closure_ready
                value_4_16 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local gifts_value_2 = captured_value_25.Leaderboards.Gifts
                    local value_2_9: boolean = false
                    gifts_value_2.Visible = value_2_9
                    local tokens_value = captured_value_25.Leaderboards.Tokens
                    local value_2_10: boolean = true
                    tokens_value.Visible = value_2_10
                    captured_value_26.value:Disable()
                    captured_value_27.value:Enable()

                    return
                end
                captured_value_25, captured_value_26, captured_value_27 = captured_value_20, gifts_value, value_3_14
                closure_ready = true
            end
            gifts_value.value.clickStart = value_4_16
            gifts_value.value:Disable()
            value_4_16 = captured_value_19.createButton(captured_value_20.Info.TypeButtons.Gifts)
            value_3_14.value = value_4_16
            do
                local captured_value_28, captured_value_29, captured_value_30, closure_ready_2
                value_4_16 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    local gifts_value_3 = captured_value_28.Leaderboards.Gifts
                    local value_2_13: boolean = true
                    gifts_value_3.Visible = value_2_13
                    local tokens_value_2 = captured_value_28.Leaderboards.Tokens
                    local value_2_14: boolean = false
                    tokens_value_2.Visible = value_2_14
                    captured_value_29.value:Disable()
                    captured_value_30.value:Enable()

                    return
                end
                captured_value_28, captured_value_29, captured_value_30 = captured_value_20, value_3_14, gifts_value
                closure_ready_2 = true
            end
            value_3_14.value.clickStart = value_4_16
            gifts_value = {value = gifts_value.value}
            value_3_14 = {value = value_3_14.value}
        else
            gifts_value.value = captured_value_20
            value_4_16 = "Info"
            gifts_value.value = gifts_value.value:WaitForChild(value_4_16)
            value_4_16 = "TypeButtons"
            gifts_value.value = gifts_value.value:WaitForChild(value_4_16)
            value_3_14.value = false
            gifts_value.value.Visible = value_3_14.value
        end
        gifts_value.value = captured_value_20
        gifts_value.value = gifts_value.value.Info
        gifts_value.value = gifts_value.value.GroupButtons
        gifts_value.value = gifts_value.value.GlobalButton
        gifts_value.value = gifts_value.value.Activated
        do
            local captured_value_31 = captured_value_20
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_31) then
                value_4_16 = closure_cache[1]
            else
                local closure_ready_3
                value_4_16 = function(): ()
                    if not closure_ready_3 then
                        return
                    end
                    local global_value = captured_value_31.Leaderboards.Gifts.Global
                    local value_2_17: boolean = true
                    global_value.Visible = value_2_17
                    local global_value_2 = captured_value_31.Leaderboards.Tokens.Global
                    local value_2_18: boolean = true
                    global_value_2.Visible = value_2_18
                    local friends_value = captured_value_31.Leaderboards.Gifts.Friends
                    local value_2_19: boolean = false
                    friends_value.Visible = value_2_19
                    local friends_value_2 = captured_value_31.Leaderboards.Tokens.Friends
                    local value_2_20: boolean = false
                    friends_value_2.Visible = value_2_20
                    local background_value = captured_value_31.Info.GroupButtons.Background
                    local new_result = UDim2.new(0, 0, 0, 0)
                    local out_value = Enum.EasingDirection.Out
                    local quad_value = Enum.EasingStyle.Quad
                    local value_6_21: number = 0.1
                    background_value:TweenPosition(new_result, out_value, quad_value, value_6_21)

                    return
                end
                closure_ready_3 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_16
                    closure_cache[2] = captured_value_31
                end
            end
        end
        gifts_value.value:Connect(value_4_16)
        gifts_value.value = captured_value_20
        gifts_value.value = gifts_value.value.Info
        gifts_value.value = gifts_value.value.GroupButtons
        gifts_value.value = gifts_value.value.FriendsButton
        gifts_value.value = gifts_value.value.Activated
        do
            local captured_value_32 = captured_value_20
            if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_32) then
                value_4_16 = closure_cache[3]
            else
                local closure_ready_4
                value_4_16 = function(): ()
                    if not closure_ready_4 then
                        return
                    end
                    local global_value_3 = captured_value_32.Leaderboards.Gifts.Global
                    local value_2_22: boolean = false
                    global_value_3.Visible = value_2_22
                    local global_value_4 = captured_value_32.Leaderboards.Tokens.Global
                    local value_2_23: boolean = false
                    global_value_4.Visible = value_2_23
                    local friends_value_3 = captured_value_32.Leaderboards.Gifts.Friends
                    local value_2_24: boolean = true
                    friends_value_3.Visible = value_2_24
                    local friends_value_4 = captured_value_32.Leaderboards.Tokens.Friends
                    local value_2_25: boolean = true
                    friends_value_4.Visible = value_2_25
                    local background_value_2 = captured_value_32.Info.GroupButtons.Background
                    local new_result_2 = UDim2.new(0.5, 0, 0, 0)
                    local out_value_2 = Enum.EasingDirection.Out
                    local quad_value_2 = Enum.EasingStyle.Quad
                    local value_6_23: number = 0.1
                    background_value_2:TweenPosition(
                        new_result_2,
                        out_value_2,
                        quad_value_2,
                        value_6_23
                    )

                    return
                end
                closure_ready_4 = true
                if closure_cache[3] == nil then
                    closure_cache[3] = value_4_16
                    closure_cache[4] = captured_value_32
                end
            end
        end
        gifts_value.value:Connect(value_4_16)
        local value_1_4 = captured_value_20
        value_3_14.value = "RewardsOverlay"
        local rewards_overlay_child = value_1_4:WaitForChild(value_3_14.value)
        value_4_16 = "RewardsContainer"
        gifts_value.value = rewards_overlay_child:WaitForChild(value_4_16)
        value_3_14.value = captured_value_21
        value_4_16 = nil
        local value_5_19 = nil
        local value_6_19
        for key_7, value_26 in value_3_14.value, value_4_16, value_5_19 do
            local value_7_20
            value_6_19, value_7_20 = key_7, value_26
            local value_10_11 = value_6_19
            local find_first_child_result_2 = gifts_value.value:FindFirstChild(value_10_11)
            if not find_first_child_result_2 then
                continue
            end
            local icon_value = find_first_child_result_2.Icon
            local value_10_12 = captured_value_22
            local value_12_11 = value_7_20
            local value_13_9: string = "Weapons"
            local get_display_info_result = value_10_12:GetDisplayInfo(value_12_11, value_13_9)
            local image_value = get_display_info_result.Image
            icon_value.Image = image_value
        end
        value_3_14.value = captured_value_19
        value_3_14.value = value_3_14.value.createButton
        value_4_16 = captured_value_20.Info
        value_6_19 = "Rewards"
        value_4_16 = value_4_16:WaitForChild(value_6_19)
        do
            local captured_value_33, closure_ready_5
            value_5_19 = function(): ()
                if not closure_ready_5 then
                    return
                end
                local value_1_30 = captured_value_33
                local value_2_27: boolean = not captured_value_33.Visible
                value_1_30.Visible = value_2_27

                return
            end
            captured_value_33 = rewards_overlay_child
            closure_ready_5 = true
        end
        value_3_14.value(value_4_16, value_5_19)
        value_3_14.value = captured_value_23
        value_3_14.value = value_3_14.value.PageChanged
        value_3_14.value = value_3_14.value.Event
        do
            local captured_value_34, captured_value_35, closure_ready_6
            value_5_19 = function(argument_1_6): ()
                if not closure_ready_6 then
                    return
                end
                local clock_result_3, clock_result_4, clock_value_3, clock_value_4, update_value_2, value_2_28, value_2_29, value_2_30, value_3_16, value_3_17, value_4_19
                local control_state = 0
                while true do
                    if control_state < 2 then
                        if control_state < 1 then
                            control_state = if argument_1_6 ~= "Leaderboard" then 3 else 1
                        else
                            clock_value_3 = os.clock
                            clock_result_3 = clock_value_3()
                            value_4_19 = value_14
                            value_2_28 = clock_result_3 - value_4_19
                            value_3_16 = 60
                            control_state = if not (value_3_16 <= value_2_28) then 4 else 2
                        end
                    else
                        if control_state < 3 then
                            clock_value_4 = os.clock
                            clock_result_4 = clock_value_4()
                            value_14 = clock_result_4
                            value_2_29 = captured_value_34
                            update_value_2 = value_2_29.Update
                            update_value_2()

                            return
                        else
                            if control_state < 4 then
                                value_2_30 = captured_value_35
                                value_3_17 = false
                                value_2_30.Visible = value_3_17
                                control_state = 4
                            else
                                return
                            end
                        end
                    end
                end
            end
            captured_value_34, captured_value_35 = captured_value_24, rewards_overlay_child
            closure_ready_6 = true
        end
        value_3_14.value:Connect(value_5_19)
        value_3_14.value = captured_value_24
        value_3_14.value = value_3_14.value.Create
        value_3_14.value()

        return
    end
end
table_1.Initialize = initialize

return table_1
