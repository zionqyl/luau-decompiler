--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "EventInfoService"
local get_current_item_pack_result = require_value(shared_services_child:WaitForChild(value_5_3)):GetCurrentItemPack()
if not get_current_item_pack_result then
    return {}
end
local require_value_2 = require
local game_value_2: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "ItemService"
local value_2 = (require_value_2(client_services_child:WaitForChild(value_7_3)))
local require_value_3 = require
local game_value_3: DataModel = game
local value_7_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_7_4)
local value_7_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service_3:WaitForChild(value_7_5)
local value_7_6: string = "ItemPackService"
local require_result_3 = require_value_3(modules_child:WaitForChild(value_7_6))
local parent_value_2 = script.Parent.Parent
local value_7_7: string = "Container"
local container_child = parent_value_2:WaitForChild(value_7_7)
local value_7_8: string = "ItemPack"
local item_pack_child = container_child:WaitForChild(value_7_8)
local value_7_9: string = "Main"
local main_child = item_pack_child:WaitForChild(value_7_9)
local item_id_value = get_current_item_pack_result.ItemPackItems.Knife.ItemID
local item_id_value_2 = get_current_item_pack_result.ItemPackItems.Gun.ItemID
local effect_item_id_value = get_current_item_pack_result.ItemPackItems.Bundle.EffectItemID
local value_11: string = "Weapons"
local value_12 = item_id_value
local value_3_5 = (value_2:GetItemInfo(value_11, value_12))
local icon_value = main_child.Knife.Center.Item.IconContainer.Icon
local value_12_2 = value_3_5
local get_item_image_result = value_2:GetItemImage(value_12_2)
icon_value.Image = get_item_image_result
local name_label_value = main_child.Knife.Center.Item.ItemName.NameLabel
local value_12_3 = value_3_5
local get_display_name_result = value_2:GetDisplayName(value_12_3)
name_label_value.Text = get_display_name_result
local shadow_value = main_child.Knife.Center.Item.ItemName.Shadow
local value_12_4 = value_3_5
local get_display_name_result_2 = value_2:GetDisplayName(value_12_4)
shadow_value.Text = get_display_name_result_2
local value_11_5: string = "Weapons"
local value_12_5 = item_id_value_2
local value_6_10 = (value_2:GetItemInfo(value_11_5, value_12_5))
local icon_value_2 = main_child.Gun.Center.Item.IconContainer.Icon
local value_12_6 = value_6_10
local get_item_image_result_2 = value_2:GetItemImage(value_12_6)
icon_value_2.Image = get_item_image_result_2
local name_label_value_2 = main_child.Gun.Center.Item.ItemName.NameLabel
local value_12_7 = value_6_10
local get_display_name_result_3 = value_2:GetDisplayName(value_12_7)
name_label_value_2.Text = get_display_name_result_3
local shadow_value_2 = main_child.Gun.Center.Item.ItemName.Shadow
local value_12_8 = value_6_10
local get_display_name_result_4 = value_2:GetDisplayName(value_12_8)
shadow_value_2.Text = get_display_name_result_4
local value_11_9: string = "Effects"
local value_12_9 = effect_item_id_value
local value_7_10 = (value_2:GetItemInfo(value_11_9, value_12_9))
local knife_icon_value = main_child.Bundle.Center.Item.IconContainer.KnifeIcon
local value_12_10 = value_3_5
local get_item_image_result_3 = value_2:GetItemImage(value_12_10)
knife_icon_value.Image = get_item_image_result_3
local gun_icon_value = main_child.Bundle.Center.Item.IconContainer.GunIcon
local value_12_11 = value_6_10
local get_item_image_result_4 = value_2:GetItemImage(value_12_11)
gun_icon_value.Image = get_item_image_result_4
local effect_icon_value = main_child.Bundle.Center.Item.IconContainer.EffectIcon
local value_12_12 = value_7_10
local get_item_image_result_5 = value_2:GetItemImage(value_12_12)
effect_icon_value.Image = get_item_image_result_5
local activated_value = main_child.Knife.Center.Confirm.Activated
local prompt_buy_knife_value = require_result_3.PromptBuyKnife
activated_value:Connect(prompt_buy_knife_value)
local activated_value_2 = main_child.Gun.Center.Confirm.Activated
local prompt_buy_gun_value = require_result_3.PromptBuyGun
activated_value_2:Connect(prompt_buy_gun_value)
local activated_value_3 = main_child.Bundle.Center.Confirm.Activated
local prompt_buy_bundle_value = require_result_3.PromptBuyBundle
activated_value_3:Connect(prompt_buy_bundle_value)

return table_1
