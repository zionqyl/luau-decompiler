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
local value_3_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_3_2)
local game_value_2: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_4)
local value_4_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_4_2)
local require_value = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_6_3))
local require_value_2 = require
local game_value_4: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_6_4)
local value_6_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service_4:WaitForChild(value_6_5)
local value_6_6: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_6_6))
local require_value_3 = require
local game_value_5: DataModel = game
local value_6_7: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_6_7)
local value_6_8: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_6_8)
local value_6_9: string = "WindowService"
local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_6_9))
local require_value_4 = require
local value_7: string = "ItemService"
local require_result_4 = require_value_4(client_services_child:WaitForChild(value_7))
local require_value_5 = require
local value_7_2: string = "InventoryService"
local require_result_5 = require_value_5(client_services_child:WaitForChild(value_7_2))
local require_value_6 = require
local value_8: string = "CraftingService"
local require_result_6 = require_value_6(client_services_child:WaitForChild(value_8))
local require_value_7 = require
local game_value_6: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_6:GetService(value_9)
local value_9_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_6:WaitForChild(value_9_2)
local value_9_3: string = "RecipeService"
local value_1_3 = (require_value_7(shared_services_child:WaitForChild(value_9_3)))
local parent_value: Instance? = script.Parent
local value_8_5: string = "Game"
local game_child = parent_value:WaitForChild(value_8_5)
local value_9_4: string = "Crafting2"
local crafting2_child = game_child:WaitForChild(value_9_4)
local value_10: string = "Contents"
local contents_child = crafting2_child:WaitForChild(value_10)
local value_10_2: string = "Results"
local value_6_14 = (contents_child:WaitForChild(value_10_2))
local value_10_3: string = "Input"
local input_child = value_6_14:WaitForChild(value_10_3)
local value_11: string = "Output"
local output_child = value_6_14:WaitForChild(value_11)
local value_12: string = "Contents"
local contents_child_2 = crafting2_child:WaitForChild(value_12)
local value_12_2: string = "Inventory"
local inventory_child = contents_child_2:WaitForChild(value_12_2)
local value_12_3: string = "ItemList"
local item_list_child = inventory_child:WaitForChild(value_12_3)
local get_salvage_inventory_result = require_result_6:GetSalvageInventory()
local value_14: string = "Weapons"
local value_15 = get_salvage_inventory_result
local value_16 = item_list_child
local generate_inventory_info_result = require_result_5:GenerateInventoryInfo(
    value_14,
    value_15,
    value_16
)
local value_11_6 = (require_result_6:GenerateMaterialInventory())
local value_15_2: string = "Materials"
local value_16_2 = value_11_6
local value_17 = item_list_child
local generate_inventory_info_result_2 = require_result_5:GenerateInventoryInfo(
    value_15_2,
    value_16_2,
    value_17
)
local initialize_salvage_items
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9 = require_result_5, generate_inventory_info_result, require_result_6, input_child, output_child, generate_inventory_info_result_2, value_6_14, remotes_child, value_1_3
    initialize_salvage_items = function()
        local value_1_4 = captured_value
        local value_3_5 = captured_value_2
        local value_4_12
        do
            local captured_value_10, captured_value_11, captured_value_12 = captured_value_3, captured_value_4, captured_value_5
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_10) and same_capture(
                closure_cache[3],
                captured_value_11
            ) and same_capture(closure_cache[4], captured_value_12) then
                value_4_12 = closure_cache[1]
            else
                local closure_ready_2
                value_4_12 = function(argument_1: string, argument_2): ()
                    if not closure_ready_2 then
                        return
                    end
                    local activated_value_2 = argument_2.Container.ActionButton.Activated
                    local value_5_12: (() -> ())?
                    do
                        local captured_value_13, captured_value_14, captured_value_15, captured_value_16, closure_ready
                        value_5_12 = function(): ()
                            if not closure_ready then
                                return
                            end
                            local value_1_17 = captured_value_13
                            local value_3_15 = captured_value_14
                            local value_4_15 = captured_value_15
                            local value_5_13: string = "Weapons"
                            local value_6_15: string? = captured_value_16
                            value_1_17:SelectItemForCrafting(
                                value_3_15,
                                value_4_15,
                                value_5_13,
                                value_6_15
                            )

                            return
                        end
                        captured_value_13, captured_value_14, captured_value_15, captured_value_16 = captured_value_10, captured_value_11, captured_value_12, argument_1
                        closure_ready = true
                    end
                    activated_value_2:Connect(value_5_12)

                    return
                end
                closure_ready_2 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_12
                    closure_cache[2], closure_cache[3], closure_cache[4] = captured_value_10, captured_value_11, captured_value_12
                end
            end
        end
        value_1_4:ForEachFrame(value_3_5, value_4_12)
        local value_1_6 = captured_value
        local value_3_6 = captured_value_6
        local value_4_13
        do
            local captured_value_17, captured_value_18, captured_value_19 = captured_value_3, captured_value_4, captured_value_5
            if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_17) and same_capture(
                closure_cache[7],
                captured_value_18
            ) and same_capture(closure_cache[8], captured_value_19) then
                value_4_13 = closure_cache[5]
            else
                local closure_ready_4
                value_4_13 = function(argument_1_2: string, argument_2_2): ()
                    if not closure_ready_4 then
                        return
                    end
                    local activated_value_3 = argument_2_2.Container.ActionButton.Activated
                    local value_5_14: (() -> ())?
                    do
                        local captured_value_20, captured_value_21, captured_value_22, captured_value_23, closure_ready_3
                        value_5_14 = function(): ()
                            if not closure_ready_3 then
                                return
                            end
                            local value_1_19 = captured_value_20
                            local value_3_17 = captured_value_21
                            local value_4_17 = captured_value_22
                            local value_5_15: string = "Materials"
                            local value_6_16: string? = captured_value_23
                            value_1_19:SelectItemForCrafting(
                                value_3_17,
                                value_4_17,
                                value_5_15,
                                value_6_16
                            )

                            return
                        end
                        captured_value_20, captured_value_21, captured_value_22, captured_value_23 = captured_value_17, captured_value_18, captured_value_19, argument_1_2
                        closure_ready_3 = true
                    end
                    activated_value_3:Connect(value_5_14)

                    return
                end
                closure_ready_4 = true
                if closure_cache[5] == nil then
                    closure_cache[5] = value_4_13
                    closure_cache[6], closure_cache[7], closure_cache[8] = captured_value_17, captured_value_18, captured_value_19
                end
            end
        end
        value_1_6:ForEachFrame(value_3_6, value_4_13)
        local value_1_8 = captured_value_7
        local value_3_7: string = "Input"
        local input_child_2 = value_1_8:WaitForChild(value_3_7)
        local value_3_8: string = "SingleContainer"
        local single_container_child = input_child_2:WaitForChild(value_3_8)
        local value_3_9: string = "Button"
        local activated_value = single_container_child:WaitForChild(value_3_9).Activated
        local value_3_10
        do
            local captured_value_24, captured_value_25, captured_value_26 = captured_value_3, captured_value_4, captured_value_7
            if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_24) and same_capture(
                closure_cache[11],
                captured_value_25
            ) and same_capture(closure_cache[12], captured_value_26) then
                value_3_10 = closure_cache[9]
            else
                local closure_ready_5
                value_3_10 = function(): ()
                    if not closure_ready_5 then
                        return
                    end
                    local value_1_21 = captured_value_24
                    local value_3_18 = captured_value_25
                    local output_value = captured_value_26.Output
                    value_1_21:ClearCrafting(value_3_18, output_value)

                    return
                end
                closure_ready_5 = true
                if closure_cache[9] == nil then
                    closure_cache[9] = value_3_10
                    closure_cache[10], closure_cache[11], closure_cache[12] = captured_value_24, captured_value_25, captured_value_26
                end
            end
        end
        activated_value:Connect(value_3_10)
        local value_1_13: Instance? = captured_value_8
        local value_3_11: string = "Inventory"
        local inventory_child_2 = value_1_13:WaitForChild(value_3_11)
        local value_3_12: string = "InventoryDataChanged"
        local event_value = inventory_child_2:WaitForChild(value_3_12).Event
        local value_3_13
        do
            local captured_value_27, captured_value_28, captured_value_29 = captured_value_2, captured_value_9, captured_value
            if closure_cache[13] ~= nil and same_capture(closure_cache[14], captured_value_27) and same_capture(
                closure_cache[15],
                captured_value_28
            ) and same_capture(closure_cache[16], captured_value_29) then
                value_3_13 = closure_cache[13]
            else
                local closure_ready_6
                value_3_13 = function(argument_1_3: string, argument_2_3: string, argument_3: number): ()
                    if not closure_ready_6 then
                        return
                    end
                    if not captured_value_27.Frames[argument_2_3] then
                        return
                    end
                    local value_5_17 = captured_value_28
                    local value_7_9: string = argument_2_3
                    if not (value_5_17:IsItemSalvageable(value_7_9)) then
                        return
                    end
                    local value_5_19 = captured_value_29
                    local value_7_10 = captured_value_27
                    local value_8_10: string = argument_2_3
                    local value_9_9: number = argument_3
                    value_5_19:ApplyChangesToInventoryInfo(value_7_10, value_8_10, value_9_9)

                    return
                end
                closure_ready_6 = true
                if closure_cache[13] == nil then
                    closure_cache[13] = value_3_13
                    closure_cache[14], closure_cache[15], closure_cache[16] = captured_value_27, captured_value_28, captured_value_29
                end
            end
        end
        event_value:Connect(value_3_13)

        return
    end
end
do
    local captured_value_30, captured_value_31, captured_value_32 = require_result_3, crafting2_child, initialize_salvage_items

    local function initialize()
        local value_1_23 = captured_value_30
        local value_3_19 = captured_value_31
        local value_4_20: string = "Crafting"
        value_1_23:RegisterFrame(value_3_19, value_4_20)
        captured_value_32()

        return
    end
end
local value_16_3 = crafting2_child
local value_17_2: string = "Crafting"
require_result_3:RegisterFrame(value_16_3, value_17_2)
initialize_salvage_items()

return
