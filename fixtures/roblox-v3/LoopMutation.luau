return function(seed: number)
    local values = { first = seed, second = seed + 1 }
    local alias = values
    local total = 0
    for index = 1, math.abs(seed) + 4 do
        if index == 4 then break end
        total += index
    end
    for _, value in { alias.first, alias.second } do
        total += value
    end
    alias.second = total
    return values.first, values.second, alias == values, nil
end
