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
local value_4_3: string = "WindowService"
local require_result = require_value(modules_child:WaitForChild(value_4_3))
local game_value_2 = script.Parent.Parent.Game
local shop_value = game_value_2.Shop
local require_result_2 = require(game.ReplicatedStorage.Modules.ShopModule)
local require_result_3 = require(game.ReplicatedStorage.Modules.ItemModule)
local gui_value = require_result_2.GUI
gui_value.ShopFrame = shop_value
local gui_value_2 = require_result_2.GUI
local main_value = shop_value.Main
gui_value_2.Main = main_value
local gui_value_3 = require_result_2.GUI
local nav_value = shop_value.Nav
gui_value_3.Nav = nav_value
local gui_value_4 = require_result_2.GUI
local title_value = shop_value.Title
gui_value_4.Title = title_value
local gui_value_5 = require_result_2.GUI
local featured_value = shop_value.Main.Featured
gui_value_5.FeaturedFrame = featured_value
local gui_value_6 = require_result_2.GUI
local container_value = shop_value.Main.ViewCrate.Container
gui_value_6.ViewBoxFrame = container_value
local gui_value_7 = require_result_2.GUI
local processing_value = game_value_2.Processing
gui_value_7.Processing = processing_value
local gui_value_8 = require_result_2.GUI
local container_value_2 = shop_value.Main.Featured.HotItems.Container
gui_value_8.HotItemsContainer = container_value_2
require_result_2.GenerateHotItems()
require_result_2.ConnectNavButtons()
require_result_2.ConnectViewBoxFrame()
require_result_2.ConnectBuyPopup()
require_result_2.ConnectGems()
require_result_2.GenerateShopItems()
local local_player_value = game.Players.LocalPlayer
local value_6: string = "Radio"
local radio_value = local_player_value:GetAttribute(value_6)
local no_radio_cover_value = game_value_2.Shop.Main.Radios.NoRadioCover
local value_6_2: boolean = not radio_value
no_radio_cover_value.Visible = value_6_2
local on_client_event_value = game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent
local value_7: (() -> ())?
do
    local captured_value = game_value_2
    value_7 = function(): ()
        local no_radio_cover_value_3 = captured_value.Shop.Main.Radios.NoRadioCover
        local value_2_4: boolean = false
        no_radio_cover_value_3.Visible = value_2_4

        return
    end
end
on_client_event_value:connect(value_7)
local mouse_button1_click_value = game_value_2.Shop.Main.Radios.NoRadioCover.Buy.MouseButton1Click

local function value_7_2(): ()
    game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()

    return
end

mouse_button1_click_value:connect(value_7_2)

return
