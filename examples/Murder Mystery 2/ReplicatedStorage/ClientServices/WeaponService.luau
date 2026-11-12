--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("KnifeThrown")] = nil,
    [("KnifeThrown")] = nil,
    [("KnifeThrown")] = nil,
    [("KnifeThrown")] = nil,
    [("KnifeThrown")] = nil,
}
local game_value: DataModel = game
local value_4: string = "CollectionService"
local collection_service: Instance = game_value:GetService(value_4)
local game_value_2: DataModel = game
local value_5: string = "UserInputService"
local user_input_service: Instance = game_value_2:GetService(value_5)
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.KnifeThrown = new_result
local script_value: LuaSourceContainer = script
local value_6: string = "GunFired"
local gun_fired_child: Instance? = script_value:WaitForChild(value_6)
table_1.GunFired = gun_fired_child
local throw_knife
do
    local captured_value = table_1
    throw_knife = function<T1>(argument_1: T1)
        captured_value.KnifeThrown:Fire()

        return
    end
end
table_1.ThrowKnife = throw_knife
local get_weapon_ignore_list
do
    local captured_value_2 = collection_service
    get_weapon_ignore_list = function()
        local local_player_value = game.Players.LocalPlayer
        local table_2 = {nil}
        local character_value = local_player_value.Character
        table_2[1] = character_value
        character_value = captured_value_2
        local value_5_4 = "WeaponPassthrough"
        local value_4_4
        character_value, value_4_4, value_5_4 = character_value:GetTagged(value_5_4)
        for key, value in character_value, value_4_4, value_5_4 do
            local value_6_2, value_7 = key, value
            local value_9 = table_2
            local value_10 = value_7
            local insert_value = table.insert
            insert_value(value_9, value_10)
        end

        return table_2
    end
end
local weapon_raycast
do
    local captured_value_3 = get_weapon_ignore_list
    weapon_raycast = function(argument_1_2: Ray)
        local new_result_2: RaycastParams = RaycastParams.new()
        local value_3_5 = captured_value_3()
        new_result_2.FilterDescendantsInstances = value_3_5
        local value_4_5: nil = nil
        local value_4_6
        while true do
            local workspace_value: Workspace = workspace
            local origin_value: Vector3 = argument_1_2.Origin
            local direction_value: Vector3 = argument_1_2.Direction
            local value_9_2: RaycastParams = new_result_2
            local raycast_result: RaycastResult? = workspace_value:Raycast(
                origin_value,
                direction_value,
                value_9_2
            )
            value_4_6 = raycast_result
            if not value_4_6 then
                break
            end
            local instance_value = value_4_6.Instance
            if not instance_value then
                break
            end
            local transparency_value = instance_value.Transparency
            if transparency_value ~= 1 then
                break
            end
            local value_7_2 = value_3_5
            local value_8 = instance_value
            local insert_value_2 = table.insert
            insert_value_2(value_7_2, value_8)
            new_result_2.FilterDescendantsInstances = value_3_5
        end

        return value_4_6
    end
end

local function is_mouse_lock_enabled<T1>(argument_1_3: T1): boolean
    local player_scripts_value = game.Players.LocalPlayer.PlayerScripts
    local value_5_6: string = "MouseLock"
    local mouse_lock_child = player_scripts_value:FindFirstChild(value_5_6)
    if not mouse_lock_child then
        return false
    end
    local value_7_3: string = "Enabled"
    local value_4_9: boolean?
    if (mouse_lock_child:GetAttribute(value_7_3)) ~= true then
        value_4_9 = false
    else
        value_4_9 = true
    end

    return value_4_9
end

table_1.IsMouseLockEnabled = is_mouse_lock_enabled
local get_target_position
do
    local captured_value_4 = weapon_raycast
    get_target_position = function<T1>(argument_1_4: T1, argument_2, argument_3)
        local local_player_value_3 = game.Players.LocalPlayer
        local current_camera_value: Camera = workspace.CurrentCamera
        local value_6_5 = argument_2
        local value_7_4 = argument_3
        local viewport_point_to_ray_result: Ray = current_camera_value:ViewportPointToRay(
            value_6_5,
            value_7_4
        )
        local new_result_3: Ray = Ray.new(
            viewport_point_to_ray_result.Origin,
            viewport_point_to_ray_result.Direction * 300
        )
        local value_6_6: nil = nil
        local value_4_11 = (captured_value_4(new_result_3))
        if value_4_11 then
            if value_4_11.Position then
                return (CFrame.new(value_4_11.Position))
            end
        end

        return (CFrame.new(new_result_3.Origin + new_result_3.Direction))
    end
end
table_1.GetTargetPosition = get_target_position
local get_mouse_target_c_frame
do
    local captured_value_5, captured_value_6 = user_input_service, weapon_raycast
    get_mouse_target_c_frame = function<T1>(argument_1_5: T1)
        local local_player_value_4 = game.Players.LocalPlayer
        local get_mouse_location_result = captured_value_5:GetMouseLocation()
        local x_value = get_mouse_location_result.X
        local y_value = get_mouse_location_result.Y
        local player_scripts_value_2 = local_player_value_4.PlayerScripts
        local value_8_4: string = "MouseLock"
        local value_3_9 = (player_scripts_value_2:FindFirstChild(value_8_4))
        if value_3_9 then
            local value_8_5: string = "Enabled"
            if (value_3_9:GetAttribute(value_8_5)) == true then
                if captured_value_5.PreferredInput ~= Enum.PreferredInput.Gamepad then
                    local viewport_size_value: Vector2 = workspace.CurrentCamera.ViewportSize
                    x_value = viewport_size_value.X / 2
                    y_value = viewport_size_value.Y / 2
                end
            end
        end
        local current_camera_value_3: Camera = workspace.CurrentCamera
        local value_8_6 = x_value
        local value_9_3 = y_value
        local value_3_10: Ray = (current_camera_value_3:ViewportPointToRay(value_8_6, value_9_3))
        local new_result_6: Ray = Ray.new(value_3_10.Origin, value_3_10.Direction * 300)
        local value_6_13: nil = nil
        local value_4_13 = (captured_value_6(new_result_6))
        if value_4_13 then
            if value_4_13.Position then
                return (CFrame.new(value_4_13.Position))
            end
        end

        return (CFrame.new(new_result_6.Origin + new_result_6.Direction))
    end
end
table_1.GetMouseTargetCFrame = get_mouse_target_c_frame

return table_1
