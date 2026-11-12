--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { ItemData: nil | { BoxType: string, Contents: number | {string?}, Godly: string, Image: string, Name: string, RarityChances: number | { Common: number, Legendary: number, Rare: number, Uncommon: number } | { Common: number?, Legendary: number?, Rare: number?, Uncommon: number? }, Season: number } | { BoxType: string, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: { Common: number, Legendary: number, Rare: number, Uncommon: number }, Season: number } }

local table_1: { ItemData: nil | { BoxType: string, Contents: number | {string?}, Godly: string, Image: string, Name: string, RarityChances: number | { Common: number, Legendary: number, Rare: number, Uncommon: number } | { Common: number?, Legendary: number?, Rare: number?, Uncommon: number? }, Season: number } | { BoxType: string, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: { Common: number, Legendary: number, Rare: number, Uncommon: number }, Season: number } } = {
    [("ItemData")] = nil,
}
local table_2: { BoxType: string, Contents: number | {string?}, Godly: string, Image: string, Name: string, RarityChances: number | { Common: number, Legendary: number, Rare: number, Uncommon: number } | { Common: number?, Legendary: number?, Rare: number?, Uncommon: number? }, Season: number } = {
    Name = "Christmas Box '24",
    Image = "rbxassetid://136255286776025",
    Contents = 0,
    RarityChances = 0,
    Season = 1,
    BoxType = "Weapons",
    Godly = "Constellation",
}
local table_3: {string?} = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_4: string = "Reindeer_K_2024"
local value_5: string = "Stockings_G_2024"
local value_6: string = "Igloo_K_2024"
local value_7: string = "Stickers_X_G_2024"
local value_8: string = "Wrapped_K_2024"
local value_9: string = "Snowman_K_2024"
local value_10: string = "Wreaths_K_2024"
local value_11: string = "Frostflame_G_2024"
local value_12: string = "Sleigh_K_2024"
local value_13: string = "Constellation_K_2024"
table_3[1], table_3[2], table_3[3], table_3[4], table_3[5], table_3[6], table_3[7], table_3[8], table_3[9], table_3[10] = value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
table_2.Contents = table_3
local table_3_2: { Common: number?, Legendary: number?, Rare: number?, Uncommon: number? } = {
    [("Common")] = nil,
    [("Common")] = nil,
    [("Common")] = nil,
}
local value_4_2: number = 70
table_3_2.Common = value_4_2
local value_4_3: number = 15
table_3_2.Uncommon = value_4_3
local value_4_4: number = 10
table_3_2.Rare = value_4_4
local value_4_5: number = 5
table_3_2.Legendary = value_4_5
table_2.RarityChances = table_3_2
table_1.ItemData = table_2

return table_1
