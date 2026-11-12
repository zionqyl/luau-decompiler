--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Abduction2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Aquatic2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Arctic2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Aurora2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Aurora2024: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Bats: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Bats2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Bats2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Bitsplosion: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Blizzard: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Bloom2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    BlueFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    Bokeh2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Bubbly26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Burn: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Candies: nil | { Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    CandyCane: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    CandyEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    CandyEffect2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    Carrots2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Cats2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Chilly2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Coal2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    CommonOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? },
    Confetti2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Cursed2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Darkfire: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Darkswirl: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    Doge: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Dual: nil | { Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    EasterGlow2023: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Electric: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    Elitify: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Ethereal: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Fireworks2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    FlamingoEffect2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Floral2023: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Flowers2024: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Flowerwood: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Frost2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    FrostbiteEffect: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Frostfire2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    GearStorm: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Ghostify: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Ghosts2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Ghosts2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    Ghosts2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Gifts2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    GingerbreadEffect: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Glisten2024: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?,
    Glowy2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    GreenFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    HallowsBlaze: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Heartify: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Hearts26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Heatwave2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    IceMagic: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Jellyfish2024: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?,
    Jingle2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Knifeception: nil | { Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    Leaves2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    LegendaryOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? },
    Lights2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Matrix2024: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Minty2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Money: nil | { DeathModule: number, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? },
    Musical: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Nightlife26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Nightsky2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    NorthernLights: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    Ocean26: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Petals: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? },
    Phantom: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    PhantomEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    PinkFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? },
    PlasmaEffect: nil | { Description: string, Image: string, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? },
    Poison: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Pumpkin: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Pumpkin2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Radioactive: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? },
    Rainbow: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    RainbowEffect: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? },
    Rainbows2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    RareOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? },
    Retro2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Snowballs2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Snowfall2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Snowflake2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Snowflakes: nil | { ChristmasDescription: string, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Snowflakes2: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Snowstorm2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Snowstorm2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Starry2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Starry2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Stars2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    StickersX2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Strawberries26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Sunbeams2024: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?,
    SweetEffect26: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
    Swirls2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    SynthEffect2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    Toxic2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    Traveler2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? },
    Treats2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    UFOs2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    UncommonOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? },
    Vampire2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Vampiric2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    VersusEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? },
    VoidRbxEffect: nil | { Description: string, Image: string, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? },
    Water2023: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? },
    Wraith2024: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?,
    Wraithfire: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    Wrapper: nil | { ChristmasDescription: string, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? },
    XenoEffect: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?,
    XmasGlow2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?,
}

local table_1: { Abduction2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Aquatic2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Arctic2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Aurora2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Aurora2024: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Bats: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Bats2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Bats2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Bitsplosion: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Blizzard: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Bloom2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, BlueFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, Bokeh2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Bubbly26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Burn: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Candies: nil | { Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, CandyCane: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, CandyEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, CandyEffect2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, Carrots2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Cats2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Chilly2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Coal2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, CommonOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? }, Confetti2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Cursed2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Darkfire: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Darkswirl: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, Doge: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Dual: nil | { Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, EasterGlow2023: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Electric: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, Elitify: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Ethereal: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Fireworks2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, FlamingoEffect2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Floral2023: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Flowers2024: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Flowerwood: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Frost2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?, FrostbiteEffect: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Frostfire2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, GearStorm: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Ghostify: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Ghosts2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Ghosts2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, Ghosts2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Gifts2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, GingerbreadEffect: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Glisten2024: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?, Glowy2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, GreenFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, HallowsBlaze: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Heartify: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Hearts26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Heatwave2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, IceMagic: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Jellyfish2024: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?, Jingle2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Knifeception: nil | { Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, Leaves2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, LegendaryOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? }, Lights2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Matrix2024: nil | { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Minty2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Money: nil | { DeathModule: number, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? }, Musical: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Nightlife26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Nightsky2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?, NorthernLights: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, Ocean26: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Petals: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? }, Phantom: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, PhantomEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, PinkFire: nil | { DeathModule: number, Description: string, Gems: boolean, Image: string, KnifeModule: number, Name: string, Price: number, Rarity: string, Type: string } | { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? }, PlasmaEffect: nil | { Description: string, Image: string, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? }, Poison: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Pumpkin: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Pumpkin2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Radioactive: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: number, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? }, Rainbow: nil | { DeathModule: number, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, RainbowEffect: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? }, Rainbows2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, RareOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? }, Retro2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Snowballs2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Snowfall2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Snowflake2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Snowflakes: nil | { ChristmasDescription: string, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Snowflakes2: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Snowstorm2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Snowstorm2025: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Starry2021: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Starry2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Stars2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, StickersX2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Strawberries26: { Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Sunbeams2024: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?, SweetEffect26: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string }?, Swirls2023: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, SynthEffect2025: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, Toxic2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, Traveler2023: nil | { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } | { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? }, Treats2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, UFOs2025: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, UncommonOrnamentEffect: nil | { ChristmasDescription: string, Description: string, Event: string, Image: string, KnifeModule: number, Name: string, Price: string, Rarity: string, SortGroup: number, SortWithinGroup: number, Type: string, Year: string } | { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? }, Vampire2020: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Vampiric2024: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, VersusEffect2022: nil | { Description: string, Event: string, Image: string, Name: string, Price: string, Type: string, Year: string } | { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? }, VoidRbxEffect: nil | { Description: string, Image: string, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? }, Water2023: nil | { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } | { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? }, Wraith2024: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string }?, Wraithfire: nil | { Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, Wrapper: nil | { ChristmasDescription: string, Description: string, Image: string, KnifeModule: number, Name: string, Price: string, Type: string } | { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? }, XenoEffect: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string }?, XmasGlow2025: { Description: string, Image: string, Name: string, Rarity: string, Type: string }? } = {
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
    [("Burn")] = nil,
}
do
    local table_2: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3: string = "Flaming Knife"
    table_2.Name = value_3
    local value_3_2: string = "Set your knife on fire and burn your enemies!"
    table_2.Description = value_3_2
    local value_3_3: string = "https://www.roblox.com/asset/?id=387182858"
    table_2.Image = value_3_3
    local value_3_4: number = 473580488
    table_2.KnifeModule = value_3_4
    local value_3_5: number = 4637958662
    table_2.DeathModule = value_3_5
    local value_3_6: string = "Weapon Effect"
    table_2.Type = value_3_6
    local value_3_7: number = 1000
    table_2.Price = value_3_7
    table_1.Burn = table_2
    local table_2_2: { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
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
    local value_3_8: string = "Blue Flaming Knife"
    table_2_2.Name = value_3_8
    local value_3_9: string = "Set your knife on (blue) fire and burn your enemies!"
    table_2_2.Description = value_3_9
    local value_3_10: string = "https://www.roblox.com/asset/?id=387182852"
    table_2_2.Image = value_3_10
    local value_3_11: number = 473588389
    table_2_2.KnifeModule = value_3_11
    local value_3_12: number = 4637963590
    table_2_2.DeathModule = value_3_12
    local value_3_13: string = "Weapon Effect"
    table_2_2.Type = value_3_13
    local value_3_14: number = 800
    table_2_2.Price = value_3_14
    local value_3_15: boolean = true
    table_2_2.Gems = value_3_15
    local value_3_16: string = "Rare"
    table_2_2.Rarity = value_3_16
    table_1.BlueFire = table_2_2
    local table_2_3: { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_17: string = "Knifeception"
    table_2_3.Name = value_3_17
    local value_3_18: string = "Your knife spawns mini knives! Changes based on your equipped knife."
    table_2_3.Description = value_3_18
    local value_3_19: string = "https://www.roblox.com/asset/?id=418207962"
    table_2_3.Image = value_3_19
    local value_3_20: number = 418205295
    table_2_3.KnifeModule = value_3_20
    local value_3_21: string = "Weapon Effect"
    table_2_3.Type = value_3_21
    local value_3_22: number = 300
    table_2_3.Price = value_3_22
    local value_3_23: boolean = true
    table_2_3.Gems = value_3_23
    local value_3_24: string = "Uncommon"
    table_2_3.Rarity = value_3_24
    table_1.Knifeception = table_2_3
    local table_2_4: { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
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
    local value_3_25: string = "Pink Flaming Knife"
    table_2_4.Name = value_3_25
    local value_3_26: string = "Set your knife on (pink) fire and burn your enemies!"
    table_2_4.Description = value_3_26
    local value_3_27: string = "https://www.roblox.com/asset/?id=387182855"
    table_2_4.Image = value_3_27
    local value_3_28: number = 473588247
    table_2_4.KnifeModule = value_3_28
    local value_3_29: number = 4990779867
    table_2_4.DeathModule = value_3_29
    local value_3_30: string = "Weapon Effect"
    table_2_4.Type = value_3_30
    local value_3_31: number = 800
    table_2_4.Price = value_3_31
    local value_3_32: boolean = true
    table_2_4.Gems = value_3_32
    local value_3_33: string = "Rare"
    table_2_4.Rarity = value_3_33
    table_1.PinkFire = table_2_4
    local table_2_5: { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
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
    local value_3_34: string = "Green Flaming Knife"
    table_2_5.Name = value_3_34
    local value_3_35: string = "Set your knife on (green) fire and burn your enemies!"
    table_2_5.Description = value_3_35
    local value_3_36: string = "https://www.roblox.com/asset/?id=387182851"
    table_2_5.Image = value_3_36
    local value_3_37: number = 473584519
    table_2_5.KnifeModule = value_3_37
    local value_3_38: number = 4990782476
    table_2_5.DeathModule = value_3_38
    local value_3_39: string = "Weapon Effect"
    table_2_5.Type = value_3_39
    local value_3_40: number = 800
    table_2_5.Price = value_3_40
    local value_3_41: boolean = true
    table_2_5.Gems = value_3_41
    local value_3_42: string = "Rare"
    table_2_5.Rarity = value_3_42
    table_1.GreenFire = table_2_5
    local table_2_6: { DeathModule: number?, Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
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
    local value_3_43: string = "Electric Knife"
    table_2_6.Name = value_3_43
    local value_3_44: string = "Zap your enemies and turn them into skeletons!"
    table_2_6.Description = value_3_44
    local value_3_45: string = "rbxassetid://84403276762632"
    table_2_6.Image = value_3_45
    local value_3_46: number = 236756675
    table_2_6.KnifeModule = value_3_46
    local value_3_47: number = 4980680584
    table_2_6.DeathModule = value_3_47
    local value_3_48: string = "Weapon Effect"
    table_2_6.Type = value_3_48
    local value_3_49: boolean = true
    table_2_6.Gems = value_3_49
    local value_3_50: number = 1000
    table_2_6.Price = value_3_50
    local value_3_51: string = "Legendary"
    table_2_6.Rarity = value_3_51
    table_1.Electric = table_2_6
    local table_2_7: { Description: string?, Gems: boolean?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_52: string = "Dual Wield"
    table_2_7.Name = value_3_52
    local value_3_53: string = "Dual wield your current knife!"
    table_2_7.Description = value_3_53
    local value_3_54: string = "rbxassetid://97094623567626"
    table_2_7.Image = value_3_54
    local value_3_55: number = 3187377961
    table_2_7.KnifeModule = value_3_55
    local value_3_56: string = "Weapon Effect"
    table_2_7.Type = value_3_56
    local value_3_57: number = 900
    table_2_7.Price = value_3_57
    local value_3_58: boolean = true
    table_2_7.Gems = value_3_58
    local value_3_59: string = "Legendary"
    table_2_7.Rarity = value_3_59
    table_1.Dual = table_2_7
end
do
    local table_2_8: { DeathModule: number?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_60: string = "Monify"
    table_2_8.Name = value_3_60
    local value_3_61: string = "Turn your victims into money!"
    table_2_8.Description = value_3_61
    local value_3_62: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=238446940"
    table_2_8.Image = value_3_62
    local value_3_63: number = 238446032
    table_2_8.DeathModule = value_3_63
    local value_3_64: string = "Weapon Effect"
    table_2_8.Type = value_3_64
    local value_3_65: string = "NotForSale"
    table_2_8.Price = value_3_65
    table_1.Money = table_2_8
    local table_2_9: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_66: string = "Doge"
    table_2_9.Name = value_3_66
    local value_3_67: string = "Dogefy your knife and victims!"
    table_2_9.Description = value_3_67
    local value_3_68: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=345179425"
    table_2_9.Image = value_3_68
    local value_3_69: number = 473615608
    table_2_9.KnifeModule = value_3_69
    local value_3_70: number = 345183062
    table_2_9.DeathModule = value_3_70
    local value_3_71: string = "Weapon Effect"
    table_2_9.Type = value_3_71
    local value_3_72: number = 500
    table_2_9.Price = value_3_72
    table_1.Doge = table_2_9
    local table_2_10: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_73: string = "Ghostify"
    table_2_10.Name = value_3_73
    local value_3_74: string = "Give your knife a ghostly effect, and turn your victims into ghosts!"
    table_2_10.Description = value_3_74
    local value_3_75: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=415915771"
    table_2_10.Image = value_3_75
    local value_3_76: number = 415986236
    table_2_10.KnifeModule = value_3_76
    local value_3_77: string = "Weapon Effect"
    table_2_10.Type = value_3_77
    local value_3_78: number = 500
    table_2_10.Price = value_3_78
    table_1.Ghostify = table_2_10
    local table_2_11: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_79: string = "Heartify"
    table_2_11.Name = value_3_79
    local value_3_80: string = "Heartify your knife and give your victims hearteyes."
    table_2_11.Description = value_3_80
    local value_3_81: string = "https://www.roblox.com/asset/?id=416769271"
    table_2_11.Image = value_3_81
    local value_3_82: number = 416763313
    table_2_11.KnifeModule = value_3_82
    local value_3_83: number = 416764727
    table_2_11.DeathModule = value_3_83
    local value_3_84: string = "Weapon Effect"
    table_2_11.Type = value_3_84
    local value_3_85: number = 600
    table_2_11.Price = value_3_85
    table_1.Heartify = table_2_11
    local table_2_12: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_86: string = "Radioactive"
    table_2_12.Name = value_3_86
    local value_3_87: string = "Give your knife a radioactive effect and turn your victims green."
    table_2_12.Description = value_3_87
    local value_3_88: string = "https://www.roblox.com/asset/?id=416805902"
    table_2_12.Image = value_3_88
    local value_3_89: number = 416783301
    table_2_12.KnifeModule = value_3_89
    local value_3_90: number = 4655600391
    table_2_12.DeathModule = value_3_90
    local value_3_91: string = "Weapon Effect"
    table_2_12.Type = value_3_91
    local value_3_92: number = 400
    table_2_12.Price = value_3_92
    table_1.Radioactive = table_2_12
    local table_2_13: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: number?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_93: string = "Musical"
    table_2_13.Name = value_3_93
    local value_3_94: string = "Give your knife a musical effect. No kill effect."
    table_2_13.Description = value_3_94
    local value_3_95: string = "https://www.roblox.com/asset/?id=416811723"
    table_2_13.Image = value_3_95
    local value_3_96: number = 416781734
    table_2_13.KnifeModule = value_3_96
    local value_3_97: string = "Weapon Effect"
    table_2_13.Type = value_3_97
    local value_3_98: number = 400
    table_2_13.Price = value_3_98
    table_1.Musical = table_2_13
    local table_2_14: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_99: string = "Elite-ify"
    table_2_14.Name = value_3_99
    local value_3_100: string = "Elite-ify your knife and victims!"
    table_2_14.Description = value_3_100
    local value_3_101: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=346681501"
    table_2_14.Image = value_3_101
    local value_3_102: number = 6683030640
    table_2_14.KnifeModule = value_3_102
    local value_3_103: number = 4790797585
    table_2_14.DeathModule = value_3_103
    local value_3_104: string = "Weapon Effect"
    table_2_14.Type = value_3_104
    local value_3_105: string = "Elite"
    table_2_14.Price = value_3_105
    local value_3_106: string = "Legendary"
    table_2_14.Rarity = value_3_106
    table_1.Elitify = table_2_14
    local table_2_15: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_107: string = "Gear Storm"
    table_2_15.Name = value_3_107
    local value_3_108: string = "Unleash the Gear Storm on your enemies!"
    table_2_15.Description = value_3_108
    local value_3_109: string = "https://www.roblox.com/asset/?id=360666852"
    table_2_15.Image = value_3_109
    local value_3_110: number = 360643995
    table_2_15.KnifeModule = value_3_110
    local value_3_111: number = 360661346
    table_2_15.DeathModule = value_3_111
    local value_3_112: string = "Weapon Effect"
    table_2_15.Type = value_3_112
    local value_3_113: string = "NotForSale"
    table_2_15.Price = value_3_113
    table_1.GearStorm = table_2_15
    local table_2_16: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_114: string = "Bitsplosion"
    table_2_16.Name = value_3_114
    local value_3_115: string = "Make your enemies pixplode!"
    table_2_16.Description = value_3_115
    local value_3_116: string = "https://www.roblox.com/asset/?id=365367041"
    table_2_16.Image = value_3_116
    local value_3_117: number = 365361025
    table_2_16.KnifeModule = value_3_117
    local value_3_118: number = 365366023
    table_2_16.DeathModule = value_3_118
    local value_3_119: string = "Weapon Effect"
    table_2_16.Type = value_3_119
    local value_3_120: string = "NotForSale"
    table_2_16.Price = value_3_120
    table_1.Bitsplosion = table_2_16
end
do
    local table_2_17: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_121: string = "Darkfire"
    table_2_17.Name = value_3_121
    local value_3_122: string = "Engulf your enemies in the flames of darkness."
    table_2_17.Description = value_3_122
    local value_3_123: string = "https://www.roblox.com/asset/?id=475504088"
    table_2_17.Image = value_3_123
    local value_3_124: number = 475501891
    table_2_17.KnifeModule = value_3_124
    local value_3_125: number = 4990800308
    table_2_17.DeathModule = value_3_125
    local value_3_126: string = "Weapon Effect"
    table_2_17.Type = value_3_126
    local value_3_127: string = "NotForSale"
    table_2_17.Price = value_3_127
    table_1.Darkfire = table_2_17
    local table_2_18: { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_128: string = "Snowflakes"
    table_2_18.Name = value_3_128
    local value_3_129: string = ""
    table_2_18.Description = value_3_129
    local value_3_130: string = "rbxassetid://585820804"
    table_2_18.Image = value_3_130
    local value_3_131: number = 585745475
    table_2_18.KnifeModule = value_3_131
    local value_3_132: string = "Weapon Effect"
    table_2_18.Type = value_3_132
    local value_3_133: string = "NotForSale"
    table_2_18.Price = value_3_133
    local value_3_134: string = "Effect"
    table_2_18.ChristmasDescription = value_3_134
    table_1.Snowflakes = table_2_18
    local table_2_19: { DeathModule: number?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_135: string = "Rainbow Fire"
    table_2_19.Name = value_3_135
    local value_3_136: string = ""
    table_2_19.Description = value_3_136
    local value_3_137: string = "https://www.roblox.com/asset/?id=619571884"
    table_2_19.Image = value_3_137
    local value_3_138: number = 619498724
    table_2_19.KnifeModule = value_3_138
    local value_3_139: number = 4990794941
    table_2_19.DeathModule = value_3_139
    local value_3_140: string = "Weapon Effect"
    table_2_19.Type = value_3_140
    local value_3_141: string = "NotForSale"
    table_2_19.Price = value_3_141
    table_1.Rainbow = table_2_19
    local table_2_20: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_142: string = "Pumpkin"
    table_2_20.Name = value_3_142
    local value_3_143: string = ""
    table_2_20.Description = value_3_143
    local value_3_144: string = "rbxassetid://314773056"
    table_2_20.Image = value_3_144
    local value_3_145: number = 1133104075
    table_2_20.KnifeModule = value_3_145
    local value_3_146: string = "Weapon Effect"
    table_2_20.Type = value_3_146
    local value_3_147: string = "NotForSale"
    table_2_20.Price = value_3_147
    table_1.Pumpkin = table_2_20
    local table_2_21: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_148: string = "Bats"
    table_2_21.Name = value_3_148
    local value_3_149: string = ""
    table_2_21.Description = value_3_149
    local value_3_150: string = "rbxassetid://1133201412"
    table_2_21.Image = value_3_150
    local value_3_151: number = 1133166797
    table_2_21.KnifeModule = value_3_151
    local value_3_152: string = "Weapon Effect"
    table_2_21.Type = value_3_152
    local value_3_153: string = "NotForSale"
    table_2_21.Price = value_3_153
    table_1.Bats = table_2_21
    local table_2_22: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_154: string = "Blizzard"
    table_2_22.Name = value_3_154
    local value_3_155: string = ""
    table_2_22.Description = value_3_155
    local value_3_156: string = "rbxassetid://1268823483"
    table_2_22.Image = value_3_156
    local value_3_157: number = 1268954397
    table_2_22.KnifeModule = value_3_157
    local value_3_158: string = "Weapon Effect"
    table_2_22.Type = value_3_158
    local value_3_159: string = "NotForSale"
    table_2_22.Price = value_3_159
    table_1.Blizzard = table_2_22
    local table_2_23: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_160: string = "Gingerbread"
    table_2_23.Name = value_3_160
    local value_3_161: string = "Turn your enemies into a Gingerbread man :-)"
    table_2_23.Description = value_3_161
    local value_3_162: string = "rbxassetid://1268961701"
    table_2_23.Image = value_3_162
    local value_3_163: number = 1271394822
    table_2_23.KnifeModule = value_3_163
    local value_3_164: string = "Weapon Effect"
    table_2_23.Type = value_3_164
    local value_3_165: string = "NotForSale"
    table_2_23.Price = value_3_165
    table_1.GingerbreadEffect = table_2_23
    local table_2_24: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_166: string = "Candy Cane"
    table_2_24.Name = value_3_166
    local value_3_167: string = "Candy Cane-ify your knife."
    table_2_24.Description = value_3_167
    local value_3_168: string = "rbxassetid://1268961700"
    table_2_24.Image = value_3_168
    local value_3_169: number = 1268971460
    table_2_24.KnifeModule = value_3_169
    local value_3_170: string = "Weapon Effect"
    table_2_24.Type = value_3_170
    local value_3_171: string = "NotForSale"
    table_2_24.Price = value_3_171
    table_1.CandyCane = table_2_24
    local table_2_25: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_172: string = "Snowflakes 2017"
    table_2_25.Name = value_3_172
    local value_3_173: string = "Snowflakes fall from your knife."
    table_2_25.Description = value_3_173
    local value_3_174: string = "rbxassetid://1268961698"
    table_2_25.Image = value_3_174
    local value_3_175: number = 1268981706
    table_2_25.KnifeModule = value_3_175
    local value_3_176: string = "Weapon Effect"
    table_2_25.Type = value_3_176
    local value_3_177: string = "NotForSale"
    table_2_25.Price = value_3_177
    table_1.Snowflakes2 = table_2_25
end
do
    local table_2_26: { ChristmasDescription: string?, Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_178: string = "Knife Wrapper"
    table_2_26.Name = value_3_178
    local value_3_179: string = "Wrap whatever knife you have equipped! (Works best with Godlies)"
    table_2_26.Description = value_3_179
    local value_3_180: string = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=1269005469"
    table_2_26.Image = value_3_180
    local value_3_181: number = 1269003110
    table_2_26.KnifeModule = value_3_181
    local value_3_182: string = "Weapon Effect"
    table_2_26.Type = value_3_182
    local value_3_183: string = "NotForSale"
    table_2_26.Price = value_3_183
    local value_3_184: string = "Effect: Wraps ANY knife in wrapping paper"
    table_2_26.ChristmasDescription = value_3_184
    table_1.Wrapper = table_2_26
    local table_2_27: { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_185: string = "Northern Lights"
    table_2_27.Name = value_3_185
    local value_3_186: string = ""
    table_2_27.Description = value_3_186
    local value_3_187: string = "rbxassetid://2674896415"
    table_2_27.Image = value_3_187
    local value_3_188: number = 2674802696
    table_2_27.KnifeModule = value_3_188
    local value_3_189: string = "Weapon Effect"
    table_2_27.Type = value_3_189
    local value_3_190: string = "NotForSale"
    table_2_27.Price = value_3_190
    local value_3_191: string = "Effect: Give your knife a Northern glow."
    table_2_27.ChristmasDescription = value_3_191
    local value_3_192: string = "Christmas"
    table_2_27.Rarity = value_3_192
    local value_3_193: string = "Christmas"
    table_2_27.Event = value_3_193
    local value_3_194: string = "2018"
    table_2_27.Year = value_3_194
    table_1.NorthernLights = table_2_27
    local table_2_28: { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? } = {
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
    local value_3_195: string = "Common Ornament"
    table_2_28.Name = value_3_195
    local value_3_196: string = ""
    table_2_28.Description = value_3_196
    local value_3_197: string = "rbxassetid://2674907874"
    table_2_28.Image = value_3_197
    local value_3_198: number = 2674901879
    table_2_28.KnifeModule = value_3_198
    local value_3_199: string = "Weapon Effect"
    table_2_28.Type = value_3_199
    local value_3_200: string = "NotForSale"
    table_2_28.Price = value_3_200
    local value_3_201: string = "Effect: Common Ornaments."
    table_2_28.ChristmasDescription = value_3_201
    local value_3_202: string = "Christmas"
    table_2_28.Rarity = value_3_202
    local value_3_203: string = "Christmas"
    table_2_28.Event = value_3_203
    local value_3_204: string = "2018"
    table_2_28.Year = value_3_204
    local value_3_205: number = 1
    table_2_28.SortGroup = value_3_205
    local value_3_206: number = 1
    table_2_28.SortWithinGroup = value_3_206
    table_1.CommonOrnamentEffect = table_2_28
    local table_2_29: { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? } = {
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
    local value_3_207: string = "Uncommon Ornament"
    table_2_29.Name = value_3_207
    local value_3_208: string = ""
    table_2_29.Description = value_3_208
    local value_3_209: string = "rbxassetid://2674907876"
    table_2_29.Image = value_3_209
    local value_3_210: number = 2674902160
    table_2_29.KnifeModule = value_3_210
    local value_3_211: string = "Weapon Effect"
    table_2_29.Type = value_3_211
    local value_3_212: string = "NotForSale"
    table_2_29.Price = value_3_212
    local value_3_213: string = "Effect: Uncommon Ornaments."
    table_2_29.ChristmasDescription = value_3_213
    local value_3_214: string = "Christmas"
    table_2_29.Rarity = value_3_214
    local value_3_215: string = "Christmas"
    table_2_29.Event = value_3_215
    local value_3_216: string = "2018"
    table_2_29.Year = value_3_216
    local value_3_217: number = 1
    table_2_29.SortGroup = value_3_217
    local value_3_218: number = 2
    table_2_29.SortWithinGroup = value_3_218
    table_1.UncommonOrnamentEffect = table_2_29
    local table_2_30: { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? } = {
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
    local value_3_219: string = "Rare Ornament"
    table_2_30.Name = value_3_219
    local value_3_220: string = ""
    table_2_30.Description = value_3_220
    local value_3_221: string = "rbxassetid://2674907875"
    table_2_30.Image = value_3_221
    local value_3_222: number = 2674902381
    table_2_30.KnifeModule = value_3_222
    local value_3_223: string = "Weapon Effect"
    table_2_30.Type = value_3_223
    local value_3_224: string = "NotForSale"
    table_2_30.Price = value_3_224
    local value_3_225: string = "Effect: Rare Ornaments"
    table_2_30.ChristmasDescription = value_3_225
    local value_3_226: string = "Christmas"
    table_2_30.Rarity = value_3_226
    local value_3_227: string = "Christmas"
    table_2_30.Event = value_3_227
    local value_3_228: string = "2018"
    table_2_30.Year = value_3_228
    local value_3_229: number = 1
    table_2_30.SortGroup = value_3_229
    local value_3_230: number = 3
    table_2_30.SortWithinGroup = value_3_230
    table_1.RareOrnamentEffect = table_2_30
    local table_2_31: { ChristmasDescription: string?, Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, SortGroup: number?, SortWithinGroup: number?, Type: string?, Year: string? } = {
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
    local value_3_231: string = "Legendary Ornament"
    table_2_31.Name = value_3_231
    local value_3_232: string = ""
    table_2_31.Description = value_3_232
    local value_3_233: string = "rbxassetid://2674907873"
    table_2_31.Image = value_3_233
    local value_3_234: number = 2674902613
    table_2_31.KnifeModule = value_3_234
    local value_3_235: string = "Weapon Effect"
    table_2_31.Type = value_3_235
    local value_3_236: string = "NotForSale"
    table_2_31.Price = value_3_236
    local value_3_237: string = "Effect: Legendary Ornaments"
    table_2_31.ChristmasDescription = value_3_237
    local value_3_238: string = "Christmas"
    table_2_31.Rarity = value_3_238
    local value_3_239: string = "Christmas"
    table_2_31.Event = value_3_239
    local value_3_240: string = "2018"
    table_2_31.Year = value_3_240
    local value_3_241: number = 1
    table_2_31.SortGroup = value_3_241
    local value_3_242: number = 4
    table_2_31.SortWithinGroup = value_3_242
    table_1.LegendaryOrnamentEffect = table_2_31
end
do
    local table_2_32: { Description: string?, Event: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_243: string = "Candies"
    table_2_32.Name = value_3_243
    local value_3_244: string = ""
    table_2_32.Description = value_3_244
    local value_3_245: string = "rbxassetid://4212945274"
    table_2_32.Image = value_3_245
    local value_3_246: number = 4212905086
    table_2_32.KnifeModule = value_3_246
    local value_3_247: string = "Common"
    table_2_32.Rarity = value_3_247
    local value_3_248: string = "Weapon Effect"
    table_2_32.Type = value_3_248
    local value_3_249: string = "NotForSale"
    table_2_32.Price = value_3_249
    local value_3_250: string = "Halloween"
    table_2_32.Event = value_3_250
    local value_3_251: string = "2019"
    table_2_32.Year = value_3_251
    table_1.Candies = table_2_32
    local table_2_33: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_252: string = "Poison"
    table_2_33.Name = value_3_252
    local value_3_253: string = ""
    table_2_33.Description = value_3_253
    local value_3_254: string = "http://www.roblox.com/asset/?id=4213585030"
    table_2_33.Image = value_3_254
    local value_3_255: number = 4213549951
    table_2_33.KnifeModule = value_3_255
    local value_3_256: string = "Common"
    table_2_33.Rarity = value_3_256
    local value_3_257: string = "Weapon Effect"
    table_2_33.Type = value_3_257
    local value_3_258: string = "NotForSale"
    table_2_33.Price = value_3_258
    table_1.Poison = table_2_33
    local table_2_34: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_259: string = "Ethereal"
    table_2_34.Name = value_3_259
    local value_3_260: string = ""
    table_2_34.Description = value_3_260
    local value_3_261: string = "http://www.roblox.com/asset/?id=4220305590"
    table_2_34.Image = value_3_261
    local value_3_262: number = 4218057644
    table_2_34.KnifeModule = value_3_262
    local value_3_263: string = "Weapon Effect"
    table_2_34.Type = value_3_263
    local value_3_264: string = "NotForSale"
    table_2_34.Price = value_3_264
    table_1.Ethereal = table_2_34
    local table_2_35: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_265: string = "Frostbite"
    table_2_35.Name = value_3_265
    local value_3_266: string = ""
    table_2_35.Description = value_3_266
    local value_3_267: string = "http://www.roblox.com/asset/?id=4528388893"
    table_2_35.Image = value_3_267
    local value_3_268: number = 4528531298
    table_2_35.KnifeModule = value_3_268
    local value_3_269: string = "Weapon Effect"
    table_2_35.Type = value_3_269
    local value_3_270: string = "NotForSale"
    table_2_35.Price = value_3_270
    table_1.FrostbiteEffect = table_2_35
    local table_2_36: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_271: string = "Ghosts"
    table_2_36.Name = value_3_271
    local value_3_272: string = ""
    table_2_36.Description = value_3_272
    local value_3_273: string = "http://www.roblox.com/asset/?id=5872809781"
    table_2_36.Image = value_3_273
    local value_3_274: number = 5872813336
    table_2_36.KnifeModule = value_3_274
    local value_3_275: string = "Weapon Effect"
    table_2_36.Type = value_3_275
    local value_3_276: string = "NotForSale"
    table_2_36.Price = value_3_276
    table_1.Ghosts2020 = table_2_36
    local table_2_37: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_277: string = "Vampire"
    table_2_37.Name = value_3_277
    local value_3_278: string = ""
    table_2_37.Description = value_3_278
    local value_3_279: string = "http://www.roblox.com/asset/?id=5873283412"
    table_2_37.Image = value_3_279
    local value_3_280: number = 5873247816
    table_2_37.KnifeModule = value_3_280
    local value_3_281: string = "Weapon Effect"
    table_2_37.Type = value_3_281
    local value_3_282: string = "NotForSale"
    table_2_37.Price = value_3_282
    table_1.Vampire2020 = table_2_37
    local table_2_38: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_283: string = "Hallow's Blaze"
    table_2_38.Name = value_3_283
    local value_3_284: string = ""
    table_2_38.Description = value_3_284
    local value_3_285: string = "http://www.roblox.com/asset/?id=5929776253"
    table_2_38.Image = value_3_285
    local value_3_286: number = 5929708803
    table_2_38.KnifeModule = value_3_286
    local value_3_287: string = "Weapon Effect"
    table_2_38.Type = value_3_287
    local value_3_288: string = "NotForSale"
    table_2_38.Price = value_3_288
    table_1.HallowsBlaze = table_2_38
    local table_2_39: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_289: string = "Batswarm"
    table_2_39.Name = value_3_289
    local value_3_290: string = ""
    table_2_39.Description = value_3_290
    local value_3_291: string = "http://www.roblox.com/asset/?id=5930489468"
    table_2_39.Image = value_3_291
    local value_3_292: number = 5930467637
    table_2_39.KnifeModule = value_3_292
    local value_3_293: string = "Weapon Effect"
    table_2_39.Type = value_3_293
    local value_3_294: string = "NotForSale"
    table_2_39.Price = value_3_294
    table_1.Bats2020 = table_2_39
    local table_2_40: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_295: string = "Jingle"
    table_2_40.Name = value_3_295
    local value_3_296: string = ""
    table_2_40.Description = value_3_296
    local value_3_297: string = "http://www.roblox.com/asset/?id=6123825971"
    table_2_40.Image = value_3_297
    local value_3_298: number = 6121731748
    table_2_40.KnifeModule = value_3_298
    local value_3_299: string = "Weapon Effect"
    table_2_40.Type = value_3_299
    local value_3_300: string = "NotForSale"
    table_2_40.Price = value_3_300
    table_1.Jingle2020 = table_2_40
end
do
    local table_2_41: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_301: string = "Snowfall"
    table_2_41.Name = value_3_301
    local value_3_302: string = ""
    table_2_41.Description = value_3_302
    local value_3_303: string = "http://www.roblox.com/asset/?id=6123847156"
    table_2_41.Image = value_3_303
    local value_3_304: number = 6121732998
    table_2_41.KnifeModule = value_3_304
    local value_3_305: string = "Weapon Effect"
    table_2_41.Type = value_3_305
    local value_3_306: string = "NotForSale"
    table_2_41.Price = value_3_306
    table_1.Snowfall2020 = table_2_41
    local table_2_42: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_307: string = "Frostfire"
    table_2_42.Name = value_3_307
    local value_3_308: string = ""
    table_2_42.Description = value_3_308
    local value_3_309: string = "http://www.roblox.com/asset/?id=6123881466"
    table_2_42.Image = value_3_309
    local value_3_310: number = 6121732310
    table_2_42.KnifeModule = value_3_310
    local value_3_311: string = "Weapon Effect"
    table_2_42.Type = value_3_311
    local value_3_312: string = "NotForSale"
    table_2_42.Price = value_3_312
    table_1.Frostfire2020 = table_2_42
    local table_2_43: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_313: string = "Wraithfire"
    table_2_43.Name = value_3_313
    local value_3_314: string = ""
    table_2_43.Description = value_3_314
    local value_3_315: string = "http://www.roblox.com/asset/?id=7808309031"
    table_2_43.Image = value_3_315
    local value_3_316: number = 7808254268
    table_2_43.KnifeModule = value_3_316
    local value_3_317: string = "Weapon Effect"
    table_2_43.Type = value_3_317
    local value_3_318: string = "NotForSale"
    table_2_43.Price = value_3_318
    table_1.Wraithfire = table_2_43
    local table_2_44: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_319: string = "Phantom"
    table_2_44.Name = value_3_319
    local value_3_320: string = ""
    table_2_44.Description = value_3_320
    local value_3_321: string = "http://www.roblox.com/asset/?id=7808308565"
    table_2_44.Image = value_3_321
    local value_3_322: number = 7808251026
    table_2_44.KnifeModule = value_3_322
    local value_3_323: string = "Weapon Effect"
    table_2_44.Type = value_3_323
    local value_3_324: string = "NotForSale"
    table_2_44.Price = value_3_324
    table_1.Phantom = table_2_44
    local table_2_45: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_325: string = "Aurora"
    table_2_45.Name = value_3_325
    local value_3_326: string = ""
    table_2_45.Description = value_3_326
    local value_3_327: string = "http://www.roblox.com/asset/?id=8304833301"
    table_2_45.Image = value_3_327
    local value_3_328: number = 8305208942
    table_2_45.KnifeModule = value_3_328
    local value_3_329: string = "Weapon Effect"
    table_2_45.Type = value_3_329
    local value_3_330: string = "NotForSale"
    table_2_45.Price = value_3_330
    table_1.Aurora2021 = table_2_45
    local table_2_46: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_331: string = "Ice Magic"
    table_2_46.Name = value_3_331
    local value_3_332: string = ""
    table_2_46.Description = value_3_332
    local value_3_333: string = "http://www.roblox.com/asset/?id=8304833835"
    table_2_46.Image = value_3_333
    local value_3_334: number = 8305207972
    table_2_46.KnifeModule = value_3_334
    local value_3_335: string = "Weapon Effect"
    table_2_46.Type = value_3_335
    local value_3_336: string = "NotForSale"
    table_2_46.Price = value_3_336
    table_1.IceMagic = table_2_46
    local table_2_47: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_337: string = "Snowflake"
    table_2_47.Name = value_3_337
    local value_3_338: string = ""
    table_2_47.Description = value_3_338
    local value_3_339: string = "http://www.roblox.com/asset/?id=8304834526"
    table_2_47.Image = value_3_339
    local value_3_340: number = 8305209648
    table_2_47.KnifeModule = value_3_340
    local value_3_341: string = "Weapon Effect"
    table_2_47.Type = value_3_341
    local value_3_342: string = "NotForSale"
    table_2_47.Price = value_3_342
    table_1.Snowflake2021 = table_2_47
    local table_2_48: { Description: string?, Image: string?, KnifeModule: number?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_343: string = "Starry"
    table_2_48.Name = value_3_343
    local value_3_344: string = "Starr"
    table_2_48.Description = value_3_344
    local value_3_345: string = "http://www.roblox.com/asset/?id=8304834906"
    table_2_48.Image = value_3_345
    local value_3_346: number = 8305210819
    table_2_48.KnifeModule = value_3_346
    local value_3_347: string = "Weapon Effect"
    table_2_48.Type = value_3_347
    local value_3_348: string = "NotForSale"
    table_2_48.Price = value_3_348
    table_1.Starry2021 = table_2_48
    local table_2_49: { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_349: string = "Plasma"
    table_2_49.Name = value_3_349
    local value_3_350: string = ""
    table_2_49.Description = value_3_350
    local value_3_351: string = "http://www.roblox.com/asset/?id=10025676429"
    table_2_49.Image = value_3_351
    local value_3_352: string = "Weapon Effect"
    table_2_49.Type = value_3_352
    local value_3_353: string = "NotForSale"
    table_2_49.Price = value_3_353
    table_1.PlasmaEffect = table_2_49
    local table_2_50: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_354: string = "Ghostly"
    table_2_50.Name = value_3_354
    local value_3_355: string = ""
    table_2_50.Description = value_3_355
    local value_3_356: string = "http://www.roblox.com/asset/?id=11253964720"
    table_2_50.Image = value_3_356
    local value_3_357: string = "Weapon Effect"
    table_2_50.Type = value_3_357
    local value_3_358: string = "NotForSale"
    table_2_50.Price = value_3_358
    local value_3_359: string = "Halloween"
    table_2_50.Event = value_3_359
    local value_3_360: string = "2022"
    table_2_50.Year = value_3_360
    table_1.PhantomEffect2022 = table_2_50
end
do
    local table_2_51: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_361: string = "Versus"
    table_2_51.Name = value_3_361
    local value_3_362: string = ""
    table_2_51.Description = value_3_362
    local value_3_363: string = "http://www.roblox.com/asset/?id=11265914765"
    table_2_51.Image = value_3_363
    local value_3_364: string = "Weapon Effect"
    table_2_51.Type = value_3_364
    local value_3_365: string = "NotForSale"
    table_2_51.Price = value_3_365
    local value_3_366: string = "Halloween"
    table_2_51.Event = value_3_366
    local value_3_367: string = "2022"
    table_2_51.Year = value_3_367
    table_1.VersusEffect2022 = table_2_51
    local table_2_52: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_368: string = "Candies"
    table_2_52.Name = value_3_368
    local value_3_369: string = ""
    table_2_52.Description = value_3_369
    local value_3_370: string = "http://www.roblox.com/asset/?id=11284556539"
    table_2_52.Image = value_3_370
    local value_3_371: string = "Weapon Effect"
    table_2_52.Type = value_3_371
    local value_3_372: string = "NotForSale"
    table_2_52.Price = value_3_372
    local value_3_373: string = "Halloween"
    table_2_52.Event = value_3_373
    local value_3_374: string = "2022"
    table_2_52.Year = value_3_374
    table_1.CandyEffect2022 = table_2_52
    local table_2_53: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_375: string = "Toxic"
    table_2_53.Name = value_3_375
    local value_3_376: string = ""
    table_2_53.Description = value_3_376
    local value_3_377: string = "http://www.roblox.com/asset/?id=11284815802"
    table_2_53.Image = value_3_377
    local value_3_378: string = "Weapon Effect"
    table_2_53.Type = value_3_378
    local value_3_379: string = "NotForSale"
    table_2_53.Price = value_3_379
    local value_3_380: string = "Halloween"
    table_2_53.Event = value_3_380
    local value_3_381: string = "2022"
    table_2_53.Year = value_3_381
    table_1.Toxic2022 = table_2_53
    local table_2_54: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_382: string = "Pumpkin"
    table_2_54.Name = value_3_382
    local value_3_383: string = ""
    table_2_54.Description = value_3_383
    local value_3_384: string = "http://www.roblox.com/asset/?id=11284819959"
    table_2_54.Image = value_3_384
    local value_3_385: string = "Weapon Effect"
    table_2_54.Type = value_3_385
    local value_3_386: string = "NotForSale"
    table_2_54.Price = value_3_386
    local value_3_387: string = "Halloween"
    table_2_54.Event = value_3_387
    local value_3_388: string = "2022"
    table_2_54.Year = value_3_388
    table_1.Pumpkin2022 = table_2_54
    local table_2_55: { Description: string?, Image: string?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_389: string = "Void"
    table_2_55.Name = value_3_389
    local value_3_390: string = ""
    table_2_55.Description = value_3_390
    local value_3_391: string = "http://www.roblox.com/asset/?id=11548191748"
    table_2_55.Image = value_3_391
    local value_3_392: string = "Weapon Effect"
    table_2_55.Type = value_3_392
    local value_3_393: string = "NotForSale"
    table_2_55.Price = value_3_393
    table_1.VoidRbxEffect = table_2_55
    local table_2_56: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_394: string = "Stickers"
    table_2_56.Name = value_3_394
    local value_3_395: string = ""
    table_2_56.Description = value_3_395
    local value_3_396: string = "http://www.roblox.com/asset/?id=11875810633"
    table_2_56.Image = value_3_396
    local value_3_397: string = "Weapon Effect"
    table_2_56.Type = value_3_397
    local value_3_398: string = "NotForSale"
    table_2_56.Price = value_3_398
    local value_3_399: string = "Christmas"
    table_2_56.Event = value_3_399
    local value_3_400: string = "2022"
    table_2_56.Year = value_3_400
    table_1.StickersX2022 = table_2_56
    local table_2_57: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_401: string = "Minty"
    table_2_57.Name = value_3_401
    local value_3_402: string = ""
    table_2_57.Description = value_3_402
    local value_3_403: string = "http://www.roblox.com/asset/?id=11875809713"
    table_2_57.Image = value_3_403
    local value_3_404: string = "Weapon Effect"
    table_2_57.Type = value_3_404
    local value_3_405: string = "NotForSale"
    table_2_57.Price = value_3_405
    local value_3_406: string = "Christmas"
    table_2_57.Event = value_3_406
    local value_3_407: string = "2022"
    table_2_57.Year = value_3_407
    table_1.Minty2022 = table_2_57
    local table_2_58: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_408: string = "Chilly"
    table_2_58.Name = value_3_408
    local value_3_409: string = ""
    table_2_58.Description = value_3_409
    local value_3_410: string = "http://www.roblox.com/asset/?id=11875810027"
    table_2_58.Image = value_3_410
    local value_3_411: string = "Weapon Effect"
    table_2_58.Type = value_3_411
    local value_3_412: string = "NotForSale"
    table_2_58.Price = value_3_412
    local value_3_413: string = "Christmas"
    table_2_58.Event = value_3_413
    local value_3_414: string = "2022"
    table_2_58.Year = value_3_414
    table_1.Chilly2022 = table_2_58
    local table_2_59: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_415: string = "Arctic"
    table_2_59.Name = value_3_415
    local value_3_416: string = ""
    table_2_59.Description = value_3_416
    local value_3_417: string = "http://www.roblox.com/asset/?id=11875810334"
    table_2_59.Image = value_3_417
    local value_3_418: string = "Weapon Effect"
    table_2_59.Type = value_3_418
    local value_3_419: string = "NotForSale"
    table_2_59.Price = value_3_419
    local value_3_420: string = "Christmas"
    table_2_59.Event = value_3_420
    local value_3_421: string = "2022"
    table_2_59.Year = value_3_421
    table_1.Arctic2022 = table_2_59
end
do
    local table_2_60: { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_422: string = "Petals"
    table_2_60.Name = value_3_422
    local value_3_423: string = ""
    table_2_60.Description = value_3_423
    local value_3_424: string = "http://www.roblox.com/asset/?id=12346535943"
    table_2_60.Image = value_3_424
    local value_3_425: string = "Weapon Effect"
    table_2_60.Type = value_3_425
    local value_3_426: string = "NotForSale"
    table_2_60.Price = value_3_426
    local value_3_427: boolean = true
    table_2_60.DeathEffect = value_3_427
    table_1.Petals = table_2_60
    local table_2_61: { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_428: string = "Rainbow"
    table_2_61.Name = value_3_428
    local value_3_429: string = ""
    table_2_61.Description = value_3_429
    local value_3_430: string = "http://www.roblox.com/asset/?id=12978560517"
    table_2_61.Image = value_3_430
    local value_3_431: string = "Weapon Effect"
    table_2_61.Type = value_3_431
    local value_3_432: string = "NotForSale"
    table_2_61.Price = value_3_432
    local value_3_433: boolean = true
    table_2_61.DeathEffect = value_3_433
    table_1.RainbowEffect = table_2_61
    local table_2_62: { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_434: string = "Easter Glow"
    table_2_62.Name = value_3_434
    local value_3_435: string = ""
    table_2_62.Description = value_3_435
    local value_3_436: string = "http://www.roblox.com/asset/?id=12980517166"
    table_2_62.Image = value_3_436
    local value_3_437: string = "Legendary"
    table_2_62.Rarity = value_3_437
    local value_3_438: string = "Weapon Effect"
    table_2_62.Type = value_3_438
    local value_3_439: string = "NotForSale"
    table_2_62.Price = value_3_439
    table_1.EasterGlow2023 = table_2_62
    local table_2_63: { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_440: string = "Floral"
    table_2_63.Name = value_3_440
    local value_3_441: string = ""
    table_2_63.Description = value_3_441
    local value_3_442: string = "rbxassetid://13944177212"
    table_2_63.Image = value_3_442
    local value_3_443: string = "Rare"
    table_2_63.Rarity = value_3_443
    local value_3_444: string = "Weapon Effect"
    table_2_63.Type = value_3_444
    local value_3_445: string = "NotForSale"
    table_2_63.Price = value_3_445
    table_1.Floral2023 = table_2_63
    local table_2_64: { DeathEffect: boolean?, Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_446: string = "Flow"
    table_2_64.Name = value_3_446
    local value_3_447: string = ""
    table_2_64.Description = value_3_447
    local value_3_448: string = "rbxassetid://13935511226"
    table_2_64.Image = value_3_448
    local value_3_449: string = "Godly"
    table_2_64.Rarity = value_3_449
    local value_3_450: boolean = true
    table_2_64.DeathEffect = value_3_450
    local value_3_451: string = "Weapon Effect"
    table_2_64.Type = value_3_451
    local value_3_452: string = "NotForSale"
    table_2_64.Price = value_3_452
    table_1.Water2023 = table_2_64
    local table_2_65: { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_453: string = "Darkswirl"
    table_2_65.Name = value_3_453
    local value_3_454: string = ""
    table_2_65.Description = value_3_454
    local value_3_455: string = "rbxassetid://15091473476"
    table_2_65.Image = value_3_455
    local value_3_456: string = "Godly"
    table_2_65.Rarity = value_3_456
    local value_3_457: boolean = true
    table_2_65.DeathEffect = value_3_457
    local value_3_458: string = "Weapon Effect"
    table_2_65.Type = value_3_458
    local value_3_459: string = "NotForSale"
    table_2_65.Price = value_3_459
    local value_3_460: string = "Halloween"
    table_2_65.Event = value_3_460
    local value_3_461: string = "2023"
    table_2_65.Year = value_3_461
    table_1.Darkswirl = table_2_65
    local table_2_66: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_462: string = "Glowy"
    table_2_66.Name = value_3_462
    local value_3_463: string = ""
    table_2_66.Description = value_3_463
    local value_3_464: string = "rbxassetid://15091473038"
    table_2_66.Image = value_3_464
    local value_3_465: string = "Common"
    table_2_66.Rarity = value_3_465
    local value_3_466: string = "Weapon Effect"
    table_2_66.Type = value_3_466
    local value_3_467: string = "NotForSale"
    table_2_66.Price = value_3_467
    local value_3_468: string = "Halloween"
    table_2_66.Event = value_3_468
    local value_3_469: string = "2023"
    table_2_66.Year = value_3_469
    table_1.Glowy2023 = table_2_66
    local table_2_67: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_470: string = "Ghosts"
    table_2_67.Name = value_3_470
    local value_3_471: string = ""
    table_2_67.Description = value_3_471
    local value_3_472: string = "rbxassetid://15091959837"
    table_2_67.Image = value_3_472
    local value_3_473: string = "Common"
    table_2_67.Rarity = value_3_473
    local value_3_474: string = "Weapon Effect"
    table_2_67.Type = value_3_474
    local value_3_475: string = "NotForSale"
    table_2_67.Price = value_3_475
    local value_3_476: string = "Halloween"
    table_2_67.Event = value_3_476
    local value_3_477: string = "2023"
    table_2_67.Year = value_3_477
    table_1.Ghosts2023 = table_2_67
end
do
    local table_2_68: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_478: string = "Candies"
    table_2_68.Name = value_3_478
    local value_3_479: string = ""
    table_2_68.Description = value_3_479
    local value_3_480: string = "rbxassetid://15092320788"
    table_2_68.Image = value_3_480
    local value_3_481: string = "Common"
    table_2_68.Rarity = value_3_481
    local value_3_482: string = "Weapon Effect"
    table_2_68.Type = value_3_482
    local value_3_483: string = "NotForSale"
    table_2_68.Price = value_3_483
    local value_3_484: string = "Halloween"
    table_2_68.Event = value_3_484
    local value_3_485: string = "2023"
    table_2_68.Year = value_3_485
    table_1.CandyEffect2023 = table_2_68
    local table_2_69: { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_486: string = "Traveler's Flame"
    table_2_69.Name = value_3_486
    local value_3_487: string = ""
    table_2_69.Description = value_3_487
    local value_3_488: string = "rbxassetid://15091960360"
    table_2_69.Image = value_3_488
    local value_3_489: string = "Common"
    table_2_69.Rarity = value_3_489
    local value_3_490: boolean = true
    table_2_69.DeathEffect = value_3_490
    local value_3_491: string = "Weapon Effect"
    table_2_69.Type = value_3_491
    local value_3_492: string = "NotForSale"
    table_2_69.Price = value_3_492
    local value_3_493: string = "Halloween"
    table_2_69.Event = value_3_493
    local value_3_494: string = "2023"
    table_2_69.Year = value_3_494
    table_1.Traveler2023 = table_2_69
    local table_2_70: { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_495: string = "Stars"
    table_2_70.Name = value_3_495
    local value_3_496: string = ""
    table_2_70.Description = value_3_496
    local value_3_497: string = "rbxassetid://15653712264"
    table_2_70.Image = value_3_497
    local value_3_498: string = "Common"
    table_2_70.Rarity = value_3_498
    local value_3_499: string = "Weapon Effect"
    table_2_70.Type = value_3_499
    local value_3_500: string = "NotForSale"
    table_2_70.Price = value_3_500
    local value_3_501: string = "Christmas"
    table_2_70.Event = value_3_501
    local value_3_502: string = "2023"
    table_2_70.Year = value_3_502
    local value_3_503: boolean = true
    table_2_70.DeathEffect = value_3_503
    table_1.Stars2023 = table_2_70
    local table_2_71: { DeathEffect: boolean?, Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
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
    local value_3_504: string = "Fireworks"
    table_2_71.Name = value_3_504
    local value_3_505: string = ""
    table_2_71.Description = value_3_505
    local value_3_506: string = "rbxassetid://15653714885"
    table_2_71.Image = value_3_506
    local value_3_507: string = "Common"
    table_2_71.Rarity = value_3_507
    local value_3_508: string = "Weapon Effect"
    table_2_71.Type = value_3_508
    local value_3_509: string = "NotForSale"
    table_2_71.Price = value_3_509
    local value_3_510: string = "Christmas"
    table_2_71.Event = value_3_510
    local value_3_511: string = "2023"
    table_2_71.Year = value_3_511
    local value_3_512: boolean = true
    table_2_71.DeathEffect = value_3_512
    table_1.Fireworks2023 = table_2_71
    local table_2_72: { Description: string?, Event: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string?, Year: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_513: string = "Swirls"
    table_2_72.Name = value_3_513
    local value_3_514: string = ""
    table_2_72.Description = value_3_514
    local value_3_515: string = "rbxassetid://15653713506"
    table_2_72.Image = value_3_515
    local value_3_516: string = "Common"
    table_2_72.Rarity = value_3_516
    local value_3_517: string = "Weapon Effect"
    table_2_72.Type = value_3_517
    local value_3_518: string = "NotForSale"
    table_2_72.Price = value_3_518
    local value_3_519: string = "Christmas"
    table_2_72.Event = value_3_519
    local value_3_520: string = "2023"
    table_2_72.Year = value_3_520
    table_1.Swirls2023 = table_2_72
    local table_2_73: { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_521: string = "Flowers"
    table_2_73.Name = value_3_521
    local value_3_522: string = ""
    table_2_73.Description = value_3_522
    local value_3_523: string = "rbxassetid://16960041861"
    table_2_73.Image = value_3_523
    local value_3_524: string = "Common"
    table_2_73.Rarity = value_3_524
    local value_3_525: string = "Weapon Effect"
    table_2_73.Type = value_3_525
    local value_3_526: string = "NotForSale"
    table_2_73.Price = value_3_526
    table_1.Flowers2024 = table_2_73
    local table_2_74: { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_527: string = "Matrix"
    table_2_74.Name = value_3_527
    local value_3_528: string = ""
    table_2_74.Description = value_3_528
    local value_3_529: string = "rbxassetid://16960043972"
    table_2_74.Image = value_3_529
    local value_3_530: string = "Common"
    table_2_74.Rarity = value_3_530
    local value_3_531: string = "Weapon Effect"
    table_2_74.Type = value_3_531
    local value_3_532: string = "NotForSale"
    table_2_74.Price = value_3_532
    table_1.Matrix2024 = table_2_74
    local table_2_75: { Description: string?, Image: string?, Name: string?, Price: string?, Rarity: string?, Type: string? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_3_533: string = "Flowerwood"
    table_2_75.Name = value_3_533
    local value_3_534: string = ""
    table_2_75.Description = value_3_534
    local value_3_535: string = "rbxassetid://16963901196"
    table_2_75.Image = value_3_535
    local value_3_536: string = "Godly"
    table_2_75.Rarity = value_3_536
    local value_3_537: string = "Weapon Effect"
    table_2_75.Type = value_3_537
    local value_3_538: string = "NotForSale"
    table_2_75.Price = value_3_538
    table_1.Flowerwood = table_2_75
end
do
    local table_2_76: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } = {
        Name = "Sunbeams",
        Description = "",
        Image = "rbxassetid://18323742861",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
    }
    table_1.Sunbeams2024 = table_2_76
    local table_2_77: { Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } = {
        Name = "Jellyfish",
        Description = "",
        Image = "rbxassetid://18323743167",
        Rarity = "Rare",
        Type = "Weapon Effect",
        Price = "NotForSale",
    }
    table_1.Jellyfish2024 = table_2_77
    local table_2_78: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } = {
        Name = "Glisten",
        Description = "",
        Image = "rbxassetid://18323743004",
        Rarity = "Godly",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
    }
    table_1.Glisten2024 = table_2_78
    local table_2_79: { DeathEffect: boolean, Description: string, Image: string, Name: string, Price: string, Rarity: string, Type: string } = {
        Name = "Wraith",
        Description = "",
        Image = "rbxassetid://127062580825035",
        Rarity = "Godly",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
    }
    table_1.Wraith2024 = table_2_79
    local table_2_80: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Ghosts",
        Description = "",
        Image = "rbxassetid://93645780712749",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2024",
    }
    table_1.Ghosts2024 = table_2_80
    local table_2_81: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Cursed",
        Description = "",
        Image = "rbxassetid://112685509835415",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2024",
    }
    table_1.Cursed2024 = table_2_81
    local table_2_82: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Bat Swarm",
        Description = "",
        Image = "rbxassetid://116945269275402",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2024",
    }
    table_1.Bats2024 = table_2_82
    local table_2_83: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Vampiric",
        Description = "",
        Image = "rbxassetid://110453044693325",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2024",
    }
    table_1.Vampiric2024 = table_2_83
    local table_2_84: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Gifts",
        Description = "",
        Image = "104330782277420",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Christmas",
        Year = "2024",
    }
    table_1.Gifts2024 = table_2_84
    local table_2_85: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Celestial",
        Description = "",
        Image = "87501403420126",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Christmas",
        Year = "2024",
    }
    table_1.Starry2024 = table_2_85
    local table_2_86: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Snowy",
        Description = "",
        Image = "71175758692160",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Christmas",
        Year = "2024",
    }
    table_1.Snowstorm2024 = table_2_86
    local table_2_87: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Aurora Lights",
        Description = "",
        Image = "122136909635189",
        Rarity = "Godly",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Christmas",
        Year = "2024",
    }
    table_1.Aurora2024 = table_2_87
    local table_2_88: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Carrots",
        Description = "",
        Image = "rbxassetid://78579865223859",
        Rarity = "Rare",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Easter",
        Year = "2025",
    }
    table_1.Carrots2025 = table_2_88
    local table_2_89: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Rainbows",
        Description = "",
        Image = "rbxassetid://123649158676650",
        Rarity = "Legendary",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Easter",
        Year = "2025",
    }
    table_1.Rainbows2025 = table_2_89
    local table_2_90: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Bloom",
        Description = "",
        Image = "rbxassetid://125624899802245",
        Rarity = "Godly",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Easter",
        Year = "2025",
    }
    table_1.Bloom2025 = table_2_90
    local table_2_91: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Flamingo",
        Description = "",
        Image = "rbxassetid://127362708425889",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Summer",
        Year = "2025",
    }
    table_1.FlamingoEffect2025 = table_2_91
    local table_2_92: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Retro",
        Description = "",
        Image = "rbxassetid://121156896113213",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Summer",
        Year = "2025",
    }
    table_1.Retro2025 = table_2_92
    local table_2_93: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Aquatic",
        Description = "",
        Image = "rbxassetid://70697360654938",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Summer",
        Year = "2025",
    }
    table_1.Aquatic2025 = table_2_93
    local table_2_94: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Heatwave",
        Description = "",
        Image = "rbxassetid://126681621399688",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Summer",
        Year = "2025",
    }
    table_1.Heatwave2025 = table_2_94
    local table_2_95: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Synthwave",
        Description = "",
        Image = "rbxassetid://77123504515104",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Summer",
        Year = "2025",
    }
    table_1.SynthEffect2025 = table_2_95
    local table_2_96: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Xeno",
        Description = "",
        Image = "rbxassetid://93543937441823",
        Rarity = "Godly",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Halloween",
        Year = "2025",
    }
    table_1.XenoEffect = table_2_96
    local table_2_97: { DeathEffect: boolean, Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Abduction",
        Description = "",
        Image = "rbxassetid://121586555485231",
        Rarity = "Legendary",
        Type = "Weapon Effect",
        Price = "NotForSale",
        DeathEffect = true,
        Event = "Halloween",
        Year = "2025",
    }
    table_1.Abduction2025 = table_2_97
    local table_2_98: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Cat Eyes",
        Description = "",
        Image = "rbxassetid://136395333523628",
        Rarity = "Rare",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2025",
    }
    table_1.Cats2025 = table_2_98
    local table_2_99: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "Treats",
        Description = "",
        Image = "rbxassetid://70498495867002",
        Rarity = "Uncommon",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2025",
    }
    table_1.Treats2025 = table_2_99
    local table_2_100: { Description: string, Event: string, Image: string, Name: string, Price: string, Rarity: string, Type: string, Year: string } = {
        Name = "UFOs",
        Description = "",
        Image = "rbxassetid://105023177822851",
        Rarity = "Common",
        Type = "Weapon Effect",
        Price = "NotForSale",
        Event = "Halloween",
        Year = "2025",
    }
    table_1.UFOs2025 = table_2_100
    local table_2_101: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Leaves",
        Description = "",
        Image = "rbxassetid://114300447747395",
        Rarity = "Common",
        Type = "Weapon Effect",
    }
    table_1.Leaves2025 = table_2_101
    local table_2_102: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Snowstorm",
        Description = "",
        Image = "rbxassetid://90255798518419",
        Rarity = "Godly",
        Type = "Weapon Effect",
        DeathEffect = true,
    }
    table_1.Snowstorm2025 = table_2_102
    local table_2_103: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Snowballs",
        Description = "",
        Image = "rbxassetid://101207271208336",
        Rarity = "Common",
        Type = "Weapon Effect",
    }
    table_1.Snowballs2025 = table_2_103
    local table_2_104: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Confetti",
        Description = "",
        Image = "rbxassetid://82294279433537",
        Rarity = "Uncommon",
        Type = "Weapon Effect",
    }
    table_1.Confetti2025 = table_2_104
    local table_2_105: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Frost",
        Description = "",
        Image = "rbxassetid://91230750233479",
        Rarity = "Legendary",
        Type = "Weapon Effect",
        DeathEffect = true,
    }
    table_1.Frost2025 = table_2_105
    local table_2_106: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Christmas Glow",
        Description = "",
        Image = "rbxassetid://96731265068506",
        Rarity = "Rare",
        Type = "Weapon Effect",
    }
    table_1.XmasGlow2025 = table_2_106
    local table_2_107: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Coal",
        Description = "",
        Image = "rbxassetid://116921008232997",
        Rarity = "Common",
        Type = "Weapon Effect",
    }
    table_1.Coal2025 = table_2_107
    local table_2_108: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Bokeh",
        Description = "",
        Image = "rbxassetid://122341714532843",
        Rarity = "Uncommon",
        Type = "Weapon Effect",
    }
    table_1.Bokeh2025 = table_2_108
    local table_2_109: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Lights",
        Description = "",
        Image = "rbxassetid://101913086214821",
        Rarity = "Rare",
        Type = "Weapon Effect",
    }
    table_1.Lights2025 = table_2_109
    local table_2_110: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Nightsky",
        Description = "",
        Image = "rbxassetid://100968055163359",
        Rarity = "Legendary",
        Type = "Weapon Effect",
        DeathEffect = true,
    }
    table_1.Nightsky2025 = table_2_110
    local table_2_111: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Pixie Dust",
        Description = "",
        Image = "rbxassetid://109485062307296",
        Rarity = "Godly",
        Type = "Weapon Effect",
        DeathEffect = true,
    }
    table_1.SweetEffect26 = table_2_111
    local table_2_112: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Strawberries",
        Description = "",
        Image = "rbxassetid://90406823538211",
        Rarity = "Common",
        Type = "Weapon Effect",
    }
    table_1.Strawberries26 = table_2_112
    local table_2_113: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Hearts",
        Description = "",
        Image = "rbxassetid://134177232274775",
        Rarity = "Rare",
        Type = "Weapon Effect",
    }
    table_1.Hearts26 = table_2_113
    local table_2_114: { DeathEffect: boolean, Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Ocean",
        Description = "",
        Image = "rbxassetid://102007867429981",
        Rarity = "Godly",
        Type = "Weapon Effect",
        DeathEffect = true,
    }
    table_1.Ocean26 = table_2_114
    local table_2_115: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Bubbly",
        Description = "",
        Image = "rbxassetid://124372895616032",
        Rarity = "Common",
        Type = "Weapon Effect",
    }
    table_1.Bubbly26 = table_2_115
    local table_2_116: { Description: string, Image: string, Name: string, Rarity: string, Type: string } = {
        Name = "Nightlife",
        Description = "",
        Image = "rbxassetid://118475237078783",
        Rarity = "Legendary",
        Type = "Weapon Effect",
    }
    table_1.Nightlife26 = table_2_116
end

return table_1
