--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("AnimationTargetLocation")] = nil,
    [("AnimationTargetLocation")] = nil,
    [("AnimationTargetLocation")] = nil,
}
local value_2: nil = nil
table_1.AnimationTargetLocation = value_2
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.ItemReceived = new_result
local new_result_2: BindableEvent = Instance.new("BindableEvent")
table_1.ItemClaimsComplete = new_result_2
local add_new_item
do
    local captured_value = table_1
    add_new_item = function<T1>(argument_1: T1, argument_2: string, argument_3: string, argument_4: number)
        local item_received_value: BindableEvent = captured_value.ItemReceived
        local value_7: string = argument_2
        local value_8: string = argument_3
        local value_9: number = argument_4
        item_received_value:Fire(value_7, value_8, value_9)

        return
    end
end
table_1.AddNewItem = add_new_item

return table_1
