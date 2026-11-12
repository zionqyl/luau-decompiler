--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("Bind")] = nil, [("Bind")] = nil}
local game_value: DataModel = game
local value_4: string = "ContextActionService"
local context_action_service: Instance = game_value:GetService(value_4)
local value_3_2
do
    local captured_value = context_action_service
    value_3_2 = function(argument_1, argument_2, argument_3): ()
        local value_4_2
        do
            local captured_value_2, closure_ready
            value_4_2 = function<T1>(argument_1_2: T1, argument_2_2): ()
                if not closure_ready then
                    return
                end
                if argument_2_2 == Enum.UserInputState.Begin then
                    if not _G.PauseBinds then
                        captured_value_2()
                    end
                end

                return
            end
            captured_value_2 = argument_3
            closure_ready = true
        end
        local value_5: Instance = captured_value
        local value_7 = argument_1
        local value_8 = value_4_2
        local value_9: boolean = false
        local value_10 = argument_2
        value_5:BindAction(value_7, value_8, value_9, value_10)

        return
    end
end
table_1.Bind = value_3_2
local value_3_3
do
    local captured_value_3 = context_action_service
    value_3_3 = function<T2, T3>(argument_1_3, argument_2_3: T2, argument_3_2: T3): ()
        local value_4_3: Instance = captured_value_3
        local value_6_2 = argument_1_3
        value_4_3:UnbindAction(value_6_2)

        return
    end
end
table_1.Unbind = value_3_3

return table_1
