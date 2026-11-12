local seed = ...
local object = { field = seed, status = "initial" }
local alias = object
if seed > 0 then
    alias.field = "changed"
else
    alias.field += 1
end
return object.field, alias.status, object == alias
