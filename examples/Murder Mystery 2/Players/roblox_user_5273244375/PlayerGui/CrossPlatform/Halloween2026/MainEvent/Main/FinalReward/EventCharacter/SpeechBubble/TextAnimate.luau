--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local value_1 = 0
local value_2 = ""
local value_3 = 0
local value_4 = 4
TextJump = value_4
value_4 = 0
local parent_value: Instance? = script.Parent
local value_7: string = "AnimatedText"
local get_attribute_changed_signal_result = parent_value:GetAttributeChangedSignal(value_7)

local function value_7_2(): ()
    value_4 = (os.clock())
    value_1 = 0
    local parent_value_2: Instance? = script.Parent
    local value_3_2: string = "AnimatedText"
    value_2 = (parent_value_2:GetAttribute(value_3_2))

    return
end

get_attribute_changed_signal_result:connect(value_7_2)
local game_value: DataModel = game
local value_7_3: string = "RunService"
local stepped_value = game_value:GetService(value_7_3).Stepped

local function value_7_4(): ()
    if 0.011 <= (os.clock()) - value_3 then
        value_3 = (os.clock())
        value_1 = value_1 + TextJump
    end
    local value_2_5 = value_2
    local value_3_4: number = 1
    local value_4_2 = value_1
    local sub_result = string.sub(value_2_5, value_3_4, value_4_2)
    local parent_value_3: Instance? = script.Parent
    parent_value_3.Text = sub_result
    if 3 <= (os.clock()) - value_4 then
        local parent_value_4: Instance? = script.Parent
        local value_4_4: string = "AnimatedText"
        local value_5_5: string = ""
        parent_value_4:SetAttribute(value_4_4, value_5_5)
    end

    return
end

stepped_value:Connect(value_7_4)

return
