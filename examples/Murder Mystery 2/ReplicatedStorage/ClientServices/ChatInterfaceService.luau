--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("IsChatActive")] = nil,
    [("IsChatActive")] = nil,
    [("IsChatActive")] = nil,
    [("IsChatActive")] = nil,
    [("IsChatActive")] = nil,
}
local game_value: DataModel = game
local value_4: string = "RunService"
local run_service: Instance = game_value:GetService(value_4)
local value_3_2: boolean = false
table_1.IsChatActive = value_3_2
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.ChatWindowToggled = new_result

local function set_chat_window_visible<T1>(argument_1: T1, argument_2): ()
    local starter_gui_value = game.StarterGui
    local value_5_2: string = "ChatActive"
    local value_6 = argument_2
    starter_gui_value:SetCore(value_5_2, value_6)

    return
end

table_1.SetChatWindowVisible = set_chat_window_visible

local function set_window_transparent<T1>(argument_1_2: T1): ()
    local game_value_3: DataModel = game
    local value_4_5: string = "TextChatService"
    local chat_window_configuration_value = game_value_3:GetService(value_4_5).ChatWindowConfiguration
    local value_3_6: number = 0.3
    chat_window_configuration_value.BackgroundTransparency = value_3_6

    return
end

table_1.SetWindowTransparent = set_window_transparent

local function set_window_opaque<T1>(argument_1_3: T1): ()
    local game_value_4: DataModel = game
    local value_4_6: string = "TextChatService"
    local chat_window_configuration_value_2 = game_value_4:GetService(value_4_6).ChatWindowConfiguration
    local value_3_8: number = 0
    chat_window_configuration_value_2.BackgroundTransparency = value_3_8

    return
end

table_1.SetWindowOpaque = set_window_opaque
local pre_simulation_value = run_service.PreSimulation
local value_5
do
    local captured_value = table_1
    value_5 = function()
        local is_chat_active_value: boolean = captured_value.IsChatActive
        local starter_gui_value_2 = game.StarterGui
        local value_5_3: string = "ChatActive"
        local value_2_4: boolean?
        if (starter_gui_value_2:GetCore(value_5_3)) ~= true then
            value_2_4 = false
        else
            value_2_4 = true
        end
        if is_chat_active_value ~= value_2_4 then
            local chat_window_toggled_value = captured_value.ChatWindowToggled
            local value_5_4: boolean = value_2_4
            chat_window_toggled_value:Fire(value_5_4)
        end
        local value_3_12 = captured_value
        value_3_12.IsChatActive = value_2_4

        return
    end
end
pre_simulation_value:Connect(value_5)

return table_1
