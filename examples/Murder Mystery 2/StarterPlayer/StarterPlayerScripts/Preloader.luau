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
local value_3: string = "ContentProvider"
local content_provider_service: Instance = game_value:GetService(value_3)
local table_2 = {}
local value_3_2: string = "http://www.roblox.com/Thumbs/Avatar.ashx?x=" .. 250 .. "&y=" .. 250 .. "&Format=Png&userId="
local value_4_2: string = "http://www.roblox.com/Thumbs/Avatar.ashx?x=" .. 250 .. "&y=" .. 250 .. "&Format=Png&username="
local new_result: BindableFunction = Instance.new("BindableFunction", game.ReplicatedStorage)
local value_6_4: string = "GetPlayerImage"
new_result.Name = value_6_4
local find_image
do
    local captured_value, captured_value_2, captured_value_3 = table_2, value_3_2, value_4_2
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) and same_capture(
        closure_cache[3],
        captured_value_2
    ) and same_capture(closure_cache[4], captured_value_3) then
        find_image = closure_cache[1]
    else
        local closure_ready
        find_image = function(argument_1)
            if not closure_ready then
                return
            end
            local pairs_value, value_3_3, value_4_3 = pairs(captured_value)
            for key, value in pairs_value, value_3_3, value_4_3 do
                local value_5_3, value_6_5 = key, value
                local name_value = value_6_5.Name
                do
                    local take_fallback = name_value == argument_1
                    if not take_fallback then
                        local user_id_value = value_6_5.userId
                        local value_9_2 = argument_1
                        local tostring_value = tostring
                        local tostring_result = tostring_value(value_9_2)
                        take_fallback = user_id_value == tostring_result
                    end
                    if take_fallback then
                        local image_value = value_6_5.Image
                        local value_8_2 = value_5_3

                        return image_value, value_8_2
                    end
                end
            end
            value_3_3 = argument_1
            if (tonumber(value_3_3)) then
                return captured_value_2 .. argument_1, nil
            end

            return captured_value_3 .. argument_1, nil
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = find_image
            closure_cache[2], closure_cache[3], closure_cache[4] = captured_value, captured_value_2, captured_value_3
        end
    end
end
new_result.OnInvoke = find_image
local load_player_image
do
    local captured_value_4, captured_value_5, captured_value_6 = value_3_2, content_provider_service, table_2
    if closure_cache[5] ~= nil and same_capture(closure_cache[6], captured_value_4) and same_capture(
        closure_cache[7],
        captured_value_5
    ) and same_capture(closure_cache[8], captured_value_6) then
        load_player_image = closure_cache[5]
    else
        local closure_ready_2
        load_player_image = function(argument_1_2)
            if not closure_ready_2 then
                return
            end
            local value_4_4: string = "Player"
            if (argument_1_2:IsA(value_4_4)) then
                local name_value_2 = argument_1_2.Name
                local value_5_4: string = "Guest "
                local find_result = name_value_2:find(value_5_4)
                local value_2_3
                do
                    local take_fallback_2 = not find_result
                    if not take_fallback_2 then
                        value_2_3 = captured_value_4 .. "1"
                        take_fallback_2 = not value_2_3
                    end
                    if take_fallback_2 then
                        local user_id_value_2 = argument_1_2.userId
                        local value_4_7: number = 1
                        do
                            local take_fallback_3 = not (user_id_value_2 < value_4_7)
                            if not take_fallback_3 then
                                value_2_3 = captured_value_4 .. "1"
                                take_fallback_3 = not value_2_3
                            end
                            if take_fallback_3 then
                                value_2_3 = captured_value_4 .. argument_1_2.userId
                            end
                        end
                    end
                end
                local value_3_9: Instance = captured_value_5
                local value_5_5 = value_2_3
                value_3_9:Preload(value_5_5)
                local value_4_10 = value_2_3
                local value_5_6: string = "&bust="
                local tick_result = tick()
                local value_3_11 = value_4_10 .. value_5_6 .. (math.floor(tick_result))
                local value_5_7 = captured_value_6
                local table_6 = {
                    Name = 0,
                    userId = 0,
                    RawImage = 0,
                    Image = 0,
                }
                local name_value_3 = argument_1_2.Name
                table_6.Name = name_value_3
                local user_id_value_4 = argument_1_2.userId
                local tostring_result_2 = tostring(user_id_value_4)
                table_6.userId = tostring_result_2
                table_6.RawImage = value_2_3
                table_6.Image = value_3_11
                table.insert(value_5_7, table_6)
            end

            return
        end
        closure_ready_2 = true
        if closure_cache[5] == nil then
            closure_cache[5] = load_player_image
            closure_cache[6], closure_cache[7], closure_cache[8] = captured_value_4, captured_value_5, captured_value_6
        end
    end
end
local value_7 = game.Players.ChildAdded
local value_9 = load_player_image
value_7:connect(value_9)
value_7 = game.Players.ChildRemoved
do
    local captured_value_7, captured_value_8 = find_image, table_2
    if closure_cache[9] ~= nil and same_capture(closure_cache[10], captured_value_7) and same_capture(
        closure_cache[11],
        captured_value_8
    ) then
        value_9 = closure_cache[9]
    else
        local closure_ready_3
        value_9 = function(argument_1_3)
            if not closure_ready_3 then
                return
            end
            local value_2_5, value_3_12 = captured_value_7(argument_1_3.Name)
            if value_3_12 then
                table.remove(captured_value_8, value_3_12)
            end

            return
        end
        closure_ready_3 = true
        if closure_cache[9] == nil then
            closure_cache[9] = value_9
            closure_cache[10], closure_cache[11] = captured_value_7, captured_value_8
        end
    end
end
value_7:connect(value_9)
local value_8
value_7, value_8, value_9 = pairs(game.Players:GetPlayers())
for key_2, value_14 in value_7, value_8, value_9 do
    local value_10, value_11 = key_2, value_14
    local value_12 = load_player_image
    local value_13 = value_11
    value_12(value_13)
end

return
