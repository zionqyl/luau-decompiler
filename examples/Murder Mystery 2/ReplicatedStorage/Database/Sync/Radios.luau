--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    BlueCandyCane2018: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    BlueCane: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    BlueSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    BluesteelRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Boombastic: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    CamoRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    CandyCane2018: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    CandyCaneRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    CandyRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    ChristmasRadio2019: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    ChristmasRadio2020: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    ChristmasRadio2021: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Coal: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Default: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    DiamondRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Dubstep: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    ElderwoodRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Elite: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    FadeRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Flaming: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    GhostRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    GingerbreadRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Gold: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    GreenCane: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    GreenSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Hallowradio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Ice: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    JackRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Omega: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    OverseerRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    PinkSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    RainbowRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    ReaverRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    RedSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    RetroRadio2025: nil | { Image: string, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    SnowRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    Tree: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
    VampireRadio2024: nil | { Image: string, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? },
}

local table_1: { BlueCandyCane2018: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, BlueCane: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, BlueSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, BluesteelRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Boombastic: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, CamoRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, CandyCane2018: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, CandyCaneRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, CandyRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, ChristmasRadio2019: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, ChristmasRadio2020: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, ChristmasRadio2021: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Coal: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Default: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, DiamondRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Dubstep: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, ElderwoodRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Elite: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, FadeRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Flaming: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, GhostRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, GingerbreadRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Gold: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, GreenCane: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, GreenSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Hallowradio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Ice: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, JackRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Omega: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, OverseerRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, PinkSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, RainbowRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, ReaverRadio: nil | { Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, RedSparkleRadio: nil | { Gems: boolean, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: number, Rarity: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, RetroRadio2025: nil | { Image: string, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, SnowRadio: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, Tree: nil | { ChristmasDescription: string, Image: string, ItemID: number, Name: string, Offset: { X: number, Y: number, Z: number }, Price: string, Rotation: { X: number, Y: number, Z: number }, Type: string } | { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? }, VampireRadio2024: nil | { Image: string, Name: string, Offset: { X: number, Y: number, Z: number }, Rotation: { X: number, Y: number, Z: number }, Type: string } | { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } } = {
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
    [("Default")] = nil,
}
do
    local table_2: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3: string = "Regular"
    table_2.Name = value_3
    local value_3_2: string = "Radio Skin"
    table_2.Type = value_3_2
    local value_3_3: string = "336413959"
    table_2.Image = value_3_3
    local table_3: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2.Offset = table_3
    local table_3_2: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2.Rotation = table_3_2
    local value_3_4: number = 336413959
    table_2.ItemID = value_3_4
    table_1.Default = table_2
    local table_2_2: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_5: string = "Dubstep"
    table_2_2.Name = value_3_5
    local value_3_6: string = "Radio Skin"
    table_2_2.Type = value_3_6
    local value_3_7: string = "340586338"
    table_2_2.Image = value_3_7
    local table_3_3: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0.1, Z = 1}
    table_2_2.Offset = table_3_3
    local table_3_4: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.6981317007977318,
    }
    table_2_2.Rotation = table_3_4
    local value_3_8: number = 340586338
    table_2_2.ItemID = value_3_8
    local value_3_9: number = 300
    table_2_2.Price = value_3_9
    table_1.Dubstep = table_2_2
    local table_2_3: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_10: string = "Elite"
    table_2_3.Name = value_3_10
    local value_3_11: string = "Radio Skin"
    table_2_3.Type = value_3_11
    local value_3_12: string = "340601210"
    table_2_3.Image = value_3_12
    local table_3_5: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0.1, Z = 1}
    table_2_3.Offset = table_3_5
    local table_3_6: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.6981317007977318,
    }
    table_2_3.Rotation = table_3_6
    local value_3_13: number = 340601210
    table_2_3.ItemID = value_3_13
    local value_3_14: string = "Elite"
    table_2_3.Price = value_3_14
    table_1.Elite = table_2_3
    local table_2_4: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_15: string = "Golden"
    table_2_4.Name = value_3_15
    local value_3_16: string = "Radio Skin"
    table_2_4.Type = value_3_16
    local value_3_17: string = "336413900"
    table_2_4.Image = value_3_17
    local table_3_7: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_4.Offset = table_3_7
    local table_3_8: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_4.Rotation = table_3_8
    local value_3_18: number = 336413900
    table_2_4.ItemID = value_3_18
    local value_3_19: number = 3000
    table_2_4.Price = value_3_19
    table_1.Gold = table_2_4
    local table_2_5: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_20: string = "Bluesteel"
    table_2_5.Name = value_3_20
    local value_3_21: string = "Radio Skin"
    table_2_5.Type = value_3_21
    local value_3_22: string = "426038132"
    table_2_5.Image = value_3_22
    local table_3_9: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_5.Offset = table_3_9
    local table_3_10: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_5.Rotation = table_3_10
    local value_3_23: number = 426038132
    table_2_5.ItemID = value_3_23
    local value_3_24: number = 780
    table_2_5.Price = value_3_24
    table_1.BluesteelRadio = table_2_5
    local table_2_6: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_25: string = "Camo"
    table_2_6.Name = value_3_25
    local value_3_26: string = "Radio Skin"
    table_2_6.Type = value_3_26
    local value_3_27: string = "426037948"
    table_2_6.Image = value_3_27
    local table_3_11: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_6.Offset = table_3_11
    local table_3_12: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_6.Rotation = table_3_12
    local value_3_28: number = 426037948
    table_2_6.ItemID = value_3_28
    local value_3_29: number = 500
    table_2_6.Price = value_3_29
    table_1.CamoRadio = table_2_6
    local table_2_7: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_30: string = "Boombastic"
    table_2_7.Name = value_3_30
    local value_3_31: string = "Radio Skin"
    table_2_7.Type = value_3_31
    local value_3_32: string = "426037145"
    table_2_7.Image = value_3_32
    local table_3_13: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_7.Offset = table_3_13
    local table_3_14: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_7.Rotation = table_3_14
    local value_3_33: number = 426037145
    table_2_7.ItemID = value_3_33
    local value_3_34: number = 900
    table_2_7.Price = value_3_34
    table_1.Boombastic = table_2_7
    local table_2_8: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_35: string = "Omega"
    table_2_8.Name = value_3_35
    local value_3_36: string = "Radio Skin"
    table_2_8.Type = value_3_36
    local value_3_37: string = "426037069"
    table_2_8.Image = value_3_37
    local table_3_15: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_8.Offset = table_3_15
    local table_3_16: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_8.Rotation = table_3_16
    local value_3_38: number = 426037069
    table_2_8.ItemID = value_3_38
    local value_3_39: boolean = true
    table_2_8.Gems = value_3_39
    local value_3_40: number = 400
    table_2_8.Price = value_3_40
    local value_3_41: string = "Uncommon"
    table_2_8.Rarity = value_3_41
    table_1.Omega = table_2_8
end
do
    local table_2_9: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_42: string = "Rainbow"
    table_2_9.Name = value_3_42
    local value_3_43: string = "Radio Skin"
    table_2_9.Type = value_3_43
    local value_3_44: string = "426036850"
    table_2_9.Image = value_3_44
    local table_3_17: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_9.Offset = table_3_17
    local table_3_18: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_9.Rotation = table_3_18
    local value_3_45: number = 426036850
    table_2_9.ItemID = value_3_45
    local value_3_46: boolean = true
    table_2_9.Gems = value_3_46
    local value_3_47: number = 800
    table_2_9.Price = value_3_47
    local value_3_48: string = "Rare"
    table_2_9.Rarity = value_3_48
    table_1.RainbowRadio = table_2_9
    local table_2_10: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_49: string = "Overseer"
    table_2_10.Name = value_3_49
    local value_3_50: string = "Radio Skin"
    table_2_10.Type = value_3_50
    local value_3_51: string = "426036356"
    table_2_10.Image = value_3_51
    local table_3_19: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_10.Offset = table_3_19
    local table_3_20: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_10.Rotation = table_3_20
    local value_3_52: number = 426036356
    table_2_10.ItemID = value_3_52
    local value_3_53: boolean = true
    table_2_10.Gems = value_3_53
    local value_3_54: number = 300
    table_2_10.Price = value_3_54
    local value_3_55: string = "Uncommon"
    table_2_10.Rarity = value_3_55
    table_1.OverseerRadio = table_2_10
    local table_2_11: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_56: string = "Fade"
    table_2_11.Name = value_3_56
    local value_3_57: string = "Radio Skin"
    table_2_11.Type = value_3_57
    local value_3_58: string = "426035979"
    table_2_11.Image = value_3_58
    local table_3_21: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_11.Offset = table_3_21
    local table_3_22: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_11.Rotation = table_3_22
    local value_3_59: number = 426035979
    table_2_11.ItemID = value_3_59
    local value_3_60: boolean = true
    table_2_11.Gems = value_3_60
    local value_3_61: number = 400
    table_2_11.Price = value_3_61
    local value_3_62: string = "Uncommon"
    table_2_11.Rarity = value_3_62
    table_1.FadeRadio = table_2_11
    local table_2_12: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_63: string = "Flaming"
    table_2_12.Name = value_3_63
    local value_3_64: string = "Radio Skin"
    table_2_12.Type = value_3_64
    local value_3_65: string = "426034894"
    table_2_12.Image = value_3_65
    local table_3_23: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_12.Offset = table_3_23
    local table_3_24: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_12.Rotation = table_3_24
    local value_3_66: number = 426034894
    table_2_12.ItemID = value_3_66
    local value_3_67: boolean = true
    table_2_12.Gems = value_3_67
    local value_3_68: number = 900
    table_2_12.Price = value_3_68
    local value_3_69: string = "Rare"
    table_2_12.Rarity = value_3_69
    table_1.Flaming = table_2_12
    local table_2_13: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_70: string = "Green Sparkle Time"
    table_2_13.Name = value_3_70
    local value_3_71: string = "Radio Skin"
    table_2_13.Type = value_3_71
    local value_3_72: string = "426036954"
    table_2_13.Image = value_3_72
    local table_3_25: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_13.Offset = table_3_25
    local table_3_26: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_13.Rotation = table_3_26
    local value_3_73: number = 426036954
    table_2_13.ItemID = value_3_73
    local value_3_74: boolean = true
    table_2_13.Gems = value_3_74
    local value_3_75: number = 1000
    table_2_13.Price = value_3_75
    local value_3_76: string = "Legendary"
    table_2_13.Rarity = value_3_76
    table_1.GreenSparkleRadio = table_2_13
    local table_2_14: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_77: string = "Pink Sparkle Time"
    table_2_14.Name = value_3_77
    local value_3_78: string = "Radio Skin"
    table_2_14.Type = value_3_78
    local value_3_79: string = "426036727"
    table_2_14.Image = value_3_79
    local table_3_27: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_14.Offset = table_3_27
    local table_3_28: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_14.Rotation = table_3_28
    local value_3_80: number = 426036727
    table_2_14.ItemID = value_3_80
    local value_3_81: boolean = true
    table_2_14.Gems = value_3_81
    local value_3_82: number = 1000
    table_2_14.Price = value_3_82
    local value_3_83: string = "Legendary"
    table_2_14.Rarity = value_3_83
    table_1.PinkSparkleRadio = table_2_14
    local table_2_15: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_84: string = "Blue Sparkle Time"
    table_2_15.Name = value_3_84
    local value_3_85: string = "Radio Skin"
    table_2_15.Type = value_3_85
    local value_3_86: string = "426035785"
    table_2_15.Image = value_3_86
    local table_3_29: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_15.Offset = table_3_29
    local table_3_30: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_15.Rotation = table_3_30
    local value_3_87: number = 426035785
    table_2_15.ItemID = value_3_87
    local value_3_88: boolean = true
    table_2_15.Gems = value_3_88
    local value_3_89: number = 1000
    table_2_15.Price = value_3_89
    local value_3_90: string = "Legendary"
    table_2_15.Rarity = value_3_90
    table_1.BlueSparkleRadio = table_2_15
end
do
    local table_2_16: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_91: string = "Red Sparkletime"
    table_2_16.Name = value_3_91
    local value_3_92: string = "Radio Skin"
    table_2_16.Type = value_3_92
    local value_3_93: string = "426034746"
    table_2_16.Image = value_3_93
    local table_3_31: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_16.Offset = table_3_31
    local table_3_32: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_16.Rotation = table_3_32
    local value_3_94: number = 426034746
    table_2_16.ItemID = value_3_94
    local value_3_95: boolean = true
    table_2_16.Gems = value_3_95
    local value_3_96: number = 1000
    table_2_16.Price = value_3_96
    local value_3_97: string = "Legendary"
    table_2_16.Rarity = value_3_97
    table_1.RedSparkleRadio = table_2_16
    local table_2_17: { Gems: boolean?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: number?, Rarity: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_98: string = "Diamond"
    table_2_17.Name = value_3_98
    local value_3_99: string = "Radio Skin"
    table_2_17.Type = value_3_99
    local value_3_100: string = "426036523"
    table_2_17.Image = value_3_100
    local table_3_33: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_17.Offset = table_3_33
    local table_3_34: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_17.Rotation = table_3_34
    local value_3_101: number = 426036523
    table_2_17.ItemID = value_3_101
    local value_3_102: boolean = true
    table_2_17.Gems = value_3_102
    local value_3_103: number = 2500
    table_2_17.Price = value_3_103
    local value_3_104: string = "Legendary"
    table_2_17.Rarity = value_3_104
    table_1.DiamondRadio = table_2_17
    local table_2_18: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_105: string = "Candy Cane"
    table_2_18.Name = value_3_105
    local value_3_106: string = "Radio Skin"
    table_2_18.Type = value_3_106
    local value_3_107: string = "585671667"
    table_2_18.Image = value_3_107
    local table_3_35: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_18.Offset = table_3_35
    local table_3_36: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_18.Rotation = table_3_36
    local value_3_108: number = 585671667
    table_2_18.ItemID = value_3_108
    local value_3_109: string = "NotForSale"
    table_2_18.Price = value_3_109
    local value_3_110: string = "Radio"
    table_2_18.ChristmasDescription = value_3_110
    table_1.CandyCaneRadio = table_2_18
    local table_2_19: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_111: string = "Gingerbread"
    table_2_19.Name = value_3_111
    local value_3_112: string = "Radio Skin"
    table_2_19.Type = value_3_112
    local value_3_113: string = "585672136"
    table_2_19.Image = value_3_113
    local table_3_37: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_19.Offset = table_3_37
    local table_3_38: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_19.Rotation = table_3_38
    local value_3_114: number = 585672136
    table_2_19.ItemID = value_3_114
    local value_3_115: string = "NotForSale"
    table_2_19.Price = value_3_115
    local value_3_116: string = "Radio"
    table_2_19.ChristmasDescription = value_3_116
    table_1.GingerbreadRadio = table_2_19
    local table_2_20: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_117: string = "Snowy"
    table_2_20.Name = value_3_117
    local value_3_118: string = "Radio Skin"
    table_2_20.Type = value_3_118
    local value_3_119: string = "585672503"
    table_2_20.Image = value_3_119
    local table_3_39: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_20.Offset = table_3_39
    local table_3_40: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_20.Rotation = table_3_40
    local value_3_120: number = 585672503
    table_2_20.ItemID = value_3_120
    local value_3_121: string = "NotForSale"
    table_2_20.Price = value_3_121
    local value_3_122: string = "Radio"
    table_2_20.ChristmasDescription = value_3_122
    table_1.SnowRadio = table_2_20
    local table_2_21: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_123: string = "Green Candy Cane"
    table_2_21.Name = value_3_123
    local value_3_124: string = "Radio Skin"
    table_2_21.Type = value_3_124
    local value_3_125: string = "1269026737"
    table_2_21.Image = value_3_125
    local table_3_41: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_21.Offset = table_3_41
    local table_3_42: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_21.Rotation = table_3_42
    local value_3_126: number = 1269026737
    table_2_21.ItemID = value_3_126
    local value_3_127: string = "NotForSale"
    table_2_21.Price = value_3_127
    local value_3_128: string = "Radio"
    table_2_21.ChristmasDescription = value_3_128
    table_1.GreenCane = table_2_21
    local table_2_22: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_129: string = "Blue Candy Cane"
    table_2_22.Name = value_3_129
    local value_3_130: string = "Radio Skin"
    table_2_22.Type = value_3_130
    local value_3_131: string = "1269026952"
    table_2_22.Image = value_3_131
    local table_3_43: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_22.Offset = table_3_43
    local table_3_44: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_22.Rotation = table_3_44
    local value_3_132: number = 1269026952
    table_2_22.ItemID = value_3_132
    local value_3_133: string = "NotForSale"
    table_2_22.Price = value_3_133
    local value_3_134: string = "Radio"
    table_2_22.ChristmasDescription = value_3_134
    table_1.BlueCane = table_2_22
end
do
    local table_2_23: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_135: string = "Ice"
    table_2_23.Name = value_3_135
    local value_3_136: string = "Radio Skin"
    table_2_23.Type = value_3_136
    local value_3_137: string = "1269027626"
    table_2_23.Image = value_3_137
    local table_3_45: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_23.Offset = table_3_45
    local table_3_46: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_23.Rotation = table_3_46
    local value_3_138: number = 1269027626
    table_2_23.ItemID = value_3_138
    local value_3_139: string = "NotForSale"
    table_2_23.Price = value_3_139
    local value_3_140: string = "Radio"
    table_2_23.ChristmasDescription = value_3_140
    table_1.Ice = table_2_23
    local table_2_24: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_141: string = "Coal"
    table_2_24.Name = value_3_141
    local value_3_142: string = "Radio Skin"
    table_2_24.Type = value_3_142
    local value_3_143: string = "1269027894"
    table_2_24.Image = value_3_143
    local table_3_47: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_24.Offset = table_3_47
    local table_3_48: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_24.Rotation = table_3_48
    local value_3_144: number = 1269027894
    table_2_24.ItemID = value_3_144
    local value_3_145: string = "NotForSale"
    table_2_24.Price = value_3_145
    local value_3_146: string = "Radio"
    table_2_24.ChristmasDescription = value_3_146
    table_1.Coal = table_2_24
    local table_2_25: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_147: string = "Candy Cane '18"
    table_2_25.Name = value_3_147
    local value_3_148: string = "Radio Skin"
    table_2_25.Type = value_3_148
    local value_3_149: string = "2672403759"
    table_2_25.Image = value_3_149
    local table_3_49: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_25.Offset = table_3_49
    local table_3_50: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_25.Rotation = table_3_50
    local value_3_150: number = 2672403759
    table_2_25.ItemID = value_3_150
    local value_3_151: string = "NotForSale"
    table_2_25.Price = value_3_151
    local value_3_152: string = "Radio"
    table_2_25.ChristmasDescription = value_3_152
    table_1.CandyCane2018 = table_2_25
    local table_2_26: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_153: string = "Blue Candy Cane '18"
    table_2_26.Name = value_3_153
    local value_3_154: string = "Radio Skin"
    table_2_26.Type = value_3_154
    local value_3_155: string = "2674776628"
    table_2_26.Image = value_3_155
    local table_3_51: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_26.Offset = table_3_51
    local table_3_52: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_26.Rotation = table_3_52
    local value_3_156: number = 2674776628
    table_2_26.ItemID = value_3_156
    local value_3_157: string = "NotForSale"
    table_2_26.Price = value_3_157
    local value_3_158: string = "Radio"
    table_2_26.ChristmasDescription = value_3_158
    table_1.BlueCandyCane2018 = table_2_26
    local table_2_27: { ChristmasDescription: string?, Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Price: string?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_159: string = "Tree"
    table_2_27.Name = value_3_159
    local value_3_160: string = "Radio Skin"
    table_2_27.Type = value_3_160
    local value_3_161: string = "2674774833"
    table_2_27.Image = value_3_161
    local table_3_53: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_27.Offset = table_3_53
    local table_3_54: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_27.Rotation = table_3_54
    local value_3_162: number = 2674774833
    table_2_27.ItemID = value_3_162
    local value_3_163: string = "NotForSale"
    table_2_27.Price = value_3_163
    local value_3_164: string = "Radio"
    table_2_27.ChristmasDescription = value_3_164
    table_1.Tree = table_2_27
    local table_2_28: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_165: string = "Candy Radio"
    table_2_28.Name = value_3_165
    local value_3_166: string = "Radio Skin"
    table_2_28.Type = value_3_166
    local value_3_167: string = "4213325191"
    table_2_28.Image = value_3_167
    local table_3_55: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_28.Offset = table_3_55
    local table_3_56: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_28.Rotation = table_3_56
    local value_3_168: number = 4324197725
    table_2_28.ItemID = value_3_168
    table_1.CandyRadio = table_2_28
    local table_2_29: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_169: string = "Jack-o-Radio"
    table_2_29.Name = value_3_169
    local value_3_170: string = "Radio Skin"
    table_2_29.Type = value_3_170
    local value_3_171: string = "4217639269"
    table_2_29.Image = value_3_171
    local table_3_57: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_29.Offset = table_3_57
    local table_3_58: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_29.Rotation = table_3_58
    local value_3_172: number = 4217639269
    table_2_29.ItemID = value_3_172
    table_1.JackRadio = table_2_29
    local table_2_30: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_173: string = "Elderwood"
    table_2_30.Name = value_3_173
    local value_3_174: string = "Radio Skin"
    table_2_30.Type = value_3_174
    local value_3_175: string = "4340193489"
    table_2_30.Image = value_3_175
    local table_3_59: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_30.Offset = table_3_59
    local table_3_60: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_30.Rotation = table_3_60
    local value_3_176: number = 4340193489
    table_2_30.ItemID = value_3_176
    table_1.ElderwoodRadio = table_2_30
end
do
    local table_2_31: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_177: string = "Minty"
    table_2_31.Name = value_3_177
    local value_3_178: string = "Radio Skin"
    table_2_31.Type = value_3_178
    local value_3_179: string = "4528279118"
    table_2_31.Image = value_3_179
    local table_3_61: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_31.Offset = table_3_61
    local table_3_62: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_31.Rotation = table_3_62
    local value_3_180: number = 4528279118
    table_2_31.ItemID = value_3_180
    table_1.ChristmasRadio2019 = table_2_31
    local table_2_32: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_181: string = "Ghost"
    table_2_32.Name = value_3_181
    local value_3_182: string = "Radio Skin"
    table_2_32.Type = value_3_182
    local value_3_183: string = "5873199043"
    table_2_32.Image = value_3_183
    local table_3_63: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_32.Offset = table_3_63
    local table_3_64: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_32.Rotation = table_3_64
    local value_3_184: number = 5873199043
    table_2_32.ItemID = value_3_184
    table_1.GhostRadio = table_2_32
    local table_2_33: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_185: string = "Hallowradio"
    table_2_33.Name = value_3_185
    local value_3_186: string = "Radio Skin"
    table_2_33.Type = value_3_186
    local value_3_187: string = "5929507735"
    table_2_33.Image = value_3_187
    local table_3_65: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_33.Offset = table_3_65
    local table_3_66: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_33.Rotation = table_3_66
    local value_3_188: number = 5929507735
    table_2_33.ItemID = value_3_188
    table_1.Hallowradio = table_2_33
    local table_2_34: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_189: string = "Reaver"
    table_2_34.Name = value_3_189
    local value_3_190: string = "Radio Skin"
    table_2_34.Type = value_3_190
    local value_3_191: string = "7805814852"
    table_2_34.Image = value_3_191
    local table_3_67: { X: number, Y: number, Z: number } = {X = 0.1, Y = 0, Z = 0.99}
    table_2_34.Offset = table_3_67
    local table_3_68: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_34.Rotation = table_3_68
    local value_3_192: number = 7805814852
    table_2_34.ItemID = value_3_192
    table_1.ReaverRadio = table_2_34
    local table_2_35: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_193: string = "Iceplayer"
    table_2_35.Name = value_3_193
    local value_3_194: string = "Radio Skin"
    table_2_35.Type = value_3_194
    local value_3_195: string = "6121716902"
    table_2_35.Image = value_3_195
    local table_3_69: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_35.Offset = table_3_69
    local table_3_70: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_35.Rotation = table_3_70
    local value_3_196: number = 6125721029
    table_2_35.ItemID = value_3_196
    table_1.ChristmasRadio2020 = table_2_35
    local table_2_36: { Image: string?, ItemID: number?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_197: string = "Swirly"
    table_2_36.Name = value_3_197
    local value_3_198: string = "Radio Skin"
    table_2_36.Type = value_3_198
    local value_3_199: string = "8304827967"
    table_2_36.Image = value_3_199
    local table_3_71: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_36.Offset = table_3_71
    local table_3_72: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_36.Rotation = table_3_72
    local value_3_200: number = 8304827967
    table_2_36.ItemID = value_3_200
    table_1.ChristmasRadio2021 = table_2_36
    local table_2_37: { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_201: string = "Vampire"
    table_2_37.Name = value_3_201
    local value_3_202: string = "Radio Skin"
    table_2_37.Type = value_3_202
    local value_3_203: string = "121531341757363"
    table_2_37.Image = value_3_203
    local table_3_73: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_37.Offset = table_3_73
    local table_3_74: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_37.Rotation = table_3_74
    table_1.VampireRadio2024 = table_2_37
    local table_2_38: { Image: string?, Name: string?, Offset: { X: number, Y: number, Z: number }?, Rotation: { X: number, Y: number, Z: number }?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_204: string = "Boombox"
    table_2_38.Name = value_3_204
    local value_3_205: string = "Radio Skin"
    table_2_38.Type = value_3_205
    local value_3_206: string = "93270344611568"
    table_2_38.Image = value_3_206
    local table_3_75: { X: number, Y: number, Z: number } = {X = 0, Y = 0, Z = 0.8}
    table_2_38.Offset = table_3_75
    local table_3_76: { X: number, Y: number, Z: number } = {
        X = 0,
        Y = 3.141592653589793,
        Z = 0.7853981633974483,
    }
    table_2_38.Rotation = table_3_76
    table_1.RetroRadio2025 = table_2_38
end

return table_1
