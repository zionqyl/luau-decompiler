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

local value_1: boolean?
if game.GameId ~= 119460199 then
    value_1 = false
else
    value_1 = true
end
local workspace_value: Workspace = workspace
local value_4 = "CurrentEventEnding"
local current_event_ending_value = workspace_value:GetAttribute(value_4)
local value_3_2: boolean = false
value_4 = workspace
local value_6: string? = "CurrentEvent"
if (value_4:GetAttribute(value_6)) == "Halloween" then
    value_3_2 = not current_event_ending_value
end
local table_2 = {
    Standard = 0,
    Disguises = 0,
    Assassin = 0,
    VampireHunt = 0,
}
value_4 = {
    DisplayName = "Standard",
    Image = "rbxassetid://14148051887",
    PlaceID = 142823291,
    TestID = 188331334,
    Popular = true,
    PlayerCount = 0,
    Description = 0,
    Order = 10,
}
local value_5: nil | boolean | {nil} = {nil, nil, nil}
value_6 = "\226\128\162 Standard MM2 Gamemode"
local value_7 = "\226\128\162 All cosmetics and avatars enabled"
local value_8 = "\226\128\162 Full XP and coins"
value_5[1], value_5[2], value_5[3] = value_6, value_7, value_8
value_4.Description = value_5
table_2.Standard = value_4
value_4 = {
    DisplayName = "Disguises",
    Image = "rbxassetid://14156478096",
    PlaceID = 335132309,
    TestID = 333740520,
    PlayerCount = 0,
    Description = 0,
    Order = 20,
}
value_5 = {
    nil,
    nil,
    nil,
    nil,
}
value_6 = "\226\128\162 Standard MM2 Gamemode"
value_7 = "\226\128\162 Player avatars are disguised"
value_8 = "\226\128\162 Some cosmetics are disabled"
local value_9: string = "\226\128\162 Full XP and coins"
value_5[1], value_5[2], value_5[3], value_5[4] = value_6, value_7, value_8, value_9
value_4.Description = value_5
table_2.Disguises = value_4
value_4 = {
    DisplayName = "Assassin",
    Image = "rbxassetid://14167876198",
    PlaceID = 636649648,
    TestID = 594100598,
    PlayerCount = 0,
    Description = 0,
    Order = 30,
}
value_5 = {
    nil,
    nil,
    nil,
    nil,
}
value_6 = "\226\128\162 Custom game mode"
value_7 = "\226\128\162 All players get a knife, hunt down your target"
value_8 = "\226\128\162 Alternate XP, full Coins"
local value_9_2: string = "\226\128\162 All cosmetics and avatars enabled"
value_5[1], value_5[2], value_5[3], value_5[4] = value_6, value_7, value_8, value_9_2
value_4.Description = value_5
table_2.Assassin = value_4
value_4 = {
    DisplayName = "Vampire Hunt",
    Image = "rbxassetid://117092830478669",
    PlaceID = 73210641948512,
    TestID = 124544126418603,
    LimitedTime = true,
    PlayerCount = 0,
    Description = 0,
    Order = 40,
    Hidden = true,
}
value_5 = {
    nil,
    nil,
    nil,
    nil,
}
value_6 = "\226\128\162 24 player servers"
value_7 = "\226\128\162 Teams of 3 vampires and 3 hunters"
value_8 = "\226\128\162 Vampires get custom perk"
local value_9_3: string = "\226\128\162 Full XP and coins"
value_5[1], value_5[2], value_5[3], value_5[4] = value_6, value_7, value_8, value_9_3
value_4.Description = value_5
table_2.VampireHunt = value_4
if value_3_2 then
    value_4 = table_2.VampireHunt
    value_5 = false
    value_4.Hidden = value_5
end
value_4 = table_2
value_5 = nil
value_6 = nil
for key, value in value_4, value_5, value_6 do
    value_7, value_8 = key, value
    local place_id_value = value_8.PlaceID
    value_8.LiveID = place_id_value
end
if value_1 then
    value_4 = table_2
    value_5 = nil
    value_6 = nil
    for key_2, value_10 in value_4, value_5, value_6 do
        value_7, value_8 = key_2, value_10
        local test_id_value = value_8.TestID
        value_8.PlaceID = test_id_value
    end
end
do
    local captured_value = table_2
    local is_game_mode
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        is_game_mode = closure_cache[1]
    else
        local closure_ready
        is_game_mode = function(argument_1: string)
            if not closure_ready then
                return
            end
            if not captured_value[argument_1] then
                return
            end
            local value_2_3: boolean?
            if game.PlaceId ~= captured_value[captured_value].PlaceID then
                value_2_3 = false
            else
                value_2_3 = true
            end

            return value_2_3
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = is_game_mode
            closure_cache[2] = captured_value
        end
    end
end

return table_2
