--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Ancient: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Christmas: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Classic: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Common: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Godly: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Halloween: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Legendary: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Rare: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Uncommon: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
    Unique: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number },
}

local table_1: { Ancient: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Christmas: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Classic: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Common: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Godly: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Halloween: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Legendary: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Rare: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Uncommon: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number }, Unique: nil | { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } | { Color: { b: number, g: number, r: number }, Hex: string, Name: string, Sort: number } } = {
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
local table_2: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Common",
    Sort = 100,
    Color = 0,
    Hex = "#6a6a6a",
}
local table_3: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4: number = 106
table_3.r = value_4
local value_4_2: number = 106
table_3.g = value_4_2
local value_4_3: number = 106
table_3.b = value_4_3
table_2.Color = table_3
table_1.Common = table_2
local table_2_2: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Uncommon",
    Sort = 95,
    Color = 0,
    Hex = "#00ffff",
}
local table_3_2: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_4: number = 0
table_3_2.r = value_4_4
local value_4_5: number = 255
table_3_2.g = value_4_5
local value_4_6: number = 255
table_3_2.b = value_4_6
table_2_2.Color = table_3_2
table_1.Uncommon = table_2_2
local table_2_3: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Rare",
    Sort = 90,
    Color = 0,
    Hex = "#00c800",
}
local table_3_3: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_7: number = 0
table_3_3.r = value_4_7
local value_4_8: number = 200
table_3_3.g = value_4_8
local value_4_9: number = 0
table_3_3.b = value_4_9
table_2_3.Color = table_3_3
table_1.Rare = table_2_3
local table_2_4: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Sort = 85,
    Name = "Legendary",
    Color = 0,
    Hex = "#dc0005",
}
local table_3_4: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_10: number = 220
table_3_4.r = value_4_10
local value_4_11: number = 0
table_3_4.g = value_4_11
local value_4_12: number = 5
table_3_4.b = value_4_12
table_2_4.Color = table_3_4
table_1.Legendary = table_2_4
local table_2_5: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Sort = 80,
    Name = "Godly",
    Color = 0,
    Hex = "#ff00b3",
}
local table_3_5: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_13: number = 255
table_3_5.r = value_4_13
local value_4_14: number = 0
table_3_5.g = value_4_14
local value_4_15: number = 179
table_3_5.b = value_4_15
table_2_5.Color = table_3_5
table_1.Godly = table_2_5
local table_2_6: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Ancient",
    Sort = 75,
    Color = 0,
    Hex = "#640aff",
}
local table_3_6: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_16: number = 100
table_3_6.r = value_4_16
local value_4_17: number = 10
table_3_6.g = value_4_17
local value_4_18: number = 255
table_3_6.b = value_4_18
table_2_6.Color = table_3_6
table_1.Ancient = table_2_6
local table_2_7: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Sort = 110,
    Name = "Vintage",
    Color = 0,
    Hex = "#e6c800",
}
local table_3_7: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_19: number = 230
table_3_7.r = value_4_19
local value_4_20: number = 200
table_3_7.g = value_4_20
local value_4_21: number = 0
table_3_7.b = value_4_21
table_2_7.Color = table_3_7
table_1.Classic = table_2_7
local table_2_8: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Sort = 70,
    Name = "Unique",
    Color = 0,
    Hex = "#fa8c00",
}
local table_3_8: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_22: number = 240
table_3_8.r = value_4_22
local value_4_23: number = 140
table_3_8.g = value_4_23
local value_4_24: number = 0
table_3_8.b = value_4_24
table_2_8.Color = table_3_8
table_1.Unique = table_2_8
local table_2_9: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Christmas",
    Sort = 105,
    Color = 0,
    Hex = "#1ec3be",
}
local table_3_9: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_25: number = 30
table_3_9.r = value_4_25
local value_4_26: number = 195
table_3_9.g = value_4_26
local value_4_27: number = 190
table_3_9.b = value_4_27
table_2_9.Color = table_3_9
table_1.Christmas = table_2_9
local table_2_10: { Color: number | { b: number, g: number, r: number } | { b: number?, g: number?, r: number? }, Hex: string, Name: string, Sort: number } = {
    Name = "Halloween",
    Sort = 104,
    Color = 0,
    Hex = "#b44600",
}
local table_3_10: { b: number?, g: number?, r: number? } = {
    [("r")] = nil,
    [("r")] = nil,
    [("r")] = nil,
}
local value_4_28: number = 180
table_3_10.r = value_4_28
local value_4_29: number = 70
table_3_10.g = value_4_29
local value_4_30: number = 0
table_3_10.b = value_4_30
table_2_10.Color = table_3_10
table_1.Halloween = table_2_10

return table_1
