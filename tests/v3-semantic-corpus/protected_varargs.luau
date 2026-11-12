local seed = ...
local thread = coroutine.create(function()
    local function forward(...)
        return pcall(function(...)
            print("arguments", select("#", ...), ...)
            return ...
        end, ...)
    end
    local result = table.pack(forward(seed, nil, "value\000\255", nil))
    return result.n, table.unpack(result, 1, result.n)
end)
return coroutine.resume(thread)
