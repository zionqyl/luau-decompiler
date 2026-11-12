local function makeCounter(start)
    local value = start
    return function(delta)
        value += delta
        return function() return value end
    end
end
local counter = makeCounter(10)
local first = counter(2)
local second = counter(7)
local functions = {}
for index = 1, 3 do
    local captured = index * 10
    functions[index] = function() return captured, index end
end
print(first(), second(), functions[1](), functions[2](), functions[3]())
return first(), second(), functions[1](), functions[3]()
