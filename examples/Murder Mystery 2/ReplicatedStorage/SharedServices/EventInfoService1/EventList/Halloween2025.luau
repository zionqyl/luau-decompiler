--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value_2 = script.Parent.Parent
local value_4: string = "BattlePasses"
local battle_passes_child = parent_value_2:WaitForChild(value_4)
local table_2 = {
    Name = "Halloween",
    Year = "2025",
    Title = "Halloween2025",
    Currency = "Candies2025",
    KeyName = "HalloweenKey2025",
    ShopCover = "rbxassetid://90234103626349",
    ShopButton = "rbxassetid://112176937171925",
    FeaturedIcon = "rbxassetid://112176937171925",
    PrimaryColor = 0,
    MysteryBox = 0,
    BattlePass = 0,
    ShopItems = 0,
    Remotes = 0,
    LiveLaunchEvent = 1760810520,
    CoinBagIcons = 0,
    Leaderboards = 0,
    Styles = 0,
    Lighting = 0,
    ItemPackItems = 0,
    DevProducts = 0,
    ProfileData = 0,
    CurrentState = 0,
}
table_2["CurrentState"] = nil
local from_rgb_result: Color3 = Color3.fromRGB(93, 218, 86)
table_2.PrimaryColor = from_rgb_result
local require_value = require
local script_value_2: LuaSourceContainer = script
local value_6_2: string = "MysteryBox"
local require_result = require_value(script_value_2:WaitForChild(value_6_2))
table_2.MysteryBox = require_result
local require_value_2 = require
local script_value_3: LuaSourceContainer = script
local value_6_3: string = "BattlePass"
local require_result_2 = require_value_2(script_value_3:WaitForChild(value_6_3))
table_2.BattlePass = require_result_2
local require_value_3 = require
local script_value_4: LuaSourceContainer = script
local value_6_4: string = "ShopItems"
local require_result_3 = require_value_3(script_value_4:WaitForChild(value_6_4))
table_2.ShopItems = require_result_3
local script_value_5: LuaSourceContainer = script
local value_5_5: string = "Remotes"
local remotes_child: Instance? = script_value_5:WaitForChild(value_5_5)
table_2.Remotes = remotes_child
local table_3: { EmptyBag: string, FullBag: string } = {
    EmptyBag = "rbxassetid://18350588425",
    FullBag = "rbxassetid://18350589657",
}
table_2.CoinBagIcons = table_3
local table_3_2: { Points: { LeaderboardEndTime: number, PauseEndTime: number, PauseStartTime: number } } = {
    Points = {PauseStartTime = 0, PauseEndTime = 0, LeaderboardEndTime = 1761807600},
}
table_2.Leaderboards = table_3_2
local table_3_3: { BackgroundColor3: number | { UI_DarkBackground: Color3, UI_PrimaryButtonColor: Color3, UI_PrimaryButtonShadow: Color3 }, Image: number | { UI_Currency: string, UI_Key: string } } = {
    BackgroundColor3 = 0,
    Image = 0,
}
local table_4_2: { UI_DarkBackground: Color3, UI_PrimaryButtonColor: Color3, UI_PrimaryButtonShadow: Color3 } = {
    UI_PrimaryButtonColor = Color3.fromRGB(93, 218, 86),
    UI_PrimaryButtonShadow = Color3.fromRGB(43, 99, 39),
    UI_DarkBackground = Color3.fromRGB(10, 61, 15),
}
table_3_3.BackgroundColor3 = table_4_2
local table_4_3: { UI_Currency: string, UI_Key: string } = {
    UI_Currency = "rbxassetid://112176937171925",
    UI_Key = "rbxassetid://96672799519702",
}
table_3_3.Image = table_4_3
table_2.Styles = table_3_3
local table_3_4: { FogEnd: number, FogStart: number, Skybox: number?, TimeOfDay: number } = {
    FogEnd = 175,
    FogStart = 0,
    TimeOfDay = 0,
    Skybox = 0,
}
table_3_4["Skybox"] = nil
table_2.Lighting = table_3_4
local table_3_5: { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } = {
    Knife = {ItemID = "XenoKnife", GamePassID = 1534775989, DevProductID = 3432358695},
    Gun = {ItemID = "XenoGun", GamePassID = 1533049236, DevProductID = 3432358848},
    Bundle = {
        KnifeItemID = "XenoKnife",
        GunItemID = "XenoGun",
        EffectItemID = "XenoEffect",
        GamePassID = 1535587918,
        DevProductID = 3432360905,
    },
}
table_2.ItemPackItems = table_3_5
local table_3_6: { Candies2025: number | { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } | { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } } = {
    Candies2025 = 0,
}
local table_4_7: { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } = {
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
}
local value_5_6: number = 3432430351
table_4_7["800"] = value_5_6
local value_5_7: number = 3432430583
table_4_7["3200"] = value_5_7
local value_5_8: number = 3432431049
table_4_7["6400"] = value_5_8
local value_5_9: number = 3432431253
table_4_7["14280"] = value_5_9
local value_5_10: number = 3432431441
table_4_7["46800"] = value_5_10
local value_5_11: number = 3432431607
table_4_7["116000"] = value_5_11
local value_5_12: number = 3432431696
table_4_7["270000"] = value_5_12
table_3_6.Candies2025 = table_4_7
table_2.DevProducts = table_3_6
local table_3_7: { ClaimedRewards: number | {  }, CurrentTier: number, FinalRewardClaimAmount: number, LeaderboardPoints: number, LiveClaimed: boolean } = {
    CurrentTier = 1,
    ClaimedRewards = 0,
    FinalRewardClaimAmount = 0,
    LeaderboardPoints = 0,
    LiveClaimed = false,
}
local table_4_8 = {}
table_3_7.ClaimedRewards = table_4_8
table_2.ProfileData = table_3_7

return table_2
