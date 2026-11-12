--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_3)
local value_2 = {}
local create_tween_from_table
do
    local captured_value = tween_service
    create_tween_from_table = function(argument_1, argument_2, argument_3)
        local value_4_5 = value_2
        local value_5_5 = value_2[argument_1] or ({})
        value_4_5[argument_1] = value_5_5
        local value_4_6 = value_2[argument_1]
        local value_5_7: Instance = captured_value
        local value_7 = argument_1
        local new_result: TweenInfo = TweenInfo.new(
            argument_3.Time,
            Enum.EasingStyle[argument_3.EasingStyle],
            Enum.EasingDirection[argument_3.EasingDirection],
            0,
            false,
            argument_3.DelayTime
        )
        local properties_value = argument_3.Properties
        local create_result = value_5_7:Create(value_7, new_result, properties_value)
        value_4_6[argument_2] = create_result

        return
    end
end
local on_client_event_value = game.ReplicatedStorage.ClientTweenEvents.CreateClientTween.OnClientEvent
local value_6
do
    local captured_value_2 = create_tween_from_table
    value_6 = function(argument_1_2, argument_2_2, argument_3_2)
        captured_value_2(argument_1_2, argument_2_2, argument_3_2)

        return
    end
end
on_client_event_value:Connect(value_6)
local on_client_event_value_2 = game.ReplicatedStorage.ClientTweenEvents.PlayClientTween.OnClientEvent
local value_6_2
do
    local captured_value_3 = create_tween_from_table
    value_6_2 = function(argument_1_3, argument_2_3)
        if value_2[argument_1_3] == nil then
            local get_client_tween_value = game.ReplicatedStorage.ClientTweenEvents.GetClientTween
            local value_5_10 = argument_1_3
            local value_6_8 = argument_2_3
            captured_value_3(
                argument_1_3,
                argument_2_3,
                (get_client_tween_value:InvokeServer(value_5_10, value_6_8))
            )
        else
            if value_2[argument_1_3][argument_2_3] == nil then
                local get_client_tween_value_2 = game.ReplicatedStorage.ClientTweenEvents.GetClientTween
                local value_5_13 = argument_1_3
                local value_6_10 = argument_2_3
                captured_value_3(
                    argument_1_3,
                    argument_2_3,
                    (get_client_tween_value_2:InvokeServer(value_5_13, value_6_10))
                )
            end
        end
        value_2[argument_1_3][argument_2_3]:Play()

        return
    end
end
on_client_event_value_2:Connect(value_6_2)
local on_client_event_value_3 = game.ReplicatedStorage.ClientTweenEvents.StopClientTween.OnClientEvent

local function value_6_3(argument_1_4, argument_2_4)
    if value_2[argument_1_4] ~= nil then
        if value_2[argument_1_4][argument_2_4] ~= nil then
            value_2[argument_1_4][argument_2_4]:Cancel()
        end
    end

    return
end

on_client_event_value_3:Connect(value_6_3)
local on_client_event_value_4 = game.ReplicatedStorage.ClientTweenEvents.ClearTweens.OnClientEvent

local function value_6_4()
    value_2 = {}

    return
end

on_client_event_value_4:Connect(value_6_4)

return
