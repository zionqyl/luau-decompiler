return function(seed: number)
    warn("local", seed, "\000\255")
    return seed, "client local", nil
end
