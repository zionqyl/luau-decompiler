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

local local_player_value = game.Players.LocalPlayer
local require_value = require
local player_scripts_value = local_player_value.PlayerScripts
local value_5: string = "PlayerModule"
local require_result = require_value(player_scripts_value:WaitForChild(value_5))
local on_character_added
do
    local captured_value = require_result
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        on_character_added = closure_cache[1]
    else
        local closure_ready
        on_character_added = function<T1>(argument_1: T1): ()
            if not closure_ready then
                return
            end
            captured_value:GetControls():Enable()

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = on_character_added
            closure_cache[2] = captured_value
        end
    end
end
while true do
    local wait_value: (number?) -> (number) = task.wait
    wait_value()
    local character_value = local_player_value.Character
    if character_value then
        break
    end
end
local character_value_2 = local_player_value.Character
require_result:GetControls():Enable()
local character_added_value = local_player_value.CharacterAdded
local value_6_3 = on_character_added
character_added_value:Connect(value_6_3)

return
