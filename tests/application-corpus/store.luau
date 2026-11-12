-- Owned application module: observable key/value store with batched effects.
local Store = {}
Store.__index = Store

function Store.new()
    return setmetatable({values = {}, listeners = {}, pending = {}, depth = 0}, Store)
end

function Store:subscribe(callback)
    local record = {callback = callback, active = true}
    self.listeners[#self.listeners + 1] = record
    return function() record.active = false end
end

function Store:get(key, fallback)
    local value = self.values[key]
    if value == nil then return fallback end
    return value
end

function Store:publish(key, previous, value)
    local count = #self.listeners
    for index = 1, count do
        local record = self.listeners[index]
        if record.active then record.callback(key, previous, value) end
    end
end

function Store:set(key, value)
    local previous = self.values[key]
    if previous == value then return false end
    self.values[key] = value
    if self.depth > 0 then
        self.pending[#self.pending + 1] = {key, previous, value}
    else
        self:publish(key, previous, value)
    end
    return true
end

function Store:begin_batch()
    self.depth += 1
end

function Store:commit()
    assert(self.depth > 0)
    self.depth -= 1
    if self.depth ~= 0 then return 0 end
    local pending = self.pending
    self.pending = {}
    for _, change in ipairs(pending) do
        self:publish(change[1], change[2], change[3])
    end
    return #pending
end

return Store
