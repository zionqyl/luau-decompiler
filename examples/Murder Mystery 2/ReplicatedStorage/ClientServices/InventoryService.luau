--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_6_3))
local game_value_3: DataModel = game
local value_5_7: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_5_7)
local value_5_8: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_5_8)
local game_value_4: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_6_4)
local value_6_5: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_4:WaitForChild(value_6_5)
local require_value_3 = require
local game_value_5: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_8)
local value_8_2: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_8_2)
local value_8_3: string = "WindowService"
local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_8_3))
local require_value_4 = require
local value_8_4: string = "ItemService"
local require_result_4 = require_value_4(client_services_child:WaitForChild(value_8_4))
local base_item_frame_value = require_result_4.BaseItemFrame
local apply_filter
do
    local captured_value = require_result
    apply_filter = function(argument_1, argument_2: string): ()
        local value_3_6 = argument_1.Filters.Search or ""
        local value_4_11 = argument_1.Filters.ClassFilter or nil
        local frame_value = argument_1.Frames[argument_2].Frame
        local value_5_11: boolean = false
        if value_3_6 ~= "" then
            if value_3_6 == nil then
                value_5_11 = false
            else
                value_5_11 = true
            end
        end
        local value_6_10: boolean = false
        if value_5_11 then
            local value_7_5 = captured_value[argument_1.ItemType][argument_2]
            local lower_value = string.lower
            local name_value = value_7_5.Name
            if not name_value then
                name_value = value_7_5.DisplayName or value_7_5.ItemName
            end
            local lower_result = lower_value(name_value)
            if (string.find(lower_result, value_3_6)) == nil then
                value_6_10 = false
            else
                value_6_10 = true
            end
        end
        local value_3_7: boolean = true
        if argument_1.Frames[argument_2].ItemClass ~= argument_1.Filters.ClassFilter then
            if argument_1.Filters.ClassFilter ~= nil then
                value_3_7 = false
            else
                value_3_7 = true
            end
        end
        local value_7_7: boolean?
        do
            local take_fallback = not value_3_7
            if not take_fallback then
                value_7_7 = not value_5_11
                take_fallback = not value_7_7
            end
            if take_fallback then
                value_7_7 = value_5_11 and value_6_10
            end
        end
        frame_value.Visible = value_7_7

        return
    end
end
local create_item_frame
do
    local captured_value_2, captured_value_3 = base_item_frame_value, require_result_4
    create_item_frame = function<T1>(argument_1_2: T1, argument_2_2, argument_3: string, argument_4: number)
        local cloned_value = captured_value_2:Clone()
        local value_6_12 = captured_value_3
        local value_8_6 = argument_2_2
        local value_9_2: string = argument_3
        local get_item_info_result = value_6_12:GetItemInfo(value_8_6, value_9_2)
        if not get_item_info_result then
            local warn_value = warn
            local value_9_3: string = "InventoryService: No info found for item:"
            local value_11_2: string = argument_3
            local tostring_result = tostring(value_11_2)
            local value_11_3: string = ", "
            local value_13 = argument_2_2
            warn_value(value_9_3 .. tostring_result .. value_11_3 .. (tostring(value_13)))

            return nil
        end
        local value_7_10 = captured_value_3
        local value_9_4 = cloned_value
        local value_10_2 = get_item_info_result
        local value_11_4: number = argument_4
        value_7_10:ApplyItemToFrame(value_9_4, value_10_2, value_11_4)
        local value_7_12 = captured_value_3
        local value_9_5 = cloned_value
        local value_10_3 = get_item_info_result
        value_7_12:ApplyTags(value_9_5, value_10_3)
        local value_7_14 = captured_value_3
        local value_9_6 = argument_2_2
        local value_10_4: string = argument_3
        local get_layout_order_result = value_7_14:GetLayoutOrder(value_9_6, value_10_4)
        cloned_value.LayoutOrder = get_layout_order_result
        local value_7_16: string? = nil
        if argument_2_2 == "Weapons" then
            if get_item_info_result.Event ~= nil then
                value_7_16 = "Event"
            else
                if get_item_info_result.Season == nil then
                    value_7_16 = "Classic"
                else
                    value_7_16 = "Current"
                end
            end
        end

        return {ItemType = argument_2_2, Frame = cloned_value, ItemClass = value_7_16}
    end
end
table_1.CreateItemFrame = create_item_frame
local add_item
do
    local captured_value_4, captured_value_5 = table_1, apply_filter
    add_item = function<T1>(argument_1_3: T1, argument_2_3, argument_3_2: string, argument_4_2: number)
        local value_5_14 = captured_value_4
        local item_type_value_2 = argument_2_3.ItemType
        local value_8_11: string = argument_3_2
        local value_9_7: number = argument_4_2
        local create_item_frame_result = value_5_14:CreateItemFrame(
            item_type_value_2,
            value_8_11,
            value_9_7
        )
        if create_item_frame_result then
            local sorted_i_ds_value = argument_2_3.SortedIDs
            local value_8_12: string = argument_3_2
            table.insert(sorted_i_ds_value, value_8_12)
            local frames_value_3 = argument_2_3.Frames
            frames_value_3[argument_3_2] = create_item_frame_result
            captured_value_5(argument_2_3, argument_3_2)
            if argument_2_3.ListFrame then
                local frame_value_2 = create_item_frame_result.Frame
                local list_frame_value_2 = argument_2_3.ListFrame
                frame_value_2.Parent = list_frame_value_2
            end
        end

        return create_item_frame_result
    end
end
table_1.AddItem = add_item
local generate_inventory_info
do
    local captured_value_6 = table_1
    generate_inventory_info = function<T1>(argument_1_4: T1, argument_2_4, argument_3_3, argument_4_3)
        local table_5 = {
            ItemType = 0,
            Frames = 0,
            Filters = 0,
            SortedIDs = 0,
            ListFrame = 0,
        }
        table_5.ItemType = argument_2_4
        local table_6 = {}
        table_5.Frames = table_6
        table_6 = {ClassFilter = 0, Search = ""}
        table_6["ClassFilter"] = nil
        table_5.Filters = table_6
        table_6 = {}
        table_5.SortedIDs = table_6
        table_5.ListFrame = argument_4_3
        table_6 = argument_3_3
        local value_7_18: nil = nil
        local value_8_14: nil = nil
        for key, value in table_6, value_7_18, value_8_14 do
            local value_9_8, value_10_5 = key, value
            local value_11_5: nil = nil
            local value_12: nil = nil
            local value_14 = value_9_8
            local tonumber_value = tonumber
            local tonumber_result = tonumber_value(value_14)
            local value_11_6, value_12_2
            if tonumber_result then
                value_11_6 = value_10_5
                value_12_2 = 1
            else
                value_11_6 = value_9_8
                value_12_2 = value_10_5
            end
            local value_13_2 = captured_value_6
            local value_15 = table_5
            local value_16 = value_11_6
            local value_17 = value_12_2
            value_13_2:AddItem(value_15, value_16, value_17)
        end

        return table_5
    end
end
table_1.GenerateInventoryInfo = generate_inventory_info
local update_filter
do
    local captured_value_7 = apply_filter
    update_filter = function<T1>(argument_1_5: T1, argument_2_5): ()
        local frames_value_4 = argument_2_5.Frames
        local value_4_13: nil = nil
        local value_5_16: nil = nil
        for key_2, value_2 in frames_value_4, value_4_13, value_5_16 do
            local value_6_16, value_7_19 = key_2, value_2
            local value_8_15 = captured_value_7
            local value_9_9 = argument_2_5
            local value_10_6 = value_6_16
            value_8_15(value_9_9, value_10_6)
        end

        return
    end
end
table_1.UpdateFilter = update_filter

local function for_each_frame<T1>(argument_1_6: T1, argument_2_6, argument_3_4): ()
    local frames_value_5 = argument_2_6.Frames
    local value_5_17: nil = nil
    local value_6_17: nil = nil
    for key_3, value_18 in frames_value_5, value_5_17, value_6_17 do
        local value_7_20, value_8_16 = key_3, value_18
        local value_9_10 = argument_3_4
        local value_10_7 = value_7_20
        local frame_value_3 = value_8_16.Frame
        value_9_10(value_10_7, frame_value_3)
    end

    return
end

table_1.ForEachFrame = for_each_frame
local apply_changes_to_inventory_info
do
    local captured_value_8, captured_value_9 = table_1, require_result_4
    apply_changes_to_inventory_info = function<T1>(argument_1_7: T1, argument_2_7, argument_3_5: string, argument_4_4: number)
        if argument_4_4 ~= nil then
            if 0 < argument_4_4 then
                if not argument_2_7.Frames[argument_3_5] then
                    local value_6_18 = captured_value_8
                    local value_8_17 = argument_2_7
                    local value_9_11: string = argument_3_5
                    local value_10_8: number = argument_4_4
                    value_6_18:AddItem(value_8_17, value_9_11, value_10_8)

                    return
                end
                local amount_value = argument_2_7.Frames[argument_3_5].Frame.Container.Amount
                local value_7_22 = captured_value_9
                local value_9_12: number = argument_4_4
                local get_amount_text_result = value_7_22:GetAmountText(value_9_12)
                amount_value.Text = get_amount_text_result

                return
            end
        end
        local value_5_20 = captured_value_8
        local value_7_24 = argument_2_7
        local value_8_19: string = argument_3_5
        value_5_20:RemoveItem(value_7_24, value_8_19)

        return
    end
end
table_1.ApplyChangesToInventoryInfo = apply_changes_to_inventory_info
local connect_search_box
do
    local captured_value_10 = table_1
    connect_search_box = function<T1>(argument_1_8: T1, argument_2_8, argument_3_6)
        local value_6_22: string = "Text"
        local get_property_changed_signal_result = argument_3_6:GetPropertyChangedSignal(
            value_6_22
        )
        local value_6_23: (() -> ())?
        do
            local captured_value_11, captured_value_12, captured_value_13, closure_ready
            value_6_23 = function(): ()
                if not closure_ready then
                    return
                end
                local filters_value_5 = captured_value_11.Filters
                local lower_result_2 = string.lower(captured_value_12.Text)
                filters_value_5.Search = lower_result_2
                local value_1_2 = captured_value_13
                local value_3_9 = captured_value_11
                value_1_2:UpdateFilter(value_3_9)

                return
            end
            captured_value_11, captured_value_12, captured_value_13 = argument_2_8, argument_3_6, captured_value_10
            closure_ready = true
        end
        get_property_changed_signal_result:Connect(value_6_23)

        return
    end
end
table_1.ConnectSearchBox = connect_search_box
local auto_update
do
    local captured_value_14, captured_value_15 = remotes_child, table_1
    auto_update = function<T1>(argument_1_9: T1, argument_2_9)
        local value_3_10: Instance? = captured_value_14
        local value_5_24: string = "Inventory"
        local inventory_child = value_3_10:WaitForChild(value_5_24)
        local value_5_25: string = "InventoryDataChanged"
        local event_value_2 = inventory_child:WaitForChild(value_5_25).Event
        local value_5_26: ((string, string, number) -> ())?
        do
            local captured_value_16, captured_value_17, closure_ready_2
            value_5_26 = function(argument_1_10: string, argument_2_10: string, argument_3_7: number): ()
                if not closure_ready_2 then
                    return
                end
                if argument_1_10 ~= captured_value_16.ItemType then
                    return
                end
                if argument_1_10 == "Toys" then
                    local value_1_4: string = "Emotes"
                end
                local value_4_20 = captured_value_17
                local value_6_24 = captured_value_16
                local value_7_25: string = argument_2_10
                local value_8_20: number = argument_3_7
                value_4_20:ApplyChangesToInventoryInfo(value_6_24, value_7_25, value_8_20)

                return
            end
            captured_value_16, captured_value_17 = argument_2_9, captured_value_15
            closure_ready_2 = true
        end
        local connection = event_value_2:Connect(value_5_26)
        argument_2_9.UpdateConnection = connection

        return
    end
end
table_1.AutoUpdate = auto_update

local function remove_item<T1>(argument_1_11: T1, argument_2_11, argument_3_8: string): ()
    argument_2_11.Frames[argument_3_8].Frame:Destroy()
    local frames_value_9 = argument_2_11.Frames
    local value_6_26: nil = nil
    frames_value_9[argument_3_8] = value_6_26
    table.remove(argument_2_11.SortedIDs, table.find(argument_2_11.SortedIDs, argument_3_8))

    return
end

table_1.RemoveItem = remove_item

local function clear_inventory<T1>(argument_1_12: T1, argument_2_12): ()
    local frames_value_10 = argument_2_12.Frames
    local value_4_23: nil = nil
    local value_5_29: nil = nil
    for key_4, value_19 in frames_value_10, value_4_23, value_5_29 do
        local value_6_27, value_7_26 = key_4, value_19
        local frame_value_6 = value_7_26.Frame
        frame_value_6:Destroy()
    end
    frames_value_10 = {}
    argument_2_12.Frames = frames_value_10
    if argument_2_12.UpdateConnection then
        argument_2_12.UpdateConnection:Disconnect()
    end

    return
end

table_1.ClearInventory = clear_inventory

return table_1
