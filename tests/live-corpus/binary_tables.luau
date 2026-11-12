local seed = ...
local key = if seed > 0 then "positive" else "other"
local data = { [key] = seed }
print("start", seed, string.char(0, 255))
data[key] += 2
warn("done", data[key])
return data[key], nil, "nil", "1", 1, string.char(128, 0, 254)
