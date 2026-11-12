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

local require_value = require
local script_value: LuaSourceContainer = script
local value_4: string = "GodlyShop"
local require_result = require_value(script_value:WaitForChild(value_4))
local require_value_2 = require
local game_value: DataModel = game
local value_4_2: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4_2)
local value_4_3: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_4_3)
local value_4_4: string = "Button"
local require_result_2 = require_value_2(client_services_child:WaitForChild(value_4_4))
local require_value_3 = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
local value_5_3: string = "WindowService"
local require_result_3 = require_value_3(modules_child:WaitForChild(value_5_3))
local parent_value: Instance? = script.Parent
local value_6: string = "Container"
local container_child = parent_value:WaitForChild(value_6)
local value_6_2: string = "ItemPack"
local item_pack_child = container_child:WaitForChild(value_6_2)
local initialize
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = require_result_3, parent_value, require_result_2, item_pack_child
    initialize = function()
        local value_1 = captured_value
        local value_3_8: Instance? = captured_value_2
        local value_4_10: string = "ItemPack"
        value_1:RegisterFrame(value_3_8, value_4_10)
        local create_button_value = captured_value_3.createButton
        local value_2_6 = captured_value_4
        local value_4_11: string = "Title"
        local title_child = value_2_6:WaitForChild(value_4_11)
        local value_4_12: string = "Close"
        local close_child = title_child:WaitForChild(value_4_12)
        local value_3_11
        do
            local captured_value_5 = captured_value
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_5) then
                value_3_11 = closure_cache[1]
            else
                local closure_ready
                value_3_11 = function(): ()
                    if not closure_ready then
                        return
                    end
                    captured_value_5:Back()

                    return
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_11
                    closure_cache[2] = captured_value_5
                end
            end
        end
        local create_button_result = create_button_value(close_child, value_3_11)

        return
    end
end
initialize()

return
