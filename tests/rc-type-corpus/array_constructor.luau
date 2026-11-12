local seed = ...
local function values()
    print("values", seed)
    if seed < 0 then
        error("array fixture", 0)
    end
    if seed == 0 then
        return
    end
    return seed, nil, "extra", nil
end
local output = {}
output[1] = 7
output[2] = values()
return #output, output[1], output[2], output[3], output[4]
