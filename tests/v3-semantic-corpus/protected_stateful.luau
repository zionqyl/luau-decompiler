local count = 0
return function(value)
    local thread = coroutine.create(function()
        return pcall(function()
            count += value
            print("state", count)
            if value < 0 then error("state error", 0) end
            return count, nil, value
        end)
    end)
    return coroutine.resume(thread)
end
