local seed = ...
local thread = coroutine.create(function()
    local function target(value)
        print("target", value)
        if value < 0 then error("expected\000\255", 0) end
        return value, nil, "tail", nil
    end
    local values = table.pack(pcall(target, seed))
    return values.n, table.unpack(values, 1, values.n)
end)
return coroutine.resume(thread)
