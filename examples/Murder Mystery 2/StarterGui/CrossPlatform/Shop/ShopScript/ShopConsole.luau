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
    local value_5_2: string = "ClientServices"
    local client_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
    local value_5_3: string = "ItemService"
    local require_result_2 = require_value_2(client_services_child:WaitForChild(value_5_3))
    local game_value_3: DataModel = game
    local value_4_7: string = "ContextActionService"
    local context_action_service: Instance = game_value_3:GetService(value_4_7)
    local require_value_3 = require
    local parent_value: Instance? = script.Parent
    local value_5_4: string = "ShopService"
    local require_result_3 = require_value_3(parent_value:WaitForChild(value_5_4))
    local require_value_4 = require
    local game_value_4: DataModel = game
    local value_6: string = "ReplicatedStorage"
    local replicated_storage_service_3: Instance = game_value_4:GetService(value_6)
    local value_6_2: string = "Database"
    local database_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
    local value_6_3: string = "Sync"
    local new_shop_value = require_value_4(database_child:WaitForChild(value_6_3)).NewShop
    local game_value_5: DataModel = game
    local value_7: string = "GuiService"
    local value_3_9: Instance = (game_value_5:GetService(value_7))
    local game_value_6: DataModel = game
    local value_7_2: string = "ReplicatedStorage"
    local replicated_storage_service_4: Instance = game_value_6:GetService(value_7_2)
    local value_7_3: string = "Remotes"
    local remotes_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_3)
    local value_7_4: string = "Shop"
    local shop_child = remotes_child:WaitForChild(value_7_4)
    local game_value_7: DataModel = game
    local value_8: string = "ReplicatedStorage"
    local replicated_storage_service_5: Instance = game_value_7:GetService(value_8)
    local value_8_2: string = "Remotes"
    local remotes_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_8_2)
    local value_8_3: string = "Inventory"
    local inventory_child = remotes_child_2:WaitForChild(value_8_3)
    local require_value_5 = require
    local game_value_8: DataModel = game
    local value_10: string = "ReplicatedStorage"
    local replicated_storage_service_6: Instance = game_value_8:GetService(value_10)
    local value_10_2: string = "Modules"
    local modules_child_2: Instance? = replicated_storage_service_6:WaitForChild(value_10_2)
    local value_10_3: string = "ProfileData"
    local require_result_5 = require_value_5(modules_child_2:WaitForChild(value_10_3))
    local require_value_6 = require
    local game_value_9: DataModel = game
    local value_11: string = "ReplicatedStorage"
    local replicated_storage_service_7: Instance = game_value_9:GetService(value_11)
    local value_11_2: string = "ClientServices"
    local client_services_child_2: Instance? = replicated_storage_service_7:WaitForChild(
        value_11_2
    )
    local value_11_3: string = "ItemPopupService"
    local require_result_6 = require_value_6(client_services_child_2:WaitForChild(value_11_3))
    local require_value_7 = require
    local game_value_10: DataModel = game
    local value_11_4: string = "ReplicatedStorage"
    local replicated_storage_service_8: Instance = game_value_10:GetService(value_11_4)
    local value_11_5: string = "SharedServices"
    local shared_services_child: Instance? = replicated_storage_service_8:WaitForChild(value_11_5)
    local value_11_6: string = "EventInfoService"
    local require_result_7 = require_value_7(shared_services_child:WaitForChild(value_11_6))
    local player_gui_value = game.Players.LocalPlayer.PlayerGui
    local value_12: string = "InputContext"
    local input_context_child = player_gui_value:WaitForChild(value_12)
    local value_12_2: string = "Console"
    local console_child = input_context_child:WaitForChild(value_12_2)
    local value_13: string = "Shop"
    local value_9_10 = (console_child:WaitForChild(value_13))
    local parent_value_3 = script.Parent.Parent
    local value_14: string = "Large"
    local large_child = parent_value_3:WaitForChild(value_14)
    local value_15: string = "Main"
    local value_11_10 = (large_child:WaitForChild(value_15))
    local value_15_2: string = "Container"
    local container_child = value_11_10:WaitForChild(value_15_2)
    local value_16: string = "Title"
    local title_child = large_child:WaitForChild(value_16)
    local value_17: string = "Nav"
    local nav_child = title_child:WaitForChild(value_17)
    local value_18: string = "Info"
    local info_child = value_11_10:WaitForChild(value_18)
    local value_19: string = "Processing"
    local processing_child = value_11_10:WaitForChild(value_19)
    local value_20: string = "BottomBar"
    local bottom_bar_child = large_child:WaitForChild(value_20)
    local value_21: string = "BuyPopup"
    local buy_popup_child = container_child:WaitForChild(value_21)
    local value_22: string = "Container"
    local container_child_2 = buy_popup_child:WaitForChild(value_22)
    local value_23: string = "Left"
    local left_child = container_child_2:WaitForChild(value_23)
    local value_23_2: string = "ItemContainer"
    local item_container_child = left_child:WaitForChild(value_23_2)
    local value_23_3: string = "ItemFrame"
    local item_frame_child = item_container_child:WaitForChild(value_23_3)
    local value_24: string = "Right"
    local right_child = container_child_2:WaitForChild(value_24)
    local value_24_2: string = "PriceFrame"
    local price_frame_child = right_child:WaitForChild(value_24_2)
    local value_25: string = "Right"
    local right_child_2 = container_child_2:WaitForChild(value_25)
    local value_25_2: string = "Description"
    local description_child = right_child_2:WaitForChild(value_25_2)
    local value_25_3: string = "TextLabel"
    local text_label_child = description_child:WaitForChild(value_25_3)
    local value_26: string = "PurchaseCurrency"
    local purchase_currency_child = container_child:WaitForChild(value_26)
    local value_26_2: string = "Items"
    local items_child = purchase_currency_child:WaitForChild(value_26_2)
    local value_26_3: string = "ScrollingFrame"
    local value_20_4 = (items_child:WaitForChild(value_26_3))
    local value_26_4: string = "ViewContents"
    local view_contents_child = container_child:WaitForChild(value_26_4)
    local value_26_5: string = "Items"
    local items_child_2 = view_contents_child:WaitForChild(value_26_5)
    local value_26_6: string = "ScrollingFrame"
    local scrolling_frame_child_2 = items_child_2:WaitForChild(value_26_6)
    local value_27: string = "BuyFrame"
    local buy_frame_child = info_child:WaitForChild(value_27)
    local value_28: string = "Featured"
    local featured_child = container_child:WaitForChild(value_28)
    local value_28_2: string = "Items"
    local items_child_3 = featured_child:WaitForChild(value_28_2)
    local value_28_3: string = "ScrollingFrame"
    local scrolling_frame_child_3 = items_child_3:WaitForChild(value_28_3)
    local value_29: string = "LargeShopItemFrame"
    local large_shop_item_frame_child = scrolling_frame_child_3:WaitForChild(value_29)
    local value_30 = "Container"
    local container_child_3 = value_11_10:WaitForChild(value_30)
    value_30 = "Items"
    local items_child_4 = container_child_3:WaitForChild(value_30)
    value_30 = "Items"
    local items_child_5 = items_child_4:WaitForChild(value_30)
    value_30 = "ScrollingFrame"
    local scrolling_frame_child_4 = items_child_5:WaitForChild(value_30)
    local value_31: string = "LargeBoxContentItem"
    local value_11_11 = (scrolling_frame_child_2:WaitForChild(value_31))
    local table_29 = {
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
    }
    value_30 = "Featured"
    value_31 = "PurchaseCurrency"
    local value_32: string = "Weapons"
    local value_33: string? = "Effects"
    local value_34: string = "Perks"
    local value_35: string = "Emotes"
    local value_36: string = "Pets"
    table_29[1], table_29[2], table_29[3], table_29[4], table_29[5], table_29[6], table_29[7] = value_30, value_31, value_32, value_33, value_34, value_35, value_36
    value_30 = 1
    value_31 = "Featured"
    value_32 = "Featured"
    value_33 = nil
    local go_to_page: ((string) -> ())?
    do
        local captured_value, captured_value_2 = container_child, value_3_9
        go_to_page = function(argument_1: string): ()
            local value_2_5, value_3_10, value_4_12 = captured_value:GetChildren()
            for key, value in value_2_5, value_3_10, value_4_12 do
                local value_5_12, value_6_11 = key, value
                local value_9_11: string = "Frame"
                local is_a_result = value_6_11:IsA(value_9_11)
                if not is_a_result then
                    continue
                end
                local name_value = value_6_11.Name
                local value_7_9: boolean?
                if name_value ~= argument_1 then
                    value_7_9 = false
                else
                    value_7_9 = true
                end
                value_6_11.Visible = value_7_9
                local name_value_2 = value_6_11.Name
                if name_value_2 ~= argument_1 then
                    continue
                end
                local value_7_10: Instance = captured_value_2
                local value_9_12 = value_6_11
                value_7_10:Select(value_9_12)
            end
            value_32 = argument_1

            return
        end
    end
    local go_to_tab
    do
        local captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9 = title_child, go_to_page, require_result_3, scrolling_frame_child_4, value_3_9, nav_child, table_29
        go_to_tab = function(argument_1_2: string)
            local value_2_6, value_3_11, value_4_13, value_5_13
            if argument_1_2 == "PurchaseCurrency" then
                value_2_6 = captured_value_3.Title
                value_3_11 = "Get Gems"
                value_2_6.Text = value_3_11
                captured_value_4("PurchaseCurrency")
            else
                if argument_1_2 == "Featured" then
                    value_2_6 = captured_value_3.Title
                    value_3_11 = "Featured"
                    value_2_6.Text = value_3_11
                    captured_value_4("Featured")
                else
                    value_2_6 = captured_value_3.Title
                    value_2_6.Text = argument_1_2
                    value_2_6 = captured_value_5
                    value_4_13 = captured_value_6
                    value_5_13 = argument_1_2
                    value_2_6:SetVisibleItems(value_4_13, value_5_13)
                    captured_value_4("Items")
                    value_2_6 = captured_value_7
                    value_4_13 = captured_value_6
                    value_2_6:Select(value_4_13)
                end
            end
            value_2_6, value_3_11, value_4_13 = captured_value_8:GetChildren()
            for key_2, value_37 in value_2_6, value_3_11, value_4_13 do
                local value_6_12
                value_5_13, value_6_12 = key_2, value_37
                local value_9_13: string = "TextButton"
                local is_a_result_2 = value_6_12:IsA(value_9_13)
                if not is_a_result_2 then
                    continue
                end
                local name_value_3 = value_6_12.Name
                local roblox_round_default_button_value
                do
                    local take_fallback = name_value_3 ~= argument_1_2
                    if not take_fallback then
                        roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                        take_fallback = not roblox_round_default_button_value
                    end
                    if take_fallback then
                        roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                    end
                end
                value_6_12.Style = roblox_round_default_button_value
            end
            value_30 = (table.find(captured_value_9, argument_1_2))
            value_31 = argument_1_2

            return
        end
    end
    local connect_purchase_currency: (() -> ())?
    do
        local captured_value_10, captured_value_11, captured_value_12 = value_20_4, shop_child, info_child
        connect_purchase_currency = function(): ()
            local value_1, value_2_7, value_3_12 = captured_value_10:GetChildren()
            for key_3, value_38 in value_1, value_2_7, value_3_12 do
                local value_4_14, value_5_14 = key_3, value_38
                local value_8_10: string = "Frame"
                local is_a_result_3 = value_5_14:IsA(value_8_10)
                if not is_a_result_3 then
                    continue
                end
                local container_value = value_5_14.Container
                local action_button_value = container_value.ActionButton
                local activated_value = action_button_value.Activated
                local value_8_11: (() -> ())?
                do
                    local captured_value_13, captured_value_14, closure_ready
                    value_8_11 = function(): ()
                        if not closure_ready then
                            return
                        end
                        local purchase_product_value = captured_value_13.PurchaseProduct
                        local name_value_4 = captured_value_14.Name
                        local value_4_15: string = "Gems"
                        purchase_product_value:FireServer(name_value_4, value_4_15)

                        return
                    end
                    captured_value_13, captured_value_14 = captured_value_11, value_5_14
                    closure_ready = true
                end
                activated_value:Connect(value_8_11)
                local container_value_2 = value_5_14.Container
                local action_button_value_2 = container_value_2.ActionButton
                local selection_gained_value = action_button_value_2.SelectionGained
                local value_8_12: (() -> ())?
                do
                    local captured_value_15, captured_value_16, closure_ready_2
                    value_8_12 = function(): ()
                        if not closure_ready_2 then
                            return
                        end
                        local icon_value = captured_value_15.ItemContainer.ItemFrame.Container.Icon
                        local image_value = captured_value_16.Container.Icon.Image
                        icon_value.Image = image_value
                        local text_label_value = captured_value_15.ItemContainer.ItemFrame.ItemName.TextLabel
                        local text_value = captured_value_16.ItemName.TextLabel.Text
                        text_label_value.Text = text_value
                        local item_name_value_3 = captured_value_15.ItemContainer.ItemFrame.ItemName
                        local background_color3_value = captured_value_16.ItemName.BackgroundColor3
                        item_name_value_3.BackgroundColor3 = background_color3_value

                        return
                    end
                    captured_value_15, captured_value_16 = captured_value_12, value_5_14
                    closure_ready_2 = true
                end
                selection_gained_value:Connect(value_8_12)
            end

            return
        end
    end
    do
        local captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21, captured_value_22 = require_result_3, info_child, scrolling_frame_child_2, buy_frame_child, go_to_page, value_3_9

        local function view_box_contents(argument_1_3: string, argument_2: string): ()
            local value_3_14 = captured_value_17
            local item_frame_value_4 = captured_value_18.ItemContainer.ItemFrame
            local value_6_16 = captured_value_19
            local value_7_16 = captured_value_20
            local value_8_13: string = argument_1_3
            local value_9_14: string = argument_2
            value_3_14:ViewBoxContents(
                item_frame_value_4,
                value_6_16,
                value_7_16,
                value_8_13,
                value_9_14
            )
            local buy_frame_value = captured_value_18.BuyFrame
            local value_4_17: boolean = true
            buy_frame_value.Visible = value_4_17
            captured_value_21("ViewContents")
            local value_3_18: Instance = captured_value_22
            local buy_frame_value_2 = captured_value_18.BuyFrame
            value_3_18:Select(buy_frame_value_2)
            value_33 = argument_1_3

            return
        end
    end
    do
        local captured_value_23, captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28 = require_result_3, item_frame_child, text_label_child, price_frame_child, buy_popup_child, value_3_9

        local function view_buy_popup(argument_1_4: string, argument_2_2: string): ()
            local value_3_20 = captured_value_23
            local value_5_17 = captured_value_24
            local value_6_17 = captured_value_25
            local value_7_17 = captured_value_26
            local value_8_14: string = argument_1_4
            local value_9_15: string = argument_2_2
            value_3_20:ViewBuyPopup(value_5_17, value_6_17, value_7_17, value_8_14, value_9_15)
            local value_3_22 = captured_value_27
            local value_4_21: boolean = true
            value_3_22.Visible = value_4_21
            local value_3_23: Instance = captured_value_28
            local value_5_18 = captured_value_26
            value_3_23:Select(value_5_18)
            value_33 = argument_1_4

            return
        end
    end
    local on_item_selected: ((string, string) -> ())?
    do
        local captured_value_29, captured_value_30 = require_result_3, info_child
        on_item_selected = function(argument_1_5: string, argument_2_3: string): ()
            local value_3_25 = captured_value_29
            local item_frame_value_5 = captured_value_30.ItemContainer.ItemFrame
            local value_6_18: string = argument_1_5
            local value_7_18: string = argument_2_3
            value_3_25:DisplayItem(item_frame_value_5, value_6_18, value_7_18)
            local buy_frame_value_3 = captured_value_30.BuyFrame
            local value_4_24: boolean = false
            buy_frame_value_3.Visible = value_4_24

            return
        end
    end
    local on_item_clicked: ((string, string) -> ())?
    do
        local captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43 = value_9_10, require_result, console_child, require_result_3, info_child, scrolling_frame_child_2, buy_frame_child, go_to_page, value_3_9, item_frame_child, text_label_child, price_frame_child, buy_popup_child
        on_item_clicked = function(argument_1_6: string, argument_2_4: string): ()
            if argument_2_4 == "Event" then
                local value_3_28 = captured_value_31
                local value_4_25: boolean = false
                value_3_28.Enabled = value_4_25
                local value_3_29 = captured_value_32
                local value_5_20: string = "CurrentEvent"
                value_3_29:ViewFrame(value_5_20)
                local event_value = captured_value_33.Event
                local value_4_27: boolean = true
                event_value.Enabled = value_4_27

                return
            end
            do
                local take_fallback_2 = argument_2_4 == "MysteryBox"
                if take_fallback_2 or argument_2_4 == "Eggs" then
                    local value_3_32 = captured_value_34
                    local item_frame_value_6 = captured_value_35.ItemContainer.ItemFrame
                    local value_6_19 = captured_value_36
                    local value_7_19 = captured_value_37
                    local value_8_15: string = argument_1_6
                    local value_9_16: string = argument_2_4
                    value_3_32:ViewBoxContents(
                        item_frame_value_6,
                        value_6_19,
                        value_7_19,
                        value_8_15,
                        value_9_16
                    )
                    local buy_frame_value_4 = captured_value_35.BuyFrame
                    local value_4_29: boolean = true
                    buy_frame_value_4.Visible = value_4_29
                    captured_value_38("ViewContents")
                    local value_3_36: Instance = captured_value_39
                    local buy_frame_value_5 = captured_value_35.BuyFrame
                    value_3_36:Select(buy_frame_value_5)
                    value_33 = argument_1_6

                    return
                end
            end
            local value_3_38 = captured_value_34
            local value_5_23 = captured_value_40
            local value_6_20 = captured_value_41
            local value_7_20 = captured_value_42
            local value_8_16: string = argument_1_6
            local value_9_17: string = argument_2_4
            value_3_38:ViewBuyPopup(value_5_23, value_6_20, value_7_20, value_8_16, value_9_17)
            local value_3_40 = captured_value_43
            local value_4_33: boolean = true
            value_3_40.Visible = value_4_33
            local value_3_41: Instance = captured_value_39
            local value_5_24 = captured_value_42
            value_3_41:Select(value_5_24)
            value_33 = argument_1_6

            return
        end
    end
    do
        local captured_value_44, captured_value_45, captured_value_46 = value_9_10, large_child, value_3_9

        local function close_shop(): ()
            local value_1_7 = captured_value_44
            local value_2_12: boolean = false
            value_1_7.Enabled = value_2_12
            local value_1_8 = captured_value_45
            local value_2_13: boolean = false
            value_1_8.Visible = value_2_13
            local value_1_9: Instance = captured_value_46
            local value_2_14: nil = nil
            value_1_9.SelectedObject = value_2_14

            return
        end
    end
    do
        local captured_value_47, captured_value_48 = table_29, go_to_tab

        local function navigate_shop(argument_1_7: number)
            value_30 = value_30 + argument_1_7
            local value_2_17 = value_30
            if #captured_value_47 < value_2_17 then
                value_30 = 1
            end
            if value_30 <= 0 then
                value_30 = #captured_value_47
            end
            captured_value_48(captured_value_47[value_30])

            return
        end
    end
    local on_shop_opened
    do
        local captured_value_49 = go_to_tab
        on_shop_opened = function()
            captured_value_49("Featured")

            return
        end
    end
    local on_item_purchase_requested: ((string, string) -> ())?
    do
        local captured_value_50, captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57 = new_shop_value, processing_child, require_result_3, value_9_10, large_child, value_3_9, shop_child, buy_popup_child
        on_item_purchase_requested = function(argument_1_8: string, argument_2_5: string): ()
            local buy_item_new_value, egg_controller_value, invoke_server_result, invoke_server_result_2, open_crate_value, request_unbox_result, type_value, value_3_47, value_3_48, value_3_49, value_4_37, value_5_26, value_5_27, value_5_28, value_5_30, value_5_31, value_5_32, value_5_33, value_5_35, value_5_36, value_5_37, value_6_21, value_6_23, value_6_24, value_6_25: nil, value_6_27, value_6_28, value_6_29, value_6_30, value_6_32, value_6_33, value_6_35, value_6_36, value_6_37, value_6_38, value_7_21, value_7_22, value_7_23, value_7_24, value_7_25: nil, value_7_27, value_7_28, value_7_29, value_7_30, value_7_31, value_8_17, value_8_18, value_8_19, value_8_20, value_9_18, value_9_19, value_9_20, visible_value
            local control_state = 0
            while true do
                if control_state < 8 then
                    if control_state < 4 then
                        if control_state < 2 then
                            if control_state < 1 then
                                value_4_37 = captured_value_50
                                value_3_47 = value_4_37[argument_1_8]
                                type_value = value_3_47.Type
                                value_5_26 = captured_value_51
                                visible_value = value_5_26.Visible
                                control_state = if visible_value == true then 2 else 1
                            else
                                value_3_48 = false
                                control_state = 3
                            end
                        else
                            if control_state < 3 then
                                value_3_48 = true
                                control_state = 3
                            else
                                control_state = if not value_3_48 then 5 else 4
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
                                value_5_27 = captured_value_51
                                value_6_21 = true
                                value_5_27.Visible = value_6_21
                                control_state = if type_value ~= "MysteryBox" then 10 else 8
                            end
                        end
                    end
                else
                    if control_state < 12 then
                        if control_state < 10 then
                            if control_state < 9 then
                                value_5_28 = captured_value_52
                                value_7_21 = argument_1_8
                                value_8_17 = argument_2_5
                                value_9_18 = 1
                                request_unbox_result = value_5_28:RequestUnbox(
                                    value_7_21,
                                    value_8_17,
                                    value_9_18
                                )
                                value_3_49 = request_unbox_result
                                control_state = if not value_3_49 then 13 else 9
                            else
                                value_5_30 = captured_value_53
                                value_6_23 = false
                                value_5_30.Enabled = value_6_23
                                value_5_31 = captured_value_54
                                value_6_24 = false
                                value_5_31.Visible = value_6_24
                                value_5_32 = captured_value_55
                                value_6_25 = nil
                                value_5_32.SelectedObject = value_6_25
                                control_state = 13
                            end
                        else
                            if control_state < 11 then
                                control_state = if type_value ~= "Eggs" then 13 else 11
                            else
                                value_5_33 = captured_value_56
                                open_crate_value = value_5_33.OpenCrate
                                value_7_22 = argument_1_8
                                value_8_18 = type_value
                                value_9_19 = argument_2_5
                                invoke_server_result = open_crate_value:InvokeServer(
                                    value_7_22,
                                    value_8_18,
                                    value_9_19
                                )
                                control_state = if not invoke_server_result then 13 else 12
                            end
                        end
                    else
                        if control_state < 14 then
                            if control_state < 13 then
                                value_6_27 = captured_value_53
                                value_7_23 = false
                                value_6_27.Enabled = value_7_23
                                value_6_28 = captured_value_54
                                value_7_24 = false
                                value_6_28.Visible = value_7_24
                                value_6_29 = captured_value_55
                                value_7_25 = nil
                                value_6_29.SelectedObject = value_7_25
                                value_6_30 = captured_value_56
                                egg_controller_value = value_6_30.EggController
                                value_8_19 = argument_1_8
                                value_9_20 = invoke_server_result
                                egg_controller_value:Fire(value_8_19, value_9_20)
                                control_state = 13
                            else
                                value_5_35 = captured_value_51
                                value_6_32 = false
                                value_5_35.Visible = value_6_32

                                return
                            end
                        else
                            if control_state < 15 then
                                value_5_36 = captured_value_51
                                value_6_33 = true
                                value_5_36.Visible = value_6_33
                                value_5_37 = captured_value_56
                                buy_item_new_value = value_5_37.BuyItemNew
                                value_7_27 = argument_1_8
                                value_8_20 = argument_2_5
                                invoke_server_result_2 = buy_item_new_value:InvokeServer(
                                    value_7_27,
                                    value_8_20
                                )
                                value_6_35 = captured_value_51
                                value_7_28 = false
                                value_6_35.Visible = value_7_28
                                control_state = if not invoke_server_result_2 then 16 else 15
                            else
                                if control_state < 16 then
                                    value_6_36 = captured_value_57
                                    value_7_29 = false
                                    value_6_36.Visible = value_7_29
                                    value_6_37 = captured_value_54
                                    value_7_30 = false
                                    value_6_37.Visible = value_7_30
                                    value_6_38 = captured_value_53
                                    value_7_31 = false
                                    value_6_38.Enabled = value_7_31
                                    control_state = 16
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
    do
        local captured_value_58, captured_value_59 = container_child, value_3_9

        local function select_last_viewed_item(): ()
            local value_1_11 = captured_value_58
            local value_3_50: string = value_32
            local find_first_child_result = value_1_11:FindFirstChild(value_3_50)
            local value_2_24: Instance = captured_value_59
            local scrolling_frame_value = find_first_child_result.Items.ScrollingFrame
            local value_6_39: string? = value_33
            ;(function(...)
                return value_2_24:Select(...)
            end)(scrolling_frame_value:FindFirstChild(value_6_39))

            return
        end
    end
    local on_shop_back_pressed
    do
        local captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64, captured_value_65 = go_to_tab, container_child, value_3_9, buy_popup_child, value_9_10, large_child
        on_shop_back_pressed = function()
            if value_32 == "ViewContents" then
                captured_value_60(value_31)
                local value_1_15 = captured_value_61
                local value_3_52: string = value_32
                local find_first_child_result_2 = value_1_15:FindFirstChild(value_3_52)
                local value_2_28: Instance = captured_value_62
                local scrolling_frame_value_2 = find_first_child_result_2.Items.ScrollingFrame
                local value_6_40: string? = value_33
                ;(function(...)
                    return value_2_28:Select(...)
                end)(scrolling_frame_value_2:FindFirstChild(value_6_40))

                return
            end
            if captured_value_63.Visible then
                local value_1_18 = captured_value_63
                local value_2_30: boolean = false
                value_1_18.Visible = value_2_30
                local value_1_19 = captured_value_61
                local value_3_54: string = value_32
                local find_first_child_result_3 = value_1_19:FindFirstChild(value_3_54)
                local value_2_32: Instance = captured_value_62
                local scrolling_frame_value_3 = find_first_child_result_3.Items.ScrollingFrame
                local value_6_41: string? = value_33
                ;(function(...)
                    return value_2_32:Select(...)
                end)(scrolling_frame_value_3:FindFirstChild(value_6_41))

                return
            end
            local value_1_21 = captured_value_64
            local value_2_34: boolean = false
            value_1_21.Enabled = value_2_34
            local value_1_22 = captured_value_65
            local value_2_35: boolean = false
            value_1_22.Visible = value_2_35
            local value_1_23: Instance = captured_value_62
            local value_2_36: nil = nil
            value_1_23.SelectedObject = value_2_36

            return
        end
    end
    local on_currency_updated: (() -> ())?
    do
        local captured_value_66, captured_value_67, captured_value_68 = require_result_5, bottom_bar_child, require_result_3
        on_currency_updated = function(): ()
            local value_1_24 = captured_value_66.Materials.Owned.Coins or 0
            local value_2_38 = captured_value_66.Materials.Owned.Gems or 0
            local value_3_57 = captured_value_67
            local value_5_42: string = "Gems"
            local gems_child = value_3_57:WaitForChild(value_5_42)
            local value_5_43: string = "Amount"
            local amount_child = gems_child:WaitForChild(value_5_43)
            local comma_value_result = captured_value_68.CommaValue(value_2_38)
            amount_child.Text = comma_value_result
            local value_3_60 = captured_value_67
            local value_5_45: string = "Coins"
            local coins_child = value_3_60:WaitForChild(value_5_45)
            local value_5_46: string = "Amount"
            local amount_child_2 = coins_child:WaitForChild(value_5_46)
            local comma_value_result_2 = captured_value_68.CommaValue(value_1_24)
            amount_child_2.Text = comma_value_result_2

            return
        end
    end
    local on_initialize
    do
        local captured_value_69, captured_value_70, captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80, captured_value_81, captured_value_82, captured_value_83, captured_value_84, captured_value_85, captured_value_86, captured_value_87, captured_value_88, captured_value_89, captured_value_90 = require_result_3, large_shop_item_frame_child, value_11_11, price_frame_child, scrolling_frame_child_3, scrolling_frame_child_4, value_9_10, on_shop_back_pressed, table_29, go_to_tab, console_child, require_result, value_3_9, connect_purchase_currency, on_currency_updated, inventory_child, on_item_purchase_requested, on_item_selected, on_item_clicked, large_child, on_shop_opened, require_result_7
        on_initialize = function()
            local value_1_25 = captured_value_69
            local value_2_39 = captured_value_70
            value_1_25.ShopItemFrame = value_2_39
            local value_1_26 = captured_value_69
            local value_2_40 = captured_value_70
            value_1_26.FeaturedItemFrame = value_2_40
            local value_1_27 = captured_value_69
            local value_2_41 = captured_value_71
            value_1_27.BoxContentItemFrame = value_2_41
            local value_1_28 = captured_value_69
            local value_2_42 = captured_value_70
            local value_4_47: string = "Container"
            local container_child_4 = value_2_42:WaitForChild(value_4_47)
            local value_4_48: string = "Prices"
            local prices_child = container_child_4:WaitForChild(value_4_48)
            local value_4_49: string = "LargeCurrencyFrame"
            local large_currency_frame_child = prices_child:WaitForChild(value_4_49)
            value_1_28.ShopItemCurrencyFrame = large_currency_frame_child
            local shop_item_currency_frame_value = captured_value_69.ShopItemCurrencyFrame
            local script_value_3: LuaSourceContainer = script
            shop_item_currency_frame_value.Parent = script_value_3
            local value_1_30 = captured_value_69
            local value_2_46 = captured_value_72
            local value_4_50: string = "Gems"
            local gems_child_2 = value_2_46:WaitForChild(value_4_50)
            value_1_30.CurrencyPriceFrame = gems_child_2
            local currency_price_frame_value = captured_value_69.CurrencyPriceFrame
            local script_value_4: LuaSourceContainer = script
            currency_price_frame_value.Parent = script_value_4
            local value_1_32 = captured_value_70
            local value_3_67: string = "Container"
            local container_child_5 = value_1_32:WaitForChild(value_3_67)
            local value_3_68: string = "Prices"
            local prices_child_2 = container_child_5:WaitForChild(value_3_68)
            local value_3_69: string = "Gems"
            prices_child_2:WaitForChild(value_3_69):Destroy()
            local value_1_37 = captured_value_70
            local script_value_5: LuaSourceContainer = script
            value_1_37.Parent = script_value_5
            local value_1_38 = captured_value_71
            local script_value_6: LuaSourceContainer = script
            value_1_38.Parent = script_value_6
            local value_1_39 = captured_value_69
            local value_3_70 = captured_value_73
            local console_value = captured_value_69.FeaturedItems.Console
            value_1_39:GenerateFeaturedItems(value_3_70, console_value)
            local value_1_41 = captured_value_69
            local value_3_71 = captured_value_74
            value_1_41:GenerateShopItems(value_3_71)
            local value_1_43 = captured_value_75
            local value_3_72: string = "Back"
            local pressed_value = value_1_43:WaitForChild(value_3_72).Pressed
            local value_3_73 = captured_value_76
            pressed_value:Connect(value_3_73)
            local value_1_46 = captured_value_75
            local value_3_74: string = "NavigateLeft"
            local pressed_value_2 = value_1_46:WaitForChild(value_3_74).Pressed
            local value_3_75
            do
                local captured_value_91, captured_value_92, closure_ready_3
                value_3_75 = function()
                    if not closure_ready_3 then
                        return
                    end
                    value_30 = value_30 + -1
                    local value_1_76 = value_30
                    if #captured_value_91 < value_1_76 then
                        value_30 = 1
                    end
                    if value_30 <= 0 then
                        value_30 = #captured_value_91
                    end
                    captured_value_92(captured_value_91[value_30])

                    return
                end
                captured_value_91, captured_value_92 = captured_value_77, captured_value_78
                closure_ready_3 = true
            end
            pressed_value_2:Connect(value_3_75)
            local value_1_49 = captured_value_75
            local value_3_76: string = "NavigateRight"
            local pressed_value_3 = value_1_49:WaitForChild(value_3_76).Pressed
            local value_3_77
            do
                local captured_value_93, captured_value_94, closure_ready_4
                value_3_77 = function()
                    if not closure_ready_4 then
                        return
                    end
                    value_30 = value_30 + 1
                    local value_1_83 = value_30
                    if #captured_value_93 < value_1_83 then
                        value_30 = 1
                    end
                    if value_30 <= 0 then
                        value_30 = #captured_value_93
                    end
                    captured_value_94(captured_value_93[value_30])

                    return
                end
                captured_value_93, captured_value_94 = captured_value_77, captured_value_78
                closure_ready_4 = true
            end
            pressed_value_3:Connect(value_3_77)
            local value_1_52 = captured_value_79
            local value_3_78: string = "Event"
            local event_child = value_1_52:WaitForChild(value_3_78)
            local value_3_79: string = "Back"
            local pressed_value_4 = event_child:WaitForChild(value_3_79).Pressed
            local value_3_80
            do
                local captured_value_95, captured_value_96, captured_value_97 = captured_value_80, captured_value_79, captured_value_81
                if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_95) and same_capture(
                    closure_cache[3],
                    captured_value_96
                ) and same_capture(closure_cache[4], captured_value_97) then
                    value_3_80 = closure_cache[1]
                else
                    local closure_ready_5
                    value_3_80 = function(): ()
                        if not closure_ready_5 then
                            return
                        end
                        captured_value_95:Back()
                        local event_value_7 = captured_value_96.Event
                        local value_2_81: boolean = false
                        event_value_7.Enabled = value_2_81
                        local value_1_91: Instance = captured_value_97
                        local value_2_82: nil = nil
                        value_1_91.SelectedObject = value_2_82

                        return
                    end
                    closure_ready_5 = true
                    if closure_cache[1] == nil then
                        closure_cache[1] = value_3_80
                        closure_cache[2], closure_cache[3], closure_cache[4] = captured_value_95, captured_value_96, captured_value_97
                    end
                end
            end
            pressed_value_4:Connect(value_3_80)
            captured_value_82()
            captured_value_83()
            local event_value_2 = captured_value_84.InventoryDataChanged.Event
            local value_3_81
            do
                local captured_value_98 = captured_value_83
                if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_98) then
                    value_3_81 = closure_cache[5]
                else
                    local closure_ready_6
                    value_3_81 = function<T1, T3>(argument_1_9: T1, argument_2_6, argument_3: T3): ()
                        if not closure_ready_6 then
                            return
                        end
                        do
                            local take_fallback_3 = argument_2_6 == "Gems"
                            if take_fallback_3 or argument_2_6 == "Coins" then
                                captured_value_98()
                            end
                        end

                        return
                    end
                    closure_ready_6 = true
                    if closure_cache[5] == nil then
                        closure_cache[5] = value_3_81
                        closure_cache[6] = captured_value_98
                    end
                end
            end
            event_value_2:Connect(value_3_81)
            local event_value_3 = captured_value_69.PurchaseGemsRequested.Event
            local value_3_82
            do
                local captured_value_99 = captured_value_78
                if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_99) then
                    value_3_82 = closure_cache[7]
                else
                    local closure_ready_7
                    value_3_82 = function()
                        if not closure_ready_7 then
                            return
                        end
                        captured_value_99("PurchaseCurrency")

                        return
                    end
                    closure_ready_7 = true
                    if closure_cache[7] == nil then
                        closure_cache[7] = value_3_82
                        closure_cache[8] = captured_value_99
                    end
                end
            end
            event_value_3:Connect(value_3_82)
            local event_value_4 = captured_value_69.ItemPurchaseRequested.Event
            local value_3_83: (string, string) -> () = captured_value_85
            event_value_4:Connect(value_3_83)
            local event_value_5 = captured_value_69.ItemSelectionGained.Event
            local value_3_84: (string, string) -> () = captured_value_86
            event_value_5:Connect(value_3_84)
            local event_value_6 = captured_value_69.ItemClicked.Event
            local value_3_85: (string, string) -> () = captured_value_87
            event_value_6:Connect(value_3_85)
            local value_1_68 = captured_value_80
            local value_3_86 = captured_value_88
            local value_4_52: string = "Shop"
            local value_5_48 = captured_value_89
            value_1_68:RegisterFrame(value_3_86, value_4_52, value_5_48)
            local value_1_70 = captured_value_88
            local value_2_69: boolean = false
            value_1_70.Visible = value_2_69
            captured_value_78("Featured")
            local value_1_72 = captured_value_90
            local value_3_87
            do
                local captured_value_100, captured_value_101, captured_value_102 = captured_value_69, captured_value_73, captured_value_74
                if closure_cache[9] ~= nil and same_capture(
                    closure_cache[10],
                    captured_value_100
                ) and same_capture(closure_cache[11], captured_value_101) and same_capture(
                    closure_cache[12],
                    captured_value_102
                ) then
                    value_3_87 = closure_cache[9]
                else
                    local closure_ready_8
                    value_3_87 = function(argument_1_10): ()
                        if not closure_ready_8 then
                            return
                        end
                        if argument_1_10.EventStartInfo.FeaturedItems then
                            local value_2_84 = captured_value_100
                            local value_4_56 = captured_value_101
                            local console_value_2 = argument_1_10.EventStartInfo.FeaturedItems.Console
                            value_2_84:GenerateFeaturedItems(value_4_56, console_value_2)
                        end
                        if argument_1_10.EventStartInfo.ShopData then
                            local value_2_86 = captured_value_100
                            local value_4_57 = captured_value_102
                            value_2_86:GenerateShopItems(value_4_57)
                        end

                        return
                    end
                    closure_ready_8 = true
                    if closure_cache[9] == nil then
                        closure_cache[9] = value_3_87
                        closure_cache[10], closure_cache[11], closure_cache[12] = captured_value_100, captured_value_101, captured_value_102
                    end
                end
            end
            value_1_72:OnEventStarted(value_3_87)

            return
        end
    end
    on_initialize()
end

return
