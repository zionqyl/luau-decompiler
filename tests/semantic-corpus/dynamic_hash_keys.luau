local seed = ... or 1
local count = 0
local function effect(value)
    count += 1
    print(count, value)
    return value
end
local key = "dynamic_" .. tostring(seed)
local values = {[key] = if seed < 0 then effect(11) else effect(19), constant = effect(13), [key] = effect(17)}
local order = ""
for field in next, values do order ..= field .. "," end
print(values[key], values.constant, count, order)
return values[key], values.constant, count, order
