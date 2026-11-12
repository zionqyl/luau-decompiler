local a = {1, nil, 3, nil, 5}
local b = {1, nil, 3, nil, 5, nil, 7, nil, 9}
local c = {1, nil, nil, nil, nil, nil, nil, 8}
local d = {nil, nil, nil, nil}
print(#a, #b, #c, #d, a[3], b[9], c[8])
return #a, #b, #c, #d
