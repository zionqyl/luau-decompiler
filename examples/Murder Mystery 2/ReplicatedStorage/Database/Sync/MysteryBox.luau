--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    GunBox1: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    GunBox2: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    GunBox3: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    KnifeBox1: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    KnifeBox2: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    KnifeBox3: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    KnifeBox4: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    KnifeBox5: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    ["MLG Box"]: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? },
    MysteryBox1: nil | { BoxType: string, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number, Season: number } | { BoxType: string?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? },
    MysteryBox2: nil | { BoxType: string, ChromaTable: {string?}, Contents: {string?}, GodlyCover: string, GodlyTable: {string?}, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number, Season: number } | { BoxType: string?, ChromaTable: {string?}?, Contents: {string?}?, GodlyCover: string?, GodlyTable: {string?}?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? },
}

local table_1: {{ Chance: number, Rarity: string }?} = {
    nil,
    nil,
    nil,
    nil,
}
do
    local table_2: { Chance: number, Rarity: string } = {Rarity = "Common", Chance = 70}
    local table_3: { Chance: number, Rarity: string } = {Rarity = "Uncommon", Chance = 15}
    local table_4: { Chance: number, Rarity: string } = {Rarity = "Rare", Chance = 10}
    local table_5: { Chance: number, Rarity: string } = {Rarity = "Legendary", Chance = 5}
    table_1[1], table_1[2], table_1[3], table_1[4] = table_2, table_3, table_4, table_5
end
local table_2_2: { GunBox1: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, GunBox2: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, GunBox3: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, KnifeBox1: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, KnifeBox2: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, KnifeBox3: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, KnifeBox4: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, KnifeBox5: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, ["MLG Box"]: nil | { BoxType: string, Classic: boolean, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number } | { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? }, MysteryBox1: nil | { BoxType: string, Contents: {string?}, Godly: string, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number, Season: number } | { BoxType: string?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? }, MysteryBox2: nil | { BoxType: string, ChromaTable: {string?}, Contents: {string?}, GodlyCover: string, GodlyTable: {string?}, Image: string, Name: string, RarityChances: {{ Chance: number, Rarity: string }?}, Released: number, Season: number } | { BoxType: string?, ChromaTable: {string?}?, Contents: {string?}?, GodlyCover: string?, GodlyTable: {string?}?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? } } = {
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
do
    local table_3_2: { BoxType: string?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4: string = "Mystery Box #1"
    table_3_2.Name = value_4
    local value_4_2: string = "rbxassetid://3060009986"
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
        nil,
        nil,
        nil,
    }
    local value_5: string = "Combat"
    local value_6: string = "Copper"
    local value_7: string = "Hardened"
    local value_8: string = "Splat"
    local value_9: string = "CamoKnife"
    local value_10: string = "Tiger"
    local value_11: string = "Pirate"
    local value_12: string = "Space"
    local value_13: string = "RainbowGun"
    local value_14: string = "Rune"
    table_4_2[1], table_4_2[2], table_4_2[3], table_4_2[4], table_4_2[5], table_4_2[6], table_4_2[7], table_4_2[8], table_4_2[9], table_4_2[10] = value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14
    table_3_2.Contents = table_4_2
    local value_4_4: number = 1
    table_3_2.Season = value_4_4
    local value_4_5: string = "Weapons"
    table_3_2.BoxType = value_4_5
    local value_4_6: string = "Gemstone"
    table_3_2.Godly = value_4_6
    table_3_2.RarityChances = table_1
    table_2_2.MysteryBox1 = table_3_2
    local table_3_3: { BoxType: string?, ChromaTable: {string?}?, Contents: {string?}?, GodlyCover: string?, GodlyTable: {string?}?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number?, Season: number? } = {
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
    local value_4_7: string = "Mystery Box #2"
    table_3_3.Name = value_4_7
    local value_4_8: string = "rbxassetid://4659688870"
    table_3_3.Image = value_4_8
    local value_4_9: number = 0
    table_3_3.Released = value_4_9
    local table_4_3: {string?} = {
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
    local value_5_2: string = "Clown_G"
    local value_6_2: string = "Shaded"
    local value_7_2: string = "Lovely"
    local value_8_2: string = "Leaf"
    local value_9_2: string = "Biogun"
    local value_10_2: string = "Graffiti"
    local value_11_2: string = "HighTech"
    local value_12_2: string = "Nightfire"
    local value_13_2: string = "DeepSea"
    local value_14_2: string = "Splash_G"
    table_4_3[1], table_4_3[2], table_4_3[3], table_4_3[4], table_4_3[5], table_4_3[6], table_4_3[7], table_4_3[8], table_4_3[9], table_4_3[10] = value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2
    table_3_3.Contents = table_4_3
    local value_4_10: number = 1
    table_3_3.Season = value_4_10
    local value_4_11: string = "Weapons"
    table_3_3.BoxType = value_4_11
    local value_4_12: string = "Emptybringer"
    table_3_3.GodlyCover = value_4_12
    local table_4_4: {string?} = {nil, nil}
    local value_5_3: string = "Lightbringer"
    local value_6_3: string = "Darkbringer"
    table_4_4[1], table_4_4[2] = value_5_3, value_6_3
    table_3_3.GodlyTable = table_4_4
    local table_4_5: {string?} = {nil, nil}
    local value_5_4: string = "ChromaLightbringer"
    local value_6_4: string = "ChromaDarkbringer"
    table_4_5[1], table_4_5[2] = value_5_4, value_6_4
    table_3_3.ChromaTable = table_4_5
    table_3_3.RarityChances = table_1
    table_2_2.MysteryBox2 = table_3_3
    local table_3_4: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_13: string = "Knife Box #1"
    table_3_4.Name = value_4_13
    local value_4_14: string = "rbxassetid://3180967400"
    table_3_4.Image = value_4_14
    local value_4_15: number = 0
    table_3_4.Released = value_4_15
    local table_4_6: {string?} = {
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
    local value_5_5: string = "Whiteout"
    local value_6_5: string = "Splatter"
    local value_7_3: string = "Ice"
    local value_8_3: string = "Love"
    local value_9_3: string = "Bluesteel"
    local value_10_3: string = "Adurite"
    local value_11_3: string = "Wanwood"
    local value_12_3: string = "Rainbow"
    local value_13_3: string = "Galaxy"
    local value_14_3: string = "Plasmite"
    table_4_6[1], table_4_6[2], table_4_6[3], table_4_6[4], table_4_6[5], table_4_6[6], table_4_6[7], table_4_6[8], table_4_6[9], table_4_6[10] = value_5_5, value_6_5, value_7_3, value_8_3, value_9_3, value_10_3, value_11_3, value_12_3, value_13_3, value_14_3
    table_3_4.Contents = table_4_6
    local value_4_16: string = "Deathshard"
    table_3_4.Godly = value_4_16
    local value_4_17: string = "Weapons"
    table_3_4.BoxType = value_4_17
    local value_4_18: boolean = true
    table_3_4.Classic = value_4_18
    table_3_4.RarityChances = table_1
    table_2_2.KnifeBox1 = table_3_4
    local table_3_5: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_19: string = "Knife Box #2"
    table_3_5.Name = value_4_19
    local value_4_20: string = "rbxassetid://3180968681"
    table_3_5.Image = value_4_20
    local value_4_21: number = 0
    table_3_5.Released = value_4_21
    local table_4_7: {string?} = {
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
    local value_5_6: string = "Linked"
    local value_6_6: string = "Slate"
    local value_7_4: string = "Borders"
    local value_8_4: string = "8bit"
    local value_9_4: string = "Stalker"
    local value_10_4: string = "Missing"
    local value_11_4: string = "Cheesy"
    local value_12_4: string = "Krypto"
    local value_13_4: string = "Spectrum"
    local value_14_4: string = "OverseerKnife"
    table_4_7[1], table_4_7[2], table_4_7[3], table_4_7[4], table_4_7[5], table_4_7[6], table_4_7[7], table_4_7[8], table_4_7[9], table_4_7[10] = value_5_6, value_6_6, value_7_4, value_8_4, value_9_4, value_10_4, value_11_4, value_12_4, value_13_4, value_14_4
    table_3_5.Contents = table_4_7
    local value_4_22: string = "Fang"
    table_3_5.Godly = value_4_22
    local value_4_23: string = "Weapons"
    table_3_5.BoxType = value_4_23
    local value_4_24: boolean = true
    table_3_5.Classic = value_4_24
    table_3_5.RarityChances = table_1
    table_2_2.KnifeBox2 = table_3_5
end
do
    local table_3_6: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_25: string = "Knife Box #3"
    table_3_6.Name = value_4_25
    local value_4_26: string = "rbxassetid://3180969927"
    table_3_6.Image = value_4_26
    local value_4_27: number = 0
    table_3_6.Released = value_4_27
    local table_4_8: {string?} = {
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
    local value_5_7: string = "Clan"
    local value_6_7: string = "Cherry"
    local value_7_5: string = "Cardboard"
    local value_8_5: string = "Stainless"
    local value_9_5: string = "Circuit"
    local value_10_5: string = "Doge"
    local value_11_5: string = "Paper"
    local value_12_5: string = "Nova"
    local value_13_5: string = "Vortex"
    local value_14_5: string = "Splash"
    table_4_8[1], table_4_8[2], table_4_8[3], table_4_8[4], table_4_8[5], table_4_8[6], table_4_8[7], table_4_8[8], table_4_8[9], table_4_8[10] = value_5_7, value_6_7, value_7_5, value_8_5, value_9_5, value_10_5, value_11_5, value_12_5, value_13_5, value_14_5
    table_3_6.Contents = table_4_8
    local value_4_28: string = "Saw"
    table_3_6.Godly = value_4_28
    local value_4_29: string = "Weapons"
    table_3_6.BoxType = value_4_29
    local value_4_30: boolean = true
    table_3_6.Classic = value_4_30
    table_3_6.RarityChances = table_1
    table_2_2.KnifeBox3 = table_3_6
    local table_3_7: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_31: string = "Knife Box #4"
    table_3_7.Name = value_4_31
    local value_4_32: string = "rbxassetid://3180970565"
    table_3_7.Image = value_4_32
    local value_4_33: number = 1446239082
    table_3_7.Released = value_4_33
    local table_4_9: {string?} = {
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
    local value_5_8: string = "Bleached"
    local value_6_8: string = "Clown"
    local value_7_6: string = "Aqua"
    local value_8_6: string = "Oily"
    local value_9_6: string = "Hazmat"
    local value_10_6: string = "Melon"
    local value_11_6: string = "Hive"
    local value_12_6: string = "Korblox"
    local value_13_6: string = "Squire"
    local value_14_6: string = "Fade"
    table_4_9[1], table_4_9[2], table_4_9[3], table_4_9[4], table_4_9[5], table_4_9[6], table_4_9[7], table_4_9[8], table_4_9[9], table_4_9[10] = value_5_8, value_6_8, value_7_6, value_8_6, value_9_6, value_10_6, value_11_6, value_12_6, value_13_6, value_14_6
    table_3_7.Contents = table_4_9
    local value_4_34: string = "Slasher"
    table_3_7.Godly = value_4_34
    local value_4_35: string = "Weapons"
    table_3_7.BoxType = value_4_35
    local value_4_36: boolean = true
    table_3_7.Classic = value_4_36
    table_3_7.RarityChances = table_1
    table_2_2.KnifeBox4 = table_3_7
    local table_3_8: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_37: string = "Knife Box #5"
    table_3_8.Name = value_4_37
    local value_4_38: string = "rbxassetid://3180971059"
    table_3_8.Image = value_4_38
    local value_4_39: number = 0
    table_3_8.Released = value_4_39
    local table_4_10: {string?} = {
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
    local value_5_9: string = "Eco"
    local value_6_9: string = "Log"
    local value_7_7: string = "Sandy"
    local value_8_7: string = "Static"
    local value_9_7: string = "Brush"
    local value_10_7: string = "Jigsaw"
    local value_11_7: string = "Lucky"
    local value_12_7: string = "Abstract"
    local value_13_7: string = "Musical"
    local value_14_7: string = "Fusion"
    table_4_10[1], table_4_10[2], table_4_10[3], table_4_10[4], table_4_10[5], table_4_10[6], table_4_10[7], table_4_10[8], table_4_10[9], table_4_10[10] = value_5_9, value_6_9, value_7_7, value_8_7, value_9_7, value_10_7, value_11_7, value_12_7, value_13_7, value_14_7
    table_3_8.Contents = table_4_10
    local value_4_40: string = "Tides"
    table_3_8.Godly = value_4_40
    local value_4_41: string = "Weapons"
    table_3_8.BoxType = value_4_41
    local value_4_42: boolean = true
    table_3_8.Classic = value_4_42
    table_3_8.RarityChances = table_1
    table_2_2.KnifeBox5 = table_3_8
    local table_3_9: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_43: string = "Rainbow Box"
    table_3_9.Name = value_4_43
    local value_4_44: string = "rbxassetid://3180972343"
    table_3_9.Image = value_4_44
    local value_4_45: number = 0
    table_3_9.Released = value_4_45
    local table_4_11: {string?} = {
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
    local value_5_10: string = "Pepper"
    local value_6_10: string = "Fanta"
    local value_7_8: string = "Kool"
    local value_8_8: string = "Marley"
    local value_9_8: string = "LMFAO"
    local value_10_8: string = "Chips"
    local value_11_8: string = "Snoop"
    local value_12_8: string = "Dew"
    local value_13_8: string = "Doritos"
    local value_14_8: string = "MLG"
    table_4_11[1], table_4_11[2], table_4_11[3], table_4_11[4], table_4_11[5], table_4_11[6], table_4_11[7], table_4_11[8], table_4_11[9], table_4_11[10] = value_5_10, value_6_10, value_7_8, value_8_8, value_9_8, value_10_8, value_11_8, value_12_8, value_13_8, value_14_8
    table_3_9.Contents = table_4_11
    local value_4_46: string = "Heat"
    table_3_9.Godly = value_4_46
    local value_4_47: string = "Weapons"
    table_3_9.BoxType = value_4_47
    local value_4_48: boolean = true
    table_3_9.Classic = value_4_48
    table_3_9.RarityChances = table_1
    table_2_2["MLG Box"] = table_3_9
end
do
    local table_3_10: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_49: string = "Gun Box #1"
    table_3_10.Name = value_4_49
    local value_4_50: string = "rbxassetid://3180973254"
    table_3_10.Image = value_4_50
    local value_4_51: number = 0
    table_3_10.Released = value_4_51
    local table_4_12: {string?} = {
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
    local value_5_11: string = "Iron"
    local value_6_11: string = "Fallout"
    local value_7_9: string = "Cold"
    local value_8_9: string = "BigKill"
    local value_9_9: string = "BluesteelGun"
    local value_10_9: string = "AduriteGun"
    local value_11_9: string = "Camo"
    local value_12_9: string = "Imbued"
    local value_13_9: string = "Galactic"
    local value_14_9: string = "Viper"
    table_4_12[1], table_4_12[2], table_4_12[3], table_4_12[4], table_4_12[5], table_4_12[6], table_4_12[7], table_4_12[8], table_4_12[9], table_4_12[10] = value_5_11, value_6_11, value_7_9, value_8_9, value_9_9, value_10_9, value_11_9, value_12_9, value_13_9, value_14_9
    table_3_10.Contents = table_4_12
    local value_4_52: string = "Luger"
    table_3_10.Godly = value_4_52
    local value_4_53: string = "Weapons"
    table_3_10.BoxType = value_4_53
    local value_4_54: boolean = true
    table_3_10.Classic = value_4_54
    table_3_10.RarityChances = table_1
    table_2_2.GunBox1 = table_3_10
    local table_3_11: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_55: string = "Gun Box #2"
    table_3_11.Name = value_4_55
    local value_4_56: string = "rbxassetid://3180973441"
    table_3_11.Image = value_4_56
    local value_4_57: number = 0
    table_3_11.Released = value_4_57
    local table_4_13: {string?} = {
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
    local value_5_12: string = "Engraved"
    local value_6_12: string = "Infiltrator"
    local value_7_10: string = "Aid"
    local value_8_10: string = "Star"
    local value_9_10: string = "Sketch"
    local value_10_10: string = "Marina"
    local value_11_10: string = "Cheddar"
    local value_12_10: string = "iRevolver"
    local value_13_10: string = "Hacker"
    local value_14_10: string = "Predator"
    table_4_13[1], table_4_13[2], table_4_13[3], table_4_13[4], table_4_13[5], table_4_13[6], table_4_13[7], table_4_13[8], table_4_13[9], table_4_13[10] = value_5_12, value_6_12, value_7_10, value_8_10, value_9_10, value_10_10, value_11_10, value_12_10, value_13_10, value_14_10
    table_3_11.Contents = table_4_13
    local value_4_58: string = "Shark"
    table_3_11.Godly = value_4_58
    local value_4_59: string = "Weapons"
    table_3_11.BoxType = value_4_59
    local value_4_60: boolean = true
    table_3_11.Classic = value_4_60
    table_3_11.RarityChances = table_1
    table_2_2.GunBox2 = table_3_11
    local table_3_12: { BoxType: string?, Classic: boolean?, Contents: {string?}?, Godly: string?, Image: string?, Name: string?, RarityChances: {{ Chance: number, Rarity: string }?}?, Released: number? } = {
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
        [("Name")] = nil,
    }
    local value_4_61: string = "Gun Box #3"
    table_3_12.Name = value_4_61
    local value_4_62: string = "rbxassetid://3180973740"
    table_3_12.Image = value_4_62
    local value_4_63: number = 1429205594
    table_3_12.Released = value_4_63
    local table_4_14: {string?} = {
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
    local value_5_13: string = "Bit"
    local value_6_13: string = "Pea"
    local value_7_11: string = "News"
    local value_8_11: string = "HL2"
    local value_9_11: string = "Caution"
    local value_10_11: string = "Cola"
    local value_11_11: string = "Wooden"
    local value_12_11: string = "Ace"
    local value_13_11: string = "Bacon"
    local value_14_11: string = "Universe"
    table_4_14[1], table_4_14[2], table_4_14[3], table_4_14[4], table_4_14[5], table_4_14[6], table_4_14[7], table_4_14[8], table_4_14[9], table_4_14[10] = value_5_13, value_6_13, value_7_11, value_8_11, value_9_11, value_10_11, value_11_11, value_12_11, value_13_11, value_14_11
    table_3_12.Contents = table_4_14
    local value_4_64: string = "Laser"
    table_3_12.Godly = value_4_64
    local value_4_65: string = "Weapons"
    table_3_12.BoxType = value_4_65
    local value_4_66: boolean = true
    table_3_12.Classic = value_4_66
    table_3_12.RarityChances = table_1
    table_2_2.GunBox3 = table_3_12
end

return table_2_2
