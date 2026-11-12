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

local parent_value: Instance? = script.Parent
local value_4: string = "Container"
local container_child = parent_value:WaitForChild(value_4)
local require_value = require
local game_value: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_6_2)
local value_6_3: string = "CurrentRoundClient"
local require_result = require_value(modules_child:WaitForChild(value_6_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child_2: Instance? = replicated_storage_service_2:WaitForChild(value_7_2)
local value_7_3: string = "WindowService"
local require_result_2 = require_value_2(modules_child_2:WaitForChild(value_7_3))
local value_7_4: string = "PlayerList"
local player_list_child = container_child:WaitForChild(value_7_4)
local value_7_5: string = "Container"
local container_child_2 = player_list_child:WaitForChild(value_7_5)
local value_8: string = "Teams"
local teams_child = container_child:WaitForChild(value_8)
local value_9: string = "PlayerList"
local player_list_child_2 = container_child:WaitForChild(value_9)
local value_9_2: string = "Start"
local start_child = player_list_child_2:WaitForChild(value_9_2)
local value_10: string = "Title"
local title_child = container_child:WaitForChild(value_10)
local value_10_2: string = "Close"
local close_child = title_child:WaitForChild(value_10_2)
local game_value_3: DataModel = game
local value_11: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_11)
local value_11_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_3:WaitForChild(value_11_2)
local value_12: string = "DuelRound"
local duel_round_child = parent_value:WaitForChild(value_12)
local value_13: string = "Container"
local container_child_3 = duel_round_child:WaitForChild(value_13)
local value_13_2: string = "DuelStart"
local value_1 = (container_child_3:WaitForChild(value_13_2))
local value_13_3: string = "Container"
local container_child_4 = duel_round_child:WaitForChild(value_13_3)
local value_13_4: string = "DuelDisplay"
local duel_display_child = container_child_4:WaitForChild(value_13_4)
local value_14: string = "Team1"
local team1_child = duel_display_child:WaitForChild(value_14)
local value_15: string = "Team2"
local team2_child = duel_display_child:WaitForChild(value_15)
local value_16: string = "Settings"
local settings_child = container_child:WaitForChild(value_16)
local value_17 = "ListPlayer"
local list_player_child = container_child_2:WaitForChild(value_17)
local script_value_2: LuaSourceContainer = script
list_player_child.Parent = script_value_2
local players_value = teams_child.Team1.Container.Players
local value_18: string = "TeamPlayer"
local team_player_child = players_value:WaitForChild(value_18)
value_17 = script
team_player_child.Parent = value_17
value_17 = nil
local value_20: string = "Team1"
local team1_child_2 = duel_display_child:WaitForChild(value_20)
local value_20_2: string = "RoundPlayer"
local round_player_child = team1_child_2:WaitForChild(value_20_2)
local script_value_3: LuaSourceContainer = script
round_player_child.Parent = script_value_3
local table_19 = {Team1 = {}, Team2 = {}}
local table_20_3 = {}
local table_21 = {}
local value_24 = "CustomGames"
local custom_games_child = remotes_child:WaitForChild(value_24)
value_24 = "CanStartDuels"
local invoke_server_result = custom_games_child:WaitForChild(value_24):InvokeServer()
local table_23: { BothVsBoth: string, Custom: string, GunVsGun: string, KnifeVsGun: string, KnifeVsKnife: string } = {
    KnifeVsGun = "KnifeVsGun",
    KnifeVsKnife = "KnifeVsKnife",
    GunVsGun = "GunVsGun",
    BothVsBoth = "BothVsBoth",
    Custom = "Custom",
}
value_24 = "KnifeVsGun"
local table_25: { Both: string, Gun: string, Knife: string } = {
    Both = "rbxassetid://18147380345",
    Gun = "rbxassetid://197518111",
    Knife = "rbxassetid://584555920",
}
do
    local captured_value = table_19
    local count_team_size
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        count_team_size = closure_cache[1]
    else
        local closure_ready
        count_team_size = function(argument_1: string)
            if not closure_ready then
                return
            end
            local value_2_2: number = 0
            local value_6_10 = captured_value
            local value_3_2 = value_6_10[argument_1]
            local value_4_5: nil = nil
            local value_5_9: nil = nil
            for key, value in value_3_2, value_4_5, value_5_9 do
                local value_7_9
                value_6_10, value_7_9 = key, value
                value_2_2 = value_2_2 + 1
            end

            return value_2_2
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = count_team_size
            closure_cache[2] = captured_value
        end
    end
end
local update_weapons_for_mode
do
    local closure_ready_2
    update_weapons_for_mode = function(argument_1_2): ()
        if not closure_ready_2 then
            return
        end
        local value_4_6: string = "Team"
        local team_value = argument_1_2:GetAttribute(value_4_6)
        if value_24 == "KnifeVsGun" then
            if team_value == "Team1" then
                local icon_value = argument_1_2.Weapon.Icon
                local value_4_7: string = "rbxassetid://584555920"
                icon_value.Image = value_4_7
            else
                local icon_value_2 = argument_1_2.Weapon.Icon
                local value_4_8: string = "rbxassetid://197518111"
                icon_value_2.Image = value_4_8
            end
            local knife_value = argument_1_2.Knife
            local value_5_10: string = "Enabled"
            local value_6_11: boolean?
            if team_value ~= "Team1" then
                value_6_11 = false
            else
                value_6_11 = true
            end
            knife_value:SetAttribute(value_5_10, value_6_11)
            local gun_value = argument_1_2.Gun
            local value_5_11: string = "Enabled"
            local value_6_12: boolean?
            if team_value ~= "Team2" then
                value_6_12 = false
            else
                value_6_12 = true
            end
            gun_value:SetAttribute(value_5_11, value_6_12)
        else
            if value_24 == "KnifeVsKnife" then
                local icon_value_3 = argument_1_2.Weapon.Icon
                local value_4_11: string = "rbxassetid://584555920"
                icon_value_3.Image = value_4_11
                local knife_value_2 = argument_1_2.Knife
                local value_5_12: string = "Enabled"
                local value_6_13: boolean = true
                knife_value_2:SetAttribute(value_5_12, value_6_13)
                local gun_value_2 = argument_1_2.Gun
                local value_5_13: string = "Enabled"
                local value_6_14: boolean = false
                gun_value_2:SetAttribute(value_5_13, value_6_14)
            else
                if value_24 == "GunVsGun" then
                    local icon_value_4 = argument_1_2.Weapon.Icon
                    local value_4_14: string = "rbxassetid://197518111"
                    icon_value_4.Image = value_4_14
                    local knife_value_3 = argument_1_2.Knife
                    local value_5_14: string = "Enabled"
                    local value_6_15: boolean = false
                    knife_value_3:SetAttribute(value_5_14, value_6_15)
                    local gun_value_3 = argument_1_2.Gun
                    local value_5_15: string = "Enabled"
                    local value_6_16: boolean = true
                    gun_value_3:SetAttribute(value_5_15, value_6_16)
                else
                    if value_24 == "BothVsBoth" then
                        local icon_value_5 = argument_1_2.Weapon.Icon
                        local value_4_17: string = "rbxassetid://18147380345"
                        icon_value_5.Image = value_4_17
                        local knife_value_4 = argument_1_2.Knife
                        local value_5_16: string = "Enabled"
                        local value_6_17: boolean = true
                        knife_value_4:SetAttribute(value_5_16, value_6_17)
                        local gun_value_4 = argument_1_2.Gun
                        local value_5_17: string = "Enabled"
                        local value_6_18: boolean = true
                        gun_value_4:SetAttribute(value_5_17, value_6_18)
                    end
                end
            end
        end
        local weapon_value_6 = argument_1_2.Weapon
        local value_4_20: boolean?
        if value_24 == "Custom" then
            value_4_20 = false
        else
            value_4_20 = true
        end
        weapon_value_6.Visible = value_4_20
        local gun_value_5 = argument_1_2.Gun
        local value_4_21: boolean?
        if value_24 ~= "Custom" then
            value_4_21 = false
        else
            value_4_21 = true
        end
        gun_value_5.Visible = value_4_21
        local knife_value_5 = argument_1_2.Knife
        local value_4_22: boolean?
        if value_24 ~= "Custom" then
            value_4_22 = false
        else
            value_4_22 = true
        end
        knife_value_5.Visible = value_4_22

        return
    end
    closure_ready_2 = true
end

local function get_player_icon(argument_1_3)
    local user_id_value = argument_1_3.UserId
    local abs_result = math.abs(user_id_value)
    local players_value_2 = game.Players
    local value_5_21 = abs_result
    local avatar_bust_value = Enum.ThumbnailType.AvatarBust
    local size100x100_value = Enum.ThumbnailSize.Size100x100

    return players_value_2:GetUserThumbnailAsync(value_5_21, avatar_bust_value, size100x100_value)
end

local update_team_frames
do
    local captured_value_2 = table_19
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) then
        update_team_frames = closure_cache[3]
    else
        local closure_ready_3
        update_team_frames = function()
            if not closure_ready_3 then
                return
            end
            local value_1_2 = captured_value_2
            local value_2_4: nil = nil
            local value_3_17: nil = nil
            for key_3, value_25 in value_1_2, value_2_4, value_3_17 do
                local value_4_24, value_5_22 = key_3, value_25
                local value_6_19 = value_5_22
                local value_7_10: nil = nil
                local value_8_6: nil = nil
                for key_2, value_21 in value_6_19, value_7_10, value_8_6 do
                    local value_9_7, value_10_6 = key_2, value_21
                    local parent_value_2 = value_9_7.Parent
                    if parent_value_2 ~= nil then
                        continue
                    end
                    if value_10_6 == nil then
                        continue
                    end
                    value_10_6:Destroy()
                    local value_11_9: nil = nil
                    value_5_22[value_9_7] = value_11_9
                end
            end

            return
        end
        closure_ready_3 = true
        if closure_cache[3] == nil then
            closure_cache[3] = update_team_frames
            closure_cache[4] = captured_value_2
        end
    end
end
do
    local captured_value_3 = table_19
    local remove_player_from_team
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_3) then
        remove_player_from_team = closure_cache[5]
    else
        local closure_ready_4
        remove_player_from_team = function(argument_1_4)
            if not closure_ready_4 then
                return
            end
            if captured_value_3.Team1[argument_1_4] then
                captured_value_3.Team1[argument_1_4]:Destroy()
            end
            if captured_value_3.Team2[argument_1_4] then
                captured_value_3.Team2[argument_1_4]:Destroy()
            end
            local team1_value_4 = captured_value_3.Team1
            local value_3_24: nil = nil
            team1_value_4[argument_1_4] = value_3_24
            local team2_value_3 = captured_value_3.Team2
            local value_3_25: nil = nil
            team2_value_3[argument_1_4] = value_3_25

            return
        end
        closure_ready_4 = true
        if closure_cache[5] == nil then
            closure_cache[5] = remove_player_from_team
            closure_cache[6] = captured_value_3
        end
    end
end
do
    local captured_value_4 = table_19
    local clear_teams
    if closure_cache[7] ~= nil and same_capture(closure_cache[8], captured_value_4) then
        clear_teams = closure_cache[7]
    else
        local closure_ready_5
        clear_teams = function()
            if not closure_ready_5 then
                return
            end
            local game_value_5, value_2_13, value_3_26 = game.Players:GetPlayers()
            for key_4, value_26 in game_value_5, value_2_13, value_3_26 do
                local value_4_25, value_5_23 = key_4, value_26
                local value_7_11 = captured_value_4
                local team1_value_5 = value_7_11.Team1
                local value_6_20 = team1_value_5[value_5_23]
                if value_6_20 then
                    local value_7_12 = captured_value_4
                    local team1_value_6 = value_7_12.Team1
                    local value_6_21 = team1_value_6[value_5_23]
                    value_6_21:Destroy()
                end
                local value_7_14 = captured_value_4
                local team2_value_4 = value_7_14.Team2
                local value_6_23 = team2_value_4[value_5_23]
                if value_6_23 then
                    local value_7_15 = captured_value_4
                    local team2_value_5 = value_7_15.Team2
                    local value_6_24 = team2_value_5[value_5_23]
                    value_6_24:Destroy()
                end
                local value_6_26 = captured_value_4
                local team1_value_7 = value_6_26.Team1
                local value_7_17: nil = nil
                team1_value_7[value_5_23] = value_7_17
                local value_6_27 = captured_value_4
                local team2_value_6 = value_6_27.Team2
                local value_7_18: nil = nil
                team2_value_6[value_5_23] = value_7_18
            end

            return
        end
        closure_ready_5 = true
        if closure_cache[7] == nil then
            closure_cache[7] = clear_teams
            closure_cache[8] = captured_value_4
        end
    end
end
local add_player_to_team
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9 = table_19, team_player_child, update_weapons_for_mode, teams_child, update_team_frames
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_5) and same_capture(
        closure_cache[11],
        captured_value_6
    ) and same_capture(closure_cache[12], captured_value_7) and same_capture(
        closure_cache[13],
        captured_value_8
    ) and same_capture(closure_cache[14], captured_value_9) then
        add_player_to_team = closure_cache[9]
    else
        local closure_ready_9
        add_player_to_team = function(argument_1_5, argument_2: string)
            if not closure_ready_9 then
                return
            end
            if captured_value_5.Team1[argument_1_5] then
                captured_value_5.Team1[argument_1_5]:Destroy()
            end
            if captured_value_5.Team2[argument_1_5] then
                captured_value_5.Team2[argument_1_5]:Destroy()
            end
            local team1_value_10 = captured_value_5.Team1
            local value_4_32: nil = nil
            team1_value_10[argument_1_5] = value_4_32
            local team2_value_9 = captured_value_5.Team2
            local value_4_33: nil = nil
            team2_value_9[argument_1_5] = value_4_33
            local cloned_value = captured_value_6:Clone()
            local text_label_value = cloned_value.TextLabel
            local name_value = argument_1_5.Name
            text_label_value.Text = name_value
            local image_label_value = cloned_value.ImageLabel
            local user_id_value_2 = argument_1_5.UserId
            local abs_result_2 = math.abs(user_id_value_2)
            local players_value_3 = game.Players
            local value_9_8 = abs_result_2
            local avatar_bust_value_2 = Enum.ThumbnailType.AvatarBust
            local size100x100_value_2 = Enum.ThumbnailSize.Size100x100
            local value_5_24 = (players_value_3:GetUserThumbnailAsync(
                value_9_8,
                avatar_bust_value_2,
                size100x100_value_2
            ))
            image_label_value.Image = value_5_24
            local activated_value_2 = cloned_value.ImageLabel.Button.Activated
            local value_6_28: (() -> ())?
            do
                local captured_value_10, captured_value_11, captured_value_12, closure_ready_6
                value_6_28 = function(): ()
                    if not closure_ready_6 then
                        return
                    end
                    captured_value_10:Destroy()
                    local value_1_5 = captured_value_11
                    if captured_value_12.Team1[value_1_5] then
                        captured_value_12.Team1[value_1_5]:Destroy()
                    end
                    if captured_value_12.Team2[value_1_5] then
                        captured_value_12.Team2[value_1_5]:Destroy()
                    end
                    local team1_value_13 = captured_value_12.Team1
                    local value_3_43: nil = nil
                    team1_value_13[value_1_5] = value_3_43
                    local team2_value_12 = captured_value_12.Team2
                    local value_3_44: nil = nil
                    team2_value_12[value_1_5] = value_3_44

                    return
                end
                captured_value_10, captured_value_11, captured_value_12 = cloned_value, argument_1_5, captured_value_5
                closure_ready_6 = true
            end
            activated_value_2:Connect(value_6_28)
            local value_4_36 = (time()) * 100
            cloned_value.LayoutOrder = value_4_36
            local value_6_29: string = "Team"
            local value_7_20: string = argument_2
            cloned_value:SetAttribute(value_6_29, value_7_20)
            local knife_value_6 = cloned_value.Knife
            local value_6_30: string = "Enabled"
            local value_7_21: boolean = true
            knife_value_6:SetAttribute(value_6_30, value_7_21)
            local activated_value_3 = cloned_value.Knife.Button.Activated
            local value_6_31: (() -> ())?
            do
                local captured_value_13, closure_ready_7
                value_6_31 = function(): ()
                    if not closure_ready_7 then
                        return
                    end
                    local knife_value_8 = captured_value_13.Knife
                    local value_3_45: string = "Enabled"
                    if (knife_value_8:GetAttribute(value_3_45)) then
                        local knife_value_9 = captured_value_13.Knife
                        local value_4_46: string = "Enabled"
                        local value_5_34: boolean = false
                        knife_value_9:SetAttribute(value_4_46, value_5_34)
                        local icon_value_6 = captured_value_13.Knife.Icon
                        local from_rgb_result: Color3 = Color3.fromRGB(255, 0, 0)
                        icon_value_6.ImageColor3 = from_rgb_result

                        return
                    end
                    local knife_value_11 = captured_value_13.Knife
                    local value_4_48: string = "Enabled"
                    local value_5_36: boolean = true
                    knife_value_11:SetAttribute(value_4_48, value_5_36)
                    local icon_value_7 = captured_value_13.Knife.Icon
                    local from_rgb_result_2: Color3 = Color3.fromRGB(0, 255, 0)
                    icon_value_7.ImageColor3 = from_rgb_result_2

                    return
                end
                captured_value_13 = cloned_value
                closure_ready_7 = true
            end
            activated_value_3:Connect(value_6_31)
            local gun_value_6 = cloned_value.Gun
            local value_6_32: string = "Enabled"
            local value_7_22: boolean = true
            gun_value_6:SetAttribute(value_6_32, value_7_22)
            local activated_value_4 = cloned_value.Gun.Button.Activated
            local value_6_33: (() -> ())?
            do
                local captured_value_14, closure_ready_8
                value_6_33 = function(): ()
                    if not closure_ready_8 then
                        return
                    end
                    local gun_value_8 = captured_value_14.Gun
                    local value_3_48: string = "Enabled"
                    if (gun_value_8:GetAttribute(value_3_48)) then
                        local gun_value_9 = captured_value_14.Gun
                        local value_4_50: string = "Enabled"
                        local value_5_38: boolean = false
                        gun_value_9:SetAttribute(value_4_50, value_5_38)
                        local icon_value_8 = captured_value_14.Gun.Icon
                        local from_rgb_result_3: Color3 = Color3.fromRGB(255, 0, 0)
                        icon_value_8.ImageColor3 = from_rgb_result_3

                        return
                    end
                    local gun_value_11 = captured_value_14.Gun
                    local value_4_52: string = "Enabled"
                    local value_5_40: boolean = true
                    gun_value_11:SetAttribute(value_4_52, value_5_40)
                    local icon_value_9 = captured_value_14.Gun.Icon
                    local from_rgb_result_4: Color3 = Color3.fromRGB(0, 255, 0)
                    icon_value_9.ImageColor3 = from_rgb_result_4

                    return
                end
                captured_value_14 = cloned_value
                closure_ready_8 = true
            end
            activated_value_4:Connect(value_6_33)
            captured_value_7(cloned_value)
            local value_4_43 = captured_value_5[argument_2]
            value_4_43[argument_1_5] = cloned_value
            local players_value_4 = captured_value_8[argument_2].Container.Players
            cloned_value.Parent = players_value_4
            captured_value_9()

            return
        end
        closure_ready_9 = true
        if closure_cache[9] == nil then
            closure_cache[9] = add_player_to_team
            closure_cache[10], closure_cache[11], closure_cache[12], closure_cache[13], closure_cache[14] = captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9
        end
    end
end
local reset_selection
do
    local captured_value_15 = table_20_3
    if closure_cache[15] ~= nil and same_capture(closure_cache[16], captured_value_15) then
        reset_selection = closure_cache[15]
    else
        local closure_ready_10
        reset_selection = function()
            if not closure_ready_10 then
                return
            end
            local value_1_10 = captured_value_15
            local value_2_37: nil = nil
            local value_3_51: nil = nil
            for key_5, value_27 in value_1_10, value_2_37, value_3_51 do
                local value_4_54, value_5_42 = key_5, value_27
                local image_label_value_3 = value_5_42.ImageLabel
                local ui_stroke_value = image_label_value_3.UIStroke
                local from_rgb_value_5: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                local value_8_8: number = 0
                local value_9_9: number = 0
                local value_10_7: number = 0
                local from_rgb_result_5: Color3 = from_rgb_value_5(
                    value_8_8,
                    value_9_9,
                    value_10_7
                )
                ui_stroke_value.Color = from_rgb_result_5
            end

            return
        end
        closure_ready_10 = true
        if closure_cache[15] == nil then
            closure_cache[15] = reset_selection
            closure_cache[16] = captured_value_15
        end
    end
end
local update_player_list
do
    local captured_value_16, captured_value_17, captured_value_18, captured_value_19, closure_ready_12
    update_player_list = function()
        if not closure_ready_12 then
            return
        end
        local value_6_38 = {}
        task.wait()
        local wait_value, value_2_38, value_3_52 = game.Players:GetPlayers()
        local value_4_55, value_5_43
        for key_6, value_28 in wait_value, value_2_38, value_3_52 do
            value_4_55, value_5_43 = key_6, value_28
            local value_7_23 = captured_value_16
            value_6_38.value = value_7_23[value_5_43]
            if value_6_38.value == nil then
                local value_7_24 = captured_value_17
                local cloned_value_2 = value_7_24:Clone()
                value_6_38.value = cloned_value_2
                local image_label_value_4 = value_6_38.value.ImageLabel
                local user_id_value_3 = value_5_43.UserId
                local abs_value_3 = math.abs
                local abs_result_3 = abs_value_3(user_id_value_3)
                local game_value_7: DataModel = game
                local players_value_5 = game_value_7.Players
                local value_12_8 = abs_result_3
                local avatar_bust_value_3 = Enum.ThumbnailType.AvatarBust
                local size100x100_value_3 = Enum.ThumbnailSize.Size100x100
                local get_user_thumbnail_async_result_2 = players_value_5:GetUserThumbnailAsync(
                    value_12_8,
                    avatar_bust_value_3,
                    size100x100_value_3
                )
                local value_8_10 = get_user_thumbnail_async_result_2
                image_label_value_4.Image = value_8_10
                local text_label_value_2 = value_6_38.value.TextLabel
                local name_value_2 = value_5_43.Name
                text_label_value_2.Text = name_value_2
                local time_value_2 = time
                local time_result_2 = time_value_2()
                local value_7_26 = time_result_2 * 100
                value_6_38.value.LayoutOrder = value_7_26
                local button_value_5 = value_6_38.value.Button
                local activated_value_5 = button_value_5.Activated
                local value_9_10
                do
                    local captured_value_20, captured_value_21, captured_value_22, closure_ready_11
                    value_9_10 = function(): ()
                        if not closure_ready_11 then
                            return
                        end
                        if value_17 == captured_value_20 then
                            local ui_stroke_value_2 = captured_value_21.value.ImageLabel.UIStroke
                            local from_rgb_result_6: Color3 = Color3.fromRGB(0, 0, 0)
                            ui_stroke_value_2.Color = from_rgb_result_6
                            value_17 = nil

                            return
                        end
                        captured_value_22()
                        value_17 = captured_value_20
                        local ui_stroke_value_3 = captured_value_21.value.ImageLabel.UIStroke
                        local from_rgb_result_7: Color3 = Color3.fromRGB(50, 200, 50)
                        ui_stroke_value_3.Color = from_rgb_result_7

                        return
                    end
                    captured_value_20, captured_value_21, captured_value_22 = value_5_43, value_6_38, captured_value_18
                    closure_ready_11 = true
                end
                activated_value_5:Connect(value_9_10)
                local value_7_28 = captured_value_19
                value_6_38.value.Parent = value_7_28
                local value_7_29 = captured_value_16
                value_7_29[value_5_43] = value_6_38.value
            end
            value_6_38 = {value = value_6_38.value}
        end
        wait_value = captured_value_16
        value_2_38 = nil
        value_3_52 = nil
        for key_7, value_29 in wait_value, value_2_38, value_3_52 do
            value_4_55, value_5_43 = key_7, value_29
            local game_value_8: DataModel = game
            local players_value_6 = game_value_8.Players
            value_6_38.value = value_4_55:IsDescendantOf(players_value_6)
            if value_6_38.value then
                continue
            end
            if value_5_43 then
                value_5_43:Destroy()
            end
            value_6_38.value = captured_value_16
            local value_7_32: nil = nil
            value_6_38.value[value_4_55] = value_7_32
        end

        return
    end
    captured_value_16, captured_value_17, captured_value_18, captured_value_19 = table_20_3, list_player_child, reset_selection, container_child_2
    closure_ready_12 = true
end
local value_34 = nil
local on_player_data_updated
do
    local captured_value_23, closure_ready_13
    on_player_data_updated = function()
        if not closure_ready_13 then
            return
        end
        local value_1_17 = captured_value_23.PlayerData
        local value_2_40: nil = nil
        local value_3_55: nil = nil
        for key_8, value_30 in value_1_17, value_2_40, value_3_55 do
            local value_4_58, value_5_46 = key_8, value_30
            local value_7_33 = table_21
            local value_6_39 = value_7_33[value_4_58]
            if not value_6_39 then
                continue
            end
            local dead_value = value_5_46.Dead
            if not dead_value then
                continue
            end
            local dead_value_2 = value_6_39.Dead
            local value_8_12: boolean = true
            dead_value_2.Visible = value_8_12
            local image_label_value_7 = value_6_39.ImageLabel
            local from_rgb_value_8: (number?, number?, number?) -> (Color3) = Color3.fromRGB
            local value_9_11: number = 20
            local value_10_9: number = 20
            local value_11_11: number = 20
            local from_rgb_result_8: Color3 = from_rgb_value_8(value_9_11, value_10_9, value_11_11)
            image_label_value_7.ImageColor3 = from_rgb_result_8
        end

        return
    end
    captured_value_23 = require_result
    closure_ready_13 = true
end
local on_duel_started
do
    local captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, closure_ready_14
    on_duel_started = function(argument_1_6)
        if not closure_ready_14 then
            return
        end
        table_21 = {}
        local value_4_59
        if value_34 == nil then
            local event_value = captured_value_24.PlayerDataChanged.Event
            value_4_59 = captured_value_25
            value_34 = (event_value:Connect(value_4_59))
        end
        local value_2_44: string?
        if argument_1_6.Team1[game.Players.LocalPlayer.Name] then
            value_2_44 = "Team1"
        else
            value_2_44 = "Team2"
        end
        local value_3_56 = argument_1_6[value_2_44]
        value_4_59 = nil
        local game_value_9 = nil
        local game_value_10, value_10_10, value_11_12, value_6_40, value_7_34, value_9_12
        for key_9, value_31 in value_3_56, value_4_59, game_value_9 do
            value_6_40, value_7_34 = key_9, value_31
            game_value_10 = game.Players
            value_10_10 = value_6_40
            game_value_10 = game_value_10:FindFirstChild(value_10_10)
            if not game_value_10 then
                continue
            end
            if game_value_10 == game.Players.LocalPlayer then
                continue
            end
            if not game_value_10.Character then
                continue
            end
            value_9_12 = game_value_10.Character
            value_11_12 = "HumanoidRootPart"
            value_9_12 = value_9_12:FindFirstChild(value_11_12)
            if not value_9_12 then
                continue
            end
            game_value_10 = (script.TeamMate:Clone())
            value_10_10 = true
            game_value_10.Enabled = value_10_10
            game_value_10.Parent = value_9_12
        end
        value_3_56, value_4_59, game_value_9 = captured_value_26:GetChildren()
        for key_10, value_32 in value_3_56, value_4_59, game_value_9 do
            value_6_40, value_7_34 = key_10, value_32
            value_10_10 = "Frame"
            game_value_10 = value_7_34:IsA(value_10_10)
            if not game_value_10 then
                continue
            end
            value_7_34:Destroy()
        end
        value_3_56, value_4_59, game_value_9 = captured_value_27:GetChildren()
        for key_11, value_33 in value_3_56, value_4_59, game_value_9 do
            value_6_40, value_7_34 = key_11, value_33
            value_10_10 = "Frame"
            game_value_10 = value_7_34:IsA(value_10_10)
            if not game_value_10 then
                continue
            end
            value_7_34:Destroy()
        end
        value_3_56 = argument_1_6
        value_4_59 = nil
        game_value_9 = nil
        for key_13, value_36 in value_3_56, value_4_59, game_value_9 do
            value_6_40, value_7_34 = key_13, value_36
            game_value_10 = value_7_34
            value_9_12 = nil
            value_10_10 = nil
            for key_12, value_35 in game_value_10, value_9_12, value_10_10 do
                local value_12_9
                value_11_12, value_12_9 = key_12, value_35
                local game_value_11: DataModel = game
                local players_value_7 = game_value_11.Players
                local value_15_4 = value_11_12
                local find_first_child_result = players_value_7:FindFirstChild(value_15_4)
                local value_2_45 = find_first_child_result
                if not value_2_45 then
                    continue
                end
                local value_13_8 = captured_value_28
                local cloned_value_3 = value_13_8:Clone()
                cloned_value_3.Name = value_11_12
                local player_name_value = cloned_value_3.PlayerName
                player_name_value.Text = value_11_12
                local image_label_value_8 = cloned_value_3.ImageLabel
                local user_id_value_4 = value_2_45.UserId
                local abs_value_4 = math.abs
                local abs_result_4 = abs_value_4(user_id_value_4)
                local game_value_12: DataModel = game
                local players_value_8 = game_value_12.Players
                local value_19_3 = abs_result_4
                local avatar_bust_value_4 = Enum.ThumbnailType.AvatarBust
                local size100x100_value_4 = Enum.ThumbnailSize.Size100x100
                local get_user_thumbnail_async_result_3 = players_value_8:GetUserThumbnailAsync(
                    value_19_3,
                    avatar_bust_value_4,
                    size100x100_value_4
                )
                local value_15_5 = get_user_thumbnail_async_result_3
                image_label_value_8.Image = value_15_5
                local weapons_value = cloned_value_3.Weapons
                local knife_value_13 = weapons_value.Knife
                local knife_value_14 = value_12_9.Knife
                local value_15_6: boolean?
                if knife_value_14 ~= true then
                    value_15_6 = false
                else
                    value_15_6 = true
                end
                knife_value_13.Visible = value_15_6
                local weapons_value_2 = cloned_value_3.Weapons
                local gun_value_13 = weapons_value_2.Gun
                local gun_value_14 = value_12_9.Gun
                local value_15_7: boolean?
                if gun_value_14 ~= true then
                    value_15_7 = false
                else
                    value_15_7 = true
                end
                gun_value_13.Visible = value_15_7
                local value_14_6
                do
                    local take_fallback = value_6_40 ~= "Team1"
                    if not take_fallback then
                        value_14_6 = captured_value_26
                        take_fallback = not value_14_6
                    end
                    if take_fallback then
                        value_14_6 = captured_value_27
                    end
                end
                cloned_value_3.Parent = value_14_6
                local value_14_7 = table_21
                value_14_7[value_11_12] = cloned_value_3
            end
        end
        value_3_56 = captured_value_29
        value_4_59 = true
        value_3_56.Visible = value_4_59
        value_3_56 = captured_value_30
        value_4_59 = true
        value_3_56.Visible = value_4_59
        value_3_56 = captured_value_31
        value_4_59 = true
        value_3_56.Visible = value_4_59
        value_3_56 = os.clock()
        while true do
            if not ((os.clock()) - value_3_56 < 10) then
                break
            end
            game_value_9 = (os.clock()) - value_3_56
            value_4_59 = math.ceil(game_value_9)
            game_value_9 = captured_value_30.Timer
            value_7_34 = 10 - value_4_59
            value_6_40 = value_7_34 + 1
            game_value_9.Text = value_6_40
            game_value_9 = task.wait
            game_value_9()
        end
        value_4_59 = captured_value_30
        game_value_9 = false
        value_4_59.Visible = game_value_9

        return
    end
    captured_value_24, captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31 = require_result, on_player_data_updated, team1_child, team2_child, round_player_child, duel_round_child, value_1, duel_display_child
    closure_ready_14 = true
end
local on_duel_submitted
do
    local captured_value_32, captured_value_33, captured_value_34 = table_19, container_child, remotes_child
    if closure_cache[17] ~= nil and same_capture(closure_cache[18], captured_value_32) and same_capture(
        closure_cache[19],
        captured_value_33
    ) and same_capture(closure_cache[20], captured_value_34) then
        on_duel_submitted = closure_cache[17]
    else
        local closure_ready_15
        on_duel_submitted = function()
            if not closure_ready_15 then
                return
            end
            local table_1 = {[("Team1")] = nil, [("Team1")] = nil}
            local table_2_2 = {}
            table_1.Team1 = table_2_2
            table_2_2 = {}
            table_1.Team2 = table_2_2
            table_2_2 = captured_value_32.Team1
            local value_3_57: boolean? = nil
            local value_4_60 = nil
            local value_5_47, value_6_41
            for key_14, value_37 in table_2_2, value_3_57, value_4_60 do
                value_5_47, value_6_41 = key_14, value_37
                local team1_value_14 = table_1.Team1
                local name_value_3 = value_5_47.Name
                local table_9 = {Knife = 0, Gun = 0}
                local knife_value_15 = value_6_41.Knife
                local value_12_10: string = "Enabled"
                local enabled_value_3 = knife_value_15:GetAttribute(value_12_10)
                table_9.Knife = enabled_value_3
                local gun_value_15 = value_6_41.Gun
                local value_12_11: string = "Enabled"
                local enabled_value_4 = gun_value_15:GetAttribute(value_12_11)
                table_9.Gun = enabled_value_4
                team1_value_14[name_value_3] = table_9
            end
            table_2_2 = captured_value_32.Team2
            value_3_57 = nil
            value_4_60 = nil
            for key_15, value_38 in table_2_2, value_3_57, value_4_60 do
                value_5_47, value_6_41 = key_15, value_38
                local team2_value_13 = table_1.Team2
                local name_value_4 = value_5_47.Name
                local table_9_2 = {Knife = 0, Gun = 0}
                local knife_value_16 = value_6_41.Knife
                local value_12_12: string = "Enabled"
                local enabled_value_5 = knife_value_16:GetAttribute(value_12_12)
                table_9_2.Knife = enabled_value_5
                local gun_value_16 = value_6_41.Gun
                local value_12_13: string = "Enabled"
                local enabled_value_6 = gun_value_16:GetAttribute(value_12_13)
                table_9_2.Gun = enabled_value_6
                team2_value_13[name_value_4] = table_9_2
            end
            table_2_2 = captured_value_33
            value_3_57 = false
            table_2_2.Visible = value_3_57
            table_2_2 = captured_value_34.CustomGames.SubmitDuel
            value_4_60 = table_1
            table_2_2:FireServer(value_4_60)

            return
        end
        closure_ready_15 = true
        if closure_cache[17] == nil then
            closure_cache[17] = on_duel_submitted
            closure_cache[18], closure_cache[19], closure_cache[20] = captured_value_32, captured_value_33, captured_value_34
        end
    end
end
local image_button_value = close_child.ImageButton.Activated
local value_40
do
    local captured_value_35 = container_child
    if closure_cache[21] ~= nil and same_capture(closure_cache[22], captured_value_35) then
        value_40 = closure_cache[21]
    else
        local closure_ready_16
        value_40 = function(): ()
            if not closure_ready_16 then
                return
            end
            local value_1_18 = captured_value_35
            local value_2_46: boolean = false
            value_1_18.Visible = value_2_46

            return
        end
        closure_ready_16 = true
        if closure_cache[21] == nil then
            closure_cache[21] = value_40
            closure_cache[22] = captured_value_35
        end
    end
end
image_button_value:Connect(value_40)
local value_41
if invoke_server_result then
    local value_39
    image_button_value, value_39, value_40 = settings_child:GetChildren()
    local value_42
    for key_19, value_49 in image_button_value, value_39, value_40 do
        value_41, value_42 = key_19, value_49
        local value_45: string = "Frame"
        local is_a_result = value_42:IsA(value_45)
        if not is_a_result then
            continue
        end
        local button_value = value_42.Button
        local activated_value = button_value.Activated
        local value_45_2
        do
            local captured_value_36, captured_value_37, captured_value_38, captured_value_39, closure_ready_17
            value_45_2 = function(): ()
                if not closure_ready_17 then
                    return
                end
                value_24 = captured_value_36.Name
                local value_1_19, value_2_47, value_3_58 = captured_value_37:GetChildren()
                local value_4_61, value_5_48, value_6_42, value_7_35, value_8_13
                for key_16, value_46 in value_1_19, value_2_47, value_3_58 do
                    value_4_61, value_5_48 = key_16, value_46
                    value_8_13 = "Frame"
                    if not (value_5_48:IsA(value_8_13)) then
                        continue
                    end
                    value_6_42 = value_5_48.Button
                    value_8_13 = captured_value_36
                    do
                        local take_fallback_2 = value_5_48 ~= value_8_13
                        if not take_fallback_2 then
                            value_7_35 = Enum.ButtonStyle.RobloxRoundDefaultButton
                            take_fallback_2 = not value_7_35
                        end
                        if take_fallback_2 then
                            value_7_35 = Enum.ButtonStyle.RobloxRoundButton
                        end
                    end
                    value_6_42.Style = value_7_35
                end
                value_1_19 = captured_value_38
                value_2_47 = nil
                value_3_58 = nil
                for key_18, value_48 in value_1_19, value_2_47, value_3_58 do
                    value_4_61, value_5_48 = key_18, value_48
                    value_6_42 = value_5_48
                    value_7_35 = nil
                    value_8_13 = nil
                    for key_17, value_47 in value_6_42, value_7_35, value_8_13 do
                        local value_9_13, value_10_15 = key_17, value_47
                        local value_11_17 = captured_value_39
                        local value_12_14 = value_10_15
                        value_11_17(value_12_14)
                    end
                end

                return
            end
            captured_value_36, captured_value_37, captured_value_38, captured_value_39 = value_42, settings_child, table_19, update_weapons_for_mode
            closure_ready_17 = true
        end
        activated_value:Connect(value_45_2)
    end
    image_button_value = start_child.ImageButton.Activated
    value_40 = on_duel_submitted
    image_button_value:Connect(value_40)
    image_button_value = teams_child.Team1.Container.Players.InputBegan
    do
        local captured_value_40, captured_value_41, captured_value_42, closure_ready_18
        value_40 = function(argument_1_7)
            if not closure_ready_18 then
                return
            end
            local user_input_type_value = argument_1_7.UserInputType
            local mouse_button1_value = Enum.UserInputType.MouseButton1
            if user_input_type_value ~= mouse_button1_value then
                local user_input_type_value_2 = argument_1_7.UserInputType
                mouse_button1_value = Enum.UserInputType.Touch
                if user_input_type_value_2 ~= mouse_button1_value then
                    return
                end
            end
            if value_17 then
                local value_2_49 = value_17
                local game_value_13 = game.Players
                if (value_2_49:IsDescendantOf(game_value_13)) then
                    local value_2_51: number = 0
                    local value_6_43 = captured_value_40
                    mouse_button1_value = value_6_43.Team1
                    game_value_13 = nil
                    local value_5_49: nil = nil
                    for key_20, value_50 in mouse_button1_value, game_value_13, value_5_49 do
                        local value_7_36
                        value_6_43, value_7_36 = key_20, value_50
                        value_2_51 = value_2_51 + 1
                    end
                    if value_2_51 < 4 then
                        captured_value_41(value_17, "Team1")
                        captured_value_42()
                        value_17 = nil
                    end
                end
            end

            return
        end
        captured_value_40, captured_value_41, captured_value_42 = table_19, add_player_to_team, reset_selection
        closure_ready_18 = true
    end
    image_button_value:Connect(value_40)
    image_button_value = teams_child.Team2.Container.Players.InputBegan
    do
        local captured_value_43, captured_value_44, captured_value_45, closure_ready_19
        value_40 = function(argument_1_8)
            if not closure_ready_19 then
                return
            end
            local user_input_type_value_3 = argument_1_8.UserInputType
            local mouse_button1_value_2 = Enum.UserInputType.MouseButton1
            if user_input_type_value_3 ~= mouse_button1_value_2 then
                local user_input_type_value_4 = argument_1_8.UserInputType
                mouse_button1_value_2 = Enum.UserInputType.Touch
                if user_input_type_value_4 ~= mouse_button1_value_2 then
                    return
                end
            end
            if value_17 then
                local value_2_56 = value_17
                local game_value_14 = game.Players
                if (value_2_56:IsDescendantOf(game_value_14)) then
                    local value_2_58: number = 0
                    local value_6_44 = captured_value_43
                    mouse_button1_value_2 = value_6_44.Team2
                    game_value_14 = nil
                    local value_5_50: nil = nil
                    for key_21, value_51 in mouse_button1_value_2, game_value_14, value_5_50 do
                        local value_7_37
                        value_6_44, value_7_37 = key_21, value_51
                        value_2_58 = value_2_58 + 1
                    end
                    if value_2_58 < 4 then
                        captured_value_44(value_17, "Team2")
                        captured_value_45()
                        value_17 = nil
                    end
                end
            end

            return
        end
        captured_value_43, captured_value_44, captured_value_45 = table_19, add_player_to_team, reset_selection
        closure_ready_19 = true
    end
    image_button_value:Connect(value_40)
    image_button_value, value_39, value_40 = container_child_2:GetChildren()
    for key_22, value_52 in image_button_value, value_39, value_40 do
        value_41, value_42 = key_22, value_52
        local value_45_3: string = "Frame"
        local is_a_result_2 = value_42:IsA(value_45_3)
        if not is_a_result_2 then
            continue
        end
        value_42:Destroy()
    end
    image_button_value, value_39, value_40 = teams_child.Team1.Container.Players:GetChildren()
    for key_23, value_53 in image_button_value, value_39, value_40 do
        value_41, value_42 = key_23, value_53
        local value_45_4: string = "Frame"
        local is_a_result_3 = value_42:IsA(value_45_4)
        if not is_a_result_3 then
            continue
        end
        value_42:Destroy()
    end
    image_button_value, value_39, value_40 = teams_child.Team2.Container.Players:GetChildren()
    for key_24, value_54 in image_button_value, value_39, value_40 do
        value_41, value_42 = key_24, value_54
        local value_45_5: string = "Frame"
        local is_a_result_4 = value_42:IsA(value_45_5)
        if not is_a_result_4 then
            continue
        end
        value_42:Destroy()
    end
    update_player_list()
    image_button_value = game.Players.PlayerAdded
    do
        local captured_value_46, captured_value_47 = update_player_list, update_team_frames
        if closure_cache[23] ~= nil and same_capture(closure_cache[24], captured_value_46) and same_capture(
            closure_cache[25],
            captured_value_47
        ) then
            value_40 = closure_cache[23]
        else
            local closure_ready_20
            value_40 = function()
                if not closure_ready_20 then
                    return
                end
                captured_value_46()
                captured_value_47()

                return
            end
            closure_ready_20 = true
            if closure_cache[23] == nil then
                closure_cache[23] = value_40
                closure_cache[24], closure_cache[25] = captured_value_46, captured_value_47
            end
        end
    end
    image_button_value:Connect(value_40)
    image_button_value = game.Players.PlayerRemoving
    do
        local captured_value_48, captured_value_49 = update_player_list, update_team_frames
        if closure_cache[26] ~= nil and same_capture(closure_cache[27], captured_value_48) and same_capture(
            closure_cache[28],
            captured_value_49
        ) then
            value_40 = closure_cache[26]
        else
            local closure_ready_21
            value_40 = function()
                if not closure_ready_21 then
                    return
                end
                captured_value_48()
                captured_value_49()

                return
            end
            closure_ready_21 = true
            if closure_cache[26] == nil then
                closure_cache[26] = value_40
                closure_cache[27], closure_cache[28] = captured_value_48, captured_value_49
            end
        end
    end
    image_button_value:Connect(value_40)
end
image_button_value = false
duel_round_child.Visible = image_button_value
image_button_value = remotes_child.CustomGames.DuelKill.OnClientEvent
value_40 = function(argument_1_9: string, argument_2_2: string, argument_3: string): ()
    return
end
image_button_value:Connect(value_40)
image_button_value = remotes_child.Gameplay.RoundEndFade.OnClientEvent
do
    local captured_value_50 = duel_round_child
    if closure_cache[29] ~= nil and same_capture(closure_cache[30], captured_value_50) then
        value_40 = closure_cache[29]
    else
        local closure_ready_22
        value_40 = function(): ()
            if not closure_ready_22 then
                return
            end
            local value_1_24 = captured_value_50
            local value_2_62: boolean = false
            value_1_24.Visible = value_2_62

            return
        end
        closure_ready_22 = true
        if closure_cache[29] == nil then
            closure_cache[29] = value_40
            closure_cache[30] = captured_value_50
        end
    end
end
image_button_value:Connect(value_40)
value_40 = "CustomGames"
image_button_value = remotes_child:WaitForChild(value_40)
value_40 = "DuelStarted"
image_button_value = image_button_value:WaitForChild(value_40).OnClientEvent
value_40 = on_duel_started
image_button_value:Connect(value_40)
value_40 = container_child
value_41 = "DuelSetup"
require_result_2:RegisterFrame(value_40, value_41)

return
