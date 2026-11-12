--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local replicated_first_value = game.ReplicatedFirst
local value_4: string = "ChinaPolicyService"
if (require_value(replicated_first_value:WaitForChild(value_4)):IsActive()) then
    local parent_value: Instance? = script.Parent
    local value_4_2: boolean = false
    parent_value.Visible = value_4_2
end

return
