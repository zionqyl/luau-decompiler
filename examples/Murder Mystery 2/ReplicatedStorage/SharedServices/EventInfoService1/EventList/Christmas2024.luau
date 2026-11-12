--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    BattlePassName: string,
    Currency: string,
    DevProducts: number | { SnowTokens2024: number | { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } | { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } } | { SnowTokens2024: { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } },
    GiftingCurrencyPrice: number,
    GiftingRewardID: string,
    GiftingRewardRequiredAmount: number,
    ItemPackItems: number | { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } },
    Key: string,
    LeaderboardEndTime: number,
    LeaderboardPauseEndTime: number,
    LeaderboardPauseStartTime: number,
    MysteryBoxName: string,
    Name: string,
    ProfileData: number | { ClaimedRewards: number | {  }, CurrentTier: number, FinalRewardClaimed: boolean, GiftInventory: number, GiftRewardClaimedAmount: number, GiftsGiven: number, LeaderboardPoints: number } | { ClaimedRewards: {  }, CurrentTier: number, FinalRewardClaimed: boolean, GiftInventory: number, GiftRewardClaimedAmount: number, GiftsGiven: number, LeaderboardPoints: number },
    ShopButton: string,
    ShopCover: string,
    Title: string,
    Year: string,
}

local table_1: { BattlePassName: string, Currency: string, DevProducts: number | { SnowTokens2024: number | { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } | { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } } | { SnowTokens2024: { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } }, GiftingCurrencyPrice: number, GiftingRewardID: string, GiftingRewardRequiredAmount: number, ItemPackItems: number | { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } }, Key: string, LeaderboardEndTime: number, LeaderboardPauseEndTime: number, LeaderboardPauseStartTime: number, MysteryBoxName: string, Name: string, ProfileData: number | { ClaimedRewards: number | {  }, CurrentTier: number, FinalRewardClaimed: boolean, GiftInventory: number, GiftRewardClaimedAmount: number, GiftsGiven: number, LeaderboardPoints: number } | { ClaimedRewards: {  }, CurrentTier: number, FinalRewardClaimed: boolean, GiftInventory: number, GiftRewardClaimedAmount: number, GiftsGiven: number, LeaderboardPoints: number }, ShopButton: string, ShopCover: string, Title: string, Year: string } = {
    Name = "Christmas",
    Year = "2024",
    Title = "Christmas2024",
    Currency = "SnowTokens2024",
    Key = "SnowKey2024",
    BattlePassName = "Christmas2024Pass",
    MysteryBoxName = "Christmas2024Box",
    GiftingRewardID = "Bauble",
    GiftingCurrencyPrice = 800,
    GiftingRewardRequiredAmount = 100,
    LeaderboardPauseStartTime = 1734980400,
    LeaderboardPauseEndTime = 1735286400,
    LeaderboardEndTime = 1735588800,
    ShopCover = "rbxassetid://112851189317262",
    ShopButton = "rbxassetid://136255286776025",
    ItemPackItems = 0,
    DevProducts = 0,
    ProfileData = 0,
}
local table_2: { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } = {
    Knife = {
        ItemID = "AuroraKnife",
        GamePassID = 1008813284,
        DevProductID = 2677077653,
    },
    Gun = {ItemID = "AuroraGun", GamePassID = 1008841389, DevProductID = 2677077552},
    Bundle = {
        KnifeItemID = "AuroraKnife",
        GunItemID = "AuroraGun",
        EffectItemID = "Aurora2024",
        GamePassID = 1009231264,
        DevProductID = 2677077853,
    },
}
table_1.ItemPackItems = table_2
local table_2_2: { SnowTokens2024: number | { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } | { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } } = {
    SnowTokens2024 = 0,
}
local table_3_4: { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } = {
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
}
local value_4: number = 1708622087
table_3_4["800"] = value_4
local value_4_2: number = 1708622419
table_3_4["3200"] = value_4_2
local value_4_3: number = 1708622583
table_3_4["6400"] = value_4_3
local value_4_4: number = 1708623108
table_3_4["14280"] = value_4_4
local value_4_5: number = 1708623477
table_3_4["46800"] = value_4_5
local value_4_6: number = 1708623763
table_3_4["116000"] = value_4_6
local value_4_7: number = 1708624150
table_3_4["270000"] = value_4_7
table_2_2.SnowTokens2024 = table_3_4
table_1.DevProducts = table_2_2
local table_2_3: { ClaimedRewards: number | {  }, CurrentTier: number, FinalRewardClaimed: boolean, GiftInventory: number, GiftRewardClaimedAmount: number, GiftsGiven: number, LeaderboardPoints: number } = {
    CurrentTier = 1,
    ClaimedRewards = 0,
    FinalRewardClaimed = false,
    GiftInventory = 0,
    GiftsGiven = 0,
    GiftRewardClaimedAmount = 0,
    LeaderboardPoints = 0,
}
local table_3_5 = {}
table_2_3.ClaimedRewards = table_3_5
table_1.ProfileData = table_2_3

return table_1
