local function calculate(x, y)
    return x + y, x - y, x * y, x / y, x // y, x % y, x ^ y,
        37 - x, 37 / y, -x, not x, #"abc", "v=" .. x .. ":" .. y
end
local a, b, c, d, e, f, g, h, i, j, k, l, m = calculate(7, 2)
print(a, b, c, d, e, f, g, h, i, j, k, l, m)
return a, e, m
