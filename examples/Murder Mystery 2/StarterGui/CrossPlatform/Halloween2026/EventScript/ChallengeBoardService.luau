--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("OnCellUpdated")] = nil,
    [("OnCellUpdated")] = nil,
    [("OnCellUpdated")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "Types"
local types_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "EventType"
local require_result = require_value(types_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_5_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5_4)
local value_5_5: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_5)
local value_5_6: string = "EventInfoService"
local wait_for_initialized_async_result = require_value_2(shared_services_child:WaitForChild(
    value_5_6
)):WaitForInitializedAsync()
local require_value_3 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "ItemService"
local require_result_3 = require_value_3(client_services_child:WaitForChild(value_6_3))
local require_value_4 = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "ProfileData"
local require_result_4 = require_value_4(modules_child:WaitForChild(value_7_3))
local require_value_5 = require
local parent_value: Instance? = script.Parent
local value_8: string = "NavigationService"
local require_result_5 = require_value_5(parent_value:WaitForChild(value_8))
local from_rgb_result: Color3 = Color3.fromRGB(100, 150, 200)
local from_rgb_result_2: Color3 = Color3.fromRGB(0, 0, 0)
local table_8 = {Sheriff = Color3.fromRGB(65, 120, 255)}
local get_main_event_result = wait_for_initialized_async_result:GetMainEvent()
local game_value_5: DataModel = game
local value_12_2: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_12_2)
local value_12_3: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_5:WaitForChild(value_12_3)
local value_12_4: string = "Events"
local events_child = remotes_child:WaitForChild(value_12_4)
local value_12_5 = get_main_event_result.Title .. "Remotes"
local value_2_2 = (events_child:WaitForChild(value_12_5))
local parent_value_3 = script.Parent.Parent
local value_13: string = "MainEvent"
local main_event_child = parent_value_3:WaitForChild(value_13)
local value_13_2: string = "Main"
local main_child = main_event_child:WaitForChild(value_13_2)
local value_14_2: string = "QuestBoard"
local value_10_8 = (main_child:WaitForChild(value_14_2))
local value_13_4: string = "Main"
local main_child_2 = value_10_8:WaitForChild(value_13_4)
local value_14_3: string = "Challenges"
local challenges_child = main_child_2:WaitForChild(value_14_3)
local value_15: string = "Tutorial"
local tutorial_child = main_child_2:WaitForChild(value_15)
local value_16: string? = "TextBubble"
local value_11_9 = (tutorial_child:WaitForChild(value_16))
value_16 = "ChallengeDetails"
local challenge_details_child = tutorial_child:WaitForChild(value_16)
local table_13 = {}
local table_15 = {}
value_16 = nil

local function on_cell_updated(argument_1, argument_2: string, argument_3: number, argument_4: number, argument_5: boolean): ()
    local container_value = argument_1.Container
    local value_8_4: string = "Complete"
    local complete_child = container_value:FindFirstChild(value_8_4)
    if complete_child then
        complete_child.Visible = argument_5
    end

    return
end

table_1.OnCellUpdated = on_cell_updated

local function on_reward_updated(argument_1_2, argument_2_2: string, argument_3_2: number, argument_4_2: number, argument_5_2: boolean): ()
    local item_value = argument_1_2.Item
    local value_8_5: string = "Locked"
    local locked_child = item_value:FindFirstChild(value_8_5)
    if locked_child then
        local value_7_8: boolean = not argument_5_2
        locked_child.Visible = value_7_8
    end

    return
end

table_1.OnRewardUpdated = on_reward_updated
do
    local captured_value = get_main_event_result

    local function get_board()
        return captured_value.EventStartInfo.ChallengeBoard
    end
end
do
    local captured_value_2 = get_main_event_result

    local function get_quest_info(argument_1_3: string)
        return captured_value_2.EventStartInfo.Quests[argument_1_3]
    end
end
do
    local captured_value_3 = get_main_event_result

    local function get_max_progress(argument_1_4: string)
        local value_2_4 = captured_value_3.EventStartInfo.Quests[argument_1_4]

        return value_2_4.Quests[#value_2_4.Quests].ChallengeAmount
    end
end
do
    local captured_value_4, captured_value_5 = require_result_4, get_main_event_result

    local function get_progress(argument_1_5: string)
        local value_2_5 = captured_value_4[captured_value_5.Title]
        local quests_value_5 = value_2_5.Quests
        if quests_value_5 then
            quests_value_5 = value_2_5.Quests[argument_1_5]
        end
        local progress_value
        do
            local take_fallback = not quests_value_5
            if not take_fallback then
                progress_value = quests_value_5.Progress
                take_fallback = not progress_value
            end
            if take_fallback then
                progress_value = 0
            end
        end

        return progress_value
    end
end
do
    local captured_value_6, captured_value_7 = require_result_4, get_main_event_result

    local function is_completed(argument_1_6: string): boolean
        local value_4_11 = captured_value_6[captured_value_7.Title]
        local quests_value_7 = value_4_11.Quests
        if quests_value_7 then
            quests_value_7 = value_4_11.Quests[argument_1_6]
        end
        local progress_value_2
        do
            local take_fallback_2 = not quests_value_7
            if not take_fallback_2 then
                progress_value_2 = quests_value_7.Progress
                take_fallback_2 = not progress_value_2
            end
            if take_fallback_2 then
                progress_value_2 = 0
            end
        end
        local value_5_15 = captured_value_7.EventStartInfo.Quests[argument_1_6]
        local value_2_6: boolean?
        if not (value_5_15.Quests[#value_5_15.Quests].ChallengeAmount <= progress_value_2) then
            value_2_6 = false
        else
            value_2_6 = true
        end

        return value_2_6
    end
end
local update_details
do
    local captured_value_8, captured_value_9, captured_value_10, captured_value_11, captured_value_12 = get_main_event_result, require_result_4, table_13, challenge_details_child, table_8
    update_details = function(argument_1_7: string)
        local value_2_7 = captured_value_8.EventStartInfo.ChallengeBoard.Cells[argument_1_7]
        local value_3_13 = captured_value_8.EventStartInfo.Quests[value_2_7]
        local value_5_16 = captured_value_9[captured_value_8.Title]
        local quests_value_13 = value_5_16.Quests
        if quests_value_13 then
            quests_value_13 = value_5_16.Quests[value_2_7]
        end
        local progress_value_3
        do
            local take_fallback_3 = not quests_value_13
            if not take_fallback_3 then
                progress_value_3 = quests_value_13.Progress
                take_fallback_3 = not progress_value_3
            end
            if take_fallback_3 then
                progress_value_3 = 0
            end
        end
        local value_6_13 = captured_value_8.EventStartInfo.Quests[value_2_7]
        local challenge_amount_value_3 = value_6_13.Quests[#value_6_13.Quests].ChallengeAmount
        local value_2_8 = captured_value_10[argument_1_7]
        local value_6_15 = captured_value_11
        local value_8_7: string = "Container"
        local container_child = value_6_15:WaitForChild(value_8_7)
        local value_9_4: string = "Border"
        local border_child = container_child:WaitForChild(value_9_4)
        local background_color3_value = value_2_8.Container.Border.BackgroundColor3
        border_child.BackgroundColor3 = background_color3_value
        local value_9_5: string = "Container"
        local container_child_2 = container_child:WaitForChild(value_9_5)
        local value_9_6: string = "ImageLabel"
        local image_label_child = container_child_2:WaitForChild(value_9_6)
        local image_value = value_2_8.Container.Container.ImageLabel.Image
        image_label_child.Image = image_value
        local container_value_5 = container_child.Container
        local value_9_7: string = "Details"
        local details_child = container_value_5:WaitForChild(value_9_7)
        local value_10_9: string = "Title"
        local value_6_17 = (details_child:WaitForChild(value_10_9))
        local title_value_5 = value_3_13.Title
        value_6_17.Text = title_value_5
        local value_8_13 = captured_value_12[value_3_13.Role]
        if not value_8_13 then
            value_8_13 = value_2_8.Container.Border.BackgroundColor3
        end
        value_6_17.TextColor3 = value_8_13
        local description_value = value_3_13.Description
        if 1 < challenge_amount_value_3 then
            local value_8_15 = description_value
            local value_9_10: string = " (%*/%*)"
            local value_12_11 = progress_value_3
            local value_13_7 = challenge_amount_value_3
            local min_result = math.min(value_12_11, value_13_7)
            local value_12_12 = challenge_amount_value_3
            description_value = value_8_15 .. (value_9_10:format(min_result, value_12_12))
        end
        local value_10_11: string = "Body"
        local body_child = details_child:WaitForChild(value_10_11)
        body_child.Text = description_value

        return
    end
end
local select_cell
do
    local captured_value_13, captured_value_14, captured_value_15, captured_value_16, captured_value_17, captured_value_18 = table_13, from_rgb_result, from_rgb_result_2, value_11_9, challenge_details_child, update_details
    select_cell = function(argument_1_8: string?)
        value_16 = argument_1_8
        local value_2_9 = captured_value_13
        local value_3_14: boolean? = nil
        local value_4_14: nil = nil
        for key, value in value_2_9, value_3_14, value_4_14 do
            local value_5_18, value_6_18 = key, value
            local container_value_7 = value_6_18.Container
            local ui_stroke_value = container_value_7.UIStroke
            local value_8_17: Color3?
            do
                local take_fallback_4 = value_5_18 ~= argument_1_8
                if not take_fallback_4 then
                    value_8_17 = captured_value_14
                    take_fallback_4 = not value_8_17
                end
                if take_fallback_4 then
                    value_8_17 = captured_value_15
                end
            end
            ui_stroke_value.Color = value_8_17
        end
        value_2_9 = captured_value_16
        if argument_1_8 ~= nil then
            value_3_14 = false
        else
            value_3_14 = true
        end
        value_2_9.Visible = value_3_14
        value_2_9 = captured_value_17
        if argument_1_8 == nil then
            value_3_14 = false
        else
            value_3_14 = true
        end
        value_2_9.Visible = value_3_14
        if argument_1_8 then
            captured_value_18(argument_1_8)
        end

        return
    end
end
local update_cell
do
    local captured_value_19, captured_value_20, captured_value_21, captured_value_22, captured_value_23 = get_main_event_result, table_1, table_13, require_result_4, update_details
    update_cell = function(argument_1_9: string)
        local value_2_10 = captured_value_19.EventStartInfo.ChallengeBoard.Cells[argument_1_9]
        local on_cell_updated_value = captured_value_20.OnCellUpdated
        local value_4_15 = captured_value_21[argument_1_9]
        local value_5_20 = value_2_10
        local value_7_17 = captured_value_22[captured_value_19.Title]
        local quests_value_18 = value_7_17.Quests
        if quests_value_18 then
            quests_value_18 = value_7_17.Quests[value_2_10]
        end
        local progress_value_4
        do
            local take_fallback_5 = not quests_value_18
            if not take_fallback_5 then
                progress_value_4 = quests_value_18.Progress
                take_fallback_5 = not progress_value_4
            end
            if take_fallback_5 then
                progress_value_4 = 0
            end
        end
        local value_8_19 = captured_value_19.EventStartInfo.Quests[value_2_10]
        local challenge_amount_value_4 = value_8_19.Quests[#value_8_19.Quests].ChallengeAmount
        local value_10_13 = captured_value_22[captured_value_19.Title]
        local quests_value_23 = value_10_13.Quests
        if quests_value_23 then
            quests_value_23 = value_10_13.Quests[value_2_10]
        end
        local progress_value_5
        do
            local take_fallback_6 = not quests_value_23
            if not take_fallback_6 then
                progress_value_5 = quests_value_23.Progress
                take_fallback_6 = not progress_value_5
            end
            if take_fallback_6 then
                progress_value_5 = 0
            end
        end
        local value_11_11 = captured_value_19.EventStartInfo.Quests[value_2_10]
        local value_8_20: boolean?
        if not (value_11_11.Quests[#value_11_11.Quests].ChallengeAmount <= progress_value_5) then
            value_8_20 = false
        else
            value_8_20 = true
        end
        on_cell_updated_value(
            value_4_15,
            value_5_20,
            progress_value_4,
            challenge_amount_value_4,
            value_8_20
        )
        if value_16 == argument_1_9 then
            captured_value_23(argument_1_9)
        end

        return
    end
end
do
    local captured_value_24, captured_value_25, captured_value_26, captured_value_27 = get_main_event_result, table_1, table_15, require_result_4

    local function update_reward(argument_1_10: string)
        local value_2_11 = captured_value_24.EventStartInfo.ChallengeBoard.Rewards[argument_1_10]
        local on_reward_updated_value = captured_value_25.OnRewardUpdated
        local value_4_17 = captured_value_26[argument_1_10]
        local value_5_22 = value_2_11
        local value_7_19 = captured_value_27[captured_value_24.Title]
        local quests_value_28 = value_7_19.Quests
        if quests_value_28 then
            quests_value_28 = value_7_19.Quests[value_2_11]
        end
        local progress_value_6
        do
            local take_fallback_7 = not quests_value_28
            if not take_fallback_7 then
                progress_value_6 = quests_value_28.Progress
                take_fallback_7 = not progress_value_6
            end
            if take_fallback_7 then
                progress_value_6 = 0
            end
        end
        local value_8_22 = captured_value_24.EventStartInfo.Quests[value_2_11]
        local challenge_amount_value_6 = value_8_22.Quests[#value_8_22.Quests].ChallengeAmount
        local value_10_16 = captured_value_27[captured_value_24.Title]
        local quests_value_33 = value_10_16.Quests
        if quests_value_33 then
            quests_value_33 = value_10_16.Quests[value_2_11]
        end
        local progress_value_7
        do
            local take_fallback_8 = not quests_value_33
            if not take_fallback_8 then
                progress_value_7 = quests_value_33.Progress
                take_fallback_8 = not progress_value_7
            end
            if take_fallback_8 then
                progress_value_7 = 0
            end
        end
        local value_11_13 = captured_value_24.EventStartInfo.Quests[value_2_11]
        local value_8_23: boolean?
        if not (value_11_13.Quests[#value_11_13.Quests].ChallengeAmount <= progress_value_7) then
            value_8_23 = false
        else
            value_8_23 = true
        end
        on_reward_updated_value(
            value_4_17,
            value_5_22,
            progress_value_6,
            challenge_amount_value_6,
            value_8_23
        )

        return
    end
end
local setup_cell
do
    local captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36 = challenges_child, get_main_event_result, table_13, from_rgb_result, from_rgb_result_2, value_11_9, challenge_details_child, select_cell, update_cell
    setup_cell = function(argument_1_11: string, argument_2_3: string)
        local value_3_21 = captured_value_28
        local value_5_23: string = argument_1_11
        local value_3_23 = value_3_21:WaitForChild(value_5_23)
        local value_4_19 = captured_value_29.EventStartInfo.Quests[argument_2_3]
        local value_5_25 = captured_value_30
        value_5_25[argument_1_11] = value_3_23
        local value_5_26 = captured_value_29.EventStartInfo.ChallengeBoard.RoleColors[value_4_19.Role]
        if value_5_26 then
            local border_value_3 = value_3_23.Container.Border
            border_value_3.BackgroundColor3 = value_5_26
        end
        local activated_value = value_3_23.ActionButton.Activated
        local value_8_24: (() -> ())?
        do
            local captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43, closure_ready
            value_8_24 = function(): ()
                if not closure_ready then
                    return
                end
                local value_1_2 = value_16
                local value_2_12: nil | boolean | string = captured_value_37
                if value_1_2 == value_2_12 then
                    value_16 = nil
                    value_1_2 = captured_value_38
                    value_2_12 = nil
                    local value_3_24: nil = nil
                    for key_2, value_17 in value_1_2, value_2_12, value_3_24 do
                        local value_4_20, value_5_27 = key_2, value_17
                        local container_value_9 = value_5_27.Container
                        local ui_stroke_value_2 = container_value_9.UIStroke
                        local value_7_23: Color3?
                        do
                            local take_fallback_9 = value_4_20 ~= nil
                            if not take_fallback_9 then
                                value_7_23 = captured_value_39
                                take_fallback_9 = not value_7_23
                            end
                            if take_fallback_9 then
                                value_7_23 = captured_value_40
                            end
                        end
                        ui_stroke_value_2.Color = value_7_23
                    end
                    value_1_2 = captured_value_41
                    value_2_12 = true
                    value_1_2.Visible = value_2_12
                    value_1_2 = captured_value_42
                    value_2_12 = false
                    value_1_2.Visible = value_2_12

                    return
                end
                captured_value_43(captured_value_37)

                return
            end
            captured_value_37, captured_value_38, captured_value_39, captured_value_40, captured_value_41, captured_value_42, captured_value_43 = argument_1_11, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35
            closure_ready = true
        end
        activated_value:Connect(value_8_24)
        captured_value_36(argument_1_11)

        return
    end
end
local setup_reward
do
    local captured_value_44, captured_value_45, captured_value_46, captured_value_47, captured_value_48, captured_value_49 = challenges_child, table_15, get_main_event_result, require_result_3, table_1, require_result_4
    setup_reward = function(argument_1_12: string, argument_2_4: string)
        local value_3_25 = captured_value_44
        local value_5_28: string = argument_1_12
        local value_3_27 = value_3_25:WaitForChild(value_5_28)
        local value_4_22 = captured_value_45
        value_4_22[argument_1_12] = value_3_27
        local value_4_23 = captured_value_46.EventStartInfo.Quests[argument_2_4].Quests[1]
        local value_5_30 = captured_value_47
        local reward_id_value = value_4_23.RewardID
        local reward_type_value = value_4_23.RewardType
        local get_display_info_result = value_5_30:GetDisplayInfo(
            reward_id_value,
            reward_type_value
        )
        local icon_value = value_3_27.Item.Icon
        local image_value_2 = get_display_info_result.Image
        icon_value.Image = image_value_2
        local value_6_24 = value_4_23.RewardAmount or 1
        local text_label_value = value_3_27.Item.TextLabel
        local value_9_17: number = 1
        local format_result_2
        do
            local take_fallback_10 = not (value_9_17 < value_6_24)
            if not take_fallback_10 then
                local value_8_25: string = "%* x%*"
                local name_value = get_display_info_result.Name
                local value_11_14 = value_6_24
                format_result_2 = value_8_25:format(name_value, value_11_14)
                take_fallback_10 = not format_result_2
            end
            if take_fallback_10 then
                format_result_2 = get_display_info_result.Name
            end
        end
        text_label_value.Text = format_result_2
        local value_6_25 = captured_value_46.EventStartInfo.ChallengeBoard.Rewards[argument_1_12]
        local on_reward_updated_value_2 = captured_value_48.OnRewardUpdated
        local value_8_27 = captured_value_45[argument_1_12]
        local value_9_20 = value_6_25
        local value_5_32 = captured_value_49[captured_value_46.Title]
        local quests_value_41 = value_5_32.Quests
        if quests_value_41 then
            quests_value_41 = value_5_32.Quests[value_6_25]
        end
        local progress_value_8
        do
            local take_fallback_11 = not quests_value_41
            if not take_fallback_11 then
                progress_value_8 = quests_value_41.Progress
                take_fallback_11 = not progress_value_8
            end
            if take_fallback_11 then
                progress_value_8 = 0
            end
        end
        local value_3_28 = captured_value_46.EventStartInfo.Quests[value_6_25]
        local challenge_amount_value_8 = value_3_28.Quests[#value_3_28.Quests].ChallengeAmount
        local value_14_7 = captured_value_49[captured_value_46.Title]
        local quests_value_46 = value_14_7.Quests
        if quests_value_46 then
            quests_value_46 = value_14_7.Quests[value_6_25]
        end
        local progress_value_9
        do
            local take_fallback_12 = not quests_value_46
            if not take_fallback_12 then
                progress_value_9 = quests_value_46.Progress
                take_fallback_12 = not progress_value_9
            end
            if take_fallback_12 then
                progress_value_9 = 0
            end
        end
        local value_15_5 = captured_value_46.EventStartInfo.Quests[value_6_25]
        local value_12_19: boolean?
        if not (value_15_5.Quests[#value_15_5.Quests].ChallengeAmount <= progress_value_9) then
            value_12_19 = false
        else
            value_12_19 = true
        end
        on_reward_updated_value_2(
            value_8_27,
            value_9_20,
            progress_value_8,
            challenge_amount_value_8,
            value_12_19
        )

        return
    end
end
local initialize
do
    local captured_value_50, captured_value_51, captured_value_52, captured_value_53, captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58, captured_value_59, captured_value_60, captured_value_61, captured_value_62, captured_value_63, captured_value_64 = get_main_event_result, value_10_8, setup_cell, setup_reward, table_13, from_rgb_result, from_rgb_result_2, value_11_9, challenge_details_child, value_2_2, require_result_4, update_cell, table_1, table_15, require_result_5
    initialize = function<T1>(argument_1_13: T1)
        local challenge_board_value_7 = captured_value_50.EventStartInfo.ChallengeBoard
        local value_3_29, value_4_24: boolean?
        if not challenge_board_value_7 then
            value_3_29 = captured_value_51
            value_4_24 = false
            value_3_29.Visible = value_4_24

            return
        end
        value_3_29 = challenge_board_value_7.Cells
        value_4_24 = nil
        local value_5_33 = nil
        local value_6_26, value_7_26
        for key_3, value_18 in value_3_29, value_4_24, value_5_33 do
            value_6_26, value_7_26 = key_3, value_18
            local value_8_28 = captured_value_52
            local value_9_21 = value_6_26
            local value_10_18 = value_7_26
            value_8_28(value_9_21, value_10_18)
        end
        value_3_29 = challenge_board_value_7.Rewards
        value_4_24 = nil
        value_5_33 = nil
        for key_4, value_19 in value_3_29, value_4_24, value_5_33 do
            value_6_26, value_7_26 = key_4, value_19
            local value_8_29 = captured_value_53
            local value_9_22 = value_6_26
            local value_10_19 = value_7_26
            value_8_29(value_9_22, value_10_19)
        end
        value_16 = nil
        value_3_29 = captured_value_54
        value_4_24 = nil
        value_5_33 = nil
        for key_5, value_20 in value_3_29, value_4_24, value_5_33 do
            value_6_26, value_7_26 = key_5, value_20
            local container_value_10 = value_7_26.Container
            local ui_stroke_value_3 = container_value_10.UIStroke
            local value_9_23: Color3?
            do
                local take_fallback_13 = value_6_26 ~= nil
                if not take_fallback_13 then
                    value_9_23 = captured_value_55
                    take_fallback_13 = not value_9_23
                end
                if take_fallback_13 then
                    value_9_23 = captured_value_56
                end
            end
            ui_stroke_value_3.Color = value_9_23
        end
        value_3_29 = captured_value_57
        value_4_24 = true
        value_3_29.Visible = value_4_24
        value_3_29 = captured_value_58
        value_4_24 = false
        value_3_29.Visible = value_4_24
        value_3_29 = captured_value_59
        value_5_33 = "EventQuestProgressed"
        value_3_29 = value_3_29:WaitForChild(value_5_33).OnClientEvent
        do
            local captured_value_65, captured_value_66, captured_value_67, captured_value_68, captured_value_69, captured_value_70, closure_ready_2
            value_5_33 = function(argument_1_14: string, argument_2_5: number): ()
                if not closure_ready_2 then
                    return
                end
                local value_3_30 = captured_value_65[captured_value_66.Title]
                local value_4_25 = value_3_30.Quests or ({})
                value_3_30.Quests = value_4_25
                local value_5_34 = value_3_30.Quests
                value_4_25 = value_5_34[argument_1_14]
                local table_6
                if value_4_25 then
                    value_4_25 = value_3_30.Quests[argument_1_14]
                    value_4_25.Progress = argument_2_5
                else
                    value_4_25 = value_3_30.Quests
                    value_5_34 = {Progress = 0, Claimed = 0}
                    value_5_34.Progress = argument_2_5
                    table_6 = {}
                    value_5_34.Claimed = table_6
                    value_4_25[argument_1_14] = value_5_34
                end
                value_4_25 = captured_value_67.Cells
                value_5_34 = nil
                table_6 = nil
                local value_7_27, value_8_30
                for key_6, value_21 in value_4_25, value_5_34, table_6 do
                    value_7_27, value_8_30 = key_6, value_21
                    if value_8_30 ~= argument_1_14 then
                        continue
                    end
                    local value_9_24 = captured_value_68
                    local value_10_20 = value_7_27
                    value_9_24(value_10_20)
                end
                value_4_25 = captured_value_67.Rewards
                value_5_34 = nil
                table_6 = nil
                for key_7, value_22 in value_4_25, value_5_34, table_6 do
                    value_7_27, value_8_30 = key_7, value_22
                    if value_8_30 ~= argument_1_14 then
                        continue
                    end
                    local value_9_25 = captured_value_66
                    local event_start_info_value_21 = value_9_25.EventStartInfo
                    local challenge_board_value_8 = event_start_info_value_21.ChallengeBoard
                    local rewards_value_3 = challenge_board_value_8.Rewards
                    local value_3_31 = rewards_value_3[value_7_27]
                    local value_9_26 = captured_value_69
                    local on_reward_updated_value_3 = value_9_26.OnRewardUpdated
                    local value_11_17 = captured_value_70
                    local value_10_21 = value_11_17[value_7_27]
                    local value_11_18 = value_3_31
                    local value_14_9 = captured_value_65
                    local value_15_6 = captured_value_66
                    local title_value_12 = value_15_6.Title
                    local value_13_11 = value_14_9[title_value_12]
                    local quests_value_51 = value_13_11.Quests
                    if quests_value_51 then
                        local quests_value_52 = value_13_11.Quests
                        quests_value_51 = quests_value_52[value_3_31]
                    end
                    local progress_value_10
                    do
                        local take_fallback_14 = not quests_value_51
                        if not take_fallback_14 then
                            progress_value_10 = quests_value_51.Progress
                            take_fallback_14 = not progress_value_10
                        end
                        if take_fallback_14 then
                            progress_value_10 = 0
                        end
                    end
                    local value_15_7 = captured_value_66
                    local event_start_info_value_22 = value_15_7.EventStartInfo
                    local quests_value_53 = event_start_info_value_22.Quests
                    local value_14_10 = quests_value_53[value_3_31]
                    local quests_value_54 = value_14_10.Quests
                    local quests_value_55 = value_14_10.Quests
                    local value_16_4 = #quests_value_55
                    local value_13_12 = quests_value_54[value_16_4]
                    local challenge_amount_value_10 = value_13_12.ChallengeAmount
                    local value_17_3 = captured_value_65
                    local value_18_2 = captured_value_66
                    local title_value_13 = value_18_2.Title
                    local value_16_5 = value_17_3[title_value_13]
                    local quests_value_56 = value_16_5.Quests
                    if quests_value_56 then
                        local quests_value_57 = value_16_5.Quests
                        quests_value_56 = quests_value_57[value_3_31]
                    end
                    local progress_value_11
                    do
                        local take_fallback_15 = not quests_value_56
                        if not take_fallback_15 then
                            progress_value_11 = quests_value_56.Progress
                            take_fallback_15 = not progress_value_11
                        end
                        if take_fallback_15 then
                            progress_value_11 = 0
                        end
                    end
                    local value_18_3 = captured_value_66
                    local event_start_info_value_23 = value_18_3.EventStartInfo
                    local quests_value_58 = event_start_info_value_23.Quests
                    local value_17_4 = quests_value_58[value_3_31]
                    local quests_value_59 = value_17_4.Quests
                    local quests_value_60 = value_17_4.Quests
                    local value_19_2 = #quests_value_60
                    local value_16_6 = quests_value_59[value_19_2]
                    local challenge_amount_value_11 = value_16_6.ChallengeAmount
                    local value_14_11: boolean?
                    if not (challenge_amount_value_11 <= progress_value_11) then
                        value_14_11 = false
                    else
                        value_14_11 = true
                    end
                    on_reward_updated_value_3(
                        value_10_21,
                        value_11_18,
                        progress_value_10,
                        challenge_amount_value_10,
                        value_14_11
                    )
                end

                return
            end
            captured_value_65, captured_value_66, captured_value_67, captured_value_68, captured_value_69, captured_value_70 = captured_value_60, captured_value_50, challenge_board_value_7, captured_value_61, captured_value_62, captured_value_63
            closure_ready_2 = true
        end
        value_3_29:Connect(value_5_33)
        value_3_29 = captured_value_64.PageChanged.Event
        do
            local captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75, closure_ready_3
            value_5_33 = function(argument_1_15): ()
                if not closure_ready_3 then
                    return
                end
                if argument_1_15 == "QuestBoard" then
                    value_16 = nil
                    local value_2_14 = captured_value_71
                    local value_3_32: boolean? = nil
                    local value_4_26: nil = nil
                    for key_8, value_23 in value_2_14, value_3_32, value_4_26 do
                        local value_5_35, value_6_27 = key_8, value_23
                        local container_value_11 = value_6_27.Container
                        local ui_stroke_value_4 = container_value_11.UIStroke
                        local value_8_31: Color3?
                        do
                            local take_fallback_16 = value_5_35 ~= nil
                            if not take_fallback_16 then
                                value_8_31 = captured_value_72
                                take_fallback_16 = not value_8_31
                            end
                            if take_fallback_16 then
                                value_8_31 = captured_value_73
                            end
                        end
                        ui_stroke_value_4.Color = value_8_31
                    end
                    value_2_14 = captured_value_74
                    value_3_32 = true
                    value_2_14.Visible = value_3_32
                    value_2_14 = captured_value_75
                    value_3_32 = false
                    value_2_14.Visible = value_3_32
                end

                return
            end
            captured_value_71, captured_value_72, captured_value_73, captured_value_74, captured_value_75 = captured_value_54, captured_value_55, captured_value_56, captured_value_57, captured_value_58
            closure_ready_3 = true
        end
        value_3_29:Connect(value_5_33)

        return
    end
end
table_1.Initialize = initialize

return table_1
