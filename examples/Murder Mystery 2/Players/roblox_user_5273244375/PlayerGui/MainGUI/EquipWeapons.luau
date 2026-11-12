--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_3: string = "Game"
local game_child = parent_value:WaitForChild(value_3)
local value_3_2: string = "Knife"
local knife_child = game_child:WaitForChild(value_3_2)
local parent_value_2: Instance? = script.Parent
local value_4: string = "Game"
local game_child_2 = parent_value_2:WaitForChild(value_4)
local value_4_2: string = "Gun"
local gun_child = game_child_2:WaitForChild(value_4_2)

local function toggle_weapon_equip(argument_1: string): ()
    local backpack_value = game.Players.LocalPlayer.Backpack
    if not backpack_value then
        return
    end
    local character_value = game.Players.LocalPlayer.Character
    if not character_value then
        return
    end
    local value_6_3 = "Humanoid"
    local find_first_child_of_class_result = character_value:FindFirstChildOfClass(value_6_3)
    if not find_first_child_of_class_result then
        return
    end
    local value_5_3, value_7
    value_5_3, value_6_3, value_7 = backpack_value:GetChildren()
    local value_8, value_9
    for key, value in value_5_3, value_6_3, value_7 do
        value_8, value_9 = key, value
        local value_12: string = argument_1
        local has_tag_result = value_9:HasTag(value_12)
        if not has_tag_result then
            continue
        end
        local value_12_2: string = "Tool"
        local is_a_result = value_9:IsA(value_12_2)
        if not is_a_result then
            continue
        end
        local value_12_3 = value_9
        find_first_child_of_class_result:EquipTool(value_12_3)

        return
    end
    value_5_3, value_6_3, value_7 = character_value:GetChildren()
    for key_2, value_13 in value_5_3, value_6_3, value_7 do
        value_8, value_9 = key_2, value_13
        local value_12_4: string = argument_1
        local has_tag_result_2 = value_9:HasTag(value_12_4)
        if not has_tag_result_2 then
            continue
        end
        local value_12_5: string = "Tool"
        local is_a_result_2 = value_9:IsA(value_12_5)
        if not is_a_result_2 then
            continue
        end
        find_first_child_of_class_result:UnequipTools()

        return
    end

    return
end

local mouse_button1_down_value = knife_child.MouseButton1Down
local value_6: (() -> ())?
do
    local captured_value = toggle_weapon_equip
    value_6 = function(): ()
        captured_value("Weapon_Knife")

        return
    end
end
mouse_button1_down_value:Connect(value_6)
local mouse_button1_down_value_2 = gun_child.MouseButton1Down
local value_6_2: (() -> ())?
do
    local captured_value_2 = toggle_weapon_equip
    value_6_2 = function(): ()
        captured_value_2("Weapon_Gun")

        return
    end
end
mouse_button1_down_value_2:Connect(value_6_2)

return
