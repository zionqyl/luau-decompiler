local seed = ...
local function build(flag, ...)
    return { if flag then 17 else 23, ... }
end
local result = build(seed > 0, nil, seed, "tail", nil)
for key, value in pairs(result) do print(key, value) end
return #result, result[1], result[2], result[3], result[4], result[5]
