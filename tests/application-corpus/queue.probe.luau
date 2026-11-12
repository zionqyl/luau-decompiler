local seed = ...
local queue = module.new(4)
assert(queue:size() == 0)
for index = 1, 4 do assert(queue:push(seed + index)) end
assert(not queue:push(99))
local sum = 0
local count, remaining = queue:drain(function(value, index)
    print("queue", index, value)
    sum += value
end, 3)
assert(count == 3 and remaining == 1)
assert(sum == seed * 3 + 6)
local value, present = queue:pop()
assert(present and value == seed + 4)
local empty, absent = queue:pop()
assert(empty == nil and absent == false)
assert(queue:push("binary\000\t\255"))
assert(queue:pop() == "binary\000\t\255")
return sum, count, remaining, queue:size(), nil, "binary\000\t\255"
