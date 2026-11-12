local seed = ... or 1
local first = seed + 1
print(first)
do
    local second = first * 2
    print(second)
end
local third = tostring(first)
print(third)
local function selectValue(flag)
    local result
    if flag then result = 10 else result = 20 end
    return result
end
return selectValue(seed > 0)
