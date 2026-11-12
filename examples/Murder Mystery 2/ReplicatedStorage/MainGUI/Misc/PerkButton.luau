--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local replicated_storage_value = game.ReplicatedStorage
local value_4: string = "ClientServices"
local client_services_child = replicated_storage_value:WaitForChild(value_4)
local value_4_2: string = "PerkService"
local require_result = require_value(client_services_child:WaitForChild(value_4_2))
local require_value_2 = require
local replicated_storage_value_2 = game.ReplicatedStorage
local value_5: string = "ClientServices"
local client_services_child_2 = replicated_storage_value_2:WaitForChild(value_5)
local value_5_2: string = "DeviceService"
local require_result_2 = require_value_2(client_services_child_2:WaitForChild(value_5_2))
local game_value_3: DataModel = game
local value_4_5: string = "UserInputService"
local user_input_service: Instance = game_value_3:GetService(value_4_5)
local parent_value_2 = script.Parent.Parent
local value_5_3: string = "Game"
local game_child = parent_value_2:WaitForChild(value_5_3)
local value_5_4: string = "Perk"
local perk_child = game_child:WaitForChild(value_5_4)
local on_preferred_input_changed: (() -> ())?
do
    local captured_value, captured_value_2, captured_value_3 = user_input_service, require_result, perk_child
    on_preferred_input_changed = function(): ()
        if captured_value.PreferredInput ~= Enum.PreferredInput.Touch then
            local value_1_2 = captured_value_2
            local value_2_4 = captured_value_3
            value_1_2.PerkButton = value_2_4
            local value_1_3 = captured_value_3
            local perk_is_active_value_2 = captured_value_2.PerkIsActive
            value_1_3.Visible = perk_is_active_value_2

            return
        end
        local value_1_4 = captured_value_3
        local value_2_6: boolean = false
        value_1_4.Visible = value_2_6

        return
    end
end
if user_input_service.PreferredInput ~= Enum.PreferredInput.Touch then
    require_result.PerkButton = perk_child
    local perk_is_active_value = require_result.PerkIsActive
    perk_child.Visible = perk_is_active_value
else
    local value_5_5: boolean = false
    perk_child.Visible = value_5_5
end
local value_7: string = "PreferredInput"
local get_property_changed_signal_result: RBXScriptSignal<> = user_input_service:GetPropertyChangedSignal(
    value_7
)
local value_7_2: () -> () = on_preferred_input_changed
get_property_changed_signal_result:Connect(value_7_2)

return
