--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type CreateFadeInfoResult<T1> = {
    End: {
        BackgroundColor3: nil,
        BackgroundTransparency: nil,
    },
    Start: {
        BackgroundColor3: nil,
        BackgroundTransparency: nil,
    },
    Time: number,
}

local table_1 = {
    [("CreateFadeInfo")] = nil,
    [("CreateFadeInfo")] = nil,
    [("CreateFadeInfo")] = nil,
}

local function create_fade_info<T1>(argument_1: T1): CreateFadeInfoResult<T1>
    local table_2: { End: number | { BackgroundColor3: nil, BackgroundTransparency: nil }, Start: number | { BackgroundColor3: nil, BackgroundTransparency: nil }, Time: number } = {
        Start = 0,
        End = 0,
        Time = 1,
    }
    local table_3: { BackgroundColor3: nil, BackgroundTransparency: nil } = {
        BackgroundTransparency = nil,
        BackgroundColor3 = nil,
    }
    table_2.Start = table_3
    local table_3_2: { BackgroundColor3: nil, BackgroundTransparency: nil } = {
        BackgroundTransparency = nil,
        BackgroundColor3 = nil,
    }
    table_2.End = table_3_2

    return table_2
end

table_1.CreateFadeInfo = create_fade_info
local create_fade_info_result = table_1:CreateFadeInfo()
table_1.FadeIn = create_fade_info_result
local start_value = table_1.FadeIn.Start
local from_rgb_result: Color3 = Color3.fromRGB(0, 0, 0)
start_value.BackgroundColor3 = from_rgb_result
local start_value_2 = table_1.FadeIn.Start
local value_3_2: number = 0
start_value_2.BackgroundTransparency = value_3_2
local end_value = table_1.FadeIn.End
local value_3_3: number = 1
end_value.BackgroundTransparency = value_3_3
local create_fade_info_result_2 = table_1:CreateFadeInfo()
table_1.FadeOut = create_fade_info_result_2
local start_value_3 = table_1.FadeOut.Start
local from_rgb_result_2: Color3 = Color3.fromRGB(0, 0, 0)
start_value_3.BackgroundColor3 = from_rgb_result_2
local start_value_4 = table_1.FadeOut.Start
local value_3_5: number = 1
start_value_4.BackgroundTransparency = value_3_5
local end_value_2 = table_1.FadeOut.End
local value_3_6: number = 0
end_value_2.BackgroundTransparency = value_3_6

local function play_fade(argument_1_2): ()
    local game_value: DataModel = game
    local value_4_3: string = "TweenService"
    local tween_service: Instance = game_value:GetService(value_4_3)
    local player_gui_value = game.Players.LocalPlayer.PlayerGui
    local value_5_3: string = "Fade"
    local fade_child = player_gui_value:WaitForChild(value_5_3)
    local value_6_3: string = "Frame"
    local frame_child = fade_child:WaitForChild(value_6_3)
    local background_transparency_value = argument_1_2.Start.BackgroundTransparency
    frame_child.BackgroundTransparency = background_transparency_value
    local background_color3_value = argument_1_2.Start.BackgroundColor3
    frame_child.BackgroundColor3 = background_color3_value
    local value_3_9: TweenInfo = (TweenInfo.new(argument_1_2.Time, Enum.EasingStyle.Linear))
    local value_7 = frame_child
    local value_8: TweenInfo = value_3_9
    local table_9 = {
        BackgroundTransparency = argument_1_2.End.BackgroundTransparency,
        BackgroundColor3 = argument_1_2.End.BackgroundColor3,
    }
    tween_service:Create(value_7, value_8, table_9):Play()

    return
end

table_1.PlayFade = play_fade

return table_1
