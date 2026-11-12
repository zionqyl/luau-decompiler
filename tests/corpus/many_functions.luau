local functions = {}
functions[1] = function(value) return value + 1 end
functions[2] = function(value) return value + 2 end
functions[3] = function(value) return value + 3 end
functions[4] = function(value) return value + 4 end
functions[5] = function(value) return value + 5 end
functions[6] = function(value) return value + 6 end
functions[7] = function(value) return value + 7 end
functions[8] = function(value) return value + 8 end
functions[9] = function(value) return value + 9 end
functions[10] = function(value) return value + 10 end
functions[11] = function(value) return value + 11 end
functions[12] = function(value) return value + 12 end
functions[13] = function(value) return value + 13 end
functions[14] = function(value) return value + 14 end
functions[15] = function(value) return value + 15 end
functions[16] = function(value) return value + 16 end
local total = 0
for index, func in ipairs(functions) do total += func(index) end
print(total, functions[1] == functions[2])
return total, functions[1] == functions[2]
