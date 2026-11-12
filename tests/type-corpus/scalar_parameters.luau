local seed = ...
local function describe(value: number, label: string?): (number, string?, nil)
    local adjusted: number = value + 2
    return adjusted, label, nil
end
return describe(seed, if seed > 0 then "positive" else nil)
