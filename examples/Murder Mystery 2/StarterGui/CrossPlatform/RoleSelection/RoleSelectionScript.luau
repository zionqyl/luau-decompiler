--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local new_result: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local local_player_value = game.Players.LocalPlayer
local parent_value: Instance? = script.Parent
local game_value_2: DataModel = game
local value_6 = "TweenService"
local tween_service: Instance = game_value_2:GetService(value_6)
local value_5 = nil
value_6 = "PC"
local table_7 = {
    PC = 0,
    Tablet = 0,
    Phone = 0,
    Gamepad = 0,
}
local value_10: string = "Desktop"
local desktop_child = parent_value:WaitForChild(value_10)
table_7.PC = desktop_child
local value_10_2: string = "Mobile"
local mobile_child = parent_value:WaitForChild(value_10_2)
table_7.Tablet = mobile_child
local value_10_3: string = "Mobile"
local mobile_child_2 = parent_value:WaitForChild(value_10_3)
table_7.Phone = mobile_child_2
local value_10_4: string = "Console"
local console_child = parent_value:WaitForChild(value_10_4)
table_7.Gamepad = console_child
local script_value_2: LuaSourceContainer = script
local value_10_5: string = "Click"
local value_3: Instance? = (script_value_2:WaitForChild(value_10_5))
local script_value_3: LuaSourceContainer = script
local value_10_6: string = "Ding"
local value_3_2: Instance? = (script_value_3:WaitForChild(value_10_6))
local script_value_4: LuaSourceContainer = script
local value_10_7: string = "ClickSounds"
local click_sounds_child: Instance? = script_value_4:WaitForChild(value_10_7)
local show_role_select
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = click_sounds_child, value_3_2, tween_service, new_result
    show_role_select = function(argument_1): ()
        task.wait(0.3)
        local value_2_2 = value_5
        local roles_value = argument_1.Roles
        local selected_role_value = argument_1.SelectedRole
        local value_5_2 = argument_1.ChanceRole or "Murderer"
        local chance_value = argument_1.Chance
        local table_7_2 = {}
        local value_8_8 = roles_value
        local value_9_8 = nil
        local value_10_8 = nil
        local value_11_9, value_12_9
        for key, value in value_8_8, value_9_8, value_10_8 do
            value_11_9, value_12_9 = key, value
            local value_14_2 = table_7_2
            local value_15 = value_11_9
            local insert_value = table.insert
            insert_value(value_14_2, value_15)
        end
        value_8_8 = value_2_2.Chance
        if chance_value == nil then
            value_9_8 = false
        else
            value_9_8 = true
        end
        value_8_8.Visible = value_9_8
        value_8_8 = value_2_2.Title
        value_9_8 = "You Are"
        value_8_8.Text = value_9_8
        value_8_8 = 0.3
        value_2_2.BackgroundTransparency = value_8_8
        value_8_8 = true
        value_2_2.Visible = value_8_8
        if chance_value ~= nil then
            value_8_8 = value_2_2.Chance
            value_10_8 = "Your chance to be "
            value_11_9 = string.lower(value_5_2)
            value_12_9 = ": "
            value_9_8 = value_10_8 .. value_11_9 .. value_12_9 .. chance_value .. "%"
            value_8_8.Text = value_9_8
        end
        value_8_8 = #table_7_2
        value_9_8 = 1
        if value_9_8 < value_8_8 then
            local value_6_2: number = 1
            local value_5_3: number = 1
            value_8_8 = captured_value:GetChildren()
            value_11_9 = 1
            value_9_8 = 24
            value_10_8 = 1
            for index = value_11_9, value_9_8, value_10_8 do
                value_11_9 = index
                value_6_2 = value_6_2 + 1
                if #table_7_2 < value_6_2 then
                    value_6_2 = 1
                end
                value_12_9 = table_7_2[value_6_2]
                local value_13_10 = roles_value[value_12_9]
                local value_14_4: boolean = false
                if value_12_9 == selected_role_value then
                    local value_15_2: number = 14
                    if not (value_15_2 < value_11_9) then
                        value_14_4 = false
                    else
                        value_14_4 = true
                    end
                end
                if value_14_4 then
                    local value_15_3: Instance? = captured_value_2
                    value_15_3:Play()
                else
                    local value_15_5: number = 6
                    if value_15_5 < value_5_3 then
                        value_5_3 = 1
                    end
                    local value_15_6 = value_8_8[value_5_3]
                    value_15_6:Play()
                    value_5_3 = value_5_3 + 1
                end
                local role_value = value_2_2.Role
                role_value.Text = value_12_9
                local role_value_2 = value_2_2.Role
                role_value_2.TextColor3 = value_13_10
                local wait_value_2: (number?) -> (number) = task.wait
                local value_16_3: number = 0.1
                wait_value_2(value_16_3)
                if value_14_4 then
                    break
                end
            end
            task.wait(2.5)
        else
            value_8_8 = argument_1.SelectedRole
            value_9_8 = roles_value[value_8_8]
            value_10_8 = value_2_2.Role
            value_10_8.Text = value_8_8
            value_10_8 = value_2_2.Role
            value_10_8.TextColor3 = value_9_8
            task.wait(1.5)
        end
        local value_7 = argument_1.GameplayText or "Game starts in..."
        value_8_8 = value_2_2.Title
        value_8_8.Text = value_7
        value_8_8 = value_2_2.Role
        value_9_8 = Color3.fromRGB
        value_10_8 = 255
        value_11_9 = 255
        value_12_9 = 255
        value_9_8 = value_9_8(value_10_8, value_11_9, value_12_9)
        value_8_8.TextColor3 = value_9_8
        value_8_8 = value_2_2.Chance
        value_9_8 = false
        value_8_8.Visible = value_9_8
        local value_7_2 = argument_1.CountdownLength or 10
        value_10_8 = 1
        value_8_8 = value_7_2
        value_9_8 = 1
        for index_2 = value_10_8, value_8_8, value_9_8 do
            value_10_8 = index_2
            value_11_9 = value_2_2.Role
            local value_13_11 = value_7_2 + 1
            value_12_9 = value_13_11 - value_10_8
            value_11_9.Text = value_12_9
            if value_10_8 == 3 then
                value_11_9 = captured_value_3
                local value_13_12 = value_2_2
                local value_14_5: TweenInfo = captured_value_4
                local table_15 = {Position = 0, BackgroundTransparency = 1}
                local new_value_2: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
                local value_17: number = 0.5
                local value_18: number = 0
                local value_19: number = 0
                local absolute_size_value = value_2_2.AbsoluteSize
                local y_value = absolute_size_value.Y
                local value_20 = y_value / 2
                local new_result_2 = new_value_2(value_17, value_18, value_19, value_20)
                table_15.Position = new_result_2
                local value_4_2 = (value_11_9:Create(value_13_12, value_14_5, table_15))
                value_4_2:Play()
            end
            value_11_9 = task.wait
            value_12_9 = 1
            value_11_9(value_12_9)
        end
        value_8_8 = false
        value_2_2.Visible = value_8_8
        value_8_8 = UDim2.new(0.5, 0, 0.5, 0)
        value_2_2.Position = value_8_8

        return
    end
end
local update_device
do
    local captured_value_5, captured_value_6 = local_player_value, table_7
    update_device = function()
        local player_gui_value_3 = captured_value_5.PlayerGui
        local value_4_3: string = "Device"
        local value_1 = (player_gui_value_3:GetAttribute(value_4_3)) or "PC"
        value_5 = captured_value_6[value_1]
        value_6 = value_1

        return
    end
end
local player_gui_value = local_player_value.PlayerGui
local value_14: string = "Device"
local value_11 = (player_gui_value:GetAttribute(value_14)) or "PC"
value_5 = table_7[value_11]
value_6 = value_11
local player_gui_value_2 = local_player_value.PlayerGui
local value_13_2: string = "Device"
local get_attribute_changed_signal_result = player_gui_value_2:GetAttributeChangedSignal(
    value_13_2
)
local value_13_3 = update_device
get_attribute_changed_signal_result:Connect(value_13_3)
local game_value_3: DataModel = game
local value_13_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_3:GetService(value_13_4)
local value_13_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_13_5)
local value_13_6: string = "Gameplay"
local gameplay_child = remotes_child:WaitForChild(value_13_6)
local value_13_7: string = "ShowRoleSelectNew"
local on_client_event_value = gameplay_child:WaitForChild(value_13_7).OnClientEvent
local value_13_8 = show_role_select
on_client_event_value:Connect(value_13_8)

return
