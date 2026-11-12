local function inspect(value)
    local result = rawset({}, "value", value)
    return type(value), typeof(result), math.clamp(value, 0, 10),
        bit32.extract(value, 2, 3), rawget(result, "value"), rawequal(result, result)
end
print(inspect(27))
print(inspect(3))
return inspect(17)
