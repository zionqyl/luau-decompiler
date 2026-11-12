--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
}
local require_result = require(game.ReplicatedStorage.Modules.InventoryModule)
local require_value_2 = require
local game_value_2: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result_2 = require_value_2(database_child:WaitForChild(value_6_3))
local table_4 = {
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
    [0] = nil,
}
local value_5_4: number = 0
local value_6_4: string = ""
table_4[value_5_4] = value_6_4
local value_5_5: string = "I"
table_4[1] = value_5_5
local value_5_6: string = "II"
table_4[2] = value_5_6
local value_5_7: string = "III"
table_4[3] = value_5_7
local value_5_8: string = "IV"
table_4[4] = value_5_8
local value_5_9: string = "V"
table_4[5] = value_5_9
local value_5_10: string = "VI"
table_4[6] = value_5_10
local value_5_11: string = "VII"
table_4[7] = value_5_11
local value_5_12: string = "VIII"
table_4[8] = value_5_12
local value_5_13: string = "IX"
table_4[9] = value_5_13
local value_5_14: string = "X"
table_4[10] = value_5_14
local require_result_3 = require(game.ReplicatedStorage.RankIconsEmpty)
local table_6 = {nil, nil, nil}
local from_rgb_value: (number?, number?, number?) -> (Color3) = Color3.fromRGB
local value_8 = 255
local from_rgb_result: Color3 = from_rgb_value(value_8, 170, 0)
table_6[1] = from_rgb_result
local from_rgb_value_2: (number?, number?, number?) -> (Color3) = Color3.fromRGB
value_8 = 193
local from_rgb_result_2: Color3 = from_rgb_value_2(value_8, 218, 216)
table_6[2] = from_rgb_result_2
local from_rgb_value_3: (number?, number?, number?) -> (Color3) = Color3.fromRGB
value_8 = 139
local from_rgb_result_3: Color3 = from_rgb_value_3(value_8, 58, 0)
table_6[3] = from_rgb_result_3
local require_value_4 = require
value_8 = script
value_8 = value_8.Parent
value_8 = value_8.ItemModule
local require_result_4 = require_value_4(value_8)
value_8 = {}
table_1.GUI = value_8
value_8 = {}
table_1.PlayerInventories = value_8
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6 = table_1, require_result_3, table_4, require_result_4, require_result_2, table_6
    value_8 = function(argument_1, argument_2, argument_3, argument_4)
        local profile_container_value = captured_value.GUI.ProfileContainer
        local character_value = profile_container_value.Character
        local container_value = profile_container_value.Profile.Season1Stats.Container
        local trophies_value = profile_container_value.Profile.Trophies
        local value_9_8: string?
        if argument_2 == game.Players.LocalPlayer.Name then
            value_9_8 = " (You)"
        else
            value_9_8 = ""
        end
        local value_12 = "Username"
        local game_value_4 = profile_container_value:FindFirstChild(value_12)
        if not game_value_4 then
            game_value_4 = profile_container_value.Parent
            value_12 = "Username"
            game_value_4 = game_value_4:FindFirstChild(value_12)
        end
        local value_11 = argument_2 .. value_9_8
        game_value_4.Text = value_11
        local players_value = game.Players
        value_12 = game.Players[argument_2].userId
        value_11 = math.abs(value_12)
        value_12 = Enum.ThumbnailType.AvatarBust
        local value_13 = Enum.ThumbnailSize.Size352x352
        local get_user_thumbnail_async_result = players_value:GetUserThumbnailAsync(
            value_11,
            value_12,
            value_13
        )
        game_value_4 = character_value.CharacterIcon
        game_value_4.Image = get_user_thumbnail_async_result
        game_value_4 = argument_1.Nav.Profile.Icon
        game_value_4.Image = get_user_thumbnail_async_result
        game_value_4 = character_value.CharacterIcon.LevelFrame.LevelContainer.Icon.Level
        value_11 = argument_3.Level
        game_value_4.Text = value_11
        game_value_4 = character_value.CharacterIcon.LevelFrame.LevelContainer.Icon
        value_11 = captured_value_2[argument_3.Level]
        game_value_4.Image = value_11
        game_value_4 = character_value.CharacterIcon.LevelFrame.LevelContainer.Prestige
        value_12 = argument_3.Prestige
        value_13 = 0
        if not (value_13 < value_12) then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = argument_3.Prestige
        value_11 = 0
        if value_11 < game_value_4 then
            game_value_4 = character_value.CharacterIcon.LevelFrame.LevelContainer.Prestige
            value_12 = captured_value_3
            value_13 = argument_3.Prestige
            value_11 = value_12[value_13]
            game_value_4.Text = value_11
        end
        game_value_4 = character_value.Elite
        if argument_3.Elite ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = character_value.Builder
        if argument_3.MapBuilder ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = character_value.WeaponDesigner
        if argument_3.WeaponDesigner ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = character_value.MM2Creator
        if argument_3.Nikilis ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = character_value.BetaTester
        if argument_3.BetaTester ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = character_value.Clown
        if argument_3.Clown ~= true then
            value_11 = false
        else
            value_11 = true
        end
        game_value_4.Visible = value_11
        game_value_4 = container_value.Eliminations.Amount
        value_11 = argument_3.Eliminations
        game_value_4.Text = value_11
        game_value_4 = container_value.Saves.Amount
        value_11 = argument_3.Victories
        game_value_4.Text = value_11
        game_value_4 = container_value.Survivals.Amount
        value_11 = argument_3.Survivals
        game_value_4.Text = value_11
        if argument_3.Trophies == nil then
            game_value_4 = false
        else
            game_value_4 = true
        end
        trophies_value.Visible = game_value_4
        game_value_4, value_11, value_12 = trophies_value.Container:GetChildren()
        local value_14
        for key, value in game_value_4, value_11, value_12 do
            value_13, value_14 = key, value
            local value_17: string = "Frame"
            local is_a_result = value_14:IsA(value_17)
            if not is_a_result then
                continue
            end
            value_14:Destroy()
        end
        game_value_4 = argument_3.Trophies
        if game_value_4 then
            game_value_4, value_11, value_12 = pairs(argument_3.Trophies)
            for key_2, value_2 in game_value_4, value_11, value_12 do
                value_13, value_14 = key_2, value_2
                local script_value: LuaSourceContainer = script
                local trophy_item_value = script_value.TrophyItem
                local cloned_value = trophy_item_value:Clone()
                local value_9_10 = cloned_value
                local item_id_value = value_14.ItemID
                local rank_value = value_14.Rank
                local container_value_2 = value_9_10.Container
                local icon_value = container_value_2.Icon
                local value_16_4 = captured_value_4
                local get_image_value = value_16_4.GetImage
                local value_18 = captured_value_5
                local weapons_value = value_18.Weapons
                local value_17_2 = weapons_value[item_id_value]
                local image_value = value_17_2.Image
                local get_image_result = get_image_value(image_value)
                icon_value.Image = get_image_result
                local container_value_3 = value_9_10.Container
                local year_value = container_value_3.Year
                local year_text_value = year_value.YearText
                local value_17_3 = captured_value_5
                local weapons_value_2 = value_17_3.Weapons
                local value_16_5 = weapons_value_2[item_id_value]
                local year_value_2 = value_16_5.Year
                year_text_value.Text = year_value_2
                local item_name_value = value_9_10.ItemName
                local label_value = item_name_value.Label
                local rank_value_2 = value_14.Rank
                local value_16_6
                do
                    local take_fallback = not rank_value_2
                    if not take_fallback then
                        local value_17_4: string = "Rank #"
                        local rank_value_3 = value_14.Rank
                        value_16_6 = value_17_4 .. rank_value_3
                        take_fallback = not value_16_6
                    end
                    if take_fallback then
                        local value_17_5 = captured_value_5
                        local weapons_value_3 = value_17_5.Weapons
                        local value_16_7 = weapons_value_3[item_id_value]
                        value_16_6 = value_16_7.ItemName
                    end
                end
                label_value.Text = value_16_6
                local value_16_8 = captured_value_6
                local value_15_4 = value_16_8[rank_value]
                if value_15_4 then
                    local item_name_value_2 = value_9_10.ItemName
                    local value_17_6 = captured_value_6
                    local value_16_9 = value_17_6[rank_value]
                    item_name_value_2.BackgroundColor3 = value_16_9
                end
                local container_value_4 = trophies_value.Container
                value_9_10.Parent = container_value_4
            end
        end
        captured_value.DisplayInventory(argument_1, argument_2, argument_4)

        return
    end
end
table_1.GenerateProfile = value_8
value_8 = nil
local value_9_4
do
    local captured_value_7, captured_value_8 = require_result, table_1
    value_9_4 = function(argument_1_2, argument_2_2, argument_3_2)
        local pairs_value = pairs
        local table_5 = {
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        }
        local value_7 = "Weapons"
        local value_8_2 = "Effects"
        local value_9_11: string = "Perks"
        local value_10_4 = "Emotes"
        local value_11_2 = "Radios"
        local value_12_2 = "Pets"
        table_5[1], table_5[2], table_5[3], table_5[4], table_5[5], table_5[6] = value_7, value_8_2, value_9_11, value_10_4, value_11_2, value_12_2
        local value_6_5
        pairs_value, table_5, value_6_5 = pairs_value(table_5)
        for key_4, value_19 in pairs_value, table_5, value_6_5 do
            value_7, value_8_2 = key_4, value_19
            local main_value = argument_1_2.Main
            value_11_2 = value_8_2
            local find_first_child_result = main_value:FindFirstChild(value_11_2)
            value_11_2 = "Title"
            local title_child = find_first_child_result:FindFirstChild(value_11_2)
            local value_13_2, value_14_2
            if title_child then
                value_10_4 = title_child.Username
                value_12_2 = argument_2_2
                value_13_2 = "'s "
                value_14_2 = value_8_2
                value_11_2 = value_12_2 .. value_13_2 .. value_14_2
                value_10_4.Text = value_11_2
            end
            value_10_4 = pairs
            value_13_2 = captured_value_7.CreateBlankInventoryTable()
            value_10_4, value_11_2, value_12_2 = value_10_4(value_13_2[value_8_2])
            for key_3, value_3 in value_10_4, value_11_2, value_12_2 do
                value_13_2, value_14_2 = key_3, value_3
                local main_value_2 = argument_1_2.Main
                local value_17_7 = value_8_2
                local value_15_6 = main_value_2:FindFirstChild(value_17_7)
                local items_value = value_15_6.Items
                local container_value_5 = items_value.Container
                local value_17_8 = value_13_2
                local find_first_child_result_2 = container_value_5:FindFirstChild(value_17_8)
                local value_9_14 = find_first_child_result_2
                if not value_9_14 then
                    local main_value_3 = argument_1_2.Main
                    local value_17_9 = value_8_2
                    local value_15_9 = main_value_3:FindFirstChild(value_17_9)
                    local items_value_2 = value_15_9.Items
                    local container_value_6 = items_value_2.Container
                    local value_17_10: string = "Holiday"
                    local holiday_child = container_value_6:FindFirstChild(value_17_10)
                    local container_value_7 = holiday_child.Container
                    local value_17_11 = value_13_2
                    local find_first_child_result_3 = container_value_7:FindFirstChild(value_17_11)
                    value_9_14 = find_first_child_result_3
                end
                local container_value_8 = value_9_14.Container
                container_value_8:ClearAllChildren()
            end
        end
        pairs_value = game.ReplicatedStorage.Remotes.Extras.GetFullInventory
        value_6_5 = argument_2_2
        pairs_value = pairs_value:InvokeServer(value_6_5)
        table_5 = captured_value_7.GenerateInventory(argument_1_2, pairs_value, nil, argument_3_2)
        value_6_5 = captured_value_8.PlayerInventories
        value_6_5[argument_2_2] = table_5
        if value_8 then
            value_8:disconnect()
        end
        pairs_value = captured_value_8.GUI.SearchFrameTextBox
        value_8_2 = "Text"
        value_6_5 = pairs_value:GetPropertyChangedSignal(value_8_2)
        do
            local captured_value_9, captured_value_10, closure_ready
            value_8_2 = function(): ()
                if not closure_ready then
                    return
                end
                local text_value = captured_value_9.Text
                local gsub_value = string.gsub
                local value_3_2 = text_value
                local value_4_4 = "S"
                local value_5_16 = ""
                local value_1_2 = (gsub_value(value_3_2, value_4_4, value_5_16))
                gsub_value, value_3_2, value_4_4 = pairs(captured_value_10.Data.Weapons)
                for key_6, value_21 in gsub_value, value_3_2, value_4_4 do
                    local value_6_6
                    value_5_16, value_6_6 = key_6, value_21
                    local pairs_value_2, value_8_3, value_9_16 = pairs(value_6_6)
                    for key_5, value_20 in pairs_value_2, value_8_3, value_9_16 do
                        local value_10_5, value_11_3 = key_5, value_20
                        local frame_value = value_11_3.Frame
                        local find_value = string.find
                        local lower_value = string.lower
                        local name_value = value_11_3.Name
                        local lower_result = lower_value(name_value)
                        local lower_value_2 = string.lower
                        local value_16_16 = value_1_2
                        local find_result = find_value(lower_result, lower_value_2(value_16_16))
                        frame_value.Visible = find_result
                        local frame_value_2 = value_11_3.Frame
                        local parent_value = frame_value_2.Parent
                        local parent_value_2 = parent_value.Parent
                        local value_14_3: string = "ScrollingFrame"
                        local is_a_result_2 = parent_value_2:IsA(value_14_3)
                        if is_a_result_2 then
                            local frame_value_3 = value_11_3.Frame
                            local parent_value_3 = frame_value_3.Parent
                            local parent_value_4 = parent_value_3.Parent
                            local new_value: (number?, number?) -> (Vector2) = Vector2.new
                            local value_14_4: number = 0
                            local value_15_13: number = 0
                            local new_result: Vector2 = new_value(value_14_4, value_15_13)
                            parent_value_4.CanvasPosition = new_result
                        else
                            local frame_value_4 = value_11_3.Frame
                            local parent_value_5 = frame_value_4.Parent
                            local parent_value_6 = parent_value_5.Parent
                            local parent_value_7 = parent_value_6.Parent
                            local parent_value_8 = parent_value_7.Parent
                            local new_value_2: (number?, number?) -> (Vector2) = Vector2.new
                            local value_14_5: number = 0
                            local value_15_14: number = 0
                            local new_result_2: Vector2 = new_value_2(value_14_5, value_15_14)
                            parent_value_8.CanvasPosition = new_result_2
                        end
                    end
                end

                return
            end
            captured_value_9, captured_value_10 = pairs_value, table_5
            closure_ready = true
        end
        value_8 = (value_6_5:connect(value_8_2))

        return
    end
end
table_1.DisplayInventory = value_9_4
local value_9_5
do
    local captured_value_11, captured_value_12 = require_result, table_1
    value_9_5 = function(argument_1_3, argument_2_3, argument_3_3)
        local pairs_value_3 = pairs
        local table_5_2 = {
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
        }
        local value_7_2 = "Weapons"
        local value_8_4 = "Effects"
        local value_9_17: string = "Perks"
        local value_10_6 = "Emotes"
        local value_11_4 = "Radios"
        local value_12_4 = "Pets"
        table_5_2[1], table_5_2[2], table_5_2[3], table_5_2[4], table_5_2[5], table_5_2[6] = value_7_2, value_8_4, value_9_17, value_10_6, value_11_4, value_12_4
        local value_6_7
        pairs_value_3, table_5_2, value_6_7 = pairs_value_3(table_5_2)
        for key_8, value_23 in pairs_value_3, table_5_2, value_6_7 do
            value_7_2, value_8_4 = key_8, value_23
            local main_value_4 = argument_1_3.Main
            value_11_4 = value_8_4
            local find_first_child_result_4 = main_value_4:FindFirstChild(value_11_4)
            value_11_4 = "Title"
            local title_child_2 = find_first_child_result_4:FindFirstChild(value_11_4)
            local value_13_4, value_14_6
            if title_child_2 then
                value_10_6 = title_child_2.Username
                value_12_4 = argument_2_3
                value_13_4 = "'s "
                value_14_6 = value_8_4
                value_11_4 = value_12_4 .. value_13_4 .. value_14_6
                value_10_6.Text = value_11_4
            end
            value_10_6 = pairs
            value_13_4 = captured_value_11.CreateBlankInventoryTable()
            value_10_6, value_11_4, value_12_4 = value_10_6(value_13_4[value_8_4])
            for key_7, value_22 in value_10_6, value_11_4, value_12_4 do
                value_13_4, value_14_6 = key_7, value_22
                local main_value_5 = argument_1_3.Main
                local value_17_12 = value_8_4
                local value_15_16 = main_value_5:FindFirstChild(value_17_12)
                local items_value_3 = value_15_16.Items
                local container_value_9 = items_value_3.Container
                local value_17_13 = value_13_4
                local find_first_child_result_5 = container_value_9:FindFirstChild(value_17_13)
                local value_9_20 = find_first_child_result_5
                if not value_9_20 then
                    local main_value_6 = argument_1_3.Main
                    local value_17_14 = value_8_4
                    local value_15_19 = main_value_6:FindFirstChild(value_17_14)
                    local items_value_4 = value_15_19.Items
                    local container_value_10 = items_value_4.Container
                    local value_17_15: string = "Holiday"
                    local holiday_child_2 = container_value_10:FindFirstChild(value_17_15)
                    local container_value_11 = holiday_child_2.Container
                    local value_17_16 = value_13_4
                    local find_first_child_result_6 = container_value_11:FindFirstChild(
                        value_17_16
                    )
                    value_9_20 = find_first_child_result_6
                end
                local container_value_12 = value_9_20.Container
                container_value_12:ClearAllChildren()
            end
        end
        pairs_value_3 = captured_value_11.GenerateInventory(argument_1_3, argument_3_3)
        table_5_2 = captured_value_12.PlayerInventories
        table_5_2[argument_2_3] = pairs_value_3

        return
    end
end
table_1.DisplayInventoryFromData = value_9_5

local function value_9_6(): ()
    return
end

table_1.DisplayInventoryFromProfile = value_9_6
local value_9_7
do
    local captured_value_13 = require_result
    value_9_7 = function(argument_1_4): ()
        captured_value_13.ConnectNavButtons(argument_1_4.Nav, argument_1_4.Main)
        captured_value_13.ConnectTabButtons(argument_1_4, "Weapons")

        return
    end
end
table_1.ConnectViewProfile = value_9_7

return table_1
