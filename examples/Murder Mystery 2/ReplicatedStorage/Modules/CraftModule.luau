--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function shared_function(argument_1_6, argument_2_3): boolean
    local value_3_8: boolean?
    if not (argument_1_6.ID < argument_2_3.ID) then
        value_3_8 = false
    else
        value_3_8 = true
    end

    return value_3_8
end

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
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
}
local table_2: { Ancient: number, Christmas: number, Classic: number, Common: number, Godly: number, Halloween: number, Legendary: number, Rare: number, Uncommon: number, Unique: number, Victim: number } = {
    Classic = 1,
    Common = 2,
    Uncommon = 3,
    Rare = 4,
    Legendary = 5,
    Godly = 6,
    Victim = 7,
    Unique = 7,
    Christmas = 1.5,
    Halloween = 1.6,
    Ancient = 6.5,
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
local require_value_3 = require
local game_value_3: DataModel = game
local value_7 = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_7)
value_7 = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_7)
value_7 = "ItemPopupService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_7))
local rarity_value = require_result.Rarity
local require_value_4 = require
value_7 = game
value_7 = value_7.ReplicatedStorage
value_7 = value_7.Modules
value_7 = value_7.GridCreator
local require_result_4 = require_value_4(value_7)
value_7 = nil
table_1.GUI = value_7
value_7 = "Craft"
table_1.Mode = value_7
value_7 = nil
local value_8 = nil
local value_9 = nil
local codes_value = require_result.Codes
local table_11 = {}
local pairs_value = pairs
local value_13 = codes_value
local value_14
pairs_value, value_13, value_14 = pairs_value(value_13)
local value_15, value_16
for key, value in pairs_value, value_13, value_14 do
    value_15, value_16 = key, value
    local prize_value = value_16.Prize
    local value_18: boolean = true
    table_11[prize_value] = value_18
end
do
    local captured_value, closure_ready
    pairs_value = function(argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7, argument_8, argument_9): ()
        if not closure_ready then
            return
        end
        local value_10 = captured_value
        value_10.GUI = argument_1
        local value_10_2 = captured_value
        value_10_2.RecipesFrame = argument_2
        local value_10_3 = captured_value
        value_10_3.NewRecipeFrame = argument_3
        local value_10_4 = captured_value
        value_10_4.ActionNav = argument_4
        local value_10_5 = captured_value
        value_10_5.SalvageInventoryFrame = argument_5
        local value_10_6 = captured_value
        value_10_6.NewItemFrame = argument_6
        local value_10_7 = captured_value
        value_10_7.SalvageConfirmFrame = argument_7
        local value_10_8 = captured_value
        value_10_8.SalvageGUI = argument_8
        local value_10_9 = captured_value
        value_10_9.SalvageConfirmButton = argument_9
        value_8 = nil
        value_7 = nil
        local mouse_button1_click_value = captured_value.SalvageConfirmButton.MouseButton1Click
        local action_confirm_button_function_value = captured_value.ActionConfirmButtonFunction
        value_9 = (mouse_button1_click_value:connect(action_confirm_button_function_value))
        captured_value.WatchSalvageGridVisibility()

        return
    end
    captured_value = table_1
    closure_ready = true
end
table_1.SetCraftGUI = pairs_value
pairs_value = function(): ()
    return
end
table_1.CraftConfirm = pairs_value
pairs_value = function(): ()
    return
end
table_1.SalvageConfirm = pairs_value
do
    local captured_value_2 = table_1
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_2) then
        pairs_value = closure_cache[1]
    else
        local closure_ready_2
        pairs_value = function(argument_1_2)
            if not closure_ready_2 then
                return
            end
            local value_2 = captured_value_2
            value_2.CraftConfirm = argument_1_2

            return
        end
        closure_ready_2 = true
        if closure_cache[1] == nil then
            closure_cache[1] = pairs_value
            closure_cache[2] = captured_value_2
        end
    end
end
table_1.SetCraftConfirmButton = pairs_value
do
    local captured_value_3 = table_1
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_3) then
        pairs_value = closure_cache[3]
    else
        local closure_ready_3
        pairs_value = function(argument_1_3)
            if not closure_ready_3 then
                return
            end
            local value_2_2 = captured_value_3
            value_2_2.SalvageConfirm = argument_1_3

            return
        end
        closure_ready_3 = true
        if closure_cache[3] == nil then
            closure_cache[3] = pairs_value
            closure_cache[4] = captured_value_3
        end
    end
end
table_1.SetSalvageConfirmButton = pairs_value
do
    local captured_value_4, closure_ready_4
    pairs_value = function(argument_1_4, argument_2_2): ()
        if not closure_ready_4 then
            return
        end
        local action_nav_value, confirm_value, roblox_round_default_button_value, value_3_4, value_3_5, value_5_10, value_5_11
        local control_state = 0
        while true do
            if control_state < 5 then
                if control_state < 2 then
                    if control_state < 1 then
                        value_3_4 = captured_value_4
                        value_3_4.Mode = argument_1_4
                        control_state = if not argument_2_2 then 9 else 1
                    else
                        value_3_5 = captured_value_4
                        action_nav_value = value_3_5.ActionNav
                        confirm_value = action_nav_value.Confirm
                        control_state = if argument_1_4 ~= "Salvage" then 5 else 2
                    end
                else
                    if control_state < 3 then
                        value_5_10 = value_8
                        control_state = if not value_5_10 then 4 else 3
                    else
                        if control_state < 4 then
                            roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                            control_state = if roblox_round_default_button_value then 8 else 4
                        else
                            roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                            control_state = if roblox_round_default_button_value then 8 else 5
                        end
                    end
                end
            else
                if control_state < 7 then
                    if control_state < 6 then
                        value_5_11 = value_7
                        control_state = if not value_5_11 then 7 else 6
                    else
                        roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                        control_state = if roblox_round_default_button_value then 8 else 7
                    end
                else
                    if control_state < 8 then
                        roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                        control_state = 8
                    else
                        if control_state < 9 then
                            confirm_value.Style = roblox_round_default_button_value
                            control_state = 9
                        else
                            return
                        end
                    end
                end
            end
        end
    end
    captured_value_4 = table_1
    closure_ready_4 = true
end
table_1.ChangeMode = pairs_value
do
    local captured_value_5, captured_value_6, captured_value_7 = require_result, table_1, require_result_2
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_5) and same_capture(
        closure_cache[7],
        captured_value_6
    ) and same_capture(closure_cache[8], captured_value_7) then
        pairs_value = closure_cache[5]
    else
        local closure_ready_5
        pairs_value = function(argument_1_5)
            if not closure_ready_5 then
                return
            end
            local value_2_3: number = 0
            local value_3_6: number = 0
            local value_4_7: number = 0
            local table_5 = {}
            local value_7_2 = captured_value_5.Recipes
            local value_6_7 = value_7_2[argument_1_5].CombinationRecipe
            local value_10_15, value_11_2, value_8_2, value_9_2
            if value_6_7 then
                value_6_7 = false
                value_7_2, value_8_2, value_9_2 = pairs(captured_value_5.Recipes)
                for key_2, value_19 in value_7_2, value_8_2, value_9_2 do
                    value_10_15, value_11_2 = key_2, value_19
                    local combined_recipe_value = value_11_2.CombinedRecipe
                    if combined_recipe_value ~= argument_1_5 then
                        continue
                    end
                    local value_12_2 = captured_value_6
                    local check_has_recipe_value = value_12_2.CheckHasRecipe
                    local value_13_2 = value_10_15
                    local check_has_recipe_result, value_13_3 = check_has_recipe_value(value_13_2)
                    if check_has_recipe_result then
                        local value_14_2: boolean = true
                        local value_15_2: boolean = true

                        return value_14_2, value_15_2
                    end
                    if not value_6_7 then
                        continue
                    end
                    value_6_7 = true
                end

                return false, value_6_7
            end
            value_6_7 = pairs
            value_9_2 = captured_value_5.Recipes
            value_6_7, value_7_2, value_8_2 = value_6_7(value_9_2[argument_1_5].Materials)
            for key_3, value_20 in value_6_7, value_7_2, value_8_2 do
                value_9_2, value_10_15 = key_3, value_20
                value_4_7 = value_4_7 + 1
                local value_12_3 = captured_value_7
                local materials_value = value_12_3.Materials
                local owned_value = materials_value.Owned
                if not owned_value[value_9_2] then
                    continue
                end
                local value_12_4 = captured_value_7
                local materials_value_2 = value_12_4.Materials
                local owned_value_2 = materials_value_2.Owned
                value_11_2 = owned_value_2[value_9_2]
                local value_12_5: number = 0
                if not (value_12_5 < value_11_2) then
                    continue
                end
                value_2_3 = value_2_3 + 1
                value_11_2 = "Has"
                table_5[value_9_2] = value_11_2
                local value_12_6 = captured_value_7
                local materials_value_3 = value_12_6.Materials
                local owned_value_3 = materials_value_3.Owned
                if not (value_10_15 <= owned_value_3[value_9_2]) then
                    continue
                end
                value_3_6 = value_3_6 + 1
                value_11_2 = "Completed"
                table_5[value_9_2] = value_11_2
            end
            if not (value_4_7 <= value_3_6) then
                value_6_7 = false
            else
                value_6_7 = true
            end
            if not (0 < value_2_3) then
                value_7_2 = false
            else
                value_7_2 = true
            end
            value_8_2 = false
            value_9_2 = 0
            if value_9_2 < value_2_3 then
                if not (value_4_7 <= value_3_6) then
                    value_9_2 = false
                else
                    value_9_2 = true
                end
                value_8_2 = not value_9_2
            end

            return value_6_7, value_7_2, value_8_2, table_5
        end
        closure_ready_5 = true
        if closure_cache[5] == nil then
            closure_cache[5] = pairs_value
            closure_cache[6], closure_cache[7], closure_cache[8] = captured_value_5, captured_value_6, captured_value_7
        end
    end
end
table_1.CheckHasRecipe = pairs_value
do
    local captured_value_8, captured_value_9 = require_result, table_1
    if closure_cache[11] ~= nil and same_capture(closure_cache[12], captured_value_8) and same_capture(
        closure_cache[13],
        captured_value_9
    ) then
        pairs_value = closure_cache[11]
    else
        local closure_ready_7
        pairs_value = function()
            if not closure_ready_7 then
                return
            end
            local table_1_2 = {}
            local pairs_value_2, value_3_7, value_4_8 = pairs(captured_value_8.Recipes)
            local combined_recipe_value_2, combined_recipe_value_3, value_5_12, value_6_8
            for key_4, value_21 in pairs_value_2, value_3_7, value_4_8 do
                value_5_12, value_6_8 = key_4, value_21
                if not value_6_8.CombinedRecipe then
                    continue
                end
                combined_recipe_value_3 = value_6_8.CombinedRecipe
                combined_recipe_value_2 = table_1_2[combined_recipe_value_3]
                if combined_recipe_value_2 then
                    combined_recipe_value_3 = value_6_8.CombinedRecipe
                    combined_recipe_value_2 = table_1_2[combined_recipe_value_3]
                    combined_recipe_value_2[value_5_12] = value_6_8
                else
                    combined_recipe_value_2 = value_6_8.CombinedRecipe
                    combined_recipe_value_3 = {[value_5_12] = nil}
                    combined_recipe_value_3[value_5_12] = value_6_8
                    table_1_2[combined_recipe_value_2] = combined_recipe_value_3
                end
            end
            pairs_value_2 = {}
            value_3_7, value_4_8, value_5_12 = pairs(captured_value_8.Recipes)
            local table_10_2, value_9_3
            for key_5, value_22 in value_3_7, value_4_8, value_5_12 do
                value_6_8, combined_recipe_value_2 = key_5, value_22
                if combined_recipe_value_2.CombinedRecipe then
                    continue
                end
                table_10_2 = {ID = 0, Data = 0}
                table_10_2.ID = value_6_8
                table_10_2.Data = combined_recipe_value_2
                value_9_3 = pairs_value_2
                combined_recipe_value_3 = table.insert
                combined_recipe_value_3(value_9_3, table_10_2)
            end
            value_3_7, value_4_8, value_5_12 = pairs(table_1_2)
            for key_8, value_25 in value_3_7, value_4_8, value_5_12 do
                value_6_8, combined_recipe_value_2 = key_8, value_25
                combined_recipe_value_3, value_9_3, table_10_2 = pairs(pairs_value_2)
                for key_7, value_24 in combined_recipe_value_3, value_9_3, table_10_2 do
                    local value_11_3, value_12_7 = key_7, value_24
                    local id_value = value_12_7.ID
                    if id_value ~= value_6_8 then
                        continue
                    end
                    local table_13 = {}
                    local pairs_value_3, value_15_3, value_16_2 = pairs(combined_recipe_value_2)
                    for key_6, value_23 in pairs_value_3, value_15_3, value_16_2 do
                        local value_17_3, value_18_4 = key_6, value_23
                        local table_21 = {ID = value_17_3, Data = value_18_4}
                        local value_20_2 = table_13
                        local insert_value = table.insert
                        insert_value(value_20_2, table_21)
                    end
                    pairs_value_3 = table.sort
                    value_15_3 = table_13
                    value_16_2 = shared_function
                    pairs_value_3(value_15_3, value_16_2)
                    pairs_value_3 = pairs_value_2[value_11_3].Data
                    pairs_value_3.RecipeList = table_13
                    break
                end
            end
            value_3_7 = table.sort
            value_4_8 = pairs_value_2
            do
                local captured_value_10 = captured_value_9
                if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_10) then
                    value_5_12 = closure_cache[9]
                else
                    local closure_ready_6
                    value_5_12 = function(argument_1_7, argument_2_4)
                        if not closure_ready_6 then
                            return
                        end
                        local check_has_recipe_result_2, value_4_9, value_5_13 = captured_value_10.CheckHasRecipe(
                            argument_1_7.ID
                        )
                        local check_has_recipe_result_3, value_7_3, value_8_3 = captured_value_10.CheckHasRecipe(
                            argument_2_4.ID
                        )
                        local sort_priority_value = argument_1_7.Data.SortPriority
                        local value_9_4: boolean?
                        if not (argument_2_4.Data.SortPriority < sort_priority_value) then
                            value_9_4 = false
                        else
                            value_9_4 = true
                        end

                        return value_9_4
                    end
                    closure_ready_6 = true
                    if closure_cache[9] == nil then
                        closure_cache[9] = value_5_12
                        closure_cache[10] = captured_value_10
                    end
                end
            end
            value_3_7(value_4_8, value_5_12)

            return pairs_value_2
        end
        closure_ready_7 = true
        if closure_cache[11] == nil then
            closure_cache[11] = pairs_value
            closure_cache[12], closure_cache[13] = captured_value_8, captured_value_9
        end
    end
end
table_1.GetRecipes = pairs_value
do
    local captured_value_11, captured_value_12 = table_1, require_result_2
    if closure_cache[14] ~= nil and same_capture(closure_cache[15], captured_value_11) and same_capture(
        closure_cache[16],
        captured_value_12
    ) then
        pairs_value = closure_cache[14]
    else
        local closure_ready_8
        pairs_value = function(argument_1_8, argument_2_5, argument_3_2, argument_4_2, argument_5_2)
            if not closure_ready_8 then
                return
            end
            local value_6_10: boolean = true
            argument_3_2.Visible = value_6_10
            local value_9_5: string = "Container"
            local value_6_11 = (argument_3_2:FindFirstChild(value_9_5)) or argument_3_2
            local icon_value = value_6_11.Icon
            local image_value = argument_2_5.Image
            icon_value.Image = image_value
            if argument_5_2 then
                local check_has_recipe_result_4, value_8_6, value_9_6, value_10_16 = captured_value_11.CheckHasRecipe(
                    argument_5_2
                )
                local value_9_7 = captured_value_12.Materials.Owned[argument_1_8]
                if value_9_7 then
                    if not (0 < captured_value_12.Materials.Owned[argument_1_8]) then
                        value_9_7 = false
                    else
                        value_9_7 = true
                    end
                end
                local amount_value = value_6_11.Amount
                local value_12_10
                do
                    local take_fallback = not value_9_7
                    if not take_fallback then
                        value_12_10 = captured_value_12.Materials.Owned[argument_1_8] .. "/" .. argument_4_2
                        take_fallback = not value_12_10
                    end
                    if take_fallback then
                        value_12_10 = "x" .. argument_4_2
                    end
                end
                amount_value.Text = value_12_10
                local value_12_11 = value_10_16[argument_1_8]
                local new_result: Color3?
                do
                    local take_fallback_2 = value_12_11 ~= "Completed"
                    if not take_fallback_2 then
                        new_result = Color3.new(0, 140, 0)
                        take_fallback_2 = not new_result
                    end
                    if take_fallback_2 then
                        local value_12_13 = value_10_16[argument_1_8]
                        do
                            local take_fallback_3 = value_12_13 ~= "Has"
                            if not take_fallback_3 then
                                new_result = Color3.new(1, 1, 0)
                                take_fallback_3 = not new_result
                            end
                            if take_fallback_3 then
                                new_result = Color3.new(0, 0, 0)
                            end
                        end
                    end
                end
                value_6_11.BorderColor3 = new_result
                local value_11_6: number?
                if value_10_16[argument_1_8] then
                    value_11_6 = 2
                else
                    value_11_6 = 0
                end
                value_6_11.BorderSizePixel = value_11_6

                return
            end
            local value_8_7 = argument_4_2
            if (tonumber(value_8_7)) then
                local amount_value_2 = value_6_11.Amount
                local value_8_8 = "x" .. argument_4_2
                amount_value_2.Text = value_8_8

                return
            end
            local amount_value_3 = value_6_11.Amount
            local value_9_9 = argument_4_2[1]
            local value_10_18 = argument_4_2[2]
            local value_8_9
            do
                local take_fallback_4 = value_9_9 == value_10_18
                if not take_fallback_4 then
                    value_8_9 = argument_4_2[1] .. "-" .. argument_4_2[2]
                    take_fallback_4 = not value_8_9
                end
                if take_fallback_4 then
                    value_8_9 = argument_4_2[1]
                end
            end
            amount_value_3.Text = value_8_9

            return
        end
        closure_ready_8 = true
        if closure_cache[14] == nil then
            closure_cache[14] = pairs_value
            closure_cache[15], closure_cache[16] = captured_value_11, captured_value_12
        end
    end
end
table_1.MakeMaterialFrame = pairs_value
do
    local captured_value_13, captured_value_14 = require_result, table_1
    if closure_cache[17] ~= nil and same_capture(closure_cache[18], captured_value_13) and same_capture(
        closure_cache[19],
        captured_value_14
    ) then
        pairs_value = closure_cache[17]
    else
        local closure_ready_9
        pairs_value = function(argument_1_9, argument_2_6, argument_3_3)
            if not closure_ready_9 then
                return
            end
            local value_4_10 = captured_value_13.Recipes[argument_1_9]
            local value_5_15: number = 1
            local pairs_value_4, materials_value_7, value_8_10 = pairs(value_4_10.Materials)
            for key_9, value_26 in pairs_value_4, materials_value_7, value_8_10 do
                local value_9_11, value_10_20 = key_9, value_26
                local value_13_9: string = "Material"
                local value_14_9: number = value_5_15
                local value_12_17: string = value_13_9 .. value_14_9
                local value_11_8 = argument_2_6[value_12_17]
                local value_13_10 = captured_value_13
                local materials_value_8 = value_13_10.Materials
                local value_12_18 = materials_value_8[value_9_11]
                local value_13_11 = captured_value_14
                local make_material_frame_value = value_13_11.MakeMaterialFrame
                local value_14_10 = value_9_11
                local value_15_5 = value_12_18
                local value_16_3 = value_11_8
                local value_17_4 = value_10_20
                local value_18_5
                do
                    local take_fallback_5 = not argument_3_3
                    if not take_fallback_5 then
                        value_18_5 = argument_1_9
                        take_fallback_5 = not value_18_5
                    end
                    if take_fallback_5 then
                        value_18_5 = nil
                    end
                end
                make_material_frame_value(
                    value_14_10,
                    value_15_5,
                    value_16_3,
                    value_17_4,
                    value_18_5
                )
                value_5_15 = value_5_15 + 1
            end

            return
        end
        closure_ready_9 = true
        if closure_cache[17] == nil then
            closure_cache[17] = pairs_value
            closure_cache[18], closure_cache[19] = captured_value_13, captured_value_14
        end
    end
end
table_1.MakeMaterialFrames = pairs_value
do
    local captured_value_15, closure_ready_10
    pairs_value = function(): ()
        if not closure_ready_10 then
            return
        end
        print("pressed")
        local value_1: boolean?
        if captured_value_15.Mode ~= "Craft" then
            value_1 = false
        else
            value_1 = true
        end
        local value_2_6: nil = nil
        local value_2_7
        if value_1 then
            value_2_7 = value_7
        else
            value_2_7 = value_8
        end
        print(value_2_7, value_7, value_8, captured_value_15.Mode)
        if value_2_7 then
            captured_value_15[captured_value_15.Mode](value_2_7)
        end

        return
    end
    captured_value_15 = table_1
    closure_ready_10 = true
end
table_1.ActionConfirmButtonFunction = pairs_value
do
    local captured_value_16, captured_value_17, captured_value_18, closure_ready_11
    pairs_value = function<T2>(argument_1_10, argument_2_7: T2, argument_3_4): ()
        if not closure_ready_11 then
            return
        end
        local action_value = captured_value_16.GUI.Action
        local craft_value = action_value.Craft
        local pairs_value_5, recipe_value, value_8_11, value_9_12
        do
            local take_fallback_6 = not argument_1_10
            if take_fallback_6 or argument_3_4 then
                pairs_value_5, recipe_value, value_8_11 = pairs(craft_value.Recipe:GetChildren())
                for key_10, value_27 in pairs_value_5, recipe_value, value_8_11 do
                    local value_10_21
                    value_9_12, value_10_21 = key_10, value_27
                    local container_value = value_10_21.Container
                    local icon_value_2 = container_value.Icon
                    local value_12_19: string = ""
                    icon_value_2.Image = value_12_19
                    local container_value_2 = value_10_21.Container
                    local amount_value_4 = container_value_2.Amount
                    local value_12_20: string = ""
                    amount_value_4.Text = value_12_20
                end
                pairs_value_5 = craft_value.Reward.Container.Icon
                recipe_value = ""
                pairs_value_5.Image = recipe_value
                pairs_value_5 = craft_value.Reward.Container.Amount
                recipe_value = ""
                pairs_value_5.Text = recipe_value
                pairs_value_5 = craft_value.Reward.Container.ItemName
                recipe_value = ""
                pairs_value_5.Text = recipe_value
                pairs_value_5 = action_value.Confirm
                recipe_value = Enum.ButtonStyle.RobloxRoundButton
                pairs_value_5.Style = recipe_value
                value_7 = nil

                return
            end
        end
        pairs_value_5 = captured_value_17.Recipes[argument_1_10]
        recipe_value = captured_value_16.CheckHasRecipe(argument_1_10)
        captured_value_16.MakeMaterialFrames(argument_1_10, craft_value.Recipe)
        recipe_value = {ItemID = 0}
        value_8_11 = pairs_value_5.RewardItem or pairs_value_5
        recipe_value.ItemID = value_8_11
        captured_value_18.MakeItemFrame(craft_value.Reward.Container, recipe_value)
        value_8_11 = action_value.Confirm
        value_9_12 = Enum.ButtonStyle.RobloxRoundDefaultButton
        value_8_11.Style = value_9_12
        value_7 = argument_1_10

        return
    end
    captured_value_16, captured_value_17, captured_value_18 = table_1, require_result, require_result_4
    closure_ready_11 = true
end
table_1.UpdateCraftConfirm = pairs_value
local table_10 = {}
do
    local captured_value_19 = table_1
    if closure_cache[20] ~= nil and same_capture(closure_cache[21], captured_value_19) then
        pairs_value = closure_cache[20]
    else
        local closure_ready_12
        pairs_value = function<T1>(argument_1_11: T1, argument_2_8, argument_3_5)
            if not closure_ready_12 then
                return
            end
            local result_value
            if argument_3_5 == nil then
                result_value = argument_2_8.Result.Confirm.Visible
                argument_3_5 = not result_value
            end
            local value_5_18
            if argument_3_5 == true then
                local value_6_13
                result_value, value_5_18, value_6_13 = pairs(
                    captured_value_19.RecipesFrame.Container:GetChildren()
                )
                for key_11, value_28 in result_value, value_5_18, value_6_13 do
                    local value_7_7, value_8_12 = key_11, value_28
                    if value_8_12 == argument_2_8 then
                        continue
                    end
                    local value_9_13 = captured_value_19
                    local update_craft_confirm_mobile_value = value_9_13.UpdateCraftConfirmMobile
                    local value_10_22: nil = nil
                    local value_11_9 = value_8_12
                    local value_12_21: boolean = false
                    update_craft_confirm_mobile_value(value_10_22, value_11_9, value_12_21)
                end
            end
            if argument_2_8 then
                result_value = argument_2_8.Result.Confirm
                result_value.Visible = argument_3_5
                result_value = argument_2_8.Result.Container.Craft
                if argument_3_5 then
                    value_5_18 = "Cancel"
                else
                    value_5_18 = "Craft"
                end
                result_value.Text = value_5_18
                result_value = argument_2_8.Result.Container.Craft
                do
                    local take_fallback_7 = not argument_3_5
                    if not take_fallback_7 then
                        value_5_18 = Color3.new(1, 1, 1)
                        take_fallback_7 = not value_5_18
                    end
                    if take_fallback_7 then
                        value_5_18 = Color3.fromRGB(159, 255, 130)
                    end
                end
                result_value.TextColor3 = value_5_18
            end

            return
        end
        closure_ready_12 = true
        if closure_cache[20] == nil then
            closure_cache[20] = pairs_value
            closure_cache[21] = captured_value_19
        end
    end
end
table_1.UpdateCraftConfirmMobile = pairs_value
do
    local captured_value_20, captured_value_21 = require_result, table_11
    if closure_cache[22] ~= nil and same_capture(closure_cache[23], captured_value_20) and same_capture(
        closure_cache[24],
        captured_value_21
    ) then
        pairs_value = closure_cache[22]
    else
        local closure_ready_13
        pairs_value = function(argument_1_12)
            if not closure_ready_13 then
                return
            end
            if not argument_1_12 then
                return false
            end
            local value_2_9 = captured_value_20.SalvageRewards[argument_1_12]
            if not value_2_9 then
                value_2_9 = captured_value_20.SalvageRewards[captured_value_20.Item[argument_1_12].Rarity]
            end
            local value_3_13 = value_2_9 and value_2_9.Rewards
            local value_2_10 = not captured_value_21[argument_1_12]
            if value_2_10 then
                local event_value = captured_value_20.Item[argument_1_12].Event
                do
                    local take_fallback_8 = event_value == nil
                    if not take_fallback_8 then
                        value_2_10 = false
                        take_fallback_8 = captured_value_20.SalvageRewards[argument_1_12] ~= nil
                    end
                    if take_fallback_8 then
                        value_2_10 = false
                        if captured_value_20.Item[argument_1_12].Season == nil then
                            value_2_10 = false
                            if captured_value_20.Item[argument_1_12].ItemType ~= "Misc" then
                                value_2_10 = value_3_13
                            end
                        end
                    end
                end
            end
            local value_4_21
            do
                local take_fallback_9 = not value_2_10
                if not take_fallback_9 then
                    value_4_21 = value_3_13
                    take_fallback_9 = not value_4_21
                end
                if take_fallback_9 then
                    value_4_21 = false
                end
            end

            return value_4_21
        end
        closure_ready_13 = true
        if closure_cache[22] == nil then
            closure_cache[22] = pairs_value
            closure_cache[23], closure_cache[24] = captured_value_20, captured_value_21
        end
    end
end
table_1.CheckSalvageable = pairs_value
do
    local captured_value_22, captured_value_23, captured_value_24, captured_value_25, closure_ready_14
    pairs_value = function(argument_1_13): ()
        if not closure_ready_14 then
            return
        end
        local check_salvageable_result = captured_value_22.CheckSalvageable(argument_1_13)
        local make_item_frame_value = captured_value_23.MakeItemFrame
        local value_4_22 = captured_value_22.SalvageConfirmFrame
        local table_5_2 = {ItemID = argument_1_13}
        make_item_frame_value(value_4_22, table_5_2)
        local item_name_value = captured_value_22.SalvageConfirmFrame.Icon.ItemName
        local value_6_14, value_7_8
        do
            local take_fallback_10 = not check_salvageable_result
            if not take_fallback_10 then
                table_5_2 = captured_value_24
                value_7_8 = captured_value_25.Item
                value_6_14 = value_7_8[argument_1_13].Rarity
                value_4_22 = table_5_2[value_6_14]
                take_fallback_10 = not value_4_22
            end
            if take_fallback_10 then
                value_4_22 = Color3.new
                table_5_2 = 0.5
                value_6_14 = 0.5
                value_7_8 = 0.5
                value_4_22 = value_4_22(table_5_2, value_6_14, value_7_8)
            end
        end
        item_name_value.TextColor3 = value_4_22
        local icon_value_4 = captured_value_22.SalvageConfirmFrame.Icon
        do
            local take_fallback_11 = not check_salvageable_result
            if not take_fallback_11 then
                value_4_22 = Color3.new
                table_5_2 = 1
                value_6_14 = 1
                value_7_8 = 1
                value_4_22 = value_4_22(table_5_2, value_6_14, value_7_8)
                take_fallback_11 = not value_4_22
            end
            if take_fallback_11 then
                value_4_22 = Color3.new
                table_5_2 = 0.2
                value_6_14 = 0.2
                value_7_8 = 0.2
                value_4_22 = value_4_22(table_5_2, value_6_14, value_7_8)
            end
        end
        icon_value_4.ImageColor3 = value_4_22
        local salvage_confirm_frame_value_3 = captured_value_22.SalvageConfirmFrame
        table_5_2 = "Rewards"
        local rewards_child = salvage_confirm_frame_value_3:FindFirstChild(table_5_2)
        if not rewards_child then
            rewards_child = captured_value_22.SalvageConfirmFrame
        end
        value_4_22, table_5_2, value_6_14 = pairs(rewards_child:GetChildren())
        local value_8_13, value_9_14
        for key_12, value_29 in value_4_22, table_5_2, value_6_14 do
            value_7_8, value_8_13 = key_12, value_29
            value_9_14 = false
            value_8_13.Visible = value_9_14
        end
        value_4_22 = print
        value_6_14 = check_salvageable_result
        table_5_2 = tostring(value_6_14)
        value_4_22(table_5_2)
        if check_salvageable_result then
            value_8 = argument_1_13
            value_4_22 = 1
            table_5_2, value_6_14, value_7_8 = pairs(check_salvageable_result)
            for key_13, value_30 in table_5_2, value_6_14, value_7_8 do
                value_8_13, value_9_14 = key_13, value_30
                local value_12_22: string = "Material"
                local value_13_12: number = value_4_22
                local value_11_10: string = value_12_22 .. value_13_12
                local value_10_23 = rewards_child[value_11_10]
                local value_11_11 = captured_value_22
                local make_material_frame_value_2 = value_11_11.MakeMaterialFrame
                local value_12_23 = value_8_13
                local value_14_11 = captured_value_25
                local materials_value_9 = value_14_11.Materials
                local value_13_13 = materials_value_9[value_8_13]
                local value_14_12 = value_10_23
                local amount_value_5 = value_9_14.Amount
                make_material_frame_value_2(value_12_23, value_13_13, value_14_12, amount_value_5)
                value_4_22 = value_4_22 + 1
            end
            table_5_2 = print
            value_7_8 = value_8
            table_5_2((tostring(value_7_8)))
        else
            value_8 = nil
        end
        value_4_22 = captured_value_22.SalvageConfirmButton
        value_6_14 = value_8
        do
            local take_fallback_12 = not value_6_14
            if not take_fallback_12 then
                table_5_2 = Enum.ButtonStyle.RobloxRoundDefaultButton
                take_fallback_12 = not table_5_2
            end
            if take_fallback_12 then
                table_5_2 = Enum.ButtonStyle.RobloxRoundButton
            end
        end
        value_4_22.Style = table_5_2

        return
    end
    captured_value_22, captured_value_23, captured_value_24, captured_value_25 = table_1, require_result_4, rarity_value, require_result
    closure_ready_14 = true
end
table_1.ShowSalvageRewards = pairs_value
do
    local captured_value_26 = table_1
    if closure_cache[25] ~= nil and same_capture(closure_cache[26], captured_value_26) then
        pairs_value = closure_cache[25]
    else
        local closure_ready_15
        pairs_value = function(argument_1_14, argument_2_9)
            if not closure_ready_15 then
                return
            end
            local value_3_21: boolean = not argument_2_9.Cancel.Visible
            local cancel_value, value_5_25, value_6_15 = pairs(
                captured_value_26.SalvageInventoryFrame.Container:GetChildren()
            )
            for key_14, value_31 in cancel_value, value_5_25, value_6_15 do
                local value_7_9, value_8_14 = key_14, value_31
                local container_value_3 = value_8_14.Container
                local cancel_value_2 = container_value_3.Cancel
                local value_10_24: boolean = false
                cancel_value_2.Visible = value_10_24
                local container_value_4 = value_8_14.Container
                local from_rgb_value: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                local value_11_12: number = 54
                local value_12_24: number = 54
                local value_13_14: number = 54
                local from_rgb_result: Color3 = from_rgb_value(
                    value_11_12,
                    value_12_24,
                    value_13_14
                )
                container_value_4.BackgroundColor3 = from_rgb_result
            end
            cancel_value = argument_2_9.Cancel
            cancel_value.Visible = value_3_21
            do
                local take_fallback_13 = not value_3_21
                if not take_fallback_13 then
                    cancel_value = Color3.fromRGB(130, 130, 130)
                    take_fallback_13 = not cancel_value
                end
                if take_fallback_13 then
                    cancel_value = Color3.fromRGB(54, 54, 54)
                end
            end
            argument_2_9.BackgroundColor3 = cancel_value
            if value_3_21 then
                captured_value_26.ShowSalvageRewards(argument_1_14)
            else
                captured_value_26.ShowSalvageRewards(nil)
            end
            cancel_value = captured_value_26.SalvageConfirmFrame
            cancel_value.Visible = value_3_21

            return
        end
        closure_ready_15 = true
        if closure_cache[25] == nil then
            closure_cache[25] = pairs_value
            closure_cache[26] = captured_value_26
        end
    end
end
table_1.SalvageConfirmMobile = pairs_value
do
    local captured_value_27, captured_value_28 = require_result_4, table_1
    if closure_cache[27] ~= nil and same_capture(closure_cache[28], captured_value_27) and same_capture(
        closure_cache[29],
        captured_value_28
    ) then
        pairs_value = closure_cache[27]
    else
        local closure_ready_18
        pairs_value = function(argument_1_15, argument_2_10)
            if not closure_ready_18 then
                return
            end
            captured_value_27.MakeItemFrame(argument_1_15, argument_2_10)
            local item_id_value = argument_2_10.ItemID
            local check_salvageable_result_2 = captured_value_28.CheckSalvageable(item_id_value)
            local cover_value = argument_1_15.Container.Cover
            local value_6_16: boolean = not check_salvageable_result_2
            cover_value.Visible = value_6_16
            local container_value_6 = argument_1_15.Container
            local value_7_10: string = "Cancel"
            if (container_value_6:FindFirstChild(value_7_10)) then
                local mouse_button1_click_value_2 = argument_1_15.Container.Cancel.MouseButton1Click
                local value_7_11: (() -> ())?
                do
                    local captured_value_29, captured_value_30, closure_ready_16
                    value_7_11 = function(): ()
                        if not closure_ready_16 then
                            return
                        end
                        local cancel_value_4 = captured_value_29.Container.Cancel
                        local value_2_12: boolean = false
                        cancel_value_4.Visible = value_2_12
                        local container_value_10 = captured_value_29.Container
                        local from_rgb_result_2: Color3 = Color3.fromRGB(54, 54, 54)
                        container_value_10.BackgroundColor3 = from_rgb_result_2
                        local salvage_confirm_frame_value_4 = captured_value_30.SalvageConfirmFrame
                        local value_2_13: boolean = false
                        salvage_confirm_frame_value_4.Visible = value_2_13

                        return
                    end
                    captured_value_29, captured_value_30 = argument_1_15, captured_value_28
                    closure_ready_16 = true
                end
                mouse_button1_click_value_2:connect(value_7_11)
            end
            local mouse_button1_click_value_3 = argument_1_15.Container.Button.MouseButton1Click
            local value_7_12: (() -> ())?
            do
                local captured_value_31, captured_value_32, captured_value_33, closure_ready_17
                value_7_12 = function(): ()
                    if not closure_ready_17 then
                        return
                    end
                    captured_value_31.SalvageConfirm(
                        captured_value_32,
                        captured_value_33.Container
                    )

                    return
                end
                captured_value_31, captured_value_32, captured_value_33 = captured_value_28, item_id_value, argument_1_15
                closure_ready_17 = true
            end
            mouse_button1_click_value_3:connect(value_7_12)

            return
        end
        closure_ready_18 = true
        if closure_cache[27] == nil then
            closure_cache[27] = pairs_value
            closure_cache[28], closure_cache[29] = captured_value_27, captured_value_28
        end
    end
end
table_1.MakeSalvageItemFrame = pairs_value
do
    local captured_value_34, captured_value_35, captured_value_36 = require_result, rarity_value, table_1
    if closure_cache[30] ~= nil and same_capture(closure_cache[31], captured_value_34) and same_capture(
        closure_cache[32],
        captured_value_35
    ) and same_capture(closure_cache[33], captured_value_36) then
        pairs_value = closure_cache[30]
    else
        local closure_ready_21
        pairs_value = function<T3>(argument_1_16, argument_2_11, argument_3_6: T3)
            if not closure_ready_21 then
                return
            end
            local data_value_3 = argument_2_11.Data
            local id_value_6 = argument_2_11.ID
            local materials_value_10 = captured_value_34.Materials
            if not data_value_3.CombinationRecipe then
                local recipe_name_value = argument_1_16.RecipeName
                local name_value = data_value_3.Name
                recipe_name_value.Text = name_value
                local recipe_name_value_2 = argument_1_16.RecipeName
                local value_8_15 = captured_value_35[data_value_3.Rarity]
                recipe_name_value_2.TextColor3 = value_8_15
                local icon_value_5 = argument_1_16.Result.Container.Icon
                local image_value_2 = data_value_3.Image
                icon_value_5.Image = image_value_2
                captured_value_36.MakeMaterialFrames(id_value_6, argument_1_16.Materials, true)
                local check_has_recipe_result_5, value_8_18, value_9_16 = captured_value_36.CheckHasRecipe(
                    id_value_6
                )
                if check_has_recipe_result_5 then
                    local complete_value = argument_1_16.Complete
                    local value_11_13: boolean = true
                    complete_value.Visible = value_11_13
                    local craft_value_2 = argument_1_16.Result.Container.Craft
                    local value_11_14: boolean = true
                    craft_value_2.Visible = value_11_14
                    local mouse_button1_click_value_4 = argument_1_16.Result.Container.Craft.MouseButton1Click
                    local value_12_25: (() -> ())?
                    do
                        local captured_value_37, captured_value_38, captured_value_39, closure_ready_19
                        value_12_25 = function(): ()
                            if not closure_ready_19 then
                                return
                            end
                            captured_value_37.CraftConfirm(captured_value_38, captured_value_39)

                            return
                        end
                        captured_value_37, captured_value_38, captured_value_39 = captured_value_36, id_value_6, argument_1_16
                        closure_ready_19 = true
                    end
                    mouse_button1_click_value_4:connect(value_12_25)
                else
                    if value_8_18 then
                        local in_progress_value = argument_1_16.InProgress
                        local value_11_16: boolean = true
                        in_progress_value.Visible = value_11_16
                    end
                end
                local result_value_5 = argument_1_16.Result
                local value_12_26: string = "Confirm"
                if (result_value_5:FindFirstChild(value_12_26)) then
                    local mouse_button1_click_value_5 = argument_1_16.Result.Confirm.MouseButton1Click
                    local value_12_27: (() -> ())?
                    do
                        local captured_value_40, captured_value_41, closure_ready_20
                        value_12_27 = function(): ()
                            if not closure_ready_20 then
                                return
                            end
                            captured_value_40.Craft(captured_value_41, true)

                            return
                        end
                        captured_value_40, captured_value_41 = captured_value_36, id_value_6
                        closure_ready_20 = true
                    end
                    mouse_button1_click_value_5:connect(value_12_27)
                end
                local missing_value = argument_1_16.Missing
                local value_11_19: boolean = not value_8_18
                missing_value.Visible = value_11_19
            end

            return
        end
        closure_ready_21 = true
        if closure_cache[30] == nil then
            closure_cache[30] = pairs_value
            closure_cache[31], closure_cache[32], closure_cache[33] = captured_value_34, captured_value_35, captured_value_36
        end
    end
end
table_1.CreateRecipeFrame = pairs_value
pairs_value = false
value_13 = false
do
    local captured_value_42, captured_value_43, closure_ready_22
    value_14 = function(): ()
        if not closure_ready_22 then
            return
        end
        pairs_value = false
        captured_value_42.CreateGrid(
            captured_value_43.MakeSalvageItemFrame,
            captured_value_43.NewItemFrame,
            (captured_value_42.GetSortedInventory()),
            captured_value_43.SalvageInventoryFrame
        )

        return
    end
    captured_value_42, captured_value_43 = require_result_4, table_1
    closure_ready_22 = true
end
table_1.GenerateSalvageInventory = value_14
do
    local captured_value_44, captured_value_45 = require_result_4, table_1
    if closure_cache[34] ~= nil and same_capture(closure_cache[35], captured_value_44) and same_capture(
        closure_cache[36],
        captured_value_45
    ) then
        value_14 = closure_cache[34]
    else
        local closure_ready_23
        value_14 = function()
            if not closure_ready_23 then
                return
            end
            captured_value_44.CreateList(
                captured_value_45.CreateRecipeFrame,
                captured_value_45.NewRecipeFrame,
                (captured_value_45.GetRecipes()),
                captured_value_45.RecipesFrame
            )

            return
        end
        closure_ready_23 = true
        if closure_cache[34] == nil then
            closure_cache[34] = value_14
            closure_cache[35], closure_cache[36] = captured_value_44, captured_value_45
        end
    end
end
table_1.GenerateRecipes = value_14

local function is_on_screen(argument_1_17)
    while true do
        if not argument_1_17 then
            break
        end
        local value_4_28: string = "GuiObject"
        local is_a_result = argument_1_17:IsA(value_4_28)
        if is_a_result then
            local visible_value = argument_1_17.Visible
            if not visible_value then
                local value_2_20: boolean = false

                return value_2_20
            end
        end
        local value_4_29: string = "LayerCollector"
        local is_a_result_2 = argument_1_17:IsA(value_4_29)
        if is_a_result_2 then
            local enabled_value = argument_1_17.Enabled

            return enabled_value
        end
        argument_1_17 = argument_1_17.Parent
    end

    return false
end

do
    local captured_value_46, captured_value_47, closure_ready_25
    value_14 = function(): ()
        if not closure_ready_25 then
            return
        end
        local value_1_11 = pairs_value
        do
            local take_fallback_14 = not value_1_11
            if not take_fallback_14 then
                take_fallback_14 = value_13
            end
            if take_fallback_14 then
                return
            end
        end
        local salvage_inventory_frame_value_2 = captured_value_46.SalvageInventoryFrame
        do
            local take_fallback_15 = not salvage_inventory_frame_value_2
            if not take_fallback_15 then
                take_fallback_15 = not (captured_value_47(captured_value_46.SalvageInventoryFrame))
            end
            if take_fallback_15 then
                return
            end
        end
        value_13 = true
        local defer_value = task.defer
        local value_2_24: (() -> ())?
        do
            local captured_value_48, closure_ready_24
            value_2_24 = function(): ()
                if not closure_ready_24 then
                    return
                end
                value_13 = false
                if pairs_value then
                    captured_value_48.GenerateSalvageInventory()
                end

                return
            end
            captured_value_48 = captured_value_46
            closure_ready_24 = true
        end
        defer_value(value_2_24)

        return
    end
    captured_value_46, captured_value_47 = table_1, is_on_screen
    closure_ready_25 = true
end
do
    local captured_value_49, captured_value_50 = table_1, value_14
    if closure_cache[37] ~= nil and same_capture(closure_cache[38], captured_value_49) and same_capture(
        closure_cache[39],
        captured_value_50
    ) then
        value_15 = closure_cache[37]
    else
        local closure_ready_26
        value_15 = function()
            if not closure_ready_26 then
                return
            end
            local salvage_inventory_frame_value_4 = captured_value_49.SalvageInventoryFrame
            while true do
                if not salvage_inventory_frame_value_4 then
                    break
                end
                local value_4_30: string = "LayerCollector"
                local is_a_result_3 = salvage_inventory_frame_value_4:IsA(value_4_30)
                if is_a_result_3 then
                    break
                end
                local value_4_31: string = "GuiObject"
                local is_a_result_4 = salvage_inventory_frame_value_4:IsA(value_4_31)
                if is_a_result_4 then
                    local value_4_32: string = "Visible"
                    local get_property_changed_signal_result = salvage_inventory_frame_value_4:GetPropertyChangedSignal(
                        value_4_32
                    )
                    local value_4_33: () -> () = captured_value_50
                    get_property_changed_signal_result:Connect(value_4_33)
                end
                salvage_inventory_frame_value_4 = salvage_inventory_frame_value_4.Parent
            end

            return
        end
        closure_ready_26 = true
        if closure_cache[37] == nil then
            closure_cache[37] = value_15
            closure_cache[38], closure_cache[39] = captured_value_49, captured_value_50
        end
    end
end
table_1.WatchSalvageGridVisibility = value_15
value_16 = game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged.Event
local value_18_2
do
    local captured_value_51, closure_ready_27
    value_18_2 = function<T2, T3>(argument_1_18, argument_2_12: T2, argument_3_7: T3): ()
        if not closure_ready_27 then
            return
        end
        if argument_1_18 == "Weapons" then
            pairs_value = true
            captured_value_51()
        end

        return
    end
    captured_value_51 = value_14
    closure_ready_27 = true
end
value_16:Connect(value_18_2)
value_16 = game.ReplicatedStorage.Remotes.Inventory.UpdateSalvageClient.Event

local function value_18_3(): ()
    return
end

value_16:connect(value_18_3)
do
    local captured_value_52, captured_value_53, captured_value_54, captured_value_55, closure_ready_28
    value_16 = function(): ()
        if not closure_ready_28 then
            return
        end
        local salvage_gui_value = captured_value_52.SalvageGUI
        local claim_value = salvage_gui_value.Claim
        local roblox_round_button_value = Enum.ButtonStyle.RobloxRoundButton
        claim_value.Style = roblox_round_button_value
        local claim_value_2 = salvage_gui_value.Claim
        local value_3_35: string = "Salvaging..."
        claim_value_2.Text = value_3_35
        local gui_value_2 = captured_value_52.GUI
        local value_3_36: boolean = false
        gui_value_2.Visible = value_3_36
        _G.Process("Salvaging")
        local time_result = time()
        local salvage_value = game.ReplicatedStorage.Remotes.Inventory.Salvage
        local value_5_34 = value_8
        local invoke_server_result = salvage_value:InvokeServer(value_5_34)
        local value_4_37 = value_8
        value_8 = nil
        captured_value_52.ShowSalvageRewards(nil)
        captured_value_52.GenerateSalvageInventory()
        captured_value_52.GenerateRecipes()
        local container_value_15 = salvage_gui_value.Main.Item1.Container
        local container_value_16 = salvage_gui_value.Main.Item2.Container
        local container_value_17 = salvage_gui_value.Main.Item3.Container
        local icon_value_6 = container_value_15.Icon
        local value_9_17 = ""
        icon_value_6.Image = value_9_17
        icon_value_6 = container_value_15.ItemName
        value_9_17 = ""
        icon_value_6.Text = value_9_17
        icon_value_6 = container_value_16.Icon
        value_9_17 = ""
        icon_value_6.Image = value_9_17
        icon_value_6 = container_value_16.ItemName
        value_9_17 = ""
        icon_value_6.Text = value_9_17
        icon_value_6 = container_value_17.Icon
        value_9_17 = ""
        icon_value_6.Image = value_9_17
        icon_value_6 = container_value_17.ItemName
        value_9_17 = ""
        icon_value_6.Text = value_9_17
        icon_value_6 = wait
        local time_value_2 = time()
        local value_10_29 = time_value_2 - time_result
        value_9_17 = 0.75 - value_10_29
        icon_value_6(value_9_17)
        if invoke_server_result then
            _G.Process(nil)
            icon_value_6 = container_value_15.Icon
            value_9_17 = captured_value_53.GetImage(captured_value_54.Item[value_4_37].Image)
            icon_value_6.Image = value_9_17
            icon_value_6 = container_value_15.ItemName
            value_9_17 = captured_value_54.Item[value_4_37].ItemName
            icon_value_6.Text = value_9_17
            icon_value_6 = container_value_15.ItemName
            value_9_17 = captured_value_55[captured_value_54.Item[value_4_37].Rarity]
            icon_value_6.TextColor3 = value_9_17
            icon_value_6 = true
            salvage_gui_value.Visible = icon_value_6
            wait(0.5)
            icon_value_6 = container_value_15.Slider
            value_10_29 = UDim2.new(0, 0, 0, 0)
            time_value_2 = "Out"
            local value_12_28 = "Quad"
            local value_13_16: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_16)
            icon_value_6 = container_value_16.Slider
            value_10_29 = UDim2.new(0, 0, 0, 0)
            time_value_2 = "Out"
            value_12_28 = "Quad"
            local value_13_18: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_18)
            icon_value_6 = container_value_17.Slider
            value_10_29 = UDim2.new(0, 0, 0, 0)
            time_value_2 = "Out"
            value_12_28 = "Quad"
            local value_13_20: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_20)
            wait(0.5)
            icon_value_6, value_9_17, value_10_29 = pairs(invoke_server_result)
            for key_15, value_32 in icon_value_6, value_9_17, value_10_29 do
                time_value_2, value_12_28 = key_15, value_32
                local main_value_4 = salvage_gui_value.Main
                local value_15_6: string = "Item"
                local value_16_4 = time_value_2
                local value_14_16 = value_15_6 .. value_16_4
                local value_2_30 = main_value_4[value_14_16]
                local container_value_18 = value_2_30.Container
                local icon_value_7 = container_value_18.Icon
                local value_15_7 = captured_value_54
                local materials_value_12 = value_15_7.Materials
                local id_value_7 = value_12_28.ID
                local value_14_17 = materials_value_12[id_value_7]
                local image_value_3 = value_14_17.Image
                icon_value_7.Image = image_value_3
                local item_name_value_2 = container_value_18.ItemName
                local value_16_5 = captured_value_54
                local materials_value_13 = value_16_5.Materials
                local id_value_8 = value_12_28.ID
                local value_15_8 = materials_value_13[id_value_8]
                local name_value_2 = value_15_8.Name
                local value_16_6: string = " [x"
                local amount_value_6 = value_12_28.Amount
                local value_18_6: string = "]"
                local value_14_18 = name_value_2 .. value_16_6 .. amount_value_6 .. value_18_6
                item_name_value_2.Text = value_14_18
                local item_name_value_3 = container_value_18.ItemName
                local value_15_9 = captured_value_55
                local value_17_5 = captured_value_54
                local materials_value_14 = value_17_5.Materials
                local id_value_9 = value_12_28.ID
                local value_16_7 = materials_value_14[id_value_9]
                local rarity_value_4 = value_16_7.Rarity
                local value_14_19 = value_15_9[rarity_value_4]
                item_name_value_3.TextColor3 = value_14_19
            end
            icon_value_6 = container_value_15.Slider
            value_10_29 = UDim2.new(0, 0, -1, 0)
            time_value_2 = "Out"
            value_12_28 = "Quad"
            local value_13_22: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_22)
            icon_value_6 = container_value_16.Slider
            value_10_29 = UDim2.new(0, 0, -1, 0)
            time_value_2 = "Out"
            value_12_28 = "Quad"
            local value_13_24: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_24)
            icon_value_6 = container_value_17.Slider
            value_10_29 = UDim2.new(0, 0, -1, 0)
            time_value_2 = "Out"
            value_12_28 = "Quad"
            local value_13_26: number = 0.2
            icon_value_6:TweenPosition(value_10_29, time_value_2, value_12_28, value_13_26)
            wait(0.4)
            icon_value_6 = salvage_gui_value.Claim
            value_9_17 = Enum.ButtonStyle.RobloxRoundDefaultButton
            icon_value_6.Style = value_9_17
            icon_value_6 = salvage_gui_value.Claim
            value_9_17 = "Claim!"
            icon_value_6.Text = value_9_17
        end

        return
    end
    captured_value_52, captured_value_53, captured_value_54, captured_value_55 = table_1, require_result_4, require_result, rarity_value
    closure_ready_28 = true
end
table_1.Salvage = value_16
do
    local captured_value_56, captured_value_57 = table_1, require_result_3
    if closure_cache[40] ~= nil and same_capture(closure_cache[41], captured_value_56) and same_capture(
        closure_cache[42],
        captured_value_57
    ) then
        value_16 = closure_cache[40]
    else
        local closure_ready_29
        value_16 = function<T2>(argument_1_19, argument_2_13: T2)
            if not closure_ready_29 then
                return
            end
            local gui_value_3 = captured_value_56.GUI
            local value_4_38: boolean = false
            gui_value_3.Visible = value_4_38
            _G.Process("Crafting")
            local time_result_2 = time()
            local craft_value_5 = game.ReplicatedStorage.Remotes.Inventory.Craft
            local value_6_22 = argument_1_19
            local invoke_server_result_2, value_5_40, value_6_23 = craft_value_5:InvokeServer(
                value_6_22
            )
            captured_value_56.GenerateRecipes()
            if not (captured_value_56.CheckHasRecipe(argument_1_19)) then
                captured_value_56.CraftConfirm(nil, nil, true)
            end
            wait(0.75 - ((time()) - time_result_2))
            _G.Process(nil)
            local gui_value_4 = captured_value_56.GUI
            local value_9_21: boolean = true
            gui_value_4.Visible = value_9_21
            if _G.ViewLobbyFrame ~= nil then
                _G.ViewLobbyFrame("Inventory")
            end
            if invoke_server_result_2 then
                local value_8_22 = captured_value_57
                local value_10_32 = invoke_server_result_2
                local value_11_21 = value_6_23
                local value_12_29 = value_5_40
                value_8_22:AddNewItem(value_10_32, value_11_21, value_12_29)
            end
            game.ReplicatedStorage.Remotes.Inventory.UpdateSalvageClient:Fire()

            return
        end
        closure_ready_29 = true
        if closure_cache[40] == nil then
            closure_cache[40] = value_16
            closure_cache[41], closure_cache[42] = captured_value_56, captured_value_57
        end
    end
end
table_1.Craft = value_16

return table_1
