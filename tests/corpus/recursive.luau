local factorial
factorial = function(n)
    if n <= 1 then return 1 end
    return n * factorial(n - 1)
end
local function outer(x)
    local function middle(y)
        return function(z) x += 1; return x + y + z end
    end
    return middle(5)
end
local f = outer(10)
print(factorial(6), f(3), f(3))
return factorial(6), f(0)
