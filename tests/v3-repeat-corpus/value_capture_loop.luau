local value = ...
local current
for index = 1, 2 do
    current = function() return value end
end
repeatCount = (repeatCount or 0) + 1
local same = previousValue == nil or rawequal(previousValue, current)
previousValue = current
print("value", repeatCount, same, current())
return repeatCount, same, current()
