--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function shared_weld_between(argument_1_2, argument_2): ManualWeld
    local new_result_2: ManualWeld = Instance.new("ManualWeld", argument_1_2)
    local value_4_3 = (argument_1_2.CFrame:inverse()) * argument_2.CFrame
    new_result_2.C0 = value_4_3
    new_result_2.Part0 = argument_1_2
    new_result_2.Part1 = argument_2
    local value_4_4: boolean = false
    argument_1_2.Anchored = value_4_4
    local value_4_5: boolean = false
    argument_2.Anchored = value_4_5
    local value_4_6: boolean = false
    argument_1_2.CanCollide = value_4_6
    local value_4_7: boolean = false
    argument_2.CanCollide = value_4_7

    return new_result_2
end

return function(argument_1): ()
    local weld_between = shared_weld_between
    local pairs_value, value_4, value_5 = pairs(argument_1:GetChildren())
    for key_2, value_2 in pairs_value, value_4, value_5 do
        local value_6, value_7 = key_2, value_2
        local value_10 = "BasePart"
        local value_8 = value_7:IsA(value_10)
        local value_11, value_9
        if value_8 then
            value_8 = Instance.new("ManualWeld", value_7)
            value_10 = value_7.CFrame:inverse()
            value_11 = argument_1.CFrame
            value_9 = value_10 * value_11
            value_8.C0 = value_9
            value_8.Part0 = value_7
            value_8.Part1 = argument_1
            value_9 = false
            value_7.Anchored = value_9
            value_9 = false
            argument_1.Anchored = value_9
            value_9 = false
            value_7.CanCollide = value_9
            value_9 = false
            argument_1.CanCollide = value_9
        end
        value_10 = "Model"
        if not (value_7:IsA(value_10)) then
            continue
        end
        value_8, value_9, value_10 = pairs(argument_1:GetChildren())
        for key, value in value_8, value_9, value_10 do
            local value_12
            value_11, value_12 = key, value
            local value_15: string = "BasePart"
            local is_a_result = value_12:IsA(value_15)
            if not is_a_result then
                continue
            end
            local new_value: (string, Instance?) -> (Instance) = Instance.new
            local value_14_2: string = "ManualWeld"
            local value_15_2 = value_12
            local new_result: Instance = new_value(value_14_2, value_15_2)
            local c_frame_value = value_12.CFrame
            local inverse_result = c_frame_value:inverse()
            local c_frame_value_2 = argument_1.CFrame
            local value_14_3 = inverse_result * c_frame_value_2
            new_result.C0 = value_14_3
            new_result.Part0 = value_12
            new_result.Part1 = argument_1
            local value_14_4: boolean = false
            value_12.Anchored = value_14_4
            local value_14_5: boolean = false
            argument_1.Anchored = value_14_5
            local value_14_6: boolean = false
            value_12.CanCollide = value_14_6
            local value_14_7: boolean = false
            argument_1.CanCollide = value_14_7
        end
    end

    return
end
