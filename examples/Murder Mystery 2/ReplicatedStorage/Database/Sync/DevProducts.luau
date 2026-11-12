--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = { ["538886310"]: {{ Amount: number, ItemID: string, ItemType: string }}? }

local value_1: boolean?
if game.GameId ~= 119460199 then
    value_1 = false
else
    value_1 = true
end
local game_value_2: DataModel = game
local value_4: string = "RunService"
local is_studio_result = game_value_2:GetService(value_4):IsStudio()
local table_2: { ["538886310"]: {{ Amount: number, ItemID: string, ItemType: string }}? } = {
    ["538886310"] = nil,
}
local table_3: {{ Amount: number, ItemID: string, ItemType: string }} = {
    {ItemID = "Gems", ItemType = "Currency", Amount = 100},
}
table_2["538886310"] = table_3
if value_1 then
end

return table_2
