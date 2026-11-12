local index, total = 0, 0
while index < 10 do
    index += 1
    if index == 3 then continue end
    if index == 8 then break end
    total += index
end
repeat
    total -= 2
until total < 10
print(index, total)
return index, total
