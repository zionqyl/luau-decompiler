--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_3: string = "Mode"
local mode_child = parent_value:WaitForChild(value_3)
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_5_3))
local value_5_4: string = "Button"
local activated_value = mode_child:WaitForChild(value_5_4).Activated
local value_5_5: (() -> ())?
do
    local captured_value = require_result
    value_5_5 = function(): ()
        local value_1_2 = captured_value
        local value_3_7: string = "ModeBrowser"
        value_1_2:ToggleFrame(value_3_7)

        return
    end
end
activated_value:Connect(value_5_5)

return
