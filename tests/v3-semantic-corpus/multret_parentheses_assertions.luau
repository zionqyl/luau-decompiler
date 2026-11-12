local seed = ...
local function values()
    print("values", seed)
    return seed, nil, "tail", nil
end
local expanded = { values() }
local grouped = { (values()) }
local asserted = { (values() :: any) }
print("tables", #expanded, #grouped, #asserted)
local expandedCount = select("#", values())
local groupedCount = select("#", (values()))
local assertedCount = select("#", (values() :: any))
return expandedCount, groupedCount, assertedCount, grouped[1], grouped[2], asserted[1], asserted[2]
