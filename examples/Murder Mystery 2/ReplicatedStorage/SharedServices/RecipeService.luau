--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("IsItemSalvageable")] = nil, [("IsItemSalvageable")] = nil}
local require_value = require
local game_value = game
local value_5 = "ReplicatedStorage"
local replicated_storage_service = game_value:GetService(value_5)
local value_5_2 = "Database"
local database_child = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3 = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local is_item_salvageable
do
    local captured_value = require_result
    is_item_salvageable = function(argument_1, argument_2: string)
        if argument_2 == nil then
            return false
        end
        local value_3_5 = captured_value.Weapons[argument_2]
        if not value_3_5 then
            return false
        end
        if captured_value.Codes[argument_2] then
            return false
        end
        local rarity_value = value_3_5.Rarity
        local value_5_6 = captured_value.SalvageRewards[argument_2]
        if value_5_6 then
            value_5_6 = captured_value.SalvageRewards[argument_2].Rewards
        end
        local value_6_3 = captured_value.SalvageRewards[rarity_value]
        if value_6_3 then
            value_6_3 = captured_value.SalvageRewards[rarity_value].Rewards
        end
        local value_4_7
        if value_3_5.Event == nil then
            value_4_7 = false
        else
            value_4_7 = true
        end
        if value_4_7 then
            if not value_5_6 then
                return false
            end
        end
        if value_3_5.Season ~= nil then
            return false
        end
        if value_3_5.ItemType == "Misc" then
            return false
        end
        if not value_6_3 then
            if not value_5_6 then
                return false
            end
        end

        return true
    end
end
table_1.IsItemSalvageable = is_item_salvageable
local get_crafting_result
do
    local captured_value_2 = require_result
    get_crafting_result = function(argument_1_2, argument_2_2)
        local value_3_6 = captured_value_2.Recipes
        local value_4_8 = nil
        local value_5_8 = nil
        for key_3, value_10 in value_3_6, value_4_8, value_5_8 do
            local value_6_5, value_7_8 = key_3, value_10
            local materials_value = value_7_8.Materials
            local value_8 = 0
            local value_9 = 0
            local materials_value_2 = value_7_8.Materials
            local value_11 = nil
            local value_12 = nil
            for key_2, value_2 in materials_value_2, value_11, value_12 do
                local value_13, value_14 = key_2, value_2
                value_9 = value_9 + 1
                local value_15 = argument_2_2
                local value_16 = nil
                local value_17 = nil
                for key, value in value_15, value_16, value_17 do
                    local value_18, value_19 = key, value
                    local item_id_value = value_19.itemID
                    if item_id_value ~= value_13 then
                        continue
                    end
                    local amount_value = value_19.amount
                    if amount_value ~= value_14 then
                        continue
                    end
                    value_8 = value_8 + 1
                end
            end
            if value_8 ~= value_9 then
                continue
            end
            materials_value_2 = #argument_2_2
            if materials_value_2 ~= value_8 then
                continue
            end

            return value_6_5
        end

        return nil
    end
end
table_1.GetCraftingResult = get_crafting_result

return table_1
