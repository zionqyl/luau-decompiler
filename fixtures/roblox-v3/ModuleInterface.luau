local count = 0
local module = {}
function module.update(delta: number)
    count += delta
    return count, nil
end
function module.snapshot()
    return { count = count, version = 3 }
end
return module
