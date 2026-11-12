local function values(...) return ... end
local function counted(...) return select("#", ...), ... end
local function forward(prefix, ...) return prefix, values(...) end
local a, b, c, d, e = counted(values(3, nil, 9, nil))
print(a, b, c, d, e)
local t = table.pack(forward("first", values(1, nil, 2, nil)))
print(t.n, t[1], t[2], t[3], t[4], t[5])
return counted(values("tail", nil, false, nil))
