local seed = ...
local function values()
    return seed, nil, "tail", nil
end
local function zero()
end
local function forward(...)
    return ...
end
local a = table.pack(forward((values())))
local b = table.pack(forward(values()))
local c = table.pack(forward((zero())))
local d = table.pack(forward(zero()))
return a.n, a[1], a[2], b.n, b[1], b[2], b[3], b[4], c.n, c[1], d.n
