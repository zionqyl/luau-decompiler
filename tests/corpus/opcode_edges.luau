moduleCounter = 21
local function arithmeticConstants(value)
    return value / 3, value % 3, value ^ 3, value // 3
end
local function choices(value)
    return value and 23, value or 45
end
local first = ("hello"):sub(2)
print(moduleCounter, arithmeticConstants(7))
print(choices(false))
print(choices(0))
moduleCounter += 1
return moduleCounter, first, choices(nil)
