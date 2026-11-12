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
local value_3: string = "SocialService"
local social_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "Players"
local local_player_value = game_value_2:GetService(value_4).LocalPlayer
local value_2_3: ExperienceInviteOptions = (Instance.new("ExperienceInviteOptions"))
local value_4_2: string = "Invite a friend!"
value_2_3.PromptMessage = value_4_2
do
    local captured_value = social_service

    local function can_send_game_invite(argument_1)
        local value_3_3
        do
            local captured_value_2, captured_value_3, closure_ready
            value_3_3 = function()
                if not closure_ready then
                    return
                end
                local value_1_2: Instance? = captured_value_2
                local value_3_5 = captured_value_3

                return value_1_2:CanSendGameInviteAsync(value_3_5)
            end
            captured_value_2, captured_value_3 = captured_value, argument_1
            closure_ready = true
        end
        local pcall_result, value_3_4 = pcall(value_3_3)

        return pcall_result and value_3_4
    end
end
local open_invites
do
    local captured_value_4, captured_value_5 = local_player_value, social_service
    open_invites = function()
        local value_2_5 = captured_value_4
        local value_4_4
        do
            local captured_value_6, captured_value_7, closure_ready_2
            value_4_4 = function()
                if not closure_ready_2 then
                    return
                end
                local value_1_5: Instance? = captured_value_6
                local value_3_8 = captured_value_7

                return value_1_5:CanSendGameInviteAsync(value_3_8)
            end
            captured_value_6, captured_value_7 = captured_value_5, value_2_5
            closure_ready_2 = true
        end
        local pcall_result_2, value_4_5 = pcall(value_4_4)
        if pcall_result_2 and value_4_5 then
            local value_3_6
            do
                local captured_value_8, captured_value_9 = captured_value_5, captured_value_4
                if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value_8) and same_capture(
                    closure_cache[3],
                    captured_value_9
                ) then
                    value_3_6 = closure_cache[1]
                else
                    local closure_ready_3
                    value_3_6 = function(): ()
                        if not closure_ready_3 then
                            return
                        end
                        local value_1_7: Instance = captured_value_8
                        local value_3_9 = captured_value_9
                        value_1_7:PromptGameInvite(value_3_9)

                        return
                    end
                    closure_ready_3 = true
                    if closure_cache[1] == nil then
                        closure_cache[1] = value_3_6
                        closure_cache[2], closure_cache[3] = captured_value_8, captured_value_9
                    end
                end
            end
            local pcall_result_3, value_3_7 = pcall(value_3_6)
        end

        return
    end
end
local activated_value = script.Parent.Title.Invite.Activated
local value_7 = open_invites
activated_value:Connect(value_7)

return
