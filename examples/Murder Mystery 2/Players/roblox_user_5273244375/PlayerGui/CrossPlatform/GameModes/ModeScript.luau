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
local value_3: string = "TeleportService"
local teleport_service: Instance = game_value:GetService(value_3)
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_5_3))
local request_teleport_value = game.ReplicatedStorage.Remotes.Extras.RequestTeleport
local require_result_2 = require(game.ReplicatedStorage.Modules.FriendsModule)
local parent_value: Instance? = script.Parent
local value_8: string = "Container"
local container_child = parent_value:WaitForChild(value_8)
local value_8_2: string = "Modes"
local modes_child = container_child:WaitForChild(value_8_2)
local teleport_info_value = parent_value.TeleportInfo
local overlay_value = parent_value.Overlay
local script_value_2: LuaSourceContainer = script
local value_11: string = "ModeFrame"
local mode_frame_child: Instance? = script_value_2:WaitForChild(value_11)
local script_value_3: LuaSourceContainer = script
local value_12: string = "ModeOverlay"
local mode_overlay_child: Instance? = script_value_3:WaitForChild(value_12)
local value_13: string = "ModeInfo"
local mode_info_child = mode_overlay_child:WaitForChild(value_13)
local value_13_2: string = "ModeList"
local mode_list_child = mode_info_child:WaitForChild(value_13_2)
local value_13_3: string = "ListItem"
local list_item_child = mode_list_child:WaitForChild(value_13_3)
local script_value_4: LuaSourceContainer = script
list_item_child.Parent = script_value_4
local require_value_3 = require
local game_value_5: DataModel = game
local value_15: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_5:GetService(value_15)
local value_15_2: string = "Database"
local database_child: Instance? = replicated_storage_service_2:WaitForChild(value_15_2)
local value_15_3: string = "Sync"
local game_modes_value = require_value_3(database_child:WaitForChild(value_15_3)).GameModes
do
    local captured_value = game_modes_value

    local function get_player_count(argument_1)
        return captured_value[argument_1].PlayerCount
    end
end

local function get_friends_playing_mode<T1>(argument_1_2: T1): number
    return 0
end

local update_frame
do
    local captured_value_2, captured_value_3, captured_value_4 = require_result_2, game_modes_value, overlay_value
    update_frame = function(argument_1_3): ()
        local name_value = argument_1_3.Name
        local info_value = argument_1_3.Info
        local value_4_4: number = 0
        local get_friends_online_result = captured_value_2:GetFriendsOnline()
        local place_id_value = captured_value_3[name_value].PlaceID
        local value_7_3 = get_friends_online_result
        local value_8_3 = nil
        local value_9_2: nil = nil
        for key, value in value_7_3, value_8_3, value_9_2 do
            local value_10_3, value_11_6 = key, value
            local place_id_value_2 = value_11_6.PlaceId
            if place_id_value_2 ~= place_id_value then
                continue
            end
            value_4_4 = value_4_4 + 1
        end
        local value_6_5: string?
        if value_4_4 == 1 then
            value_6_5 = "Friend"
        else
            value_6_5 = "Friends"
        end
        value_7_3 = value_4_4
        value_8_3 = " "
        local value_5_6: string = value_7_3 .. value_8_3 .. value_6_5 .. " " .. "Online"
        value_7_3 = info_value.PlayerCount
        if not (0 < captured_value_3[name_value].PlayerCount) then
            value_8_3 = false
        else
            value_8_3 = true
        end
        value_7_3.Visible = value_8_3
        value_7_3 = info_value.FriendsPlaying
        if not (0 < value_4_4) then
            value_8_3 = false
        else
            value_8_3 = true
        end
        value_7_3.Visible = value_8_3
        value_7_3 = info_value.FriendsPlaying.TextLabel
        value_7_3.Text = value_5_6
        value_7_3 = info_value.Popular
        value_8_3 = false
        if name_value == "Standard" then
            value_8_3 = false
            if info_value.PlayerCount.Visible == false then
                if info_value.FriendsPlaying.Visible ~= false then
                    value_8_3 = false
                else
                    value_8_3 = true
                end
            end
        end
        value_7_3.Visible = value_8_3
        local container_value = captured_value_4.Container
        value_8_3 = name_value
        local value_6_8 = container_value:FindFirstChild(value_8_3)
        value_7_3 = value_6_8.FriendsPlaying
        if not (0 < value_4_4) then
            value_8_3 = false
        else
            value_8_3 = true
        end
        value_7_3.Visible = value_8_3
        value_7_3 = value_6_8.FriendsPlaying.TextLabel
        value_7_3.Text = value_5_6
        value_7_3 = value_6_8.Actions.Friends
        if not (0 < value_4_4) then
            value_8_3 = false
        else
            value_8_3 = true
        end
        value_7_3.Visible = value_8_3

        return
    end
end
local setup_modes
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14 = game_modes_value, mode_frame_child, mode_overlay_child, list_item_child, overlay_value, update_frame, teleport_info_value, request_teleport_value, require_result, modes_child
    setup_modes = function()
        local value_1_2 = captured_value_5
        local value_2_4: nil = nil
        local value_3_6: nil = nil
        for key_4, value_23 in value_1_2, value_2_4, value_3_6 do
            local value_4_5, value_5_7 = key_4, value_23
            local hidden_value = value_5_7.Hidden
            if hidden_value then
                continue
            end
            local value_6_9: Instance? = captured_value_6
            local cloned_value = value_6_9:Clone()
            cloned_value.Name = value_4_5
            local info_value_2 = cloned_value.Info
            local mode_name_value = info_value_2.ModeName
            local text_label_value = mode_name_value.TextLabel
            local display_name_value = value_5_7.DisplayName
            text_label_value.Text = display_name_value
            local info_value_3 = cloned_value.Info
            local mode_icon_value = info_value_3.ModeIcon
            local image_label_value = mode_icon_value.ImageLabel
            display_name_value = value_5_7.Image
            image_label_value.Image = display_name_value
            local info_value_4 = cloned_value.Info
            local mode_icon_value_2 = info_value_4.ModeIcon
            local limited_value = mode_icon_value_2.Limited
            if value_5_7.LimitedTime ~= true then
                display_name_value = false
            else
                display_name_value = true
            end
            limited_value.Visible = display_name_value
            local order_value = value_5_7.Order
            cloned_value.LayoutOrder = order_value
            local value_7_5: Instance? = captured_value_7
            local cloned_value_2 = value_7_5:Clone()
            display_name_value = cloned_value_2.ModeName
            local limited_time_value = value_5_7.DisplayName
            display_name_value.Text = limited_time_value
            display_name_value = cloned_value_2.ModeInfo.ModeIcon.ImageLabel
            limited_time_value = value_5_7.Image
            display_name_value.Image = limited_time_value
            display_name_value = value_5_7.Description
            limited_time_value = nil
            local value_10_4 = nil
            local value_11_7
            for key_2, value_21 in display_name_value, limited_time_value, value_10_4 do
                local value_12_5
                value_11_7, value_12_5 = key_2, value_21
                local value_13_7 = captured_value_8
                local cloned_value_3 = value_13_7:Clone()
                cloned_value_3.Text = value_12_5
                cloned_value_3.LayoutOrder = value_11_7
                local mode_info_value = cloned_value_2.ModeInfo
                local mode_list_value = mode_info_value.ModeList
                cloned_value_3.Parent = mode_list_value
            end
            cloned_value_2.Name = value_4_5
            display_name_value = captured_value_9.Container
            cloned_value_2.Parent = display_name_value
            display_name_value = captured_value_10
            limited_time_value = cloned_value
            display_name_value(limited_time_value)
            display_name_value = cloned_value.Info.ModeIcon.CurrentServer
            value_10_4 = value_5_7.PlaceID
            value_11_7 = game.PlaceId
            if value_10_4 ~= value_11_7 then
                limited_time_value = false
            else
                limited_time_value = true
            end
            display_name_value.Visible = limited_time_value
            display_name_value = cloned_value.Button.Activated
            do
                local captured_value_15, captured_value_16, closure_ready
                value_10_4 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local value_1_3 = captured_value_15.Visible
                    if not value_1_3 then
                        local value_2_5, value_3_7
                        value_1_3, value_2_5, value_3_7 = captured_value_15.Container:GetChildren()
                        for key_3, value_22 in value_1_3, value_2_5, value_3_7 do
                            local value_4_6, value_5_8 = key_3, value_22
                            local value_8_4: string = "Frame"
                            local is_a_result = value_5_8:IsA(value_8_4)
                            if not is_a_result then
                                continue
                            end
                            local name_value_2 = value_5_8.Name
                            if name_value_2 == "Close" then
                                continue
                            end
                            local value_7_8 = captured_value_16
                            local value_6_12: boolean?
                            if value_5_8 ~= value_7_8 then
                                value_6_12 = false
                            else
                                value_6_12 = true
                            end
                            value_5_8.Visible = value_6_12
                        end
                        value_1_3 = captured_value_15
                        value_2_5 = true
                        value_1_3.Visible = value_2_5
                    end

                    return
                end
                captured_value_15, captured_value_16 = captured_value_9, cloned_value_2
                closure_ready = true
            end
            display_name_value:Connect(value_10_4)
            display_name_value = cloned_value_2.Actions.Play.Activated
            do
                local captured_value_17, captured_value_18, captured_value_19, captured_value_20, closure_ready_2
                value_10_4 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    local place_id_value_3 = captured_value_17.PlaceID
                    local value_2_6 = captured_value_18
                    local value_3_8: boolean = true
                    value_2_6.Visible = value_3_8
                    local value_2_7 = captured_value_19
                    local value_4_7 = captured_value_20
                    value_2_7:InvokeServer(value_4_7)

                    return
                end
                captured_value_17, captured_value_18, captured_value_19, captured_value_20 = value_5_7, captured_value_11, captured_value_12, value_4_5
                closure_ready_2 = true
            end
            display_name_value:Connect(value_10_4)
            display_name_value = cloned_value_2.Actions.Friends.Activated
            do
                local captured_value_21 = captured_value_13
                if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_21) then
                    value_10_4 = closure_cache[1]
                else
                    local closure_ready_3
                    value_10_4 = function(): ()
                        if not closure_ready_3 then
                            return
                        end
                        local value_1_5 = captured_value_21
                        local value_3_10: string = "FriendsOnline"
                        value_1_5:ToggleFrame(value_3_10)

                        return
                    end
                    closure_ready_3 = true
                    if closure_cache[1] == nil then
                        closure_cache[1] = value_10_4
                        closure_cache[2] = captured_value_21
                    end
                end
            end
            display_name_value:Connect(value_10_4)
            display_name_value = captured_value_14
            cloned_value.Parent = display_name_value
        end

        return
    end
end
local teleport_init_failed_value = teleport_service.TeleportInitFailed
local value_18: (() -> ())?
do
    local captured_value_22 = teleport_info_value
    value_18 = function(): ()
        local value_1_7 = captured_value_22
        local value_2_10: boolean = false
        value_1_7.Visible = value_2_10

        return
    end
end
teleport_init_failed_value:Connect(value_18)
local activated_value = overlay_value.Close.Button.Activated
local value_18_2: (() -> ())?
do
    local captured_value_23 = overlay_value
    value_18_2 = function(): ()
        local value_1_8 = captured_value_23
        local value_2_11: boolean = false
        value_1_8.Visible = value_2_11

        return
    end
end
activated_value:Connect(value_18_2)
local update_frames: (() -> ())?
do
    local captured_value_24, captured_value_25 = modes_child, update_frame
    update_frames = function(): ()
        local value_1_9, value_2_12, value_3_11 = captured_value_24:GetChildren()
        for key_5, value_24 in value_1_9, value_2_12, value_3_11 do
            local value_4_8, value_5_9 = key_5, value_24
            local value_8_5: string = "Frame"
            local is_a_result_2 = value_5_9:IsA(value_8_5)
            if not is_a_result_2 then
                continue
            end
            local value_6_14 = captured_value_25
            local value_7_10 = value_5_9
            value_6_14(value_7_10)
        end

        return
    end
end
local value_18_3: Instance? = parent_value
local value_19: string = "ModeBrowser"
local value_20: () -> () = update_frames
require_result:RegisterFrame(value_18_3, value_19, value_20)
local value_18_4: string = "Container"
local container_child_2 = parent_value:WaitForChild(value_18_4)
local value_18_5: string = "Title"
local title_child = container_child_2:WaitForChild(value_18_5)
local value_18_6: string = "Close"
local close_child = title_child:WaitForChild(value_18_6)
local value_18_7: string = "Button"
local activated_value_2 = close_child:WaitForChild(value_18_7).Activated
local value_18_8: (() -> ())?
do
    local captured_value_26 = parent_value
    value_18_8 = function(): ()
        local value_1_10: Instance? = captured_value_26
        local value_2_13: boolean = false
        value_1_10.Visible = value_2_13

        return
    end
end
activated_value_2:Connect(value_18_8)
setup_modes()
local updated_value = require_result_2.Updated
local value_18_9: () -> () = update_frames
updated_value:Connect(value_18_9)

return
