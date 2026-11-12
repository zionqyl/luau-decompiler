--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value = game
local value_4 = "ReplicatedStorage"
local replicated_storage_service = game_value:GetService(value_4)
local value_4_2 = "Database"
local database_child = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3 = "Sync"
local require_result = require_value(database_child:WaitForChild(value_4_3))
do
    local captured_value = require_result

    local function on_database_updated(argument_1: string, argument_2)
        local value_3_4 = argument_2
        local value_4_4 = nil
        local value_5 = nil
        for key_2, value_15 in value_3_4, value_4_4, value_5 do
            local value_6, value_7 = key_2, value_15
            local value_8 = captured_value[argument_1]
            local value_9 = {}
            value_8[value_6] = value_9
            value_8 = value_7
            value_9 = nil
            local value_10 = nil
            for key, value in value_8, value_9, value_10 do
                local value_11, value_12 = key, value
                local value_14 = captured_value
                local value_13 = value_14[argument_1]
                value_13[value_6] = value_12
            end
        end

        return
    end
end

return
