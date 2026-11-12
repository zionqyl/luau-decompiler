local object = {value = 10}
function object:push(delta)
    self.value += delta
    return self.value, nil, "done"
end
local first, missing, last = object:push(4)
local proxy = setmetatable({value = 1}, {
    __index = function(_, key)
        print("lookup", key)
        return object.push
    end,
})
print(first, missing, last, proxy:push(7))
return object:push(2)
