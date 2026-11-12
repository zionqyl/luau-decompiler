--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Box: string,
    Cover: string,
    HotItems: number | {{ ItemID: string, Type: string }?},
}

local table_1: { Box: string, Cover: string, HotItems: number | {{ ItemID: string, Type: string }?} } = {
    Cover = "rbxassetid://2171174581",
    Box = "MysteryBox2",
    HotItems = 0,
}
local table_2: {{ ItemID: string, Type: string }?} = {
    nil,
    nil,
    nil,
    nil,
}
local table_3: { ItemID: string, Type: string } = {ItemID = "Dual", Type = "Effects"}
local table_4: { ItemID: string, Type: string } = {ItemID = "Electric", Type = "Effects"}
local table_5: { ItemID: string, Type: string } = {ItemID = "Ghost", Type = "Perks"}
local table_6: { ItemID: string, Type: string } = {ItemID = "Xray", Type = "Perks"}
table_2[1], table_2[2], table_2[3], table_2[4] = table_3, table_4, table_5, table_6
table_1.HotItems = table_2

return table_1
