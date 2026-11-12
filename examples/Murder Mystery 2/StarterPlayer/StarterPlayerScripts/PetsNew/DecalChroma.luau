--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

return function(argument_1): ()
    local game_value: DataModel = game
    local value_4: string = "TweenService"
    local tween_service: Instance = game_value:GetService(value_4)
    local new_result: TweenInfo = TweenInfo.new(
        1,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local table_4 = {
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
    }
    local value_7 = argument_1
    local value_8 = new_result
    local value_9 = {[("Color3")] = nil}
    local from_rgb_result: Color3 = Color3.fromRGB(255, 0, 0)
    value_9.Color3 = from_rgb_result
    local linear_value = tween_service:Create(value_7, value_8, value_9)
    value_8 = argument_1
    value_9 = new_result
    local table_10 = {[("Color3")] = nil}
    local from_rgb_result_2: Color3 = Color3.fromRGB(255, 255, 0)
    table_10.Color3 = from_rgb_result_2
    local out_value = tween_service:Create(value_8, value_9, table_10)
    value_9 = argument_1
    local value_10: TweenInfo = new_result
    local table_11 = {[("Color3")] = nil}
    local from_rgb_result_3: Color3 = Color3.fromRGB(0, 255, 0)
    table_11.Color3 = from_rgb_result_3
    value_7 = tween_service:Create(value_9, value_10, table_11)
    local value_10_2 = argument_1
    local value_11_2: TweenInfo = new_result
    local table_12 = {[("Color3")] = nil}
    local from_rgb_result_4: Color3 = Color3.fromRGB(0, 255, 255)
    table_12.Color3 = from_rgb_result_4
    value_8 = tween_service:Create(value_10_2, value_11_2, table_12)
    local value_11_3 = argument_1
    local value_12_3: TweenInfo = new_result
    local table_13 = {[("Color3")] = nil}
    local from_rgb_result_5: Color3 = Color3.fromRGB(0, 0, 255)
    table_13.Color3 = from_rgb_result_5
    value_9 = tween_service:Create(value_11_3, value_12_3, table_13)
    local value_12_4 = argument_1
    local value_13_4: TweenInfo = new_result
    local table_14 = {[("Color3")] = nil}
    local from_rgb_result_6: Color3 = Color3.fromRGB(255, 0, 255)
    table_14.Color3 = from_rgb_result_6
    table_4 = {
        linear_value,
        out_value,
        value_7,
        value_8,
        value_9,
        tween_service:Create(value_12_4, value_13_4, table_14),
    }
    while true do
        if not (task.wait()) then
            break
        end
        linear_value, out_value, value_7 = pairs(table_4)
        for key, value in linear_value, out_value, value_7 do
            value_8, value_9 = key, value
            value_9:Play()
            local wait_value: (number?) -> (number) = task.wait
            local value_11_6: number = 1
            wait_value(value_11_6)
        end
    end

    return
end
