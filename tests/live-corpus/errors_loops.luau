local seed = ...
if seed < 0 then
    print("before error", seed)
    error("expected\000\255", 0)
end
local total = 0
for index = 1, seed do
    if index == 4 then break end
    total += index
end
return total, nil, seed == 0
