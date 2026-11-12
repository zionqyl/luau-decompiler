--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_3)
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "ItemService"
local require_result = require_value(client_services_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "ItemPopupService"
local require_result_2 = require_value_2(client_services_child_2:WaitForChild(value_6_3))
local game_value_4: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_6_4)
local value_6_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_5)
local value_6_6: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_6_6)
local game_value_5: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_5:GetService(value_7)
local value_7_2: string = "Remotes"
local remotes_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "Shop"
local shop_child = remotes_child_2:WaitForChild(value_7_3)
local game_value_6: DataModel = game
local value_8: string = "GuiService"
local gui_service: Instance = game_value_6:GetService(value_8)
local game_value_7: DataModel = game
local value_9: string = "UserInputService"
local user_input_service: Instance = game_value_7:GetService(value_9)
local game_value_8: DataModel = game
local value_10: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_8:GetService(value_10)
local value_10_2: string = "ItemGift"
local item_gift_child: Instance? = replicated_storage_service_5:WaitForChild(value_10_2)
local parent_value: Instance? = script.Parent
local value_12: string = "Medium"
local medium_child = parent_value:WaitForChild(value_12)
local value_13: string = "Container"
local container_child = medium_child:WaitForChild(value_13)
local value_13_2: string = "Claim"
local claim_child = container_child:WaitForChild(value_13_2)
local value_14: string = "Container"
local container_child_2 = medium_child:WaitForChild(value_14)
local value_14_2: string = "NewItem"
local new_item_child = container_child_2:WaitForChild(value_14_2)
local game_value_9: DataModel = game
local value_15 = "Lighting"
local lighting_service: Instance = game_value_9:GetService(value_15)
value_15 = "NewItemBlur"
local new_item_blur_child: Instance? = lighting_service:WaitForChild(value_15)
local table_14 = {}
value_15 = 1
local value_16 = 0
local new_result: TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local play_inventory_animation: (<T3>(string, string, T3) -> ())?
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6 = new_item_child, require_result_2, require_result, parent_value, tween_service, new_result
    play_inventory_animation = function<T3>(argument_1: string, argument_2: string, argument_3: T3): ()
        local value_4_10 = captured_value
        local value_6_11: string = "Container"
        local container_child_3 = value_4_10:WaitForChild(value_6_11)
        local value_6_12: string = "Icon"
        local icon_child = container_child_3:WaitForChild(value_6_12)
        local animation_target_location_value = captured_value_2.AnimationTargetLocation
        local script_value_2: LuaSourceContainer = script
        local value_8_5: string = "ItemIcon"
        local cloned_value = script_value_2:WaitForChild(value_8_5):Clone()
        local value_7_8 = captured_value_3
        local value_9_4: string = argument_1
        local value_10_4: string = argument_2
        local image_value = value_7_8:GetDisplayInfo(value_9_4, value_10_4).Image
        cloned_value.Image = image_value
        local from_offset_result: UDim2 = UDim2.fromOffset(
            icon_child.AbsoluteSize.X,
            icon_child.AbsoluteSize.Y
        )
        local from_offset_result_2: UDim2 = UDim2.fromOffset(
            icon_child.AbsolutePosition.X,
            icon_child.AbsolutePosition.Y
        )
        local value_4_13: UDim2 = (UDim2.fromOffset(25, 25))
        local value_9_5: nil = nil
        local value_9_6
        if animation_target_location_value then
            value_9_6 = (UDim2.fromOffset(
                animation_target_location_value.AbsolutePosition.X,
                animation_target_location_value.AbsolutePosition.Y
            ))
        else
            value_9_6 = (UDim2.new(0.5, 0, 1, 25))
        end
        cloned_value.Size = from_offset_result
        cloned_value.Position = from_offset_result_2
        local value_10_6: Instance? = captured_value_4
        local value_12_7: string = "Animation"
        local animation_child = value_10_6:WaitForChild(value_12_7)
        cloned_value.Parent = animation_child
        local value_10_8: Instance = captured_value_5
        local value_12_8 = cloned_value
        local value_13_8: TweenInfo = captured_value_6
        local table_14_2 = {
            Position = value_9_6 + (UDim2.fromOffset(12, 8)),
            Size = value_4_13,
        }
        value_10_8:Create(value_12_8, value_13_8, table_14_2):Play()
        local debris_value = game.Debris
        local value_12_9 = cloned_value
        local value_13_9: number = 0.5
        debris_value:AddItem(value_12_9, value_13_9)

        return
    end
end
local show_new_item
do
    local captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14 = table_14, require_result, new_item_child, medium_child, new_item_blur_child, user_input_service, gui_service, claim_child
    show_new_item = function()
        local value_1_2 = captured_value_7[1]
        local id_value = value_1_2.ID
        local type_value = value_1_2.Type
        local value_4_14 = value_1_2.Amount or 1
        local value_5_16 = captured_value_8
        local value_7_10 = id_value
        local value_8_8 = type_value
        local value_1_3 = (value_5_16:GetDisplayInfo(value_7_10, value_8_8))
        local value_5_18 = captured_value_9
        local value_7_11: string = "Container"
        local container_child_4 = value_5_18:WaitForChild(value_7_11)
        local value_7_12: string = "Icon"
        local icon_child_2 = container_child_4:WaitForChild(value_7_12)
        local image_value_2 = value_1_3.Image
        icon_child_2.Image = image_value_2
        local value_5_21 = captured_value_9
        local value_7_13: string = "ItemName"
        local item_name_child = value_5_21:WaitForChild(value_7_13)
        local value_7_14: string = "Label"
        local label_child = item_name_child:WaitForChild(value_7_14)
        local name_value = value_1_3.Name
        label_child.Text = name_value
        local value_5_24 = captured_value_9
        local value_7_15: string = "ItemName"
        local item_name_child_2 = value_5_24:WaitForChild(value_7_15)
        local color_value = value_1_3.Color
        item_name_child_2.BackgroundColor3 = color_value
        local value_5_26 = captured_value_9
        local value_7_16: string = "Tags"
        local tags_child = value_5_26:WaitForChild(value_7_16)
        local value_7_17: string = "Chroma"
        local chroma_child = tags_child:WaitForChild(value_7_17)
        local chroma_value = value_1_3.Chroma
        chroma_child.Visible = chroma_value
        local value_5_29 = captured_value_10
        local value_7_18: string = "Container"
        local container_child_5 = value_5_29:WaitForChild(value_7_18)
        local value_7_19: string = "Starburst"
        local starburst_child = container_child_5:WaitForChild(value_7_19)
        local color_value_2 = value_1_3.Color
        starburst_child.ImageColor3 = color_value_2
        local amount_value_2 = captured_value_9.Container.Amount
        local value_7_20: number = 1
        local format_result
        do
            local take_fallback = not (value_7_20 < value_4_14)
            if not take_fallback then
                local value_6_25: string = "x%*"
                local value_8_9 = value_4_14
                format_result = value_6_25:format(value_8_9)
                take_fallback = not format_result
            end
            if take_fallback then
                format_result = ""
            end
        end
        amount_value_2.Text = format_result
        if 1 < value_16 then
            local value_5_34 = captured_value_10
            local value_7_22: string = "Container"
            local container_child_6 = value_5_34:WaitForChild(value_7_22)
            local value_7_23: string = "Claim"
            local claim_child_2 = container_child_6:WaitForChild(value_7_23)
            local value_6_30: string = "Claim (%*/%*)"
            local value_8_10 = value_15
            local value_9_7 = value_16
            local format_result_2 = value_6_30:format(value_8_10, value_9_7)
            claim_child_2.Text = format_result_2
        else
            local value_5_37 = captured_value_10
            local value_7_25: string = "Container"
            local container_child_7 = value_5_37:WaitForChild(value_7_25)
            local value_7_26: string = "Claim"
            local claim_child_3 = container_child_7:WaitForChild(value_7_26)
            local value_6_34: string = "Claim"
            claim_child_3.Text = value_6_34
        end
        local value_5_40: Instance? = captured_value_11
        local value_6_35: boolean = true
        value_5_40.Enabled = value_6_35
        local value_5_41 = captured_value_10
        local value_6_36: boolean = true
        value_5_41.Visible = value_6_36
        local value_4_15: boolean?
        if captured_value_12.PreferredInput ~= Enum.PreferredInput.Gamepad then
            value_4_15 = false
        else
            value_4_15 = true
        end
        if value_4_15 then
            local value_5_43: Instance = captured_value_13
            local value_6_37 = captured_value_14
            value_5_43.SelectedObject = value_6_37
        end
        local image_label_value = captured_value_14.ImageLabel
        image_label_value.Visible = value_4_15

        return
    end
end
local on_new_item
do
    local captured_value_15, captured_value_16 = table_14, show_new_item
    on_new_item = function(argument_1_2: string, argument_2_2: string, argument_3_2: number?)
        local value_5_45 = captured_value_15
        local table_6 = {
            ID = argument_1_2,
            Type = argument_2_2,
            Amount = argument_3_2,
        }
        table.insert(value_5_45, table_6)
        value_16 = value_16 + 1
        captured_value_16()

        return
    end
end
local on_item_claimed
do
    local captured_value_17, captured_value_18, captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24 = play_inventory_animation, table_14, show_new_item, gui_service, medium_child, shop_child, new_item_blur_child, require_result_2
    on_item_claimed = function()
        captured_value_17(captured_value_18[1].ID, captured_value_18[1].Type)
        table.remove(captured_value_18, 1)
        if captured_value_18[1] ~= nil then
            value_15 = value_15 + 1
            captured_value_19()

            return
        end
        local value_1_9: Instance = captured_value_20
        local value_2_6: nil = nil
        value_1_9.SelectedObject = value_2_6
        local value_1_10 = captured_value_21
        local value_2_7: boolean = false
        value_1_10.Visible = value_2_7
        local value_1_11 = captured_value_22
        local value_3_8: string = "NewItemsClaimed"
        value_1_11:WaitForChild(value_3_8):Fire()
        value_16 = 0
        value_15 = 1
        local value_1_16: Instance? = captured_value_23
        local value_2_10: boolean = false
        value_1_16.Enabled = value_2_10
        captured_value_24.ItemClaimsComplete:Fire()

        return
    end
end
local on_initialize
do
    local captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32 = medium_child, on_item_claimed, require_result_2, on_new_item, shop_child, inventory_child, item_gift_child, gui_service
    on_initialize = function()
        local value_1_19 = captured_value_25
        local value_2_12: boolean = false
        value_1_19.Visible = value_2_12
        local value_1_20 = captured_value_25
        local value_3_9: string = "Container"
        local container_child_8 = value_1_20:WaitForChild(value_3_9)
        local value_3_10: string = "Claim"
        local activated_value = container_child_8:WaitForChild(value_3_10).Activated
        local value_3_11 = captured_value_26
        activated_value:Connect(value_3_11)
        local event_value = captured_value_27.ItemReceived.Event
        local value_3_12 = captured_value_28
        event_value:Connect(value_3_12)
        local event_value_2 = captured_value_29.NewItemReceived.Event
        local value_3_13 = captured_value_28
        event_value_2:Connect(value_3_13)
        local on_client_event_value = captured_value_30.ItemReceived.OnClientEvent
        local value_3_14 = captured_value_28
        on_client_event_value:Connect(value_3_14)
        local on_client_event_value_2 = captured_value_31.OnClientEvent
        local value_3_15 = captured_value_28
        on_client_event_value_2:Connect(value_3_15)
        if (captured_value_32:IsTenFootInterface()) then
            local value_1_34 = captured_value_25
            local value_3_16: string = "Container"
            local container_child_9 = value_1_34:WaitForChild(value_3_16)
            local value_3_17: string = "UIScale"
            local ui_scale_child = container_child_9:WaitForChild(value_3_17)
            local value_2_23: number = 1.5
            ui_scale_child.Scale = value_2_23
        end

        return
    end
end
on_initialize()

return
