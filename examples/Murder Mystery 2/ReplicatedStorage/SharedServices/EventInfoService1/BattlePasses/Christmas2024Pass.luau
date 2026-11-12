--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    FinalReward: string,
    FinalRewardCost: number,
    PassName: string,
    Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { ItemID: string, ItemType: string }, ["11"]: { Amount: number, ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { ItemID: string, ItemType: string }, ["2"]: { ItemID: string, ItemType: string }, ["20"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { ItemID: string, ItemType: string }, ["4"]: { ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { ItemID: string, ItemType: string }, ["7"]: { ItemID: string, ItemType: string }, ["8"]: { ItemID: string, ItemType: string }, ["9"]: { ItemID: string, ItemType: string } },
    TierCost: number,
    TotalTiers: number,
}

local table_1: { FinalReward: string, FinalRewardCost: number, PassName: string, Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { ItemID: string, ItemType: string }, ["11"]: { Amount: number, ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { ItemID: string, ItemType: string }, ["2"]: { ItemID: string, ItemType: string }, ["20"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { ItemID: string, ItemType: string }, ["4"]: { ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { ItemID: string, ItemType: string }, ["7"]: { ItemID: string, ItemType: string }, ["8"]: { ItemID: string, ItemType: string }, ["9"]: { ItemID: string, ItemType: string } }, TierCost: number, TotalTiers: number } = {
    PassName = "Christmas",
    TotalTiers = 20,
    TierCost = 800,
    FinalReward = "Celestial",
    FinalRewardCost = 98000,
    Rewards = 0,
}
local table_2: { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { Amount: number, ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } = {
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
local table_3: { ItemID: string, ItemType: string } = {
    ItemID = "Santa2024",
    ItemType = "Toys",
}
table_2["1"] = table_3
local table_3_2: { ItemID: string, ItemType: string } = {
    ItemID = "HotChocolate_K_2024",
    ItemType = "Weapons",
}
table_2["2"] = table_3_2
local table_3_3: { ItemID: string, ItemType: string } = {
    ItemID = "Gifts_K_2024",
    ItemType = "Weapons",
}
table_2["3"] = table_3_3
local table_3_4: { ItemID: string, ItemType: string } = {
    ItemID = "Igloo_G_2024",
    ItemType = "Weapons",
}
table_2["4"] = table_3_4
local table_3_5: { ItemID: string, ItemType: string } = {
    ItemID = "SnowKey2024",
    ItemType = "Materials",
}
table_2["5"] = table_3_5
local table_3_6: { ItemID: string, ItemType: string } = {
    ItemID = "TreeToy2024",
    ItemType = "Toys",
}
table_2["6"] = table_3_6
local table_3_7: { ItemID: string, ItemType: string } = {
    ItemID = "Stickers_X_K_2024",
    ItemType = "Weapons",
}
table_2["7"] = table_3_7
local table_3_8: { ItemID: string, ItemType: string } = {
    ItemID = "Forest_G_2024",
    ItemType = "Weapons",
}
table_2["8"] = table_3_8
local table_3_9: { ItemID: string, ItemType: string } = {
    ItemID = "Gingerheart_K_2024",
    ItemType = "Weapons",
}
table_2["9"] = table_3_9
local table_3_10: { ItemID: string, ItemType: string } = {
    ItemID = "Snowstorm2024",
    ItemType = "Effects",
}
table_2["10"] = table_3_10
local table_3_11: { Amount: number, ItemID: string, ItemType: string } = {
    ItemID = "SnowKey2024",
    ItemType = "Materials",
    Amount = 3,
}
table_2["11"] = table_3_11
local table_3_12: { ItemID: string, ItemType: string } = {
    ItemID = "Wrapped_G_2024",
    ItemType = "Weapons",
}
table_2["12"] = table_3_12
local table_3_13: { ItemID: string, ItemType: string } = {
    ItemID = "Gifts2024",
    ItemType = "Effects",
}
table_2["13"] = table_3_13
local table_3_14: { ItemID: string, ItemType: string } = {
    ItemID = "Snowglobe2024",
    ItemType = "Toys",
}
table_2["14"] = table_3_14
local table_3_15: { ItemID: string, ItemType: string } = {
    ItemID = "Logcutter_K_2024",
    ItemType = "Weapons",
}
table_2["15"] = table_3_15
local table_3_16: { ItemID: string, ItemType: string } = {
    ItemID = "Snowman2024",
    ItemType = "Toys",
}
table_2["16"] = table_3_16
local table_3_17: { ItemID: string, ItemType: string } = {
    ItemID = "Frostflame_K_2024",
    ItemType = "Weapons",
}
table_2["17"] = table_3_17
local table_3_18: { ItemID: string, ItemType: string } = {
    ItemID = "Starry2024",
    ItemType = "Effects",
}
table_2["18"] = table_3_18
local table_3_19: { ItemID: string, ItemType: string } = {
    ItemID = "Constellation_G_2024",
    ItemType = "Weapons",
}
table_2["19"] = table_3_19
local table_3_20: { Final: boolean, Image: string, ItemID: string } = {
    ItemID = "???",
    Final = true,
    Image = "rbxassetid://103185866141053",
}
table_2["20"] = table_3_20
table_1.Rewards = table_2

return table_1
