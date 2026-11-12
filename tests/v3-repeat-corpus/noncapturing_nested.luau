local function outer()
    local function inner() return 17 end
    return inner
end
repeatCount = (repeatCount or 0) + 1
local inner = outer()
local sameOuter = previousOuter == nil or rawequal(previousOuter, outer)
local sameInner = previousInner == nil or rawequal(previousInner, inner)
previousOuter, previousInner = outer, inner
print("identity", repeatCount, sameOuter, sameInner)
return repeatCount, sameOuter, sameInner, inner()
