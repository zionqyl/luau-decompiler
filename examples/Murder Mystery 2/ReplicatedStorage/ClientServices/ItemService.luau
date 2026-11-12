--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
    [("BaseItemFrame")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local from_rgb_result: Color3 = Color3.fromRGB(95, 95, 95)
local script_value: LuaSourceContainer = script
local value_6_2: string = "ItemFrame"
local item_frame_child: Instance? = script_value:WaitForChild(value_6_2)
local script_value_2: LuaSourceContainer = script
local value_7: string = "MiniItemFrame"
local mini_item_frame_child: Instance? = script_value_2:WaitForChild(value_7)
local table_5 = {
    Unique = 100000,
    Ancient = 200000,
    Godly = 300000,
    Legendary = 400000,
    Rare = 500000,
    Uncommon = 600000,
    Common = 700000,
}
table_1.BaseItemFrame = item_frame_child

local function get_item_name_order(argument_1: string)
    local lower_result = string.lower(argument_1)
    local value_3_5 = 0
    local value_5_7 = #lower_result
    local value_6_4: number = 3
    local min_result = math.min(value_5_7, value_6_4)
    local value_7_2: number = 1
    value_5_7 = min_result
    value_6_4 = 1
    for index = value_7_2, value_5_7, value_6_4 do
        value_7_2 = index
        local value_11 = lower_result
        local value_12: number = value_7_2
        local byte_value = string.byte
        local byte_result = byte_value(value_11, value_12)
        local value_9 = byte_result - 97
        local value_8 = value_9 + 1
        local value_9_2 = value_3_5 * 26
        value_3_5 = value_9_2 + value_8
    end

    return value_3_5
end

local find_item_info
do
    local captured_value = require_result
    find_item_info = function<T1>(argument_1_2: T1, argument_2: string, argument_3: string)
        if not captured_value[argument_3] then
            return nil
        end
        local value_5_10: nil = nil
        if argument_3 == "Emotes" then
            local value_6_5 = captured_value.Emotes[argument_2]
            if not value_6_5 then
                value_6_5 = captured_value.Toys[argument_2]
            end

            return value_6_5
        end

        return captured_value[argument_3][argument_2]
    end
end
table_1.FindItemInfo = find_item_info
local get_item_info
do
    local captured_value_2 = require_result
    get_item_info = function<T1>(argument_1_3: T1, argument_2_2: string, argument_3_2: string)
        local value_4_7 = nil
        if argument_3_2 == "Emotes" then
            local value_5_12 = captured_value_2.Emotes[argument_2_2]
            if not value_5_12 then
                value_5_12 = captured_value_2.Toys[argument_2_2]
            end
            value_4_7 = value_5_12
        else
            if captured_value_2[argument_3_2] then
                value_4_7 = captured_value_2[argument_3_2][argument_2_2]
            end
        end
        if value_4_7 then
            return value_4_7
        end
        local warn_value = warn
        local value_7_6: string = "ItemService: Failed to find data for item: "
        local value_9_3: string = argument_2_2
        local tostring_result = tostring(value_9_3)
        local value_9_4: string = ", "
        local value_11_2: string = argument_3_2
        warn_value(value_7_6 .. tostring_result .. value_9_4 .. (tostring(value_11_2)))

        return captured_value_2.Materials.ErrorItem
    end
end
table_1.GetItemInfo = get_item_info
local item_exists: (<T1>(T1, string, string) -> (boolean))?
do
    local captured_value_3 = require_result
    item_exists = function<T1>(argument_1_4: T1, argument_2_3: string, argument_3_3: string): boolean
        local value_4_8: boolean?
        if captured_value_3[argument_3_3][argument_2_3] == nil then
            value_4_8 = false
        else
            value_4_8 = true
        end

        return value_4_8
    end
end
table_1.ItemExists = item_exists
local get_rarity_color
do
    local captured_value_4, captured_value_5 = from_rgb_result, require_result
    get_rarity_color = function<T1>(argument_1_5: T1, argument_2_4)
        local rarity_value = argument_2_4.Rarity
        do
            local take_fallback = rarity_value == "Common"
            if take_fallback or rarity_value == nil then
                return captured_value_4
            end
        end

        return captured_value_5.Rarity[rarity_value]
    end
end
table_1.GetRarityColor = get_rarity_color
local get_display_info
do
    local captured_value_6 = table_1
    get_display_info = function<T1>(argument_1_6: T1, argument_2_5: string, argument_3_4: string)
        local value_4_11 = captured_value_6
        local value_6_13: string = argument_2_5
        local value_7_8: string = argument_3_4
        local get_item_info_result = value_4_11:GetItemInfo(value_6_13, value_7_8)
        local table_5_2 = {
            Name = 0,
            Image = 0,
            Color = 0,
            Chroma = 0,
        }
        local value_6_14 = captured_value_6
        local value_8_3 = get_item_info_result
        local get_display_name_result = value_6_14:GetDisplayName(value_8_3)
        table_5_2.Name = get_display_name_result
        local value_6_16 = captured_value_6
        local value_8_4 = get_item_info_result
        local get_item_image_result = value_6_16:GetItemImage(value_8_4)
        table_5_2.Image = get_item_image_result
        local value_6_18 = captured_value_6
        local value_8_5 = get_item_info_result
        local get_rarity_color_result = value_6_18:GetRarityColor(value_8_5)
        table_5_2.Color = get_rarity_color_result
        local chroma_value = get_item_info_result.Chroma
        table_5_2.Chroma = chroma_value

        return table_5_2
    end
end
table_1.GetDisplayInfo = get_display_info

local function get_display_name<T1>(argument_1_7: T1, argument_2_6)
    local name_value = argument_2_6.Name
    if not name_value then
        name_value = argument_2_6.DisplayName or argument_2_6.ItemName
    end

    return name_value
end

table_1.GetDisplayName = get_display_name

local function get_item_image<T1>(argument_1_8: T1, argument_2_7)
    local image_value = argument_2_7.Image or argument_2_7.Icon
    local value_5_19 = image_value
    local tonumber_result = tonumber(value_5_19)
    if tonumber_result then
        return "rbxthumb://type=Asset&w=150&h=150&id=" .. tonumber_result
    end
    local value_6_21 = image_value
    if (typeof(value_6_21)) == "string" then
        return image_value
    end

    return ""
end

table_1.GetItemImage = get_item_image

local function get_amount_text<T1>(argument_1_9: T1, argument_2_8: number): string?
    local value_4_13: number = 1
    local value_3_6: string?
    do
        local take_fallback_2 = not (value_4_13 < argument_2_8)
        if not take_fallback_2 then
            value_3_6 = "x" .. argument_2_8
            take_fallback_2 = not value_3_6
        end
        if take_fallback_2 then
            value_3_6 = ""
        end
    end

    return value_3_6
end

table_1.GetAmountText = get_amount_text
local get_layout_order
do
    local captured_value_7, captured_value_8, captured_value_9 = table_1, table_5, get_item_name_order
    get_layout_order = function<T1>(argument_1_10: T1, argument_2_9: string, argument_3_5: string)
        if argument_3_5 == "DefaultKnife" then
            return 0
        end
        if argument_3_5 == "DefaultGun" then
            return 1
        end
        local value_4_17 = captured_value_7
        local value_6_22: string = argument_2_9
        local value_7_13: string = argument_3_5
        local get_item_info_result_2 = value_4_17:GetItemInfo(value_6_22, value_7_13)
        local rarity_value_3 = get_item_info_result_2.Rarity
        local value_7_14 = captured_value_7
        local value_9_5 = get_item_info_result_2
        local value_6_23 = (value_7_14:GetDisplayName(value_9_5)) or ""

        return (captured_value_8[rarity_value_3] or 700000) + (captured_value_9(value_6_23))
    end
end
table_1.GetLayoutOrder = get_layout_order

local function update_tags<T1>(argument_1_11: T1, argument_2_10, argument_3_6): number
    local value_4_21 = argument_3_6 or ({})
    local tags_value = argument_2_10.Tags.Chroma
    local value_6_24
    if value_4_21.Chroma ~= true then
        value_6_24 = false
    else
        value_6_24 = true
    end
    tags_value.Visible = value_6_24
    tags_value = argument_2_10.Tags.FX
    if value_4_21.FX ~= true then
        value_6_24 = false
    else
        value_6_24 = true
    end
    tags_value.Visible = value_6_24
    tags_value = argument_2_10.Tags.Evo
    if value_4_21.EvoBaseID == nil then
        value_6_24 = false
    else
        value_6_24 = true
    end
    tags_value.Visible = value_6_24
    local value_4_22: number = 0
    local chroma_value_2
    tags_value, value_6_24, chroma_value_2 = argument_2_10.Tags:GetChildren()
    for key, value in tags_value, value_6_24, chroma_value_2 do
        local value_8_9, value_9_6 = key, value
        local value_12_2: string = "Frame"
        local is_a_result = value_9_6:IsA(value_12_2)
        if not is_a_result then
            continue
        end
        local visible_value = value_9_6.Visible
        if not visible_value then
            continue
        end
        value_4_22 = value_4_22 + 1
    end

    return value_4_22
end

table_1.UpdateTags = update_tags
local apply_tags
do
    local captured_value_10 = table_1
    apply_tags = function<T1>(argument_1_12: T1, argument_2_11, argument_3_7)
        local value_4_23 = captured_value_10
        local value_6_25 = argument_2_11
        local value_7_19 = argument_3_7
        if (value_4_23:UpdateTags(value_6_25, value_7_19)) < 1 then
            argument_2_11.Tags:Destroy()
        end

        return
    end
end
table_1.ApplyTags = apply_tags
local apply_mini_item_frame
do
    local captured_value_11 = table_1
    apply_mini_item_frame = function<T1>(argument_1_13: T1, argument_2_12, argument_3_8, argument_4: number?)
        local value_5_27: number? = argument_4 or 1
        if argument_3_8 == nil then
            local title_value = argument_2_12.Title
            local value_7_20: string = ""
            title_value.Text = value_7_20
            local icon_value = argument_2_12.Icon
            local value_7_21: string = ""
            icon_value.Image = value_7_21
            local amount_value = argument_2_12.Amount
            local value_7_22: string = ""
            amount_value.Text = value_7_22

            return
        end
        local title_value_2 = argument_2_12.Title
        local value_7_23 = captured_value_11
        local value_9_7 = argument_3_8
        local get_display_name_result_3 = value_7_23:GetDisplayName(value_9_7)
        title_value_2.Text = get_display_name_result_3
        local icon_value_2 = argument_2_12.Icon
        local value_7_25 = captured_value_11
        local value_9_8 = argument_3_8
        local get_item_image_result_2 = value_7_25:GetItemImage(value_9_8)
        icon_value_2.Image = get_item_image_result_2
        local amount_value_2 = argument_2_12.Amount
        local value_7_27 = captured_value_11
        local value_9_9: number? = value_5_27
        local get_amount_text_result = value_7_27:GetAmountText(value_9_9)
        amount_value_2.Text = get_amount_text_result

        return
    end
end
table_1.ApplyMiniItemFrame = apply_mini_item_frame
local apply_item_to_frame
do
    local captured_value_12, captured_value_13 = require_result, table_1
    apply_item_to_frame = function<T1>(argument_1_14: T1, argument_2_13, argument_3_9, argument_4_2: number?)
        local value_5_28: number? = argument_4_2 or 1
        if argument_3_9 == nil then
            local label_value = argument_2_13.ItemName.Label
            local value_7_29: string = ""
            label_value.Text = value_7_29
            local item_name_value_2 = argument_2_13.ItemName
            local common_value = captured_value_12.Rarity.Common
            item_name_value_2.BackgroundColor3 = common_value
            local icon_value_3 = argument_2_13.Container.Icon
            local value_7_31: string = ""
            icon_value_3.Image = value_7_31
            local amount_value_3 = argument_2_13.Container.Amount
            local value_7_32: string = ""
            amount_value_3.Text = value_7_32

            return argument_2_13
        end
        local label_value_2 = argument_2_13.ItemName.Label
        local value_7_33 = captured_value_13
        local value_9_10 = argument_3_9
        local get_display_name_result_4 = value_7_33:GetDisplayName(value_9_10)
        label_value_2.Text = get_display_name_result_4
        local item_name_value_4 = argument_2_13.ItemName
        local value_7_35 = captured_value_13
        local value_9_11 = argument_3_9
        local get_rarity_color_result_2 = value_7_35:GetRarityColor(value_9_11)
        item_name_value_4.BackgroundColor3 = get_rarity_color_result_2
        local icon_value_4 = argument_2_13.Container.Icon
        local value_7_37 = captured_value_13
        local value_9_12 = argument_3_9
        local get_item_image_result_3 = value_7_37:GetItemImage(value_9_12)
        icon_value_4.Image = get_item_image_result_3
        local amount_value_4 = argument_2_13.Container.Amount
        local value_7_39 = captured_value_13
        local value_9_13: number? = value_5_28
        local get_amount_text_result_2 = value_7_39:GetAmountText(value_9_13)
        amount_value_4.Text = get_amount_text_result_2

        return argument_2_13
    end
end
table_1.ApplyItemToFrame = apply_item_to_frame

local function comma_number<T1>(argument_1_15: T1, argument_2_14: number)
    local value_3_7: nil = nil
    local value_5_29: number = argument_2_14
    local tostring_result_3 = tostring(value_5_29)
    while true do
        local gsub_value = string.gsub
        local value_6_27 = tostring_result_3
        local value_7_41: string = "^(-?%d+)(%d%d%d)"
        local value_8_17: string = "%1,%2"
        local gsub_result, value_6_28 = gsub_value(value_6_27, value_7_41, value_8_17)
        tostring_result_3 = gsub_result
        local value_3_8 = value_6_28
        if value_3_8 == 0 then
            break
        end
    end

    return tostring_result_3
end

table_1.CommaNumber = comma_number

return table_1
