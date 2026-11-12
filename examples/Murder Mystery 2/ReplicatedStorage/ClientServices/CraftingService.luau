--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("CurrentlyCrafting")] = nil,
    [("CurrentlyCrafting")] = nil,
    [("CurrentlyCrafting")] = nil,
    [("CurrentlyCrafting")] = nil,
    [("CurrentlyCrafting")] = nil,
}
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
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
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_7_3))
local require_value_3 = require
local value_8: string = "InventoryService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_8))
local require_value_4 = require
local value_8_2: string = "ItemService"
local require_result_4 = require_value_4(client_services_child:WaitForChild(value_8_2))
local require_value_5 = require
local game_value_5: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_9)
local value_9_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_5:WaitForChild(value_9_2)
local value_9_3: string = "RecipeService"
local value_2_3 = (require_value_5(shared_services_child:WaitForChild(value_9_3)))
local table_6 = {}
table_1.CurrentlyCrafting = table_6
local is_material_craftable: (<T1>(T1, string) -> (boolean))?
do
    local captured_value = require_result
    is_material_craftable = function<T1>(argument_1: T1, argument_2: string): boolean
        if argument_2 == nil then
            return false
        end
        local value_3_6 = captured_value.Materials[argument_2]
        if value_3_6 == nil then
            return false
        end
        if not value_3_6.Craftable then
            return false
        end

        return true
    end
end
table_1.IsMaterialCraftable = is_material_craftable
local get_weapon_salvage_rewards
do
    local captured_value_2 = require_result
    get_weapon_salvage_rewards = function<T1>(argument_1_2: T1, argument_2_2: string)
        local rarity_value = captured_value_2.Weapons[argument_2_2].Rarity
        local value_3_8 = captured_value_2.SalvageRewards[argument_2_2]
        if value_3_8 then
            value_3_8 = captured_value_2.SalvageRewards[argument_2_2].Rewards
        end
        local value_5_11 = captured_value_2.SalvageRewards[rarity_value]
        if value_5_11 then
            value_5_11 = captured_value_2.SalvageRewards[rarity_value].Rewards
        end
        if value_3_8 then
            return value_3_8
        end
        if value_5_11 then
            return value_5_11
        end

        return {}
    end
end
table_1.GetWeaponSalvageRewards = get_weapon_salvage_rewards
local get_salvage_inventory
do
    local captured_value_3, captured_value_4 = require_result_2, value_2_3
    get_salvage_inventory = function<T1>(argument_1_3: T1)
        local table_2 = {}
        local value_3_10 = captured_value_3.Weapons.Owned
        local value_4_13: nil = nil
        local value_5_13: nil = nil
        for key, value in value_3_10, value_4_13, value_5_13 do
            local value_6_11, value_7_9 = key, value
            local value_8_6 = captured_value_4
            local value_10 = value_6_11
            local is_item_salvageable_result = value_8_6:IsItemSalvageable(value_10)
            if not is_item_salvageable_result then
                continue
            end
            table_2[value_6_11] = value_7_9
        end

        return table_2
    end
end
table_1.GetSalvageInventory = get_salvage_inventory
local generate_material_inventory
do
    local captured_value_5, captured_value_6 = require_result_2, table_1
    generate_material_inventory = function<T1>(argument_1_4: T1)
        local table_2_2 = {}
        local value_3_11 = captured_value_5.Materials.Owned
        local value_4_14: nil = nil
        local value_5_14: nil = nil
        for key_2, value_11 in value_3_11, value_4_14, value_5_14 do
            local value_6_12, value_7_10 = key_2, value_11
            local value_8_8 = captured_value_6
            local value_10_2 = value_6_12
            local is_material_craftable_result = value_8_8:IsMaterialCraftable(value_10_2)
            if not is_material_craftable_result then
                continue
            end
            table_2_2[value_6_12] = value_7_10
        end

        return table_2_2
    end
end
table_1.GenerateMaterialInventory = generate_material_inventory
local clear_multiple_container
do
    local captured_value_7 = require_result_4
    clear_multiple_container = function<T1>(argument_1_5: T1, argument_2_3): ()
        local multiple_container_value, value_4_15, value_5_15 = argument_2_3.MultipleContainer:GetChildren()
        for key_3, value_13 in multiple_container_value, value_4_15, value_5_15 do
            local value_6_13, value_7_11 = key_3, value_13
            local value_10_3: string = "Frame"
            local is_a_result = value_7_11:IsA(value_10_3)
            if not is_a_result then
                continue
            end
            local value_8_11 = captured_value_7
            local value_10_4 = value_7_11
            local value_11_2: nil = nil
            local value_12: number = 1
            value_8_11:ApplyMiniItemFrame(value_10_4, value_11_2, value_12)
        end

        return
    end
end
table_1.ClearMultipleContainer = clear_multiple_container
local clear_crafting
do
    local captured_value_8 = table_1
    clear_crafting = function<T1>(argument_1_6: T1, argument_2_4, argument_3)
        local value_4_16 = captured_value_8
        local table_5 = {}
        value_4_16.CurrentlyCrafting = table_5
        local single_container_value = argument_2_4.SingleContainer
        local value_5_16: boolean = false
        single_container_value.Visible = value_5_16
        local multiple_container_value_2 = argument_2_4.MultipleContainer
        local value_5_17: boolean = false
        multiple_container_value_2.Visible = value_5_17
        local single_container_value_2 = argument_3.SingleContainer
        local value_5_18: boolean = false
        single_container_value_2.Visible = value_5_18
        local multiple_container_value_3 = argument_3.MultipleContainer
        local value_5_19: boolean = false
        multiple_container_value_3.Visible = value_5_19

        return
    end
end
table_1.ClearCrafting = clear_crafting
local select_item_for_crafting
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13 = require_result, require_result_4, table_1, require_result_2, value_2_3
    select_item_for_crafting = function<T1>(argument_1_7: T1, argument_2_5, argument_3_2, argument_4: string, argument_5: string)
        local amount_value, amount_value_2, get_item_info_result, item_id_value, multiple_container_value_4, multiple_container_value_5, multiple_container_value_6, single_container_value_3, value_10_5, value_11_3, value_12_2, value_13_2, value_14, value_14_2, value_14_3: nil, value_14_4, value_15, value_15_3, value_15_4, value_15_5, value_16_2, value_16_4, value_16_5, value_17, value_17_3, value_17_4, value_18, value_18_2, value_18_3, value_19, value_20, value_20_2, value_21, value_22, value_6_14, value_7_12, value_8_13
        local control_state = 0
        while true do
            if control_state < 19 then
                if control_state < 7 then
                    if control_state < 2 then
                        if control_state < 1 then
                            value_8_13 = captured_value_9
                            value_7_12 = value_8_13[argument_4]
                            value_6_14 = value_7_12[argument_5]
                            control_state = if value_6_14 then 2 else 1
                        else
                            return
                        end
                    else
                        if control_state < 3 then
                            control_state = if argument_4 ~= "Weapons" then 7 else 3
                        else
                            if control_state < 6 then
                                value_7_12 = captured_value_10
                                single_container_value_3 = argument_2_5.SingleContainer.NewItem
                                value_10_5 = value_6_14
                                value_11_3 = 1
                                value_7_12:ApplyItemToFrame(
                                    single_container_value_3,
                                    value_10_5,
                                    value_11_3
                                )
                                value_7_12 = argument_2_5.SingleContainer
                                value_8_13 = true
                                value_7_12.Visible = value_8_13
                                value_7_12 = argument_2_5.MultipleContainer
                                value_8_13 = false
                                value_7_12.Visible = value_8_13
                                value_7_12 = argument_3_2.SingleContainer
                                value_8_13 = false
                                value_7_12.Visible = value_8_13
                                value_7_12 = argument_3_2.MultipleContainer
                                value_8_13 = true
                                value_7_12.Visible = value_8_13
                                value_7_12 = captured_value_11
                                single_container_value_3 = argument_3_2
                                value_7_12:ClearMultipleContainer(single_container_value_3)
                                value_7_12 = captured_value_11
                                single_container_value_3 = argument_5
                                value_7_12 = value_7_12:GetWeaponSalvageRewards(
                                    single_container_value_3
                                )
                                value_8_13 = 1
                                single_container_value_3 = value_7_12
                                value_10_5 = nil
                                value_11_3 = nil
                                for key_4, value_23 in single_container_value_3, value_10_5, value_11_3 do
                                    value_12_2, value_13_2 = key_4, value_23
                                    amount_value = value_13_2.Amount
                                    value_14 = amount_value[1]
                                    value_15 = captured_value_10
                                    value_17 = "Materials"
                                    value_18 = value_12_2
                                    get_item_info_result = value_15:GetItemInfo(value_17, value_18)
                                    value_16_2 = captured_value_10
                                    multiple_container_value_4 = argument_3_2.MultipleContainer
                                    value_21 = "Material"
                                    value_22 = value_8_13
                                    value_20 = value_21 .. value_22
                                    value_18_2 = multiple_container_value_4[value_20]
                                    value_19 = get_item_info_result
                                    value_20_2 = value_14
                                    value_16_2:ApplyMiniItemFrame(value_18_2, value_19, value_20_2)
                                    value_8_13 = value_8_13 + 1
                                end
                                control_state = 6
                            else
                                single_container_value_3 = captured_value_11
                                value_10_5 = {nil}
                                value_11_3 = {
                                    itemType = "Weapons",
                                    itemID = 0,
                                    amount = 1,
                                }
                                value_11_3.itemID = argument_5
                                value_10_5[1] = value_11_3
                                single_container_value_3.CurrentlyCrafting = value_10_5

                                return
                            end
                        end
                    end
                else
                    if control_state < 16 then
                        if control_state < 8 then
                            control_state = if argument_4 ~= "Materials" then 33 else 8
                        else
                            if control_state < 12 then
                                value_7_12 = captured_value_11.CurrentlyCrafting
                                value_8_13 = nil
                                single_container_value_3 = nil
                                for key_5, value_24 in value_7_12, value_8_13, single_container_value_3 do
                                    value_10_5, value_11_3 = key_5, value_24
                                    if value_11_3.itemType ~= "Weapons" then
                                        continue
                                    end
                                    value_12_2 = captured_value_11
                                    value_13_2 = {}
                                    value_12_2.CurrentlyCrafting = value_13_2
                                    break
                                end
                                control_state = 12
                            else
                                value_7_12 = nil
                                value_8_13 = captured_value_11.CurrentlyCrafting
                                single_container_value_3 = nil
                                value_10_5 = nil
                                for key_6, value_25 in value_8_13, single_container_value_3, value_10_5 do
                                    value_11_3, value_12_2 = key_6, value_25
                                    value_13_2 = value_12_2.itemID
                                    if value_13_2 ~= argument_5 then
                                        continue
                                    end
                                    value_7_12 = value_11_3
                                    break
                                end
                                control_state = 16
                            end
                        end
                    else
                        if control_state < 17 then
                            control_state = if not value_7_12 then 19 else 17
                        else
                            if control_state < 18 then
                                value_8_13 = captured_value_11.CurrentlyCrafting[value_7_12].amount
                                value_10_5 = captured_value_12.Materials.Owned
                                single_container_value_3 = value_10_5[argument_5]
                                control_state = if not (value_8_13 < single_container_value_3) then 21 else 18
                            else
                                value_8_13 = captured_value_11.CurrentlyCrafting[value_7_12]
                                single_container_value_3 = value_8_13.amount + 1
                                value_8_13.amount = single_container_value_3
                                control_state = 21
                            end
                        end
                    end
                end
            else
                if control_state < 28 then
                    if control_state < 21 then
                        if control_state < 20 then
                            value_8_13 = #captured_value_11.CurrentlyCrafting
                            single_container_value_3 = 4
                            control_state = if not (value_8_13 < single_container_value_3) then 21 else 20
                        else
                            single_container_value_3 = captured_value_11.CurrentlyCrafting
                            value_10_5 = {
                                itemType = "Materials",
                                itemID = 0,
                                amount = 1,
                            }
                            value_10_5.itemID = argument_5
                            value_8_13 = table.insert
                            value_8_13(single_container_value_3, value_10_5)
                            control_state = 21
                        end
                    else
                        if control_state < 26 then
                            value_10_5 = 1
                            value_8_13 = 4
                            single_container_value_3 = 1
                            for index = value_10_5, value_8_13, single_container_value_3 do
                                value_10_5 = index
                                value_11_3 = captured_value_11.CurrentlyCrafting
                                value_7_12 = value_11_3[value_10_5]
                                if value_7_12 then
                                    value_11_3 = captured_value_10
                                    value_13_2 = "Materials"
                                    item_id_value = value_7_12.itemID
                                    value_11_3 = value_11_3:GetItemInfo(value_13_2, item_id_value)
                                    value_12_2 = captured_value_10
                                    multiple_container_value_5 = argument_2_5.MultipleContainer
                                    value_17_3 = "Material"
                                    value_18_3 = value_10_5
                                    value_16_4 = value_17_3 .. value_18_3
                                    value_14_2 = multiple_container_value_5[value_16_4]
                                    value_15_3 = value_11_3
                                    amount_value_2 = value_7_12.amount
                                    value_12_2:ApplyMiniItemFrame(
                                        value_14_2,
                                        value_15_3,
                                        amount_value_2
                                    )
                                else
                                    value_11_3 = captured_value_10
                                    multiple_container_value_6 = argument_2_5.MultipleContainer
                                    value_16_5 = "Material"
                                    value_17_4 = value_10_5
                                    value_15_4 = value_16_5 .. value_17_4
                                    value_13_2 = multiple_container_value_6[value_15_4]
                                    value_14_3 = nil
                                    value_15_5 = 0
                                    value_11_3:ApplyMiniItemFrame(
                                        value_13_2,
                                        value_14_3,
                                        value_15_5
                                    )
                                end
                            end
                            control_state = 26
                        else
                            if control_state < 27 then
                                value_8_13 = captured_value_13
                                value_10_5 = captured_value_11.CurrentlyCrafting
                                value_8_13 = value_8_13:GetCraftingResult(value_10_5)
                                control_state = if not value_8_13 then 28 else 27
                            else
                                single_container_value_3 = captured_value_10
                                value_11_3 = "Recipes"
                                value_12_2 = value_8_13
                                single_container_value_3 = single_container_value_3:GetItemInfo(
                                    value_11_3,
                                    value_12_2
                                )
                                value_10_5 = captured_value_10
                                value_12_2 = argument_3_2.SingleContainer.NewItem
                                value_13_2 = single_container_value_3
                                value_14_4 = 1
                                value_10_5:ApplyItemToFrame(value_12_2, value_13_2, value_14_4)
                                control_state = 29
                            end
                        end
                    end
                else
                    if control_state < 31 then
                        if control_state < 29 then
                            single_container_value_3 = captured_value_10
                            value_11_3 = argument_3_2.SingleContainer.NewItem
                            value_12_2 = nil
                            value_13_2 = 1
                            single_container_value_3:ApplyItemToFrame(
                                value_11_3,
                                value_12_2,
                                value_13_2
                            )
                            control_state = 29
                        else
                            if control_state < 30 then
                                single_container_value_3 = argument_3_2.SingleContainer
                                control_state = if value_8_13 ~= nil then 31 else 30
                            else
                                value_10_5 = false
                                control_state = 32
                            end
                        end
                    else
                        if control_state < 32 then
                            value_10_5 = true
                            control_state = 32
                        else
                            if control_state < 33 then
                                single_container_value_3.Visible = value_10_5
                                single_container_value_3 = argument_3_2.MultipleContainer
                                value_10_5 = false
                                single_container_value_3.Visible = value_10_5
                                single_container_value_3 = argument_2_5.SingleContainer
                                value_10_5 = false
                                single_container_value_3.Visible = value_10_5
                                single_container_value_3 = argument_2_5.MultipleContainer
                                value_10_5 = true
                                single_container_value_3.Visible = value_10_5
                                control_state = 33
                            else
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
table_1.SelectItemForCrafting = select_item_for_crafting

return table_1
