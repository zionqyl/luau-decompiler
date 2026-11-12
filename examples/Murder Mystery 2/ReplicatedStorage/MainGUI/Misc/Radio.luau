--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function shared_function(argument_1_2)
    local value_3_12 = argument_1_2
    if (tonumber(value_3_12)) then
        local value_3_13 = argument_1_2
        if (tonumber(value_3_13)) < 126 then
            local value_4_14 = argument_1_2
            local tonumber_result_3 = tonumber(value_4_14)

            return (string.char(tonumber_result_3))
        end
    end

    return ""
end

local function shared_function_2(argument_1_3)
    local value_3_15 = argument_1_3
    if (tonumber(value_3_15)) then
        local value_3_16 = argument_1_3
        if (tonumber(value_3_16)) < 126 then
            local value_4_15 = argument_1_3
            local tonumber_result_6 = tonumber(value_4_15)

            return (string.char(tonumber_result_6))
        end
    end

    return ""
end

local function shared_function_3(argument_1_4)
    local value_3_18 = argument_1_4
    local byte_result = string.byte(value_3_18)
    if byte_result then
        if byte_result < 126 then
            return argument_1_4
        end
    end

    return ""
end

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

local parent_value_2 = script.Parent.Parent
local value_3: string = "Game"
local game_child = parent_value_2:WaitForChild(value_3)
local value_4: string = "Settings"
local settings_child = game_child:WaitForChild(value_4)
local value_4_2: string = "Radio"
local radio_child = settings_child:WaitForChild(value_4_2)
local require_value = require
local game_value: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local radio_value = game_child.Radio
local value_7 = radio_value
local value_8: string = "Radio"
require_result:RegisterFrame(value_7, value_8)
local local_player_value = game.Players.LocalPlayer
local value_7_2: string = "Radio"
local value_1_2 = (local_player_value:GetAttribute(value_7_2))
local require_result_2 = require(game.ReplicatedStorage.Modules.AudioSearcher)
local value_5_6: boolean = true
if game.PlaceId ~= 335132309 then
    if game.PlaceId ~= 333740520 then
        value_5_6 = false
    else
        value_5_6 = true
    end
end
local value_6_6: boolean = true
if game.PlaceId ~= 5895823254 then
    if game.PlaceId ~= 5928494131 then
        value_6_6 = false
    else
        value_6_6 = true
    end
end
local scroll_frame_value = radio_value.Main.MySongs.ScrollFrame
local adder_value = radio_value.Main.MySongs.Adder
local search_value = radio_value.Main.Search
local scroll_frame_value_2 = radio_value.Main.Search.ScrollFrame
local searcher_value = radio_value.Main.Search.Searcher

local function unescape_2(argument_1)
    local value_1_3 = (string.gsub(argument_1, "&lt;", "<"))
    local value_1_4 = (string.gsub(value_1_3, "&gt;", ">"))
    local value_1_5 = (string.gsub(value_1_4, "&quot;", "\""))
    local value_1_6 = (string.gsub(value_1_5, "&apos;", "'"))
    local value_1_7 = (string.gsub(value_1_6, "&#(%d+);", shared_function))
    local value_1_8 = (string.gsub(value_1_7, "&#x(%d+);", shared_function_2))
    local value_1_9 = (string.gsub(value_1_8, ".", shared_function_3))

    return (string.gsub(value_1_9, "&amp;", "&"))
end

unescape = unescape_2
local table_13
if not value_5_6 then
    if not value_6_6 then
        table_13 = {nil}
        local game_value_8 = game.ReplicatedStorage.Remotes.Extras.GetData
        local value_16 = "RadioSongs"
        table_13 = {game_value_8:InvokeServer(value_16)}
        local unpack_result = unpack(table_13)
        table_13 = pairs
        game_value_8 = radio_value.Nav
        local value_15
        table_13, game_value_8, value_15 = (function(...)
            return table_13(...)
        end)(game_value_8:GetChildren())
        local value_17
        for key_3, value_10 in table_13, game_value_8, value_15 do
            value_16, value_17 = key_3, value_10
            local mouse_button1_click_value = value_17.MouseButton1Click
            local value_20
            do
                local captured_value, captured_value_2, closure_ready
                value_20 = function(): ()
                    if not closure_ready then
                        return
                    end
                    script.Preview:Stop()
                    local script_value_2 = script.Preview
                    local value_2_6 = ""
                    script_value_2.SoundId = value_2_6
                    local value_3_21
                    script_value_2, value_2_6, value_3_21 = pairs(captured_value.Nav:GetChildren())
                    local value_4_16, value_5_15
                    for key, value in script_value_2, value_2_6, value_3_21 do
                        value_4_16, value_5_15 = key, value
                        local value_7_3 = captured_value_2
                        local roblox_round_default_button_value
                        do
                            local take_fallback = value_5_15 ~= value_7_3
                            if not take_fallback then
                                roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundDefaultButton
                                take_fallback = not roblox_round_default_button_value
                            end
                            if take_fallback then
                                roblox_round_default_button_value = Enum.ButtonStyle.RobloxRoundButton
                            end
                        end
                        value_5_15.Style = roblox_round_default_button_value
                    end
                    script_value_2, value_2_6, value_3_21 = pairs(captured_value.Main:GetChildren())
                    for key_2, value_9 in script_value_2, value_2_6, value_3_21 do
                        value_4_16, value_5_15 = key_2, value_9
                        local name_value = value_5_15.Name
                        local value_8_2 = captured_value_2
                        local name_value_2 = value_8_2.Name
                        local value_6_7: boolean?
                        if name_value ~= name_value_2 then
                            value_6_7 = false
                        else
                            value_6_7 = true
                        end
                        value_5_15.Visible = value_6_7
                    end

                    return
                end
                captured_value, captured_value_2 = radio_value, value_17
                closure_ready = true
            end
            mouse_button1_click_value:connect(value_20)
        end
        table_13 = false
        game_value_8 = game.ReplicatedStorage.Remotes.Gameplay.RoleSelect.OnClientEvent
        do
            local closure_ready_2
            value_16 = function<T1, T2, T3, T4>(argument_1_5: T1, argument_2: T2, argument_3: T3, argument_4: T4): ()
                if not closure_ready_2 then
                    return
                end
                table_13 = true

                return
            end
            closure_ready_2 = true
        end
        game_value_8:connect(value_16)
        game_value_8 = game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent
        do
            local closure_ready_3
            value_16 = function(): ()
                if not closure_ready_3 then
                    return
                end
                table_13 = true

                return
            end
            closure_ready_3 = true
        end
        game_value_8:connect(value_16)
        do
            local captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7, closure_ready_6
            game_value_8 = function(): ()
                if not closure_ready_6 then
                    return
                end
                captured_value_3:ClearAllChildren()
                local value_1_12, value_2_7, value_3_22 = pairs(captured_value_4)
                for key_4, value_13 in value_1_12, value_2_7, value_3_22 do
                    local value_4_17, value_5_17 = key_4, value_13
                    local script_value_3: LuaSourceContainer = script
                    local song_value = script_value_3.Song
                    local cloned_value = song_value:Clone()
                    local container_value = cloned_value.Container
                    local song_name_value = container_value.SongName
                    local name_value_3 = value_5_17.Name
                    song_name_value.Text = name_value_3
                    local container_value_2 = cloned_value.Container
                    local play_value = container_value_2.Play
                    local mouse_button1_click_value_2 = play_value.MouseButton1Click
                    local value_9_2: (() -> ())?
                    do
                        local captured_value_8, captured_value_9, captured_value_10, closure_ready_4
                        value_9_2 = function(): ()
                            if not closure_ready_4 then
                                return
                            end
                            if table_13 then
                                if game.Players.LocalPlayer.Character then
                                    if 0 < game.Players.LocalPlayer.Character.Humanoid.Health then
                                        if captured_value_8 then
                                            local play_song_value = game.ReplicatedStorage.Remotes.Inventory.PlaySong
                                            local id_value = captured_value_9.ID
                                            play_song_value:FireServer(id_value)

                                            return
                                        end
                                        game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()

                                        return
                                    end
                                end
                            end
                            local wait_value = captured_value_10.Main.MySongs.Wait
                            local value_2_11: boolean = true
                            wait_value.Visible = value_2_11
                            wait(2)
                            local wait_value_3 = captured_value_10.Main.MySongs.Wait
                            local value_2_13: boolean = false
                            wait_value_3.Visible = value_2_13

                            return
                        end
                        captured_value_8, captured_value_9, captured_value_10 = captured_value_5, value_5_17, captured_value_6
                        closure_ready_4 = true
                    end
                    mouse_button1_click_value_2:connect(value_9_2)
                    local container_value_3 = cloned_value.Container
                    local delete_value = container_value_3.Delete
                    local mouse_button1_click_value_3 = delete_value.MouseButton1Click
                    local value_9_3: (() -> ())?
                    do
                        local captured_value_11, captured_value_12, captured_value_13, closure_ready_5
                        value_9_3 = function(): ()
                            if not closure_ready_5 then
                                return
                            end
                            table.remove(captured_value_11, captured_value_12)
                            local remove_song_value = game.ReplicatedStorage.Remotes.Inventory.RemoveSong
                            local value_3_25 = captured_value_12
                            remove_song_value:FireServer(value_3_25)
                            captured_value_13()

                            return
                        end
                        captured_value_11, captured_value_12, captured_value_13 = captured_value_4, value_4_17, captured_value_7
                        closure_ready_5 = true
                    end
                    mouse_button1_click_value_3:connect(value_9_3)
                    local new_value: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
                    local value_8_5: number = 0
                    local value_9_4: number = 0
                    local value_10_2: number = 0
                    local value_12 = value_4_17 - 1
                    local size_value = cloned_value.Size
                    local y_value = size_value.Y
                    local offset_value = y_value.Offset
                    local value_11 = value_12 * offset_value
                    local new_result = new_value(value_8_5, value_9_4, value_10_2, value_11)
                    cloned_value.Position = new_result
                    local value_7_7 = captured_value_3
                    cloned_value.Parent = value_7_7
                end

                return
            end
            captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7 = scroll_frame_value, unpack_result, value_1_2, radio_value, game_value_8
            closure_ready_6 = true
        end
        do
            local captured_value_14, captured_value_15, captured_value_16 = unpack_result, game_value_8, adder_value
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_14) and same_capture(
                closure_cache[3],
                captured_value_15
            ) and same_capture(closure_cache[4], captured_value_16) then
                value_15 = closure_cache[1]
            else
                local closure_ready_8
                value_15 = function(argument_1_6, argument_2_2): ()
                    if not closure_ready_8 then
                        return
                    end
                    local value_3_26 = nil
                    local pcall_value_2, value_5_18
                    if argument_2_2 == nil then
                        do
                            local captured_value_17, closure_ready_7
                            value_5_18 = function(): ()
                                if not closure_ready_7 then
                                    return
                                end
                                local value_2_16 = captured_value_17
                                if (tonumber(value_2_16)) then
                                    local game_value_14: DataModel = game
                                    local value_3_27: string = "MarketplaceService"
                                    local marketplace_service: Instance = game_value_14:GetService(
                                        value_3_27
                                    )
                                    local value_3_28 = captured_value_17
                                    local get_product_info_result = marketplace_service:GetProductInfo(
                                        value_3_28
                                    )
                                    if get_product_info_result then
                                        if get_product_info_result.AssetTypeId == 3 then
                                            value_3_26 = "https://www.roblox.com/asset/?id=" .. captured_value_17
                                            argument_2_2 = (unescape(get_product_info_result.Name))
                                        end
                                    end
                                end

                                return
                            end
                            captured_value_17 = argument_1_6
                            closure_ready_7 = true
                        end
                        pcall_value_2 = pcall
                        pcall_value_2(value_5_18)
                    else
                        pcall_value_2 = "https://www.roblox.com/asset/?id="
                        value_5_18 = argument_1_6
                        value_3_26 = pcall_value_2 .. value_5_18
                    end
                    if value_3_26 then
                        local value_6_9
                        pcall_value_2, value_5_18, value_6_9 = pairs(captured_value_14)
                        local value_7_8
                        for key_5, value_14 in pcall_value_2, value_5_18, value_6_9 do
                            local value_8_6
                            value_7_8, value_8_6 = key_5, value_14
                            local id_value_2 = value_8_6.ID
                            if id_value_2 ~= value_3_26 then
                                continue
                            end

                            return
                        end
                        value_5_18 = captured_value_14
                        value_6_9 = 1
                        value_7_8 = {ID = 0, Name = 0}
                        value_7_8.ID = value_3_26
                        value_7_8.Name = argument_2_2
                        table.insert(value_5_18, value_6_9, value_7_8)
                        if 30 <= #captured_value_14 then
                            table.remove(captured_value_14, 30)
                        end
                        pcall_value_2 = game.ReplicatedStorage.Remotes.Inventory.SaveSong
                        value_6_9 = value_3_26
                        value_7_8 = argument_2_2
                        pcall_value_2:FireServer(value_6_9, value_7_8)
                        captured_value_15()
                    else
                        pcall_value_2 = captured_value_16.ID
                        value_5_18 = "Invalid ID!"
                        pcall_value_2.Text = value_5_18
                    end

                    return
                end
                closure_ready_8 = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_15
                    closure_cache[2], closure_cache[3], closure_cache[4] = captured_value_14, captured_value_15, captured_value_16
                end
            end
        end
        value_16 = radio_child.Button.Activated
        local value_18_2
        do
            local captured_value_18 = require_result
            if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_18) then
                value_18_2 = closure_cache[5]
            else
                local closure_ready_9
                value_18_2 = function(): ()
                    if not closure_ready_9 then
                        return
                    end
                    local value_1_23 = captured_value_18
                    local value_3_30: string = "Radio"
                    value_1_23:ToggleFrame(value_3_30)

                    return
                end
                closure_ready_9 = true
                if closure_cache[5] == nil then
                    closure_cache[5] = value_18_2
                    closure_cache[6] = captured_value_18
                end
            end
        end
        value_16:Connect(value_18_2)
        do
            local captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24 = value_1_2, search_value, searcher_value, scroll_frame_value_2, unpack_result, value_15
            if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_19) and same_capture(
                closure_cache[11],
                captured_value_20
            ) and same_capture(closure_cache[12], captured_value_21) and same_capture(
                closure_cache[13],
                captured_value_22
            ) and same_capture(closure_cache[14], captured_value_23) and same_capture(
                closure_cache[15],
                captured_value_24
            ) then
                value_16 = closure_cache[9]
            else
                local closure_ready_13
                value_16 = function(argument_1_7)
                    if not closure_ready_13 then
                        return
                    end
                    local container_value_4 = {}
                    if not captured_value_19 then
                        if not argument_1_7 then
                            return
                        end
                    end
                    script.Preview:Stop()
                    local value_2_21 = script.Preview
                    local value_3_31 = ""
                    value_2_21.SoundId = value_3_31
                    local value_4_19
                    value_2_21, value_3_31, value_4_19 = pairs(captured_value_20:GetChildren())
                    local name_value_5, value_5_19, value_6_10
                    for key_6, value_21 in value_2_21, value_3_31, value_4_19 do
                        value_5_19, value_6_10 = key_6, value_21
                        if value_6_10.Name == "Searcher" then
                            continue
                        end
                        name_value_5 = false
                        value_6_10.Visible = name_value_5
                    end
                    value_2_21 = captured_value_20.Processing
                    value_3_31 = true
                    value_2_21.Visible = value_3_31
                    value_2_21 = captured_value_20.Processing
                    value_3_31 = "Searching."
                    value_2_21.Text = value_3_31
                    value_2_21 = spawn
                    do
                        local captured_value_25 = captured_value_20
                        if closure_cache[7] ~= nil and same_capture(
                            closure_cache[8],
                            captured_value_25
                        ) then
                            value_3_31 = closure_cache[7]
                        else
                            local closure_ready_10
                            value_3_31 = function(): ()
                                if not closure_ready_10 then
                                    return
                                end
                                local value_1_25: number = 1
                                while true do
                                    if not captured_value_25.Processing.Visible then
                                        break
                                    end
                                    local value_2_22 = captured_value_25.Processing
                                    local value_3_32: number | string = "Searching"
                                    value_2_22.Text = value_3_32
                                    local value_4_20: number = 1
                                    local value_5_20: number = value_1_25 - 1
                                    value_2_22 = value_5_20 % 4
                                    value_3_32 = 1
                                    for index = value_4_20, value_2_22, value_3_32 do
                                        value_4_20 = index
                                        local value_5_21 = captured_value_25
                                        local processing_value = value_5_21.Processing
                                        local value_7_9 = captured_value_25
                                        local processing_value_2 = value_7_9.Processing
                                        local text_value = processing_value_2.Text
                                        local value_8_8: string = "."
                                        local value_6_11 = text_value .. value_8_8
                                        processing_value.Text = value_6_11
                                    end
                                    value_1_25 = value_1_25 + 1
                                    value_2_22 = wait
                                    value_3_32 = 0.25
                                    value_2_22(value_3_32)
                                end

                                return
                            end
                            closure_ready_10 = true
                            if closure_cache[7] == nil then
                                closure_cache[7] = value_3_31
                                closure_cache[8] = captured_value_25
                            end
                        end
                    end
                    value_2_21(value_3_31)
                    value_2_21 = captured_value_21.ID.Text
                    value_2_21 = game.ReplicatedStorage.Remotes.Extras.SearchSongs
                    do
                        local take_fallback_2 = argument_1_7
                        if not take_fallback_2 then
                            value_4_19 = captured_value_21.ID.Text
                            take_fallback_2 = not value_4_19
                        end
                        if take_fallback_2 then
                            value_4_19 = ""
                        end
                    end
                    value_2_21 = value_2_21:InvokeServer(value_4_19)
                    value_3_31 = captured_value_20.Processing
                    value_4_19 = false
                    value_3_31.Visible = value_4_19
                    if value_2_21 then
                        value_4_19 = value_2_21
                        value_3_31 = type(value_4_19)
                        if value_3_31 == "table" then
                            value_3_31 = #value_2_21
                            value_4_19 = 0
                            if value_4_19 < value_3_31 then
                                captured_value_22:ClearAllChildren()
                                value_3_31, value_4_19, value_5_19 = pairs(value_2_21)
                                for key_9, value_24 in value_3_31, value_4_19, value_5_19 do
                                    value_6_10, name_value_5 = key_9, value_24
                                    local script_value_4: LuaSourceContainer = script
                                    local searched_song_value = script_value_4.SearchedSong
                                    local cloned_value_2 = searched_song_value:Clone()
                                    local title_value = name_value_5.Title or name_value_5.Name
                                    local id_value_3 = name_value_5.Id or name_value_5.AssetId
                                    container_value_4.value = cloned_value_2.Container
                                    container_value_4.value = container_value_4.value.SongName
                                    local value_13_2 = title_value
                                    local tostring_value = tostring(value_13_2)
                                    container_value_4.value.Text = tostring_value
                                    container_value_4.value = pairs
                                    tostring_value = captured_value_23
                                    container_value_4.value, tostring_value, value_13_2 = container_value_4.value(
                                        tostring_value
                                    )
                                    local value_14_2, value_15_2
                                    for key_7, value_22 in container_value_4.value, tostring_value, value_13_2 do
                                        value_14_2, value_15_2 = key_7, value_22
                                        local id_value_4 = value_15_2.ID
                                        local value_18_6: string = "https://www.roblox.com/asset/?id="
                                        local value_19_5 = id_value_3
                                        local value_17_2 = value_18_6 .. value_19_5
                                        if id_value_4 ~= value_17_2 then
                                            continue
                                        end
                                        local container_value_5 = cloned_value_2.Container
                                        local add_value = container_value_5.Add
                                        local value_17_3: string = "Added"
                                        add_value.Text = value_17_3
                                        local container_value_6 = cloned_value_2.Container
                                        local add_value_2 = container_value_6.Add
                                        local roblox_round_button_value = Enum.ButtonStyle.RobloxRoundButton
                                        add_value_2.Style = roblox_round_button_value
                                    end
                                    container_value_4.value = nil
                                    tostring_value = cloned_value_2.Container.Add.MouseButton1Click
                                    do
                                        local captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, closure_ready_11
                                        value_14_2 = function(): ()
                                            if not closure_ready_11 then
                                                return
                                            end
                                            captured_value_26.value:disconnect()
                                            local add_value_3 = captured_value_27.Container.Add
                                            local value_2_24: string = "Added"
                                            add_value_3.Text = value_2_24
                                            local add_value_4 = captured_value_27.Container.Add
                                            local roblox_round_button_value_2 = Enum.ButtonStyle.RobloxRoundButton
                                            add_value_4.Style = roblox_round_button_value_2
                                            captured_value_28(captured_value_29, captured_value_30)

                                            return
                                        end
                                        captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30 = container_value_4, cloned_value_2, captured_value_24, id_value_3, title_value
                                        closure_ready_11 = true
                                    end
                                    tostring_value = tostring_value:connect(value_14_2)
                                    container_value_4.value = tostring_value
                                    tostring_value = cloned_value_2.Container.Preview.MouseButton1Click
                                    do
                                        local captured_value_31, captured_value_32, captured_value_33, closure_ready_12
                                        value_14_2 = function(): ()
                                            if not closure_ready_12 then
                                                return
                                            end
                                            local pairs_value, value_2_26, value_3_34 = pairs(
                                                captured_value_31:GetChildren()
                                            )
                                            local value_4_21
                                            for key_8, value_23 in pairs_value, value_2_26, value_3_34 do
                                                local value_5_22
                                                value_4_21, value_5_22 = key_8, value_23
                                                local container_value_9 = value_5_22.Container
                                                local preview_value = container_value_9.Preview
                                                local value_7_10: string = "Preview"
                                                preview_value.Text = value_7_10
                                            end
                                            script.Preview:Stop()
                                            pairs_value = "https://www.roblox.com/asset/?id=" .. captured_value_32
                                            value_2_26 = script.Preview.SoundId
                                            value_3_34 = script.Preview
                                            value_3_34.SoundId = pairs_value
                                            value_3_34 = script.Preview.SoundId
                                            if value_3_34 ~= value_2_26 then
                                                value_3_34 = captured_value_33.Container.Preview
                                                value_4_21 = "Stop"
                                                value_3_34.Text = value_4_21
                                                script.Preview:Play()

                                                return
                                            end
                                            value_3_34 = script.Preview
                                            value_4_21 = ""
                                            value_3_34.SoundId = value_4_21

                                            return
                                        end
                                        captured_value_31, captured_value_32, captured_value_33 = captured_value_22, id_value_3, cloned_value_2
                                        closure_ready_12 = true
                                    end
                                    tostring_value:connect(value_14_2)
                                    tostring_value = UDim2.new
                                    value_13_2 = 0
                                    value_14_2 = 0
                                    value_15_2 = 0
                                    local value_17_4 = value_6_10 - 1
                                    local size_value_2 = cloned_value_2.Size
                                    local y_value_2 = size_value_2.Y
                                    local offset_value_2 = y_value_2.Offset
                                    local value_16_2 = value_17_4 * offset_value_2
                                    tostring_value = tostring_value(
                                        value_13_2,
                                        value_14_2,
                                        value_15_2,
                                        value_16_2
                                    )
                                    cloned_value_2.Position = tostring_value
                                    tostring_value = captured_value_22
                                    value_13_2 = UDim2.new
                                    value_14_2 = 0
                                    value_15_2 = 0
                                    local value_16_3: number = 0
                                    local size_value_3 = cloned_value_2.Size
                                    local y_value_3 = size_value_3.Y
                                    local offset_value_3 = y_value_3.Offset
                                    local value_17_5 = offset_value_3 * value_6_10
                                    value_13_2 = value_13_2(
                                        value_14_2,
                                        value_15_2,
                                        value_16_3,
                                        value_17_5
                                    )
                                    tostring_value.CanvasSize = value_13_2
                                    tostring_value = captured_value_22
                                    cloned_value_2.Parent = tostring_value
                                    container_value_4 = {value = container_value_4.value}
                                end
                                value_3_31 = captured_value_22
                                value_4_19 = true
                                value_3_31.Visible = value_4_19

                                return
                            end
                            value_3_31 = captured_value_20.Empty
                            value_4_19 = true
                            value_3_31.Visible = value_4_19

                            return
                        end
                    end
                    value_3_31 = captured_value_20.Error
                    value_4_19 = true
                    value_3_31.Visible = value_4_19

                    return
                end
                closure_ready_13 = true
                if closure_cache[9] == nil then
                    closure_cache[9] = value_16
                    closure_cache[10], closure_cache[11], closure_cache[12], closure_cache[13], closure_cache[14], closure_cache[15] = captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24
                end
            end
        end
        value_17 = searcher_value.Add.MouseButton1Click
        local value_19_2 = value_16
        value_17:connect(value_19_2)
        value_17 = searcher_value.ID.FocusLost
        local value_19_3
        do
            local captured_value_34 = value_16
            if closure_cache[16] ~= nil and same_capture(closure_cache[17], captured_value_34) then
                value_19_3 = closure_cache[16]
            else
                local closure_ready_14
                value_19_3 = function(argument_1_8)
                    if not closure_ready_14 then
                        return
                    end
                    if argument_1_8 then
                        captured_value_34()
                    end

                    return
                end
                closure_ready_14 = true
                if closure_cache[16] == nil then
                    closure_cache[16] = value_19_3
                    closure_cache[17] = captured_value_34
                end
            end
        end
        value_17:connect(value_19_3)
        value_17 = adder_value.Add.MouseButton1Click
        local value_19_4
        do
            local captured_value_35, captured_value_36 = value_15, adder_value
            if closure_cache[18] ~= nil and same_capture(closure_cache[19], captured_value_35) and same_capture(
                closure_cache[20],
                captured_value_36
            ) then
                value_19_4 = closure_cache[18]
            else
                local closure_ready_15
                value_19_4 = function()
                    if not closure_ready_15 then
                        return
                    end
                    captured_value_35(captured_value_36.ID.Text)

                    return
                end
                closure_ready_15 = true
                if closure_cache[18] == nil then
                    closure_cache[18] = value_19_4
                    closure_cache[19], closure_cache[20] = captured_value_35, captured_value_36
                end
            end
        end
        value_17:connect(value_19_4)
        value_16()
        game_value_8()

        return
    end
end
if value_5_6 then
    table_13 = function(): ()
        game.Workspace.Lobby.RadioGamepass:Destroy()

        return
    end
    pcall(table_13)
end

return
