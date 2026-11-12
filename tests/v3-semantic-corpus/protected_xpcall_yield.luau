local seed = ...
local thread = coroutine.create(function(value)
    return xpcall(function()
        local nextValue = coroutine.yield("protected", value)
        if nextValue < 0 then error("yield error\000\255", 0) end
        return nextValue, nil, "done", nil
    end, function(failure)
        print("handler", failure)
        return failure .. "!"
    end)
end)
local first = table.pack(coroutine.resume(thread, seed))
print("first", first.n, table.unpack(first, 1, first.n))
local last = table.pack(coroutine.resume(thread, seed))
return last.n, table.unpack(last, 1, last.n)
