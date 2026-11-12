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

local parent_value_2 = script.Parent.Parent
local value_3: string = "Game"
local game_child = parent_value_2:WaitForChild(value_3)
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_5)
local require_value = require
local game_value_2: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "ProfileData"
local value_2_3 = (require_value(modules_child:WaitForChild(value_7_3)))
local require_value_2 = require
local game_value_3: DataModel = game
local value_7_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_7_4)
local value_7_5: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_7_5)
local value_7_6: string = "ItemPopupService"
local require_result_2 = require_value_2(client_services_child:WaitForChild(value_7_6))
local value_7_7: string = "Inventory"
local inventory_child = game_child:WaitForChild(value_7_7)
local value_8: string = "Dock"
local dock_child = game_child:WaitForChild(value_8)
local require_value_3 = require
local game_value_4: DataModel = game
local value_10 = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_10)
value_10 = "Modules"
local modules_child_2: Instance? = replicated_storage_service_4:WaitForChild(value_10)
value_10 = "WindowService"
local require_result_3 = require_value_3(modules_child_2:WaitForChild(value_10))
local replicated_storage_value = game.ReplicatedStorage
value_10 = "Modules"
local modules_child_3 = replicated_storage_value:WaitForChild(value_10)
local require_value_4 = require
local value_12 = "InventoryModule"
local require_result_4 = require_value_4(modules_child_3:WaitForChild(value_12))
value_10 = require_result_4.GUI
local value_11 = {}
value_10.MyInventory = value_11
value_10 = require_result_4.GUI.MyInventory
value_11 = inventory_child.Main
value_10.Main = value_11
value_10 = require_result_4.GUI.MyInventory
value_11 = inventory_child.Nav
value_10.Nav = value_11
value_10 = require_result_4.GUI
value_11 = game_child.NewItem
value_10.NewItem = value_11
value_10 = require_result_4.GUI
value_11 = inventory_child.Main.Weapons.EvoMenu
value_10.EvoMenu = value_11
value_10 = pairs
value_11 = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_13 = "Weapons"
local value_14 = "Effects"
local value_15 = "Perks"
local value_16 = "Emotes"
local value_17 = "Radios"
local value_18 = "Pets"
value_11[1], value_11[2], value_11[3], value_11[4], value_11[5], value_11[6] = value_13, value_14, value_15, value_16, value_17, value_18
value_10, value_11, value_12 = value_10(value_11)
for key_2, value_23 in value_10, value_11, value_12 do
    value_13, value_14 = key_2, value_23
    value_15 = pairs
    value_18 = require_result_4.CreateBlankInventoryTable()
    value_15, value_16, value_17 = value_15(value_18[value_14])
    for key, value in value_15, value_16, value_17 do
        local value_19
        value_18, value_19 = key, value
        local main_value = inventory_child.Main
        local value_22 = value_14
        local value_20_2 = main_value:FindFirstChild(value_22)
        local items_value = value_20_2.Items
        local container_value = items_value.Container
        local value_22_2 = value_18
        local find_first_child_result = container_value:FindFirstChild(value_22_2)
        local value_8_6 = find_first_child_result
        if not value_8_6 then
            local main_value_2 = inventory_child.Main
            local value_22_3 = value_14
            local value_20_5 = main_value_2:FindFirstChild(value_22_3)
            local items_value_2 = value_20_5.Items
            local container_value_2 = items_value_2.Container
            local value_22_4: string = "Holiday"
            local holiday_child = container_value_2:FindFirstChild(value_22_4)
            local container_value_3 = holiday_child.Container
            local value_22_5 = value_18
            local find_first_child_result_2 = container_value_3:FindFirstChild(value_22_5)
            value_8_6 = find_first_child_result_2
        end
        local container_value_4 = value_8_6.Container
        container_value_4:ClearAllChildren()
    end
end
value_10 = require_result_4.GenerateInventory(inventory_child, value_2_3)
require_result_4.MyInventory = value_10
local container_value_5 = inventory_child.Main.Weapons.Items.Container
value_10 = container_value_5.Holiday.Container.EventLayout
value_12 = "AbsoluteContentSize"
value_10 = value_10:GetPropertyChangedSignal(value_12)
do
    local captured_value = container_value_5
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        value_12 = closure_cache[1]
    else
        local closure_ready
        value_12 = function(): ()
            if not closure_ready then
                return
            end
            local container_value_7 = captured_value.Holiday.Container
            local new_result = UDim2.new(
                1,
                0,
                0,
                captured_value.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 3
            )
            container_value_7.Size = new_result
            local holiday_value_3 = captured_value.Holiday
            local new_result_2 = UDim2.new(
                1,
                0,
                0,
                captured_value.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 6
            )
            holiday_value_3.CanvasSize = new_result_2

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = value_12
            closure_cache[2] = captured_value
        end
    end
end
value_10:connect(value_12)
require_result_4.ConnectNavButtons(inventory_child.Nav, inventory_child.Main)
require_result_4.ConnectTabButtons(inventory_child, "Weapons")
require_result_4.UpdateMyEquip()
require_result_4.ConnectEquipButtons()
require_result_4.ConnectPetNaming(
    inventory_child.Main.Pets.Equipped.Container.NameYourPet.Container2
)
require_result_4.ConnectCodeFrame(inventory_child.Main.Weapons.Equipped.Container.Codes)
require_result_4.ConnectEvoMenu()
value_14 = "Inventory"
value_12 = game_child:WaitForChild(value_14)
value_13 = "Inventory"
require_result_3:RegisterFrame(value_12, value_13)
value_10 = dock_child.Inventory.Activated
do
    local captured_value_2 = require_result_3
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) then
        value_12 = closure_cache[3]
    else
        local closure_ready_2
        value_12 = function(): ()
            if not closure_ready_2 then
                return
            end
            local value_1_4 = captured_value_2
            local value_3_7: string = "Inventory"
            value_1_4:ToggleFrame(value_3_7)

            return
        end
        closure_ready_2 = true
        if closure_cache[3] == nil then
            closure_cache[3] = value_12
            closure_cache[4] = captured_value_2
        end
    end
end
value_10:Connect(value_12)
local search_text_value = inventory_child.Main.Weapons.Items.Tabs.Search.Container.SearchText
value_12 = "Text"
value_10 = search_text_value:GetPropertyChangedSignal(value_12)
do
    local captured_value_3, captured_value_4 = search_text_value, require_result_4
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_3) and same_capture(
        closure_cache[7],
        captured_value_4
    ) then
        value_12 = closure_cache[5]
    else
        local closure_ready_3
        value_12 = function(): ()
            if not closure_ready_3 then
                return
            end
            local text_value = captured_value_3.Text
            local value_1_7 = (string.gsub(text_value, "S", ""))
            local value_2_5 = nil
            local value_3_8, value_4_5, value_5_11 = pairs(
                captured_value_4.MyInventory.Data.Weapons
            )
            for key_4, value_25 in value_3_8, value_4_5, value_5_11 do
                local value_6_11, value_7_11 = key_4, value_25
                local value_8_7 = value_7_11
                local value_9_5: nil = nil
                local value_10_2: nil = nil
                for key_3, value_24 in value_8_7, value_9_5, value_10_2 do
                    local value_11_2, value_12_2 = key_3, value_24
                    local frame_value = value_12_2.Frame
                    local find_value = string.find
                    local lower_value = string.lower
                    local name_value = value_12_2.Name
                    local lower_result = lower_value(name_value)
                    local lower_value_2 = string.lower
                    local value_17_2 = value_1_7
                    local find_result = find_value(lower_result, lower_value_2(value_17_2))
                    frame_value.Visible = find_result
                    if value_2_5 then
                        continue
                    end
                    local frame_value_2 = value_12_2.Frame
                    local parent_value_3 = frame_value_2.Parent
                    local parent_value_4 = parent_value_3.Parent
                    local value_15_2: string = "ScrollingFrame"
                    local is_a_result = parent_value_4:IsA(value_15_2)
                    if is_a_result then
                        local frame_value_3 = value_12_2.Frame
                        local parent_value_5 = frame_value_3.Parent
                        value_2_5 = parent_value_5.Parent
                    else
                        local frame_value_4 = value_12_2.Frame
                        local parent_value_6 = frame_value_4.Parent
                        local parent_value_7 = parent_value_6.Parent
                        local parent_value_8 = parent_value_7.Parent
                        value_2_5 = parent_value_8.Parent
                    end
                end
            end
            if value_2_5 then
                value_3_8 = Vector2.new(0, 0)
                value_2_5.CanvasPosition = value_3_8
            end

            return
        end
        closure_ready_3 = true
        if closure_cache[5] == nil then
            closure_cache[5] = value_12
            closure_cache[6], closure_cache[7] = captured_value_3, captured_value_4
        end
    end
end
value_10:Connect(value_12)
value_10 = game_child.Processing
value_11 = _G
do
    local captured_value_5 = value_10
    if closure_cache[12] ~= nil and same_capture(closure_cache[13], captured_value_5) then
        value_12 = closure_cache[12]
    else
        local closure_ready_6
        value_12 = function(argument_1)
            if not closure_ready_6 then
                return
            end
            if argument_1 then
                local title_value = captured_value_5.Title
                title_value.Text = argument_1
                local spawn_value = spawn
                local value_3_9
                do
                    local captured_value_6 = captured_value_5
                    if closure_cache[8] ~= nil and same_capture(
                        closure_cache[9],
                        captured_value_6
                    ) then
                        value_3_9 = closure_cache[8]
                    else
                        local closure_ready_4
                        value_3_9 = function(): ()
                            if not closure_ready_4 then
                                return
                            end
                            while true do
                                local value_1_8 = captured_value_6
                                local visible_value = value_1_8.Visible
                                if visible_value ~= true then
                                    break
                                end
                                local value_1_9 = captured_value_6
                                local spinner_value = value_1_9.Spinner
                                local value_3_13 = captured_value_6
                                local spinner_value_2 = value_3_13.Spinner
                                local rotation_value = spinner_value_2.Rotation
                                local value_2_9 = rotation_value + 5
                                spinner_value.Rotation = value_2_9
                                local game_value_6: DataModel = game
                                local value_3_14: string = "RunService"
                                local run_service: Instance = game_value_6:GetService(value_3_14)
                                local render_stepped_value = run_service.RenderStepped
                                render_stepped_value:wait()
                            end

                            return
                        end
                        closure_ready_4 = true
                        if closure_cache[8] == nil then
                            closure_cache[8] = value_3_9
                            closure_cache[9] = captured_value_6
                        end
                    end
                end
                spawn_value(value_3_9)
                local spawn_value_2 = spawn
                local value_3_10
                do
                    local captured_value_7 = captured_value_5
                    if closure_cache[10] ~= nil and same_capture(
                        closure_cache[11],
                        captured_value_7
                    ) then
                        value_3_10 = closure_cache[10]
                    else
                        local closure_ready_5
                        value_3_10 = function(): ()
                            if not closure_ready_5 then
                                return
                            end
                            while true do
                                local value_1_12 = captured_value_7
                                local visible_value_2 = value_1_12.Visible
                                if visible_value_2 ~= true then
                                    break
                                end
                                local wait_value = wait
                                local value_2_12: number = 0.2
                                wait_value(value_2_12)
                                local value_1_13 = captured_value_7
                                local title_value_2 = value_1_13.Title
                                local value_3_15 = captured_value_7
                                local title_value_3 = value_3_15.Title
                                local text_value_2 = title_value_3.Text
                                local value_4_6: string = "."
                                local value_2_13 = text_value_2 .. value_4_6
                                title_value_2.Text = value_2_13
                            end

                            return
                        end
                        closure_ready_5 = true
                        if closure_cache[10] == nil then
                            closure_cache[10] = value_3_10
                            closure_cache[11] = captured_value_7
                        end
                    end
                end
                spawn_value_2(value_3_10)
                local value_2_7 = captured_value_5
                local value_3_11: boolean = true
                value_2_7.Visible = value_3_11

                return
            end
            local value_2_8 = captured_value_5
            local value_3_12: boolean = false
            value_2_8.Visible = value_3_12

            return
        end
        closure_ready_6 = true
        if closure_cache[12] == nil then
            closure_cache[12] = value_12
            closure_cache[13] = captured_value_5
        end
    end
end
value_11.Process = value_12
value_13 = "Inventory"
value_11 = remotes_child:WaitForChild(value_13)
value_13 = "ProfileDataChanged"
value_11 = value_11:WaitForChild(value_13).Event
do
    local captured_value_8, captured_value_9 = require_result_4, inventory_child
    if closure_cache[14] ~= nil and same_capture(closure_cache[15], captured_value_8) and same_capture(
        closure_cache[16],
        captured_value_9
    ) then
        value_13 = closure_cache[14]
    else
        local closure_ready_7
        value_13 = function<T2>(argument_1_2, argument_2: T2): ()
            if not closure_ready_7 then
                return
            end
            if argument_1_2 == "Uniques" then
                captured_value_8.UpdateInventory(captured_value_9, captured_value_8.MyInventory)
            end

            return
        end
        closure_ready_7 = true
        if closure_cache[14] == nil then
            closure_cache[14] = value_13
            closure_cache[15], closure_cache[16] = captured_value_8, captured_value_9
        end
    end
end
value_11:Connect(value_13)
value_13 = "Inventory"
value_11 = remotes_child:WaitForChild(value_13)
value_13 = "InventoryDataChanged"
value_11 = value_11:WaitForChild(value_13).Event
do
    local captured_value_10, captured_value_11 = require_result_4, inventory_child
    if closure_cache[17] ~= nil and same_capture(closure_cache[18], captured_value_10) and same_capture(
        closure_cache[19],
        captured_value_11
    ) then
        value_13 = closure_cache[17]
    else
        local closure_ready_8
        value_13 = function(): ()
            if not closure_ready_8 then
                return
            end
            captured_value_10.UpdateInventory(captured_value_11, captured_value_10.MyInventory)

            return
        end
        closure_ready_8 = true
        if closure_cache[17] == nil then
            closure_cache[17] = value_13
            closure_cache[18], closure_cache[19] = captured_value_10, captured_value_11
        end
    end
end
value_11:Connect(value_13)
value_11 = inventory_child.Main.Weapons.Equipped.Container.Crafting.ActionButton.Activated
do
    local captured_value_12 = require_result_3
    if closure_cache[20] ~= nil and same_capture(closure_cache[21], captured_value_12) then
        value_13 = closure_cache[20]
    else
        local closure_ready_9
        value_13 = function(): ()
            if not closure_ready_9 then
                return
            end
            local value_1_15 = captured_value_12
            local value_3_18: string = "Crafting"
            value_1_15:AddToStack(value_3_18)

            return
        end
        closure_ready_9 = true
        if closure_cache[20] == nil then
            closure_cache[20] = value_13
            closure_cache[21] = captured_value_12
        end
    end
end
value_11:Connect(value_13)
value_11 = inventory_child.Main.Radios.Equipped.Container.ViewSongs.ActionButton.Activated
do
    local captured_value_13 = require_result_3
    if closure_cache[22] ~= nil and same_capture(closure_cache[23], captured_value_13) then
        value_13 = closure_cache[22]
    else
        local closure_ready_10
        value_13 = function(): ()
            if not closure_ready_10 then
                return
            end
            local value_1_17 = captured_value_13
            local value_3_19: string = "Radio"
            value_1_17:AddToStack(value_3_19)

            return
        end
        closure_ready_10 = true
        if closure_cache[22] == nil then
            closure_cache[22] = value_13
            closure_cache[23] = captured_value_13
        end
    end
end
value_11:Connect(value_13)
value_11 = game.Players.LocalPlayer
value_13 = "Radio"
local value_3_4 = (value_11:GetAttribute(value_13))
value_11 = game_child.Inventory.Main.Radios.NoRadioCover
value_12 = not value_3_4
value_11.Visible = value_12
value_11 = game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent
do
    local captured_value_14 = game_child
    if closure_cache[24] ~= nil and same_capture(closure_cache[25], captured_value_14) then
        value_13 = closure_cache[24]
    else
        local closure_ready_11
        value_13 = function(): ()
            if not closure_ready_11 then
                return
            end
            local no_radio_cover_value = captured_value_14.Inventory.Main.Radios.NoRadioCover
            local value_2_17: boolean = false
            no_radio_cover_value.Visible = value_2_17

            return
        end
        closure_ready_11 = true
        if closure_cache[24] == nil then
            closure_cache[24] = value_13
            closure_cache[25] = captured_value_14
        end
    end
end
value_11:connect(value_13)
value_11 = game_child.Inventory.Main.Radios.NoRadioCover.Buy.MouseButton1Click
value_13 = function(): ()
    game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()

    return
end
value_11:connect(value_13)
value_13 = "Dock"
value_11 = game_child:WaitForChild(value_13)
value_13 = "Inventory"
value_11 = value_11:WaitForChild(value_13)
require_result_2.AnimationTargetLocation = value_11

return
