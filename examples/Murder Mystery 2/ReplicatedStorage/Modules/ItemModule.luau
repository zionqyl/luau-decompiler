--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("GetImage")] = nil,
    [("GetImage")] = nil,
    [("GetImage")] = nil,
    [("GetImage")] = nil,
    [("GetImage")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local table_3 = {[("Weapons")] = nil, [("Weapons")] = nil}
local value_4_4: boolean = true
table_3.Weapons = value_4_4
local value_4_5: boolean = true
table_3.Pets = value_4_5
local rarities_value = require_result.Rarities

local function get_image(argument_1)
    if _G.Cache[argument_1] ~= nil then
        return _G.Cache[argument_1]
    end
    local value_4_6 = argument_1
    local tonumber_result = tonumber(value_4_6)
    local value_2_3
    do
        local take_fallback = not tonumber_result
        if not take_fallback then
            value_2_3 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. argument_1
            take_fallback = not value_2_3
        end
        if take_fallback then
            value_2_3 = argument_1
        end
    end
    local value_2_4 = value_2_3 .. "&bust=" .. (math.random(1, 10000))
    local cache_value_3 = _G.Cache
    cache_value_3[argument_1] = value_2_4

    return value_2_4
end

table_1.GetImage = get_image

local function get_image_small(argument_1_2)
    if _G.SmallCache[argument_1_2] ~= nil then
        return _G.SmallCache[argument_1_2]
    end
    local value_4_9 = argument_1_2
    local tonumber_result_2 = tonumber(value_4_9)
    local value_2_7
    do
        local take_fallback_2 = not tonumber_result_2
        if not take_fallback_2 then
            value_2_7 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=110&height=110&assetId=" .. argument_1_2
            take_fallback_2 = not value_2_7
        end
        if take_fallback_2 then
            value_2_7 = argument_1_2
        end
    end
    local value_2_8 = value_2_7 .. "&bust=" .. (math.random(1, 10000))
    local small_cache_value_3 = _G.SmallCache
    small_cache_value_3[argument_1_2] = value_2_8

    return value_2_8
end

table_1.GetImageSmall = get_image_small
local table_5 = {
    [("Chroma")] = nil,
    [("Chroma")] = nil,
    [("Chroma")] = nil,
    [("Chroma")] = nil,
    [("Chroma")] = nil,
}

local function value_6(argument_1_3, argument_2): ()
    local chroma_value = argument_1_3.Tags.Chroma
    local value_4_12: boolean?
    if argument_2.Chroma ~= true then
        value_4_12 = false
    else
        value_4_12 = true
    end
    chroma_value.Visible = value_4_12

    return
end

table_5.Chroma = value_6

local function value_6_2(argument_1_4, argument_2_2): ()
    local fx_value = argument_1_4.Tags.FX
    local value_4_13: boolean?
    if argument_2_2.FX ~= true then
        value_4_13 = false
    else
        value_4_13 = true
    end
    fx_value.Visible = value_4_13

    return
end

table_5.FX = value_6_2

local function value_6_3(argument_1_5, argument_2_3): ()
    local evo_value = argument_1_5.Tags.Evo
    local value_4_14: boolean?
    if argument_2_3.EvoBaseID == nil then
        value_4_14 = false
    else
        value_4_14 = true
    end
    evo_value.Visible = value_4_14

    return
end

table_5.Evo = value_6_3
local value_6_4
do
    local captured_value = table_3
    value_6_4 = function(argument_1_6, argument_2_4)
        if not captured_value[argument_2_4.DataType] then
            local halloween_value = argument_1_6.Tags.Halloween
            local value_4_16: boolean?
            if argument_2_4.Event ~= "Halloween" then
                value_4_16 = false
            else
                value_4_16 = true
            end
            halloween_value.Visible = value_4_16
            local year_value = argument_1_6.Tags.Halloween.Year
            local value_4_17 = argument_2_4.Year or ""
            year_value.Text = value_4_17
        end

        return
    end
end
table_5.Halloween = value_6_4
local value_6_5
do
    local captured_value_2 = table_3
    value_6_5 = function(argument_1_7, argument_2_5)
        if not captured_value_2[argument_2_5.DataType] then
            local christmas_value = argument_1_7.Tags.Christmas
            local value_4_19: boolean?
            if argument_2_5.Event ~= "Christmas" then
                value_4_19 = false
            else
                value_4_19 = true
            end
            christmas_value.Visible = value_4_19
            local year_value_3 = argument_1_7.Tags.Christmas.Year
            local value_4_20 = argument_2_5.Year or ""
            year_value_3.Text = value_4_20
        end

        return
    end
end
table_5.Christmas = value_6_5
local value_6_6
do
    local captured_value_3, captured_value_4 = rarities_value, table_5
    value_6_6 = function(argument_1_8, argument_2_6, argument_3, argument_4)
        local find_first_child_result, is_a_result, item_name_value, random_result_3, random_value_3, tags_value_8, value_10, value_11, value_12, value_12_3, value_13, value_13_3, value_14, value_14_2, value_14_3, value_14_4, value_6_11, value_7_3, value_8, value_9, visible_value
        local control_state = 0
        while true do
            if control_state < 27 then
                if control_state < 15 then
                    if control_state < 9 then
                        if control_state < 6 then
                            if control_state < 1 then
                                control_state = if argument_2_6 ~= nil then 6 else 1
                            else
                                if control_state < 5 then
                                    item_name_value = argument_1_8.ItemName.Label
                                    value_6_11 = ""
                                    item_name_value.Text = value_6_11
                                    item_name_value = argument_1_8.Container.Icon
                                    value_6_11 = ""
                                    item_name_value.Image = value_6_11
                                    item_name_value = argument_1_8.Container.Amount
                                    value_6_11 = ""
                                    item_name_value.Text = value_6_11
                                    item_name_value = argument_1_8.ItemName
                                    value_6_11 = Color3.fromRGB
                                    value_7_3 = 95
                                    value_8 = 95
                                    value_9 = 95
                                    value_6_11 = value_6_11(value_7_3, value_8, value_9)
                                    item_name_value.BackgroundColor3 = value_6_11
                                    item_name_value, value_6_11, value_7_3 = pairs(
                                        argument_1_8.Tags:GetChildren()
                                    )
                                    for key, value in item_name_value, value_6_11, value_7_3 do
                                        value_8, value_9 = key, value
                                        value_12 = "Frame"
                                        if not (value_9:IsA(value_12)) then
                                            continue
                                        end
                                        value_10 = false
                                        value_9.Visible = value_10
                                    end
                                    control_state = 5
                                else
                                    return
                                end
                            end
                        else
                            if control_state < 7 then
                                item_name_value = argument_1_8.ItemName.Label
                                value_6_11 = argument_2_6.ItemName
                                control_state = if value_6_11 then 8 else 7
                            else
                                if control_state < 8 then
                                    value_6_11 = argument_2_6.Name
                                    control_state = 8
                                else
                                    item_name_value.Text = value_6_11
                                    item_name_value = argument_2_6.Rarity or "Common"
                                    argument_2_6.Rarity = item_name_value
                                    item_name_value = captured_value_3[argument_2_6.Rarity].Color
                                    value_6_11 = Color3.fromRGB
                                    value_7_3 = item_name_value.r
                                    value_8 = item_name_value.g
                                    value_9 = item_name_value.b
                                    value_6_11 = value_6_11(value_7_3, value_8, value_9)
                                    control_state = if value_6_11 then 10 else 9
                                end
                            end
                        end
                    else
                        if control_state < 12 then
                            if control_state < 10 then
                                value_6_11 = Color3.new
                                value_7_3 = 1
                                value_8 = 1
                                value_9 = 1
                                value_6_11 = value_6_11(value_7_3, value_8, value_9)
                                control_state = 10
                            else
                                if control_state < 11 then
                                    value_7_3 = argument_1_8.ItemName
                                    value_7_3.BackgroundColor3 = value_6_11
                                    value_7_3 = argument_1_8.Container.Icon
                                    value_9 = argument_2_6.Image
                                    value_11 = _G.Cache
                                    value_10 = value_11[value_9]
                                    control_state = if value_10 == nil then 12 else 11
                                else
                                    value_10 = _G.Cache
                                    value_8 = value_10[value_9]
                                    control_state = 16
                                end
                            end
                        else
                            if control_state < 13 then
                                value_11 = value_9
                                value_10 = tonumber(value_11)
                                control_state = if not value_10 then 14 else 13
                            else
                                if control_state < 14 then
                                    value_10 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId="
                                    value_11 = value_9
                                    item_name_value = value_10 .. value_11
                                    control_state = if item_name_value then 15 else 14
                                else
                                    item_name_value = value_9
                                    control_state = 15
                                end
                            end
                        end
                    end
                else
                    if control_state < 21 then
                        if control_state < 18 then
                            if control_state < 16 then
                                value_10 = item_name_value
                                value_11 = "&bust="
                                random_value_3 = math.random
                                value_13 = 1
                                value_14 = 10000
                                random_result_3 = random_value_3(value_13, value_14)
                                item_name_value = value_10 .. value_11 .. random_result_3
                                value_10 = _G.Cache
                                value_10[value_9] = item_name_value
                                value_8 = item_name_value
                                control_state = 16
                            else
                                if control_state < 17 then
                                    value_7_3.Image = value_8
                                    value_7_3 = argument_1_8.Container
                                    value_9 = "Amount"
                                    value_7_3 = value_7_3:FindFirstChild(value_9)
                                    control_state = if not value_7_3 then 24 else 17
                                else
                                    value_7_3 = argument_3
                                    control_state = if value_7_3 then 19 else 18
                                end
                            end
                        else
                            if control_state < 19 then
                                value_7_3 = argument_2_6.Amount
                                control_state = 19
                            else
                                if control_state < 20 then
                                    value_8 = argument_1_8.Container.Amount
                                    control_state = if not value_7_3 then 22 else 20
                                else
                                    value_10 = 1
                                    control_state = if not (value_10 < value_7_3) then 22 else 21
                                end
                            end
                        end
                    else
                        if control_state < 24 then
                            if control_state < 22 then
                                value_10 = "x"
                                value_11 = value_7_3
                                value_9 = value_10 .. value_11
                                control_state = if value_9 then 23 else 22
                            else
                                if control_state < 23 then
                                    value_9 = ""
                                    control_state = 23
                                else
                                    value_8.Text = value_9
                                    control_state = 24
                                end
                            end
                        else
                            if control_state < 25 then
                                value_7_3 = argument_1_8.Container
                                value_9 = "Classic"
                                value_7_3 = value_7_3:FindFirstChild(value_9)
                                control_state = if not value_7_3 then 29 else 25
                            else
                                if control_state < 26 then
                                    value_7_3 = argument_1_8.Container.Classic
                                    value_9 = argument_2_6.Classic
                                    control_state = if value_9 ~= nil then 27 else 26
                                else
                                    value_8 = false
                                    control_state = 28
                                end
                            end
                        end
                    end
                end
            else
                if control_state < 42 then
                    if control_state < 33 then
                        if control_state < 30 then
                            if control_state < 28 then
                                value_8 = true
                                control_state = 28
                            else
                                if control_state < 29 then
                                    value_7_3.Visible = value_8
                                    control_state = 29
                                else
                                    value_7_3 = argument_1_8.ItemName
                                    value_9 = "ColoredName"
                                    value_7_3 = value_7_3:FindFirstChild(value_9)
                                    control_state = if not value_7_3 then 35 else 30
                                end
                            end
                        else
                            if control_state < 31 then
                                value_7_3 = argument_1_8.ItemName.ColoredName
                                value_8 = argument_2_6.ItemName
                                control_state = if value_8 then 32 else 31
                            else
                                if control_state < 32 then
                                    value_8 = argument_2_6.Name
                                    control_state = 32
                                else
                                    value_7_3.Text = value_8
                                    value_7_3 = value_6_11
                                    value_8 = argument_2_6.Rarity
                                    control_state = if value_8 ~= "Common" then 34 else 33
                                end
                            end
                        end
                    else
                        if control_state < 36 then
                            if control_state < 34 then
                                value_8 = Color3.new
                                value_9 = 1
                                value_10 = 1
                                value_11 = 1
                                value_8 = value_8(value_9, value_10, value_11)
                                value_7_3 = value_8
                                control_state = 34
                            else
                                if control_state < 35 then
                                    value_8 = argument_1_8.ItemName.ColoredName
                                    value_8.TextColor3 = value_7_3
                                    value_8 = argument_1_8.ItemName.RarityBar
                                    value_8.BackgroundColor3 = value_7_3
                                    control_state = 35
                                else
                                    value_9 = "Tags"
                                    value_7_3 = argument_1_8:FindFirstChild(value_9)
                                    control_state = if not value_7_3 then 40 else 36
                                end
                            end
                        else
                            if control_state < 40 then
                                value_7_3, value_8, value_9 = pairs(captured_value_4)
                                for key_2, value_15 in value_7_3, value_8, value_9 do
                                    value_10, value_11 = key_2, value_15
                                    tags_value_8 = argument_1_8.Tags
                                    value_14_2 = value_10
                                    find_first_child_result = tags_value_8:FindFirstChild(
                                        value_14_2
                                    )
                                    if not find_first_child_result then
                                        continue
                                    end
                                    value_12_3 = value_11
                                    value_13_3 = argument_1_8
                                    value_14_3 = argument_2_6
                                    value_12_3(value_13_3, value_14_3)
                                end
                                control_state = 40
                            else
                                if control_state < 41 then
                                    value_7_3 = argument_2_6.Signature
                                    control_state = if not value_7_3 then 48 else 41
                                else
                                    value_6_11 = argument_2_6.Signature
                                    control_state = if value_6_11 == "" then 44 else 42
                                end
                            end
                        end
                    end
                else
                    if control_state < 48 then
                        if control_state < 45 then
                            if control_state < 43 then
                                value_7_3 = argument_1_8.Tags.Unique.PlayerName
                                value_9 = value_6_11
                                value_10 = "'s"
                                value_8 = value_9 .. value_10
                                value_7_3.Text = value_8
                                value_7_3 = argument_1_8.Tags.Unique
                                value_8 = true
                                value_7_3.Visible = value_8
                                value_8 = value_6_11
                                value_7_3 = tonumber(value_8)
                                control_state = if not value_7_3 then 44 else 43
                            else
                                if control_state < 44 then
                                    value_7_3 = spawn
                                    do
                                        local captured_value_5, captured_value_6, closure_ready
                                        value_8 = function(): ()
                                            if not closure_ready then
                                                return
                                            end
                                            local player_name_value = captured_value_5.Tags.Unique.PlayerName
                                            local players_value = game.Players
                                            local signature_value = captured_value_6.Signature
                                            local abs_result = math.abs(signature_value)
                                            local value_2_9 = (players_value:GetNameFromUserIdAsync(
                                                abs_result
                                            )) .. "'s"
                                            player_name_value.Text = value_2_9

                                            return
                                        end
                                        captured_value_5, captured_value_6 = argument_1_8, argument_2_6
                                        closure_ready = true
                                    end
                                    value_7_3(value_8)
                                    control_state = 44
                                else
                                    value_7_3 = argument_1_8.Container.Amount
                                    value_9 = argument_2_6.Rank
                                    control_state = if not value_9 then 46 else 45
                                end
                            end
                        else
                            if control_state < 46 then
                                value_9 = "#"
                                value_10 = argument_2_6.Rank
                                value_8 = value_9 .. value_10
                                control_state = if value_8 then 47 else 46
                            else
                                if control_state < 47 then
                                    value_8 = ""
                                    control_state = 47
                                else
                                    value_7_3.Text = value_8
                                    control_state = 48
                                end
                            end
                        end
                    else
                        if control_state < 55 then
                            if control_state < 49 then
                                control_state = if not argument_4 then 57 else 49
                            else
                                if control_state < 50 then
                                    value_9 = "Tags"
                                    value_7_3 = argument_1_8:FindFirstChild(value_9)
                                    control_state = if not value_7_3 then 57 else 50
                                else
                                    value_7_3, value_8, value_9 = pairs(argument_1_8.Tags:GetChildren())
                                    for key_3, value_16 in value_7_3, value_8, value_9 do
                                        value_10, value_11 = key_3, value_16
                                        value_14_4 = "Frame"
                                        is_a_result = value_11:IsA(value_14_4)
                                        if not is_a_result then
                                            continue
                                        end
                                        visible_value = value_11.Visible
                                        if visible_value ~= false then
                                            continue
                                        end
                                        value_11:Destroy()
                                    end
                                    control_state = 55
                                end
                            end
                        else
                            if control_state < 56 then
                                value_8 = argument_1_8.Tags:GetChildren()
                                value_7_3 = #value_8
                                control_state = if value_7_3 ~= 1 then 57 else 56
                            else
                                if control_state < 57 then
                                    value_7_3 = argument_1_8.Tags
                                    value_7_3:Destroy()
                                    control_state = 57
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
end
table_1.DisplayItem = value_6_6

local function value_6_7(argument_1_9)
    local value_3_11 = argument_1_9
    local value_2_10 = (tostring(value_3_11))
    while true do
        local gsub_value = string.gsub
        local value_4_23 = value_2_10
        local value_5_4: string = "^(-?%d+)(%d%d%d)"
        local value_6_13: string = "%1,%2"
        local gsub_result, value_4_24 = gsub_value(value_4_23, value_5_4, value_6_13)
        k = value_4_24
        value_2_10 = gsub_result
        local k_value = k
        if k_value == 0 then
            break
        end
    end

    return value_2_10
end

table_1.Commafy = value_6_7

local function value_6_8(argument_1_10, argument_2_7, argument_3_2): ()
    local cloned_value = argument_1_10:Clone()
    local x_value = argument_1_10.AbsoluteSize.X
    local y_value = argument_1_10.AbsoluteSize.Y
    local x_value_2 = argument_1_10.AbsolutePosition.X
    local y_value_2 = argument_1_10.AbsolutePosition.Y
    local new_result = UDim2.new(0, x_value, 0, y_value)
    cloned_value.Size = new_result
    local value_9_2: number = 1
    cloned_value.BackgroundTransparency = value_9_2
    local new_result_2 = UDim2.new(0, x_value_2 + x_value / 2, 0, y_value_2 + y_value / 2)
    cloned_value.Position = new_result_2
    local new_result_3: Vector2 = Vector2.new(0.5, 0.5)
    cloned_value.AnchorPoint = new_result_3
    local value_9_3: number = 10
    cloned_value.ZIndex = value_9_3
    cloned_value.Parent = argument_3_2
    local spawn_value = spawn
    local value_10_5: (() -> ())?
    do
        local captured_value_7, captured_value_8, closure_ready_2
        value_10_5 = function(): ()
            if not closure_ready_2 then
                return
            end
            local value_1_3 = captured_value_7
            local new_result_4 = UDim2.new(0, 25, 0, 25)
            local new_result_5 = UDim2.new(
                0,
                captured_value_8.AbsolutePosition.X + captured_value_8.AbsoluteSize.X / 2 - 3,
                0,
                captured_value_8.AbsolutePosition.Y + captured_value_8.AbsoluteSize.Y / 2 - 20
            )
            local value_5_8: string = "InOut"
            local value_6_16: string = "Sine"
            local value_7_7: number = 0.5
            value_1_3:TweenSizeAndPosition(
                new_result_4,
                new_result_5,
                value_5_8,
                value_6_16,
                value_7_7
            )
            wait(0.5)
            captured_value_7:Destroy()

            return
        end
        captured_value_7, captured_value_8 = cloned_value, argument_2_7
        closure_ready_2 = true
    end
    spawn_value(value_10_5)

    return
end

table_1.AnimateItemIconIntoInventory = value_6_8

return table_1
