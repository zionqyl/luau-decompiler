--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { Weapons: number | { Christmas2024Box: number | { DataType: string, LayoutOrder: number, Price: number | { SnowKey2024: number, SnowTokens2024: number } } | { DataType: string, LayoutOrder: number, Price: { SnowKey2024: number, SnowTokens2024: number } }, CoinExchange: number | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: number | { SnowTokens2024: number } } | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: { SnowTokens2024: number } } } | { Christmas2024Box: { DataType: string, LayoutOrder: number, Price: { SnowKey2024: number, SnowTokens2024: number } }, CoinExchange: { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: { SnowTokens2024: number } } } }

local table_1: { Weapons: number | { Christmas2024Box: number | { DataType: string, LayoutOrder: number, Price: number | { SnowKey2024: number, SnowTokens2024: number } } | { DataType: string, LayoutOrder: number, Price: { SnowKey2024: number, SnowTokens2024: number } }, CoinExchange: number | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: number | { SnowTokens2024: number } } | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: { SnowTokens2024: number } } } | { Christmas2024Box: { DataType: string, LayoutOrder: number, Price: { SnowKey2024: number, SnowTokens2024: number } }, CoinExchange: { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: { SnowTokens2024: number } } } } = {
    Weapons = 0,
}
local table_2: { Christmas2024Box: number | { DataType: string, LayoutOrder: number, Price: number | { SnowKey2024: number, SnowTokens2024: number } } | { DataType: string, LayoutOrder: number, Price: { SnowKey2024: number, SnowTokens2024: number } }, CoinExchange: number | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: number | { SnowTokens2024: number } } | { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: { SnowTokens2024: number } } } = {
    Christmas2024Box = 0,
    CoinExchange = 0,
}
local table_3: { DataType: string, LayoutOrder: number, Price: number | { SnowKey2024: number, SnowTokens2024: number } } = {
    DataType = "MysteryBox",
    Price = 0,
    LayoutOrder = 99,
}
local table_4: { SnowKey2024: number, SnowTokens2024: number } = {
    SnowTokens2024 = 800,
    SnowKey2024 = 1,
}
table_3.Price = table_4
table_2.Christmas2024Box = table_3
local table_3_2: { CustomReward: boolean, DataType: string, Description: string, ExchangeAmount: number, LayoutOrder: number, Price: number | { SnowTokens2024: number } } = {
    Description = "Exchange 100 Snow Tokens for 100 Coins.",
    DataType = "Materials",
    Price = 0,
    ExchangeAmount = 100,
    LayoutOrder = 90,
    CustomReward = true,
}
local table_4_2: { SnowTokens2024: number } = {SnowTokens2024 = 100}
table_3_2.Price = table_4_2
table_2.CoinExchange = table_3_2
table_1.Weapons = table_2

return table_1
