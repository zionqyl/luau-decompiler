local events = {}
local function touch(label, value)
    events[#events + 1] = label
    return value
end
local a = touch("a", false) and touch("skip", 100)
local b = touch("b", true) and touch("c", 2) or touch("skip2", 4)
local c = touch("d", nil) or touch("e", "fallback")
local d = not (touch("f", 4) < touch("g", 7))
print(table.concat(events, ","), a, b, c, d)
return a, b, c, d
