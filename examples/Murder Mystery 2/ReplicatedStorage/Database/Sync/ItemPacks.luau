--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    ["1165838634"]: {{ ItemName: string, Type: string }}?,
    ["1166580569"]: {{ ItemName: string, Type: string }?}?,
    ["1167438350"]: {{ ItemName: string, Type: string }}?,
    ["1326724250"]: {{ Evo: boolean, ItemName: string, Type: string }}?,
    ["1533049236"]: {{ ItemName: string, Type: string }}?,
    ["1534775989"]: {{ ItemName: string, Type: string }}?,
    ["1535587918"]: {{ ItemName: string, Type: string }?}?,
}

local table_1: { ["1165838634"]: {{ ItemName: string, Type: string }}?, ["1166580569"]: {{ ItemName: string, Type: string }?}?, ["1167438350"]: {{ ItemName: string, Type: string }}?, ["1326724250"]: {{ Evo: boolean, ItemName: string, Type: string }}?, ["1533049236"]: {{ ItemName: string, Type: string }}?, ["1534775989"]: {{ ItemName: string, Type: string }}?, ["1535587918"]: {{ ItemName: string, Type: string }?}? } = {
    ["1165838634"] = nil,
    ["1165838634"] = nil,
    ["1165838634"] = nil,
    ["1165838634"] = nil,
    ["1165838634"] = nil,
}
local table_2: {{ ItemName: string, Type: string }} = {
    {ItemName = "Bloom", Type = "Weapons"},
}
table_1["1165838634"] = table_2
local table_2_2: {{ ItemName: string, Type: string }} = {
    {ItemName = "Flora", Type = "Weapons"},
}
table_1["1167438350"] = table_2_2
local table_2_3: {{ ItemName: string, Type: string }?} = {nil, nil, nil}
local table_3_3: { ItemName: string, Type: string } = {
    ItemName = "Bloom",
    Type = "Weapons",
}
local table_4: { ItemName: string, Type: string } = {ItemName = "Flora", Type = "Weapons"}
local table_5: { ItemName: string, Type: string } = {
    ItemName = "Bloom2025",
    Type = "Effects",
}
table_2_3[1], table_2_3[2], table_2_3[3] = table_3_3, table_4, table_5
table_1["1166580569"] = table_2_3
local table_2_4: {{ Evo: boolean, ItemName: string, Type: string }} = {
    {ItemName = "Synthwave", Type = "Weapons", Evo = true},
}
table_1["1326724250"] = table_2_4
local table_2_5: {{ ItemName: string, Type: string }} = {
    {ItemName = "XenoKnife", Type = "Weapons"},
}
table_1["1534775989"] = table_2_5
local table_2_6: {{ ItemName: string, Type: string }} = {
    {ItemName = "XenoGun", Type = "Weapons"},
}
table_1["1533049236"] = table_2_6
local table_2_7: {{ ItemName: string, Type: string }?} = {nil, nil, nil}
local table_3_7: { ItemName: string, Type: string } = {
    ItemName = "XenoKnife",
    Type = "Weapons",
}
local table_4_2: { ItemName: string, Type: string } = {
    ItemName = "XenoGun",
    Type = "Weapons",
}
local table_5_2: { ItemName: string, Type: string } = {
    ItemName = "XenoEffect",
    Type = "Effects",
}
table_2_7[1], table_2_7[2], table_2_7[3] = table_3_7, table_4_2, table_5_2
table_1["1535587918"] = table_2_7

return table_1
