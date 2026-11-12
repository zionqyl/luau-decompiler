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
    Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { ItemID: string, ItemType: string }?, ["21"]: { ItemID: string, ItemType: string }?, ["22"]: { ItemID: string, ItemType: string }?, ["23"]: { ItemID: string, ItemType: string }?, ["24"]: { ItemID: string, ItemType: string }?, ["25"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { ItemID: string, ItemType: string }, ["11"]: { ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { ItemID: string, ItemType: string }, ["2"]: { ItemID: string, ItemType: string }, ["20"]: { ItemID: string, ItemType: string }, ["21"]: { ItemID: string, ItemType: string }, ["22"]: { ItemID: string, ItemType: string }, ["23"]: { ItemID: string, ItemType: string }, ["24"]: { ItemID: string, ItemType: string }, ["25"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { ItemID: string, ItemType: string }, ["4"]: { ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { ItemID: string, ItemType: string }, ["7"]: { ItemID: string, ItemType: string }, ["8"]: { ItemID: string, ItemType: string }, ["9"]: { ItemID: string, ItemType: string } },
    TierCost: number,
    TotalTiers: number,
}

local table_1: { FinalReward: string, FinalRewardCost: number, PassName: string, Rewards: number | { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { ItemID: string, ItemType: string }?, ["21"]: { ItemID: string, ItemType: string }?, ["22"]: { ItemID: string, ItemType: string }?, ["23"]: { ItemID: string, ItemType: string }?, ["24"]: { ItemID: string, ItemType: string }?, ["25"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } | { ["1"]: { ItemID: string, ItemType: string }, ["10"]: { ItemID: string, ItemType: string }, ["11"]: { ItemID: string, ItemType: string }, ["12"]: { ItemID: string, ItemType: string }, ["13"]: { ItemID: string, ItemType: string }, ["14"]: { ItemID: string, ItemType: string }, ["15"]: { ItemID: string, ItemType: string }, ["16"]: { ItemID: string, ItemType: string }, ["17"]: { ItemID: string, ItemType: string }, ["18"]: { ItemID: string, ItemType: string }, ["19"]: { ItemID: string, ItemType: string }, ["2"]: { ItemID: string, ItemType: string }, ["20"]: { ItemID: string, ItemType: string }, ["21"]: { ItemID: string, ItemType: string }, ["22"]: { ItemID: string, ItemType: string }, ["23"]: { ItemID: string, ItemType: string }, ["24"]: { ItemID: string, ItemType: string }, ["25"]: { Final: boolean, Image: string, ItemID: string }, ["3"]: { ItemID: string, ItemType: string }, ["4"]: { ItemID: string, ItemType: string }, ["5"]: { ItemID: string, ItemType: string }, ["6"]: { ItemID: string, ItemType: string }, ["7"]: { ItemID: string, ItemType: string }, ["8"]: { ItemID: string, ItemType: string }, ["9"]: { ItemID: string, ItemType: string } }, TierCost: number, TotalTiers: number } = {
    PassName = "Summer",
    TotalTiers = 25,
    TierCost = 800,
    FinalReward = "SunsetKnife",
    FinalRewardCost = 90000,
    Rewards = 0,
}
local table_2: { ["1"]: { ItemID: string, ItemType: string }?, ["10"]: { ItemID: string, ItemType: string }?, ["11"]: { ItemID: string, ItemType: string }?, ["12"]: { ItemID: string, ItemType: string }?, ["13"]: { ItemID: string, ItemType: string }?, ["14"]: { ItemID: string, ItemType: string }?, ["15"]: { ItemID: string, ItemType: string }?, ["16"]: { ItemID: string, ItemType: string }?, ["17"]: { ItemID: string, ItemType: string }?, ["18"]: { ItemID: string, ItemType: string }?, ["19"]: { ItemID: string, ItemType: string }?, ["2"]: { ItemID: string, ItemType: string }?, ["20"]: { ItemID: string, ItemType: string }?, ["21"]: { ItemID: string, ItemType: string }?, ["22"]: { ItemID: string, ItemType: string }?, ["23"]: { ItemID: string, ItemType: string }?, ["24"]: { ItemID: string, ItemType: string }?, ["25"]: { Final: boolean, Image: string, ItemID: string }?, ["3"]: { ItemID: string, ItemType: string }?, ["4"]: { ItemID: string, ItemType: string }?, ["5"]: { ItemID: string, ItemType: string }?, ["6"]: { ItemID: string, ItemType: string }?, ["7"]: { ItemID: string, ItemType: string }?, ["8"]: { ItemID: string, ItemType: string }?, ["9"]: { ItemID: string, ItemType: string }? } = {
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
    ItemID = "IceCream2025",
    ItemType = "Toys",
}
table_2["1"] = table_3
local table_3_2: { ItemID: string, ItemType: string } = {
    ItemID = "Leaves_K_2025",
    ItemType = "Weapons",
}
table_2["2"] = table_3_2
local table_3_3: { ItemID: string, ItemType: string } = {
    ItemID = "Coconut_K_2025",
    ItemType = "Weapons",
}
table_2["3"] = table_3_3
local table_3_4: { ItemID: string, ItemType: string } = {
    ItemID = "Stickers_K_2025",
    ItemType = "Weapons",
}
table_2["4"] = table_3_4
local table_3_5: { ItemID: string, ItemType: string } = {
    ItemID = "SummerKey2025",
    ItemType = "Materials",
}
table_2["5"] = table_3_5
local table_3_6: { ItemID: string, ItemType: string } = {
    ItemID = "Flamingo2025",
    ItemType = "Toys",
}
table_2["6"] = table_3_6
local table_3_7: { ItemID: string, ItemType: string } = {
    ItemID = "Striped_G_2025",
    ItemType = "Weapons",
}
table_2["7"] = table_3_7
local table_3_8: { ItemID: string, ItemType: string } = {
    ItemID = "Pool_K_2025",
    ItemType = "Weapons",
}
table_2["8"] = table_3_8
local table_3_9: { ItemID: string, ItemType: string } = {
    ItemID = "SummerKey2025",
    ItemType = "Materials",
}
table_2["9"] = table_3_9
local table_3_10: { ItemID: string, ItemType: string } = {
    ItemID = "Soda_G_2025",
    ItemType = "Weapons",
}
table_2["10"] = table_3_10
local table_3_11: { ItemID: string, ItemType: string } = {
    ItemID = "FlamingoEffect2025",
    ItemType = "Effects",
}
table_2["11"] = table_3_11
local table_3_12: { ItemID: string, ItemType: string } = {
    ItemID = "SummerKey2025",
    ItemType = "Materials",
}
table_2["12"] = table_3_12
local table_3_13: { ItemID: string, ItemType: string } = {
    ItemID = "Lava_K_2025",
    ItemType = "Weapons",
}
table_2["13"] = table_3_13
local table_3_14: { ItemID: string, ItemType: string } = {
    ItemID = "Retro2025",
    ItemType = "Effects",
}
table_2["14"] = table_3_14
local table_3_15: { ItemID: string, ItemType: string } = {
    ItemID = "RetroRadio2025",
    ItemType = "Radios",
}
table_2["15"] = table_3_15
local table_3_16: { ItemID: string, ItemType: string } = {
    ItemID = "SummerKey2025",
    ItemType = "Materials",
}
table_2["16"] = table_3_16
local table_3_17: { ItemID: string, ItemType: string } = {
    ItemID = "Aquatic2025",
    ItemType = "Effects",
}
table_2["17"] = table_3_17
local table_3_18: { ItemID: string, ItemType: string } = {
    ItemID = "VolleyBall2025",
    ItemType = "Toys",
}
table_2["18"] = table_3_18
local table_3_19: { ItemID: string, ItemType: string } = {
    ItemID = "PopArt_K_2025",
    ItemType = "Weapons",
}
table_2["19"] = table_3_19
local table_3_20: { ItemID: string, ItemType: string } = {
    ItemID = "Heatwave2025",
    ItemType = "Effects",
}
table_2["20"] = table_3_20
local table_3_21: { ItemID: string, ItemType: string } = {
    ItemID = "Tropical_K_2025",
    ItemType = "Weapons",
}
table_2["21"] = table_3_21
local table_3_22: { ItemID: string, ItemType: string } = {
    ItemID = "SummerKey2025",
    ItemType = "Materials",
}
table_2["22"] = table_3_22
local table_3_23: { ItemID: string, ItemType: string } = {
    ItemID = "Aquarium_G_2025",
    ItemType = "Weapons",
}
table_2["23"] = table_3_23
local table_3_24: { ItemID: string, ItemType: string } = {
    ItemID = "SynthEffect2025",
    ItemType = "Effects",
}
table_2["24"] = table_3_24
local table_3_25: { Final: boolean, Image: string, ItemID: string } = {
    ItemID = "???",
    Final = true,
    Image = "rbxthumb://type=Asset&w=150&h=150&id=103526268515240",
}
table_2["25"] = table_3_25
table_1.Rewards = table_2

return table_1
