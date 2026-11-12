--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {Fire = "http://www.roblox.com/asset/?id=9426132023"}
local parent_value: Instance? = script.Parent
local new_result: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local new_result_2: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local on_client_event_value = game.ReplicatedStorage.Remotes.Gameplay.KillEvent.OnClientEvent
local value_6
do
    local captured_value, captured_value_2, captured_value_3 = parent_value, new_result, new_result_2
    value_6 = function<T1, T2>(argument_1: T1, argument_2: T2, argument_3, argument_4): ()
        local pairs_value, value_6_2, value_7 = pairs(captured_value:GetChildren())
        local value_8, value_9
        for key, value in pairs_value, value_6_2, value_7 do
            value_8, value_9 = key, value
            local value_12: string = "Frame"
            local is_a_result = value_9:IsA(value_12)
            if not is_a_result then
                continue
            end
            local layout_order_value = value_9.LayoutOrder
            local value_10_2 = layout_order_value + 1
            value_9.LayoutOrder = value_10_2
        end
        pairs_value = script.NewEvent:Clone()
        value_6_2 = script.Parent
        pairs_value.Parent = value_6_2
        value_6_2 = ""
        if argument_3 then
            value_6_2 = "+" .. argument_3 .. " - "
        end
        local value_4_3 = argument_4 or "Eliminated"
        value_7 = pairs_value.EventName
        value_7.Text = value_4_3
        value_7 = game.Debris
        value_9 = pairs_value
        local value_10_3: number = 2
        value_7:AddItem(value_9, value_10_3)
        value_7 = pairs_value.EventName
        value_8 = 1
        value_7.TextTransparency = value_8
        value_7 = pairs_value.EventName
        value_8 = 1
        value_7.TextStrokeTransparency = value_8
        value_6_2 = game
        value_8 = "TweenService"
        value_6_2 = value_6_2:GetService(value_8)
        value_8 = pairs_value.EventName
        value_9 = captured_value_2
        local table_10 = {
            TextTransparency = 0,
            TextStrokeTransparency = 0.3,
            Position = 0,
        }
        local new_result_3 = UDim2.new(0, 0, 0, 0)
        table_10.Position = new_result_3
        value_6_2 = value_6_2:Create(value_8, value_9, table_10):Play()
        wait(1.5)
        value_6_2 = game
        value_8 = "TweenService"
        value_6_2 = value_6_2:GetService(value_8)
        value_8 = pairs_value.EventName
        value_9 = captured_value_3
        local table_10_2 = {TextTransparency = 1, TextStrokeTransparency = 1}
        value_6_2 = value_6_2:Create(value_8, value_9, table_10_2):Play()

        return
    end
end
on_client_event_value:Connect(value_6)

return
