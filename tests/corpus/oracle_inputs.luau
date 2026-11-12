local value, optional = ...
print("input", type(value), value, optional, select("#", ...))
if type(value) == "number" then
    local doubled = value * 2
    print(doubled)
    return value, doubled, optional, nil
elseif type(value) == "string" then
    return value, #value, optional, nil
elseif value == false then
    error("false input\000\255", 0)
end
return value, optional, nil
