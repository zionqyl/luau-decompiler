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
    Name = "Summer",
    Year = "2025",
    Title = "Summer2025",
    Currency = "BeachBalls2025",
    KeyName = "SummerKey2025",
    ShopCover = "rbxassetid://76437356338798",
    ShopButton = "rbxassetid://13932988534",
    FeaturedIcon = "rbxassetid://110525374723576",
    PrimaryColor = 0,
    MysteryBox = 0,
    BattlePass = 0,
    ShopItems = 0,
    Remotes = 0,
    CoinBagIcons = 0,
    Leaderboards = 0,
    Styles = 0,
    ItemPackItems = 0,
    DevProducts = 0,
    ProfileData = 0,
}
local from_rgb_result: Color3 = Color3.fromRGB(120, 220, 120)
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
    Points = {PauseStartTime = 0, PauseEndTime = 0, LeaderboardEndTime = 1754031600},
}
table_2.Leaderboards = table_3_2
local table_3_3: { BackgroundColor3: number | { UI_DarkBackground: Color3, UI_PrimaryButtonColor: Color3, UI_PrimaryButtonShadow: Color3 }, Image: number | { UI_Currency: string, UI_Key: string } } = {
    BackgroundColor3 = 0,
    Image = 0,
}
local table_4_2: { UI_DarkBackground: Color3, UI_PrimaryButtonColor: Color3, UI_PrimaryButtonShadow: Color3 } = {
    UI_PrimaryButtonColor = Color3.fromRGB(163, 136, 180),
    UI_PrimaryButtonShadow = Color3.fromRGB(61, 51, 68),
    UI_DarkBackground = Color3.fromRGB(48, 43, 56),
}
table_3_3.BackgroundColor3 = table_4_2
local table_4_3: { UI_Currency: string, UI_Key: string } = {
    UI_Currency = "rbxassetid://13932988534",
    UI_Key = "rbxassetid://134240302664368",
}
table_3_3.Image = table_4_3
table_2.Styles = table_3_3
local table_3_4: { Evo: { GamePassID: number, ItemID: string } } = {
    Evo = {ItemID = "Synthwave", GamePassID = 1326724250},
}
table_2.ItemPackItems = table_3_4
local table_3_5: { BeachBalls2025: number | { ["116000"]: number, ["14280"]: number, ["270000"]: number, ["3200"]: number, ["46800"]: number, ["6400"]: number, ["800"]: number } | { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } } = {
    BeachBalls2025 = 0,
}
local table_4_5: { ["116000"]: number?, ["14280"]: number?, ["270000"]: number?, ["3200"]: number?, ["46800"]: number?, ["6400"]: number?, ["800"]: number? } = {
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
    ["800"] = nil,
}
local value_5_6: number = 3337628474
table_4_5["800"] = value_5_6
local value_5_7: number = 3337628748
table_4_5["3200"] = value_5_7
local value_5_8: number = 3337629198
table_4_5["6400"] = value_5_8
local value_5_9: number = 3337630029
table_4_5["14280"] = value_5_9
local value_5_10: number = 3337630347
table_4_5["46800"] = value_5_10
local value_5_11: number = 3337630826
table_4_5["116000"] = value_5_11
local value_5_12: number = 3337631043
table_4_5["270000"] = value_5_12
table_3_5.BeachBalls2025 = table_4_5
table_2.DevProducts = table_3_5
local table_3_6: { ClaimedRewards: number | {  }, CurrentTier: number, FinalRewardClaimAmount: number, LeaderboardPoints: number } = {
    CurrentTier = 1,
    ClaimedRewards = 0,
    FinalRewardClaimAmount = 0,
    LeaderboardPoints = 0,
}
local table_4_6 = {}
table_3_6.ClaimedRewards = table_4_6
table_2.ProfileData = table_3_6

return table_2
