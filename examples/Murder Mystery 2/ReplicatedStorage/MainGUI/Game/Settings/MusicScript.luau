--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local value_3: string = "Mute"
local mute_child = parent_value:WaitForChild(value_3)
local game_value: DataModel = game
local value_4: string = "SoundService"
local sound_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Music"
local music_child: Instance? = sound_service:WaitForChild(value_4_2)
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local require_value = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "AudioService"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local value_5_6: string = "MutedIcon"
local muted_icon_child = mute_child:WaitForChild(value_5_6)
local value_6_4: string = "UnmutedIcon"
local unmuted_icon_child = mute_child:WaitForChild(value_6_4)
do
    local captured_value = music_child

    local function is_muted(): boolean
        local value_1_2: boolean?
        if not (captured_value.Volume <= 0) then
            value_1_2 = false
        else
            value_1_2 = true
        end

        return value_1_2
    end
end
do
    local captured_value_2, captured_value_3, captured_value_4 = muted_icon_child, music_child, unmuted_icon_child

    local function update_mute_icon(): ()
        local value_1_3 = captured_value_2
        local value_2_5: boolean?
        if not (captured_value_3.Volume <= 0) then
            value_2_5 = false
        else
            value_2_5 = true
        end
        value_1_3.Visible = value_2_5
        local value_1_4 = captured_value_4
        local value_3_9: boolean?
        if not (captured_value_3.Volume <= 0) then
            value_3_9 = false
        else
            value_3_9 = true
        end
        local value_2_6: boolean = not value_3_9
        value_1_4.Visible = value_2_6

        return
    end
end
local on_mute_toggled: (() -> ())?
do
    local captured_value_5, captured_value_6, captured_value_7 = music_child, muted_icon_child, unmuted_icon_child
    on_mute_toggled = function(): ()
        if 0 < captured_value_5.Volume then
            local value_1_6: Instance? = captured_value_5
            local value_2_8: number = 0
            value_1_6.Volume = value_2_8
        else
            local value_1_7: Instance? = captured_value_5
            local value_2_9: number = 1
            value_1_7.Volume = value_2_9
        end
        local value_1_8 = captured_value_6
        local value_2_10: boolean?
        if not (captured_value_5.Volume <= 0) then
            value_2_10 = false
        else
            value_2_10 = true
        end
        value_1_8.Visible = value_2_10
        local value_1_9 = captured_value_7
        local value_3_11: boolean?
        if not (captured_value_5.Volume <= 0) then
            value_3_11 = false
        else
            value_3_11 = true
        end
        local value_2_11: boolean = not value_3_11
        value_1_9.Visible = value_2_11

        return
    end
end
local value_8: boolean?
if not (music_child.Volume <= 0) then
    value_8 = false
else
    value_8 = true
end
muted_icon_child.Visible = value_8
local value_9: boolean?
if not (music_child.Volume <= 0) then
    value_9 = false
else
    value_9 = true
end
local value_8_2: boolean = not value_9
unmuted_icon_child.Visible = value_8_2
local value_10_2: string = "Button"
local activated_value = mute_child:WaitForChild(value_10_2).Activated
local value_10_3: () -> () = on_mute_toggled
activated_value:Connect(value_10_3)

return
