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
    local require_value = require
    local game_value: DataModel = game
    local value_4: string = "ReplicatedStorage"
    local replicated_storage_service: Instance = game_value:GetService(value_4)
    local value_4_2: string = "Modules"
    local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
    local value_4_3: string = "WindowService"
    local require_result = require_value(modules_child:WaitForChild(value_4_3))
    local require_value_2 = require
    local game_value_2: DataModel = game
    local value_5: string = "ReplicatedStorage"
    local replicated_storage_service_2: Instance = game_value_2:GetService(value_5)
    local value_5_2: string = "Database"
    local database_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
    local value_5_3: string = "Sync"
    local require_result_2 = require_value_2(database_child:WaitForChild(value_5_3))
    local require_value_3 = require
    local game_value_3: DataModel = game
    local value_6: string = "ReplicatedStorage"
    local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
    local value_6_2: string = "Modules"
    local modules_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
    local value_6_3: string = "ProfileData"
    local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_6_3))
    local require_value_4 = require
    local game_value_4: DataModel = game
    local value_7: string = "ReplicatedStorage"
    local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
    local value_7_2: string = "ClientServices"
    local client_services_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
    local value_7_3: string = "ItemService"
    local require_result_4 = require_value_4(client_services_child:WaitForChild(value_7_3))
    local require_value_5 = require
    local game_value_5: DataModel = game
    local value_8: string = "ReplicatedStorage"
    local replicated_storage_service_5: Instance = game_value_5:GetService(value_8)
    local value_8_2: string = "ClientServices"
    local client_services_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_8_2)
    local value_8_3: string = "ItemPopupService"
    local require_result_5 = require_value_5(client_services_child_2:WaitForChild(value_8_3))
    local require_value_6 = require
    local game_value_6: DataModel = game
    local value_9: string = "ReplicatedStorage"
    local replicated_storage_service_6: Instance = game_value_6:GetService(value_9)
    local value_9_2: string = "SharedServices"
    local shared_services_child: Instance? = replicated_storage_service_6:WaitForChild(value_9_2)
    local value_9_3: string = "EventInfoService"
    local require_result_6 = require_value_6(shared_services_child:WaitForChild(value_9_3))
    local local_player_value = game.Players.LocalPlayer
    local parent_value_2 = script.Parent.Parent
    local require_value_7 = require
    local parent_value_3: Instance? = script.Parent
    local value_12: string = "ShopService"
    local require_result_7 = require_value_7(parent_value_3:WaitForChild(value_12))
    local new_shop_value = require_result_2.NewShop
    local game_value_8: DataModel = game
    local value_13: string = "ReplicatedStorage"
    local replicated_storage_service_7: Instance = game_value_8:GetService(value_13)
    local value_13_2: string = "Remotes"
    local remotes_child: Instance? = replicated_storage_service_7:WaitForChild(value_13_2)
    local value_13_3: string = "Shop"
    local shop_child = remotes_child:WaitForChild(value_13_3)
    local game_value_9: DataModel = game
    local value_14: string = "ReplicatedStorage"
    local replicated_storage_service_8: Instance = game_value_9:GetService(value_14)
    local value_14_2: string = "Remotes"
    local remotes_child_2: Instance? = replicated_storage_service_8:WaitForChild(value_14_2)
    local value_14_3: string = "Inventory"
    local inventory_child = remotes_child_2:WaitForChild(value_14_3)
    local value_15: string = "Medium"
    local medium_child = parent_value_2:WaitForChild(value_15)
    local value_16: string = "Container"
    local container_child = medium_child:WaitForChild(value_16)
    local value_16_2: string = "Container"
    local container_child_2 = container_child:WaitForChild(value_16_2)
    local value_16_3: string = "Main"
    local value_8_7 = (container_child_2:WaitForChild(value_16_3))
    local value_16_4: string = "Title"
    local title_child = medium_child:WaitForChild(value_16_4)
    local value_17: string = "Container"
    local container_child_3 = medium_child:WaitForChild(value_17)
    local value_17_2: string = "Container"
    local container_child_4 = container_child_3:WaitForChild(value_17_2)
    local value_17_3: string = "Nav"
    local nav_child = container_child_4:WaitForChild(value_17_3)
    local value_17_4: string = "Container"
    local container_child_5 = nav_child:WaitForChild(value_17_4)
    local value_18: string = "Container"
    local container_child_6 = medium_child:WaitForChild(value_18)
    local value_18_2: string = "Processing"
    local processing_child = container_child_6:WaitForChild(value_18_2)
    local value_19: string = "Items"
    local items_child = value_8_7:WaitForChild(value_19)
    local value_19_2: string = "Container"
    local container_child_7 = items_child:WaitForChild(value_19_2)
    local value_19_3: string = "RadioCover"
    local radio_cover_child = container_child_7:WaitForChild(value_19_3)
    local value_20: string = "ViewContents"
    local view_contents_child = value_8_7:WaitForChild(value_20)
    local value_21: string = "Container"
    local container_child_8 = view_contents_child:WaitForChild(value_21)
    local value_21_2: string = "BoxFrame"
    local box_frame_child = container_child_8:WaitForChild(value_21_2)
    local value_21_3: string = "ItemFrame"
    local item_frame_child = box_frame_child:WaitForChild(value_21_3)
    local value_22: string = "Container"
    local container_child_9 = view_contents_child:WaitForChild(value_22)
    local value_22_2: string = "BuyFrame"
    local buy_frame_child = container_child_9:WaitForChild(value_22_2)
    local value_22_3: string = "Currencies"
    local currencies_child = buy_frame_child:WaitForChild(value_22_3)
    local value_23: string = "Container"
    local container_child_10 = view_contents_child:WaitForChild(value_23)
    local value_23_2: string = "BoxContents"
    local box_contents_child = container_child_10:WaitForChild(value_23_2)
    local value_23_3: string = "Container"
    local container_child_11 = box_contents_child:WaitForChild(value_23_3)
    local value_24: string = "Container"
    local container_child_12 = view_contents_child:WaitForChild(value_24)
    local value_24_2: string = "BuyFrame"
    local buy_frame_child_2 = container_child_12:WaitForChild(value_24_2)
    local value_24_3: string = "PurchaseOptions"
    local purchase_options_child = buy_frame_child_2:WaitForChild(value_24_3)
    local value_25: string = "BuyPopup"
    local buy_popup_child = value_8_7:WaitForChild(value_25)
    local value_26: string = "Container"
    local container_child_13 = buy_popup_child:WaitForChild(value_26)
    local value_26_2: string = "Left"
    local left_child = container_child_13:WaitForChild(value_26_2)
    local value_26_3: string = "ItemContainer"
    local item_container_child = left_child:WaitForChild(value_26_3)
    local value_26_4: string = "ItemFrame"
    local item_frame_child_2 = item_container_child:WaitForChild(value_26_4)
    local value_27: string = "Container"
    local container_child_14 = buy_popup_child:WaitForChild(value_27)
    local value_27_2: string = "Right"
    local right_child = container_child_14:WaitForChild(value_27_2)
    local value_27_3: string = "Description"
    local description_child = right_child:WaitForChild(value_27_3)
    local value_27_4: string = "TextLabel"
    local text_label_child = description_child:WaitForChild(value_27_4)
    local value_28: string = "Container"
    local container_child_15 = buy_popup_child:WaitForChild(value_28)
    local value_28_2: string = "Right"
    local right_child_2 = container_child_15:WaitForChild(value_28_2)
    local value_28_3: string = "PriceFrame"
    local price_frame_child = right_child_2:WaitForChild(value_28_3)
    local value_29: string = "Items"
    local items_child_2 = value_8_7:WaitForChild(value_29)
    local value_29_2: string = "Container"
    local container_child_16 = items_child_2:WaitForChild(value_29_2)
    local value_29_3: string = "ScrollFrame"
    local scroll_frame_child = container_child_16:WaitForChild(value_29_3)
    local value_30: string = "Featured"
    local featured_child = value_8_7:WaitForChild(value_30)
    local value_31: string = "HotItems"
    local hot_items_child = featured_child:WaitForChild(value_31)
    value_31 = "Container"
    local container_child_17 = hot_items_child:WaitForChild(value_31)
    value_30 = "Featured"
    value_31 = "Featured"
    local value_32 = nil
    local script_value_3: LuaSourceContainer = script
    local value_35: string = "OwnedCurrencyFrame"
    local owned_currency_frame_child: Instance? = script_value_3:WaitForChild(value_35)
    local update_nav_buttons: (() -> ())?
    do
        local captured_value = container_child_5
        update_nav_buttons = function(): ()
            local value_1, value_2_4, value_3_7 = captured_value:GetChildren()
            for key, value in value_1, value_2_4, value_3_7 do
                local value_4_10, value_5_10 = key, value
                local value_8_8: string = "TextButton"
                local is_a_result = value_5_10:IsA(value_8_8)
                if not is_a_result then
                    continue
                end
                local name_value = value_5_10.Name
                local value_7_11 = value_32
                if value_7_11 == name_value then
                    local value_7_12: string = value_30
                    if value_7_12 == "Featured" then
                        local back_value = value_5_10.Back
                        local value_8_9: boolean = false
                        back_value.Visible = value_8_9
                        local is_selected_value = value_5_10.IsSelected
                        local value_8_10: boolean = true
                        is_selected_value.Visible = value_8_10
                        local not_selected_value = value_5_10.NotSelected
                        local value_8_11: boolean = false
                        not_selected_value.Visible = value_8_11
                    else
                        local back_value_2 = value_5_10.Back
                        local value_8_12: boolean = true
                        back_value_2.Visible = value_8_12
                        local is_selected_value_2 = value_5_10.IsSelected
                        local value_8_13: boolean = false
                        is_selected_value_2.Visible = value_8_13
                        local not_selected_value_2 = value_5_10.NotSelected
                        local value_8_14: boolean = false
                        not_selected_value_2.Visible = value_8_14
                    end
                else
                    local back_value_3 = value_5_10.Back
                    local value_8_15: boolean = false
                    back_value_3.Visible = value_8_15
                    local is_selected_value_3 = value_5_10.IsSelected
                    local value_8_16: boolean = false
                    is_selected_value_3.Visible = value_8_16
                    local not_selected_value_3 = value_5_10.NotSelected
                    local value_8_17: boolean = true
                    not_selected_value_3.Visible = value_8_17
                end
            end

            return
        end
    end
    local go_to_page: ((string) -> ())?
    do
        local captured_value_2, captured_value_3 = value_8_7, update_nav_buttons
        go_to_page = function(argument_1: string): ()
            local value_2_5, value_3_8, value_4_11 = captured_value_2:GetChildren()
            for key_2, value_36 in value_2_5, value_3_8, value_4_11 do
                local value_5_11, value_6_11 = key_2, value_36
                local value_9_4: string = "Frame"
                local is_a_result_2 = value_6_11:IsA(value_9_4)
                if not is_a_result_2 then
                    continue
                end
                local name_value_2 = value_6_11.Name
                local value_7_14: boolean?
                if name_value_2 ~= argument_1 then
                    value_7_14 = false
                else
                    value_7_14 = true
                end
                value_6_11.Visible = value_7_14
            end
            value_31 = argument_1
            captured_value_3()

            return
        end
    end
    do
        local captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9 = go_to_page, local_player_value, radio_cover_child, require_result_7, scroll_frame_child, update_nav_buttons

        local function go_to_tab(argument_1_2: string): ()
            captured_value_4("Items")
            if argument_1_2 == "Radios" then
                local value_2_7 = captured_value_5
                local value_4_12: string = "Radio"
                local radio_value = value_2_7:GetAttribute(value_4_12)
                local value_3_11 = captured_value_6
                local value_4_13: boolean = not radio_value
                value_3_11.Visible = value_4_13
            else
                local value_2_9 = captured_value_6
                local value_3_12: boolean = false
                value_2_9.Visible = value_3_12
            end
            local value_2_10 = captured_value_7
            local value_4_14 = captured_value_8
            local value_5_12: string = argument_1_2
            value_2_10:SetVisibleItems(value_4_14, value_5_12)
            value_32 = argument_1_2
            captured_value_9()

            return
        end
    end
    local on_item_purchase_requested
    do
        local captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14, captured_value_15, captured_value_16 = new_shop_value, processing_child, require_result_7, medium_child, shop_child, require_result_5, buy_popup_child
        on_item_purchase_requested = function(argument_1_3: string, argument_2: string)
            local buy_item_new_value, egg_controller_value, event_value, event_value_2, invoke_server_result, invoke_server_result_2, item_claims_complete_value, item_claims_complete_value_2, open_crate_value, request_unbox_result, type_value, value_3_14, value_3_15, value_3_16, value_4_15, value_5_13, value_5_14, value_5_15, value_5_17, value_5_18, value_5_20, value_5_22, value_5_23, value_5_24, value_6_12, value_6_14, value_6_16, value_6_17, value_6_20, value_6_21, value_6_23, value_6_24, value_6_25, value_6_27, value_7_15, value_7_16, value_7_17, value_7_19, value_7_20, value_7_21, value_7_22, value_7_24, value_8_19, value_8_20, value_8_21, value_8_22, value_8_23, value_9_5, value_9_6, value_9_7, visible_value
            local control_state = 0
            while true do
                if control_state < 8 then
                    if control_state < 4 then
                        if control_state < 2 then
                            if control_state < 1 then
                                value_4_15 = captured_value_10
                                value_3_14 = value_4_15[argument_1_3]
                                type_value = value_3_14.Type
                                value_5_13 = captured_value_11
                                visible_value = value_5_13.Visible
                                control_state = if visible_value == true then 2 else 1
                            else
                                value_3_15 = false
                                control_state = 3
                            end
                        else
                            if control_state < 3 then
                                value_3_15 = true
                                control_state = 3
                            else
                                control_state = if not value_3_15 then 5 else 4
                            end
                        end
                    else
                        if control_state < 6 then
                            if control_state < 5 then
                                return
                            else
                                control_state = if type_value == "MysteryBox" then 7 else 6
                            end
                        else
                            if control_state < 7 then
                                control_state = if type_value ~= "Eggs" then 14 else 7
                            else
                                value_5_14 = captured_value_11
                                value_6_12 = true
                                value_5_14.Visible = value_6_12
                                control_state = if type_value ~= "MysteryBox" then 10 else 8
                            end
                        end
                    end
                else
                    if control_state < 12 then
                        if control_state < 10 then
                            if control_state < 9 then
                                value_5_15 = captured_value_12
                                value_7_15 = argument_1_3
                                value_8_19 = argument_2
                                value_9_5 = 1
                                request_unbox_result = value_5_15:RequestUnbox(
                                    value_7_15,
                                    value_8_19,
                                    value_9_5
                                )
                                value_3_16 = request_unbox_result
                                control_state = if not value_3_16 then 13 else 9
                            else
                                value_5_17 = captured_value_13
                                value_6_14 = false
                                value_5_17.Visible = value_6_14
                                control_state = 13
                            end
                        else
                            if control_state < 11 then
                                control_state = if type_value ~= "Eggs" then 13 else 11
                            else
                                value_5_18 = captured_value_14
                                open_crate_value = value_5_18.OpenCrate
                                value_7_16 = argument_1_3
                                value_8_20 = type_value
                                value_9_6 = argument_2
                                invoke_server_result = open_crate_value:InvokeServer(
                                    value_7_16,
                                    value_8_20,
                                    value_9_6
                                )
                                control_state = if not invoke_server_result then 13 else 12
                            end
                        end
                    else
                        if control_state < 14 then
                            if control_state < 13 then
                                value_6_16 = captured_value_13
                                value_7_17 = false
                                value_6_16.Visible = value_7_17
                                value_6_17 = captured_value_14
                                egg_controller_value = value_6_17.EggController
                                value_8_21 = argument_1_3
                                value_9_7 = invoke_server_result
                                egg_controller_value:Fire(value_8_21, value_9_7)
                                control_state = 13
                            else
                                value_5_20 = captured_value_15
                                item_claims_complete_value = value_5_20.ItemClaimsComplete
                                event_value = item_claims_complete_value.Event
                                do
                                    local captured_value_17 = captured_value_13
                                    if closure_cache[1] ~= nil and same_capture(
                                        closure_cache[2],
                                        captured_value_17
                                    ) then
                                        value_7_19 = closure_cache[1]
                                    else
                                        local closure_ready
                                        value_7_19 = function(): ()
                                            if not closure_ready then
                                                return
                                            end
                                            local value_1_2 = captured_value_17
                                            local value_2_13: boolean = true
                                            value_1_2.Visible = value_2_13

                                            return
                                        end
                                        closure_ready = true
                                        if closure_cache[1] == nil then
                                            closure_cache[1] = value_7_19
                                            closure_cache[2] = captured_value_17
                                        end
                                    end
                                end
                                event_value:Once(value_7_19)
                                value_5_22 = captured_value_11
                                value_6_20 = false
                                value_5_22.Visible = value_6_20

                                return
                            end
                        else
                            if control_state < 15 then
                                value_5_23 = captured_value_11
                                value_6_21 = true
                                value_5_23.Visible = value_6_21
                                value_5_24 = captured_value_14
                                buy_item_new_value = value_5_24.BuyItemNew
                                value_7_20 = argument_1_3
                                value_8_22 = argument_2
                                invoke_server_result_2 = buy_item_new_value:InvokeServer(
                                    value_7_20,
                                    value_8_22
                                )
                                control_state = if not invoke_server_result_2 then 16 else 15
                            else
                                if control_state < 16 then
                                    value_6_23 = captured_value_13
                                    value_7_21 = false
                                    value_6_23.Visible = value_7_21
                                    value_6_24 = captured_value_16
                                    value_7_22 = false
                                    value_6_24.Visible = value_7_22
                                    value_6_25 = captured_value_15
                                    item_claims_complete_value_2 = value_6_25.ItemClaimsComplete
                                    event_value_2 = item_claims_complete_value_2.Event
                                    do
                                        local captured_value_18 = captured_value_13
                                        if closure_cache[3] ~= nil and same_capture(
                                            closure_cache[4],
                                            captured_value_18
                                        ) then
                                            value_8_23 = closure_cache[3]
                                        else
                                            local closure_ready_2
                                            value_8_23 = function(): ()
                                                if not closure_ready_2 then
                                                    return
                                                end
                                                local value_1_3 = captured_value_18
                                                local value_2_14: boolean = true
                                                value_1_3.Visible = value_2_14

                                                return
                                            end
                                            closure_ready_2 = true
                                            if closure_cache[3] == nil then
                                                closure_cache[3] = value_8_23
                                                closure_cache[4] = captured_value_18
                                            end
                                        end
                                    end
                                    event_value_2:Once(value_8_23)
                                    control_state = 16
                                else
                                    value_6_27 = captured_value_11
                                    value_7_24 = false
                                    value_6_27.Visible = value_7_24

                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local table_38 = {}
    local view_box_contents
    do
        local captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31 = require_result_7, item_frame_child, container_child_11, purchase_options_child, table_38, currencies_child, new_shop_value, require_result_4, owned_currency_frame_child, require_result_3, inventory_child, require_result_2, view_contents_child
        view_box_contents = function(argument_1_4: string, argument_2_2: string)
            local value_3_17 = captured_value_19
            local value_5_26 = captured_value_20
            local value_6_28 = captured_value_21
            local value_7_25 = captured_value_22
            local value_8_24 = argument_1_4
            local value_9_8: string = argument_2_2
            value_3_17:ViewBoxContents(value_5_26, value_6_28, value_7_25, value_8_24, value_9_8)
            value_3_17 = captured_value_23
            local value_4_16 = nil
            value_5_26 = nil
            for key_3, value_37 in value_3_17, value_4_16, value_5_26 do
                value_6_28, value_7_25 = key_3, value_37
                value_7_25:Disconnect()
            end
            value_3_17, value_4_16, value_5_26 = captured_value_24:GetChildren()
            for key_4, value_38 in value_3_17, value_4_16, value_5_26 do
                value_6_28, value_7_25 = key_4, value_38
                local value_10_2: string = "Frame"
                value_8_24 = value_7_25:IsA(value_10_2)
                if not value_8_24 then
                    continue
                end
                value_7_25:Destroy()
            end
            value_3_17 = captured_value_25[argument_1_4].Price
            value_4_16 = value_3_17
            value_5_26 = nil
            value_6_28 = nil
            for key_5, value_39 in value_4_16, value_5_26, value_6_28 do
                value_7_25, value_8_24 = key_5, value_39
                if value_7_25 == "Coins" then
                    continue
                end
                if value_7_25 == "Gems" then
                    continue
                end
                local value_9_12 = captured_value_26
                local value_11_5 = value_7_25
                local value_12_8: string = "Materials"
                local find_item_info_result = value_9_12:FindItemInfo(value_11_5, value_12_8)
                if not find_item_info_result then
                    local value_9_14 = captured_value_26
                    local value_11_6 = value_7_25
                    local value_12_9: string = "Weapons"
                    find_item_info_result = value_9_14:FindItemInfo(value_11_6, value_12_9)
                end
                if not find_item_info_result then
                    continue
                end
                local value_10_5: Instance? = captured_value_27
                local cloned_value = value_10_5:Clone()
                local container_value = cloned_value.Container
                local icon_value = container_value.Icon
                local image_value = find_item_info_result.Image
                icon_value.Image = image_value
                local value_11_8 = captured_value_28
                local materials_value = value_11_8.Materials
                local owned_value = materials_value.Owned
                local value_9_16 = owned_value[value_7_25]
                if not value_9_16 then
                    local value_11_9 = captured_value_28
                    local weapons_value = value_11_9.Weapons
                    local owned_value_2 = weapons_value.Owned
                    value_9_16 = owned_value_2[value_7_25] or 0
                end
                local container_value_2 = cloned_value.Container
                local price_frame_value = container_value_2.PriceFrame
                local price_label_value = price_frame_value.PriceLabel
                local value_12_10 = captured_value_19
                local comma_value_value = value_12_10.CommaValue
                local value_13_8 = value_9_16
                local comma_value_result = comma_value_value(value_13_8)
                price_label_value.Text = comma_value_result
                cloned_value.LayoutOrder = value_9_16
                local value_12_11 = captured_value_23
                local value_13_9 = captured_value_29
                local inventory_data_changed_value = value_13_9.InventoryDataChanged
                local event_value_3 = inventory_data_changed_value.Event
                local value_15_10
                do
                    local captured_value_32, captured_value_33, captured_value_34, closure_ready_3
                    value_15_10 = function<T1>(argument_1_5: T1, argument_2_3, argument_3): ()
                        if not closure_ready_3 then
                            return
                        end
                        if argument_2_3 == captured_value_32 then
                            local price_label_value_2 = captured_value_33.Container.PriceFrame.PriceLabel
                            local comma_value_result_2 = captured_value_34.CommaValue(
                                argument_3 or 0
                            )
                            price_label_value_2.Text = comma_value_result_2
                        end

                        return
                    end
                    captured_value_32, captured_value_33, captured_value_34 = value_7_25, cloned_value, captured_value_19
                    closure_ready_3 = true
                end
                ;(function(...)
                    local open_callee = table.insert

                    return open_callee(value_12_11, ...)
                end)(event_value_3:Connect(value_15_10))
                local value_11_10 = captured_value_24
                cloned_value.Parent = value_11_10
            end
            value_8_24 = captured_value_30
            value_7_25 = value_8_24[argument_2_2]
            value_4_16 = value_7_25[argument_1_4].RarityChances
            value_5_26 = nil
            value_6_28 = nil
            for key_6, value_40 in value_4_16, value_5_26, value_6_28 do
                value_7_25, value_8_24 = key_6, value_40
                local value_9_17 = captured_value_31
                local container_value_3 = value_9_17.Container
                local box_frame_value = container_value_3.BoxFrame
                local rarity_frame_value = box_frame_value.RarityFrame
                local rarity_value = value_8_24.Rarity
                local find_first_child_result = rarity_frame_value:FindFirstChild(rarity_value)
                value_3_17 = find_first_child_result
                if not value_3_17 then
                    continue
                end
                local chance_value = value_3_17.Chance
                local value_10_8: string = "%*%%"
                local chance_value_2 = value_8_24.Chance
                local format_result = value_10_8:format(chance_value_2)
                chance_value.Text = format_result
            end
            value_4_16 = captured_value_31.Container.BoxFrame.RarityFrame.Godly.Chance
            value_5_26 = ".2%"
            value_4_16.Text = value_5_26

            return
        end
    end
    local on_item_clicked
    do
        local captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42 = require_result, view_box_contents, go_to_page, require_result_7, item_frame_child_2, text_label_child, price_frame_child, buy_popup_child
        on_item_clicked = function(argument_1_6: string, argument_2_4: string)
            if argument_2_4 == "Event" then
                local value_3_18 = captured_value_35
                local value_5_28: string = "CurrentEvent"
                value_3_18:ViewFrame(value_5_28)

                return
            end
            do
                local take_fallback = argument_2_4 == "MysteryBox"
                if take_fallback or argument_2_4 == "Eggs" then
                    value_30 = value_31
                    captured_value_36(argument_1_6, argument_2_4)
                    if argument_2_4 == "MysteryBox" then
                        value_32 = "Weapons"
                    else
                        if argument_2_4 == "Eggs" then
                            value_32 = "Pets"
                        end
                    end
                    captured_value_37("ViewContents")

                    return
                end
            end
            local value_3_25 = captured_value_38
            local value_5_30 = captured_value_39
            local value_6_30 = captured_value_40
            local value_7_26 = captured_value_41
            local value_8_25: string = argument_1_6
            value_3_25:ViewBuyPopup(value_5_30, value_6_30, value_7_26, value_8_25)
            local value_3_27 = captured_value_42
            local value_4_23: boolean = true
            value_3_27.Visible = value_4_23

            return
        end
    end
    do
        local captured_value_43, captured_value_44 = require_result_7, on_item_clicked

        local function setup_callbacks()
            local event_value_4 = captured_value_43.ItemClicked.Event
            local value_3_28 = captured_value_44
            event_value_4:Connect(value_3_28)

            return
        end
    end
    local on_latest_mystery_box_activated
    do
        local captured_value_45, captured_value_46 = view_box_contents, go_to_page
        on_latest_mystery_box_activated = function()
            value_30 = "Featured"
            value_32 = "Weapons"
            captured_value_45("MysteryBox2", "MysteryBox")
            captured_value_46("ViewContents")

            return
        end
    end
    local setup_featured
    do
        local captured_value_47, captured_value_48, captured_value_49, captured_value_50 = featured_child, require_result_7, on_latest_mystery_box_activated, container_child_17
        setup_featured = function()
            local value_1_10 = captured_value_47
            local value_3_30: string = "Box"
            local box_child = value_1_10:WaitForChild(value_3_30)
            local value_3_31: string = "ItemFrame"
            local item_frame_child_3 = box_child:WaitForChild(value_3_31)
            local value_2_20 = captured_value_48
            local value_4_24 = item_frame_child_3
            local value_5_31: string = "MysteryBox2"
            local value_6_31: string = "MysteryBox"
            value_2_20:DisplayItem(value_4_24, value_5_31, value_6_31)
            local value_2_22 = captured_value_47
            local value_4_25: string = "Box"
            local box_child_2 = value_2_22:WaitForChild(value_4_25)
            local value_4_26: string = "Buy"
            local activated_value = box_child_2:WaitForChild(value_4_26).Activated
            local value_4_27 = captured_value_49
            activated_value:Connect(value_4_27)
            local value_4_28: string = "Container"
            local container_child_18 = item_frame_child_3:WaitForChild(value_4_28)
            local value_4_29: string = "ActionButton"
            local activated_value_2 = container_child_18:WaitForChild(value_4_29).Activated
            local value_4_30 = captured_value_49
            activated_value_2:Connect(value_4_30)
            local value_2_29 = captured_value_48
            local value_4_31 = captured_value_50
            local desktop_value = captured_value_48.FeaturedItems.Desktop
            value_2_29:GenerateFeaturedItems(value_4_31, desktop_value)

            return
        end
    end
    local setup_navigation
    do
        local captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58 = container_child_5, go_to_page, local_player_value, radio_cover_child, require_result_7, scroll_frame_child, update_nav_buttons, buy_popup_child
        setup_navigation = function()
            local value_1_13, value_2_31, value_3_40 = captured_value_51:GetChildren()
            for key_7, value_41 in value_1_13, value_2_31, value_3_40 do
                local value_4_32, value_5_33 = key_7, value_41
                local value_8_26: string = "TextButton"
                local is_a_result_3 = value_5_33:IsA(value_8_26)
                if not is_a_result_3 then
                    continue
                end
                local name_value_3 = value_5_33.Name
                local activated_value_3 = value_5_33.Activated
                local value_9_19: (() -> ())?
                do
                    local captured_value_59, captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64, captured_value_65, closure_ready_4
                    value_9_19 = function(): ()
                        if not closure_ready_4 then
                            return
                        end
                        if value_32 == captured_value_59 then
                            if value_30 == "Featured" then
                                value_32 = nil
                                captured_value_60("Featured")

                                return
                            end
                            if value_30 == "Items" then
                                value_30 = "Featured"
                                local value_1_20 = captured_value_59
                                captured_value_60("Items")
                                if value_1_20 == "Radios" then
                                    local value_2_35 = captured_value_61
                                    local value_4_33: string = "Radio"
                                    local radio_value_2 = value_2_35:GetAttribute(value_4_33)
                                    local value_3_43 = captured_value_62
                                    local value_4_34: boolean = not radio_value_2
                                    value_3_43.Visible = value_4_34
                                else
                                    local value_2_37 = captured_value_62
                                    local value_3_44: boolean = false
                                    value_2_37.Visible = value_3_44
                                end
                                local value_2_38 = captured_value_63
                                local value_4_35 = captured_value_64
                                local value_5_34 = value_1_20
                                value_2_38:SetVisibleItems(value_4_35, value_5_34)
                                value_32 = value_1_20
                                captured_value_65()

                                return
                            end
                            value_30 = "Featured"
                            local value_1_22 = captured_value_59
                            captured_value_60("Items")
                            if value_1_22 == "Radios" then
                                local value_2_42 = captured_value_61
                                local value_4_36: string = "Radio"
                                local radio_value_3 = value_2_42:GetAttribute(value_4_36)
                                local value_3_48 = captured_value_62
                                local value_4_37: boolean = not radio_value_3
                                value_3_48.Visible = value_4_37
                            else
                                local value_2_44 = captured_value_62
                                local value_3_49: boolean = false
                                value_2_44.Visible = value_3_49
                            end
                            local value_2_45 = captured_value_63
                            local value_4_38 = captured_value_64
                            local value_5_35 = value_1_22
                            value_2_45:SetVisibleItems(value_4_38, value_5_35)
                            value_32 = value_1_22
                            captured_value_65()

                            return
                        end
                        value_30 = "Featured"
                        local value_1_24 = captured_value_59
                        captured_value_60("Items")
                        if value_1_24 == "Radios" then
                            local value_2_49 = captured_value_61
                            local value_4_39: string = "Radio"
                            local radio_value_4 = value_2_49:GetAttribute(value_4_39)
                            local value_3_53 = captured_value_62
                            local value_4_40: boolean = not radio_value_4
                            value_3_53.Visible = value_4_40
                        else
                            local value_2_51 = captured_value_62
                            local value_3_54: boolean = false
                            value_2_51.Visible = value_3_54
                        end
                        local value_2_52 = captured_value_63
                        local value_4_41 = captured_value_64
                        local value_5_36 = value_1_24
                        value_2_52:SetVisibleItems(value_4_41, value_5_36)
                        value_32 = value_1_24
                        captured_value_65()

                        return
                    end
                    captured_value_59, captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64, captured_value_65 = name_value_3, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57
                    closure_ready_4 = true
                end
                activated_value_3:Connect(value_9_19)
            end
            value_1_13 = captured_value_58
            value_3_40 = "Container"
            value_1_13 = value_1_13:WaitForChild(value_3_40)
            value_3_40 = "Close"
            value_1_13 = value_1_13:WaitForChild(value_3_40)
            value_3_40 = "ImageButton"
            value_1_13 = value_1_13:WaitForChild(value_3_40).Activated
            do
                local captured_value_66 = captured_value_58
                if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_66) then
                    value_3_40 = closure_cache[5]
                else
                    local closure_ready_5
                    value_3_40 = function(): ()
                        if not closure_ready_5 then
                            return
                        end
                        local value_1_25 = captured_value_66
                        local value_2_55: boolean = false
                        value_1_25.Visible = value_2_55

                        return
                    end
                    closure_ready_5 = true
                    if closure_cache[5] == nil then
                        closure_cache[5] = value_3_40
                        closure_cache[6] = captured_value_66
                    end
                end
            end
            value_1_13:Connect(value_3_40)
            value_1_13 = captured_value_58
            value_3_40 = "ClickBlock"
            value_1_13 = value_1_13:WaitForChild(value_3_40).Activated
            do
                local captured_value_67 = captured_value_58
                if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_67) then
                    value_3_40 = closure_cache[7]
                else
                    local closure_ready_6
                    value_3_40 = function(): ()
                        if not closure_ready_6 then
                            return
                        end
                        local value_1_26 = captured_value_67
                        local value_2_56: boolean = false
                        value_1_26.Visible = value_2_56

                        return
                    end
                    closure_ready_6 = true
                    if closure_cache[7] == nil then
                        closure_cache[7] = value_3_40
                        closure_cache[8] = captured_value_67
                    end
                end
            end
            value_1_13:Connect(value_3_40)

            return
        end
    end
    local update_currency: (() -> ())?
    do
        local captured_value_68, captured_value_69, captured_value_70 = require_result_3, title_child, require_result_7
        update_currency = function(): ()
            local value_1_27 = captured_value_68.Materials.Owned.Coins or 0
            local value_2_58 = captured_value_68.Materials.Owned.Gems or 0
            local value_3_57 = captured_value_69
            local value_5_37: string = "Coins"
            local coins_child = value_3_57:WaitForChild(value_5_37)
            local value_5_38: string = "Container"
            local container_child_19 = coins_child:WaitForChild(value_5_38)
            local value_5_39: string = "Amount"
            local amount_child = container_child_19:WaitForChild(value_5_39)
            local comma_value_result_3 = captured_value_70.CommaValue(value_1_27)
            amount_child.Text = comma_value_result_3
            local value_3_61 = captured_value_69
            local value_5_41: string = "Gems"
            local gems_child = value_3_61:WaitForChild(value_5_41)
            local value_5_42: string = "Container"
            local container_child_20 = gems_child:WaitForChild(value_5_42)
            local value_5_43: string = "Amount"
            local amount_child_2 = container_child_20:WaitForChild(value_5_43)
            local comma_value_result_4 = captured_value_70.CommaValue(value_2_58)
            amount_child_2.Text = comma_value_result_4

            return
        end
    end
    local on_initialize
    do
        local captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80, captured_value_81, captured_value_82, captured_value_83, captured_value_84, captured_value_85, captured_value_86, captured_value_87, captured_value_88, captured_value_89, captured_value_90, captured_value_91, captured_value_92, captured_value_93, captured_value_94 = setup_featured, setup_navigation, require_result_7, on_item_clicked, view_contents_child, value_8_7, medium_child, go_to_page, scroll_frame_child, require_result, view_box_contents, local_player_value, radio_cover_child, update_nav_buttons, item_frame_child_2, text_label_child, price_frame_child, buy_popup_child, on_item_purchase_requested, update_currency, inventory_child, shop_child, require_result_6, container_child_17
        on_initialize = function()
            captured_value_71()
            captured_value_72()
            local event_value_5 = captured_value_73.ItemClicked.Event
            local value_3_65 = captured_value_74
            event_value_5:Connect(value_3_65)
            local value_1_32 = captured_value_73
            local value_3_66 = captured_value_75
            local value_5_45: string = "Container"
            local container_child_21 = value_3_66:WaitForChild(value_5_45)
            local value_5_46: string = "ItemChances"
            local item_chances_child = container_child_21:WaitForChild(value_5_46)
            local container_value_5 = captured_value_75.Container
            local value_6_33: string = "BoxFrame"
            local box_frame_child_2 = container_value_5:WaitForChild(value_6_33)
            local value_6_34: string = "ViewOddsFrame"
            local view_odds_frame_child = box_frame_child_2:WaitForChild(value_6_34)
            local value_6_35: string = "Button"
            ;(function(...)
                return value_1_32:ConnectItemChances(item_chances_child, ...)
            end)(view_odds_frame_child:WaitForChild(value_6_35))
            local value_1_34 = captured_value_73
            local value_3_69 = captured_value_76
            local value_5_50: string = "PurchaseCurrency"
            ;(function(...)
                return value_1_34:ConnectPurchaseCurrency(...)
            end)(value_3_69:WaitForChild(value_5_50))
            local value_1_36 = captured_value_77
            local value_3_71: string = "Title"
            local title_child_2 = value_1_36:WaitForChild(value_3_71)
            local value_3_72: string = "Gems"
            local gems_child_2 = title_child_2:WaitForChild(value_3_72)
            local value_3_73: string = "GetMore"
            local get_more_child = gems_child_2:WaitForChild(value_3_73)
            local value_3_74: string = "Button"
            local activated_value_4 = get_more_child:WaitForChild(value_3_74).Activated
            local value_3_75
            do
                local captured_value_95 = captured_value_78
                if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_95) then
                    value_3_75 = closure_cache[9]
                else
                    local closure_ready_7
                    value_3_75 = function(): ()
                        if not closure_ready_7 then
                            return
                        end
                        captured_value_95("PurchaseCurrency")

                        return
                    end
                    closure_ready_7 = true
                    if closure_cache[9] == nil then
                        closure_cache[9] = value_3_75
                        closure_cache[10] = captured_value_95
                    end
                end
            end
            activated_value_4:Connect(value_3_75)
            local value_1_42 = captured_value_73
            local value_3_76 = captured_value_79
            value_1_42:GenerateShopItems(value_3_76)
            local value_1_44 = captured_value_80
            local value_3_77 = captured_value_77
            local value_4_57: string = "Shop"
            local value_5_51
            do
                local captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, captured_value_103, captured_value_104, captured_value_105, captured_value_106, closure_ready_8
                value_5_51 = function(argument_1_7): ()
                    if not closure_ready_8 then
                        return
                    end
                    if not argument_1_7 then
                        return
                    end
                    local target_frame_value = argument_1_7.TargetFrame
                    if not target_frame_value then
                        return
                    end
                    if target_frame_value == "ViewContents" then
                        local target_item_value = argument_1_7.TargetItem
                        if not target_item_value then
                            return
                        end
                        value_30 = "Featured"
                        value_32 = "Weapons"
                        captured_value_96(target_item_value, "MysteryBox")
                        captured_value_97("ViewContents")

                        return
                    end
                    captured_value_97("Items")
                    if target_frame_value == "Radios" then
                        local value_3_90 = captured_value_98
                        local value_5_54: string = "Radio"
                        local radio_value_5 = value_3_90:GetAttribute(value_5_54)
                        local value_4_64 = captured_value_99
                        local value_5_55: boolean = not radio_value_5
                        value_4_64.Visible = value_5_55
                    else
                        local value_3_92 = captured_value_99
                        local value_4_65: boolean = false
                        value_3_92.Visible = value_4_65
                    end
                    local value_3_93 = captured_value_100
                    local value_5_56 = captured_value_101
                    local value_6_37 = target_frame_value
                    value_3_93:SetVisibleItems(value_5_56, value_6_37)
                    value_32 = target_frame_value
                    captured_value_102()
                    if argument_1_7.TargetItem then
                        local value_3_96 = captured_value_100
                        local value_5_57 = captured_value_103
                        local value_6_38 = captured_value_104
                        local value_7_29 = captured_value_105
                        local target_item_value_3 = argument_1_7.TargetItem
                        value_3_96:ViewBuyPopup(
                            value_5_57,
                            value_6_38,
                            value_7_29,
                            target_item_value_3
                        )
                        local value_3_98 = captured_value_106
                        local value_4_68: boolean = true
                        value_3_98.Visible = value_4_68
                    end

                    return
                end
                captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, captured_value_103, captured_value_104, captured_value_105, captured_value_106 = captured_value_81, captured_value_78, captured_value_82, captured_value_83, captured_value_73, captured_value_79, captured_value_84, captured_value_85, captured_value_86, captured_value_87, captured_value_88
                closure_ready_8 = true
            end
            value_1_44:RegisterFrame(value_3_77, value_4_57, value_5_51)
            local event_value_6 = captured_value_73.ItemPurchaseRequested.Event
            local value_3_78 = captured_value_89
            event_value_6:Connect(value_3_78)
            local event_value_7 = captured_value_73.PurchaseGemsRequested.Event
            local value_3_79: (() -> ())?
            do
                local captured_value_107, closure_ready_9
                value_3_79 = function(): ()
                    if not closure_ready_9 then
                        return
                    end
                    value_30 = value_31
                    captured_value_107("PurchaseCurrency")

                    return
                end
                captured_value_107 = captured_value_78
                closure_ready_9 = true
            end
            event_value_7:Connect(value_3_79)
            captured_value_90()
            local value_1_51 = captured_value_91
            local value_3_80: string = "InventoryDataChanged"
            local event_value_8 = value_1_51:WaitForChild(value_3_80).Event
            local value_3_81
            do
                local captured_value_108 = captured_value_90
                if closure_cache[11] ~= nil and same_capture(
                    closure_cache[12],
                    captured_value_108
                ) then
                    value_3_81 = closure_cache[11]
                else
                    local closure_ready_10
                    value_3_81 = function<T1, T3>(argument_1_8: T1, argument_2_5, argument_3_2: T3): ()
                        if not closure_ready_10 then
                            return
                        end
                        do
                            local take_fallback_2 = argument_2_5 == "Gems"
                            if take_fallback_2 or argument_2_5 == "Coins" then
                                captured_value_108()
                            end
                        end

                        return
                    end
                    closure_ready_10 = true
                    if closure_cache[11] == nil then
                        closure_cache[11] = value_3_81
                        closure_cache[12] = captured_value_108
                    end
                end
            end
            event_value_8:Connect(value_3_81)
            local value_1_54 = captured_value_82
            local value_3_82: string = "Radio"
            local get_attribute_changed_signal_result = value_1_54:GetAttributeChangedSignal(
                value_3_82
            )
            local value_3_83
            do
                local captured_value_109, captured_value_110 = captured_value_82, captured_value_83
                if closure_cache[13] ~= nil and same_capture(
                    closure_cache[14],
                    captured_value_109
                ) and same_capture(closure_cache[15], captured_value_110) then
                    value_3_83 = closure_cache[13]
                else
                    local closure_ready_11
                    value_3_83 = function(): ()
                        if not closure_ready_11 then
                            return
                        end
                        local value_1_68 = captured_value_109
                        local value_3_99: string = "Radio"
                        if (value_1_68:GetAttribute(value_3_99)) then
                            local value_2_84 = captured_value_110
                            local value_3_100: boolean = false
                            value_2_84.Visible = value_3_100
                        end

                        return
                    end
                    closure_ready_11 = true
                    if closure_cache[13] == nil then
                        closure_cache[13] = value_3_83
                        closure_cache[14], closure_cache[15] = captured_value_109, captured_value_110
                    end
                end
            end
            get_attribute_changed_signal_result:Connect(value_3_83)
            local value_1_57 = captured_value_83
            local value_3_84: string = "Container"
            local container_child_22 = value_1_57:WaitForChild(value_3_84)
            local value_3_85: string = "BuyFrame"
            local buy_frame_child_3 = container_child_22:WaitForChild(value_3_85)
            local value_3_86: string = "Buy"
            local activated_value_5 = buy_frame_child_3:WaitForChild(value_3_86).Activated
            local value_3_87
            do
                local captured_value_111 = captured_value_92
                if closure_cache[16] ~= nil and same_capture(
                    closure_cache[17],
                    captured_value_111
                ) then
                    value_3_87 = closure_cache[16]
                else
                    local closure_ready_12
                    value_3_87 = function(): ()
                        if not closure_ready_12 then
                            return
                        end
                        captured_value_111.GetRadio:FireServer()

                        return
                    end
                    closure_ready_12 = true
                    if closure_cache[16] == nil then
                        closure_cache[16] = value_3_87
                        closure_cache[17] = captured_value_111
                    end
                end
            end
            activated_value_5:Connect(value_3_87)
            local value_1_62 = captured_value_93
            local value_3_88
            do
                local captured_value_112, captured_value_113, captured_value_114 = captured_value_73, captured_value_94, captured_value_79
                if closure_cache[18] ~= nil and same_capture(
                    closure_cache[19],
                    captured_value_112
                ) and same_capture(closure_cache[20], captured_value_113) and same_capture(
                    closure_cache[21],
                    captured_value_114
                ) then
                    value_3_88 = closure_cache[18]
                else
                    local closure_ready_13
                    value_3_88 = function(argument_1_9): ()
                        if not closure_ready_13 then
                            return
                        end
                        if argument_1_9.EventStartInfo.FeaturedItems then
                            local value_2_86 = captured_value_112
                            local value_4_70 = captured_value_113
                            local desktop_value_2 = argument_1_9.EventStartInfo.FeaturedItems.Desktop
                            value_2_86:GenerateFeaturedItems(value_4_70, desktop_value_2)
                        end
                        if argument_1_9.EventStartInfo.ShopData then
                            local value_2_88 = captured_value_112
                            local value_4_71 = captured_value_114
                            value_2_88:GenerateShopItems(value_4_71)
                        end

                        return
                    end
                    closure_ready_13 = true
                    if closure_cache[18] == nil then
                        closure_cache[18] = value_3_88
                        closure_cache[19], closure_cache[20], closure_cache[21] = captured_value_112, captured_value_113, captured_value_114
                    end
                end
            end
            value_1_62:OnEventStarted(value_3_88)
            captured_value_78("Featured")

            return
        end
    end
    on_initialize()
end

return
