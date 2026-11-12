local function make(value)
    return function() return value end
end
local firstValue = setmetatable({value = 1}, {__eq = function() return true end})
local otherValue = setmetatable({value = 2}, getmetatable(firstValue))
local first = make(firstValue)
local again = make(firstValue)
local other = make(otherValue)
local otherAgain = make(otherValue)
local firstAgain = make(firstValue)
local function emptyFactory() return function() return 7 end end
local empty1, empty2 = emptyFactory(), emptyFactory()
print(first == again, first == other, other == otherAgain, first == firstAgain, empty1 == empty2)
return first == again, first == other, other == otherAgain, first == firstAgain, empty1 == empty2
