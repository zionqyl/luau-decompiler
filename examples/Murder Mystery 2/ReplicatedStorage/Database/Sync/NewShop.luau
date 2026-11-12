--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    BeachBundleEffect: nil | { Description: string, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, GamepassId: number, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, OneTimePurchase: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { Description: string, DisplayInfo: { Color: Color3, Image: string, Name: string }, GamepassId: number, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, OneTimePurchase: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string },
    BeachyKnife: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }}, Type: string },
    BlueFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    BlueSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    BluesteelRadio: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    Boombastic: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    Burn: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    CamoRadio: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    ChocolateMilk: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    ClassicBundle: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string },
    Decoy: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    DiamondRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    Dual: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    Dubstep: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    Egg: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number }, Type: string },
    Electric: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    FadeRadio: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    FakeBomb: nil | { Description: string, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Description: string, Price: { Coins: number, Gems: number }, Type: string },
    FakeGun: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Fireflies: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    Flaming: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    GGSign: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    Gems100: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Gems13000: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Gems2000: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Gems400: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Gems5500: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Gems800: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} },
    Ghost: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Ghostify: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Gold: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    GreenFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    GreenSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    GunBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    GunBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    GunBox3: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    Haste: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Heartify: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    IceCream: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    Key: nil | { Description: string, LayoutOrder: number, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, LayoutOrder: number, Price: { Gems: number }, Type: string },
    KnifeBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    KnifeBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    KnifeBox3: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    KnifeBox4: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    KnifeBox5: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    Knifeception: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    ["MLG Box"]: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    Musical: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    MysteryBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    MysteryBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string },
    Ninja: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Omega: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    PinkFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    PinkSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    Pizza: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    Radioactive: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string },
    RainbowRadio: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string },
    RedSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    SandsGun: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }}, Type: string },
    Sleight: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    SnowyBundleEffect: nil | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string },
    SprayPaint: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    Sprint: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    SweetBundleEffect: nil | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string },
    Teddy: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    Trap: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    Xray: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string },
    dab: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    floss: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
    ninja: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    sit: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string },
    zen: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string },
}

local table_1: { BeachBundleEffect: nil | { Description: string, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, GamepassId: number, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, OneTimePurchase: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { Description: string, DisplayInfo: { Color: Color3, Image: string, Name: string }, GamepassId: number, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, OneTimePurchase: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string }, BeachyKnife: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }}, Type: string }, BlueFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, BlueSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, BluesteelRadio: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, Boombastic: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, Burn: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, CamoRadio: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, ChocolateMilk: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, ClassicBundle: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string }, Decoy: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, DiamondRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, Dual: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, Dubstep: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, Egg: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number }, Type: string }, Electric: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, FadeRadio: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, FakeBomb: nil | { Description: string, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Description: string, Price: { Coins: number, Gems: number }, Type: string }, FakeGun: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Fireflies: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, Flaming: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, GGSign: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, Gems100: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Gems13000: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Gems2000: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Gems400: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Gems5500: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Gems800: nil | { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } | { DevProductId: number, Hidden: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }} }, Ghost: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Ghostify: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Gold: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, GreenFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, GreenSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, GunBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, GunBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, GunBox3: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, Haste: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Heartify: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, IceCream: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, Key: nil | { Description: string, LayoutOrder: number, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, LayoutOrder: number, Price: { Gems: number }, Type: string }, KnifeBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, KnifeBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, KnifeBox3: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, KnifeBox4: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, KnifeBox5: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, Knifeception: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, ["MLG Box"]: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, Musical: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, MysteryBox1: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, MysteryBox2: nil | { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } | { LayoutOrder: number, Price: { Coins: number, Gems: number, Key: number }, Type: string }, Ninja: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Omega: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, PinkFire: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, PinkSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, Pizza: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, Radioactive: nil | { Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Price: { Coins: number }, Type: string }, RainbowRadio: nil | { Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Price: { Gems: number }, Type: string }, RedSparkleRadio: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, SandsGun: nil | { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } | { Description: string, DevProductId: number, DisplayInfo: { Color: Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: { Robux: number }, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }}, Type: string }, Sleight: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, SnowyBundleEffect: nil | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string }, SprayPaint: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, Sprint: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, SweetBundleEffect: nil | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } | { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string }, Teddy: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, Trap: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, Xray: nil | { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } | { Price: { Coins: number, Gems: number }, Type: string }, dab: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, floss: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string }, ninja: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, sit: nil | { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } | { Description: string, Price: { Coins: number }, Type: string }, zen: nil | { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } | { Description: string, Price: { Gems: number }, Type: string } } = {
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
    [("Key")] = nil,
}
do
    local table_2: { Description: string, LayoutOrder: number, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Weapons",
        Description = "Can be used once to open a standard mystery box. Tradeable!",
        Price = 0,
        LayoutOrder = 1000,
    }
    local table_3: { Gems: number? } = {[("Gems")] = nil}
    local value_4: number = 125
    table_3.Gems = value_4
    table_2.Price = table_3
    table_1.Key = table_2
    local table_2_2: { Description: string, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, GamepassId: number, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, OneTimePurchase: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } = {
        Offsale = true,
        Hidden = true,
        Type = "ItemBundle",
        OneTimePurchase = true,
        DisplayInfo = 0,
        Description = "[Limited] A godly bundle including: a knife, a gun and an effect. Available for a limited time, then goes off-sale.",
        Price = 0,
        RewardItems = 0,
        GamepassId = 1927110322,
        Limited = true,
        LayoutOrder = 50,
    }
    local table_3_2: { Color: number | Color3, Image: string, Name: string } = {
        Name = "Beach Bundle",
        Color = 0,
        Image = "rbxassetid://122272924703939",
    }
    local from_rgb_result: Color3 = Color3.fromRGB(255, 0, 255)
    table_3_2.Color = from_rgb_result
    table_2_2.DisplayInfo = table_3_2
    local table_3_3: { Robux: number? } = {[("Robux")] = nil}
    local value_4_2: number = 3399
    table_3_3.Robux = value_4_2
    table_2_2.Price = table_3_3
    local table_3_4: {{ Amount: number, ItemID: string, ItemType: string }?} = {nil, nil, nil}
    local table_4: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Beachy",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_5: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Sands",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_6: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Ocean26",
        ItemType = "Effects",
        Amount = 1,
    }
    table_3_4[1], table_3_4[2], table_3_4[3] = table_4, table_5, table_6
    table_2_2.RewardItems = table_3_4
    table_1.BeachBundleEffect = table_2_2
    local table_2_3: { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } = {
        Offsale = true,
        Hidden = true,
        Type = "ItemBundle",
        DisplayInfo = 0,
        Description = "[Limited] A godly knife. Available as a bundle with a gun and effect. Available for a limited time, then goes off-sale.",
        Price = 0,
        RewardItems = 0,
        DevProductId = 3611355018,
        Limited = true,
        LayoutOrder = 51,
    }
    local table_3_5: { Color: number | Color3, Image: string, Name: string } = {
        Name = "Beachy",
        Color = 0,
        Image = "rbxassetid://120770561009128",
    }
    local from_rgb_result_2: Color3 = Color3.fromRGB(255, 0, 255)
    table_3_5.Color = from_rgb_result_2
    table_2_3.DisplayInfo = table_3_5
    local table_3_6: { Robux: number? } = {[("Robux")] = nil}
    local value_4_3: number = 1699
    table_3_6.Robux = value_4_3
    table_2_3.Price = table_3_6
    local table_3_7: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Beachy", ItemType = "Weapons", Amount = 1},
    }
    table_2_3.RewardItems = table_3_7
    table_1.BeachyKnife = table_2_3
    local table_2_4: { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }}, Type: string } = {
        Offsale = true,
        Hidden = true,
        Type = "ItemBundle",
        DisplayInfo = 0,
        Description = "[Limited] A godly gun. Available as a bundle with a knife and effect. Available for a limited time, then goes off-sale.",
        Price = 0,
        RewardItems = 0,
        DevProductId = 3611355069,
        Limited = true,
        LayoutOrder = 51,
    }
    local table_3_8: { Color: number | Color3, Image: string, Name: string } = {
        Name = "Sands",
        Color = 0,
        Image = "rbxassetid://72440406585231",
    }
    local from_rgb_result_3: Color3 = Color3.fromRGB(255, 0, 255)
    table_3_8.Color = from_rgb_result_3
    table_2_4.DisplayInfo = table_3_8
    local table_3_9: { Robux: number? } = {[("Robux")] = nil}
    local value_4_4: number = 1699
    table_3_9.Robux = value_4_4
    table_2_4.Price = table_3_9
    local table_3_10: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Sands", ItemType = "Weapons", Amount = 1},
    }
    table_2_4.RewardItems = table_3_10
    table_1.SandsGun = table_2_4
    local table_2_5: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 100,
    }
    local table_3_11: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_5: number = 1000
    table_3_11.Coins = value_4_5
    local value_4_6: number = 100
    table_3_11.Gems = value_4_6
    local value_4_7: number = 1
    table_3_11.Key = value_4_7
    table_2_5.Price = table_3_11
    table_1.MysteryBox1 = table_2_5
    local table_2_6: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 100,
    }
    local table_3_12: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_8: number = 1000
    table_3_12.Coins = value_4_8
    local value_4_9: number = 100
    table_3_12.Gems = value_4_9
    local value_4_10: number = 1
    table_3_12.Key = value_4_10
    table_2_6.Price = table_3_12
    table_1.MysteryBox2 = table_2_6
    local table_2_7: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 301,
    }
    local table_3_13: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_11: number = 1000
    table_3_13.Coins = value_4_11
    local value_4_12: number = 100
    table_3_13.Gems = value_4_12
    local value_4_13: number = 1
    table_3_13.Key = value_4_13
    table_2_7.Price = table_3_13
    table_1.KnifeBox1 = table_2_7
    local table_2_8: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 302,
    }
    local table_3_14: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_14: number = 1000
    table_3_14.Coins = value_4_14
    local value_4_15: number = 100
    table_3_14.Gems = value_4_15
    local value_4_16: number = 1
    table_3_14.Key = value_4_16
    table_2_8.Price = table_3_14
    table_1.KnifeBox2 = table_2_8
    local table_2_9: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 303,
    }
    local table_3_15: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_17: number = 1000
    table_3_15.Coins = value_4_17
    local value_4_18: number = 100
    table_3_15.Gems = value_4_18
    local value_4_19: number = 1
    table_3_15.Key = value_4_19
    table_2_9.Price = table_3_15
    table_1.KnifeBox3 = table_2_9
    local table_2_10: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 304,
    }
    local table_3_16: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_20: number = 1000
    table_3_16.Coins = value_4_20
    local value_4_21: number = 100
    table_3_16.Gems = value_4_21
    local value_4_22: number = 1
    table_3_16.Key = value_4_22
    table_2_10.Price = table_3_16
    table_1.KnifeBox4 = table_2_10
    local table_2_11: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 305,
    }
    local table_3_17: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_23: number = 1000
    table_3_17.Coins = value_4_23
    local value_4_24: number = 100
    table_3_17.Gems = value_4_24
    local value_4_25: number = 1
    table_3_17.Key = value_4_25
    table_2_11.Price = table_3_17
    table_1.KnifeBox5 = table_2_11
    local table_2_12: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 306,
    }
    local table_3_18: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_26: number = 1000
    table_3_18.Coins = value_4_26
    local value_4_27: number = 100
    table_3_18.Gems = value_4_27
    local value_4_28: number = 1
    table_3_18.Key = value_4_28
    table_2_12.Price = table_3_18
    table_1["MLG Box"] = table_2_12
end
do
    local table_2_13: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 401,
    }
    local table_3_19: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_29: number = 1000
    table_3_19.Coins = value_4_29
    local value_4_30: number = 100
    table_3_19.Gems = value_4_30
    local value_4_31: number = 1
    table_3_19.Key = value_4_31
    table_2_13.Price = table_3_19
    table_1.GunBox1 = table_2_13
    local table_2_14: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 402,
    }
    local table_3_20: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_32: number = 1000
    table_3_20.Coins = value_4_32
    local value_4_33: number = 100
    table_3_20.Gems = value_4_33
    local value_4_34: number = 1
    table_3_20.Key = value_4_34
    table_2_14.Price = table_3_20
    table_1.GunBox2 = table_2_14
    local table_2_15: { LayoutOrder: number, Price: number | { Coins: number, Gems: number, Key: number } | { Coins: number?, Gems: number?, Key: number? }, Type: string } = {
        Type = "MysteryBox",
        Price = 0,
        LayoutOrder = 403,
    }
    local table_3_21: { Coins: number?, Gems: number?, Key: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_35: number = 1000
    table_3_21.Coins = value_4_35
    local value_4_36: number = 100
    table_3_21.Gems = value_4_36
    local value_4_37: number = 1
    table_3_21.Key = value_4_37
    table_2_15.Price = table_3_21
    table_1.GunBox3 = table_2_15
    local table_2_16: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_22: { Gems: number? } = {[("Gems")] = nil}
    local value_4_38: number = 300
    table_3_22.Gems = value_4_38
    table_2_16.Price = table_3_22
    table_1.Knifeception = table_2_16
    local table_2_17: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_23: { Coins: number? } = {[("Coins")] = nil}
    local value_4_39: number = 4000
    table_3_23.Coins = value_4_39
    table_2_17.Price = table_3_23
    table_1.Burn = table_2_17
    local table_2_18: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_24: { Gems: number? } = {[("Gems")] = nil}
    local value_4_40: number = 800
    table_3_24.Gems = value_4_40
    table_2_18.Price = table_3_24
    table_1.BlueFire = table_2_18
    local table_2_19: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_25: { Gems: number? } = {[("Gems")] = nil}
    local value_4_41: number = 800
    table_3_25.Gems = value_4_41
    table_2_19.Price = table_3_25
    table_1.PinkFire = table_2_19
    local table_2_20: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_26: { Gems: number? } = {[("Gems")] = nil}
    local value_4_42: number = 800
    table_3_26.Gems = value_4_42
    table_2_20.Price = table_3_26
    table_1.GreenFire = table_2_20
    local table_2_21: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_27: { Gems: number? } = {[("Gems")] = nil}
    local value_4_43: number = 900
    table_3_27.Gems = value_4_43
    table_2_21.Price = table_3_27
    table_1.Dual = table_2_21
    local table_2_22: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_28: { Gems: number? } = {[("Gems")] = nil}
    local value_4_44: number = 1000
    table_3_28.Gems = value_4_44
    table_2_22.Price = table_3_28
    table_1.Electric = table_2_22
    local table_2_23: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_29: { Coins: number?, Gems: number? } = {[("Gems")] = nil, [("Gems")] = nil}
    local value_4_45: number = 200
    table_3_29.Gems = value_4_45
    local value_4_46: number = 2000
    table_3_29.Coins = value_4_46
    table_2_23.Price = table_3_29
    table_1.Ghostify = table_2_23
    local table_2_24: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_30: { Coins: number? } = {[("Coins")] = nil}
    local value_4_47: number = 2400
    table_3_30.Coins = value_4_47
    table_2_24.Price = table_3_30
    table_1.Heartify = table_2_24
    local table_2_25: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_31: { Coins: number? } = {[("Coins")] = nil}
    local value_4_48: number = 1600
    table_3_31.Coins = value_4_48
    table_2_25.Price = table_3_31
    table_1.Radioactive = table_2_25
    local table_2_26: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Effects",
        Price = 0,
    }
    local table_3_32: { Coins: number? } = {[("Coins")] = nil}
    local value_4_49: number = 2000
    table_3_32.Coins = value_4_49
    table_2_26.Price = table_3_32
    table_1.Musical = table_2_26
    local table_2_27: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_33: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_50: number = 1000
    table_3_33.Coins = value_4_50
    local value_4_51: number = 100
    table_3_33.Gems = value_4_51
    table_2_27.Price = table_3_33
    table_1.Sleight = table_2_27
    local table_2_28: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_34: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_52: number = 1000
    table_3_34.Coins = value_4_52
    local value_4_53: number = 100
    table_3_34.Gems = value_4_53
    table_2_28.Price = table_3_34
    table_1.Ninja = table_2_28
    local table_2_29: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_35: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_54: number = 3000
    table_3_35.Coins = value_4_54
    local value_4_55: number = 400
    table_3_35.Gems = value_4_55
    table_2_29.Price = table_3_35
    table_1.FakeGun = table_2_29
    local table_2_30: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_36: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_56: number = 3000
    table_3_36.Coins = value_4_56
    local value_4_57: number = 400
    table_3_36.Gems = value_4_57
    table_2_30.Price = table_3_36
    table_1.Haste = table_2_30
end
do
    local table_2_31: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_37: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_58: number = 3000
    table_3_37.Coins = value_4_58
    local value_4_59: number = 400
    table_3_37.Gems = value_4_59
    table_2_31.Price = table_3_37
    table_1.Sprint = table_2_31
    local table_2_32: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_38: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_60: number = 3000
    table_3_38.Coins = value_4_60
    local value_4_61: number = 400
    table_3_38.Gems = value_4_61
    table_2_32.Price = table_3_38
    table_1.Trap = table_2_32
    local table_2_33: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_39: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_62: number = 6000
    table_3_39.Coins = value_4_62
    local value_4_63: number = 800
    table_3_39.Gems = value_4_63
    table_2_33.Price = table_3_39
    table_1.Ghost = table_2_33
    local table_2_34: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_40: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_64: number = 6000
    table_3_40.Coins = value_4_64
    local value_4_65: number = 800
    table_3_40.Gems = value_4_65
    table_2_34.Price = table_3_40
    table_1.Xray = table_2_34
    local table_2_35: { Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Perks",
        Price = 0,
    }
    local table_3_41: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_66: number = 3000
    table_3_41.Coins = value_4_66
    local value_4_67: number = 400
    table_3_41.Gems = value_4_67
    table_2_35.Price = table_3_41
    table_1.Decoy = table_2_35
    local table_2_36: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Emotes",
        Description = "Have a seat after a long day of coin-collecting.",
        Price = 0,
    }
    local table_3_42: { Coins: number? } = {[("Coins")] = nil}
    local value_4_68: number = 800
    table_3_42.Coins = value_4_68
    table_2_36.Price = table_3_42
    table_1.sit = table_2_36
    local table_2_37: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Emotes",
        Description = "Embrace the shadow of a ninja with this flexible pose.",
        Price = 0,
    }
    local table_3_43: { Coins: number? } = {[("Coins")] = nil}
    local value_4_69: number = 2600
    table_3_43.Coins = value_4_69
    table_2_37.Price = table_3_43
    table_1.ninja = table_2_37
    local table_2_38: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Emotes",
        Description = "Hit a HUGE dab on your enemies!",
        Price = 0,
    }
    local table_3_44: { Coins: number? } = {[("Coins")] = nil}
    local value_4_70: number = 2800
    table_3_44.Coins = value_4_70
    table_2_38.Price = table_3_44
    table_1.dab = table_2_38
    local table_2_39: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Emotes",
        Description = "Experience tranquility with this relaxing zen pose.",
        Price = 0,
    }
    local table_3_45: { Gems: number? } = {[("Gems")] = nil}
    local value_4_71: number = 800
    table_3_45.Gems = value_4_71
    table_2_39.Price = table_3_45
    table_1.zen = table_2_39
    local table_2_40: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "FLOSS on your enemies!",
        Type = "Emotes",
        Price = 0,
    }
    local table_3_46: { Gems: number? } = {[("Gems")] = nil}
    local value_4_72: number = 750
    table_3_46.Gems = value_4_72
    table_2_40.Price = table_3_46
    table_1.floss = table_2_40
    local table_2_41: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Toys",
        Description = "Release a jar of fireflies.",
        Price = 0,
    }
    local table_3_47: { Coins: number? } = {[("Coins")] = nil}
    local value_4_73: number = 1500
    table_3_47.Coins = value_4_73
    table_2_41.Price = table_3_47
    table_1.Fireflies = table_2_41
    local table_2_42: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Toys",
        Description = "Good game!",
        Price = 0,
    }
    local table_3_48: { Gems: number? } = {[("Gems")] = nil}
    local value_4_74: number = 100
    table_3_48.Gems = value_4_74
    table_2_42.Price = table_3_48
    table_1.GGSign = table_2_42
    local table_2_43: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Toys",
        Description = "Relax after a long day of unboxing crates with a cool glass of chocolate milk.",
        Price = 0,
    }
    local table_3_49: { Coins: number? } = {[("Coins")] = nil}
    local value_4_75: number = 400
    table_3_49.Coins = value_4_75
    table_2_43.Price = table_3_49
    table_1.ChocolateMilk = table_2_43
    local table_2_44: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Toys",
        Description = "Spray paint your favorite decals on the walls.",
        Price = 0,
    }
    local table_3_50: { Gems: number? } = {[("Gems")] = nil}
    local value_4_76: number = 750
    table_3_50.Gems = value_4_76
    table_2_44.Price = table_3_50
    table_1.SprayPaint = table_2_44
    local table_2_45: { Description: string, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Toys",
        Description = "Prank your friends with this confetti bomb!",
        Price = 0,
    }
    local table_3_51: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_77: number = 4800
    table_3_51.Coins = value_4_77
    local value_4_78: number = 400
    table_3_51.Gems = value_4_78
    table_2_45.Price = table_3_51
    table_1.FakeBomb = table_2_45
    local table_2_46: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Toys",
        Description = "Yummy!",
        Price = 0,
    }
    local table_3_52: { Coins: number? } = {[("Coins")] = nil}
    local value_4_79: number = 400
    table_3_52.Coins = value_4_79
    table_2_46.Price = table_3_52
    table_1.IceCream = table_2_46
    local table_2_47: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Toys",
        Description = "Pizza = delicious.",
        Price = 0,
    }
    local table_3_53: { Coins: number? } = {[("Coins")] = nil}
    local value_4_80: number = 400
    table_3_53.Coins = value_4_80
    table_2_47.Price = table_3_53
    table_1.Pizza = table_2_47
    local table_2_48: { Description: string, Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Toys",
        Description = "He will always love you forever.",
        Price = 0,
    }
    local table_3_54: { Coins: number? } = {[("Coins")] = nil}
    local value_4_81: number = 600
    table_3_54.Coins = value_4_81
    table_2_48.Price = table_3_54
    table_1.Teddy = table_2_48
    local table_2_49: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_55: { Coins: number? } = {[("Coins")] = nil}
    local value_4_82: number = 1200
    table_3_55.Coins = value_4_82
    table_2_49.Price = table_3_55
    table_1.Dubstep = table_2_49
    local table_2_50: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_56: { Coins: number? } = {[("Coins")] = nil}
    local value_4_83: number = 12000
    table_3_56.Coins = value_4_83
    table_2_50.Price = table_3_56
    table_1.Gold = table_2_50
end
do
    local table_2_51: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_57: { Coins: number? } = {[("Coins")] = nil}
    local value_4_84: number = 3200
    table_3_57.Coins = value_4_84
    table_2_51.Price = table_3_57
    table_1.BluesteelRadio = table_2_51
    local table_2_52: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_58: { Coins: number? } = {[("Coins")] = nil}
    local value_4_85: number = 2000
    table_3_58.Coins = value_4_85
    table_2_52.Price = table_3_58
    table_1.CamoRadio = table_2_52
    local table_2_53: { Price: number | { Coins: number } | { Coins: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_59: { Coins: number? } = {[("Coins")] = nil}
    local value_4_86: number = 3600
    table_3_59.Coins = value_4_86
    table_2_53.Price = table_3_59
    table_1.Boombastic = table_2_53
    local table_2_54: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_60: { Gems: number? } = {[("Gems")] = nil}
    local value_4_87: number = 400
    table_3_60.Gems = value_4_87
    table_2_54.Price = table_3_60
    table_1.Omega = table_2_54
    local table_2_55: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_61: { Gems: number? } = {[("Gems")] = nil}
    local value_4_88: number = 800
    table_3_61.Gems = value_4_88
    table_2_55.Price = table_3_61
    table_1.RainbowRadio = table_2_55
    local table_2_56: { Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Type = "Radios",
        Price = 0,
    }
    local table_3_62: { Gems: number? } = {[("Gems")] = nil}
    local value_4_89: number = 400
    table_3_62.Gems = value_4_89
    table_2_56.Price = table_3_62
    table_1.FadeRadio = table_2_56
    local table_2_57: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A flaming radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_63: { Gems: number? } = {[("Gems")] = nil}
    local value_4_90: number = 900
    table_3_63.Gems = value_4_90
    table_2_57.Price = table_3_63
    table_1.Flaming = table_2_57
    local table_2_58: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A green sparkly radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_64: { Gems: number? } = {[("Gems")] = nil}
    local value_4_91: number = 1000
    table_3_64.Gems = value_4_91
    table_2_58.Price = table_3_64
    table_1.GreenSparkleRadio = table_2_58
    local table_2_59: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A pink sparkly radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_65: { Gems: number? } = {[("Gems")] = nil}
    local value_4_92: number = 1000
    table_3_65.Gems = value_4_92
    table_2_59.Price = table_3_65
    table_1.PinkSparkleRadio = table_2_59
    local table_2_60: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A blue sparkly radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_66: { Gems: number? } = {[("Gems")] = nil}
    local value_4_93: number = 1000
    table_3_66.Gems = value_4_93
    table_2_60.Price = table_3_66
    table_1.BlueSparkleRadio = table_2_60
    local table_2_61: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A red sparkly radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_67: { Gems: number? } = {[("Gems")] = nil}
    local value_4_94: number = 1000
    table_3_67.Gems = value_4_94
    table_2_61.Price = table_3_67
    table_1.RedSparkleRadio = table_2_61
    local table_2_62: { Description: string, Price: number | { Gems: number } | { Gems: number? }, Type: string } = {
        Description = "A diamond radio.",
        Type = "Radios",
        Price = 0,
    }
    local table_3_68: { Gems: number? } = {[("Gems")] = nil}
    local value_4_95: number = 2500
    table_3_68.Gems = value_4_95
    table_2_62.Price = table_3_68
    table_1.DiamondRadio = table_2_62
    local table_2_63: { LayoutOrder: number, Price: number | { Coins: number, Gems: number } | { Coins: number?, Gems: number? }, Type: string } = {
        Type = "Eggs",
        Price = 0,
        LayoutOrder = 100,
    }
    local table_3_69: { Coins: number?, Gems: number? } = {
        [("Coins")] = nil,
        [("Coins")] = nil,
    }
    local value_4_96: number = 1000
    table_3_69.Coins = value_4_96
    local value_4_97: number = 100
    table_3_69.Gems = value_4_97
    table_2_63.Price = table_3_69
    table_1.Egg = table_2_63
    local table_2_64: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 538886310,
    }
    local table_3_70: { Robux: number? } = {[("Robux")] = nil}
    local value_4_98: number = 100
    table_3_70.Robux = value_4_98
    table_2_64.Price = table_3_70
    local table_3_71: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 100},
    }
    table_2_64.RewardItems = table_3_71
    table_1.Gems100 = table_2_64
    local table_2_65: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 538886443,
    }
    local table_3_72: { Robux: number? } = {[("Robux")] = nil}
    local value_4_99: number = 400
    table_3_72.Robux = value_4_99
    table_2_65.Price = table_3_72
    local table_3_73: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 400},
    }
    table_2_65.RewardItems = table_3_73
    table_1.Gems400 = table_2_65
    local table_2_66: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 538886505,
    }
    local table_3_74: { Robux: number? } = {[("Robux")] = nil}
    local value_4_100: number = 800
    table_3_74.Robux = value_4_100
    table_2_66.Price = table_3_74
    local table_3_75: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 800},
    }
    table_2_66.RewardItems = table_3_75
    table_1.Gems800 = table_2_66
    local table_2_67: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 951674177,
    }
    local table_3_76: { Robux: number? } = {[("Robux")] = nil}
    local value_4_101: number = 1700
    table_3_76.Robux = value_4_101
    table_2_67.Price = table_3_76
    local table_3_77: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 2000},
    }
    table_2_67.RewardItems = table_3_77
    table_1.Gems2000 = table_2_67
    local table_2_68: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 538887086,
    }
    local table_3_78: { Robux: number? } = {[("Robux")] = nil}
    local value_4_102: number = 4500
    table_3_78.Robux = value_4_102
    table_2_68.Price = table_3_78
    local table_3_79: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 5500},
    }
    table_2_68.RewardItems = table_3_79
    table_1.Gems5500 = table_2_68
end
do
    local table_2_69: { DevProductId: number, Hidden: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }} } = {
        Hidden = true,
        Price = 0,
        RewardItems = 0,
        DevProductId = 538887199,
    }
    local table_3_80: { Robux: number? } = {[("Robux")] = nil}
    local value_4_103: number = 10000
    table_3_80.Robux = value_4_103
    table_2_69.Price = table_3_80
    local table_3_81: {{ Amount: number, ItemID: string, ItemType: string }} = {
        {ItemID = "Gems", ItemType = "Materials", Amount = 13000},
    }
    table_2_69.RewardItems = table_3_81
    table_1.Gems13000 = table_2_69
    local table_2_70: { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } = {
        Type = "ItemBundle",
        Offsale = true,
        Hidden = true,
        OneTimePurchase = true,
        RewardItems = 0,
        GamepassId = 1627475702,
    }
    local table_3_82: {{ Amount: number, ItemID: string, ItemType: string }?} = {nil, nil, nil}
    local table_4_10: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Snowstorm",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_5_2: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Blizzard",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_6_2: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Snowstorm2025",
        ItemType = "Effects",
        Amount = 1,
    }
    table_3_82[1], table_3_82[2], table_3_82[3] = table_4_10, table_5_2, table_6_2
    table_2_70.RewardItems = table_3_82
    table_1.SnowyBundleEffect = table_2_70
    local table_2_71: { GamepassId: number, Hidden: boolean, Offsale: boolean, OneTimePurchase: boolean, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } = {
        Type = "ItemBundle",
        Offsale = true,
        Hidden = true,
        OneTimePurchase = true,
        RewardItems = 0,
        GamepassId = 1709590006,
    }
    local table_3_83: {{ Amount: number, ItemID: string, ItemType: string }?} = {nil, nil, nil}
    local table_4_11: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Sweet",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_5_3: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Treat",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_6_3: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "SweetEffect26",
        ItemType = "Effects",
        Amount = 1,
    }
    table_3_83[1], table_3_83[2], table_3_83[3] = table_4_11, table_5_3, table_6_3
    table_2_71.RewardItems = table_3_83
    table_1.SweetBundleEffect = table_2_71
    local table_2_72: { Description: string, DevProductId: number, DisplayInfo: number | { Color: Color3, Image: string, Name: string } | { Color: number | Color3, Image: string, Name: string }, Hidden: boolean, LayoutOrder: number, Limited: boolean, Offsale: boolean, Price: number | { Robux: number } | { Robux: number? }, RewardItems: number | {{ Amount: number, ItemID: string, ItemType: string }?}, Type: string } = {
        Offsale = true,
        Hidden = true,
        Type = "ItemBundle",
        DisplayInfo = 0,
        Description = "[Limited] A bundle of items based on classic skins from Murder Mystery in 2014.",
        Price = 0,
        RewardItems = 0,
        DevProductId = 3713181560,
        Limited = true,
        LayoutOrder = 50,
    }
    local table_3_84: { Color: number | Color3, Image: string, Name: string } = {
        Name = "Retro Bundle",
        Color = 0,
        Image = "rbxassetid://87017208426938",
    }
    local from_rgb_result_4: Color3 = Color3.fromRGB(230, 200, 0)
    table_3_84.Color = from_rgb_result_4
    table_2_72.DisplayInfo = table_3_84
    local table_3_85: { Robux: number? } = {[("Robux")] = nil}
    local value_4_104: number = 799
    table_3_85.Robux = value_4_104
    table_2_72.Price = table_3_85
    local table_3_86: {{ Amount: number, ItemID: string, ItemType: string }?} = {
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
    }
    local table_4_12: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Phaser_K_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_5_4: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Cowboy_K_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_6_4: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Laser_K_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_7: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Golden_K_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_8: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Prince_G_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_9: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Shadow_G_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    local table_10: { Amount: number, ItemID: string, ItemType: string } = {
        ItemID = "Ghost_G_2026",
        ItemType = "Weapons",
        Amount = 1,
    }
    table_3_86[1], table_3_86[2], table_3_86[3], table_3_86[4], table_3_86[5], table_3_86[6], table_3_86[7] = table_4_12, table_5_4, table_6_4, table_7, table_8, table_9, table_10
    table_2_72.RewardItems = table_3_86
    table_1.ClassicBundle = table_2_72
end

return table_1
