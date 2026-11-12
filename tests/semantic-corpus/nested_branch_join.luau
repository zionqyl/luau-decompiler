local seed, token = ...
local total = seed + 2
local effects = 0
local function mark(value)
    print("mark", effects, value, token)
    return value
end
if seed < 0 then
    local value = total * 6
    if value < 0 then total = -value else total = value + 2 end
else
    local value = total - 2
    total = value * 6
end
local selected = (total > seed and mark(total)) or mark(seed)
