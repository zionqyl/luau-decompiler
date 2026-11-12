local function choose(x, y, z)
    local result
    if x == y then
        result = "equal"
    elseif x < y then
        if z then result = "less yes" else result = "less no" end
    else
        result = "greater"
    end
    return result
end
print(choose(1, 1, true), choose(1, 2, true), choose(1, 2, false), choose(2, 1, false))
return choose(3, 5, false)
