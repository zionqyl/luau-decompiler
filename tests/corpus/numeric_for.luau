local total = 0
for index = 1, 6 do
    if index == 2 then continue end
    total += index
end
for index = 5, 1, -2 do total += index end
for index = 0.5, 2, 0.5 do total += index end
for index = 3, 1 do total += 10000 end
print(total)
return total
