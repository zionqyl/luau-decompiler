--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("ToggleFrame")] = nil,
    [("ToggleFrame")] = nil,
    [("ToggleFrame")] = nil,
    [("ToggleFrame")] = nil,
    [("ToggleFrame")] = nil,
}
local table_2 = {}
local table_3 = {}
local table_4 = {}
local update_stack
do
    local captured_value, captured_value_2 = table_2, table_3
    update_stack = function(argument_1)
        local value_2 = captured_value
        local value_3: nil = nil
        local value_4: nil = nil
        local value_5, value_6
        for key, value in value_2, value_3, value_4 do
            value_5, value_6 = key, value
            local value_7: boolean = false
            value_6.Visible = value_7
        end
        value_2 = table_4
        value_3 = nil
        value_4 = nil
        for key_2, value_10 in value_2, value_3, value_4 do
            value_5, value_6 = key_2, value_10
            local value_9 = table_4
            local value_8 = #value_9
            local value_7_2: boolean?
            if value_5 ~= value_8 then
                value_7_2 = false
            else
                value_7_2 = true
            end
            value_6.Visible = value_7_2
            local visible_value = value_6.Visible
            if not visible_value then
                continue
            end
            local value_8_2 = captured_value_2
            local value_7_3 = value_8_2[value_6]
            if not value_7_3 then
                continue
            end
            local value_8_3 = captured_value_2
            local value_7_4 = value_8_3[value_6]
            local value_8_4 = argument_1
            value_7_4(value_8_4)
        end

        return
    end
end
local toggle_frame
do
    local captured_value_3, captured_value_4 = table_2, update_stack
    toggle_frame = function<T1>(argument_1_2: T1, argument_2, argument_3)
        local value_4_2 = captured_value_3[argument_2] or argument_2
        local value_6_2 = value_4_2
        local type_result = type(value_6_2)
        do
            local take_fallback = type_result == "string"
            if take_fallback or value_4_2 == nil then
                local warn_value = warn
                local value_7_5: string = "Frame not found: "
                local value_9_2 = argument_2
                warn_value(value_7_5 .. (tostring(value_9_2)))

                return
            end
        end
        if value_4_2.Visible then
            local value_5_3: boolean = false
            value_4_2.Visible = value_5_3
            table_4 = {}
        else
            local table_5_2 = {value_4_2}
            table_4 = table_5_2
        end
        captured_value_4(argument_3)

        return
    end
end
table_1.ToggleFrame = toggle_frame
local view_frame
do
    local captured_value_5, captured_value_6 = table_2, update_stack
    view_frame = function<T1>(argument_1_3: T1, argument_2_2, argument_3_2)
        local value_4_3 = captured_value_5[argument_2_2] or argument_2_2
        local value_6_6 = value_4_3
        local type_result_2 = type(value_6_6)
        do
            local take_fallback_2 = type_result_2 == "string"
            if take_fallback_2 or value_4_3 == nil then
                local warn_value_2 = warn
                local value_7_6: string = "Frame not found: "
                local value_9_3 = argument_2_2
                warn_value_2(value_7_6 .. (tostring(value_9_3)))

                return
            end
        end
        local table_5_3 = {value_4_3}
        table_4 = table_5_3
        captured_value_6(argument_3_2)

        return
    end
end
table_1.ViewFrame = view_frame
local close_all_frames
do
    local captured_value_7 = update_stack
    close_all_frames = function<T1>(argument_1_4: T1)
        table_4 = {}
        captured_value_7()

        return
    end
end
table_1.CloseAllFrames = close_all_frames
local back
do
    local captured_value_8 = update_stack
    back = function<T1>(argument_1_5: T1)
        if #table_4 < 1 then
            return
        end
        local value_2_4 = #table_4
        local value_3_5 = table_4[value_2_4]
        local value_4_5: boolean = false
        value_3_5.Visible = value_4_5
        table.remove(table_4, value_2_4)
        captured_value_8()

        return
    end
end
table_1.Back = back
local add_to_stack
do
    local captured_value_9, captured_value_10 = table_2, update_stack
    add_to_stack = function<T1>(argument_1_6: T1, argument_2_3, argument_3_3)
        local value_4_7 = captured_value_9[argument_2_3] or argument_2_3
        do
            local take_fallback_3 = value_4_7 == nil
            if not take_fallback_3 then
                local value_6_12 = value_4_7
                take_fallback_3 = (typeof(value_6_12)) == "string"
            end
            if take_fallback_3 then
                local warn_value_3 = warn
                local value_7_7: string = "WindowService: Frame not found: "
                local value_9_4 = argument_2_3
                warn_value_3(value_7_7 .. (tostring(value_9_4)))

                return
            end
        end
        local find_result = table.find(table_4, value_4_7)
        if find_result then
            table.remove(table_4, find_result)
        end
        local value_7_10 = table_4
        local value_8_6 = value_4_7
        table.insert(value_7_10, value_8_6)
        captured_value_10(argument_3_3)

        return
    end
end
table_1.AddToStack = add_to_stack
local get_frame
do
    local captured_value_11 = table_2
    get_frame = function<T1>(argument_1_7: T1, argument_2_4: string)
        return captured_value_11[argument_2_4]
    end
end
table_1.GetFrame = get_frame
local register_frame
do
    local captured_value_12, captured_value_13 = table_2, table_3
    register_frame = function<T1>(argument_1_8: T1, argument_2_5, argument_3_4: string, argument_4)
        local value_6_16 = argument_2_5
        if (typeof(value_6_16)) ~= "Instance" then
            warn("WindowService: First argument must be a GuiObject")

            return
        end
        local value_7_12: string = "GuiObject"
        if not (argument_2_5:IsA(value_7_12)) then
            warn("WindowService: First argument must be a GuiObject")

            return
        end
        if captured_value_12[argument_3_4] ~= nil then
        end
        local value_5_11 = captured_value_12
        value_5_11[argument_3_4] = argument_2_5
        if argument_4 then
            local value_5_12 = captured_value_13
            value_5_12[argument_2_5] = argument_4
        end

        return
    end
end
table_1.RegisterFrame = register_frame

return table_1
