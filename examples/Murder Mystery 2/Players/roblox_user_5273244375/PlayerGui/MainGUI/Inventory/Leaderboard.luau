--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function shared_function(argument_1, argument_2): boolean
    local value_3_5 = (argument_1.Prestige or 0) * 100 + (argument_1.Level or 1)
    local value_5_16: boolean?
    if not ((argument_2.Prestige or 0) * 100 + (argument_2.Level or 1) < value_3_5) then
        value_5_16 = false
    else
        value_5_16 = true
    end

    return value_5_16
end

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

local game_value = script.Parent.Parent.Game
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "WindowService"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_6_3))
local require_value_3 = require
local game_value_4: DataModel = game
local value_7 = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_7)
value_7 = "Modules"
local modules_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_7)
value_7 = "ProfileData"
local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_7))
local game_value_5: DataModel = game
value_7 = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_5:GetService(value_7)
value_7 = "Remotes"
local remotes_child: Instance? = replicated_storage_service_4:WaitForChild(value_7)
local require_value_4 = require
value_7 = script
value_7 = value_7.getTableFromInstance
local require_result_4 = require_value_4(value_7)
value_7 = require_result_4
value_7 = value_7(game.Players)
value_7 = value_7.Players
local table_8 = {}
local require_result_5 = require(game.ReplicatedStorage.Modules.ViewProfileModule)
local view_profile_value = script.Parent.Parent.Game.ViewProfile
local gui_value = require_result_5.GUI
local container_value = view_profile_value.Main.Profile.Container
gui_value.ProfileContainer = container_value
local gui_value_2 = require_result_5.GUI
local search_text_value = view_profile_value.Main.Weapons.Items.Tabs.Search.Container.SearchText
gui_value_2.SearchFrameTextBox = search_text_value
local require_result_6 = require(game.ReplicatedStorage.Modules.TradeModule)
local require_result_7 = require(game.ReplicatedStorage.Modules.LevelModule)
local g_value = _G
local value_14
if _G.LeaderboardOpen == nil then
    value_14 = true
else
    value_14 = _G.LeaderboardOpen
end
g_value.LeaderboardOpen = value_14
local table_13: {[number]: string?} = {
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
}
local value_14_2: number = 0
local value_15: string = ""
table_13[value_14_2] = value_15
local value_14_3: string = "I"
table_13[1] = value_14_3
local value_14_4: string = "II"
table_13[2] = value_14_4
local value_14_5: string = "III"
table_13[3] = value_14_5
local value_14_6: string = "IV"
table_13[4] = value_14_6
local value_14_7: string = "V"
table_13[5] = value_14_7
local value_14_8: string = "VI"
table_13[6] = value_14_8
local value_14_9: string = "VII"
table_13[7] = value_14_9
local value_14_10: string = "VIII"
table_13[8] = value_14_10
local value_14_11: string = "IX"
table_13[9] = value_14_11
local value_14_12: string = "X"
table_13[10] = value_14_12
local table_14 = {[true] = nil, [true] = nil}
local value_15_2: boolean = true
local value_16: string = "^"
table_14[value_15_2] = value_16
local value_15_3: boolean = false
local value_16_2: string = "v"
table_14[value_15_3] = value_16_2
local require_result_8 = require(game.ReplicatedStorage.RankIconsEmpty)
local name_tags_value = require_result.NameTags
local from_rgb_value: (number?, number?, number?) -> (Color3) = Color3.fromRGB
local value_17 = 232
local from_rgb_result: Color3 = from_rgb_value(value_17, 42, 42)
local leaderboard_value = script.Parent.Parent.Game.Leaderboard
value_17 = nil
local inspect_value = leaderboard_value.Inspect
local roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
local roblox_round_button_value = Enum.ButtonStyle.RobloxRoundButton
local update_leaderboard: (() -> ())?
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, closure_ready_4
    update_leaderboard = function(): ()
        if not closure_ready_4 then
            return
        end
        local table_1 = {}
        local pairs_value_2, value_3_4, value_4_7 = pairs(value_7)
        local value_5_12, value_6_9
        for key, value in pairs_value_2, value_3_4, value_4_7 do
            value_5_12, value_6_9 = key, value
            local game_value_14: DataModel = game
            local players_value_2 = game_value_14.Players
            local value_9 = value_5_12
            local find_first_child_result = players_value_2:FindFirstChild(value_9)
            if not find_first_child_result then
                continue
            end
            local table_9 = {
                PlayerName = 0,
                Level = 0,
                Elite = 0,
                Prestige = 0,
                XP = 0,
            }
            table_9.PlayerName = value_5_12
            local level_value = value_6_9.Level
            local value_10 = level_value or 1
            table_9.Level = value_10
            local elite_value = value_6_9.Elite
            table_9.Elite = elite_value
            local prestige_value = value_6_9.Prestige
            local value_10_2 = prestige_value or 0
            table_9.Prestige = value_10_2
            local xp_value = value_6_9.XP
            local value_10_3 = xp_value or 0
            table_9.XP = value_10_3
            local value_8_2 = table_1
            local insert_value = table.insert
            insert_value(value_8_2, table_9)
        end
        table.sort(table_1, shared_function)
        pairs_value_2, value_3_4, value_4_7 = pairs(table_1)
        for key_2, value_20 in pairs_value_2, value_3_4, value_4_7 do
            value_5_12, value_6_9 = key_2, value_20
            local player_name_value = value_6_9.PlayerName
            local value_9_2 = captured_value
            local value_8_3 = value_9_2[player_name_value]
            do
                local take_fallback = value_8_3 == nil
                if not take_fallback then
                    local parent_value_7 = value_8_3.Parent
                    take_fallback = parent_value_7 == nil
                end
                if take_fallback then
                    local script_value_4: LuaSourceContainer = script
                    local player_frame_value = script_value_4.Player_Frame
                    local cloned_value = player_frame_value:Clone()
                    local game_value_15: DataModel = game
                    local players_value_3 = game_value_15.Players
                    local local_player_value_2 = players_value_3.LocalPlayer
                    local name_value_2 = local_player_value_2.Name
                    local value_10_5: boolean?
                    if player_name_value ~= name_value_2 then
                        value_10_5 = false
                    else
                        value_10_5 = true
                    end
                    local player_label_value = cloned_value.PlayerLabel
                    local elite_value_2 = value_6_9.Elite
                    local value_13: string?
                    if elite_value_2 == true then
                        value_13 = "[ELITE] "
                    else
                        value_13 = ""
                    end
                    local value_14_13 = player_name_value
                    local value_12 = value_13 .. value_14_13
                    player_label_value.Text = value_12
                    local player_label_value_2 = cloned_value.PlayerLabel
                    local elite_value_3 = value_6_9.Elite
                    local value_12_2: Color3?
                    do
                        local take_fallback_2 = elite_value_3 ~= true
                        if not take_fallback_2 then
                            value_12_2 = captured_value_2
                            take_fallback_2 = not value_12_2
                        end
                        if take_fallback_2 then
                            local new_value: (number?, number?, number?) -> (Color3) = Color3.new
                            local value_13_2: number = 1
                            local value_14_14: number = 1
                            local value_15_4: number = 1
                            value_12_2 = new_value(value_13_2, value_14_14, value_15_4)
                        end
                    end
                    player_label_value_2.TextColor3 = value_12_2
                    local xp_bar_value = cloned_value.XPBar
                    xp_bar_value.Visible = value_10_5
                    if value_10_5 then
                        do
                            local captured_value_12, captured_value_13, captured_value_14, closure_ready

                            local function update_xp_bar(): ()
                                if not closure_ready then
                                    return
                                end
                                local new_xp_value_2 = captured_value_12.NewXP
                                local get_progress_to_next_level_result_2 = captured_value_13.GetProgressToNextLevel(
                                    new_xp_value_2
                                )
                                local bar_value_2 = captured_value_14.XPBar.Bar
                                local new_result_2 = UDim2.new(
                                    get_progress_to_next_level_result_2,
                                    bar_value_2.Size.X.Offset,
                                    bar_value_2.Size.Y.Scale,
                                    bar_value_2.Size.Y.Offset
                                )
                                bar_value_2.Size = new_result_2

                                return
                            end

                            captured_value_12, captured_value_13, captured_value_14 = captured_value_3, captured_value_4, cloned_value
                            closure_ready = true
                        end
                        local value_12_3 = captured_value_3
                        local new_xp_value = value_12_3.NewXP
                        local value_13_3 = captured_value_4
                        local get_progress_to_next_level_value = value_13_3.GetProgressToNextLevel
                        local value_14_15 = new_xp_value
                        local get_progress_to_next_level_result = get_progress_to_next_level_value(
                            value_14_15
                        )
                        local xp_bar_value_2 = cloned_value.XPBar
                        local bar_value = xp_bar_value_2.Bar
                        local new_value_2: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
                        local value_15_5 = get_progress_to_next_level_result
                        local size_value = bar_value.Size
                        local x_value = size_value.X
                        local offset_value = x_value.Offset
                        local size_value_2 = bar_value.Size
                        local y_value = size_value_2.Y
                        local scale_value = y_value.Scale
                        local size_value_3 = bar_value.Size
                        local y_value_2 = size_value_3.Y
                        local offset_value_2 = y_value_2.Offset
                        local new_result = new_value_2(
                            value_15_5,
                            offset_value,
                            scale_value,
                            offset_value_2
                        )
                        bar_value.Size = new_result
                        local value_12_4: Instance? = captured_value_5
                        local value_14_16: string = "Inventory"
                        local inventory_child = value_12_4:WaitForChild(value_14_16)
                        local value_14_17: string = "ProfileDataChanged"
                        local profile_data_changed_child = inventory_child:WaitForChild(
                            value_14_17
                        )
                        local event_value = profile_data_changed_child.Event
                        local value_14_18
                        do
                            local captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21, closure_ready_2
                            value_14_18 = function<T2>(argument_1_2, argument_2_2: T2): ()
                                if not closure_ready_2 then
                                    return
                                end
                                do
                                    local take_fallback_3 = argument_1_2 == "NewXP"
                                    if take_fallback_3 or argument_1_2 == "Prestige" then
                                        local new_xp_value_3 = captured_value_15.NewXP
                                        local get_progress_to_next_level_result_3 = captured_value_16.GetProgressToNextLevel(
                                            new_xp_value_3
                                        )
                                        local bar_value_3 = captured_value_17.XPBar.Bar
                                        local new_result_3 = UDim2.new(
                                            get_progress_to_next_level_result_3,
                                            bar_value_3.Size.X.Offset,
                                            bar_value_3.Size.Y.Scale,
                                            bar_value_3.Size.Y.Offset
                                        )
                                        bar_value_3.Size = new_result_3
                                        local value_3_9: boolean?
                                        if not (100 <= (captured_value_16.GetLevel(
                                            captured_value_18.XP
                                        ))) then
                                            value_3_9 = false
                                        else
                                            value_3_9 = true
                                        end
                                        local prestige_value_6 = captured_value_19.Container.Prestige
                                        local value_5_20
                                        do
                                            local take_fallback_4 = not value_3_9
                                            if not take_fallback_4 then
                                                value_5_20 = captured_value_20
                                                take_fallback_4 = not value_5_20
                                            end
                                            if take_fallback_4 then
                                                value_5_20 = captured_value_21
                                            end
                                        end
                                        prestige_value_6.Style = value_5_20
                                    end
                                end

                                return
                            end
                            captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21 = captured_value_3, captured_value_4, cloned_value, value_6_9, captured_value_6, captured_value_7, captured_value_8
                            closure_ready_2 = true
                        end
                        event_value:Connect(value_14_18)
                    end
                    local action_button_value = cloned_value.ActionButton
                    local activated_value_2 = action_button_value.Activated
                    local value_13_7: (() -> ())?
                    do
                        local captured_value_22, captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, closure_ready_3
                        value_13_7 = function(): ()
                            if not closure_ready_3 then
                                return
                            end
                            local value_1_3: boolean?
                            if value_17 ~= captured_value_22 then
                                value_1_3 = false
                            else
                                value_1_3 = true
                            end
                            value_17 = captured_value_22
                            local username_value = captured_value_23.Container.Username
                            local value_3_11 = captured_value_22
                            username_value.Text = value_3_11
                            local value_2_5 = captured_value_23
                            local new_result_4 = UDim2.new(
                                captured_value_23.Position.X,
                                UDim.new(0, captured_value_24.AbsolutePosition.Y + 45)
                            )
                            value_2_5.Position = new_result_4
                            local trade_value = captured_value_23.Container.Trade
                            local value_3_12: boolean = not captured_value_25 and true
                            trade_value.Visible = value_3_12
                            local prestige_value_7 = captured_value_23.Container.Prestige
                            local value_3_13: boolean? = captured_value_25
                            prestige_value_7.Visible = value_3_13
                            if captured_value_25 then
                                local value_2_9: boolean?
                                if not (100 <= (captured_value_26.GetLevel(captured_value_27.XP))) then
                                    value_2_9 = false
                                else
                                    value_2_9 = true
                                end
                                local prestige_value_8 = captured_value_23.Container.Prestige
                                local value_4_18
                                do
                                    local take_fallback_5 = not value_2_9
                                    if not take_fallback_5 then
                                        value_4_18 = captured_value_28
                                        take_fallback_5 = not value_4_18
                                    end
                                    if take_fallback_5 then
                                        value_4_18 = captured_value_29
                                    end
                                end
                                prestige_value_8.Style = value_4_18
                            end
                            if value_1_3 then
                                local value_2_10 = captured_value_23
                                local value_3_16: boolean = not captured_value_23.Visible
                                value_2_10.Visible = value_3_16

                                return
                            end
                            local value_2_11 = captured_value_23
                            local value_3_17: boolean = true
                            value_2_11.Visible = value_3_17

                            return
                        end
                        captured_value_22, captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29 = player_name_value, captured_value_6, cloned_value, value_10_5, captured_value_4, value_6_9, captured_value_7, captured_value_8
                        closure_ready_3 = true
                    end
                    activated_value_2:Connect(value_13_7)
                    local g_value_5 = _G
                    local leaderboard_open_value_3 = g_value_5.LeaderboardOpen
                    cloned_value.Visible = leaderboard_open_value_3
                    cloned_value.Name = player_name_value
                    local value_11_2 = captured_value_9
                    local container_value_4 = value_11_2.Container
                    cloned_value.Parent = container_value_4
                    value_8_3 = cloned_value
                    local value_11_3 = captured_value
                    value_11_3[player_name_value] = cloned_value
                end
            end
            local level_value_2 = value_8_3.Level
            local prestige_value_2 = level_value_2.Prestige
            local value_11_4: {[number]: string?} = captured_value_10
            local prestige_value_3 = value_6_9.Prestige
            local tonumber_value = tonumber
            local tonumber_result = tonumber_value(prestige_value_3)
            local value_10_6: string?? = value_11_4[tonumber_result]
            prestige_value_2.Text = value_10_6
            local level_value_3 = value_8_3.Level
            local level_value_4 = level_value_3.Level
            local value_11_5 = captured_value_4
            local get_level_value = value_11_5.GetLevel
            local xp_value_2 = value_6_9.XP
            local get_level_result = get_level_value(xp_value_2)
            local value_10_7 = get_level_result or "?"
            level_value_4.Text = value_10_7
            local level_value_5 = value_8_3.Level
            local value_11_6 = captured_value_11
            local level_value_6 = value_6_9.Level
            local value_10_8 = value_11_6[level_value_6]
            level_value_5.Image = value_10_8
            value_8_3.LayoutOrder = value_5_12
            local game_value_16: DataModel = game
            local players_value_4 = game_value_16.Players
            local value_11_7 = player_name_value
            local find_first_child_result_2 = players_value_4:FindFirstChild(value_11_7)
            if find_first_child_result_2 ~= nil then
                continue
            end
            local value_9_5 = captured_value
            local value_10_10: nil = nil
            value_9_5[player_name_value] = value_10_10
            value_8_3:Destroy()
            local value_9_7: nil = nil
            table_1[value_5_12] = value_9_7
        end
        pairs_value_2, value_3_4, value_4_7 = pairs(captured_value_9.Container:GetChildren())
        for key_3, value_21 in pairs_value_2, value_3_4, value_4_7 do
            value_5_12, value_6_9 = key_3, value_21
            local value_9_8: string = "IsPlayerFrame"
            local is_player_frame_child = value_6_9:FindFirstChild(value_9_8)
            if not is_player_frame_child then
                continue
            end
            local game_value_17: DataModel = game
            local players_value_5 = game_value_17.Players
            local name_value_3 = value_6_9.Name
            local find_first_child_result_3 = players_value_5:FindFirstChild(name_value_3)
            if find_first_child_result_3 ~= nil then
                continue
            end
            value_6_9:Destroy()
        end

        return
    end
    captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11 = table_8, from_rgb_result, require_result_3, require_result_7, remotes_child, inspect_value, roblox_round_default_button_value, roblox_round_button_value, leaderboard_value, table_13, require_result_8
    closure_ready_4 = true
end
update_leaderboard()
do
    local captured_value_30, captured_value_31, captured_value_32 = table_8, leaderboard_value, table_14
    local update_leaderboard_visibility
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_30) and same_capture(
        closure_cache[3],
        captured_value_31
    ) and same_capture(closure_cache[4], captured_value_32) then
        update_leaderboard_visibility = closure_cache[1]
    else
        local closure_ready_5
        update_leaderboard_visibility = function()
            if not closure_ready_5 then
                return
            end
            local pairs_value_3, value_2_12, value_3_18 = pairs(captured_value_30)
            for key_4, value_23 in pairs_value_3, value_2_12, value_3_18 do
                local value_4_20, value_5_22 = key_4, value_23
                local g_value_6 = _G
                local leaderboard_open_value_4 = g_value_6.LeaderboardOpen
                value_5_22.Visible = leaderboard_open_value_4
            end
            pairs_value_3 = captured_value_31.Container.Close.Title
            value_2_12 = captured_value_32[_G.LeaderboardOpen]
            pairs_value_3.Text = value_2_12

            return
        end
        closure_ready_5 = true
        if closure_cache[1] == nil then
            closure_cache[1] = update_leaderboard_visibility
            closure_cache[2], closure_cache[3], closure_cache[4] = captured_value_30, captured_value_31, captured_value_32
        end
    end
end
local pairs_value, value_24, value_25 = pairs(table_8)
local value_26, value_27
for key_5, value_33 in pairs_value, value_24, value_25 do
    value_26, value_27 = key_5, value_33
    local g_value_4 = _G
    local leaderboard_open_value_2 = g_value_4.LeaderboardOpen
    value_27.Visible = leaderboard_open_value_2
end
pairs_value = leaderboard_value.Container.Close.Title
value_24 = table_14[_G.LeaderboardOpen]
pairs_value.Text = value_24
value_25 = view_profile_value
value_26 = "ViewProfile"
require_result_2:RegisterFrame(value_25, value_26)
pairs_value = inspect_value.Container.Profile.Activated
do
    local captured_value_33, captured_value_34, captured_value_35, captured_value_36, closure_ready_6
    value_25 = function(): ()
        if not closure_ready_6 then
            return
        end
        local get_player_profile_value = game.ReplicatedStorage.Remotes.Misc.GetPlayerProfile
        local value_3_19 = value_17
        local invoke_server_result = get_player_profile_value:InvokeServer(value_3_19)
        local value_2_14 = captured_value_33
        local value_3_20: boolean = false
        value_2_14.Visible = value_3_20
        captured_value_34.GenerateProfile(captured_value_35, value_17, invoke_server_result)
        local value_2_16 = captured_value_36
        local value_4_22: string = "ViewProfile"
        value_2_16:ViewFrame(value_4_22)

        return
    end
    captured_value_33, captured_value_34, captured_value_35, captured_value_36 = inspect_value, require_result_5, view_profile_value, require_result_2
    closure_ready_6 = true
end
pairs_value:Connect(value_25)
if game.GameId ~= 119460199 then
    pairs_value = false
else
    pairs_value = true
end
value_24 = inspect_value.Container.Trade.MouseButton1Click
do
    local captured_value_37, captured_value_38, closure_ready_7
    value_26 = function(): ()
        if not closure_ready_7 then
            return
        end
        captured_value_37.SendTradeRequest(value_17)
        local value_1_6 = captured_value_38
        local value_2_19: boolean = false
        value_1_6.Visible = value_2_19

        return
    end
    captured_value_37, captured_value_38 = require_result_6, inspect_value
    closure_ready_7 = true
end
value_24:Connect(value_26)
value_24 = inspect_value.Close.MouseButton1Click
do
    local captured_value_39, closure_ready_8
    value_26 = function(): ()
        if not closure_ready_8 then
            return
        end
        value_17 = nil
        local value_1_8 = captured_value_39
        local value_2_20: boolean = false
        value_1_8.Visible = value_2_20

        return
    end
    captured_value_39 = inspect_value
    closure_ready_8 = true
end
value_24:Connect(value_26)
value_24 = game.ReplicatedStorage.Remotes.Misc.UpdateLeaderboard.OnClientEvent
do
    local captured_value_40, captured_value_41, closure_ready_9
    value_26 = function<T1>(argument_1_3: T1): ()
        if not closure_ready_9 then
            return
        end
        value_7 = captured_value_40(game.Players).Players
        captured_value_41()

        return
    end
    captured_value_40, captured_value_41 = require_result_4, update_leaderboard
    closure_ready_9 = true
end
value_24:connect(value_26)
value_24 = leaderboard_value.Container.Close.Toggle.MouseButton1Click
do
    local captured_value_42, captured_value_43, captured_value_44 = table_8, leaderboard_value, table_14
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_42) and same_capture(
        closure_cache[7],
        captured_value_43
    ) and same_capture(closure_cache[8], captured_value_44) then
        value_26 = closure_cache[5]
    else
        local closure_ready_10
        value_26 = function()
            if not closure_ready_10 then
                return
            end
            local g_value_7 = _G
            local value_2_24 = not _G.LeaderboardOpen
            g_value_7.LeaderboardOpen = value_2_24
            local g_value_8
            g_value_7, value_2_24, g_value_8 = pairs(captured_value_42)
            for key_6, value_46 in g_value_7, value_2_24, g_value_8 do
                local value_4_23, value_5_24 = key_6, value_46
                local g_value_9 = _G
                local leaderboard_open_value_5 = g_value_9.LeaderboardOpen
                value_5_24.Visible = leaderboard_open_value_5
            end
            g_value_7 = captured_value_43.Container.Close.Title
            value_2_24 = captured_value_44[_G.LeaderboardOpen]
            g_value_7.Text = value_2_24

            return
        end
        closure_ready_10 = true
        if closure_cache[5] == nil then
            closure_cache[5] = value_26
            closure_cache[6], closure_cache[7], closure_cache[8] = captured_value_42, captured_value_43, captured_value_44
        end
    end
end
value_24:connect(value_26)
require_result_5.ConnectViewProfile(view_profile_value)
pairs_value = view_profile_value.Main.Weapons.Items.Container
value_24 = pairs_value.Holiday.Container.EventLayout
value_26 = "AbsoluteContentSize"
value_24 = value_24:GetPropertyChangedSignal(value_26)
do
    local captured_value_45 = pairs_value
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_45) then
        value_26 = closure_cache[9]
    else
        local closure_ready_11
        value_26 = function(): ()
            if not closure_ready_11 then
                return
            end
            local container_value_10 = captured_value_45.Holiday.Container
            local new_result_5 = UDim2.new(
                1,
                0,
                0,
                captured_value_45.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 3
            )
            container_value_10.Size = new_result_5
            local holiday_value_3 = captured_value_45.Holiday
            local new_result_6 = UDim2.new(
                1,
                0,
                0,
                captured_value_45.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 6
            )
            holiday_value_3.CanvasSize = new_result_6

            return
        end
        closure_ready_11 = true
        if closure_cache[9] == nil then
            closure_cache[9] = value_26
            closure_cache[10] = captured_value_45
        end
    end
end
value_24:connect(value_26)
value_24 = view_profile_value.Main.Weapons.Items.Tabs.Search.Container.SearchText
do
    local captured_value_46, captured_value_47, captured_value_48, captured_value_49 = require_result_7, require_result_3, leaderboard_value, require_result_6
    if closure_cache[11] ~= nil and same_capture(closure_cache[12], captured_value_46) and same_capture(
        closure_cache[13],
        captured_value_47
    ) and same_capture(closure_cache[14], captured_value_48) and same_capture(
        closure_cache[15],
        captured_value_49
    ) then
        value_24 = closure_cache[11]
    else
        local closure_ready_12
        value_24 = function(): ()
            if not closure_ready_12 then
                return
            end
            local get_level_result_4 = captured_value_46.GetLevel(captured_value_47.NewXP)
            local value_2_26: boolean = true
            if not (10 <= get_level_result_4) then
                if not (0 < captured_value_47.Prestige) then
                    value_2_26 = false
                else
                    value_2_26 = true
                end
            end
            local toggle_requests_value = captured_value_48.Container.ToggleRequests
            toggle_requests_value.Visible = value_2_26
            local trade_info_value = captured_value_48.Container.TradeInfo
            trade_info_value.Visible = value_2_26
            local minimum_trade_level_value = captured_value_48.Container.MinimumTradeLevel
            local value_4_27: boolean = not value_2_26
            minimum_trade_level_value.Visible = value_4_27
            if not value_2_26 then
                local value_3_30 = captured_value_49
                local value_4_28: boolean = false
                value_3_30.RequestsEnabled = value_4_28
            end

            return
        end
        closure_ready_12 = true
        if closure_cache[11] == nil then
            closure_cache[11] = value_24
            closure_cache[12], closure_cache[13], closure_cache[14], closure_cache[15] = captured_value_46, captured_value_47, captured_value_48, captured_value_49
        end
    end
end
value_25 = require_result_7.GetLevel(require_result_3.NewXP)
value_26 = true
if not (10 <= value_25) then
    if not (0 < require_result_3.Prestige) then
        value_26 = false
    else
        value_26 = true
    end
end
value_27 = leaderboard_value.Container.ToggleRequests
value_27.Visible = value_26
value_27 = leaderboard_value.Container.TradeInfo
value_27.Visible = value_26
value_27 = leaderboard_value.Container.MinimumTradeLevel
local value_28_2: boolean = not value_26
value_27.Visible = value_28_2
if not value_26 then
    value_27 = false
    require_result_6.RequestsEnabled = value_27
end
value_27 = "Inventory"
value_25 = remotes_child:WaitForChild(value_27)
value_27 = "ProfileDataChanged"
value_25 = value_25:WaitForChild(value_27).Event
do
    local captured_value_50, captured_value_51, captured_value_52, captured_value_53 = require_result_7, require_result_3, leaderboard_value, require_result_6
    if closure_cache[16] ~= nil and same_capture(closure_cache[17], captured_value_50) and same_capture(
        closure_cache[18],
        captured_value_51
    ) and same_capture(closure_cache[19], captured_value_52) and same_capture(
        closure_cache[20],
        captured_value_53
    ) then
        value_27 = closure_cache[16]
    else
        local closure_ready_13
        value_27 = function<T2>(argument_1_4, argument_2_3: T2): ()
            if not closure_ready_13 then
                return
            end
            if argument_1_4 == "NewXP" then
                local get_level_result_5 = captured_value_50.GetLevel(captured_value_51.NewXP)
                local value_4_30: boolean = true
                if not (10 <= get_level_result_5) then
                    if not (0 < captured_value_51.Prestige) then
                        value_4_30 = false
                    else
                        value_4_30 = true
                    end
                end
                local toggle_requests_value_2 = captured_value_52.Container.ToggleRequests
                toggle_requests_value_2.Visible = value_4_30
                local trade_info_value_2 = captured_value_52.Container.TradeInfo
                trade_info_value_2.Visible = value_4_30
                local minimum_trade_level_value_2 = captured_value_52.Container.MinimumTradeLevel
                local value_6_17: boolean = not value_4_30
                minimum_trade_level_value_2.Visible = value_6_17
                if not value_4_30 then
                    local value_5_32 = captured_value_53
                    local value_6_18: boolean = false
                    value_5_32.RequestsEnabled = value_6_18
                end
            end

            return
        end
        closure_ready_13 = true
        if closure_cache[16] == nil then
            closure_cache[16] = value_27
            closure_cache[17], closure_cache[18], closure_cache[19], closure_cache[20] = captured_value_50, captured_value_51, captured_value_52, captured_value_53
        end
    end
end
value_25:Connect(value_27)
do
    local captured_value_54 = leaderboard_value
    if closure_cache[21] ~= nil and same_capture(closure_cache[22], captured_value_54) then
        value_25 = closure_cache[21]
    else
        local closure_ready_14
        value_25 = function(): ()
            if not closure_ready_14 then
                return
            end
            local workspace_value: Workspace = workspace
            local value_3_32: string = "ServerRestarting"
            if (workspace_value:GetAttribute(value_3_32)) then
                local title_value_3 = captured_value_54.Container.TradeInfo.Title
                local value_2_28: string = "\226\154\160\239\184\143 Trading Unavailable"
                title_value_3.Text = value_2_28
            end

            return
        end
        closure_ready_14 = true
        if closure_cache[21] == nil then
            closure_cache[21] = value_25
            closure_cache[22] = captured_value_54
        end
    end
end
value_26 = workspace
local value_28_3: string = "ServerRestarting"
value_26 = value_26:GetAttributeChangedSignal(value_28_3)
local value_28_4 = value_25
value_26:Connect(value_28_4)
value_26 = workspace
local value_28_5: string = "ServerRestarting"
value_26 = value_26:GetAttribute(value_28_5)
if value_26 then
    value_26 = leaderboard_value.Container.TradeInfo.Title
    value_27 = "\226\154\160\239\184\143 Trading Unavailable"
    value_26.Text = value_27
end
value_26 = game.ReplicatedStorage.Remotes.Extras.Admin.OnClientEvent
local value_28_6
do
    local captured_value_55, captured_value_56, captured_value_57 = require_result_5, view_profile_value, require_result_2
    if closure_cache[23] ~= nil and same_capture(closure_cache[24], captured_value_55) and same_capture(
        closure_cache[25],
        captured_value_56
    ) and same_capture(closure_cache[26], captured_value_57) then
        value_28_6 = closure_cache[23]
    else
        local closure_ready_15
        value_28_6 = function(argument_1_5, argument_2_4): ()
            if not closure_ready_15 then
                return
            end
            if argument_1_5 == "CheckInventory" then
                captured_value_55.DisplayInventoryFromData(
                    captured_value_56,
                    "Player",
                    argument_2_4
                )
                local value_3_34 = captured_value_57
                local value_5_34: string = "ViewProfile"
                value_3_34:ViewFrame(value_5_34)
            end

            return
        end
        closure_ready_15 = true
        if closure_cache[23] == nil then
            closure_cache[23] = value_28_6
            closure_cache[24], closure_cache[25], closure_cache[26] = captured_value_55, captured_value_56, captured_value_57
        end
    end
end
value_26:Connect(value_28_6)
value_25 = game
value_27 = "TeleportService"
value_25 = value_25:GetService(value_27)
value_25 = leaderboard_value.Container.FriendsOnline
value_26 = game_value.FriendsOnline
local container_value_3 = value_26.Main.ScrollFrame.Container
value_27 = game
local value_29: string = "SocialService"
value_27 = value_27:GetService(value_29)
local game_value_13: DataModel = game
local value_30: string = "Players"
local players_service: Instance = game_value_13:GetService(value_30)
local local_player_value = players_service.LocalPlayer
local mouse_button1_click_value = value_26.Title.Close.MouseButton1Click
local value_32
do
    local captured_value_58 = value_26
    if closure_cache[27] ~= nil and same_capture(closure_cache[28], captured_value_58) then
        value_32 = closure_cache[27]
    else
        local closure_ready_16
        value_32 = function(): ()
            if not closure_ready_16 then
                return
            end
            local value_1_14 = captured_value_58
            local value_2_29: boolean = false
            value_1_14.Visible = value_2_29

            return
        end
        closure_ready_16 = true
        if closure_cache[27] == nil then
            closure_cache[27] = value_32
            closure_cache[28] = captured_value_58
        end
    end
end
mouse_button1_click_value:connect(value_32)
local mouse_button1_click_value_2 = value_26.Retry.Back.MouseButton1Click
local value_32_2
do
    local captured_value_59 = value_26
    if closure_cache[29] ~= nil and same_capture(closure_cache[30], captured_value_59) then
        value_32_2 = closure_cache[29]
    else
        local closure_ready_17
        value_32_2 = function(): ()
            if not closure_ready_17 then
                return
            end
            local retry_value_2 = captured_value_59.Retry
            local value_2_30: boolean = false
            retry_value_2.Visible = value_2_30
            local main_value_4 = captured_value_59.Main
            local value_2_31: boolean = true
            main_value_4.Visible = value_2_31

            return
        end
        closure_ready_17 = true
        if closure_cache[29] == nil then
            closure_cache[29] = value_32_2
            closure_cache[30] = captured_value_59
        end
    end
end
mouse_button1_click_value_2:connect(value_32_2)
do
    local captured_value_60 = value_27
    local can_send_game_invite
    if closure_cache[31] ~= nil and same_capture(closure_cache[32], captured_value_60) then
        can_send_game_invite = closure_cache[31]
    else
        local closure_ready_19
        can_send_game_invite = function(argument_1_6, argument_2_5)
            if not closure_ready_19 then
                return
            end
            local value_4_33
            do
                local captured_value_61, captured_value_62, captured_value_63, closure_ready_18
                value_4_33 = function()
                    if not closure_ready_18 then
                        return
                    end
                    local value_1_17: Instance? = captured_value_61
                    local value_3_36 = captured_value_62
                    local value_4_35 = captured_value_63

                    return value_1_17:CanSendGameInviteAsync(value_3_36, value_4_35)
                end
                captured_value_61, captured_value_62, captured_value_63 = captured_value_60, argument_1_6, argument_2_5
                closure_ready_18 = true
            end
            local pcall_result, value_4_34 = pcall(value_4_33)

            return pcall_result, value_4_34
        end
        closure_ready_19 = true
        if closure_cache[31] == nil then
            closure_cache[31] = can_send_game_invite
            closure_cache[32] = captured_value_60
        end
    end
end
do
    local captured_value_64, captured_value_65 = local_player_value, value_27
    local open_invites
    if closure_cache[36] ~= nil and same_capture(closure_cache[37], captured_value_64) and same_capture(
        closure_cache[38],
        captured_value_65
    ) then
        open_invites = closure_cache[36]
    else
        local closure_ready_22
        open_invites = function()
            if not closure_ready_22 then
                return
            end
            local value_2_33 = captured_value_64
            local value_5_35: nil = nil
            local value_4_36
            do
                local captured_value_66, captured_value_67, captured_value_68, closure_ready_20
                value_4_36 = function()
                    if not closure_ready_20 then
                        return
                    end
                    local value_1_20: Instance? = captured_value_66
                    local value_3_39 = captured_value_67
                    local value_4_38: nil = captured_value_68

                    return value_1_20:CanSendGameInviteAsync(value_3_39, value_4_38)
                end
                captured_value_66, captured_value_67, captured_value_68 = captured_value_65, value_2_33, value_5_35
                closure_ready_20 = true
            end
            local pcall_result_2, value_4_37 = pcall(value_4_36)
            if pcall_result_2 then
                local value_3_37
                do
                    local captured_value_69, captured_value_70 = captured_value_65, captured_value_64
                    if closure_cache[33] ~= nil and same_capture(
                        closure_cache[34],
                        captured_value_69
                    ) and same_capture(closure_cache[35], captured_value_70) then
                        value_3_37 = closure_cache[33]
                    else
                        local closure_ready_21
                        value_3_37 = function(): ()
                            if not closure_ready_21 then
                                return
                            end
                            local value_1_22: Instance = captured_value_69
                            local value_3_40 = captured_value_70
                            value_1_22:PromptGameInvite(value_3_40)

                            return
                        end
                        closure_ready_21 = true
                        if closure_cache[33] == nil then
                            closure_cache[33] = value_3_37
                            closure_cache[34], closure_cache[35] = captured_value_69, captured_value_70
                        end
                    end
                end
                local pcall_result_3, value_3_38 = pcall(value_3_37)
            end

            return
        end
        closure_ready_22 = true
        if closure_cache[36] == nil then
            closure_cache[36] = open_invites
            closure_cache[37], closure_cache[38] = captured_value_64, captured_value_65
        end
    end
end
local invite_player
do
    local captured_value_71, captured_value_72 = local_player_value, value_27
    if closure_cache[39] ~= nil and same_capture(closure_cache[40], captured_value_71) and same_capture(
        closure_cache[41],
        captured_value_72
    ) then
        invite_player = closure_cache[39]
    else
        local closure_ready_25
        invite_player = function(argument_1_7)
            if not closure_ready_25 then
                return
            end
            local invite_user_value, pcall_result_4, pcall_result_5, pcall_value_4, pcall_value_5, value_2_36, value_3_41, value_4_39, value_5_36, value_5_37, value_5_38, value_6_20, value_7_10, value_7_11, value_7_9, warn_value, warn_value_2
            local control_state = 0
            while true do
                if control_state < 2 then
                    if control_state < 1 then
                        value_4_39 = captured_value_71
                        invite_user_value = argument_1_7.InviteUser
                        do
                            local captured_value_73, captured_value_74, captured_value_75, closure_ready_23
                            value_7_9 = function()
                                if not closure_ready_23 then
                                    return
                                end
                                local value_1_24 = captured_value_73
                                local value_3_42 = captured_value_74
                                local value_4_40 = captured_value_75

                                return value_1_24:CanSendGameInviteAsync(value_3_42, value_4_40)
                            end
                            captured_value_73, captured_value_74, captured_value_75 = captured_value_72, value_4_39, invite_user_value
                            closure_ready_23 = true
                        end
                        pcall_value_4 = pcall
                        pcall_result_4, value_7_10 = pcall_value_4(value_7_9)
                        value_2_36 = pcall_result_4
                        value_3_41 = value_7_10
                        control_state = if not value_2_36 then 3 else 1
                    else
                        do
                            local captured_value_76, captured_value_77, captured_value_78, closure_ready_24
                            value_5_36 = function(): ()
                                if not closure_ready_24 then
                                    return
                                end
                                local value_1_26: Instance? = captured_value_76
                                local value_3_43 = captured_value_77
                                local value_4_41 = captured_value_78
                                value_1_26:PromptGameInvite(value_3_43, value_4_41)

                                return
                            end
                            captured_value_76, captured_value_77, captured_value_78 = captured_value_72, captured_value_71, argument_1_7
                            closure_ready_24 = true
                        end
                        pcall_value_5 = pcall
                        pcall_result_5, value_5_37 = pcall_value_5(value_5_36)
                        control_state = if pcall_result_5 then 4 else 2
                    end
                else
                    if control_state < 3 then
                        warn_value = warn
                        value_7_11 = value_5_37
                        warn_value(value_7_11)

                        return
                    else
                        if control_state < 4 then
                            warn_value_2 = warn
                            value_5_38 = value_2_36
                            value_6_20 = value_3_41
                            warn_value_2(value_5_38, value_6_20)
                            control_state = 4
                        else
                            return
                        end
                    end
                end
            end
        end
        closure_ready_25 = true
        if closure_cache[39] == nil then
            closure_cache[39] = invite_player
            closure_cache[40], closure_cache[41] = captured_value_71, captured_value_72
        end
    end
end
local title_value_2 = value_26.Title
title_value_2 = title_value_2.Invite
title_value_2 = title_value_2.Activated
local value_35
do
    local captured_value_79, captured_value_80 = local_player_value, value_27
    if closure_cache[45] ~= nil and same_capture(closure_cache[46], captured_value_79) and same_capture(
        closure_cache[47],
        captured_value_80
    ) then
        value_35 = closure_cache[45]
    else
        local closure_ready_28
        value_35 = function()
            if not closure_ready_28 then
                return
            end
            local value_2_39 = captured_value_79
            local value_5_39: nil = nil
            local value_4_42
            do
                local captured_value_81, captured_value_82, captured_value_83, closure_ready_26
                value_4_42 = function()
                    if not closure_ready_26 then
                        return
                    end
                    local value_1_29: Instance? = captured_value_81
                    local value_3_46 = captured_value_82
                    local value_4_44: nil = captured_value_83

                    return value_1_29:CanSendGameInviteAsync(value_3_46, value_4_44)
                end
                captured_value_81, captured_value_82, captured_value_83 = captured_value_80, value_2_39, value_5_39
                closure_ready_26 = true
            end
            local pcall_result_6, value_4_43 = pcall(value_4_42)
            if pcall_result_6 then
                local value_3_44
                do
                    local captured_value_84, captured_value_85 = captured_value_80, captured_value_79
                    if closure_cache[42] ~= nil and same_capture(
                        closure_cache[43],
                        captured_value_84
                    ) and same_capture(closure_cache[44], captured_value_85) then
                        value_3_44 = closure_cache[42]
                    else
                        local closure_ready_27
                        value_3_44 = function(): ()
                            if not closure_ready_27 then
                                return
                            end
                            local value_1_31: Instance = captured_value_84
                            local value_3_47 = captured_value_85
                            value_1_31:PromptGameInvite(value_3_47)

                            return
                        end
                        closure_ready_27 = true
                        if closure_cache[42] == nil then
                            closure_cache[42] = value_3_44
                            closure_cache[43], closure_cache[44] = captured_value_84, captured_value_85
                        end
                    end
                end
                local pcall_result_7, value_3_45 = pcall(value_3_44)
            end

            return
        end
        closure_ready_28 = true
        if closure_cache[45] == nil then
            closure_cache[45] = value_35
            closure_cache[46], closure_cache[47] = captured_value_79, captured_value_80
        end
    end
end
title_value_2:Connect(value_35)
title_value_2 = value_26.Title
title_value_2 = title_value_2.Modes
title_value_2 = title_value_2.Activated
do
    local captured_value_86 = require_result_2
    if closure_cache[48] ~= nil and same_capture(closure_cache[49], captured_value_86) then
        value_35 = closure_cache[48]
    else
        local closure_ready_29
        value_35 = function(): ()
            if not closure_ready_29 then
                return
            end
            local value_1_33 = captured_value_86
            local value_3_48: string = "ModeBrowser"
            value_1_33:ToggleFrame(value_3_48)

            return
        end
        closure_ready_29 = true
        if closure_cache[48] == nil then
            closure_cache[48] = value_35
            closure_cache[49] = captured_value_86
        end
    end
end
title_value_2:Connect(value_35)
title_value_2 = 0
local activated_value = value_25.Join.Activated
local value_36
do
    local captured_value_87, captured_value_88, captured_value_89, closure_ready_32
    value_36 = function()
        if not closure_ready_32 then
            return
        end
        if 0 < title_value_2 then
            local value_1_36 = captured_value_87
            local value_3_49: string = "FriendsOnline"
            value_1_36:ToggleFrame(value_3_49)

            return
        end
        local value_2_45 = captured_value_88
        local value_5_40: nil = nil
        local value_4_45
        do
            local captured_value_90, captured_value_91, captured_value_92, closure_ready_30
            value_4_45 = function()
                if not closure_ready_30 then
                    return
                end
                local value_1_39: Instance? = captured_value_90
                local value_3_52 = captured_value_91
                local value_4_47: nil = captured_value_92

                return value_1_39:CanSendGameInviteAsync(value_3_52, value_4_47)
            end
            captured_value_90, captured_value_91, captured_value_92 = captured_value_89, value_2_45, value_5_40
            closure_ready_30 = true
        end
        local pcall_result_8, value_4_46 = pcall(value_4_45)
        if pcall_result_8 then
            local value_3_50
            do
                local captured_value_93, captured_value_94 = captured_value_89, captured_value_88
                if closure_cache[50] ~= nil and same_capture(
                    closure_cache[51],
                    captured_value_93
                ) and same_capture(closure_cache[52], captured_value_94) then
                    value_3_50 = closure_cache[50]
                else
                    local closure_ready_31
                    value_3_50 = function(): ()
                        if not closure_ready_31 then
                            return
                        end
                        local value_1_41: Instance? = captured_value_93
                        local value_3_53 = captured_value_94
                        value_1_41:PromptGameInvite(value_3_53)

                        return
                    end
                    closure_ready_31 = true
                    if closure_cache[50] == nil then
                        closure_cache[50] = value_3_50
                        closure_cache[51], closure_cache[52] = captured_value_93, captured_value_94
                    end
                end
            end
            local pcall_result_9, value_3_51 = pcall(value_3_50)
        end

        return
    end
    captured_value_87, captured_value_88, captured_value_89 = require_result_2, local_player_value, value_27
    closure_ready_32 = true
end
activated_value:connect(value_36)
local value_36_2 = value_26
local value_37: string = "FriendsOnline"
require_result_2:RegisterFrame(value_36_2, value_37)
local require_value_9 = require
value_35 = game
value_35 = value_35.ReplicatedStorage
value_35 = value_35.Modules
value_35 = value_35.FriendsModule
local require_result_9 = require_value_9(value_35)
value_35 = value_26.Retry
value_35 = value_35.Back
value_35 = value_35.MouseButton1Click
local value_37_2
do
    local captured_value_95 = require_result_9
    if closure_cache[53] ~= nil and same_capture(closure_cache[54], captured_value_95) then
        value_37_2 = closure_cache[53]
    else
        local closure_ready_33
        value_37_2 = function(): ()
            if not closure_ready_33 then
                return
            end
            captured_value_95:CancelJoin()

            return
        end
        closure_ready_33 = true
        if closure_cache[53] == nil then
            closure_cache[53] = value_37_2
            closure_cache[54] = captured_value_95
        end
    end
end
value_35:connect(value_37_2)
value_35 = {}

local function set_friend_in_server(argument_1_8, argument_2_6): ()
    local join_value_2 = argument_1_8.Join
    local value_4_48: boolean = not argument_2_6
    join_value_2.Visible = value_4_48
    local invite_value = argument_1_8.Invite
    local value_4_49: boolean = not argument_2_6
    invite_value.Visible = value_4_49
    local is_in_server_value = argument_1_8.IsInServer
    is_in_server_value.Visible = argument_2_6

    return
end

local update_friends
do
    local captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, closure_ready_39
    update_friends = function()
        if not closure_ready_39 then
            return
        end
        local get_friends_online_result = captured_value_96:GetFriendsOnline()
        captured_value_97:ClearAllChildren()
        value_35 = {}
        title_value_2 = 0
        local value_2_49, value_3_54, value_4_50 = pairs(get_friends_online_result)
        for key_7, value_47 in value_2_49, value_3_54, value_4_50 do
            local value_5_41, value_6_21 = key_7, value_47
            local script_value_5: LuaSourceContainer = script
            local friend_value = script_value_5.Friend
            local cloned_value_2 = friend_value:Clone()
            local user_name_value = value_6_21.UserName
            local player_name_value_2 = cloned_value_2.PlayerName
            player_name_value_2.Text = user_name_value
            local game_mode_value = cloned_value_2.GameMode
            local other_server_value = value_6_21.OtherServer
            if not other_server_value then
                local place_id_value = value_6_21.PlaceId
                if place_id_value == 335132309 then
                    other_server_value = "Disguises"
                else
                    local place_id_value_2 = value_6_21.PlaceId
                    if place_id_value_2 == 636649648 then
                        other_server_value = "Assassin"
                    else
                        other_server_value = ""
                    end
                end
            end
            game_mode_value.Text = other_server_value
            local new_value_9: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
            local value_10_12: number = 0
            local value_11_8: number = 0
            local value_12_9: number = 0
            local size_value_10 = cloned_value_2.Size
            local y_value_10 = size_value_10.Y
            local offset_value_7 = y_value_10.Offset
            local value_15_6: number = title_value_2
            local value_13_8 = offset_value_7 * value_15_6
            local new_result_7 = new_value_9(value_10_12, value_11_8, value_12_9, value_13_8)
            cloned_value_2.Position = new_result_7
            local value_9_9 = captured_value_97
            cloned_value_2.Parent = value_9_9
            local game_value_20: DataModel = game
            local players_value_8 = game_value_20.Players
            local value_12_10 = user_name_value
            local find_first_child_result_4 = players_value_8:FindFirstChild(value_12_10)
            local value_9_10: boolean?
            if find_first_child_result_4 == nil then
                value_9_10 = false
            else
                value_9_10 = true
            end
            local join_value_3 = cloned_value_2.Join
            local value_11_10: boolean = not value_9_10
            join_value_3.Visible = value_11_10
            local invite_value_2 = cloned_value_2.Invite
            local value_11_11: boolean = not value_9_10
            invite_value_2.Visible = value_11_11
            local is_in_server_value_2 = cloned_value_2.IsInServer
            is_in_server_value_2.Visible = value_9_10
            local value_9_11 = value_35
            local visitor_id_value = value_6_21.VisitorId
            value_9_11[visitor_id_value] = cloned_value_2
            local invite_value_3 = cloned_value_2.Invite
            local activated_value_3 = invite_value_3.Activated
            local value_11_12: (() -> ())?
            do
                local captured_value_101, captured_value_102, closure_ready_34
                value_11_12 = function(): ()
                    if not closure_ready_34 then
                        return
                    end
                    local new_result_8: ExperienceInviteOptions = Instance.new(
                        "ExperienceInviteOptions"
                    )
                    local visitor_id_value_2 = captured_value_101.VisitorId
                    new_result_8.InviteUser = visitor_id_value_2
                    captured_value_102(new_result_8)

                    return
                end
                captured_value_101, captured_value_102 = value_6_21, captured_value_98
                closure_ready_34 = true
            end
            activated_value_3:Connect(value_11_12)
            local join_value_4 = cloned_value_2.Join
            local activated_value_4 = join_value_4.Activated
            local value_11_13
            do
                local captured_value_103, captured_value_104, captured_value_105, closure_ready_38
                value_11_13 = function()
                    if not closure_ready_38 then
                        return
                    end
                    local main_value_5 = captured_value_103.Main
                    local value_2_53: boolean = false
                    main_value_5.Visible = value_2_53
                    local teleporting_value = captured_value_103.Teleporting
                    local value_2_54: boolean = true
                    teleporting_value.Visible = value_2_54
                    local value_1_49 = captured_value_104
                    local value_3_56 = captured_value_105
                    local value_4_51
                    do
                        local captured_value_106 = captured_value_103
                        if closure_cache[57] ~= nil and same_capture(
                            closure_cache[58],
                            captured_value_106
                        ) then
                            value_4_51 = closure_cache[57]
                        else
                            local closure_ready_36
                            value_4_51 = function(argument_1_9)
                                if not closure_ready_36 then
                                    return
                                end
                                local teleporting_value_2 = captured_value_106.Teleporting
                                local value_3_57: boolean = false
                                teleporting_value_2.Visible = value_3_57
                                local spinner_value = captured_value_106.Retry.Spinner
                                local value_3_58: boolean = true
                                spinner_value.Visible = value_3_58
                                local retrying_value = captured_value_106.Retry.Retrying
                                local value_3_59: boolean = true
                                retrying_value.Visible = value_3_59
                                local retrying_value_2 = captured_value_106.Retry.Retrying
                                local value_3_60 = "Retrying... (" .. argument_1_9 .. ")"
                                retrying_value_2.Text = value_3_60
                                local retry_value_6 = captured_value_106.Retry
                                local value_3_61: boolean = true
                                retry_value_6.Visible = value_3_61
                                if argument_1_9 == 1 then
                                    local spawn_value = spawn
                                    local value_3_62
                                    do
                                        local captured_value_107 = captured_value_106
                                        if closure_cache[55] ~= nil and same_capture(
                                            closure_cache[56],
                                            captured_value_107
                                        ) then
                                            value_3_62 = closure_cache[55]
                                        else
                                            local closure_ready_35
                                            value_3_62 = function(): ()
                                                if not closure_ready_35 then
                                                    return
                                                end
                                                while true do
                                                    local value_1_51 = captured_value_107
                                                    local retry_value_7 = value_1_51.Retry
                                                    local visible_value_2 = retry_value_7.Visible
                                                    if visible_value_2 ~= true then
                                                        break
                                                    end
                                                    local value_1_52 = captured_value_107
                                                    local retry_value_8 = value_1_52.Retry
                                                    local spinner_value_2 = retry_value_8.Spinner
                                                    local value_3_63 = captured_value_107
                                                    local retry_value_9 = value_3_63.Retry
                                                    local spinner_value_3 = retry_value_9.Spinner
                                                    local rotation_value = spinner_value_3.Rotation
                                                    local value_2_61 = rotation_value + 5
                                                    spinner_value_2.Rotation = value_2_61
                                                    local game_value_21: DataModel = game
                                                    local value_3_64: string = "RunService"
                                                    local run_service: Instance = game_value_21:GetService(
                                                        value_3_64
                                                    )
                                                    local render_stepped_value = run_service.RenderStepped
                                                    render_stepped_value:wait()
                                                end

                                                return
                                            end
                                            closure_ready_35 = true
                                            if closure_cache[55] == nil then
                                                closure_cache[55] = value_3_62
                                                closure_cache[56] = captured_value_107
                                            end
                                        end
                                    end
                                    spawn_value(value_3_62)
                                end

                                return
                            end
                            closure_ready_36 = true
                            if closure_cache[57] == nil then
                                closure_cache[57] = value_4_51
                                closure_cache[58] = captured_value_106
                            end
                        end
                    end
                    local value_5_42
                    do
                        local captured_value_108 = captured_value_103
                        if closure_cache[59] ~= nil and same_capture(
                            closure_cache[60],
                            captured_value_108
                        ) then
                            value_5_42 = closure_cache[59]
                        else
                            local closure_ready_37
                            value_5_42 = function(): ()
                                if not closure_ready_37 then
                                    return
                                end
                                local teleporting_value_3 = captured_value_108.Teleporting
                                local value_2_64: boolean = false
                                teleporting_value_3.Visible = value_2_64
                                local spinner_value_4 = captured_value_108.Retry.Spinner
                                local value_2_65: boolean = false
                                spinner_value_4.Visible = value_2_65
                                local retrying_value_3 = captured_value_108.Retry.Retrying
                                local value_2_66: boolean = false
                                retrying_value_3.Visible = value_2_66
                                local retry_value_12 = captured_value_108.Retry
                                local value_2_67: boolean = true
                                retry_value_12.Visible = value_2_67

                                return
                            end
                            closure_ready_37 = true
                            if closure_cache[59] == nil then
                                closure_cache[59] = value_5_42
                                closure_cache[60] = captured_value_108
                            end
                        end
                    end
                    value_1_49:JoinFriend(value_3_56, value_4_51, value_5_42)

                    return
                end
                captured_value_103, captured_value_104, captured_value_105 = captured_value_99, captured_value_96, value_6_21
                closure_ready_38 = true
            end
            activated_value_4:connect(value_11_13)
            local value_10_16: number = title_value_2
            local value_9_14: number = value_10_16 + 1
            title_value_2 = value_9_14
        end
        value_2_49 = captured_value_100.Title
        value_3_54 = "Friends Playing: " .. title_value_2
        value_2_49.Text = value_3_54
        value_2_49 = captured_value_100.Join
        value_3_54 = true
        value_2_49.Visible = value_3_54

        return
    end
    captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100 = require_result_9, container_value_3, invite_player, value_26, value_25
    closure_ready_39 = true
end
update_friends()
local value_38 = require_result_9.Updated
local value_40 = update_friends
value_38:Connect(value_40)
value_38 = players_service.PlayerAdded
do
    local closure_ready_40
    value_40 = function(argument_1_10)
        if not closure_ready_40 then
            return
        end
        local value_2_68 = value_35[argument_1_10.UserId]
        if value_2_68 then
            local join_value_5 = value_2_68.Join
            local value_4_53: boolean = false
            join_value_5.Visible = value_4_53
            local invite_value_4 = value_2_68.Invite
            local value_4_54: boolean = false
            invite_value_4.Visible = value_4_54
            local is_in_server_value_3 = value_2_68.IsInServer
            local value_4_55: boolean = true
            is_in_server_value_3.Visible = value_4_55
        end

        return
    end
    closure_ready_40 = true
end
value_38:Connect(value_40)
value_38 = players_service.PlayerRemoving
do
    local closure_ready_41
    value_40 = function(argument_1_11)
        if not closure_ready_41 then
            return
        end
        local value_2_69 = value_35[argument_1_11.UserId]
        if value_2_69 then
            local join_value_6 = value_2_69.Join
            local value_4_56: boolean = true
            join_value_6.Visible = value_4_56
            local invite_value_5 = value_2_69.Invite
            local value_4_57: boolean = true
            invite_value_5.Visible = value_4_57
            local is_in_server_value_4 = value_2_69.IsInServer
            local value_4_58: boolean = false
            is_in_server_value_4.Visible = value_4_58
        end

        return
    end
    closure_ready_41 = true
end
value_38:Connect(value_40)
local player_gui_value = local_player_value.PlayerGui
local check_for_esp
do
    local captured_value_109 = local_player_value
    if closure_cache[61] ~= nil and same_capture(closure_cache[62], captured_value_109) then
        check_for_esp = closure_cache[61]
    else
        local closure_ready_42
        check_for_esp = function(argument_1_12): ()
            if not closure_ready_42 then
                return
            end
            if argument_1_12.Name == "ESP" then
                local value_2_70 = captured_value_109
                local value_4_59: string = "You have been banned from MM2."
                value_2_70:Kick(value_4_59)
            end

            return
        end
        closure_ready_42 = true
        if closure_cache[61] == nil then
            closure_cache[61] = check_for_esp
            closure_cache[62] = captured_value_109
        end
    end
end
local value_39
value_38, value_39, value_40 = player_gui_value:GetChildren()
for key_8, value_48 in value_38, value_39, value_40 do
    local value_41, value_42 = key_8, value_48
    local name_value = value_42.Name
    if name_value ~= "ESP" then
        continue
    end
    local value_45: string = "You have been banned from MM2."
    local_player_value:Kick(value_45)
end
value_38 = player_gui_value.ChildAdded
value_40 = check_for_esp
value_38:Connect(value_40)

return
