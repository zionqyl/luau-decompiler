return function(seed: number)
    print("scalar", seed, "\000\255")
    return seed + 7, nil, "\128\000\254", seed == 0
end
