--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { Egg: nil | { BoxType: string, Contents: {string?}, GodlyTag: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Contents: {string?}?, GodlyTag: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } }

local table_1: {{ Chance: number, Rarity: string }?} = {
    nil,
    nil,
    nil,
    nil,
}
local table_2: { Chance: number, Rarity: string } = {Rarity = "Common", Chance = 70}
local table_3: { Chance: number, Rarity: string } = {Rarity = "Uncommon", Chance = 15}
local table_4: { Chance: number, Rarity: string } = {Rarity = "Rare", Chance = 10}
local table_5: { Chance: number, Rarity: string } = {Rarity = "Legendary", Chance = 5}
table_1[1], table_1[2], table_1[3], table_1[4] = table_2, table_3, table_4, table_5
local table_2_2: { Egg: nil | { BoxType: string, Contents: {string?}, GodlyTag: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Contents: {string?}?, GodlyTag: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } } = {
    [("Egg")] = nil,
}
local table_3_2: { BoxType: string?, Contents: {string?}?, GodlyTag: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_4: string = "Common Egg"
table_3_2.Name = value_4
local value_4_2: string = "rbxassetid://3149859416"
table_3_2.Image = value_4_2
local value_4_3: number = 0
table_3_2.Released = value_4_3
local table_4_2: {string?} = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
local value_5: string = "Cat"
local value_6: string = "Dog"
local value_7: string = "Bunny"
local value_8: string = "Pig"
local value_9: string = "Fox"
local value_10: string = "Bear"
local value_11: string = "Bat"
table_4_2[1], table_4_2[2], table_4_2[3], table_4_2[4], table_4_2[5], table_4_2[6], table_4_2[7] = value_5, value_6, value_7, value_8, value_9, value_10, value_11
table_3_2.Contents = table_4_2
local value_4_4: string = "Pets"
table_3_2.BoxType = value_4_4
local value_4_5: string = "Fire"
table_3_2.GodlyTag = value_4_5
table_3_2.RarityChances = table_1
table_2_2.Egg = table_3_2

return table_2_2
