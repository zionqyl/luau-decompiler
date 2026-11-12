--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { Weapons: number | { Summer2025Box: number | { DataType: string, LayoutOrder: number, Price: number | { BeachBalls2025: number, SummerKey2025: number } } | { DataType: string, LayoutOrder: number, Price: { BeachBalls2025: number, SummerKey2025: number } } } | { Summer2025Box: { DataType: string, LayoutOrder: number, Price: { BeachBalls2025: number, SummerKey2025: number } } } }

local table_1: { Weapons: number | { Summer2025Box: number | { DataType: string, LayoutOrder: number, Price: number | { BeachBalls2025: number, SummerKey2025: number } } | { DataType: string, LayoutOrder: number, Price: { BeachBalls2025: number, SummerKey2025: number } } } | { Summer2025Box: { DataType: string, LayoutOrder: number, Price: { BeachBalls2025: number, SummerKey2025: number } } } } = {
    Weapons = 0,
}
local table_2: { Summer2025Box: number | { DataType: string, LayoutOrder: number, Price: number | { BeachBalls2025: number, SummerKey2025: number } } | { DataType: string, LayoutOrder: number, Price: { BeachBalls2025: number, SummerKey2025: number } } } = {
    Summer2025Box = 0,
}
local table_3: { DataType: string, LayoutOrder: number, Price: number | { BeachBalls2025: number, SummerKey2025: number } } = {
    DataType = "MysteryBox",
    Price = 0,
    LayoutOrder = 99,
}
local table_4: { BeachBalls2025: number, SummerKey2025: number } = {
    BeachBalls2025 = 800,
    SummerKey2025 = 1,
}
table_3.Price = table_4
table_2.Summer2025Box = table_3
table_1.Weapons = table_2

return table_1
