--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    ChallengeRewards: number | {{ ItemID: string, ItemType: string, Required: number }},
    FinalReward: string,
    FinalRewardCost: number,
    PassName: string,
    Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { Amount: number, ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { Amount: number, ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { Amount: number, ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { Amount: number, ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { Amount: number, ItemID: string, ItemType: string }?, ["2"]: { Amount: number, ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { Amount: number, ItemID: string, ItemType: string }?, ["4"]: { Amount: number, ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { Amount: number, ItemID: string, ItemType: string }?, ["7"]: { Amount: number, ItemID: string, ItemType: string }?, ["8"]: { Amount: number, ItemID: string, ItemType: string }?, ["9"]: { Amount: number, ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { Amount: number, ItemID: string, ItemType: string }, ["11"]: { Amount: number, ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { Amount: number, ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { Amount: number, ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { Amount: number, ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { Amount: number, ItemID: string, ItemType: string }, ["2"]: { Amount: number, ItemID: string, ItemType: string }, ["20"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { Amount: number, ItemID: string, ItemType: string }, ["4"]: { Amount: number, ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { Amount: number, ItemID: string, ItemType: string }, ["7"]: { Amount: number, ItemID: string, ItemType: string }, ["8"]: { Amount: number, ItemID: string, ItemType: string }, ["9"]: { Amount: number, ItemID: string, ItemType: string } },
    TierCost: number,
    TotalTiers: number,
}

local table_1: { ChallengeRewards: number | {{ ItemID: string, ItemType: string, Required: number }}, FinalReward: string, FinalRewardCost: number, PassName: string, Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { Amount: number, ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { Amount: number, ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { Amount: number, ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { Amount: number, ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { Amount: number, ItemID: string, ItemType: string }?, ["2"]: { Amount: number, ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { Amount: number, ItemID: string, ItemType: string }?, ["4"]: { Amount: number, ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { Amount: number, ItemID: string, ItemType: string }?, ["7"]: { Amount: number, ItemID: string, ItemType: string }?, ["8"]: { Amount: number, ItemID: string, ItemType: string }?, ["9"]: { Amount: number, ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { Amount: number, ItemID: string, ItemType: string }, ["11"]: { Amount: number, ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { Amount: number, ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { Amount: number, ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { Amount: number, ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { Amount: number, ItemID: string, ItemType: string }, ["2"]: { Amount: number, ItemID: string, ItemType: string }, ["20"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { Amount: number, ItemID: string, ItemType: string }, ["4"]: { Amount: number, ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { Amount: number, ItemID: string, ItemType: string }, ["7"]: { Amount: number, ItemID: string, ItemType: string }, ["8"]: { Amount: number, ItemID: string, ItemType: string }, ["9"]: { Amount: number, ItemID: string, ItemType: string } }, TierCost: number, TotalTiers: number } = {
    PassName = "Halloween",
    TotalTiers = 20,
    TierCost = 800,
    FinalReward = "VampireAxe",
    FinalRewardCost = 98000,
    ChallengeRewards = 0,
    Rewards = 0,
}
local table_2: {{ ItemID: string, ItemType: string, Required: number }} = {
    {ItemID = "Lantern2024", ItemType = "Toys", Required = 5},
    {ItemID = "Bats2024", ItemType = "Effects", Required = 25},
    {ItemID = "Candle2024", ItemType = "Toys", Required = 100},
}
table_1.ChallengeRewards = table_2
local table_2_2: { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { Amount: number, ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { Amount: number, ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { Amount: number, ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { Amount: number, ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { Amount: number, ItemID: string, ItemType: string }?, ["2"]: { Amount: number, ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { Amount: number, ItemID: string, ItemType: string }?, ["4"]: { Amount: number, ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { Amount: number, ItemID: string, ItemType: string }?, ["7"]: { Amount: number, ItemID: string, ItemType: string }?, ["8"]: { Amount: number, ItemID: string, ItemType: string }?, ["9"]: { Amount: number, ItemID: string, ItemType: string }? } = {
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
    ["1"] = nil,
}
local table_3_4: { ItemID: string, ItemType: string } = {
    ItemID = "Ghosts2024",
    ItemType = "Effects",
}
table_2_2["1"] = table_3_4
local table_3_5: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "CandyCorn_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["2"] = table_3_5
local table_3_6: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "VampireKey2024",
    ItemType = "Materials",
    Amount = 1,
}
table_2_2["3"] = table_3_6
local table_3_7: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Bats_G_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["4"] = table_3_7
local table_3_8: { ItemID: string, ItemType: string } = {
    ItemID = "Gravestone2024",
    ItemType = "Toys",
}
table_2_2["5"] = table_3_8
local table_3_9: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Stickers_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["6"] = table_3_9
local table_3_10: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "VampireKey2024",
    ItemType = "Materials",
    Amount = 1,
}
table_2_2["7"] = table_3_10
local table_3_11: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Candles_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["8"] = table_3_11
local table_3_12: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "VampireKey2024",
    ItemType = "Materials",
    Amount = 1,
}
table_2_2["9"] = table_3_12
local table_3_13: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Monster_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["10"] = table_3_13
local table_3_14: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Moons_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["11"] = table_3_14
local table_3_15: { ItemID: string, ItemType: string } = {
    ItemID = "MagicBook2024",
    ItemType = "Toys",
}
table_2_2["12"] = table_3_15
local table_3_16: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Clown_G_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["13"] = table_3_16
local table_3_17: { ItemID: string, ItemType: string } = {
    ItemID = "Vampiric2024",
    ItemType = "Effects",
}
table_2_2["14"] = table_3_17
local table_3_18: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Storm_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["15"] = table_3_18
local table_3_19: { ItemID: string, ItemType: string } = {
    ItemID = "VampireRadio2024",
    ItemType = "Radios",
}
table_2_2["16"] = table_3_19
local table_3_20: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Candleflame_G_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["17"] = table_3_20
local table_3_21: { ItemID: string, ItemType: string } = {
    ItemID = "Cursed2024",
    ItemType = "Effects",
}
table_2_2["18"] = table_3_21
local table_3_22: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "Cursed_K_2024",
    ItemType = "Weapons",
    Amount = 1,
}
table_2_2["19"] = table_3_22
local table_3_23: { Final: boolean, Image: string, ItemID: string } = {
    ItemID = "???",
    Final = true,
    Image = "rbxassetid://85337315454669",
}
table_2_2["20"] = table_3_23
table_1.Rewards = table_2_2

return table_1
