--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { Weapons: number | { Halloween2025Box: number | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: number | { Candies2025: number, HalloweenKey2025: number } } | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: { Candies2025: number, HalloweenKey2025: number } } } | { Halloween2025Box: { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: { Candies2025: number, HalloweenKey2025: number } } } }

local table_1: { Weapons: number | { Halloween2025Box: number | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: number | { Candies2025: number, HalloweenKey2025: number } } | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: { Candies2025: number, HalloweenKey2025: number } } } | { Halloween2025Box: { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: { Candies2025: number, HalloweenKey2025: number } } } } = {
    Weapons = 0,
}
local table_2: { Halloween2025Box: number | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: number | { Candies2025: number, HalloweenKey2025: number } } | { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: { Candies2025: number, HalloweenKey2025: number } } } = {
    Halloween2025Box = 0,
}
local table_3: { DataType: string, LayoutOrder: number, LiveEvent: boolean, Price: number | { Candies2025: number, HalloweenKey2025: number } } = {
    DataType = "MysteryBox",
    Price = 0,
    LiveEvent = true,
    LayoutOrder = 99,
}
local table_4: { Candies2025: number, HalloweenKey2025: number } = {
    Candies2025 = 800,
    HalloweenKey2025 = 1,
}
table_3.Price = table_4
table_2.Halloween2025Box = table_3
table_1.Weapons = table_2

return table_1
