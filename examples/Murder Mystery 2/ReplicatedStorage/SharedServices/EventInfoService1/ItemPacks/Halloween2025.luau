--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    DisplayTitle: string,
    FeaturedIcon: string,
    ItemPackItems: number | { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } },
}

local table_1: { DisplayTitle: string, FeaturedIcon: string, ItemPackItems: number | { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } } = {
    DisplayTitle = "Xeno Bundle",
    FeaturedIcon = "rbxassetid://125624899802245",
    ItemPackItems = 0,
}
local table_2: { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } = {
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
table_1.ItemPackItems = table_2

return table_1
