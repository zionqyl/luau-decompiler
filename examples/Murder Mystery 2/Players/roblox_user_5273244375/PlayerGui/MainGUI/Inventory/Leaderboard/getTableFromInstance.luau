--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

return function(argument_1)
    local table_2 = {}
    local attach_instances
    do
        local captured_value, closure_ready
        attach_instances = function(argument_1_2, argument_2): ()
            if not closure_ready then
                return
            end
            local name_value_2 = argument_2.Name
            local name_value_4, value_5_2, value_7_2, value_8_2
            if argument_1_2[name_value_2] == nil then
                local name_value_3 = argument_2.Name
                name_value_2 = {}
                argument_1_2[name_value_3] = name_value_2
            else
                local error_value = error
                value_5_2 = "Instances cannot have duplicate names: "
                name_value_4 = argument_2.Name
                value_7_2 = " in "
                value_8_2 = captured_value.Name
                error_value(value_5_2 .. name_value_4 .. value_7_2 .. value_8_2)
            end
            local get_attributes_result = argument_2:GetAttributes()
            name_value_2, value_5_2, name_value_4 = pairs(get_attributes_result)
            for key, value in name_value_2, value_5_2, name_value_4 do
                value_7_2, value_8_2 = key, value
                local name_value_5 = argument_2.Name
                local value_9_2 = argument_1_2[name_value_5]
                value_9_2[value_7_2] = value_8_2
            end

            return
        end
        captured_value = argument_1
        closure_ready = true
    end
    attach_instances(table_2, argument_1)
    local value_4, value_5, value_6 = pairs(argument_1:GetChildren())
    for key_2, value_2 in value_4, value_5, value_6 do
        local value_7, value_8 = key_2, value_2
        local value_9 = attach_instances
        local name_value = argument_1.Name
        local value_10 = table_2[name_value]
        local value_11 = value_8
        value_9(value_10, value_11)
    end

    return table_2
end
