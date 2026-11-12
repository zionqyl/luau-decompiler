local events = {}
local function effect(name, value)
    events[#events + 1] = name
    return value
end
local t = {}
t[effect("key", 1)] = effect("value", 7)
local x, y = effect("first", 1), effect("second", 2)
x, y = y, x
local function combine(...) return table.concat({...}, ":") end
local result = combine(effect("arg1", "one"), effect("arg2", "two"))
print(table.concat(events, ","), t[1], x, y, result)
return x, y, result
