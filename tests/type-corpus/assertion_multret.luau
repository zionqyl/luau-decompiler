local function values(): (number, nil, number)
    return 7, nil, 9
end
local asserted = table.pack(values() :: number)
local scalar = table.pack((values()))
local multiple = table.pack(values())
return asserted.n, asserted[1], asserted[2], scalar.n, multiple.n, multiple[1], multiple[2], multiple[3], nil
