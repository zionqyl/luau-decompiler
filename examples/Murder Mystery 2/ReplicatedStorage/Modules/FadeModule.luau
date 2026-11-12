--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("PlayCameraFade")] = nil,
    [("PlayCameraFade")] = nil,
    [("PlayCameraFade")] = nil,
    [("PlayCameraFade")] = nil,
    [("PlayCameraFade")] = nil,
}
local game_value: DataModel = game
local value_4: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_4)
local new_result: TweenInfo = TweenInfo.new(
    0.3,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.In,
    0,
    false
)
local new_result_2: TweenInfo = TweenInfo.new(
    0.15,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out,
    0,
    false
)

local function play_tweens(argument_1): ()
    local pairs_value, value_3_2, value_4_3 = pairs(argument_1)
    for key, value in pairs_value, value_3_2, value_4_3 do
        local value_5_2, value_6 = key, value
        value_6:Play()
    end

    return
end

local table_5 = {In = 0, Out = 1}
local table_6 = {In = false, Out = true}
local value_7_2
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = table_6, tween_service, new_result, table_5
    value_7_2 = function(argument_1_2)
        local player_gui_value = game.Players.LocalPlayer.PlayerGui
        local value_4_4: string = "CameraFade"
        local fade_value = player_gui_value:WaitForChild(value_4_4).Fade
        local starter_gui_value = game.StarterGui
        local backpack_value = Enum.CoreGuiType.Backpack
        local value_7_4 = captured_value[argument_1_2]
        starter_gui_value:SetCoreGuiEnabled(backpack_value, value_7_4)
        local table_4 = {nil}
        local value_5_3 = captured_value_2
        value_7_4 = fade_value
        local value_8_8 = captured_value_3
        local table_9 = {[("BackgroundTransparency")] = nil}
        local value_10 = captured_value_4[argument_1_2]
        table_9.BackgroundTransparency = value_10
        table_4 = {value_5_3:Create(value_7_4, value_8_8, table_9)}
        value_5_3, backpack_value, value_7_4 = pairs(table_4)
        for key_2, value_12 in value_5_3, backpack_value, value_7_4 do
            value_8_8, table_9 = key_2, value_12
            table_9:Play()
        end

        return
    end
end
table_1.PlayCameraFade = value_7_2
local play_death_fade
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8 = table_6, tween_service, new_result, table_5
    play_death_fade = function(argument_1_3)
        local player_gui_value_2 = game.Players.LocalPlayer.PlayerGui
        local value_4_6: string = "SpawnFade"
        local fade_value_2 = player_gui_value_2:FindFirstChild(value_4_6).Fade
        local starter_gui_value_2 = game.StarterGui
        local backpack_value_2 = Enum.CoreGuiType.Backpack
        local value_7_5 = captured_value_5[argument_1_3]
        starter_gui_value_2:SetCoreGuiEnabled(backpack_value_2, value_7_5)
        local table_4_2 = {nil}
        local value_5_4 = captured_value_6
        value_7_5 = fade_value_2
        local value_8_9 = captured_value_7
        local table_9_2 = {[("BackgroundTransparency")] = nil}
        local value_10_3 = captured_value_8[argument_1_3]
        table_9_2.BackgroundTransparency = value_10_3
        table_4_2 = {value_5_4:Create(value_7_5, value_8_9, table_9_2)}
        value_5_4, backpack_value_2, value_7_5 = pairs(table_4_2)
        for key_3, value_13 in value_5_4, backpack_value_2, value_7_5 do
            value_8_9, table_9_2 = key_3, value_13
            table_9_2:Play()
        end

        return
    end
end

local function value_8_3(): ()
    local player_gui_value_3 = game.Players.LocalPlayer.PlayerGui
    local value_3_5: string = "SpawnFade"
    local fade_value_3 = player_gui_value_3:FindFirstChild(value_3_5).Fade
    local value_3_6: number = 0
    fade_value_3.BackgroundTransparency = value_3_6
    local new_result_3: Color3 = Color3.new(1, 1, 1)
    fade_value_3.BackgroundColor3 = new_result_3
    wait(0.1)
    local new_result_4: Color3 = Color3.new(0, 0, 0)
    fade_value_3.BackgroundColor3 = new_result_4

    return
end

table_1.DeathFlash = value_8_3
local value_8_4
do
    local captured_value_9, captured_value_10 = table_1, play_death_fade
    value_8_4 = function(argument_1_4, argument_2)
        if argument_2 then
            captured_value_9.PlayCameraFade("In")
            wait(0.3)
        end
        local character_value = argument_1_4.Character
        if character_value then
            local value_6_4: string = "Humanoid"
            local humanoid_child = character_value:FindFirstChild(value_6_4)
            if humanoid_child then
                local current_camera_value: Camera = game.Workspace.CurrentCamera
                current_camera_value.CameraSubject = humanoid_child
            end
        end
        captured_value_9.PlayCameraFade("Out")
        captured_value_10("Out")
        wait(0.4)

        return
    end
end
table_1.FadeToWinner = value_8_4
local value_8_5
do
    local captured_value_11, captured_value_12 = play_death_fade, table_1
    value_8_5 = function()
        wait(0.5)
        local player_gui_value_4 = game.Players.LocalPlayer.PlayerGui
        local value_3_8: string = "SpawnFade"
        local fade_value_4 = player_gui_value_4:FindFirstChild(value_3_8).Fade
        local value_3_9: number = 0
        fade_value_4.BackgroundTransparency = value_3_9
        local new_result_5: Color3 = Color3.new(0, 0, 0)
        fade_value_4.BackgroundColor3 = new_result_5
        captured_value_11("Out")
        captured_value_12.PlayCameraFade("Out")
        local current_camera_value_2: Camera = game.Workspace.CurrentCamera
        local value_4_19: string = "Custom"
        current_camera_value_2.CameraType = value_4_19
        local current_camera_value_3: Camera = game.Workspace.CurrentCamera
        local humanoid_value = game.Players.LocalPlayer.Character.Humanoid
        current_camera_value_3.CameraSubject = humanoid_value
        if _G.CancelSpectate ~= nil then
            _G.CancelSpectate()
        end

        return
    end
end
table_1.SpawnFade = value_8_5
local value_8_6
do
    local captured_value_13 = table_1
    value_8_6 = function()
        if game.Players.LocalPlayer.Character ~= nil then
            local current_camera_value_4: Camera = game.Workspace.CurrentCamera
            local value_2_7: string = "Custom"
            current_camera_value_4.CameraType = value_2_7
            local current_camera_value_5: Camera = game.Workspace.CurrentCamera
            local humanoid_value_2 = game.Players.LocalPlayer.Character.Humanoid
            current_camera_value_5.CameraSubject = humanoid_value_2
        end
        if _G.CancelSpectate ~= nil then
            _G.CancelSpectate()
        end
        captured_value_13.PlayCameraFade("Out")

        return
    end
end
table_1.CameraFadeToLocalPlayer = value_8_6

return table_1
