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

local table_1 = {[("Update")] = nil, [("Update")] = nil, [("Update")] = nil}
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
local value_5_5: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_5)
local value_5_6: string = "Button"
local require_result_2 = require_value_2(client_services_child:WaitForChild(value_5_6))
local require_value_3 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "ClientServices"
local client_services_child_2: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "ItemService"
local require_result_3 = require_value_3(client_services_child_2:WaitForChild(value_6_3))
local require_value_4 = require
local game_value_4: DataModel = game
local value_7: string = "ReplicatedStorage"
local replicated_storage_service_4: Instance = game_value_4:GetService(value_7)
local value_7_2: string = "ClientServices"
local client_services_child_3: Instance? = replicated_storage_service_4:WaitForChild(value_7_2)
local value_7_3: string = "ItemPopupService"
local require_result_4 = require_value_4(client_services_child_3:WaitForChild(value_7_3))
local from_rgb_result: Color3 = Color3.fromRGB(70, 169, 255)
local from_rgb_result_2: Color3 = Color3.fromRGB(103, 255, 1)
local parent_value_2 = script.Parent.Parent
local value_10: string = "MainEvent"
local main_event_child = parent_value_2:WaitForChild(value_10)
local value_10_2: string = "Main"
local main_child = main_event_child:WaitForChild(value_10_2)
local value_10_3: string = "Gifting"
local gifting_child = main_child:WaitForChild(value_10_3)
local value_11: string = "Container"
local container_child = gifting_child:WaitForChild(value_11)
local value_11_2: string = "Center"
local center_child = container_child:WaitForChild(value_11_2)
local value_11_3: string = "RequiredBar"
local value_7_6 = (center_child:WaitForChild(value_11_3))
local value_11_4: string = "Container"
local container_child_2 = gifting_child:WaitForChild(value_11_4)
local value_11_5: string = "Left"
local left_child = container_child_2:WaitForChild(value_11_5)
local value_11_6: string = "Buy1"
local buy1_child = left_child:WaitForChild(value_11_6)
local value_12 = "Container"
local container_child_3 = gifting_child:WaitForChild(value_12)
value_12 = "Left"
local left_child_2 = container_child_3:WaitForChild(value_12)
value_12 = "Buy10"
local buy10_child = left_child_2:WaitForChild(value_12)
local value_13: string = "Container"
local container_child_4 = gifting_child:WaitForChild(value_13)
local value_13_2: string = "Right"
local right_child = container_child_4:WaitForChild(value_13_2)
local value_13_3: string = "Claim"
local claim_child = right_child:WaitForChild(value_13_3)
value_12 = nil
local require_value_5 = require
local game_value_5: DataModel = game
local value_16: string = "ReplicatedStorage"
local replicated_storage_service_5: Instance = game_value_5:GetService(value_16)
local value_16_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_5:WaitForChild(value_16_2)
local value_16_3: string = "ProfileData"
local require_result_5 = require_value_5(modules_child:WaitForChild(value_16_3))
local require_value_6 = require
local game_value_6: DataModel = game
local value_17: string = "ReplicatedStorage"
local replicated_storage_service_6: Instance = game_value_6:GetService(value_17)
local value_17_2: string = "Database"
local database_child: Instance? = replicated_storage_service_6:WaitForChild(value_17_2)
local value_17_3: string = "Sync"
local require_result_6 = require_value_6(database_child:WaitForChild(value_17_3))
local require_value_7 = require
local game_value_7: DataModel = game
local value_18: string = "ReplicatedStorage"
local replicated_storage_service_7: Instance = game_value_7:GetService(value_18)
local value_18_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_7:WaitForChild(value_18_2)
local value_18_3: string = "EventInfoService"
local require_result_7 = require_value_7(shared_services_child:WaitForChild(value_18_3))
require_result_7:WaitForInitializedAsync()
local get_main_event_result = require_result_7:GetMainEvent()
local currency_name_value = get_main_event_result.EventStartInfo.CurrencyName
local game_value_8: DataModel = game
local value_19: string = "ReplicatedStorage"
local replicated_storage_service_8: Instance = game_value_8:GetService(value_19)
local value_19_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service_8:WaitForChild(value_19_2)
local value_20: string = "Events"
local events_child = remotes_child:WaitForChild(value_20)
local value_20_2 = get_main_event_result.Title .. "Remotes"
local wait_for_child_result = events_child:WaitForChild(value_20_2)
local reward_required_amount_value = get_main_event_result.EventStartInfo.Gifting.RewardRequiredAmount
local gift_currency_price_value = get_main_event_result.EventStartInfo.Gifting.GiftCurrencyPrice
local update: (<T1>(T1) -> ())?
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5, captured_value_6, captured_value_7 = require_result_5, get_main_event_result, reward_required_amount_value, value_7_6, from_rgb_result_2, from_rgb_result, gifting_child
    update = function<T1>(argument_1: T1): ()
        local value_2 = captured_value[captured_value_2.Title]
        local value_3_8 = value_2.GiftsGiven or 0
        local value_4_11 = value_2.GiftRewardClaimedAmount or 0
        local value_2_2 = (value_4_11 + 1) * captured_value_3
        local value_5_14 = value_4_11 * captured_value_3
        local value_6_10: boolean?
        if not (value_2_2 <= value_3_8) then
            value_6_10 = false
        else
            value_6_10 = true
        end
        local value_2_3 = value_3_8 - value_5_14
        local value_5_15 = captured_value_3
        local value_8_6 = value_2_3 / value_5_15
        local value_9_11: number = 0
        local value_10_13: number = 1
        local clamp_result = math.clamp(value_8_6, value_9_11, value_10_13)
        local required_amount_value = captured_value_4.RequiredAmount
        local value_9_12 = value_2_3 .. "/" .. value_5_15
        required_amount_value.Text = value_9_12
        local bar_value = captured_value_4.BarContainer.Bar
        local new_result = UDim2.new(clamp_result, 0, 1, 0)
        bar_value.Size = new_result
        local bar_value_2 = captured_value_4.BarContainer.Bar
        local value_9_13: Color3?
        do
            local take_fallback = not value_6_10
            if not take_fallback then
                value_9_13 = captured_value_5
                take_fallback = not value_9_13
            end
            if take_fallback then
                value_9_13 = captured_value_6
            end
        end
        bar_value_2.BackgroundColor3 = value_9_13
        local ready_claim_value = captured_value_4.ReadyClaim
        ready_claim_value.Visible = value_6_10
        local required_amount_value_2 = captured_value_4.RequiredAmount
        local value_9_14: boolean = not value_6_10
        required_amount_value_2.Visible = value_9_14
        local total_given_value = captured_value_7.Container.Center.TotalGiven
        local value_9_15 = "Total Given: " .. value_3_8
        total_given_value.Text = value_9_15
        local total_given_value_2 = captured_value_7.Container.Center.TotalGiven
        local value_9_16: boolean?
        if not (0 < value_4_11) then
            value_9_16 = false
        else
            value_9_16 = true
        end
        total_given_value_2.Visible = value_9_16
        local owned_value = captured_value_7.Container.Right.RewardIcon.Background.Owned
        local value_9_17: boolean?
        if not (0 < value_4_11) then
            value_9_17 = false
        else
            value_9_17 = true
        end
        owned_value.Visible = value_9_17
        local claim_counter_value = captured_value_7.Container.Right.RewardIcon.ClaimCounter
        local value_9_18: boolean?
        if not (1 < value_4_11) then
            value_9_18 = false
        else
            value_9_18 = true
        end
        claim_counter_value.Visible = value_9_18
        local claim_counter_value_2 = captured_value_7.Container.Right.RewardIcon.ClaimCounter
        local value_9_19 = value_4_11 .. "x Claimed"
        claim_counter_value_2.Text = value_9_19
        if value_6_10 then
            value_12:Enable()

            return
        end
        value_12:Disable()

        return
    end
end
table_1.Update = update
local open
do
    local captured_value_8 = table_1
    open = function<T1>(argument_1_2: T1)
        captured_value_8:Update()

        return
    end
end
table_1.Open = open
local buy_gifts_with_tokens
do
    local captured_value_9, captured_value_10, captured_value_11, captured_value_12, captured_value_13, captured_value_14 = require_result_5, currency_name_value, get_main_event_result, gift_currency_price_value, require_result_4, wait_for_child_result
    buy_gifts_with_tokens = function(argument_1_3): ()
        local value_2_6 = captured_value_9.Materials.Owned[captured_value_10] or 0
        local value_3_11 = captured_value_9[captured_value_11.Title].GiftInventory or 0
        local value_4_14 = captured_value_12 * argument_1_3
        if value_2_6 < value_4_14 then
            return
        end
        local owned_value_3 = captured_value_9.Materials.Owned
        local value_6_12 = captured_value_10
        local value_7_7 = value_2_6 - value_4_14
        owned_value_3[value_6_12] = value_7_7
        local value_5_20 = captured_value_9[captured_value_11.Title]
        local value_6_14 = value_3_11 + argument_1_3
        value_5_20.GiftInventory = value_6_14
        local value_5_21 = captured_value_13
        local value_7_9: string = "GiftVisual"
        local value_8_21: string = "Materials"
        local value_9_22 = argument_1_3
        value_5_21:AddNewItem(value_7_9, value_8_21, value_9_22)
        local buy_gift_value = captured_value_14.BuyGift
        local value_7_10 = argument_1_3
        buy_gift_value:FireServer(value_7_10)

        return
    end
end
local claim_gifting_reward
do
    local captured_value_15, captured_value_16, captured_value_17, captured_value_18, captured_value_19 = require_result_5, get_main_event_result, reward_required_amount_value, wait_for_child_result, table_1
    claim_gifting_reward = function()
        local value_1 = captured_value_15[captured_value_16.Title]
        local value_2_8 = value_1.GiftsGiven or 0
        local value_3_14: boolean?
        if not (((value_1.GiftRewardClaimedAmount or 0) + 1) * captured_value_17 <= value_2_8) then
            value_3_14 = false
        else
            value_3_14 = true
        end
        if value_3_14 then
            captured_value_18.ClaimGiftReward:FireServer()
            local value_4_16 = value_1.GiftRewardClaimedAmount or 0
            local value_5_28 = captured_value_15[captured_value_16.Title]
            local value_6_20 = value_4_16 + 1
            value_5_28.GiftRewardClaimedAmount = value_6_20
            value_12:Disable()
            captured_value_19:Update()
        end

        return
    end
end
local update_gift_tool
do
    local captured_value_20, captured_value_21, captured_value_22, captured_value_23, captured_value_24 = require_result_5, get_main_event_result, gifting_child, require_result_3, table_1
    update_gift_tool = function(argument_1_4, argument_2)
        local value_3_15 = captured_value_20[captured_value_21.Title]
        value_3_15.GiftsGiven = argument_2
        local value_3_16 = captured_value_20[captured_value_21.Title]
        value_3_16.GiftInventory = argument_1_4
        local value_3_17 = captured_value_22
        local value_5_35: string = "Title"
        local title_child = value_3_17:WaitForChild(value_5_35)
        local value_5_36: string = "Gifts"
        local gifts_child = title_child:WaitForChild(value_5_36)
        local value_4_21 = captured_value_20[captured_value_21.Title].GiftInventory or 0
        local value_7_13: string = "Container"
        local container_child_5 = gifts_child:WaitForChild(value_7_13)
        local value_7_14: string = "TextLabel"
        local text_label_child = container_child_5:WaitForChild(value_7_14)
        local value_6_26 = captured_value_23
        local value_8_22 = value_4_21
        local comma_number_result = value_6_26:CommaNumber(value_8_22)
        text_label_child.Text = comma_number_result
        captured_value_24:Update()

        return
    end
end
local initialize
do
    local captured_value_25, captured_value_26, captured_value_27, captured_value_28, captured_value_29, captured_value_30, captured_value_31, captured_value_32, captured_value_33, captured_value_34, captured_value_35, captured_value_36, captured_value_37, captured_value_38 = require_result_2, buy1_child, buy_gifts_with_tokens, buy10_child, get_main_event_result, gifting_child, require_result_6, claim_child, claim_gifting_reward, require_result_3, update_gift_tool, require_result_5, wait_for_child_result, table_1
    initialize = function()
        local create_button_value = captured_value_25.createButton
        local value_2_9 = captured_value_26
        local value_3_20
        do
            local captured_value_39 = captured_value_27
            if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_39) then
                value_3_20 = closure_cache[1]
            else
                local closure_ready
                value_3_20 = function(): ()
                    if not closure_ready then
                        return
                    end
                    captured_value_39(1)

                    return
                end
                closure_ready = true
                if closure_cache[1] == nil then
                    closure_cache[1] = value_3_20
                    closure_cache[2] = captured_value_39
                end
            end
        end
        create_button_value(value_2_9, value_3_20)
        local create_button_value_2 = captured_value_25.createButton
        local value_2_10 = captured_value_28
        local value_3_21
        do
            local captured_value_40 = captured_value_27
            if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_40) then
                value_3_21 = closure_cache[3]
            else
                local closure_ready_2
                value_3_21 = function(): ()
                    if not closure_ready_2 then
                        return
                    end
                    captured_value_40(10)

                    return
                end
                closure_ready_2 = true
                if closure_cache[3] == nil then
                    closure_cache[3] = value_3_21
                    closure_cache[4] = captured_value_40
                end
            end
        end
        create_button_value_2(value_2_10, value_3_21)
        local gifting_value_3 = captured_value_29.EventStartInfo.Gifting
        local reward_id_value = gifting_value_3.RewardID
        local box_icon_value = captured_value_30.Container.Right.RewardIcon.BoxIcon
        local image_value = captured_value_31.Weapons[reward_id_value].Image
        box_icon_value.Image = image_value
        value_12 = (captured_value_25.createButton(captured_value_32, captured_value_33))
        local value_3_24 = captured_value_26
        local value_5_44: string = "Container"
        local container_child_6 = value_3_24:WaitForChild(value_5_44)
        local value_5_45: string = "Container"
        local container_child_7 = container_child_6:WaitForChild(value_5_45)
        local value_5_46: string = "ListContainer"
        local list_container_child = container_child_7:WaitForChild(value_5_46)
        local value_5_47: string = "TextLabel"
        local text_label_child_2 = list_container_child:WaitForChild(value_5_47)
        local value_4_28 = captured_value_34
        local gift_currency_price_value_2 = gifting_value_3.GiftCurrencyPrice
        local comma_number_result_2 = value_4_28:CommaNumber(gift_currency_price_value_2)
        text_label_child_2.Text = comma_number_result_2
        local value_3_29 = captured_value_28
        local value_5_49: string = "Container"
        local container_child_8 = value_3_29:WaitForChild(value_5_49)
        local value_5_50: string = "Container"
        local container_child_9 = container_child_8:WaitForChild(value_5_50)
        local value_5_51: string = "ListContainer"
        local list_container_child_2 = container_child_9:WaitForChild(value_5_51)
        local value_5_52: string = "TextLabel"
        local text_label_child_3 = list_container_child_2:WaitForChild(value_5_52)
        local value_4_34 = captured_value_34
        local value_6_29 = gifting_value_3.GiftCurrencyPrice * 10
        local comma_number_result_3 = value_4_34:CommaNumber(value_6_29)
        text_label_child_3.Text = comma_number_result_3
        local button_value = captured_value_30.Container.Left.GiftIcon.ChancesButton.Button
        local chances_frame_value = captured_value_30.Container.Left.GiftIcon.ChancesFrame
        local activated_value = button_value.Activated
        local value_5_54: (() -> ())?
        do
            local captured_value_41, closure_ready_3
            value_5_54 = function(): ()
                if not closure_ready_3 then
                    return
                end
                local value_1_8 = captured_value_41
                local value_2_14: boolean = not captured_value_41.Visible
                value_1_8.Visible = value_2_14

                return
            end
            captured_value_41 = chances_frame_value
            closure_ready_3 = true
        end
        activated_value:Connect(value_5_54)
        captured_value_35(
            captured_value_36[captured_value_29.Title].GiftInventory,
            captured_value_36[captured_value_29.Title].GiftsGiven
        )
        local on_client_event_value = captured_value_37.UpdateGiftTool.OnClientEvent
        local value_5_57 = captured_value_35
        on_client_event_value:Connect(value_5_57)
        captured_value_38:Update()

        return
    end
end
table_1.Initialize = initialize

return table_1
