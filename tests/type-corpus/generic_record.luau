local seed = ...
local function wrap<T>(value: T)
    return { value = value, valid = true }
end
local numberBox = wrap(seed)
local stringBox = wrap("\128\000\255")
return numberBox.value, numberBox.valid, stringBox.value, stringBox.valid, nil
