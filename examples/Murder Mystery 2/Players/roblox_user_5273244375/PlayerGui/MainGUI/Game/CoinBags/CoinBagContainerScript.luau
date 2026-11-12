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

local container_value = script.Parent.Container
local game_value: DataModel = game
local value_4: string = "TweenService"
local tween_service: Instance = game_value:GetService(value_4)
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "Remotes"
local remotes_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Gameplay"
local gameplay_child = remotes_child:WaitForChild(value_5_3)
local value_5_4: string = "CoinCollected"
local coin_collected_child = gameplay_child:WaitForChild(value_5_4)
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "Remotes"
local remotes_child_2: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "Gameplay"
local gameplay_child_2 = remotes_child_2:WaitForChild(value_6_3)
local value_6_4: string = "CoinsStarted"
local coins_started_child = gameplay_child_2:WaitForChild(value_6_4)
local require_value = require
local game_value_4: DataModel = game
local value_8: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_4:GetService(value_8)
local value_8_2: string = "Database"
local database_child: Instance? = replicated_storage_service_3:WaitForChild(value_8_2)
local value_8_3: string = "Sync"
local require_result = require_value(database_child:WaitForChild(value_8_3))
local new_result: TweenInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)
local new_result_2: TweenInfo = TweenInfo.new(
    1.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)
local new_result_3: TweenInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)
local play_bag_full_animation
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4 = tween_service, new_result, new_result_2, new_result_3
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) and same_capture(
        closure_cache[3],
        captured_value_2
    ) and same_capture(closure_cache[4], captured_value_3) and same_capture(
        closure_cache[5],
        captured_value_4
    ) then
        play_bag_full_animation = closure_cache[1]
    else
        local closure_ready
        play_bag_full_animation = function(argument_1: string): ()
            if not closure_ready then
                return
            end
            local cloned_value = script.FullBagNotification:Clone()
            local value_3_7 = (string.upper(argument_1)) .. " FULL!"
            cloned_value.Text = value_3_7
            local new_result_4 = UDim2.new(0.5, 0, 1.15, 0)
            cloned_value.Position = new_result_4
            local value_3_8: number = -3
            cloned_value.Rotation = value_3_8
            local value_3_9: boolean = true
            cloned_value.Visible = value_3_9
            local parent_value_2: Instance? = script.Parent
            cloned_value.Parent = parent_value_2
            local debris_value = game.Debris
            local value_5_12 = cloned_value
            local value_6_9: number = 3
            debris_value:AddItem(value_5_12, value_6_9)
            local value_3_11: Instance = captured_value
            local value_5_13 = cloned_value
            local value_6_10: TweenInfo = captured_value_2
            local table_7 = {[("Position")] = nil}
            local new_result_5 = UDim2.new(0.5, 0, 0.8, 0)
            table_7.Position = new_result_5
            value_3_11:Create(value_5_13, value_6_10, table_7):Play()
            task.wait(0.5)
            local value_3_14: Instance = captured_value
            local value_5_14 = cloned_value
            local value_6_11: TweenInfo = captured_value_3
            local table_7_2 = {[("Rotation")] = nil}
            local value_8_5: number = 3
            table_7_2.Rotation = value_8_5
            value_3_14:Create(value_5_14, value_6_11, table_7_2):Play()
            task.wait(1.5)
            local value_3_17: Instance = captured_value
            local value_5_15 = cloned_value
            local value_6_12: TweenInfo = captured_value_4
            local table_7_3 = {[("Position")] = nil}
            local new_result_6 = UDim2.new(0.5, 0, 1.15, 0)
            table_7_3.Position = new_result_6
            value_3_17:Create(value_5_15, value_6_12, table_7_3):Play()

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = play_bag_full_animation
            closure_cache[2], closure_cache[3], closure_cache[4], closure_cache[5] = captured_value, captured_value_2, captured_value_3, captured_value_4
        end
    end
end
local on_coin_collected
do
    local captured_value_5, captured_value_6 = container_value, play_bag_full_animation
    if closure_cache[6] ~= nil and same_capture(closure_cache[7], captured_value_5) and same_capture(
        closure_cache[8],
        captured_value_6
    ) then
        on_coin_collected = closure_cache[6]
    else
        local closure_ready_2
        on_coin_collected = function<T4>(argument_1_2: string, argument_2: number, argument_3: number, argument_4: T4)
            if not closure_ready_2 then
                return
            end
            local value_5_16 = captured_value_5
            local value_7_6: string = argument_1_2
            local value_5_18 = value_5_16:FindFirstChild(value_7_6)
            if not value_5_18 then
                return
            end
            local value_6_14: boolean?
            if not (argument_3 <= argument_2) then
                value_6_14 = false
            else
                value_6_14 = true
            end
            local coins_value = value_5_18.CurrencyFrame.Icon.Coins
            coins_value.Text = argument_2
            if value_6_14 then
                local empty_bag_icon_value = value_5_18.EmptyBagIcon
                local value_8_6: boolean = false
                empty_bag_icon_value.Visible = value_8_6
                local full_bag_icon_value = value_5_18.FullBagIcon
                local value_8_7: boolean = true
                full_bag_icon_value.Visible = value_8_7
                local full_value = value_5_18.Full
                local value_8_8: boolean = true
                full_value.Visible = value_8_8
                local value_7_7 = captured_value_6
                local value_10_4: string = "BagName"
                value_7_7(value_5_18:GetAttribute(value_10_4))
            end

            return
        end
        closure_ready_2 = true
        if closure_cache[6] == nil then
            closure_cache[6] = on_coin_collected
            closure_cache[7], closure_cache[8] = captured_value_5, captured_value_6
        end
    end
end
local on_coins_started
do
    local captured_value_7, captured_value_8 = container_value, require_result
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_7) and same_capture(
        closure_cache[11],
        captured_value_8
    ) then
        on_coins_started = closure_cache[9]
    else
        local closure_ready_3
        on_coins_started = function(argument_1_3): ()
            if not closure_ready_3 then
                return
            end
            local children = captured_value_7:GetChildren()
            local value_3_20, value_4_20, value_5_19 = pairs(children)
            for key, value in value_3_20, value_4_20, value_5_19 do
                local value_6_15, value_7_8 = key, value
                local value_10_5: string = "Frame"
                local is_a_result_2 = value_7_8:IsA(value_10_5)
                if not is_a_result_2 then
                    continue
                end
                local name_value = value_7_8.Name
                local value_9_6 = argument_1_3[name_value]
                local value_10_6: boolean?
                if value_9_6 == nil then
                    value_10_6 = false
                else
                    value_10_6 = true
                end
                value_7_8.Visible = value_10_6
                local value_8_11 = value_9_6
                if value_8_11 then
                    value_8_11 = value_9_6.CurrencyID
                    if value_8_11 then
                        local value_10_7 = captured_value_8
                        local materials_value = value_10_7.Materials
                        local currency_id_value = value_9_6.CurrencyID
                        value_8_11 = materials_value[currency_id_value]
                    end
                end
                if not value_8_11 then
                    continue
                end
                local image_value = value_8_11.Image
                if not image_value then
                    continue
                end
                local currency_frame_value_2 = value_7_8.CurrencyFrame
                local icon_value_2 = currency_frame_value_2.Icon
                local image_value_2 = value_8_11.Image
                icon_value_2.Image = image_value_2
            end

            return
        end
        closure_ready_3 = true
        if closure_cache[9] == nil then
            closure_cache[9] = on_coins_started
            closure_cache[10], closure_cache[11] = captured_value_7, captured_value_8
        end
    end
end
local value_12, value_13, value_14 = pairs(container_value:GetChildren())
for key_2, value_20 in value_12, value_13, value_14 do
    local value_15, value_16 = key_2, value_20
    local value_19: string = "Frame"
    local is_a_result = value_16:IsA(value_19)
    if not is_a_result then
        continue
    end
    local value_17_2: boolean = false
    value_16.Visible = value_17_2
end
value_12 = coin_collected_child.OnClientEvent
value_14 = on_coin_collected
value_12:Connect(value_14)
value_12 = coins_started_child.OnClientEvent
value_14 = on_coins_started
value_12:Connect(value_14)

return
