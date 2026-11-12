--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    AmericaSword: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Amerilaser: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    BattleAxe: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    BattleAxe2: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Blaster: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Candy: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Chill: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Clockwork: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Common: nil | { CountChance: number | {number?}, Rewards: number | { CommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { CommonShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { CommonShards: { Amount: {number?}, Rarity: {number?} } } },
    Deathshard: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Eternal: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Fang: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Frostsaber: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    GingerLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Gingerblade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    GreenLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Hallow: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    HallowsBlade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Handsaw: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Heat: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    IceDragon: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    IceShard: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Laser: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Legendary: nil | { CountChance: number | {number?}, Rewards: number | { LegendaryShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { LegendaryShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { LegendaryShards: { Amount: {number?}, Rarity: {number?} } } },
    Luger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Nightblade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Pixel: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Pumpking: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Rare: nil | { CountChance: number | {number?}, Rewards: number | { RareShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { RareShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { RareShards: { Amount: {number?}, Rarity: {number?} } } },
    RedLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Saw: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Shark: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Slasher: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Snowflake: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Spider: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Sugar: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    TheSeer: nil | { CountChance: number | {number?}, Rewards: number | { GodlyMetal: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyMetal: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyMetal: { Amount: {number?}, Rarity: {number?} } } },
    Tides: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Uncommon: nil | { CountChance: number | {number?}, Rewards: number | { UncommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { UncommonShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { UncommonShards: { Amount: {number?}, Rarity: {number?} } } },
    Virtual: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    WintersEdge: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
    Xbox: {  }?,
    Xmas: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } },
}

local table_1: { AmericaSword: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Amerilaser: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, BattleAxe: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, BattleAxe2: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Blaster: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Candy: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Chill: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Clockwork: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Common: nil | { CountChance: number | {number?}, Rewards: number | { CommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { CommonShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { CommonShards: { Amount: {number?}, Rarity: {number?} } } }, Deathshard: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Eternal: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Fang: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Frostsaber: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, GingerLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Gingerblade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, GreenLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Hallow: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, HallowsBlade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Handsaw: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Heat: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, IceDragon: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, IceShard: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Laser: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Legendary: nil | { CountChance: number | {number?}, Rewards: number | { LegendaryShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { LegendaryShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { LegendaryShards: { Amount: {number?}, Rarity: {number?} } } }, Luger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Nightblade: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Pixel: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Pumpking: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Rare: nil | { CountChance: number | {number?}, Rewards: number | { RareShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { RareShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { RareShards: { Amount: {number?}, Rarity: {number?} } } }, RedLuger: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Saw: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Shark: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Slasher: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Snowflake: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Spider: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Sugar: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, TheSeer: nil | { CountChance: number | {number?}, Rewards: number | { GodlyMetal: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyMetal: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyMetal: { Amount: {number?}, Rarity: {number?} } } }, Tides: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Uncommon: nil | { CountChance: number | {number?}, Rewards: number | { UncommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { UncommonShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { UncommonShards: { Amount: {number?}, Rarity: {number?} } } }, Virtual: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, WintersEdge: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } }, Xbox: {  }?, Xmas: nil | { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } | { CountChance: {number?}, Rewards: { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } } = {
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
}
do
    local table_2: { CountChance: number | {number?}, Rewards: number | { CommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { CommonShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3: {number?} = {nil, nil, nil}
    local value_4: number = 100
    local value_5: number = 0
    local value_6: number = 0
    table_3[1], table_3[2], table_3[3] = value_4, value_5, value_6
    table_2.CountChance = table_3
    local table_3_2: { CommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("CommonShards")] = nil,
    }
    local table_4: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5: {number?} = {nil, nil}
    local value_6_2: number = 2
    local value_7: number = 2
    table_5[1], table_5[2] = value_6_2, value_7
    table_4.Amount = table_5
    local table_5_2: {number?} = {nil, nil, nil}
    local value_6_3: number = 100
    local value_7_2: number = 0
    local value_8: number = 0
    table_5_2[1], table_5_2[2], table_5_2[3] = value_6_3, value_7_2, value_8
    table_4.Rarity = table_5_2
    table_3_2.CommonShards = table_4
    table_2.Rewards = table_3_2
    table_1.Common = table_2
    local table_2_2: { CountChance: number | {number?}, Rewards: number | { UncommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { UncommonShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_3: {number?} = {nil, nil, nil}
    local value_4_2: number = 100
    local value_5_2: number = 0
    local value_6_4: number = 0
    table_3_3[1], table_3_3[2], table_3_3[3] = value_4_2, value_5_2, value_6_4
    table_2_2.CountChance = table_3_3
    local table_3_4: { UncommonShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("UncommonShards")] = nil,
    }
    local table_4_2: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_3: {number?} = {nil, nil}
    local value_6_5: number = 2
    local value_7_3: number = 2
    table_5_3[1], table_5_3[2] = value_6_5, value_7_3
    table_4_2.Amount = table_5_3
    local table_5_4: {number?} = {nil, nil, nil}
    local value_6_6: number = 100
    local value_7_4: number = 0
    local value_8_2: number = 0
    table_5_4[1], table_5_4[2], table_5_4[3] = value_6_6, value_7_4, value_8_2
    table_4_2.Rarity = table_5_4
    table_3_4.UncommonShards = table_4_2
    table_2_2.Rewards = table_3_4
    table_1.Uncommon = table_2_2
    local table_2_3: { CountChance: number | {number?}, Rewards: number | { RareShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { RareShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_5: {number?} = {nil, nil, nil}
    local value_4_3: number = 100
    local value_5_3: number = 0
    local value_6_7: number = 0
    table_3_5[1], table_3_5[2], table_3_5[3] = value_4_3, value_5_3, value_6_7
    table_2_3.CountChance = table_3_5
    local table_3_6: { RareShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("RareShards")] = nil,
    }
    local table_4_3: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_5: {number?} = {nil, nil}
    local value_6_8: number = 2
    local value_7_5: number = 2
    table_5_5[1], table_5_5[2] = value_6_8, value_7_5
    table_4_3.Amount = table_5_5
    local table_5_6: {number?} = {nil, nil, nil}
    local value_6_9: number = 100
    local value_7_6: number = 0
    local value_8_3: number = 0
    table_5_6[1], table_5_6[2], table_5_6[3] = value_6_9, value_7_6, value_8_3
    table_4_3.Rarity = table_5_6
    table_3_6.RareShards = table_4_3
    table_2_3.Rewards = table_3_6
    table_1.Rare = table_2_3
    local table_2_4: { CountChance: number | {number?}, Rewards: number | { LegendaryShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { LegendaryShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_7: {number?} = {nil, nil, nil}
    local value_4_4: number = 100
    local value_5_4: number = 0
    local value_6_10: number = 0
    table_3_7[1], table_3_7[2], table_3_7[3] = value_4_4, value_5_4, value_6_10
    table_2_4.CountChance = table_3_7
    local table_3_8: { LegendaryShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("LegendaryShards")] = nil,
    }
    local table_4_4: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_7: {number?} = {nil, nil}
    local value_6_11: number = 2
    local value_7_7: number = 2
    table_5_7[1], table_5_7[2] = value_6_11, value_7_7
    table_4_4.Amount = table_5_7
    local table_5_8: {number?} = {nil, nil, nil}
    local value_6_12: number = 100
    local value_7_8: number = 0
    local value_8_4: number = 0
    table_5_8[1], table_5_8[2], table_5_8[3] = value_6_12, value_7_8, value_8_4
    table_4_4.Rarity = table_5_8
    table_3_8.LegendaryShards = table_4_4
    table_2_4.Rewards = table_3_8
    table_1.Legendary = table_2_4
    local table_2_5: { CountChance: number | {number?}, Rewards: number | { GodlyMetal: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyMetal: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_9: {number?} = {nil, nil, nil}
    local value_4_5: number = 100
    local value_5_5: number = 0
    local value_6_13: number = 0
    table_3_9[1], table_3_9[2], table_3_9[3] = value_4_5, value_5_5, value_6_13
    table_2_5.CountChance = table_3_9
    local table_3_10: { GodlyMetal: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyMetal")] = nil,
    }
    local table_4_5: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_9: {number?} = {nil, nil}
    local value_6_14: number = 1
    local value_7_9: number = 1
    table_5_9[1], table_5_9[2] = value_6_14, value_7_9
    table_4_5.Amount = table_5_9
    local table_5_10: {number?} = {nil, nil, nil}
    local value_6_15: number = 100
    local value_7_10: number = 0
    local value_8_5: number = 0
    table_5_10[1], table_5_10[2], table_5_10[3] = value_6_15, value_7_10, value_8_5
    table_4_5.Rarity = table_5_10
    table_3_10.GodlyMetal = table_4_5
    table_2_5.Rewards = table_3_10
    table_1.TheSeer = table_2_5
end
do
    local table_2_6: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_11: {number?} = {nil, nil, nil}
    local value_4_6: number = 100
    local value_5_6: number = 0
    local value_6_16: number = 0
    table_3_11[1], table_3_11[2], table_3_11[3] = value_4_6, value_5_6, value_6_16
    table_2_6.CountChance = table_3_11
    local table_3_12: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_6: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_11: {number?} = {nil, nil}
    local value_6_17: number = 255
    local value_7_11: number = 255
    table_5_11[1], table_5_11[2] = value_6_17, value_7_11
    table_4_6.Amount = table_5_11
    local table_5_12: {number?} = {nil, nil, nil}
    local value_6_18: number = 100
    local value_7_12: number = 0
    local value_8_6: number = 0
    table_5_12[1], table_5_12[2], table_5_12[3] = value_6_18, value_7_12, value_8_6
    table_4_6.Rarity = table_5_12
    table_3_12.GodlyShards = table_4_6
    table_2_6.Rewards = table_3_12
    table_1.Handsaw = table_2_6
    local table_2_7: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_13: {number?} = {nil, nil, nil}
    local value_4_7: number = 100
    local value_5_7: number = 0
    local value_6_19: number = 0
    table_3_13[1], table_3_13[2], table_3_13[3] = value_4_7, value_5_7, value_6_19
    table_2_7.CountChance = table_3_13
    local table_3_14: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_7: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_13: {number?} = {nil, nil}
    local value_6_20: number = 255
    local value_7_13: number = 255
    table_5_13[1], table_5_13[2] = value_6_20, value_7_13
    table_4_7.Amount = table_5_13
    local table_5_14: {number?} = {nil, nil, nil}
    local value_6_21: number = 100
    local value_7_14: number = 0
    local value_8_7: number = 0
    table_5_14[1], table_5_14[2], table_5_14[3] = value_6_21, value_7_14, value_8_7
    table_4_7.Rarity = table_5_14
    table_3_14.GodlyShards = table_4_7
    table_2_7.Rewards = table_3_14
    table_1.Sugar = table_2_7
    local table_2_8: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_15: {number?} = {nil, nil, nil}
    local value_4_8: number = 100
    local value_5_8: number = 0
    local value_6_22: number = 0
    table_3_15[1], table_3_15[2], table_3_15[3] = value_4_8, value_5_8, value_6_22
    table_2_8.CountChance = table_3_15
    local table_3_16: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_8: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_15: {number?} = {nil, nil}
    local value_6_23: number = 235
    local value_7_15: number = 235
    table_5_15[1], table_5_15[2] = value_6_23, value_7_15
    table_4_8.Amount = table_5_15
    local table_5_16: {number?} = {nil, nil, nil}
    local value_6_24: number = 100
    local value_7_16: number = 0
    local value_8_8: number = 0
    table_5_16[1], table_5_16[2], table_5_16[3] = value_6_24, value_7_16, value_8_8
    table_4_8.Rarity = table_5_16
    table_3_16.GodlyShards = table_4_8
    table_2_8.Rewards = table_3_16
    table_1.Candy = table_2_8
    local table_2_9: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_17: {number?} = {nil, nil, nil}
    local value_4_9: number = 100
    local value_5_9: number = 0
    local value_6_25: number = 0
    table_3_17[1], table_3_17[2], table_3_17[3] = value_4_9, value_5_9, value_6_25
    table_2_9.CountChance = table_3_17
    local table_3_18: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_9: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_17: {number?} = {nil, nil}
    local value_6_26: number = 235
    local value_7_17: number = 235
    table_5_17[1], table_5_17[2] = value_6_26, value_7_17
    table_4_9.Amount = table_5_17
    local table_5_18: {number?} = {nil, nil, nil}
    local value_6_27: number = 100
    local value_7_18: number = 0
    local value_8_9: number = 0
    table_5_18[1], table_5_18[2], table_5_18[3] = value_6_27, value_7_18, value_8_9
    table_4_9.Rarity = table_5_18
    table_3_18.GodlyShards = table_4_9
    table_2_9.Rewards = table_3_18
    table_1.Chill = table_2_9
    local table_2_10: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_19: {number?} = {nil, nil, nil}
    local value_4_10: number = 100
    local value_5_10: number = 0
    local value_6_28: number = 0
    table_3_19[1], table_3_19[2], table_3_19[3] = value_4_10, value_5_10, value_6_28
    table_2_10.CountChance = table_3_19
    local table_3_20: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_10: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_19: {number?} = {nil, nil}
    local value_6_29: number = 230
    local value_7_19: number = 230
    table_5_19[1], table_5_19[2] = value_6_29, value_7_19
    table_4_10.Amount = table_5_19
    local table_5_20: {number?} = {nil, nil, nil}
    local value_6_30: number = 100
    local value_7_20: number = 0
    local value_8_10: number = 0
    table_5_20[1], table_5_20[2], table_5_20[3] = value_6_30, value_7_20, value_8_10
    table_4_10.Rarity = table_5_20
    table_3_20.GodlyShards = table_4_10
    table_2_10.Rewards = table_3_20
    table_1.RedLuger = table_2_10
end
do
    local table_2_11: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_21: {number?} = {nil, nil, nil}
    local value_4_11: number = 100
    local value_5_11: number = 0
    local value_6_31: number = 0
    table_3_21[1], table_3_21[2], table_3_21[3] = value_4_11, value_5_11, value_6_31
    table_2_11.CountChance = table_3_21
    local table_3_22: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_11: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_21: {number?} = {nil, nil}
    local value_6_32: number = 230
    local value_7_21: number = 230
    table_5_21[1], table_5_21[2] = value_6_32, value_7_21
    table_4_11.Amount = table_5_21
    local table_5_22: {number?} = {nil, nil, nil}
    local value_6_33: number = 100
    local value_7_22: number = 0
    local value_8_11: number = 0
    table_5_22[1], table_5_22[2], table_5_22[3] = value_6_33, value_7_22, value_8_11
    table_4_11.Rarity = table_5_22
    table_3_22.GodlyShards = table_4_11
    table_2_11.Rewards = table_3_22
    table_1.GreenLuger = table_2_11
    local table_2_12: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_23: {number?} = {nil, nil, nil}
    local value_4_12: number = 100
    local value_5_12: number = 0
    local value_6_34: number = 0
    table_3_23[1], table_3_23[2], table_3_23[3] = value_4_12, value_5_12, value_6_34
    table_2_12.CountChance = table_3_23
    local table_3_24: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_12: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_23: {number?} = {nil, nil}
    local value_6_35: number = 160
    local value_7_23: number = 160
    table_5_23[1], table_5_23[2] = value_6_35, value_7_23
    table_4_12.Amount = table_5_23
    local table_5_24: {number?} = {nil, nil, nil}
    local value_6_36: number = 100
    local value_7_24: number = 0
    local value_8_12: number = 0
    table_5_24[1], table_5_24[2], table_5_24[3] = value_6_36, value_7_24, value_8_12
    table_4_12.Rarity = table_5_24
    table_3_24.GodlyShards = table_4_12
    table_2_12.Rewards = table_3_24
    table_1.Eternal = table_2_12
    local table_2_13: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_25: {number?} = {nil, nil, nil}
    local value_4_13: number = 100
    local value_5_13: number = 0
    local value_6_37: number = 0
    table_3_25[1], table_3_25[2], table_3_25[3] = value_4_13, value_5_13, value_6_37
    table_2_13.CountChance = table_3_25
    local table_3_26: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_13: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_25: {number?} = {nil, nil}
    local value_6_38: number = 135
    local value_7_25: number = 135
    table_5_25[1], table_5_25[2] = value_6_38, value_7_25
    table_4_13.Amount = table_5_25
    local table_5_26: {number?} = {nil, nil, nil}
    local value_6_39: number = 100
    local value_7_26: number = 0
    local value_8_13: number = 0
    table_5_26[1], table_5_26[2], table_5_26[3] = value_6_39, value_7_26, value_8_13
    table_4_13.Rarity = table_5_26
    table_3_26.GodlyShards = table_4_13
    table_2_13.Rewards = table_3_26
    table_1.Clockwork = table_2_13
    local table_2_14: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_27: {number?} = {nil, nil, nil}
    local value_4_14: number = 100
    local value_5_14: number = 0
    local value_6_40: number = 0
    table_3_27[1], table_3_27[2], table_3_27[3] = value_4_14, value_5_14, value_6_40
    table_2_14.CountChance = table_3_27
    local table_3_28: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_14: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_27: {number?} = {nil, nil}
    local value_6_41: number = 110
    local value_7_27: number = 110
    table_5_27[1], table_5_27[2] = value_6_41, value_7_27
    table_4_14.Amount = table_5_27
    local table_5_28: {number?} = {nil, nil, nil}
    local value_6_42: number = 100
    local value_7_28: number = 0
    local value_8_14: number = 0
    table_5_28[1], table_5_28[2], table_5_28[3] = value_6_42, value_7_28, value_8_14
    table_4_14.Rarity = table_5_28
    table_3_28.GodlyShards = table_4_14
    table_2_14.Rewards = table_3_28
    table_1.Spider = table_2_14
    local table_2_15: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_29: {number?} = {nil, nil, nil}
    local value_4_15: number = 100
    local value_5_15: number = 0
    local value_6_43: number = 0
    table_3_29[1], table_3_29[2], table_3_29[3] = value_4_15, value_5_15, value_6_43
    table_2_15.CountChance = table_3_29
    local table_3_30: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_15: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_29: {number?} = {nil, nil}
    local value_6_44: number = 105
    local value_7_29: number = 105
    table_5_29[1], table_5_29[2] = value_6_44, value_7_29
    table_4_15.Amount = table_5_29
    local table_5_30: {number?} = {nil, nil, nil}
    local value_6_45: number = 100
    local value_7_30: number = 0
    local value_8_15: number = 0
    table_5_30[1], table_5_30[2], table_5_30[3] = value_6_45, value_7_30, value_8_15
    table_4_15.Rarity = table_5_30
    table_3_30.GodlyShards = table_4_15
    table_2_15.Rewards = table_3_30
    table_1.Pixel = table_2_15
end
do
    local table_2_16: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_31: {number?} = {nil, nil, nil}
    local value_4_16: number = 100
    local value_5_16: number = 0
    local value_6_46: number = 0
    table_3_31[1], table_3_31[2], table_3_31[3] = value_4_16, value_5_16, value_6_46
    table_2_16.CountChance = table_3_31
    local table_3_32: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_16: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_31: {number?} = {nil, nil}
    local value_6_47: number = 90
    local value_7_31: number = 90
    table_5_31[1], table_5_31[2] = value_6_47, value_7_31
    table_4_16.Amount = table_5_31
    local table_5_32: {number?} = {nil, nil, nil}
    local value_6_48: number = 100
    local value_7_32: number = 0
    local value_8_16: number = 0
    table_5_32[1], table_5_32[2], table_5_32[3] = value_6_48, value_7_32, value_8_16
    table_4_16.Rarity = table_5_32
    table_3_32.GodlyShards = table_4_16
    table_2_16.Rewards = table_3_32
    table_1.BattleAxe2 = table_2_16
    local table_2_17: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_33: {number?} = {nil, nil, nil}
    local value_4_17: number = 100
    local value_5_17: number = 0
    local value_6_49: number = 0
    table_3_33[1], table_3_33[2], table_3_33[3] = value_4_17, value_5_17, value_6_49
    table_2_17.CountChance = table_3_33
    local table_3_34: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_17: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_33: {number?} = {nil, nil}
    local value_6_50: number = 75
    local value_7_33: number = 75
    table_5_33[1], table_5_33[2] = value_6_50, value_7_33
    table_4_17.Amount = table_5_33
    local table_5_34: {number?} = {nil, nil, nil}
    local value_6_51: number = 100
    local value_7_34: number = 0
    local value_8_17: number = 0
    table_5_34[1], table_5_34[2], table_5_34[3] = value_6_51, value_7_34, value_8_17
    table_4_17.Rarity = table_5_34
    table_3_34.GodlyShards = table_4_17
    table_2_17.Rewards = table_3_34
    table_1.Hallow = table_2_17
    local table_2_18: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_35: {number?} = {nil, nil, nil}
    local value_4_18: number = 100
    local value_5_18: number = 0
    local value_6_52: number = 0
    table_3_35[1], table_3_35[2], table_3_35[3] = value_4_18, value_5_18, value_6_52
    table_2_18.CountChance = table_3_35
    local table_3_36: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_18: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_35: {number?} = {nil, nil}
    local value_6_53: number = 72
    local value_7_35: number = 72
    table_5_35[1], table_5_35[2] = value_6_53, value_7_35
    table_4_18.Amount = table_5_35
    local table_5_36: {number?} = {nil, nil, nil}
    local value_6_54: number = 100
    local value_7_36: number = 0
    local value_8_18: number = 0
    table_5_36[1], table_5_36[2], table_5_36[3] = value_6_54, value_7_36, value_8_18
    table_4_18.Rarity = table_5_36
    table_3_36.GodlyShards = table_4_18
    table_2_18.Rewards = table_3_36
    table_1.Amerilaser = table_2_18
    local table_2_19: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_37: {number?} = {nil, nil, nil}
    local value_4_19: number = 100
    local value_5_19: number = 0
    local value_6_55: number = 0
    table_3_37[1], table_3_37[2], table_3_37[3] = value_4_19, value_5_19, value_6_55
    table_2_19.CountChance = table_3_37
    local table_3_38: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_19: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_37: {number?} = {nil, nil}
    local value_6_56: number = 72
    local value_7_37: number = 72
    table_5_37[1], table_5_37[2] = value_6_56, value_7_37
    table_4_19.Amount = table_5_37
    local table_5_38: {number?} = {nil, nil, nil}
    local value_6_57: number = 100
    local value_7_38: number = 0
    local value_8_19: number = 0
    table_5_38[1], table_5_38[2], table_5_38[3] = value_6_57, value_7_38, value_8_19
    table_4_19.Rarity = table_5_38
    table_3_38.GodlyShards = table_4_19
    table_2_19.Rewards = table_3_38
    table_1.AmericaSword = table_2_19
    local table_2_20: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_39: {number?} = {nil, nil, nil}
    local value_4_20: number = 100
    local value_5_20: number = 0
    local value_6_58: number = 0
    table_3_39[1], table_3_39[2], table_3_39[3] = value_4_20, value_5_20, value_6_58
    table_2_20.CountChance = table_3_39
    local table_3_40: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_20: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_39: {number?} = {nil, nil}
    local value_6_59: number = 70
    local value_7_39: number = 70
    table_5_39[1], table_5_39[2] = value_6_59, value_7_39
    table_4_20.Amount = table_5_39
    local table_5_40: {number?} = {nil, nil, nil}
    local value_6_60: number = 100
    local value_7_40: number = 0
    local value_8_20: number = 0
    table_5_40[1], table_5_40[2], table_5_40[3] = value_6_60, value_7_40, value_8_20
    table_4_20.Rarity = table_5_40
    table_3_40.GodlyShards = table_4_20
    table_2_20.Rewards = table_3_40
    table_1.Blaster = table_2_20
end
do
    local table_2_21: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_41: {number?} = {nil, nil, nil}
    local value_4_21: number = 100
    local value_5_21: number = 0
    local value_6_61: number = 0
    table_3_41[1], table_3_41[2], table_3_41[3] = value_4_21, value_5_21, value_6_61
    table_2_21.CountChance = table_3_41
    local table_3_42: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_21: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_41: {number?} = {nil, nil}
    local value_6_62: number = 65
    local value_7_41: number = 65
    table_5_41[1], table_5_41[2] = value_6_62, value_7_41
    table_4_21.Amount = table_5_41
    local table_5_42: {number?} = {nil, nil, nil}
    local value_6_63: number = 100
    local value_7_42: number = 0
    local value_8_21: number = 0
    table_5_42[1], table_5_42[2], table_5_42[3] = value_6_63, value_7_42, value_8_21
    table_4_21.Rarity = table_5_42
    table_3_42.GodlyShards = table_4_21
    table_2_21.Rewards = table_3_42
    table_1.Luger = table_2_21
    local table_2_22: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_43: {number?} = {nil, nil, nil}
    local value_4_22: number = 100
    local value_5_22: number = 0
    local value_6_64: number = 0
    table_3_43[1], table_3_43[2], table_3_43[3] = value_4_22, value_5_22, value_6_64
    table_2_22.CountChance = table_3_43
    local table_3_44: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_22: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_43: {number?} = {nil, nil}
    local value_6_65: number = 60
    local value_7_43: number = 60
    table_5_43[1], table_5_43[2] = value_6_65, value_7_43
    table_4_22.Amount = table_5_43
    local table_5_44: {number?} = {nil, nil, nil}
    local value_6_66: number = 100
    local value_7_44: number = 0
    local value_8_22: number = 0
    table_5_44[1], table_5_44[2], table_5_44[3] = value_6_66, value_7_44, value_8_22
    table_4_22.Rarity = table_5_44
    table_3_44.GodlyShards = table_4_22
    table_2_22.Rewards = table_3_44
    table_1.GingerLuger = table_2_22
    local table_2_23: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_45: {number?} = {nil, nil, nil}
    local value_4_23: number = 100
    local value_5_23: number = 0
    local value_6_67: number = 0
    table_3_45[1], table_3_45[2], table_3_45[3] = value_4_23, value_5_23, value_6_67
    table_2_23.CountChance = table_3_45
    local table_3_46: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_23: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_45: {number?} = {nil, nil}
    local value_6_68: number = 55
    local value_7_45: number = 55
    table_5_45[1], table_5_45[2] = value_6_68, value_7_45
    table_4_23.Amount = table_5_45
    local table_5_46: {number?} = {nil, nil, nil}
    local value_6_69: number = 100
    local value_7_46: number = 0
    local value_8_23: number = 0
    table_5_46[1], table_5_46[2], table_5_46[3] = value_6_69, value_7_46, value_8_23
    table_4_23.Rarity = table_5_46
    table_3_46.GodlyShards = table_4_23
    table_2_23.Rewards = table_3_46
    table_1.Heat = table_2_23
    local table_2_24: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_47: {number?} = {nil, nil, nil}
    local value_4_24: number = 100
    local value_5_24: number = 0
    local value_6_70: number = 0
    table_3_47[1], table_3_47[2], table_3_47[3] = value_4_24, value_5_24, value_6_70
    table_2_24.CountChance = table_3_47
    local table_3_48: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_24: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_47: {number?} = {nil, nil}
    local value_6_71: number = 55
    local value_7_47: number = 55
    table_5_47[1], table_5_47[2] = value_6_71, value_7_47
    table_4_24.Amount = table_5_47
    local table_5_48: {number?} = {nil, nil, nil}
    local value_6_72: number = 100
    local value_7_48: number = 0
    local value_8_24: number = 0
    table_5_48[1], table_5_48[2], table_5_48[3] = value_6_72, value_7_48, value_8_24
    table_4_24.Rarity = table_5_48
    table_3_48.GodlyShards = table_4_24
    table_2_24.Rewards = table_3_48
    table_1.Tides = table_2_24
    local table_2_25: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_49: {number?} = {nil, nil, nil}
    local value_4_25: number = 100
    local value_5_25: number = 0
    local value_6_73: number = 0
    table_3_49[1], table_3_49[2], table_3_49[3] = value_4_25, value_5_25, value_6_73
    table_2_25.CountChance = table_3_49
    local table_3_50: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_25: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_49: {number?} = {nil, nil}
    local value_6_74: number = 48
    local value_7_49: number = 48
    table_5_49[1], table_5_49[2] = value_6_74, value_7_49
    table_4_25.Amount = table_5_49
    local table_5_50: {number?} = {nil, nil, nil}
    local value_6_75: number = 100
    local value_7_50: number = 0
    local value_8_25: number = 0
    table_5_50[1], table_5_50[2], table_5_50[3] = value_6_75, value_7_50, value_8_25
    table_4_25.Rarity = table_5_50
    table_3_50.GodlyShards = table_4_25
    table_2_25.Rewards = table_3_50
    table_1.Virtual = table_2_25
end
do
    local table_2_26: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_51: {number?} = {nil, nil, nil}
    local value_4_26: number = 100
    local value_5_26: number = 0
    local value_6_76: number = 0
    table_3_51[1], table_3_51[2], table_3_51[3] = value_4_26, value_5_26, value_6_76
    table_2_26.CountChance = table_3_51
    local table_3_52: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_26: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_51: {number?} = {nil, nil}
    local value_6_77: number = 38
    local value_7_51: number = 38
    table_5_51[1], table_5_51[2] = value_6_77, value_7_51
    table_4_26.Amount = table_5_51
    local table_5_52: {number?} = {nil, nil, nil}
    local value_6_78: number = 100
    local value_7_52: number = 0
    local value_8_26: number = 0
    table_5_52[1], table_5_52[2], table_5_52[3] = value_6_78, value_7_52, value_8_26
    table_4_26.Rarity = table_5_52
    table_3_52.GodlyShards = table_4_26
    table_2_26.Rewards = table_3_52
    table_1.Xmas = table_2_26
    local table_2_27: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_53: {number?} = {nil, nil, nil}
    local value_4_27: number = 100
    local value_5_27: number = 0
    local value_6_79: number = 0
    table_3_53[1], table_3_53[2], table_3_53[3] = value_4_27, value_5_27, value_6_79
    table_2_27.CountChance = table_3_53
    local table_3_54: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_27: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_53: {number?} = {nil, nil}
    local value_6_80: number = 35
    local value_7_53: number = 35
    table_5_53[1], table_5_53[2] = value_6_80, value_7_53
    table_4_27.Amount = table_5_53
    local table_5_54: {number?} = {nil, nil, nil}
    local value_6_81: number = 100
    local value_7_54: number = 0
    local value_8_27: number = 0
    table_5_54[1], table_5_54[2], table_5_54[3] = value_6_81, value_7_54, value_8_27
    table_4_27.Rarity = table_5_54
    table_3_54.GodlyShards = table_4_27
    table_2_27.Rewards = table_3_54
    table_1.Slasher = table_2_27
    local table_2_28: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_55: {number?} = {nil, nil, nil}
    local value_4_28: number = 100
    local value_5_28: number = 0
    local value_6_82: number = 0
    table_3_55[1], table_3_55[2], table_3_55[3] = value_4_28, value_5_28, value_6_82
    table_2_28.CountChance = table_3_55
    local table_3_56: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_28: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_55: {number?} = {nil, nil}
    local value_6_83: number = 32
    local value_7_55: number = 32
    table_5_55[1], table_5_55[2] = value_6_83, value_7_55
    table_4_28.Amount = table_5_55
    local table_5_56: {number?} = {nil, nil, nil}
    local value_6_84: number = 100
    local value_7_56: number = 0
    local value_8_28: number = 0
    table_5_56[1], table_5_56[2], table_5_56[3] = value_6_84, value_7_56, value_8_28
    table_4_28.Rarity = table_5_56
    table_3_56.GodlyShards = table_4_28
    table_2_28.Rewards = table_3_56
    table_1.Saw = table_2_28
    local table_2_29: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_57: {number?} = {nil, nil, nil}
    local value_4_29: number = 100
    local value_5_29: number = 0
    local value_6_85: number = 0
    table_3_57[1], table_3_57[2], table_3_57[3] = value_4_29, value_5_29, value_6_85
    table_2_29.CountChance = table_3_57
    local table_3_58: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_29: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_57: {number?} = {nil, nil}
    local value_6_86: number = 30
    local value_7_57: number = 30
    table_5_57[1], table_5_57[2] = value_6_86, value_7_57
    table_4_29.Amount = table_5_57
    local table_5_58: {number?} = {nil, nil, nil}
    local value_6_87: number = 100
    local value_7_58: number = 0
    local value_8_29: number = 0
    table_5_58[1], table_5_58[2], table_5_58[3] = value_6_87, value_7_58, value_8_29
    table_4_29.Rarity = table_5_58
    table_3_58.GodlyShards = table_4_29
    table_2_29.Rewards = table_3_58
    table_1.Laser = table_2_29
    local table_2_30: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_59: {number?} = {nil, nil, nil}
    local value_4_30: number = 100
    local value_5_30: number = 0
    local value_6_88: number = 0
    table_3_59[1], table_3_59[2], table_3_59[3] = value_4_30, value_5_30, value_6_88
    table_2_30.CountChance = table_3_59
    local table_3_60: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_30: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_59: {number?} = {nil, nil}
    local value_6_89: number = 28
    local value_7_59: number = 28
    table_5_59[1], table_5_59[2] = value_6_89, value_7_59
    table_4_30.Amount = table_5_59
    local table_5_60: {number?} = {nil, nil, nil}
    local value_6_90: number = 100
    local value_7_60: number = 0
    local value_8_30: number = 0
    table_5_60[1], table_5_60[2], table_5_60[3] = value_6_90, value_7_60, value_8_30
    table_4_30.Rarity = table_5_60
    table_3_60.GodlyShards = table_4_30
    table_2_30.Rewards = table_3_60
    table_1.Fang = table_2_30
end
do
    local table_2_31: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_61: {number?} = {nil, nil, nil}
    local value_4_31: number = 100
    local value_5_31: number = 0
    local value_6_91: number = 0
    table_3_61[1], table_3_61[2], table_3_61[3] = value_4_31, value_5_31, value_6_91
    table_2_31.CountChance = table_3_61
    local table_3_62: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_31: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_61: {number?} = {nil, nil}
    local value_6_92: number = 27
    local value_7_61: number = 27
    table_5_61[1], table_5_61[2] = value_6_92, value_7_61
    table_4_31.Amount = table_5_61
    local table_5_62: {number?} = {nil, nil, nil}
    local value_6_93: number = 100
    local value_7_62: number = 0
    local value_8_31: number = 0
    table_5_62[1], table_5_62[2], table_5_62[3] = value_6_93, value_7_62, value_8_31
    table_4_31.Rarity = table_5_62
    table_3_62.GodlyShards = table_4_31
    table_2_31.Rewards = table_3_62
    table_1.Shark = table_2_31
    local table_2_32: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_63: {number?} = {nil, nil, nil}
    local value_4_32: number = 100
    local value_5_32: number = 0
    local value_6_94: number = 0
    table_3_63[1], table_3_63[2], table_3_63[3] = value_4_32, value_5_32, value_6_94
    table_2_32.CountChance = table_3_63
    local table_3_64: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_32: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_63: {number?} = {nil, nil}
    local value_6_95: number = 25
    local value_7_63: number = 25
    table_5_63[1], table_5_63[2] = value_6_95, value_7_63
    table_4_32.Amount = table_5_63
    local table_5_64: {number?} = {nil, nil, nil}
    local value_6_96: number = 100
    local value_7_64: number = 0
    local value_8_32: number = 0
    table_5_64[1], table_5_64[2], table_5_64[3] = value_6_96, value_7_64, value_8_32
    table_4_32.Rarity = table_5_64
    table_3_64.GodlyShards = table_4_32
    table_2_32.Rewards = table_3_64
    table_1.Deathshard = table_2_32
    local table_2_33: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_65: {number?} = {nil, nil, nil}
    local value_4_33: number = 100
    local value_5_33: number = 0
    local value_6_97: number = 0
    table_3_65[1], table_3_65[2], table_3_65[3] = value_4_33, value_5_33, value_6_97
    table_2_33.CountChance = table_3_65
    local table_3_66: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_33: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_65: {number?} = {nil, nil}
    local value_6_98: number = 22
    local value_7_65: number = 22
    table_5_65[1], table_5_65[2] = value_6_98, value_7_65
    table_4_33.Amount = table_5_65
    local table_5_66: {number?} = {nil, nil, nil}
    local value_6_99: number = 100
    local value_7_66: number = 0
    local value_8_33: number = 0
    table_5_66[1], table_5_66[2], table_5_66[3] = value_6_99, value_7_66, value_8_33
    table_4_33.Rarity = table_5_66
    table_3_66.GodlyShards = table_4_33
    table_2_33.Rewards = table_3_66
    table_1.Pumpking = table_2_33
    local table_2_34: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_67: {number?} = {nil, nil, nil}
    local value_4_34: number = 100
    local value_5_34: number = 0
    local value_6_100: number = 0
    table_3_67[1], table_3_67[2], table_3_67[3] = value_4_34, value_5_34, value_6_100
    table_2_34.CountChance = table_3_67
    local table_3_68: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_34: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_67: {number?} = {nil, nil}
    local value_6_101: number = 22
    local value_7_67: number = 22
    table_5_67[1], table_5_67[2] = value_6_101, value_7_67
    table_4_34.Amount = table_5_67
    local table_5_68: {number?} = {nil, nil, nil}
    local value_6_102: number = 100
    local value_7_68: number = 0
    local value_8_34: number = 0
    table_5_68[1], table_5_68[2], table_5_68[3] = value_6_102, value_7_68, value_8_34
    table_4_34.Rarity = table_5_68
    table_3_68.GodlyShards = table_4_34
    table_2_34.Rewards = table_3_68
    table_1.WintersEdge = table_2_34
    local table_2_35: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_69: {number?} = {nil, nil, nil}
    local value_4_35: number = 100
    local value_5_35: number = 0
    local value_6_103: number = 0
    table_3_69[1], table_3_69[2], table_3_69[3] = value_4_35, value_5_35, value_6_103
    table_2_35.CountChance = table_3_69
    local table_3_70: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_35: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_69: {number?} = {nil, nil}
    local value_6_104: number = 20
    local value_7_69: number = 20
    table_5_69[1], table_5_69[2] = value_6_104, value_7_69
    table_4_35.Amount = table_5_69
    local table_5_70: {number?} = {nil, nil, nil}
    local value_6_105: number = 100
    local value_7_70: number = 0
    local value_8_35: number = 0
    table_5_70[1], table_5_70[2], table_5_70[3] = value_6_105, value_7_70, value_8_35
    table_4_35.Rarity = table_5_70
    table_3_70.GodlyShards = table_4_35
    table_2_35.Rewards = table_3_70
    table_1.Gingerblade = table_2_35
end
do
    local table_2_36: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_71: {number?} = {nil, nil, nil}
    local value_4_36: number = 100
    local value_5_36: number = 0
    local value_6_106: number = 0
    table_3_71[1], table_3_71[2], table_3_71[3] = value_4_36, value_5_36, value_6_106
    table_2_36.CountChance = table_3_71
    local table_3_72: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_36: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_71: {number?} = {nil, nil}
    local value_6_107: number = 16
    local value_7_71: number = 16
    table_5_71[1], table_5_71[2] = value_6_107, value_7_71
    table_4_36.Amount = table_5_71
    local table_5_72: {number?} = {nil, nil, nil}
    local value_6_108: number = 100
    local value_7_72: number = 0
    local value_8_36: number = 0
    table_5_72[1], table_5_72[2], table_5_72[3] = value_6_108, value_7_72, value_8_36
    table_4_36.Rarity = table_5_72
    table_3_72.GodlyShards = table_4_36
    table_2_36.Rewards = table_3_72
    table_1.IceDragon = table_2_36
    local table_2_37: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_73: {number?} = {nil, nil, nil}
    local value_4_37: number = 100
    local value_5_37: number = 0
    local value_6_109: number = 0
    table_3_73[1], table_3_73[2], table_3_73[3] = value_4_37, value_5_37, value_6_109
    table_2_37.CountChance = table_3_73
    local table_3_74: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_37: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_73: {number?} = {nil, nil}
    local value_6_110: number = 12
    local value_7_73: number = 12
    table_5_73[1], table_5_73[2] = value_6_110, value_7_73
    table_4_37.Amount = table_5_73
    local table_5_74: {number?} = {nil, nil, nil}
    local value_6_111: number = 100
    local value_7_74: number = 0
    local value_8_37: number = 0
    table_5_74[1], table_5_74[2], table_5_74[3] = value_6_111, value_7_74, value_8_37
    table_4_37.Rarity = table_5_74
    table_3_74.GodlyShards = table_4_37
    table_2_37.Rewards = table_3_74
    table_1.IceShard = table_2_37
    local table_2_38: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_75: {number?} = {nil, nil, nil}
    local value_4_38: number = 100
    local value_5_38: number = 0
    local value_6_112: number = 0
    table_3_75[1], table_3_75[2], table_3_75[3] = value_4_38, value_5_38, value_6_112
    table_2_38.CountChance = table_3_75
    local table_3_76: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_38: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_75: {number?} = {nil, nil}
    local value_6_113: number = 11
    local value_7_75: number = 11
    table_5_75[1], table_5_75[2] = value_6_113, value_7_75
    table_4_38.Amount = table_5_75
    local table_5_76: {number?} = {nil, nil, nil}
    local value_6_114: number = 100
    local value_7_76: number = 0
    local value_8_38: number = 0
    table_5_76[1], table_5_76[2], table_5_76[3] = value_6_114, value_7_76, value_8_38
    table_4_38.Rarity = table_5_76
    table_3_76.GodlyShards = table_4_38
    table_2_38.Rewards = table_3_76
    table_1.Frostsaber = table_2_38
    local table_2_39: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_77: {number?} = {nil, nil, nil}
    local value_4_39: number = 100
    local value_5_39: number = 0
    local value_6_115: number = 0
    table_3_77[1], table_3_77[2], table_3_77[3] = value_4_39, value_5_39, value_6_115
    table_2_39.CountChance = table_3_77
    local table_3_78: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_39: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_77: {number?} = {nil, nil}
    local value_6_116: number = 10
    local value_7_77: number = 10
    table_5_77[1], table_5_77[2] = value_6_116, value_7_77
    table_4_39.Amount = table_5_77
    local table_5_78: {number?} = {nil, nil, nil}
    local value_6_117: number = 100
    local value_7_78: number = 0
    local value_8_39: number = 0
    table_5_78[1], table_5_78[2], table_5_78[3] = value_6_117, value_7_78, value_8_39
    table_4_39.Rarity = table_5_78
    table_3_78.GodlyShards = table_4_39
    table_2_39.Rewards = table_3_78
    table_1.HallowsBlade = table_2_39
    local table_2_40: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_79: {number?} = {nil, nil, nil}
    local value_4_40: number = 100
    local value_5_40: number = 0
    local value_6_118: number = 0
    table_3_79[1], table_3_79[2], table_3_79[3] = value_4_40, value_5_40, value_6_118
    table_2_40.CountChance = table_3_79
    local table_3_80: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_40: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_79: {number?} = {nil, nil}
    local value_6_119: number = 10
    local value_7_79: number = 10
    table_5_79[1], table_5_79[2] = value_6_119, value_7_79
    table_4_40.Amount = table_5_79
    local table_5_80: {number?} = {nil, nil, nil}
    local value_6_120: number = 100
    local value_7_80: number = 0
    local value_8_40: number = 0
    table_5_80[1], table_5_80[2], table_5_80[3] = value_6_120, value_7_80, value_8_40
    table_4_40.Rarity = table_5_80
    table_3_80.GodlyShards = table_4_40
    table_2_40.Rewards = table_3_80
    table_1.Snowflake = table_2_40
end
do
    local table_2_41: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_81: {number?} = {nil, nil, nil}
    local value_4_41: number = 100
    local value_5_41: number = 0
    local value_6_121: number = 0
    table_3_81[1], table_3_81[2], table_3_81[3] = value_4_41, value_5_41, value_6_121
    table_2_41.CountChance = table_3_81
    local table_3_82: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_41: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_81: {number?} = {nil, nil}
    local value_6_122: number = 8
    local value_7_81: number = 8
    table_5_81[1], table_5_81[2] = value_6_122, value_7_81
    table_4_41.Amount = table_5_81
    local table_5_82: {number?} = {nil, nil, nil}
    local value_6_123: number = 100
    local value_7_82: number = 0
    local value_8_41: number = 0
    table_5_82[1], table_5_82[2], table_5_82[3] = value_6_123, value_7_82, value_8_41
    table_4_41.Rarity = table_5_82
    table_3_82.GodlyShards = table_4_41
    table_2_41.Rewards = table_3_82
    table_1.BattleAxe = table_2_41
    local table_2_42: { CountChance: number | {number?}, Rewards: number | { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } | { GodlyShards: { Amount: {number?}, Rarity: {number?} } } } = {
        CountChance = 0,
        Rewards = 0,
    }
    local table_3_83: {number?} = {nil, nil, nil}
    local value_4_42: number = 100
    local value_5_42: number = 0
    local value_6_124: number = 0
    table_3_83[1], table_3_83[2], table_3_83[3] = value_4_42, value_5_42, value_6_124
    table_2_42.CountChance = table_3_83
    local table_3_84: { GodlyShards: nil | { Amount: number | {number?}, Rarity: number | {number?} } | { Amount: {number?}, Rarity: {number?} } } = {
        [("GodlyShards")] = nil,
    }
    local table_4_42: { Amount: number | {number?}, Rarity: number | {number?} } = {
        Amount = 0,
        Rarity = 0,
    }
    local table_5_83: {number?} = {nil, nil}
    local value_6_125: number = 3
    local value_7_83: number = 3
    table_5_83[1], table_5_83[2] = value_6_125, value_7_83
    table_4_42.Amount = table_5_83
    local table_5_84: {number?} = {nil, nil, nil}
    local value_6_126: number = 100
    local value_7_84: number = 0
    local value_8_42: number = 0
    table_5_84[1], table_5_84[2], table_5_84[3] = value_6_126, value_7_84, value_8_42
    table_4_42.Rarity = table_5_84
    table_3_84.GodlyShards = table_4_42
    table_2_42.Rewards = table_3_84
    table_1.Nightblade = table_2_42
    local table_2_43 = {}
    table_1.Xbox = table_2_43
end

return table_1
