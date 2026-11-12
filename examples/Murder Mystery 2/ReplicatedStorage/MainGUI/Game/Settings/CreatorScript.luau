--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_3)
local value_3_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_3_2)
local value_4: string = "Extras"
local extras_child = remotes_child:WaitForChild(value_4)
local value_4_2: string = "GetCreatorStatus"
local invoke_server_result, value_3_6 = extras_child:WaitForChild(value_4_2):InvokeServer()
local parent_value: Instance? = script.Parent
local value_5: string = "Creator"
local creator_child = parent_value:WaitForChild(value_5)
local require_value = require
local game_value_2: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "WindowService"
local value_1_3 = (require_value(modules_child:WaitForChild(value_7_3)))
creator_child.Visible = invoke_server_result
local value_6_4: string = "Button"
local activated_value = creator_child:WaitForChild(value_6_4).Activated
local value_6_5: (() -> ())?
do
    local captured_value = value_1_3
    value_6_5 = function(): ()
        local value_1_4 = captured_value
        local value_3_8: string = "CreatorWindow"
        value_1_4:ToggleFrame(value_3_8)

        return
    end
end
activated_value:Connect(value_6_5)

return
