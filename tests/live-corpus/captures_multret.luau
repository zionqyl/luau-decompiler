local seed = ...
local count = seed
local function update(delta)
    count += delta
    return count, nil, "value"
end
local function forward(...)
    print("call", ...)
    return ...
end
local first = update(3)
return first, forward(update(4))
