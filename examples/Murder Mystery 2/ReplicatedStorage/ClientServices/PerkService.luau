--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("PerkIsActive")] = nil,
    [("PerkIsActive")] = nil,
    [("PerkIsActive")] = nil,
    [("PerkIsActive")] = nil,
    [("PerkIsActive")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local game_value_2: DataModel = game
local value_5_4: string = "ContextActionService"
local context_action_service: Instance = game_value_2:GetService(value_5_4)
local table_3 = {nil, nil}
local q_value = Enum.KeyCode.Q
local button_r1_value = Enum.KeyCode.ButtonR1
table_3[1], table_3[2] = q_value, button_r1_value
local value_4_5: boolean = false
table_1.PerkIsActive = value_4_5
local script_value: LuaSourceContainer = script
local value_6: string = "PerkActivated"
local perk_activated_child: Instance? = script_value:WaitForChild(value_6)
table_1.PerkActivated = perk_activated_child
local value_4_7: nil = nil
table_1.PerkButton = value_4_7

local function get_equipped_perk<T1>(argument_1: T1)
    local local_player_value = game.Players.LocalPlayer
    local value_5_6: string = "EquippedPerk"

    return (local_player_value:GetAttribute(value_5_6)) or "Footsteps"
end

table_1.GetEquippedPerk = get_equipped_perk
local activate_perk
do
    local captured_value = table_1
    activate_perk = function<T1>(argument_1_2: T1)
        captured_value.PerkActivated:Fire()

        return
    end
end
table_1.ActivatePerk = activate_perk
do
    local captured_value_2 = require_result

    local function generate_perk_info(argument_1_3: string)
        local value_2_4 = captured_value_2.Perks[argument_1_3]
        local table_3_2 = {
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
        }
        local name_value = value_2_4.Name
        table_3_2.DisplayName = name_value
        local image_value = value_2_4.Image
        table_3_2.Image = image_value
        local value_4_9: boolean = not value_2_4.Active
        table_3_2.Passive = value_4_9
        local cooldown_value = value_2_4.Cooldown
        table_3_2.Cooldown = cooldown_value
        local active_time_value = value_2_4.ActiveTime
        table_3_2.ActiveTime = active_time_value
        local charges_value = value_2_4.Charges
        table_3_2.Charges = charges_value

        return table_3_2
    end
end
local get_perk_info
do
    local captured_value_3 = require_result
    get_perk_info = function<T1>(argument_1_4: T1, argument_2: string)
        local value_4_10 = captured_value_3.Perks[argument_2]
        local table_3_3 = {
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
            [("DisplayName")] = nil,
        }
        local name_value_2 = value_4_10.Name
        table_3_3.DisplayName = name_value_2
        local image_value_2 = value_4_10.Image
        table_3_3.Image = image_value_2
        local value_5_8: boolean = not value_4_10.Active
        table_3_3.Passive = value_5_8
        local cooldown_value_2 = value_4_10.Cooldown
        table_3_3.Cooldown = cooldown_value_2
        local active_time_value_2 = value_4_10.ActiveTime
        table_3_3.ActiveTime = active_time_value_2
        local charges_value_2 = value_4_10.Charges
        table_3_3.Charges = charges_value_2

        return table_3_3
    end
end
table_1.GetPerkInfo = get_perk_info

return table_1
