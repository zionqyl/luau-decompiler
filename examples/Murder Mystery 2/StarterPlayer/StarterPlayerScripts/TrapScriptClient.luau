--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local trap_system_value = game.ReplicatedStorage.TrapSystem
local on_client_event_value = trap_system_value.TrapHitLocal.OnClientEvent
local value_4
do
    local captured_value = trap_system_value
    value_4 = function(argument_1, argument_2): ()
        local character_value = argument_2.Character
        local table_4 = {nil}
        table_4 = {argument_1.TrapVisual.CFrame:GetComponents()}
        local x_value = character_value.HumanoidRootPart.Position.X
        table_4[1] = x_value
        local y_value = argument_1.TrapVisual.Position.Y
        table_4[2] = y_value
        local z_value = character_value.HumanoidRootPart.Position.Z
        table_4[3] = z_value
        local trap_visual_value_3 = argument_1.TrapVisual
        local new_value: (() -> (CFrame)) & ((Vector3) -> (CFrame)) & ((Vector3, Vector3) -> (CFrame)) & ((number, number, number) -> (CFrame)) & ((number, number, number, number, number, number, number) -> (CFrame)) & ((number, number, number, number, number, number, number, number, number, number, number, number) -> (CFrame)) = CFrame.new
        local value_8 = table_4
        local new_result = new_value(unpack(value_8))
        trap_visual_value_3.CFrame = new_result
        local trap_visual_value_4 = argument_1.TrapVisual
        local value_6_2: number = 0
        trap_visual_value_4.Transparency = value_6_2
        local humanoid_value = character_value.Humanoid
        local value_6_3: number = 0.01
        humanoid_value.WalkSpeed = value_6_3
        local humanoid_value_2 = character_value.Humanoid
        local value_6_4: number = 1
        humanoid_value_2.JumpPower = value_6_4
        local cloned_value = script.TrapGUI:Clone()
        local value_5_3: boolean = true
        cloned_value.Enabled = value_5_3
        local player_gui_value = game.Players.LocalPlayer.PlayerGui
        cloned_value.Parent = player_gui_value
        local tween_script_value = cloned_value.Main.Progress.Bar.TweenScript
        local value_6_5: boolean = false
        tween_script_value.Disabled = value_6_5
        local trap_replicate_value = captured_value.TrapReplicate
        local value_7 = argument_1
        local c_frame_value_2 = argument_1.TrapVisual.CFrame
        trap_replicate_value:FireServer(value_7, c_frame_value_2)
        task.wait(4)
        local humanoid_value_3 = character_value.Humanoid
        local value_6_8: number = 16
        humanoid_value_3.WalkSpeed = value_6_8
        local humanoid_value_4 = character_value.Humanoid
        local value_6_9: number = 50
        humanoid_value_4.JumpPower = value_6_9

        return
    end
end
on_client_event_value:Connect(value_4)
local on_client_event_value_2 = trap_system_value.TrapHitVisual.OnClientEvent

local function value_4_2(argument_1_2, argument_2_2, argument_3): ()
    local trap_visual_value_6 = argument_1_2.TrapVisual
    trap_visual_value_6.CFrame = argument_2_2
    local trap_visual_value_7 = argument_1_2.TrapVisual
    local value_5_6: number = 0
    trap_visual_value_7.Transparency = value_5_6
    if game.Players.LocalPlayer == argument_1_2.PlacedPlayer.Value then
        local cloned_value_2 = script.TrappedBillboard:Clone()
        local humanoid_root_part_value_3 = argument_3.Character.HumanoidRootPart
        cloned_value_2.Parent = humanoid_root_part_value_3
        local value_5_8: boolean = true
        cloned_value_2.Enabled = value_5_8
        local debris_value = game.Debris
        local value_7_2 = cloned_value_2
        local value_8_2: number = 5
        debris_value:AddItem(value_7_2, value_8_2)
    end

    return
end

on_client_event_value_2:Connect(value_4_2)
local on_client_event_value_3 = trap_system_value.PlaceTrapLocal.OnClientEvent

local function value_4_3(argument_1_3): ()
    local trap_visual_value_8 = argument_1_3.TrapVisual
    local value_3_5: number = 0.5
    trap_visual_value_8.Transparency = value_3_5
    local cloned_value_3 = script.TrapBillboard:Clone()
    local trap_visual_value_9 = argument_1_3.TrapVisual
    cloned_value_3.Parent = trap_visual_value_9
    local value_3_7: boolean = true
    cloned_value_3.Enabled = value_3_7

    return
end

on_client_event_value_3:Connect(value_4_3)
local on_client_event_value_4 = trap_system_value.TrapNotification.OnClientEvent

local function value_4_4(argument_1_4): ()
    script.Sound:Play()
    local script_value_4, value_3_8, value_4_7 = pairs(argument_1_4:GetDescendants())
    for key, value in script_value_4, value_3_8, value_4_7 do
        local value_5_10, value_6_11 = key, value
        local value_9: string = "BillboardGui"
        local is_a_result = value_6_11:IsA(value_9)
        if not is_a_result then
            continue
        end
        value_6_11:Destroy()
    end

    return
end

on_client_event_value_4:Connect(value_4_4)

return
