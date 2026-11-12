--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("EquippedChanged")] = nil,
    [("EquippedChanged")] = nil,
    [("EquippedChanged")] = nil,
    [("EquippedChanged")] = nil,
    [("EquippedChanged")] = nil,
}
local script_value: LuaSourceContainer = script
local value_4: string = "EquipContainer"
local equip_container_child: Instance? = script_value:WaitForChild(value_4)
local require_value = require
local game_value: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "ProfileData"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local game_value_2: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6_4)
local value_6_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_5)
local game_value_3: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_7_2)
local require_value_2 = require
local value_9: string = "ItemService"
local require_result_2 = require_value_2(client_services_child:WaitForChild(value_9))
local table_5 = {Perks = true, Knife = true, Gun = true}
local table_7 = {}
local script_value_2: LuaSourceContainer = script
local value_10: string = "EquippedChanged"
local equipped_changed_child: Instance? = script_value_2:WaitForChild(value_10)
table_1.EquippedChanged = equipped_changed_child
local equip_item
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = require_result_2, require_result, table_1, remotes_child
    equip_item = function<T1>(argument_1: T1, argument_2: string, argument_3: string)
        local value_4_7 = captured_value
        local value_6_8: string = argument_2
        local value_7_4: string = argument_3
        local get_item_info_result = value_4_7:GetItemInfo(value_6_8, value_7_4)
        if argument_2 == "Weapons" then
            local item_type_value = get_item_info_result.ItemType
            local equipped_value = captured_value_2.Weapons.Equipped
            equipped_value[item_type_value] = argument_3
            local equipped_changed_value_2: Instance? = captured_value_3.EquippedChanged
            local value_8_3 = item_type_value
            local value_9_4: string = argument_3
            equipped_changed_value_2:Fire(value_8_3, value_9_4)
        else
            local value_5_9 = captured_value_2[argument_2]
            local table_6 = {argument_3}
            value_5_9.Equipped = table_6
            local equipped_changed_value_3: Instance? = captured_value_3.EquippedChanged
            local value_7_7: string = argument_2
            local value_8_4: string = argument_3
            equipped_changed_value_3:Fire(value_7_7, value_8_4)
        end
        local equip_value = captured_value_4.Inventory.Equip
        local value_7_8: string = argument_3
        local value_8_5: string = argument_2
        equip_value:FireServer(value_7_8, value_8_5)

        return
    end
end
table_1.EquipItem = equip_item
local unequip_item
do
    local captured_value_5, captured_value_6, captured_value_7 = require_result, remotes_child, table_1
    unequip_item = function<T1>(argument_1_2: T1, argument_2_2: string)
        if argument_2_2 == "Knife" then
            local equipped_value_2 = captured_value_5.Weapons.Equipped
            local value_4_9: string = "DefaultKnife"
            equipped_value_2.Knife = value_4_9
        else
            if argument_2_2 == "Gun" then
                local equipped_value_3 = captured_value_5.Weapons.Equipped
                local value_4_10: string = "DefaultGun"
                equipped_value_3.Gun = value_4_10
            else
                local value_3_4 = captured_value_5[argument_2_2]
                local table_4 = {}
                value_3_4.Equipped = table_4
                local unequip_value = captured_value_6.Inventory.Unequip
                local value_5_14: number = 1
                local value_6_15: string = argument_2_2
                unequip_value:FireServer(value_5_14, value_6_15)
            end
        end
        local equipped_changed_value_4 = captured_value_7.EquippedChanged
        local value_5_15: string = argument_2_2
        local value_6_16: nil = nil
        equipped_changed_value_4:Fire(value_5_15, value_6_16)

        return
    end
end
table_1.UnequipItem = unequip_item
local get_equipped
do
    local captured_value_8 = require_result
    get_equipped = function<T1>(argument_1_3: T1, argument_2_3: string)
        if argument_2_3 == "Knife" then
            return captured_value_8.Weapons.Equipped.Knife
        end
        if argument_2_3 == "Gun" then
            return captured_value_8.Weapons.Equipped.Gun
        end

        return captured_value_8[argument_2_3].Equipped[1]
    end
end
table_1.GetEquipped = get_equipped
local create_equip_container
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12 = equip_container_child, require_result_2, table_5, table_7
    create_equip_container = function<T1>(argument_1_4: T1, argument_2_4: string)
        local cloned_value = captured_value_9:Clone()
        cloned_value.ItemFrame:Destroy()
        local cloned_value_2 = captured_value_10.BaseItemFrame:Clone()
        cloned_value_2.Parent = cloned_value
        if captured_value_11[argument_2_4] then
            cloned_value_2.UIPadding:Destroy()
        end
        local value_5_21 = captured_value_12
        value_5_21[argument_2_4] = cloned_value

        return cloned_value
    end
end
table_1.CreateEquipContainer = create_equip_container
local on_equipped_changed
do
    local captured_value_13, captured_value_14 = table_7, require_result_2
    on_equipped_changed = function(argument_1_5: string, argument_2_5: string?)
        local value_3_14 = captured_value_13[argument_1_5]
        if not value_3_14 then
            return
        end
        local value_4_20: string?
        if argument_1_5 == "Knife" then
            value_4_20 = "Weapons"
        else
            if argument_1_5 == "Gun" then
                value_4_20 = "Weapons"
            else
                value_4_20 = argument_1_5
            end
        end
        local value_5_22 = nil
        if argument_2_5 then
            local value_6_19 = captured_value_14
            local value_8_6: string = value_4_20
            local value_9_5: string = argument_2_5
            value_5_22 = (value_6_19:GetItemInfo(value_8_6, value_9_5))
        end
        local value_8_7: string = "ItemFrame"
        local item_frame_child = value_3_14:WaitForChild(value_8_7)
        local value_7_11: boolean?
        if argument_2_5 == nil then
            value_7_11 = false
        else
            value_7_11 = true
        end
        item_frame_child.Visible = value_7_11
        local unequip_value_2 = value_3_14.Unequip
        local value_8_8: boolean = false
        if argument_2_5 ~= nil then
            value_8_8 = false
            if value_4_20 ~= "Perks" then
                if value_4_20 == "Weapons" then
                    value_8_8 = false
                else
                    value_8_8 = true
                end
            end
        end
        unequip_value_2.Visible = value_8_8
        local value_7_12 = captured_value_14
        local value_9_6 = item_frame_child
        local value_10_3 = value_5_22
        value_7_12:ApplyItemToFrame(value_9_6, value_10_3)
        local value_7_14 = captured_value_14
        local value_9_7 = item_frame_child
        local value_10_4 = value_5_22
        value_7_14:UpdateTags(value_9_7, value_10_4)

        return
    end
end
local bind_equip_container
do
    local captured_value_15, captured_value_16, captured_value_17 = table_7, on_equipped_changed, table_1
    bind_equip_container = function<T1>(argument_1_6: T1, argument_2_6: string, argument_3_2)
        local value_4_21 = captured_value_15
        value_4_21[argument_2_6] = argument_3_2
        local value_4_22 = captured_value_16
        local value_5_23: string = argument_2_6
        local value_6_22 = captured_value_17
        local value_8_11: string = argument_2_6
        value_4_22(value_5_23, value_6_22:GetEquipped(value_8_11))

        return
    end
end
table_1.BindEquipContainer = bind_equip_container
local event_value = table_1.EquippedChanged.Event
local value_11 = on_equipped_changed
event_value:Connect(value_11)

return table_1
