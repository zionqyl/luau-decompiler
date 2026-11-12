local count = 0
local function update(delta)
    count += delta
    return count
end
repeatCount = (repeatCount or 0) + 1
local same = previousUpdate == nil or rawequal(previousUpdate, update)
local old = if previousUpdate then previousUpdate(1) else -1
previousUpdate = update
local current = update(2)
print("reference", repeatCount, same, old, current)
return repeatCount, same, old, current
