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

do
    local table_1 = {
        nil,
        nil,
        nil,
        nil,
    }
    local value_2: string = "Event"
    local value_3: string = "MysteryBox2"
    local value_4: string = "Dual"
    local value_5: string = "Electric"
    table_1[1], table_1[2], table_1[3], table_1[4] = value_2, value_3, value_4, value_5
    local require_value = require
    local game_value: DataModel = game
    local value_5_2: string = "ReplicatedStorage"
    local replicated_storage_service: Instance = game_value:GetService(value_5_2)
    local value_5_3: string = "Database"
    local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_3)
    local value_5_4: string = "Sync"
    local require_result = require_value(database_child:WaitForChild(value_5_4))
    local require_value_2 = require
    local game_value_2: DataModel = game
    local value_6: string = "ReplicatedStorage"
    local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
    local value_6_2: string = "ClientServices"
    local client_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
    local value_6_3: string = "Button"
    local require_result_2 = require_value_2(client_services_child:WaitForChild(value_6_3))
    local require_value_3 = require
    local game_value_3: DataModel = game
    local value_7: string = "ReplicatedStorage"
    local replicated_storage_service_3: Instance = game_value_3:GetService(value_7)
    local value_7_2: string = "ClientServices"
    local client_services_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_7_2)
    local value_7_3: string = "ItemService"
    local require_result_3 = require_value_3(client_services_child_2:WaitForChild(value_7_3))
    local require_value_4 = require
    local game_value_4: DataModel = game
    local value_8: string = "ReplicatedStorage"
    local replicated_storage_service_4: Instance = game_value_4:GetService(value_8)
    local value_8_2: string = "Modules"
    local modules_child: Instance? = replicated_storage_service_4:WaitForChild(value_8_2)
    local value_8_3: string = "WindowService"
    local require_result_4 = require_value_4(modules_child:WaitForChild(value_8_3))
    local require_value_5 = require
    local game_value_5: DataModel = game
    local value_9: string = "ReplicatedStorage"
    local replicated_storage_service_5: Instance = game_value_5:GetService(value_9)
    local value_9_2: string = "Modules"
    local modules_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_9_2)
    local value_9_3: string = "ProfileData"
    local require_result_5 = require_value_5(modules_child_2:WaitForChild(value_9_3))
    local game_value_6: DataModel = game
    local value_9_4: string = "ReplicatedStorage"
    local replicated_storage_service_6: Instance = game_value_6:GetService(value_9_4)
    local value_9_5: string = "Remotes"
    local remotes_child: Instance? = replicated_storage_service_6:WaitForChild(value_9_5)
    local value_9_6: string = "Inventory"
    local inventory_child = remotes_child:WaitForChild(value_9_6)
    local game_value_7: DataModel = game
    local value_10: string = "ReplicatedStorage"
    local replicated_storage_service_7: Instance = game_value_7:GetService(value_10)
    local value_10_2: string = "Remotes"
    local remotes_child_2: Instance? = replicated_storage_service_7:WaitForChild(value_10_2)
    local value_10_3: string = "Shop"
    local shop_child = remotes_child_2:WaitForChild(value_10_3)
    local new_shop_value = require_result.NewShop
    local parent_value: Instance? = script.Parent
    local table_10 = {Navigation = 0, Featured = 0}
    local table_11 = {ButtonsList = nil}
    table_10.Navigation = table_11
    local table_11_2 = {LatestBox = nil, ItemsList = nil}
    table_10.Featured = table_11_2
    local value_13: string = "Small"
    local small_child = parent_value:WaitForChild(value_13)
    local value_14: string = "Small"
    local small_child_2 = parent_value:WaitForChild(value_14)
    local value_14_2: string = "Container"
    local container_child = small_child_2:WaitForChild(value_14_2)
    local value_15: string = "Main"
    local main_child = container_child:WaitForChild(value_15)
    local value_16: string = "Title"
    local title_child = container_child:WaitForChild(value_16)
    local value_16_2: string = "Container"
    local container_child_2 = title_child:WaitForChild(value_16_2)
    local navigation_value = table_10.Navigation
    local value_18: string = "Container"
    local container_child_3 = small_child:WaitForChild(value_18)
    local value_18_2: string = "Main"
    local main_child_2 = container_child_3:WaitForChild(value_18_2)
    local value_18_3: string = "Featured"
    local featured_child = main_child_2:WaitForChild(value_18_3)
    local value_18_4: string = "Nav"
    local nav_child = featured_child:WaitForChild(value_18_4)
    local value_18_5: string = "Container"
    local container_child_4 = nav_child:WaitForChild(value_18_5)
    navigation_value.ButtonsList = container_child_4
    local value_17_6: string = "Featured"
    local value_12_4 = (main_child:WaitForChild(value_17_6))
    local value_17_7: string = "Nav"
    local value_10_4 = (value_12_4:WaitForChild(value_17_7))
    local value_17_8: string = "BuyPopup"
    local buy_popup_child = main_child:WaitForChild(value_17_8)
    local value_18_6: string = "ViewContents"
    local view_contents_child = main_child:WaitForChild(value_18_6)
    local value_19: string = "Container"
    local container_child_5 = view_contents_child:WaitForChild(value_19)
    local value_19_2: string = "Main"
    local main_child_3 = container_child_5:WaitForChild(value_19_2)
    local value_19_3: string = "BoxContents"
    local box_contents_child = main_child_3:WaitForChild(value_19_3)
    local value_19_4: string = "Container"
    local container_child_6 = box_contents_child:WaitForChild(value_19_4)
    local value_19_5: string = "ScrollingFrame"
    local scrolling_frame_child = container_child_6:WaitForChild(value_19_5)
    local value_20: string = "PurchaseCurrency"
    local purchase_currency_child = main_child:WaitForChild(value_20)
    local value_21: string = "Processing"
    local processing_child = small_child:WaitForChild(value_21)
    local value_22: string = "Items"
    local items_child = main_child:WaitForChild(value_22)
    local value_22_2: string = "Container"
    local container_child_7 = items_child:WaitForChild(value_22_2)
    local value_22_3: string = "ScrollFrame"
    local scroll_frame_child = container_child_7:WaitForChild(value_22_3)
    local value_23: string = "ItemGridLayout"
    local item_grid_layout_child = scroll_frame_child:WaitForChild(value_23)
    local value_24: string = "NewItem"
    local new_item_child = scroll_frame_child:WaitForChild(value_24)
    local value_25: string = "Container"
    local container_child_8 = new_item_child:WaitForChild(value_25)
    local value_25_2: string = "Prices"
    local prices_child = container_child_8:WaitForChild(value_25_2)
    local value_25_3: string = "Gems"
    local gems_child = prices_child:WaitForChild(value_25_3)
    local script_value_2: LuaSourceContainer = script
    gems_child.Parent = script_value_2
    local value_26: string = "Container"
    local container_child_9 = buy_popup_child:WaitForChild(value_26)
    local value_26_2: string = "Right"
    local right_child = container_child_9:WaitForChild(value_26_2)
    local value_26_3: string = "PriceFrame"
    local price_frame_child = right_child:WaitForChild(value_26_3)
    local value_26_4: string = "Gems"
    local gems_child_2 = price_frame_child:WaitForChild(value_26_4)
    local script_value_3: LuaSourceContainer = script
    gems_child_2.Parent = script_value_3
    local value_27: string = "NewItem"
    local new_item_child_2 = scrolling_frame_child:WaitForChild(value_27)
    local script_value_4: LuaSourceContainer = script
    new_item_child_2.Parent = script_value_4
    local value_28: string = "Container"
    local container_child_10 = view_contents_child:WaitForChild(value_28)
    local value_28_2: string = "BuyFrame"
    local buy_frame_child = container_child_10:WaitForChild(value_28_2)
    local value_28_3: string = "CurrencyFrame"
    local currency_frame_child = buy_frame_child:WaitForChild(value_28_3)
    local script_value_5: LuaSourceContainer = script
    currency_frame_child.Parent = script_value_5
    local value_29: string = "Container"
    local container_child_11 = value_12_4:WaitForChild(value_29)
    local value_29_2: string = "ItemFrame"
    local item_frame_child = container_child_11:WaitForChild(value_29_2)
    local script_value_6: LuaSourceContainer = script
    item_frame_child.Parent = script_value_6
    local table_28 = {
        Weapons = {Weapons = true, MysteryBox = true, ItemBundle = true},
    }
    local table_29_2 = {
        MysteryBox = "Mystery Box",
        Event = "Event",
        Effects = "Effect",
    }
    local table_30 = {
        Godly = 10,
        Legendary = 20,
        Rare = 30,
        Uncommon = 40,
        Common = 50,
    }
    local table_31 = {"Featured"}

    local function comma_value(argument_1)
        local value_2_2 = argument_1
        local value_3_5: nil = nil
        while true do
            local gsub_value = string.gsub
            local value_5_11 = value_2_2
            local value_6_10: string = "^(-?%d+)(%d%d%d)"
            local value_7_13: string = "%1,%2"
            local gsub_result, value_5_12 = gsub_value(value_5_11, value_6_10, value_7_13)
            value_2_2 = gsub_result
            local value_3_6 = value_5_12
            if value_3_6 == 0 then
                break
            end
        end

        return value_2_2
    end

    local go_to_page
    do
        local captured_value = container_child_2
        go_to_page = function(argument_1_2, argument_2: string): ()
            local value_3_7 = captured_value
            local value_5_13 = "Back"
            value_3_7 = value_3_7:WaitForChild(value_5_13)
            local value_4_8
            if argument_2 == "Featured" then
                value_4_8 = false
            else
                value_4_8 = true
            end
            value_3_7.Visible = value_4_8
            value_3_7 = captured_value
            value_5_13 = "Title"
            value_3_7 = value_3_7:WaitForChild(value_5_13)
            if argument_2 ~= "Featured" then
                value_4_8 = false
            else
                value_4_8 = true
            end
            value_3_7.Visible = value_4_8
            value_3_7, value_4_8, value_5_13 = argument_1_2:GetChildren()
            for key, value in value_3_7, value_4_8, value_5_13 do
                local value_6_11, value_7_14 = key, value
                local value_10_5: string = "GuiObject"
                local is_a_result = value_7_14:IsA(value_10_5)
                if not is_a_result then
                    continue
                end
                local name_value = value_7_14.Name
                local value_8_14: boolean?
                if name_value ~= argument_2 then
                    value_8_14 = false
                else
                    value_8_14 = true
                end
                value_7_14.Visible = value_8_14
            end

            return
        end
    end
    local go_back
    do
        local captured_value_2, captured_value_3 = go_to_page, main_child
        go_back = function()
            table.remove(table_31)
            captured_value_2(captured_value_3, table_31[#table_31])

            return
        end
    end

    local function get_current_page(argument_1_3)
        local value_2_5, value_3_9, value_4_10 = argument_1_3:GetChildren()
        for key_2, value_30 in value_2_5, value_3_9, value_4_10 do
            local value_5_15, value_6_13 = key_2, value_30
            local value_9_11: string = "GuiObject"
            local is_a_result_2 = value_6_13:IsA(value_9_11)
            if not is_a_result_2 then
                continue
            end
            local visible_value = value_6_13.Visible
            if not visible_value then
                continue
            end

            return value_6_13
        end

        return
    end

    local get_sorted_item_list
    do
        local captured_value_4, captured_value_5, captured_value_6 = new_shop_value, require_result_3, table_30
        get_sorted_item_list = function()
            local table_1_2 = {}
            local value_2_6 = captured_value_4
            local value_3_10 = nil
            local value_4_11 = nil
            local value_5_16, value_6_14, value_7_16
            for key_3, value_31 in value_2_6, value_3_10, value_4_11 do
                value_5_16, value_6_14 = key_3, value_31
                value_7_16 = captured_value_5
                local value_9_12 = value_5_16
                local type_value = value_6_14.Type
                if not (value_7_16:FindItemInfo(value_9_12, type_value)) then
                    continue
                end
                local table_9 = {ID = 0, Info = 0, Shop = 0}
                table_9.ID = value_5_16
                local value_10_6 = captured_value_5
                local value_12_5 = value_5_16
                local type_value_2 = value_6_14.Type
                local get_item_info_result = value_10_6:GetItemInfo(value_12_5, type_value_2)
                table_9.Info = get_item_info_result
                table_9.Shop = value_6_14
                local value_8_17 = table_1_2
                value_7_16 = table.insert
                value_7_16(value_8_17, table_9)
            end
            value_2_6 = table.sort
            value_3_10 = table_1_2
            do
                local captured_value_7 = captured_value_6
                if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_7) then
                    value_4_11 = closure_cache[1]
                else
                    local closure_ready
                    value_4_11 = function(argument_1_4, argument_2_2)
                        if not closure_ready then
                            return
                        end
                        local id_value_2 = argument_1_4.ID
                        local info_value = argument_1_4.Info
                        local shop_value = argument_1_4.Shop
                        local id_value_3 = argument_2_2.ID
                        local info_value_2 = argument_2_2.Info
                        local shop_value_2 = argument_2_2.Shop
                        local value_6_15 = info_value.Rarity or "Common"
                        local value_4_12 = info_value_2.Rarity or "Common"
                        if value_6_15 == value_4_12 then
                            if shop_value.Price.Coins then
                                if shop_value_2.Price.Coins then
                                    local value_9_14: boolean?
                                    if not (shop_value.Price.Coins < shop_value_2.Price.Coins) then
                                        value_9_14 = false
                                    else
                                        value_9_14 = true
                                    end

                                    return value_9_14
                                end
                            end
                            if shop_value.Price.Coins then
                                if not shop_value_2.Price.Coins then
                                    return true
                                end
                            end
                            if shop_value.Price.Gems then
                                if shop_value_2.Price.Gems then
                                    local value_9_16: boolean?
                                    if not (shop_value.Price.Gems < shop_value_2.Price.Gems) then
                                        value_9_16 = false
                                    else
                                        value_9_16 = true
                                    end

                                    return value_9_16
                                end
                            end
                        end
                        local value_8_18 = captured_value_7[value_6_15]
                        local value_9_19: boolean?
                        if not (captured_value_7[value_4_12] < value_8_18) then
                            value_9_19 = false
                        else
                            value_9_19 = true
                        end

                        return value_9_19
                    end
                    closure_ready = true
                    if closure_cache[1] == nil then
                        closure_cache[1] = value_4_11
                        closure_cache[2] = captured_value_7
                    end
                end
            end
            value_2_6(value_3_10, value_4_11)
            value_2_6 = {}
            value_3_10 = table_1_2
            value_4_11 = nil
            value_5_16 = nil
            for key_4, value_33 in value_3_10, value_4_11, value_5_16 do
                value_6_14, value_7_16 = key_4, value_33
                local id_value = value_7_16.ID
                local value_9_13 = value_2_6
                local insert_value = table.insert
                insert_value(value_9_13, id_value)
            end

            return value_2_6
        end
    end
    local on_item_purchase_requested: ((string, string) -> ())?
    do
        local captured_value_8, captured_value_9, captured_value_10, captured_value_11 = new_shop_value, processing_child, shop_child, small_child
        on_item_purchase_requested = function(argument_1_5: string, argument_2_3: string): ()
            local type_value_3 = captured_value_8[argument_1_5].Type
            do
                local take_fallback = type_value_3 == "MysteryBox"
                if take_fallback or type_value_3 == "Eggs" then
                    local value_5_17 = captured_value_9
                    local value_6_16: boolean = true
                    value_5_17.Visible = value_6_16
                    local open_crate_value = captured_value_10.OpenCrate
                    local value_7_18: string = argument_1_5
                    local value_8_19 = type_value_3
                    local value_9_20: string = argument_2_3
                    local value_3_12 = (open_crate_value:InvokeServer(
                        value_7_18,
                        value_8_19,
                        value_9_20
                    ))
                    local value_5_20 = captured_value_11
                    local value_6_18: boolean = false
                    value_5_20.Visible = value_6_18
                    local value_5_21 = captured_value_9
                    local value_6_19: boolean = false
                    value_5_21.Visible = value_6_19
                    local box_controller_value = captured_value_10.BoxController
                    local value_7_19: string = argument_1_5
                    local value_8_20 = value_3_12
                    box_controller_value:Fire(value_7_19, value_8_20)

                    return
                end
            end
            local value_5_24 = captured_value_9
            local value_6_21: boolean = true
            value_5_24.Visible = value_6_21
            local buy_item_new_value = captured_value_10.BuyItemNew
            local value_7_20: string = argument_1_5
            local value_8_21: string = argument_2_3
            buy_item_new_value:InvokeServer(value_7_20, value_8_21)
            local value_5_27 = captured_value_11
            local value_6_23: boolean = false
            value_5_27.Visible = value_6_23
            local value_5_28 = captured_value_9
            local value_6_24: boolean = false
            value_5_28.Visible = value_6_24

            return
        end
    end
    local view_box_contents
    do
        local captured_value_12, captured_value_13, captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21 = view_contents_child, new_shop_value, require_result_3, scrolling_frame_child, new_item_child_2, currency_frame_child, comma_value, on_item_purchase_requested, go_to_page, main_child
        view_box_contents = function(argument_1_6: string, argument_2_4: string)
            local value_3_13 = captured_value_12
            local value_5_29: string = "Container"
            local container_child_12 = value_3_13:WaitForChild(value_5_29)
            local value_5_30: string = "Main"
            local main_child_4 = container_child_12:WaitForChild(value_5_30)
            local value_5_31: string = "BoxFrame"
            local box_frame_child = main_child_4:WaitForChild(value_5_31)
            local value_5_32: string = "ItemContainer"
            local item_container_child = box_frame_child:WaitForChild(value_5_32)
            local value_4_18 = captured_value_13[argument_1_6]
            local value_5_34 = captured_value_14
            local value_7_21 = argument_1_6
            local value_8_22 = argument_2_4
            local get_display_info_result = value_5_34:GetDisplayInfo(value_7_21, value_8_22)
            local value_6_25 = item_container_child.Container.Icon
            value_7_21 = get_display_info_result.Image
            value_6_25.Image = value_7_21
            value_6_25 = item_container_child.ItemName.TextLabel
            value_7_21 = get_display_info_result.Name
            value_6_25.Text = value_7_21
            value_6_25 = item_container_child.ItemName
            value_7_21 = get_display_info_result.Color
            value_6_25.BackgroundColor3 = value_7_21
            local value_5_36 = captured_value_14
            value_7_21 = argument_1_6
            value_8_22 = argument_2_4
            local get_item_info_result_2 = value_5_36:GetItemInfo(value_7_21, value_8_22)
            local contents_value = get_item_info_result_2.Contents
            value_6_25, value_7_21, value_8_22 = captured_value_15:GetChildren()
            local value_10_8, value_9_21
            for key_5, value_34 in value_6_25, value_7_21, value_8_22 do
                value_9_21, value_10_8 = key_5, value_34
                local value_13_5: string = "Frame"
                local is_a_result_3 = value_10_8:IsA(value_13_5)
                if not is_a_result_3 then
                    continue
                end
                value_10_8:Destroy()
            end
            value_6_25 = contents_value
            value_7_21 = nil
            value_8_22 = nil
            for key_6, value_35 in value_6_25, value_7_21, value_8_22 do
                value_9_21, value_10_8 = key_6, value_35
                local value_11_5 = captured_value_16
                local cloned_value = value_11_5:Clone()
                local value_12_9 = captured_value_14
                local value_14_6 = value_10_8
                local box_type_value = get_item_info_result_2.BoxType
                local get_display_info_result_2 = value_12_9:GetDisplayInfo(
                    value_14_6,
                    box_type_value
                )
                local container_value = cloned_value.Container
                local icon_value = container_value.Icon
                local image_value = get_display_info_result_2.Image
                icon_value.Image = image_value
                local item_name_value = cloned_value.ItemName
                local text_label_value = item_name_value.TextLabel
                local name_value_2 = get_display_info_result_2.Name
                text_label_value.Text = name_value_2
                local item_name_value_2 = cloned_value.ItemName
                local color_value = get_display_info_result_2.Color
                item_name_value_2.BackgroundColor3 = color_value
                local container_value_2 = cloned_value.Container
                local owned_text_value = container_value_2.OwnedText
                local value_14_7: boolean = false
                owned_text_value.Visible = value_14_7
                local container_value_3 = cloned_value.Container
                local owned_background_value = container_value_3.OwnedBackground
                local value_14_8: boolean = false
                owned_background_value.Visible = value_14_8
                cloned_value.LayoutOrder = value_9_21
                local value_13_7 = captured_value_15
                cloned_value.Parent = value_13_7
            end
            value_6_25, value_7_21, value_8_22 = captured_value_12.Container.BuyFrame:GetChildren()
            for key_7, value_36 in value_6_25, value_7_21, value_8_22 do
                value_9_21, value_10_8 = key_7, value_36
                local value_13_8: string = "Frame"
                local is_a_result_4 = value_10_8:IsA(value_13_8)
                if not is_a_result_4 then
                    continue
                end
                value_10_8:Destroy()
            end
            value_6_25 = value_4_18.Price
            value_7_21 = nil
            value_8_22 = nil
            for key_8, value_37 in value_6_25, value_7_21, value_8_22 do
                value_9_21, value_10_8 = key_8, value_37
                local value_11_9: nil = nil
                local value_12_13 = captured_value_14
                local value_14_9 = value_9_21
                local value_15_7: string = "Materials"
                local item_exists_result = value_12_13:ItemExists(value_14_9, value_15_7)
                local value_11_10
                if item_exists_result then
                    local value_12_15 = captured_value_14
                    local value_14_10 = value_9_21
                    local value_15_8: string = "Materials"
                    local get_item_info_result_3 = value_12_15:GetItemInfo(value_14_10, value_15_8)
                    value_11_10 = get_item_info_result_3
                else
                    local value_12_17 = captured_value_14
                    local value_14_11 = value_9_21
                    local value_15_9: string = "Weapons"
                    local item_exists_result_2 = value_12_17:ItemExists(value_14_11, value_15_9)
                    if item_exists_result_2 then
                        local value_12_19 = captured_value_14
                        local value_14_12 = value_9_21
                        local value_15_10: string = "Weapons"
                        local get_item_info_result_4 = value_12_19:GetItemInfo(
                            value_14_12,
                            value_15_10
                        )
                        value_11_10 = get_item_info_result_4
                    else
                        local warn_value = warn
                        local value_13_13: string = "Currency does not exist"
                        warn_value(value_13_13)
                        continue
                    end
                end
                local value_12_21 = captured_value_14
                local value_14_13 = value_11_10
                local get_item_image_result = value_12_21:GetItemImage(value_14_13)
                local value_5_38 = get_item_image_result
                local value_11_11 = captured_value_17
                local cloned_value_2 = value_11_11:Clone()
                local container_value_4 = cloned_value_2.Container
                local icon_value_2 = container_value_4.Icon
                icon_value_2.Image = value_5_38
                local container_value_5 = cloned_value_2.Container
                local price_frame_value = container_value_5.PriceFrame
                local price_label_value = price_frame_value.PriceLabel
                local value_13_15 = captured_value_18
                local value_14_14 = value_10_8
                local value_13_16 = value_13_15(value_14_14)
                price_label_value.Text = value_13_16
                local buy_value = cloned_value_2.Buy
                local activated_value = buy_value.Activated
                local value_14_15: (() -> ())?
                do
                    local captured_value_22, captured_value_23, captured_value_24, closure_ready_2
                    value_14_15 = function(): ()
                        if not closure_ready_2 then
                            return
                        end
                        captured_value_22(captured_value_23, captured_value_24)

                        return
                    end
                    captured_value_22, captured_value_23, captured_value_24 = captured_value_19, argument_1_6, value_9_21
                    closure_ready_2 = true
                end
                activated_value:Connect(value_14_15)
                cloned_value_2.LayoutOrder = value_10_8
                local value_12_25 = captured_value_12
                local container_value_6 = value_12_25.Container
                local buy_frame_value = container_value_6.BuyFrame
                cloned_value_2.Parent = buy_frame_value
            end
            value_7_21 = table_31
            value_8_22 = "ViewContents"
            table.insert(value_7_21, value_8_22)
            captured_value_20(captured_value_21, "ViewContents")

            return
        end
    end
    local view_buy_popup
    do
        local captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32 = new_shop_value, require_result_3, buy_popup_child, gems_child_2, comma_value, on_item_purchase_requested, go_to_page, main_child
        view_buy_popup = function(argument_1_7: string)
            local value_2_8 = captured_value_25[argument_1_7]
            local display_info_value = value_2_8.DisplayInfo
            local type_value_4
            if not display_info_value then
                local value_3_20 = captured_value_26
                local value_5_39: string = argument_1_7
                type_value_4 = value_2_8.Type
                display_info_value = value_3_20:GetDisplayInfo(value_5_39, type_value_4)
            end
            local value_4_20 = captured_value_27
            type_value_4 = "Container"
            local container_child_13 = value_4_20:WaitForChild(type_value_4)
            type_value_4 = "Left"
            local left_child = container_child_13:WaitForChild(type_value_4)
            type_value_4 = "ItemFrame"
            local item_frame_child_2 = left_child:WaitForChild(type_value_4)
            type_value_4 = "ItemContainer"
            local item_container_child_2 = item_frame_child_2:WaitForChild(type_value_4)
            local value_5_44 = captured_value_26
            local value_7_22 = argument_1_7
            local type_value_5 = value_2_8.Type
            local find_item_info_result = (value_5_44:FindItemInfo(value_7_22, type_value_5)) or ({})
            type_value_4 = item_container_child_2.Container.Icon
            value_7_22 = display_info_value.Image
            type_value_4.Image = value_7_22
            type_value_4 = item_container_child_2.ItemName.TextLabel
            value_7_22 = display_info_value.Name
            type_value_4.Text = value_7_22
            type_value_4 = item_container_child_2.ItemName
            value_7_22 = display_info_value.Color
            type_value_4.BackgroundColor3 = value_7_22
            type_value_4 = captured_value_27.Container.Right.Description.TextLabel
            value_7_22 = value_2_8.Description
            if not value_7_22 then
                value_7_22 = find_item_info_result.Description or ""
            end
            type_value_4.Text = value_7_22
            type_value_4, value_7_22, type_value_5 = captured_value_27.Container.Right.PriceFrame:GetChildren()
            local value_10_9, value_9_22
            for key_9, value_38 in type_value_4, value_7_22, type_value_5 do
                value_9_22, value_10_9 = key_9, value_38
                local value_13_18: string = "Frame"
                local is_a_result_5 = value_10_9:IsA(value_13_18)
                if not is_a_result_5 then
                    continue
                end
                value_10_9:Destroy()
            end
            type_value_4 = value_2_8.Price
            value_7_22 = nil
            type_value_5 = nil
            for key_10, value_39 in type_value_4, value_7_22, type_value_5 do
                value_9_22, value_10_9 = key_10, value_39
                local value_11_15: nil = nil
                local value_12_28 = captured_value_26
                local value_14_16 = value_9_22
                local value_15_11: string = "Materials"
                local item_exists_result_3 = value_12_28:ItemExists(value_14_16, value_15_11)
                local value_11_16
                if item_exists_result_3 then
                    local value_12_30 = captured_value_26
                    local value_14_17 = value_9_22
                    local value_15_12: string = "Materials"
                    local get_item_info_result_5 = value_12_30:GetItemInfo(
                        value_14_17,
                        value_15_12
                    )
                    value_11_16 = get_item_info_result_5
                else
                    local value_12_32 = captured_value_26
                    local value_14_18 = value_9_22
                    local value_15_13: string = "Weapons"
                    local item_exists_result_4 = value_12_32:ItemExists(value_14_18, value_15_13)
                    if item_exists_result_4 then
                        local value_12_34 = captured_value_26
                        local value_14_19 = value_9_22
                        local value_15_14: string = "Weapons"
                        local get_item_info_result_6 = value_12_34:GetItemInfo(
                            value_14_19,
                            value_15_14
                        )
                        value_11_16 = get_item_info_result_6
                    else
                        local warn_value_2 = warn
                        local value_13_23: string = "Currency does not exist"
                        warn_value_2(value_13_23)
                        continue
                    end
                end
                local value_12_36 = captured_value_26
                local value_14_20 = value_11_16
                local get_item_image_result_2 = value_12_36:GetItemImage(value_14_20)
                local value_5_46 = get_item_image_result_2
                local value_11_17 = captured_value_28
                local cloned_value_3 = value_11_17:Clone()
                local container_value_7 = cloned_value_3.Container
                local icon_value_3 = container_value_7.Icon
                icon_value_3.Image = value_5_46
                local container_value_8 = cloned_value_3.Container
                local price_frame_value_2 = container_value_8.PriceFrame
                local price_label_value_2 = price_frame_value_2.PriceLabel
                local value_13_25 = captured_value_29
                local value_14_21 = value_10_9
                local value_13_26 = value_13_25(value_14_21)
                price_label_value_2.Text = value_13_26
                local buy_value_2 = cloned_value_3.Buy
                local activated_value_2 = buy_value_2.Activated
                local value_14_22: (() -> ())?
                do
                    local captured_value_33, captured_value_34, captured_value_35, closure_ready_3
                    value_14_22 = function(): ()
                        if not closure_ready_3 then
                            return
                        end
                        captured_value_33(captured_value_34, captured_value_35)

                        return
                    end
                    captured_value_33, captured_value_34, captured_value_35 = captured_value_30, argument_1_7, value_9_22
                    closure_ready_3 = true
                end
                activated_value_2:Connect(value_14_22)
                cloned_value_3.LayoutOrder = value_10_9
                local value_12_40 = captured_value_27
                local container_value_9 = value_12_40.Container
                local right_value = container_value_9.Right
                local price_frame_value_3 = right_value.PriceFrame
                cloned_value_3.Parent = price_frame_value_3
            end
            value_7_22 = table_31
            type_value_5 = "BuyPopup"
            table.insert(value_7_22, type_value_5)
            captured_value_31(captured_value_32, "BuyPopup")

            return
        end
    end
    local on_currency_updated: (() -> ())?
    do
        local captured_value_36, captured_value_37, captured_value_38 = require_result_5, container_child_2, comma_value
        on_currency_updated = function(): ()
            local coins_value_7 = captured_value_36.Coins
            local gems_value_5 = captured_value_36.Gems
            local value_3_23 = captured_value_37
            local value_5_47: string = "Gems"
            local gems_child_3 = value_3_23:WaitForChild(value_5_47)
            local value_5_48: string = "Container"
            local container_child_14 = gems_child_3:WaitForChild(value_5_48)
            local value_5_49: string = "Amount"
            local amount_child = container_child_14:WaitForChild(value_5_49)
            local value_4_29 = captured_value_38(gems_value_5)
            amount_child.Text = value_4_29
            local value_3_27 = captured_value_37
            local value_5_51: string = "Coins"
            local coins_child = value_3_27:WaitForChild(value_5_51)
            local value_5_52: string = "Container"
            local container_child_15 = coins_child:WaitForChild(value_5_52)
            local value_5_53: string = "Amount"
            local amount_child_2 = container_child_15:WaitForChild(value_5_53)
            local value_4_34 = captured_value_38(coins_value_7)
            amount_child_2.Text = value_4_34

            return
        end
    end
    do
        local captured_value_39, captured_value_40, captured_value_41 = require_result_4, view_box_contents, view_buy_popup

        local function on_item_clicked(argument_1_8: string, argument_2_5: string)
            if argument_2_5 == "Event" then
                local value_3_31 = captured_value_39
                local value_5_55: string = "CurrentEvent"
                value_3_31:ViewFrame(value_5_55)

                return
            end
            do
                local take_fallback_2 = argument_2_5 == "MysteryBox"
                if take_fallback_2 or argument_2_5 == "Eggs" then
                    captured_value_40(argument_1_8, argument_2_5)

                    return
                end
            end
            captured_value_41(argument_1_8)

            return
        end
    end
    local setup_navigation
    do
        local captured_value_42, captured_value_43, captured_value_44, captured_value_45, captured_value_46 = value_10_4, go_to_page, main_child, scroll_frame_child, table_28
        setup_navigation = function()
            local value_1_5 = captured_value_42
            local value_3_35 = "Container"
            local value_2_11
            value_1_5, value_2_11, value_3_35 = value_1_5:WaitForChild(value_3_35):GetChildren()
            for key_12, value_41 in value_1_5, value_2_11, value_3_35 do
                local value_4_38, value_5_57 = key_12, value_41
                local value_8_23: string = "TextButton"
                local is_a_result_6 = value_5_57:IsA(value_8_23)
                if not is_a_result_6 then
                    continue
                end
                local activated_value_3 = value_5_57.Activated
                local value_8_24
                do
                    local captured_value_47, captured_value_48, captured_value_49, captured_value_50, captured_value_51, closure_ready_4
                    value_8_24 = function()
                        if not closure_ready_4 then
                            return
                        end
                        local value_2_12 = table_31
                        local value_3_36 = "Items"
                        table.insert(value_2_12, value_3_36)
                        captured_value_47(captured_value_48, "Items")
                        local insert_value_2
                        insert_value_2, value_2_12, value_3_36 = captured_value_49:GetChildren()
                        for key_11, value_40 in insert_value_2, value_2_12, value_3_36 do
                            local value_4_39, value_5_58 = key_11, value_40
                            local value_8_25: string = "Frame"
                            local is_a_result_7 = value_5_58:IsA(value_8_25)
                            if not is_a_result_7 then
                                continue
                            end
                            local value_8_26: string = "ItemType"
                            local item_type_value = value_5_58:GetAttribute(value_8_26)
                            local value_7_27 = captured_value_50
                            local name_value_3 = value_7_27.Name
                            if name_value_3 == "Weapons" then
                                local value_8_27 = captured_value_51
                                local weapons_value = value_8_27.Weapons
                                local value_7_28 = weapons_value[item_type_value]
                                value_5_58.Visible = value_7_28
                            else
                                local value_7_29 = captured_value_50
                                local name_value_4 = value_7_29.Name
                                if name_value_4 == "Emotes" then
                                    local value_7_30: boolean = true
                                    if item_type_value ~= "Emotes" then
                                        if item_type_value ~= "Toys" then
                                            value_7_30 = false
                                        else
                                            value_7_30 = true
                                        end
                                    end
                                    value_5_58.Visible = value_7_30
                                else
                                    local value_7_31 = captured_value_50
                                    local name_value_5 = value_7_31.Name
                                    if name_value_5 == "Pets" then
                                        local value_7_32: boolean = true
                                        if item_type_value ~= "Pets" then
                                            if item_type_value ~= "Eggs" then
                                                value_7_32 = false
                                            else
                                                value_7_32 = true
                                            end
                                        end
                                        value_5_58.Visible = value_7_32
                                    else
                                        local value_10_10: string = "ItemType"
                                        local item_type_value_2 = value_5_58:GetAttribute(
                                            value_10_10
                                        )
                                        local value_9_24 = captured_value_50
                                        local name_value_6 = value_9_24.Name
                                        local value_7_33: boolean?
                                        if item_type_value_2 ~= name_value_6 then
                                            value_7_33 = false
                                        else
                                            value_7_33 = true
                                        end
                                        value_5_58.Visible = value_7_33
                                    end
                                end
                            end
                        end

                        return
                    end
                    captured_value_47, captured_value_48, captured_value_49, captured_value_50, captured_value_51 = captured_value_43, captured_value_44, captured_value_45, value_5_57, captured_value_46
                    closure_ready_4 = true
                end
                activated_value_3:Connect(value_8_24)
            end

            return
        end
    end
    local generate_shop_items
    do
        local captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58, captured_value_59, captured_value_60, captured_value_61 = get_sorted_item_list, new_shop_value, new_item_child, require_result_3, gems_child, comma_value, require_result_4, view_box_contents, view_buy_popup, scroll_frame_child
        generate_shop_items = function()
            local value_1_7 = captured_value_52()
            local value_2_13 = captured_value_53
            local value_3_37: nil = nil
            local value_4_40: nil = nil
            for key_14, value_43 in value_2_13, value_3_37, value_4_40 do
                local value_5_59, value_6_30 = key_14, value_43
                local type_value_6 = value_6_30.Type
                local value_8_29 = captured_value_54
                local cloned_value_4 = value_8_29:Clone()
                local display_info_value_2 = value_6_30.DisplayInfo
                local value_11_19, value_12_41
                if not display_info_value_2 then
                    local value_9_26 = captured_value_55
                    value_11_19 = value_5_59
                    value_12_41 = type_value_6
                    display_info_value_2 = value_9_26:GetDisplayInfo(value_11_19, value_12_41)
                end
                local value_10_11 = cloned_value_4.Container.Icon
                value_11_19 = display_info_value_2.Image
                value_10_11.Image = value_11_19
                value_10_11 = cloned_value_4.ItemName.TextLabel
                value_11_19 = display_info_value_2.Name
                value_10_11.Text = value_11_19
                value_10_11 = cloned_value_4.ItemName
                value_11_19 = display_info_value_2.Color
                value_10_11.BackgroundColor3 = value_11_19
                value_10_11 = value_6_30.LayoutOrder
                if not value_10_11 then
                    value_10_11 = table.find
                    value_11_19 = value_1_7
                    value_12_41 = value_5_59
                    value_10_11 = (value_10_11(value_11_19, value_12_41)) or 0
                end
                cloned_value_4.LayoutOrder = value_10_11
                value_10_11 = value_6_30.Type
                local value_13_28
                if value_10_11 ~= "MysteryBox" then
                    value_10_11 = value_6_30.Price
                    value_11_19 = nil
                    value_12_41 = nil
                    for key_13, value_42 in value_10_11, value_11_19, value_12_41 do
                        local value_14_23
                        value_13_28, value_14_23 = key_13, value_42
                        local value_15_15: nil = nil
                        local value_16_12 = captured_value_55
                        local value_18_13 = value_13_28
                        local value_19_8: string = "Materials"
                        local item_exists_result_5 = value_16_12:ItemExists(
                            value_18_13,
                            value_19_8
                        )
                        local value_15_16
                        if item_exists_result_5 then
                            local value_16_14 = captured_value_55
                            local value_18_14 = value_13_28
                            local value_19_9: string = "Materials"
                            local get_item_info_result_7 = value_16_14:GetItemInfo(
                                value_18_14,
                                value_19_9
                            )
                            value_15_16 = get_item_info_result_7
                        else
                            local value_16_16 = captured_value_55
                            local value_18_15 = value_13_28
                            local value_19_10: string = "Weapons"
                            local item_exists_result_6 = value_16_16:ItemExists(
                                value_18_15,
                                value_19_10
                            )
                            if item_exists_result_6 then
                                local value_16_18 = captured_value_55
                                local value_18_16 = value_13_28
                                local value_19_11: string = "Weapons"
                                local get_item_info_result_8 = value_16_18:GetItemInfo(
                                    value_18_16,
                                    value_19_11
                                )
                                value_15_16 = get_item_info_result_8
                            else
                                local warn_value_3 = warn
                                local value_17_19: string = "Currency does not exist"
                                warn_value_3(value_17_19)
                                continue
                            end
                        end
                        local value_16_20 = captured_value_55
                        local value_18_17 = value_15_16
                        local get_item_image_result_3 = value_16_20:GetItemImage(value_18_17)
                        local value_9_28 = get_item_image_result_3
                        local value_15_17 = captured_value_56
                        local cloned_value_5 = value_15_17:Clone()
                        local icon_value_4 = cloned_value_5.Icon
                        local title_value = icon_value_4.Title
                        title_value.Image = value_9_28
                        local price_value_11 = cloned_value_5.Price
                        local value_17_21 = captured_value_57
                        local value_18_18 = value_14_23
                        local value_17_22 = value_17_21(value_18_18)
                        price_value_11.Text = value_17_22
                        cloned_value_5.LayoutOrder = value_14_23
                        local container_value_10 = cloned_value_4.Container
                        local prices_value = container_value_10.Prices
                        cloned_value_5.Parent = prices_value
                    end
                end
                value_10_11 = cloned_value_4.Container.ActionButton.Activated
                do
                    local captured_value_62, captured_value_63, captured_value_64, captured_value_65, captured_value_66, closure_ready_5
                    value_12_41 = function(): ()
                        if not closure_ready_5 then
                            return
                        end
                        local value_1_8 = captured_value_62
                        local value_2_14 = captured_value_63
                        if value_2_14 == "Event" then
                            local value_3_38 = captured_value_64
                            local value_5_60: string = "CurrentEvent"
                            value_3_38:ViewFrame(value_5_60)

                            return
                        end
                        do
                            local take_fallback_3 = value_2_14 == "MysteryBox"
                            if take_fallback_3 or value_2_14 == "Eggs" then
                                captured_value_65(value_1_8, value_2_14)

                                return
                            end
                        end
                        captured_value_66(value_1_8)

                        return
                    end
                    captured_value_62, captured_value_63, captured_value_64, captured_value_65, captured_value_66 = value_5_59, type_value_6, captured_value_58, captured_value_59, captured_value_60
                    closure_ready_5 = true
                end
                value_10_11:Connect(value_12_41)
                value_12_41 = "ItemType"
                value_13_28 = type_value_6
                cloned_value_4:SetAttribute(value_12_41, value_13_28)
                value_10_11 = captured_value_61
                cloned_value_4.Parent = value_10_11
            end

            return
        end
    end
    local generate_featured_items
    do
        local captured_value_67, captured_value_68, captured_value_69, captured_value_70, captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75 = table_1, new_shop_value, item_frame_child, require_result_3, table_29_2, require_result_4, view_box_contents, view_buy_popup, value_12_4
        generate_featured_items = function()
            local value_1_9 = captured_value_67
            local value_2_15: nil = nil
            local value_3_42: nil = nil
            for key_15, value_44 in value_1_9, value_2_15, value_3_42 do
                local value_4_44, value_5_62 = key_15, value_44
                local value_7_34 = captured_value_68
                local value_6_31 = value_7_34[value_5_62]
                if not value_6_31 then
                    local warn_value_4 = warn
                    local value_8_31: string = "Featured item not found."
                    warn_value_4(value_8_31)
                else
                    local value_7_35 = captured_value_69
                    local cloned_value_6 = value_7_35:Clone()
                    local display_info_value_3 = value_6_31.DisplayInfo
                    if not display_info_value_3 then
                        local value_8_33 = captured_value_70
                        local value_10_12 = value_5_62
                        local type_value_7 = value_6_31.Type
                        display_info_value_3 = value_8_33:GetDisplayInfo(value_10_12, type_value_7)
                    end
                    local container_value_11 = cloned_value_6.Container
                    local icon_value_5 = container_value_11.Icon
                    local image_value_2 = display_info_value_3.Image
                    icon_value_5.Image = image_value_2
                    local item_name_value_3 = cloned_value_6.ItemName
                    local text_label_value_2 = item_name_value_3.TextLabel
                    local name_value_7 = display_info_value_3.Name
                    text_label_value_2.Text = name_value_7
                    local item_name_value_4 = cloned_value_6.ItemName
                    local color_value_2 = display_info_value_3.Color
                    item_name_value_4.BackgroundColor3 = color_value_2
                    local container_value_12 = cloned_value_6.Container
                    local subtitle_value = container_value_12.Subtitle
                    local value_11_20 = captured_value_71
                    local type_value_8 = value_6_31.Type
                    local value_10_13 = value_11_20[type_value_8] or value_6_31.Type
                    subtitle_value.Text = value_10_13
                    local container_value_13 = cloned_value_6.Container
                    local action_button_value = container_value_13.ActionButton
                    local activated_value_4 = action_button_value.Activated
                    local value_11_21
                    do
                        local captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80, closure_ready_6
                        value_11_21 = function(): ()
                            if not closure_ready_6 then
                                return
                            end
                            local value_1_10 = captured_value_76
                            local type_value_9 = captured_value_77.Type
                            if type_value_9 == "Event" then
                                local value_3_43 = captured_value_78
                                local value_5_63: string = "CurrentEvent"
                                value_3_43:ViewFrame(value_5_63)

                                return
                            end
                            do
                                local take_fallback_4 = type_value_9 == "MysteryBox"
                                if take_fallback_4 or type_value_9 == "Eggs" then
                                    captured_value_79(value_1_10, type_value_9)

                                    return
                                end
                            end
                            captured_value_80(value_1_10)

                            return
                        end
                        captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80 = value_5_62, value_6_31, captured_value_72, captured_value_73, captured_value_74
                        closure_ready_6 = true
                    end
                    activated_value_4:Connect(value_11_21)
                    cloned_value_6.LayoutOrder = value_4_44
                    local value_9_31 = captured_value_75
                    local value_11_22: string = "Container"
                    local container_child_16 = value_9_31:WaitForChild(value_11_22)
                    cloned_value_6.Parent = container_child_16
                end
            end

            return
        end
    end
    local setup_purchase_currency
    do
        local captured_value_81, captured_value_82, captured_value_83, captured_value_84, captured_value_85, captured_value_86 = purchase_currency_child, require_result_2, shop_child, container_child_2, go_to_page, main_child
        setup_purchase_currency = function()
            local value_1_11, value_2_17, value_3_47 = captured_value_81:GetChildren()
            for key_16, value_45 in value_1_11, value_2_17, value_3_47 do
                local value_4_48, value_5_65 = key_16, value_45
                local value_8_35: string = "Frame"
                local is_a_result_8 = value_5_65:IsA(value_8_35)
                if not is_a_result_8 then
                    continue
                end
                local value_6_33 = captured_value_82
                local create_button_value = value_6_33.createButton
                local value_7_38 = value_5_65
                local value_8_36: (() -> ())?
                do
                    local captured_value_87, captured_value_88, closure_ready_7
                    value_8_36 = function(): ()
                        if not closure_ready_7 then
                            return
                        end
                        local purchase_product_value = captured_value_87.PurchaseProduct
                        local name_value_8 = captured_value_88.Name
                        local value_4_49: string = "Gems"
                        purchase_product_value:FireServer(name_value_8, value_4_49)

                        return
                    end
                    captured_value_87, captured_value_88 = captured_value_83, value_5_65
                    closure_ready_7 = true
                end
                local create_button_result = create_button_value(value_7_38, value_8_36)
            end
            value_1_11 = captured_value_84
            value_3_47 = "Gems"
            value_1_11 = value_1_11:WaitForChild(value_3_47)
            value_3_47 = "GetMore"
            value_1_11 = value_1_11:WaitForChild(value_3_47)
            value_3_47 = "Button"
            value_1_11 = value_1_11:WaitForChild(value_3_47).Activated
            do
                local captured_value_89, captured_value_90, closure_ready_8
                value_3_47 = function()
                    if not closure_ready_8 then
                        return
                    end
                    local value_2_19 = table_31
                    local value_3_49: string = "PurchaseCurrency"
                    table.insert(value_2_19, value_3_49)
                    captured_value_89(captured_value_90, "PurchaseCurrency")

                    return
                end
                captured_value_89, captured_value_90 = captured_value_85, captured_value_86
                closure_ready_8 = true
            end
            value_1_11:Connect(value_3_47)

            return
        end
    end
    local on_initialize
    do
        local captured_value_91, captured_value_92, captured_value_93, captured_value_94, captured_value_95, captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, captured_value_103, captured_value_104, captured_value_105 = new_item_child, item_grid_layout_child, buy_popup_child, go_to_page, main_child, generate_shop_items, generate_featured_items, setup_navigation, setup_purchase_currency, on_currency_updated, inventory_child, container_child_2, go_back, require_result_4, parent_value
        on_initialize = function()
            local value_1_15: boolean = false
            if captured_value_91.AbsoluteSize.Y < 160 then
                local value_1_16: boolean = true
                local value_2_22 = captured_value_92
                local new_result = UDim2.new(0.333, -4, 1, 0)
                value_2_22.CellSize = new_result
            end
            local value_2_23 = captured_value_91
            local script_value_7: LuaSourceContainer = script
            value_2_23.Parent = script_value_7
            local value_2_24 = captured_value_91
            local value_4_51: string = "Container"
            local container_child_17 = value_2_24:WaitForChild(value_4_51)
            local value_4_52: string = "Prices"
            local prices_child_2 = container_child_17:WaitForChild(value_4_52)
            local value_4_53: string = "Coins"
            prices_child_2:WaitForChild(value_4_53):Destroy()
            local value_2_29 = captured_value_93
            local value_4_54: string = "Container"
            local container_child_18 = value_2_29:WaitForChild(value_4_54)
            local value_4_55: string = "Right"
            local right_child_2 = container_child_18:WaitForChild(value_4_55)
            local value_4_56: string = "PriceFrame"
            local price_frame_child_2 = right_child_2:WaitForChild(value_4_56)
            local value_4_57: string = "Coins"
            price_frame_child_2:WaitForChild(value_4_57):Destroy()
            captured_value_94(captured_value_95, "Featured")
            captured_value_96()
            captured_value_97()
            captured_value_98()
            captured_value_99()
            captured_value_100()
            local event_value = captured_value_101.ProfileDataChanged.Event
            local value_4_59: () -> () = captured_value_100
            event_value:Connect(value_4_59)
            local value_2_43 = captured_value_102
            local value_4_60: string = "Back"
            local activated_value_5 = value_2_43:WaitForChild(value_4_60).Activated
            local value_4_61 = captured_value_103
            activated_value_5:Connect(value_4_61)
            local value_2_46 = captured_value_104
            local value_4_62: Instance? = captured_value_105
            local value_6_35: string = "Small"
            local small_child_3 = value_4_62:WaitForChild(value_6_35)
            local value_5_68: string = "Shop"
            local value_6_36
            do
                local closure_ready_9
                value_6_36 = function()
                    if not closure_ready_9 then
                        return
                    end
                    local table_1_3 = {"Featured"}
                    table_31 = table_1_3

                    return
                end
                closure_ready_9 = true
            end
            value_2_46:RegisterFrame(small_child_3, value_5_68, value_6_36)

            return
        end
    end
    on_initialize()
end

return
