--!strict
--[=[
    Luau Decompiler 0.4.0-rc.5
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local InventoryServiceModule = {
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
    [("CreateItemFrame")] = nil,
}
local requireResult = require(game:GetService("ReplicatedStorage"):WaitForChild("Database"):WaitForChild(
    "Sync"
))
local requireResult2 = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild(
    "ProfileData"
))
local remotesChild: Instance? = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local clientServicesChild: Instance? = game:GetService("ReplicatedStorage"):WaitForChild(
    "ClientServices"
)
local requireResult3 = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild(
    "WindowService"
))
local requireResult4 = require(clientServicesChild:WaitForChild("ItemService"))
local baseItemFrameValue = requireResult4.BaseItemFrame

local function applyFilter(argument1, argument2: string): ()
    local value3 = argument1.Filters.Search or ""
    local value4 = argument1.Filters.ClassFilter or nil
    local frameValue = argument1.Frames[argument2].Frame
    local value5: boolean = false
    if value3 ~= "" then
        if value3 == nil then
            value5 = false
        else
            value5 = true
        end
    end
    local value6: boolean = false
    if value5 then
        local value72 = requireResult[argument1.ItemType][argument2]
        local lowerValue = string.lower
        local nameValue = value72.Name
        if not nameValue then
            nameValue = value72.DisplayName or value72.ItemName
        end
        local lowerResult = lowerValue(nameValue)
        if (string.find(lowerResult, value3)) == nil then
            value6 = false
        else
            value6 = true
        end
    end
    local value32: boolean = true
    if argument1.Frames[argument2].ItemClass ~= argument1.Filters.ClassFilter then
        if argument1.Filters.ClassFilter ~= nil then
            value32 = false
        else
            value32 = true
        end
    end
    local value7: boolean?
    do
        local takeFallback = not value32
        if not takeFallback then
            value7 = not value5
            takeFallback = not value7
        end
        if takeFallback then
            value7 = value5 and value6
        end
    end
    frameValue.Visible = value7

    return
end

InventoryServiceModule.CreateItemFrame = function(
    argument1: unknown,
    itemType,
    argument3: string,
    argument4: number
)
    local clonedValue = baseItemFrameValue:Clone()
    local getItemInfoResult = requireResult4:GetItemInfo(itemType, argument3)
    if not getItemInfoResult then
        warn(
            "InventoryService: No info found for item:" .. (tostring(argument3)) .. ", " .. (tostring(
                itemType
            ))
        )

        return nil
    end
    requireResult4:ApplyItemToFrame(clonedValue, getItemInfoResult, argument4)
    requireResult4:ApplyTags(clonedValue, getItemInfoResult)
    clonedValue.LayoutOrder = (requireResult4:GetLayoutOrder(itemType, argument3))
    local value7: string? = nil
    if itemType == "Weapons" then
        if getItemInfoResult.Event ~= nil then
            value7 = "Event"
        else
            if getItemInfoResult.Season == nil then
                value7 = "Classic"
            else
                value7 = "Current"
            end
        end
    end

    return {ItemType = itemType, Frame = clonedValue, ItemClass = value7}
end
InventoryServiceModule.AddItem = function(
    argument1: unknown,
    argument2,
    argument3: string,
    argument4: number
)
    local itemTypeValue = argument2.ItemType
    local createItemFrameResult = InventoryServiceModule:CreateItemFrame(
        itemTypeValue,
        argument3,
        argument4
    )
    if createItemFrameResult then
        local sortedIDsValue = argument2.SortedIDs
        table.insert(sortedIDsValue, argument3)
        local framesValue = argument2.Frames
        framesValue[argument3] = createItemFrameResult
        applyFilter(argument2, argument3)
        if argument2.ListFrame then
            local frameValue = createItemFrameResult.Frame
            frameValue.Parent = argument2.ListFrame
        end
    end

    return createItemFrameResult
end
InventoryServiceModule.GenerateInventoryInfo = function(
    argument1: unknown,
    itemType,
    argument3,
    listFrame
)
    local table5 = {
        ItemType = 0,
        Frames = 0,
        Filters = 0,
        SortedIDs = 0,
        ListFrame = 0,
    }
    table5.ItemType = itemType
    table5.Frames = {}
    local table6 = {ClassFilter = 0, Search = ""}
    table6["ClassFilter"] = nil
    table5.Filters = table6
    table5.SortedIDs = {}
    table5.ListFrame = listFrame
    table6 = argument3
    local value7: nil = nil
    local value8: nil = nil
    for key, value in table6, value7, value8 do
        local value9, value10 = key, value
        local value11: nil = nil
        local value12: nil = nil
        local value14 = value9
        local tonumberValue = tonumber
        local tonumberResult = tonumberValue(value14)
        local value112, value122
        if tonumberResult then
            value112 = value10
            value122 = 1
        else
            value112 = value9
            value122 = value10
        end
        local value13 = InventoryServiceModule
        local value15 = table5
        local value16 = value112
        local value17 = value122
        value13:AddItem(value15, value16, value17)
    end

    return table5
end
InventoryServiceModule.UpdateFilter = function(argument1: unknown, argument2): ()
    local framesValue = argument2.Frames
    local value4: nil = nil
    local value5: nil = nil
    for key2, value2 in framesValue, value4, value5 do
        local value6, value7 = key2, value2
        local value8 = applyFilter
        local value9 = argument2
        local value10 = value6
        value8(value9, value10)
    end

    return
end
InventoryServiceModule.ForEachFrame = function(argument1: unknown, argument2, argument3): ()
    local framesValue = argument2.Frames
    local value5: nil = nil
    local value6: nil = nil
    for key3, value18 in framesValue, value5, value6 do
        local value7, value8 = key3, value18
        local value9 = argument3
        local value10 = value7
        local frameValue = value8.Frame
        value9(value10, frameValue)
    end

    return
end
InventoryServiceModule.ApplyChangesToInventoryInfo = function(
    argument1: unknown,
    argument2,
    argument3: string,
    argument4: number
)
    if argument4 ~= nil then
        if 0 < argument4 then
            if not argument2.Frames[argument3] then
                InventoryServiceModule:AddItem(argument2, argument3, argument4)

                return
            end
            local amountValue = argument2.Frames[argument3].Frame.Container.Amount
            amountValue.Text = (requireResult4:GetAmountText(argument4))

            return
        end
    end
    InventoryServiceModule:RemoveItem(argument2, argument3)

    return
end
InventoryServiceModule.ConnectSearchBox = function(argument1: unknown, argument2, argument3)
    local getPropertyChangedSignalResult = argument3:GetPropertyChangedSignal("Text")
    local value6
    do
        local closureReady
        value6 = function()
            if not closureReady then
                return
            end
            local filtersValue = argument2.Filters
            filtersValue.Search = (string.lower(argument3.Text))
            InventoryServiceModule:UpdateFilter(argument2)

            return
        end
        closureReady = true
    end
    getPropertyChangedSignalResult:Connect(value6)

    return
end
InventoryServiceModule.AutoUpdate = function(argument1: unknown, argument2)
    local eventValue = remotesChild:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event
    local value5
    do
        local closureReady2
        value5 = function(argument12: string, argument22: string, argument3: number)
            if not closureReady2 then
                return
            end
            if argument12 ~= argument2.ItemType then
                return
            end
            if argument12 == "Toys" then
                local value1: string = "Emotes"
            end
            InventoryServiceModule:ApplyChangesToInventoryInfo(argument2, argument22, argument3)

            return
        end
        closureReady2 = true
    end
    argument2.UpdateConnection = (eventValue:Connect(value5))

    return
end
InventoryServiceModule.RemoveItem = function(argument1: unknown, argument2, argument3: string): ()
    argument2.Frames[argument3].Frame:Destroy()
    local framesValue = argument2.Frames
    local value6: nil = nil
    framesValue[argument3] = value6
    table.remove(argument2.SortedIDs, table.find(argument2.SortedIDs, argument3))

    return
end
InventoryServiceModule.ClearInventory = function(argument1: unknown, argument2): ()
    local framesValue = argument2.Frames
    local value4: nil = nil
    local value5: nil = nil
    for key4, value20 in framesValue, value4, value5 do
        local value6, value7 = key4, value20
        local frameValue = value7.Frame
        frameValue:Destroy()
    end
    argument2.Frames = {}
    if argument2.UpdateConnection then
        argument2.UpdateConnection:Disconnect()
    end

    return
end

return InventoryServiceModule
