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

local table_1 = {[("UpdateRecipes")] = nil, [("UpdateRecipes")] = nil}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Types"
local types_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "EventType"
local require_result = require_value(types_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_5_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5_4)
local value_5_5: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_5)
local value_5_6: string = "EventInfoService"
local wait_for_initialized_async_result = require_value_2(shared_services_child:WaitForChild(
    value_5_6
)):WaitForInitializedAsync()
local require_value_3 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "ItemService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_6_3))
local require_value_4 = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "Button"
local require_result_4 = require_value_4(client_services_child_2:WaitForChild(value_7_3))
local require_value_5 = require
local parent_value: Instance? = script.Parent
local value_8: string = "NavigationService"
local require_result_5 = require_value_5(parent_value:WaitForChild(value_8))
local get_main_event_result = wait_for_initialized_async_result:GetMainEvent()
local game_value_5: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_9)
local value_9_2: string = "Remotes"
local value_2_2: Instance? = (replicated_storage_service_5:WaitForChild(value_9_2))
local value_9_3: string = "Events"
local events_child = value_2_2:WaitForChild(value_9_3)
local value_9_4 = get_main_event_result.Title .. "Remotes"
local wait_for_child_result = events_child:WaitForChild(value_9_4)
local require_value_6 = require
local game_value_6: DataModel = game
local value_11_2: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_6:GetService(value_11_2)
local value_11_3: string = "Modules"
local modules_child: Instance? = replicated_storage_service_6:WaitForChild(value_11_3)
local value_11_4: string = "ProfileData"
local require_result_6 = require_value_6(modules_child:WaitForChild(value_11_4))
local parent_value_3 = script.Parent.Parent
local value_12: string = "MainEvent"
local main_event_child = parent_value_3:WaitForChild(value_12)
local value_13: string = "Title"
local value_9_8 = (main_event_child:WaitForChild(value_13))
local value_13_2: string = "Main"
local value_9_9 = (main_event_child:WaitForChild(value_13_2))
local value_12_4: string = "Crafting"
local crafting_child = value_9_9:WaitForChild(value_12_4)
local value_13_3: string = "Container"
local container_child = crafting_child:WaitForChild(value_13_3)
local value_13_4: string = "ScrollingFrame"
local value_9_10 = (container_child:WaitForChild(value_13_4))
local value_13_5: string = "CraftingRecipe"
local crafting_recipe_child = value_9_10:WaitForChild(value_13_5)
local script_value_3: LuaSourceContainer = script
crafting_recipe_child.Parent = script_value_3
local table_12 = {}
local table_13 = {}
local update_recipes
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = require_result_6, get_main_event_result, table_12, table_13
    update_recipes = function<T1>(argument_1: T1)
        local value_2_3 = captured_value[captured_value_2.Title]
        local value_3_8 = captured_value_3
        local value_4_10: nil = nil
        local value_5_13: nil = nil
        for key, value in value_3_8, value_4_10, value_5_13 do
            local value_6_9, value_7_10 = key, value
            local value_9_11 = captured_value_2
            local event_start_info_value = value_9_11.EventStartInfo
            local crafting_recipes_value = event_start_info_value.CraftingRecipes
            local value_8_6 = crafting_recipes_value[value_6_9]
            local crafted_value = value_2_3.Crafted
            local value_9_12 = crafted_value[value_6_9]
            local value_12_8 = "Container"
            local container_child_2 = value_7_10:WaitForChild(value_12_8)
            local value_13_6 = "Input"
            local input_child = container_child_2:WaitForChild(value_13_6)
            value_13_6 = "Items"
            local items_child = input_child:WaitForChild(value_13_6)
            local input_value, value_14: nil | boolean | number, value_15
            if value_9_12 then
                value_12_8 = value_7_10.Crafted
                value_13_6 = true
                value_12_8.Visible = value_13_6
                value_14 = 1
                value_12_8 = 4
                value_13_6 = 1
                for index = value_14, value_12_8, value_13_6 do
                    value_14 = index
                    if not value_8_6.Input[value_14] then
                        continue
                    end
                    local value_18: string = "Item"
                    local value_19: number = value_14
                    local value_17: string = value_18 .. value_19
                    local value_10_7 = (items_child:FindFirstChild(value_17))
                    value_15 = value_10_7.Container.Amount
                    input_value = ""
                    value_15.Text = input_value
                    value_15 = value_10_7.Container.Ready
                    input_value = false
                    value_15.Visible = input_value
                end
                value_13_6 = captured_value_4
                value_12_8 = value_13_6[value_6_9]
                value_12_8:Disable()
            else
                value_12_8 = 0
                value_13_6 = #value_8_6.Input
                input_value = 1
                value_14 = 4
                value_15 = 1
                for index_2 = input_value, value_14, value_15 do
                    input_value = index_2
                    local input_value_2 = value_8_6.Input
                    local value_17_2 = input_value_2[input_value]
                    if not value_17_2 then
                        continue
                    end
                    local input_value_3 = value_8_6.Input
                    local value_17_3 = input_value_3[input_value]
                    local value_21: string = "Item"
                    local value_22 = input_value
                    local value_20 = value_21 .. value_22
                    local find_first_child_result = items_child:FindFirstChild(value_20)
                    local value_22_2 = captured_value
                    local item_type_value = value_17_3.ItemType
                    local value_21_2 = value_22_2[item_type_value]
                    local owned_value = value_21_2.Owned
                    local item_id_value = value_17_3.ItemID
                    local value_20_2 = owned_value[item_id_value]
                    local value_19_3 = value_20_2 or 0
                    local container_value = find_first_child_result.Container
                    local amount_value = container_value.Amount
                    local value_21_3: string = "%*/%*"
                    local value_23 = value_19_3
                    local amount_value_2 = value_17_3.Amount
                    local format_result = value_21_3:format(value_23, amount_value_2)
                    amount_value.Text = format_result
                    local container_value_2 = find_first_child_result.Container
                    local ready_value = container_value_2.Ready
                    local amount_value_3 = value_17_3.Amount
                    local value_21_5: boolean?
                    if not (amount_value_3 <= value_19_3) then
                        value_21_5 = false
                    else
                        value_21_5 = true
                    end
                    ready_value.Visible = value_21_5
                    local amount_value_4 = value_17_3.Amount
                    if not (amount_value_4 <= value_19_3) then
                        continue
                    end
                    value_12_8 = value_12_8 + 1
                end
                if not (value_13_6 <= value_12_8) then
                    value_14 = false
                else
                    value_14 = true
                end
                if value_14 then
                    input_value = captured_value_4
                    value_15 = input_value[value_6_9]
                    value_15:Enable()
                else
                    input_value = captured_value_4
                    value_15 = input_value[value_6_9]
                    value_15:Disable()
                end
            end
        end

        return
    end
end
table_1.UpdateRecipes = update_recipes
local generate_recipes
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14, captured_value_15, captured_value_16 = get_main_event_result, crafting_recipe_child, require_result_3, table_13, require_result_4, wait_for_child_result, table_12, value_9_10, table_1, value_2_2, crafting_child, require_result_5
    generate_recipes = function<T1>(argument_1_2: T1)
        local value_2_4 = captured_value_5.EventStartInfo.CraftingRecipes
        local value_3_9: nil = nil
        local value_4_11 = nil
        for key_2, value_24 in value_2_4, value_3_9, value_4_11 do
            local value_5_14, value_6_10 = key_2, value_24
            local value_7_11 = captured_value_6
            local cloned_value = value_7_11:Clone()
            local value_8_7 = cloned_value.Container.Input.Title.TextLabel
            local title_value_2 = value_6_10.Title
            value_8_7.Text = title_value_2
            local value_10_8 = 1
            value_8_7 = 4
            title_value_2 = 1
            for index_3 = value_10_8, value_8_7, title_value_2 do
                value_10_8 = index_3
                local input_value_4 = value_6_10.Input
                local value_11_15 = input_value_4[value_10_8]
                local container_value_3 = cloned_value.Container
                local input_value_5 = container_value_3.Input
                local items_value = input_value_5.Items
                local value_15_2: string = "Item"
                local value_16 = value_10_8
                local value_14_2 = value_15_2 .. value_16
                local find_first_child_result_2 = items_value:FindFirstChild(value_14_2)
                if not value_11_15 then
                    local value_13_8: boolean = false
                    find_first_child_result_2.Visible = value_13_8
                else
                    local value_13_9 = captured_value_7
                    local item_id_value_2 = value_11_15.ItemID
                    local item_type_value_2 = value_11_15.ItemType
                    local get_display_info_result = value_13_9:GetDisplayInfo(
                        item_id_value_2,
                        item_type_value_2
                    )
                    local item_name_value = find_first_child_result_2.ItemName
                    local text_label_value = item_name_value.TextLabel
                    local name_value = get_display_info_result.Name
                    text_label_value.Text = name_value
                    local item_name_value_2 = find_first_child_result_2.ItemName
                    local color_value = get_display_info_result.Color
                    item_name_value_2.BackgroundColor3 = color_value
                    local container_value_4 = find_first_child_result_2.Container
                    local icon_value = container_value_4.Icon
                    local image_value = get_display_info_result.Image
                    icon_value.Image = image_value
                    local value_14_4: boolean = true
                    find_first_child_result_2.Visible = value_14_4
                end
            end
            value_10_8 = 1
            value_8_7 = 1
            title_value_2 = 1
            for index_4 = value_10_8, value_8_7, title_value_2 do
                value_10_8 = index_4
                local output_value = value_6_10.Output
                local value_11_16 = output_value[value_10_8]
                local container_value_5 = cloned_value.Container
                local output_value_2 = container_value_5.Output
                local value_15_3: string = "Item"
                local value_16_2 = value_10_8
                local value_14_5 = value_15_3 .. value_16_2
                local find_first_child_result_3 = output_value_2:FindFirstChild(value_14_5)
                if not value_11_16 then
                    local value_13_12: boolean = false
                    find_first_child_result_3.Visible = value_13_12
                else
                    local value_13_13 = captured_value_7
                    local item_id_value_3 = value_11_16.ItemID
                    local item_type_value_3 = value_11_16.ItemType
                    local get_display_info_result_2 = value_13_13:GetDisplayInfo(
                        item_id_value_3,
                        item_type_value_3
                    )
                    local item_name_value_3 = find_first_child_result_3.ItemName
                    local text_label_value_2 = item_name_value_3.TextLabel
                    local name_value_2 = get_display_info_result_2.Name
                    text_label_value_2.Text = name_value_2
                    local item_name_value_4 = find_first_child_result_3.ItemName
                    local color_value_2 = get_display_info_result_2.Color
                    item_name_value_4.BackgroundColor3 = color_value_2
                    local container_value_6 = find_first_child_result_3.Container
                    local icon_value_2 = container_value_6.Icon
                    local image_value_2 = get_display_info_result_2.Image
                    icon_value_2.Image = image_value_2
                    local container_value_7 = find_first_child_result_3.Container
                    local amount_value_5 = container_value_7.Amount
                    local value_15_4: string = ""
                    amount_value_5.Text = value_15_4
                    local value_14_7: boolean = true
                    find_first_child_result_3.Visible = value_14_7
                end
            end
            value_8_7 = captured_value_8
            title_value_2 = captured_value_9.createButton
            local value_12_11: string = "Container"
            value_10_8 = cloned_value:WaitForChild(value_12_11)
            local value_12_12: string = "Output"
            value_10_8 = value_10_8:WaitForChild(value_12_12)
            local value_12_13: string = "Craft"
            value_10_8 = value_10_8:WaitForChild(value_12_13)
            local value_12_14: string = "Craft"
            value_10_8 = value_10_8:WaitForChild(value_12_14)
            local value_11_21
            do
                local captured_value_17, captured_value_18, closure_ready
                value_11_21 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local craft_recipe_value = captured_value_17.CraftRecipe
                    local value_3_10 = captured_value_18
                    craft_recipe_value:FireServer(value_3_10)

                    return
                end
                captured_value_17, captured_value_18 = captured_value_10, value_5_14
                closure_ready = true
            end
            title_value_2 = title_value_2(value_10_8, value_11_21)
            value_8_7[value_5_14] = title_value_2
            value_8_7 = captured_value_11
            value_8_7[value_5_14] = cloned_value
            value_8_7 = value_6_10.LayoutOrder
            cloned_value.LayoutOrder = value_8_7
            value_8_7 = captured_value_12
            cloned_value.Parent = value_8_7
        end
        captured_value_13:UpdateRecipes()
        value_2_4 = captured_value_14
        value_4_11 = "Inventory"
        value_2_4 = value_2_4:WaitForChild(value_4_11)
        value_4_11 = "InventoryDataChanged"
        value_2_4 = value_2_4:WaitForChild(value_4_11).Event
        do
            local captured_value_19, captured_value_20, captured_value_21 = captured_value_15, captured_value_5, captured_value_13
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_19) and same_capture(
                closure_cache[3],
                captured_value_20
            ) and same_capture(closure_cache[4], captured_value_21) then
                value_4_11 = closure_cache[1]
            else
                local closure_ready_2
                value_4_11 = function(argument_1_3: string, argument_2: string)
                    if not closure_ready_2 then
                        return
                    end
                    if not captured_value_19.Visible then
                        return
                    end
                    local value_3_12: boolean = false
                    local value_4_12 = captured_value_20.EventStartInfo.CraftingRecipes
                    local value_5_15: nil = nil
                    local value_6_11: nil = nil
                    for key_5, value_27 in value_4_12, value_5_15, value_6_11 do
                        local value_7_13, value_8_8 = key_5, value_27
                        local input_value_6 = value_8_8.Input
                        local value_10_9: nil = nil
                        local value_11_22: nil = nil
                        local value_12_15, value_13_15
                        for key_3, value_25 in input_value_6, value_10_9, value_11_22 do
                            value_12_15, value_13_15 = key_3, value_25
                            local item_id_value_4 = value_13_15.ItemID
                            if item_id_value_4 ~= argument_2 then
                                continue
                            end
                            value_3_12 = true
                            break
                        end
                        input_value_6 = value_8_8.Output
                        value_10_9 = nil
                        value_11_22 = nil
                        for key_4, value_26 in input_value_6, value_10_9, value_11_22 do
                            value_12_15, value_13_15 = key_4, value_26
                            local item_id_value_5 = value_13_15.ItemID
                            if item_id_value_5 ~= argument_2 then
                                continue
                            end
                            value_3_12 = true
                            break
                        end
                    end
                    if value_3_12 then
                        captured_value_21:UpdateRecipes()
                    end

                    return
                end
                closure_ready_2 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_4_11
                    closure_cache[2], closure_cache[3], closure_cache[4] = captured_value_19, captured_value_20, captured_value_21
                end
            end
        end
        value_2_4:Connect(value_4_11)
        value_2_4 = captured_value_16.PageChanged.Event
        do
            local captured_value_22 = captured_value_13
            if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_22) then
                value_4_11 = closure_cache[5]
            else
                local closure_ready_3
                value_4_11 = function(argument_1_4: string)
                    if not closure_ready_3 then
                        return
                    end
                    if argument_1_4 == "Crafting" then
                        captured_value_22:UpdateRecipes()
                    end

                    return
                end
                closure_ready_3 = true
                if closure_cache[5] == nil then
                    closure_cache[5] = value_4_11
                    closure_cache[6] = captured_value_22
                end
            end
        end
        value_2_4:Connect(value_4_11)

        return
    end
end
table_1.GenerateRecipes = generate_recipes

return table_1
