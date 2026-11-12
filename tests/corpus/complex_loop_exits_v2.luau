local seed = ... or 1
local total = 0
local step = 0
while step < 20 do
    step += 1
    if step % 2 == 0 then
        if seed > 0 then continue end
    elseif step % 3 == 0 then
        if total > 30 then break end
    end
    if seed < 0 then
        if step > 10 then break end
        total += step * seed
        continue
    end
    total += step
end
return total, step
