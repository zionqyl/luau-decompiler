local count: number = 0
local function update(delta: number): (number, nil)
    count += delta
    return count, nil
end
return update
