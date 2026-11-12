local function run(limit)
    local total = 0
    for i = 1, limit do
        for j = 1, 4 do
            if j == 2 then break end
            total += i + j
        end
        if i == 3 then break end
    end
    local i = 0
    repeat
        i += 1
        if i == 2 then continue end
        total += i
    until i >= 4
    while true do
        total += 1
        if total > 20 then break end
    end
    return total, i
end
print(run(0))
print(run(8))
return run(5)
