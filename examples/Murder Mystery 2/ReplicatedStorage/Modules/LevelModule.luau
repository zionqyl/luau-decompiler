--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("XPTable")] = nil, [("XPTable")] = nil, [("XPTable")] = nil}
local table_2 = {}
table_1.XPTable = table_2

local function get_total_xp(argument_1)
    return (1000 + 225 * argument_1) * argument_1 - 225 * (argument_1 * (0.5 * (argument_1 - 1))) - 1000 - 225
end

local generate_xp_table
do
    local captured_value = table_1
    generate_xp_table = function(argument_1_2)
        local value_2_2: number = 0
        local value_5_3: number = 1
        local value_3_3: number = 100
        local value_4_8: number = 1
        for index = value_5_3, value_3_3, value_4_8 do
            value_5_3 = index
            local value_7_3: number = value_5_3 - 1
            local value_11: number = 1000
            local value_13: number = 225
            local value_12: number = value_13 * value_7_3
            local value_10: number = value_11 + value_12
            local value_9_2: number = value_10 * value_7_3
            local value_11_2: number = 225
            local value_14: number = 0.5
            local value_15: number = value_7_3 - 1
            local value_13_2: number = value_14 * value_15
            local value_12_2: number = value_7_3 * value_13_2
            local value_10_2: number = value_11_2 * value_12_2
            local value_8_2: number = value_9_2 - value_10_2
            local value_9_3: number = value_8_2 - 1000
            local value_6_3: number = value_9_3 - 225
            local value_11_3: number = 1000
            local value_13_3: number = 225
            local value_12_3: number = value_13_3 * value_5_3
            local value_10_3: number = value_11_3 + value_12_3
            local value_9_4: number = value_10_3 * value_5_3
            local value_11_4: number = 225
            local value_14_2: number = 0.5
            local value_15_2: number = value_5_3 - 1
            local value_13_4: number = value_14_2 * value_15_2
            local value_12_4: number = value_5_3 * value_13_4
            local value_10_4: number = value_11_4 * value_12_4
            local value_8_3: number = value_9_4 - value_10_4
            local value_9_5: number = value_8_3 - 1000
            local value_7_4: number = value_9_5 - 225
            local value_8_4: number = value_7_4 - value_6_3
            value_2_2 = value_2_2 + value_8_4
            local value_9_6 = captured_value
            local xp_table_value = value_9_6.XPTable
            xp_table_value[value_5_3] = value_2_2
            if not argument_1_2 then
                continue
            end
            local print_value = print
            local value_10_5: string = "Level: "
            local value_11_5: number = value_5_3
            local value_12_5: string = " XP: "
            local value_13_5: number = value_5_3
            local value_17: number = 1000
            local value_19: number = 225
            local value_18: number = value_19 * value_5_3
            local value_16: number = value_17 + value_18
            local value_15_3: number = value_16 * value_5_3
            local value_17_2: number = 225
            local value_20: number = 0.5
            local value_21: number = value_5_3 - 1
            local value_19_2: number = value_20 * value_21
            local value_18_2: number = value_5_3 * value_19_2
            local value_16_2: number = value_17_2 * value_18_2
            local value_8_5: number = value_15_3 - value_16_2
            local value_15_4: number = value_8_5 - 1000
            local value_14_3: number = value_15_4 - 225
            print_value(value_10_5, value_11_5, value_12_5, value_13_5, value_14_3)
        end

        return
    end
end
generate_xp_table()
local value_4_2
do
    local captured_value_2 = table_1
    value_4_2 = function(argument_1_3)
        local value_1 = argument_1_3 or 0
        if 1237500 <= value_1 then
            return 100, captured_value_2.XPTable[100]
        end
        local value_2_3 = captured_value_2.XPTable
        local value_3_4: nil = nil
        local value_4_9: nil = nil
        for key, value in value_2_3, value_3_4, value_4_9 do
            local value_5_4, value_6_4 = key, value
            local value_8_6 = captured_value_2
            local xp_table_value_2 = value_8_6.XPTable
            local value_9_7 = value_5_4 + 1
            local value_7_5 = xp_table_value_2[value_9_7]
            if value_7_5 ~= nil then
                if not (value_6_4 <= value_1) then
                    continue
                end
                if not (value_1 < value_7_5) then
                    continue
                end
                local value_8_7 = value_5_4
                local value_9_8 = value_7_5

                return value_8_7, value_9_8
            else
                if not (value_6_4 <= value_1) then
                    continue
                end

                return value_5_4, value_6_4
            end
        end

        return 1, captured_value_2.XPTable[2]
    end
end
table_1.GetLevel = value_4_2

local function value_4_3(argument_1_4)
    local value_1_2 = argument_1_4 or 1
    if value_1_2 < 1 then
        value_1_2 = 1
    end

    return (1000 + 225 * value_1_2) * value_1_2 - 225 * (value_1_2 * (0.5 * (value_1_2 - 1))) - 1000 - 225
end

table_1.GetXP = value_4_3
local value_4_4
do
    local captured_value_3 = table_1
    value_4_4 = function(argument_1_5)
        local get_level_result, value_3_7 = captured_value_3.GetLevel(argument_1_5)
        local get_xp_result = captured_value_3.GetXP(get_level_result)

        return (argument_1_5 - get_xp_result) / (value_3_7 - get_xp_result)
    end
end
table_1.GetProgressToNextLevel = value_4_4

return table_1
