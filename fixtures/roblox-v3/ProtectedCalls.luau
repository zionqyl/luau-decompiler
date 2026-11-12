local function inner(seed: number, ...)
    if seed < 0 then error("controlled\000\255", 0) end
    if seed == 0 then
        print("before yield")
        task.wait()
        print("after yield")
    end
    return seed, nil, ...
end
return function(seed: number)
    local function protected(...)
        return pcall(inner, seed, ...)
    end
    return pcall(protected, "tail", nil)
end
