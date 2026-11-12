local count = 0
return function(delta: number)
    count += delta
    return count, nil, "counter"
end
