local functions = {}
local index = 0
while index < 4 do
    index += 1
    local value = index
    functions[index] = function(delta) value += delta; return value end
end
do
    local replaced = 100
    functions[5] = function() return replaced end
end
local replaced = 200
print(functions[1](10), functions[2](10), functions[1](0), functions[5](), replaced)
return functions[3](1), functions[4](2), functions[5]()
