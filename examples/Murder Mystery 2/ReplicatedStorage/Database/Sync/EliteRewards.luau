--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    EliteEffect: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? },
    EliteKnife: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? },
    ElitePet: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? },
    EliteRadio: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? },
}

local table_1: { EliteEffect: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? }, EliteKnife: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? }, ElitePet: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? }, EliteRadio: nil | { Reward: string, Type: string } | { Reward: string?, Type: string? } } = {
    [("EliteKnife")] = nil,
    [("EliteKnife")] = nil,
    [("EliteKnife")] = nil,
}
local table_2: { Reward: string?, Type: string? } = {[("Reward")] = nil, [("Reward")] = nil}
local value_3: string = "Elite"
table_2.Reward = value_3
local value_3_2: string = "Weapon"
table_2.Type = value_3_2
table_1.EliteKnife = table_2
local table_2_2: { Reward: string?, Type: string? } = {[("Reward")] = nil, [("Reward")] = nil}
local value_3_3: string = "Elite"
table_2_2.Reward = value_3_3
local value_3_4: string = "Radios"
table_2_2.Type = value_3_4
table_1.EliteRadio = table_2_2
local table_2_3: { Reward: string?, Type: string? } = {[("Reward")] = nil, [("Reward")] = nil}
local value_3_5: string = "Elitify"
table_2_3.Reward = value_3_5
local value_3_6: string = "Effects"
table_2_3.Type = value_3_6
table_1.EliteEffect = table_2_3
local table_2_4: { Reward: string?, Type: string? } = {[("Reward")] = nil, [("Reward")] = nil}
local value_3_7: string = "Elitey"
table_2_4.Reward = value_3_7
local value_3_8: string = "Pets"
table_2_4.Type = value_3_8
table_1.ElitePet = table_2_4

return table_1
