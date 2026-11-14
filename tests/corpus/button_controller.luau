local pendingButton
local function waitForClick(seconds)
    print("wait", seconds)
    pendingButton.clickEnd = function() print("late end") end
end

local defaultClickStart = function() end
local defaultClickEnd = function() end

local function createButton(frame, onClickEnd, onClickStart)
    local button = {}
    button.Frame = frame
    button.Container = frame.Container
    button.shadowSize = math.abs(button.Container.Shadow.Offset)
    button.clickStart = onClickStart or defaultClickStart
    button.clickEnd = onClickEnd or defaultClickEnd
    local isPressed = false
    local isEnabled = true
    local initialContainerPosition = button.Container.Position
    local initialShadowPosition = button.Container.Shadow.Position

    button.Reset = function(unused)
        isPressed = false
        button.Container.Position = initialContainerPosition
        button.Container.Shadow.Position = initialShadowPosition
    end
    button.Press = function(unused)
        if not isEnabled then return end
        isPressed = true
        button.Container.Position += 1
    end
    button.Disable = function(unused)
        isEnabled = false
        button.Container.Visible = false
    end
    button.Enable = function(unused)
        isEnabled = true
        button.Container.Visible = true
    end
    button.GetEnabled = function(unused)
        return isEnabled
    end
    button.Clicked = function(unused)
        if isPressed and isEnabled then
            button.Reset()
            button.clickStart()
            waitForClick(0.025)
            button.clickEnd()
            return
        end
        button.Reset()
    end
    frame.Button.MouseButton1Down:Connect(button.Press)
    frame.Button.MouseButton1Up:Connect(button.Clicked)
    return button
end

local function signal()
    return {
        Connect = function(self, callback) self.callback = callback end,
        Fire = function(self, argument) self.callback(argument) end,
    }
end
local function frame(position)
    return {
        Container = { Position = position, Shadow = { Position = position + 10, Offset = -3 }, Visible = true },
        Button = { MouseButton1Down = signal(), MouseButton1Up = signal() },
    }
end

local firstFrame = frame(10)
local secondFrame = frame(20)
local first = createButton(firstFrame, function() print("original end") end, function() print("start") end)
local second = createButton(secondFrame, false, nil)
pendingButton = first
local savedPress = first.Press
first.Press = function() print("replacement press") end
firstFrame.Button.MouseButton1Down:Fire({ event = "down" })
print("state", first.Container.Position, second.Container.Position, first.GetEnabled(999))
firstFrame.Button.MouseButton1Up:Fire(42)
print("reset", first.Container.Position, first.Container.Shadow.Position)
first.Container = { Position = 100, Shadow = { Position = 200, Offset = 9 }, Visible = true }
savedPress(false)
first.Reset(nil)
print("snapshot", first.Container.Position, first.Container.Shadow.Position, firstFrame.Container.Position)
first.Disable()
secondFrame.Button.MouseButton1Down:Fire(nil)
secondFrame.Button.MouseButton1Up:Fire(false)
print("independent", first.GetEnabled(), second.GetEnabled(), first.Container.Visible, second.Container.Visible)
local third = createButton(frame(30), nil, false)
print("defaults", rawequal(second.clickStart, third.clickStart), rawequal(second.clickEnd, third.clickEnd), rawequal(second.clickStart, second.clickEnd))
return first.Container.Position, second.Container.Position, first.shadowSize, second.GetEnabled(), rawequal(savedPress, first.Press)
