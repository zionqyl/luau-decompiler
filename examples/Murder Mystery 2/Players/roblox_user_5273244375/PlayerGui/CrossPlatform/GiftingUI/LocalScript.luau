--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local character_added_value = game.Players.LocalPlayer.CharacterAdded
local value_5: (() -> ())?
do
    local captured_value = parent_value
    value_5 = function(): ()
        local value_1: Instance? = captured_value
        local value_2: boolean = false
        value_1.Visible = value_2

        return
    end
end
character_added_value:Connect(value_5)

return
