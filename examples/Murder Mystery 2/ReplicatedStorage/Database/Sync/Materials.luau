--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    ["1TierVisual"]: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    ActionFigureParts: { Image: string, Name: string, Rarity: string }?,
    BankEgg: { Image: string, Name: string, Rarity: string }?,
    BasketballParts: { Image: string, Name: string, Rarity: string }?,
    BeachBalls2023: { Image: string, Name: string, Rarity: string }?,
    BeachBalls2024: { Image: string, Name: string, Rarity: string }?,
    BeachBalls2024_Box: { Image: string, Name: string, Rarity: string }?,
    BeachBalls2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    BioEgg: { Image: string, Name: string, Rarity: string }?,
    BlueTokens: { Image: string, Name: string, Rarity: string }?,
    CamoEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    Candies2018: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2019: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2020: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2021: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2022: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2023: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2024: { Currency: boolean, Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?,
    Candies2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    Candies2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    CandyExchange: { Halloween: boolean, Image: string, ItemName: string, Rarity: string }?,
    CashEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    ChristmasGems: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    CoinExchange: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    CoinVisual: { Image: string, ItemName: string, Rarity: string }?,
    Coins: { Image: string, Name: string, Rarity: string }?,
    CommonBlade: { Image: string, Name: string, Rarity: string }?,
    CommonMetal: { Image: string, Name: string, Rarity: string }?,
    CommonOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    CommonShards: { Craftable: boolean, Image: string, Name: string, Rarity: string }?,
    ComputerEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    ConstructionEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    DiamondEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    DoctorEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    Eggs2023: { Image: string, Name: string, Rarity: string }?,
    Eggs2024: { Image: string, Name: string, Rarity: string }?,
    Eggs2025: { Image: string, Name: string, Rarity: string }?,
    ErrorItem: { Image: string, Name: string, Rarity: string }?,
    ExperimentEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    Fertilizer: { Christmas: boolean, ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    FireOrb: { Image: string, Name: string, Rarity: string }?,
    FireplaceEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    FragileEgg: { Image: string, Name: string, Rarity: string }?,
    GameSystemParts: { Image: string, Name: string, Rarity: string }?,
    Gems: { Image: string, Name: string, Rarity: string }?,
    Gems100: { Image: string, Name: string, Rarity: string }?,
    Gems13000: { Image: string, Name: string, Rarity: string }?,
    Gems2000: { Image: string, Name: string, Rarity: string }?,
    Gems400: { Image: string, Name: string, Rarity: string }?,
    Gems5500: { Image: string, Name: string, Rarity: string }?,
    Gems800: { Image: string, Name: string, Rarity: string }?,
    GiftVisual: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    GingerbreadCookie: { Image: string, Name: string, Rarity: string }?,
    GodlyMetal: { Image: string, Name: string, Rarity: string }?,
    GodlyShards: { Image: string, Name: string, Rarity: string }?,
    GoldBar: { Image: string, Name: string, Rarity: string }?,
    Halloween2023Key: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    HalloweenKey2022: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    HalloweenKey2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    HalloweenKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    Hearts2023: { Image: string, Name: string, Rarity: string }?,
    HospitalEgg: { Image: string, Name: string, Rarity: string }?,
    JDEgg: { Image: string, Name: string, Rarity: string }?,
    KnifeCrown: { Image: string, ItemName: string, ItemType: string, Rarity: string }?,
    LegendaryBlade: { Image: string, Name: string, Rarity: string }?,
    LegendaryMetal: { Image: string, Name: string, Rarity: string }?,
    LegendaryOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    LegendaryShards: { Image: string, Name: string, Rarity: string }?,
    Logs2018: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    MarbleEgg: { Image: string, Name: string, Rarity: string }?,
    MatrixEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    MedicEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    MilitaryEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    MissingInfo: { Image: string, Name: string, Rarity: string }?,
    NikEgg: { Image: string, Name: string, Rarity: string }?,
    NukeEgg: { Image: string, Name: string, Rarity: string }?,
    OfficeEgg: { Image: string, Name: string, Rarity: string }?,
    OfficeEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    PaintingEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    PoliceEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    PumpkinKey: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    PumpkinKey2020: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    PurpleEgg: { Image: string, Name: string, Rarity: string }?,
    RareBlade: { Image: string, Name: string, Rarity: string }?,
    RareEggs2025: { Image: string, Name: string, Rarity: string }?,
    RareMetal: { Image: string, Name: string, Rarity: string }?,
    RareOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    RareShards: { Image: string, Name: string, Rarity: string }?,
    ReaverKey2021: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? },
    RedTokens: { Image: string, Name: string, Rarity: string }?,
    RobotEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    RobotEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    Robux: { Image: string, Name: string, Rarity: string }?,
    ScientistEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    SkateboardParts: { Image: string, Name: string, Rarity: string }?,
    SnowKey2019: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    SnowKey2020: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    SnowKey2021: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    SnowKey2022: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    SnowKey2023: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? },
    SnowKey2024: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?,
    SnowKey2025: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2019: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2020: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2021: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2022: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2023: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2024: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?,
    SnowTokens2024_116000: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_14280: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_270000: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_3200: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_46800: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_6400: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2024_800: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SnowTokens2025: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?,
    SnowflakeTokens: { Image: string, Name: string, Rarity: string }?,
    SnowflakeTokens2018: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    SpeedyEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    SuitEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    SummerKey2024: { Image: string, Name: string, Rarity: string }?,
    SummerKey2024_1: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_150: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_20: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_360: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_4: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_60: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2024_8: { Image: string, ItemType: string, Name: string, Rarity: string }?,
    SummerKey2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    SummerKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    TechEgg: { Image: string, Name: string, Rarity: string }?,
    ToyBasketball: { Image: string, Name: string, Rarity: string }?,
    ToyGameSystem: { Image: string, Name: string, Rarity: string }?,
    ToyHoverboard: { Image: string, Name: string, Rarity: string }?,
    ToyHoverboardParts: { Image: string, Name: string, Rarity: string }?,
    ToyRCCar: { Image: string, Name: string, Rarity: string }?,
    ToyRCCarParts: { Image: string, Name: string, Rarity: string }?,
    ToyRobot: { Image: string, Name: string, Rarity: string }?,
    ToySkateboard: { Image: string, Name: string, Rarity: string }?,
    ToySpinner: { Image: string, Name: string, Rarity: string }?,
    ToySpinnerParts: { Image: string, Name: string, Rarity: string }?,
    ToyTablet: { Image: string, Name: string, Rarity: string }?,
    ToyTabletParts: { Image: string, Name: string, Rarity: string }?,
    UncommonBlade: { Image: string, Name: string, Rarity: string }?,
    UncommonMetal: { Image: string, Name: string, Rarity: string }?,
    UncommonOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?,
    UncommonShards: { Image: string, Name: string, Rarity: string }?,
    ValentinesKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?,
    VampireKey2024: nil | { Currency: boolean, Event: string, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } | { Currency: boolean?, Event: string?, Image: string?, ItemType: string?, Name: string?, Rarity: string?, Year: string? },
    WaterOrb: { Image: string, Name: string, Rarity: string }?,
    WinterKey: { Image: string, Name: string, Rarity: string }?,
    WorkerEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string },
    WrappedBasketballGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedBasketballPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedBasketballRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedGameSystemGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedGameSystemPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedGameSystemRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedHoverboardBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedHoverboardGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedHoverboardUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRCCarBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRCCarGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRCCarUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRobotGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRobotPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedRobotRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSkateboardGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSkateboardPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSkateboardRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSpinnerBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSpinnerGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedSpinnerUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedTabletBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedTabletGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappedTabletUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?,
    WrappingPaperBlue: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    WrappingPaperGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    WrappingPaperGreen: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    WrappingPaperPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    WrappingPaperRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    WrappingPaperUltra: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?,
    ZyleakEgg: { Image: string, Name: string, Rarity: string }?,
}

local table_1: { ["1TierVisual"]: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, ActionFigureParts: { Image: string, Name: string, Rarity: string }?, BankEgg: { Image: string, Name: string, Rarity: string }?, BasketballParts: { Image: string, Name: string, Rarity: string }?, BeachBalls2023: { Image: string, Name: string, Rarity: string }?, BeachBalls2024: { Image: string, Name: string, Rarity: string }?, BeachBalls2024_Box: { Image: string, Name: string, Rarity: string }?, BeachBalls2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?, BioEgg: { Image: string, Name: string, Rarity: string }?, BlueTokens: { Image: string, Name: string, Rarity: string }?, CamoEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, Candies2018: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2019: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2020: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2021: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2022: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2023: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2024: { Currency: boolean, Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string }?, Candies2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?, Candies2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?, CandyExchange: { Halloween: boolean, Image: string, ItemName: string, Rarity: string }?, CashEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, ChristmasGems: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, CoinExchange: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, CoinVisual: { Image: string, ItemName: string, Rarity: string }?, Coins: { Image: string, Name: string, Rarity: string }?, CommonBlade: { Image: string, Name: string, Rarity: string }?, CommonMetal: { Image: string, Name: string, Rarity: string }?, CommonOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, CommonShards: { Craftable: boolean, Image: string, Name: string, Rarity: string }?, ComputerEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, ConstructionEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, DiamondEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, DoctorEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, Eggs2023: { Image: string, Name: string, Rarity: string }?, Eggs2024: { Image: string, Name: string, Rarity: string }?, Eggs2025: { Image: string, Name: string, Rarity: string }?, ErrorItem: { Image: string, Name: string, Rarity: string }?, ExperimentEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, Fertilizer: { Christmas: boolean, ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, FireOrb: { Image: string, Name: string, Rarity: string }?, FireplaceEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, FragileEgg: { Image: string, Name: string, Rarity: string }?, GameSystemParts: { Image: string, Name: string, Rarity: string }?, Gems: { Image: string, Name: string, Rarity: string }?, Gems100: { Image: string, Name: string, Rarity: string }?, Gems13000: { Image: string, Name: string, Rarity: string }?, Gems2000: { Image: string, Name: string, Rarity: string }?, Gems400: { Image: string, Name: string, Rarity: string }?, Gems5500: { Image: string, Name: string, Rarity: string }?, Gems800: { Image: string, Name: string, Rarity: string }?, GiftVisual: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, GingerbreadCookie: { Image: string, Name: string, Rarity: string }?, GodlyMetal: { Image: string, Name: string, Rarity: string }?, GodlyShards: { Image: string, Name: string, Rarity: string }?, GoldBar: { Image: string, Name: string, Rarity: string }?, Halloween2023Key: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, HalloweenKey2022: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, HalloweenKey2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?, HalloweenKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?, Hearts2023: { Image: string, Name: string, Rarity: string }?, HospitalEgg: { Image: string, Name: string, Rarity: string }?, JDEgg: { Image: string, Name: string, Rarity: string }?, KnifeCrown: { Image: string, ItemName: string, ItemType: string, Rarity: string }?, LegendaryBlade: { Image: string, Name: string, Rarity: string }?, LegendaryMetal: { Image: string, Name: string, Rarity: string }?, LegendaryOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, LegendaryShards: { Image: string, Name: string, Rarity: string }?, Logs2018: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, MarbleEgg: { Image: string, Name: string, Rarity: string }?, MatrixEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, MedicEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, MilitaryEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, MissingInfo: { Image: string, Name: string, Rarity: string }?, NikEgg: { Image: string, Name: string, Rarity: string }?, NukeEgg: { Image: string, Name: string, Rarity: string }?, OfficeEgg: { Image: string, Name: string, Rarity: string }?, OfficeEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, PaintingEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, PoliceEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, PumpkinKey: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, PumpkinKey2020: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, PurpleEgg: { Image: string, Name: string, Rarity: string }?, RareBlade: { Image: string, Name: string, Rarity: string }?, RareEggs2025: { Image: string, Name: string, Rarity: string }?, RareMetal: { Image: string, Name: string, Rarity: string }?, RareOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, RareShards: { Image: string, Name: string, Rarity: string }?, ReaverKey2021: nil | { Event: string, Image: string, ItemName: string, ItemType: string, Rarity: string, Year: string } | { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? }, RedTokens: { Image: string, Name: string, Rarity: string }?, RobotEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, RobotEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, Robux: { Image: string, Name: string, Rarity: string }?, ScientistEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, SkateboardParts: { Image: string, Name: string, Rarity: string }?, SnowKey2019: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, SnowKey2020: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, SnowKey2021: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, SnowKey2022: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, SnowKey2023: nil | { Christmas: boolean, Image: string, ItemName: string, Rarity: string } | { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? }, SnowKey2024: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?, SnowKey2025: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2019: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2020: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2021: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2022: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2023: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2024: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?, SnowTokens2024_116000: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_14280: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_270000: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_3200: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_46800: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_6400: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2024_800: { Image: string, ItemType: string, Name: string, Rarity: string }?, SnowTokens2025: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string }?, SnowflakeTokens: { Image: string, Name: string, Rarity: string }?, SnowflakeTokens2018: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, SpeedyEgg2025: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, SuitEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, SummerKey2024: { Image: string, Name: string, Rarity: string }?, SummerKey2024_1: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_150: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_20: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_360: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_4: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_60: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2024_8: { Image: string, ItemType: string, Name: string, Rarity: string }?, SummerKey2025: { Currency: boolean, Image: string, Name: string, Rarity: string }?, SummerKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?, TechEgg: { Image: string, Name: string, Rarity: string }?, ToyBasketball: { Image: string, Name: string, Rarity: string }?, ToyGameSystem: { Image: string, Name: string, Rarity: string }?, ToyHoverboard: { Image: string, Name: string, Rarity: string }?, ToyHoverboardParts: { Image: string, Name: string, Rarity: string }?, ToyRCCar: { Image: string, Name: string, Rarity: string }?, ToyRCCarParts: { Image: string, Name: string, Rarity: string }?, ToyRobot: { Image: string, Name: string, Rarity: string }?, ToySkateboard: { Image: string, Name: string, Rarity: string }?, ToySpinner: { Image: string, Name: string, Rarity: string }?, ToySpinnerParts: { Image: string, Name: string, Rarity: string }?, ToyTablet: { Image: string, Name: string, Rarity: string }?, ToyTabletParts: { Image: string, Name: string, Rarity: string }?, UncommonBlade: { Image: string, Name: string, Rarity: string }?, UncommonMetal: { Image: string, Name: string, Rarity: string }?, UncommonOrnament: { Christmas: boolean, Image: string, Name: string, Rarity: string }?, UncommonShards: { Image: string, Name: string, Rarity: string }?, ValentinesKey2026: { Currency: boolean, Image: string, Name: string, Rarity: string }?, VampireKey2024: nil | { Currency: boolean, Event: string, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } | { Currency: boolean?, Event: string?, Image: string?, ItemType: string?, Name: string?, Rarity: string?, Year: string? }, WaterOrb: { Image: string, Name: string, Rarity: string }?, WinterKey: { Image: string, Name: string, Rarity: string }?, WorkerEgg2024: nil | { Image: string, Name: string, Rarity: string } | { Image: number | string, Name: string, Rarity: string }, WrappedBasketballGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedBasketballPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedBasketballRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedGameSystemGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedGameSystemPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedGameSystemRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedHoverboardBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedHoverboardGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedHoverboardUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedRCCarBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedRCCarGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedRCCarUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedRobotGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedRobotPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedRobotRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedSkateboardGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedSkateboardPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedSkateboardRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number }?, WrappedSpinnerBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedSpinnerGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedSpinnerUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedTabletBlue: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedTabletGreen: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappedTabletUltra: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number }?, WrappingPaperBlue: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, WrappingPaperGold: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, WrappingPaperGreen: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, WrappingPaperPurple: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, WrappingPaperRed: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, WrappingPaperUltra: { ChristmasDescription: string, Image: string, Name: string, Rarity: string }?, ZyleakEgg: { Image: string, Name: string, Rarity: string }? } = {
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
    [("Gems")] = nil,
}
do
    local table_2: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://377010926",
        Rarity = "Common",
    }
    table_1.Gems = table_2
    local table_2_2: { Image: string, Name: string, Rarity: string } = {
        Name = "Coins",
        Image = "rbxassetid://3150319038",
        Rarity = "Common",
    }
    table_1.Coins = table_2_2
    local table_2_3: { Image: string, Name: string, Rarity: string } = {
        Name = "Robux",
        Image = "rbxassetid://4753462939",
        Rarity = "Common",
    }
    table_1.Robux = table_2_3
    local table_2_4: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://114051511883252",
        Rarity = "Common",
    }
    table_1.Gems100 = table_2_4
    local table_2_5: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://127872064436614",
        Rarity = "Common",
    }
    table_1.Gems400 = table_2_5
    local table_2_6: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://108440042637037",
        Rarity = "Uncommon",
    }
    table_1.Gems800 = table_2_6
    local table_2_7: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://138958526613467",
        Rarity = "Rare",
    }
    table_1.Gems2000 = table_2_7
    local table_2_8: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://124302198387616",
        Rarity = "Legendary",
    }
    table_1.Gems5500 = table_2_8
    local table_2_9: { Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "rbxassetid://111917834481221",
        Rarity = "Godly",
    }
    table_1.Gems13000 = table_2_9
    local table_2_10: { Craftable: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Common Shards",
        Image = "https://www.roblox.com/asset/?id=377277359",
        Rarity = "Common",
        Craftable = true,
    }
    table_1.CommonShards = table_2_10
    local table_2_11: { Image: string, Name: string, Rarity: string } = {
        Name = "Common Metal",
        Image = "https://www.roblox.com/asset/?id=377352531",
        Rarity = "Common",
    }
    table_1.CommonMetal = table_2_11
    local table_2_12: { Image: string, Name: string, Rarity: string } = {
        Name = "Common Blade",
        Image = "https://www.roblox.com/asset/?id=377375936",
        Rarity = "Common",
    }
    table_1.CommonBlade = table_2_12
    local table_2_13: { Image: string, Name: string, Rarity: string } = {
        Name = "Uncommon Shards",
        Image = "https://www.roblox.com/asset/?id=379521032",
        Rarity = "Uncommon",
    }
    table_1.UncommonShards = table_2_13
    local table_2_14: { Image: string, Name: string, Rarity: string } = {
        Name = "Uncommon Metal",
        Image = "https://www.roblox.com/asset/?id=379521014",
        Rarity = "Uncommon",
    }
    table_1.UncommonMetal = table_2_14
    local table_2_15: { Image: string, Name: string, Rarity: string } = {
        Name = "Uncommon Blade",
        Image = "https://www.roblox.com/asset/?id=450508117",
        Rarity = "Uncommon",
    }
    table_1.UncommonBlade = table_2_15
    local table_2_16: { Image: string, Name: string, Rarity: string } = {
        Name = "Rare Shards",
        Image = "https://www.roblox.com/asset/?id=450509512",
        Rarity = "Rare",
    }
    table_1.RareShards = table_2_16
    local table_2_17: { Image: string, Name: string, Rarity: string } = {
        Name = "Rare Metal",
        Image = "https://www.roblox.com/asset/?id=450509411",
        Rarity = "Rare",
    }
    table_1.RareMetal = table_2_17
    local table_2_18: { Image: string, Name: string, Rarity: string } = {
        Name = "Rare Blade",
        Image = "https://www.roblox.com/asset/?id=450509482",
        Rarity = "Rare",
    }
    table_1.RareBlade = table_2_18
    local table_2_19: { Image: string, Name: string, Rarity: string } = {
        Name = "Legendary Shards",
        Image = "https://www.roblox.com/asset/?id=450512602",
        Rarity = "Legendary",
    }
    table_1.LegendaryShards = table_2_19
    local table_2_20: { Image: string, Name: string, Rarity: string } = {
        Name = "Legendary Blade",
        Image = "https://www.roblox.com/asset/?id=450512648",
        Rarity = "Legendary",
    }
    table_1.LegendaryBlade = table_2_20
    local table_2_21: { Image: string, Name: string, Rarity: string } = {
        Name = "Legendary Metal",
        Image = "https://www.roblox.com/asset/?id=450512697",
        Rarity = "Legendary",
    }
    table_1.LegendaryMetal = table_2_21
    local table_2_22: { Image: string, Name: string, Rarity: string } = {
        Name = "Godly Shards",
        Image = "https://www.roblox.com/asset/?id=582317831",
        Rarity = "Godly",
    }
    table_1.GodlyShards = table_2_22
    local table_2_23: { Image: string, Name: string, Rarity: string } = {
        Name = "Godly Metal",
        Image = "rbxassetid://583459154",
        Rarity = "Godly",
    }
    table_1.GodlyMetal = table_2_23
    local table_2_24: { Image: string, Name: string, Rarity: string } = {
        Name = "Basketball Rubber",
        Image = "rbxassetid://583435481",
        Rarity = "Common",
    }
    table_1.BasketballParts = table_2_24
    local table_2_25: { Image: string, Name: string, Rarity: string } = {
        Name = "Toy Robot Pieces",
        Image = "rbxassetid://583436050",
        Rarity = "Uncommon",
    }
    table_1.ActionFigureParts = table_2_25
    local table_2_26: { Image: string, Name: string, Rarity: string } = {
        Name = "Skateboard Parts",
        Image = "rbxassetid://583442584",
        Rarity = "Rare",
    }
    table_1.SkateboardParts = table_2_26
    local table_2_27: { Image: string, Name: string, Rarity: string } = {
        Name = "Game System Parts",
        Image = "rbxassetid://583442650",
        Rarity = "Legendary",
    }
    table_1.GameSystemParts = table_2_27
    local table_2_28: { Image: string, Name: string, Rarity: string } = {
        Name = "Basketball",
        Image = "rbxassetid://583505141",
        Rarity = "Common",
    }
    table_1.ToyBasketball = table_2_28
    local table_2_29: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Red Wrapped Basketball",
        Image = "rbxassetid://584820728",
        Rarity = "Common",
        ChristmasDescription = "1 Tokens",
        TokenValue = 1,
    }
    table_1.WrappedBasketballRed = table_2_29
    local table_2_30: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Purple Wrapped Basketball",
        Image = "rbxassetid://584821953",
        Rarity = "Common",
        ChristmasDescription = "2 Tokens",
        TokenValue = 2,
    }
    table_1.WrappedBasketballPurple = table_2_30
    local table_2_31: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Gold Wrapped Basketball",
        Image = "rbxassetid://584822040",
        Rarity = "Common",
        ChristmasDescription = "3 Tokens",
        TokenValue = 3,
    }
    table_1.WrappedBasketballGold = table_2_31
    local table_2_32: { Image: string, Name: string, Rarity: string } = {
        Name = "Toy Robot",
        Image = "rbxassetid://583508162",
        Rarity = "Uncommon",
    }
    table_1.ToyRobot = table_2_32
    local table_2_33: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Red Wrapped Robot",
        Image = "rbxassetid://584862997",
        Rarity = "Common",
        TokenValue = 6,
        ChristmasDescription = "6 Tokens",
    }
    table_1.WrappedRobotRed = table_2_33
    local table_2_34: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Purple Wrapped Robot",
        Image = "rbxassetid://584863032",
        Rarity = "Common",
        TokenValue = 12,
        ChristmasDescription = "12 Tokens",
    }
    table_1.WrappedRobotPurple = table_2_34
    local table_2_35: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Gold Wrapped Robot",
        Image = "rbxassetid://584863080",
        Rarity = "Common",
        TokenValue = 18,
        ChristmasDescription = "18 Tokens",
    }
    table_1.WrappedRobotGold = table_2_35
    local table_2_36: { Image: string, Name: string, Rarity: string } = {
        Name = "Skateboard",
        Image = "rbxassetid://583508609",
        Rarity = "Rare",
    }
    table_1.ToySkateboard = table_2_36
    local table_2_37: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Red Wrapped Skateboard",
        Image = "rbxassetid://584864157",
        Rarity = "Rare",
        ChristmasDescription = "40 Tokens",
        TokenValue = 40,
    }
    table_1.WrappedSkateboardRed = table_2_37
    local table_2_38: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Purple Wrapped Skateboard",
        Image = "rbxassetid://584864219",
        Rarity = "Rare",
        ChristmasDescription = "80 Tokens",
        TokenValue = 80,
    }
    table_1.WrappedSkateboardPurple = table_2_38
    local table_2_39: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Gold Wrapped Skateboard",
        Image = "rbxassetid://584864241",
        Rarity = "Rare",
        ChristmasDescription = "120 Tokens",
        TokenValue = 120,
    }
    table_1.WrappedSkateboardGold = table_2_39
    local table_2_40: { Image: string, Name: string, Rarity: string } = {
        Name = "Game System",
        Image = "rbxassetid://583509564",
        Rarity = "Legendary",
    }
    table_1.ToyGameSystem = table_2_40
    local table_2_41: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Red Wrapped Game System",
        Image = "rbxassetid://584864788",
        Rarity = "Legendary",
        ChristmasDescription = "500 Tokens",
        TokenValue = 250,
    }
    table_1.WrappedGameSystemRed = table_2_41
    local table_2_42: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Purple Wrapped Game System",
        Image = "rbxassetid://584864824",
        Rarity = "Legendary",
        ChristmasDescription = "1,000 Tokens",
        TokenValue = 500,
    }
    table_1.WrappedGameSystemPurple = table_2_42
    local table_2_43: { ChristmasDescription: string, Image: string, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Gold Wrapped Game System",
        Image = "rbxassetid://584864856",
        Rarity = "Legendary",
        ChristmasDescription = "1,500 Tokens",
        TokenValue = 750,
    }
    table_1.WrappedGameSystemGold = table_2_43
    local table_2_44: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Red Wrapping Paper",
        Image = "rbxassetid://584490043",
        Rarity = "Common",
        ChristmasDescription = "Obtained from round drops",
    }
    table_1.WrappingPaperRed = table_2_44
    local table_2_45: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Purple Wrapping Paper",
        Image = "rbxassetid://584585410",
        Rarity = "Common",
        ChristmasDescription = "Gives 1.5x Token and Key Reward",
    }
    table_1.WrappingPaperPurple = table_2_45
    local table_2_46: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Gold Wrapping Paper",
        Image = "rbxassetid://584585923",
        Rarity = "Common",
        ChristmasDescription = "Gives 2x Token and Key Reward",
    }
    table_1.WrappingPaperGold = table_2_46
    local table_2_47: { Image: string, Name: string, Rarity: string } = {
        Name = "Blue Tokens",
        Image = "rbxassetid://583684053",
        Rarity = "Common",
    }
    table_1.BlueTokens = table_2_47
    local table_2_48: { Image: string, Name: string, Rarity: string } = {
        Name = "Red Tokens",
        Image = "rbxassetid://584578609",
        Rarity = "Common",
    }
    table_1.RedTokens = table_2_48
    local table_2_49: { Image: string, Name: string, Rarity: string } = {
        Name = "Spinner Parts",
        Image = "rbxassetid://1265440730",
        Rarity = "Common",
    }
    table_1.ToySpinnerParts = table_2_49
    local table_2_50: { Image: string, Name: string, Rarity: string } = {
        Name = "Spinner",
        Image = "rbxassetid://1265440726",
        Rarity = "Common",
    }
    table_1.ToySpinner = table_2_50
    local table_2_51: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Spinner (Green)",
        Image = "rbxassetid://1265440741",
        Rarity = "Common",
        ChristmasDescription = "10 Tokens",
        TokenValue = 10,
        KeyValue = 2,
    }
    table_1.WrappedSpinnerGreen = table_2_51
    local table_2_52: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Spinner (Blue)",
        Image = "rbxassetid://1265440767",
        Rarity = "Common",
        ChristmasDescription = "20 Tokens",
        TokenValue = 15,
        KeyValue = 3,
    }
    table_1.WrappedSpinnerBlue = table_2_52
    local table_2_53: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Spinner (Ultra)",
        Image = "rbxassetid://1265440732",
        Rarity = "Common",
        ChristmasDescription = "30 Tokens",
        TokenValue = 20,
        KeyValue = 4,
    }
    table_1.WrappedSpinnerUltra = table_2_53
    local table_2_54: { Image: string, Name: string, Rarity: string } = {
        Name = "RC Car Parts",
        Image = "rbxassetid://1265473109",
        Rarity = "Uncommon",
    }
    table_1.ToyRCCarParts = table_2_54
    local table_2_55: { Image: string, Name: string, Rarity: string } = {
        Name = "RC Car",
        Image = "rbxassetid://1265473066",
        Rarity = "Uncommon",
    }
    table_1.ToyRCCar = table_2_55
    local table_2_56: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped RC Car (Green)",
        Image = "rbxassetid://1265473115",
        Rarity = "Uncommon",
        ChristmasDescription = "60 Tokens",
        TokenValue = 60,
        KeyValue = 5,
    }
    table_1.WrappedRCCarGreen = table_2_56
    local table_2_57: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped RC Car (Blue)",
        Image = "rbxassetid://1265473171",
        Rarity = "Uncommon",
        ChristmasDescription = "120 Tokens",
        TokenValue = 90,
        KeyValue = 7,
    }
    table_1.WrappedRCCarBlue = table_2_57
    local table_2_58: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped RC Car (Ultra)",
        Image = "rbxassetid://1265473130",
        Rarity = "Uncommon",
        ChristmasDescription = "180 Tokens",
        TokenValue = 120,
        KeyValue = 10,
    }
    table_1.WrappedRCCarUltra = table_2_58
    local table_2_59: { Image: string, Name: string, Rarity: string } = {
        Name = "Hoverboard Parts",
        Image = "rbxassetid://1265502028",
        Rarity = "Rare",
    }
    table_1.ToyHoverboardParts = table_2_59
    local table_2_60: { Image: string, Name: string, Rarity: string } = {
        Name = "Hoverboard",
        Image = "rbxassetid://1265502030",
        Rarity = "Rare",
    }
    table_1.ToyHoverboard = table_2_60
    local table_2_61: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Hoverboard (Green)",
        Image = "rbxassetid://1265502031",
        Rarity = "Rare",
        ChristmasDescription = "60 Tokens",
        TokenValue = 400,
        KeyValue = 10,
    }
    table_1.WrappedHoverboardGreen = table_2_61
    local table_2_62: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Hoverboard (Blue)",
        Image = "rbxassetid://1265502029",
        Rarity = "Rare",
        ChristmasDescription = "120 Tokens",
        TokenValue = 600,
        KeyValue = 15,
    }
    table_1.WrappedHoverboardBlue = table_2_62
    local table_2_63: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Hoverboard (Ultra)",
        Image = "rbxassetid://1265502035",
        Rarity = "Rare",
        ChristmasDescription = "180 Tokens",
        TokenValue = 800,
        KeyValue = 20,
    }
    table_1.WrappedHoverboardUltra = table_2_63
    local table_2_64: { Image: string, Name: string, Rarity: string } = {
        Name = "Tablet Parts",
        Image = "rbxassetid://1265527127",
        Rarity = "Legendary",
    }
    table_1.ToyTabletParts = table_2_64
end
do
    local table_2_65: { Image: string, Name: string, Rarity: string } = {
        Name = "Tablet",
        Image = "rbxassetid://1265527129",
        Rarity = "Legendary",
    }
    table_1.ToyTablet = table_2_65
    local table_2_66: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Tablet (Green)",
        Image = "rbxassetid://1265527271",
        Rarity = "Legendary",
        ChristmasDescription = "60 Tokens",
        TokenValue = 2500,
        KeyValue = 20,
    }
    table_1.WrappedTabletGreen = table_2_66
    local table_2_67: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Tablet (Blue)",
        Image = "rbxassetid://1265527279",
        Rarity = "Rare",
        ChristmasDescription = "120 Tokens",
        TokenValue = 3750,
        KeyValue = 30,
    }
    table_1.WrappedTabletBlue = table_2_67
    local table_2_68: { ChristmasDescription: string, Image: string, KeyValue: number, Name: string, Rarity: string, TokenValue: number } = {
        Name = "Wrapped Tablet (Ultra)",
        Image = "rbxassetid://1265527300",
        Rarity = "Legendary",
        ChristmasDescription = "180 Tokens",
        TokenValue = 5000,
        KeyValue = 40,
    }
    table_1.WrappedTabletUltra = table_2_68
    local table_2_69: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Green Wrapping Paper",
        Image = "rbxassetid://1262588123",
        Rarity = "Common",
        ChristmasDescription = "Obtained from round drops",
    }
    table_1.WrappingPaperGreen = table_2_69
    local table_2_70: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Blue Wrapping Paper",
        Image = "rbxassetid://1262588124",
        Rarity = "Common",
        ChristmasDescription = "Gives 1.5x Token and Key Reward",
    }
    table_1.WrappingPaperBlue = table_2_70
    local table_2_71: { ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Ultra Wrapping Paper",
        Image = "rbxassetid://1262588130",
        Rarity = "Common",
        ChristmasDescription = "Gives 2x Token and Key Reward",
    }
    table_1.WrappingPaperUltra = table_2_71
    local table_2_72: { Image: string, Name: string, Rarity: string } = {
        Name = "Snowflake Tokens",
        Image = "rbxassetid://1260488844",
        Rarity = "Common",
    }
    table_1.SnowflakeTokens = table_2_72
    local table_2_73: { Image: string, Name: string, Rarity: string } = {
        Name = "Winter Key",
        Image = "rbxassetid://1265372551",
        Rarity = "Common",
    }
    table_1.WinterKey = table_2_73
    local table_2_74: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "rbxassetid://2496266437",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2018",
    }
    table_1.Candies2018 = table_2_74
    local table_2_75: { Image: string, Name: string, Rarity: string } = {
        Name = "Fire Orb",
        Image = "rbxassetid://585638462",
        Rarity = "Godly",
    }
    table_1.FireOrb = table_2_75
    local table_2_76: { Image: string, Name: string, Rarity: string } = {
        Name = "Water Orb",
        Image = "rbxassetid://585638567",
        Rarity = "Godly",
    }
    table_1.WaterOrb = table_2_76
    local table_2_77: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Common Ornament",
        Image = "rbxassetid://2661312119",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.CommonOrnament = table_2_77
    local table_2_78: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Uncommon Ornament",
        Image = "rbxassetid://2664044862",
        Rarity = "Uncommon",
        Christmas = true,
    }
    table_1.UncommonOrnament = table_2_78
    local table_2_79: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Rare Ornament",
        Image = "rbxassetid://2664044849",
        Rarity = "Rare",
        Christmas = true,
    }
    table_1.RareOrnament = table_2_79
    local table_2_80: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Legendary Ornament",
        Image = "rbxassetid://2664049951",
        Rarity = "Legendary",
        Christmas = true,
    }
    table_1.LegendaryOrnament = table_2_80
    local table_2_81: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snowflake Tokens",
        Image = "rbxassetid://2667058005",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowflakeTokens2018 = table_2_81
    local table_2_82: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Logs",
        Image = "rbxassetid://2669693376",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.Logs2018 = table_2_82
    local table_2_83: { Christmas: boolean, ChristmasDescription: string, Image: string, Name: string, Rarity: string } = {
        Name = "Fertilizer",
        Image = "rbxassetid://2669880385",
        Rarity = "Uncommon",
        Christmas = true,
        ChristmasDescription = "Grows a tree instantly. One-time use.",
    }
    table_1.Fertilizer = table_2_83
    local table_2_84: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Gems",
        Image = "https://www.roblox.com/asset/?id=377010926",
        Rarity = "Uncommon",
        Christmas = true,
    }
    table_1.ChristmasGems = table_2_84
    local table_2_85: { Image: string, Name: string, Rarity: string } = {
        Name = "Gold Bar",
        Image = "rbxassetid://2674991164",
        Rarity = "Godly",
    }
    table_1.GoldBar = table_2_85
    local table_2_86: { Image: string, Name: string, Rarity: string } = {
        Name = "Gingerbread Cookie",
        Image = "rbxassetid://2674991174",
        Rarity = "Godly",
    }
    table_1.GingerbreadCookie = table_2_86
    local table_2_87: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "rbxassetid://4204110912",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2019",
    }
    table_1.Candies2019 = table_2_87
    local table_2_88: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "rbxassetid://5859138726",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2020",
    }
    table_1.Candies2020 = table_2_88
    local table_2_89: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "http://www.roblox.com/asset/?id=7798523352",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2021",
    }
    table_1.Candies2021 = table_2_89
    local table_2_90: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "http://www.roblox.com/asset/?id=11137521765",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2022",
    }
    table_1.Candies2022 = table_2_90
    local table_2_91: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3: string = "Pumpkin Key"
    table_2_91.ItemName = value_3
    local value_3_2: string = "rbxassetid://4217900274"
    table_2_91.Image = value_3_2
    local value_3_3: string = "Halloween"
    table_2_91.Rarity = value_3_3
    local value_3_4: string = "Misc"
    table_2_91.ItemType = value_3_4
    local value_3_5: string = "Halloween"
    table_2_91.Event = value_3_5
    local value_3_6: string = "2019"
    table_2_91.Year = value_3_6
    table_1.PumpkinKey = table_2_91
    local table_2_92: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_7: string = "Pumpkin Key"
    table_2_92.ItemName = value_3_7
    local value_3_8: string = "rbxassetid://4217900274"
    table_2_92.Image = value_3_8
    local value_3_9: string = "Halloween"
    table_2_92.Rarity = value_3_9
    local value_3_10: string = "Misc"
    table_2_92.ItemType = value_3_10
    local value_3_11: string = "Halloween"
    table_2_92.Event = value_3_11
    local value_3_12: string = "2020"
    table_2_92.Year = value_3_12
    table_1.PumpkinKey2020 = table_2_92
    local table_2_93: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_13: string = "Reaver Key"
    table_2_93.ItemName = value_3_13
    local value_3_14: string = "http://www.roblox.com/asset/?id=7801095142"
    table_2_93.Image = value_3_14
    local value_3_15: string = "Halloween"
    table_2_93.Rarity = value_3_15
    local value_3_16: string = "Misc"
    table_2_93.ItemType = value_3_16
    local value_3_17: string = "Halloween"
    table_2_93.Event = value_3_17
    local value_3_18: string = "2021"
    table_2_93.Year = value_3_18
    table_1.ReaverKey2021 = table_2_93
    local table_2_94: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_19: string = "+1 Tier"
    table_2_94.ItemName = value_3_19
    local value_3_20: string = "http://www.roblox.com/asset/?id=2954739019"
    table_2_94.Image = value_3_20
    local value_3_21: string = "Halloween"
    table_2_94.Rarity = value_3_21
    local value_3_22: string = "Misc"
    table_2_94.ItemType = value_3_22
    local value_3_23: string = "Halloween"
    table_2_94.Event = value_3_23
    local value_3_24: string = "2019"
    table_2_94.Year = value_3_24
    table_1["1TierVisual"] = table_2_94
    local table_2_95: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowTokens2019 = table_2_95
    local table_2_96: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_25: string = "Snow Key"
    table_2_96.ItemName = value_3_25
    local value_3_26: string = "rbxassetid://2667058001"
    table_2_96.Image = value_3_26
    local value_3_27: string = "Common"
    table_2_96.Rarity = value_3_27
    local value_3_28: boolean = true
    table_2_96.Christmas = value_3_28
    table_1.SnowKey2019 = table_2_96
    local table_2_97: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowTokens2020 = table_2_97
    local table_2_98: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_29: string = "Snow Key"
    table_2_98.ItemName = value_3_29
    local value_3_30: string = "rbxassetid://2667058001"
    table_2_98.Image = value_3_30
    local value_3_31: string = "Common"
    table_2_98.Rarity = value_3_31
    local value_3_32: boolean = true
    table_2_98.Christmas = value_3_32
    table_1.SnowKey2020 = table_2_98
end
do
    local table_2_99: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowTokens2021 = table_2_99
    local table_2_100: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_33: string = "Snow Key"
    table_2_100.ItemName = value_3_33
    local value_3_34: string = "rbxassetid://2667058001"
    table_2_100.Image = value_3_34
    local value_3_35: string = "Common"
    table_2_100.Rarity = value_3_35
    local value_3_36: boolean = true
    table_2_100.Christmas = value_3_36
    table_1.SnowKey2021 = table_2_100
    local table_2_101: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowTokens2022 = table_2_101
    local table_2_102: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_37: string = "Snow Key"
    table_2_102.ItemName = value_3_37
    local value_3_38: string = "rbxassetid://2667058001"
    table_2_102.Image = value_3_38
    local value_3_39: string = "Common"
    table_2_102.Rarity = value_3_39
    local value_3_40: boolean = true
    table_2_102.Christmas = value_3_40
    table_1.SnowKey2022 = table_2_102
    local table_2_103: { Christmas: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
    }
    table_1.SnowTokens2023 = table_2_103
    local table_2_104: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_41: string = "Snow Key"
    table_2_104.ItemName = value_3_41
    local value_3_42: string = "rbxassetid://15625795123"
    table_2_104.Image = value_3_42
    local value_3_43: string = "Common"
    table_2_104.Rarity = value_3_43
    local value_3_44: boolean = true
    table_2_104.Christmas = value_3_44
    table_1.SnowKey2023 = table_2_104
    local table_2_105: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_45: string = "Exchange"
    table_2_105.ItemName = value_3_45
    local value_3_46: string = "http://www.roblox.com/asset/?id=6126024514"
    table_2_105.Image = value_3_46
    local value_3_47: string = "Common"
    table_2_105.Rarity = value_3_47
    local value_3_48: boolean = true
    table_2_105.Christmas = value_3_48
    table_1.CoinExchange = table_2_105
    local table_2_106: { Halloween: boolean, Image: string, ItemName: string, Rarity: string } = {
        ItemName = "Exchange",
        Image = "rbxassetid://112176937171925",
        Rarity = "Common",
        Halloween = true,
    }
    table_1.CandyExchange = table_2_106
    local table_2_107: { Image: string, ItemName: string, Rarity: string } = {
        ItemName = "100 Coins",
        Image = "rbxassetid://3150319038",
        Rarity = "Common",
    }
    table_1.CoinVisual = table_2_107
    local table_2_108: { Christmas: boolean?, Image: string?, ItemName: string?, Rarity: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_49: string = "Gift Box"
    table_2_108.ItemName = value_3_49
    local value_3_50: string = "http://www.roblox.com/asset/?id=15642266627"
    table_2_108.Image = value_3_50
    local value_3_51: string = "Common"
    table_2_108.Rarity = value_3_51
    local value_3_52: boolean = true
    table_2_108.Christmas = value_3_52
    table_1.GiftVisual = table_2_108
    local table_2_109: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_53: string = "Pumpkin Key"
    table_2_109.ItemName = value_3_53
    local value_3_54: string = "rbxassetid://11284124234"
    table_2_109.Image = value_3_54
    local value_3_55: string = "Halloween"
    table_2_109.Rarity = value_3_55
    local value_3_56: string = "Misc"
    table_2_109.ItemType = value_3_56
    local value_3_57: string = "Halloween"
    table_2_109.Event = value_3_57
    local value_3_58: string = "2022"
    table_2_109.Year = value_3_58
    table_1.HalloweenKey2022 = table_2_109
    local table_2_110: { Image: string, ItemName: string, ItemType: string, Rarity: string } = {
        ItemName = "Knife Crown",
        Image = "rbxassetid://11548017689",
        Rarity = "Common",
        ItemType = "Misc",
    }
    table_1.KnifeCrown = table_2_110
    local table_2_111: { Image: string, Name: string, Rarity: string } = {
        Name = "Heart",
        Image = "rbxassetid://12339309125",
        Rarity = "Common",
    }
    table_1.Hearts2023 = table_2_111
    local table_2_112: { Image: string, Name: string, Rarity: string } = {
        Name = "Egg",
        Image = "http://www.roblox.com/asset/?id=12966771924",
        Rarity = "Common",
    }
    table_1.Eggs2023 = table_2_112
    local table_2_113: { Image: string, Name: string, Rarity: string } = {
        Name = "Fragile Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964954883",
        Rarity = "Common",
    }
    table_1.FragileEgg = table_2_113
    local table_2_114: { Image: string, Name: string, Rarity: string } = {
        Name = "Marble Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964929254",
        Rarity = "Uncommon",
    }
    table_1.MarbleEgg = table_2_114
    local table_2_115: { Image: string, Name: string, Rarity: string } = {
        Name = "Hospital Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964905145",
        Rarity = "Rare",
    }
    table_1.HospitalEgg = table_2_115
    local table_2_116: { Image: string, Name: string, Rarity: string } = {
        Name = "Office Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964888920",
        Rarity = "Legendary",
    }
    table_1.OfficeEgg = table_2_116
    local table_2_117: { Image: string, Name: string, Rarity: string } = {
        Name = "Tech Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964951524",
        Rarity = "Common",
    }
    table_1.TechEgg = table_2_117
    local table_2_118: { Image: string, Name: string, Rarity: string } = {
        Name = "Bank Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964908855",
        Rarity = "Uncommon",
    }
    table_1.BankEgg = table_2_118
    local table_2_119: { Image: string, Name: string, Rarity: string } = {
        Name = "Bio Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964938900",
        Rarity = "Rare",
    }
    table_1.BioEgg = table_2_119
    local table_2_120: { Image: string, Name: string, Rarity: string } = {
        Name = "Nuke Egg",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964900162",
        Rarity = "Legendary",
    }
    table_1.NukeEgg = table_2_120
    local table_2_121: { Image: string, Name: string, Rarity: string } = {
        Name = "Dev Egg (JD)",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964850258",
        Rarity = "Common",
    }
    table_1.JDEgg = table_2_121
    local table_2_122: { Image: string, Name: string, Rarity: string } = {
        Name = "Dev Egg (IDHAU)",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964942611",
        Rarity = "Uncommon",
    }
    table_1.PurpleEgg = table_2_122
    local table_2_123: { Image: string, Name: string, Rarity: string } = {
        Name = "Dev Egg (Zyleak)",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964837119",
        Rarity = "Rare",
    }
    table_1.ZyleakEgg = table_2_123
    local table_2_124: { Image: string, Name: string, Rarity: string } = {
        Name = "Dev Egg (Nikilis)",
        Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=12964892968",
        Rarity = "Legendary",
    }
    table_1.NikEgg = table_2_124
    local table_2_125: { Image: string, Name: string, Rarity: string } = {
        Name = "Beachball",
        Image = "rbxassetid://13932988534",
        Rarity = "Common",
    }
    table_1.BeachBalls2023 = table_2_125
    local table_2_126: { Image: string, Name: string, Rarity: string } = {
        Name = "ERROR",
        Image = "http://www.roblox.com/asset/?id=12989389953",
        Rarity = "Common",
    }
    table_1.MissingInfo = table_2_126
    local table_2_127: { Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "http://www.roblox.com/asset/?id=15056209964",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Event = "Halloween",
        Year = "2023",
    }
    table_1.Candies2023 = table_2_127
    local table_2_128: { Event: string?, Image: string?, ItemName: string?, ItemType: string?, Rarity: string?, Year: string? } = {
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
        [("ItemName")] = nil,
    }
    local value_3_59: string = "Traveler Key"
    table_2_128.ItemName = value_3_59
    local value_3_60: string = "http://www.roblox.com/asset/?id=15080166389"
    table_2_128.Image = value_3_60
    local value_3_61: string = "Halloween"
    table_2_128.Rarity = value_3_61
    local value_3_62: string = "Misc"
    table_2_128.ItemType = value_3_62
    local value_3_63: string = "Halloween"
    table_2_128.Event = value_3_63
    local value_3_64: string = "2023"
    table_2_128.Year = value_3_64
    table_1.Halloween2023Key = table_2_128
    local table_2_129: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "800 Tokens",
        Image = "rbxassetid://15675642787",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_800 = table_2_129
    local table_2_130: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "3,200 Tokens",
        Image = "rbxassetid://15675647698",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_3200 = table_2_130
end
do
    local table_2_131: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "6,400 Tokens",
        Image = "rbxassetid://15675650148",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_6400 = table_2_131
    local table_2_132: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "14,280 Tokens",
        Image = "rbxassetid://15675658387",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_14280 = table_2_132
    local table_2_133: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "46,800 Tokens",
        Image = "rbxassetid://15675663446",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_46800 = table_2_133
    local table_2_134: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "116,000 Tokens",
        Image = "rbxassetid://15675668184",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_116000 = table_2_134
    local table_2_135: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "270,000 Tokens",
        Image = "rbxassetid://15675668184",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SnowTokens2024_270000 = table_2_135
    local table_2_136: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Camo Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_65: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948136021
    table_2_136.Image = value_3_65
    table_1.CamoEgg2024 = table_2_136
    local table_2_137: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Cash Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_66: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948135301
    table_2_137.Image = value_3_66
    table_1.CashEgg2024 = table_2_137
    local table_2_138: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Computer Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_67: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948134283
    table_2_138.Image = value_3_67
    table_1.ComputerEgg2024 = table_2_138
    local table_2_139: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Fireplace Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_68: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948132958
    table_2_139.Image = value_3_68
    table_1.FireplaceEgg2024 = table_2_139
    local table_2_140: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Matrix Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_69: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948131620
    table_2_140.Image = value_3_69
    table_1.MatrixEgg2024 = table_2_140
    local table_2_141: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Medic Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_70: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948130380
    table_2_141.Image = value_3_70
    table_1.MedicEgg2024 = table_2_141
    local table_2_142: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Painting Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_71: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948129220
    table_2_142.Image = value_3_71
    table_1.PaintingEgg2024 = table_2_142
    local table_2_143: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Robot Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_72: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948127002
    table_2_143.Image = value_3_72
    table_1.RobotEgg2024 = table_2_143
    local table_2_144: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Suit Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_73: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948124473
    table_2_144.Image = value_3_73
    table_1.SuitEgg2024 = table_2_144
    local table_2_145: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Worker Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_74: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 16948122832
    table_2_145.Image = value_3_74
    table_1.WorkerEgg2024 = table_2_145
    local table_2_146: { Image: string, Name: string, Rarity: string } = {
        Name = "Egg",
        Image = "http://www.roblox.com/asset/?id=12966771924",
        Rarity = "Common",
    }
    table_1.Eggs2024 = table_2_146
    local table_2_147: { Image: string, Name: string, Rarity: string } = {
        Name = "Egg",
        Image = "http://www.roblox.com/asset/?id=93997606516273",
        Rarity = "Common",
    }
    table_1.Eggs2025 = table_2_147
    local table_2_148: { Image: string, Name: string, Rarity: string } = {
        Name = "Egg",
        Image = "http://www.roblox.com/asset/?id=12966771924",
        Rarity = "Common",
    }
    table_1.RareEggs2025 = table_2_148
    local table_2_149: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Speedy Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_75: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 131944552875874
    table_2_149.Image = value_3_75
    table_1.SpeedyEgg2025 = table_2_149
    local table_2_150: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Scientist Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_76: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 73906746537574
    table_2_150.Image = value_3_76
    table_1.ScientistEgg2025 = table_2_150
    local table_2_151: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Robot Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_77: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 121415445121445
    table_2_151.Image = value_3_77
    table_1.RobotEgg2025 = table_2_151
    local table_2_152: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Police Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_78: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 140148355441434
    table_2_152.Image = value_3_78
    table_1.PoliceEgg2025 = table_2_152
    local table_2_153: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Diamond Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_79: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 92020867772179
    table_2_153.Image = value_3_79
    table_1.DiamondEgg2025 = table_2_153
    local table_2_154: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Construction Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_80: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 97077712100542
    table_2_154.Image = value_3_80
    table_1.ConstructionEgg2025 = table_2_154
    local table_2_155: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Office Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_81: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 103515261666490
    table_2_155.Image = value_3_81
    table_1.OfficeEgg2025 = table_2_155
    local table_2_156: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Military Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_82: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 136606257744446
    table_2_156.Image = value_3_82
    table_1.MilitaryEgg2025 = table_2_156
    local table_2_157: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Doctor Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_83: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 89515235634625
    table_2_157.Image = value_3_83
    table_1.DoctorEgg2025 = table_2_157
    local table_2_158: { Image: number | string, Name: string, Rarity: string } = {
        Name = "Experiment Egg",
        Image = 0,
        Rarity = "Rare",
    }
    local value_3_84: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. 96416982610081
    table_2_158.Image = value_3_84
    table_1.ExperimentEgg2025 = table_2_158
    local table_2_159: { Image: string, Name: string, Rarity: string } = {
        Name = "Beachball",
        Image = "rbxassetid://13932988534",
        Rarity = "Common",
    }
    table_1.BeachBalls2024 = table_2_159
    local table_2_160: { Image: string, Name: string, Rarity: string } = {
        Name = "Beachball",
        Image = "rbxassetid://13932988534",
        Rarity = "Common",
    }
    table_1.BeachBalls2024_Box = table_2_160
    local table_2_161: { Image: string, Name: string, Rarity: string } = {
        Name = "Summer Key",
        Image = "rbxassetid://18346996267",
        Rarity = "Common",
    }
    table_1.SummerKey2024 = table_2_161
    local table_2_162: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "1x Key",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_1 = table_2_162
    local table_2_163: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "4x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_4 = table_2_163
    local table_2_164: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "8x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_8 = table_2_164
    local table_2_165: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "20x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_20 = table_2_165
    local table_2_166: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "60x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_60 = table_2_166
    local table_2_167: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "150x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_150 = table_2_167
    local table_2_168: { Image: string, ItemType: string, Name: string, Rarity: string } = {
        Name = "360x Keys",
        Image = "rbxassetid://18346996267",
        ItemType = "Misc",
        Rarity = "Common",
    }
    table_1.SummerKey2024_360 = table_2_168
    local table_2_169: { Image: string, Name: string, Rarity: string } = {
        Name = "Error",
        Image = "rbxassetid://12989389953",
        Rarity = "Common",
    }
    table_1.ErrorItem = table_2_169
    local table_2_170: { Currency: boolean, Event: string, Halloween: boolean, Image: string, ItemType: string, Name: string, Rarity: string, Year: string } = {
        Name = "Candies",
        Image = "http://www.roblox.com/asset/?id=137794285751344",
        ItemType = "Misc",
        Rarity = "Common",
        Halloween = true,
        Currency = true,
        Event = "Halloween",
        Year = "2024",
    }
    table_1.Candies2024 = table_2_170
    local table_2_171: { Currency: boolean?, Event: string?, Image: string?, ItemType: string?, Name: string?, Rarity: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_85: string = "Vampire Key"
    table_2_171.Name = value_3_85
    local value_3_86: string = "http://www.roblox.com/asset/?id=103021827564795"
    table_2_171.Image = value_3_86
    local value_3_87: string = "Common"
    table_2_171.Rarity = value_3_87
    local value_3_88: string = "Misc"
    table_2_171.ItemType = value_3_88
    local value_3_89: boolean = true
    table_2_171.Currency = value_3_89
    local value_3_90: string = "Halloween"
    table_2_171.Event = value_3_90
    local value_3_91: string = "2024"
    table_2_171.Year = value_3_91
    table_1.VampireKey2024 = table_2_171
end
do
    local table_2_172: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
        Currency = true,
    }
    table_1.SnowTokens2024 = table_2_172
    local table_2_173: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Key",
        Image = "rbxassetid://15625795123",
        Rarity = "Common",
        Christmas = true,
        Currency = true,
    }
    table_1.SnowKey2024 = table_2_173
    local table_2_174: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Tokens",
        Image = "rbxassetid://4521639303",
        Rarity = "Common",
        Christmas = true,
        Currency = true,
    }
    table_1.SnowTokens2025 = table_2_174
    local table_2_175: { Christmas: boolean, Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Snow Key",
        Image = "rbxassetid://15625795123",
        Rarity = "Common",
        Christmas = true,
        Currency = true,
    }
    table_1.SnowKey2025 = table_2_175
    local table_2_176: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Beachball",
        Image = "rbxassetid://13932988534",
        Rarity = "Common",
        Currency = true,
    }
    table_1.BeachBalls2025 = table_2_176
    local table_2_177: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Summer Key",
        Image = "rbxassetid://134240302664368",
        Rarity = "Common",
        Currency = true,
    }
    table_1.SummerKey2025 = table_2_177
    local table_2_178: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Candies",
        Image = "rbxassetid://112176937171925",
        Rarity = "Common",
        Currency = true,
    }
    table_1.Candies2025 = table_2_178
    local table_2_179: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Alien Key",
        Image = "rbxassetid://96672799519702",
        Rarity = "Common",
        Currency = true,
    }
    table_1.HalloweenKey2025 = table_2_179
    local table_2_180: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Heart Gem",
        Image = "rbxassetid://71517024647654",
        Rarity = "Common",
        Currency = true,
    }
    table_1.ValentinesKey2026 = table_2_180
    local table_2_181: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Shells",
        Image = "rbxassetid://126508703036392",
        Rarity = "Common",
        Currency = true,
    }
    table_1.SummerKey2026 = table_2_181
    local table_2_182: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Candies",
        Image = "rbxassetid://127192865191352",
        Rarity = "Common",
        Currency = true,
    }
    table_1.Candies2026 = table_2_182
    local table_2_183: { Currency: boolean, Image: string, Name: string, Rarity: string } = {
        Name = "Halloween Key",
        Image = "rbxassetid://129332919886886",
        Rarity = "Common",
        Currency = true,
    }
    table_1.HalloweenKey2026 = table_2_183
end

return table_1
