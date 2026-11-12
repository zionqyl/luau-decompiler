--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    PaintedSeer: nil | { Function: string, Image: string, Materials: number | { GodlyMetal: number, GodlyShards: number } | { GodlyMetal: number?, GodlyShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { GodlyMetal: number, GodlyShards: number }, Name: string, Rarity: string, SortPriority: number },
    RandomLegendaryWeapon: nil | { Function: string, Image: string, Materials: number | { RareShards: number } | { RareShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { RareShards: number }, Name: string, Rarity: string, SortPriority: number },
    RandomRareWeapon: nil | { Function: string, Image: string, Materials: number | { UncommonShards: number } | { UncommonShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { UncommonShards: number }, Name: string, Rarity: string, SortPriority: number },
    RandomUncommonWeapon: nil | { Function: string, Image: string, Materials: number | { CommonShards: number } | { CommonShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { CommonShards: number }, Name: string, Rarity: string, SortPriority: number },
    TheSeer: nil | { Image: string, Materials: number | { LegendaryShards: number } | { LegendaryShards: number? }, Name: string, Rarity: string, RewardAmount: number, RewardItem: string, RewardType: string, SortPriority: number } | { Image: string, Materials: { LegendaryShards: number }, Name: string, Rarity: string, RewardAmount: number, RewardItem: string, RewardType: string, SortPriority: number },
}

local table_1: { PaintedSeer: nil | { Function: string, Image: string, Materials: number | { GodlyMetal: number, GodlyShards: number } | { GodlyMetal: number?, GodlyShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { GodlyMetal: number, GodlyShards: number }, Name: string, Rarity: string, SortPriority: number }, RandomLegendaryWeapon: nil | { Function: string, Image: string, Materials: number | { RareShards: number } | { RareShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { RareShards: number }, Name: string, Rarity: string, SortPriority: number }, RandomRareWeapon: nil | { Function: string, Image: string, Materials: number | { UncommonShards: number } | { UncommonShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { UncommonShards: number }, Name: string, Rarity: string, SortPriority: number }, RandomUncommonWeapon: nil | { Function: string, Image: string, Materials: number | { CommonShards: number } | { CommonShards: number? }, Name: string, Rarity: string, SortPriority: number } | { Function: string, Image: string, Materials: { CommonShards: number }, Name: string, Rarity: string, SortPriority: number }, TheSeer: nil | { Image: string, Materials: number | { LegendaryShards: number } | { LegendaryShards: number? }, Name: string, Rarity: string, RewardAmount: number, RewardItem: string, RewardType: string, SortPriority: number } | { Image: string, Materials: { LegendaryShards: number }, Name: string, Rarity: string, RewardAmount: number, RewardItem: string, RewardType: string, SortPriority: number } } = {
    [("RandomUncommonWeapon")] = nil,
    [("RandomUncommonWeapon")] = nil,
    [("RandomUncommonWeapon")] = nil,
    [("RandomUncommonWeapon")] = nil,
    [("RandomUncommonWeapon")] = nil,
}
local table_2: { Function: string, Image: string, Materials: number | { CommonShards: number } | { CommonShards: number? }, Name: string, Rarity: string, SortPriority: number } = {
    Name = "Random Uncommon Weapon",
    Image = "rbxassetid://582222761",
    Rarity = "Uncommon",
    Materials = 0,
    SortPriority = 1000,
    Function = "RandomCraft",
}
local table_3: { CommonShards: number? } = {[("CommonShards")] = nil}
local value_4: number = 12
table_3.CommonShards = value_4
table_2.Materials = table_3
table_1.RandomUncommonWeapon = table_2
local table_2_2: { Function: string, Image: string, Materials: number | { UncommonShards: number } | { UncommonShards: number? }, Name: string, Rarity: string, SortPriority: number } = {
    Name = "Random Rare Weapon",
    Image = "rbxassetid://582222760",
    Rarity = "Rare",
    Materials = 0,
    SortPriority = 1100,
    Function = "RandomCraft",
}
local table_3_2: { UncommonShards: number? } = {[("UncommonShards")] = nil}
local value_4_2: number = 12
table_3_2.UncommonShards = value_4_2
table_2_2.Materials = table_3_2
table_1.RandomRareWeapon = table_2_2
local table_2_3: { Function: string, Image: string, Materials: number | { RareShards: number } | { RareShards: number? }, Name: string, Rarity: string, SortPriority: number } = {
    Name = "Random Legendary Weapon",
    Image = "rbxassetid://582222766",
    Rarity = "Legendary",
    Materials = 0,
    SortPriority = 1200,
    Function = "RandomCraft",
}
local table_3_3: { RareShards: number? } = {[("RareShards")] = nil}
local value_4_3: number = 12
table_3_3.RareShards = value_4_3
table_2_3.Materials = table_3_3
table_1.RandomLegendaryWeapon = table_2_3
local table_2_4: { Image: string, Materials: number | { LegendaryShards: number } | { LegendaryShards: number? }, Name: string, Rarity: string, RewardAmount: number, RewardItem: string, RewardType: string, SortPriority: number } = {
    Name = "Seer",
    Image = "http://www.roblox.com/asset/?id=198459100",
    Rarity = "Godly",
    RewardItem = "TheSeer",
    RewardAmount = 1,
    RewardType = "Weapons",
    Materials = 0,
    SortPriority = 1300,
}
local table_3_4: { LegendaryShards: number? } = {[("LegendaryShards")] = nil}
local value_4_4: number = 20
table_3_4.LegendaryShards = value_4_4
table_2_4.Materials = table_3_4
table_1.TheSeer = table_2_4
local table_2_5: { Function: string, Image: string, Materials: number | { GodlyMetal: number, GodlyShards: number } | { GodlyMetal: number?, GodlyShards: number? }, Name: string, Rarity: string, SortPriority: number } = {
    Name = "Random Painted Seer",
    Image = "rbxassetid://3184179319",
    Rarity = "Godly",
    Materials = 0,
    SortPriority = 1400,
    Function = "PaintedSeer",
}
local table_3_5: { GodlyMetal: number?, GodlyShards: number? } = {
    [("GodlyShards")] = nil,
    [("GodlyShards")] = nil,
}
local value_4_5: number = 10
table_3_5.GodlyShards = value_4_5
local value_4_6: number = 10
table_3_5.GodlyMetal = value_4_6
table_2_5.Materials = table_3_5
table_1.PaintedSeer = table_2_5

return table_1
