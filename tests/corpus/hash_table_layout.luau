local tableValue = { alpha = 1, beta = 2, gamma = 3, delta = 4, epsilon = 5,
    [3] = "three", [9] = "nine", ["end"] = "keyword" }
tableValue.zeta = 6
tableValue.beta = nil
tableValue.eta = 7
local trace = {}
for key, value in pairs(tableValue) do trace[#trace + 1] = tostring(key) .. "=" .. tostring(value) end
print(table.concat(trace, ","))
return #trace, tableValue.alpha, tableValue[3], tableValue[9]
