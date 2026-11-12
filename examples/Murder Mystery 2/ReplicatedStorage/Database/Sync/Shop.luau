--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Effects: nil | { BlueFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Burn: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Dual: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Electric: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Ghostify: nil | { LayoutOrder: number, Price: { Coins: number, Gems: number } } | { LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } }, GreenFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Heartify: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Knifeception: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Musical: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, PinkFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Radioactive: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } } | { BlueFire: { LayoutOrder: number, Price: { Gems: number } }, Burn: { LayoutOrder: number, Price: { Coins: number } }, Dual: { LayoutOrder: number, Price: { Gems: number } }, Electric: { LayoutOrder: number, Price: { Gems: number } }, Ghostify: { LayoutOrder: number, Price: { Coins: number, Gems: number } }, GreenFire: { LayoutOrder: number, Price: { Gems: number } }, Heartify: { LayoutOrder: number, Price: { Coins: number } }, Knifeception: { LayoutOrder: number, Price: { Gems: number } }, Musical: { LayoutOrder: number, Price: { Coins: number } }, PinkFire: { LayoutOrder: number, Price: { Gems: number } }, Radioactive: { LayoutOrder: number, Price: { Coins: number } } },
    Emotes: nil | { ChocolateMilk: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, FakeBomb: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Fireflies: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, GGSign: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, IceCream: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Pizza: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, SprayPaint: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, Teddy: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, dab: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, floss: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, ninja: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, sit: nil | { Price: nil | { Coins: number, Description: string } | { Coins: number?, Description: string? } } | { Price: { Coins: number, Description: string } }, zen: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } } } | { ChocolateMilk: { DataType: string, Description: string, Price: { Coins: number } }, FakeBomb: { DataType: string, Description: string, Price: { Coins: number } }, Fireflies: { DataType: string, Description: string, Price: { Coins: number } }, GGSign: { DataType: string, Description: string, Price: { Gems: number } }, IceCream: { DataType: string, Description: string, Price: { Coins: number } }, Pizza: { DataType: string, Description: string, Price: { Coins: number } }, SprayPaint: { DataType: string, Description: string, Price: { Gems: number } }, Teddy: { DataType: string, Description: string, Price: { Coins: number } }, dab: { Description: string, Price: { Coins: number } }, floss: { Description: string, Price: { Gems: number } }, ninja: { Description: string, Price: { Coins: number } }, sit: { Price: { Coins: number, Description: string } }, zen: { Description: string, Price: { Gems: number } } },
    Perks: nil | { FakeGun: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ghost: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Haste: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ninja: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sleight: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sprint: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Trap: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Xray: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } } } | { FakeGun: { Price: { Coins: number, Gems: number } }, Ghost: { Price: { Coins: number, Gems: number } }, Haste: { Price: { Coins: number, Gems: number } }, Ninja: { Price: { Coins: number, Gems: number } }, Sleight: { Price: { Coins: number, Gems: number } }, Sprint: { Price: { Coins: number, Gems: number } }, Trap: { Price: { Coins: number, Gems: number } }, Xray: { Price: { Coins: number, Gems: number } } },
    Pets: nil | { Egg: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } } | { Egg: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number } } },
    Radios: nil | { BlueSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, BluesteelRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, Boombastic: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, CamoRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, DiamondRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Dubstep: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, FadeRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Flaming: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Gold: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, GreenSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Omega: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, PinkSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RainbowRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RedSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } } } | { BlueSparkleRadio: { Price: { Gems: number } }, BluesteelRadio: { Price: { Coins: number } }, Boombastic: { Price: { Coins: number } }, CamoRadio: { Price: { Coins: number } }, DiamondRadio: { Price: { Gems: number } }, Dubstep: { Price: { Coins: number } }, FadeRadio: { Price: { Gems: number } }, Flaming: { Price: { Gems: number } }, Gold: { Price: { Coins: number } }, GreenSparkleRadio: { Price: { Gems: number } }, Omega: { Price: { Gems: number } }, PinkSparkleRadio: { Price: { Gems: number } }, RainbowRadio: { Price: { Gems: number } }, RedSparkleRadio: { Price: { Gems: number } } },
    Weapons: nil | { GunBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, Key: nil | { DataType: string, Description: string, LayoutOrder: number, OwnedType: string, Price: { Gems: number } } | { DataType: string?, Description: string?, LayoutOrder: number?, OwnedType: string?, Price: nil | { Gems: number } | { Gems: number? } }, KnifeBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox4: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox5: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, ["MLG Box"]: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } } | { GunBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, GunBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, GunBox3: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, Key: { DataType: string, Description: string, LayoutOrder: number, OwnedType: string, Price: { Gems: number } }, KnifeBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox3: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox4: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox5: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, ["MLG Box"]: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, MysteryBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, MysteryBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } },
}

local table_1: { Effects: nil | { BlueFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Burn: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Dual: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Electric: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Ghostify: nil | { LayoutOrder: number, Price: { Coins: number, Gems: number } } | { LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } }, GreenFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Heartify: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Knifeception: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Musical: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, PinkFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Radioactive: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } } | { BlueFire: { LayoutOrder: number, Price: { Gems: number } }, Burn: { LayoutOrder: number, Price: { Coins: number } }, Dual: { LayoutOrder: number, Price: { Gems: number } }, Electric: { LayoutOrder: number, Price: { Gems: number } }, Ghostify: { LayoutOrder: number, Price: { Coins: number, Gems: number } }, GreenFire: { LayoutOrder: number, Price: { Gems: number } }, Heartify: { LayoutOrder: number, Price: { Coins: number } }, Knifeception: { LayoutOrder: number, Price: { Gems: number } }, Musical: { LayoutOrder: number, Price: { Coins: number } }, PinkFire: { LayoutOrder: number, Price: { Gems: number } }, Radioactive: { LayoutOrder: number, Price: { Coins: number } } }, Emotes: nil | { ChocolateMilk: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, FakeBomb: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Fireflies: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, GGSign: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, IceCream: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Pizza: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, SprayPaint: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, Teddy: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, dab: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, floss: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, ninja: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, sit: nil | { Price: nil | { Coins: number, Description: string } | { Coins: number?, Description: string? } } | { Price: { Coins: number, Description: string } }, zen: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } } } | { ChocolateMilk: { DataType: string, Description: string, Price: { Coins: number } }, FakeBomb: { DataType: string, Description: string, Price: { Coins: number } }, Fireflies: { DataType: string, Description: string, Price: { Coins: number } }, GGSign: { DataType: string, Description: string, Price: { Gems: number } }, IceCream: { DataType: string, Description: string, Price: { Coins: number } }, Pizza: { DataType: string, Description: string, Price: { Coins: number } }, SprayPaint: { DataType: string, Description: string, Price: { Gems: number } }, Teddy: { DataType: string, Description: string, Price: { Coins: number } }, dab: { Description: string, Price: { Coins: number } }, floss: { Description: string, Price: { Gems: number } }, ninja: { Description: string, Price: { Coins: number } }, sit: { Price: { Coins: number, Description: string } }, zen: { Description: string, Price: { Gems: number } } }, Perks: nil | { FakeGun: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ghost: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Haste: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ninja: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sleight: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sprint: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Trap: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Xray: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } } } | { FakeGun: { Price: { Coins: number, Gems: number } }, Ghost: { Price: { Coins: number, Gems: number } }, Haste: { Price: { Coins: number, Gems: number } }, Ninja: { Price: { Coins: number, Gems: number } }, Sleight: { Price: { Coins: number, Gems: number } }, Sprint: { Price: { Coins: number, Gems: number } }, Trap: { Price: { Coins: number, Gems: number } }, Xray: { Price: { Coins: number, Gems: number } } }, Pets: nil | { Egg: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } } | { Egg: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number } } }, Radios: nil | { BlueSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, BluesteelRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, Boombastic: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, CamoRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, DiamondRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Dubstep: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, FadeRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Flaming: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Gold: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, GreenSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Omega: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, PinkSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RainbowRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RedSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } } } | { BlueSparkleRadio: { Price: { Gems: number } }, BluesteelRadio: { Price: { Coins: number } }, Boombastic: { Price: { Coins: number } }, CamoRadio: { Price: { Coins: number } }, DiamondRadio: { Price: { Gems: number } }, Dubstep: { Price: { Coins: number } }, FadeRadio: { Price: { Gems: number } }, Flaming: { Price: { Gems: number } }, Gold: { Price: { Coins: number } }, GreenSparkleRadio: { Price: { Gems: number } }, Omega: { Price: { Gems: number } }, PinkSparkleRadio: { Price: { Gems: number } }, RainbowRadio: { Price: { Gems: number } }, RedSparkleRadio: { Price: { Gems: number } } }, Weapons: nil | { GunBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, Key: nil | { DataType: string, Description: string, LayoutOrder: number, OwnedType: string, Price: { Gems: number } } | { DataType: string?, Description: string?, LayoutOrder: number?, OwnedType: string?, Price: nil | { Gems: number } | { Gems: number? } }, KnifeBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox4: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox5: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, ["MLG Box"]: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } } | { GunBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, GunBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, GunBox3: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, Key: { DataType: string, Description: string, LayoutOrder: number, OwnedType: string, Price: { Gems: number } }, KnifeBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox3: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox4: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, KnifeBox5: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, ["MLG Box"]: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, MysteryBox1: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } }, MysteryBox2: { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } } } = {
    [("Weapons")] = nil,
    [("Weapons")] = nil,
    [("Weapons")] = nil,
    [("Weapons")] = nil,
    [("Weapons")] = nil,
}
do
    local table_2: { GunBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, GunBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, Key: nil | { DataType: string, Description: string, LayoutOrder: number, OwnedType: string, Price: { Gems: number } } | { DataType: string?, Description: string?, LayoutOrder: number?, OwnedType: string?, Price: nil | { Gems: number } | { Gems: number? } }, KnifeBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox3: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox4: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, KnifeBox5: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, ["MLG Box"]: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox1: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } }, MysteryBox2: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } } = {
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
        [("MysteryBox1")] = nil,
    }
    local table_3: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4: string = "MysteryBox"
    table_3.DataType = value_4
    local table_4: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5: number = 1000
    table_4.Coins = value_5
    local value_5_2: number = 100
    table_4.Gems = value_5_2
    local value_5_3: number = 1
    table_4.Key = value_5_3
    table_3.Price = table_4
    local value_4_2: number = 100
    table_3.LayoutOrder = value_4_2
    table_2.MysteryBox1 = table_3
    local table_3_2: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_3: string = "MysteryBox"
    table_3_2.DataType = value_4_3
    local table_4_2: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_4: number = 1000
    table_4_2.Coins = value_5_4
    local value_5_5: number = 100
    table_4_2.Gems = value_5_5
    local value_5_6: number = 1
    table_4_2.Key = value_5_6
    table_3_2.Price = table_4_2
    local value_4_4: number = 100
    table_3_2.LayoutOrder = value_4_4
    table_2.MysteryBox2 = table_3_2
    local table_3_3: { DataType: string?, Description: string?, LayoutOrder: number?, OwnedType: string?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
        [("Description")] = nil,
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_5: string = "Can be used once to open a mystery box. Tradeable!"
    table_3_3.Description = value_4_5
    local value_4_6: string = "Item"
    table_3_3.DataType = value_4_6
    local value_4_7: string = "Weapons"
    table_3_3.OwnedType = value_4_7
    local table_4_3: { Gems: number? } = {[("Gems")] = nil}
    local value_5_7: number = 125
    table_4_3.Gems = value_5_7
    table_3_3.Price = table_4_3
    local value_4_8: number = 200
    table_3_3.LayoutOrder = value_4_8
    table_2.Key = table_3_3
    local table_3_4: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_9: string = "MysteryBox"
    table_3_4.DataType = value_4_9
    local table_4_4: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_8: number = 1000
    table_4_4.Coins = value_5_8
    local value_5_9: number = 100
    table_4_4.Gems = value_5_9
    local value_5_10: number = 1
    table_4_4.Key = value_5_10
    table_3_4.Price = table_4_4
    local value_4_10: number = 301
    table_3_4.LayoutOrder = value_4_10
    table_2.KnifeBox1 = table_3_4
    local table_3_5: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_11: string = "MysteryBox"
    table_3_5.DataType = value_4_11
    local table_4_5: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_11: number = 1000
    table_4_5.Coins = value_5_11
    local value_5_12: number = 100
    table_4_5.Gems = value_5_12
    local value_5_13: number = 1
    table_4_5.Key = value_5_13
    table_3_5.Price = table_4_5
    local value_4_12: number = 302
    table_3_5.LayoutOrder = value_4_12
    table_2.KnifeBox2 = table_3_5
    local table_3_6: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_13: string = "MysteryBox"
    table_3_6.DataType = value_4_13
    local table_4_6: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_14: number = 1000
    table_4_6.Coins = value_5_14
    local value_5_15: number = 100
    table_4_6.Gems = value_5_15
    local value_5_16: number = 1
    table_4_6.Key = value_5_16
    table_3_6.Price = table_4_6
    local value_4_14: number = 303
    table_3_6.LayoutOrder = value_4_14
    table_2.KnifeBox3 = table_3_6
    local table_3_7: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_15: string = "MysteryBox"
    table_3_7.DataType = value_4_15
    local table_4_7: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_17: number = 1000
    table_4_7.Coins = value_5_17
    local value_5_18: number = 100
    table_4_7.Gems = value_5_18
    local value_5_19: number = 1
    table_4_7.Key = value_5_19
    table_3_7.Price = table_4_7
    local value_4_16: number = 304
    table_3_7.LayoutOrder = value_4_16
    table_2.KnifeBox4 = table_3_7
    local table_3_8: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_17: string = "MysteryBox"
    table_3_8.DataType = value_4_17
    local table_4_8: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_20: number = 1000
    table_4_8.Coins = value_5_20
    local value_5_21: number = 100
    table_4_8.Gems = value_5_21
    local value_5_22: number = 1
    table_4_8.Key = value_5_22
    table_3_8.Price = table_4_8
    local value_4_18: number = 305
    table_3_8.LayoutOrder = value_4_18
    table_2.KnifeBox5 = table_3_8
    local table_3_9: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_19: string = "MysteryBox"
    table_3_9.DataType = value_4_19
    local table_4_9: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_23: number = 1000
    table_4_9.Coins = value_5_23
    local value_5_24: number = 100
    table_4_9.Gems = value_5_24
    local value_5_25: number = 1
    table_4_9.Key = value_5_25
    table_3_9.Price = table_4_9
    local value_4_20: number = 306
    table_3_9.LayoutOrder = value_4_20
    table_2["MLG Box"] = table_3_9
    local table_3_10: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_21: string = "MysteryBox"
    table_3_10.DataType = value_4_21
    local table_4_10: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_26: number = 1000
    table_4_10.Coins = value_5_26
    local value_5_27: number = 100
    table_4_10.Gems = value_5_27
    local value_5_28: number = 1
    table_4_10.Key = value_5_28
    table_3_10.Price = table_4_10
    local value_4_22: number = 401
    table_3_10.LayoutOrder = value_4_22
    table_2.GunBox1 = table_3_10
    local table_3_11: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_23: string = "MysteryBox"
    table_3_11.DataType = value_4_23
    local table_4_11: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_29: number = 1000
    table_4_11.Coins = value_5_29
    local value_5_30: number = 100
    table_4_11.Gems = value_5_30
    local value_5_31: number = 1
    table_4_11.Key = value_5_31
    table_3_11.Price = table_4_11
    local value_4_24: number = 402
    table_3_11.LayoutOrder = value_4_24
    table_2.GunBox2 = table_3_11
    local table_3_12: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_25: string = "MysteryBox"
    table_3_12.DataType = value_4_25
    local table_4_12: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_32: number = 1000
    table_4_12.Coins = value_5_32
    local value_5_33: number = 100
    table_4_12.Gems = value_5_33
    local value_5_34: number = 1
    table_4_12.Key = value_5_34
    table_3_12.Price = table_4_12
    local value_4_26: number = 403
    table_3_12.LayoutOrder = value_4_26
    table_2.GunBox3 = table_3_12
    table_1.Weapons = table_2
end
do
    local table_2_2: { BlueFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Burn: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Dual: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Electric: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Ghostify: nil | { LayoutOrder: number, Price: { Coins: number, Gems: number } } | { LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } }, GreenFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Heartify: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, Knifeception: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Musical: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } }, PinkFire: nil | { LayoutOrder: number, Price: { Gems: number } } | { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } }, Radioactive: nil | { LayoutOrder: number, Price: { Coins: number } } | { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } } = {
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
        [("Knifeception")] = nil,
    }
    local table_3_13: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_13: { Gems: number? } = {[("Gems")] = nil}
    local value_5_35: number = 300
    table_4_13.Gems = value_5_35
    table_3_13.Price = table_4_13
    local value_4_27: number = 900
    table_3_13.LayoutOrder = value_4_27
    table_2_2.Knifeception = table_3_13
    local table_3_14: { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_14: { Coins: number? } = {[("Coins")] = nil}
    local value_5_36: number = 4000
    table_4_14.Coins = value_5_36
    table_3_14.Price = table_4_14
    local value_4_28: number = 1500
    table_3_14.LayoutOrder = value_4_28
    table_2_2.Burn = table_3_14
    local table_3_15: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_15: { Gems: number? } = {[("Gems")] = nil}
    local value_5_37: number = 800
    table_4_15.Gems = value_5_37
    table_3_15.Price = table_4_15
    local value_4_29: number = 1010
    table_3_15.LayoutOrder = value_4_29
    table_2_2.BlueFire = table_3_15
    local table_3_16: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_16: { Gems: number? } = {[("Gems")] = nil}
    local value_5_38: number = 800
    table_4_16.Gems = value_5_38
    table_3_16.Price = table_4_16
    local value_4_30: number = 1020
    table_3_16.LayoutOrder = value_4_30
    table_2_2.PinkFire = table_3_16
    local table_3_17: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_17: { Gems: number? } = {[("Gems")] = nil}
    local value_5_39: number = 800
    table_4_17.Gems = value_5_39
    table_3_17.Price = table_4_17
    local value_4_31: number = 1030
    table_3_17.LayoutOrder = value_4_31
    table_2_2.GreenFire = table_3_17
    local table_3_18: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_18: { Gems: number? } = {[("Gems")] = nil}
    local value_5_40: number = 900
    table_4_18.Gems = value_5_40
    table_3_18.Price = table_4_18
    local value_4_32: number = 1300
    table_3_18.LayoutOrder = value_4_32
    table_2_2.Dual = table_3_18
    local table_3_19: { LayoutOrder: number?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_19: { Gems: number? } = {[("Gems")] = nil}
    local value_5_41: number = 1000
    table_4_19.Gems = value_5_41
    table_3_19.Price = table_4_19
    local value_4_33: number = 1400
    table_3_19.LayoutOrder = value_4_33
    table_2_2.Electric = table_3_19
    local table_3_20: { LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_20: { Coins: number?, Gems: number? } = {[("Gems")] = nil, [("Gems")] = nil}
    local value_5_42: number = 200
    table_4_20.Gems = value_5_42
    local value_5_43: number = 2000
    table_4_20.Coins = value_5_43
    table_3_20.Price = table_4_20
    local value_4_34: number = 2000
    table_3_20.LayoutOrder = value_4_34
    table_2_2.Ghostify = table_3_20
    local table_3_21: { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_21: { Coins: number? } = {[("Coins")] = nil}
    local value_5_44: number = 2400
    table_4_21.Coins = value_5_44
    table_3_21.Price = table_4_21
    local value_4_35: number = 2100
    table_3_21.LayoutOrder = value_4_35
    table_2_2.Heartify = table_3_21
    local table_3_22: { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_22: { Coins: number? } = {[("Coins")] = nil}
    local value_5_45: number = 1600
    table_4_22.Coins = value_5_45
    table_3_22.Price = table_4_22
    local value_4_36: number = 1890
    table_3_22.LayoutOrder = value_4_36
    table_2_2.Radioactive = table_3_22
    local table_3_23: { LayoutOrder: number?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
        [("Price")] = nil,
    }
    local table_4_23: { Coins: number? } = {[("Coins")] = nil}
    local value_5_46: number = 2000
    table_4_23.Coins = value_5_46
    table_3_23.Price = table_4_23
    local value_4_37: number = 1899
    table_3_23.LayoutOrder = value_4_37
    table_2_2.Musical = table_3_23
    table_1.Effects = table_2_2
    local table_2_3: { FakeGun: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ghost: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Haste: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Ninja: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sleight: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Sprint: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Trap: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } }, Xray: nil | { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } | { Price: { Coins: number, Gems: number } } } = {
        [("Sleight")] = nil,
        [("Sleight")] = nil,
        [("Sleight")] = nil,
        [("Sleight")] = nil,
        [("Sleight")] = nil,
    }
    local table_3_24: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_24: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_47: number = 1000
    table_4_24.Coins = value_5_47
    local value_5_48: number = 100
    table_4_24.Gems = value_5_48
    table_3_24.Price = table_4_24
    table_2_3.Sleight = table_3_24
    local table_3_25: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_25: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_49: number = 1000
    table_4_25.Coins = value_5_49
    local value_5_50: number = 100
    table_4_25.Gems = value_5_50
    table_3_25.Price = table_4_25
    table_2_3.Ninja = table_3_25
    local table_3_26: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_26: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_51: number = 3000
    table_4_26.Coins = value_5_51
    local value_5_52: number = 400
    table_4_26.Gems = value_5_52
    table_3_26.Price = table_4_26
    table_2_3.FakeGun = table_3_26
    local table_3_27: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_27: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_53: number = 3000
    table_4_27.Coins = value_5_53
    local value_5_54: number = 400
    table_4_27.Gems = value_5_54
    table_3_27.Price = table_4_27
    table_2_3.Haste = table_3_27
    local table_3_28: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_28: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_55: number = 3000
    table_4_28.Coins = value_5_55
    local value_5_56: number = 400
    table_4_28.Gems = value_5_56
    table_3_28.Price = table_4_28
    table_2_3.Sprint = table_3_28
    local table_3_29: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_29: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_57: number = 3000
    table_4_29.Coins = value_5_57
    local value_5_58: number = 400
    table_4_29.Gems = value_5_58
    table_3_29.Price = table_4_29
    table_2_3.Trap = table_3_29
    local table_3_30: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_30: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_59: number = 6000
    table_4_30.Coins = value_5_59
    local value_5_60: number = 800
    table_4_30.Gems = value_5_60
    table_3_30.Price = table_4_30
    table_2_3.Ghost = table_3_30
    local table_3_31: { Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_31: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_61: number = 6000
    table_4_31.Coins = value_5_61
    local value_5_62: number = 800
    table_4_31.Gems = value_5_62
    table_3_31.Price = table_4_31
    table_2_3.Xray = table_3_31
    table_1.Perks = table_2_3
end
do
    local table_2_4: { ChocolateMilk: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, FakeBomb: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Fireflies: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, GGSign: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, IceCream: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, Pizza: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, SprayPaint: nil | { DataType: string, Description: string, Price: { Gems: number } } | { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, Teddy: nil | { DataType: string, Description: string, Price: { Coins: number } } | { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, dab: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, floss: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } }, ninja: nil | { Description: string, Price: { Coins: number } } | { Description: string?, Price: nil | { Coins: number } | { Coins: number? } }, sit: nil | { Price: nil | { Coins: number, Description: string } | { Coins: number?, Description: string? } } | { Price: { Coins: number, Description: string } }, zen: nil | { Description: string, Price: { Gems: number } } | { Description: string?, Price: nil | { Gems: number } | { Gems: number? } } } = {
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
        [("sit")] = nil,
    }
    local table_3_32: { Price: nil | { Coins: number, Description: string } | { Coins: number?, Description: string? } } = {
        [("Price")] = nil,
    }
    local table_4_32: { Coins: number?, Description: string? } = {
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_5_63: string = "Have a seat after a long day of coin-collecting."
    table_4_32.Description = value_5_63
    local value_5_64: number = 800
    table_4_32.Coins = value_5_64
    table_3_32.Price = table_4_32
    table_2_4.sit = table_3_32
    local table_3_33: { Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_38: string = "Embrace the shadow of a ninja with this flexible pose."
    table_3_33.Description = value_4_38
    local table_4_33: { Coins: number? } = {[("Coins")] = nil}
    local value_5_65: number = 2600
    table_4_33.Coins = value_5_65
    table_3_33.Price = table_4_33
    table_2_4.ninja = table_3_33
    local table_3_34: { Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_39: string = "Hit a HUGE dab on your enemies!"
    table_3_34.Description = value_4_39
    local table_4_34: { Coins: number? } = {[("Coins")] = nil}
    local value_5_66: number = 2800
    table_4_34.Coins = value_5_66
    table_3_34.Price = table_4_34
    table_2_4.dab = table_3_34
    local table_3_35: { Description: string?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_40: string = "Experience tranquility with this relaxing zen pose."
    table_3_35.Description = value_4_40
    local table_4_35: { Gems: number? } = {[("Gems")] = nil}
    local value_5_67: number = 800
    table_4_35.Gems = value_5_67
    table_3_35.Price = table_4_35
    table_2_4.zen = table_3_35
    local table_3_36: { Description: string?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_41: string = "FLOSS on your enemies!"
    table_3_36.Description = value_4_41
    local table_4_36: { Gems: number? } = {[("Gems")] = nil}
    local value_5_68: number = 750
    table_4_36.Gems = value_5_68
    table_3_36.Price = table_4_36
    table_2_4.floss = table_3_36
    local table_3_37: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_42: string = "Release a jar of fireflies."
    table_3_37.Description = value_4_42
    local value_4_43: string = "Toys"
    table_3_37.DataType = value_4_43
    local table_4_37: { Coins: number? } = {[("Coins")] = nil}
    local value_5_69: number = 1500
    table_4_37.Coins = value_5_69
    table_3_37.Price = table_4_37
    table_2_4.Fireflies = table_3_37
    local table_3_38: { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Description")] = nil,
        [("Description")] = nil,
        [("Description")] = nil,
    }
    local value_4_44: string = "Good game!"
    table_3_38.Description = value_4_44
    local value_4_45: string = "Toys"
    table_3_38.DataType = value_4_45
    local table_4_38: { Gems: number? } = {[("Gems")] = nil}
    local value_5_70: number = 100
    table_4_38.Gems = value_5_70
    table_3_38.Price = table_4_38
    table_2_4.GGSign = table_3_38
    local table_3_39: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_46: string = "Toys"
    table_3_39.DataType = value_4_46
    local value_4_47: string = "Relax after a long day of unboxing crates with a cool glass of chocolate milk."
    table_3_39.Description = value_4_47
    local table_4_39: { Coins: number? } = {[("Coins")] = nil}
    local value_5_71: number = 400
    table_4_39.Coins = value_5_71
    table_3_39.Price = table_4_39
    table_2_4.ChocolateMilk = table_3_39
    local table_3_40: { DataType: string?, Description: string?, Price: nil | { Gems: number } | { Gems: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_48: string = "Toys"
    table_3_40.DataType = value_4_48
    local value_4_49: string = "Spray paint your favorite decals on the walls."
    table_3_40.Description = value_4_49
    local table_4_40: { Gems: number? } = {[("Gems")] = nil}
    local value_5_72: number = 750
    table_4_40.Gems = value_5_72
    table_3_40.Price = table_4_40
    table_2_4.SprayPaint = table_3_40
    local table_3_41: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_50: string = "Toys"
    table_3_41.DataType = value_4_50
    local value_4_51: string = "Prank your friends with this confetti bomb!"
    table_3_41.Description = value_4_51
    local table_4_41: { Coins: number? } = {[("Coins")] = nil}
    local value_5_73: number = 4800
    table_4_41.Coins = value_5_73
    table_3_41.Price = table_4_41
    table_2_4.FakeBomb = table_3_41
    local table_3_42: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_52: string = "Toys"
    table_3_42.DataType = value_4_52
    local value_4_53: string = "Yummy!"
    table_3_42.Description = value_4_53
    local table_4_42: { Coins: number? } = {[("Coins")] = nil}
    local value_5_74: number = 400
    table_4_42.Coins = value_5_74
    table_3_42.Price = table_4_42
    table_2_4.IceCream = table_3_42
    local table_3_43: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_54: string = "Toys"
    table_3_43.DataType = value_4_54
    local value_4_55: string = "Pizza = delicious."
    table_3_43.Description = value_4_55
    local table_4_43: { Coins: number? } = {[("Coins")] = nil}
    local value_5_75: number = 400
    table_4_43.Coins = value_5_75
    table_3_43.Price = table_4_43
    table_2_4.Pizza = table_3_43
    local table_3_44: { DataType: string?, Description: string?, Price: nil | { Coins: number } | { Coins: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_56: string = "Toys"
    table_3_44.DataType = value_4_56
    local value_4_57: string = "He will always love you forever."
    table_3_44.Description = value_4_57
    local table_4_44: { Coins: number? } = {[("Coins")] = nil}
    local value_5_76: number = 600
    table_4_44.Coins = value_5_76
    table_3_44.Price = table_4_44
    table_2_4.Teddy = table_3_44
    table_1.Emotes = table_2_4
end
do
    local table_2_5: { BlueSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, BluesteelRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, Boombastic: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, CamoRadio: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, DiamondRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Dubstep: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, FadeRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Flaming: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Gold: nil | { Price: nil | { Coins: number } | { Coins: number? } } | { Price: { Coins: number } }, GreenSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, Omega: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, PinkSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RainbowRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } }, RedSparkleRadio: nil | { Price: nil | { Gems: number } | { Gems: number? } } | { Price: { Gems: number } } } = {
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
        [("Dubstep")] = nil,
    }
    local table_3_45: { Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
    }
    local table_4_45: { Coins: number? } = {[("Coins")] = nil}
    local value_5_77: number = 1200
    table_4_45.Coins = value_5_77
    table_3_45.Price = table_4_45
    table_2_5.Dubstep = table_3_45
    local table_3_46: { Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
    }
    local table_4_46: { Coins: number? } = {[("Coins")] = nil}
    local value_5_78: number = 12000
    table_4_46.Coins = value_5_78
    table_3_46.Price = table_4_46
    table_2_5.Gold = table_3_46
    local table_3_47: { Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
    }
    local table_4_47: { Coins: number? } = {[("Coins")] = nil}
    local value_5_79: number = 3200
    table_4_47.Coins = value_5_79
    table_3_47.Price = table_4_47
    table_2_5.BluesteelRadio = table_3_47
    local table_3_48: { Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
    }
    local table_4_48: { Coins: number? } = {[("Coins")] = nil}
    local value_5_80: number = 2000
    table_4_48.Coins = value_5_80
    table_3_48.Price = table_4_48
    table_2_5.CamoRadio = table_3_48
    local table_3_49: { Price: nil | { Coins: number } | { Coins: number? } } = {
        [("Price")] = nil,
    }
    local table_4_49: { Coins: number? } = {[("Coins")] = nil}
    local value_5_81: number = 3600
    table_4_49.Coins = value_5_81
    table_3_49.Price = table_4_49
    table_2_5.Boombastic = table_3_49
    local table_3_50: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_50: { Gems: number? } = {[("Gems")] = nil}
    local value_5_82: number = 400
    table_4_50.Gems = value_5_82
    table_3_50.Price = table_4_50
    table_2_5.Omega = table_3_50
    local table_3_51: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_51: { Gems: number? } = {[("Gems")] = nil}
    local value_5_83: number = 800
    table_4_51.Gems = value_5_83
    table_3_51.Price = table_4_51
    table_2_5.RainbowRadio = table_3_51
    local table_3_52: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_52: { Gems: number? } = {[("Gems")] = nil}
    local value_5_84: number = 400
    table_4_52.Gems = value_5_84
    table_3_52.Price = table_4_52
    table_2_5.FadeRadio = table_3_52
    local table_3_53: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_53: { Gems: number? } = {[("Gems")] = nil}
    local value_5_85: number = 900
    table_4_53.Gems = value_5_85
    table_3_53.Price = table_4_53
    table_2_5.Flaming = table_3_53
    local table_3_54: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_54: { Gems: number? } = {[("Gems")] = nil}
    local value_5_86: number = 1000
    table_4_54.Gems = value_5_86
    table_3_54.Price = table_4_54
    table_2_5.GreenSparkleRadio = table_3_54
    local table_3_55: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_55: { Gems: number? } = {[("Gems")] = nil}
    local value_5_87: number = 1000
    table_4_55.Gems = value_5_87
    table_3_55.Price = table_4_55
    table_2_5.PinkSparkleRadio = table_3_55
    local table_3_56: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_56: { Gems: number? } = {[("Gems")] = nil}
    local value_5_88: number = 1000
    table_4_56.Gems = value_5_88
    table_3_56.Price = table_4_56
    table_2_5.BlueSparkleRadio = table_3_56
    local table_3_57: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_57: { Gems: number? } = {[("Gems")] = nil}
    local value_5_89: number = 1000
    table_4_57.Gems = value_5_89
    table_3_57.Price = table_4_57
    table_2_5.RedSparkleRadio = table_3_57
    local table_3_58: { Price: nil | { Gems: number } | { Gems: number? } } = {
        [("Price")] = nil,
    }
    local table_4_58: { Gems: number? } = {[("Gems")] = nil}
    local value_5_90: number = 2500
    table_4_58.Gems = value_5_90
    table_3_58.Price = table_4_58
    table_2_5.DiamondRadio = table_3_58
    table_1.Radios = table_2_5
    local table_2_6: { Egg: nil | { DataType: string, LayoutOrder: number, Price: { Coins: number, Gems: number } } | { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } } = {
        [("Egg")] = nil,
    }
    local table_3_59: { DataType: string?, LayoutOrder: number?, Price: nil | { Coins: number, Gems: number } | { Coins: number?, Gems: number? } } = {
        [("DataType")] = nil,
        [("DataType")] = nil,
        [("DataType")] = nil,
    }
    local value_4_58: string = "Eggs"
    table_3_59.DataType = value_4_58
    local table_4_59: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_5_91: number = 1000
    table_4_59.Coins = value_5_91
    local value_5_92: number = 100
    table_4_59.Gems = value_5_92
    table_3_59.Price = table_4_59
    local value_4_59: number = 100
    table_3_59.LayoutOrder = value_4_59
    table_2_6.Egg = table_3_59
    table_1.Pets = table_2_6
end

return table_1
