--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local new_result = UDim2.new(0, 0, 1, 0)
local in_value = Enum.EasingDirection.In
local linear_value = Enum.EasingStyle.Linear
local value_6_2: number = 4
parent_value:TweenSize(new_result, in_value, linear_value, value_6_2)
task.wait(4)
local script_value_2: LuaSourceContainer = script
local value_3: string = "TrapGUI"
script_value_2:FindFirstAncestor(value_3):Destroy()

return
