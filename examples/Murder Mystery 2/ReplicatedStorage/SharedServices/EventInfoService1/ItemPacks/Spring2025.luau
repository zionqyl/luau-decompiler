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
    DisplayTitle = "Bloom Pack",
    FeaturedIcon = "rbxassetid://125624899802245",
    ItemPackItems = 0,
}
local table_2: { Bundle: { DevProductID: number, EffectItemID: string, GamePassID: number, GunItemID: string, KnifeItemID: string }, Gun: { DevProductID: number, GamePassID: number, ItemID: string }, Knife: { DevProductID: number, GamePassID: number, ItemID: string } } = {
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
table_1.ItemPackItems = table_2

return table_1
