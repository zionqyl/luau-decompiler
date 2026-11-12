--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local game_value: DataModel = game
local value_3: string = "CollectionService"
local collection_service: Instance = game_value:GetService(value_3)
local table_2 = {}
local on_instance_added
do
    local captured_value = table_2
    on_instance_added = function(argument_1)
        local value_4: string = "Handle"
        local value_5: number = 5
        local handle_child = argument_1:WaitForChild(value_4, value_5)
        if not handle_child then
            return
        end
        local value_5_2: string = "Mesh"
        local value_6_2: number = 5
        handle_child:WaitForChild(value_5_2, value_6_2)
        local cloned_value = handle_child:Clone()
        local script_value: LuaSourceContainer = script
        local value_6_3: string = "Player"
        if not (script_value:FindFirstAncestorWhichIsA(value_6_3)) then
            local game_value_2: DataModel = game
            local value_6_4: string = "Players"
            local players_service: Instance = game_value_2:GetService(value_6_4)
            local parent_value = argument_1.Parent
            local get_player_from_character_result = players_service:GetPlayerFromCharacter(
                parent_value
            )
        end
        local new_result: RigidConstraint = Instance.new("RigidConstraint")
        local value_5_7: string = "VisualConstraint"
        new_result.Name = value_5_7
        new_result.Parent = cloned_value
        local new_result_2: Attachment = Instance.new("Attachment")
        new_result_2.Parent = handle_child
        local new_value_3: (string, Instance?) -> (Instance) = Instance.new
        local value_7 = "Attachment"
        local new_result_3: Instance = new_value_3(value_7)
        new_result_3.Parent = cloned_value
        new_result.Attachment0 = new_result_2
        new_result.Attachment1 = new_result_3
        value_7 = 1
        handle_child.LocalTransparencyModifier = value_7
        local value_9 = "Transparency"
        value_7 = handle_child:GetPropertyChangedSignal(value_9)
        do
            local captured_value_2, captured_value_3, closure_ready
            value_9 = function(): ()
                if not closure_ready then
                    return
                end
                local value_1_2 = captured_value_2
                local transparency_value = captured_value_3.Transparency
                value_1_2.Transparency = transparency_value

                return
            end
            captured_value_2, captured_value_3 = cloned_value, handle_child
            closure_ready = true
        end
        value_7:Connect(value_9)
        value_7 = false
        cloned_value.CanCollide = value_7
        value_7 = false
        cloned_value.CanQuery = value_7
        value_7 = false
        cloned_value.CanTouch = value_7
        value_7 = script
        cloned_value.Parent = value_7
        local value_8
        value_7, value_8, value_9 = handle_child:GetChildren()
        local value_10, value_11
        for key, value in value_7, value_8, value_9 do
            value_10, value_11 = key, value
            local value_14: string = "ParticleEmitter"
            local is_a_result = value_11:IsA(value_14)
            if not is_a_result then
                continue
            end
            local value_14_2: string = "Enabled"
            local get_property_changed_signal_result = value_11:GetPropertyChangedSignal(
                value_14_2
            )
            local value_14_3
            do
                local captured_value_4, captured_value_5, closure_ready_2
                value_14_3 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    local value_1_3 = captured_value_4[captured_value_5.Name]
                    local enabled_value = captured_value_5.Enabled
                    value_1_3.Enabled = enabled_value

                    return
                end
                captured_value_4, captured_value_5 = cloned_value, value_11
                closure_ready_2 = true
            end
            get_property_changed_signal_result:Connect(value_14_3)
        end
        value_7, value_8, value_9 = handle_child:GetDescendants()
        for key_2, value_15 in value_7, value_8, value_9 do
            value_10, value_11 = key_2, value_15
            local value_14_4: string = "Decal"
            local is_a_result_2 = value_11:IsA(value_14_4)
            if not is_a_result_2 then
                continue
            end
            local value_12_5: number = 1
            value_11.Transparency = value_12_5
        end
        do
            local captured_value_6, closure_ready_3

            local function on_tool_equipped(): ()
                if not closure_ready_3 then
                    return
                end
                if not captured_value_6.Parent then
                    return
                end
                local value_1_5 = captured_value_6
                local workspace_value: Workspace = workspace
                value_1_5.Parent = workspace_value

                return
            end

            captured_value_6 = cloned_value
            closure_ready_3 = true
        end
        do
            local captured_value_7, closure_ready_4

            local function on_tool_unequipped(): ()
                if not closure_ready_4 then
                    return
                end
                if not captured_value_7.Parent then
                    return
                end
                local value_1_7 = captured_value_7
                local script_value_2: LuaSourceContainer = script
                value_1_7.Parent = script_value_2

                return
            end

            captured_value_7 = cloned_value
            closure_ready_4 = true
        end
        value_7 = captured_value
        value_7[argument_1] = cloned_value
        value_7 = nil
        value_8 = argument_1.AncestryChanged
        do
            local captured_value_8, captured_value_9, closure_ready_5
            value_10 = function(): ()
                if not closure_ready_5 then
                    return
                end
                if not captured_value_8.Parent then
                    value_7:Disconnect()

                    return
                end
                local parent_value_5 = captured_value_8.Parent
                local value_3_6: string = "Model"
                if (parent_value_5:IsA(value_3_6)) then
                    if not captured_value_9.Parent then
                        return
                    end
                    local value_1_14 = captured_value_9
                    local workspace_value_2: Workspace = workspace
                    value_1_14.Parent = workspace_value_2

                    return
                end
                if not captured_value_9.Parent then
                    return
                end
                local value_1_16 = captured_value_9
                local script_value_3: LuaSourceContainer = script
                value_1_16.Parent = script_value_3

                return
            end
            captured_value_8, captured_value_9 = argument_1, cloned_value
            closure_ready_5 = true
        end
        value_7 = (value_8:Connect(value_10))

        return
    end
end
local on_instance_removed
do
    local captured_value_10 = table_2
    on_instance_removed = function(argument_1_2)
        if captured_value_10[argument_1_2] then
            captured_value_10[argument_1_2]:Destroy()
            local value_2_11 = captured_value_10
            local value_3_10: nil = nil
            value_2_11[argument_1_2] = value_3_10
        end

        return
    end
end
local on_initialize
do
    local captured_value_11, captured_value_12, captured_value_13 = collection_service, on_instance_added, on_instance_removed
    on_initialize = function()
        local value_1_17 = captured_value_11
        local value_3_11 = "GlowTool"
        local value_2_12
        value_1_17, value_2_12, value_3_11 = value_1_17:GetTagged(value_3_11)
        for key_3, value_16 in value_1_17, value_2_12, value_3_11 do
            local value_4_7, value_5_8 = key_3, value_16
            local value_6_6 = captured_value_12
            local value_7_2 = value_5_8
            value_6_6(value_7_2)
        end
        value_1_17 = captured_value_11
        value_3_11 = "GlowTool"
        value_1_17 = value_1_17:GetInstanceAddedSignal(value_3_11)
        value_3_11 = captured_value_12
        value_1_17:Connect(value_3_11)
        value_1_17 = captured_value_11
        value_3_11 = "GlowTool"
        value_1_17 = value_1_17:GetInstanceRemovedSignal(value_3_11)
        value_3_11 = captured_value_13
        value_1_17:Connect(value_3_11)

        return
    end
end
on_initialize()

return
