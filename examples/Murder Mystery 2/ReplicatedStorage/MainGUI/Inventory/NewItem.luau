--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value = script.Parent.Parent.Game
local require_result = require(game.ReplicatedStorage.Modules.ItemModule)
local require_value_2 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result_2 = require_value_2(database_child:WaitForChild(value_6_3))
local new_item_value = game_value.NewItem
local value_5 = nil
local table_6 = {}
local game_value_4 = game
game_value_4 = game_value_4.Lighting
game_value_4 = game_value_4.NewItemBlur
local value_8 = false
game_value_4.Enabled = value_8
game_value_4 = 1
value_8 = 1
do
    local captured_value = new_item_value

    local function update_claim_text(): ()
        if 1 < value_8 then
            local claim_value_2 = captured_value.Container.Claim
            local value_2_2 = "Claim (" .. game_value_4 .. "/" .. value_8 .. ")"
            claim_value_2.Text = value_2_2

            return
        end
        local claim_value_3 = captured_value.Container.Claim
        local value_2_3: string = "Claim"
        claim_value_3.Text = value_2_3

        return
    end
end
local show_item
do
    local captured_value_2, captured_value_3, captured_value_4, captured_value_5 = table_6, require_result_2, require_result, new_item_value
    show_item = function()
        local value_1_4 = captured_value_2[1]
        local value_2_5 = captured_value_3[value_1_4.Type][value_1_4.ItemName]
        local value_3_3 = value_1_4.Amount or nil
        captured_value_4.DisplayItem(captured_value_5.Container.NewItem, value_2_5, value_3_3)
        local color_value = captured_value_3.Rarities[value_2_5.Rarity].Color
        local starburst_value = captured_value_5.Container.Starburst
        local from_rgb_result: Color3 = Color3.fromRGB(color_value.r, color_value.g, color_value.b)
        if not from_rgb_result then
            from_rgb_result = Color3.new(1, 1, 1)
        end
        starburst_value.ImageColor3 = from_rgb_result
        local title_value = captured_value_5.Container.Title
        local title_text_value = value_1_4.TitleText
        title_value.Text = title_text_value
        if value_1_4.LFrame then
            value_5 = value_1_4.LFrame
            local value_4_10 = value_5
            local value_5_4: boolean = false
            value_4_10.Visible = value_5_4
        end
        local new_item_blur_value = game.Lighting.NewItemBlur
        local value_5_5: boolean = true
        new_item_blur_value.Enabled = value_5_5
        local value_4_11 = captured_value_5
        local value_5_6: boolean = true
        value_4_11.Visible = value_5_6

        return
    end
end
local g_value = _G
local value_12
do
    local captured_value_6, captured_value_7, captured_value_8 = table_6, new_item_value, show_item
    value_12 = function(argument_1, argument_2, argument_3, argument_4, argument_5)
        local value_7_4 = captured_value_6
        local table_8 = {
            ItemName = argument_1,
            TitleText = argument_2 or "You Got...",
            LFrame = argument_3,
            Type = argument_4 or "Weapons",
            Amount = argument_5,
        }
        table.insert(value_7_4, table_8)
        if not captured_value_7.Visible then
            game_value_4 = 1
            value_8 = #captured_value_6
            captured_value_8()
        else
            value_8 = value_8 + 1
        end
        if 1 < value_8 then
            local claim_value_4 = captured_value_7.Container.Claim
            local value_7_8 = "Claim (" .. game_value_4 .. "/" .. value_8 .. ")"
            claim_value_4.Text = value_7_8

            return
        end
        local claim_value_5 = captured_value_7.Container.Claim
        local value_7_9: string = "Claim"
        claim_value_5.Text = value_7_9

        return
    end
end
g_value.NewItem = value_12
local mouse_button1_click_value = new_item_value.Container.Claim.MouseButton1Click
local value_13
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13 = require_result, new_item_value, game_value, table_6, show_item
    value_13 = function()
        captured_value_9.AnimateItemIconIntoInventory(
            captured_value_10.Container.NewItem.Container.Icon,
            captured_value_11.Dock.Inventory,
            captured_value_11
        )
        local value_1_6 = captured_value_10
        local value_2_7: boolean = false
        value_1_6.Visible = value_2_7
        local g_value_3 = _G
        local value_2_8: nil = nil
        g_value_3.UnfinishedItem = value_2_8
        local g_value_4 = _G
        local value_2_9: nil = nil
        g_value_4.UnfinishedType = value_2_9
        table.remove(captured_value_12, 1)
        local new_item_blur_value_2 = game.Lighting.NewItemBlur
        local value_2_11: boolean = false
        new_item_blur_value_2.Enabled = value_2_11
        if captured_value_12[1] ~= nil then
            game_value_4 = game_value_4 + 1
            if 1 < value_8 then
                local claim_value_6 = captured_value_10.Container.Claim
                local value_2_15 = "Claim (" .. game_value_4 .. "/" .. value_8 .. ")"
                claim_value_6.Text = value_2_15
            else
                local claim_value_7 = captured_value_10.Container.Claim
                local value_2_16: string = "Claim"
                claim_value_7.Text = value_2_16
            end
            captured_value_13()

            return
        end
        value_8 = 1
        game_value_4 = 1
        if value_5 then
            local value_1_16 = value_5
            local value_2_17: boolean = true
            value_1_16.Visible = value_2_17
        end

        return
    end
end
mouse_button1_click_value:connect(value_13)
local replicated_storage_value_2 = game.ReplicatedStorage
local value_13_2: string = "ItemGift"
local on_client_event_value = replicated_storage_value_2:WaitForChild(value_13_2).OnClientEvent

local function value_13_3(argument_1_2, argument_2_2): ()
    _G.NewItem(argument_1_2, "You Got...", nil, argument_2_2)

    return
end

on_client_event_value:connect(value_13_3)

return
