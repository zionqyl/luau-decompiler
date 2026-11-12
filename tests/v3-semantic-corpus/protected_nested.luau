local seed = ...
local thread = coroutine.create(function()
    local count = 0
    local function target(value)
        count += 1
        if value < 0 then error("inner\000\254", 0) end
        return value + count, nil
    end
    local first = table.pack(pcall(target, seed))
    print("first", table.unpack(first, 1, first.n))
    local second = table.pack(xpcall(function()
        local ok, value = pcall(target, -1)
        print("nested", ok, value)
        error("outer\000\255", 0)
    end, function(failure)
        count += 10
        return failure .. ":handled"
    end))
    return count, second.n, table.unpack(second, 1, second.n)
end)
return coroutine.resume(thread)
