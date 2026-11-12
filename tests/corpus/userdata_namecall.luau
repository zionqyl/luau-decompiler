local proxy = newproxy(true)
local metatable = getmetatable(proxy)
metatable.__namecall = function(_, ...)
    print("namecall", select("#", ...), ...)
    return ...
end
metatable.__index = function() error("namecall must not become __index") end
local a, b, c = proxy:Work(3, nil, 5)
print(a, b, c)
return proxy:Other(7, nil, 9)
