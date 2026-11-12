--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local sheriff_victory_value = script.Parent.SheriffVictory
local value_2: boolean = true
sheriff_victory_value.Visible = value_2
local game_value: DataModel = game
local value_4: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_4)
local new_result: TweenInfo = TweenInfo.new(
    0.3,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)
local table_4 = {nil, nil, nil}
local value_7 = sheriff_victory_value.Container
local value_8 = new_result
local value_9 = {[("Size")] = nil}
local new_result_2 = UDim2.new(1, 0, 1, 0)
value_9.Size = new_result_2
local quad_value = tween_service:Create(value_7, value_8, value_9)
value_8 = sheriff_victory_value.KnifeRight
value_9 = new_result
local table_10 = {[("Position")] = nil, [("Position")] = nil}
local new_result_3 = UDim2.new(0.975, 0, 0.5, 0)
table_10.Position = new_result_3
local value_11_2: number = 0
table_10.Rotation = value_11_2
local out_value = tween_service:Create(value_8, value_9, table_10)
value_9 = sheriff_victory_value.KnifeLeft
local value_10: TweenInfo = new_result
local table_11 = {[("Position")] = nil, [("Position")] = nil}
local new_result_4 = UDim2.new(0.025, 0, 0.5, 0)
table_11.Position = new_result_4
local value_12_3: number = 0
table_11.Rotation = value_12_3
table_4 = {quad_value, out_value, tween_service:Create(value_9, value_10, table_11)}
quad_value, out_value, value_7 = pairs(table_4)
for key, value in quad_value, out_value, value_7 do
    value_8, value_9 = key, value
    value_9:Play()
end

return
