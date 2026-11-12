local function tail() return 3, nil, 5 end
local t = {10, 20, tail()}
local u = {name = "sample", ["end"] = "keyword", [9] = 99}
u[t[1]] = t[5]
u.name = u.name .. "!"
print(t[1], t[2], t[3], t[4], t[5], u.name, u["end"], u[9], u[10])
return t[3], t[4], t[5], u.name
