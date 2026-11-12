local function test(a, b)
    return a == b, a ~= b, a < b, a <= b, a > b, a >= b, not a, a and b, a or b
end
print(test(1, 2))
print(test(3, 3))
local function check(value)
    if value == nil then return "nil" end
    if value == true then return "true" end
    if value == false then return "false" end
    if value == 42 then return "number" end
    if value == "x" then return "string" end
    return "other"
end
print(check(nil), check(true), check(false), check(42), check("x"), check({}))
return test(2, 1)
