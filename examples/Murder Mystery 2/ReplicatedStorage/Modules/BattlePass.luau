--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
    [("GUI")] = nil,
}
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
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_6)
local value_6_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "ProfileData"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_6_3))
local require_result_3 = require(game.ReplicatedStorage.Modules.GridCreator)
local christmas_events2018_value = game.ReplicatedStorage.ChristmasEvents2018
local value_6_4: nil = nil
table_1.GUI = value_6_4
local value_6_5: nil = nil
table_1.BattlePassFrame = value_6_5
local value_6_6: nil = nil
table_1.YourTier = value_6_6
local value_6_7: number = 0
table_1.CurrentPassPage = value_6_7
local value_6_8: number = 1
table_1.CurrentTierBuy = value_6_8
local value_6_9: nil = nil
table_1.BuyTiersFrame = value_6_9
local value_6_10: nil = nil
table_1.NewPassTierRewardObject = value_6_10
local value_6_11: nil = nil
table_1.NewPassPageObject = value_6_11
local value_6_12: nil = nil
table_1.PassTierRewardObjectFunction = value_6_12
local value_6_13
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = require_result, require_result_3, table_1, require_result_2
    value_6_13 = function(argument_1, argument_2, argument_3, argument_4)
        local christmas_pass2018_value = captured_value.ChristmasPass2018
        local create_pass_value = captured_value_2.CreatePass
        local value_7_7 = argument_3
        local value_8 = argument_1
        local value_9 = christmas_pass2018_value
        local value_10 = captured_value_3.BattlePassFrame
        local value_11 = argument_2
        create_pass_value(value_7_7, value_8, value_9, value_10, value_11)
        local your_tier_value: nil = captured_value_3.YourTier
        value_8 = "Your Tier: "
        value_10 = captured_value_4
        local value_7_8 = value_8 .. value_10.Christmas2018.CurrentTier
        your_tier_value.Text = value_7_8
        local value_7_10 = captured_value_4.Christmas2018.CurrentTier
        if christmas_pass2018_value.TotalTiers <= value_7_10 then
            value_7_10 = value_7_10 - 1
        end
        value_9 = value_7_10 / 5
        value_8 = math.floor(value_9)
        local value_6_17 = value_8
        if not argument_4 then
            value_8, value_9, value_10 = pairs(captured_value_3.BattlePassFrame:GetChildren())
            for key, value in value_8, value_9, value_10 do
                local value_12
                value_11, value_12 = key, value
                local name_value = value_12.Name
                local value_16: string = "Page"
                local value_17 = value_6_17
                local value_15 = value_16 .. value_17
                local value_13: boolean?
                if name_value ~= value_15 then
                    value_13 = false
                else
                    value_13 = true
                end
                value_12.Visible = value_13
            end
            value_8 = captured_value_3
            value_8.CurrentPassPage = value_6_17
        end
        value_8 = captured_value_3
        value_9 = 1
        value_8.CurrentTierBuy = value_9
        captured_value_3.ChangeBuyTiers(0)
        value_8 = captured_value_3
        value_8.NewPassTierRewardObject = argument_1
        value_8 = captured_value_3
        value_8.NewPassPageObject = argument_2
        value_8 = captured_value_3
        value_8.PassTierRewardObjectFunction = argument_3

        return
    end
end
table_1.GenerateTiers = value_6_13
local table_6 = {}
local value_7
do
    local captured_value_5, captured_value_6, captured_value_7, captured_value_8, captured_value_9 = require_result_2, require_result, require_result_3, table_6, table_1
    value_7 = function(argument_1_2, argument_2_2, argument_3_2)
        local value_5_7 = argument_3_2
        local tostring_result = tostring(value_5_7)
        local value_5_8 = captured_value_5.Christmas2018.ClaimedRewards[tostring_result]
        local value_6_18: boolean?
        if captured_value_6.ChristmasPass2018.Rewards[tostring_result] == nil then
            value_6_18 = false
        else
            value_6_18 = true
        end
        if argument_2_2.ItemID then
            captured_value_7.MakeItemFrame(argument_1_2, argument_2_2, false)
            if not captured_value_8[argument_1_2] then
                local value_7_15 = captured_value_8
                local mouse_button1_click_value = argument_1_2.Claim.MouseButton1Click
                local value_10_3: (() -> ())?
                do
                    local captured_value_10, captured_value_11, captured_value_12, captured_value_13, closure_ready
                    value_10_3 = function(): ()
                        if not closure_ready then
                            return
                        end
                        local claim_value_3 = captured_value_10.Claim
                        local value_2: boolean = false
                        claim_value_3.Visible = value_2
                        if captured_value_11.Christmas2018.ClaimedRewards[captured_value_12] ~= true then
                            captured_value_13.ClaimReward(captured_value_12)
                        end

                        return
                    end
                    captured_value_10, captured_value_11, captured_value_12, captured_value_13 = argument_1_2, captured_value_5, tostring_result, captured_value_9
                    closure_ready = true
                end
                local connect_result = mouse_button1_click_value:connect(value_10_3)
                value_7_15[argument_1_2] = connect_result
            end
        end
        local locked_value = argument_1_2.Locked
        local value_8_5: boolean?
        if not (captured_value_5.Christmas2018.CurrentTier < argument_3_2) then
            value_8_5 = false
        else
            value_8_5 = true
        end
        locked_value.Visible = value_8_5
        local next_value = argument_1_2.Next
        local value_8_6: boolean?
        if captured_value_5.Christmas2018.CurrentTier + 1 ~= argument_3_2 then
            value_8_6 = false
        else
            value_8_6 = true
        end
        next_value.Visible = value_8_6
        local claim_value_2 = argument_1_2.Claim
        local value_8_7: boolean = false
        if argument_3_2 <= captured_value_5.Christmas2018.CurrentTier then
            value_8_7 = not value_5_8 and value_6_18
        end
        claim_value_2.Visible = value_8_7
        local tier_number_value = argument_1_2.Title.TierNumber
        tier_number_value.Text = argument_3_2

        return
    end
end
table_1.GenerateTierRewardPC = value_7
local value_7_2
do
    local captured_value_14 = table_1
    value_7_2 = function(argument_1_3)
        local value_2_3 = captured_value_14
        local value_3_6 = captured_value_14.CurrentPassPage + argument_1_3
        value_2_3.CurrentPassPage = value_3_6
        local value_4_7
        value_2_3, value_3_6, value_4_7 = pairs(captured_value_14.BattlePassFrame:GetChildren())
        for key_2, value_14 in value_2_3, value_3_6, value_4_7 do
            local value_5_9, value_6_19 = key_2, value_14
            local name_value_2 = value_6_19.Name
            local value_10_6: string = "Page"
            local value_11_3 = captured_value_14
            local current_pass_page_value = value_11_3.CurrentPassPage
            local value_9_6 = value_10_6 .. current_pass_page_value
            local value_7_16: boolean?
            if name_value_2 ~= value_9_6 then
                value_7_16 = false
            else
                value_7_16 = true
            end
            value_6_19.Visible = value_7_16
        end

        return
    end
end
table_1.ChangePage = value_7_2
local value_7_3
do
    local captured_value_15, captured_value_16, captured_value_17 = require_result_2, require_result, table_1
    value_7_3 = function(argument_1_4)
        local current_tier_value_5 = captured_value_15.Christmas2018.CurrentTier
        local total_tiers_value = captured_value_16.ChristmasPass2018.TotalTiers
        local tier_cost_value = captured_value_16.ChristmasPass2018.TierCost
        local value_5_11 = captured_value_17
        local value_6_20 = captured_value_17.CurrentTierBuy + argument_1_4
        value_5_11.CurrentTierBuy = value_6_20
        if captured_value_17.CurrentTierBuy < 1 then
            local value_5_13 = captured_value_17
            local value_6_22: number = 1
            value_5_13.CurrentTierBuy = value_6_22
        end
        if total_tiers_value < captured_value_17.CurrentTierBuy + current_tier_value_5 then
            local value_5_15 = captured_value_17
            local value_6_24 = total_tiers_value - current_tier_value_5
            value_5_15.CurrentTierBuy = value_6_24
        end
        local value_6_25: string?
        if 1 < captured_value_17.CurrentTierBuy then
            value_6_25 = "s"
        else
            value_6_25 = ""
        end
        local tostring_result_2 = tostring(value_6_25)
        local buy_value = captured_value_17.BuyTiersFrame.Buy
        local value_7_19 = "Buy " .. captured_value_17.CurrentTierBuy .. " Tier" .. tostring_result_2
        buy_value.Text = value_7_19
        local amount_value = captured_value_17.BuyTiersFrame.CandyDisplay.Amount
        local value_7_20 = captured_value_17.CurrentTierBuy * tier_cost_value
        amount_value.Text = value_7_20
        if total_tiers_value <= current_tier_value_5 then
            local parent_value = captured_value_17.BuyTiersFrame.Parent
            local value_7_21: boolean = false
            parent_value.Visible = value_7_21
            local pass_complete_value = captured_value_17.BattlePassFrame.Parent.PassComplete
            local value_7_22: boolean = true
            pass_complete_value.Visible = value_7_22
        end

        return
    end
end
table_1.ChangeBuyTiers = value_7_3
local value_7_4
do
    local captured_value_18, captured_value_19, captured_value_20, captured_value_21 = table_1, require_result_2, require_result, christmas_events2018_value
    value_7_4 = function()
        local current_tier_buy_value_7 = captured_value_18.CurrentTierBuy
        local value_2_4 = captured_value_19.Materials.Owned.Logs2018 or 0
        local value_4_10 = captured_value_20.ChristmasPass2018.TierCost * current_tier_buy_value_7
        local value_3_9: boolean?
        if not (value_4_10 <= value_2_4) then
            value_3_9 = false
        else
            value_3_9 = true
        end
        print("Tiers To Buy: " .. current_tier_buy_value_7)
        print("Current Tier: " .. captured_value_19.Christmas2018.CurrentTier)
        if value_3_9 then
            local buy_tiers_value = captured_value_21.BuyTiers
            local value_7_25 = current_tier_buy_value_7
            buy_tiers_value:FireServer(value_7_25)
            local owned_value_2 = captured_value_19.Materials.Owned
            local value_6_33 = captured_value_19.Materials.Owned.Logs2018 - value_4_10
            owned_value_2.Logs2018 = value_6_33
            local christmas2018_value_9 = captured_value_19.Christmas2018
            local value_6_35 = captured_value_19.Christmas2018.CurrentTier + current_tier_buy_value_7
            christmas2018_value_9.CurrentTier = value_6_35
            local value_5_19 = captured_value_18
            local value_6_36: number = 1
            value_5_19.CurrentTierBuy = value_6_36
            captured_value_18.ChangeBuyTiers(0)
            print(" -- ")
            print("Tiers To Buy: " .. captured_value_18.CurrentTierBuy)
            print("Current Tier: " .. captured_value_19.Christmas2018.CurrentTier)
            captured_value_18.UpdateCandies()
            captured_value_18.GenerateTiers(
                captured_value_18.NewPassTierRewardObject,
                captured_value_18.NewPassPageObject,
                captured_value_18.PassTierRewardObjectFunction
            )

            return true
        end

        return false, value_4_10 - value_2_4
    end
end
table_1.BuyTiers = value_7_4
local value_7_5
do
    local captured_value_22, captured_value_23, captured_value_24, captured_value_25 = require_result, require_result_2, table_1, christmas_events2018_value
    value_7_5 = function(argument_1_5)
        local amount_value_2, christmas2018_value_12, christmas2018_value_13, christmas2018_value_14, christmas_pass2018_value_6, claim_reward_value_2, claimed_rewards_value_3, claimed_rewards_value_4, current_tier_value_9, generate_tiers_value_2, insert_value, item_id_value_2, item_type_value, item_type_value_2, item_type_value_3, item_type_value_4, item_type_value_5, item_type_value_6, new_pass_page_object_value_2, new_pass_tier_reward_object_value_2, owned_value_4, owned_value_5, owned_value_6, pass_tier_reward_object_function_value_2, print_value_6, rewards_value_2, tonumber_result, tonumber_value, tostring_result_3, tostring_value_3, value_3_10, value_3_11, value_5_25, value_5_26, value_5_27, value_5_28, value_5_29, value_6_43, value_6_44, value_6_45, value_6_46, value_6_47, value_6_48, value_6_49, value_6_50, value_7_30, value_7_31, value_7_32, value_7_33, value_7_34, value_7_35, value_7_36, value_7_37, value_7_38, value_8_15, value_9_10
        local control_state = 0
        while true do
            if control_state < 6 then
                if control_state < 3 then
                    if control_state < 1 then
                        value_3_10 = argument_1_5
                        tostring_value_3 = tostring
                        tostring_result_3 = tostring_value_3(value_3_10)
                        value_5_25 = captured_value_22
                        christmas_pass2018_value_6 = value_5_25.ChristmasPass2018
                        rewards_value_2 = christmas_pass2018_value_6.Rewards
                        value_3_11 = rewards_value_2[tostring_result_3]
                        control_state = if not value_3_11 then 12 else 1
                    else
                        if control_state < 2 then
                            item_id_value_2 = value_3_11.ItemID
                            print_value_6 = print
                            value_6_43 = item_id_value_2
                            print_value_6(value_6_43)
                            value_6_44 = captured_value_23
                            christmas2018_value_12 = value_6_44.Christmas2018
                            current_tier_value_9 = christmas2018_value_12.CurrentTier
                            value_7_30 = tostring_result_3
                            tonumber_value = tonumber
                            tonumber_result = tonumber_value(value_7_30)
                            control_state = if not (tonumber_result <= current_tier_value_9) then 12 else 2
                        else
                            value_7_31 = captured_value_23
                            christmas2018_value_13 = value_7_31.Christmas2018
                            claimed_rewards_value_3 = christmas2018_value_13.ClaimedRewards
                            value_5_26 = claimed_rewards_value_3[tostring_result_3]
                            control_state = if value_5_26 == true then 12 else 3
                        end
                    end
                else
                    if control_state < 4 then
                        value_6_45 = captured_value_23
                        christmas2018_value_14 = value_6_45.Christmas2018
                        claimed_rewards_value_4 = christmas2018_value_14.ClaimedRewards
                        value_6_46 = true
                        claimed_rewards_value_4[tostring_result_3] = value_6_46
                        item_type_value = value_3_11.ItemType
                        control_state = if item_type_value == "Weapons" then 6 else 4
                    else
                        if control_state < 5 then
                            item_type_value_2 = value_3_11.ItemType
                            control_state = if item_type_value_2 == "Pets" then 6 else 5
                        else
                            item_type_value_3 = value_3_11.ItemType
                            control_state = if item_type_value_3 ~= "Materials" then 10 else 6
                        end
                    end
                end
            else
                if control_state < 9 then
                    if control_state < 7 then
                        value_7_32 = captured_value_23
                        item_type_value_4 = value_3_11.ItemType
                        value_6_47 = value_7_32[item_type_value_4]
                        owned_value_4 = value_6_47.Owned
                        value_5_27 = owned_value_4[item_id_value_2]
                        value_7_33 = captured_value_23
                        item_type_value_5 = value_3_11.ItemType
                        value_6_48 = value_7_33[item_type_value_5]
                        owned_value_5 = value_6_48.Owned
                        control_state = if not value_5_27 then 8 else 7
                    else
                        if control_state < 8 then
                            amount_value_2 = value_3_11.Amount
                            value_7_34 = value_5_27 + amount_value_2
                            control_state = if value_7_34 then 9 else 8
                        else
                            value_7_34 = value_3_11.Amount
                            control_state = 9
                        end
                    end
                else
                    if control_state < 11 then
                        if control_state < 10 then
                            owned_value_5[item_id_value_2] = value_7_34
                            control_state = 11
                        else
                            value_7_35 = captured_value_23
                            item_type_value_6 = value_3_11.ItemType
                            value_6_49 = value_7_35[item_type_value_6]
                            owned_value_6 = value_6_49.Owned
                            value_7_36 = item_id_value_2
                            insert_value = table.insert
                            insert_value(owned_value_6, value_7_36)
                            control_state = 11
                        end
                    else
                        if control_state < 12 then
                            value_5_28 = captured_value_24
                            generate_tiers_value_2 = value_5_28.GenerateTiers
                            value_6_50 = captured_value_24
                            new_pass_tier_reward_object_value_2 = value_6_50.NewPassTierRewardObject
                            value_7_37 = captured_value_24
                            new_pass_page_object_value_2 = value_7_37.NewPassPageObject
                            value_8_15 = captured_value_24
                            pass_tier_reward_object_function_value_2 = value_8_15.PassTierRewardObjectFunction
                            value_9_10 = true
                            generate_tiers_value_2(
                                new_pass_tier_reward_object_value_2,
                                new_pass_page_object_value_2,
                                pass_tier_reward_object_function_value_2,
                                value_9_10
                            )
                            value_5_29 = captured_value_25
                            claim_reward_value_2 = value_5_29.ClaimReward
                            value_7_38 = tostring_result_3
                            claim_reward_value_2:FireServer(value_7_38)

                            return
                        else
                            return
                        end
                    end
                end
            end
        end
    end
end
table_1.ClaimReward = value_7_5
local value_7_6
do
    local captured_value_26, captured_value_27, captured_value_28 = table_1, require_result_3, require_result_2
    value_7_6 = function()
        local amount_value_3 = captured_value_26.GUI.CandyDisplay.Amount
        local commafy_result = captured_value_27.Commafy(
            captured_value_28.Materials.Owned.Logs2018 or 0
        )
        amount_value_3.Text = commafy_result

        return
    end
end
table_1.UpdateCandies = value_7_6

return table_1
