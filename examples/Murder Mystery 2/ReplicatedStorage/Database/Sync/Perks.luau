--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type Module = {
    Decoy: { Active: boolean, Charges: number, Cooldown: number, Description: string, Image: string, Name: string, Type: string }?,
    FakeGun: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? },
    Footsteps: nil | { Active: boolean, Character: number, Description: string, Image: string, Local: number, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Character: number?, Description: string?, Image: string?, Local: number?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? },
    Ghost: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? },
    Haste: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? },
    Ninja: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? },
    Sleight: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? },
    Sprint: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? },
    Trap: nil | { Active: boolean, Charges: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Charges: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? },
    VampireBat: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Type: string } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Type: string? },
    Xray: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? },
}

local table_1: { Decoy: { Active: boolean, Charges: number, Cooldown: number, Description: string, Image: string, Name: string, Type: string }?, FakeGun: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? }, Footsteps: nil | { Active: boolean, Character: number, Description: string, Image: string, Local: number, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Character: number?, Description: string?, Image: string?, Local: number?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? }, Ghost: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? }, Haste: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? }, Ninja: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? }, Sleight: nil | { Active: boolean, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? }, Sprint: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? }, Trap: nil | { Active: boolean, Charges: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string } | { Active: boolean?, Charges: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? }, VampireBat: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Type: string } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Type: string? }, Xray: nil | { Active: boolean, ActiveTime: number, Cooldown: number, Description: string, Image: string, Name: string, Price: number, Type: string, UnlockLevel: number } | { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } } = {
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
    [("Footsteps")] = nil,
}
local table_2: { Active: boolean?, Character: number?, Description: string?, Image: string?, Local: number?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } = {
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
local value_3: string = "Footsteps"
table_2.Name = value_3
local value_3_2: string = "https://www.roblox.com/asset/?id=336404773"
table_2.Image = value_3_2
local value_3_3: number = 1
table_2.UnlockLevel = value_3_3
local value_3_4: number = 0
table_2.Price = value_3_4
local value_3_5: string = "Allows you to see the footprints of innocents."
table_2.Description = value_3_5
local value_3_6: string = "Murderer"
table_2.Type = value_3_6
local value_3_7: boolean = false
table_2.Active = value_3_7
local value_3_8: number = 0
table_2.Character = value_3_8
local value_3_9: number = 0
table_2.Local = value_3_9
table_1.Footsteps = table_2
local table_2_2: { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_10: string = "Sleight"
table_2_2.Name = value_3_10
local value_3_11: string = "https://www.roblox.com/asset/?id=340309581"
table_2_2.Image = value_3_11
local value_3_12: number = 22
table_2_2.UnlockLevel = value_3_12
local value_3_13: number = 400
table_2_2.Price = value_3_13
local value_3_14: string = "Throw knives quicker."
table_2_2.Description = value_3_14
local value_3_15: string = "Murderer"
table_2_2.Type = value_3_15
local value_3_16: boolean = false
table_2_2.Active = value_3_16
table_1.Sleight = table_2_2
local table_2_3: { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_17: string = "Ninja"
table_2_3.Name = value_3_17
local value_3_18: string = "https://www.roblox.com/asset/?id=416832054"
table_2_3.Image = value_3_18
local value_3_19: number = 600
table_2_3.Price = value_3_19
local value_3_20: string = "Your knife becomes silent. Coins are silent while holding knife."
table_2_3.Description = value_3_20
local value_3_21: string = "Murderer"
table_2_3.Type = value_3_21
local value_3_22: boolean = false
table_2_3.Active = value_3_22
table_1.Ninja = table_2_3
local table_2_4: { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_23: string = "Haste"
table_2_4.Name = value_3_23
local value_3_24: string = "https://www.roblox.com/asset/?id=416942717"
table_2_4.Image = value_3_24
local value_3_25: number = 1000
table_2_4.Price = value_3_25
local value_3_26: string = "Increases the murderer walkspeed while holding the knife from 17 to 18"
table_2_4.Description = value_3_26
local value_3_27: string = "Murderer"
table_2_4.Type = value_3_27
local value_3_28: boolean = false
table_2_4.Active = value_3_28
table_1.Haste = table_2_4
local table_2_5: { Active: boolean?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_29: string = "Fake Gun"
table_2_5.Name = value_3_29
local value_3_30: string = "http://www.roblox.com/asset/?id=17899774181"
table_2_5.Image = value_3_30
local value_3_31: number = 79
table_2_5.UnlockLevel = value_3_31
local value_3_32: number = 700
table_2_5.Price = value_3_32
local value_3_33: string = "Get a fake gun at the start of the round to trick people"
table_2_5.Description = value_3_33
local value_3_34: string = "Murderer"
table_2_5.Type = value_3_34
local value_3_35: boolean = false
table_2_5.Active = value_3_35
table_1.FakeGun = table_2_5
local table_2_6: { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } = {
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
local value_3_36: string = "Ghost"
table_2_6.Name = value_3_36
local value_3_37: string = "https://www.roblox.com/asset/?id=335206856"
table_2_6.Image = value_3_37
local value_3_38: number = 53
table_2_6.UnlockLevel = value_3_38
local value_3_39: number = 1100
table_2_6.Price = value_3_39
local value_3_40: string = "Go invisible for a few seconds."
table_2_6.Description = value_3_40
local value_3_41: string = "Murderer"
table_2_6.Type = value_3_41
local value_3_42: boolean = true
table_2_6.Active = value_3_42
local value_3_43: number = 5
table_2_6.ActiveTime = value_3_43
local value_3_44: number = 30
table_2_6.Cooldown = value_3_44
table_1.Ghost = table_2_6
local table_2_7: { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string?, UnlockLevel: number? } = {
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
local value_3_45: string = "X-Ray"
table_2_7.Name = value_3_45
local value_3_46: string = "https://www.roblox.com/asset/?id=340313896"
table_2_7.Image = value_3_46
local value_3_47: number = 61
table_2_7.UnlockLevel = value_3_47
local value_3_48: number = 1300
table_2_7.Price = value_3_48
local value_3_49: string = "See through walls for a few seconds. 30s cooldown."
table_2_7.Description = value_3_49
local value_3_50: string = "Murderer"
table_2_7.Type = value_3_50
local value_3_51: boolean = true
table_2_7.Active = value_3_51
local value_3_52: number = 4
table_2_7.ActiveTime = value_3_52
local value_3_53: number = 30
table_2_7.Cooldown = value_3_53
table_1.Xray = table_2_7
local table_2_8: { Active: boolean?, Charges: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_54: string = "Trap"
table_2_8.Name = value_3_54
local value_3_55: string = "https://www.roblox.com/asset/?id=4966828196"
table_2_8.Image = value_3_55
local value_3_56: number = 1000
table_2_8.Price = value_3_56
local value_3_57: string = "Places an invisible trap that will stop innocents. Max 4 traps."
table_2_8.Description = value_3_57
local value_3_58: string = "Murderer"
table_2_8.Type = value_3_58
local value_3_59: boolean = true
table_2_8.Active = value_3_59
local value_3_60: number = 4
table_2_8.Charges = value_3_60
local value_3_61: number = 0.5
table_2_8.Cooldown = value_3_61
table_1.Trap = table_2_8
local table_2_9: { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Price: number?, Type: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_62: string = "Sprint"
table_2_9.Name = value_3_62
local value_3_63: string = "https://www.roblox.com/asset/?id=4970219155"
table_2_9.Image = value_3_63
local value_3_64: number = 1000
table_2_9.Price = value_3_64
local value_3_65: string = "Activate to gain a 50% speed boost temporarily."
table_2_9.Description = value_3_65
local value_3_66: string = "Murderer"
table_2_9.Type = value_3_66
local value_3_67: boolean = true
table_2_9.Active = value_3_67
local value_3_68: number = 30
table_2_9.Cooldown = value_3_68
local value_3_69: number = 5
table_2_9.ActiveTime = value_3_69
table_1.Sprint = table_2_9
local table_2_10: { Active: boolean?, ActiveTime: number?, Cooldown: number?, Description: string?, Image: string?, Name: string?, Type: string? } = {
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
    [("Name")] = nil,
}
local value_3_70: string = "Bat Form"
table_2_10.Name = value_3_70
local value_3_71: string = "rbxassetid://129078122681639"
table_2_10.Image = value_3_71
local value_3_72: string = "Transform into a bat."
table_2_10.Description = value_3_72
local value_3_73: string = "Murderer"
table_2_10.Type = value_3_73
local value_3_74: boolean = true
table_2_10.Active = value_3_74
local value_3_75: number = 20
table_2_10.Cooldown = value_3_75
local value_3_76: number = 5
table_2_10.ActiveTime = value_3_76
table_1.VampireBat = table_2_10
local table_2_11: { Active: boolean, Charges: number, Cooldown: number, Description: string, Image: string, Name: string, Type: string } = {
    Name = "Decoy",
    Image = "rbxassetid://113722008817201",
    Description = "Place a decoy of you that can block a shot.",
    Type = "Murderer",
    Active = true,
    Charges = 3,
    Cooldown = 0.5,
}
table_1.Decoy = table_2_11

return table_1
