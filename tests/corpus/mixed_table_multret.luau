local function tail() return 7, nil, 9 end
local t = { label = "mixed", 1, 2, tail() }
print(t.label, t[1], t[2], t[3], t[4], t[5])
local function build(...)
    return { ["end"] = 42, 10, ... }
end
local u = build(20, nil, 40)
print(u["end"], u[1], u[2], u[3], u[4])
return t.label, t[5], u["end"], u[4]
