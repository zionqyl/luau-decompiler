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

local table_1 = {
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
    [("ItemClicked")] = nil,
}
local game_value: DataModel = game
local value_4: string = "UserInputService"
local user_input_service: Instance = game_value:GetService(value_4)
local require_value = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_6_3))
local require_value_2 = require
local game_value_3: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "ItemService"
local require_result_2 = require_value_2(client_services_child:WaitForChild(value_7_3))
local require_value_3 = require
local game_value_4: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_8)
local value_8_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_3:WaitForChild(value_8_2)
local value_8_3: string = "ProfileData"
local require_result_3 = require_value_3(modules_child:WaitForChild(value_8_3))
local require_value_4 = require
local game_value_5: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_5:GetService(value_9)
local value_9_2: string = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_9_2)
local value_9_3: string = "Button"
local require_result_4 = require_value_4(client_services_child_2:WaitForChild(value_9_3))
local game_value_6: DataModel = game
local value_9_4: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_6:GetService(value_9_4)
local value_9_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_5:WaitForChild(value_9_5)
local value_9_6: string = "Shop"
local shop_child = remotes_child:WaitForChild(value_9_6)
local game_value_7: DataModel = game
local value_10: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_7:GetService(value_10)
local value_10_2: string = "Remotes"
local remotes_child_2: Instance? = replicated_storage_service_6:WaitForChild(value_10_2)
local value_10_3: string = "Inventory"
local inventory_child = remotes_child_2:WaitForChild(value_10_3)
local new_shop_value = require_result.NewShop
local require_value_5 = require
local game_value_8: DataModel = game
local value_13: string = "ReplicatedStorage"
local replicated_storage_service_7: Instance = game_value_8:GetService(value_13)
local value_13_2: string = "ClientServices"
local client_services_child_3: Instance? = replicated_storage_service_7:WaitForChild(value_13_2)
local value_13_3: string = "PolicyManager"
local require_result_5 = require_value_5(client_services_child_3:WaitForChild(value_13_3))
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.ItemClicked = new_result
local new_result_2: BindableEvent = Instance.new("BindableEvent")
table_1.ItemSelectionGained = new_result_2
local new_result_3: BindableEvent = Instance.new("BindableEvent")
table_1.ItemPurchaseRequested = new_result_3
local new_result_4: BindableEvent = Instance.new("BindableEvent")
table_1.PurchaseGemsRequested = new_result_4
local table_11 = {Desktop = 0, Mobile = 0, Console = 0}
local table_12 = {
    nil,
    nil,
    nil,
    nil,
}
local value_13_4: string = "Dual"
local value_14: string = "Electric"
local value_15: string = "Trap"
local value_16: string = "Decoy"
table_12[1], table_12[2], table_12[3], table_12[4] = value_13_4, value_14, value_15, value_16
table_11.Desktop = table_12
local table_12_2 = {
    nil,
    nil,
    nil,
    nil,
}
local value_13_5: string = "MysteryBox2"
local value_14_2: string = "Electric"
local value_15_2: string = "Dual"
local value_16_2: string = "Decoy"
table_12_2[1], table_12_2[2], table_12_2[3], table_12_2[4] = value_13_5, value_14_2, value_15_2, value_16_2
table_11.Mobile = table_12_2
local table_12_3 = {
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_13_6: string = "MysteryBox2"
local value_14_3: string = "MysteryBox1"
local value_15_3: string = "Decoy"
local value_16_3: string = "Dual"
local value_17: string = "Electric"
table_12_3[1], table_12_3[2], table_12_3[3], table_12_3[4], table_12_3[5] = value_13_6, value_14_3, value_15_3, value_16_3, value_17
table_11.Console = table_12_3
table_1.FeaturedItems = table_11
local table_11_2 = {
    MysteryBox = "Mystery Box",
    Event = "Event",
    Effects = "Effect",
    ItemBundle = "Bundle",
    Perks = "Perk",
}
local table_12_4 = {
    Unique = 4,
    Ancient = 5,
    Godly = 10,
    Legendary = 20,
    Rare = 30,
    Uncommon = 40,
    Common = 50,
}
local table_13 = {
    Weapons = {
        Weapons = true,
        MysteryBox = true,
        ItemBundle = true,
        Materials = true,
    },
}
local table_14_2 = {Weapons = true, Pets = true, Materials = true}
local table_15 = {Key = true, CandyExchange = true}
local script_value: LuaSourceContainer = script
local value_18: string = "CurrencyPriceFrame"
local currency_price_frame_child: Instance? = script_value:WaitForChild(value_18)
table_1.CurrencyPriceFrame = currency_price_frame_child
local script_value_2: LuaSourceContainer = script
local value_18_2: string = "FeaturedItemFrame"
local featured_item_frame_child: Instance? = script_value_2:WaitForChild(value_18_2)
table_1.FeaturedItemFrame = featured_item_frame_child
local script_value_3: LuaSourceContainer = script
local value_18_3: string = "ShopItemFrame"
local shop_item_frame_child: Instance? = script_value_3:WaitForChild(value_18_3)
table_1.ShopItemFrame = shop_item_frame_child
local script_value_4: LuaSourceContainer = script
local value_18_4: string = "BoxContentItemFrame"
local box_content_item_frame_child: Instance? = script_value_4:WaitForChild(value_18_4)
table_1.BoxContentItemFrame = box_content_item_frame_child
local shop_item_frame_value = table_1.ShopItemFrame
local value_18_5: string = "Container"
local container_child = shop_item_frame_value:WaitForChild(value_18_5)
local value_18_6: string = "Prices"
local prices_child = container_child:WaitForChild(value_18_6)
local value_18_7: string = "Gems"
local gems_child = prices_child:WaitForChild(value_18_7)
table_1.ShopItemCurrencyFrame = gems_child
local shop_item_frame_value_2 = table_1.ShopItemFrame
local value_18_8: string = "Container"
local container_child_2 = shop_item_frame_value_2:WaitForChild(value_18_8)
local value_18_9: string = "Prices"
local prices_child_2 = container_child_2:WaitForChild(value_18_9)
local value_18_10: string = "Coins"
prices_child_2:WaitForChild(value_18_10):Destroy()
local shop_item_currency_frame_value = table_1.ShopItemCurrencyFrame
local script_value_5: LuaSourceContainer = script
shop_item_currency_frame_value.Parent = script_value_5

local function comma_value(argument_1)
    local value_2_2 = argument_1
    local value_3_2: nil = nil
    while true do
        local gsub_value = string.gsub
        local value_5_7 = value_2_2
        local value_6_10: string = "^(-?%d+)(%d%d%d)"
        local value_7_13: string = "%1,%2"
        local gsub_result, value_5_8 = gsub_value(value_5_7, value_6_10, value_7_13)
        value_2_2 = gsub_result
        local value_3_3 = value_5_8
        if value_3_3 == 0 then
            break
        end
    end

    return value_2_2
end

table_1.CommaValue = comma_value
local table_17 = {}
local table_18 = {}
local get_sorted_item_list
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = new_shop_value, require_result_2, table_1, table_12_4
    get_sorted_item_list = function()
        local table_1_2 = {}
        local value_2_3 = captured_value
        local value_3_4 = nil
        local value_4_5 = nil
        local value_5_9, value_6_11, value_7_14
        for key, value in value_2_3, value_3_4, value_4_5 do
            value_5_9, value_6_11 = key, value
            value_7_14 = captured_value_2
            local value_9_10 = value_5_9
            local type_value = value_6_11.Type
            if not (value_7_14:FindItemInfo(value_9_10, type_value)) then
                continue
            end
            local table_9 = {ID = 0, Info = 0, Shop = 0}
            table_9.ID = value_5_9
            local value_10_4 = captured_value_2
            local value_12_8 = value_5_9
            local type_value_2 = value_6_11.Type
            local get_item_info_result = value_10_4:GetItemInfo(value_12_8, type_value_2)
            table_9.Info = get_item_info_result
            table_9.Shop = value_6_11
            local value_8_14 = table_1_2
            value_7_14 = table.insert
            value_7_14(value_8_14, table_9)
        end
        value_2_3 = table.sort
        value_3_4 = table_1_2
        do
            local captured_value_5, captured_value_6 = captured_value_3, captured_value_4
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_5) and same_capture(
                closure_cache[3],
                captured_value_6
            ) then
                value_4_5 = closure_cache[1]
            else
                local closure_ready
                value_4_5 = function(argument_1_2, argument_2)
                    if not closure_ready then
                        return
                    end
                    local coins_value, coins_value_2, coins_value_3, coins_value_4, coins_value_5, coins_value_6, gems_value, gems_value_2, gems_value_3, gems_value_4, gems_value_5, gems_value_6, id_value_2, id_value_3, info_value, info_value_2, item_already_purchased_result, item_already_purchased_result_2, limited_value, limited_value_2, limited_value_3, limited_value_4, price_value, price_value_10, price_value_11, price_value_12, price_value_2, price_value_3, price_value_4, price_value_5, price_value_6, price_value_7, price_value_8, price_value_9, rarity_value, rarity_value_2, shop_value, shop_value_2, value_10_10, value_10_11, value_10_6, value_10_8, value_11_10, value_11_11, value_11_12, value_11_13, value_11_14, value_11_15, value_11_7, value_11_8, value_11_9, value_12_10, value_12_11, value_12_12, value_12_9, value_4_6, value_7_15, value_7_16, value_7_17, value_8_15, value_9_12, value_9_13
                    local control_state = 0
                    while true do
                        if control_state < 25 then
                            if control_state < 12 then
                                if control_state < 6 then
                                    if control_state < 3 then
                                        if control_state < 1 then
                                            id_value_2 = argument_1_2.ID
                                            info_value = argument_1_2.Info
                                            shop_value = argument_1_2.Shop
                                            id_value_3 = argument_2.ID
                                            info_value_2 = argument_2.Info
                                            shop_value_2 = argument_2.Shop
                                            rarity_value = info_value.Rarity
                                            value_9_12 = rarity_value or "Common"
                                            rarity_value_2 = info_value_2.Rarity
                                            value_4_6 = rarity_value_2 or "Common"
                                            value_10_6 = captured_value_5
                                            value_12_9 = id_value_2
                                            item_already_purchased_result = value_10_6:ItemAlreadyPurchased(
                                                value_12_9
                                            )
                                            value_7_15 = item_already_purchased_result
                                            value_10_8 = captured_value_5
                                            value_12_10 = id_value_3
                                            item_already_purchased_result_2 = value_10_8:ItemAlreadyPurchased(
                                                value_12_10
                                            )
                                            control_state = if value_7_15 == item_already_purchased_result_2 then 2 else 1
                                        else
                                            if control_state < 2 then
                                                value_11_7 = not value_7_15

                                                return value_11_7
                                            else
                                                limited_value = shop_value.Limited
                                                control_state = if not limited_value then 5 else 3
                                            end
                                        end
                                    else
                                        if control_state < 4 then
                                            limited_value_2 = shop_value_2.Limited
                                            control_state = if limited_value_2 then 5 else 4
                                        else
                                            if control_state < 5 then
                                                value_11_8 = true

                                                return value_11_8
                                            else
                                                limited_value_3 = shop_value_2.Limited
                                                control_state = if not limited_value_3 then 8 else 6
                                            end
                                        end
                                    end
                                else
                                    if control_state < 9 then
                                        if control_state < 7 then
                                            limited_value_4 = shop_value.Limited
                                            control_state = if limited_value_4 then 8 else 7
                                        else
                                            if control_state < 8 then
                                                value_11_9 = false

                                                return value_11_9
                                            else
                                                control_state = if value_9_12 ~= value_4_6 then 41 else 9
                                            end
                                        end
                                    else
                                        if control_state < 10 then
                                            price_value = shop_value.Price
                                            coins_value = price_value.Coins
                                            control_state = if coins_value ~= nil then 11 else 10
                                        else
                                            if control_state < 11 then
                                                value_10_10 = false
                                                control_state = 12
                                            else
                                                value_10_10 = true
                                                control_state = 12
                                            end
                                        end
                                    end
                                end
                            else
                                if control_state < 18 then
                                    if control_state < 15 then
                                        if control_state < 13 then
                                            price_value_2 = shop_value_2.Price
                                            coins_value_2 = price_value_2.Coins
                                            control_state = if coins_value_2 ~= nil then 14 else 13
                                        else
                                            if control_state < 14 then
                                                value_7_16 = false
                                                control_state = 15
                                            else
                                                value_7_16 = true
                                                control_state = 15
                                            end
                                        end
                                    else
                                        if control_state < 16 then
                                            control_state = if not value_10_10 then 23 else 16
                                        else
                                            if control_state < 17 then
                                                control_state = if not value_7_16 then 23 else 17
                                            else
                                                price_value_3 = shop_value.Price
                                                coins_value_3 = price_value_3.Coins
                                                price_value_4 = shop_value_2.Price
                                                coins_value_4 = price_value_4.Coins
                                                control_state = if coins_value_3 == coins_value_4 then 25 else 18
                                            end
                                        end
                                    end
                                else
                                    if control_state < 21 then
                                        if control_state < 19 then
                                            price_value_5 = shop_value.Price
                                            coins_value_5 = price_value_5.Coins
                                            price_value_6 = shop_value_2.Price
                                            coins_value_6 = price_value_6.Coins
                                            control_state = if coins_value_5 < coins_value_6 then 20 else 19
                                        else
                                            if control_state < 20 then
                                                value_11_10 = false
                                                control_state = 21
                                            else
                                                value_11_10 = true
                                                control_state = 21
                                            end
                                        end
                                    else
                                        if control_state < 23 then
                                            return value_11_10
                                        else
                                            if control_state < 24 then
                                                control_state = if value_10_10 == value_7_16 then 25 else 24
                                            else
                                                return value_10_10
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            if control_state < 37 then
                                if control_state < 31 then
                                    if control_state < 28 then
                                        if control_state < 26 then
                                            price_value_7 = shop_value.Price
                                            gems_value = price_value_7.Gems
                                            control_state = if gems_value ~= nil then 27 else 26
                                        else
                                            if control_state < 27 then
                                                value_10_11 = false
                                                control_state = 28
                                            else
                                                value_10_11 = true
                                                control_state = 28
                                            end
                                        end
                                    else
                                        if control_state < 29 then
                                            price_value_8 = shop_value_2.Price
                                            gems_value_2 = price_value_8.Gems
                                            control_state = if gems_value_2 ~= nil then 30 else 29
                                        else
                                            if control_state < 30 then
                                                value_7_17 = false
                                                control_state = 31
                                            else
                                                value_7_17 = true
                                                control_state = 31
                                            end
                                        end
                                    end
                                else
                                    if control_state < 34 then
                                        if control_state < 32 then
                                            control_state = if not value_10_11 then 39 else 32
                                        else
                                            if control_state < 33 then
                                                control_state = if not value_7_17 then 39 else 33
                                            else
                                                price_value_9 = shop_value.Price
                                                gems_value_3 = price_value_9.Gems
                                                price_value_10 = shop_value_2.Price
                                                gems_value_4 = price_value_10.Gems
                                                control_state = if gems_value_3 == gems_value_4 then 41 else 34
                                            end
                                        end
                                    else
                                        if control_state < 35 then
                                            price_value_11 = shop_value.Price
                                            gems_value_5 = price_value_11.Gems
                                            price_value_12 = shop_value_2.Price
                                            gems_value_6 = price_value_12.Gems
                                            control_state = if gems_value_5 < gems_value_6 then 36 else 35
                                        else
                                            if control_state < 36 then
                                                value_11_11 = false
                                                control_state = 37
                                            else
                                                value_11_11 = true
                                                control_state = 37
                                            end
                                        end
                                    end
                                end
                            else
                                if control_state < 44 then
                                    if control_state < 41 then
                                        if control_state < 39 then
                                            return value_11_11
                                        else
                                            if control_state < 40 then
                                                control_state = if value_10_11 == value_7_17 then 41 else 40
                                            else
                                                return value_10_11
                                            end
                                        end
                                    else
                                        if control_state < 42 then
                                            value_12_11 = captured_value_6
                                            value_11_12 = value_12_11[value_9_12]
                                            value_8_15 = value_11_12 or 0
                                            value_12_12 = captured_value_6
                                            value_11_13 = value_12_12[value_4_6]
                                            value_9_13 = value_11_13 or 0
                                            control_state = if value_8_15 == value_9_13 then 46 else 42
                                        else
                                            if control_state < 43 then
                                                control_state = if value_9_13 < value_8_15 then 44 else 43
                                            else
                                                value_11_14 = false
                                                control_state = 45
                                            end
                                        end
                                    end
                                else
                                    if control_state < 47 then
                                        if control_state < 45 then
                                            value_11_14 = true
                                            control_state = 45
                                        else
                                            if control_state < 46 then
                                                return value_11_14
                                            else
                                                control_state = if id_value_2 < id_value_3 then 48 else 47
                                            end
                                        end
                                    else
                                        if control_state < 48 then
                                            value_11_15 = false
                                            control_state = 49
                                        else
                                            if control_state < 49 then
                                                value_11_15 = true
                                                control_state = 49
                                            else
                                                return value_11_15
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_5
                    closure_cache[2], closure_cache[3] = captured_value_5, captured_value_6
                end
            end
        end
        value_2_3(value_3_4, value_4_5)
        value_2_3 = {}
        value_3_4 = table_1_2
        value_4_5 = nil
        value_5_9 = nil
        for key_2, value_19 in value_3_4, value_4_5, value_5_9 do
            value_6_11, value_7_14 = key_2, value_19
            local id_value = value_7_14.ID
            local value_9_11 = value_2_3
            local insert_value = table.insert
            insert_value(value_9_11, id_value)
        end

        return value_2_3
    end
end
local purchase_is_repeatable
do
    local captured_value_7, captured_value_8 = new_shop_value, table_14_2
    purchase_is_repeatable = function<T1>(argument_1_3: T1, argument_2_2: string)
        local dev_product_id_value, one_time_purchase_value, one_time_purchase_value_2, type_value_3, value_3_5, value_4_7, value_5_10, value_5_11, value_5_12, value_5_13, value_5_14, value_6_12
        local control_state_2 = 0
        while true do
            if control_state_2 < 5 then
                if control_state_2 < 2 then
                    if control_state_2 < 1 then
                        value_4_7 = captured_value_7
                        value_3_5 = value_4_7[argument_2_2]
                        type_value_3 = value_3_5.Type
                        one_time_purchase_value = value_3_5.OneTimePurchase
                        control_state_2 = if not one_time_purchase_value then 2 else 1
                    else
                        value_5_10 = false

                        return value_5_10
                    end
                else
                    if control_state_2 < 3 then
                        dev_product_id_value = value_3_5.DevProductId
                        control_state_2 = if not dev_product_id_value then 5 else 3
                    else
                        if control_state_2 < 4 then
                            one_time_purchase_value_2 = value_3_5.OneTimePurchase
                            control_state_2 = if one_time_purchase_value_2 then 5 else 4
                        else
                            value_5_11 = true

                            return value_5_11
                        end
                    end
                end
            else
                if control_state_2 < 7 then
                    if control_state_2 < 6 then
                        value_6_12 = captured_value_8
                        value_5_12 = value_6_12[type_value_3]
                        control_state_2 = if value_5_12 then 8 else 6
                    else
                        control_state_2 = if type_value_3 == "MysteryBox" then 8 else 7
                    end
                else
                    if control_state_2 < 8 then
                        control_state_2 = if type_value_3 ~= "Eggs" then 9 else 8
                    else
                        if control_state_2 < 9 then
                            value_5_13 = true

                            return value_5_13
                        else
                            value_5_14 = false

                            return value_5_14
                        end
                    end
                end
            end
        end
    end
end
table_1.PurchaseIsRepeatable = purchase_is_repeatable
do
    local captured_value_9, captured_value_10 = new_shop_value, require_result_3
    purchase_is_repeatable = function<T1>(argument_1_4: T1, argument_2_3: string): boolean
        local value_3_6 = captured_value_9[argument_2_3]
        if not value_3_6.RequiredPurchases then
            return true
        end
        local value_4_10: number = 0
        local value_5_15: number = 0
        local required_purchases_value_2 = value_3_6.RequiredPurchases
        local value_7_18: nil = nil
        local value_8_16: nil = nil
        for key_3, value_20 in required_purchases_value_2, value_7_18, value_8_16 do
            local value_9_14, value_10_12 = key_3, value_20
            local value_12_13 = captured_value_10
            local one_time_purchases_value = value_12_13.OneTimePurchases
            local value_11_16 = one_time_purchases_value[value_10_12]
            if value_11_16 then
                value_4_10 = value_4_10 + 1
            end
            value_5_15 = value_5_15 + 1
        end
        if not (value_5_15 <= value_4_10) then
            required_purchases_value_2 = false
        else
            required_purchases_value_2 = true
        end

        return required_purchases_value_2
    end
end
table_1.HasRequiredPurchases = purchase_is_repeatable
do
    local captured_value_11, captured_value_12, captured_value_13 = new_shop_value, require_result_3, table_14_2
    purchase_is_repeatable = function<T1>(argument_1_5: T1, argument_2_4: string)
        local dev_product_id_value_2, find_result, find_value, gamepass_id_value, one_time_purchase_value_3, one_time_purchases_value_2, one_time_purchases_value_3, owned_value, type_value_4, value_3_7, value_4_11, value_5_16, value_5_17, value_5_18, value_5_19, value_5_20, value_5_21, value_5_22, value_5_23, value_6_13, value_6_14, value_6_15, value_6_16, value_7_19, value_7_20, value_8_17, value_8_18
        local control_state_3 = 0
        while true do
            if control_state_3 < 9 then
                if control_state_3 < 4 then
                    if control_state_3 < 2 then
                        if control_state_3 < 1 then
                            value_4_11 = captured_value_11
                            value_3_7 = value_4_11[argument_2_4]
                            type_value_4 = value_3_7.Type
                            dev_product_id_value_2 = value_3_7.DevProductId
                            control_state_3 = if not dev_product_id_value_2 then 6 else 1
                        else
                            value_5_16 = false
                            one_time_purchase_value_3 = value_3_7.OneTimePurchase
                            control_state_3 = if one_time_purchase_value_3 ~= true then 5 else 2
                        end
                    else
                        if control_state_3 < 3 then
                            value_7_19 = captured_value_12
                            one_time_purchases_value_2 = value_7_19.OneTimePurchases
                            value_6_13 = one_time_purchases_value_2[argument_2_4]
                            control_state_3 = if value_6_13 == true then 4 else 3
                        else
                            value_5_16 = false
                            control_state_3 = 5
                        end
                    end
                else
                    if control_state_3 < 6 then
                        if control_state_3 < 5 then
                            value_5_16 = true
                            control_state_3 = 5
                        else
                            return value_5_16
                        end
                    else
                        if control_state_3 < 7 then
                            gamepass_id_value = value_3_7.GamepassId
                            control_state_3 = if not gamepass_id_value then 9 else 7
                        else
                            if control_state_3 < 8 then
                                value_6_14 = captured_value_12
                                one_time_purchases_value_3 = value_6_14.OneTimePurchases
                                value_5_17 = one_time_purchases_value_3[argument_2_4]
                                control_state_3 = if value_5_17 ~= true then 9 else 8
                            else
                                value_5_18 = true

                                return value_5_18
                            end
                        end
                    end
                end
            else
                if control_state_3 < 14 then
                    if control_state_3 < 11 then
                        if control_state_3 < 10 then
                            value_6_15 = captured_value_13
                            value_5_19 = value_6_15[type_value_4]
                            control_state_3 = if value_5_19 then 12 else 10
                        else
                            control_state_3 = if type_value_4 == "MysteryBox" then 12 else 11
                        end
                    else
                        if control_state_3 < 12 then
                            control_state_3 = if type_value_4 ~= "Eggs" then 13 else 12
                        else
                            if control_state_3 < 13 then
                                value_5_20 = false

                                return value_5_20
                            else
                                value_6_16 = captured_value_12
                                value_5_21 = value_6_16[type_value_4]
                                control_state_3 = if value_5_21 then 15 else 14
                            end
                        end
                    end
                else
                    if control_state_3 < 16 then
                        if control_state_3 < 15 then
                            value_5_22 = false

                            return value_5_22
                        else
                            find_value = table.find
                            value_8_17 = captured_value_12
                            value_7_20 = value_8_17[type_value_4]
                            owned_value = value_7_20.Owned
                            value_8_18 = argument_2_4
                            find_result = find_value(owned_value, value_8_18)
                            control_state_3 = if find_result ~= nil then 17 else 16
                        end
                    else
                        if control_state_3 < 17 then
                            value_5_23 = false
                            control_state_3 = 18
                        else
                            if control_state_3 < 18 then
                                value_5_23 = true
                                control_state_3 = 18
                            else
                                return value_5_23
                            end
                        end
                    end
                end
            end
        end
    end
end
table_1.ItemAlreadyPurchased = purchase_is_repeatable
do
    local captured_value_14, captured_value_15 = new_shop_value, require_result_3
    purchase_is_repeatable = function<T1>(argument_1_6: T1, argument_2_5: string, argument_3: string): boolean
        if argument_3 == "Robux" then
            return true
        end
        local value_5_25 = captured_value_14[argument_2_5].Price[argument_3]
        local value_4_14 = captured_value_15.Materials.Owned[argument_3]
        if not value_4_14 then
            value_4_14 = captured_value_15.Weapons.Owned[argument_3] or 0
        end
        local value_6_19: boolean?
        if not (value_5_25 <= value_4_14) then
            value_6_19 = false
        else
            value_6_19 = true
        end

        return value_6_19
    end
end
table_1.CanAffordItem = purchase_is_repeatable
do
    local captured_value_16 = table_1
    purchase_is_repeatable = function<T1>(argument_1_7: T1, argument_2_6: string, argument_3_2: string)
        local value_4_15 = captured_value_16
        local value_6_20: string = argument_2_6
        local value_7_21: string = argument_3_2
        local can_afford_item_result = value_4_15:CanAffordItem(value_6_20, value_7_21)
        if can_afford_item_result then
            local value_5_27 = captured_value_16
            local value_7_22: string = argument_2_6
            can_afford_item_result = not (value_5_27:ItemAlreadyPurchased(value_7_22))
        end

        return can_afford_item_result
    end
end
table_1.CanPurchaseItem = purchase_is_repeatable
do
    local captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21 = new_shop_value, table_1, require_result_2, table_11_2, user_input_service
    purchase_is_repeatable = function<T1>(argument_1_8: T1, argument_2_7, argument_3_3)
        local value_4_17, value_5_29, value_6_22 = argument_2_7:GetChildren()
        local value_7_23, value_8_19
        for key_4, value_25 in value_4_17, value_5_29, value_6_22 do
            value_7_23, value_8_19 = key_4, value_25
            local value_11_17: string = "Frame"
            local is_a_result = value_8_19:IsA(value_11_17)
            if not is_a_result then
                continue
            end
            value_8_19:Destroy()
        end
        value_4_17 = argument_3_3
        value_5_29 = nil
        value_6_22 = nil
        for key_5, value_26 in value_4_17, value_5_29, value_6_22 do
            value_7_23, value_8_19 = key_5, value_26
            local value_10_15 = captured_value_17
            local value_9_17 = value_10_15[value_8_19]
            if not value_9_17 then
                local warn_value = warn
                local value_11_18: string = "Featured item not found."
                warn_value(value_11_18)
            else
                local value_10_16 = captured_value_18
                local featured_item_frame_value = value_10_16.FeaturedItemFrame
                local cloned_value = featured_item_frame_value:Clone()
                local display_info_value = value_9_17.DisplayInfo
                if not display_info_value then
                    local value_11_20 = captured_value_19
                    local value_13_7 = value_8_19
                    local type_value_5 = value_9_17.Type
                    display_info_value = value_11_20:GetDisplayInfo(value_13_7, type_value_5)
                end
                cloned_value.Name = value_8_19
                local container_value = cloned_value.Container
                local icon_value = container_value.Icon
                local image_value = display_info_value.Image
                icon_value.Image = image_value
                local item_name_value = cloned_value.ItemName
                local text_label_value = item_name_value.TextLabel
                local name_value = display_info_value.Name
                text_label_value.Text = name_value
                local item_name_value_2 = cloned_value.ItemName
                local color_value = display_info_value.Color
                item_name_value_2.BackgroundColor3 = color_value
                local container_value_2 = cloned_value.Container
                local subtitle_value = container_value_2.Subtitle
                local value_14_4 = captured_value_20
                local type_value_6 = value_9_17.Type
                local value_13_8 = value_14_4[type_value_6] or value_9_17.Type
                subtitle_value.Text = value_13_8
                local container_value_3 = cloned_value.Container
                local limited_value_5 = container_value_3.Limited
                local limited_value_6 = value_9_17.Limited
                local value_13_9: boolean?
                if limited_value_6 ~= true then
                    value_13_9 = false
                else
                    value_13_9 = true
                end
                limited_value_5.Visible = value_13_9
                local container_value_4 = cloned_value.Container
                local action_button_value = container_value_4.ActionButton
                local activated_value = action_button_value.Activated
                local value_14_5
                do
                    local captured_value_22, captured_value_23, captured_value_24, closure_ready_2
                    value_14_5 = function(): ()
                        if not closure_ready_2 then
                            return
                        end
                        local item_clicked_value = captured_value_22.ItemClicked
                        local value_3_8 = captured_value_23
                        local type_value_7 = captured_value_24.Type
                        item_clicked_value:Fire(value_3_8, type_value_7)

                        return
                    end
                    captured_value_22, captured_value_23, captured_value_24 = captured_value_18, value_8_19, value_9_17
                    closure_ready_2 = true
                end
                activated_value:Connect(value_14_5)
                local value_12_16: Instance = captured_value_21
                local gamepad_enabled_value = value_12_16.GamepadEnabled
                if gamepad_enabled_value then
                    local container_value_5 = cloned_value.Container
                    local action_button_value_2 = container_value_5.ActionButton
                    local selection_gained_value = action_button_value_2.SelectionGained
                    local value_14_6
                    do
                        local captured_value_25, captured_value_26, captured_value_27, closure_ready_3
                        value_14_6 = function(): ()
                            if not closure_ready_3 then
                                return
                            end
                            local item_selection_gained_value = captured_value_25.ItemSelectionGained
                            local value_3_9 = captured_value_26
                            local type_value_8 = captured_value_27.Type
                            item_selection_gained_value:Fire(value_3_9, type_value_8)

                            return
                        end
                        captured_value_25, captured_value_26, captured_value_27 = captured_value_18, value_8_19, value_9_17
                        closure_ready_3 = true
                    end
                    selection_gained_value:Connect(value_14_6)
                end
                cloned_value.LayoutOrder = value_7_23
                cloned_value.Parent = argument_2_7
            end
        end

        return
    end
end
table_1.GenerateFeaturedItems = purchase_is_repeatable
do
    local captured_value_28, captured_value_29, captured_value_30 = new_shop_value, table_1, table_13
    purchase_is_repeatable = function<T1>(argument_1_9: T1, argument_2_8, argument_3_4: string)
        local value_4_20, value_5_30, value_6_23 = argument_2_8:GetChildren()
        for key_6, value_27 in value_4_20, value_5_30, value_6_23 do
            local value_7_24, value_8_20 = key_6, value_27
            local value_11_22: string = "Frame"
            local is_a_result_2 = value_8_20:IsA(value_11_22)
            if not is_a_result_2 then
                continue
            end
            local name_value_2 = value_8_20.Name
            local value_12_18: string = "ItemType"
            local item_type_value = value_8_20:GetAttribute(value_12_18)
            local value_12_19 = captured_value_28
            local value_11_24 = value_12_19[name_value_2]
            local value_13_12 = captured_value_28
            local value_12_20 = value_13_12[name_value_2]
            if not value_12_20 then
                local value_12_21: boolean = false
                value_8_20.Visible = value_12_21
            else
                local value_12_22 = captured_value_29
                local value_14_7 = name_value_2
                local has_required_purchases_result = value_12_22:HasRequiredPurchases(value_14_7)
                if not has_required_purchases_result then
                    local value_12_24: boolean = false
                    value_8_20.Visible = value_12_24
                else
                    if argument_3_4 == "Weapons" then
                        local value_13_14 = captured_value_30
                        local weapons_value_2 = value_13_14.Weapons
                        local value_12_25 = weapons_value_2[item_type_value]
                        value_8_20.Visible = value_12_25
                    else
                        if argument_3_4 == "Emotes" then
                            local value_12_26: boolean = true
                            if item_type_value ~= "Emotes" then
                                if item_type_value ~= "Toys" then
                                    value_12_26 = false
                                else
                                    value_12_26 = true
                                end
                            end
                            value_8_20.Visible = value_12_26
                        else
                            if argument_3_4 == "Pets" then
                                local value_12_27: boolean = true
                                if item_type_value ~= "Pets" then
                                    if item_type_value ~= "Eggs" then
                                        value_12_27 = false
                                    else
                                        value_12_27 = true
                                    end
                                end
                                value_8_20.Visible = value_12_27
                            else
                                local value_15_4: string = "ItemType"
                                local item_type_value_2 = value_8_20:GetAttribute(value_15_4)
                                local value_12_28: boolean?
                                if item_type_value_2 ~= argument_3_4 then
                                    value_12_28 = false
                                else
                                    value_12_28 = true
                                end
                                value_8_20.Visible = value_12_28
                            end
                        end
                    end
                end
            end
        end

        return
    end
end
table_1.SetVisibleItems = purchase_is_repeatable
do
    local captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40 = get_sorted_item_list, new_shop_value, table_18, table_15, require_result_5, table_1, require_result_2, table_17, comma_value, user_input_service
    purchase_is_repeatable = function<T1>(argument_1_10: T1, argument_2_9)
        local value_3_11 = captured_value_31()
        local value_4_21 = captured_value_32
        local value_5_31: nil = nil
        local value_6_24: nil = nil
        for key_8, value_29 in value_4_21, value_5_31, value_6_24 do
            local value_7_25, value_8_21 = key_8, value_29
            local value_10_20 = captured_value_33
            local value_9_19 = value_10_20[value_7_25]
            if value_9_19 then
                continue
            end
            local value_10_21 = captured_value_34
            local value_9_20 = value_10_21[value_7_25]
            do
                local take_fallback = not value_9_20
                if not take_fallback then
                    local value_9_21 = captured_value_35
                    local are_paid_random_items_restricted_value = value_9_21.ArePaidRandomItemsRestricted
                    take_fallback = not are_paid_random_items_restricted_value
                end
                if take_fallback then
                    local hidden_value = value_8_21.Hidden
                    if hidden_value then
                        continue
                    end
                    local type_value_9 = value_8_21.Type
                    local value_10_22 = captured_value_36
                    local shop_item_frame_value_3 = value_10_22.ShopItemFrame
                    local cloned_value_2 = shop_item_frame_value_3:Clone()
                    local display_info_value_2 = value_8_21.DisplayInfo
                    local value_13_16, value_14_9
                    if not display_info_value_2 then
                        local value_11_26 = captured_value_37
                        value_13_16 = value_7_25
                        value_14_9 = type_value_9
                        display_info_value_2 = value_11_26:GetDisplayInfo(value_13_16, value_14_9)
                    end
                    cloned_value_2.Name = value_7_25
                    local value_12_29 = cloned_value_2.Container.Icon
                    value_13_16 = display_info_value_2.Image
                    value_12_29.Image = value_13_16
                    value_12_29 = cloned_value_2.ItemName.TextLabel
                    value_13_16 = display_info_value_2.Name
                    value_12_29.Text = value_13_16
                    value_12_29 = cloned_value_2.ItemName
                    value_13_16 = display_info_value_2.Color
                    value_12_29.BackgroundColor3 = value_13_16
                    value_12_29 = cloned_value_2.Container.Limited
                    value_14_9 = value_8_21.Limited
                    if value_14_9 ~= true then
                        value_13_16 = false
                    else
                        value_13_16 = true
                    end
                    value_12_29.Visible = value_13_16
                    value_12_29 = value_8_21.LayoutOrder
                    if not value_12_29 then
                        value_12_29 = table.find
                        value_13_16 = value_3_11
                        value_14_9 = value_7_25
                        value_12_29 = (value_12_29(value_13_16, value_14_9)) or 0
                    end
                    cloned_value_2.LayoutOrder = value_12_29
                    value_12_29 = value_8_21.Type
                    local value_15_5
                    if value_12_29 ~= "MysteryBox" then
                        value_12_29 = captured_value_36
                        value_14_9 = value_7_25
                        value_12_29 = value_12_29:ItemAlreadyPurchased(value_14_9)
                        if value_12_29 then
                            value_12_29 = cloned_value_2.Container.Prices.OwnedPrice
                            value_13_16 = true
                            value_12_29.Visible = value_13_16
                        else
                            value_12_29 = captured_value_36
                            value_14_9 = value_7_25
                            value_12_29 = value_12_29:PurchaseIsRepeatable(value_14_9)
                            if not value_12_29 then
                                value_12_29 = captured_value_38
                                value_12_29[value_7_25] = cloned_value_2
                            end
                            value_12_29 = value_8_21.Price
                            value_13_16 = nil
                            value_14_9 = nil
                            for key_7, value_28 in value_12_29, value_13_16, value_14_9 do
                                local value_16_15
                                value_15_5, value_16_15 = key_7, value_28
                                local value_17_13: nil = nil
                                local value_18_11 = captured_value_37
                                local value_20_2 = value_15_5
                                local value_21_2: string = "Materials"
                                local item_exists_result = value_18_11:ItemExists(
                                    value_20_2,
                                    value_21_2
                                )
                                local value_17_14
                                if item_exists_result then
                                    local value_18_13 = captured_value_37
                                    local value_20_3 = value_15_5
                                    local value_21_3: string = "Materials"
                                    local get_item_info_result_2 = value_18_13:GetItemInfo(
                                        value_20_3,
                                        value_21_3
                                    )
                                    value_17_14 = get_item_info_result_2
                                else
                                    local value_18_15 = captured_value_37
                                    local value_20_4 = value_15_5
                                    local value_21_4: string = "Weapons"
                                    local item_exists_result_2 = value_18_15:ItemExists(
                                        value_20_4,
                                        value_21_4
                                    )
                                    if item_exists_result_2 then
                                        local value_18_17 = captured_value_37
                                        local value_20_5 = value_15_5
                                        local value_21_5: string = "Weapons"
                                        local get_item_info_result_3 = value_18_17:GetItemInfo(
                                            value_20_5,
                                            value_21_5
                                        )
                                        value_17_14 = get_item_info_result_3
                                    else
                                        local warn_value_2 = warn
                                        local value_19_6: string = "Currency does not exist"
                                        warn_value_2(value_19_6)
                                        continue
                                    end
                                end
                                local value_18_19 = captured_value_37
                                local value_20_6 = value_17_14
                                local get_item_image_result = value_18_19:GetItemImage(value_20_6)
                                local value_11_28 = get_item_image_result
                                local value_17_15 = captured_value_36
                                local shop_item_currency_frame_value_2 = value_17_15.ShopItemCurrencyFrame
                                local cloned_value_3 = shop_item_currency_frame_value_2:Clone()
                                local icon_value_2 = cloned_value_3.Icon
                                local title_value = icon_value_2.Title
                                title_value.Image = value_11_28
                                local price_value_14 = cloned_value_3.Price
                                local value_19_8 = captured_value_39
                                local value_20_7 = value_16_15
                                local value_19_9 = value_19_8(value_20_7)
                                price_value_14.Text = value_19_9
                                cloned_value_3.LayoutOrder = value_16_15
                                local container_value_6 = cloned_value_2.Container
                                local prices_value = container_value_6.Prices
                                cloned_value_3.Parent = prices_value
                            end
                        end
                    end
                    value_12_29 = cloned_value_2.Container.ActionButton.Activated
                    do
                        local captured_value_41, captured_value_42, captured_value_43, closure_ready_4
                        value_14_9 = function(): ()
                            if not closure_ready_4 then
                                return
                            end
                            local item_clicked_value_2 = captured_value_41.ItemClicked
                            local value_3_12 = captured_value_42
                            local value_4_22 = captured_value_43
                            item_clicked_value_2:Fire(value_3_12, value_4_22)

                            return
                        end
                        captured_value_41, captured_value_42, captured_value_43 = captured_value_36, value_7_25, type_value_9
                        closure_ready_4 = true
                    end
                    value_12_29:Connect(value_14_9)
                    value_12_29 = captured_value_40.GamepadEnabled
                    if value_12_29 then
                        value_12_29 = cloned_value_2.Container.ActionButton.SelectionGained
                        do
                            local captured_value_44, captured_value_45, captured_value_46, closure_ready_5
                            value_14_9 = function(): ()
                                if not closure_ready_5 then
                                    return
                                end
                                local item_selection_gained_value_2 = captured_value_44.ItemSelectionGained
                                local value_3_13 = captured_value_45
                                local type_value_10 = captured_value_46.Type
                                item_selection_gained_value_2:Fire(value_3_13, type_value_10)

                                return
                            end
                            captured_value_44, captured_value_45, captured_value_46 = captured_value_36, value_7_25, value_8_21
                            closure_ready_5 = true
                        end
                        value_12_29:Connect(value_14_9)
                    end
                    value_14_9 = "ItemType"
                    value_15_5 = type_value_9
                    cloned_value_2:SetAttribute(value_14_9, value_15_5)
                    cloned_value_2.Parent = argument_2_9
                    value_12_29 = captured_value_33
                    value_12_29[value_7_25] = cloned_value_2
                end
            end
        end

        return
    end
end
table_1.GenerateShopItems = purchase_is_repeatable
do
    local captured_value_47, captured_value_48, captured_value_49, captured_value_50 = new_shop_value, require_result_2, table_1, comma_value
    purchase_is_repeatable = function<T1>(argument_1_11: T1, argument_2_10, argument_3_5, argument_4, argument_5: string)
        local value_6_25 = captured_value_47[argument_5]
        local display_info_value_3 = value_6_25.DisplayInfo
        local type_value_11, value_9_22
        if not display_info_value_3 then
            local value_7_27 = captured_value_48
            value_9_22 = argument_5
            type_value_11 = value_6_25.Type
            display_info_value_3 = value_7_27:GetDisplayInfo(value_9_22, type_value_11)
        end
        local value_8_23 = captured_value_48
        type_value_11 = argument_5
        local type_value_12 = value_6_25.Type
        local find_item_info_result = (value_8_23:FindItemInfo(type_value_11, type_value_12)) or ({})
        value_9_22 = argument_2_10.Container.Icon
        type_value_11 = display_info_value_3.Image
        value_9_22.Image = type_value_11
        value_9_22 = argument_2_10.ItemName.TextLabel
        type_value_11 = display_info_value_3.Name
        value_9_22.Text = type_value_11
        value_9_22 = argument_2_10.ItemName
        type_value_11 = display_info_value_3.Color
        value_9_22.BackgroundColor3 = type_value_11
        value_9_22 = value_6_25.Description
        if not value_9_22 then
            value_9_22 = find_item_info_result.Description or ""
        end
        argument_3_5.Text = value_9_22
        value_9_22, type_value_11, type_value_12 = argument_4:GetChildren()
        local value_12_30, value_13_17
        for key_9, value_30 in value_9_22, type_value_11, type_value_12 do
            value_12_30, value_13_17 = key_9, value_30
            local value_16_16: string = "Frame"
            local is_a_result_3 = value_13_17:IsA(value_16_16)
            if not is_a_result_3 then
                continue
            end
            value_13_17:Destroy()
        end
        value_9_22 = value_6_25.Price
        type_value_11 = nil
        type_value_12 = nil
        for key_10, value_31 in value_9_22, type_value_11, type_value_12 do
            value_12_30, value_13_17 = key_10, value_31
            local value_14_12: nil = nil
            local value_15_8 = captured_value_48
            local value_17_17 = value_12_30
            local value_18_22: string = "Materials"
            local item_exists_result_3 = value_15_8:ItemExists(value_17_17, value_18_22)
            local value_14_13
            if item_exists_result_3 then
                local value_15_10 = captured_value_48
                local value_17_18 = value_12_30
                local value_18_23: string = "Materials"
                local get_item_info_result_4 = value_15_10:GetItemInfo(value_17_18, value_18_23)
                value_14_13 = get_item_info_result_4
            else
                local value_15_12 = captured_value_48
                local value_17_19 = value_12_30
                local value_18_24: string = "Weapons"
                local item_exists_result_4 = value_15_12:ItemExists(value_17_19, value_18_24)
                if item_exists_result_4 then
                    local value_15_14 = captured_value_48
                    local value_17_20 = value_12_30
                    local value_18_25: string = "Weapons"
                    local get_item_info_result_5 = value_15_14:GetItemInfo(
                        value_17_20,
                        value_18_25
                    )
                    value_14_13 = get_item_info_result_5
                else
                    local warn_value_3 = warn
                    local value_16_21: string = "Currency does not exist"
                    warn_value_3(value_16_21)
                    continue
                end
            end
            local value_15_16 = captured_value_48
            local value_17_21 = value_14_13
            local get_item_image_result_2 = value_15_16:GetItemImage(value_17_21)
            local value_8_25 = get_item_image_result_2
            local value_14_14 = captured_value_49
            local currency_price_frame_value = value_14_14.CurrencyPriceFrame
            local cloned_value_4 = currency_price_frame_value:Clone()
            cloned_value_4.LayoutOrder = value_13_17
            local container_value_7 = cloned_value_4.Container
            local icon_value_3 = container_value_7.Icon
            icon_value_3.Image = value_8_25
            local container_value_8 = cloned_value_4.Container
            local price_frame_value = container_value_8.PriceFrame
            local price_label_value = price_frame_value.PriceLabel
            local value_16_23 = captured_value_50
            local value_17_22 = value_13_17
            local value_16_24 = value_16_23(value_17_22)
            price_label_value.Text = value_16_24
            local buy_value = cloned_value_4.Buy
            local value_17_23 = captured_value_49
            local value_19_10: string = argument_5
            local value_20_8 = value_12_30
            local can_purchase_item_result = value_17_23:CanPurchaseItem(value_19_10, value_20_8)
            local roblox_round_default_button_value
            do
                local take_fallback_2 = not can_purchase_item_result
                if not take_fallback_2 then
                    roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                    take_fallback_2 = not roblox_round_default_button_value
                end
                if take_fallback_2 then
                    roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                end
            end
            buy_value.Style = roblox_round_default_button_value
            local buy_value_2 = cloned_value_4.Buy
            local activated_value_2 = buy_value_2.Activated
            local value_17_25
            do
                local captured_value_51, captured_value_52, captured_value_53, closure_ready_6
                value_17_25 = function(): ()
                    if not closure_ready_6 then
                        return
                    end
                    if captured_value_51 == "Gems" then
                        local value_1_10 = captured_value_52
                        local value_3_14 = captured_value_53
                        local value_4_24 = captured_value_51
                        if not (value_1_10:ItemAlreadyPurchased(value_3_14, value_4_24)) then
                            local value_1_12 = captured_value_52
                            local value_3_15 = captured_value_53
                            local value_4_25 = captured_value_51
                            if not (value_1_12:CanAffordItem(value_3_15, value_4_25)) then
                                captured_value_52.PurchaseGemsRequested:Fire()

                                return
                            end
                        end
                    end
                    local value_1_16 = captured_value_52
                    local value_3_16 = captured_value_53
                    local value_4_26 = captured_value_51
                    if not (value_1_16:CanPurchaseItem(value_3_16, value_4_26)) then
                        return
                    end
                    local item_purchase_requested_value = captured_value_52.ItemPurchaseRequested
                    local value_3_17 = captured_value_53
                    local value_4_27 = captured_value_51
                    item_purchase_requested_value:Fire(value_3_17, value_4_27)

                    return
                end
                captured_value_51, captured_value_52, captured_value_53 = value_12_30, captured_value_49, argument_5
                closure_ready_6 = true
            end
            activated_value_2:Connect(value_17_25)
            cloned_value_4.LayoutOrder = value_13_17
            cloned_value_4.Parent = argument_4
        end

        return
    end
end
table_1.ViewBuyPopup = purchase_is_repeatable
do
    local captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58 = table_1, new_shop_value, require_result_2, require_result_5, comma_value
    purchase_is_repeatable = function<T1>(argument_1_12: T1, argument_2_11, argument_3_6, argument_4_2, argument_5_2: string, argument_6: string)
        local value_7_29 = captured_value_54
        value_7_29.ViewedBoxId = argument_5_2
        local value_7_30 = captured_value_54
        value_7_30.ViewedBoxType = argument_6
        if captured_value_54.ItemChancesFrame then
            local item_chances_frame_value_2 = captured_value_54.ItemChancesFrame
            local value_8_26: boolean = false
            item_chances_frame_value_2.Visible = value_8_26
        end
        local value_7_33 = captured_value_55[argument_5_2]
        local value_8_28 = captured_value_56
        local value_10_24 = argument_5_2
        local value_11_29 = argument_6
        local get_display_info_result = value_8_28:GetDisplayInfo(value_10_24, value_11_29)
        local icon_value_4 = argument_2_11.Container.Icon
        value_10_24 = get_display_info_result.Image
        icon_value_4.Image = value_10_24
        local text_label_value_2 = argument_2_11.ItemName.TextLabel
        value_10_24 = get_display_info_result.Name
        text_label_value_2.Text = value_10_24
        local item_name_value_4 = argument_2_11.ItemName
        value_10_24 = get_display_info_result.Color
        item_name_value_4.BackgroundColor3 = value_10_24
        local value_8_30 = captured_value_56
        value_10_24 = argument_5_2
        value_11_29 = argument_6
        local get_item_info_result_6 = value_8_30:GetItemInfo(value_10_24, value_11_29)
        local contents_value = get_item_info_result_6.Contents
        local value_12_31
        value_10_24, value_11_29, value_12_31 = argument_3_6:GetChildren()
        local value_13_18, value_14_16
        for key_11, value_32 in value_10_24, value_11_29, value_12_31 do
            value_13_18, value_14_16 = key_11, value_32
            local value_17_26: string = "Frame"
            local is_a_result_4 = value_14_16:IsA(value_17_26)
            if not is_a_result_4 then
                continue
            end
            value_14_16:Destroy()
        end
        value_10_24 = contents_value
        value_11_29 = nil
        value_12_31 = nil
        for key_12, value_33 in value_10_24, value_11_29, value_12_31 do
            value_13_18, value_14_16 = key_12, value_33
            local value_15_22 = captured_value_54
            local box_content_item_frame_value = value_15_22.BoxContentItemFrame
            local cloned_value_5 = box_content_item_frame_value:Clone()
            local value_16_29 = captured_value_56
            local value_18_27 = value_14_16
            local box_type_value = get_item_info_result_6.BoxType
            local get_display_info_result_2 = value_16_29:GetDisplayInfo(
                value_18_27,
                box_type_value
            )
            cloned_value_5.Name = value_14_16
            local container_value_10 = cloned_value_5.Container
            local icon_value_5 = container_value_10.Icon
            local image_value_2 = get_display_info_result_2.Image
            icon_value_5.Image = image_value_2
            local item_name_value_5 = cloned_value_5.ItemName
            local text_label_value_3 = item_name_value_5.TextLabel
            local name_value_3 = get_display_info_result_2.Name
            text_label_value_3.Text = name_value_3
            local item_name_value_6 = cloned_value_5.ItemName
            local color_value_2 = get_display_info_result_2.Color
            item_name_value_6.BackgroundColor3 = color_value_2
            local container_value_11 = cloned_value_5.Container
            local owned_text_value = container_value_11.OwnedText
            local value_18_28: boolean = false
            owned_text_value.Visible = value_18_28
            local container_value_12 = cloned_value_5.Container
            local owned_background_value = container_value_12.OwnedBackground
            local value_18_29: boolean = false
            owned_background_value.Visible = value_18_29
            cloned_value_5.LayoutOrder = value_13_18
            cloned_value_5.Parent = argument_3_6
        end
        value_10_24, value_11_29, value_12_31 = argument_4_2:GetChildren()
        for key_13, value_34 in value_10_24, value_11_29, value_12_31 do
            value_13_18, value_14_16 = key_13, value_34
            local value_17_28: string = "Frame"
            local is_a_result_5 = value_14_16:IsA(value_17_28)
            if not is_a_result_5 then
                continue
            end
            value_14_16:Destroy()
        end
        value_10_24 = value_7_33.Price
        value_11_29 = nil
        value_12_31 = nil
        for key_14, value_35 in value_10_24, value_11_29, value_12_31 do
            value_13_18, value_14_16 = key_14, value_35
            local value_15_26: nil = nil
            local value_16_33 = captured_value_56
            local value_18_30 = value_13_18
            local value_19_11: string = "Materials"
            local item_exists_result_5 = value_16_33:ItemExists(value_18_30, value_19_11)
            local value_15_27
            if item_exists_result_5 then
                local value_16_35 = captured_value_56
                local value_18_31 = value_13_18
                local value_19_12: string = "Materials"
                local get_item_info_result_7 = value_16_35:GetItemInfo(value_18_31, value_19_12)
                value_15_27 = get_item_info_result_7
            else
                local value_16_37 = captured_value_56
                local value_18_32 = value_13_18
                local value_19_13: string = "Weapons"
                local item_exists_result_6 = value_16_37:ItemExists(value_18_32, value_19_13)
                if item_exists_result_6 then
                    local value_16_39 = captured_value_56
                    local value_18_33 = value_13_18
                    local value_19_14: string = "Weapons"
                    local get_item_info_result_8 = value_16_39:GetItemInfo(
                        value_18_33,
                        value_19_14
                    )
                    value_15_27 = get_item_info_result_8
                else
                    local warn_value_4 = warn
                    local value_17_33: string = "Currency does not exist"
                    warn_value_4(value_17_33)
                    continue
                end
            end
            do
                local take_fallback_3 = value_13_18 ~= "Gems"
                if not take_fallback_3 then
                    local value_16_41 = captured_value_57
                    local are_paid_random_items_restricted_value_2 = value_16_41.ArePaidRandomItemsRestricted
                    take_fallback_3 = not are_paid_random_items_restricted_value_2
                end
                if take_fallback_3 then
                    local value_16_42 = captured_value_56
                    local value_18_34 = value_15_27
                    local get_item_image_result_3 = value_16_42:GetItemImage(value_18_34)
                    local value_9_25 = get_item_image_result_3
                    local value_15_28 = captured_value_54
                    local currency_price_frame_value_2 = value_15_28.CurrencyPriceFrame
                    local cloned_value_6 = currency_price_frame_value_2:Clone()
                    local container_value_13 = cloned_value_6.Container
                    local icon_value_6 = container_value_13.Icon
                    icon_value_6.Image = value_9_25
                    local container_value_14 = cloned_value_6.Container
                    local price_frame_value_2 = container_value_14.PriceFrame
                    local price_label_value_2 = price_frame_value_2.PriceLabel
                    local value_17_35 = captured_value_58
                    local value_18_35 = value_14_16
                    local value_17_36 = value_17_35(value_18_35)
                    price_label_value_2.Text = value_17_36
                    local buy_value_3 = cloned_value_6.Buy
                    local value_18_36 = captured_value_54
                    local value_20_9: string = argument_5_2
                    local value_21_6 = value_13_18
                    local can_afford_item_result_3 = value_18_36:CanAffordItem(
                        value_20_9,
                        value_21_6
                    )
                    local roblox_round_default_button_value_2
                    do
                        local take_fallback_4 = not can_afford_item_result_3
                        if not take_fallback_4 then
                            roblox_round_default_button_value_2 = Enum.ButtonStyle.RobloxRoundDefaultButton
                            take_fallback_4 = not roblox_round_default_button_value_2
                        end
                        if take_fallback_4 then
                            roblox_round_default_button_value_2 = Enum.ButtonStyle.RobloxRoundButton
                        end
                    end
                    buy_value_3.Style = roblox_round_default_button_value_2
                    local buy_value_4 = cloned_value_6.Buy
                    local activated_value_3 = buy_value_4.Activated
                    local value_18_38
                    do
                        local captured_value_59, captured_value_60, captured_value_61, closure_ready_7
                        value_18_38 = function(): ()
                            if not closure_ready_7 then
                                return
                            end
                            if captured_value_59 == "Gems" then
                                local value_1_21 = captured_value_60
                                local value_3_18 = captured_value_61
                                local value_4_28 = captured_value_59
                                if not (value_1_21:ItemAlreadyPurchased(value_3_18, value_4_28)) then
                                    local value_1_23 = captured_value_60
                                    local value_3_19 = captured_value_61
                                    local value_4_29 = captured_value_59
                                    if not (value_1_23:CanAffordItem(value_3_19, value_4_29)) then
                                        captured_value_60.PurchaseGemsRequested:Fire()

                                        return
                                    end
                                end
                            end
                            local value_1_27 = captured_value_60
                            local value_3_20 = captured_value_61
                            local value_4_30 = captured_value_59
                            if not (value_1_27:CanPurchaseItem(value_3_20, value_4_30)) then
                                return
                            end
                            local item_purchase_requested_value_2 = captured_value_60.ItemPurchaseRequested
                            local value_3_21 = captured_value_61
                            local value_4_31 = captured_value_59
                            item_purchase_requested_value_2:Fire(value_3_21, value_4_31)

                            return
                        end
                        captured_value_59, captured_value_60, captured_value_61 = value_13_18, captured_value_54, argument_5_2
                        closure_ready_7 = true
                    end
                    activated_value_3:Connect(value_18_38)
                    cloned_value_6.LayoutOrder = value_14_16
                    cloned_value_6.Parent = argument_4_2
                end
            end
        end

        return
    end
end
table_1.ViewBoxContents = purchase_is_repeatable
purchase_is_repeatable = nil
local value_21 = nil
local populate_item_chances
do
    local captured_value_62, captured_value_63 = require_result_2, require_result
    populate_item_chances = function<T1>(argument_1_13: T1, argument_2_12, argument_3_7: string, argument_4_3: string): ()
        local value_7_34: string = "ScrollingFrame"
        local scrolling_frame_child = argument_2_12:FindFirstChild(value_7_34)
        local value_6_27 = captured_value_62
        local value_8_32 = argument_3_7
        local value_9_26 = argument_4_3
        local get_item_info_result_9 = value_6_27:GetItemInfo(value_8_32, value_9_26)
        local rarity_value_3 = captured_value_63.Rarity
        value_8_32 = purchase_is_repeatable
        local value_10_25
        if not value_8_32 then
            value_10_25 = "Common"
            value_8_32 = scrolling_frame_child:FindFirstChild(value_10_25)
            value_8_32 = value_8_32:Clone()
            purchase_is_repeatable = value_8_32
            value_10_25 = "Common1"
            value_8_32 = scrolling_frame_child:FindFirstChild(value_10_25)
            value_8_32 = value_8_32:Clone()
            value_21 = value_8_32
        end
        value_8_32, value_9_26, value_10_25 = scrolling_frame_child:GetChildren()
        local value_11_30, value_12_32, value_13_19, value_15_30
        for key_15, value_36 in value_8_32, value_9_26, value_10_25 do
            value_11_30, value_12_32 = key_15, value_36
            value_15_30 = "TextLabel"
            if not (value_12_32:IsA(value_15_30)) then
                continue
            end
            value_13_19 = value_12_32.Name
            if value_13_19 == "Title" then
                continue
            end
            value_12_32:Destroy()
        end
        value_8_32 = 0
        do
            local captured_value_64, closure_ready_8
            value_9_26 = function(argument_1_14, argument_2_13: string, argument_3_8: Color3?): ()
                if not closure_ready_8 then
                    return
                end
                value_8_32 = value_8_32 + 1
                local cloned_value_8 = argument_1_14:Clone()
                local value_5_34: string = "Chance%*"
                local value_7_37 = value_8_32
                local format_result_4 = value_5_34:format(value_7_37)
                cloned_value_8.Name = format_result_4
                cloned_value_8.Text = argument_2_13
                local value_5_36: Color3? = argument_3_8
                if not value_5_36 then
                    value_5_36 = Color3.new(1, 1, 1)
                end
                cloned_value_8.TextColor3 = value_5_36
                local value_5_37 = value_8_32
                cloned_value_8.LayoutOrder = value_5_37
                local value_5_38 = captured_value_64
                cloned_value_8.Parent = value_5_38

                return
            end
            captured_value_64 = scrolling_frame_child
            closure_ready_8 = true
        end
        do
            local captured_value_65, captured_value_66, closure_ready_9
            value_10_25 = function(argument_1_15: string)
                if not closure_ready_9 then
                    return
                end
                local value_2_18 = captured_value_65
                local value_4_35: string = argument_1_15
                local box_type_value_6 = captured_value_66.BoxType
                local find_item_info_result_3 = value_2_18:FindItemInfo(
                    value_4_35,
                    box_type_value_6
                )
                local get_display_name_result_3
                do
                    local take_fallback_5 = not find_item_info_result_3
                    if not take_fallback_5 then
                        local value_3_23 = captured_value_65
                        local value_5_40 = find_item_info_result_3
                        get_display_name_result_3 = value_3_23:GetDisplayName(value_5_40)
                        take_fallback_5 = not get_display_name_result_3
                    end
                    if take_fallback_5 then
                        get_display_name_result_3 = argument_1_15
                    end
                end

                return get_display_name_result_3
            end
            captured_value_65, captured_value_66 = captured_value_62, get_item_info_result_9
            closure_ready_9 = true
        end
        value_11_30 = {}
        value_12_32 = get_item_info_result_9.Contents
        value_13_19 = nil
        local value_14_17 = nil
        local box_type_value_2, value_16_46, value_17_38, value_18_39, value_19_16, value_21_7
        for key_16, value_37 in value_12_32, value_13_19, value_14_17 do
            value_15_30, value_16_46 = key_16, value_37
            value_17_38 = captured_value_62
            value_19_16 = value_16_46
            box_type_value_2 = get_item_info_result_9.BoxType
            value_17_38 = value_17_38:FindItemInfo(value_19_16, box_type_value_2)
            do
                local take_fallback_6 = not value_17_38
                if not take_fallback_6 then
                    value_18_39 = value_17_38.Rarity
                    take_fallback_6 = not value_18_39
                end
                if take_fallback_6 then
                    value_18_39 = "Common"
                end
            end
            value_19_16 = value_11_30[value_18_39] or ({})
            value_11_30[value_18_39] = value_19_16
            box_type_value_2 = value_11_30[value_18_39]
            value_21_7 = value_16_46
            value_19_16 = table.insert
            value_19_16(box_type_value_2, value_21_7)
        end
        value_12_32 = value_21
        value_8_32 = value_8_32 + 1
        value_13_19 = value_12_32:Clone()
        value_14_17 = "Chance%*"
        value_16_46 = value_8_32
        value_14_17 = value_14_17:format(value_16_46)
        value_13_19.Name = value_14_17
        value_14_17 = "Probabilities are rounded to the nearest decimal place and may not total exactly 100%"
        value_13_19.Text = value_14_17
        value_14_17 = Color3.new
        value_15_30 = 1
        value_16_46 = 1
        value_17_38 = 1
        value_14_17 = value_14_17(value_15_30, value_16_46, value_17_38)
        value_13_19.TextColor3 = value_14_17
        value_13_19.LayoutOrder = value_8_32
        value_13_19.Parent = scrolling_frame_child
        value_12_32 = get_item_info_result_9.RarityChances
        value_13_19 = nil
        value_14_17 = nil
        local chance_value
        for key_18, value_39 in value_12_32, value_13_19, value_14_17 do
            value_15_30, value_16_46 = key_18, value_39
            value_17_38 = value_11_30[value_16_46.Rarity]
            if not value_17_38 then
                continue
            end
            value_18_39 = purchase_is_repeatable
            value_19_16 = "%*: %*%%"
            value_21_7 = value_16_46.Rarity
            chance_value = value_16_46.Chance
            value_19_16 = value_19_16:format(value_21_7, chance_value)
            box_type_value_2 = rarity_value_3[value_16_46.Rarity]
            value_8_32 = value_8_32 + 1
            value_21_7 = value_18_39:Clone()
            chance_value = "Chance%*"
            local value_24_5 = value_8_32
            chance_value = chance_value:format(value_24_5)
            value_21_7.Name = chance_value
            value_21_7.Text = value_19_16
            chance_value = box_type_value_2
            if not chance_value then
                chance_value = Color3.new
                local value_23_6: number = 1
                local value_24_6: number = 1
                local value_25_2: number = 1
                chance_value = chance_value(value_23_6, value_24_6, value_25_2)
            end
            value_21_7.TextColor3 = chance_value
            value_21_7.LayoutOrder = value_8_32
            value_21_7.Parent = scrolling_frame_child
            value_18_39 = value_17_38
            value_19_16 = nil
            box_type_value_2 = nil
            for key_17, value_38 in value_18_39, value_19_16, box_type_value_2 do
                value_21_7, chance_value = key_17, value_38
                local format_value = string.format
                local value_24_7: string = "%.2f"
                local chance_value_2 = value_16_46.Chance
                local value_27_2 = #value_17_38
                local value_25_3 = chance_value_2 / value_27_2
                local format_result = format_value(value_24_7, value_25_3)
                local value_24_8 = value_21
                local value_25_4: string = "%* - %*%%/%* = %*%%"
                local value_28_2 = captured_value_62
                local value_30_2 = chance_value
                local box_type_value_3 = get_item_info_result_9.BoxType
                local find_item_info_result_2 = value_28_2:FindItemInfo(
                    value_30_2,
                    box_type_value_3
                )
                local value_27_3
                do
                    local take_fallback_7 = not find_item_info_result_2
                    if not take_fallback_7 then
                        local value_29_3 = captured_value_62
                        local value_31_2 = find_item_info_result_2
                        local get_display_name_result = value_29_3:GetDisplayName(value_31_2)
                        value_27_3 = get_display_name_result
                        take_fallback_7 = not value_27_3
                    end
                    if take_fallback_7 then
                        value_27_3 = chance_value
                    end
                end
                local chance_value_3 = value_16_46.Chance
                local value_29_5 = #value_17_38
                local value_30_4 = format_result
                local format_result_2 = value_25_4:format(
                    value_27_3,
                    chance_value_3,
                    value_29_5,
                    value_30_4
                )
                value_8_32 = value_8_32 + 1
                local cloned_value_7 = value_24_8:Clone()
                local value_27_5: string = "Chance%*"
                local value_29_6 = value_8_32
                local format_result_3 = value_27_5:format(value_29_6)
                cloned_value_7.Name = format_result_3
                cloned_value_7.Text = format_result_2
                local new_value_5: (number?, number?, number?) -> (Color3) = Color3.new
                local value_28_5: number = 1
                local value_29_7: number = 1
                local value_30_5: number = 1
                local new_result_5: Color3 = new_value_5(value_28_5, value_29_7, value_30_5)
                cloned_value_7.TextColor3 = new_result_5
                cloned_value_7.LayoutOrder = value_8_32
                cloned_value_7.Parent = scrolling_frame_child
            end
        end
        value_11_30 = {}
        value_12_32 = get_item_info_result_9.Godly
        if value_12_32 then
            value_14_17 = get_item_info_result_9.Godly
            value_13_19 = value_11_30
            table.insert(value_13_19, value_14_17)
        else
            value_12_32 = get_item_info_result_9.GodlyTable
            if value_12_32 then
                value_12_32 = get_item_info_result_9.GodlyTable
                value_13_19 = nil
                value_14_17 = nil
                for key_19, value_40 in value_12_32, value_13_19, value_14_17 do
                    value_15_30, value_16_46 = key_19, value_40
                    value_18_39 = value_11_30
                    value_19_16 = value_16_46
                    value_17_38 = table.insert
                    value_17_38(value_18_39, value_19_16)
                end
            else
                value_12_32 = get_item_info_result_9.GodlyTag
                if value_12_32 then
                    value_12_32 = get_item_info_result_9.Contents
                    value_13_19 = nil
                    value_14_17 = nil
                    for key_20, value_41 in value_12_32, value_13_19, value_14_17 do
                        value_15_30, value_16_46 = key_20, value_41
                        box_type_value_2 = value_16_46
                        value_21_7 = get_item_info_result_9.GodlyTag
                        value_19_16 = box_type_value_2 .. value_21_7
                        value_18_39 = value_11_30
                        value_17_38 = table.insert
                        value_17_38(value_18_39, value_19_16)
                    end
                end
            end
        end
        value_12_32 = #value_11_30
        value_13_19 = 0
        if value_13_19 < value_12_32 then
            value_12_32 = purchase_is_repeatable
            value_13_19 = "Godly: %*%%"
            value_15_30 = 0.2
            value_13_19 = value_13_19:format(value_15_30)
            value_14_17 = rarity_value_3.Godly
            value_8_32 = value_8_32 + 1
            value_15_30 = value_12_32:Clone()
            value_16_46 = "Chance%*"
            value_18_39 = value_8_32
            value_16_46 = value_16_46:format(value_18_39)
            value_15_30.Name = value_16_46
            value_15_30.Text = value_13_19
            value_16_46 = value_14_17
            if not value_16_46 then
                value_16_46 = Color3.new
                value_17_38 = 1
                value_18_39 = 1
                value_19_16 = 1
                value_16_46 = value_16_46(value_17_38, value_18_39, value_19_16)
            end
            value_15_30.TextColor3 = value_16_46
            value_15_30.LayoutOrder = value_8_32
            value_15_30.Parent = scrolling_frame_child
            value_12_32 = value_11_30
            value_13_19 = nil
            value_14_17 = nil
            for key_21, value_42 in value_12_32, value_13_19, value_14_17 do
                value_15_30, value_16_46 = key_21, value_42
                value_17_38 = #value_11_30
                if value_17_38 == 1 then
                    value_17_38 = value_21
                    value_18_39 = "%* - %*%%"
                    value_21_7 = captured_value_62
                    local value_23_7 = value_16_46
                    local box_type_value_4 = get_item_info_result_9.BoxType
                    value_21_7 = value_21_7:FindItemInfo(value_23_7, box_type_value_4)
                    do
                        local take_fallback_8 = not value_21_7
                        if not take_fallback_8 then
                            chance_value = captured_value_62
                            local value_24_9 = value_21_7
                            box_type_value_2 = (chance_value:GetDisplayName(value_24_9))
                            take_fallback_8 = not box_type_value_2
                        end
                        if take_fallback_8 then
                            box_type_value_2 = value_16_46
                        end
                    end
                    value_21_7 = 0.2
                    value_18_39 = value_18_39:format(box_type_value_2, value_21_7)
                    value_8_32 = value_8_32 + 1
                    value_19_16 = value_17_38:Clone()
                    box_type_value_2 = "Chance%*"
                    chance_value = value_8_32
                    box_type_value_2 = box_type_value_2:format(chance_value)
                    value_19_16.Name = box_type_value_2
                    value_19_16.Text = value_18_39
                    box_type_value_2 = Color3.new
                    value_21_7 = 1
                    chance_value = 1
                    local value_23_9: number = 1
                    box_type_value_2 = box_type_value_2(value_21_7, chance_value, value_23_9)
                    value_19_16.TextColor3 = box_type_value_2
                    value_19_16.LayoutOrder = value_8_32
                    value_19_16.Parent = scrolling_frame_child
                else
                    value_17_38 = string.format("%.3f", 0.2 / #value_11_30)
                    value_18_39 = value_21
                    value_19_16 = "%* - %*%%/%* = %*%%"
                    chance_value = captured_value_62
                    local value_24_10 = value_16_46
                    local box_type_value_5 = get_item_info_result_9.BoxType
                    chance_value = chance_value:FindItemInfo(value_24_10, box_type_value_5)
                    do
                        local take_fallback_9 = not chance_value
                        if not take_fallback_9 then
                            local value_23_11 = captured_value_62
                            local value_25_6 = chance_value
                            local get_display_name_result_2 = value_23_11:GetDisplayName(
                                value_25_6
                            )
                            value_21_7 = get_display_name_result_2
                            take_fallback_9 = not value_21_7
                        end
                        if take_fallback_9 then
                            value_21_7 = value_16_46
                        end
                    end
                    chance_value = 0.2
                    local value_23_13 = #value_11_30
                    local value_24_12 = value_17_38
                    value_19_16 = value_19_16:format(
                        value_21_7,
                        chance_value,
                        value_23_13,
                        value_24_12
                    )
                    value_8_32 = value_8_32 + 1
                    box_type_value_2 = value_18_39:Clone()
                    value_21_7 = "Chance%*"
                    local value_23_14 = value_8_32
                    value_21_7 = value_21_7:format(value_23_14)
                    box_type_value_2.Name = value_21_7
                    box_type_value_2.Text = value_19_16
                    value_21_7 = Color3.new
                    chance_value = 1
                    local value_23_15: number = 1
                    local value_24_13: number = 1
                    value_21_7 = value_21_7(chance_value, value_23_15, value_24_13)
                    box_type_value_2.TextColor3 = value_21_7
                    box_type_value_2.LayoutOrder = value_8_32
                    box_type_value_2.Parent = scrolling_frame_child
                end
            end
            value_12_32 = true
            value_13_19 = get_item_info_result_9.ChromaTable
            if value_13_19 == nil then
                value_13_19 = get_item_info_result_9.GodlyTag
                if value_13_19 == nil then
                    value_12_32 = false
                else
                    value_12_32 = true
                end
            end
            if not value_12_32 then
                value_13_19 = value_11_30
                value_14_17 = nil
                value_15_30 = nil
                for key_22, value_43 in value_13_19, value_14_17, value_15_30 do
                    value_16_46, value_17_38 = key_22, value_43
                    value_18_39 = captured_value_62
                    value_21_7 = value_17_38
                    chance_value = "Chroma"
                    box_type_value_2 = value_21_7 .. chance_value
                    value_21_7 = get_item_info_result_9.BoxType
                    value_18_39 = value_18_39:FindItemInfo(box_type_value_2, value_21_7)
                    if not value_18_39 then
                        continue
                    end
                    value_12_32 = true
                    break
                end
            end
            if value_12_32 then
                value_13_19 = value_21
                value_14_17 = "Chroma - %*%%"
                value_16_46 = string.format("%g", 0.004)
                value_14_17 = value_14_17:format(value_16_46)
                value_8_32 = value_8_32 + 1
                value_15_30 = value_13_19:Clone()
                value_16_46 = "Chance%*"
                value_18_39 = value_8_32
                value_16_46 = value_16_46:format(value_18_39)
                value_15_30.Name = value_16_46
                value_15_30.Text = value_14_17
                value_16_46 = Color3.new(1, 1, 1)
                value_15_30.TextColor3 = value_16_46
                value_15_30.LayoutOrder = value_8_32
                value_15_30.Parent = scrolling_frame_child
            end
        end

        return
    end
end
table_1.PopulateItemChances = populate_item_chances
local connect_item_chances
do
    local captured_value_67 = table_1
    connect_item_chances = function<T1>(argument_1_16: T1, argument_2_14, argument_3_9)
        local value_4_37 = captured_value_67
        value_4_37.ItemChancesFrame = argument_2_14
        local activated_value_4 = argument_3_9.Activated
        local value_6_31: (() -> ())?
        do
            local captured_value_68, captured_value_69, closure_ready_10
            value_6_31 = function(): ()
                if not closure_ready_10 then
                    return
                end
                if not captured_value_68.ViewedBoxId then
                    return
                end
                local value_1_32 = captured_value_68
                local value_3_25 = captured_value_69
                local viewed_box_id_value_2 = captured_value_68.ViewedBoxId
                local viewed_box_type_value = captured_value_68.ViewedBoxType
                value_1_32:PopulateItemChances(
                    value_3_25,
                    viewed_box_id_value_2,
                    viewed_box_type_value
                )
                local value_1_34 = captured_value_69
                local value_2_21: boolean = true
                value_1_34.Visible = value_2_21

                return
            end
            captured_value_68, captured_value_69 = captured_value_67, argument_2_14
            closure_ready_10 = true
        end
        activated_value_4:Connect(value_6_31)
        local value_6_32: string = "Close"
        local close_child = argument_2_14:WaitForChild(value_6_32)
        local value_6_33: string = "Button"
        local activated_value_5 = close_child:WaitForChild(value_6_33).Activated
        local value_7_39: (() -> ())?
        do
            local captured_value_70, closure_ready_11
            value_7_39 = function(): ()
                if not closure_ready_11 then
                    return
                end
                local value_1_35 = captured_value_70
                local value_2_22: boolean = false
                value_1_35.Visible = value_2_22

                return
            end
            captured_value_70 = argument_2_14
            closure_ready_11 = true
        end
        activated_value_5:Connect(value_7_39)
        local parent_value = argument_2_14.Parent
        while true do
            if not parent_value then
                break
            end
            local value_7_40: string = "GuiObject"
            local is_a_result_6 = parent_value:IsA(value_7_40)
            if not is_a_result_6 then
                break
            end
            local value_5_46 = parent_value
            local value_8_34: string = "Visible"
            local get_property_changed_signal_result = value_5_46:GetPropertyChangedSignal(
                value_8_34
            )
            local value_8_35: (() -> ())?
            do
                local captured_value_71, captured_value_72, closure_ready_12
                value_8_35 = function(): ()
                    if not closure_ready_12 then
                        return
                    end
                    if not captured_value_71.Visible then
                        local value_1_37 = captured_value_72
                        local value_2_23: boolean = false
                        value_1_37.Visible = value_2_23
                    end

                    return
                end
                captured_value_71, captured_value_72 = value_5_46, argument_2_14
                closure_ready_12 = true
            end
            get_property_changed_signal_result:Connect(value_8_35)
            parent_value = value_5_46.Parent
        end

        return
    end
end
table_1.ConnectItemChances = connect_item_chances
local request_unbox
do
    local captured_value_73 = shop_child
    request_unbox = function<T1>(argument_1_17: T1, argument_2_15: string, argument_3_10: string, argument_4_4: number)
        local value_5_48: number = 0
        do
            local take_fallback_10 = argument_4_4 <= value_5_48
            if not take_fallback_10 then
                take_fallback_10 = 3 < argument_4_4
            end
            if take_fallback_10 then
                return
            end
        end
        local table_5 = {}
        local value_8_36 = 1
        local value_6_38 = argument_4_4
        local value_7_43: number = 1
        for index = value_8_36, value_6_38, value_7_43 do
            value_8_36 = index
            local value_9_27 = captured_value_73
            local open_crate_value = value_9_27.OpenCrate
            local value_11_31: string = argument_2_15
            local value_12_33: string = "MysteryBox"
            local value_13_20: string = argument_3_10
            local invoke_server_result = open_crate_value:InvokeServer(
                value_11_31,
                value_12_33,
                value_13_20
            )
            if not invoke_server_result then
                continue
            end
            local table_10 = {
                MysteryBoxId = argument_2_15,
                RewardedItemId = invoke_server_result,
            }
            table_5[value_8_36] = table_10
        end
        value_6_38 = captured_value_73.BoxController
        value_8_36 = table_5
        value_6_38:Fire(value_8_36)

        return table_5
    end
end
table_1.RequestUnbox = request_unbox
local connect_purchase_currency
do
    local captured_value_74, captured_value_75 = require_result_4, shop_child
    connect_purchase_currency = function<T1>(argument_1_18: T1, argument_2_16): ()
        local value_3_26, value_4_42, value_5_50 = argument_2_16:GetChildren()
        for key_23, value_44 in value_3_26, value_4_42, value_5_50 do
            local value_6_39, value_7_44 = key_23, value_44
            local value_10_27: string = "Frame"
            local is_a_result_7 = value_7_44:IsA(value_10_27)
            if not is_a_result_7 then
                continue
            end
            local value_8_38 = captured_value_74
            local create_button_value = value_8_38.createButton
            local value_9_30 = value_7_44
            local value_10_28: (() -> ())?
            do
                local captured_value_76, captured_value_77, closure_ready_13
                value_10_28 = function(): ()
                    if not closure_ready_13 then
                        return
                    end
                    local buy_item_new_value = captured_value_76.BuyItemNew
                    local name_value_4 = captured_value_77.Name
                    local value_4_43: string = "Robux"
                    buy_item_new_value:InvokeServer(name_value_4, value_4_43)

                    return
                end
                captured_value_76, captured_value_77 = captured_value_75, value_7_44
                closure_ready_13 = true
            end
            local create_button_result = create_button_value(value_9_30, value_10_28)
        end

        return
    end
end
table_1.ConnectPurchaseCurrency = connect_purchase_currency
local display_item
do
    local captured_value_78, captured_value_79 = new_shop_value, require_result_2
    display_item = function<T1>(argument_1_19: T1, argument_2_17, argument_3_11: string, argument_4_5: string, argument_5_3: string?): ()
        local display_info_value_4 = captured_value_78[argument_3_11].DisplayInfo
        if not display_info_value_4 then
            local value_7_46 = captured_value_79
            local value_9_31: string = argument_3_11
            local value_10_29: string = argument_4_5
            display_info_value_4 = value_7_46:GetDisplayInfo(value_9_31, value_10_29)
        end
        local icon_value_7 = argument_2_17.Container.Icon
        local image_value_3 = display_info_value_4.Image
        icon_value_7.Image = image_value_3
        local text_label_value_4 = argument_2_17.ItemName.TextLabel
        local name_value_5 = display_info_value_4.Name
        text_label_value_4.Text = name_value_5
        local item_name_value_8 = argument_2_17.ItemName
        local color_value_3 = display_info_value_4.Color
        item_name_value_8.BackgroundColor3 = color_value_3
        local subtitle_value_2 = argument_2_17.Container.Subtitle
        local value_9_32: string? = argument_5_3 or ""
        subtitle_value_2.Text = value_9_32

        return
    end
end
table_1.DisplayItem = display_item
local value_24: string = "ProductPurchaseComplete"
local on_client_event_value = shop_child:WaitForChild(value_24).OnClientEvent
local value_24_2
do
    local captured_value_80, captured_value_81, captured_value_82, captured_value_83 = table_18, new_shop_value, table_1, table_17
    value_24_2 = function(argument_1_20: string, argument_2_18: number)
        local value_3_28 = captured_value_80
        local value_4_44 = nil
        local value_5_51 = nil
        local value_6_41, value_7_48
        for key_24, value_45 in value_3_28, value_4_44, value_5_51 do
            value_6_41, value_7_48 = key_24, value_45
            local value_9_33 = captured_value_81
            local value_8_40 = value_9_33[value_6_41]
            local required_purchases_value_3 = value_8_40.RequiredPurchases
            if not required_purchases_value_3 then
                continue
            end
            local find_value_2 = table.find
            local required_purchases_value_4 = value_8_40.RequiredPurchases
            local value_11_32: string = argument_1_20
            local find_result_2 = find_value_2(required_purchases_value_4, value_11_32)
            if not find_result_2 then
                continue
            end
            local value_9_34 = captured_value_82
            local value_11_33 = value_6_41
            local has_required_purchases_result_2 = value_9_34:HasRequiredPurchases(value_11_33)
            if not has_required_purchases_result_2 then
                continue
            end
            local value_10_31 = captured_value_80
            local value_9_36 = value_10_31[argument_1_20]
            if not value_9_36 then
                continue
            end
            local value_10_32 = captured_value_80
            local value_9_37 = value_10_32[argument_1_20]
            local visible_value_2 = value_9_37.Visible
            if not visible_value_2 then
                continue
            end
            local value_9_38: boolean = true
            value_7_48.Visible = value_9_38
        end
        value_4_44 = captured_value_83
        value_3_28 = value_4_44[argument_1_20]
        if value_3_28 then
            value_3_28, value_4_44, value_5_51 = captured_value_83[argument_1_20].Container.Prices:GetChildren()
            for key_25, value_46 in value_3_28, value_4_44, value_5_51 do
                value_6_41, value_7_48 = key_25, value_46
                local value_10_33: string = "Frame"
                local is_a_result_8 = value_7_48:IsA(value_10_33)
                if not is_a_result_8 then
                    continue
                end
                local name_value_6 = value_7_48.Name
                local value_8_42: boolean?
                if name_value_6 ~= "OwnedPrice" then
                    value_8_42 = false
                else
                    value_8_42 = true
                end
                value_7_48.Visible = value_8_42
            end
        end

        return
    end
end
on_client_event_value:Connect(value_24_2)
local value_24_3: string = "InventoryDataChanged"
local event_value = inventory_child:WaitForChild(value_24_3).Event
local value_24_4
do
    local captured_value_84 = table_17
    value_24_4 = function<T1>(argument_1_21: T1, argument_2_19, argument_3_12)
        local value_5_52 = captured_value_84
        local value_4_45 = value_5_52[argument_2_19]
        if value_4_45 then
            value_4_45 = 0
            if value_4_45 < argument_3_12 then
                local value_6_42
                value_4_45, value_5_52, value_6_42 = captured_value_84[argument_2_19].Container.Prices:GetChildren()
                for key_26, value_47 in value_4_45, value_5_52, value_6_42 do
                    local value_7_49, value_8_43 = key_26, value_47
                    local value_11_34: string = "Frame"
                    local is_a_result_9 = value_8_43:IsA(value_11_34)
                    if not is_a_result_9 then
                        continue
                    end
                    local name_value_7 = value_8_43.Name
                    local value_9_41: boolean?
                    if name_value_7 ~= "OwnedPrice" then
                        value_9_41 = false
                    else
                        value_9_41 = true
                    end
                    value_8_43.Visible = value_9_41
                end
            end
        end

        return
    end
end
event_value:Connect(value_24_4)

local function initialize<T1>(argument_1_22: T1): ()
    return
end

table_1.Initialize = initialize

return table_1
