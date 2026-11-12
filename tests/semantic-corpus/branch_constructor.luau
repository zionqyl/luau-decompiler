local seed = ... or 1
local count = 0
local function effect(value)
    count += 1
    print(count, value)
    return value
end
local values = {if seed < 0 then effect(-7) else effect(11), if seed == 0 then nil else effect(13), (effect(17))}
print(values[1], values[2], values[3], #values)
return values[1], values[2], values[3], #values, count
