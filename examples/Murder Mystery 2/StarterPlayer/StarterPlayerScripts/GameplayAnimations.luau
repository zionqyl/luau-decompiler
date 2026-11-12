--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_3)
local g_value = _G
local value_3_2: number = -1
g_value.LastRound = value_3_2
local g_value_2 = _G
local table_3 = {}
g_value_2.PlayerIcons = table_3

local function update_icons(): ()
    local pairs_value, game_value_10, value_3_7 = pairs(game.Players:GetPlayers())
    for key, value in pairs_value, game_value_10, value_3_7 do
        local value_4_4, value_5_3 = key, value
        local g_value_4 = _G
        local player_icons_value = g_value_4.PlayerIcons
        local name_value = value_5_3.Name
        local value_6_2 = player_icons_value[name_value]
        if value_6_2 ~= nil then
            continue
        end
        local spawn_value = spawn
        local value_7_3: (() -> ())?
        do
            local captured_value, closure_ready
            value_7_3 = function(): ()
                if not closure_ready then
                    return
                end
                local player_icons_value_2 = _G.PlayerIcons
                local name_value_2 = captured_value.Name
                local players_value_3 = game.Players
                local user_id_value = captured_value.userId
                local abs_result = math.abs(user_id_value)
                local avatar_bust_value = Enum.ThumbnailType.AvatarBust
                local size352x352_value = Enum.ThumbnailSize.Size352x352
                local get_user_thumbnail_async_result = players_value_3:GetUserThumbnailAsync(
                    abs_result,
                    avatar_bust_value,
                    size352x352_value
                )
                player_icons_value_2[name_value_2] = get_user_thumbnail_async_result

                return
            end
            captured_value = value_5_3
            closure_ready = true
        end
        spawn_value(value_7_3)
    end

    return
end

update_icons()
local player_added_value = game.Players.PlayerAdded
local value_5: () -> () = update_icons
player_added_value:connect(value_5)
local player_removing_value = game.Players.PlayerRemoving
local value_5_2: () -> () = update_icons
player_removing_value:connect(value_5_2)
local new_result: TweenInfo = TweenInfo.new(
    0.3,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)
local new_result_2: TweenInfo = TweenInfo.new(
    0.3,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.In,
    0,
    false,
    0
)
local require_result = require(game.ReplicatedStorage.Modules.FadeModule)

local function play_tweens(argument_1): ()
    local pairs_value_2, value_3_9, value_4_6 = pairs(argument_1)
    for key_2, value_13 in pairs_value_2, value_3_9, value_4_6 do
        local value_5_4, value_6_4 = key_2, value_13
        value_6_4:Play()
    end

    return
end

local play_victory_screen
do
    local captured_value_2, captured_value_3 = tween_service, new_result
    play_victory_screen = function(argument_1_2): ()
        local cloned_value = script.Victory:Clone()
        local value_5_5 = argument_1_2 .. "Victory"
        local find_first_child_result = cloned_value:FindFirstChild(value_5_5)
        if not find_first_child_result then
            value_5_5 = argument_1_2
            find_first_child_result = (cloned_value:FindFirstChild(value_5_5)) or cloned_value.MurdererVictory
        end
        local value_4_9: boolean = true
        find_first_child_result.Visible = value_4_9
        local player_gui_value = game.Players.LocalPlayer.PlayerGui
        cloned_value.Parent = player_gui_value
        task.wait(0.05)
        local table_4 = {nil, nil, nil}
        value_5_5 = captured_value_2
        local value_7_5 = find_first_child_result.Container
        local value_8_5 = captured_value_3
        local table_9 = {[("Size")] = nil}
        local new_result_3 = UDim2.new(1, 0, 1, 0)
        table_9.Size = new_result_3
        value_5_5 = value_5_5:Create(value_7_5, value_8_5, table_9)
        local value_6_5 = captured_value_2
        value_8_5 = find_first_child_result.KnifeRight
        table_9 = captured_value_3
        local table_10 = {[("Position")] = nil, [("Position")] = nil}
        local new_result_4 = UDim2.new(0.975, 0, 0.5, 0)
        table_10.Position = new_result_4
        local value_11_4: number = 0
        table_10.Rotation = value_11_4
        value_6_5 = value_6_5:Create(value_8_5, table_9, table_10)
        value_7_5 = captured_value_2
        table_9 = find_first_child_result.KnifeLeft
        local value_10_3: TweenInfo = captured_value_3
        local table_11 = {[("Position")] = nil, [("Position")] = nil}
        local new_result_5 = UDim2.new(0.025, 0, 0.5, 0)
        table_11.Position = new_result_5
        local value_12_6: number = 0
        table_11.Rotation = value_12_6
        table_4 = {value_5_5, value_6_5, value_7_5:Create(table_9, value_10_3, table_11)}
        value_5_5, value_6_5, value_7_5 = pairs(table_4)
        for key_3, value_17 in value_5_5, value_6_5, value_7_5 do
            value_8_5, table_9 = key_3, value_17
            table_9:Play()
        end
        task.wait(8)
        local table_4_2 = {nil}
        value_5_5 = captured_value_2
        value_7_5 = find_first_child_result
        value_8_5 = captured_value_3
        table_9 = {[("Position")] = nil}
        local new_result_6 = UDim2.new(
            0.5,
            0,
            0,
            -(find_first_child_result.Container.AbsoluteSize.Y * 2) - 10
        )
        table_9.Position = new_result_6
        table_4_2 = {value_5_5:Create(value_7_5, value_8_5, table_9)}
        value_5_5, value_6_5, value_7_5 = pairs(table_4_2)
        for key_4, value_18 in value_5_5, value_6_5, value_7_5 do
            value_8_5, table_9 = key_4, value_18
            table_9:Play()
        end
        task.wait(captured_value_3.Time)
        cloned_value:Destroy()

        return
    end
end
local table_7 = {
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
    [("Innocent")] = nil,
}
local table_8 = {
    Time = true,
    MurdererDied = true,
    MurdererLeft = true,
    InnocentsEscaped = true,
}
table_7.Innocent = table_8
local table_8_2 = {Time = true, MurdererDied = true, MurdererLeft = true}
table_7.Hero = table_8_2
local table_8_3 = {MurdererDied = true, MurdererLeft = true, SheriffWin = true}
table_7.Sheriff = table_8_3
local table_8_4 = {MurdererWin = true}
table_7.Murderer = table_8_4
local table_8_5 = {PlayerWon = true}
table_7.Assassin = table_8_5
local table_8_6 = {ZombiesWin = true}
table_7.Zombie = table_8_6
local table_8_7 = {SurvivorsWin = true, Time = true}
table_7.Survivor = table_8_7
local table_8_8 = {FreezersWin = true}
table_7.Freezer = table_8_8
local table_8_9 = {RunnersWin = true, Time = true}
table_7.Runner = table_8_9
local table_8_10 = {Team1Victory = true}
table_7.Team1 = table_8_10
local table_8_11 = {Team2Victory = true}
table_7.Team2 = table_8_11
local table_8_12 = {VampireWin = true}
table_7.Vampire = table_8_12
local table_8_13 = {Time = true, InnocentWin = true}
table_7.Hunter = table_8_13
local table_8_14 = {Time = true, InnocentWin = true}
table_7.Villager = table_8_14
do
    local captured_value_4, captured_value_5 = tween_service, new_result_2

    local function play_fade(): ()
        local cloned_value_2 = script.DeathFade:Clone()
        local fade_value = cloned_value_2.Fade
        local player_gui_value_2 = game.Players.LocalPlayer.PlayerGui
        cloned_value_2.Parent = player_gui_value_2
        local starter_gui_value = game.StarterGui
        local backpack_value = Enum.CoreGuiType.Backpack
        local value_6_6 = false
        starter_gui_value:SetCoreGuiEnabled(backpack_value, value_6_6)
        local table_3_2 = {nil}
        local value_4_11 = captured_value_4
        value_6_6 = fade_value
        local value_7_6 = captured_value_5
        local table_8_15 = {[("BackgroundTransparency")] = nil}
        local value_9_2: number = 0
        table_8_15.BackgroundTransparency = value_9_2
        table_3_2 = {value_4_11:Create(value_6_6, value_7_6, table_8_15)}
        value_4_11, backpack_value, value_6_6 = pairs(table_3_2)
        for key_5, value_19 in value_4_11, backpack_value, value_6_6 do
            value_7_6, table_8_15 = key_5, value_19
            table_8_15:Play()
        end

        return
    end
end
local value_8_3: boolean = true
if game.PlaceId ~= 5895823254 then
    if game.PlaceId ~= 5928494131 then
        value_8_3 = false
    else
        value_8_3 = true
    end
end
local play_end_music
do
    local captured_value_6 = value_8_3
    play_end_music = function(argument_1_3, argument_2): ()
        if argument_1_3 ~= nil then
            if argument_1_3.Character ~= nil then
                local character_value_2 = argument_1_3.Character
                local value_5_6: string = "Radio"
                if (character_value_2:FindFirstChild(value_5_6)) then
                    local radio_value = argument_1_3.Character.Radio
                    local value_5_7: string = "Sound"
                    if (radio_value:FindFirstChild(value_5_7)) then
                        if argument_1_3.Character.Radio.Sound.IsPlaying == true then
                            return
                        end
                    end
                end
            end
        end
        local table_3_3 = {
            nil,
            nil,
            nil,
            nil,
        }
        local value_4_14: string = "rbxassetid://13934589675"
        local value_5_8: string = "rbxassetid://139379638020186"
        local value_6_7: string = "rbxassetid://320397765"
        local value_7_7: string = "rbxassetid://320403652"
        table_3_3[1], table_3_3[2], table_3_3[3], table_3_3[4] = value_4_14, value_5_8, value_6_7, value_7_7
        if captured_value_6 then
            local table_4_3 = {nil, nil, nil}
            local value_5_9: string = "rbxassetid://1836013831"
            local value_6_8: string = "rbxassetid://1838605064"
            local value_7_8: string = "rbxassetid://1841274964"
            table_4_3[1], table_4_3[2], table_4_3[3] = value_5_9, value_6_8, value_7_8
            table_3_3 = table_4_3
            _G.HalloweenMusic("Murderer", "Stop")
            _G.HalloweenMusic("Escape", "Stop")
            _G.HalloweenMusic("Lobby", "Stop")
        end
        local value_4_16 = table_3_3[argument_2]
        local value_3_16: Sound = (Instance.new("Sound"))
        value_3_16.SoundId = value_4_16
        local value_5_13: number = 0.4
        value_3_16.Volume = value_5_13
        local value_5_14: boolean = false
        value_3_16.Looped = value_5_14
        local value_5_15: boolean = false
        value_3_16.PlayOnRemove = value_5_15
        local game_value_15: DataModel = game
        local value_7_9: string = "SoundService"
        local sound_service: Instance = game_value_15:GetService(value_7_9)
        local value_7_10: string = "Music"
        local music_child: Instance? = sound_service:FindFirstChild(value_7_10)
        value_3_16.SoundGroup = music_child
        local new_result_8: NumberValue = Instance.new("NumberValue", value_3_16)
        local volume_value: number = value_3_16.Volume
        new_result_8.Value = volume_value
        local player_gui_value_3 = game.Players.LocalPlayer.PlayerGui
        value_3_16.Parent = player_gui_value_3
        value_3_16:Play()
        local debris_value = game.Debris
        local value_7_11: Sound = value_3_16
        debris_value:AddItem(value_7_11)

        return
    end
end
local on_client_event_value = game.ReplicatedStorage.Remotes.Gameplay.VictoryScreen.OnClientEvent
local value_12
do
    local captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11 = play_end_music, play_victory_screen, table_7, require_result, value_8_3
    value_12 = function(argument_1_4, argument_2_2, argument_3, argument_4, argument_5)
        local character_value_5, fade_to_winner_value, game_value_18, game_value_19, game_value_20, game_value_21, game_value_22, game_value_23, game_value_24, local_player_value_10, local_player_value_4, local_player_value_5, local_player_value_6, local_player_value_7, local_player_value_8, local_player_value_9, players_value_10, players_value_11, players_value_12, players_value_13, players_value_7, players_value_8, players_value_9, print_value, value_10_7, value_6_18, value_6_19, value_6_20, value_6_21, value_6_22, value_6_23, value_6_24, value_6_25, value_6_26, value_6_27, value_6_28, value_6_29, value_6_30, value_6_31, value_6_32, value_7_12, value_7_13, value_7_14, value_7_15, value_7_16, value_7_17, value_7_18, value_7_19, value_7_20, value_7_21, value_7_22, value_7_23, value_7_24, value_7_25, value_7_26, value_8_10, value_8_11, value_8_12, value_8_13, value_8_14, value_8_15, value_8_16, value_8_6, value_8_7, value_8_8, value_8_9, value_9_4, value_9_5, value_9_6, wait_value_4, wait_value_5, wait_value_6, wait_value_7
        local control_state = 0
        while true do
            if control_state < 13 then
                if control_state < 6 then
                    if control_state < 3 then
                        if control_state < 1 then
                            print_value = print
                            value_7_12 = argument_1_4
                            value_8_6 = argument_2_2
                            value_9_4 = argument_3
                            value_10_7 = argument_4
                            print_value(value_7_12, value_8_6, value_9_4, value_10_7)
                            control_state = if argument_4 == "Zombie" then 2 else 1
                        else
                            if control_state < 2 then
                                control_state = if argument_4 ~= "Survivor" then 3 else 2
                            else
                                wait_value_4 = task.wait
                                value_7_13 = 0.5
                                wait_value_4(value_7_13)
                                value_6_18 = captured_value_7
                                game_value_18 = game
                                players_value_7 = game_value_18.Players
                                local_player_value_4 = players_value_7.LocalPlayer
                                value_8_7 = argument_5
                                value_6_18(local_player_value_4, value_8_7)
                                value_6_19 = captured_value_8
                                value_7_14 = argument_4
                                value_6_19(value_7_14)

                                return
                            end
                        end
                    else
                        if control_state < 4 then
                            control_state = if argument_4 == "Freezer" then 5 else 4
                        else
                            if control_state < 5 then
                                control_state = if argument_4 ~= "Runner" then 6 else 5
                            else
                                wait_value_5 = task.wait
                                value_7_15 = 0.5
                                wait_value_5(value_7_15)
                                value_6_20 = captured_value_7
                                game_value_19 = game
                                players_value_8 = game_value_19.Players
                                local_player_value_5 = players_value_8.LocalPlayer
                                value_8_8 = argument_5
                                value_6_20(local_player_value_5, value_8_8)
                                value_6_21 = captured_value_8
                                value_7_16 = argument_4
                                value_6_21(value_7_16)

                                return
                            end
                        end
                    end
                else
                    if control_state < 9 then
                        if control_state < 7 then
                            control_state = if argument_4 == "Red Team" then 8 else 7
                        else
                            if control_state < 8 then
                                control_state = if argument_4 ~= "Blue Team" then 9 else 8
                            else
                                value_6_22 = captured_value_7
                                game_value_20 = game
                                players_value_9 = game_value_20.Players
                                local_player_value_6 = players_value_9.LocalPlayer
                                value_8_9 = argument_5
                                value_6_22(local_player_value_6, value_8_9)
                                value_6_23 = captured_value_8
                                value_7_17 = argument_4
                                value_6_23(value_7_17)

                                return
                            end
                        end
                    else
                        if control_state < 11 then
                            if control_state < 10 then
                                value_7_18 = captured_value_9
                                value_6_24 = value_7_18[argument_2_2]
                                control_state = if not value_6_24 then 24 else 10
                            else
                                value_8_10 = captured_value_9
                                value_7_19 = value_8_10[argument_2_2]
                                value_6_25 = value_7_19[argument_3]
                                control_state = if not value_6_25 then 13 else 11
                            end
                        else
                            if control_state < 12 then
                                control_state = if not argument_1_4 then 13 else 12
                            else
                                wait_value_6 = task.wait
                                value_7_20 = 0.5
                                wait_value_6(value_7_20)
                                value_6_26 = captured_value_7
                                game_value_21 = game
                                players_value_10 = game_value_21.Players
                                local_player_value_7 = players_value_10.LocalPlayer
                                value_8_11 = argument_5
                                value_6_26(local_player_value_7, value_8_11)
                                value_6_27 = captured_value_8
                                value_7_21 = argument_2_2
                                value_6_27(value_7_21)

                                return
                            end
                        end
                    end
                end
            else
                if control_state < 19 then
                    if control_state < 16 then
                        if control_state < 14 then
                            control_state = if not argument_4 then 19 else 14
                        else
                            if control_state < 15 then
                                control_state = if argument_1_4 ~= false then 19 else 15
                            else
                                game_value_22 = game
                                players_value_11 = game_value_22.Players
                                local_player_value_8 = players_value_11.LocalPlayer
                                character_value_5 = local_player_value_8.Character
                                control_state = if character_value_5 ~= nil then 17 else 16
                            end
                        end
                    else
                        if control_state < 17 then
                            value_6_28 = false
                            control_state = 18
                        else
                            if control_state < 18 then
                                value_6_28 = true
                                control_state = 18
                            else
                                value_7_22 = captured_value_10
                                fade_to_winner_value = value_7_22.FadeToWinner
                                value_8_12 = argument_4
                                value_9_5 = value_6_28
                                fade_to_winner_value(value_8_12, value_9_5)
                                value_7_23 = captured_value_7
                                value_8_13 = argument_4
                                value_9_6 = argument_5
                                value_7_23(value_8_13, value_9_6)

                                return
                            end
                        end
                    end
                else
                    if control_state < 22 then
                        if control_state < 20 then
                            control_state = if not argument_1_4 then 25 else 20
                        else
                            if control_state < 21 then
                                wait_value_7 = task.wait
                                value_7_24 = 0.5
                                wait_value_7(value_7_24)
                                value_6_29 = captured_value_7
                                game_value_23 = game
                                players_value_12 = game_value_23.Players
                                local_player_value_9 = players_value_12.LocalPlayer
                                value_8_14 = argument_5
                                value_6_29(local_player_value_9, value_8_14)
                                value_6_30 = captured_value_8
                                value_8_15 = captured_value_11
                                control_state = if not value_8_15 then 22 else 21
                            else
                                value_7_25 = "InnocentsEscaped"
                                control_state = 23
                            end
                        end
                    else
                        if control_state < 24 then
                            if control_state < 23 then
                                value_7_25 = "TimesUp"
                                control_state = 23
                            else
                                value_6_30(value_7_25)

                                return
                            end
                        else
                            if control_state < 25 then
                                value_6_31 = captured_value_7
                                game_value_24 = game
                                players_value_13 = game_value_24.Players
                                local_player_value_10 = players_value_13.LocalPlayer
                                value_8_16 = argument_5
                                value_6_31(local_player_value_10, value_8_16)
                                value_6_32 = captured_value_8
                                value_7_26 = "TimesUp"
                                value_6_32(value_7_26)
                                control_state = 25
                            else
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
on_client_event_value:connect(value_12)
local on_client_event_value_2 = game.ReplicatedStorage.Remotes.Gameplay.RoundEndFade.OnClientEvent
local value_12_2
do
    local captured_value_12 = require_result
    value_12_2 = function(argument_1_5): ()
        captured_value_12.PlayCameraFade("In")
        if not argument_1_5 then
            wait(0.4)
            captured_value_12.CameraFadeToLocalPlayer("Out")
            _G.ShowResults()
        end

        return
    end
end
on_client_event_value_2:connect(value_12_2)
local require_result_2 = require(game.ReplicatedStorage.Modules.ScoreboardModule)
local g_value_3 = _G
local value_12_3: (<T1>(T1) -> ())?
do
    local captured_value_13 = require_result_2
    value_12_3 = function<T1>(argument_1_6: T1): ()
        local invoke_server_result = game.ReplicatedStorage.Remotes.Gameplay.GetLastRoundRewards:InvokeServer()
        if invoke_server_result == nil then
            return
        end
        if invoke_server_result.RoundCount ~= _G.LastRound then
            local scoreboard_value = game.Players.LocalPlayer.PlayerGui.Scoreboard
            captured_value_13.DisplayScoreboard(invoke_server_result)
        end

        return
    end
end
g_value_3.ShowResults = value_12_3

return
