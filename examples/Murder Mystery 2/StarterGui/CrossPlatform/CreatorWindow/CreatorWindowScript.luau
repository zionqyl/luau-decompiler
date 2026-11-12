--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local closure_cache = {}

local function same_capture(left_capture, right_capture): boolean
    if left_capture == nil or right_capture == nil then
        return left_capture == right_capture
    end
    if left_capture ~= left_capture or right_capture ~= right_capture then
        return false
    end
    local identity_lookup = {[left_capture] = true}

    return identity_lookup[right_capture] == true
end

local game_value: DataModel = game
local value_3: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_3)
local value_3_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_3_2)
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
local value_5_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_5_3))
local parent_value: Instance? = script.Parent
local value_6: string = "Commands"
local commands_child = parent_value:WaitForChild(value_6)
local value_6_2: string = "List"
local list_child = commands_child:WaitForChild(value_6_2)
local value_7 = "Extras"
local extras_child = remotes_child:WaitForChild(value_7)
value_7 = "GetCreatorStatus"
local invoke_server_result, value_6_6 = extras_child:WaitForChild(value_7):InvokeServer()
if not invoke_server_result then
    parent_value:Destroy()

    return
end
value_7 = false
parent_value.Visible = value_7
local value_8, value_9
value_7, value_8, value_9 = list_child:GetChildren()
local value_10
for key, value in value_7, value_8, value_9 do
    local value_11
    value_10, value_11 = key, value
    local value_14: string = "Frame"
    local is_a_result = value_11:IsA(value_14)
    if not is_a_result then
        continue
    end
    local value_5_9: boolean = true
    local name_value = value_11.Name
    local value_12_2 = value_6_6[name_value]
    if value_12_2 ~= true then
        local name_value_2 = value_11.Name
        local value_12_3 = value_6_6[name_value_2]
        if value_12_3 ~= "PrivateServer" then
            value_5_9 = false
        else
            value_5_9 = true
        end
    end
    local name_value_3 = value_11.Name
    local value_12_4 = value_6_6[name_value_3]
    local value_1_3: boolean?
    if value_12_4 ~= "PrivateServer" then
        value_1_3 = false
    else
        value_1_3 = true
    end
    if value_1_3 then
        local script_value_2: LuaSourceContainer = script
        local value_14_2: string = "PrivateServer"
        local private_server_child: Instance? = script_value_2:WaitForChild(value_14_2)
        local cloned_value = private_server_child:Clone()
        local title_value = value_11.Title
        cloned_value.Parent = title_value
        local value_13_4: boolean = true
        cloned_value.Visible = value_13_4
    end
    value_11.Visible = value_5_9
end
value_9 = "Title"
value_7 = parent_value:WaitForChild(value_9)
value_9 = "Close"
value_7 = value_7:WaitForChild(value_9)
value_9 = "Button"
value_7 = value_7:WaitForChild(value_9).Activated
do
    local captured_value = parent_value
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        value_9 = closure_cache[1]
    else
        local closure_ready
        value_9 = function(): ()
            if not closure_ready then
                return
            end
            local value_1_4: Instance? = captured_value
            local value_2_3: boolean = false
            value_1_4.Visible = value_2_3

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = value_9
            closure_cache[2] = captured_value
        end
    end
end
value_7:Connect(value_9)
value_9 = parent_value
value_10 = "CreatorWindow"
require_result:RegisterFrame(value_9, value_10)

return
