return function(seed: number)
    local result = seed
    repeat
        result += 1
    until result >= seed + 3
    return result, nil, "repeat"
end
