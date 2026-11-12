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
local value_4 = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_4)
local value_5: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_5)
value_4 = nil
while true do
    local value_7: string = "GetProfileData"
    local get_profile_data_child = inventory_child:WaitForChild(value_7)
    local invoke_server_result = get_profile_data_child:InvokeServer()
    value_4 = invoke_server_result
    local wait_value: (number?) -> (number) = task.wait
    local value_6_3: number = 0.1
    wait_value(value_6_3)
    if value_4 ~= nil then
        break
    end
end
local value_7_2: string = "ProfileDataChanged"
local value_2_3 = (inventory_child:WaitForChild(value_7_2))
local value_7_3: string = "InventoryDataChanged"
local inventory_data_changed_child = inventory_child:WaitForChild(value_7_3)
local value_8: string = "UpdateDataClient"
local update_data_client_child: Instance? = replicated_storage_service:WaitForChild(value_8)
local table_1: { Materials: boolean, Pets: boolean, Weapons: boolean } = {
    Weapons = true,
    Pets = true,
    Materials = true,
}
local legacy_convert_toys_to_emotes: (() -> ())?
do
    local closure_ready
    legacy_convert_toys_to_emotes = function(): ()
        if not closure_ready then
            return
        end
        local value_1_2 = value_4.Toys.Owned
        local value_2_4: nil = nil
        local value_3_4: nil = nil
        for key, value in value_1_2, value_2_4, value_3_4 do
            local value_4_2, value_5_6 = key, value
            local find_value = table.find
            local value_7_5 = value_4
            local emotes_value = value_7_5.Emotes
            local owned_value = emotes_value.Owned
            local value_8_2 = value_5_6
            local find_result = find_value(owned_value, value_8_2)
            if find_result then
                continue
            end
            local value_7_6 = value_4
            local emotes_value_2 = value_7_6.Emotes
            local owned_value_2 = emotes_value_2.Owned
            local value_8_3 = value_5_6
            local insert_value = table.insert
            insert_value(owned_value_2, value_8_3)
        end

        return
    end
    closure_ready = true
end
do
    local captured_value = legacy_convert_toys_to_emotes
    local legacy_update
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        legacy_update = closure_cache[1]
    else
        local closure_ready_2
        legacy_update = function(): ()
            if not closure_ready_2 then
                return
            end
            captured_value()

            return
        end
        closure_ready_2 = true
        if closure_cache[1] == nil then
            closure_cache[1] = legacy_update
            closure_cache[2] = captured_value
        end
    end
end
local on_profile_data_changed
do
    local captured_value_2, closure_ready_3
    on_profile_data_changed = function(argument_1: string, argument_2): ()
        if not closure_ready_3 then
            return
        end
        local value_3_5 = value_4
        value_3_5[argument_1] = argument_2
        local value_3_6 = captured_value_2
        local value_5_7: string = argument_1
        local value_6_7 = argument_2
        value_3_6:Fire(value_5_7, value_6_7)

        return
    end
    captured_value_2 = value_2_3
    closure_ready_3 = true
end
local on_inventory_item_changed: ((string, string, number) -> ())?
do
    local captured_value_3, captured_value_4, captured_value_5, captured_value_6, closure_ready_4
    on_inventory_item_changed = function(argument_1_2: string, argument_2_2: string, argument_3: number): ()
        if not closure_ready_4 then
            return
        end
        if captured_value_3[argument_1_2] then
            local owned_value_3 = value_4[argument_1_2].Owned
            owned_value_3[argument_2_2] = argument_3
        else
            if argument_3 ~= nil then
                if 0 < argument_3 then
                    local owned_value_4 = value_4[argument_1_2].Owned
                    local value_6_9: string = argument_2_2
                    table.insert(owned_value_4, value_6_9)
                end
            end
        end
        captured_value_4()
        local value_4_8 = captured_value_5
        local value_6_10: string = argument_1_2
        local value_7_7: string = argument_2_2
        local value_8_4: number? = argument_3
        value_4_8:Fire(value_6_10, value_7_7, value_8_4)
        local value_4_10: Instance? = captured_value_6
        local value_6_11: boolean = false
        local value_7_8 = value_4
        value_4_10:Fire(value_6_11, value_7_8)

        return
    end
    captured_value_3, captured_value_4, captured_value_5, captured_value_6 = table_1, legacy_convert_toys_to_emotes, inventory_data_changed_child, update_data_client_child
    closure_ready_4 = true
end
legacy_convert_toys_to_emotes()
local value_13: string = "ChangeProfileData"
local on_client_event_value = inventory_child:WaitForChild(value_13).OnClientEvent
local value_13_2 = on_profile_data_changed
on_client_event_value:Connect(value_13_2)
local value_13_3: string = "ChangeInventoryItem"
local on_client_event_value_2 = inventory_child:WaitForChild(value_13_3).OnClientEvent
local value_13_4: (string, string, number) -> () = on_inventory_item_changed
on_client_event_value_2:Connect(value_13_4)
local g_value = _G
g_value.UpdateEmotes = legacy_convert_toys_to_emotes

return value_4
