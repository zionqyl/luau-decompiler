--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local game_value_2 = script.Parent.Parent.Game
local crafting_value = game_value_2.Crafting
local salvage_value = game_value_2.Salvage
local inventory_value = game_value_2.Inventory
local require_result_2 = require(game.ReplicatedStorage.Modules.CraftModule)
local scroll_frame_value = crafting_value.Inventory.Salvage.ScrollFrame
local scroll_frame_value_2 = crafting_value.Inventory.Craft.ScrollFrame
local recipe_value = script.Recipe
local item_value = script.Item
local confirm_value = crafting_value.Action.Confirm
require_result_2.SetSalvageConfirmButton(require_result_2.ShowSalvageRewards)
require_result_2.SetCraftConfirmButton(require_result_2.UpdateCraftConfirm)
require_result_2.SetCraftGUI(
    crafting_value,
    scroll_frame_value_2,
    recipe_value,
    crafting_value.Action,
    scroll_frame_value,
    item_value,
    crafting_value.Action.Salvage,
    salvage_value,
    confirm_value
)
require_result_2.GenerateRecipes()
require_result_2.GenerateSalvageInventory(
    crafting_value.Inventory.Salvage.ScrollFrame,
    script.Item
)
local value_15: string = "Crafting"
local crafting_child = game_value_2:WaitForChild(value_15)
local value_14_3: string = "Crafting"
require_result:RegisterFrame(crafting_child, value_14_3)
local activated_value = crafting_value.Title.Back.Activated
local value_13_3: (() -> ())?
do
    local captured_value = require_result
    value_13_3 = function(): ()
        captured_value:Back()

        return
    end
end
activated_value:Connect(value_13_3)
local mouse_button1_click_value = crafting_value.Action.Nav.Salvage.MouseButton1Click
local value_13_4: (() -> ())?
do
    local captured_value_2, captured_value_3 = crafting_value, require_result_2
    value_13_4 = function(): ()
        local craft_value_3 = captured_value_2.Inventory.Craft
        local value_2_5: boolean = false
        craft_value_3.Visible = value_2_5
        local salvage_value_6 = captured_value_2.Inventory.Salvage
        local value_2_6: boolean = true
        salvage_value_6.Visible = value_2_6
        local craft_value_4 = captured_value_2.Action.Craft
        local value_2_7: boolean = false
        craft_value_4.Visible = value_2_7
        local salvage_value_7 = captured_value_2.Action.Salvage
        local value_2_8: boolean = true
        salvage_value_7.Visible = value_2_8
        local salvage_value_8 = captured_value_2.Action.Nav.Salvage
        local roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
        salvage_value_8.Style = roblox_round_default_button_value
        local craft_value_5 = captured_value_2.Action.Nav.Craft
        local roblox_round_button_value = Enum.ButtonStyle.RobloxRoundButton
        craft_value_5.Style = roblox_round_button_value
        captured_value_3.ChangeMode("Salvage", true)

        return
    end
end
mouse_button1_click_value:connect(value_13_4)
local mouse_button1_click_value_2 = crafting_value.Action.Nav.Craft.MouseButton1Click
local value_13_5: (() -> ())?
do
    local captured_value_4, captured_value_5 = crafting_value, require_result_2
    value_13_5 = function(): ()
        local craft_value_6 = captured_value_4.Inventory.Craft
        local value_2_10: boolean = true
        craft_value_6.Visible = value_2_10
        local salvage_value_9 = captured_value_4.Inventory.Salvage
        local value_2_11: boolean = false
        salvage_value_9.Visible = value_2_11
        local craft_value_7 = captured_value_4.Action.Craft
        local value_2_12: boolean = true
        craft_value_7.Visible = value_2_12
        local salvage_value_10 = captured_value_4.Action.Salvage
        local value_2_13: boolean = false
        salvage_value_10.Visible = value_2_13
        local craft_value_8 = captured_value_4.Action.Nav.Craft
        local roblox_round_default_button_value_2 = Enum.ButtonStyle.RobloxRoundDefaultButton
        craft_value_8.Style = roblox_round_default_button_value_2
        local salvage_value_11 = captured_value_4.Action.Nav.Salvage
        local roblox_round_button_value_2 = Enum.ButtonStyle.RobloxRoundButton
        salvage_value_11.Style = roblox_round_button_value_2
        captured_value_5.ChangeMode("Craft", true)

        return
    end
end
mouse_button1_click_value_2:connect(value_13_5)
local mouse_button1_click_value_3 = salvage_value.Claim.MouseButton1Click
local value_13_6: (() -> ())?
do
    local captured_value_6, captured_value_7 = salvage_value, crafting_value
    value_13_6 = function(): ()
        if captured_value_6.Claim.Style == Enum.ButtonStyle.RobloxRoundDefaultButton then
            local value_1_18 = captured_value_6
            local value_2_15: boolean = false
            value_1_18.Visible = value_2_15
            local value_1_19 = captured_value_7
            local value_2_16: boolean = true
            value_1_19.Visible = value_2_16
        end

        return
    end
end
mouse_button1_click_value_3:connect(value_13_6)

return
