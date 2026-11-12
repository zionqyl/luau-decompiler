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

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local require_value_2 = require
local parent_value: Instance? = script.Parent
local value_5: string = "ShopService"
local require_result_2 = require_value_2(parent_value:WaitForChild(value_5))
local require_value_3 = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "ProfileData"
local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_6_3))
local require_value_4 = require
local game_value_3: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_7_2)
local value_7_3: string = "ItemPopupService"
local require_result_4 = require_value_4(client_services_child:WaitForChild(value_7_3))
local game_value_4: DataModel = game
local value_7_4: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7_4)
local value_7_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_5)
local value_7_6: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_7_6)
local game_value_5: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_8)
local value_8_2: string = "Remotes"
local remotes_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_8_2)
local value_8_3: string = "Shop"
local shop_child = remotes_child_2:WaitForChild(value_8_3)
local require_value_5 = require
local game_value_6: DataModel = game
local value_10: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_6:GetService(value_10)
local value_10_2: string = "Database"
local database_child: Instance? = replicated_storage_service_6:WaitForChild(value_10_2)
local value_10_3: string = "Sync"
local new_shop_value = require_value_5(database_child:WaitForChild(value_10_3)).NewShop
local require_value_6 = require
local game_value_7: DataModel = game
local value_12: string = "ReplicatedStorage"
local replicated_storage_service_7: Instance = game_value_7:GetService(value_12)
local value_12_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_7:WaitForChild(value_12_2)
local value_12_3: string = "EventInfoService"
local value_7_10 = (require_value_6(shared_services_child:WaitForChild(value_12_3)))
local local_player_value = game.Players.LocalPlayer
local parent_value_3 = script.Parent.Parent
local value_13: string = "Small"
local small_child = parent_value_3:WaitForChild(value_13)
local value_14: string = "Container"
local container_child = small_child:WaitForChild(value_14)
local value_14_2: string = "Main"
local value_10_7 = (container_child:WaitForChild(value_14_2))
local value_14_3: string = "Container"
local container_child_2 = small_child:WaitForChild(value_14_3)
local value_14_4: string = "Title"
local title_child = container_child_2:WaitForChild(value_14_4)
local value_15: string = "Container"
local container_child_3 = title_child:WaitForChild(value_15)
local value_16: string = "Processing"
local value_12_9 = (small_child:WaitForChild(value_16))
local value_16_2: string = "Featured"
local featured_child = value_10_7:WaitForChild(value_16_2)
local value_16_3: string = "Nav"
local nav_child = featured_child:WaitForChild(value_16_3)
local value_16_4: string = "Container"
local container_child_4 = nav_child:WaitForChild(value_16_4)
local value_17: string = "Featured"
local featured_child_2 = value_10_7:WaitForChild(value_17)
local value_17_2: string = "Container"
local container_child_5 = featured_child_2:WaitForChild(value_17_2)
local value_18: string = "Items"
local items_child = value_10_7:WaitForChild(value_18)
local value_18_2: string = "Container"
local container_child_6 = items_child:WaitForChild(value_18_2)
local value_18_3: string = "RadioCover"
local radio_cover_child = container_child_6:WaitForChild(value_18_3)
local value_19: string = "ViewContents"
local view_contents_child = value_10_7:WaitForChild(value_19)
local value_20: string = "Container"
local container_child_7 = view_contents_child:WaitForChild(value_20)
local value_20_2: string = "Main"
local main_child_2 = container_child_7:WaitForChild(value_20_2)
local value_20_3: string = "BoxFrame"
local box_frame_child = main_child_2:WaitForChild(value_20_3)
local value_20_4: string = "ItemContainer"
local item_container_child = box_frame_child:WaitForChild(value_20_4)
local value_21: string = "Container"
local container_child_8 = view_contents_child:WaitForChild(value_21)
local value_21_2: string = "Main"
local main_child_3 = container_child_8:WaitForChild(value_21_2)
local value_21_3: string = "BoxContents"
local box_contents_child = main_child_3:WaitForChild(value_21_3)
local value_21_4: string = "Container"
local container_child_9 = box_contents_child:WaitForChild(value_21_4)
local value_21_5: string = "ScrollingFrame"
local scrolling_frame_child = container_child_9:WaitForChild(value_21_5)
local value_22: string = "Container"
local container_child_10 = view_contents_child:WaitForChild(value_22)
local value_22_2: string = "BuyFrame"
local buy_frame_child = container_child_10:WaitForChild(value_22_2)
local value_23: string = "BuyPopup"
local value_17_7 = (value_10_7:WaitForChild(value_23))
local value_23_2: string = "Container"
local container_child_11 = value_17_7:WaitForChild(value_23_2)
local value_23_3: string = "Left"
local left_child = container_child_11:WaitForChild(value_23_3)
local value_23_4: string = "ItemFrame"
local item_frame_child = left_child:WaitForChild(value_23_4)
local value_23_5: string = "ItemContainer"
local item_container_child_2 = item_frame_child:WaitForChild(value_23_5)
local value_24: string = "Container"
local container_child_12 = value_17_7:WaitForChild(value_24)
local value_24_2: string = "Right"
local right_child = container_child_12:WaitForChild(value_24_2)
local value_24_3: string = "Description"
local description_child = right_child:WaitForChild(value_24_3)
local value_24_4: string = "TextLabel"
local text_label_child = description_child:WaitForChild(value_24_4)
local value_25: string = "Container"
local container_child_13 = value_17_7:WaitForChild(value_25)
local value_25_2: string = "Right"
local right_child_2 = container_child_13:WaitForChild(value_25_2)
local value_25_3: string = "PriceFrame"
local price_frame_child = right_child_2:WaitForChild(value_25_3)
local value_26: string = "Items"
local value_17_8 = (value_10_7:WaitForChild(value_26))
local value_26_2: string = "Container"
local container_child_14 = value_17_8:WaitForChild(value_26_2)
local value_26_3: string = "ScrollFrame"
local scroll_frame_child = container_child_14:WaitForChild(value_26_3)
local value_27: string = "ItemGridLayout"
local value_17_9 = (scroll_frame_child:WaitForChild(value_27))
local value_27_2: string = "NewItem"
local new_item_child = scroll_frame_child:WaitForChild(value_27_2)
local table_26 = {"Featured"}
local go_to_page
do
    local captured_value = container_child_3
    go_to_page = function(argument_1, argument_2: string): ()
        local value_3_5 = captured_value
        local value_5_11 = "Back"
        value_3_5 = value_3_5:WaitForChild(value_5_11)
        local value_4_8
        if argument_2 == "Featured" then
            value_4_8 = false
        else
            value_4_8 = true
        end
        value_3_5.Visible = value_4_8
        value_3_5 = captured_value
        value_5_11 = "Title"
        value_3_5 = value_3_5:WaitForChild(value_5_11)
        if argument_2 ~= "Featured" then
            value_4_8 = false
        else
            value_4_8 = true
        end
        value_3_5.Visible = value_4_8
        value_3_5, value_4_8, value_5_11 = argument_1:GetChildren()
        for key, value in value_3_5, value_4_8, value_5_11 do
            local value_6_13, value_7_11 = key, value
            local value_10_8: string = "GuiObject"
            local is_a_result = value_7_11:IsA(value_10_8)
            if not is_a_result then
                continue
            end
            local name_value = value_7_11.Name
            local value_8_8: boolean?
            if name_value ~= argument_2 then
                value_8_8 = false
            else
                value_8_8 = true
            end
            value_7_11.Visible = value_8_8
        end

        return
    end
end
local go_back
do
    local captured_value_2, captured_value_3, captured_value_4 = table_26, go_to_page, value_10_7
    go_back = function()
        table.remove(captured_value_2)
        captured_value_3(captured_value_4, captured_value_2[#captured_value_2])

        return
    end
end
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11 = require_result_2, item_container_child, scrolling_frame_child, buy_frame_child, table_26, go_to_page, value_10_7

    local function view_box_contents(argument_1_2: string, argument_2_2: string)
        local value_3_7 = captured_value_5
        local value_5_13 = captured_value_6
        local value_6_15 = captured_value_7
        local value_7_12 = captured_value_8
        local value_8_9: string = argument_1_2
        local value_9_5: string = argument_2_2
        value_3_7:ViewBoxContents(value_5_13, value_6_15, value_7_12, value_8_9, value_9_5)
        local value_4_11 = captured_value_9
        local value_5_14: string = "ViewContents"
        table.insert(value_4_11, value_5_14)
        captured_value_10(captured_value_11, "ViewContents")

        return
    end
end
do
    local captured_value_12, captured_value_13, captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18 = require_result_2, item_container_child_2, text_label_child, price_frame_child, table_26, go_to_page, value_10_7

    local function view_buy_popup(argument_1_3: string, argument_2_3: string)
        local value_3_10 = captured_value_12
        local value_5_16 = captured_value_13
        local value_6_16 = captured_value_14
        local value_7_13 = captured_value_15
        local value_8_10: string = argument_1_3
        value_3_10:ViewBuyPopup(value_5_16, value_6_16, value_7_13, value_8_10)
        local value_4_14 = captured_value_16
        local value_5_17: string = "BuyPopup"
        table.insert(value_4_14, value_5_17)
        captured_value_17(captured_value_18, "BuyPopup")

        return
    end
end
do
    local captured_value_19, captured_value_20 = new_item_child, value_17_9

    local function setup_screen_size(): ()
        local value_1_2: boolean = false
        if captured_value_19.AbsoluteSize.Y < 160 then
            local value_1_3: boolean = true
            local value_2_7 = captured_value_20
            local new_result = UDim2.new(0.333, -4, 1, 0)
            value_2_7.CellSize = new_result
        end
        captured_value_19:Destroy()

        return
    end
end
local setup_navigation
do
    local captured_value_21, captured_value_22, captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28 = container_child_4, table_26, go_to_page, value_10_7, require_result_2, scroll_frame_child, local_player_value, radio_cover_child
    setup_navigation = function()
        local value_1_4, value_2_10, value_3_15 = captured_value_21:GetChildren()
        for key_2, value_28 in value_1_4, value_2_10, value_3_15 do
            local value_4_17, value_5_20 = key_2, value_28
            local value_8_11: string = "TextButton"
            local is_a_result_2 = value_5_20:IsA(value_8_11)
            if not is_a_result_2 then
                continue
            end
            local activated_value = value_5_20.Activated
            local value_8_12
            do
                local captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, closure_ready
                value_8_12 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local value_2_11 = captured_value_29
                    local value_3_16: string = "Items"
                    table.insert(value_2_11, value_3_16)
                    captured_value_30(captured_value_31, "Items")
                    local value_1_6 = captured_value_32
                    local value_3_18 = captured_value_33
                    local name_value_2 = captured_value_34.Name
                    value_1_6:SetVisibleItems(value_3_18, name_value_2)
                    if captured_value_34.Name == "Radios" then
                        local value_1_9 = captured_value_35
                        local value_3_19: string = "Radio"
                        local radio_value = value_1_9:GetAttribute(value_3_19)
                        local value_2_15 = captured_value_36
                        local value_3_20 = not radio_value
                        value_2_15.Visible = value_3_20

                        return
                    end
                    local value_1_11 = captured_value_36
                    local value_2_16: boolean = false
                    value_1_11.Visible = value_2_16

                    return
                end
                captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36 = captured_value_22, captured_value_23, captured_value_24, captured_value_25, captured_value_26, value_5_20, captured_value_27, captured_value_28
                closure_ready = true
            end
            activated_value:Connect(value_8_12)
        end

        return
    end
end
local on_item_purchase_requested
do
    local captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44, captured_value_45 = new_shop_value, value_12_9, require_result_2, small_child, shop_child, require_result_4, table_26, go_to_page, value_10_7
    on_item_purchase_requested = function(argument_1_4: string, argument_2_4: string)
        local buy_item_new_value, egg_controller_value, event_value, event_value_2, invoke_server_result, invoke_server_result_2, item_claims_complete_value, item_claims_complete_value_2, open_crate_value, remove_value_2, request_unbox_result, type_value, value_10_9, value_11_5, value_3_21, value_3_22, value_3_23, value_4_19, value_5_21, value_5_22, value_5_23, value_5_25, value_5_26, value_5_27, value_5_29, value_5_31, value_5_32, value_6_20, value_6_22, value_6_23, value_6_25, value_6_26, value_6_27, value_6_30, value_6_32, value_6_33, value_6_34, value_6_36, value_7_17, value_7_18, value_7_19, value_7_20, value_7_22, value_7_23, value_7_24, value_7_25, value_7_26, value_7_28, value_8_13, value_8_14, value_8_15, value_8_16, value_8_17, value_8_18, value_9_6, value_9_7, value_9_8, value_9_9, visible_value
        local control_state = 0
        while true do
            if control_state < 8 then
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            value_4_19 = captured_value_37
                            value_3_21 = value_4_19[argument_1_4]
                            type_value = value_3_21.Type
                            value_5_21 = captured_value_38
                            visible_value = value_5_21.Visible
                            control_state = if visible_value == true then 2 else 1
                        else
                            value_3_22 = false
                            control_state = 3
                        end
                    else
                        if control_state < 3 then
                            value_3_22 = true
                            control_state = 3
                        else
                            control_state = if not value_3_22 then 5 else 4
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
                            value_5_22 = captured_value_38
                            value_6_20 = true
                            value_5_22.Visible = value_6_20
                            control_state = if type_value ~= "MysteryBox" then 10 else 8
                        end
                    end
                end
            else
                if control_state < 12 then
                    if control_state < 10 then
                        if control_state < 9 then
                            value_5_23 = captured_value_39
                            value_7_17 = argument_1_4
                            value_8_13 = argument_2_4
                            value_9_6 = 1
                            request_unbox_result = value_5_23:RequestUnbox(
                                value_7_17,
                                value_8_13,
                                value_9_6
                            )
                            value_3_23 = request_unbox_result
                            value_5_25 = captured_value_38
                            value_6_22 = false
                            value_5_25.Visible = value_6_22
                            control_state = if not value_3_23 then 13 else 9
                        else
                            value_5_26 = captured_value_40
                            value_6_23 = false
                            value_5_26.Visible = value_6_23
                            control_state = 13
                        end
                    else
                        if control_state < 11 then
                            control_state = if type_value ~= "Eggs" then 13 else 11
                        else
                            value_5_27 = captured_value_41
                            open_crate_value = value_5_27.OpenCrate
                            value_7_18 = argument_1_4
                            value_8_14 = type_value
                            value_9_7 = argument_2_4
                            invoke_server_result = open_crate_value:InvokeServer(
                                value_7_18,
                                value_8_14,
                                value_9_7
                            )
                            value_6_25 = captured_value_38
                            value_7_19 = false
                            value_6_25.Visible = value_7_19
                            control_state = if not invoke_server_result then 13 else 12
                        end
                    end
                else
                    if control_state < 14 then
                        if control_state < 13 then
                            value_6_26 = captured_value_40
                            value_7_20 = false
                            value_6_26.Visible = value_7_20
                            value_6_27 = captured_value_41
                            egg_controller_value = value_6_27.EggController
                            value_8_15 = argument_1_4
                            value_9_8 = invoke_server_result
                            egg_controller_value:Fire(value_8_15, value_9_8)
                            control_state = 13
                        else
                            value_5_29 = captured_value_42
                            item_claims_complete_value = value_5_29.ItemClaimsComplete
                            event_value = item_claims_complete_value.Event
                            do
                                local captured_value_46 = captured_value_40
                                if closure_cache[1] ~= nil and same_capture(
                                    closure_cache[2],
                                    captured_value_46
                                ) then
                                    value_7_22 = closure_cache[1]
                                else
                                    local closure_ready_2
                                    value_7_22 = function(): ()
                                        if not closure_ready_2 then
                                            return
                                        end
                                        local value_1_12 = captured_value_46
                                        local value_2_17: boolean = true
                                        value_1_12.Visible = value_2_17

                                        return
                                    end
                                    closure_ready_2 = true
                                    if closure_cache[1] == nil then
                                        closure_cache[1] = value_7_22
                                        closure_cache[2] = captured_value_46
                                    end
                                end
                            end
                            event_value:Once(value_7_22)

                            return
                        end
                    else
                        if control_state < 15 then
                            value_5_31 = captured_value_38
                            value_6_30 = true
                            value_5_31.Visible = value_6_30
                            value_5_32 = captured_value_41
                            buy_item_new_value = value_5_32.BuyItemNew
                            value_7_23 = argument_1_4
                            value_8_16 = argument_2_4
                            invoke_server_result_2 = buy_item_new_value:InvokeServer(
                                value_7_23,
                                value_8_16
                            )
                            control_state = if not invoke_server_result_2 then 16 else 15
                        else
                            if control_state < 16 then
                                remove_value_2 = table.remove
                                value_7_24 = captured_value_43
                                remove_value_2(value_7_24)
                                value_6_32 = captured_value_44
                                value_7_25 = captured_value_45
                                value_9_9 = captured_value_43
                                value_11_5 = captured_value_43
                                value_10_9 = #value_11_5
                                value_8_17 = value_9_9[value_10_9]
                                value_6_32(value_7_25, value_8_17)
                                value_6_33 = captured_value_40
                                value_7_26 = false
                                value_6_33.Visible = value_7_26
                                value_6_34 = captured_value_42
                                item_claims_complete_value_2 = value_6_34.ItemClaimsComplete
                                event_value_2 = item_claims_complete_value_2.Event
                                do
                                    local captured_value_47 = captured_value_40
                                    if closure_cache[3] ~= nil and same_capture(
                                        closure_cache[4],
                                        captured_value_47
                                    ) then
                                        value_8_18 = closure_cache[3]
                                    else
                                        local closure_ready_3
                                        value_8_18 = function(): ()
                                            if not closure_ready_3 then
                                                return
                                            end
                                            local value_1_13 = captured_value_47
                                            local value_2_18: boolean = true
                                            value_1_13.Visible = value_2_18

                                            return
                                        end
                                        closure_ready_3 = true
                                        if closure_cache[3] == nil then
                                            closure_cache[3] = value_8_18
                                            closure_cache[4] = captured_value_47
                                        end
                                    end
                                end
                                event_value_2:Once(value_8_18)
                                control_state = 16
                            else
                                value_6_36 = captured_value_38
                                value_7_28 = false
                                value_6_36.Visible = value_7_28

                                return
                            end
                        end
                    end
                end
            end
        end
    end
end
local on_item_clicked
do
    local captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58 = require_result, require_result_2, item_container_child, scrolling_frame_child, buy_frame_child, table_26, go_to_page, value_10_7, item_container_child_2, text_label_child, price_frame_child
    on_item_clicked = function(argument_1_5: string, argument_2_5: string)
        if argument_2_5 == "Event" then
            local value_3_24 = captured_value_48
            local value_5_34: string = "CurrentEvent"
            value_3_24:ViewFrame(value_5_34)

            return
        end
        do
            local take_fallback = argument_2_5 == "MysteryBox"
            if take_fallback or argument_2_5 == "Eggs" then
                local value_3_26 = captured_value_49
                local value_5_35 = captured_value_50
                local value_6_37 = captured_value_51
                local value_7_29 = captured_value_52
                local value_8_19: string = argument_1_5
                local value_9_10: string = argument_2_5
                value_3_26:ViewBoxContents(
                    value_5_35,
                    value_6_37,
                    value_7_29,
                    value_8_19,
                    value_9_10
                )
                local value_4_22 = captured_value_53
                local value_5_36: string = "ViewContents"
                table.insert(value_4_22, value_5_36)
                captured_value_54(captured_value_55, "ViewContents")

                return
            end
        end
        local value_3_29 = captured_value_49
        local value_5_38 = captured_value_56
        local value_6_38 = captured_value_57
        local value_7_30 = captured_value_58
        local value_8_20: string = argument_1_5
        value_3_29:ViewBuyPopup(value_5_38, value_6_38, value_7_30, value_8_20)
        local value_4_25 = captured_value_53
        local value_5_39: string = "BuyPopup"
        table.insert(value_4_25, value_5_39)
        captured_value_54(captured_value_55, "BuyPopup")

        return
    end
end
local on_currency_updated: (() -> ())?
do
    local captured_value_59, captured_value_60, captured_value_61 = require_result_3, container_child_3, require_result_2
    on_currency_updated = function(): ()
        local value_1_14 = captured_value_59.Materials.Owned.Coins or 0
        local value_2_20 = captured_value_59.Materials.Owned.Gems or 0
        local value_3_33 = captured_value_60
        local value_5_41: string = "Gems"
        local gems_child = value_3_33:WaitForChild(value_5_41)
        local value_5_42: string = "Container"
        local container_child_15 = gems_child:WaitForChild(value_5_42)
        local value_5_43: string = "Amount"
        local amount_child = container_child_15:WaitForChild(value_5_43)
        local comma_value_result = captured_value_61.CommaValue(value_2_20)
        amount_child.Text = comma_value_result
        local value_3_37 = captured_value_60
        local value_5_45: string = "Coins"
        local coins_child = value_3_37:WaitForChild(value_5_45)
        local value_5_46: string = "Container"
        local container_child_16 = coins_child:WaitForChild(value_5_46)
        local value_5_47: string = "Amount"
        local amount_child_2 = container_child_16:WaitForChild(value_5_47)
        local comma_value_result_2 = captured_value_61.CommaValue(value_1_14)
        amount_child_2.Text = comma_value_result_2

        return
    end
end
local on_initialize
do
    local captured_value_62, captured_value_63, captured_value_64, captured_value_65, captured_value_66, captured_value_67, captured_value_68, captured_value_69, captured_value_70, captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80, captured_value_81, captured_value_82, captured_value_83, captured_value_84, captured_value_85, captured_value_86, captured_value_87, captured_value_88, captured_value_89 = new_item_child, value_17_9, setup_navigation, require_result_2, scroll_frame_child, value_10_7, container_child_5, container_child_3, table_26, go_to_page, go_back, require_result, small_child, item_container_child, scrolling_frame_child, buy_frame_child, new_shop_value, item_container_child_2, text_label_child, price_frame_child, on_currency_updated, inventory_child, local_player_value, radio_cover_child, shop_child, on_item_clicked, on_item_purchase_requested, value_7_10
    on_initialize = function()
        local value_1_15: boolean = false
        if captured_value_62.AbsoluteSize.Y < 160 then
            local value_1_16: boolean = true
            local value_2_22 = captured_value_63
            local new_result_2 = UDim2.new(0.333, -4, 1, 0)
            value_2_22.CellSize = new_result_2
        end
        captured_value_62:Destroy()
        captured_value_64()
        local value_1_18 = captured_value_65
        local value_3_43 = captured_value_66
        value_1_18:GenerateShopItems(value_3_43)
        local value_1_20 = captured_value_65
        local value_3_44 = captured_value_67
        local value_5_50: string = "PurchaseCurrency"
        ;(function(...)
            return value_1_20:ConnectPurchaseCurrency(...)
        end)(value_3_44:WaitForChild(value_5_50))
        local value_1_22 = captured_value_65
        local value_3_46 = captured_value_68
        local mobile_value = captured_value_65.FeaturedItems.Mobile
        value_1_22:GenerateFeaturedItems(value_3_46, mobile_value)
        local value_1_24 = captured_value_69
        local value_3_47: string = "Gems"
        local gems_child_2 = value_1_24:WaitForChild(value_3_47)
        local value_3_48: string = "GetMore"
        local get_more_child = gems_child_2:WaitForChild(value_3_48)
        local value_3_49: string = "Button"
        local activated_value_2 = get_more_child:WaitForChild(value_3_49).Activated
        local value_3_50
        do
            local captured_value_90, captured_value_91, captured_value_92 = captured_value_70, captured_value_71, captured_value_67
            if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_90) and same_capture(
                closure_cache[7],
                captured_value_91
            ) and same_capture(closure_cache[8], captured_value_92) then
                value_3_50 = closure_cache[5]
            else
                local closure_ready_4
                value_3_50 = function()
                    if not closure_ready_4 then
                        return
                    end
                    local value_2_47 = captured_value_90
                    local value_3_66: string = "PurchaseCurrency"
                    table.insert(value_2_47, value_3_66)
                    captured_value_91(captured_value_92, "PurchaseCurrency")

                    return
                end
                closure_ready_4 = true
                if closure_cache[5] == nil then
                    closure_cache[5] = value_3_50
                    closure_cache[6], closure_cache[7], closure_cache[8] = captured_value_90, captured_value_91, captured_value_92
                end
            end
        end
        activated_value_2:Connect(value_3_50)
        captured_value_71(captured_value_67, "Featured")
        local value_1_30 = captured_value_69
        local value_3_52: string = "Back"
        local activated_value_3 = value_1_30:WaitForChild(value_3_52).Activated
        local value_3_53 = captured_value_72
        activated_value_3:Connect(value_3_53)
        local value_1_33 = captured_value_73
        local value_3_54 = captured_value_74
        local value_4_38: string = "Shop"
        local value_5_51
        do
            local captured_value_93, captured_value_94, captured_value_95, captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, captured_value_103 = captured_value_65, captured_value_75, captured_value_76, captured_value_77, captured_value_70, captured_value_71, captured_value_67, captured_value_78, captured_value_79, captured_value_80, captured_value_81
            if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_93) and same_capture(
                closure_cache[11],
                captured_value_94
            ) and same_capture(closure_cache[12], captured_value_95) and same_capture(
                closure_cache[13],
                captured_value_96
            ) and same_capture(closure_cache[14], captured_value_97) and same_capture(
                closure_cache[15],
                captured_value_98
            ) and same_capture(closure_cache[16], captured_value_99) and same_capture(
                closure_cache[17],
                captured_value_100
            ) and same_capture(closure_cache[18], captured_value_101) and same_capture(
                closure_cache[19],
                captured_value_102
            ) and same_capture(closure_cache[20], captured_value_103) then
                value_5_51 = closure_cache[9]
            else
                local closure_ready_5
                value_5_51 = function(argument_1_6)
                    if not closure_ready_5 then
                        return
                    end
                    if not argument_1_6 then
                        return
                    end
                    local target_frame_value = argument_1_6.TargetFrame
                    if not target_frame_value then
                        return
                    end
                    if target_frame_value == "ViewContents" then
                        local target_item_value = argument_1_6.TargetItem
                        if not target_item_value then
                            return
                        end
                        local value_4_39 = captured_value_93
                        local value_6_40 = captured_value_94
                        local value_7_32 = captured_value_95
                        local value_8_21 = captured_value_96
                        local value_9_11 = target_item_value
                        local value_10_10: string = "MysteryBox"
                        value_4_39:ViewBoxContents(
                            value_6_40,
                            value_7_32,
                            value_8_21,
                            value_9_11,
                            value_10_10
                        )
                        local value_5_53 = captured_value_97
                        local value_6_41: string = "ViewContents"
                        table.insert(value_5_53, value_6_41)
                        captured_value_98(captured_value_99, "ViewContents")

                        return
                    end
                    if argument_1_6.TargetItem then
                        local target_item_value_3 = argument_1_6.TargetItem
                        local type_value_2 = captured_value_100[argument_1_6.TargetItem].Type
                        local value_5_56 = captured_value_93
                        local value_7_33 = captured_value_101
                        local value_8_22 = captured_value_102
                        local value_9_12 = captured_value_103
                        local value_10_11 = target_item_value_3
                        value_5_56:ViewBuyPopup(value_7_33, value_8_22, value_9_12, value_10_11)
                        local value_6_44 = captured_value_97
                        local value_7_34: string = "BuyPopup"
                        table.insert(value_6_44, value_7_34)
                        captured_value_98(captured_value_99, "BuyPopup")
                    end

                    return
                end
                closure_ready_5 = true
                if closure_cache[9] == nil then
                    closure_cache[9] = value_5_51
                    closure_cache[10], closure_cache[11], closure_cache[12], closure_cache[13], closure_cache[14], closure_cache[15], closure_cache[16], closure_cache[17], closure_cache[18], closure_cache[19], closure_cache[20] = captured_value_93, captured_value_94, captured_value_95, captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, captured_value_103
                end
            end
        end
        value_1_33:RegisterFrame(value_3_54, value_4_38, value_5_51)
        captured_value_82()
        local event_value_3 = captured_value_83.InventoryDataChanged.Event
        local value_3_55
        do
            local captured_value_104 = captured_value_82
            if closure_cache[21] ~= nil and same_capture(closure_cache[22], captured_value_104) then
                value_3_55 = closure_cache[21]
            else
                local closure_ready_6
                value_3_55 = function<T1, T3>(argument_1_7: T1, argument_2_6, argument_3: T3): ()
                    if not closure_ready_6 then
                        return
                    end
                    do
                        local take_fallback_2 = argument_2_6 == "Gems"
                        if take_fallback_2 or argument_2_6 == "Coins" then
                            captured_value_104()
                        end
                    end

                    return
                end
                closure_ready_6 = true
                if closure_cache[21] == nil then
                    closure_cache[21] = value_3_55
                    closure_cache[22] = captured_value_104
                end
            end
        end
        event_value_3:Connect(value_3_55)
        local value_1_38 = captured_value_84
        local value_3_56: string = "Radio"
        local get_attribute_changed_signal_result = value_1_38:GetAttributeChangedSignal(
            value_3_56
        )
        local value_3_57
        do
            local captured_value_105, captured_value_106 = captured_value_84, captured_value_85
            if closure_cache[23] ~= nil and same_capture(closure_cache[24], captured_value_105) and same_capture(
                closure_cache[25],
                captured_value_106
            ) then
                value_3_57 = closure_cache[23]
            else
                local closure_ready_7
                value_3_57 = function(): ()
                    if not closure_ready_7 then
                        return
                    end
                    local value_1_55 = captured_value_105
                    local value_3_68: string = "Radio"
                    if (value_1_55:GetAttribute(value_3_68)) then
                        local value_2_50 = captured_value_106
                        local value_3_69: boolean = false
                        value_2_50.Visible = value_3_69
                    end

                    return
                end
                closure_ready_7 = true
                if closure_cache[23] == nil then
                    closure_cache[23] = value_3_57
                    closure_cache[24], closure_cache[25] = captured_value_105, captured_value_106
                end
            end
        end
        get_attribute_changed_signal_result:Connect(value_3_57)
        local value_1_41 = captured_value_85
        local value_3_58: string = "Container"
        local container_child_17 = value_1_41:WaitForChild(value_3_58)
        local value_3_59: string = "BuyFrame"
        local buy_frame_child_2 = container_child_17:WaitForChild(value_3_59)
        local value_3_60: string = "Buy"
        local activated_value_4 = buy_frame_child_2:WaitForChild(value_3_60).Activated
        local value_3_61
        do
            local captured_value_107 = captured_value_86
            if closure_cache[26] ~= nil and same_capture(closure_cache[27], captured_value_107) then
                value_3_61 = closure_cache[26]
            else
                local closure_ready_8
                value_3_61 = function(): ()
                    if not closure_ready_8 then
                        return
                    end
                    captured_value_107.GetRadio:FireServer()

                    return
                end
                closure_ready_8 = true
                if closure_cache[26] == nil then
                    closure_cache[26] = value_3_61
                    closure_cache[27] = captured_value_107
                end
            end
        end
        activated_value_4:Connect(value_3_61)
        local event_value_4 = captured_value_65.PurchaseGemsRequested.Event
        local value_3_62
        do
            local captured_value_108, captured_value_109, captured_value_110 = captured_value_70, captured_value_71, captured_value_67
            if closure_cache[28] ~= nil and same_capture(closure_cache[29], captured_value_108) and same_capture(
                closure_cache[30],
                captured_value_109
            ) and same_capture(closure_cache[31], captured_value_110) then
                value_3_62 = closure_cache[28]
            else
                local closure_ready_9
                value_3_62 = function()
                    if not closure_ready_9 then
                        return
                    end
                    local value_2_52 = captured_value_108
                    local value_3_70: string = "PurchaseCurrency"
                    table.insert(value_2_52, value_3_70)
                    captured_value_109(captured_value_110, "PurchaseCurrency")

                    return
                end
                closure_ready_9 = true
                if closure_cache[28] == nil then
                    closure_cache[28] = value_3_62
                    closure_cache[29], closure_cache[30], closure_cache[31] = captured_value_108, captured_value_109, captured_value_110
                end
            end
        end
        event_value_4:Connect(value_3_62)
        local event_value_5 = captured_value_65.ItemClicked.Event
        local value_3_63 = captured_value_87
        event_value_5:Connect(value_3_63)
        local event_value_6 = captured_value_65.ItemPurchaseRequested.Event
        local value_3_64 = captured_value_88
        event_value_6:Connect(value_3_64)
        local value_1_52 = captured_value_89
        local value_3_65
        do
            local captured_value_111, captured_value_112, captured_value_113 = captured_value_65, captured_value_68, captured_value_66
            if closure_cache[32] ~= nil and same_capture(closure_cache[33], captured_value_111) and same_capture(
                closure_cache[34],
                captured_value_112
            ) and same_capture(closure_cache[35], captured_value_113) then
                value_3_65 = closure_cache[32]
            else
                local closure_ready_10
                value_3_65 = function(argument_1_8): ()
                    if not closure_ready_10 then
                        return
                    end
                    if argument_1_8.EventStartInfo.FeaturedItems then
                        local value_2_54 = captured_value_111
                        local value_4_44 = captured_value_112
                        local mobile_value_2 = argument_1_8.EventStartInfo.FeaturedItems.Mobile
                        value_2_54:GenerateFeaturedItems(value_4_44, mobile_value_2)
                    end
                    if argument_1_8.EventStartInfo.ShopData then
                        local value_2_56 = captured_value_111
                        local value_4_45 = captured_value_113
                        value_2_56:GenerateShopItems(value_4_45)
                    end

                    return
                end
                closure_ready_10 = true
                if closure_cache[32] == nil then
                    closure_cache[32] = value_3_65
                    closure_cache[33], closure_cache[34], closure_cache[35] = captured_value_111, captured_value_112, captured_value_113
                end
            end
        end
        value_1_52:OnEventStarted(value_3_65)

        return
    end
end
on_initialize()

return
