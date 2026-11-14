--!strict
--[=[
    Luau Decompiler 0.4.0-rc.5
    Made by @zionqyl
    https://github.com/zionqyl/luau-decompiler
]=]

local function sharedDefaultClickStart(): ()
    return
end

local function sharedDefaultClickEnd(): ()
    return
end

local TweenService: TweenService = game:GetService("TweenService")
local tweenInfo: TweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local ButtonModule = {[("createButton")] = nil}
ButtonModule.createButton = function(frame, onClickEnd, onClickStart)
    local button = {
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
        [("Frame")] = nil,
    }
    button.Frame = frame
    button.Container = frame.Container
    local offsetValue = button.Container.Shadow.Position.X.Offset
    button.shadowSize = (math.abs(offsetValue))
    button.clickStart = onClickStart or sharedDefaultClickStart
    button.clickEnd = onClickEnd or sharedDefaultClickEnd
    local isPressed: boolean = false
    local isEnabled: boolean = true
    local initialContainerPosition = button.Container.Position
    local initialShadowPosition = button.Container.Shadow.Position
    button.Reset = function(argument1: unknown)
        isPressed = false
        local containerValue = button.Container
        local table6 = {
            Size = (UDim2.fromScale(1, 1)),
            Position = initialContainerPosition,
        }
        TweenService:Create(containerValue, tweenInfo, table6):Play()
        local shadowValue = button.Container.Shadow
        local table62 = {
            Size = (UDim2.new(1, button.shadowSize * 2, 1, button.shadowSize * 3)),
            Position = initialShadowPosition,
        }
        TweenService:Create(shadowValue, tweenInfo, table62):Play()

        return
    end
    button.Press = function(argument1: unknown)
        if not isEnabled then
            return
        end
        isPressed = true
        local containerValue = button.Container
        local table6 = {
            Size = (UDim2.fromScale(0.95, 0.95)),
            Position = button.Container.Position + (UDim2.new(0, 0, 0, 2)),
        }
        TweenService:Create(containerValue, tweenInfo, table6):Play()
        local shadowValue = button.Container.Shadow
        local table62 = {
            Size = (UDim2.new(1, button.shadowSize * 2, 1, button.shadowSize * 2)),
            Position = button.Container.Shadow.Position,
        }
        TweenService:Create(shadowValue, tweenInfo, table62):Play()

        return
    end
    button.Disable = function(argument1: unknown)
        isEnabled = false
        local backgroundValue = button.Container.Background
        backgroundValue.Visible = false

        return
    end
    button.Enable = function(argument1: unknown)
        isEnabled = true
        local backgroundValue = button.Container.Background
        backgroundValue.Visible = true

        return
    end
    button.GetEnabled = function(argument1: unknown): boolean
        return isEnabled
    end
    button.Clicked = function(argument1: unknown)
        if isPressed then
            if isEnabled then
                button:Reset()
                button.clickStart()
                task.wait(0.025)
                button.clickEnd()

                return
            end
        end
        button:Reset()

        return
    end
    local mouseButton1DownValue = button.Frame.Button.MouseButton1Down
    local pressValue = button.Press
    mouseButton1DownValue:Connect(pressValue)
    local mouseButton1UpValue = button.Frame.Button.MouseButton1Up
    local clickedValue = button.Clicked
    mouseButton1UpValue:Connect(clickedValue)
    local mouseLeaveValue = button.Frame.MouseLeave
    local resetValue = button.Reset
    mouseLeaveValue:Connect(resetValue)

    return button
end

return ButtonModule
