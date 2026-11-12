--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    EloRanks: number | {{ Elo: number, RankName: string }?},
    MaxElo: number,
    MaxRank: string,
    RankIcons: number | { Bronze: string, Diamond: string, DiamondPlus: string, Gold: string, GoldPlus: string, None: string, Silver: string, SilverPlus: string },
    RankOrder: number | { Bronze: number, Diamond: number, DiamondPlus: number, Gold: number, GoldPlus: number, None: number, Silver: number, SilverPlus: number },
}

local table_1: { EloRanks: number | {{ Elo: number, RankName: string }?}, MaxElo: number, MaxRank: string, RankIcons: number | { Bronze: string, Diamond: string, DiamondPlus: string, Gold: string, GoldPlus: string, None: string, Silver: string, SilverPlus: string }, RankOrder: number | { Bronze: number, Diamond: number, DiamondPlus: number, Gold: number, GoldPlus: number, None: number, Silver: number, SilverPlus: number } } = {
    EloRanks = 0,
    MaxRank = "DiamondPlus",
    MaxElo = 1600,
    RankIcons = 0,
    RankOrder = 0,
}
local table_2: {{ Elo: number, RankName: string }?} = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local table_3: { Elo: number, RankName: string } = {RankName = "Bronze", Elo = 1150}
local table_4: { Elo: number, RankName: string } = {RankName = "Silver", Elo = 1250}
local table_5: { Elo: number, RankName: string } = {RankName = "SilverPlus", Elo = 1325}
local table_6: { Elo: number, RankName: string } = {RankName = "Gold", Elo = 1400}
local table_7: { Elo: number, RankName: string } = {RankName = "GoldPlus", Elo = 1500}
local table_8: { Elo: number, RankName: string } = {RankName = "Diamond", Elo = 1600}
table_2[1], table_2[2], table_2[3], table_2[4], table_2[5], table_2[6] = table_3, table_4, table_5, table_6, table_7, table_8
table_1.EloRanks = table_2
local table_2_2: { Bronze: string, Diamond: string, DiamondPlus: string, Gold: string, GoldPlus: string, None: string, Silver: string, SilverPlus: string } = {
    None = "http://www.roblox.com/asset/?id=4801598442",
    Bronze = "http://www.roblox.com/asset/?id=4801543290",
    Silver = "http://www.roblox.com/asset/?id=4801543932",
    SilverPlus = "http://www.roblox.com/asset/?id=4802472365",
    Gold = "http://www.roblox.com/asset/?id=4801544128",
    GoldPlus = "http://www.roblox.com/asset/?id=4802472150",
    Diamond = "http://www.roblox.com/asset/?id=4801544484",
    DiamondPlus = "http://www.roblox.com/asset/?id=4809009917",
}
table_1.RankIcons = table_2_2
local table_2_3: { Bronze: number, Diamond: number, DiamondPlus: number, Gold: number, GoldPlus: number, None: number, Silver: number, SilverPlus: number } = {
    None = 0,
    Bronze = 1,
    Silver = 2,
    SilverPlus = 3,
    Gold = 4,
    GoldPlus = 5,
    Diamond = 6,
    DiamondPlus = 7,
}
table_1.RankOrder = table_2_3

return table_1
