-- Owned application module: synchronous signal with stable reentrant dispatch.
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({connections = {}, firing = 0}, Signal)
end

function Signal:connect(callback, once)
    local record = {callback = callback, active = true, once = once}
    self.connections[#self.connections + 1] = record
    return function()
        local previous = record.active
        record.active = false
        return previous
    end
end

function Signal:fire(...)
    local boundary = #self.connections
    self.firing += 1
    local dispatched = 0
    for index = 1, boundary do
        local record = self.connections[index]
        if record.active then
            if record.once then
                record.active = false
            end
            dispatched += 1
            record.callback(...)
        end
    end
    self.firing -= 1
    return dispatched
end

function Signal:compact()
    if self.firing ~= 0 then return false end
    local compacted = {}
    for _, record in ipairs(self.connections) do
        if record.active then
            compacted[#compacted + 1] = record
        end
    end
    self.connections = compacted
    return true
end

return Signal
