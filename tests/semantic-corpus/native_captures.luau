local function make(start)
    local value = start
    local function add(delta)
        value += delta
        value += 1
        return value
    end
    local function read() return value end
    return add, read
end
local add, read = make(... or 4)
print(read(), add(2), read(), add(-1), read())
return read(), add(0), read()
