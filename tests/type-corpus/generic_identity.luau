local seed = ...
local function identity<T>(value: T): T
    return value
end
return identity(seed), identity("\000\255"), identity(nil), nil
