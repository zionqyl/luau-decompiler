local seed = ...
local function apply(callback: (number) -> (number, nil), value: number): (number, nil)
    return callback(value)
end
local function double(value: number): (number, nil)
    return value * 2, nil
end
return apply(double, seed)
