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

local parent_value_2 = script.Parent.Parent
local value_4: string = "MainEvent"
local main_event_child = parent_value_2:WaitForChild(value_4)
local value_4_2: string = "Main"
local main_child = main_event_child:WaitForChild(value_4_2)
local value_5: string = "ShopBundles"
local shop_bundles_child = main_child:WaitForChild(value_5)
local value_6: string = "Main"
local main_child_2 = shop_bundles_child:WaitForChild(value_6)
local value_6_2: string = "Items"
local items_child = main_child_2:WaitForChild(value_6_2)
local value_6_3: string = "ScrollingFrame"
local value_2_3 = (items_child:WaitForChild(value_6_3))
local require_value = require
local game_value: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_6_4)
local value_6_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_5)
local value_6_6: string = "ProfileData"
local require_result = require_value(modules_child:WaitForChild(value_6_6))
local require_value_2 = require
local parent_value_3: Instance? = script.Parent
local value_7: string = "NavigationService"
local require_result_2 = require_value_2(parent_value_3:WaitForChild(value_7))
local require_value_3 = require
local game_value_2: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_8)
local value_8_2: string = "Database"
local database_child: Instance? = replicated_storage_service_2:WaitForChild(value_8_2)
local value_8_3: string = "Sync"
local require_result_3 = require_value_3(database_child:WaitForChild(value_8_3))
local require_value_4 = require
local game_value_3: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_9)
local value_9_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_9_2)
local value_9_3: string = "ItemService"
local require_result_4 = require_value_4(client_services_child:WaitForChild(value_9_3))
local game_value_4: DataModel = game
local value_9_4: string = "TweenService"
local tween_service: Instance = game_value_4:GetService(value_9_4)
local game_value_5: DataModel = game
local value_10: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_5:GetService(value_10)
local value_10_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_4:WaitForChild(value_10_2)
local value_11: string = "Shop"
local shop_child = remotes_child:WaitForChild(value_11)
local value_12: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_12)
local value_8_10: TweenInfo = (TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
local new_result_2: TweenInfo = TweenInfo.new(
    0.15,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)
local require_value_5 = require
local game_value_6: DataModel = game
local value_15 = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_6:GetService(value_15)
value_15 = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_5:WaitForChild(value_15)
value_15 = "EventInfoService"
local get_main_event_result = require_value_5(shared_services_child:WaitForChild(value_15)):WaitForInitializedAsync():GetMainEvent()
local table_12 = {
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_14_5: string = "CurrencyBundle"
value_15 = "CurrencyPack"
local value_16 = "ItemBundle"
local value_17 = "CurrencyPurchase"
local value_18 = "Divider"
table_12[1], table_12[2], table_12[3], table_12[4], table_12[5] = value_14_5, value_15, value_16, value_17, value_18
local table_14 = {}
value_15 = table_12
value_16 = nil
value_17 = nil
local value_19
for key, value in value_15, value_16, value_17 do
    value_18, value_19 = key, value
    local value_22 = value_19
    local wait_for_child_result = value_2_3:WaitForChild(value_22)
    local value_21_2: nil = nil
    wait_for_child_result.Parent = value_21_2
    table_14[value_19] = wait_for_child_result
end
local scroll_to_item
do
    local captured_value, captured_value_2, captured_value_3 = value_2_3, tween_service, new_result_2
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) and same_capture(
        closure_cache[3],
        captured_value_2
    ) and same_capture(closure_cache[4], captured_value_3) then
        scroll_to_item = closure_cache[1]
    else
        local closure_ready
        scroll_to_item = function(argument_1: string): ()
            if not closure_ready then
                return
            end
            local value_2_4 = captured_value
            local value_4_10: string = argument_1
            local value_2_6 = value_2_4:FindFirstChild(value_4_10)
            if not value_2_6 then
                warn("Target item not found:", argument_1)

                return
            end
            local absolute_position_value = value_2_6.AbsolutePosition
            local absolute_position_value_2 = captured_value.AbsolutePosition
            local value_4_12 = absolute_position_value.X - absolute_position_value_2.X + captured_value.CanvasPosition.X
            local value_5_11 = absolute_position_value.Y - absolute_position_value_2.Y + captured_value.CanvasPosition.Y
            local value_6_13: Vector2? = nil
            if captured_value.ScrollingDirection == Enum.ScrollingDirection.X then
                value_6_13 = (Vector2.new(value_4_12, captured_value.CanvasPosition.Y))
            else
                if captured_value.ScrollingDirection == Enum.ScrollingDirection.Y then
                    value_6_13 = (Vector2.new(captured_value.CanvasPosition.X, value_5_11))
                else
                    if captured_value.ScrollingDirection == Enum.ScrollingDirection.XY then
                        value_6_13 = (Vector2.new(value_4_12, value_5_11))
                    end
                end
            end
            local value_7_13: Instance = captured_value_2
            local value_9_11 = captured_value
            local value_10_5: TweenInfo = captured_value_3
            local table_11 = {CanvasPosition = value_6_13}
            value_7_13:Create(value_9_11, value_10_5, table_11):Play()

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = scroll_to_item
            closure_cache[2], closure_cache[3], closure_cache[4] = captured_value, captured_value_2, captured_value_3
        end
    end
end
do
    local captured_value_4 = require_result_4
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_4) then
        value_15 = closure_cache[5]
    else
        local closure_ready_2
        value_15 = function(argument_1_2)
            if not closure_ready_2 then
                return
            end
            local value_2_8 = captured_value_4
            local item_id_value = argument_1_2.ItemID
            local item_type_value = argument_1_2.ItemType

            return value_2_8:GetDisplayInfo(item_id_value, item_type_value).Image
        end
        closure_ready_2 = true
        if closure_cache[5] == nil then
            closure_cache[5] = value_15
            closure_cache[6] = captured_value_4
        end
    end
end
value_16 = function(argument_1_3, argument_2): ()
    if not argument_2.Color then
        return
    end
    local value_5_12: string = "Background"
    local background_child = argument_1_3:FindFirstChild(value_5_12)
    local value_4_14 = background_child or argument_1_3.Container
    local color_value_2 = argument_2.Color
    value_4_14.BackgroundColor3 = color_value_2
    local container_value = argument_1_3.Container
    local value_6_14: string = "UIStroke"
    local find_first_child_of_class_result = container_value:FindFirstChildOfClass(value_6_14)
    if not find_first_child_of_class_result then
        find_first_child_of_class_result = background_child
        if find_first_child_of_class_result then
            local value_6_15: string = "UIStroke"
            find_first_child_of_class_result = background_child:FindFirstChildOfClass(value_6_15)
        end
    end
    if find_first_child_of_class_result then
        local stroke_color_value = argument_2.StrokeColor
        if not stroke_color_value then
            local color_value_3 = argument_2.Color
            local new_result_6: Color3 = Color3.new(0, 0, 0)
            local value_8_17: number = 0.41
            stroke_color_value = color_value_3:Lerp(new_result_6, value_8_17)
        end
        find_first_child_of_class_result.Color = stroke_color_value
    end

    return
end
value_17 = function(argument_1_4, argument_2_2): ()
    local value_5_16: string = "Background"
    local background_child_2 = argument_1_4:FindFirstChild(value_5_16)
    if not background_child_2 then
        return
    end
    local value_6_17: string = "Starburst"
    local starburst_child = background_child_2:FindFirstChild(value_6_17)
    if starburst_child then
        local value_5_18: boolean?
        if argument_2_2.Highlight ~= true then
            value_5_18 = false
        else
            value_5_18 = true
        end
        starburst_child.Visible = value_5_18
    end
    local value_6_18: string = "Pattern"
    local pattern_child = background_child_2:FindFirstChild(value_6_18)
    if pattern_child then
        local value_5_20 = argument_2_2.Pattern or ""
        pattern_child.Image = value_5_20
        local value_5_21: boolean?
        if argument_2_2.Pattern == nil then
            value_5_21 = false
        else
            value_5_21 = true
        end
        pattern_child.Visible = value_5_21
    end

    return
end
value_18 = function(argument_1_5, argument_2_3, argument_3): ()
    local icon_value = argument_1_5.Container.Icon
    local value_6_19: string = "Tags"
    local tags_child = icon_value:FindFirstChild(value_6_19)
    if not tags_child then
        return
    end
    local one_time_value = tags_child.OneTime
    local value_6_20: boolean?
    if argument_2_3.OneTimePurchase ~= true then
        value_6_20 = false
    else
        value_6_20 = true
    end
    one_time_value.Visible = value_6_20
    local value_value = tags_child.Value
    local value_6_21: boolean?
    if argument_3.Tag == nil then
        value_6_21 = false
    else
        value_6_21 = true
    end
    value_value.Visible = value_6_21
    if argument_3.Tag then
        local text_label_value = tags_child.Value.TextLabel
        local tag_value_3 = argument_3.Tag
        text_label_value.Text = tag_value_3
    end

    return
end
do
    local captured_value_5 = require_result_4
    if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_5) then
        value_19 = closure_cache[7]
    else
        local closure_ready_3
        value_19 = function(argument_1_6, argument_2_4, argument_3_2, argument_4): ()
            if not closure_ready_3 then
                return
            end
            local icon_value_2 = argument_1_6.Container.Icon
            local value_7_16: string = "Items"
            local items_child_2 = icon_value_2:FindFirstChild(value_7_16)
            if not items_child_2 then
                return
            end
            local reward_items_value = argument_3_2.RewardItems or ({})
            local notes_value = argument_4.Notes or ({})
            local value_8_18 = reward_items_value
            local value_9_13 = nil
            local value_10_7 = nil
            local value_11_3, value_12_5
            for key_2, value_23 in value_8_18, value_9_13, value_10_7 do
                value_11_3, value_12_5 = key_2, value_23
                local value_16_2: string = "Reward"
                local value_17_2 = value_11_3
                local value_15_2 = value_16_2 .. value_17_2
                local find_first_child_result = items_child_2:FindFirstChild(value_15_2)
                if not find_first_child_result then
                    local warn_value_2 = warn
                    local value_15_3: string = "[EventShopService] %*: %* has no Reward%* slot for %*"
                    local value_17_3 = argument_2_4
                    local shape_value = argument_4.Shape
                    local value_19_2 = value_11_3
                    local item_id_value_2 = value_12_5.ItemID
                    local format_result = value_15_3:format(
                        value_17_3,
                        shape_value,
                        value_19_2,
                        item_id_value_2
                    )
                    warn_value_2(format_result)
                else
                    local value_14_7 = captured_value_5
                    local item_id_value_3 = value_12_5.ItemID
                    local item_type_value_2 = value_12_5.ItemType
                    local get_display_info_result_2 = value_14_7:GetDisplayInfo(
                        item_id_value_3,
                        item_type_value_2
                    )
                    local image_value_2 = get_display_info_result_2.Image
                    find_first_child_result.Image = image_value_2
                    local amount_value = find_first_child_result.Amount
                    local value_16_4: string = "x"
                    local value_17_4 = captured_value_5
                    local amount_value_2 = value_12_5.Amount
                    local comma_number_result = value_17_4:CommaNumber(amount_value_2)
                    local value_15_6 = value_16_4 .. comma_number_result
                    amount_value.Text = value_15_6
                    local value_16_5: string = "Note"
                    local note_child = find_first_child_result:FindFirstChild(value_16_5)
                    if not note_child then
                        continue
                    end
                    local item_id_value_4 = value_12_5.ItemID
                    local value_16_6 = notes_value[item_id_value_4]
                    local value_15_8 = value_16_6 or ""
                    note_child.Text = value_15_8
                    local item_id_value_5 = value_12_5.ItemID
                    local value_16_7 = notes_value[item_id_value_5]
                    local value_15_9: boolean?
                    if value_16_7 == nil then
                        value_15_9 = false
                    else
                        value_15_9 = true
                    end
                    note_child.Visible = value_15_9
                end
            end
            value_8_18, value_9_13, value_10_7 = items_child_2:GetChildren()
            for key_3, value_24 in value_8_18, value_9_13, value_10_7 do
                value_11_3, value_12_5 = key_3, value_24
                local name_value = value_12_5.Name
                local value_16_8: string = "^Reward(%d+)$"
                local tonumber_result = (function(...)
                    local open_callee = tonumber

                    return open_callee(...)
                end)(name_value:match(value_16_8))
                local value_7_17 = tonumber_result
                if not value_7_17 then
                    continue
                end
                local value_13_7 = reward_items_value[value_7_17]
                if value_13_7 then
                    continue
                end
                local value_13_8: boolean = false
                value_12_5.Visible = value_13_8
            end

            return
        end
        closure_ready_3 = true
        if closure_cache[7] == nil then
            closure_cache[7] = value_19
            closure_cache[8] = captured_value_5
        end
    end
end
local apply_card
do
    local captured_value_6, captured_value_7, captured_value_8, captured_value_9 = require_result_4, value_16, value_17, value_19
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_6) and same_capture(
        closure_cache[11],
        captured_value_7
    ) and same_capture(closure_cache[12], captured_value_8) and same_capture(
        closure_cache[13],
        captured_value_9
    ) then
        apply_card = closure_cache[9]
    else
        local closure_ready_4
        apply_card = function(argument_1_7, argument_2_5: string, argument_3_3, argument_4_2)
            if not closure_ready_4 then
                return
            end
            local display_info_value = argument_3_3.DisplayInfo or ({})
            local reward_items_value_2 = argument_3_3.RewardItems
            if reward_items_value_2 then
                reward_items_value_2 = argument_3_3.RewardItems[1]
            end
            local icon_value_3 = argument_1_7.Container.Icon
            if argument_4_2.Shape == "CurrencyPurchase" then
                local text_label_value_2 = icon_value_3.ItemName.TextLabel
                local comma_number_result_2
                do
                    local take_fallback = not reward_items_value_2
                    if not take_fallback then
                        local value_9_14 = captured_value_6
                        local amount_value_3 = reward_items_value_2.Amount
                        comma_number_result_2 = value_9_14:CommaNumber(amount_value_3)
                        take_fallback = not comma_number_result_2
                    end
                    if take_fallback then
                        comma_number_result_2 = ""
                    end
                end
                text_label_value_2.Text = comma_number_result_2
            else
                local text_label_value_3 = icon_value_3.ItemName.TextLabel
                local title_value = argument_4_2.Title
                if not title_value then
                    title_value = display_info_value.Name or argument_2_5
                end
                text_label_value_3.Text = title_value
            end
            local value_10_9: string = "ImageLabel"
            local image_label_child = icon_value_3:FindFirstChild(value_10_9)
            if image_label_child then
                local icon_value_4 = argument_4_2.Icon
                if not icon_value_4 then
                    icon_value_4 = display_info_value.Image
                    if not icon_value_4 then
                        do
                            local take_fallback_2 = not reward_items_value_2
                            if not take_fallback_2 then
                                local value_9_17 = captured_value_6
                                local item_id_value_6 = reward_items_value_2.ItemID
                                local item_type_value_3 = reward_items_value_2.ItemType
                                icon_value_4 = value_9_17:GetDisplayInfo(
                                    item_id_value_6,
                                    item_type_value_3
                                ).Image
                                take_fallback_2 = not icon_value_4
                            end
                            if take_fallback_2 then
                                icon_value_4 = ""
                            end
                        end
                    end
                end
                image_label_child.Image = icon_value_4
            end
            local price_value = argument_3_3.Price
            if price_value then
                price_value = argument_3_3.Price.Robux
            end
            local price_value_4 = argument_1_7.Container.Price.RobuxCost.Price
            local comma_number_result_3
            do
                local take_fallback_3 = not price_value
                if not take_fallback_3 then
                    local value_10_11 = captured_value_6
                    local value_12_6 = price_value
                    comma_number_result_3 = value_10_11:CommaNumber(value_12_6)
                    take_fallback_3 = not comma_number_result_3
                end
                if take_fallback_3 then
                    comma_number_result_3 = ""
                end
            end
            price_value_4.Text = comma_number_result_3
            captured_value_7(argument_1_7, argument_4_2)
            captured_value_8(argument_1_7, argument_4_2)
            local icon_value_5 = argument_1_7.Container.Icon
            local value_10_15: string = "Tags"
            local tags_child_2 = icon_value_5:FindFirstChild(value_10_15)
            if not tags_child_2 then
            else
                local one_time_value_2 = tags_child_2.OneTime
                local value_10_16: boolean?
                if argument_3_3.OneTimePurchase ~= true then
                    value_10_16 = false
                else
                    value_10_16 = true
                end
                one_time_value_2.Visible = value_10_16
                local value_value_3 = tags_child_2.Value
                local value_10_17: boolean?
                if argument_4_2.Tag == nil then
                    value_10_17 = false
                else
                    value_10_17 = true
                end
                value_value_3.Visible = value_10_17
                if argument_4_2.Tag then
                    local text_label_value_4 = tags_child_2.Value.TextLabel
                    local tag_value_6 = argument_4_2.Tag
                    text_label_value_4.Text = tag_value_6
                end
            end
            captured_value_9(argument_1_7, argument_2_5, argument_3_3, argument_4_2)

            return
        end
        closure_ready_4 = true
        if closure_cache[9] == nil then
            closure_cache[9] = apply_card
            closure_cache[10], closure_cache[11], closure_cache[12], closure_cache[13] = captured_value_6, captured_value_7, captured_value_8, captured_value_9
        end
    end
end
local build_cards
do
    local captured_value_10, captured_value_11, captured_value_12, captured_value_13 = get_main_event_result, table_14, value_2_3, apply_card
    if closure_cache[14] ~= nil and same_capture(closure_cache[15], captured_value_10) and same_capture(
        closure_cache[16],
        captured_value_11
    ) and same_capture(closure_cache[17], captured_value_12) and same_capture(
        closure_cache[18],
        captured_value_13
    ) then
        build_cards = closure_cache[14]
    else
        local closure_ready_5
        build_cards = function()
            if not closure_ready_5 then
                return
            end
            local event_start_info_value = captured_value_10.EventStartInfo
            local shop_layout_value = event_start_info_value.ShopLayout
            local shop_data_value = event_start_info_value.ShopData
            if not shop_layout_value then
                warn("[EventShopService] The event has no ShopLayout; the shop page is empty")

                return
            end
            local value_1_2: number = 0
            local table_4 = {}
            local value_5_24 = shop_layout_value
            local value_6_23: nil = nil
            local value_7_18: nil = nil
            local value_10_19, value_11_8, value_13_10, value_8_21, value_9_23
            for key_5, value_26 in value_5_24, value_6_23, value_7_18 do
                value_8_21, value_9_23 = key_5, value_26
                value_10_19 = 1
                if value_10_19 < value_8_21 then
                    value_1_2 = value_1_2 + 1
                    value_10_19 = captured_value_11.Divider:Clone()
                    value_10_19.LayoutOrder = value_1_2
                    value_11_8 = captured_value_12
                    value_10_19.Parent = value_11_8
                end
                value_10_19 = value_9_23
                value_11_8 = nil
                local value_12_8: nil = nil
                for key_4, value_25 in value_10_19, value_11_8, value_12_8 do
                    local value_14_11
                    value_13_10, value_14_11 = key_4, value_25
                    local value_15_11 = shop_data_value[value_14_11]
                    local value_16_9 = value_15_11 and value_15_11.Card
                    local value_17_6 = value_16_9
                    if value_17_6 then
                        local value_18_3 = captured_value_11
                        local shape_value_3 = value_16_9.Shape
                        value_17_6 = value_18_3[shape_value_3]
                    end
                    if not value_17_6 then
                        local warn_value_4 = warn
                        local value_19_3: string = "[EventShopService] %* is in ShopLayout but has no ShopData entry, Card or known Shape"
                        local value_21_3 = value_14_11
                        local format_result_2 = value_19_3:format(value_21_3)
                        warn_value_4(format_result_2)
                    else
                        value_1_2 = value_1_2 + 1
                        local cloned_value = value_17_6:Clone()
                        cloned_value.Name = value_14_11
                        cloned_value.LayoutOrder = value_1_2
                        local value_19_6 = captured_value_13
                        local value_20_3 = cloned_value
                        local value_21_4 = value_14_11
                        local value_22_2 = value_15_11
                        local value_23_2 = value_16_9
                        value_19_6(value_20_3, value_21_4, value_22_2, value_23_2)
                        local value_19_7 = captured_value_12
                        cloned_value.Parent = value_19_7
                        local value_19_8: boolean = true
                        table_4[value_14_11] = value_19_8
                    end
                end
            end
            value_5_24 = shop_data_value
            value_6_23 = nil
            value_7_18 = nil
            for key_6, value_27 in value_5_24, value_6_23, value_7_18 do
                value_8_21, value_9_23 = key_6, value_27
                if not value_9_23.Card then
                    continue
                end
                if table_4[value_8_21] then
                    continue
                end
                value_10_19 = warn
                value_11_8 = "[EventShopService] %* has a Card but isn't in ShopLayout"
                value_13_10 = value_8_21
                value_11_8 = value_11_8:format(value_13_10)
                value_10_19(value_11_8)
            end

            return
        end
        closure_ready_5 = true
        if closure_cache[14] == nil then
            closure_cache[14] = build_cards
            closure_cache[15], closure_cache[16], closure_cache[17], closure_cache[18] = captured_value_10, captured_value_11, captured_value_12, captured_value_13
        end
    end
end
local get_first_visible_card
do
    local captured_value_14, captured_value_15 = get_main_event_result, value_2_3
    if closure_cache[19] ~= nil and same_capture(closure_cache[20], captured_value_14) and same_capture(
        closure_cache[21],
        captured_value_15
    ) then
        get_first_visible_card = closure_cache[19]
    else
        local closure_ready_6
        get_first_visible_card = function(argument_1_8: string)
            if not closure_ready_6 then
                return
            end
            local event_start_info_value_2 = captured_value_14.EventStartInfo
            local shop_layout_value_2 = event_start_info_value_2.ShopLayout or ({})
            local value_4_21: nil = nil
            local value_5_25: nil = nil
            for key_8, value_29 in shop_layout_value_2, value_4_21, value_5_25 do
                local value_6_24, value_7_19 = key_8, value_29
                local value_8_22 = value_7_19
                local value_9_24: nil = nil
                local value_10_20: nil = nil
                for key_7, value_28 in value_8_22, value_9_24, value_10_20 do
                    local value_11_9, value_12_9 = key_7, value_28
                    local shop_data_value_2 = event_start_info_value_2.ShopData
                    local value_13_11 = shop_data_value_2[value_12_9]
                    local value_14_12 = captured_value_15
                    local value_16_10 = value_12_9
                    local find_first_child_result_2 = value_14_12:FindFirstChild(value_16_10)
                    if not value_13_11 then
                        continue
                    end
                    local card_value = value_13_11.Card
                    if not card_value then
                        continue
                    end
                    local card_value_2 = value_13_11.Card
                    local shape_value_4 = card_value_2.Shape
                    if shape_value_4 ~= argument_1_8 then
                        continue
                    end
                    if not find_first_child_result_2 then
                        continue
                    end
                    local visible_value = find_first_child_result_2.Visible
                    if not visible_value then
                        continue
                    end

                    return value_12_9
                end
            end

            return nil
        end
        closure_ready_6 = true
        if closure_cache[19] == nil then
            closure_cache[19] = get_first_visible_card
            closure_cache[20], closure_cache[21] = captured_value_14, captured_value_15
        end
    end
end
local table_23 = {}
local update_shop_item_container
do
    local captured_value_16 = value_2_3
    if closure_cache[22] ~= nil and same_capture(closure_cache[23], captured_value_16) then
        update_shop_item_container = closure_cache[22]
    else
        local closure_ready_7
        update_shop_item_container = function(): ()
            if not closure_ready_7 then
                return
            end
            local value_1_3 = captured_value_16
            local value_3_8: string = "UIListLayout"
            local ui_list_layout_child = value_1_3:WaitForChild(value_3_8)
            local value_2_12 = 0
            local value_3_9 = 0
            if captured_value_16.ScrollingDirection == Enum.ScrollingDirection.X then
                value_2_12 = ui_list_layout_child.AbsoluteContentSize.X + 5
            else
                if captured_value_16.ScrollingDirection == Enum.ScrollingDirection.Y then
                    value_3_9 = ui_list_layout_child.AbsoluteContentSize.Y + 5
                else
                    if captured_value_16.ScrollingDirection == Enum.ScrollingDirection.XY then
                        value_2_12 = ui_list_layout_child.AbsoluteContentSize.X + 5
                        value_3_9 = ui_list_layout_child.AbsoluteContentSize.Y + 5
                    end
                end
            end
            local value_4_25 = captured_value_16
            local from_offset_result: UDim2 = UDim2.fromOffset(value_2_12, value_3_9)
            value_4_25.CanvasSize = from_offset_result

            return
        end
        closure_ready_7 = true
        if closure_cache[22] == nil then
            closure_cache[22] = update_shop_item_container
            closure_cache[23] = captured_value_16
        end
    end
end
local update_required_purchases
do
    local captured_value_17, captured_value_18, captured_value_19 = value_2_3, require_result_3, require_result
    if closure_cache[24] ~= nil and same_capture(closure_cache[25], captured_value_17) and same_capture(
        closure_cache[26],
        captured_value_18
    ) and same_capture(closure_cache[27], captured_value_19) then
        update_required_purchases = closure_cache[24]
    else
        local closure_ready_8
        update_required_purchases = function(): ()
            if not closure_ready_8 then
                return
            end
            local value_1_5, value_2_13, value_3_10 = captured_value_17:GetChildren()
            for key_10, value_31 in value_1_5, value_2_13, value_3_10 do
                local value_4_26, value_5_26 = key_10, value_31
                local value_8_23 = "PurchaseButton"
                local purchase_button_child = value_5_26:FindFirstChild(value_8_23)
                if not purchase_button_child then
                    continue
                end
                local name_value_2 = value_5_26.Name
                local value_7_22 = captured_value_18.NewShop[name_value_2]
                if not value_7_22 then
                    continue
                end
                local required_purchases_value = value_7_22.RequiredPurchases
                if not required_purchases_value then
                    continue
                end
                local value_7_23: boolean = true
                value_8_23 = required_purchases_value
                local value_9_25: nil = nil
                local value_10_21: nil = nil
                for key_9, value_30 in value_8_23, value_9_25, value_10_21 do
                    local value_11_10, value_12_10 = key_9, value_30
                    local value_14_14 = captured_value_19
                    local one_time_purchases_value = value_14_14.OneTimePurchases
                    local value_13_12 = one_time_purchases_value[value_12_10]
                    if value_13_12 then
                        continue
                    end
                    value_7_23 = false
                    break
                end
                value_5_26.Visible = value_7_23
            end

            return
        end
        closure_ready_8 = true
        if closure_cache[24] == nil then
            closure_cache[24] = update_required_purchases
            closure_cache[25], closure_cache[26], closure_cache[27] = captured_value_17, captured_value_18, captured_value_19
        end
    end
end
local update_one_time_purchase
do
    local captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24, captured_value_25 = require_result, value_2_3, require_result_3, table_23, tween_service, value_8_10
    if closure_cache[28] ~= nil and same_capture(closure_cache[29], captured_value_20) and same_capture(
        closure_cache[30],
        captured_value_21
    ) and same_capture(closure_cache[31], captured_value_22) and same_capture(
        closure_cache[32],
        captured_value_23
    ) and same_capture(closure_cache[33], captured_value_24) and same_capture(
        closure_cache[34],
        captured_value_25
    ) then
        update_one_time_purchase = closure_cache[28]
    else
        local closure_ready_10
        update_one_time_purchase = function()
            if not closure_ready_10 then
                return
            end
            local one_time_purchases_value_2 = captured_value_20.OneTimePurchases
            local value_2_14, value_3_11, value_4_27 = captured_value_21:GetChildren()
            for key_11, value_32 in value_2_14, value_3_11, value_4_27 do
                local value_5_27, value_6_27 = key_11, value_32
                local value_9_26: string = "PurchaseButton"
                local purchase_button_child_2 = value_6_27:FindFirstChild(value_9_26)
                if not purchase_button_child_2 then
                    continue
                end
                local name_value_3 = value_6_27.Name
                local value_9_27 = captured_value_22
                local new_shop_value = value_9_27.NewShop
                local value_8_25 = new_shop_value[name_value_3]
                if not value_8_25 then
                    continue
                end
                local value_10_22 = captured_value_23
                local value_9_28 = value_10_22[name_value_3]
                if value_9_28 then
                    continue
                end
                local value_9_29 = one_time_purchases_value_2[name_value_3]
                if not value_9_29 then
                    continue
                end
                local value_9_30 = captured_value_23
                local value_10_23: boolean = true
                value_9_30[name_value_3] = value_10_23
                local spawn_value = task.spawn
                local value_10_24: (() -> ())?
                do
                    local captured_value_26, captured_value_27, captured_value_28, closure_ready_9
                    value_10_24 = function(): ()
                        if not closure_ready_9 then
                            return
                        end
                        local purchased_value = captured_value_26.Purchased
                        local value_2_15: boolean = true
                        purchased_value.Visible = value_2_15
                        task.wait(2)
                        local value_1_8: Instance? = captured_value_27
                        local value_3_12 = captured_value_26
                        local value_4_28: TweenInfo? = captured_value_28
                        local table_5 = {GroupTransparency = 1, Size = 0}
                        local new_result_7 = UDim2.new(0, 0, 1, 0)
                        table_5.Size = new_result_7
                        value_1_8:Create(value_3_12, value_4_28, table_5):Play()
                        task.wait(captured_value_28.Time)
                        local value_1_11 = captured_value_26
                        local value_2_20: boolean = false
                        value_1_11.Visible = value_2_20

                        return
                    end
                    captured_value_26, captured_value_27, captured_value_28 = value_6_27, captured_value_24, captured_value_25
                    closure_ready_9 = true
                end
                spawn_value(value_10_24)
            end

            return
        end
        closure_ready_10 = true
        if closure_cache[28] == nil then
            closure_cache[28] = update_one_time_purchase
            closure_cache[29], closure_cache[30], closure_cache[31], closure_cache[32], closure_cache[33], closure_cache[34] = captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24, captured_value_25
        end
    end
end
local connect_one_time_purchase
do
    local captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36 = get_main_event_result, require_result, table_23, value_2_3, update_one_time_purchase, update_required_purchases, inventory_child, shop_child
    if closure_cache[38] ~= nil and same_capture(closure_cache[39], captured_value_29) and same_capture(
        closure_cache[40],
        captured_value_30
    ) and same_capture(closure_cache[41], captured_value_31) and same_capture(
        closure_cache[42],
        captured_value_32
    ) and same_capture(closure_cache[43], captured_value_33) and same_capture(
        closure_cache[44],
        captured_value_34
    ) and same_capture(closure_cache[45], captured_value_35) and same_capture(
        closure_cache[46],
        captured_value_36
    ) then
        connect_one_time_purchase = closure_cache[38]
    else
        local closure_ready_12
        connect_one_time_purchase = function()
            if not closure_ready_12 then
                return
            end
            local value_1_12 = captured_value_29.EventStartInfo.ShopData
            local value_2_21: nil = nil
            local value_3_13 = nil
            for key_12 in value_1_12, value_2_21, value_3_13 do
                local value_4_29 = key_12
                local value_7_26 = captured_value_30
                local one_time_purchases_value_3 = value_7_26.OneTimePurchases
                local value_6_28 = one_time_purchases_value_3[value_4_29]
                if not value_6_28 then
                    continue
                end
                local value_6_29 = captured_value_31
                local value_7_27: boolean = true
                value_6_29[value_4_29] = value_7_27
                local value_6_30 = captured_value_32
                local value_8_27 = value_4_29
                local find_first_child_result_3 = value_6_30:FindFirstChild(value_8_27)
                if not find_first_child_result_3 then
                    continue
                end
                local value_7_29: boolean = false
                find_first_child_result_3.Visible = value_7_29
            end
            captured_value_33()
            captured_value_34()
            value_1_12 = captured_value_35.ProfileDataChanged.Event
            do
                local captured_value_37, captured_value_38 = captured_value_33, captured_value_34
                if closure_cache[35] ~= nil and same_capture(
                    closure_cache[36],
                    captured_value_37
                ) and same_capture(closure_cache[37], captured_value_38) then
                    value_3_13 = closure_cache[35]
                else
                    local closure_ready_11
                    value_3_13 = function(argument_1_9: string)
                        if not closure_ready_11 then
                            return
                        end
                        if argument_1_9 == "OneTimePurchases" then
                            captured_value_37()
                            captured_value_38()
                        end

                        return
                    end
                    closure_ready_11 = true
                    if closure_cache[35] == nil then
                        closure_cache[35] = value_3_13
                        closure_cache[36], closure_cache[37] = captured_value_37, captured_value_38
                    end
                end
            end
            value_1_12:Connect(value_3_13)
            value_1_12 = captured_value_36
            value_3_13 = "ProductPurchaseComplete"
            value_1_12 = value_1_12:WaitForChild(value_3_13).OnClientEvent
            value_3_13 = captured_value_34
            value_1_12:Connect(value_3_13)

            return
        end
        closure_ready_12 = true
        if closure_cache[38] == nil then
            closure_cache[38] = connect_one_time_purchase
            closure_cache[39], closure_cache[40], closure_cache[41], closure_cache[42], closure_cache[43], closure_cache[44], closure_cache[45], closure_cache[46] = captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36
        end
    end
end
local generate_shop_items
do
    local captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44, captured_value_45, captured_value_46, captured_value_47, captured_value_48 = build_cards, value_2_3, update_shop_item_container, shop_child, require_result_2, get_first_visible_card, scroll_to_item, tween_service, new_result_2, connect_one_time_purchase
    if closure_cache[53] ~= nil and same_capture(closure_cache[54], captured_value_39) and same_capture(
        closure_cache[55],
        captured_value_40
    ) and same_capture(closure_cache[56], captured_value_41) and same_capture(
        closure_cache[57],
        captured_value_42
    ) and same_capture(closure_cache[58], captured_value_43) and same_capture(
        closure_cache[59],
        captured_value_44
    ) and same_capture(closure_cache[60], captured_value_45) and same_capture(
        closure_cache[61],
        captured_value_46
    ) and same_capture(closure_cache[62], captured_value_47) and same_capture(
        closure_cache[63],
        captured_value_48
    ) then
        generate_shop_items = closure_cache[53]
    else
        local closure_ready_15
        generate_shop_items = function<T1>(argument_1_10: T1)
            if not closure_ready_15 then
                return
            end
            captured_value_39()
            local value_2_25 = captured_value_40
            local value_4_30 = "UIListLayout"
            local ui_list_layout_child_2 = value_2_25:WaitForChild(value_4_30)
            local value_5_29 = "AbsoluteContentSize"
            local value_3_14 = ui_list_layout_child_2:GetPropertyChangedSignal(value_5_29)
            value_5_29 = captured_value_41
            value_3_14:Connect(value_5_29)
            captured_value_41()
            value_3_14, value_4_30, value_5_29 = captured_value_40:GetChildren()
            for key_13, value_33 in value_3_14, value_4_30, value_5_29 do
                local value_6_32, value_7_30 = key_13, value_33
                local value_10_26: string = "PurchaseButton"
                local purchase_button_child_3 = value_7_30:FindFirstChild(value_10_26)
                local value_2_27 = purchase_button_child_3
                if not value_2_27 then
                    continue
                end
                local activated_value = value_2_27.Activated
                local value_10_27: (() -> ())?
                do
                    local captured_value_49, captured_value_50, closure_ready_13
                    value_10_27 = function(): ()
                        if not closure_ready_13 then
                            return
                        end
                        local buy_item_new_value = captured_value_49.BuyItemNew
                        local name_value_4 = captured_value_50.Name
                        local value_4_31: string = "Robux"
                        buy_item_new_value:InvokeServer(name_value_4, value_4_31)

                        return
                    end
                    captured_value_49, captured_value_50 = captured_value_42, value_7_30
                    closure_ready_13 = true
                end
                activated_value:Connect(value_10_27)
            end
            value_3_14 = captured_value_43.PageChanged.Event
            do
                local captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55 = captured_value_44, captured_value_45, captured_value_46, captured_value_40, captured_value_47
                if closure_cache[47] ~= nil and same_capture(
                    closure_cache[48],
                    captured_value_51
                ) and same_capture(closure_cache[49], captured_value_52) and same_capture(
                    closure_cache[50],
                    captured_value_53
                ) and same_capture(closure_cache[51], captured_value_54) and same_capture(
                    closure_cache[52],
                    captured_value_55
                ) then
                    value_5_29 = closure_cache[47]
                else
                    local closure_ready_14
                    value_5_29 = function(argument_1_11, argument_2_6)
                        if not closure_ready_14 then
                            return
                        end
                        local create_result_3, new_result_8, new_value_8, table_7, value_10_28, value_3_16, value_3_17, value_3_18, value_3_19, value_4_32, value_4_33, value_4_34, value_5_30, value_5_31, value_6_33, value_9_34
                        local control_state = 0
                        while true do
                            if control_state < 4 then
                                if control_state < 2 then
                                    if control_state < 1 then
                                        control_state = if argument_1_11 ~= "ShopBundles" then 7 else 1
                                    else
                                        control_state = if not argument_2_6 then 6 else 2
                                    end
                                else
                                    if control_state < 3 then
                                        control_state = if argument_2_6 ~= "ItemBundle" then 5 else 3
                                    else
                                        value_3_16 = captured_value_51
                                        value_4_32 = "ItemBundle"
                                        value_3_17 = value_3_16(value_4_32)
                                        control_state = if not value_3_17 then 7 else 4
                                    end
                                end
                            else
                                if control_state < 6 then
                                    if control_state < 5 then
                                        value_4_33 = captured_value_52
                                        value_5_30 = value_3_17
                                        value_4_33(value_5_30)

                                        return
                                    else
                                        value_3_18 = captured_value_52
                                        value_4_34 = argument_2_6
                                        value_3_18(value_4_34)

                                        return
                                    end
                                else
                                    if control_state < 7 then
                                        value_3_19 = captured_value_53
                                        value_5_31 = captured_value_54
                                        value_6_33 = captured_value_55
                                        table_7 = {CanvasPosition = 0}
                                        new_value_8 = Vector2.new
                                        value_9_34 = 0
                                        value_10_28 = 0
                                        new_result_8 = new_value_8(value_9_34, value_10_28)
                                        table_7.CanvasPosition = new_result_8
                                        create_result_3 = value_3_19:Create(
                                            value_5_31,
                                            value_6_33,
                                            table_7
                                        )
                                        create_result_3:Play()
                                        control_state = 7
                                    else
                                        return
                                    end
                                end
                            end
                        end
                    end
                    closure_ready_14 = true
                    if closure_cache[47] == nil then
                        closure_cache[47] = value_5_29
                        closure_cache[48], closure_cache[49], closure_cache[50], closure_cache[51], closure_cache[52] = captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55
                    end
                end
            end
            value_3_14:Connect(value_5_29)
            captured_value_48()

            return
        end
        closure_ready_15 = true
        if closure_cache[53] == nil then
            closure_cache[53] = generate_shop_items
            closure_cache[54], closure_cache[55], closure_cache[56], closure_cache[57], closure_cache[58], closure_cache[59], closure_cache[60], closure_cache[61], closure_cache[62], closure_cache[63] = captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44, captured_value_45, captured_value_46, captured_value_47, captured_value_48
        end
    end
end
local table_1 = {[("GenerateShopItems")] = nil}
table_1.GenerateShopItems = generate_shop_items

return table_1
