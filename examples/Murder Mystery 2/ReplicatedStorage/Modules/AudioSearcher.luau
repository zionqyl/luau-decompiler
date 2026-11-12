--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {[("searchAudio")] = nil}
local game_value: DataModel = game
local value_4: string = "AssetService"
local asset_service: Instance = game_value:GetService(value_4)
local search_audio
do
    local captured_value = asset_service
    search_audio = function(argument_1)
        local new_result: AudioSearchParams = Instance.new("AudioSearchParams")
        local music_value = Enum.AudioSubType.Music
        new_result.AudioSubType = music_value
        local new_result_2: AudioSearchParams = Instance.new("AudioSearchParams")
        local sound_effect_value = Enum.AudioSubType.SoundEffect
        new_result_2.AudioSubType = sound_effect_value
        new_result.SearchKeyword = argument_1
        new_result_2.SearchKeyword = argument_1
        local value_5
        do
            local captured_value_2, captured_value_3, closure_ready
            value_5 = function()
                if not closure_ready then
                    return
                end
                local value_1: Instance? = captured_value_2
                local value_3_3: AudioSearchParams? = captured_value_3

                return value_1:SearchAudio(value_3_3)
            end
            captured_value_2, captured_value_3 = captured_value, new_result
            closure_ready = true
        end
        local pcall_result, value_5_2 = pcall(value_5)
        local value_7
        do
            local captured_value_4, captured_value_5, closure_ready_2
            value_7 = function()
                if not closure_ready_2 then
                    return
                end
                local value_1_3: Instance? = captured_value_4
                local value_3_4: AudioSearchParams? = captured_value_5

                return value_1_3:SearchAudio(value_3_4)
            end
            captured_value_4, captured_value_5 = captured_value, new_result_2
            closure_ready_2 = true
        end
        local pcall_result_2, value_7_2 = pcall(value_7)
        local table_8 = {}
        local table_9 = {}
        if pcall_result then
            table_8 = (value_5_2:GetCurrentPage())
        else
            warn(value_5_2)
        end
        if pcall_result_2 then
            table_9 = (value_7_2:GetCurrentPage())
        else
            warn(value_7_2)
        end
        if not pcall_result_2 then
            if not pcall_result then
                return nil
            end
        end
        local table_7 = {}
        local value_12: number = 1
        local value_10: number = 30
        local value_11: number = 1
        for index = value_12, value_10, value_11 do
            value_12 = index
            local value_6 = table_8[value_12]
            local value_5_3 = table_9[value_12]
            if value_6 then
                local value_14 = table_7
                local value_15 = value_6
                local insert_value = table.insert
                insert_value(value_14, value_15)
            end
            if not value_5_3 then
                continue
            end
            local value_14_2 = table_7
            local value_15_2 = value_5_3
            local insert_value_2 = table.insert
            insert_value_2(value_14_2, value_15_2)
        end

        return table_7
    end
end
table_1.searchAudio = search_audio

return table_1
