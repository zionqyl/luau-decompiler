--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_3: string = "Game"
local game_child = parent_value:WaitForChild(value_3)
local local_player_value = game.Players.LocalPlayer
local value_3_2: boolean = true
if game.PlaceId ~= 5895823254 then
    if game.PlaceId ~= 5928494131 then
        value_3_2 = false
    else
        value_3_2 = true
    end
end
local require_value = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_7_2)
local value_7_3: string = "ProfileData"
local require_result = require_value(modules_child:WaitForChild(value_7_3))
local require_value_2 = require
local game_value_5: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_5:GetService(value_8)
local value_8_2: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_2:WaitForChild(value_8_2)
local value_8_3: string = "CurrentRoundClient"
local require_result_2 = require_value_2(modules_child_2:WaitForChild(value_8_3))
local game_value_6: DataModel = game
local value_8_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_6:GetService(value_8_4)
local value_8_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_8_5)
local require_value_3 = require
local game_value_7: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_7:GetService(value_9)
local value_9_2: string = "Modules"
local modules_child_3: Instance? = replicated_storage_service_4:WaitForChild(value_9_2)
local value_9_3: string = "WindowService"
local require_result_3 = require_value_3(modules_child_3:WaitForChild(value_9_3))
local player_gui_value = game.Players.LocalPlayer.PlayerGui
local value_9_4: string = "Device"
local device_value = player_gui_value:GetAttribute(value_9_4)
local value_8_10: boolean = true
if device_value ~= "Tablet" then
    if device_value ~= "Phone" then
        local value_8_11: boolean = false
    else
        local value_8_12: boolean = true
    end
end
local value_8_13: boolean?
if device_value ~= "Tablet" then
    value_8_13 = false
else
    value_8_13 = true
end
local value_11: nil | boolean | string, value_7_13
do
    local take_fallback = not value_8_13
    if not take_fallback then
        value_11 = "TabletLevel"
        value_7_13 = (game_child:WaitForChild(value_11))
        take_fallback = not value_7_13
    end
    if take_fallback then
        value_11 = "Level"
        value_7_13 = (game_child:WaitForChild(value_11))
    end
end
local require_value_4 = require
local replicated_storage_value = game.ReplicatedStorage
value_11 = "Modules"
local modules_child_4 = replicated_storage_value:WaitForChild(value_11)
value_11 = "LevelModule"
local require_result_4 = require_value_4(modules_child_4:WaitForChild(value_11))
local require_value_5 = require
local replicated_storage_value_2 = game.ReplicatedStorage
local value_12: string? = "Modules"
local modules_child_5 = replicated_storage_value_2:WaitForChild(value_12)
value_12 = "FadeModule"
local require_result_5 = require_value_5(modules_child_5:WaitForChild(value_12))
value_12 = "EarnedXP"
local earned_xp_child = game_child:WaitForChild(value_12)
value_11 = nil
value_12 = nil
local value_13 = nil
local value_14: number? = nil
local value_15: number? = nil
local value_16: boolean = true
local value_17: number = 900

local function comma_value_2(argument_1)
    local value_2_2 = argument_1
    while true do
        local gsub_value = string.gsub
        local value_4 = value_2_2
        local value_5_4: string = "^(-?%d+)(%d%d%d)"
        local value_6_9: string = "%1,%2"
        local gsub_result, value_4_2 = gsub_value(value_4, value_5_4, value_6_9)
        k = value_4_2
        value_2_2 = gsub_result
        local k_value = k
        if k_value == 0 then
            break
        end
    end

    return value_2_2
end

comma_value = comma_value_2

local function get_time_text(argument_1_2: number)
    local value_3_3: number = argument_1_2 / 60
    local floor_result = math.floor(value_3_3)
    local value_3_4 = argument_1_2 - floor_result * 60
    local value_5_5: number = 0
    local value_4_4
    do
        local take_fallback_2 = not (value_5_5 < floor_result)
        if not take_fallback_2 then
            value_4_4 = floor_result .. "m "
            take_fallback_2 = not value_4_4
        end
        if take_fallback_2 then
            value_4_4 = ""
        end
    end

    return value_4_4 .. value_3_4 .. "s"
end

local update_level: (() -> ())?
do
    local captured_value, captured_value_2, captured_value_3 = require_result, value_7_13, require_result_4
    update_level = function(): ()
        local new_xp_value = captured_value.NewXP
        local value_2_3 = captured_value_2
        local value_4_5: string = "XPBar"
        local xp_value = value_2_3:WaitForChild(value_4_5).XP
        local level_text_value = captured_value_2.LevelText
        local get_level_result = captured_value_3.GetLevel(new_xp_value)
        level_text_value.Text = get_level_result
        local get_progress_to_next_level_result = captured_value_3.GetProgressToNextLevel(
            new_xp_value
        )
        local new_result = UDim2.new(
            get_progress_to_next_level_result,
            xp_value.Size.X.Offset,
            xp_value.Size.Y.Scale,
            xp_value.Size.Y.Offset
        )
        xp_value.Size = new_result
        if 100 <= (captured_value_3.GetLevel(new_xp_value)) then
            local prestige_value = captured_value_2.Prestige
            local value_5_12: boolean = true
            prestige_value.Visible = value_5_12

            return
        end
        local prestige_value_2 = captured_value_2.Prestige
        local value_5_13: boolean = false
        prestige_value_2.Visible = value_5_13

        return
    end
end
UpdateLevel = update_level
local value_21: string = "Dock"
local dock_child = game_child:WaitForChild(value_21)
local value_21_2: string = "Shop"
local activated_value = dock_child:WaitForChild(value_21_2).Activated
local value_21_3: (() -> ())?
do
    local captured_value_4 = require_result_3
    value_21_3 = function(): ()
        local value_1_3 = captured_value_4
        local value_3_8: string = "Shop"
        value_1_3:ToggleFrame(value_3_8)

        return
    end
end
activated_value:Connect(value_21_3)
local on_prestige_button_clicked: (() -> ())?
do
    local captured_value_5, captured_value_6, captured_value_7 = require_result, require_result_4, game_child
    on_prestige_button_clicked = function(): ()
        local new_xp_value_2 = captured_value_5.NewXP
        if (captured_value_6.GetLevel(new_xp_value_2)) < 100 then
            return
        end
        local prestige_value_3 = captured_value_7.Prestige
        local value_3_11: boolean = true
        prestige_value_3.Visible = value_3_11

        return
    end
end
local on_prestige_cancelled: (() -> ())?
do
    local captured_value_8 = game_child
    on_prestige_cancelled = function(): ()
        local prestige_value_4 = captured_value_8.Prestige
        local value_2_8: boolean = false
        prestige_value_4.Visible = value_2_8

        return
    end
end
local on_prestige_accepted: (() -> ())?
do
    local captured_value_9, captured_value_10 = game_child, local_player_value
    on_prestige_accepted = function(): ()
        game.ReplicatedStorage.Remotes.Inventory.Prestige:FireServer()
        local prestige_value_6 = captured_value_9.Prestige
        local value_2_10: boolean = false
        prestige_value_6.Visible = value_2_10
        UpdateLevel()
        local value_2_11 = captured_value_10
        local value_4_11: string = "Prestige"
        local value_1_9 = (value_2_11:GetAttribute(value_4_11)) or 0
        local value_2_13 = captured_value_10
        local value_4_12: string = "Prestige"
        local value_5_14 = value_1_9 + 1
        value_2_13:SetAttribute(value_4_12, value_5_14)

        return
    end
end
local on_backpack_child_added
do
    local captured_value_11, captured_value_12, captured_value_13, captured_value_14 = require_result_2, local_player_value, earned_xp_child, game_child
    on_backpack_child_added = function(argument_1_3): ()
        local value_4_13: string = "IsGun"
        if not (argument_1_3:FindFirstChild(value_4_13)) then
            return
        end
        local get_latest_player_data_result = captured_value_11.GetLatestPlayerData()
        if get_latest_player_data_result[captured_value_12.Name] ~= nil then
            if get_latest_player_data_result[captured_value_12.Name].Role == "Hero" then
                value_12 = "Hero"
                local value_3_17 = captured_value_13
                local value_4_16: boolean = false
                value_3_17.Visible = value_4_16
                local timer_value = captured_value_14.Timer
                local value_4_17: boolean = true
                timer_value.Visible = value_4_17
            end
        end

        return
    end
end

local function on_data_updated(): ()
    UpdateCash()
    UpdateLevel()

    return
end

local on_round_start
do
    local captured_value_15, captured_value_16, captured_value_17, captured_value_18 = value_3_2, local_player_value, earned_xp_child, game_child
    on_round_start = function(argument_1_4: number, argument_2): ()
        if captured_value_15 then
            return
        end
        value_17 = argument_1_4 * 5
        if argument_2[captured_value_16.Name] ~= nil then
            if argument_2[captured_value_16.Name].Dead == false then
                value_13 = (time())
                value_15 = argument_1_4
                if argument_2[captured_value_16.Name].Role == "Innocent" then
                    value_14 = 0
                    value_12 = "Innocent"
                    value_11 = true
                    local xp_text_value = captured_value_17.XPText
                    local value_4_21: number = 0
                    xp_text_value.Text = value_4_21
                    local value_3_26 = captured_value_17
                    local value_4_22: boolean = true
                    value_3_26.Visible = value_4_22

                    return
                end
                value_11 = true
                if not captured_value_15 then
                    local timer_value_2 = captured_value_18.Timer
                    local value_4_23: boolean = true
                    timer_value_2.Visible = value_4_23
                    local role_selector_value = captured_value_18.RoleSelector
                    local value_4_24: boolean = false
                    role_selector_value.Visible = value_4_24
                end
            end
        end

        return
    end
end

local function on_victory_screen_shown(): ()
    value_12 = nil
    value_13 = nil

    return
end

local on_dock_toggled: (() -> ())?
do
    local captured_value_19 = game_child
    on_dock_toggled = function(): ()
        value_16 = not value_16
        local title_value = captured_value_19.Dock.Touch.Title
        local value_2_18: string?
        if value_16 then
            value_2_18 = "<"
        else
            value_2_18 = ">"
        end
        title_value.Text = value_2_18
        local dock_value_2 = captured_value_19.Dock
        local new_value_2: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
        local value_4_25: number = 0
        local value_5_18: number?
        if value_16 then
            value_5_18 = 0
        else
            value_5_18 = -135
        end
        local new_result_2 = new_value_2(value_4_25, value_5_18, 0.5, -150)
        local value_4_26: string = "Out"
        local value_5_19: string = "Quad"
        local value_6_14: number = 0.2
        local value_7_16: boolean = true
        dock_value_2:TweenPosition(new_result_2, value_4_26, value_5_19, value_6_14, value_7_16)

        return
    end
end
local on_died: (() -> ())?
do
    local captured_value_20, captured_value_21 = require_result_5, earned_xp_child
    on_died = function(): ()
        captured_value_20.DeathFlash()
        local xp_text_value_2 = captured_value_21.XPText
        local color_value = BrickColor.new("Medium stone grey").Color
        xp_text_value_2.TextColor3 = color_value
        local victory_label_value = captured_value_21.VictoryLabel
        local color_value_2 = BrickColor.new("Medium stone grey").Color
        victory_label_value.TextColor3 = color_value_2
        value_11 = false

        return
    end
end
local on_update: ((number) -> ())?
do
    local captured_value_22, captured_value_23, captured_value_24 = game_child, value_3_2, earned_xp_child
    on_update = function(argument_1_5: number): ()
        local floor_result_2, floor_result_3, floor_value_2, floor_value_3, new_result_5, new_result_6, new_result_7, new_value_5, new_value_6, new_value_7, time_result_2, time_value_2, timer_value_3, timer_value_4, timer_value_5, timer_value_6, timer_value_7, value_10_8, value_10_9, value_11_2, value_2_20, value_2_21, value_2_22, value_3_34, value_3_35, value_3_36, value_4_27, value_4_28, value_4_29, value_4_30, value_4_31, value_4_32, value_4_33, value_4_34, value_4_35, value_5_20, value_5_21, value_5_22, value_5_23, value_5_24, value_5_25, value_5_26, value_5_27, value_6_15, value_6_16, value_6_17, value_6_18, value_7_17, value_7_18, value_7_19, value_7_20, value_7_21, value_8_15, value_8_16, value_8_17, value_8_18, value_8_19, value_9_10, value_9_11, value_9_12, value_9_9, victory_label_value_2, xp_text_value_3, xp_text_value_4, xp_text_value_5, xp_text_value_6, xp_text_value_7, xp_text_value_8, xp_text_value_9
        local control_state = 0
        while true do
            if control_state < 8 then
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            value_2_20 = value_13
                            control_state = if value_2_20 ~= nil then 2 else 1
                        else
                            value_2_21 = captured_value_22
                            timer_value_3 = value_2_21.Timer
                            value_3_34 = false
                            timer_value_3.Visible = value_3_34

                            return
                        end
                    else
                        if control_state < 3 then
                            value_2_22 = captured_value_23
                            control_state = if not value_2_22 then 4 else 3
                        else
                            return
                        end
                    end
                else
                    if control_state < 6 then
                        if control_state < 5 then
                            time_value_2 = time
                            time_result_2 = time_value_2()
                            value_5_20 = value_13
                            value_3_35 = time_result_2 - value_5_20
                            floor_value_2 = math.floor
                            floor_result_2 = floor_value_2(value_3_35)
                            value_4_27 = value_15
                            value_3_36 = value_4_27 - floor_result_2
                            value_4_28 = value_12
                            control_state = if value_4_28 ~= "Innocent" then 8 else 5
                        else
                            value_4_29 = floor_result_2 * 5
                            value_5_21 = value_17
                            control_state = if not (value_5_21 <= value_4_29) then 7 else 6
                        end
                    else
                        if control_state < 7 then
                            value_5_22 = captured_value_24
                            xp_text_value_3 = value_5_22.XPText
                            value_6_15 = value_17
                            xp_text_value_3.Text = value_6_15
                            value_5_23 = captured_value_24
                            victory_label_value_2 = value_5_23.VictoryLabel
                            value_6_16 = "Game Over!"
                            victory_label_value_2.Text = value_6_16
                            value_5_24 = captured_value_24
                            xp_text_value_4 = value_5_24.XPText
                            new_value_5 = Color3.new
                            value_7_17 = 0
                            value_8_15 = 1
                            value_9_9 = 0
                            new_result_5 = new_value_5(value_7_17, value_8_15, value_9_9)
                            xp_text_value_4.TextColor3 = new_result_5

                            return
                        else
                            value_5_25 = captured_value_24
                            xp_text_value_5 = value_5_25.XPText
                            xp_text_value_5.Text = value_4_29

                            return
                        end
                    end
                end
            else
                if control_state < 12 then
                    if control_state < 10 then
                        if control_state < 9 then
                            value_4_30 = 0
                            control_state = if not (value_4_30 < value_3_36) then 14 else 9
                        else
                            value_4_31 = captured_value_22
                            timer_value_4 = value_4_31.Timer
                            xp_text_value_6 = timer_value_4.XPText
                            value_7_18 = value_3_36 / 60
                            floor_value_3 = math.floor
                            floor_result_3 = floor_value_3(value_7_18)
                            value_8_16 = floor_result_3 * 60
                            value_7_19 = value_3_36 - value_8_16
                            value_9_10 = 0
                            control_state = if not (value_9_10 < floor_result_3) then 11 else 10
                        end
                    else
                        if control_state < 11 then
                            value_9_11 = floor_result_3
                            value_10_8 = "m "
                            value_8_17 = value_9_11 .. value_10_8
                            control_state = if value_8_17 then 12 else 11
                        else
                            value_8_17 = ""
                            control_state = 12
                        end
                    end
                else
                    if control_state < 14 then
                        if control_state < 13 then
                            value_9_12 = value_8_17
                            value_10_9 = value_7_19
                            value_11_2 = "s"
                            value_5_26 = value_9_12 .. value_10_9 .. value_11_2
                            xp_text_value_6.Text = value_5_26
                            value_4_32 = 30
                            control_state = if not (value_3_36 <= value_4_32) then 15 else 13
                        else
                            value_4_33 = captured_value_22
                            timer_value_5 = value_4_33.Timer
                            xp_text_value_7 = timer_value_5.XPText
                            new_value_6 = Color3.new
                            value_6_17 = 255
                            value_7_20 = 0
                            value_8_18 = 0
                            new_result_6 = new_value_6(value_6_17, value_7_20, value_8_18)
                            xp_text_value_7.TextColor3 = new_result_6

                            return
                        end
                    else
                        if control_state < 15 then
                            value_4_34 = captured_value_22
                            timer_value_6 = value_4_34.Timer
                            xp_text_value_8 = timer_value_6.XPText
                            value_5_27 = "Game Over!"
                            xp_text_value_8.Text = value_5_27
                            value_4_35 = captured_value_22
                            timer_value_7 = value_4_35.Timer
                            xp_text_value_9 = timer_value_7.XPText
                            new_value_7 = Color3.new
                            value_6_18 = 1
                            value_7_21 = 1
                            value_8_19 = 1
                            new_result_7 = new_value_7(value_6_18, value_7_21, value_8_19)
                            xp_text_value_9.TextColor3 = new_result_7
                            control_state = 15
                        else
                            return
                        end
                    end
                end
            end
        end
    end
end
local initialize: (() -> ())?
do
    local captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36 = local_player_value, on_victory_screen_shown, on_round_start, on_data_updated, on_backpack_child_added, on_update, game_child, on_prestige_button_clicked, on_prestige_accepted, on_prestige_cancelled, on_dock_toggled, on_died
    initialize = function(): ()
        local g_value = _G
        local value_2_23: nil = nil
        g_value.LockTarget = value_2_23
        local value_1_20 = captured_value_25
        local classic_value = Enum.CameraMode.Classic
        value_1_20.CameraMode = classic_value
        UpdateLevel()
        local replicated_storage_value_4 = game.ReplicatedStorage
        local value_3_37: string = "Remotes"
        local remotes_child_2 = replicated_storage_value_4:WaitForChild(value_3_37)
        local value_3_38: string = "Gameplay"
        local gameplay_child = remotes_child_2:WaitForChild(value_3_38)
        local value_3_39: string = "VictoryScreen"
        local on_client_event_value = gameplay_child:WaitForChild(value_3_39).OnClientEvent
        local value_3_40: () -> () = captured_value_26
        on_client_event_value:Connect(value_3_40)
        local replicated_storage_value_5 = game.ReplicatedStorage
        local value_3_41: string = "Remotes"
        local remotes_child_3 = replicated_storage_value_5:WaitForChild(value_3_41)
        local value_3_42: string = "Gameplay"
        local gameplay_child_2 = remotes_child_3:WaitForChild(value_3_42)
        local value_3_43: string = "RoundStart"
        local on_client_event_value_2 = gameplay_child_2:WaitForChild(value_3_43).OnClientEvent
        local value_3_44 = captured_value_27
        on_client_event_value_2:Connect(value_3_44)
        local replicated_storage_value_6 = game.ReplicatedStorage
        local value_3_45: string = "UpdateData2"
        local on_client_event_value_3 = replicated_storage_value_6:WaitForChild(value_3_45).OnClientEvent
        local value_3_46: () -> () = captured_value_28
        on_client_event_value_3:Connect(value_3_46)
        local value_1_31 = captured_value_25
        local value_3_47: string = "Backpack"
        local child_added_value = value_1_31:WaitForChild(value_3_47).ChildAdded
        local value_3_48 = captured_value_29
        child_added_value:Connect(value_3_48)
        local game_value_15: DataModel = game
        local value_3_49: string = "RunService"
        local pre_simulation_value = game_value_15:GetService(value_3_49).PreSimulation
        local value_3_50: (number) -> () = captured_value_30
        pre_simulation_value:Connect(value_3_50)
        local activated_value_2 = captured_value_31.Leaderboard.Inspect.Container.Prestige.Activated
        local value_3_51: () -> () = captured_value_32
        activated_value_2:Connect(value_3_51)
        local activated_value_3 = captured_value_31.Prestige.Accept.Activated
        local value_3_52: () -> () = captured_value_33
        activated_value_3:Connect(value_3_52)
        local activated_value_4 = captured_value_31.Prestige.Decline.Activated
        local value_3_53: () -> () = captured_value_34
        activated_value_4:Connect(value_3_53)
        local touch_value_2 = captured_value_31.Dock.Touch
        local game_value_16: DataModel = game
        local value_4_36: string = "UserInputService"
        local touch_enabled_value = game_value_16:GetService(value_4_36).TouchEnabled
        touch_value_2.Visible = touch_enabled_value
        local activated_value_5 = captured_value_31.Dock.Touch.Button.Activated
        local value_3_55: () -> () = captured_value_35
        activated_value_5:Connect(value_3_55)
        while true do
            local wait_value: (number?) -> (number) = task.wait
            wait_value()
            local value_1_45 = captured_value_25
            local character_value = value_1_45.Character
            if character_value ~= nil then
                break
            end
        end
        task.wait()
        local value_1_46 = captured_value_25
        local value_2_43: string = "Classic"
        value_1_46.CameraMode = value_2_43
        local value_1_47 = captured_value_25
        local value_2_44: number = 7
        value_1_47.CameraMinZoomDistance = value_2_44
        task.wait(0.5)
        local value_1_48 = captured_value_25
        local value_2_46: number = 0.5
        value_1_48.CameraMinZoomDistance = value_2_46
        local starter_gui_value = game.StarterGui
        local value_3_56: string = "Health"
        local value_4_37: boolean = false
        starter_gui_value:SetCoreGuiEnabled(value_3_56, value_4_37)
        local starter_gui_value_2 = game.StarterGui
        local value_3_57: string = "PlayerList"
        local value_4_38: boolean = false
        starter_gui_value_2:SetCoreGuiEnabled(value_3_57, value_4_38)
        local value_1_51: nil = nil
        local value_1_52
        while true do
            local wait_value_4: (number?) -> (number) = task.wait
            wait_value_4()
            local game_value_19: DataModel = game
            local players_value_3 = game_value_19.Players
            local local_player_value_3 = players_value_3.LocalPlayer
            local character_value_2 = local_player_value_3.Character
            local value_4_39: string = "Humanoid"
            local humanoid_child = character_value_2:FindFirstChild(value_4_39)
            value_1_52 = humanoid_child
            if value_1_52 ~= nil then
                break
            end
        end
        local died_value = value_1_52.Died
        local value_4_40: () -> () = captured_value_36
        died_value:Connect(value_4_40)
        local place_version_value: number = game.PlaceVersion
        local version_value = captured_value_31.Dock.Version
        version_value.Text = place_version_value

        return
    end
end
initialize()

return
