--!strict
--[=[
    Luau Decompiler 0.4.0-rc.4
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local table_1 = {
    [("PageChanged")] = nil,
    [("PageChanged")] = nil,
    [("PageChanged")] = nil,
    [("PageChanged")] = nil,
    [("PageChanged")] = nil,
}
local require_value = require
local game_value: DataModel = game
local value_5: string = "ReplicatedStorage"
local replicated_storage_service: Instance = game_value:GetService(value_5)
local value_5_2: string = "ClientServices"
local client_services_child: Instance? = replicated_storage_service:WaitForChild(value_5_2)
local value_5_3: string = "Button"
local require_result = require_value(client_services_child:WaitForChild(value_5_3))
local require_value_2 = require
local game_value_2: DataModel = game
local value_5_4: string = "ReplicatedStorage"
local replicated_storage_service_2: Instance = game_value_2:GetService(value_5_4)
local value_5_5: string = "Modules"
local modules_child: Instance? = replicated_storage_service_2:WaitForChild(value_5_5)
local value_5_6: string = "WindowService"
local require_result_2 = require_value_2(modules_child:WaitForChild(value_5_6))
local require_value_3 = require
local game_value_3: DataModel = game
local value_6: string = "ReplicatedStorage"
local replicated_storage_service_3: Instance = game_value_3:GetService(value_6)
local value_6_2: string = "SharedServices"
local shared_services_child: Instance? = replicated_storage_service_3:WaitForChild(value_6_2)
local value_6_3: string = "EventInfoService"
local wait_for_initialized_async_result = require_value_3(shared_services_child:WaitForChild(
    value_6_3
)):WaitForInitializedAsync()
local parent_value_2 = script.Parent.Parent
local value_7: string = "MainEvent"
local main_event_child = parent_value_2:WaitForChild(value_7)
local value_8: string = "Title"
local value_4_11 = (main_event_child:WaitForChild(value_8))
local value_8_2: string = "Main"
local value_4_12 = (main_event_child:WaitForChild(value_8_2))
local new_result: BindableEvent = Instance.new("BindableEvent")
table_1.PageChanged = new_result
local go_to_page
do
    local captured_value, captured_value_2 = value_4_12, table_1
    go_to_page = function<T1>(argument_1: T1, argument_2: string, argument_3)
        local value_4_13 = captured_value
        local value_6_7 = argument_2
        if not (value_4_13:FindFirstChild(value_6_7)) then
            return
        end
        local value_5_11
        value_4_13, value_5_11, value_6_7 = captured_value:GetChildren()
        local value_7_5
        for key, value in value_4_13, value_5_11, value_6_7 do
            local value_8_3
            value_7_5, value_8_3 = key, value
            local value_11: string = "Frame"
            local is_a_result = value_8_3:IsA(value_11)
            if not is_a_result then
                continue
            end
            local name_value = value_8_3.Name
            local value_9_2: boolean?
            if name_value ~= argument_2 then
                value_9_2 = false
            else
                value_9_2 = true
            end
            value_8_3.Visible = value_9_2
        end
        value_4_13 = captured_value_2.PageChanged
        value_6_7 = argument_2
        value_7_5 = argument_3
        value_4_13:Fire(value_6_7, value_7_5)

        return
    end
end
table_1.GoToPage = go_to_page
local get_event_mystery_box_id
do
    local captured_value_3 = wait_for_initialized_async_result
    get_event_mystery_box_id = function<T1>(argument_1_2: T1)
        local get_main_event_result = captured_value_3:GetMainEvent()
        local value_3_9 = get_main_event_result and get_main_event_result.EventStartInfo
        local value_2_3 = value_3_9
        if value_2_3 then
            value_2_3 = value_3_9.Items
            if value_2_3 then
                value_2_3 = value_3_9.Items.MysteryBox
            end
        end
        if not value_2_3 then
            return nil
        end

        return (next(value_2_3))
    end
end
table_1.GetEventMysteryBoxId = get_event_mystery_box_id
local view_event_mystery_box
do
    local captured_value_4, captured_value_5 = table_1, require_result_2
    view_event_mystery_box = function<T1>(argument_1_3: T1)
        local get_event_mystery_box_id_result = captured_value_4:GetEventMysteryBoxId()
        if not get_event_mystery_box_id_result then
            warn("No mystery box registered for the current event")

            return
        end
        local value_3_11 = captured_value_5
        local value_5_12: string = "Shop"
        local table_6 = {TargetFrame = "ViewContents", TargetItem = 0}
        table_6.TargetItem = get_event_mystery_box_id_result
        value_3_11:ViewFrame(value_5_12, table_6)

        return
    end
end
table_1.ViewEventMysteryBox = view_event_mystery_box
local connect_navigation_buttons
do
    local captured_value_6 = table_1
    connect_navigation_buttons = function<T1>(argument_1_4: T1, argument_2_2)
        local value_3_13, value_4_18, value_5_13 = argument_2_2:GetChildren()
        for key_2, value_12 in value_3_13, value_4_18, value_5_13 do
            local value_6_8, value_7_6 = key_2, value_12
            local value_10_2: string = "Frame"
            local is_a_result_2 = value_7_6:IsA(value_10_2)
            if not is_a_result_2 then
                continue
            end
            local container_value = value_7_6.Container
            local button_value = container_value.Button
            local activated_value = button_value.Activated
            local value_10_3
            do
                local captured_value_7, captured_value_8, closure_ready
                value_10_3 = function(): ()
                    if not closure_ready then
                        return
                    end
                    if captured_value_7.Name == "MysteryBox" then
                        captured_value_8:ViewEventMysteryBox()

                        return
                    end
                    if captured_value_7.Name == "ItemBundle" then
                        local value_1_5 = captured_value_8
                        local value_3_14: string = "ShopBundles"
                        local value_4_19: string = "ItemBundle"
                        value_1_5:GoToPage(value_3_14, value_4_19)

                        return
                    end
                    local value_1_7 = captured_value_8
                    local name_value_4 = captured_value_7.Name
                    value_1_7:GoToPage(name_value_4)

                    return
                end
                captured_value_7, captured_value_8 = value_7_6, captured_value_6
                closure_ready = true
            end
            activated_value:Connect(value_10_3)
        end

        return
    end
end
table_1.ConnectNavigationButtons = connect_navigation_buttons

return table_1
