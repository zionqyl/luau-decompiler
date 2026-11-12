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
local value_3: string = "TextChatService"
if game_value:GetService(value_3).ChatVersion == Enum.ChatVersion.LegacyChatService then
    return
end
local require_value = require
local game_value_2: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_4)
local value_4_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_4_3))
local require_value_2 = require
local game_value_3: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_5)
local value_5_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_2)
local value_5_3: string = "CurrentRoundClient"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_5_3))
local game_value_4: DataModel = game
local value_5_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_5_4)
local value_5_5: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_5_5)
local value_4_9: boolean?
if game.GameId ~= 119460199 then
    value_4_9 = false
else
    value_4_9 = true
end
local replicated_storage_value = game.ReplicatedStorage
local game_value_7: DataModel = game
local value_8: string = "TextChatService"
local text_chat_service_2: Instance = game_value_7:GetService(value_8)
local game_value_8: DataModel = game
local value_9: string = "TextChatService"
local text_chat_service_3: Instance = game_value_8:GetService(value_9)
local local_player_value = game.Players.LocalPlayer
local players_value_2 = game.Players
local value_12: string = "TextChannels"
local text_channels_child: Instance? = text_chat_service_3:WaitForChild(value_12)
local value_13: string = "RBXSystem"
local rbx_system_child = text_channels_child:WaitForChild(value_13)
local value_14: string = "ChatInputBarConfiguration"
local value_10_2: Instance? = (text_chat_service_3:WaitForChild(value_14))
local script_value: LuaSourceContainer = script
local value_14_2: string = "SystemMessage"
local value_10_3: Instance? = (script_value:WaitForChild(value_14_2))
local game_value_11: DataModel = game
local value_14_3: string = "TextChatService"
local text_chat_service_4: Instance = game_value_11:GetService(value_14_3)
local value_14_4: string = "ChromaCommad"
local chroma_commad_child: Instance? = text_chat_service_4:WaitForChild(value_14_4)
local item_value = require_result.Item
local rarity_value = require_result.Rarity
do
    local captured_value = local_player_value
    local am_in_channel
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        am_in_channel = closure_cache[1]
    else
        local closure_ready
        am_in_channel = function(argument_1)
            if not closure_ready then
                return
            end
            local name_value = captured_value.Name

            return argument_1:FindFirstChild(name_value)
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = am_in_channel
            closure_cache[2] = captured_value
        end
    end
end
do
    local captured_value_2, captured_value_3 = players_value_2, require_result_2
    local is_player_alive
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) and same_capture(
        closure_cache[5],
        captured_value_3
    ) then
        is_player_alive = closure_cache[3]
    else
        local closure_ready_2
        is_player_alive = function(argument_1_2): (...boolean)
            if not closure_ready_2 then
                return
            end
            do
                local take_fallback = argument_1_2 == nil
                if not take_fallback then
                    local value_4_11 = captured_value_2
                    take_fallback = not (argument_1_2:IsDescendantOf(value_4_11))
                end
                if take_fallback then
                    return false
                end
            end
            if captured_value_3.PlayerData[argument_1_2.Name] == nil then
                return false
            end
            if captured_value_3.PlayerData[argument_1_2.Name].Dead == true then
                return false
            end

            return true
        end
        closure_ready_2 = true
        if closure_cache[3] == nil then
            closure_cache[3] = is_player_alive
            closure_cache[4], closure_cache[5] = captured_value_2, captured_value_3
        end
    end
end
do
    local captured_value_4, captured_value_5 = players_value_2, require_result_2
    local get_disguise_name
    if closure_cache[6] ~= nil and same_capture(closure_cache[7], captured_value_4) and same_capture(
        closure_cache[8],
        captured_value_5
    ) then
        get_disguise_name = closure_cache[6]
    else
        local closure_ready_3
        get_disguise_name = function(argument_1_3)
            if not closure_ready_3 then
                return
            end
            do
                local take_fallback_2 = argument_1_3 == nil
                if not take_fallback_2 then
                    local value_4_12 = captured_value_4
                    take_fallback_2 = not (argument_1_3:IsDescendantOf(value_4_12))
                end
                if take_fallback_2 then
                    return nil
                end
            end
            if captured_value_5.PlayerData[argument_1_3.Name] == nil then
                return nil
            end

            return captured_value_5.PlayerData[argument_1_3.Name].CodeName
        end
        closure_ready_3 = true
        if closure_cache[6] == nil then
            closure_cache[6] = get_disguise_name
            closure_cache[7], closure_cache[8] = captured_value_4, captured_value_5
        end
    end
end
do
    local captured_value_6, captured_value_7 = players_value_2, require_result_2
    local get_disguise_color
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_6) and same_capture(
        closure_cache[11],
        captured_value_7
    ) then
        get_disguise_color = closure_cache[9]
    else
        local closure_ready_4
        get_disguise_color = function(argument_1_4)
            if not closure_ready_4 then
                return
            end
            do
                local take_fallback_3 = argument_1_4 == nil
                if not take_fallback_3 then
                    local value_4_13 = captured_value_6
                    take_fallback_3 = not (argument_1_4:IsDescendantOf(value_4_13))
                end
                if take_fallback_3 then
                    return nil
                end
            end
            if captured_value_7.PlayerData[argument_1_4.Name] == nil then
                return nil
            end
            local value_2_22 = "ffffff"
            local color_value = captured_value_7.PlayerData[argument_1_4.Name].Color
            if color_value then
                value_2_22 = (color_value.Color:ToHex())
            end

            return value_2_22
        end
        closure_ready_4 = true
        if closure_cache[9] == nil then
            closure_cache[9] = get_disguise_color
            closure_cache[10], closure_cache[11] = captured_value_6, captured_value_7
        end
    end
end
do
    local captured_value_8, captured_value_9 = players_value_2, require_result_2
    local is_player_dead
    if closure_cache[12] ~= nil and same_capture(closure_cache[13], captured_value_8) and same_capture(
        closure_cache[14],
        captured_value_9
    ) then
        is_player_dead = closure_cache[12]
    else
        local closure_ready_5
        is_player_dead = function(argument_1_5)
            if not closure_ready_5 then
                return
            end
            local dead_value_2, is_descendant_of_result_4, name_value_8, name_value_9, player_data_value_7, player_data_value_8, value_2_23, value_3_20, value_4_17, value_4_18, value_5_10, value_5_9, value_6_2
            local control_state = 0
            while true do
                if control_state < 4 then
                    if control_state < 2 then
                        if control_state < 1 then
                            control_state = if argument_1_5 == nil then 2 else 1
                        else
                            value_6_2 = captured_value_8
                            is_descendant_of_result_4 = argument_1_5:IsDescendantOf(value_6_2)
                            control_state = if is_descendant_of_result_4 then 3 else 2
                        end
                    else
                        if control_state < 3 then
                            value_3_20 = false
                            control_state = 8
                        else
                            value_5_9 = captured_value_9
                            player_data_value_7 = value_5_9.PlayerData
                            name_value_8 = argument_1_5.Name
                            value_4_17 = player_data_value_7[name_value_8]
                            control_state = if value_4_17 ~= nil then 5 else 4
                        end
                    end
                else
                    if control_state < 6 then
                        if control_state < 5 then
                            value_3_20 = false
                            control_state = 8
                        else
                            value_5_10 = captured_value_9
                            player_data_value_8 = value_5_10.PlayerData
                            name_value_9 = argument_1_5.Name
                            value_4_18 = player_data_value_8[name_value_9]
                            dead_value_2 = value_4_18.Dead
                            control_state = if dead_value_2 ~= true then 7 else 6
                        end
                    else
                        if control_state < 7 then
                            value_3_20 = false
                            control_state = 8
                        else
                            if control_state < 8 then
                                value_3_20 = true
                                control_state = 8
                            else
                                value_2_23 = not value_3_20

                                return value_2_23
                            end
                        end
                    end
                end
            end
        end
        closure_ready_5 = true
        if closure_cache[12] == nil then
            closure_cache[12] = is_player_dead
            closure_cache[13], closure_cache[14] = captured_value_8, captured_value_9
        end
    end
end

local function color_text(argument_1_6, argument_2)
    return "<font color='#" .. argument_2 .. "'>" .. argument_1_6 .. "</font>"
end

local function get_chroma_tag(): string
    return ("<font color='#" .. (Color3.fromRGB(255, 0, 0):ToHex()) .. "'>" .. "C" .. "</font>") .. ("<font color='#" .. (Color3.fromRGB(
        255,
        100,
        0
    ):ToHex()) .. "'>" .. "h" .. "</font>") .. ("<font color='#" .. (Color3.fromRGB(255, 225, 0):ToHex()) .. "'>" .. "r" .. "</font>") .. ("<font color='#" .. (Color3.fromRGB(
        0,
        255,
        0
    ):ToHex()) .. "'>" .. "o" .. "</font>") .. ("<font color='#" .. (Color3.fromRGB(0, 255, 255):ToHex()) .. "'>" .. "m" .. "</font>") .. ("<font color='#" .. (Color3.fromRGB(
        0,
        125,
        255
    ):ToHex()) .. "'>" .. "a" .. "</font>") .. " "
end

local function is_whisper(argument_1_7): boolean
    local name_value_10 = argument_1_7.Name
    local value_4_26: number = 1
    local value_5_20: number = 10
    if (string.sub(name_value_10, value_4_26, value_5_20)) == "RBXWhisper" then
        return true
    end

    return false
end

local value_21
do
    local captured_value_10, captured_value_11, captured_value_12 = players_value_2, require_result_2, value_10_3
    if closure_cache[15] ~= nil and same_capture(closure_cache[16], captured_value_10) and same_capture(
        closure_cache[17],
        captured_value_11
    ) and same_capture(closure_cache[18], captured_value_12) then
        value_21 = closure_cache[15]
    else
        local closure_ready_6
        value_21 = function(argument_1_8)
            if not closure_ready_6 then
                return
            end
            local color_value_3, color_value_4, dead_value_3, dead_value_4, dead_value_5, dead_value_6, dead_value_7, elite_value, game_value_12, game_value_13, game_value_14, get_player_by_user_id_result, get_player_by_user_id_result_2, get_player_by_user_id_result_3, invalid_text_channel_permissions_value, is_descendant_of_result_10, is_descendant_of_result_11, is_descendant_of_result_5, is_descendant_of_result_6, is_descendant_of_result_7, is_descendant_of_result_8, is_descendant_of_result_9, local_player_value_2, name_value_11, name_value_12, name_value_13, name_value_14, name_value_15, name_value_16, name_value_17, name_value_18, name_value_19, name_value_20, name_value_21, name_value_22, name_value_23, name_value_24, name_value_25, name_value_26, name_value_27, new_result, new_value, player_data_value_10, player_data_value_11, player_data_value_12, player_data_value_13, player_data_value_14, player_data_value_15, player_data_value_16, player_data_value_17, player_data_value_18, player_data_value_19, player_data_value_20, player_data_value_21, player_data_value_22, player_data_value_9, players_value_3, players_value_4, players_value_5, prefix_text_value, prefix_text_value_2, prefix_text_value_3, split_result, split_value, sub_result_2, sub_result_3, sub_value_2, sub_value_3, table_9, text_channel_value, text_channel_value_2, text_source_value, text_source_value_2, text_source_value_3, to_hex_result_8, user_id_value, user_id_value_2, user_id_value_3, value_10_10, value_10_11, value_10_12, value_10_13, value_10_14, value_10_16, value_10_17, value_10_18, value_10_9, value_11_6, value_11_7, value_11_8, value_11_9, value_12_11, value_12_12, value_12_9, value_13_7, value_13_8, value_14_6, value_14_7, value_15, value_15_2, value_16, value_16_2, value_3_25, value_3_26, value_3_27, value_4_27, value_4_29, value_5_23, value_5_24, value_6_14, value_6_18, value_6_19, value_6_21, value_7_14, value_7_15, value_7_16, value_7_18, value_7_19, value_7_21, value_7_22, value_7_23, value_7_24, value_7_26, value_7_27, value_7_28, value_7_29, value_8_13, value_8_14, value_8_16, value_8_17, value_8_19, value_8_20, value_8_22, value_8_23, value_8_25, value_8_26, value_8_29, value_8_30, value_8_31: nil, value_8_32, value_8_33, value_9_11, value_9_12, value_9_14, value_9_15, value_9_16, value_9_18, value_9_19, value_9_21, value_9_22, value_9_23, value_9_25, value_9_26, value_9_27, value_9_28, value_9_29
            local control_state_2 = 0
            while true do
                if control_state_2 < 40 then
                    if control_state_2 < 20 then
                        if control_state_2 < 10 then
                            if control_state_2 < 5 then
                                if control_state_2 < 2 then
                                    if control_state_2 < 1 then
                                        new_value = Instance.new
                                        value_3_25 = "TextChatMessageProperties"
                                        new_result = new_value(value_3_25)
                                        text_source_value = argument_1_8.TextSource
                                        control_state_2 = if not text_source_value then 79 else 1
                                    else
                                        text_source_value_2 = argument_1_8.TextSource
                                        user_id_value = text_source_value_2.UserId
                                        game_value_12 = game
                                        players_value_3 = game_value_12.Players
                                        local_player_value_2 = players_value_3.LocalPlayer
                                        user_id_value_2 = local_player_value_2.UserId
                                        control_state_2 = if user_id_value ~= user_id_value_2 then 44 else 2
                                    end
                                else
                                    if control_state_2 < 3 then
                                        text_channel_value = argument_1_8.TextChannel
                                        name_value_11 = text_channel_value.Name
                                        value_7_14 = 1
                                        value_8_13 = 10
                                        sub_value_2 = string.sub
                                        sub_result_2 = sub_value_2(
                                            name_value_11,
                                            value_7_14,
                                            value_8_13
                                        )
                                        control_state_2 = if sub_result_2 ~= "RBXWhisper" then 4 else 3
                                    else
                                        if control_state_2 < 4 then
                                            value_3_26 = true
                                            control_state_2 = 5
                                        else
                                            value_3_26 = false
                                            control_state_2 = 5
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 7 then
                                    if control_state_2 < 6 then
                                        control_state_2 = if not value_3_26 then 44 else 6
                                    else
                                        split_value = string.split
                                        text_channel_value_2 = argument_1_8.TextChannel
                                        name_value_12 = text_channel_value_2.Name
                                        value_7_15 = 12
                                        sub_value_3 = string.sub
                                        sub_result_3 = sub_value_3(name_value_12, value_7_15)
                                        value_6_14 = "_"
                                        split_result = split_value(sub_result_3, value_6_14)
                                        game_value_13 = game
                                        players_value_4 = game_value_13.Players
                                        value_7_16 = split_result[1]
                                        get_player_by_user_id_result = players_value_4:GetPlayerByUserId(
                                            value_7_16
                                        )
                                        game_value_14 = game
                                        players_value_5 = game_value_14.Players
                                        value_8_14 = split_result[2]
                                        get_player_by_user_id_result_2 = players_value_5:GetPlayerByUserId(
                                            value_8_14
                                        )
                                        control_state_2 = if get_player_by_user_id_result == nil then 8 else 7
                                    end
                                else
                                    if control_state_2 < 8 then
                                        value_10_9 = captured_value_10
                                        is_descendant_of_result_5 = get_player_by_user_id_result:IsDescendantOf(
                                            value_10_9
                                        )
                                        control_state_2 = if is_descendant_of_result_5 then 9 else 8
                                    else
                                        if control_state_2 < 9 then
                                            value_7_18 = false
                                            control_state_2 = 14
                                        else
                                            value_9_11 = captured_value_11
                                            player_data_value_9 = value_9_11.PlayerData
                                            name_value_13 = get_player_by_user_id_result.Name
                                            value_8_16 = player_data_value_9[name_value_13]
                                            control_state_2 = if value_8_16 ~= nil then 11 else 10
                                        end
                                    end
                                end
                            end
                        else
                            if control_state_2 < 15 then
                                if control_state_2 < 12 then
                                    if control_state_2 < 11 then
                                        value_7_18 = false
                                        control_state_2 = 14
                                    else
                                        value_9_12 = captured_value_11
                                        player_data_value_10 = value_9_12.PlayerData
                                        name_value_14 = get_player_by_user_id_result.Name
                                        value_8_17 = player_data_value_10[name_value_14]
                                        dead_value_3 = value_8_17.Dead
                                        control_state_2 = if dead_value_3 ~= true then 13 else 12
                                    end
                                else
                                    if control_state_2 < 13 then
                                        value_7_18 = false
                                        control_state_2 = 14
                                    else
                                        if control_state_2 < 14 then
                                            value_7_18 = true
                                            control_state_2 = 14
                                        else
                                            control_state_2 = if not value_7_18 then 24 else 15
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 17 then
                                    if control_state_2 < 16 then
                                        control_state_2 = if get_player_by_user_id_result_2 == nil then 17 else 16
                                    else
                                        value_10_10 = captured_value_10
                                        is_descendant_of_result_6 = get_player_by_user_id_result_2:IsDescendantOf(
                                            value_10_10
                                        )
                                        control_state_2 = if is_descendant_of_result_6 then 18 else 17
                                    end
                                else
                                    if control_state_2 < 18 then
                                        value_7_19 = false
                                        control_state_2 = 23
                                    else
                                        if control_state_2 < 19 then
                                            value_9_14 = captured_value_11
                                            player_data_value_11 = value_9_14.PlayerData
                                            name_value_15 = get_player_by_user_id_result_2.Name
                                            value_8_19 = player_data_value_11[name_value_15]
                                            control_state_2 = if value_8_19 ~= nil then 20 else 19
                                        else
                                            value_7_19 = false
                                            control_state_2 = 23
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if control_state_2 < 30 then
                            if control_state_2 < 25 then
                                if control_state_2 < 22 then
                                    if control_state_2 < 21 then
                                        value_9_15 = captured_value_11
                                        player_data_value_12 = value_9_15.PlayerData
                                        name_value_16 = get_player_by_user_id_result_2.Name
                                        value_8_20 = player_data_value_12[name_value_16]
                                        dead_value_4 = value_8_20.Dead
                                        control_state_2 = if dead_value_4 ~= true then 22 else 21
                                    else
                                        value_7_19 = false
                                        control_state_2 = 23
                                    end
                                else
                                    if control_state_2 < 23 then
                                        value_7_19 = true
                                        control_state_2 = 23
                                    else
                                        if control_state_2 < 24 then
                                            value_4_27 = not value_7_19
                                            control_state_2 = if value_4_27 then 42 else 24
                                        else
                                            control_state_2 = if get_player_by_user_id_result_2 == nil then 26 else 25
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 27 then
                                    if control_state_2 < 26 then
                                        value_9_16 = captured_value_10
                                        is_descendant_of_result_7 = get_player_by_user_id_result_2:IsDescendantOf(
                                            value_9_16
                                        )
                                        control_state_2 = if is_descendant_of_result_7 then 27 else 26
                                    else
                                        value_4_27 = false
                                        control_state_2 = 32
                                    end
                                else
                                    if control_state_2 < 28 then
                                        value_8_22 = captured_value_11
                                        player_data_value_13 = value_8_22.PlayerData
                                        name_value_17 = get_player_by_user_id_result_2.Name
                                        value_7_21 = player_data_value_13[name_value_17]
                                        control_state_2 = if value_7_21 ~= nil then 29 else 28
                                    else
                                        if control_state_2 < 29 then
                                            value_4_27 = false
                                            control_state_2 = 32
                                        else
                                            value_8_23 = captured_value_11
                                            player_data_value_14 = value_8_23.PlayerData
                                            name_value_18 = get_player_by_user_id_result_2.Name
                                            value_7_22 = player_data_value_14[name_value_18]
                                            dead_value_5 = value_7_22.Dead
                                            control_state_2 = if dead_value_5 ~= true then 31 else 30
                                        end
                                    end
                                end
                            end
                        else
                            if control_state_2 < 35 then
                                if control_state_2 < 32 then
                                    if control_state_2 < 31 then
                                        value_4_27 = false
                                        control_state_2 = 32
                                    else
                                        value_4_27 = true
                                        control_state_2 = 32
                                    end
                                else
                                    if control_state_2 < 33 then
                                        control_state_2 = if not value_4_27 then 42 else 33
                                    else
                                        if control_state_2 < 34 then
                                            control_state_2 = if get_player_by_user_id_result == nil then 35 else 34
                                        else
                                            value_10_11 = captured_value_10
                                            is_descendant_of_result_8 = get_player_by_user_id_result:IsDescendantOf(
                                                value_10_11
                                            )
                                            control_state_2 = if is_descendant_of_result_8 then 36 else 35
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 37 then
                                    if control_state_2 < 36 then
                                        value_7_23 = false
                                        control_state_2 = 41
                                    else
                                        value_9_18 = captured_value_11
                                        player_data_value_15 = value_9_18.PlayerData
                                        name_value_19 = get_player_by_user_id_result.Name
                                        value_8_25 = player_data_value_15[name_value_19]
                                        control_state_2 = if value_8_25 ~= nil then 38 else 37
                                    end
                                else
                                    if control_state_2 < 38 then
                                        value_7_23 = false
                                        control_state_2 = 41
                                    else
                                        if control_state_2 < 39 then
                                            value_9_19 = captured_value_11
                                            player_data_value_16 = value_9_19.PlayerData
                                            name_value_20 = get_player_by_user_id_result.Name
                                            value_8_26 = player_data_value_16[name_value_20]
                                            dead_value_6 = value_8_26.Dead
                                            control_state_2 = if dead_value_6 ~= true then 40 else 39
                                        else
                                            value_7_23 = false
                                            control_state_2 = 41
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if control_state_2 < 60 then
                        if control_state_2 < 50 then
                            if control_state_2 < 45 then
                                if control_state_2 < 42 then
                                    if control_state_2 < 41 then
                                        value_7_23 = true
                                        control_state_2 = 41
                                    else
                                        value_4_27 = not value_7_23
                                        control_state_2 = 42
                                    end
                                else
                                    if control_state_2 < 43 then
                                        control_state_2 = if not value_4_27 then 44 else 43
                                    else
                                        if control_state_2 < 44 then
                                            value_7_24 = captured_value_12
                                            table_9 = {
                                                text = "You cannot whisper remaining players while eliminated.",
                                            }
                                            value_7_24:Fire(table_9)
                                            invalid_text_channel_permissions_value = Enum.TextChatMessageStatus.InvalidTextChannelPermissions
                                            argument_1_8.Status = invalid_text_channel_permissions_value

                                            return new_result
                                        else
                                            value_3_27 = captured_value_10
                                            text_source_value_3 = argument_1_8.TextSource
                                            user_id_value_3 = text_source_value_3.UserId
                                            get_player_by_user_id_result_3 = value_3_27:GetPlayerByUserId(
                                                user_id_value_3
                                            )
                                            control_state_2 = if get_player_by_user_id_result_3 then 46 else 45
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 47 then
                                    if control_state_2 < 46 then
                                        return new_result
                                    else
                                        control_state_2 = if get_player_by_user_id_result_3 == nil then 48 else 47
                                    end
                                else
                                    if control_state_2 < 48 then
                                        value_7_26 = captured_value_10
                                        is_descendant_of_result_9 = get_player_by_user_id_result_3:IsDescendantOf(
                                            value_7_26
                                        )
                                        control_state_2 = if is_descendant_of_result_9 then 49 else 48
                                    else
                                        if control_state_2 < 49 then
                                            value_4_29 = false
                                            control_state_2 = 54
                                        else
                                            value_6_18 = captured_value_11
                                            player_data_value_17 = value_6_18.PlayerData
                                            name_value_21 = get_player_by_user_id_result_3.Name
                                            value_5_23 = player_data_value_17[name_value_21]
                                            control_state_2 = if value_5_23 ~= nil then 51 else 50
                                        end
                                    end
                                end
                            end
                        else
                            if control_state_2 < 55 then
                                if control_state_2 < 52 then
                                    if control_state_2 < 51 then
                                        value_4_29 = false
                                        control_state_2 = 54
                                    else
                                        value_6_19 = captured_value_11
                                        player_data_value_18 = value_6_19.PlayerData
                                        name_value_22 = get_player_by_user_id_result_3.Name
                                        value_5_24 = player_data_value_18[name_value_22]
                                        dead_value_7 = value_5_24.Dead
                                        control_state_2 = if dead_value_7 ~= true then 53 else 52
                                    end
                                else
                                    if control_state_2 < 53 then
                                        value_4_29 = false
                                        control_state_2 = 54
                                    else
                                        if control_state_2 < 54 then
                                            value_4_29 = true
                                            control_state_2 = 54
                                        else
                                            value_7_27 = "Elite"
                                            elite_value = get_player_by_user_id_result_3:GetAttribute(
                                                value_7_27
                                            )
                                            name_value_23 = get_player_by_user_id_result_3.Name
                                            control_state_2 = if get_player_by_user_id_result_3 == nil then 56 else 55
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 57 then
                                    if control_state_2 < 56 then
                                        value_10_12 = captured_value_10
                                        is_descendant_of_result_10 = get_player_by_user_id_result_3:IsDescendantOf(
                                            value_10_12
                                        )
                                        control_state_2 = if is_descendant_of_result_10 then 57 else 56
                                    else
                                        value_7_28 = nil
                                        control_state_2 = 60
                                    end
                                else
                                    if control_state_2 < 58 then
                                        value_9_21 = captured_value_11
                                        player_data_value_19 = value_9_21.PlayerData
                                        name_value_24 = get_player_by_user_id_result_3.Name
                                        value_8_29 = player_data_value_19[name_value_24]
                                        control_state_2 = if value_8_29 ~= nil then 59 else 58
                                    else
                                        if control_state_2 < 59 then
                                            value_7_28 = nil
                                            control_state_2 = 60
                                        else
                                            value_8_30 = captured_value_11
                                            player_data_value_20 = value_8_30.PlayerData
                                            name_value_25 = get_player_by_user_id_result_3.Name
                                            value_7_29 = player_data_value_20[name_value_25]
                                            value_7_28 = value_7_29.CodeName
                                            control_state_2 = 60
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if control_state_2 < 70 then
                            if control_state_2 < 65 then
                                if control_state_2 < 62 then
                                    if control_state_2 < 61 then
                                        value_8_31 = nil
                                        control_state_2 = if not value_7_28 then 64 else 61
                                    else
                                        control_state_2 = if not value_4_29 then 63 else 62
                                    end
                                else
                                    if control_state_2 < 63 then
                                        value_8_32 = value_7_28
                                        control_state_2 = 65
                                    else
                                        if control_state_2 < 64 then
                                            value_9_22 = name_value_23
                                            value_10_13 = " ("
                                            value_11_6 = value_7_28
                                            value_12_9 = ")"
                                            value_8_32 = value_9_22 .. value_10_13 .. value_11_6 .. value_12_9
                                            control_state_2 = 65
                                        else
                                            value_8_32 = name_value_23
                                            control_state_2 = 65
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 67 then
                                    if control_state_2 < 66 then
                                        value_10_14 = value_8_32
                                        value_11_7 = ":"
                                        value_9_23 = value_10_14 .. value_11_7
                                        argument_1_8.PrefixText = value_9_23
                                        value_8_33 = "ffffff"
                                        value_6_21 = "a3a2a5"
                                        control_state_2 = if not value_7_28 then 74 else 66
                                    else
                                        control_state_2 = if get_player_by_user_id_result_3 == nil then 68 else 67
                                    end
                                else
                                    if control_state_2 < 68 then
                                        value_11_8 = captured_value_10
                                        is_descendant_of_result_11 = get_player_by_user_id_result_3:IsDescendantOf(
                                            value_11_8
                                        )
                                        control_state_2 = if is_descendant_of_result_11 then 69 else 68
                                    else
                                        if control_state_2 < 69 then
                                            value_8_33 = nil
                                            control_state_2 = 76
                                        else
                                            value_10_16 = captured_value_11
                                            player_data_value_21 = value_10_16.PlayerData
                                            name_value_26 = get_player_by_user_id_result_3.Name
                                            value_9_25 = player_data_value_21[name_value_26]
                                            control_state_2 = if value_9_25 ~= nil then 71 else 70
                                        end
                                    end
                                end
                            end
                        else
                            if control_state_2 < 75 then
                                if control_state_2 < 72 then
                                    if control_state_2 < 71 then
                                        value_8_33 = nil
                                        control_state_2 = 76
                                    else
                                        value_9_26 = "ffffff"
                                        value_11_9 = captured_value_11
                                        player_data_value_22 = value_11_9.PlayerData
                                        name_value_27 = get_player_by_user_id_result_3.Name
                                        value_10_17 = player_data_value_22[name_value_27]
                                        color_value_3 = value_10_17.Color
                                        control_state_2 = if not color_value_3 then 73 else 72
                                    end
                                else
                                    if control_state_2 < 73 then
                                        color_value_4 = color_value_3.Color
                                        to_hex_result_8 = color_value_4:ToHex()
                                        value_9_26 = to_hex_result_8
                                        control_state_2 = 73
                                    else
                                        if control_state_2 < 74 then
                                            value_8_33 = value_9_26
                                            control_state_2 = 76
                                        else
                                            control_state_2 = if not elite_value then 76 else 75
                                        end
                                    end
                                end
                            else
                                if control_state_2 < 77 then
                                    if control_state_2 < 76 then
                                        value_10_18 = "[ELITE] "
                                        prefix_text_value = argument_1_8.PrefixText
                                        value_9_27 = value_10_18 .. prefix_text_value
                                        argument_1_8.PrefixText = value_9_27
                                        value_8_33 = "e82a2a"
                                        value_6_21 = "bf5f5f"
                                        control_state_2 = 76
                                    else
                                        control_state_2 = if not value_4_29 then 78 else 77
                                    end
                                else
                                    if control_state_2 < 78 then
                                        prefix_text_value_2 = argument_1_8.PrefixText
                                        value_12_11 = "<font color='#"
                                        value_13_7 = value_8_33
                                        value_14_6 = "'>"
                                        value_15 = prefix_text_value_2
                                        value_16 = "</font>"
                                        value_9_28 = value_12_11 .. value_13_7 .. value_14_6 .. value_15 .. value_16
                                        argument_1_8.PrefixText = value_9_28

                                        return new_result
                                    else
                                        if control_state_2 < 79 then
                                            prefix_text_value_3 = argument_1_8.PrefixText
                                            value_12_12 = "<font color='#"
                                            value_13_8 = value_6_21
                                            value_14_7 = "'>"
                                            value_15_2 = prefix_text_value_3
                                            value_16_2 = "</font>"
                                            value_9_29 = value_12_12 .. value_13_8 .. value_14_7 .. value_15_2 .. value_16_2
                                            argument_1_8.PrefixText = value_9_29
                                            control_state_2 = 79
                                        else
                                            return new_result
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        closure_ready_6 = true
        if closure_cache[15] == nil then
            closure_cache[15] = value_21
            closure_cache[16], closure_cache[17], closure_cache[18] = captured_value_10, captured_value_11, captured_value_12
        end
    end
end
text_chat_service_3.OnIncomingMessage = value_21
local get_colored_item_text
do
    local captured_value_13, captured_value_14, captured_value_15 = require_result, rarity_value, get_chroma_tag
    if closure_cache[19] ~= nil and same_capture(closure_cache[20], captured_value_13) and same_capture(
        closure_cache[21],
        captured_value_14
    ) and same_capture(closure_cache[22], captured_value_15) then
        get_colored_item_text = closure_cache[19]
    else
        local closure_ready_7
        get_colored_item_text = function(argument_1_9)
            if not closure_ready_7 then
                return
            end
            local value_2_28 = captured_value_13.Item[argument_1_9]
            if not value_2_28 then
                value_2_28 = captured_value_13.Pets[argument_1_9]
            end
            if not value_2_28 then
                local warn_value = warn
                local value_5_26: string = "ItemData not found for: "
                local value_7_30 = argument_1_9
                warn_value(value_5_26 .. (tostring(value_7_30)))

                return argument_1_9
            end
            local to_hex_result_9 = captured_value_14[value_2_28.Rarity]:ToHex()
            local item_name_value = value_2_28.ItemName or value_2_28.Name
            local chroma_value = value_2_28.Chroma
            local value_5_30: string?
            do
                local take_fallback_4 = not chroma_value
                if not take_fallback_4 then
                    value_5_30 = captured_value_15()
                    take_fallback_4 = not value_5_30
                end
                if take_fallback_4 then
                    value_5_30 = ""
                end
            end

            return value_5_30 .. "<font color='#" .. to_hex_result_9 .. "'>" .. item_name_value .. "</font>"
        end
        closure_ready_7 = true
        if closure_cache[19] == nil then
            closure_cache[19] = get_colored_item_text
            closure_cache[20], closure_cache[21], closure_cache[22] = captured_value_13, captured_value_14, captured_value_15
        end
    end
end
local replicate_message
do
    local captured_value_16, captured_value_17 = get_colored_item_text, rbx_system_child
    if closure_cache[23] ~= nil and same_capture(closure_cache[24], captured_value_16) and same_capture(
        closure_cache[25],
        captured_value_17
    ) then
        replicate_message = closure_cache[23]
    else
        local closure_ready_8
        replicate_message = function(argument_1_10)
            if not closure_ready_8 then
                return
            end
            local text_value = argument_1_10.text
            if argument_1_10.item then
                text_value = text_value .. " " .. (captured_value_16(argument_1_10.item))
            end
            local value_3_32 = captured_value_17
            local value_5_33 = text_value
            value_3_32:DisplaySystemMessage(value_5_33)

            return
        end
        closure_ready_8 = true
        if closure_cache[23] == nil then
            closure_cache[23] = replicate_message
            closure_cache[24], closure_cache[25] = captured_value_16, captured_value_17
        end
    end
end
local triggered_value = chroma_commad_child.Triggered

local function value_24(): ()
    game.Players.LocalPlayer.PlayerScripts.WeaponVisuals.ChromaScript.ToggleChromas:Fire()

    return
end

triggered_value:Connect(value_24)
triggered_value = value_10_3.Event
do
    local captured_value_18, captured_value_19 = get_colored_item_text, rbx_system_child
    if closure_cache[26] ~= nil and same_capture(closure_cache[27], captured_value_18) and same_capture(
        closure_cache[28],
        captured_value_19
    ) then
        value_24 = closure_cache[26]
    else
        local closure_ready_10
        value_24 = function(argument_1_11)
            if not closure_ready_10 then
                return
            end
            local defer_value = task.defer
            local value_3_34: (() -> ())?
            do
                local captured_value_20, captured_value_21, captured_value_22, closure_ready_9
                value_3_34 = function(): ()
                    if not closure_ready_9 then
                        return
                    end
                    local value_1_4 = captured_value_20
                    local text_value_2 = value_1_4.text
                    if value_1_4.item then
                        text_value_2 = text_value_2 .. " " .. (captured_value_21(value_1_4.item))
                    end
                    local value_3_36 = captured_value_22
                    local value_5_36 = text_value_2
                    value_3_36:DisplaySystemMessage(value_5_36)

                    return
                end
                captured_value_20, captured_value_21, captured_value_22 = argument_1_11, captured_value_18, captured_value_19
                closure_ready_9 = true
            end
            defer_value(value_3_34)

            return
        end
        closure_ready_10 = true
        if closure_cache[26] == nil then
            closure_cache[26] = value_24
            closure_cache[27], closure_cache[28] = captured_value_18, captured_value_19
        end
    end
end
triggered_value:Connect(value_24)
triggered_value = replicated_storage_value.ChatMessage.OnClientEvent
value_24 = replicate_message
triggered_value:Connect(value_24)
value_24 = "Extras"
triggered_value = remotes_child:WaitForChild(value_24)
value_24 = "GetAvailableCommands"
triggered_value = (triggered_value:WaitForChild(value_24):InvokeServer())
local value_23: nil = nil
value_24 = nil
for key, value in triggered_value, value_23, value_24 do
    local value_25, value_26 = key, value
    local value_29 = value_26
    local wait_for_child_result: Instance? = text_chat_service_2:WaitForChild(value_29)
    local value_5_6: Instance? = wait_for_child_result
    local value_29_2: string = "TestingServerCommand"
    local testing_server_command_value = value_5_6:GetAttribute(value_29_2)
    if testing_server_command_value ~= true then
        local value_27_3: boolean = true
        value_5_6.AutocompleteVisible = value_27_3
        local value_27_4: boolean = true
        value_5_6.Enabled = value_27_4
    else
        if value_4_9 then
            local value_27_5: boolean = true
            value_5_6.AutocompleteVisible = value_27_5
            local value_27_6: boolean = true
            value_5_6.Enabled = value_27_6
        else
            local value_27_7: boolean = false
            value_5_6.Enabled = value_27_7
            local value_27_8: boolean = false
            value_5_6.AutocompleteVisible = value_27_8
        end
    end
end

return
