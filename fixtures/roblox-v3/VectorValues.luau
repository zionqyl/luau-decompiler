return function(seed: number)
    local value = Vector3.new(seed, 2, 3)
    local cross = value:Cross(Vector3.new(0, 1, 0))
    return value, cross, value.Magnitude, nil
end
