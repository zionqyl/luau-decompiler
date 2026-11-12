--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local parent_value: Instance? = script.Parent
local local_player_value = game.Players.LocalPlayer
local require_value = require
local game_value_2: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value_2:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "DeviceService"
local require_result = require_value(client_services_child:WaitForChild(value_5_3))
local game_value_3: DataModel = game
local value_4_4: string = "GuiService"
local gui_service: Instance = game_value_3:GetService(value_4_4)
local require_value_2 = require
local game_value_4: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_4:GetService(value_6)
local value_6_2: string = "Database"
local database_child: Instance? = replicated_storage_service_2:WaitForChild(value_6_2)
local value_6_3: string = "Sync"
local require_result_2 = require_value_2(database_child:WaitForChild(value_6_3))
local require_value_3 = require
local game_value_5: DataModel = game
local value_6_4: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_5:GetService(value_6_4)
local value_6_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_5)
local value_6_6: string = "ProfileData"
local require_result_3 = require_value_3(modules_child:WaitForChild(value_6_6))
local script_value_2: LuaSourceContainer = script
local value_5_10: string = "ShopPhone"
local shop_phone_child: Instance? = script_value_2:WaitForChild(value_5_10)
local script_value_3: LuaSourceContainer = script
local value_6_7: string = "ShopDesktop"
local shop_desktop_child: Instance? = script_value_3:WaitForChild(value_6_7)
local script_value_4: LuaSourceContainer = script
local value_7: string = "ShopConsole"
local shop_console_child: Instance? = script_value_4:WaitForChild(value_7)
local on_initialize: (() -> ())?
do
    local captured_value, captured_value_2, captured_value_3, captured_value_4, captured_value_5 = local_player_value, gui_service, shop_phone_child, shop_console_child, shop_desktop_child
    on_initialize = function(): ()
        while true do
            local value_1 = captured_value
            local player_gui_value = value_1.PlayerGui
            local value_3_6: string = "Device"
            local device_value = player_gui_value:GetAttribute(value_3_6)
            if device_value ~= nil then
                break
            end
            local wait_value: (number?) -> (number) = task.wait
            wait_value()
        end
        while true do
            local value_1_3 = captured_value
            local player_gui_value_2 = value_1_3.PlayerGui
            local value_3_7: string = "MainGUI"
            local main_gui_child = player_gui_value_2:FindFirstChild(value_3_7)
            if main_gui_child then
                break
            end
            local wait_value_2: (number?) -> (number) = task.wait
            wait_value_2()
        end
        local player_gui_value_3 = captured_value.PlayerGui
        local value_4_13: string = "Device"
        local value_1_5: boolean?
        if (player_gui_value_3:GetAttribute(value_4_13)) ~= "Phone" then
            value_1_5 = false
        else
            value_1_5 = true
        end
        local is_ten_foot_interface_result = captured_value_2:IsTenFootInterface()
        if value_1_5 then
            local value_3_10: Instance? = captured_value_3
            local value_4_14: boolean = true
            value_3_10.Enabled = value_4_14

            return
        end
        if is_ten_foot_interface_result then
            local value_3_11: Instance? = captured_value_4
            local value_4_15: boolean = true
            value_3_11.Enabled = value_4_15

            return
        end
        local value_3_12: Instance? = captured_value_5
        local value_4_16: boolean = true
        value_3_12.Enabled = value_4_16

        return
    end
end
on_initialize()

return
