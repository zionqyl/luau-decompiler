--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Effects: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? },
    Perks: nil | { Max: number } | { Max: number? },
    Pets: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? },
    Radios: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? },
    Toys: nil | { Max: number, Prices: {number}, Unequip: boolean } | { Max: number?, Prices: {number}?, Unequip: boolean? },
}

local table_1: { Effects: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? }, Perks: nil | { Max: number } | { Max: number? }, Pets: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? }, Radios: nil | { Max: number, Unequip: boolean } | { Max: number?, Unequip: boolean? }, Toys: nil | { Max: number, Prices: {number}, Unequip: boolean } | { Max: number?, Prices: {number}?, Unequip: boolean? } } = {
    [("Toys")] = nil,
    [("Toys")] = nil,
    [("Toys")] = nil,
    [("Toys")] = nil,
    [("Toys")] = nil,
}
local table_2: { Max: number?, Prices: {number}?, Unequip: boolean? } = {
    [("Unequip")] = nil,
    [("Unequip")] = nil,
    [("Unequip")] = nil,
}
local value_3: boolean = true
table_2.Unequip = value_3
local value_3_2: number = 4
table_2.Max = value_3_2
local table_3: {number} = {
    0,
    25,
    100,
    300,
}
table_2.Prices = table_3
table_1.Toys = table_2
local table_2_2: { Max: number?, Unequip: boolean? } = {[("Max")] = nil, [("Max")] = nil}
local value_3_3: number = 1
table_2_2.Max = value_3_3
local value_3_4: boolean = true
table_2_2.Unequip = value_3_4
table_1.Effects = table_2_2
local table_2_3: { Max: number? } = {[("Max")] = nil}
local value_3_5: number = 1
table_2_3.Max = value_3_5
table_1.Perks = table_2_3
local table_2_4: { Max: number?, Unequip: boolean? } = {[("Max")] = nil, [("Max")] = nil}
local value_3_6: number = 1
table_2_4.Max = value_3_6
local value_3_7: boolean = true
table_2_4.Unequip = value_3_7
table_1.Radios = table_2_4
local table_2_5: { Max: number?, Unequip: boolean? } = {[("Max")] = nil, [("Max")] = nil}
local value_3_8: number = 1
table_2_5.Max = value_3_8
local value_3_9: boolean = true
table_2_5.Unequip = value_3_9
table_1.Pets = table_2_5

return table_1
