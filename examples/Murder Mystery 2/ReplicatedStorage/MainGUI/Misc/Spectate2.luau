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
local value_4_3: string = "SpectateService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local parent_value_2 = script.Parent.Parent
local value_5: string = "Game"
local game_child = parent_value_2:WaitForChild(value_5)
local value_6: string = "Dock"
local dock_child = game_child:WaitForChild(value_6)
local value_6_2: string = "Spectate"
local value_2_4 = (dock_child:WaitForChild(value_6_2))
local value_6_3: string = "Spectate"
local spectate_child_2 = game_child:WaitForChild(value_6_3)
local on_spectate_started: (() -> ())?
do
    local captured_value = spectate_child_2
    on_spectate_started = function(): ()
        local value_1 = captured_value
        local value_2_5: boolean = true
        value_1.Visible = value_2_5

        return
    end
end
local on_spectate_cancelled: (() -> ())?
do
    local captured_value_2 = spectate_child_2
    on_spectate_cancelled = function(): ()
        local value_1_2 = captured_value_2
        local value_2_6: boolean = false
        value_1_2.Visible = value_2_6

        return
    end
end
local on_spectate_target_changed
do
    local captured_value_3 = spectate_child_2
    on_spectate_target_changed = function(argument_1): ()
        local player_name_value = captured_value_3.CodeImage.PlayerName
        local name_value = argument_1.Name
        player_name_value.Text = name_value

        return
    end
end
local on_spectate_button_activated: (() -> ())?
do
    local captured_value_4 = require_result
    on_spectate_button_activated = function(): ()
        captured_value_4:ToggleSpectate()

        return
    end
end
local event_value = require_result.SpectateStarted.Event
local value_10: () -> () = on_spectate_started
event_value:Connect(value_10)
local event_value_2 = require_result.SpectateCancelled.Event
local value_10_2: () -> () = on_spectate_cancelled
event_value_2:Connect(value_10_2)
local event_value_3 = require_result.SpectateTargetChanged.Event
local value_10_3 = on_spectate_target_changed
event_value_3:Connect(value_10_3)
local activated_value = spectate_child_2.Right.Activated
local value_10_4: (() -> ())?
do
    local captured_value_5 = require_result
    value_10_4 = function(): ()
        local value_1_5 = captured_value_5
        local value_3_5: number = 1
        value_1_5:NavigateSpectate(value_3_5)

        return
    end
end
activated_value:Connect(value_10_4)
local activated_value_2 = spectate_child_2.Left.Activated
local value_10_5: (() -> ())?
do
    local captured_value_6 = require_result
    value_10_5 = function(): ()
        local value_1_7 = captured_value_6
        local value_3_6: number = -1
        value_1_7:NavigateSpectate(value_3_6)

        return
    end
end
activated_value_2:Connect(value_10_5)
local activated_value_3 = value_2_4.Activated
local value_10_6: () -> () = on_spectate_button_activated
activated_value_3:Connect(value_10_6)

return
