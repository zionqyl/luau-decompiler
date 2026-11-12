local seed = ...
local value: number? = nil
if seed > 0 then
    value = seed
end
return value, nil, seed == 0
