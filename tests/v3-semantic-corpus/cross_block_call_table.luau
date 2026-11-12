local seed = ...
local function tail(value)
    print("tail", value)
    return value, nil, "last", nil
end
local result = { if seed > 0 then 31 else 47, tail(seed) }
for key, value in pairs(result) do print(key, value) end
return #result, result[1], result[2], result[3], result[4], result[5]
