--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_4: string = "Text"
local get_property_changed_signal_result = parent_value:GetPropertyChangedSignal(value_4)
local value_4_2: (() -> ())?
do
    local captured_value = parent_value
    value_4_2 = function(): ()
        local value_1: Instance? = captured_value
        local value_2_3: boolean = false
        value_1.TextScaled = value_2_3
        if not captured_value.TextFits then
            local value_1_3: Instance? = captured_value
            local value_2_4: boolean = true
            value_1_3.TextScaled = value_2_4
        end

        return
    end
end
get_property_changed_signal_result:Connect(value_4_2)

return
