--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "RunService"
local run_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "CollectionService"
local collection_service: Instance = game_value_2:GetService(value_4)
local table_3 = {}
local on_throwing_knife_added
do
    local captured_value = table_3
    on_throwing_knife_added = function(argument_1)
        local value_4_2: string = "HandleLink"
        local value_value = argument_1:WaitForChild(value_4_2).Value
        if not value_value then
            return
        end
        local value_5: string = "BladePosition"
        local blade_position_child = argument_1:WaitForChild(value_5)
        local cloned_value = value_value:Clone()
        local c_frame_value = blade_position_child.CFrame
        cloned_value.CFrame = c_frame_value
        local value_7_4: string = "VH"
        local value_3_5 = (cloned_value:FindFirstChild(value_7_4))
        if value_3_5 then
            local value_5_4: number = 1
            cloned_value.Transparency = value_5_4
            local value_5_5: number = 0
            value_3_5.Transparency = value_5_5
            local value_7_5: string = "VisualHandle"
            local value_8_4: boolean = true
            value_3_5:SetAttribute(value_7_5, value_8_4)
        else
            local value_5_7: number = 0
            cloned_value.Transparency = value_5_7
        end
        local value_7_6: string = "Direction"
        local value_10: string = "Direction"
        ;(function(...)
            return cloned_value:SetAttribute(value_7_6, ...)
        end)(argument_1:GetAttribute(value_10))
        local value_5_9: boolean = true
        cloned_value.Anchored = value_5_9
        local value_5_10: string = "KnifeVisual"
        cloned_value.Name = value_5_10
        cloned_value.Parent = argument_1
        local value_5_11 = captured_value
        local value_6_7: boolean = true
        value_5_11[cloned_value] = value_6_7

        return
    end
end
local on_update
do
    local captured_value_2 = table_3
    on_update = function(argument_1_2: number)
        local value_2_4 = captured_value_2
        local value_3_6: nil = nil
        local value_4_5: nil = nil
        for key, value in value_2_4, value_3_6, value_4_5 do
            local value_5_12, value_6_8 = key, value
            local parent_value = value_5_12.Parent
            if parent_value == nil then
                local value_7_7 = captured_value_2
                local value_8_6: nil = nil
                value_7_7[value_5_12] = value_8_6
            else
                local c_frame_value_2 = value_5_12.CFrame
                local value_10_2: string = "Direction"
                local direction_value = value_5_12:GetAttribute(value_10_2)
                local value_9_3: number = argument_1_2 * -12.566370614359172
                local angles_value: (number, number, number) -> (CFrame) = CFrame.Angles
                local value_13: number = value_9_3
                local value_14: number = 0
                local value_15: number = 0
                local angles_result: CFrame = angles_value(value_13, value_14, value_15)
                local value_11 = c_frame_value_2 * angles_result
                local value_13_2 = direction_value * 96
                local value_12 = value_13_2 * argument_1_2
                local value_10_3 = value_11 + value_12
                value_5_12.CFrame = value_10_3
            end
        end

        return
    end
end
local pre_simulation_value = run_service.PreSimulation
local value_8 = on_update
pre_simulation_value:Connect(value_8)
local value_8_2: string = "ThrowingKnife"
local get_instance_added_signal_result = collection_service:GetInstanceAddedSignal(value_8_2)
local value_8_3 = on_throwing_knife_added
get_instance_added_signal_result:Connect(value_8_3)

return
