--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_4: string = "SettingsContainer"
local settings_container_child = parent_value:WaitForChild(value_4)
local value_4_2: string = "SettingsList"
local settings_list_child = settings_container_child:WaitForChild(value_4_2)
local require_value = require
local game_value: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local game_value_2: DataModel = game
local value_5_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5_4)
local value_5_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_5)
local value_6_4: string = "Extras"
local extras_child = remotes_child:WaitForChild(value_6_4)
local value_6_5: string = "GetServerSettings"
local invoke_server_result = extras_child:WaitForChild(value_6_5):InvokeServer()
local value_6_6: string = "CustomGames"
local custom_games_child = remotes_child:WaitForChild(value_6_6)
local value_6_7: string = "CanStartDuels"
local invoke_server_result_2 = custom_games_child:WaitForChild(value_6_7):InvokeServer()
local require_value_2 = require
local game_value_3: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_8)
local value_8_2: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_8_2)
local value_8_3: string = "WindowService"
local require_result_2 = require_value_2(modules_child_2:WaitForChild(value_8_3))
do
    local captured_value = settings_list_child

    local function on_option_enabled(argument_1: string): ()
        if argument_1 == "DuelMode" then
            local duel_value = captured_value.Duel
            local value_3_5: boolean = true
            duel_value.Visible = value_3_5

            return
        end
        local duel_value_2 = captured_value.Duel
        local value_3_6: boolean = false
        duel_value_2.Visible = value_3_6

        return
    end
end
local bind_option_frame
do
    local captured_value_2, captured_value_3 = remotes_child, settings_list_child
    bind_option_frame = function(argument_1_2): ()
        local options_value, value_3_7, value_4_14 = argument_1_2.Options:GetChildren()
        for key_2, value_12 in options_value, value_3_7, value_4_14 do
            local value_5_12, value_6_11 = key_2, value_12
            local value_9_15: string = "Frame"
            local is_a_result = value_6_11:IsA(value_9_15)
            if not is_a_result then
                continue
            end
            local button_value = value_6_11.Button
            local activated_value_3 = button_value.Activated
            local value_9_16: (() -> ())?
            do
                local captured_value_4, captured_value_5, captured_value_6, captured_value_7, closure_ready
                value_9_16 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local value_1 = captured_value_4.Name
                    local value_3_8, value_4_15
                    if value_1 == "GameMode" then
                        value_1 = captured_value_5.Extras.ChangeServerSetting
                        value_3_8 = captured_value_6.Name
                        value_4_15 = true
                        value_1:FireServer(value_3_8, value_4_15)
                    else
                        value_1 = captured_value_5.Extras.ChangeServerSetting
                        value_3_8 = captured_value_4.Name
                        value_4_15 = captured_value_6.Name
                        value_1:FireServer(value_3_8, value_4_15)
                    end
                    local value_2_5
                    value_1, value_2_5, value_3_8 = captured_value_4.Options:GetChildren()
                    for key, value in value_1, value_2_5, value_3_8 do
                        local value_5_13
                        value_4_15, value_5_13 = key, value
                        local value_8_20: string = "Frame"
                        local is_a_result_2 = value_5_13:IsA(value_8_20)
                        if not is_a_result_2 then
                            continue
                        end
                        local button_value_2 = value_5_13.Button
                        local value_8_21 = captured_value_6
                        local roblox_round_default_button_value
                        do
                            local take_fallback = value_5_13 ~= value_8_21
                            if not take_fallback then
                                roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                                take_fallback = not roblox_round_default_button_value
                            end
                            if take_fallback then
                                roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                            end
                        end
                        button_value_2.Style = roblox_round_default_button_value
                    end
                    if captured_value_6.Name == "DuelMode" then
                        value_2_5 = captured_value_7.Duel
                        value_3_8 = true
                        value_2_5.Visible = value_3_8

                        return
                    end
                    value_2_5 = captured_value_7.Duel
                    value_3_8 = false
                    value_2_5.Visible = value_3_8

                    return
                end
                captured_value_4, captured_value_5, captured_value_6, captured_value_7 = argument_1_2, captured_value_2, value_6_11, captured_value_3
                closure_ready = true
            end
            activated_value_3:Connect(value_9_16)
        end

        return
    end
end
local value_8_4 = bind_option_frame
local value_11: string = "GameMode"
value_8_4(settings_list_child:WaitForChild(value_11))
local value_8_5 = bind_option_frame
local value_11_2: string = "RoundTimerOverride"
value_8_5(settings_list_child:WaitForChild(value_11_2))
local value_10_3: string = "Title"
local title_child = parent_value:WaitForChild(value_10_3)
local value_10_4: string = "Close"
local close_child = title_child:WaitForChild(value_10_4)
local value_10_5: string = "Button"
local activated_value = close_child:WaitForChild(value_10_5).Activated
local value_10_6: (() -> ())?
do
    local captured_value_8 = parent_value
    value_10_6 = function(): ()
        local value_1_2: Instance? = captured_value_8
        local value_2_6: boolean = false
        value_1_2.Visible = value_2_6

        return
    end
end
activated_value:Connect(value_10_6)
local value_10_7: string = "Duel"
local duel_child = settings_list_child:WaitForChild(value_10_7)
local value_10_8: string = "DuelSetup"
local duel_setup_child = duel_child:WaitForChild(value_10_8)
local value_10_9: string = "Button"
local activated_value_2 = duel_setup_child:WaitForChild(value_10_9).Activated
local value_10_10: (() -> ())?
do
    local captured_value_9 = require_result_2
    value_10_10 = function(): ()
        local value_1_3 = captured_value_9
        local value_3_9: string = "DuelSetup"
        value_1_3:ToggleFrame(value_3_9)

        return
    end
end
activated_value_2:Connect(value_10_10)
local value_10_11: string = "GameMode"
local game_mode_child = settings_list_child:WaitForChild(value_10_11)
local value_10_12: string = "Options"
local options_child = game_mode_child:WaitForChild(value_10_12)
local value_10_13: string = "DuelMode"
local duel_mode_child = options_child:WaitForChild(value_10_13)
duel_mode_child.Visible = invoke_server_result_2
local value_10_14: Instance? = parent_value
local value_11_3: string = "PrivateServer"
require_result_2:RegisterFrame(value_10_14, value_11_3)

return
