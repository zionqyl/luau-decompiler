local seed = ...
local signal = module.new()
local score = 0
local disconnect
disconnect = signal:connect(function(value, trailing)
    print("first", value, trailing)
    score += value
    assert(signal:compact() == false)
    disconnect()
    signal:connect(function(nextValue)
        print("late", nextValue)
        score += nextValue * 2
    end, false)
end, false)
signal:connect(function(value)
    print("once", value)
    score += value * 3
end, true)
assert(signal:fire(seed, nil) == 2)
assert(signal:fire(seed + 1, "tail\000") == 1)
assert(signal:compact())
assert(#signal.connections == 1)
assert(not disconnect())
assert(score == seed * 6 + 2)
return score, signal.firing, #signal.connections, nil, "tail\000"
