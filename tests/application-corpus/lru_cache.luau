-- Owned application module: deterministic LRU cache for client resource paths.
local Cache = {}
Cache.__index = Cache

function Cache.new(capacity)
    return setmetatable({nodes = {}, newest = nil, oldest = nil, size = 0, capacity = capacity}, Cache)
end

function Cache:unlink(node)
    if node.previous then node.previous.next = node.next else self.oldest = node.next end
    if node.next then node.next.previous = node.previous else self.newest = node.previous end
    node.previous = nil
    node.next = nil
end

function Cache:append(node)
    node.previous = self.newest
    node.next = nil
    if self.newest then self.newest.next = node else self.oldest = node end
    self.newest = node
end

function Cache:get(key)
    local node = self.nodes[key]
    if not node then return nil, false end
    self:unlink(node)
    self:append(node)
    return node.value, true
end

function Cache:put(key, value)
    local node = self.nodes[key]
    if node then
        node.value = value
        self:unlink(node)
    else
        node = {key = key, value = value}
        self.nodes[key] = node
        self.size += 1
    end
    self:append(node)
    if self.size > self.capacity then
        local removed = self.oldest
        self:unlink(removed)
        self.nodes[removed.key] = nil
        self.size -= 1
        return removed.key, removed.value
    end
    return nil, nil
end

function Cache:keys()
    local keys = {}
    local node = self.oldest
    while node do
        keys[#keys + 1] = node.key
        node = node.next
    end
    return table.concat(keys, "|")
end

return Cache
