--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function create_point_part(argument_1): Part
    local new_result_3: Part = Instance.new("Part")
    local value_3_3: number = 1
    new_result_3.Transparency = value_3_3
    local value_3_4: boolean = true
    new_result_3.Anchored = value_3_4
    local value_3_5: boolean = false
    new_result_3.CanCollide = value_3_5
    local new_result_4 = CFrame.new(argument_1)
    new_result_3.CFrame = new_result_4
    local new_result_5: Attachment = Instance.new("Attachment", new_result_3)
    local debris_value = game.Debris
    local value_6_2: Part = new_result_3
    local value_7: number = 1
    debris_value:AddItem(value_6_2, value_7)
    local workspace_value: Workspace = game.Workspace
    new_result_3.Parent = workspace_value

    return new_result_3
end

local new_result: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local new_result_2: TweenInfo = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)
local game_value: DataModel = game
local value_6: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_6)
local value_5_2
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = create_point_part, tween_service, new_result, new_result_2
    value_5_2 = function(argument_1_2, argument_2): ()
        local value_3_7: Part = captured_value(argument_1_2.Position)
        local value_4_7: Part = captured_value(argument_2)
        local value_5_6: nil = nil
        local value_8: string = "CustomBeam"
        local custom_beam_child = argument_1_2:FindFirstChild(value_8)
        local value_5_7
        if custom_beam_child then
            value_5_7 = (custom_beam_child:Clone())
        else
            value_5_7 = (Instance.new("Beam"))
            local value_7_4: number = 0.2
            value_5_7.Width0 = value_7_4
            local value_7_5: number = 0.2
            value_5_7.Width1 = value_7_5
            local value_7_6: number = 0.5
            value_5_7.LightEmission = value_7_6
            local value_7_7: number = 0
            value_5_7.LightInfluence = value_7_7
            local new_value_7: ((number) -> (NumberSequence)) & ((number, number) -> (NumberSequence)) & (({NumberSequenceKeypoint}) -> (NumberSequence)) = NumberSequence.new
            local table_8: {nil} = {nil, nil, nil}
            local new_result_9 = new_value_7(
                {
                    (NumberSequenceKeypoint.new(0, 1)),
                    (NumberSequenceKeypoint.new(0.202, 0.95)),
                    NumberSequenceKeypoint.new(1, 0.6),
                }
            )
            value_5_7.Transparency = new_result_9
        end
        local attachment_value = value_3_7.Attachment
        value_5_7.Attachment0 = attachment_value
        local attachment_value_2 = value_4_7.Attachment
        value_5_7.Attachment1 = attachment_value_2
        local value_7_8: boolean = true
        value_5_7.FaceCamera = value_7_8
        value_5_7.Parent = value_3_7
        wait(0.03)
        local value_7_9: Instance = captured_value_2
        local value_9 = value_5_7
        local value_10_2: TweenInfo = captured_value_3
        local table_11 = {Width0 = 0}
        value_7_9:Create(value_9, value_10_2, table_11):Play()
        local value_7_12: Instance = captured_value_2
        local value_9_2 = value_5_7
        local value_10_3: TweenInfo = captured_value_4
        local table_11_2 = {Width1 = 0}
        value_7_12:Create(value_9_2, value_10_3, table_11_2):Play()

        return
    end
end

return value_5_2
