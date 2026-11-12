local events = {}
local mt = {}
local function note(event) events[#events + 1] = event end
mt.__add = function(a, b) note("add"); return a.value + b.value end
mt.__lt = function(a, b) note("lt"); return a.value < b.value end
mt.__le = function(a, b) note("le"); return a.value <= b.value end
mt.__eq = function(a, b) note("eq"); return a.value == b.value end
mt.__concat = function(a, b) note("concat"); return a.value .. b.value end
mt.__call = function(a, x) note("call"); return a.value * x end
mt.__index = function(_, key) note("index:" .. key); return 42 end
mt.__newindex = function(t, key, value) note("newindex:" .. key); rawset(t, key, value) end
local a = setmetatable({value = 2}, mt)
local b = setmetatable({value = 3}, mt)
local sum, less, le, equal, text, called = a + b, a < b, a <= b, a == b, a .. b, a(4)
local absent = a.absent
a.extra = 6
print(table.concat(events, ","), sum, less, le, equal, text, called, absent, a.extra)
return sum, less, le, equal, text, called, absent
