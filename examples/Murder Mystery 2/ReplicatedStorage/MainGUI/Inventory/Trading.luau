--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local require_value = require
local game_value: DataModel = game
local value_4: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_4)
local value_4_2: string = "Modules"
local modules_child: Instance? = replicated_storage_service:WaitForChild(value_4_2)
local value_4_3: string = "ProfileData"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local game_value_2: DataModel = game
local value_4_4: string = "PolicyService"
local policy_service: Instance = game_value_2:GetService(value_4_4)
local local_player_value = game.Players.LocalPlayer
local game_value_4 = script.Parent.Parent.Game
local require_result_2 = require(game.ReplicatedStorage.Modules.TradeModule)
local require_result_3 = require(game.ReplicatedStorage.Modules.LevelModule)
local game_value_7: DataModel = game
local value_9: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_7:GetService(value_9)
local value_9_2: string = "Trade"
local trade_child: Instance? = replicated_storage_service_2:WaitForChild(value_9_2)
local value_9_3
do
    local captured_value, captured_value_2 = policy_service, local_player_value
    value_9_3 = function()
        local value_1: Instance = captured_value
        local value_3_5 = captured_value_2

        return value_1:GetPolicyInfoForPlayerAsync(value_3_5)
    end
end
local pcall_result, value_9_4 = pcall(value_9_3)
local get_level_result = require_result_3.GetLevel(require_result.NewXP)
local value_6: boolean = true
if not (10 <= get_level_result) then
    if not (0 < require_result.Prestige) then
        value_6 = false
    else
        value_6 = true
    end
end
if not pcall_result then
    warn("PolicyService error: " .. value_9_4)
else
    if not value_9_4.IsPaidItemTradingAllowed then
        local trade_value = game_value_4.Leaderboard.Inspect.Trade
        local value_12_3: boolean = false
        trade_value.Visible = value_12_3
        local value_11_2: boolean = false
        require_result_2.RequestsEnabled = value_11_2

        return "Trading Not Allowed"
    end
end
if not value_6 then
    local trade_value_2 = game_value_4.Leaderboard.Inspect.Trade
    local value_12_4: boolean = false
    trade_value_2.Visible = value_12_4
    local value_11_4: boolean = false
    require_result_2.RequestsEnabled = value_11_4
end
local leaderboard_value_3 = game_value_4.Leaderboard
local inspect_value_3 = leaderboard_value_3.Inspect
local trade_request_value = leaderboard_value_3.Container.TradeRequest
local trade_gui_value = game.Players.LocalPlayer.PlayerGui.TradeGUI
local gui_value = require_result_2.GUI
gui_value.RequestFrame = trade_request_value
local gui_value_2 = require_result_2.GUI
local trade_gui_value_2 = game.Players.LocalPlayer.PlayerGui.TradeGUI
gui_value_2.TradeGUI = trade_gui_value_2
local gui_value_3 = require_result_2.GUI
local actions_value = trade_gui_value.Container.Trade.Actions
gui_value_3.Actions = actions_value
local gui_value_4 = require_result_2.GUI
local your_offer_value = trade_gui_value.Container.Trade.YourOffer
gui_value_4.YourOffer = your_offer_value
local gui_value_5 = require_result_2.GUI
local their_offer_value = trade_gui_value.Container.Trade.TheirOffer
gui_value_5.TheirOffer = their_offer_value
local invoke_server_result, value_12_6 = game.ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()
require_result_2.UpdateTradeRequestWindow(invoke_server_result, value_12_6)
require_result_2.ConnectRequestWindow()
require_result_2.ConnectActions()
require_result_2.ConnectTabButtons()
local toggle_requests_value = game_value_4.Leaderboard.Container.ToggleRequests
local on_value = toggle_requests_value.On
local requests_enabled_value = require_result_2.RequestsEnabled
on_value.Visible = requests_enabled_value
local off_value = toggle_requests_value.Off
local value_14_3: boolean = not require_result_2.RequestsEnabled
off_value.Visible = value_14_3
local activated_value = toggle_requests_value.On.Activated
local value_15_2: (() -> ())?
do
    local captured_value_3, captured_value_4, captured_value_5, captured_value_6 = toggle_requests_value, require_result_2, trade_child, trade_request_value
    value_15_2 = function(): ()
        local on_value_3 = captured_value_3.On
        local value_2_6: boolean = false
        on_value_3.Visible = value_2_6
        local off_value_3 = captured_value_3.Off
        local value_2_7: boolean = true
        off_value_3.Visible = value_2_7
        local value_1_5 = captured_value_4
        local value_2_8: boolean = false
        value_1_5.RequestsEnabled = value_2_8
        game.ReplicatedStorage.Trade.DeclineRequest:FireServer()
        local set_requests_enabled_value = captured_value_5.SetRequestsEnabled
        local value_3_6: boolean = false
        set_requests_enabled_value:FireServer(value_3_6)
        local value_1_9 = captured_value_6
        local value_2_11: boolean = false
        value_1_9.Visible = value_2_11

        return
    end
end
activated_value:Connect(value_15_2)
local activated_value_2 = toggle_requests_value.Off.Activated
local value_15_3: (() -> ())?
do
    local captured_value_7, captured_value_8, captured_value_9 = toggle_requests_value, trade_child, require_result_2
    value_15_3 = function(): ()
        local on_value_4 = captured_value_7.On
        local value_2_12: boolean = true
        on_value_4.Visible = value_2_12
        local off_value_4 = captured_value_7.Off
        local value_2_13: boolean = false
        off_value_4.Visible = value_2_13
        local set_requests_enabled_value_2 = captured_value_8.SetRequestsEnabled
        local value_3_7: boolean = true
        set_requests_enabled_value_2:FireServer(value_3_7)
        local value_1_14 = captured_value_9
        local value_2_15: boolean = true
        value_1_14.RequestsEnabled = value_2_15

        return
    end
end
activated_value_2:Connect(value_15_3)
local changed_value = trade_gui_value.Changed
local value_15_4: (() -> ())?
do
    local captured_value_10 = trade_gui_value
    value_15_4 = function(): ()
        local click_blocker_value = captured_value_10.ClickBlocker
        local enabled_value = captured_value_10.Enabled
        click_blocker_value.Visible = enabled_value

        return
    end
end
changed_value:Connect(value_15_4)
local local_player_value_4 = game.Players.LocalPlayer
local changed_value_2 = local_player_value_4.Changed
local value_15_5: (() -> ())?
do
    local captured_value_11, captured_value_12 = trade_gui_value, local_player_value_4
    value_15_5 = function(): ()
        local container_value_6 = captured_value_11.Container
        local value_3_8 = captured_value_12
        local value_5: string = "PerformingTrade"
        local value_2_17: boolean?
        if (value_3_8:GetAttribute(value_5)) == true then
            value_2_17 = false
        else
            value_2_17 = true
        end
        container_value_6.Visible = value_2_17
        local processing_value = captured_value_11.Processing
        local value_3_10 = captured_value_12
        local value_5_2: string = "PerformingTrade"
        local value_2_18: boolean?
        if (value_3_10:GetAttribute(value_5_2)) ~= true then
            value_2_18 = false
        else
            value_2_18 = true
        end
        processing_value.Visible = value_2_18

        return
    end
end
changed_value_2:connect(value_15_5)

return
