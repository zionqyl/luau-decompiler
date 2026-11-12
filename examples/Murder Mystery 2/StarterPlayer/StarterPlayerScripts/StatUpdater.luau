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

local function get_gifts(): ()
    local owned_value = _G.PlayerData.Weapons.Owned
    local pairs_value, value_3_2, value_4_5 = pairs(owned_value)
    for key, value in pairs_value, value_3_2, value_4_5 do
        local value_5_7, value_6_5 = key, value
        if value_5_7 ~= "Gift" then
            continue
        end
        local g_value_5 = _G
        g_value_5.Gifts = value_6_5

        return
    end

    return
end

local g_value = _G
local value_3 = 0
g_value.Gifts = value_3
local g_value_2 = _G
value_3 = 1471244400
g_value_2.OfferEndTime = value_3
value_3 = _G
value_3 = value_3.OfferEndTime
local value_2 = value_3 - (os.time())
value_3 = _G
local value_4: boolean?
if not (0 < value_2) then
    value_4 = false
else
    value_4 = true
end
value_3.ShowItemPack = value_4
value_3 = _G
local value_4_2: boolean = true
value_3.CanJump = value_4_2
local value_2_2: boolean = true
value_3 = game
value_3 = value_3.PlaceId
if value_3 ~= 5895823254 then
    value_3 = game
    value_3 = value_3.PlaceId
    if value_3 ~= 5928494131 then
        value_2_2 = false
    else
        value_2_2 = true
    end
end
while true do
    value_3 = _G
    local game_value: DataModel = game
    local replicated_storage_value = game_value.ReplicatedStorage
    local remotes_value = replicated_storage_value.Remotes
    local extras_value = remotes_value.Extras
    local get_data2_value = extras_value.GetData2
    local invoke_server_result = get_data2_value:InvokeServer()
    value_3.PlayerData = invoke_server_result
    value_3 = wait
    local value_4_4: number = 0.1
    value_3(value_4_4)
    value_3 = _G
    value_3 = value_3.PlayerData
    if value_3 ~= nil then
        break
    end
end
value_3 = {}
local update_data
do
    local captured_value, closure_ready
    update_data = function()
        if not closure_ready then
            return
        end
        local g_value_6 = _G.PlayerData.Weapons.Owned
        local pairs_value_2, value_3_3, value_4_6 = pairs(g_value_6)
        local value_5_8, value_6_6
        for key_2, value_9 in pairs_value_2, value_3_3, value_4_6 do
            value_5_8, value_6_6 = key_2, value_9
            if value_5_8 ~= "Gift" then
                continue
            end
            local g_value_7 = _G
            g_value_7.Gifts = value_6_6
            break
        end
        g_value_6 = captured_value
        if not g_value_6 then
            g_value_6, pairs_value_2, value_3_3 = pairs(_G.PlayerData.Toys.Owned)
            for key_3, value_10 in g_value_6, pairs_value_2, value_3_3 do
                value_4_6, value_5_8 = key_3, value_10
                local value_7_4 = value_3
                if value_7_4[value_5_8] ~= nil then
                    continue
                end
                local g_value_8 = _G
                local player_data_value_2 = g_value_8.PlayerData
                local emotes_value = player_data_value_2.Emotes
                local owned_value_2 = emotes_value.Owned
                local value_8 = value_5_8
                table.insert(owned_value_2, value_8)
                value_6_6 = value_3
                local value_7_5: boolean = true
                value_6_6[value_5_8] = value_7_5
            end
        end

        return
    end
    captured_value = value_2_2
    closure_ready = true
end
local on_client_event_value = game.ReplicatedStorage.UpdateData2.OnClientEvent
local value_7
do
    local captured_value_2, closure_ready_2
    value_7 = function(argument_1, argument_2)
        if not closure_ready_2 then
            return
        end
        local g_value_9 = _G
        g_value_9.PlayerData = argument_1
        value_3 = {}
        captured_value_2()
        local update_data_client_value_2 = game.ReplicatedStorage.UpdateDataClient
        local value_5_9 = argument_2
        local value_6_7 = argument_1
        update_data_client_value_2:Fire(value_5_9, value_6_7)

        return
    end
    captured_value_2 = update_data
    closure_ready_2 = true
end
on_client_event_value:connect(value_7)
local event_value = game.ReplicatedStorage.UpdateDataClient.Event
local value_7_2 = update_data
event_value:connect(value_7_2)
local on_client_event_value_2 = game.ReplicatedStorage.UpdateData3.OnClientEvent
local value_7_3
do
    local captured_value_3, closure_ready_3
    value_7_3 = function(argument_1_2)
        if not closure_ready_3 then
            return
        end
        local g_value_10 = _G
        g_value_10.PlayerData = argument_1_2
        value_3 = {}
        captured_value_3()

        return
    end
    captured_value_3 = update_data
    closure_ready_3 = true
end
on_client_event_value_2:connect(value_7_3)
update_data()
local g_value_3 = _G
local value_6_4
do
    local captured_value_4 = update_data
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_4) then
        value_6_4 = closure_cache[1]
    else
        local closure_ready_4
        value_6_4 = function()
            if not closure_ready_4 then
                return
            end
            captured_value_4()

            return
        end
        closure_ready_4 = true
        if closure_cache[1] == nil then
            closure_cache[1] = value_6_4
            closure_cache[2] = captured_value_4
        end
    end
end
g_value_3.UpdateEmotes = value_6_4

return
