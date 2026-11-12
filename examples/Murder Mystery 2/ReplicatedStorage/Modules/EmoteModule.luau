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

while true do
    local wait_value: (number?) -> (number) = task.wait
    wait_value()
    local g_value = _G
    local emote_controller_value = g_value.EmoteController
    if emote_controller_value ~= nil then
        break
    end
end
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Database"
local database_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_6 = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
value_6 = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_6)
value_6 = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_6))
local game_value_3: DataModel = game
value_6 = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
value_6 = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_6)
local table_5 = {}
value_6 = {}
local table_7 = {}
local g_value_2 = _G
local table_9 = {}
g_value_2.EmotePages = table_9
local g_value_3 = _G
local value_9: string = ""
g_value_3.CurrentPage = value_9
local value_8: nil = nil
local table_1 = {
    [("EmoteGUI")] = nil,
    [("EmoteGUI")] = nil,
    [("EmoteGUI")] = nil,
    [("EmoteGUI")] = nil,
    [("EmoteGUI")] = nil,
}
table_1.EmoteGUI = value_8
local game_value_4: DataModel = game
local value_10: string = "UserInputService"
local value_5_9: Instance = (game_value_4:GetService(value_10))

local function get_image(argument_1)
    if _G.Cache[argument_1] ~= nil then
        return _G.Cache[argument_1]
    end
    local value_4_9 = argument_1
    local tonumber_result = tonumber(value_4_9)
    local value_2_3
    do
        local take_fallback = not tonumber_result
        if not take_fallback then
            value_2_3 = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. argument_1
            take_fallback = not value_2_3
        end
        if take_fallback then
            value_2_3 = argument_1
        end
    end
    local value_2_4 = value_2_3 .. "&bust=" .. (math.random(1, 10000))
    local cache_value_3 = _G.Cache
    cache_value_3[argument_1] = value_2_4

    return value_2_4
end

local value_9_3
do
    local captured_value, captured_value_2, closure_ready_2
    value_9_3 = function<T4, T5>(argument_1_2, argument_2, argument_3, argument_4: T4, argument_5: T5)
        if not closure_ready_2 then
            return
        end
        local cloned_value = script.Page:Clone()
        local cloned_value_2 = script.Container:Clone()
        cloned_value_2.Parent = cloned_value
        cloned_value.Name = argument_3
        local value_8_3 = argument_2.EmotePages
        cloned_value.Parent = value_8_3
        local table_6 = {}
        local value_10_6, value_9_10
        value_8_3, value_9_10, value_10_6 = pairs(argument_1_2)
        local value_11_4, value_12
        for key, value in value_8_3, value_9_10, value_10_6 do
            value_11_4, value_12 = key, value
            table_6[value_11_4] = value_12
        end
        value_10_6 = 1
        value_11_4 = ""
        value_9_10 = table_6
        table.insert(value_9_10, value_10_6, value_11_4)
        value_10_6 = 2
        value_11_4 = ""
        value_9_10 = table_6
        table.insert(value_9_10, value_10_6, value_11_4)
        value_8_3 = value_6
        value_9_10 = {}
        value_8_3[argument_3] = value_9_10
        value_8_3 = #table_6 - 2
        value_9_10 = UDim2.new
        value_10_6 = value_8_3
        value_11_4 = 0
        value_12 = 1
        local value_13 = 0
        value_9_10 = value_9_10(value_10_6, value_11_4, value_12, value_13)
        cloned_value_2.Size = value_9_10
        cloned_value_2:ClearAllChildren()
        value_9_10 = 3
        value_10_6 = table_6
        value_11_4 = nil
        value_12 = nil
        local value_14
        for key_2, value_23 in value_10_6, value_11_4, value_12 do
            value_13, value_14 = key_2, value_23
            local value_16 = captured_value
            local emotes_value = value_16.Emotes
            local value_15 = emotes_value[value_14]
            if not value_15 then
                local value_16_2 = captured_value
                local toys_value = value_16_2.Toys
                value_15 = toys_value[value_14]
            end
            if not value_15 then
                continue
            end
            local script_value_3: LuaSourceContainer = script
            local emote_value = script_value_3.Emote
            local cloned_value_3 = emote_value:Clone()
            local new_value: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
            local value_18 = 1 / value_8_3
            local value_19: number = 0
            local value_20: number = 1
            local value_21: number = 0
            local new_result = new_value(value_18, value_19, value_20, value_21)
            cloned_value_3.Size = new_result
            local new_value_2: ((UDim, UDim) -> (UDim2)) & ((number?, number?, number?, number?) -> (UDim2)) = UDim2.new
            local value_19_2 = 1 / value_8_3
            local value_22 = value_9_10 - 1
            local value_21_2 = value_22 - 1
            local value_20_2 = value_21_2 - 1
            local value_18_2 = value_19_2 * value_20_2
            local value_19_3: number = 0
            local value_20_3: number = 0
            local value_21_3: number = 0
            local new_result_2 = new_value_2(value_18_2, value_19_3, value_20_3, value_21_3)
            cloned_value_3.Position = new_result_2
            cloned_value_3.Name = value_14
            cloned_value_3.Parent = cloned_value_2
            local container_value_2 = cloned_value_3.Container
            local icon_value = container_value_2.Icon
            local image_value = value_15.Image
            local g_value_8 = _G
            local cache_value_4 = g_value_8.Cache
            local value_20_4 = cache_value_4[image_value]
            local value_18_3
            if value_20_4 ~= nil then
                local g_value_9 = _G
                local cache_value_5 = g_value_9.Cache
                value_18_3 = cache_value_5[image_value]
            else
                local value_22_2 = image_value
                local tonumber_value_2 = tonumber
                local tonumber_result_2 = tonumber_value_2(value_22_2)
                local value_20_5
                do
                    local take_fallback_2 = not tonumber_result_2
                    if not take_fallback_2 then
                        local value_21_4: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId="
                        local value_22_3 = image_value
                        value_20_5 = value_21_4 .. value_22_3
                        take_fallback_2 = not value_20_5
                    end
                    if take_fallback_2 then
                        value_20_5 = image_value
                    end
                end
                local value_21_5 = value_20_5
                local value_22_4: string = "&bust="
                local random_value_2 = math.random
                local value_24: number = 1
                local value_25: number = 10000
                local random_result_2 = random_value_2(value_24, value_25)
                local value_20_6 = value_21_5 .. value_22_4 .. random_result_2
                local g_value_10 = _G
                local cache_value_6 = g_value_10.Cache
                cache_value_6[image_value] = value_20_6
                value_18_3 = value_20_6
            end
            icon_value.Image = value_18_3
            local container_value_3 = cloned_value_3.Container
            local emote_name_value = container_value_3.EmoteName
            local name_value = value_15.Name
            emote_name_value.Text = name_value
            local container_value_4 = cloned_value_3.Container
            local hotkey_value = container_value_4.Hotkey
            hotkey_value.Text = value_9_10
            local container_value_5 = cloned_value_3.Container
            local hotkey_value_2 = container_value_5.Hotkey
            local value_18_4: Instance? = captured_value_2
            local keyboard_enabled_value = value_18_4.KeyboardEnabled
            hotkey_value_2.Visible = keyboard_enabled_value
            local container_value_6 = cloned_value_3.Container
            local button_value = container_value_6.Button
            local mouse_button1_click_value = button_value.MouseButton1Click
            local value_19_4
            do
                local captured_value_3, closure_ready
                value_19_4 = function(): ()
                    if not closure_ready then
                        return
                    end
                    local play_emote_value = game.ReplicatedStorage.Remotes.Misc.PlayEmote
                    local value_3_6 = captured_value_3
                    play_emote_value:Fire(value_3_6)

                    return
                end
                captured_value_3 = value_14
                closure_ready = true
            end
            mouse_button1_click_value:Connect(value_19_4)
            local value_18_6 = value_6
            local value_17_3 = value_18_6[argument_3]
            value_17_3[value_9_10] = value_14
            value_9_10 = value_9_10 + 1
        end
        value_11_4 = _G.EmotePages
        value_12 = argument_3
        table.insert(value_11_4, value_12)
        value_9_10 = script.Back:Clone()
        value_10_6 = UDim2.new(1 / value_8_3, 0, 1, 0)
        value_9_10.Size = value_10_6
        value_10_6 = value_9_10.Container.Icon
        value_12 = game
        value_14 = "UserInputService"
        value_11_4 = not value_12:GetService(value_14).GamepadEnabled
        value_10_6.Visible = value_11_4
        value_10_6 = value_9_10.Container.BButton
        value_11_4 = game
        value_13 = "UserInputService"
        value_11_4 = value_11_4:GetService(value_13).GamepadEnabled
        value_10_6.Visible = value_11_4
        value_10_6 = value_9_10.Container.Hotkey
        value_11_4 = game
        value_13 = "UserInputService"
        value_11_4 = value_11_4:GetService(value_13).KeyboardEnabled
        value_10_6.Visible = value_11_4
        value_9_10.Parent = cloned_value_2

        return
    end
    captured_value, captured_value_2 = require_result, value_5_9
    closure_ready_2 = true
end
table_1.GeneratePage = value_9_3
local value_9_4
do
    local captured_value_4, captured_value_5, closure_ready_3
    value_9_4 = function(argument_1_3)
        if not closure_ready_3 then
            return
        end
        local g_value_11 = _G.EmoteController
        local table_3 = {nil, nil}
        local value_4_12 = nil
        table_3[1] = value_4_12
        value_4_12 = "Back"
        table_3[2] = value_4_12
        g_value_11.Emotes = table_3
        g_value_11 = pairs
        local value_5_10 = value_6
        g_value_11, table_3, value_4_12 = g_value_11(value_5_10[argument_1_3])
        local value_6_4
        for key_3, value_26 in g_value_11, table_3, value_4_12 do
            value_5_10, value_6_4 = key_3, value_26
            local g_value_12 = _G
            local emote_controller_value_2 = g_value_12.EmoteController
            local emotes_value_2 = emote_controller_value_2.Emotes
            emotes_value_2[value_5_10] = value_6_4
        end
        g_value_11, table_3, value_4_12 = pairs(captured_value_4.EmoteGUI.EmotePages:GetChildren())
        for key_4, value_27 in g_value_11, table_3, value_4_12 do
            value_5_10, value_6_4 = key_4, value_27
            local name_value_2 = value_6_4.Name
            local value_7_4: boolean?
            if name_value_2 ~= argument_1_3 then
                value_7_4 = false
            else
                value_7_4 = true
            end
            value_6_4.Visible = value_7_4
        end
        g_value_11 = _G
        g_value_11.CurrentPage = argument_1_3
        g_value_11 = captured_value_4.EmoteGUI.PageName
        g_value_11.Text = argument_1_3
        task.wait()
        g_value_11 = captured_value_5:GetLastInputType()
        table_3 = Enum.UserInputType.Gamepad1
        if g_value_11 == table_3 then
            g_value_11 = captured_value_4.EmoteGUI.Visible
            if g_value_11 then
                g_value_11 = game
                value_4_12 = "GuiService"
                g_value_11 = g_value_11:GetService(value_4_12)
                table_3 = captured_value_4.EmoteGUI.EmotePages[argument_1_3].Container:GetChildren()[1].Container.Button
                g_value_11.SelectedObject = table_3
            end
        end

        return
    end
    captured_value_4, captured_value_5 = table_1, value_5_9
    closure_ready_3 = true
end
table_1.ShowPage = value_9_4
local g_value_4 = _G
local value_10_2
do
    local captured_value_6 = table_1
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_6) then
        value_10_2 = closure_cache[1]
    else
        local closure_ready_4
        value_10_2 = function(argument_1_4)
            if not closure_ready_4 then
                return
            end
            local g_value_13 = _G.EmotePages
            local value_3_7: nil = nil
            local value_4_13: nil = nil
            for key_5, value_28 in g_value_13, value_3_7, value_4_13 do
                local value_5_11, value_6_5 = key_5, value_28
                if value_5_11 ~= argument_1_4 then
                    continue
                end
                local value_7_5 = captured_value_6
                local show_page_value = value_7_5.ShowPage
                local value_8_4 = value_6_5
                show_page_value(value_8_4)
            end

            return
        end
        closure_ready_4 = true
        if closure_cache[1] == nil then
            closure_cache[1] = value_10_2
            closure_cache[2] = captured_value_6
        end
    end
end
g_value_4.ChangePage = value_10_2
local value_9_5
do
    local captured_value_7, closure_ready_5
    value_9_5 = function(argument_1_5, argument_2_2)
        if not closure_ready_5 then
            return
        end
        value_6 = {}
        local table_3_2 = _G
        local table_4 = {}
        table_3_2.EmotePages = table_4
        table_3_2 = _G
        table_4 = ""
        table_3_2.CurrentPage = table_4
        argument_2_2.EmotePages:ClearAllChildren()
        table_3_2 = #argument_1_5
        table_4 = 0
        local pairs_value, value_10_7, value_6_6, value_7_6, value_8_5, value_9_11
        if table_4 < table_3_2 then
            table_3_2 = #argument_1_5
            table_4 = 6
            if table_4 < table_3_2 then
                table_3_2 = {}
                table_4 = 0
                pairs_value, value_6_6, value_7_6 = pairs(argument_1_5)
                for key_6, value_29 in pairs_value, value_6_6, value_7_6 do
                    value_8_5, value_9_11 = key_6, value_29
                    local value_12_2 = value_8_5 / 6
                    local floor_value = math.floor
                    local floor_result = floor_value(value_12_2)
                    value_10_7 = floor_result + 1
                    local value_11_5 = table_3_2[value_10_7] or ({})
                    table_3_2[value_10_7] = value_11_5
                    local value_12_3 = table_3_2[value_10_7]
                    local value_13_2 = value_9_11
                    local insert_value = table.insert
                    insert_value(value_12_3, value_13_2)
                    table_4 = value_10_7
                end
                pairs_value = nil
                value_6_6, value_7_6, value_8_5 = pairs(table_3_2)
                for key_7, value_30 in value_6_6, value_7_6, value_8_5 do
                    value_9_11, value_10_7 = key_7, value_30
                    local value_12_4: string = "Your Emotes ("
                    local value_13_3 = value_9_11
                    local value_14_2: string = "/"
                    local value_15_2 = table_4
                    local value_16_4: string = ")"
                    local value_11_6 = value_12_4 .. value_13_3 .. value_14_2 .. value_15_2 .. value_16_4
                    local value_12_5 = captured_value_7
                    local generate_page_value = value_12_5.GeneratePage
                    local value_13_4 = value_10_7
                    local value_14_3 = argument_2_2
                    local value_15_3 = value_11_6
                    generate_page_value(value_13_4, value_14_3, value_15_3)
                    if value_9_11 ~= 1 then
                        continue
                    end
                    pairs_value = value_11_6
                end
                value_6_6 = captured_value_7.GeneratePage
                value_7_6 = {
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                }
                value_8_5 = "wave"
                value_9_11 = "cheer"
                value_10_7 = "laugh"
                local value_11_7: string = "dance1"
                local value_12_6: string = "dance2"
                local value_13_5: string = "dance3"
                value_7_6[1], value_7_6[2], value_7_6[3], value_7_6[4], value_7_6[5], value_7_6[6] = value_8_5, value_9_11, value_10_7, value_11_7, value_12_6, value_13_5
                value_8_5 = argument_2_2
                value_9_11 = "Roblox Emotes"
                value_6_6(value_7_6, value_8_5, value_9_11)
                value_6_6 = captured_value_7.ShowPage
                value_7_6 = pairs_value
                value_8_5 = argument_2_2
                value_6_6(value_7_6, value_8_5)
            else
                captured_value_7.GeneratePage(argument_1_5, argument_2_2, "Your Emotes")
                table_3_2 = captured_value_7.GeneratePage
                table_4 = {
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                    nil,
                }
                pairs_value = "wave"
                value_6_6 = "cheer"
                value_7_6 = "laugh"
                value_8_5 = "dance1"
                value_9_11 = "dance2"
                value_10_7 = "dance3"
                table_4[1], table_4[2], table_4[3], table_4[4], table_4[5], table_4[6] = pairs_value, value_6_6, value_7_6, value_8_5, value_9_11, value_10_7
                pairs_value = argument_2_2
                value_6_6 = "Roblox Emotes"
                table_3_2(table_4, pairs_value, value_6_6)
                captured_value_7.ShowPage("Your Emotes", argument_2_2)
            end
        else
            table_3_2 = captured_value_7.GeneratePage
            table_4 = {
                nil,
                nil,
                nil,
                nil,
                nil,
                nil,
            }
            pairs_value = "wave"
            value_6_6 = "cheer"
            value_7_6 = "laugh"
            value_8_5 = "dance1"
            value_9_11 = "dance2"
            value_10_7 = "dance3"
            table_4[1], table_4[2], table_4[3], table_4[4], table_4[5], table_4[6] = pairs_value, value_6_6, value_7_6, value_8_5, value_9_11, value_10_7
            table_3_2(table_4, argument_2_2, "Roblox Emotes")
            table_3_2 = captured_value_7.GeneratePage
            table_4 = argument_1_5
            pairs_value = argument_2_2
            value_6_6 = "Your Emotes"
            table_3_2(table_4, pairs_value, value_6_6)
            captured_value_7.ShowPage("Roblox Emotes", argument_2_2)
        end
        table_7 = {}
        table_3_2, table_4, pairs_value = pairs(argument_1_5)
        for key_8, value_31 in table_3_2, table_4, pairs_value do
            value_6_6, value_7_6 = key_8, value_31
            value_8_5 = table_7
            value_9_11 = true
            value_8_5[value_7_6] = value_9_11
        end

        return
    end
    captured_value_7 = table_1
    closure_ready_5 = true
end
table_1.GenerateEmotes = value_9_5
local value_9_6
do
    local captured_value_8 = table_1
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_8) then
        value_9_6 = closure_cache[3]
    else
        local closure_ready_6
        value_9_6 = function()
            if not closure_ready_6 then
                return
            end
            local game_value_6: DataModel = game
            local value_4_14: string = "UserInputService"
            local value_1_2: boolean?
            if (game_value_6:GetService(value_4_14):GetLastInputType()) ~= Enum.UserInputType.Gamepad1 then
                value_1_2 = false
            else
                value_1_2 = true
            end
            local value_2_8: boolean = not value_1_2
            local value_3_10: string?
            if value_1_2 then
                value_3_10 = ""
            else
                if value_2_8 then
                    value_3_10 = "< Q"
                else
                    value_3_10 = "<"
                end
            end
            local value_4_15: string?
            if value_1_2 then
                value_4_15 = ""
            else
                if value_2_8 then
                    value_4_15 = "E >"
                else
                    value_4_15 = ">"
                end
            end
            local left_value = captured_value_8.EmoteGUI.Left
            left_value.Text = value_3_10
            local right_value = captured_value_8.EmoteGUI.Right
            right_value.Text = value_4_15
            local left_value_2 = captured_value_8.EmoteGUI.Left
            local value_7_7: string = "ButtonIcon"
            if (left_value_2:FindFirstChild(value_7_7)) then
                local button_icon_value = captured_value_8.EmoteGUI.Left.ButtonIcon
                button_icon_value.Visible = value_1_2
                local button_icon_value_2 = captured_value_8.EmoteGUI.Right.ButtonIcon
                button_icon_value_2.Visible = value_1_2
            end
            local mouse_button1_click_value_2 = captured_value_8.EmoteGUI.Left.MouseButton1Click
            local emote_page_left_value = _G.EmotePageLeft
            mouse_button1_click_value_2:Connect(emote_page_left_value)
            local mouse_button1_click_value_3 = captured_value_8.EmoteGUI.Right.MouseButton1Click
            local emote_page_right_value = _G.EmotePageRight
            mouse_button1_click_value_3:Connect(emote_page_right_value)

            return
        end
        closure_ready_6 = true
        if closure_cache[3] == nil then
            closure_cache[3] = value_9_6
            closure_cache[4] = captured_value_8
        end
    end
end
table_1.SetupPageButtons = value_9_6
local value_11: string = "Inventory"
local inventory_child = remotes_child:WaitForChild(value_11)
local value_11_2: string = "InventoryDataChanged"
local event_value = inventory_child:WaitForChild(value_11_2).Event
local value_11_3
do
    local captured_value_9, captured_value_10, closure_ready_7
    value_11_3 = function<T2, T3>(argument_1_6, argument_2_3: T2, argument_3_2: T3)
        if not closure_ready_7 then
            return
        end
        do
            local take_fallback_3 = argument_1_6 == "Emotes"
            if take_fallback_3 or argument_1_6 == "Toys" then
                local value_5_22 = captured_value_9.Emotes.Owned
                local value_6_10: nil = nil
                local value_7_8: nil = nil
                for key_9, value_32 in value_5_22, value_6_10, value_7_8 do
                    local value_8_6, value_9_12 = key_9, value_32
                    local value_11_8 = table_7
                    local value_10_8 = value_11_8[value_9_12]
                    if value_10_8 ~= nil then
                        continue
                    end
                    local value_10_9 = captured_value_10
                    local generate_emotes_value = value_10_9.GenerateEmotes
                    local value_11_9 = captured_value_9
                    local emotes_value_4 = value_11_9.Emotes
                    local owned_value_2 = emotes_value_4.Owned
                    local value_12_7 = captured_value_10
                    local emote_gui_value_8 = value_12_7.EmoteGUI
                    generate_emotes_value(owned_value_2, emote_gui_value_8)

                    return
                end
            end
        end

        return
    end
    captured_value_9, captured_value_10 = require_result_2, table_1
    closure_ready_7 = true
end
event_value:Connect(value_11_3)

return table_1
