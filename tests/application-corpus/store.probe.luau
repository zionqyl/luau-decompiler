local seed = ...
local store = module.new()
local events = 0
local detach = store:subscribe(function(key, before, after)
    events += 1
    print("store", key, before, after)
end)
assert(store:get("missing", false) == false)
assert(store:set("count", seed))
assert(not store:set("count", seed))
store:begin_batch()
store:begin_batch()
assert(store:set("count", seed + 1))
assert(store:set("binary\000", "value\255"))
assert(store:commit() == 0)
assert(events == 1)
assert(store:commit() == 2)
assert(events == 3)
detach()
assert(store:set("count", nil))
assert(events == 3)
return store:get("count", "empty"), store:get("binary\000"), events, nil
