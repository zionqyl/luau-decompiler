local seed = ...
local thread = coroutine.create(function()
    local ok, result = xpcall(function()
        error("target error\000\255", 0)
    end, function(failure)
        print("handler error", seed, failure)
        error(17, 0)
    end)
    return ok, result, nil
end)
return coroutine.resume(thread)
