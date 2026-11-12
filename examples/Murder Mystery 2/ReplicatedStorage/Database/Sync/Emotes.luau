--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Back: nil | { Image: string, Price: string } | { Image: string?, Price: string? },
    cheer: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? },
    dab: nil | { AnimationID: number, Command: string, Image: string, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: number? },
    dance1: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? },
    dance2: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? },
    dance3: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? },
    floss: nil | { AnimationID: number, Command: string, Gems: boolean, Image: string, Loop: boolean, Name: string, Price: number, Rarity: string } | { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? },
    headless: nil | { AnimationID: number, Command: string, Image: string, Name: string, Price: string } | { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: string? },
    laugh: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? },
    ninja: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? },
    point: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? },
    sit: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? },
    wave: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? },
    zen: nil | { AnimationID: number, Command: string, Gems: boolean, Image: string, Loop: boolean, Name: string, Price: number, Rarity: string } | { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? },
    zombie: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? },
}

local table_1: { Back: nil | { Image: string, Price: string } | { Image: string?, Price: string? }, cheer: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? }, dab: nil | { AnimationID: number, Command: string, Image: string, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: number? }, dance1: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? }, dance2: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? }, dance3: nil | { Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? }, floss: nil | { AnimationID: number, Command: string, Gems: boolean, Image: string, Loop: boolean, Name: string, Price: number, Rarity: string } | { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? }, headless: nil | { AnimationID: number, Command: string, Image: string, Name: string, Price: string } | { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: string? }, laugh: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? }, ninja: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? }, point: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? }, sit: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: number } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? }, wave: nil | { Command: string, Image: string, Name: string, Price: string } | { Command: string?, Image: string?, Name: string?, Price: string? }, zen: nil | { AnimationID: number, Command: string, Gems: boolean, Image: string, Loop: boolean, Name: string, Price: number, Rarity: string } | { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? }, zombie: nil | { AnimationID: number, Command: string, Image: string, Loop: boolean, Name: string, Price: string } | { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? } } = {
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
    [("sit")] = nil,
}
local table_2: { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3: string = "Sit"
table_2.Name = value_3
local value_3_2: string = "sit2"
table_2.Command = value_3_2
local value_3_3: string = "http://www.roblox.com/asset/?id=198215446"
table_2.Image = value_3_3
local value_3_4: number = 2431845940
table_2.AnimationID = value_3_4
local value_3_5: boolean = true
table_2.Loop = value_3_5
local value_3_6: number = 200
table_2.Price = value_3_6
table_1.sit = table_2
local table_2_2: { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_7: string = "Ninja Rest"
table_2_2.Name = value_3_7
local value_3_8: string = "ninja"
table_2_2.Command = value_3_8
local value_3_9: string = "http://www.roblox.com/asset/?id=198273910"
table_2_2.Image = value_3_9
local value_3_10: number = 2431864798
table_2_2.AnimationID = value_3_10
local value_3_11: boolean = true
table_2_2.Loop = value_3_11
local value_3_12: number = 650
table_2_2.Price = value_3_12
table_1.ninja = table_2_2
local table_2_3: { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_13: string = "Zen"
table_2_3.Name = value_3_13
local value_3_14: string = "zen"
table_2_3.Command = value_3_14
local value_3_15: string = "http://www.roblox.com/asset/?id=198273518"
table_2_3.Image = value_3_15
local value_3_16: number = 2431812646
table_2_3.AnimationID = value_3_16
local value_3_17: boolean = true
table_2_3.Loop = value_3_17
local value_3_18: number = 800
table_2_3.Price = value_3_18
local value_3_19: boolean = true
table_2_3.Gems = value_3_19
local value_3_20: string = "Rare"
table_2_3.Rarity = value_3_20
table_1.zen = table_2_3
local table_2_4: { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_21: string = "Dab"
table_2_4.Name = value_3_21
local value_3_22: string = "dab"
table_2_4.Command = value_3_22
local value_3_23: string = "rbxassetid://2474247481"
table_2_4.Image = value_3_23
local value_3_24: number = 2445521505
table_2_4.AnimationID = value_3_24
local value_3_25: number = 700
table_2_4.Price = value_3_25
table_1.dab = table_2_4
local table_2_5: { AnimationID: number?, Command: string?, Gems: boolean?, Image: string?, Loop: boolean?, Name: string?, Price: number?, Rarity: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_26: string = "Floss"
table_2_5.Name = value_3_26
local value_3_27: string = "floss"
table_2_5.Command = value_3_27
local value_3_28: string = "rbxassetid://2474247282"
table_2_5.Image = value_3_28
local value_3_29: number = 2452938820
table_2_5.AnimationID = value_3_29
local value_3_30: boolean = true
table_2_5.Loop = value_3_30
local value_3_31: number = 750
table_2_5.Price = value_3_31
local value_3_32: boolean = true
table_2_5.Gems = value_3_32
local value_3_33: string = "Rare"
table_2_5.Rarity = value_3_33
table_1.floss = table_2_5
local table_2_6: { AnimationID: number?, Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_34: string = "Zombie"
table_2_6.Name = value_3_34
local value_3_35: string = "zombie"
table_2_6.Command = value_3_35
local value_3_36: string = "rbxassetid://2513709229"
table_2_6.Image = value_3_36
local value_3_37: number = 2513692312
table_2_6.AnimationID = value_3_37
local value_3_38: boolean = true
table_2_6.Loop = value_3_38
local value_3_39: string = "NotForSale"
table_2_6.Price = value_3_39
table_1.zombie = table_2_6
local table_2_7: { AnimationID: number?, Command: string?, Image: string?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_40: string = "Headless"
table_2_7.Name = value_3_40
local value_3_41: string = "headless"
table_2_7.Command = value_3_41
local value_3_42: string = "rbxassetid://2513709230"
table_2_7.Image = value_3_42
local value_3_43: number = 2513664073
table_2_7.AnimationID = value_3_43
local value_3_44: string = "NotForSale"
table_2_7.Price = value_3_44
table_1.headless = table_2_7
local table_2_8: { Image: string?, Price: string? } = {[("Image")] = nil, [("Image")] = nil}
local value_3_45: string = ""
table_2_8.Image = value_3_45
local value_3_46: string = "NotForSale"
table_2_8.Price = value_3_46
table_1.Back = table_2_8
local table_2_9: { Command: string?, Image: string?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_47: string = "Wave"
table_2_9.Name = value_3_47
local value_3_48: string = "wave"
table_2_9.Command = value_3_48
local value_3_49: string = "rbxassetid://2435882728"
table_2_9.Image = value_3_49
local value_3_50: string = "NotForSale"
table_2_9.Price = value_3_50
table_1.wave = table_2_9
local table_2_10: { Command: string?, Image: string?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_51: string = "Cheer"
table_2_10.Name = value_3_51
local value_3_52: string = "cheer"
table_2_10.Command = value_3_52
local value_3_53: string = "rbxassetid://2435882701"
table_2_10.Image = value_3_53
local value_3_54: string = "NotForSale"
table_2_10.Price = value_3_54
table_1.cheer = table_2_10
local table_2_11: { Command: string?, Image: string?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_55: string = "Laugh"
table_2_11.Name = value_3_55
local value_3_56: string = "laugh"
table_2_11.Command = value_3_56
local value_3_57: string = "rbxassetid://2435995264"
table_2_11.Image = value_3_57
local value_3_58: string = "NotForSale"
table_2_11.Price = value_3_58
table_1.laugh = table_2_11
local table_2_12: { Command: string?, Image: string?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_59: string = "Point"
table_2_12.Name = value_3_59
local value_3_60: string = "point"
table_2_12.Command = value_3_60
local value_3_61: string = "rbxassetid://2435938718"
table_2_12.Image = value_3_61
local value_3_62: string = "NotForSale"
table_2_12.Price = value_3_62
table_1.point = table_2_12
local table_2_13: { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_63: string = "Dance 1"
table_2_13.Name = value_3_63
local value_3_64: string = "dance"
table_2_13.Command = value_3_64
local value_3_65: string = "rbxassetid://2435882712"
table_2_13.Image = value_3_65
local value_3_66: boolean = true
table_2_13.Loop = value_3_66
local value_3_67: string = "NotForSale"
table_2_13.Price = value_3_67
table_1.dance1 = table_2_13
local table_2_14: { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_68: string = "Dance 2"
table_2_14.Name = value_3_68
local value_3_69: string = "dance2"
table_2_14.Command = value_3_69
local value_3_70: string = "rbxassetid://2435882711"
table_2_14.Image = value_3_70
local value_3_71: boolean = true
table_2_14.Loop = value_3_71
local value_3_72: string = "NotForSale"
table_2_14.Price = value_3_72
table_1.dance2 = table_2_14
local table_2_15: { Command: string?, Image: string?, Loop: boolean?, Name: string?, Price: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_73: string = "Dance 3"
table_2_15.Name = value_3_73
local value_3_74: string = "dance3"
table_2_15.Command = value_3_74
local value_3_75: string = "rbxassetid://2435882719"
table_2_15.Image = value_3_75
local value_3_76: boolean = true
table_2_15.Loop = value_3_76
local value_3_77: string = "NotForSale"
table_2_15.Price = value_3_77
table_1.dance3 = table_2_15

return table_1
