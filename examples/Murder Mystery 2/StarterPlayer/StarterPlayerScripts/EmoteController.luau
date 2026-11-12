--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local closure_cache = {}

local function same_capture(left_capture, right_capture): boolean
    if left_capture == nil or right_capture == nil then
        return left_capture == right_capture
    end
    if left_capture ~= left_capture or right_capture ~= right_capture then
        return false
    end
    local identity_lookup = {[left_capture] = true}

    return identity_lookup[right_capture] == true
end

local game_value: DataModel = game
local value_3 = "ContextActionService"
local context_action_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "UserInputService"
local user_input_service: Instance = game_value_2:GetService(value_4)
local require_value = require
value_3 = game
local value_5: string = "ReplicatedStorage"
value_3 = value_3:GetService(value_5)
local value_5_2: string = "Modules"
value_3 = value_3:WaitForChild(value_5_2)
local value_5_3: string = "ProfileData"
local require_result = require_value(value_3:WaitForChild(value_5_3))
while true do
    value_3 = wait
    value_3()
    value_3 = game
    value_3 = value_3.Players
    value_3 = value_3.LocalPlayer
    value_3 = value_3.Character
    if value_3 then
        value_3 = _G
        value_3 = value_3.EmoteFrame
        if value_3 ~= nil then
            break
        end
    end
end
value_3 = script
value_3 = value_3.Emotes
value_3 = value_3:Clone()
local d_value = value_3.D
local value_5_4: boolean = false
d_value.Disabled = value_5_4
local backpack_value = game.Players.LocalPlayer.Backpack
value_3.Parent = backpack_value
local g_value = _G
local table_5 = {}
g_value.EmoteController = table_5
local emote_controller_value = _G.EmoteController
local table_5_2 = {}
emote_controller_value.Emotes = table_5_2
local table_2 = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local one_value = Enum.KeyCode.One
local two_value = Enum.KeyCode.Two
local three_value = Enum.KeyCode.Three
local four_value = Enum.KeyCode.Four
local five_value = Enum.KeyCode.Five
local six_value = Enum.KeyCode.Six
local seven_value = Enum.KeyCode.Seven
local eight_value = Enum.KeyCode.Eight
local nine_value = Enum.KeyCode.Nine
local zero_value = Enum.KeyCode.Zero
table_2[1], table_2[2], table_2[3], table_2[4], table_2[5], table_2[6], table_2[7], table_2[8], table_2[9], table_2[10] = one_value, two_value, three_value, four_value, five_value, six_value, seven_value, eight_value, nine_value, zero_value
local table_4 = {}
local table_5_3 = {}
local game_value_4: DataModel = game
local value_8: string = "UserInputService"
local user_input_service_2: Instance = game_value_4:GetService(value_8)
local game_value_5: DataModel = game
local value_9: string = "GuiService"
local gui_service: Instance = game_value_5:GetService(value_9)
local game_value_6: DataModel = game
local value_10: string = "ContextActionService"
local context_action_service_2: Instance = game_value_6:GetService(value_10)
local close_emotes: (() -> ())?
do
    local closure_ready
    close_emotes = function(): ()
        if not closure_ready then
            return
        end
        local value_1_2 = value_3
        local backpack_value_3 = game.Players.LocalPlayer.Backpack
        value_1_2.Parent = backpack_value_3

        return
    end
    closure_ready = true
end
local clear_binds
do
    local captured_value, captured_value_2, captured_value_3 = table_4, context_action_service_2, table_5_3
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) and same_capture(
        closure_cache[3],
        captured_value_2
    ) and same_capture(closure_cache[4], captured_value_3) then
        clear_binds = closure_cache[1]
    else
        local closure_ready_2
        clear_binds = function()
            if not closure_ready_2 then
                return
            end
            local value_1_3 = captured_value
            local value_2_3: nil = nil
            local value_3_2: nil = nil
            local value_4_6, value_5_5
            for key, value in value_1_3, value_2_3, value_3_2 do
                value_4_6, value_5_5 = key, value
                local value_6_2: Instance = captured_value_2
                local value_8_4 = value_5_5
                value_6_2:UnbindAction(value_8_4)
            end
            value_1_3 = captured_value_3
            value_2_3 = nil
            value_3_2 = nil
            for key_2, value_11 in value_1_3, value_2_3, value_3_2 do
                value_4_6, value_5_5 = key_2, value_11
                value_5_5:Disconnect()
            end

            return
        end
        closure_ready_2 = true
        if closure_cache[1] == nil then
            closure_cache[1] = clear_binds
            closure_cache[2], closure_cache[3], closure_cache[4] = captured_value, captured_value_2, captured_value_3
        end
    end
end
eight_value = 1
local bind_page: (() -> ())?
do
    local captured_value_4, captured_value_5, captured_value_6, captured_value_7, closure_ready_5
    bind_page = function(): ()
        if not closure_ready_5 then
            return
        end
        captured_value_4()
        local value_1_4 = _G.EmoteController.Emotes
        local value_2_4: nil = nil
        local value_3_3: nil = nil
        for key_3, value_19 in value_1_4, value_2_4, value_3_3 do
            local value_4_7, value_5_6 = key_3, value_19
            local value_6_5: (() -> ())?
            do
                local captured_value_8, closure_ready_3
                value_6_5 = function(): ()
                    if not closure_ready_3 then
                        return
                    end
                    if captured_value_8 ~= "Back" then
                        local play_emote_value = game.ReplicatedStorage.Remotes.Misc.PlayEmote
                        local value_3_4 = captured_value_8
                        play_emote_value:Fire(value_3_4)
                    end
                    local value_1_7 = value_3
                    local backpack_value_4 = game.Players.LocalPlayer.Backpack
                    value_1_7.Parent = backpack_value_4

                    return
                end
                captured_value_8 = value_5_6
                closure_ready_3 = true
            end
            local game_value_10: DataModel = game
            local value_9_3: string = "ContextActionService"
            local context_action_service_3: Instance = game_value_10:GetService(value_9_3)
            local value_9_4 = value_5_6
            local value_10_2
            do
                local captured_value_9, closure_ready_4
                value_10_2 = function<T1, T3>(argument_1: T1, argument_2, argument_3: T3): ()
                    if not closure_ready_4 then
                        return
                    end
                    if argument_2 ~= Enum.UserInputState.Begin then
                        return
                    end
                    if captured_value_9 ~= "Back" then
                        local play_emote_value_2 = game.ReplicatedStorage.Remotes.Misc.PlayEmote
                        local value_6_6 = captured_value_9
                        play_emote_value_2:Fire(value_6_6)
                    end
                    local value_4_10 = value_3
                    local backpack_value_5 = game.Players.LocalPlayer.Backpack
                    value_4_10.Parent = backpack_value_5

                    return
                end
                captured_value_9 = value_5_6
                closure_ready_4 = true
            end
            local value_11_2: boolean = false
            local value_13 = captured_value_5
            local value_12 = value_13[value_4_7]
            context_action_service_3:BindAction(value_9_4, value_10_2, value_11_2, value_12)
            local value_8_7 = captured_value_6
            local value_9_5 = value_5_6
            local insert_value = table.insert
            insert_value(value_8_7, value_9_5)
            local value_8_8 = captured_value_7
            local g_value_6 = _G
            local emote_frame_value = g_value_6.EmoteFrame
            local emote_pages_value = emote_frame_value.EmotePages
            local g_value_7 = _G
            local current_page_value = g_value_7.CurrentPage
            local value_9_6 = emote_pages_value[current_page_value]
            local container_value = value_9_6.Container
            local value_11_3 = value_5_6
            local find_first_child_result = container_value:FindFirstChild(value_11_3)
            local container_value_2 = find_first_child_result.Container
            local button_value = container_value_2.Button
            local mouse_button1_click_value = button_value.MouseButton1Click
            local value_11_4: () -> () = value_6_5
            ;(function(...)
                local open_callee = table.insert

                return open_callee(value_8_8, ...)
            end)(mouse_button1_click_value:connect(value_11_4))
        end

        return
    end
    captured_value_4, captured_value_5, captured_value_6, captured_value_7 = clear_binds, table_2, table_4, table_5_3
    closure_ready_5 = true
end
local g_value_3 = _G
local value_14
do
    local captured_value_10 = bind_page
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_10) then
        value_14 = closure_cache[5]
    else
        local closure_ready_6
        value_14 = function(): ()
            if not closure_ready_6 then
                return
            end
            captured_value_10()

            return
        end
        closure_ready_6 = true
        if closure_cache[5] == nil then
            closure_cache[5] = value_14
            closure_cache[6] = captured_value_10
        end
    end
end
g_value_3.RebindPage = value_14
do
    local captured_value_11, closure_ready_7

    local function change_page(argument_1_2): ()
        if not closure_ready_7 then
            return
        end
        local value_3_5 = eight_value + argument_1_2
        local value_2_6
        if #_G.EmotePages < value_3_5 then
            value_2_6 = 1
        else
            local value_3_6 = eight_value + argument_1_2
            local value_4_14: number = 1
            do
                local take_fallback = not (value_3_6 < value_4_14)
                if not take_fallback then
                    value_2_6 = #_G.EmotePages
                    take_fallback = not value_2_6
                end
                if take_fallback then
                    value_2_6 = eight_value + argument_1_2
                end
            end
        end
        eight_value = value_2_6
        _G.ChangePage(eight_value)
        captured_value_11()

        return
    end

    captured_value_11 = bind_page
    closure_ready_7 = true
end
local g_value_4 = _G
local value_15
do
    local captured_value_12, closure_ready_8
    value_15 = function(): ()
        if not closure_ready_8 then
            return
        end
        local value_2_8 = eight_value + -1
        local value_1_9
        if #_G.EmotePages < value_2_8 then
            value_1_9 = 1
        else
            local value_2_9 = eight_value + -1
            local value_3_12: number = 1
            do
                local take_fallback_2 = not (value_2_9 < value_3_12)
                if not take_fallback_2 then
                    value_1_9 = #_G.EmotePages
                    take_fallback_2 = not value_1_9
                end
                if take_fallback_2 then
                    value_1_9 = eight_value + -1
                end
            end
        end
        eight_value = value_1_9
        _G.ChangePage(eight_value)
        captured_value_12()

        return
    end
    captured_value_12 = bind_page
    closure_ready_8 = true
end
g_value_4.EmotePageLeft = value_15
local g_value_5 = _G
do
    local captured_value_13, closure_ready_9
    value_15 = function(): ()
        if not closure_ready_9 then
            return
        end
        local value_2_12 = eight_value + 1
        local value_1_11
        if #_G.EmotePages < value_2_12 then
            value_1_11 = 1
        else
            local value_2_13 = eight_value + 1
            local value_3_16: number = 1
            do
                local take_fallback_3 = not (value_2_13 < value_3_16)
                if not take_fallback_3 then
                    value_1_11 = #_G.EmotePages
                    take_fallback_3 = not value_1_11
                end
                if take_fallback_3 then
                    value_1_11 = eight_value + 1
                end
            end
        end
        eight_value = value_1_11
        _G.ChangePage(eight_value)
        captured_value_13()

        return
    end
    captured_value_13 = bind_page
    closure_ready_9 = true
end
g_value_5.EmotePageRight = value_15

local function on_page_action<T3>(argument_1_3: string, argument_2_2, argument_3_2: T3): ()
    if argument_2_2 ~= Enum.UserInputState.Begin then
        return
    end
    if argument_1_3 == "EmotePageLeft" then
        _G.EmotePageLeft()

        return
    end
    if argument_1_3 == "EmotePageRight" then
        _G.EmotePageRight()
    end

    return
end

value_15 = 0
local local_tool_equipped_value = context_action_service.LocalToolEquipped
local value_18
do
    local captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19, closure_ready_11
    value_18 = function(argument_1_4): ()
        if not closure_ready_11 then
            return
        end
        if argument_1_4.Name ~= "Emotes" then
            return
        end
        local child_added_value_2 = game.Players.LocalPlayer.Character.ChildAdded
        local value_4_15: (<T1>(T1) -> ())?
        do
            local closure_ready_10
            value_4_15 = function<T1>(argument_1_5: T1): ()
                if not closure_ready_10 then
                    return
                end
                value_15 = (time())

                return
            end
            closure_ready_10 = true
        end
        child_added_value_2:Connect(value_4_15)
        local starter_gui_value = game.StarterGui
        local backpack_value_6 = Enum.CoreGuiType.Backpack
        local value_5_8: boolean = false
        starter_gui_value:SetCoreGuiEnabled(backpack_value_6, value_5_8)
        local emote_frame_value_2 = _G.EmoteFrame
        local value_3_19: boolean = true
        emote_frame_value_2.Visible = value_3_19
        captured_value_14()
        local value_2_19: Instance? = captured_value_15
        local value_4_16: string = "EmotePageLeft"
        local value_5_9 = captured_value_16
        local value_6_7: boolean = false
        local button_l1_value = Enum.KeyCode.ButtonL1
        local q_value = Enum.KeyCode.Q
        value_2_19:BindAction(value_4_16, value_5_9, value_6_7, button_l1_value, q_value)
        local value_2_21: Instance? = captured_value_15
        local value_4_17: string = "EmotePageRight"
        local value_5_10 = captured_value_16
        local value_6_8: boolean = false
        local button_r1_value = Enum.KeyCode.ButtonR1
        local e_value = Enum.KeyCode.E
        value_2_21:BindAction(value_4_17, value_5_10, value_6_8, button_r1_value, e_value)
        local value_2_23: Instance? = captured_value_15
        local value_4_18: string = "CloseEmotePage"
        local value_5_11: (() -> ())? = captured_value_17
        local value_6_9: boolean = false
        local button_b_value = Enum.KeyCode.ButtonB
        value_2_23:BindAction(value_4_18, value_5_11, value_6_9, button_b_value)
        if (captured_value_18:GetLastInputType()) == Enum.UserInputType.Gamepad1 then
            local value_2_27: Instance? = captured_value_19
            local button_value_2 = _G.EmoteFrame.EmotePages[_G.CurrentPage].Container:GetChildren()[1].Container.Button
            value_2_27.SelectedObject = button_value_2
        end
        if #(game.Players.LocalPlayer.Backpack:GetChildren()) == 0 then
            local cloned_value = script.AAAAA:Clone()
            local backpack_value_8 = game.Players.LocalPlayer.Backpack
            cloned_value.Parent = backpack_value_8
        end

        return
    end
    captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19 = bind_page, context_action_service_2, on_page_action, close_emotes, user_input_service_2, gui_service
    closure_ready_11 = true
end
local_tool_equipped_value:Connect(value_18)
local local_tool_unequipped_value = context_action_service_2.LocalToolUnequipped
local value_18_2
do
    local captured_value_20, captured_value_21, captured_value_22 = gui_service, clear_binds, context_action_service_2
    if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_20) and same_capture(
        closure_cache[9],
        captured_value_21
    ) and same_capture(closure_cache[10], captured_value_22) then
        value_18_2 = closure_cache[7]
    else
        local closure_ready_12
        value_18_2 = function(argument_1_6)
            if not closure_ready_12 then
                return
            end
            if argument_1_6.Name ~= "Emotes" then
                return
            end
            local value_2_30: Instance = captured_value_20
            local value_3_27: nil = nil
            value_2_30.SelectedObject = value_3_27
            task.wait()
            local backpack_value_9 = game.Players.LocalPlayer.Backpack
            local value_4_22: string = "AAAAA"
            local aaaaa_child = backpack_value_9:FindFirstChild(value_4_22)
            if aaaaa_child then
                aaaaa_child:Destroy()
            end
            captured_value_21()
            local value_3_31: Instance = captured_value_22
            local value_5_13: string = "EmotePageLeft"
            value_3_31:UnbindAction(value_5_13)
            local value_3_33: Instance = captured_value_22
            local value_5_14: string = "EmotePageRight"
            value_3_33:UnbindAction(value_5_14)
            local value_3_35: Instance = captured_value_22
            local value_5_15: string = "CloseEmotePage"
            value_3_35:UnbindAction(value_5_15)
            local starter_gui_value_2 = game.StarterGui
            local backpack_value_10 = Enum.CoreGuiType.Backpack
            local value_6_10: boolean = true
            starter_gui_value_2:SetCoreGuiEnabled(backpack_value_10, value_6_10)
            local emote_frame_value_4 = _G.EmoteFrame
            local value_4_28: boolean = false
            emote_frame_value_4.Visible = value_4_28

            return
        end
        closure_ready_12 = true
        if closure_cache[7] == nil then
            closure_cache[7] = value_18_2
            closure_cache[8], closure_cache[9], closure_cache[10] = captured_value_20, captured_value_21, captured_value_22
        end
    end
end
local_tool_unequipped_value:Connect(value_18_2)
local character_added_value = game.Players.LocalPlayer.CharacterAdded
local value_18_3: (<T1>(T1) -> ())?
do
    local captured_value_23, closure_ready_13
    value_18_3 = function<T1>(argument_1_7: T1): ()
        if not closure_ready_13 then
            return
        end
        while true do
            local wait_value_2 = wait
            wait_value_2()
            local game_value_21: DataModel = game
            local players_value_11 = game_value_21.Players
            local local_player_value_11 = players_value_11.LocalPlayer
            local character_value_2 = local_player_value_11.Character
            if character_value_2 then
                break
            end
        end
        captured_value_23()
        value_3 = (script.Emotes:Clone())
        local d_value_2 = value_3.D
        local value_3_39: boolean = false
        d_value_2.Disabled = value_3_39
        local value_2_35 = value_3
        local backpack_value_11 = game.Players.LocalPlayer.Backpack
        value_2_35.Parent = backpack_value_11
        local starter_gui_value_3 = game.StarterGui
        local backpack_value_12 = Enum.CoreGuiType.Backpack
        local value_5_16: boolean = true
        starter_gui_value_3:SetCoreGuiEnabled(backpack_value_12, value_5_16)
        local emote_frame_value_5 = _G.EmoteFrame
        local value_3_41: boolean = false
        emote_frame_value_5.Visible = value_3_41

        return
    end
    captured_value_23 = clear_binds
    closure_ready_13 = true
end
character_added_value:Connect(value_18_3)
local child_added_value = game.Players.LocalPlayer.Backpack.ChildAdded

local function value_18_4<T1>(argument_1_8: T1): ()
    return
end

child_added_value:connect(value_18_4)

return
