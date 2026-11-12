--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

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

local parent_value_6 = script.Parent.Parent.Parent.Parent.Parent.Parent
local list_value = script.Parent.Parent.Parent.List
local parent_value_10: Instance? = script.Parent
do
    local captured_value = parent_value_10
    local chat
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        chat = closure_cache[1]
    else
        local closure_ready
        chat = function(argument_1): ()
            if not closure_ready then
                return
            end
            local value_2: Instance? = captured_value
            local value_4: string = "AnimatedText"
            local value_5 = argument_1
            value_2:SetAttribute(value_4, value_5)
            if argument_1 ~= "" then
                script.Parent.Parent.ReaverChat:Fire()
            end

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = chat
            closure_cache[2] = captured_value
        end
    end
end
local table_5 = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_6 = "\"Welcome to the event...\""
local value_7 = "\"Welcome to the event...\""
local value_8 = "\"Welcome to the event...\""
local value_9 = "\"Boo! Scared you!\""
local value_10 = "\"Back again?\""
local value_11 = "\"What will you unlock next?\""
table_5[1], table_5[2], table_5[3], table_5[4], table_5[5], table_5[6] = value_6, value_7, value_8, value_9, value_10, value_11
value_8 = "Visible"
value_6 = parent_value_6:GetPropertyChangedSignal(value_8)
do
    local captured_value_2, captured_value_3, captured_value_4 = parent_value_6, table_5, parent_value_10
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) and same_capture(
        closure_cache[5],
        captured_value_3
    ) and same_capture(closure_cache[6], captured_value_4) then
        value_8 = closure_cache[3]
    else
        local closure_ready_2
        value_8 = function()
            if not closure_ready_2 then
                return
            end
            local parent_value_13, parent_value_14, random_result, random_result_2, random_value, random_value_2, reaver_chat_value_2, script_value_5, value_1, value_1_2, value_1_3, value_2_4, value_2_5, value_2_6, value_3_3, value_3_6, value_4_2, value_4_3, value_4_4, value_5_2, value_5_3, value_6_2, visible_value
            local control_state = 0
            while true do
                if control_state < 3 then
                    if control_state < 1 then
                        value_1 = captured_value_2
                        visible_value = value_1.Visible
                        control_state = if visible_value ~= true then 5 else 1
                    else
                        if control_state < 2 then
                            random_value = math.random
                            value_2_4 = 1
                            value_3_3 = 3
                            random_result = random_value(value_2_4, value_3_3)
                            control_state = if random_result ~= 1 then 4 else 2
                        else
                            value_2_5 = captured_value_3
                            random_value_2 = math.random
                            value_4_2 = 1
                            value_6_2 = captured_value_3
                            value_5_2 = #value_6_2
                            random_result_2 = random_value_2(value_4_2, value_5_2)
                            value_1_2 = value_2_5[random_result_2]
                            value_2_6 = captured_value_4
                            value_4_3 = "AnimatedText"
                            value_5_3 = value_1_2
                            value_2_6:SetAttribute(value_4_3, value_5_3)
                            control_state = if value_1_2 == "" then 5 else 3
                        end
                    end
                else
                    if control_state < 4 then
                        script_value_5 = script
                        parent_value_13 = script_value_5.Parent
                        parent_value_14 = parent_value_13.Parent
                        reaver_chat_value_2 = parent_value_14.ReaverChat
                        reaver_chat_value_2:Fire()

                        return
                    else
                        if control_state < 5 then
                            value_1_3 = captured_value_4
                            value_3_6 = "AnimatedText"
                            value_4_4 = ""
                            value_1_3:SetAttribute(value_3_6, value_4_4)
                            control_state = 5
                        else
                            return
                        end
                    end
                end
            end
        end
        closure_ready_2 = true
        if closure_cache[3] == nil then
            closure_cache[3] = value_8
            closure_cache[4], closure_cache[5], closure_cache[6] = captured_value_2, captured_value_3, captured_value_4
        end
    end
end
value_6:connect(value_8)
value_6 = script
value_6 = value_6.Parent
value_6 = value_6.Parent
value_6 = value_6.Parent
value_6 = value_6.List
value_6 = value_6.MouseLeave
value_8 = function(): ()
    return
end
value_6:Connect(value_8)
value_6 = os.clock
value_6 = value_6()
value_7, value_8, value_9 = pairs(list_value:GetChildren())
for key, value in value_7, value_8, value_9 do
    value_10, value_11 = key, value
    local value_14: string = "Frame"
    local is_a_result = value_11:IsA(value_14)
    if not is_a_result then
        continue
    end
    local mouse_enter_value = value_11.MouseEnter
    local value_14_2
    do
        local captured_value_5, captured_value_6, closure_ready_3
        value_14_2 = function(): ()
            if not closure_ready_3 then
                return
            end
            if 4 <= (os.clock()) - value_6 then
                if (math.random(1, 5)) == 5 then
                    local value_1_6 = captured_value_5
                    local value_3_9: string = "ChatText"
                    local chat_text_value = value_1_6:GetAttribute(value_3_9)
                    local value_2_13 = captured_value_6
                    local value_4_5: string = "AnimatedText"
                    local value_5_4 = chat_text_value
                    value_2_13:SetAttribute(value_4_5, value_5_4)
                    if chat_text_value ~= "" then
                        script.Parent.Parent.ReaverChat:Fire()
                    end
                    value_6 = (os.clock())

                    return
                end
                local value_1_8 = captured_value_6
                local value_3_12: string = "AnimatedText"
                local value_4_6: string = ""
                value_1_8:SetAttribute(value_3_12, value_4_6)
            end

            return
        end
        captured_value_5, captured_value_6 = value_11, parent_value_10
        closure_ready_3 = true
    end
    mouse_enter_value:connect(value_14_2)
end

return
