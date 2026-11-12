local child = {value = 1}
local root = {nested = {entries = {child}}}
local alias = child
local function reveal()
    return root
end
return function(mutate)
    mutate(reveal)
    return alias.value
end
