local values = {4, 7, 10}
local total = 0
for index, value in ipairs(values) do total += index * value end
local function iterate(state, index)
    index += 1
    if index <= state then return index, index * 3 end
end
for index, value in iterate, 4, 0 do
    if index == 2 then continue end
    total += value
end
local object = setmetatable({}, {__iter = function() return iterate, 2, 0 end})
for index, value in object do total += index + value end
print(total)
return total
