--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local script_value: LuaSourceContainer = script
local value_3: string = "RareEggs"
local rare_eggs_child: Instance? = script_value:WaitForChild(value_3)
local table_2 = {
    Name = "Easter",
    Year = "2025",
    Title = "Easter2025",
    Currency = "Eggs2025",
    RareCurrency = "RareEggs2025",
    ShopCover = "rbxassetid://111778291609370",
    ShopButton = "rbxassetid://93997606516273",
    PrimaryColor = 0,
    CoinBagIcons = 0,
    ItemPackItems = 0,
    RewardTracks = 0,
    Remotes = 0,
    CommonEggParts = 0,
    RareEggParts = 0,
    RareEggNames = 0,
    RareEggsList = 0,
    ProfileData = 0,
}
local from_rgb_result: Color3 = Color3.fromRGB(120, 220, 120)
table_2.PrimaryColor = from_rgb_result
local table_3: { EmptyBag: string, FullBag: string } = {
    EmptyBag = "rbxassetid://124750169912761",
    FullBag = "rbxassetid://118335122838129",
}
table_2.CoinBagIcons = table_3
local table_3_2: { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } = {
    Knife = {ItemID = "Bloom", GamePassID = 1165838634, DevProductID = 3268213875},
    Gun = {ItemID = "Flora", GamePassID = 1167438350, DevProductID = 3268214475},
    Bundle = {
        KnifeItemID = "Bloom",
        GunItemID = "Flora",
        EffectItemID = "Bloom2025",
        GamePassID = 1166580569,
        DevProductID = 3268216220,
    },
}
table_2.ItemPackItems = table_3_2
local table_3_3: { CommonEggs: number | { RequiredMaterial: string, Rewards: number | {{ Cost: number, ItemName: string, Type: string }} } | { RequiredMaterial: string, Rewards: {{ Cost: number, ItemName: string, Type: string }} }, RareEggs: number | { RequiredMaterial: string, Rewards: number | {{ Cost: number, ItemName: string, Type: string }} } | { RequiredMaterial: string, Rewards: {{ Cost: number, ItemName: string, Type: string }} } } = {
    CommonEggs = 0,
    RareEggs = 0,
}
local table_4_4: { RequiredMaterial: string, Rewards: number | {{ Cost: number, ItemName: string, Type: string }} } = {
    RequiredMaterial = "Eggs2025",
    Rewards = 0,
}
local table_5: {{ Cost: number, ItemName: string, Type: string }} = {
    {ItemName = "Carrots_K_2025", Cost = 200, Type = "Weapons"},
    {ItemName = "CommonEgg2025", Cost = 400, Type = "Toys"},
    {ItemName = "Decorated_K_2025", Cost = 800, Type = "Weapons"},
    {ItemName = "Sunny_G_2025", Cost = 2000, Type = "Weapons"},
    {ItemName = "Carrots2025", Cost = 3000, Type = "Effects"},
    {ItemName = "Bunnies_K_2025", Cost = 4000, Type = "Weapons"},
}
table_4_4.Rewards = table_5
table_3_3.CommonEggs = table_4_4
local table_4_5: { RequiredMaterial: string, Rewards: number | {{ Cost: number, ItemName: string, Type: string }} } = {
    RequiredMaterial = "RareEggs2025",
    Rewards = 0,
}
local table_5_2: {{ Cost: number, ItemName: string, Type: string }} = {
    {ItemName = "RareEgg2025", Cost = 2, Type = "Toys"},
    {ItemName = "Chick_K_2025", Cost = 4, Type = "Weapons"},
    {ItemName = "Meadow_G_2025", Cost = 6, Type = "Weapons"},
    {ItemName = "Butterflies_G_2025", Cost = 8, Type = "Weapons"},
    {ItemName = "Rainbows2025", Cost = 10, Type = "Effects"},
}
table_4_5.Rewards = table_5_2
table_3_3.RareEggs = table_4_5
table_2.RewardTracks = table_3_3
local script_value_2: LuaSourceContainer = script
local value_5_2: string = "Remotes"
local remotes_child: Instance? = script_value_2:WaitForChild(value_5_2)
table_2.Remotes = remotes_child
local script_value_3: LuaSourceContainer = script
local value_5_3: string = "CommonEggs"
local common_eggs_child: Instance? = script_value_3:WaitForChild(value_5_3)
table_2.CommonEggParts = common_eggs_child
table_2.RareEggParts = rare_eggs_child
local table_3_4: { ConstructionEgg2025: boolean, DiamondEgg2025: boolean, DoctorEgg2025: boolean, ExperimentEgg2025: boolean, MilitaryEgg2025: boolean, OfficeEgg2025: boolean, PoliceEgg2025: boolean, RobotEgg2025: boolean, ScientistEgg2025: boolean, SpeedyEgg2025: boolean } = {
    SpeedyEgg2025 = true,
    PoliceEgg2025 = true,
    DiamondEgg2025 = true,
    ConstructionEgg2025 = true,
    RobotEgg2025 = true,
    DoctorEgg2025 = true,
    ScientistEgg2025 = true,
    MilitaryEgg2025 = true,
    ExperimentEgg2025 = true,
    OfficeEgg2025 = true,
}
table_2.RareEggNames = table_3_4
local table_3_5 = {
    House2 = 0,
    Bank2 = 0,
    Factory = 0,
    ResearchFacility = 0,
    MilBase = 0,
    Office3 = 0,
    Workplace = 0,
    Hotel = 0,
    BioLab = 0,
    Mansion2 = 0,
    Hospital3 = 0,
    PoliceStation = 0,
}
local table_4_6 = {nil, nil}
local value_7: string = "SpeedyEgg2025"
local speedy_egg2025_child = rare_eggs_child:WaitForChild(value_7)
local value_8: string = "PoliceEgg2025"
table_4_6 = {speedy_egg2025_child, rare_eggs_child:WaitForChild(value_8)}
table_3_5.House2 = table_4_6
local table_4_7 = {nil, nil}
local value_7_3: string = "DiamondEgg2025"
local diamond_egg2025_child = rare_eggs_child:WaitForChild(value_7_3)
local value_8_2: string = "PoliceEgg2025"
table_4_7 = {diamond_egg2025_child, rare_eggs_child:WaitForChild(value_8_2)}
table_3_5.Bank2 = table_4_7
local table_4_8 = {nil, nil}
local value_7_5: string = "ConstructionEgg2025"
local construction_egg2025_child = rare_eggs_child:WaitForChild(value_7_5)
local value_8_3: string = "RobotEgg2025"
table_4_8 = {construction_egg2025_child, rare_eggs_child:WaitForChild(value_8_3)}
table_3_5.Factory = table_4_8
local table_4_9 = {nil, nil}
local value_7_7: string = "DoctorEgg2025"
local doctor_egg2025_child = rare_eggs_child:WaitForChild(value_7_7)
local value_8_4: string = "ScientistEgg2025"
table_4_9 = {doctor_egg2025_child, rare_eggs_child:WaitForChild(value_8_4)}
table_3_5.ResearchFacility = table_4_9
local table_4_10 = {nil, nil}
local value_7_9: string = "MilitaryEgg2025"
local military_egg2025_child = rare_eggs_child:WaitForChild(value_7_9)
local value_8_5: string = "ExperimentEgg2025"
table_4_10 = {military_egg2025_child, rare_eggs_child:WaitForChild(value_8_5)}
table_3_5.MilBase = table_4_10
local table_4_11 = {nil, nil}
local value_7_11: string = "OfficeEgg2025"
local office_egg2025_child = rare_eggs_child:WaitForChild(value_7_11)
local value_8_6: string = "SpeedyEgg2025"
table_4_11 = {office_egg2025_child, rare_eggs_child:WaitForChild(value_8_6)}
table_3_5.Office3 = table_4_11
local table_4_12 = {nil, nil}
local value_7_13: string = "OfficeEgg2025"
local office_egg2025_child_2 = rare_eggs_child:WaitForChild(value_7_13)
local value_8_7: string = "ConstructionEgg2025"
table_4_12 = {office_egg2025_child_2, rare_eggs_child:WaitForChild(value_8_7)}
table_3_5.Workplace = table_4_12
local table_4_13 = {nil, nil}
local value_7_15: string = "OfficeEgg2025"
local office_egg2025_child_3 = rare_eggs_child:WaitForChild(value_7_15)
local value_8_8: string = "DiamondEgg2025"
table_4_13 = {office_egg2025_child_3, rare_eggs_child:WaitForChild(value_8_8)}
table_3_5.Hotel = table_4_13
local table_4_14 = {nil, nil}
local value_7_17: string = "ExperimentEgg2025"
local experiment_egg2025_child = rare_eggs_child:WaitForChild(value_7_17)
local value_8_9: string = "ScientistEgg2025"
table_4_14 = {experiment_egg2025_child, rare_eggs_child:WaitForChild(value_8_9)}
table_3_5.BioLab = table_4_14
local table_4_15 = {nil, nil}
local value_7_19: string = "SpeedyEgg2025"
local speedy_egg2025_child_2 = rare_eggs_child:WaitForChild(value_7_19)
local value_8_10: string = "DiamondEgg2025"
table_4_15 = {speedy_egg2025_child_2, rare_eggs_child:WaitForChild(value_8_10)}
table_3_5.Mansion2 = table_4_15
local table_4_16 = {nil, nil}
local value_7_21: string = "DoctorEgg2025"
local doctor_egg2025_child_2 = rare_eggs_child:WaitForChild(value_7_21)
local value_8_11: string = "RobotEgg2025"
table_4_16 = {doctor_egg2025_child_2, rare_eggs_child:WaitForChild(value_8_11)}
table_3_5.Hospital3 = table_4_16
local table_4_17 = {nil, nil}
local value_7_23: string = "MilitaryEgg2025"
local military_egg2025_child_2 = rare_eggs_child:WaitForChild(value_7_23)
local value_8_12: string = "PoliceEgg2025"
table_4_17 = {military_egg2025_child_2, rare_eggs_child:WaitForChild(value_8_12)}
table_3_5.PoliceStation = table_4_17
table_2.RareEggsList = table_3_5
local table_3_6 = {Claimed = {}, RareEggs = {}}
table_2.ProfileData = table_3_6

return table_2
