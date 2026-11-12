--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local replicated_storage_value = game.ReplicatedStorage
local value_2: boolean = false
local value_3: boolean = true
if game.PlaceId ~= 5895823254 then
    if game.PlaceId ~= 5928494131 then
        value_3 = false
    else
        value_3 = true
    end
end
value_2 = value_3

local function fix_sync_data(): ()
    local g_value_5 = _G.Database
    local g_value_6 = _G.Database.Item
    g_value_5.Weapons = g_value_6
    g_value_5 = value_2
    if not g_value_5 then
        local value_3_2
        g_value_5, g_value_6, value_3_2 = pairs(_G.Database.Toys)
        for key, value in g_value_5, g_value_6, value_3_2 do
            local value_4_2, value_5_2 = key, value
            local g_value_7 = _G
            local database_value_3 = g_value_7.Database
            local emotes_value = database_value_3.Emotes
            emotes_value[value_4_2] = value_5_2
        end
    end

    return
end

local g_value = _G
local table_5 = {}
g_value.LoadedImages = table_5
local g_value_2 = _G
local invoke_server_result = replicated_storage_value.GetSyncData:InvokeServer()
g_value_2.Database = invoke_server_result
local database_value = _G.Database
local item_value = _G.Database.Item
database_value.Weapons = item_value
fix_sync_data()

return
