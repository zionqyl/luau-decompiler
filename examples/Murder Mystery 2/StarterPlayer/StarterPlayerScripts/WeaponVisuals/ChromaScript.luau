--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

export type ColorData = {
    B: number,
    G: number,
    R: number,
}

local closure_cache = {}

local function same_capture(left_capture, right_capture): boolean
    if left_capture == nil or right_capture == nil then
        return left_capture == right_capture
    end
    if left_capture ~= left_capture or right_capture ~= right_capture then
        return false
    end
    local identity_lookup = {[left_capture] = true}

    return identity_lookup[right_capture] == true
end

local game_value: DataModel = game
local value_3: boolean | string = "RunService"
local run_service: Instance = game_value:GetService(value_3)
local game_value_2: DataModel = game
local value_4: string = "CollectionService"
local collection_service: Instance = game_value_2:GetService(value_4)
value_3 = true
local table_4 = {
    Red = Color3.fromRGB(255, 0, 0),
    Yellow = Color3.fromRGB(255, 255, 0),
    Green = Color3.fromRGB(0, 255, 0),
    Cyan = Color3.fromRGB(0, 255, 255),
    Blue = Color3.fromRGB(0, 0, 255),
    Purple = Color3.fromRGB(255, 0, 255),
}
local table_5: {Color3} = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}
table_5 = {
    (Color3.fromRGB(255, 0, 0)),
    (Color3.fromRGB(255, 255, 0)),
    (Color3.fromRGB(0, 255, 0)),
    (Color3.fromRGB(0, 255, 255)),
    (Color3.fromRGB(0, 0, 255)),
    Color3.fromRGB(255, 0, 255),
}
local table_6 = {}

local function lerp(argument_1: number, argument_2: number, argument_3: number): number
    return argument_1 + (argument_2 - argument_1) * argument_3
end

local function time_lerp(argument_1_2: number, argument_2_2: number, argument_3_2: number, argument_4: number)
    local value_6_8: number = argument_3_2 / argument_4
    local value_7_8: number = 1
    local min_result = math.min(value_6_8, value_7_8)

    return argument_1_2 + (argument_2_2 - argument_1_2) * min_result
end

TimeLerp = time_lerp

local function disable_chroma_decal(argument_1_3): ()
    local value_4_3: string = "ChromaLayer"
    local texture_value = argument_1_3.Texture
    argument_1_3:SetAttribute(value_4_3, texture_value)
    local value_4_4: string = "StaticLayer"
    local static_layer_value = argument_1_3:GetAttribute(value_4_4)
    if static_layer_value then
        local from_rgb_result_12: Color3 = Color3.fromRGB(255, 255, 255)
        argument_1_3.Color3 = from_rgb_result_12
        argument_1_3.Texture = static_layer_value

        return
    end
    local from_rgb_result_13: Color3 = Color3.fromRGB(255, 255, 255)
    argument_1_3.Color3 = from_rgb_result_13
    local value_3_4: string = "rbxassetid://18363392181"
    argument_1_3.Texture = value_3_4

    return
end

local function enable_chroma_decal(argument_1_4): ()
    local value_4_7: string = "ChromaLayer"
    local chroma_layer_value = argument_1_4:GetAttribute(value_4_7)
    if chroma_layer_value then
        local from_rgb_result_14: Color3 = Color3.fromRGB(255, 0, 0)
        argument_1_4.Color3 = from_rgb_result_14
        argument_1_4.Texture = chroma_layer_value
    end

    return
end

local enable_chromas
do
    local captured_value = table_6
    if closure_cache[1] ~= nil and same_capture(closure_cache[2], captured_value) then
        enable_chromas = closure_cache[1]
    else
        local closure_ready
        enable_chromas = function()
            if not closure_ready then
                return
            end
            local value_1_2 = captured_value
            local value_2_6: nil = nil
            local value_3_6: nil = nil
            for key, value in value_1_2, value_2_6, value_3_6 do
                local value_4_9, value_5_5 = key, value
                local value_8_10: string = "Decal"
                local is_a_result = value_4_9:IsA(value_8_10)
                if not is_a_result then
                    continue
                end
                local value_8_11: string = "ChromaLayer"
                local chroma_layer_value_2 = value_4_9:GetAttribute(value_8_11)
                if not chroma_layer_value_2 then
                    continue
                end
                local from_rgb_value_16: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                local value_8_12: number = 255
                local value_9_4: number = 0
                local value_10_4: number = 0
                local from_rgb_result_15: Color3 = from_rgb_value_16(
                    value_8_12,
                    value_9_4,
                    value_10_4
                )
                value_4_9.Color3 = from_rgb_result_15
                value_4_9.Texture = chroma_layer_value_2
            end

            return
        end
        closure_ready = true
        if closure_cache[1] == nil then
            closure_cache[1] = enable_chromas
            closure_cache[2] = captured_value
        end
    end
end
local disable_chromas
do
    local captured_value_2, captured_value_3 = table_6, disable_chroma_decal
    if closure_cache[3] ~= nil and same_capture(closure_cache[4], captured_value_2) and same_capture(
        closure_cache[5],
        captured_value_3
    ) then
        disable_chromas = closure_cache[3]
    else
        local closure_ready_2
        disable_chromas = function()
            if not closure_ready_2 then
                return
            end
            local value_1_3 = captured_value_2
            local value_2_7: nil = nil
            local value_3_7: nil = nil
            for key_2, value_15 in value_1_3, value_2_7, value_3_7 do
                local value_4_10, value_5_6 = key_2, value_15
                local value_8_13: string = "Decal"
                local is_a_result_2 = value_4_10:IsA(value_8_13)
                if not is_a_result_2 then
                    continue
                end
                local value_6_16 = captured_value_3
                local value_7_13 = value_4_10
                value_6_16(value_7_13)
            end

            return
        end
        closure_ready_2 = true
        if closure_cache[3] == nil then
            closure_cache[3] = disable_chromas
            closure_cache[4], closure_cache[5] = captured_value_2, captured_value_3
        end
    end
end

local function get_color_data(argument_1_5: Color3): ColorData
    return {
        R = argument_1_5.R * 255,
        G = argument_1_5.G * 255,
        B = argument_1_5.B * 255,
    }
end

local function get_color_distance(argument_1_6, argument_2_3)
    local value_3_11 = argument_1_6.R - argument_2_3.R
    local value_4_11 = argument_1_6.G - argument_2_3.G
    local value_5_7 = argument_1_6.B - argument_2_3.B
    local value_7_14 = value_3_11 * value_3_11 + value_4_11 * value_4_11 + value_5_7 * value_5_7

    return (math.sqrt(value_7_14))
end

GetColorDistance = get_color_distance
local lerp_to_color
do
    local captured_value_4 = table_6
    if closure_cache[6] ~= nil and same_capture(closure_cache[7], captured_value_4) then
        lerp_to_color = closure_cache[6]
    else
        local closure_ready_3
        lerp_to_color = function(argument_1_7)
            if not closure_ready_3 then
                return
            end
            local value_2_8 = captured_value_4[argument_1_7]
            local table_3 = {R = 0, B = 0, G = 0}
            local time_lerp_result = TimeLerp(
                value_2_8.StartColor.R,
                value_2_8.TargetColor.R,
                (os.clock()) - value_2_8.StartTime,
                1
            )
            table_3.R = time_lerp_result
            local time_lerp_result_2 = TimeLerp(
                value_2_8.StartColor.G,
                value_2_8.TargetColor.G,
                (os.clock()) - value_2_8.StartTime,
                1
            )
            table_3.G = time_lerp_result_2
            local time_lerp_result_3 = TimeLerp(
                value_2_8.StartColor.B,
                value_2_8.TargetColor.B,
                (os.clock()) - value_2_8.StartTime,
                1
            )
            table_3.B = time_lerp_result_3

            return table_3
        end
        closure_ready_3 = true
        if closure_cache[6] == nil then
            closure_cache[6] = lerp_to_color
            closure_cache[7] = captured_value_4
        end
    end
end
do
    local captured_value_5, captured_value_6 = table_6, table_4
    local set_color
    if closure_cache[8] ~= nil and same_capture(closure_cache[9], captured_value_5) and same_capture(
        closure_cache[10],
        captured_value_6
    ) then
        set_color = closure_cache[8]
    else
        local closure_ready_4
        set_color = function(argument_1_8, argument_2_4, argument_3_3: string)
            if not closure_ready_4 then
                return
            end
            local value_4_12 = captured_value_5[argument_1_8]
            local value_5_9 = captured_value_6[argument_3_3]
            value_4_12.StartColor = argument_2_4
            local table_6_2 = {
                R = value_5_9.R * 255,
                G = value_5_9.G * 255,
                B = value_5_9.B * 255,
            }
            value_4_12.TargetColor = table_6_2
            local clock_result_4 = os.clock()
            value_4_12.StartTime = clock_result_4
            value_4_12.State = argument_3_3

            return
        end
        closure_ready_4 = true
        if closure_cache[8] == nil then
            closure_cache[8] = set_color
            closure_cache[9], closure_cache[10] = captured_value_5, captured_value_6
        end
    end
end
local toggle_chromas: (() -> ())?
do
    local captured_value_7, captured_value_8, closure_ready_5
    toggle_chromas = function(): ()
        if not closure_ready_5 then
            return
        end
        value_3 = not value_3
        if value_3 then
            captured_value_7()

            return
        end
        captured_value_8()

        return
    end
    captured_value_7, captured_value_8 = enable_chromas, disable_chromas
    closure_ready_5 = true
end
local on_chroma_instance_added
do
    local captured_value_9, captured_value_10, closure_ready_6
    on_chroma_instance_added = function(argument_1_9): ()
        if not closure_ready_6 then
            return
        end
        local value_4_13: string = "Decal"
        if not (argument_1_9:IsA(value_4_13)) then
            local value_4_14: string = "Fire"
            if not (argument_1_9:IsA(value_4_14)) then
                local value_4_15: string = "Part"
                if not (argument_1_9:IsA(value_4_15)) then
                    return
                end
            end
        end
        if captured_value_9[argument_1_9] then
            return
        end
        if not value_3 then
            local value_4_16: string = "Decal"
            if (argument_1_9:IsA(value_4_16)) then
                captured_value_10(argument_1_9)
            end
        end
        local value_2_17 = captured_value_9
        local table_3_2 = {
            Index = 1,
            StartColor = 0,
            TargetColor = 0,
            StartTime = 0,
            State = "Red",
        }
        local table_4_2 = {R = 255, G = 0, B = 0}
        table_3_2.StartColor = table_4_2
        local table_4_3 = {R = 255, G = 0, B = 0}
        table_3_2.TargetColor = table_4_3
        local clock_result_5 = os.clock()
        table_3_2.StartTime = clock_result_5
        value_2_17[argument_1_9] = table_3_2

        return
    end
    captured_value_9, captured_value_10 = table_6, disable_chroma_decal
    closure_ready_6 = true
end
local on_chroma_instance_removed
do
    local captured_value_11 = table_6
    if closure_cache[11] ~= nil and same_capture(closure_cache[12], captured_value_11) then
        on_chroma_instance_removed = closure_cache[11]
    else
        local closure_ready_7
        on_chroma_instance_removed = function(argument_1_10)
            if not closure_ready_7 then
                return
            end
            local value_4_17: string = "Decal"
            if not (argument_1_10:IsA(value_4_17)) then
                local value_4_18: string = "Fire"
                if not (argument_1_10:IsA(value_4_18)) then
                    return
                end
            end
            local value_2_20 = captured_value_11
            local value_3_21: nil = nil
            value_2_20[argument_1_10] = value_3_21

            return
        end
        closure_ready_7 = true
        if closure_cache[11] == nil then
            closure_cache[11] = on_chroma_instance_removed
            closure_cache[12] = captured_value_11
        end
    end
end
local clock_value = os.clock
clock_value = clock_value()
local on_update: ((number) -> ())?
do
    local captured_value_12, captured_value_13, captured_value_14, closure_ready_8
    on_update = function(argument_1_11: number): ()
        if not closure_ready_8 then
            return
        end
        if not value_3 then
            return
        end
        if (os.clock()) - clock_value < 0.03333333333333333 then
            return
        end
        clock_value = (os.clock())
        local value_2_21 = captured_value_12
        local clock_value_7: nil = nil
        local value_4_19: nil = nil
        for key_3, value_16 in value_2_21, clock_value_7, value_4_19 do
            local value_5_10, value_6_18 = key_3, value_16
            local value_7_21 = captured_value_13
            local value_8_18 = value_5_10
            local value_7_22 = value_7_21(value_8_18)
            local get_color_distance_value = GetColorDistance
            local value_9_7 = value_7_22
            local target_color_value_4 = value_6_18.TargetColor
            local get_color_distance_result = get_color_distance_value(
                value_9_7,
                target_color_value_4
            )
            local value_9_8: number = 1
            if get_color_distance_result <= value_9_8 then
                local index_value = value_6_18.Index
                local value_8_19 = index_value + 1
                value_6_18.Index = value_8_19
                local value_9_9: {Color3} = captured_value_14
                local index_value_2 = value_6_18.Index
                local value_8_20 = value_9_9[index_value_2]
                if not value_8_20 then
                    local value_8_21: number = 1
                    value_6_18.Index = value_8_21
                end
                value_6_18.StartColor = value_7_22
                local value_10_6: {Color3} = captured_value_14
                local index_value_3 = value_6_18.Index
                local value_9_10 = value_10_6[index_value_3]
                local table_8 = {R = 0, G = 0, B = 0}
                local r_value_7 = value_9_10.R
                local value_10_7 = r_value_7 * 255
                table_8.R = value_10_7
                local g_value_7 = value_9_10.G
                local value_10_8 = g_value_7 * 255
                table_8.G = value_10_8
                local b_value_7 = value_9_10.B
                local value_10_9 = b_value_7 * 255
                table_8.B = value_10_9
                value_6_18.TargetColor = table_8
                local clock_value_8 = os.clock
                local clock_result_6 = clock_value_8()
                value_6_18.StartTime = clock_result_6
            end
            local value_10_10: string = "Decal"
            local is_a_result_9 = value_5_10:IsA(value_10_10)
            if is_a_result_9 then
                local from_rgb_value_17: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                local r_value_8 = value_7_22.R
                local g_value_8 = value_7_22.G
                local b_value_8 = value_7_22.B
                local from_rgb_result_16: Color3 = from_rgb_value_17(
                    r_value_8,
                    g_value_8,
                    b_value_8
                )
                value_5_10.Color3 = from_rgb_result_16
            else
                local value_10_11: string = "Fire"
                local is_a_result_10 = value_5_10:IsA(value_10_11)
                if is_a_result_10 then
                    local from_rgb_value_18: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                    local r_value_9 = value_7_22.R
                    local g_value_9 = value_7_22.G
                    local b_value_9 = value_7_22.B
                    local from_rgb_result_17: Color3 = from_rgb_value_18(
                        r_value_9,
                        g_value_9,
                        b_value_9
                    )
                    value_5_10.Color = from_rgb_result_17
                else
                    local value_10_12: string = "Part"
                    local is_a_result_11 = value_5_10:IsA(value_10_12)
                    if not is_a_result_11 then
                        continue
                    end
                    local from_rgb_value_19: (number?, number?, number?) -> (Color3) = Color3.fromRGB
                    local r_value_10 = value_7_22.R
                    local g_value_10 = value_7_22.G
                    local b_value_10 = value_7_22.B
                    local from_rgb_result_18: Color3 = from_rgb_value_19(
                        r_value_10,
                        g_value_10,
                        b_value_10
                    )
                    value_5_10.Color = from_rgb_result_18
                end
            end
        end

        return
    end
    captured_value_12, captured_value_13, captured_value_14 = table_6, lerp_to_color, table_5
    closure_ready_8 = true
end
local value_21 = "ChromaDecal"
local value_19, value_20
value_19, value_20, value_21 = collection_service:GetTagged(value_21)
local value_22, value_23
for key_4, value_17 in value_19, value_20, value_21 do
    value_22, value_23 = key_4, value_17
    local value_24 = on_chroma_instance_added
    local value_25 = value_23
    value_24(value_25)
end
value_21 = "ChromaFire"
value_19, value_20, value_21 = collection_service:GetTagged(value_21)
for key_5, value_18 in value_19, value_20, value_21 do
    value_22, value_23 = key_5, value_18
    local value_24_2 = on_chroma_instance_added
    local value_25_2 = value_23
    value_24_2(value_25_2)
end
value_21 = "ChromaPart"
value_19, value_20, value_21 = collection_service:GetTagged(value_21)
for key_6, value_26 in value_19, value_20, value_21 do
    value_22, value_23 = key_6, value_26
    local value_24_3 = on_chroma_instance_added
    local value_25_3 = value_23
    value_24_3(value_25_3)
end
value_21 = "ChromaPart"
value_19 = collection_service:GetInstanceRemovedSignal(value_21)
value_21 = on_chroma_instance_removed
value_19:Connect(value_21)
value_21 = "ChromaDecal"
value_19 = collection_service:GetInstanceRemovedSignal(value_21)
value_21 = on_chroma_instance_removed
value_19:Connect(value_21)
value_21 = "ChromaFire"
value_19 = collection_service:GetInstanceRemovedSignal(value_21)
value_21 = on_chroma_instance_removed
value_19:Connect(value_21)
value_21 = "ChromaFire"
value_19 = collection_service:GetInstanceAddedSignal(value_21)
value_21 = on_chroma_instance_added
value_19:Connect(value_21)
value_21 = "ChromaDecal"
value_19 = collection_service:GetInstanceAddedSignal(value_21)
value_21 = on_chroma_instance_added
value_19:Connect(value_21)
value_21 = "ChromaPart"
value_19 = collection_service:GetInstanceAddedSignal(value_21)
value_21 = on_chroma_instance_added
value_19:Connect(value_21)
value_19 = script
value_21 = "ToggleChromas"
value_19 = value_19:WaitForChild(value_21).Event
value_21 = toggle_chromas
value_19:Connect(value_21)
value_19 = run_service.PostSimulation
value_21 = on_update
value_19:Connect(value_21)

return
