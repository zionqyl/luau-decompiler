--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    AlienPlushie: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    BeachBall2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Bell2025: { Image: string, Name: string, Type: string }?,
    BooSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Broom26: { Image: string, Name: string, Type: string }?,
    Bubbles26: { Image: string, Name: string, Type: string }?,
    Bunny2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Candle2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Candle2025: { Image: string, Name: string, Type: string }?,
    CandyBucket2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    CandyToy: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    CandyToy2020: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    CandyToy2021: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    CandyToy2022: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Cauldron26: { Image: string, Name: string, Rarity: string, Type: string }?,
    ChocolateMilk: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    Coconut2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Coffee2025: { Image: string, Name: string, Type: string }?,
    CommonEgg2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    CommonEgg2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Cookie2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    EggToy2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    FakeBomb: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    Fireflies: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    Flamingo2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    GGSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Gravestone2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Heart2026: { Image: string, Name: string, Type: string }?,
    IceCream: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    IceCream2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Lantern2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    MagicBook2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Pie2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Pizza: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    Pumpkin2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Pumpkin2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Pumpkin26: { Image: string, Name: string, Rarity: string, Type: string }?,
    PumpkinBucket: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    RCCar26: { Image: string, Name: string, Type: string }?,
    RareEgg2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    RareEgg2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    ReaverSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    SandBucket2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Santa2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Santa2025: { Image: string, Name: string, Type: string }?,
    ScaryKey: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Skull26: { Image: string, Name: string, Type: string }?,
    SnowTokenToy: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    SnowballToy2020: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Snowglobe2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    Snowman2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    SprayPaint: nil | { Description: string, Gems: boolean, Image: string, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    TeamSurvivors: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    TeamZombies: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    Teddy: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? },
    TreeToy2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    VelvetCake2025: { Image: string, Name: string, Type: string }?,
    VolleyBall2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    WaterBalloon2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? },
    WitchsBrew26: { Image: string, Name: string, Rarity: string, Type: string }?,
    ZombieFriend: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? },
    ZombiePlush26: { Image: string, Name: string, Type: string }?,
}

local table_1: { AlienPlushie: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, BeachBall2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Bell2025: { Image: string, Name: string, Type: string }?, BooSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Broom26: { Image: string, Name: string, Type: string }?, Bubbles26: { Image: string, Name: string, Type: string }?, Bunny2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Candle2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Candle2025: { Image: string, Name: string, Type: string }?, CandyBucket2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, CandyToy: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, CandyToy2020: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, CandyToy2021: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, CandyToy2022: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Cauldron26: { Image: string, Name: string, Rarity: string, Type: string }?, ChocolateMilk: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, Coconut2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Coffee2025: { Image: string, Name: string, Type: string }?, CommonEgg2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, CommonEgg2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Cookie2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, EggToy2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, FakeBomb: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, Fireflies: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, Flamingo2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, GGSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Gravestone2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Heart2026: { Image: string, Name: string, Type: string }?, IceCream: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, IceCream2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Lantern2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, MagicBook2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Pie2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Pizza: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, Pumpkin2023: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Pumpkin2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Pumpkin26: { Image: string, Name: string, Rarity: string, Type: string }?, PumpkinBucket: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, RCCar26: { Image: string, Name: string, Type: string }?, RareEgg2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, RareEgg2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, ReaverSign: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, SandBucket2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Santa2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Santa2025: { Image: string, Name: string, Type: string }?, ScaryKey: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Skull26: { Image: string, Name: string, Type: string }?, SnowTokenToy: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, SnowballToy2020: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Snowglobe2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, Snowman2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, SprayPaint: nil | { Description: string, Gems: boolean, Image: string, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, Name: string?, Price: number?, Rarity: string?, Type: string? }, TeamSurvivors: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, TeamZombies: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, Teddy: nil | { Description: string, Image: string, ItemID: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? }, TreeToy2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, VelvetCake2025: { Image: string, Name: string, Type: string }?, VolleyBall2025: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, WaterBalloon2024: nil | { Description: string, Image: string, Name: string, Type: string } | { Description: string?, Image: string?, Name: string?, Type: string? }, WitchsBrew26: { Image: string, Name: string, Rarity: string, Type: string }?, ZombieFriend: nil | { Description: string, Image: string, ItemID: number, Name: string, Type: string } | { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? }, ZombiePlush26: { Image: string, Name: string, Type: string }? } = {
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
    [("Fireflies")] = nil,
}
do
    local table_2: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3: string = "Firefly Jar"
    table_2.Name = value_3
    local value_3_2: string = "Toy"
    table_2.Type = value_3_2
    local value_3_3: string = "Light up the room with a jar of fireflies."
    table_2.Description = value_3_3
    local value_3_4: string = "342145382"
    table_2.Image = value_3_4
    local value_3_5: number = 2474323527
    table_2.ItemID = value_3_5
    local value_3_6: number = 400
    table_2.Price = value_3_6
    table_1.Fireflies = table_2
    local table_2_2: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_7: string = "Chocolate Milk"
    table_2_2.Name = value_3_7
    local value_3_8: string = "Toy"
    table_2_2.Type = value_3_8
    local value_3_9: string = "Relax after a long day of unboxing crates with a cool glass of chocolate milk."
    table_2_2.Description = value_3_9
    local value_3_10: string = "342177661"
    table_2_2.Image = value_3_10
    local value_3_11: number = 342177661
    table_2_2.ItemID = value_3_11
    local value_3_12: number = 100
    table_2_2.Price = value_3_12
    table_1.ChocolateMilk = table_2_2
    local table_2_3: { Description: string?, Gems: boolean?, Image: string?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_13: string = "Spray Paint"
    table_2_3.Name = value_3_13
    local value_3_14: string = "Toy"
    table_2_3.Type = value_3_14
    local value_3_15: string = "Spray paint your favorite decals on the walls."
    table_2_3.Description = value_3_15
    local value_3_16: string = "342185593"
    table_2_3.Image = value_3_16
    local value_3_17: number = 750
    table_2_3.Price = value_3_17
    local value_3_18: string = "Rare"
    table_2_3.Rarity = value_3_18
    local value_3_19: boolean = true
    table_2_3.Gems = value_3_19
    table_1.SprayPaint = table_2_3
    local table_2_4: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_20: string = "Prank Bomb"
    table_2_4.Name = value_3_20
    local value_3_21: string = "Toy"
    table_2_4.Type = value_3_21
    local value_3_22: string = "Prank your friends with this confetti bomb!"
    table_2_4.Description = value_3_22
    local value_3_23: string = "342187115"
    table_2_4.Image = value_3_23
    local value_3_24: number = 2477932633
    table_2_4.ItemID = value_3_24
    local value_3_25: number = 1200
    table_2_4.Price = value_3_25
    table_1.FakeBomb = table_2_4
    local table_2_5: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_26: string = "Ice Cream"
    table_2_5.Name = value_3_26
    local value_3_27: string = "Toy"
    table_2_5.Type = value_3_27
    local value_3_28: string = "Yummy!"
    table_2_5.Description = value_3_28
    local value_3_29: string = "342188950"
    table_2_5.Image = value_3_29
    local value_3_30: number = 2474138899
    table_2_5.ItemID = value_3_30
    local value_3_31: number = 100
    table_2_5.Price = value_3_31
    table_1.IceCream = table_2_5
    local table_2_6: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_32: string = "Pizza"
    table_2_6.Name = value_3_32
    local value_3_33: string = "Toy"
    table_2_6.Type = value_3_33
    local value_3_34: string = "Pizza = delicious."
    table_2_6.Description = value_3_34
    local value_3_35: string = "342189892"
    table_2_6.Image = value_3_35
    local value_3_36: number = 342189892
    table_2_6.ItemID = value_3_36
    local value_3_37: number = 100
    table_2_6.Price = value_3_37
    table_1.Pizza = table_2_6
    local table_2_7: { Description: string?, Image: string?, ItemID: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_38: string = "Teddy Bear"
    table_2_7.Name = value_3_38
    local value_3_39: string = "Toy"
    table_2_7.Type = value_3_39
    local value_3_40: string = "He will always love you forever."
    table_2_7.Description = value_3_40
    local value_3_41: string = "345708612"
    table_2_7.Image = value_3_41
    local value_3_42: number = 345708612
    table_2_7.ItemID = value_3_42
    local value_3_43: number = 140
    table_2_7.Price = value_3_43
    table_1.Teddy = table_2_7
    local table_2_8: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_44: string = "Treat Bucket"
    table_2_8.Name = value_3_44
    local value_3_45: string = "Toy"
    table_2_8.Type = value_3_45
    local value_3_46: string = ""
    table_2_8.Description = value_3_46
    local value_3_47: string = "4212804497"
    table_2_8.Image = value_3_47
    local value_3_48: number = 4212804497
    table_2_8.ItemID = value_3_48
    table_1.PumpkinBucket = table_2_8
    local table_2_9: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_49: string = "Zombie Friend"
    table_2_9.Name = value_3_49
    local value_3_50: string = "Toy"
    table_2_9.Type = value_3_50
    local value_3_51: string = ""
    table_2_9.Description = value_3_51
    local value_3_52: string = "36784258"
    table_2_9.Image = value_3_52
    local value_3_53: number = 36784258
    table_2_9.ItemID = value_3_53
    table_1.ZombieFriend = table_2_9
    local table_2_10: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_54: string = "Toy Candy"
    table_2_10.Name = value_3_54
    local value_3_55: string = "Toy"
    table_2_10.Type = value_3_55
    local value_3_56: string = ""
    table_2_10.Description = value_3_56
    local value_3_57: string = "http://www.roblox.com/asset/?id=4212868318"
    table_2_10.Image = value_3_57
    local value_3_58: number = 4238848221
    table_2_10.ItemID = value_3_58
    table_1.CandyToy = table_2_10
end
do
    local table_2_11: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_59: string = "Toy Token"
    table_2_11.Name = value_3_59
    local value_3_60: string = "Toy"
    table_2_11.Type = value_3_60
    local value_3_61: string = ""
    table_2_11.Description = value_3_61
    local value_3_62: string = "http://www.roblox.com/asset/?id=4521691392"
    table_2_11.Image = value_3_62
    local value_3_63: number = 4535394532
    table_2_11.ItemID = value_3_63
    table_1.SnowTokenToy = table_2_11
    local table_2_12: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_64: string = "Toy Candy 2"
    table_2_12.Name = value_3_64
    local value_3_65: string = "Toy"
    table_2_12.Type = value_3_65
    local value_3_66: string = ""
    table_2_12.Description = value_3_66
    local value_3_67: string = "http://www.roblox.com/asset/?id=5872775283"
    table_2_12.Image = value_3_67
    local value_3_68: number = 5872766873
    table_2_12.ItemID = value_3_68
    table_1.CandyToy2020 = table_2_12
    local table_2_13: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_69: string = "Key Toy"
    table_2_13.Name = value_3_69
    local value_3_70: string = "Toy"
    table_2_13.Type = value_3_70
    local value_3_71: string = ""
    table_2_13.Description = value_3_71
    local value_3_72: string = "http://www.roblox.com/asset/?id=5924837972"
    table_2_13.Image = value_3_72
    local value_3_73: number = 5924837972
    table_2_13.ItemID = value_3_73
    table_1.ScaryKey = table_2_13
    local table_2_14: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_74: string = "GG Sign"
    table_2_14.Name = value_3_74
    local value_3_75: string = "Toy"
    table_2_14.Type = value_3_75
    local value_3_76: string = ""
    table_2_14.Description = value_3_76
    local value_3_77: string = "4806328826"
    table_2_14.Image = value_3_77
    local value_3_78: number = 4806328826
    table_2_14.ItemID = value_3_78
    table_1.GGSign = table_2_14
    local table_2_15: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_79: string = "BooSign"
    table_2_15.Name = value_3_79
    local value_3_80: string = "Toy"
    table_2_15.Type = value_3_80
    local value_3_81: string = ""
    table_2_15.Description = value_3_81
    local value_3_82: string = "7808228583"
    table_2_15.Image = value_3_82
    local value_3_83: number = 7808228583
    table_2_15.ItemID = value_3_83
    table_1.BooSign = table_2_15
    local table_2_16: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_84: string = "Reaver Sign"
    table_2_16.Name = value_3_84
    local value_3_85: string = "Toy"
    table_2_16.Type = value_3_85
    local value_3_86: string = ""
    table_2_16.Description = value_3_86
    local value_3_87: string = "7808229175"
    table_2_16.Image = value_3_87
    local value_3_88: number = 7808229175
    table_2_16.ItemID = value_3_88
    table_1.ReaverSign = table_2_16
    local table_2_17: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_89: string = "Snowball"
    table_2_17.Name = value_3_89
    local value_3_90: string = "Toy"
    table_2_17.Type = value_3_90
    local value_3_91: string = ""
    table_2_17.Description = value_3_91
    local value_3_92: string = "6123754554"
    table_2_17.Image = value_3_92
    local value_3_93: number = 6124068212
    table_2_17.ItemID = value_3_93
    table_1.SnowballToy2020 = table_2_17
    local table_2_18: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_94: string = "Candy"
    table_2_18.Name = value_3_94
    local value_3_95: string = "Toy"
    table_2_18.Type = value_3_95
    local value_3_96: string = ""
    table_2_18.Description = value_3_96
    local value_3_97: string = "7808227101"
    table_2_18.Image = value_3_97
    local value_3_98: number = 7808227101
    table_2_18.ItemID = value_3_98
    table_1.CandyToy2021 = table_2_18
    local table_2_19: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_99: string = "Survivor Sign"
    table_2_19.Name = value_3_99
    local value_3_100: string = "Toy"
    table_2_19.Type = value_3_100
    local value_3_101: string = ""
    table_2_19.Description = value_3_101
    local value_3_102: string = "11283752703"
    table_2_19.Image = value_3_102
    local value_3_103: number = 11283752703
    table_2_19.ItemID = value_3_103
    table_1.TeamSurvivors = table_2_19
    local table_2_20: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_104: string = "Zombie Sign"
    table_2_20.Name = value_3_104
    local value_3_105: string = "Toy"
    table_2_20.Type = value_3_105
    local value_3_106: string = ""
    table_2_20.Description = value_3_106
    local value_3_107: string = "11283762381"
    table_2_20.Image = value_3_107
    local value_3_108: number = 11283762381
    table_2_20.ItemID = value_3_108
    table_1.TeamZombies = table_2_20
    local table_2_21: { Description: string?, Image: string?, ItemID: number?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_109: string = "Candy Emote"
    table_2_21.Name = value_3_109
    local value_3_110: string = "Toy"
    table_2_21.Type = value_3_110
    local value_3_111: string = ""
    table_2_21.Description = value_3_111
    local value_3_112: string = "http://www.roblox.com/asset/?id=11137521765"
    table_2_21.Image = value_3_112
    local value_3_113: number = 11283836868
    table_2_21.ItemID = value_3_113
    table_1.CandyToy2022 = table_2_21
end
do
    local table_2_22: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_114: string = "Egg Toy"
    table_2_22.Name = value_3_114
    local value_3_115: string = "Toy"
    table_2_22.Type = value_3_115
    local value_3_116: string = ""
    table_2_22.Description = value_3_116
    local value_3_117: string = "http://www.roblox.com/asset/?id=12966771924"
    table_2_22.Image = value_3_117
    table_1.EggToy2023 = table_2_22
    local table_2_23: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_118: string = "Beach Ball"
    table_2_23.Name = value_3_118
    local value_3_119: string = "Toy"
    table_2_23.Type = value_3_119
    local value_3_120: string = ""
    table_2_23.Description = value_3_120
    local value_3_121: string = "rbxassetid://13932988534"
    table_2_23.Image = value_3_121
    table_1.BeachBall2023 = table_2_23
    local table_2_24: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_122: string = "Pumpkin Toy"
    table_2_24.Name = value_3_122
    local value_3_123: string = "Toy"
    table_2_24.Type = value_3_123
    local value_3_124: string = ""
    table_2_24.Description = value_3_124
    local value_3_125: string = "rbxassetid://15092282349"
    table_2_24.Image = value_3_125
    table_1.Pumpkin2023 = table_2_24
    local table_2_25: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_126: string = "Pie"
    table_2_25.Name = value_3_126
    local value_3_127: string = "Toy"
    table_2_25.Type = value_3_127
    local value_3_128: string = ""
    table_2_25.Description = value_3_128
    local value_3_129: string = "rbxassetid://15415343872"
    table_2_25.Image = value_3_129
    table_1.Pie2023 = table_2_25
    local table_2_26: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_130: string = "Cookie"
    table_2_26.Name = value_3_130
    local value_3_131: string = "Toy"
    table_2_26.Type = value_3_131
    local value_3_132: string = ""
    table_2_26.Description = value_3_132
    local value_3_133: string = "rbxassetid://15653924406"
    table_2_26.Image = value_3_133
    table_1.Cookie2023 = table_2_26
    local table_2_27: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_134: string = "Bunny Toy"
    table_2_27.Name = value_3_134
    local value_3_135: string = "Toy"
    table_2_27.Type = value_3_135
    local value_3_136: string = ""
    table_2_27.Description = value_3_136
    local value_3_137: string = "rbxassetid://16960933548"
    table_2_27.Image = value_3_137
    table_1.Bunny2024 = table_2_27
    local table_2_28: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_138: string = "Egg Toy '24"
    table_2_28.Name = value_3_138
    local value_3_139: string = "Toy"
    table_2_28.Type = value_3_139
    local value_3_140: string = ""
    table_2_28.Description = value_3_140
    local value_3_141: string = "rbxassetid://16959887230"
    table_2_28.Image = value_3_141
    table_1.CommonEgg2024 = table_2_28
    local table_2_29: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_142: string = "Rare Egg Toy '24"
    table_2_29.Name = value_3_142
    local value_3_143: string = "Toy"
    table_2_29.Type = value_3_143
    local value_3_144: string = ""
    table_2_29.Description = value_3_144
    local value_3_145: string = "rbxassetid://16959891184"
    table_2_29.Image = value_3_145
    table_1.RareEgg2024 = table_2_29
    local table_2_30: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_146: string = "Egg Toy '25"
    table_2_30.Name = value_3_146
    local value_3_147: string = "Toy"
    table_2_30.Type = value_3_147
    local value_3_148: string = ""
    table_2_30.Description = value_3_148
    local value_3_149: string = "rbxassetid://107464481035057"
    table_2_30.Image = value_3_149
    table_1.CommonEgg2025 = table_2_30
    local table_2_31: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_150: string = "Rare Egg Toy '25"
    table_2_31.Name = value_3_150
    local value_3_151: string = "Toy"
    table_2_31.Type = value_3_151
    local value_3_152: string = ""
    table_2_31.Description = value_3_152
    local value_3_153: string = "rbxassetid://111683562237797"
    table_2_31.Image = value_3_153
    table_1.RareEgg2025 = table_2_31
    local table_2_32: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_154: string = "Coconut"
    table_2_32.Name = value_3_154
    local value_3_155: string = "Toy"
    table_2_32.Type = value_3_155
    local value_3_156: string = ""
    table_2_32.Description = value_3_156
    local value_3_157: string = "rbxassetid://18335937971"
    table_2_32.Image = value_3_157
    table_1.Coconut2024 = table_2_32
    local table_2_33: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_158: string = "Sand Bucket"
    table_2_33.Name = value_3_158
    local value_3_159: string = "Toy"
    table_2_33.Type = value_3_159
    local value_3_160: string = ""
    table_2_33.Description = value_3_160
    local value_3_161: string = "rbxassetid://18335937779"
    table_2_33.Image = value_3_161
    table_1.SandBucket2024 = table_2_33
    local table_2_34: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_162: string = "Water Balloon"
    table_2_34.Name = value_3_162
    local value_3_163: string = "Toy"
    table_2_34.Type = value_3_163
    local value_3_164: string = ""
    table_2_34.Description = value_3_164
    local value_3_165: string = "rbxassetid://18335937543"
    table_2_34.Image = value_3_165
    table_1.WaterBalloon2024 = table_2_34
end
do
    local table_2_35: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_166: string = "Gravestone"
    table_2_35.Name = value_3_166
    local value_3_167: string = "Toy"
    table_2_35.Type = value_3_167
    local value_3_168: string = ""
    table_2_35.Description = value_3_168
    local value_3_169: string = "rbxassetid://94986187104463"
    table_2_35.Image = value_3_169
    table_1.Gravestone2024 = table_2_35
    local table_2_36: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_170: string = "Spellbook"
    table_2_36.Name = value_3_170
    local value_3_171: string = "Toy"
    table_2_36.Type = value_3_171
    local value_3_172: string = ""
    table_2_36.Description = value_3_172
    local value_3_173: string = "rbxassetid://127461882663273"
    table_2_36.Image = value_3_173
    table_1.MagicBook2024 = table_2_36
    local table_2_37: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_174: string = "Candle"
    table_2_37.Name = value_3_174
    local value_3_175: string = "Toy"
    table_2_37.Type = value_3_175
    local value_3_176: string = ""
    table_2_37.Description = value_3_176
    local value_3_177: string = "120527509122737"
    table_2_37.Image = value_3_177
    table_1.Candle2024 = table_2_37
    local table_2_38: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_178: string = "Villager's Lantern"
    table_2_38.Name = value_3_178
    local value_3_179: string = "Toy"
    table_2_38.Type = value_3_179
    local value_3_180: string = ""
    table_2_38.Description = value_3_180
    local value_3_181: string = "97762906196843"
    table_2_38.Image = value_3_181
    table_1.Lantern2024 = table_2_38
    local table_2_39: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_182: string = "Santa"
    table_2_39.Name = value_3_182
    local value_3_183: string = "Toy"
    table_2_39.Type = value_3_183
    local value_3_184: string = ""
    table_2_39.Description = value_3_184
    local value_3_185: string = "112947511371641"
    table_2_39.Image = value_3_185
    table_1.Santa2024 = table_2_39
    local table_2_40: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_186: string = "Tree"
    table_2_40.Name = value_3_186
    local value_3_187: string = "Toy"
    table_2_40.Type = value_3_187
    local value_3_188: string = ""
    table_2_40.Description = value_3_188
    local value_3_189: string = "74235287046602"
    table_2_40.Image = value_3_189
    table_1.TreeToy2024 = table_2_40
    local table_2_41: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_190: string = "Snowman"
    table_2_41.Name = value_3_190
    local value_3_191: string = "Toy"
    table_2_41.Type = value_3_191
    local value_3_192: string = ""
    table_2_41.Description = value_3_192
    local value_3_193: string = "120518460229991"
    table_2_41.Image = value_3_193
    table_1.Snowman2024 = table_2_41
    local table_2_42: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_194: string = "Snowglobe"
    table_2_42.Name = value_3_194
    local value_3_195: string = "Toy"
    table_2_42.Type = value_3_195
    local value_3_196: string = ""
    table_2_42.Description = value_3_196
    local value_3_197: string = "124332844075984"
    table_2_42.Image = value_3_197
    table_1.Snowglobe2024 = table_2_42
    local table_2_43: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_198: string = "Volleyball"
    table_2_43.Name = value_3_198
    local value_3_199: string = "Toy"
    table_2_43.Type = value_3_199
    local value_3_200: string = ""
    table_2_43.Description = value_3_200
    local value_3_201: string = "138701813251984"
    table_2_43.Image = value_3_201
    table_1.VolleyBall2025 = table_2_43
    local table_2_44: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_202: string = "Ice Cream"
    table_2_44.Name = value_3_202
    local value_3_203: string = "Toy"
    table_2_44.Type = value_3_203
    local value_3_204: string = ""
    table_2_44.Description = value_3_204
    local value_3_205: string = "120676916451742"
    table_2_44.Image = value_3_205
    table_1.IceCream2025 = table_2_44
    local table_2_45: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_206: string = "Flamingo"
    table_2_45.Name = value_3_206
    local value_3_207: string = "Toy"
    table_2_45.Type = value_3_207
    local value_3_208: string = ""
    table_2_45.Description = value_3_208
    local value_3_209: string = "95337986608857"
    table_2_45.Image = value_3_209
    table_1.Flamingo2025 = table_2_45
    local table_2_46: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_210: string = "Alien Plush"
    table_2_46.Name = value_3_210
    local value_3_211: string = "Toy"
    table_2_46.Type = value_3_211
    local value_3_212: string = ""
    table_2_46.Description = value_3_212
    local value_3_213: string = "71841712321048"
    table_2_46.Image = value_3_213
    table_1.AlienPlushie = table_2_46
    local table_2_47: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_214: string = "Candy Bucket"
    table_2_47.Name = value_3_214
    local value_3_215: string = "Toy"
    table_2_47.Type = value_3_215
    local value_3_216: string = ""
    table_2_47.Description = value_3_216
    local value_3_217: string = "78256987492296"
    table_2_47.Image = value_3_217
    table_1.CandyBucket2025 = table_2_47
end
do
    local table_2_48: { Description: string?, Image: string?, Name: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_218: string = "Pumpkin"
    table_2_48.Name = value_3_218
    local value_3_219: string = "Toy"
    table_2_48.Type = value_3_219
    local value_3_220: string = ""
    table_2_48.Description = value_3_220
    local value_3_221: string = "105847499123104"
    table_2_48.Image = value_3_221
    table_1.Pumpkin2025 = table_2_48
    local table_2_49: { Image: string, Name: string, Type: string } = {
        Name = "Latte",
        Type = "Toy",
        Image = "80447498175863",
    }
    table_1.Coffee2025 = table_2_49
    local table_2_50: { Image: string, Name: string, Type: string } = {
        Name = "Santa Plushie",
        Type = "Toy",
        Image = "80174351218254",
    }
    table_1.Santa2025 = table_2_50
    local table_2_51: { Image: string, Name: string, Type: string } = {
        Name = "Candle",
        Type = "Toy",
        Image = "96198788268210",
    }
    table_1.Candle2025 = table_2_51
    local table_2_52: { Image: string, Name: string, Type: string } = {
        Name = "Bell",
        Type = "Toy",
        Image = "101006957746013",
    }
    table_1.Bell2025 = table_2_52
    local table_2_53: { Image: string, Name: string, Type: string } = {
        Name = "Velvet Cake",
        Type = "Toy",
        Image = "134026228181985",
    }
    table_1.VelvetCake2025 = table_2_53
    local table_2_54: { Image: string, Name: string, Type: string } = {
        Name = "Heart",
        Type = "Toy",
        Image = "131241967066086",
    }
    table_1.Heart2026 = table_2_54
    local table_2_55: { Image: string, Name: string, Type: string } = {
        Name = "RC Car",
        Type = "Toy",
        Image = "97596245727419",
    }
    table_1.RCCar26 = table_2_55
    local table_2_56: { Image: string, Name: string, Type: string } = {
        Name = "Bubble Blower",
        Type = "Toy",
        Image = "73572795844904",
    }
    table_1.Bubbles26 = table_2_56
    local table_2_57: { Image: string, Name: string, Type: string } = {
        Name = "Broom",
        Type = "Toy",
        Image = "106281722914189",
    }
    table_1.Broom26 = table_2_57
    local table_2_58: { Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Witches Brew",
        Type = "Toy",
        Rarity = "Uncommon",
        Image = "105854510755059",
    }
    table_1.WitchsBrew26 = table_2_58
    local table_2_59: { Image: string, Name: string, Type: string } = {
        Name = "Zombie Plush",
        Type = "Toy",
        Image = "131234371554801",
    }
    table_1.ZombiePlush26 = table_2_59
    local table_2_60: { Image: string, Name: string, Type: string } = {
        Name = "Skull",
        Type = "Toy",
        Image = "89138711443617",
    }
    table_1.Skull26 = table_2_60
    local table_2_61: { Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Pumpkin",
        Type = "Toy",
        Rarity = "Common",
        Image = "71540568939613",
    }
    table_1.Pumpkin26 = table_2_61
    local table_2_62: { Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Cauldron",
        Type = "Toy",
        Rarity = "Rare",
        Image = "80658870713560",
    }
    table_1.Cauldron26 = table_2_62
end

return table_1
