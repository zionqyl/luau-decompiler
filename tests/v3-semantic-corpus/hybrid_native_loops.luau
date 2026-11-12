local seed = ...
local total = 0
if seed < 0 then total = -10 else total = 10 end
for index = 1, 5 do
    if index == 2 then continue end
    total += index
    if index + seed > 9 then break end
end
local values = { 3, 5, 7 }
for key, value in ipairs(values) do
    if key == 2 and seed == 0 then continue end
    total += key * value
end
if seed == 1 then total += 100 elseif seed == 7 then total -= 100 end
return total
