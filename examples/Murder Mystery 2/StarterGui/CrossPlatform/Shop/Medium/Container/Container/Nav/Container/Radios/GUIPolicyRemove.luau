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
    local changed_value = script.Parent.Changed

    local function value_5(): ()
        local parent_value_2: Instance? = script.Parent
        local value_2_3: boolean = false
        parent_value_2.Visible = value_2_3

        return
    end

    changed_value:Connect(value_5)
end

return
