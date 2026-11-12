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

local local_player_value = game.Players.LocalPlayer
local table_2 = {}
local table_3 = {}
local table_4 = {}
local game_value_2: DataModel = game
local value_7: string = "UserInputService"
local user_input_service: Instance = game_value_2:GetService(value_7)
local game_value_3: DataModel = game
local value_8: string = "GuiService"
local gui_service: Instance = game_value_3:GetService(value_8)
local game_value_4: DataModel = game
local value_9: string = "GamepadService"
local gamepad_service: Instance = game_value_4:GetService(value_9)
local game_value_5: DataModel = game
local value_9_2: string = "TweenService"
local tween_service: Instance = game_value_5:GetService(value_9_2)
local player_gui_value = game.Players.LocalPlayer.PlayerGui
local value_9_3: string = "InputContext"
local input_context_child = player_gui_value:WaitForChild(value_9_3)
local value_10: string = "GameplayContext"
local gameplay_context_child = input_context_child:WaitForChild(value_10)
local value_11: string = "EmoteContext"
local emote_context_child = input_context_child:WaitForChild(value_11)
local require_value = require
local game_value_7: DataModel = game
local value_13: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_7:GetService(value_13)
local value_13_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_13_2)
local value_13_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_13_3))
local require_value_2 = require
local game_value_8: DataModel = game
local value_13_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_8:GetService(value_13_4)
local value_13_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_13_5)
local value_13_6: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_13_6))
local game_value_9: DataModel = game
local value_13_7: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_9:GetService(value_13_7)
local value_13_8: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_13_8)
local require_value_3 = require
local game_value_10: DataModel = game
local value_15: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_10:GetService(value_15)
local value_15_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_4:WaitForChild(value_15_2)
local value_15_3: string = "ItemService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_15_3))
local game_value_11: DataModel = game
local value_15_4: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_11:GetService(value_15_4)
local value_15_5: string = "Remotes"
local remotes_child_2: Instance? = replicated_storage_service_5:WaitForChild(value_15_5)
local value_15_6: string = "Misc"
local misc_child = remotes_child_2:WaitForChild(value_15_6)
local value_15_7: string = "PlayEmote"
local play_emote_child = misc_child:WaitForChild(value_15_7)
local parent_value: Instance? = script.Parent
local value_16: string = "EmoteWindow"
local emote_window_child = parent_value:WaitForChild(value_16)
local value_17: string = "EmoteContainer"
local emote_container_child = emote_window_child:WaitForChild(value_17)
local value_18: string = "VerticalNavigation"
local vertical_navigation_child = emote_container_child:WaitForChild(value_18)
local value_18_2: string = "EmotePages"
local emote_pages_child = emote_container_child:WaitForChild(value_18_2)
local value_19: string = "Avatar Emotes"
local value_15_10 = (emote_pages_child:WaitForChild(value_19))
local value_19_2: string = "Game Emotes"
local wait_for_child_result_2 = emote_pages_child:WaitForChild(value_19_2)
local value_20: string = "EmoteNavigation"
local emote_navigation_child = emote_window_child:WaitForChild(value_20)
local table_19 = {nil, nil}
local value_20_2 = value_15_10
local value_21 = wait_for_child_result_2
table_19[1], table_19[2] = value_20_2, value_21
local value_22 = "Game Emotes"
local wait_for_child_result_3 = emote_pages_child:WaitForChild(value_22)
value_22 = "Row1"
local row1_child = wait_for_child_result_3:WaitForChild(value_22)
value_22 = "EmoteFrame"
local emote_frame_child = row1_child:WaitForChild(value_22)
local script_value_2: LuaSourceContainer = script
local value_23 = "RowFrame"
local row_frame_child: Instance? = script_value_2:WaitForChild(value_23)
value_22 = false
value_23 = nil
local value_24 = 8
local x_value = emote_frame_child.AbsoluteSize.X
local value_27 = 0
local table_26 = {[value_15_10] = nil, [value_15_10] = nil}
table_26[value_15_10] = value_27
value_27 = 0
table_26[wait_for_child_result_2] = value_27
value_27 = 1
local new_result: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
local table_28 = {}
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6 = emote_context_child, emote_window_child, user_input_service, gui_service, emote_pages_child, input_context_child

    local function update_emote_container_enabled(): ()
        local value_1 = captured_value
        local value_2 = value_22
        value_1.Sink = value_2
        local value_1_2 = captured_value_2
        local value_2_2 = value_22
        value_1_2.Visible = value_2_2
        if captured_value_3.PreferredInput == Enum.PreferredInput.Gamepad then
            if value_22 then
                local value_1_5: Instance = captured_value_4
                local current_page_value_2 = captured_value_5.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_1_5:Select(current_page_value_2)

                return
            end
            local value_1_7: Instance = captured_value_4
            local value_2_4: nil = nil
            value_1_7.SelectedObject = value_2_4
            local emotes_value = captured_value_6.GameplayContext.Emotes
            local value_3_2: boolean = false
            emotes_value:Fire(value_3_2)
        end

        return
    end
end
local on_emote_button_pressed: (() -> ())?
do
    local captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12 = emote_context_child, emote_window_child, user_input_service, gui_service, emote_pages_child, input_context_child
    on_emote_button_pressed = function(): ()
        value_22 = not value_22
        local value_1_11 = captured_value_7
        local value_2_7: boolean = value_22
        value_1_11.Sink = value_2_7
        local value_1_12 = captured_value_8
        local value_2_8: boolean = value_22
        value_1_12.Visible = value_2_8
        if captured_value_9.PreferredInput == Enum.PreferredInput.Gamepad then
            if value_22 then
                local value_1_15: Instance = captured_value_10
                local current_page_value_4 = captured_value_11.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_1_15:Select(current_page_value_4)

                return
            end
            local value_1_17: Instance = captured_value_10
            local value_2_10: nil = nil
            value_1_17.SelectedObject = value_2_10
            local emotes_value_2 = captured_value_12.GameplayContext.Emotes
            local value_3_4: boolean = false
            emotes_value_2:Fire(value_3_4)
        end

        return
    end
end
do
    local captured_value_13, captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18 = emote_context_child, emote_window_child, user_input_service, gui_service, emote_pages_child, input_context_child

    local function play_avatar_emote(argument_1: string): ()
        value_22 = false
        local value_2_13 = captured_value_13
        local value_3_5: boolean = value_22
        value_2_13.Sink = value_3_5
        local value_2_14 = captured_value_14
        local value_3_6: boolean = value_22
        value_2_14.Visible = value_3_6
        if captured_value_15.PreferredInput == Enum.PreferredInput.Gamepad then
            if value_22 then
                local value_2_17: Instance = captured_value_16
                local current_page_value_6 = captured_value_17.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_2_17:Select(current_page_value_6)
            else
                local value_2_19: Instance = captured_value_16
                local value_3_8: nil = nil
                value_2_19.SelectedObject = value_3_8
                local emotes_value_3 = captured_value_18.GameplayContext.Emotes
                local value_4_2: boolean = false
                emotes_value_3:Fire(value_4_2)
            end
        end
        local value_2_22 = value_23
        local value_4_3: string = argument_1
        value_2_22:PlayEmote(value_4_3)

        return
    end
end
do
    local captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24, captured_value_25 = emote_context_child, emote_window_child, user_input_service, gui_service, emote_pages_child, input_context_child, play_emote_child

    local function play_game_emote(argument_1_2: string): ()
        value_22 = false
        local value_2_25 = captured_value_19
        local value_3_11: boolean = value_22
        value_2_25.Sink = value_3_11
        local value_2_26 = captured_value_20
        local value_3_12: boolean = value_22
        value_2_26.Visible = value_3_12
        if captured_value_21.PreferredInput == Enum.PreferredInput.Gamepad then
            if value_22 then
                local value_2_29: Instance = captured_value_22
                local current_page_value_8 = captured_value_23.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_2_29:Select(current_page_value_8)
            else
                local value_2_31: Instance = captured_value_22
                local value_3_14: nil = nil
                value_2_31.SelectedObject = value_3_14
                local emotes_value_4 = captured_value_24.GameplayContext.Emotes
                local value_4_5: boolean = false
                emotes_value_4:Fire(value_4_5)
            end
        end
        local value_2_34 = captured_value_25
        local value_4_6: string = argument_1_2
        value_2_34:Fire(value_4_6)

        return
    end
end
local add_game_emotes
do
    local captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, captured_value_37, captured_value_38, captured_value_39 = require_result_2, table_4, require_result_3, emote_frame_child, user_input_service, emote_context_child, emote_window_child, gui_service, emote_pages_child, input_context_child, play_emote_child, wait_for_child_result_2, row_frame_child, table_26
    add_game_emotes = function()
        local value_2_36 = captured_value_26.Emotes.Owned
        local value_3_17: nil = nil
        local value_4_7: nil = nil
        for key, value in value_2_36, value_3_17, value_4_7 do
            local value_5_2, value_6_3 = key, value
            local value_8_6 = captured_value_27
            local value_7_6 = value_8_6[value_6_3]
            if value_7_6 then
                continue
            end
            local value_7_7 = captured_value_28
            local value_9_6 = value_6_3
            local value_10_3: string = "Emotes"
            local get_item_info_result = value_7_7:GetItemInfo(value_9_6, value_10_3)
            if not get_item_info_result then
                continue
            end
            local value_12_9 = value_27
            local value_11_10 = value_12_9 - 1
            local value_12_10 = value_24
            local value_10_4 = value_11_10 / value_12_10
            local floor_value = math.floor
            local floor_result = floor_value(value_10_4)
            local value_8_8 = floor_result + 1
            local value_12_11 = value_27
            local value_11_11 = value_12_11 - 1
            local value_12_12 = value_24
            local value_10_5 = value_11_11 % value_12_12
            local value_9_7 = value_10_5 + 1
            local value_10_6 = captured_value_29
            local cloned_value = value_10_6:Clone()
            local value_12_13: string = "Emote"
            local value_13_16 = value_9_7
            local value_11_13 = value_12_13 .. value_13_16
            cloned_value.Name = value_11_13
            local value_13_17: string = "EmoteName"
            local value_14_9 = value_6_3
            cloned_value:SetAttribute(value_13_17, value_14_9)
            local emote_name_value = cloned_value.EmoteName
            local name_value = get_item_info_result.Name
            local value_12_15 = name_value or value_6_3
            emote_name_value.Text = value_12_15
            local emote_icon_value = cloned_value.EmoteIcon
            local value_12_16 = captured_value_28
            local value_14_10 = get_item_info_result
            local get_item_image_result = value_12_16:GetItemImage(value_14_10)
            emote_icon_value.Image = get_item_image_result
            local hotkey_value = cloned_value.Hotkey
            local key_label_value = hotkey_value.KeyLabel
            key_label_value.Text = value_9_7
            local hotkey_value_2 = cloned_value.Hotkey
            local value_12_18: Instance = captured_value_30
            local keyboard_enabled_value = value_12_18.KeyboardEnabled
            hotkey_value_2.Visible = keyboard_enabled_value
            local value_11_15 = value_27
            cloned_value.LayoutOrder = value_11_15
            local play_button_value = cloned_value.PlayButton
            local activated_value = play_button_value.Activated
            local value_13_19: (() -> ())?
            do
                local captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44, captured_value_45, captured_value_46, captured_value_47, closure_ready
                value_13_19 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local value_1_21 = captured_value_40
                    value_22 = false
                    local value_2_38 = captured_value_41
                    local value_3_18: boolean = value_22
                    value_2_38.Sink = value_3_18
                    local value_2_39 = captured_value_42
                    local value_3_19: boolean = value_22
                    value_2_39.Visible = value_3_19
                    if captured_value_43.PreferredInput == Enum.PreferredInput.Gamepad then
                        if value_22 then
                            local value_2_42: Instance? = captured_value_44
                            local current_page_value_10 = captured_value_45.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                            value_2_42:Select(current_page_value_10)
                        else
                            local value_2_44: Instance? = captured_value_44
                            local value_3_21: nil = nil
                            value_2_44.SelectedObject = value_3_21
                            local emotes_value_6 = captured_value_46.GameplayContext.Emotes
                            local value_4_9: boolean = false
                            emotes_value_6:Fire(value_4_9)
                        end
                    end
                    local value_2_47 = captured_value_47
                    local value_4_10 = value_1_21
                    value_2_47:Fire(value_4_10)

                    return
                end
                captured_value_40, captured_value_41, captured_value_42, captured_value_43, captured_value_44, captured_value_45, captured_value_46, captured_value_47 = value_6_3, captured_value_31, captured_value_32, captured_value_30, captured_value_33, captured_value_34, captured_value_35, captured_value_36
                closure_ready = true
            end
            activated_value:Connect(value_13_19)
            local value_11_17 = captured_value_37
            local value_14_11: string = "Row"
            local value_15_11 = value_8_8
            local value_13_20 = value_14_11 .. value_15_11
            local find_first_child_result = value_11_17:FindFirstChild(value_13_20)
            local value_9_8 = find_first_child_result
            if not value_9_8 then
                local value_11_19: Instance? = captured_value_38
                local cloned_value_2 = value_11_19:Clone()
                value_9_8 = cloned_value_2
                local value_12_22: string = "Row"
                local value_13_21 = value_8_8
                local value_11_21 = value_12_22 .. value_13_21
                value_9_8.Name = value_11_21
                local value_11_22 = captured_value_37
                value_9_8.Parent = value_11_22
            end
            value_9_8.LayoutOrder = value_8_8
            local value_11_23 = captured_value_39
            local value_12_23 = captured_value_37
            value_11_23[value_12_23] = value_8_8
            cloned_value.Parent = value_9_8
            local value_11_24 = captured_value_27
            value_11_24[value_6_3] = cloned_value
            local value_11_25 = value_27
            local value_11_26 = value_11_25 + 1
            value_27 = value_11_26
        end

        return
    end
end
local on_character_added
do
    local captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58, captured_value_59 = emote_context_child, emote_window_child, user_input_service, gui_service, emote_pages_child, input_context_child, table_2, table_3, value_15_10, emote_frame_child, row_frame_child, table_26
    on_character_added = function(argument_1_3)
        value_22 = false
        local value_2_50 = captured_value_48
        local value_3_24 = value_22
        value_2_50.Sink = value_3_24
        local value_2_51 = captured_value_49
        value_3_24 = value_22
        value_2_51.Visible = value_3_24
        local preferred_input_value_6 = captured_value_50.PreferredInput
        value_3_24 = Enum.PreferredInput.Gamepad
        local value_4_11
        if preferred_input_value_6 == value_3_24 then
            if value_22 then
                local value_2_54: Instance = captured_value_51
                value_4_11 = captured_value_52.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_2_54:Select(value_4_11)
            else
                local value_2_56: Instance = captured_value_51
                value_3_24 = nil
                value_2_56.SelectedObject = value_3_24
                local emotes_value_7 = captured_value_53.GameplayContext.Emotes
                value_4_11 = false
                emotes_value_7:Fire(value_4_11)
            end
        end
        value_4_11 = "Humanoid"
        value_23 = (argument_1_3:WaitForChild(value_4_11))
        local get_applied_description_result = value_23:GetAppliedDescription()
        table.clear(captured_value_54)
        table.clear(captured_value_55)
        local value_5_3
        value_3_24, value_4_11, value_5_3 = get_applied_description_result:GetEmotes()
        local value_6_4, value_7_9
        for key_2, value_25 in value_3_24, value_4_11, value_5_3 do
            value_6_4, value_7_9 = key_2, value_25
            local value_8_9 = value_7_9[1]
            local value_9_9: string = "rbxthumb://type=Asset&w=150&h=150&id=%*"
            local value_11_27 = value_8_9
            local format_result = value_9_9:format(value_11_27)
            local value_10_9 = captured_value_54
            local table_11 = {Image = 0, Slot = 0}
            table_11["Slot"] = nil
            table_11.Image = format_result
            value_10_9[value_6_4] = table_11
        end
        value_3_24, value_4_11, value_5_3 = get_applied_description_result:GetEquippedEmotes()
        for key_3, value_26 in value_3_24, value_4_11, value_5_3 do
            value_6_4, value_7_9 = key_3, value_26
            local name_value_2 = value_7_9.Name
            local value_10_10 = captured_value_54
            local value_9_11 = value_10_10[name_value_2]
            if not value_9_11 then
                continue
            end
            local find_value = table.find
            local value_10_11 = captured_value_55
            local value_11_28 = name_value_2
            local find_result = find_value(value_10_11, value_11_28)
            if find_result then
                continue
            end
            local value_10_12 = captured_value_54
            local value_9_12 = value_10_12[name_value_2]
            local slot_value = value_7_9.Slot
            value_9_12.Slot = slot_value
            local value_10_13 = captured_value_55
            local slot_value_2 = value_7_9.Slot
            local value_12_24 = name_value_2
            local insert_value = table.insert
            insert_value(value_10_13, slot_value_2, value_12_24)
        end
        value_3_24 = captured_value_54
        value_4_11 = nil
        value_5_3 = nil
        for key_4, value_28 in value_3_24, value_4_11, value_5_3 do
            value_6_4, value_7_9 = key_4, value_28
            local find_value_2 = table.find
            local value_9_13 = captured_value_55
            local value_10_14 = value_6_4
            local find_result_2 = find_value_2(value_9_13, value_10_14)
            if find_result_2 then
                continue
            end
            local value_9_14 = captured_value_55
            local value_10_15 = value_6_4
            local insert_value_2 = table.insert
            insert_value_2(value_9_14, value_10_15)
        end
        value_3_24, value_4_11, value_5_3 = captured_value_56:GetChildren()
        for key_5, value_30 in value_3_24, value_4_11, value_5_3 do
            value_6_4, value_7_9 = key_5, value_30
            local value_10_16: string = "Frame"
            local is_a_result = value_7_9:IsA(value_10_16)
            if not is_a_result then
                continue
            end
            value_7_9:Destroy()
        end
        value_3_24 = captured_value_55
        value_4_11 = nil
        value_5_3 = nil
        for key_6, value_31 in value_3_24, value_4_11, value_5_3 do
            value_6_4, value_7_9 = key_6, value_31
            local value_10_17 = value_6_4 - 1
            local value_11_29 = value_24
            local value_9_17 = value_10_17 / value_11_29
            local floor_value_2 = math.floor
            local floor_result_2 = floor_value_2(value_9_17)
            local value_2_62 = floor_result_2 + 1
            local value_10_18 = value_6_4 - 1
            local value_11_30 = value_24
            local value_9_18 = value_10_18 % value_11_30
            local value_8_12 = value_9_18 + 1
            local value_9_19 = captured_value_57
            local cloned_value_3 = value_9_19:Clone()
            local value_11_31: string = "Emote"
            local value_12_25 = value_8_12
            local value_10_20 = value_11_31 .. value_12_25
            cloned_value_3.Name = value_10_20
            local value_12_26: string = "EmoteName"
            local value_13_22 = value_7_9
            cloned_value_3:SetAttribute(value_12_26, value_13_22)
            local emote_name_value_2 = cloned_value_3.EmoteName
            emote_name_value_2.Text = value_7_9
            local emote_icon_value_2 = cloned_value_3.EmoteIcon
            local value_12_27 = captured_value_54
            local value_11_33 = value_12_27[value_7_9]
            local image_value = value_11_33.Image
            emote_icon_value_2.Image = image_value
            local hotkey_value_3 = cloned_value_3.Hotkey
            local key_label_value_2 = hotkey_value_3.KeyLabel
            key_label_value_2.Text = value_8_12
            local hotkey_value_4 = cloned_value_3.Hotkey
            local value_11_34: Instance = captured_value_50
            local keyboard_enabled_value_2 = value_11_34.KeyboardEnabled
            hotkey_value_4.Visible = keyboard_enabled_value_2
            cloned_value_3.LayoutOrder = value_8_12
            local play_button_value_2 = cloned_value_3.PlayButton
            local activated_value_2 = play_button_value_2.Activated
            local value_12_28: (() -> ())?
            do
                local captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64, captured_value_65, captured_value_66, closure_ready_2
                value_12_28 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    local value_1_22 = captured_value_60
                    value_22 = false
                    local value_2_64 = captured_value_61
                    local value_3_25: boolean = value_22
                    value_2_64.Sink = value_3_25
                    local value_2_65 = captured_value_62
                    local value_3_26: boolean = value_22
                    value_2_65.Visible = value_3_26
                    if captured_value_63.PreferredInput == Enum.PreferredInput.Gamepad then
                        if value_22 then
                            local value_2_68: Instance? = captured_value_64
                            local current_page_value_12 = captured_value_65.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                            value_2_68:Select(current_page_value_12)
                        else
                            local value_2_70: Instance? = captured_value_64
                            local value_3_28: nil = nil
                            value_2_70.SelectedObject = value_3_28
                            local emotes_value_8 = captured_value_66.GameplayContext.Emotes
                            local value_4_13: boolean = false
                            emotes_value_8:Fire(value_4_13)
                        end
                    end
                    local value_2_73 = value_23
                    local value_4_14 = value_1_22
                    value_2_73:PlayEmote(value_4_14)

                    return
                end
                captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64, captured_value_65, captured_value_66 = value_7_9, captured_value_48, captured_value_49, captured_value_50, captured_value_51, captured_value_52, captured_value_53
                closure_ready_2 = true
            end
            activated_value_2:Connect(value_12_28)
            local value_10_23 = captured_value_56
            local value_13_23: string = "Row"
            local value_14_12 = value_2_62
            local value_12_29 = value_13_23 .. value_14_12
            local find_first_child_result_2 = value_10_23:FindFirstChild(value_12_29)
            local value_8_13 = find_first_child_result_2
            if not value_8_13 then
                local value_10_25: Instance? = captured_value_58
                local cloned_value_4 = value_10_25:Clone()
                value_8_13 = cloned_value_4
                local value_11_38: string = "Row"
                local value_12_30 = value_2_62
                local value_10_27 = value_11_38 .. value_12_30
                value_8_13.Name = value_10_27
                local value_10_28 = captured_value_56
                value_8_13.Parent = value_10_28
            end
            value_8_13.LayoutOrder = value_2_62
            local value_10_29 = captured_value_59
            local value_11_39 = captured_value_56
            value_10_29[value_11_39] = value_2_62
            cloned_value_3.Parent = value_8_13
            value_6_4 = value_6_4 + 1
        end

        return
    end
end
do
    local captured_value_67, captured_value_68, captured_value_69 = emote_pages_child, table_26, emote_navigation_child

    local function update_title_text()
        local current_page_value_13 = captured_value_67.UIPageLayout.CurrentPage
        local current_page_value_14 = current_page_value_13.UIPageLayout.CurrentPage
        local name_value_3 = current_page_value_13.Name
        local layout_order_value = current_page_value_14.LayoutOrder
        local value_2_75 = captured_value_68[current_page_value_13]
        local text_label_value = captured_value_69.Title.TextLabel
        local value_6_5: string = "%* (%*/%*)"
        local value_8_14 = name_value_3
        local value_9_21 = layout_order_value
        local value_10_30 = value_2_75
        local format_result_2 = value_6_5:format(value_8_14, value_9_21, value_10_30)
        text_label_value.Text = format_result_2

        return
    end
end
local on_preferred_input_changed: (() -> ())?
do
    local captured_value_70, captured_value_71 = emote_navigation_child, user_input_service
    on_preferred_input_changed = function(): ()
        local value_1_24 = captured_value_70
        local value_3_31: string = "SwapFrame"
        local swap_frame_child = value_1_24:WaitForChild(value_3_31)
        local value_3_32: string = "Container"
        local container_child = swap_frame_child:WaitForChild(value_3_32)
        local value_3_33: string = "KeycodeLabel"
        local keycode_label_child = container_child:WaitForChild(value_3_33)
        local value_2_79: boolean?
        if captured_value_71.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse then
            value_2_79 = false
        else
            value_2_79 = true
        end
        keycode_label_child.Visible = value_2_79
        local value_1_28 = captured_value_70
        local value_3_35: string = "Up"
        local up_child = value_1_28:WaitForChild(value_3_35)
        local value_3_36: string = "Container"
        local container_child_2 = up_child:WaitForChild(value_3_36)
        local value_3_37: string = "KeycodeLabel"
        local keycode_label_child_2 = container_child_2:WaitForChild(value_3_37)
        local value_2_83: boolean?
        if captured_value_71.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse then
            value_2_83 = false
        else
            value_2_83 = true
        end
        keycode_label_child_2.Visible = value_2_83
        local value_1_32 = captured_value_70
        local value_3_39: string = "Down"
        local down_child = value_1_32:WaitForChild(value_3_39)
        local value_3_40: string = "Container"
        local container_child_3 = down_child:WaitForChild(value_3_40)
        local value_3_41: string = "KeycodeLabel"
        local keycode_label_child_3 = container_child_3:WaitForChild(value_3_41)
        local value_2_87: boolean?
        if captured_value_71.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse then
            value_2_87 = false
        else
            value_2_87 = true
        end
        keycode_label_child_3.Visible = value_2_87

        return
    end
end
local on_initialize
do
    local captured_value_72, captured_value_73, captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_78, captured_value_79, captured_value_80, captured_value_81, captured_value_82, captured_value_83, captured_value_84, captured_value_85, captured_value_86, captured_value_87, captured_value_88, captured_value_89, captured_value_90, captured_value_91, captured_value_92 = emote_frame_child, emote_pages_child, emote_context_child, emote_window_child, user_input_service, gui_service, input_context_child, x_value, wait_for_child_result_2, play_emote_child, value_15_10, table_26, emote_navigation_child, table_19, local_player_value, on_character_added, gameplay_context_child, on_emote_button_pressed, add_game_emotes, remotes_child, on_preferred_input_changed
    on_initialize = function()
        local value_1_36 = captured_value_72
        local script_value_3 = script
        value_1_36.Parent = script_value_3
        captured_value_73["Game Emotes"].Row1:Destroy()
        value_22 = false
        value_1_36 = captured_value_74
        script_value_3 = value_22
        value_1_36.Sink = script_value_3
        value_1_36 = captured_value_75
        script_value_3 = value_22
        value_1_36.Visible = script_value_3
        value_1_36 = captured_value_76.PreferredInput
        script_value_3 = Enum.PreferredInput.Gamepad
        local value_3_43
        if value_1_36 == script_value_3 then
            value_1_36 = value_22
            if value_1_36 then
                value_1_36 = captured_value_77
                value_3_43 = captured_value_73.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                value_1_36:Select(value_3_43)
            else
                value_1_36 = captured_value_77
                script_value_3 = nil
                value_1_36.SelectedObject = script_value_3
                value_1_36 = captured_value_78.GameplayContext.Emotes
                value_3_43 = false
                value_1_36:Fire(value_3_43)
            end
        end
        local value_4_15 = captured_value_73.AbsoluteSize.X
        local value_5_6 = captured_value_79 + 5
        value_3_43 = value_4_15 / value_5_6
        script_value_3 = math.floor(value_3_43)
        value_3_43 = 0
        value_4_15 = 8
        value_24 = (math.clamp(script_value_3, value_3_43, value_4_15))
        value_1_36, script_value_3, value_3_43 = captured_value_74:GetChildren()
        for key_7, value_32 in value_1_36, script_value_3, value_3_43 do
            value_4_15, value_5_6 = key_7, value_32
            local name_value_4 = value_5_6.Name
            local value_8_15: number = 1
            local value_9_22: number = 5
            local sub_value = string.sub
            local sub_result = sub_value(name_value_4, value_8_15, value_9_22)
            if sub_result ~= "Emote" then
                continue
            end
            local name_value_5 = value_5_6.Name
            local value_9_23: number = 6
            local sub_value_2 = string.sub
            local sub_result_2 = sub_value_2(name_value_5, value_9_23)
            local tonumber_value = tonumber
            local tonumber_result = tonumber_value(sub_result_2)
            local pressed_value = value_5_6.Pressed
            local value_9_24
            do
                local captured_value_93, captured_value_94, captured_value_95, captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102, closure_ready_3
                value_9_24 = function(): ()
                    if not closure_ready_3 then
                        return
                    end
                    if not value_22 then
                        return
                    end
                    local current_page_value_15 = captured_value_93.UIPageLayout.CurrentPage
                    local current_page_value_16 = current_page_value_15.UIPageLayout.CurrentPage
                    local value_5_7 = "Emote" .. captured_value_94
                    local find_first_child_result_3 = current_page_value_16:FindFirstChild(
                        value_5_7
                    )
                    if not find_first_child_result_3 then
                        return
                    end
                    local value_6_13: string = "EmoteName"
                    local value_2_88 = (find_first_child_result_3:GetAttribute(value_6_13))
                    if current_page_value_15 == captured_value_95 then
                        value_22 = false
                        local value_4_20 = captured_value_96
                        local value_5_9 = value_22
                        value_4_20.Sink = value_5_9
                        local value_4_21 = captured_value_97
                        local value_5_10 = value_22
                        value_4_21.Visible = value_5_10
                        if captured_value_98.PreferredInput == Enum.PreferredInput.Gamepad then
                            if value_22 then
                                local value_4_24: Instance? = captured_value_99
                                local current_page_value_18 = captured_value_93.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                                value_4_24:Select(current_page_value_18)
                            else
                                local value_4_26: Instance? = captured_value_99
                                local value_5_12: nil = nil
                                value_4_26.SelectedObject = value_5_12
                                local emotes_value_9 = captured_value_100.GameplayContext.Emotes
                                local value_6_15: boolean = false
                                emotes_value_9:Fire(value_6_15)
                            end
                        end
                        local value_4_29 = captured_value_101
                        local value_6_16 = value_2_88
                        value_4_29:Fire(value_6_16)

                        return
                    end
                    if current_page_value_15 == captured_value_102 then
                        value_22 = false
                        local value_4_33 = captured_value_96
                        local value_5_15 = value_22
                        value_4_33.Sink = value_5_15
                        local value_4_34 = captured_value_97
                        local value_5_16 = value_22
                        value_4_34.Visible = value_5_16
                        if captured_value_98.PreferredInput == Enum.PreferredInput.Gamepad then
                            if value_22 then
                                local value_4_37: Instance? = captured_value_99
                                local current_page_value_20 = captured_value_93.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                                value_4_37:Select(current_page_value_20)
                            else
                                local value_4_39: Instance? = captured_value_99
                                local value_5_18: nil = nil
                                value_4_39.SelectedObject = value_5_18
                                local emotes_value_10 = captured_value_100.GameplayContext.Emotes
                                local value_6_18: boolean = false
                                emotes_value_10:Fire(value_6_18)
                            end
                        end
                        local value_4_42 = value_23
                        local value_6_19 = value_2_88
                        value_4_42:PlayEmote(value_6_19)
                    end

                    return
                end
                captured_value_93, captured_value_94, captured_value_95, captured_value_96, captured_value_97, captured_value_98, captured_value_99, captured_value_100, captured_value_101, captured_value_102 = captured_value_73, tonumber_result, captured_value_80, captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_78, captured_value_81, captured_value_82
                closure_ready_3 = true
            end
            pressed_value:Connect(value_9_24)
        end
        value_1_36 = captured_value_74
        value_3_43 = "ScrollRight"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        do
            local captured_value_103, captured_value_104, captured_value_105, closure_ready_4
            value_3_43 = function(): ()
                if not closure_ready_4 then
                    return
                end
                if not value_22 then
                    return
                end
                captured_value_103.UIPageLayout:Next()
                local current_page_value_21 = captured_value_103.UIPageLayout.CurrentPage
                local current_page_value_22 = current_page_value_21.UIPageLayout.CurrentPage
                local name_value_6 = current_page_value_21.Name
                local layout_order_value_2 = current_page_value_22.LayoutOrder
                local value_2_90 = captured_value_104[current_page_value_21]
                local text_label_value_2 = captured_value_105.Title.TextLabel
                local value_6_20: string = "%* (%*/%*)"
                local value_8_19 = name_value_6
                local value_9_26 = layout_order_value_2
                local value_10_32 = value_2_90
                local format_result_4 = value_6_20:format(value_8_19, value_9_26, value_10_32)
                text_label_value_2.Text = format_result_4

                return
            end
            captured_value_103, captured_value_104, captured_value_105 = captured_value_73, captured_value_83, captured_value_84
            closure_ready_4 = true
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_74
        value_3_43 = "ScrollLeft"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        do
            local captured_value_106, captured_value_107, captured_value_108, closure_ready_5
            value_3_43 = function(): ()
                if not closure_ready_5 then
                    return
                end
                if not value_22 then
                    return
                end
                captured_value_106.UIPageLayout:Previous()
                local current_page_value_23 = captured_value_106.UIPageLayout.CurrentPage
                local current_page_value_24 = current_page_value_23.UIPageLayout.CurrentPage
                local name_value_7 = current_page_value_23.Name
                local layout_order_value_3 = current_page_value_24.LayoutOrder
                local value_2_92 = captured_value_107[current_page_value_23]
                local text_label_value_3 = captured_value_108.Title.TextLabel
                local value_6_22: string = "%* (%*/%*)"
                local value_8_20 = name_value_7
                local value_9_27 = layout_order_value_3
                local value_10_33 = value_2_92
                local format_result_5 = value_6_22:format(value_8_20, value_9_27, value_10_33)
                text_label_value_3.Text = format_result_5

                return
            end
            captured_value_106, captured_value_107, captured_value_108 = captured_value_73, captured_value_83, captured_value_84
            closure_ready_5 = true
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_74
        value_3_43 = "ScrollUp"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        do
            local captured_value_109, captured_value_110, captured_value_111, closure_ready_6
            value_3_43 = function(): ()
                if not closure_ready_6 then
                    return
                end
                if not value_22 then
                    return
                end
                captured_value_109.UIPageLayout.CurrentPage.UIPageLayout:Previous()
                local current_page_value_26 = captured_value_109.UIPageLayout.CurrentPage
                local current_page_value_27 = current_page_value_26.UIPageLayout.CurrentPage
                local name_value_8 = current_page_value_26.Name
                local layout_order_value_4 = current_page_value_27.LayoutOrder
                local value_2_94 = captured_value_110[current_page_value_26]
                local text_label_value_4 = captured_value_111.Title.TextLabel
                local value_6_24: string = "%* (%*/%*)"
                local value_8_21 = name_value_8
                local value_9_28 = layout_order_value_4
                local value_10_34 = value_2_94
                local format_result_6 = value_6_24:format(value_8_21, value_9_28, value_10_34)
                text_label_value_4.Text = format_result_6

                return
            end
            captured_value_109, captured_value_110, captured_value_111 = captured_value_73, captured_value_83, captured_value_84
            closure_ready_6 = true
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_74
        value_3_43 = "ScrollDown"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        do
            local captured_value_112, captured_value_113, captured_value_114, closure_ready_7
            value_3_43 = function(): ()
                if not closure_ready_7 then
                    return
                end
                if not value_22 then
                    return
                end
                captured_value_112.UIPageLayout.CurrentPage.UIPageLayout:Next()
                local current_page_value_29 = captured_value_112.UIPageLayout.CurrentPage
                local current_page_value_30 = current_page_value_29.UIPageLayout.CurrentPage
                local name_value_9 = current_page_value_29.Name
                local layout_order_value_5 = current_page_value_30.LayoutOrder
                local value_2_96 = captured_value_113[current_page_value_29]
                local text_label_value_5 = captured_value_114.Title.TextLabel
                local value_6_26: string = "%* (%*/%*)"
                local value_8_22 = name_value_9
                local value_9_29 = layout_order_value_5
                local value_10_35 = value_2_96
                local format_result_7 = value_6_26:format(value_8_22, value_9_29, value_10_35)
                text_label_value_5.Text = format_result_7

                return
            end
            captured_value_112, captured_value_113, captured_value_114 = captured_value_73, captured_value_83, captured_value_84
            closure_ready_7 = true
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_85
        script_value_3 = nil
        value_3_43 = nil
        for key_8, value_33 in value_1_36, script_value_3, value_3_43 do
            value_4_15, value_5_6 = key_8, value_33
            local input_changed_value = value_5_6.InputChanged
            local value_8_17
            do
                local captured_value_115, closure_ready_8
                value_8_17 = function(argument_1_4): ()
                    if not closure_ready_8 then
                        return
                    end
                    if argument_1_4.UserInputType == Enum.UserInputType.MouseWheel then
                        if 0 < argument_1_4.Position.Z then
                            captured_value_115.UIPageLayout:Previous()

                            return
                        end
                        captured_value_115.UIPageLayout:Next()
                    end

                    return
                end
                captured_value_115 = value_5_6
                closure_ready_8 = true
            end
            input_changed_value:Connect(value_8_17)
        end
        while true do
            task.wait()
            value_1_36 = captured_value_86.Character
            if value_1_36 ~= nil then
                break
            end
        end
        value_1_36 = captured_value_87
        script_value_3 = captured_value_86.Character
        value_1_36(script_value_3)
        value_1_36 = captured_value_86.CharacterAdded
        value_3_43 = captured_value_87
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_88
        value_3_43 = "Emotes"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        value_3_43 = captured_value_89
        value_1_36:Connect(value_3_43)
        captured_value_90()
        value_1_36 = captured_value_91
        value_3_43 = "Inventory"
        value_1_36 = value_1_36:WaitForChild(value_3_43)
        value_3_43 = "InventoryDataChanged"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Event
        do
            local captured_value_116 = captured_value_90
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_116) then
                value_3_43 = closure_cache[1]
            else
                local closure_ready_9
                value_3_43 = function<T2, T3>(argument_1_5, argument_2: T2, argument_3: T3)
                    if not closure_ready_9 then
                        return
                    end
                    if argument_1_5 ~= "Emotes" then
                        if argument_1_5 ~= "Toys" then
                            return
                        end
                    end
                    captured_value_116()

                    return
                end
                closure_ready_9 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_43
                    closure_cache[2] = captured_value_116
                end
            end
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_77:IsTenFootInterface()
        if value_1_36 then
            value_1_36 = captured_value_75
            script_value_3 = UDim2.new(0.5, 0, 1, -100)
            value_1_36.Position = script_value_3
            value_1_36 = captured_value_75.UIScale
            script_value_3 = 1.33
            value_1_36.Scale = script_value_3
        end
        captured_value_92()
        value_1_36 = captured_value_76
        value_3_43 = "PreferredInput"
        value_1_36 = value_1_36:GetPropertyChangedSignal(value_3_43)
        value_3_43 = captured_value_92
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_74
        value_3_43 = "Cancel"
        value_1_36 = value_1_36:WaitForChild(value_3_43).Pressed
        do
            local captured_value_117, captured_value_118, captured_value_119, captured_value_120, captured_value_121, captured_value_122, closure_ready_10
            value_3_43 = function(): ()
                if not closure_ready_10 then
                    return
                end
                value_22 = false
                local value_1_56 = captured_value_117
                local value_2_101: boolean = value_22
                value_1_56.Sink = value_2_101
                local value_1_57 = captured_value_118
                local value_2_102: boolean = value_22
                value_1_57.Visible = value_2_102
                if captured_value_119.PreferredInput == Enum.PreferredInput.Gamepad then
                    if value_22 then
                        local value_1_60: Instance? = captured_value_120
                        local current_page_value_32 = captured_value_121.UIPageLayout.CurrentPage.UIPageLayout.CurrentPage
                        value_1_60:Select(current_page_value_32)

                        return
                    end
                    local value_1_62: Instance? = captured_value_120
                    local value_2_104: nil = nil
                    value_1_62.SelectedObject = value_2_104
                    local emotes_value_11 = captured_value_122.GameplayContext.Emotes
                    local value_3_49: boolean = false
                    emotes_value_11:Fire(value_3_49)
                end

                return
            end
            captured_value_117, captured_value_118, captured_value_119, captured_value_120, captured_value_121, captured_value_122 = captured_value_74, captured_value_75, captured_value_76, captured_value_77, captured_value_73, captured_value_78
            closure_ready_10 = true
        end
        value_1_36:Connect(value_3_43)
        value_1_36 = captured_value_84
        value_3_43 = "Title"
        value_1_36 = value_1_36:WaitForChild(value_3_43)
        value_3_43 = "TextLabel"
        value_1_36 = value_1_36:WaitForChild(value_3_43)
        script_value_3 = captured_value_73
        value_4_15 = "UIPageLayout"
        script_value_3 = script_value_3:WaitForChild(value_4_15).CurrentPage.Name
        value_1_36.Text = script_value_3
        value_1_36 = captured_value_73.UIPageLayout.CurrentPage
        script_value_3 = value_1_36.UIPageLayout.CurrentPage
        value_3_43 = value_1_36.Name
        value_4_15 = script_value_3.LayoutOrder
        script_value_3 = captured_value_83[value_1_36]
        value_5_6 = captured_value_84.Title.TextLabel
        local value_6_10: string = "%* (%*/%*)"
        local value_8_18 = value_3_43
        local value_9_25 = value_4_15
        local value_10_31 = script_value_3
        local format_result_3 = value_6_10:format(value_8_18, value_9_25, value_10_31)
        value_5_6.Text = format_result_3

        return
    end
end
on_initialize()

return
