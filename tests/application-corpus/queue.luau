-- Owned application module: bounded FIFO used for client event work queues.
local Queue = {}
Queue.__index = Queue

function Queue.new(capacity)
    return setmetatable({items = {}, first = 1, last = 0, capacity = capacity}, Queue)
end

function Queue:push(value)
    if self.last - self.first + 1 >= self.capacity then
        return false
    end
    self.last += 1
    self.items[self.last] = value
    return true
end

function Queue:pop()
    if self.first > self.last then
        return nil, false
    end
    local value = self.items[self.first]
    self.items[self.first] = nil
    self.first += 1
    if self.first > self.last then
        self.first = 1
        self.last = 0
    end
    return value, true
end

function Queue:size()
    return self.last - self.first + 1
end

function Queue:drain(consume, limit)
    local count = 0
    while count < limit do
        local value, present = self:pop()
        if not present then
            break
        end
        count += 1
        consume(value, count)
    end
    return count, self:size()
end

return Queue
