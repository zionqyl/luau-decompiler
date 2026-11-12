local Test = require("./native-test-v3")
local observe = Test._observe_for_tests
local descriptor = { probe = "scalar_function" }
local function entry(fn)
    return function() return fn end
end
local function encoded(fn, probe)
    local original = entry(fn)
    local environment = getfenv(original)
    local frame, failure = observe(original, nil, probe or descriptor, {}, 7)
    assert(getfenv(original) == environment, "observer leaked a test environment")
    assert(frame and not failure)
    return frame
end
local negatives = {
    { function() return 1 end, function() return "1" end },
    { function() return nil end, function() return "nil" end },
    { function() return "a\tb", "c" end, function() return "a", "b\tc" end },
    { function() return "\000\255" end, function() return "\000\254" end },
    { function() return 1, nil end, function() return 1 end },
    { function() error("expected\000\255", 0) end, function() error("expected\000\254", 0) end },
    { function() print(1); warn("x"); return nil end, function() warn("x"); print(1); return nil end },
}
for _, pair in negatives do assert(encoded(pair[1]) ~= encoded(pair[2]), "typed observation collision") end
local stateful = { probe = "stateful_function" }
assert(encoded(function() return 1, nil, "third" end, stateful)
    ~= encoded(function() return 1, nil, "different third" end, stateful), "stateful probe dropped a return value")
local frame = observe(entry(function() pcall(function() print({}) end); return 1 end), nil, descriptor, {}, 7)
assert(frame == nil, "caught unsupported print was counted as complete")
frame = observe(entry(function() return {} end), nil, descriptor, {}, 7)
assert(frame == nil, "opaque terminal counted as complete")
frame = observe(function() return nil end, nil, descriptor, {}, 7)
assert(frame == nil, "unexpected entry result counted as equivalent program error")
local stable = function(value) return value end
local original = entry(stable)
local state = {}
local first = observe(original, nil, descriptor, state, 7)
local second = observe(original, nil, descriptor, state, 7)
assert(first ~= second, "repeated loaded-entry closure identity was not observed")
print("native-v3 observer conformance: 8 collision negatives and 3 incomplete observations rejected")
